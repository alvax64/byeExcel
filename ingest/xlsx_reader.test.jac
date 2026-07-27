# Tests for the openpyxl boundary. Fixtures are built in memory with openpyxl
# itself - no binary files in the repo.

import io;
import openpyxl;
import from datetime { datetime }

def _fixture_clientes() -> bytes {
    wb = openpyxl.Workbook();
    ws = wb.active;
    ws.title = "Clientes";
    ws.append(["Nombre", "Edad", "Saldo", "Activo", "Alta", "Total"]);
    ws.append(["Ana", 34, 1500.5, True, datetime(2026, 1, 5), "=C2*2"]);
    ws.append(["Luis", 28, 900.25, False, datetime(2026, 2, 10), "=C3*2"]);
    ws.append(["Rosa", 41]);
    extras = wb.create_sheet("Extras");
    extras.append(["", None, "Codigo"]);
    extras.append([1, 2, "A1"]);
    buf = io.BytesIO();
    wb.save(buf);
    return buf.getvalue();
}

test "reader extracts sheet and column facts" {
    parsed = read_workbook_bytes(_fixture_clientes(), "clientes.xlsx");
    assert parsed.filename == "clientes.xlsx";
    assert not parsed.sheets_truncated;
    assert len(parsed.sheets) == 2;

    clientes = parsed.sheets[0];
    assert clientes.name == "Clientes";
    assert clientes.sheet_index == 0;
    assert clientes.row_count == 3;
    assert not clientes.rows_truncated;
    headers = [c.header for c in clientes.columns];
    assert headers == ["Nombre", "Edad", "Saldo", "Activo", "Alta", "Total"];

    assert clientes.columns[0].n_text == 3;
    assert clientes.columns[1].n_int == 3;
    assert clientes.columns[2].n_float == 2;
    assert clientes.columns[2].n_empty == 1;
    assert clientes.columns[3].n_bool == 2;
    assert clientes.columns[4].n_date == 2;
    assert clientes.columns[5].n_formula == 2;
    assert clientes.columns[5].n_empty == 1;
    assert "Ana" in clientes.columns[0].samples;
}

test "reader names blank headers positionally" {
    parsed = read_workbook_bytes(_fixture_clientes(), "clientes.xlsx");
    extras = parsed.sheets[1];
    assert extras.name == "Extras";
    assert [c.header for c in extras.columns] == ["col_1", "col_2", "Codigo"];
    assert extras.row_count == 1;
}

test "reader caps samples and cell text" {
    wb = openpyxl.Workbook();
    ws = wb.active;
    ws.append(["Valores"]);
    ws.append(["y" * 300]);
    for i in range(25) {
        ws.append([f"val_{i}"]);
    }
    buf = io.BytesIO();
    wb.save(buf);

    parsed = read_workbook_bytes(buf.getvalue(), "muchos.xlsx");
    col = parsed.sheets[0].columns[0];
    assert col.n_text == 26;
    assert len(col.samples) == MAX_SAMPLES;
    assert len(col.samples[0]) == MAX_CELL_TEXT;
}

test "checksum is stable for identical bytes" {
    data = _fixture_clientes();
    a = read_workbook_bytes(data, "a.xlsx");
    b = read_workbook_bytes(data, "b.xlsx");
    assert a.checksum == b.checksum;
    assert len(a.checksum) == 64;
}
