# Canonical layer: immutable, versioned snapshots of an approved model.
# Approval deep-copies the proposal into frozen nodes so later edits to the
# (mutable) proposal can never mutate an approved version. The generator
# (future) reads ONLY these versions - never raw proposals.

import from datetime { datetime, timezone }
import from ingest.source { Workbook }
import from model.proposal {
    Proposal,
    FieldType,
    proposal_entities,
    entity_fields,
    RelatesTo
}

node ModelVersion {
    has source_checksum: str,
        version: int,
        approved_at: str;
}

node CanonicalEntity {
    has name: str,
        description: str = "",
        source_sheet: str = "";
}

node CanonicalField {
    has name: str,
        field_type: FieldType = FieldType.UNKNOWN,
        required: bool = False,
        key_candidate: bool = False;
}

edge VersionOf: ModelVersion --> Workbook {}
edge ApprovedFrom: ModelVersion --> Proposal {}
edge FrozenEntity: ModelVersion --> CanonicalEntity {}
edge FrozenField: CanonicalEntity --> CanonicalField {}

edge FrozenRelation: CanonicalEntity --> CanonicalEntity {
    has via_field: str;
}

def workbook_versions(wb: Workbook) -> list[ModelVersion] {
    return [wb<-:VersionOf:<-];
}

def version_entities(v: ModelVersion) -> list[CanonicalEntity] {
    return [v->:FrozenEntity:->];
}

def entity_frozen_fields(entity: CanonicalEntity) -> list[CanonicalField] {
    return [entity->:FrozenField:->];
}

def freeze_proposal(wb: Workbook, p: Proposal) -> ModelVersion {
    # approving accepts what the review screen shows: the suggested name
    # when present, the heuristic name otherwise
    frozen_version = ModelVersion(
        source_checksum=p.source_checksum,
        version=len([wb<-:VersionOf:<-]) + 1,
        approved_at=datetime.now(timezone.utc).isoformat()
    );
    root ++> frozen_version;
    frozen_version +>:VersionOf:+> wb;
    frozen_version +>:ApprovedFrom:+> p;

    frozen_by_sheet: dict[str, CanonicalEntity] = {};
    entities = proposal_entities(p);
    for entity in entities {
        frozen = CanonicalEntity(
            name=(entity.suggested_name or entity.name),
            description=entity.description,
            source_sheet=entity.source_sheet
        );
        frozen_version +>:FrozenEntity:+> frozen;
        frozen_by_sheet[entity.source_sheet] = frozen;
        for f in entity_fields(entity) {
            frozen +>:FrozenField:+> CanonicalField(
                name=f.name,
                field_type=f.field_type,
                required=f.required,
                key_candidate=f.key_candidate
            );
        }
    }
    for entity in entities {
        source = frozen_by_sheet[entity.source_sheet];
        for target in [entity->:RelatesTo:->] {
            for e in [edge entity->:RelatesTo:->target] {
                source +>:FrozenRelation(via_field=e.via_field):+> frozen_by_sheet[
                    target.source_sheet
                ];
            }
        }
    }
    return frozen_version;
}
