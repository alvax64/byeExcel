# byeExcel — 4-minute demo script (JacHacks SF 2026)

Judged on: Use of Jac 40% · Use case 20% · Execution 20% · Demo & story 20%.
Rubric mandate: *say who it's for → run the core workflow live → show where Jac runs.*

## 0:00–0:40 — Who it's for, what breaks

> "Doña Rosa runs a hardware store in Lima. Her entire business lives in one
> Excel file: sales, customers, inventory. It works — until she needs a second
> user, validation, or history. Excel *is* her software; it just can't grow.
> byeExcel turns the spreadsheet that already runs a business into real
> software — with human review in the middle, because you don't blindly
> generate someone's business system."

## 0:40–2:30 — Core workflow, live (demo/ferreteria_dona_rosa.xlsx)

1. Open the app. Type business context: *"I run a hardware store in Lima,
   I track sales, customers and inventory."*
2. Upload `ferreteria_dona_rosa.xlsx`. Narrate while it analyzes:
   - "We parse it read-only — never executing spreadsheet macros."
3. Walk the proposed model on screen:
   - Three entities from three sheets; AI-suggested names + descriptions.
   - Field types inferred from evidence: dates, decimals, booleans — point at
     `Total` detected as **formula**, `Pagado` as **boolean** with a blank.
   - **Relations found by traversal**: Ventas → Clientes via 'Cliente',
     Ventas → Productos via 'Producto' — each with its evidence line.
   - Accents handled: `Categoría`, `Teléfono` normalized correctly.
4. Land the thesis: "Nothing gets generated until a human approves this model.
   Inference proposes; the owner decides."

## 2:30–3:30 — Where Jac runs (repo open in editor)

- `model/infer.jac` — **walker `InferSchema`**: abilities per node type
  (`Root`/`Workbook`/`Sheet`/`Column`), real multi-hop graph traversal over
  the snapshot; relations linked by walking the proposal graph.
- Same file — **`by llm`** with `sem` prompts: the LLM is a *suggester* with
  a heuristic fallback; it can't block inference or skip review.
- `ingest/source.jac` — the immutable snapshot layer: every proposed field
  has provenance edges back to the exact sheet/column it came from.
- One line on the stack: "Server, graph persistence, typed RPC and this React
  UI are one Jac codebase — 18 files, 16 tests."

## 3:30–4:00 — Close

> "Excel is the world's most successful database — and its least maintainable.
> byeExcel meets businesses where they already are: their own spreadsheet,
> reviewed by them, turned into software they own. Built in one day, in Jac."

## Contingencies

- **No wifi / no API key** → suggestions fall back to heuristic sheet names;
  everything else is identical. Do not mention it unless asked.
- **Upload fails on stage** → `Imported workbooks` list keeps prior uploads:
  click the existing entry to reopen its proposal (state persists in the graph).
- **Question "is the LLM deciding the schema?"** → No: deterministic
  heuristics + graph evidence decide; the LLM only names and describes, and
  the human approves.
