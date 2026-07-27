# Tests for schema inference. The heuristic core runs with enrich=False (no
# LLM involved); the byLLM path is exercised with MockLLM by rebinding the
# module's `llm` glob - no API keys needed. Checksums are unique per test so
# assertions survive a persisted root between runs.

import from jaclang.byllm.lib { MockLLM }
import from ingest.xlsx_reader { WorkbookData, SheetData, ColumnData }
import from ingest.source { ingest_workbook_data }
import from model.proposal {
    FieldType,
    proposal_entities,
    entity_fields,
    entity_source_sheet,
    field_source_column,
    workbook_proposals,
    RelatesTo
}

def _tienda_snapshot(checksum: str) -> WorkbookData {
    return WorkbookData(
        filename="tienda.xlsx",
        checksum=checksum,
        imported_at="2026-07-26T00:00:00+00:00",
        sheets=[
            SheetData(
                name="Ventas",
                sheet_index=0,
                row_count=3,
                columns=[
                    ColumnData(
                        header="ID", col_index=0, n_int=3, samples=["1", "2", "3"]
                    ),
                    ColumnData(
                        header="Cliente", col_index=1, n_text=3, samples=["Ana", "Luis"]
                    ),
                    ColumnData(
                        header="Monto",
                        col_index=2,
                        n_int=1,
                        n_float=2,
                        samples=["100", "59.9"]
                    ),
                    ColumnData(
                        header="Fecha", col_index=3, n_date=3, samples=["2026-01-05"]
                    ),
                    ColumnData(
                        header="Nota",
                        col_index=4,
                        n_text=2,
                        n_empty=1,
                        samples=["al contado"]
                    )
                ]
            ),
            SheetData(
                name="Clientes",
                sheet_index=1,
                row_count=2,
                columns=[
                    ColumnData(
                        header="DNI", col_index=0, n_int=2, samples=["45678901"]
                    ),
                    ColumnData(header="Nombre", col_index=1, n_text=2, samples=["Ana"])
                ]
            )
        ]
    );
}

test "infer builds a proposal with typed fields" {
    wb = ingest_workbook_data(_tienda_snapshot("cs-infer-1"));
    result = root spawn InferSchema(checksum="cs-infer-1");
    assert len(result.reports) == 1;
    p = result.reports[0];
    assert p.source_checksum == "cs-infer-1";
    assert p in workbook_proposals(wb);

    entities = proposal_entities(p);
    assert [e.name for e in entities] == ["Ventas", "Clientes"];

    fields = entity_fields(entities[0]);
    assert [f.name for f in fields] == ["ID", "Cliente", "Monto", "Fecha", "Nota"];
    assert fields[0].field_type == FieldType.INTEGER;
    assert fields[0].key_candidate;
    assert fields[2].field_type == FieldType.DECIMAL;
    assert fields[3].field_type == FieldType.DATE;
    assert fields[3].required;
    assert not fields[4].required;

    clientes_fields = entity_fields(entities[1]);
    assert clientes_fields[0].key_candidate;
}

test "relations are proposed from column-to-sheet name match" {
    _ = ingest_workbook_data(_tienda_snapshot("cs-infer-2"));
    result = root spawn InferSchema(checksum="cs-infer-2");
    entities = proposal_entities(result.reports[0]);

    linked = [entities[0]->:RelatesTo:->];
    assert len(linked) == 1;
    assert linked[0] is entities[1];

    rels = [edge entities[0]->:RelatesTo:->];
    assert rels[0].via_field == "Cliente";
    assert rels[0].confidence > 0.0;
    assert "Clientes" in rels[0].evidence;
}

test "provenance edges point back at the snapshot" {
    _ = ingest_workbook_data(_tienda_snapshot("cs-infer-3"));
    result = root spawn InferSchema(checksum="cs-infer-3");
    entities = proposal_entities(result.reports[0]);

    source_sheet = entity_source_sheet(entities[0]);
    assert source_sheet is not None and source_sheet.name == "Ventas";

    first_field = entity_fields(entities[0])[0];
    source_col = field_source_column(first_field);
    assert source_col is not None and source_col.header == "ID";
}

test "unknown workbook reports nothing" {
    result = root spawn InferSchema(checksum="cs-missing");
    assert len(result.reports) == 0;
}

test "mockllm suggestions land on entities" {
    llm = MockLLM(
        model_name="mockllm",
        config={
            "outputs": [
                [
                    EntitySuggestion(
                        sheet_name="Ventas",
                        entity_name="Venta",
                        description="Una venta registrada de la tienda."
                    ),
                    EntitySuggestion(
                        sheet_name="Clientes",
                        entity_name="Cliente",
                        description="Un cliente de la tienda."
                    )
                ]
            ]
        }
    );
    _ = ingest_workbook_data(_tienda_snapshot("cs-infer-4"));
    result = root spawn InferSchema(
        checksum="cs-infer-4",
        enrich=True,
        business_context="Vendo ropa en Gamarra y anoto todo en Excel"
    );
    p = result.reports[0];
    assert p.enriched;
    entities = proposal_entities(p);
    assert entities[0].suggested_name == "Venta";
    assert entities[1].suggested_name == "Cliente";
    assert entities[1].description != "";
}
