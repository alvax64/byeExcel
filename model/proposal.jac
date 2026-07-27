# Proposal layer: the mutable, review-facing output of inference. Built by
# InferSchema from the immutable snapshot, edited by the user during review,
# and frozen into the canonical model on approval (future PR). Provenance
# edges point back at the snapshot so every proposed piece is explainable.

import from ingest.source { Workbook, Sheet, Column }

enum FieldType: str {
    INTEGER = "integer",
    DECIMAL = "decimal",
    BOOLEAN = "boolean",
    DATE = "date",
    TEXT = "text",
    FORMULA = "formula",
    UNKNOWN = "unknown"
}

node Proposal {
    has source_checksum: str,
        created_at: str,
        enriched: bool = False;
}

node Entity {
    has name: str,
        source_sheet: str,
        suggested_name: str = "",
        description: str = "";
}

node Field {
    has name: str,
        field_type: FieldType = FieldType.UNKNOWN,
        required: bool = False,
        key_candidate: bool = False,
        type_confidence: float = 0.0;
}

edge ProposalFor: Proposal --> Workbook {}
edge HasEntity: Proposal --> Entity {}
edge HasField: Entity --> Field {}
edge FromSheet: Entity --> Sheet {}
edge FromColumn: Field --> Column {}

edge RelatesTo: Entity --> Entity {
    has via_field: str,
        confidence: float,
        evidence: str;
}

def workbook_proposals(wb: Workbook) -> list[Proposal] {
    return [wb<-:ProposalFor:<-];
}

def latest_proposal(wb: Workbook) -> Proposal | None {
    proposals = [wb<-:ProposalFor:<-];
    return proposals[-1] if proposals else None;
}

def proposal_entities(p: Proposal) -> list[Entity] {
    return [p->:HasEntity:->];
}

def entity_fields(entity: Entity) -> list[Field] {
    return [entity->:HasField:->];
}

def entity_source_sheet(entity: Entity) -> Sheet | None {
    sources = [entity->:FromSheet:->];
    return sources[0] if sources else None;
}

def field_source_column(field: Field) -> Column | None {
    sources = [field->:FromColumn:->];
    return sources[0] if sources else None;
}
