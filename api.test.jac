# Tests for the demo API: the full flow (base64 xlsx -> ingest -> infer ->
# view models) without HTTP - endpoints are called in-process against the
# test root. Fixtures are built in memory with openpyxl.

import io;
import base64;
import openpyxl;

def _xlsx_b64 -> str {
    wb = openpyxl.Workbook();
    ws = wb.active;
    ws.title = "Pedidos";
    ws.append(["ID", "Cliente", "Total"]);
    ws.append([1, "Ana", 120.5]);
    ws.append([2, "Luis", 80.0]);
    clientes = wb.create_sheet("Clientes");
    clientes.append(["DNI", "Nombre"]);
    clientes.append(["45678901", "Ana"]);
    buf = io.BytesIO();
    wb.save(buf);
    return base64.b64encode(buf.getvalue()).decode("ascii");
}

test "upload workbook returns a full proposal view" {
    view = upload_workbook("pedidos.xlsx", _xlsx_b64(), "Vendo por pedidos");
    assert view is not None;
    assert view.filename == "pedidos.xlsx";
    assert [e.name for e in view.entities] == ["Pedidos", "Clientes"];

    pedidos = view.entities[0];
    assert [f.name for f in pedidos.fields] == ["ID", "Cliente", "Total"];
    assert pedidos.fields[0].field_type == "integer";
    assert pedidos.fields[0].key_candidate;
    assert pedidos.fields[2].field_type == "decimal";
    assert len(pedidos.relations) == 1;
    assert pedidos.relations[0].target_entity == "Clientes";
    assert pedidos.relations[0].via_field == "Cliente";
}

test "workbooks view lists uploads with proposal counts" {
    _ = upload_workbook("pedidos.xlsx", _xlsx_b64());
    listed = [
        v
        for v in workbooks_view()
        if v.filename == "pedidos.xlsx"
    ];
    assert len(listed) == 1;
    assert listed[0].sheet_count == 2;
    assert listed[0].proposal_count >= 1;

    pv = proposal_view(listed[0].checksum);
    assert pv is not None;
    assert len(pv.entities) == 2;
}

test "proposal view for unknown checksum is None" {
    assert proposal_view("cs-nope") is None;
}

test "approved proposal generates a usable system" {
    proposal = upload_workbook(
        "pedidos-generados.xlsx", _xlsx_b64(), "Vendo por pedidos"
    );
    assert proposal is not None;
    generated = generate_system(proposal.checksum, "Pedidos Operativos");
    assert generated is not None;
    assert generated.name == "Pedidos Operativos";
    assert len(generated.version_id) == 12;
    assert [e.entity_key for e in generated.entities] == ["Pedidos", "Clientes"];
    assert [f.name for f in generated.entities[0].fields] == ["ID", "Cliente", "Total"];
    assert len(generated.entities[0].records) == 2;
    assert generated.entities[0].records[0].values["Cliente"] == "Ana";
    assert generated.entities[0].fields[1].input_type == "select";
    assert generated.entities[0].fields[1].relation_target == "Clientes";

    reopened = generated_system_view(proposal.checksum);
    assert reopened is not None;
    assert reopened.version_id == generated.version_id;
}

test "generated module accepts and validates records" {
    proposal = upload_workbook("pedidos-registros.xlsx", _xlsx_b64());
    assert proposal is not None;
    generated = generate_system(proposal.checksum);
    assert generated is not None;

    saved = create_generated_record(
        proposal.checksum, "Pedidos", {"ID": "3", "Cliente": "Rosa", "Total": "45.90"}
    );
    assert saved.ok;
    assert saved.system is not None;
    assert len(saved.system.entities[0].records) == 3;
    assert saved.system.entities[0].records[-1].values["Cliente"] == "Rosa";

    invalid = create_generated_record(
        proposal.checksum,
        "Pedidos",
        {"ID": "", "Cliente": "Rosa", "Total": "not-a-number"}
    );
    assert not invalid.ok;
    assert invalid.error != "";
}
