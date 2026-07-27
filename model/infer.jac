# Schema inference: walks the immutable snapshot graph (Workbook -> Sheet ->
# Column) and builds a Proposal in the mutable layer. Heuristics are
# deterministic - the LLM is a best-effort *suggester* of names/descriptions
# that never blocks inference and never skips human review.

import os;
import unicodedata;
import from datetime { datetime, timezone }
import from jaclang.byllm.lib { Model }
import from ingest.source { Workbook, Sheet, Column }
import from model.proposal {
    FieldType, Proposal, Entity, Field,
    ProposalFor, HasEntity, HasField, FromSheet, FromColumn, RelatesTo
}

glob llm: Model = Model(model_name=os.environ.get("BYLLM_DEFAULT_MODEL", "gpt-4o-mini"));

obj TypeGuess {
    has field_type: FieldType,
        confidence: float;
}

obj SheetBrief {
    has sheet_name: str,
        headers: list[str],
        sample_values: list[str];
}
sem SheetBrief.sheet_name = "Name of the spreadsheet sheet as the business wrote it.";
sem SheetBrief.headers = "Column headers of the sheet, in order.";
sem SheetBrief.sample_values = "A few representative cell values from the sheet.";

obj EntitySuggestion {
    has sheet_name: str,
        entity_name: str,
        description: str;
}
sem EntitySuggestion.sheet_name = "The sheet this suggestion is for - copy it verbatim from the input.";
sem EntitySuggestion.entity_name = "Clean singular entity name in the sheet's language, PascalCase, e.g. 'Venta' for a 'Ventas' sheet.";
sem EntitySuggestion.description = "One short sentence: what one row of this sheet represents for the business.";

def suggest_entities(business_context: str, sheets: list[SheetBrief]) -> list[EntitySuggestion] by llm(temperature=0.2);
sem suggest_entities = "Given the sheets of a small-business spreadsheet and the owner's description of their business, propose one entity per sheet: a clean singular name and a one-line description. Suggestions only - a human reviews them.";
sem suggest_entities.business_context = "The owner's own words about what the workbook is used for. May be empty.";
sem suggest_entities.sheets = "One brief per sheet: name, headers, and sample values.";

walker InferSchema {
    has checksum: str;
    has business_context: str = "",
        enrich: bool = False,
        reports: list[Proposal] = [],
        proposal: Proposal | None = None,
        entity_by_sheet: dict[str, Entity] = {};

    can locate with Root entry {
        target = [root -->[?:Workbook, checksum == self.checksum]];
        if not target {
            disengage;
        }
        visit target;
    }

    can start with Workbook entry {
        p = Proposal(
            source_checksum=here.checksum,
            created_at=datetime.now(timezone.utc).isoformat(),
            enriched=self.enrich
        );
        root ++> p;
        p +>:ProposalFor:+> here;
        self.proposal = p;
        visit [here ->:HasSheet:->];
    }

    can map_sheet with Sheet entry {
        p = self.proposal;
        if not isinstance(p, Proposal) {
            disengage;
        }
        entity = Entity(name=here.name, source_sheet=here.name);
        p +>:HasEntity:+> entity;
        entity +>:FromSheet:+> here;
        self.entity_by_sheet[jid(here)] = entity;
        visit [here ->:HasColumn:->];
    }

    can map_column with Column entry {
        # BFS may interleave columns of different sheets: resolve the parent
        # sheet through the graph, never through "current sheet" walker state.
        parents = [here <-:HasColumn:<-];
        if not parents {
            skip;
        }
        entity = self.entity_by_sheet[jid(parents[0])];
        guess = _guess_type(here);
        field = Field(
            name=here.header,
            field_type=guess.field_type,
            required=(here.n_empty == 0 and guess.confidence > 0.0),
            key_candidate=_is_key_candidate(here.header),
            type_confidence=guess.confidence
        );
        entity +>:HasField:+> field;
        field +>:FromColumn:+> here;
    }

    can finish with Root exit {
        p = self.proposal;
        if isinstance(p, Proposal) {
            _link_relations(p);
            if self.enrich {
                _enrich_proposal(p, self.business_context);
            }
            report p;
        }
    }
}

