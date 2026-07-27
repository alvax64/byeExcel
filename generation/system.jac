# Approval and deterministic generation for the first usable byeExcel system.
# A proposal is frozen into a versioned canonical model before generation.
# Generated records live on the generated module, never on the source evidence
# or canonical schema.

import hashlib;
import re;
import from datetime { datetime, timezone }
import from model.proposal { Proposal, proposal_entities, entity_fields, RelatesTo }

node CanonicalModel {
    has source_checksum: str,
        manifest_hash: str,
        version_id: str,
        approved_at: str;
}

node CanonicalEntity {
    has entity_key: str,
        name: str,
        source_sheet: str,
        description: str = "";
}

node CanonicalField {
    has name: str,
        field_type: str,
        required: bool,
        key_candidate: bool;
}

node CanonicalRelation {
    has source_key: str,
        target_key: str,
        via_field: str;
}

node GeneratedSystem {
    has source_checksum: str,
        manifest_hash: str,
        version_id: str,
        name: str,
        generated_at: str,
        generator_version: str = "byeexcel-generator-v1";
}

node GeneratedModule {
    has entity_key: str,
        name: str,
        route: str,
        description: str = "";
}

node GeneratedField {
    has name: str,
        field_type: str,
        required: bool,
        key_candidate: bool;
}

node GeneratedRecord {
    has record_id: str,
        values: dict[str, str],
        created_at: str;
}

edge ApprovedFrom: CanonicalModel --> Proposal {}
edge HasCanonicalEntity: CanonicalModel --> CanonicalEntity {}
edge HasCanonicalField: CanonicalEntity --> CanonicalField {}
edge HasCanonicalRelation: CanonicalModel --> CanonicalRelation {}
edge GeneratedFrom: GeneratedSystem --> CanonicalModel {}
edge HasGeneratedModule: GeneratedSystem --> GeneratedModule {}
edge HasGeneratedField: GeneratedModule --> GeneratedField {}
edge HasGeneratedRecord: GeneratedModule --> GeneratedRecord {}

def approve_and_generate(p: Proposal, system_name: str) -> GeneratedSystem {
    manifest = _proposal_manifest(p);
    proposal_hash = hashlib.sha256(manifest.encode("utf-8")).hexdigest();
    existing = [root-->[?:GeneratedSystem, manifest_hash==proposal_hash]];
    if existing {
        return existing[-1];
    }

    approved_at = datetime.now(timezone.utc).isoformat();
    canonical = CanonicalModel(
        source_checksum=p.source_checksum,
        manifest_hash=proposal_hash,
        version_id=proposal_hash[:12],
        approved_at=approved_at
    );
    root ++> canonical;
    canonical +>:ApprovedFrom:+> p;

    for entity in proposal_entities(p) {
        entity_name = entity.suggested_name or entity.name;
        canonical_entity = CanonicalEntity(
            entity_key=entity.source_sheet,
            name=entity_name,
            source_sheet=entity.source_sheet,
            description=entity.description
        );
        canonical +>:HasCanonicalEntity:+> canonical_entity;
        for field in entity_fields(entity) {
            canonical_entity +>:HasCanonicalField:+> CanonicalField(
                name=field.name,
                field_type=str(field.field_type),
                required=field.required,
                key_candidate=field.key_candidate
            );
        }
        for target in [entity->:RelatesTo:->] {
            for rel in [edge entity->:RelatesTo:->target] {
                canonical +>:HasCanonicalRelation:+> CanonicalRelation(
                    source_key=entity.source_sheet,
                    target_key=target.source_sheet,
                    via_field=rel.via_field
                );
            }
        }
    }

    generated_name = system_name.strip() or "Generated business system";
    system = GeneratedSystem(
        source_checksum=p.source_checksum,
        manifest_hash=proposal_hash,
        version_id=proposal_hash[:12],
        name=generated_name,
        generated_at=approved_at
    );
    root ++> system;
    system +>:GeneratedFrom:+> canonical;

    for canonical_entity in canonical_entities(canonical) {
        module = GeneratedModule(
            entity_key=canonical_entity.entity_key,
            name=canonical_entity.name,
            route="/" + _slugify(canonical_entity.name),
            description=canonical_entity.description
        );
        system +>:HasGeneratedModule:+> module;
        for field in canonical_fields(canonical_entity) {
            module +>:HasGeneratedField:+> GeneratedField(
                name=field.name,
                field_type=field.field_type,
                required=field.required,
                key_candidate=field.key_candidate
            );
        }
    }
    return system;
}

