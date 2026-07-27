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
import from generation.system {
    GeneratedSystem,
    approve_and_generate,
    generated_system_for_checksum,
    generated_modules,
    generated_fields,
    generated_records,
    relation_options,
    add_generated_record
}

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

obj GeneratedFieldView {
    has name: str,
        field_type: str,
        input_type: str,
        required: bool,
        key_candidate: bool,
        relation_target: str = "",
        options: list[str] = [];
}

obj GeneratedRecordView {
    has record_id: str,
        values: dict[str, str],
        created_at: str;
}

obj GeneratedEntityView {
    has entity_key: str,
        name: str,
        route: str,
        description: str = "",
        fields: list[GeneratedFieldView] = [],
        records: list[GeneratedRecordView] = [];
}

obj GeneratedSystemView {
    has checksum: str,
        name: str,
        version_id: str,
        manifest_hash: str,
        generated_at: str,
        generator_version: str,
        entities: list[GeneratedEntityView] = [];
}

obj RecordMutationView {
    has ok: bool,
        error: str = "",
        system: GeneratedSystemView | None = None;
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

def:pub generate_system(
    wb_checksum: str, system_name: str = ""
) -> GeneratedSystemView | None {
    matches = [root-->[?:Workbook, checksum==wb_checksum]];
    if not matches {
        return None;
    }
    wb = matches[0];
    p = latest_proposal(wb);
    if not isinstance(p, Proposal) {
        return None;
    }
    generated_name = system_name.strip();
    if generated_name == "" {
        generated_name = wb.filename.rsplit(".", 1)[0] + " System";
    }
    system = approve_and_generate(p, generated_name);
    return _generated_system_view(system);
}

def:pub generated_system_view(wb_checksum: str) -> GeneratedSystemView | None {
    system = generated_system_for_checksum(wb_checksum);
    if not isinstance(system, GeneratedSystem) {
        return None;
    }
    return _generated_system_view(system);
}

def:pub create_generated_record(
    wb_checksum: str, entity_key: str, values: dict[str, str]
) -> RecordMutationView {
    system = generated_system_for_checksum(wb_checksum);
    if not isinstance(system, GeneratedSystem) {
        return RecordMutationView(
            ok=False, error="Generate the system before adding records."
        );
    }
    try {
        _ = add_generated_record(system, entity_key, values);
        return RecordMutationView(ok=True, system=_generated_system_view(system));
    } except ValueError as e {
        return RecordMutationView(
            ok=False, error=str(e), system=_generated_system_view(system)
        );
    }
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

def _generated_system_view(system: GeneratedSystem) -> GeneratedSystemView {
    entity_views: list[GeneratedEntityView] = [];
    for module in generated_modules(system) {
        field_views: list[GeneratedFieldView] = [];
        for field in generated_fields(module) {
            input_type = "text";
            field_options: list[str] = [];
            if field.relation_target != "" {
                input_type = "select";
                field_options = relation_options(system, field.relation_target);
            } elif field.field_type in ["integer", "decimal"] {
                input_type = "number";
            } elif field.field_type == "date" {
                input_type = "date";
            }
            field_views.append(
                GeneratedFieldView(
                    name=field.name,
                    field_type=field.field_type,
                    input_type=input_type,
                    required=field.required,
                    key_candidate=field.key_candidate,
                    relation_target=field.relation_target,
                    options=field_options
                )
            );
        }
        record_views: list[GeneratedRecordView] = [];
        for record in generated_records(module) {
            record_views.append(
                GeneratedRecordView(
                    record_id=record.record_id,
                    values=dict(record.values),
                    created_at=record.created_at
                )
            );
        }
        entity_views.append(
            GeneratedEntityView(
                entity_key=module.entity_key,
                name=module.name,
                route=module.route,
                description=module.description,
                fields=field_views,
                records=record_views
            )
        );
    }
    return GeneratedSystemView(
        checksum=system.source_checksum,
        name=system.name,
        version_id=system.version_id,
        manifest_hash=system.manifest_hash,
        generated_at=system.generated_at,
        generator_version=system.generator_version,
        entities=entity_views
    );
}
