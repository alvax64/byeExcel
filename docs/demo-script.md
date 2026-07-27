# byeExcel — 4-minute demo script (JacHacks SF 2026)

Judged on: Use of Jac 40% · Use case 20% · Execution 20% · Demo & story 20%.
Rubric mandate: *say who it's for → run the core workflow live → show where Jac runs.*

Live app: https://aule-server.tail92f367.ts.net/ · Demo file: `demo/ferreteria_dona_rosa.xlsx`
(Hard-refresh — Cmd+Shift+R — before going on stage.)

## 0:00–0:35 — Who it's for, what breaks

> "Doña Rosa runs a hardware store in Lima. Her whole business lives in one
> Excel file: sales, customers, inventory. It works — until she needs a second
> user, validation, or history. Excel *is* her software; it just can't grow.
> byeExcel turns the spreadsheet that already runs a business into real
> software — with human review in the middle."

## 0:35–2:10 — Upload and review, live

1. Type business context: *"I run a hardware store in Lima: sales, customers,
   inventory."* Upload `ferreteria_dona_rosa.xlsx`.
   - While it analyzes: "Parsed read-only — spreadsheet macros never execute."
2. Walk the proposed model:
   - Three entities from three sheets. Field types inferred from evidence —
     point at `Total` = **formula**, `Pagado` = **boolean**, `Fecha` = required.
   - **Relations found by graph traversal**: Ventas → Clientes via 'Cliente',
     Ventas → Productos via 'Producto' — each with its evidence line.
   - Accents normalized: `Categoría`, `Teléfono`.
3. Thesis: "Inference proposes; Rosa decides. Nothing is generated until a
   human approves this model."

## 2:10–3:00 — Approve & generate, live (the money shot)

1. Click **Approve & generate system**.
   - "Approval freezes the model as an immutable version — and generates a
     working data application from it."
2. In the generated system, add a sale — but **leave `Fecha` empty** and hit
   save: it rejects with *"'Fecha' is required."*
   - "The generated app enforces the rules we inferred from her spreadsheet.
     Evidence → model → running system, end to end."
3. Fill the date, save — the record lands.

## 3:00–3:40 — Where Jac runs (repo open in editor)

- `model/infer.jac` — **walker `InferSchema`**: abilities per node type,
  multi-hop graph traversal over the snapshot; plus **`by llm`** with `sem`
  prompts — the LLM only *suggests* names, with a heuristic fallback.
- `model/canonical.jac` — approval deep-freezes the model with provenance
  edges back to the exact sheet and column each field came from.
- The generator consumes only approved versions — never raw inference.
- "Server, graph persistence, typed RPC and the React UI are one Jac
  codebase. Everything you just saw ran through walkers on a graph."

## 3:40–4:00 — Close

> "Excel is the world's most successful database — and its least maintainable.
> byeExcel meets businesses where they already are: their own spreadsheet,
> reviewed by them, turned into software they own. Built in one day, in Jac."

## Contingencies

- **Stale page / inputs misbehave** → hard refresh (Cmd+Shift+R); the record
  form fix requires the fresh bundle.
- **Upload fails on stage** → `Imported workbooks` keeps prior uploads: click
  one to reopen its proposal — state persists in the graph.
- **AI names/descriptions absent** → expected without an API key: heuristic
  names stand. Don't promise AI naming unless the key is set in
  `secrets/byeexcel.env`.
- **"Is the LLM deciding the schema?"** → No: deterministic heuristics over
  graph evidence decide; the LLM only names and describes; the human approves;
  the generator reads only approved versions.
