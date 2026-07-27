# Demo-facing API: anonymous (:pub) endpoints running on the guest graph,
# returning view models so the UI never depends on graph node shapes.
# Post-hackathon: switch to :priv + login so each business owns its data.

import base64;
import from ingest.source {
    Workbook,
    ingest_workbook_bytes,
    list_workbooks,
    workbook_sheets
}
import from model.proposal {
    Proposal,
    workbook_proposals,
    latest_proposal,
    proposal_entities,
    entity_fields,
    RelatesTo
}
import from model.infer { InferSchema }

obj FieldView {
    has name: str,
        field_type: str,
        required: bool,
        key_candidate: bool,
        confidence: float;
}

obj RelationView {
    has via_field: str,
        target_entity: str,
        evidence: str,
        confidence: float;
}

obj EntityView {
    has name: str,
        suggested_name: str,
        description: str,
        source_sheet: str,
        fields: list[FieldView] = [],
        relations: list[RelationView] = [];
}

obj ProposalView {
    has checksum: str,
        filename: str,
        created_at: str,
        enriched: bool = False,
        entities: list[EntityView] = [];
}

obj WorkbookView {
    has filename: str,
        checksum: str,
        imported_at: str,
        sheet_count: int = 0,
        proposal_count: int = 0;
}

def:pub upload_workbook(
    filename: str, content_b64: str, business_context: str = ""
) -> ProposalView | None {
    data = base64.b64decode(content_b64);
    wb = ingest_workbook_bytes(data, filename);
    result = root spawn InferSchema(
        checksum=wb.checksum, business_context=business_context, enrich=True
    );
    if not result.reports {
        return None;
    }
    return _proposal_view(wb, result.reports[0]);
}

def:pub workbooks_view -> list[WorkbookView] {
    views: list[WorkbookView] = [];
    for wb in list_workbooks() {
        views.append(
            WorkbookView(
                filename=wb.filename,
                checksum=wb.checksum,
                imported_at=wb.imported_at,
                sheet_count=len(workbook_sheets(wb)),
                proposal_count=len(workbook_proposals(wb))
            )
        );
    }
    return views;
}

def:pub proposal_view(wb_checksum: str) -> ProposalView | None {
    matches = [root-->[?:Workbook, checksum==wb_checksum]];
    if not matches {
        return None;
    }
    wb = matches[0];
    p = latest_proposal(wb);
    if not isinstance(p, Proposal) {
        return None;
    }
    return _proposal_view(wb, p);
}

def _proposal_view(wb: Workbook, p: Proposal) -> ProposalView {
    views: list[EntityView] = [];
    for entity in proposal_entities(p) {
        fviews: list[FieldView] = [];
        for f in entity_fields(entity) {
            fviews.append(
                FieldView(
                    name=f.name,
                    field_type=str(f.field_type),
                    required=f.required,
                    key_candidate=f.key_candidate,
                    confidence=f.type_confidence
                )
            );
        }
        rviews: list[RelationView] = [];
        for target in [entity->:RelatesTo:->] {
            for e in [edge entity->:RelatesTo:->target] {
                rviews.append(
                    RelationView(
                        via_field=e.via_field,
                        target_entity=target.source_sheet,
                        evidence=e.evidence,
                        confidence=e.confidence
                    )
                );
            }
        }
        views.append(
            EntityView(
                name=entity.name,
                suggested_name=entity.suggested_name,
                description=entity.description,
                source_sheet=entity.source_sheet,
                fields=fviews,
                relations=rviews
            )
        );
    }
    return ProposalView(
        checksum=p.source_checksum,
        filename=wb.filename,
        created_at=p.created_at,
        enriched=p.enriched,
        entities=views
    );
}
