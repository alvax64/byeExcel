# Client shell for the demo flow: upload an .xlsx, watch the inferred model
# appear, review entities/fields/relations. One stateful shell owns all page
# state; sections are stateless components fed by props.

import from .components.ui.button { Button }
import from .components.ui.card {
    Card,
    CardHeader,
    CardTitle,
    CardDescription,
    CardContent
}
import from .components.ui.badge { Badge }
import from .components.ui.input { Input }
import from .components.ui.textarea { Textarea }
import from .components.ui.table {
    Table,
    TableHeader,
    TableBody,
    TableRow,
    TableHead,
    TableCell
}
sv import from .api {
    upload_workbook,
    workbooks_view,
    proposal_view,
    ProposalView,
    WorkbookView,
    EntityView,
    FieldView,
    RelationView
}

def:pub ReviewShell -> JsxElement {
    has workbooks: list[WorkbookView] = [],
        current: ProposalView | None = None,
        businessContext: str = "",
        uploading: bool = False,
        error: str = "";

    async can with entry {
        workbooks = await workbooks_view();
    }

    def handleContext(e: ChangeEvent) {
        businessContext = e.target.value;
    }

    def handleFile(e: ChangeEvent) {
        # browser file objects have no Jac stubs: any-typed on purpose
        files: any = e.target.files;
        if not files {
            return;
        }
        f: any = files[0];
        if not f {
            return;
        }
        uploading = True;
        error = "";
        reader: any = new(FileReader);  # jac:ignore[E1053]
        reader.onload = lambda { finishUpload(String(f.name), String(reader.result)); };
        reader.onerror = lambda {
            uploading = False;
            error = "No se pudo leer el archivo.";
        };
        reader.readAsDataURL(f);
    }

    async def finishUpload(name: str, dataUrl: str) {
        parts = dataUrl.split(",");
        if len(parts) < 2 {
            uploading = False;
            error = "Archivo vacío o ilegible.";
            return;
        }
        result = await upload_workbook(name, parts[1], businessContext);
        current = result;
        uploading = False;
        if result is None {
            error = "No se pudo inferir un modelo de ese archivo.";
        }
        workbooks = await workbooks_view();
    }

    async def openProposal(checksum: str) {
        current = await proposal_view(checksum);
    }

    # precomputed so the optional narrows via isinstance - the type checker
    # does not narrow `current` inside a trailing JSX ternary (E1099)
    c = current;
    proposalSection: any = None;
    if isinstance(c, ProposalView) {
        proposalSection = <section className="flex flex-col gap-4">
            <h2 className="text-xl font-semibold">
                {"2 · Modelo propuesto - revísalo antes de generar"}
            </h2>
            {for entity in c.entities {
                <EntityCard key={entity.source_sheet} entity={entity}/>
            }}
        </section>;
    }

    return
        <div className="min-h-screen bg-background text-foreground p-6">
            <div className="mx-auto flex max-w-5xl flex-col gap-6">
                <header>
                    <h1 className="text-2xl font-semibold">byeExcel</h1>
                    <p className="text-muted-foreground">
                        {"De tu Excel a un sistema - con revisión humana en el medio."}
                    </p>
                </header>
                <Card>
                    <CardHeader>
                        <CardTitle>{"1 · Sube tu Excel"}</CardTitle>
                        <CardDescription>
                            {"Cuéntanos de tu negocio (opcional) y sube el .xlsx que usas hoy."}
                        </CardDescription>
                    </CardHeader>
                    <CardContent className="flex flex-col gap-3">
                        <Textarea
                            placeholder="¿De qué es tu negocio? Mejora los nombres sugeridos por la IA."
                            value={businessContext}
                            onChange={handleContext}
                        />
                        <Input type="file" accept=".xlsx" onChange={handleFile}/>
                        {<p className="text-sm text-muted-foreground">
                            {"Analizando tu Excel..."}
                        </p>
                            if uploading
                            else None}
                        {<p className="text-sm text-destructive">{error}</p>
                            if error
                            else None}
                    </CardContent>
                </Card>
                {<Card>
                    <CardHeader>
                        <CardTitle>{"Workbooks importados"}</CardTitle>
                    </CardHeader>
                    <CardContent className="flex flex-wrap gap-2">
                        {for wb in workbooks {
                            <Button
                                key={wb.checksum}
                                variant="outline"
                                onClick={lambda { openProposal(wb.checksum); }}
                            >
                                {wb.filename + " (" + str(wb.sheet_count) + " hojas)"}
                            </Button>
                        }}
                    </CardContent>
                </Card>
                    if workbooks
                    else None}
                {proposalSection}
            </div>
        </div>;
}

def:pub EntityCard(entity: EntityView) -> JsxElement {
    return
        <Card>
            <CardHeader>
                <CardTitle className="flex items-center gap-2">
                    {entity.suggested_name or entity.name}
                    <Badge variant="secondary">{"hoja: " + entity.source_sheet}</Badge>
                </CardTitle>
                {<CardDescription>{entity.description}</CardDescription>
                    if entity.description
                    else None}
            </CardHeader>
            <CardContent className="flex flex-col gap-3">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>{"Campo"}</TableHead>
                            <TableHead>{"Tipo"}</TableHead>
                            <TableHead>{"Requerido"}</TableHead>
                            <TableHead>{"Clave"}</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {for f in entity.fields {
                            <TableRow key={f.name}>
                                <TableCell>{f.name}</TableCell>
                                <TableCell>
                                    <Badge variant="outline">{f.field_type}</Badge>
                                </TableCell>
                                <TableCell>{"sí" if f.required else "no"}</TableCell>
                                <TableCell>
                                    {"clave" if f.key_candidate else ""}
                                </TableCell>
                            </TableRow>
                        }}
                    </TableBody>
                </Table>
                {for r in entity.relations {
                    <p key={r.via_field} className="text-sm text-muted-foreground">
                        {"→ se relaciona con " + r.target_entity + " vía '" + r.via_field + "' (" + r.evidence + ")"}
                    </p>
                }}
            </CardContent>
        </Card>;
}
