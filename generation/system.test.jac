# Tests for approval, deterministic generation, and generated records.

import from model.proposal { Proposal, Entity, Field, FieldType, HasEntity, HasField }

def _generation_proposal(checksum: str) -> Proposal {
    p = Proposal(source_checksum=checksum, created_at="2026-07-27T00:00:00+00:00");
    root ++> p;
    entity = Entity(
        name="Clientes",
        source_sheet="Clientes",
        suggested_name="Customer",
        description="A customer account."
    );
    p +>:HasEntity:+> entity;
    entity +>:HasField:+> Field(
        name="Customer ID",
        field_type=FieldType.TEXT,
        required=True,
        key_candidate=True,
        type_confidence=1.0
    );
    entity +>:HasField:+> Field(
        name="Credit Limit",
        field_type=FieldType.DECIMAL,
        required=False,
        type_confidence=1.0
    );
    return p;
}

test "approval produces a versioned generated system" {
    p = _generation_proposal("cs-generate-1");
    system = approve_and_generate(p, "Customer Manager");
    assert system.source_checksum == "cs-generate-1";
    assert len(system.version_id) == 12;
    assert system.generator_version == "byeexcel-generator-v1";

    modules = generated_modules(system);
    assert len(modules) == 1;
    assert modules[0].name == "Customer";
    assert modules[0].route == "/customer";
    assert [f.name for f in generated_fields(modules[0])] == [
        "Customer ID",
        "Credit Limit"
    ];
}

test "generation is idempotent for an unchanged proposal" {
    p = _generation_proposal("cs-generate-2");
    first = approve_and_generate(p, "First name");
    second = approve_and_generate(p, "Changed name");
    assert jid(first) == jid(second);
    assert first.version_id == second.version_id;
}

test "generated records validate and persist" {
    p = _generation_proposal("cs-generate-3");
    system = approve_and_generate(p, "Customer Manager");
    record = add_generated_record(
        system, "Clientes", {"Customer ID": "CUS-001", "Credit Limit": "1250.50"}
    );
    assert record.values["Customer ID"] == "CUS-001";
    module = generated_modules(system)[0];
    assert generated_records(module)[0].record_id == record.record_id;

    try {
        _ = add_generated_record(
            system, "Clientes", {"Customer ID": "", "Credit Limit": "not-a-number"}
        );
        assert False , "invalid generated record should fail";
    } except ValueError {
        assert True;
    }
}