def generated_system_for_checksum(checksum: str) -> GeneratedSystem | None {
    matches = [root-->[?:GeneratedSystem, source_checksum==checksum]];
    return matches[-1] if matches else None;
}

def canonical_entities(model: CanonicalModel) -> list[CanonicalEntity] {
    return [model->:HasCanonicalEntity:->];
}

def canonical_fields(entity: CanonicalEntity) -> list[CanonicalField] {
    return [entity->:HasCanonicalField:->];
}

def generated_modules(system: GeneratedSystem) -> list[GeneratedModule] {
    return [system->:HasGeneratedModule:->];
}

def generated_fields(module: GeneratedModule) -> list[GeneratedField] {
    return [module->:HasGeneratedField:->];
}

def generated_records(module: GeneratedModule) -> list[GeneratedRecord] {
    return [module->:HasGeneratedRecord:->];
}

def find_generated_module(
    system: GeneratedSystem, entity_key: str
) -> GeneratedModule | None {
    for module in generated_modules(system) {
        if module.entity_key == entity_key {
            return module;
        }
    }
    return None;
}

def add_generated_record(
    system: GeneratedSystem, entity_key: str, values: dict[str, str]
) -> GeneratedRecord {
    module = find_generated_module(system, entity_key);
    if not isinstance(module, GeneratedModule) {
        raise ValueError("Generated module not found.");
    }

    cleaned: dict[str, str] = {};
    has_value = False;
    for field in generated_fields(module) {
        value = (values.get(field.name) or "").strip();
        if field.required and value == "" {
            raise ValueError("'" + field.name + "' is required.");
        }
        _validate_value(field, value);
        cleaned[field.name] = value;
        if value != "" {
            has_value = True;
        }
    }
    if not has_value {
        raise ValueError("Enter at least one value.");
    }

    created_at = datetime.now(timezone.utc).isoformat();
    record_seed = (
        system.manifest_hash + entity_key + created_at + repr(sorted(cleaned.items()))
    );
    record = GeneratedRecord(
        record_id=hashlib.sha256(record_seed.encode("utf-8")).hexdigest()[:12],
        values=cleaned,
        created_at=created_at
    );
    module +>:HasGeneratedRecord:+> record;
    return record;
}

def _validate_value(field: GeneratedField, value: str) {
    if value == "" {
        return;
    }
    try {
        if field.field_type == "integer" {
            _ = int(value);
        } elif field.field_type == "decimal" {
            _ = float(value);
        } elif (
            field.field_type == "boolean"
            and value.lower() not in ["true", "false", "yes", "no", "1", "0"]
        ) {
            raise ValueError("invalid boolean");
        }
    } except ValueError {
        raise ValueError(
            "'" + field.name + "' must be a valid " + field.field_type + "."
        );
    }
}

def _proposal_manifest(p: Proposal) -> str {
    parts: list[str] = ["source:" + p.source_checksum];
    for entity in proposal_entities(p) {
        entity_name = entity.suggested_name or entity.name;
        parts.append(
            "entity:" + entity.source_sheet + ":" + entity_name + ":" + entity.description
        );
        for field in entity_fields(entity) {
            parts.append(
                "field:" + entity.source_sheet + ":" + field.name + ":" + str(
                    field.field_type
                ) + ":" + str(field.required) + ":" + str(field.key_candidate)
            );
        }
        for target in [entity->:RelatesTo:->] {
            for rel in [edge entity->:RelatesTo:->target] {
                parts.append(
                    "relation:" + entity.source_sheet + ":" + target.source_sheet + ":" + rel.via_field
                );
            }
        }
    }
    return "\n".join(parts);
}

def _slugify(name: str) -> str {
    slug = re.sub("[^a-z0-9]+", "-", name.lower()).strip("-");
    return slug or "module";
}