def _guess_type(col: Column) -> TypeGuess {
    # ints are valid decimals, so a mixed numeric column is DECIMAL
    numeric = col.n_int + col.n_float;
    total = numeric + col.n_bool + col.n_date + col.n_text + col.n_formula;
    if total == 0 {
        return TypeGuess(field_type=FieldType.UNKNOWN, confidence=0.0);
    }
    best_type = FieldType.DECIMAL if col.n_float > 0 else FieldType.INTEGER;
    best_count = numeric;
    if col.n_bool > best_count {
        best_type = FieldType.BOOLEAN;
        best_count = col.n_bool;
    }
    if col.n_date > best_count {
        best_type = FieldType.DATE;
        best_count = col.n_date;
    }
    if col.n_text > best_count {
        best_type = FieldType.TEXT;
        best_count = col.n_text;
    }
    if col.n_formula > best_count {
        best_type = FieldType.FORMULA;
        best_count = col.n_formula;
    }
    return TypeGuess(field_type=best_type, confidence=best_count / total);
}

def _normalize(text: str) -> str {
    decomposed = unicodedata.normalize("NFD", text.lower().strip());
    cleaned = "".join([ch for ch in decomposed if not unicodedata.combining(ch)]);
    return cleaned.replace(" ", "_");
}

def _is_key_candidate(header: str) -> bool {
    n = _normalize(header);
    if n in ["id", "codigo", "code", "dni", "ruc", "sku"] {
        return True;
    }
    return n.startswith("id_") or n.endswith("_id");
}

def _relation_stem(header: str) -> str {
    n = _normalize(header);
    if n.endswith("_id") {
        n = n[:-3];
    } elif n.startswith("id_") {
        n = n[3:];
    }
    if n in ["id", "codigo", "code"] {
        return "";
    }
    return n;
}

def _matches_entity(stem: str, other: Entity) -> bool {
    other_name = _normalize(other.source_sheet);
    return stem == other_name or f"{stem}s" == other_name or stem == f"{other_name}s";
}

def _link_relations(p: Proposal) -> None {
    entities = [p ->:HasEntity:->];
    for entity in entities {
        for field in [entity ->:HasField:->] {
            stem = _relation_stem(field.name);
            if stem == "" {
                continue;
            }
            for other in entities {
                if other is entity {
                    continue;
                }
                if _matches_entity(stem, other) {
                    entity +>:RelatesTo(
                        via_field=field.name,
                        confidence=0.6,
                        evidence=f"column '{field.name}' matches sheet '{other.source_sheet}' by name"
                    ):+> other;
                }
            }
        }
    }
}

def _enrich_proposal(p: Proposal, business_context: str) -> None {
    entities = [p ->:HasEntity:->];
    briefs: list[SheetBrief] = [];
    for entity in entities {
        fields = [entity ->:HasField:->];
        headers = [f.name for f in fields];
        samples: list[str] = [];
        for f in fields {
            for col in [f ->:FromColumn:->] {
                samples.extend(col.samples[:2]);
            }
        }
        briefs.append(SheetBrief(
            sheet_name=entity.source_sheet,
            headers=headers,
            sample_values=samples[:8]
        ));
    }
    if not briefs {
        return;
    }
    try {
        suggestions = suggest_entities(business_context, briefs);
        for s in suggestions {
            for entity in entities {
                if entity.source_sheet == s.sheet_name {
                    entity.suggested_name = s.entity_name;
                    entity.description = s.description;
                }
            }
        }
    } except Exception {
        # the suggester is best-effort: heuristic names stand if the model
        # is unreachable, and inference itself never fails because of it
    }
}
