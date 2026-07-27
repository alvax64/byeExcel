# Snapshot layer: the immutable graph record of an imported workbook.
# Nodes here are evidence - never edited after import. Inference reads them,
# and canonical-model provenance edges will point back at them.

import from ingest.xlsx_reader { WorkbookData, read_workbook_file, read_workbook_bytes }

node Workbook {
    has filename: str,
        checksum: str,
        imported_at: str,
        sheets_truncated: bool = False;
}

node Sheet {
    has name: str,
        sheet_index: int,
        row_count: int = 0,
        rows_truncated: bool = False;
}

node Column {
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

edge HasSheet: Workbook --> Sheet {}
edge HasColumn: Sheet --> Column {}

def ingest_workbook_data(data: WorkbookData) -> Workbook {
    # same checksum = same snapshot: re-importing an unchanged file is a no-op
    existing = [root-->[?:Workbook, checksum==data.checksum]];
    if existing {
        return existing[0];
    }

    wb = Workbook(
        filename=data.filename,
        checksum=data.checksum,
        imported_at=data.imported_at,
        sheets_truncated=data.sheets_truncated
    );
    root ++> wb;
    for sheet_data in data.sheets {
        sheet = Sheet(
            name=sheet_data.name,
            sheet_index=sheet_data.sheet_index,
            row_count=sheet_data.row_count,
            rows_truncated=sheet_data.rows_truncated
        );
        wb +>:HasSheet:+> sheet;
        for column_data in sheet_data.columns {
            column = Column(
                header=column_data.header,
                col_index=column_data.col_index,
                n_int=column_data.n_int,
                n_float=column_data.n_float,
                n_bool=column_data.n_bool,
                n_date=column_data.n_date,
                n_text=column_data.n_text,
                n_formula=column_data.n_formula,
                n_empty=column_data.n_empty,
                samples=list(column_data.samples)
            );
            sheet +>:HasColumn:+> column;
        }
    }
    return wb;
}

def ingest_workbook_file(path: str) -> Workbook {
    return ingest_workbook_data(read_workbook_file(path));
}

def ingest_workbook_bytes(data: bytes, filename: str) -> Workbook {
    return ingest_workbook_data(read_workbook_bytes(data, filename));
}

def list_workbooks -> list[Workbook] {
    return [root-->[?:Workbook]];
}

def workbook_sheets(wb: Workbook) -> list[Sheet] {
    return [wb->:HasSheet:->];
}

def sheet_columns(sheet: Sheet) -> list[Column] {
    return [sheet->:HasColumn:->];
}
