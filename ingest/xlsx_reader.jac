# Typed boundary around openpyxl: the ONLY module allowed to touch spreadsheet
# parsing. Workbooks are untrusted input, so reads are read_only (no macro
# execution), capped in size, and retain only normalized cell values needed to
# seed the generated system.

import hashlib;
import io;
import openpyxl;
import from datetime { datetime, date, timezone }
import from os.path { basename }

glob MAX_SHEETS: int = 25,
     MAX_COLS: int = 256,
     MAX_DATA_ROWS: int = 5000,
     MAX_SAMPLES: int = 20,
     MAX_CELL_TEXT: int = 120;

obj ColumnData {
    has header: str,
        col_index: int,
        n_int: int = 0,
        n_float: int = 0,
        n_bool: int = 0,
        n_date: int = 0,
        n_text: int = 0,
        n_formula: int = 0,
        n_empty: int = 0,
        samples: list[str] = [];
}

obj SheetData {
    has name: str,
        sheet_index: int,
        row_count: int = 0,
        rows_truncated: bool = False,
        columns: list[ColumnData] = [],
        records: list[dict[str, str]] = [];
}

obj WorkbookData {
    has filename: str,
        checksum: str,
        imported_at: str,
        sheets: list[SheetData] = [],
        sheets_truncated: bool = False;
}

def read_workbook_bytes(data: bytes, filename: str) -> WorkbookData {
    checksum = hashlib.sha256(data).hexdigest();
    imported_at = datetime.now(timezone.utc).isoformat();
    result = WorkbookData(
        filename=filename, checksum=checksum, imported_at=imported_at
    );

    wb = openpyxl.load_workbook(io.BytesIO(data), read_only=True, data_only=False);
    # openpyxl is an untyped Python boundary; its public API guarantees strings.
    sheet_names: list[str] = wb.sheetnames as list[str];
    if len(sheet_names) > MAX_SHEETS {
        result.sheets_truncated = True;
        sheet_names = sheet_names[:MAX_SHEETS];
    }
    sheet_index = 0;
    for sheet_name in sheet_names {
        ws = wb[sheet_name];
        result.sheets.append(_read_sheet(ws, str(sheet_name), sheet_index));
        sheet_index += 1;
    }
    wb.close();
    return result;
}

def read_workbook_file(path: str) -> WorkbookData {
    with open(path, "rb") as fh {
        data = fh.read();
    }
    return read_workbook_bytes(data, basename(path));
}

def _read_sheet(ws: any, name: str, sheet_index: int) -> SheetData {
    sheet = SheetData(name=name, sheet_index=sheet_index);
    header_seen = False;
    for row in ws.iter_rows(values_only=True) {
        if not header_seen {
            _init_columns(sheet, row);
            header_seen = True;
            continue;
        }
        if sheet.row_count >= MAX_DATA_ROWS {
            sheet.rows_truncated = True;
            break;
        }
        _tally_row(sheet, row);
        values = _record_values(sheet, row);
        if values {
            sheet.records.append(values);
        }
        sheet.row_count += 1;
    }
    return sheet;
}

def _init_columns(sheet: SheetData, row: any) {
    col_index = 0;
    for value in row {
        if col_index >= MAX_COLS {
            break;
        }
        header = _cell_text(value) if value is not None else "";
        if header == "" {
            header = f"col_{col_index + 1}";
        }
        sheet.columns.append(ColumnData(header=header, col_index=col_index));
        col_index += 1;
    }
}

def _tally_row(sheet: SheetData, row: any) {
    col_index = 0;
    for value in row {
        if col_index >= len(sheet.columns) {
            break;
        }
        _tally_cell(sheet.columns[col_index], value);
        col_index += 1;
    }
    # rows shorter than the header still count one empty cell per missing column
    while col_index < len(sheet.columns) {
        sheet.columns[col_index].n_empty += 1;
        col_index += 1;
    }
}

def _record_values(sheet: SheetData, row: any) -> dict[str, str] {
    values: dict[str, str] = {};
    col_index = 0;
    for value in row {
        if col_index >= len(sheet.columns) {
            break;
        }
        if value is not None {
            text = _cell_text(value);
            if text != "" {
                values[sheet.columns[col_index].header] = text;
            }
        }
        col_index += 1;
    }
    return values;
}

def _tally_cell(col: ColumnData, value: any) -> None {
    if value is None {
        col.n_empty += 1;
        return;
    }
    # bool must be checked before int: Python bools are ints
    if isinstance(value, bool) {
        col.n_bool += 1;
    } elif isinstance(value, int) {
        col.n_int += 1;
    } elif isinstance(value, float) {
        col.n_float += 1;
    } elif isinstance(value, datetime) or isinstance(value, date) {
        col.n_date += 1;
    } else {
        text = _cell_text(value);
        if text == "" {
            col.n_empty += 1;
            return;
        }
        if text.startswith("=") {
            col.n_formula += 1;
        } else {
            col.n_text += 1;
        }
    }
    _add_sample(col, value);
}

def _add_sample(col: ColumnData, value: any) -> None {
    if len(col.samples) >= MAX_SAMPLES {
        return;
    }
    text = _cell_text(value);
    if text not in col.samples {
        col.samples.append(text);
    }
}

def _cell_text(value: any) -> str {
    text = str(value).strip();
    if len(text) > MAX_CELL_TEXT {
        text = text[:MAX_CELL_TEXT];
    }
    return text;
}
