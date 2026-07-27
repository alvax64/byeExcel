# Tests for the snapshot graph layer. Graph tests build WorkbookData by hand -
# the typed boundary means no spreadsheet parsing is needed here. Assertions
# filter by unique checksums so they stay valid on a persisted root (tests
# share .jac/data between runs).

import os;
import tempfile;
import openpyxl;
import from ingest.xlsx_reader { WorkbookData, SheetData, ColumnData }

def _snapshot(checksum: str) -> WorkbookData {
    return WorkbookData(
        filename="ventas.xlsx",
        checksum=checksum,
        imported_at="2026-07-26T00:00:00+00:00",
        sheets=[
            SheetData(
                name="Ventas",
                sheet_index=0,
                row_count=2,
                columns=[
                    ColumnData(
                        header="Producto",
                        col_index=0,
                        n_text=2,
                        samples=["Polo", "Gorra"]
                    ),
                    ColumnData(
                        header="Precio",
                        col_index=1,
                        n_float=2,
                        samples=["59.9", "35.0"]
                    )
                ]
            ),
            SheetData(name="Vacia", sheet_index=1)
        ]
    );
}

test "ingest builds the snapshot graph" {
    wb = ingest_workbook_data(_snapshot("cs-graph"));
    assert wb.filename == "ventas.xlsx";
    sheets = workbook_sheets(wb);
    assert [s.name for s in sheets] == ["Ventas", "Vacia"];
    cols = sheet_columns(sheets[0]);
    assert [c.header for c in cols] == ["Producto", "Precio"];
    assert cols[1].n_float == 2;
    assert cols[0].samples == ["Polo", "Gorra"];
    assert sheet_columns(sheets[1]) == [];
}

test "re-ingesting the same checksum returns the existing node" {
    first = ingest_workbook_data(_snapshot("cs-idem"));
    second = ingest_workbook_data(_snapshot("cs-idem"));
    assert jid(first) == jid(second);
    assert len([root-->[?:Workbook, checksum=="cs-idem"]]) == 1;
}

test "different checksums create separate workbooks" {
    _ = ingest_workbook_data(_snapshot("cs-v1"));
    _ = ingest_workbook_data(_snapshot("cs-v2"));
    assert len([root-->[?:Workbook, checksum=="cs-v1"]]) == 1;
    assert len([root-->[?:Workbook, checksum=="cs-v2"]]) == 1;
}

test "ingest from an xlsx file end to end" {
    fixture = openpyxl.Workbook();
    ws = fixture.active;
    ws.title = "Inventario";
    ws.append(["Item", "Stock"]);
    ws.append(["Tornillo", 120]);
    ws.append(["Clavo", 80]);
    filename = f"byeexcel_ingest_{os.getpid()}.xlsx";
    path = os.path.join(tempfile.gettempdir(), filename);
    fixture.save(path);

    imported = ingest_workbook_file(path);
    os.remove(path);

    assert imported.filename == filename;
    sheets = workbook_sheets(imported);
    assert len(sheets) == 1;
    assert sheets[0].name == "Inventario";
    assert sheets[0].row_count == 2;
    cols = sheet_columns(sheets[0]);
    assert [c.header for c in cols] == ["Item", "Stock"];
    assert cols[1].n_int == 2;
}
