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
    generate_system,
    generated_system_view,
    create_generated_record,
    ProposalView,
    WorkbookView,
    EntityView,
    FieldView,
    RelationView,
    GeneratedSystemView,
    GeneratedEntityView,
    GeneratedFieldView,
    GeneratedRecordView,
    RecordMutationView
}

def:pub ReviewShell -> JsxElement {
    has workbooks: list[WorkbookView] = [],
        current: ProposalView | None = None,
        generated: GeneratedSystemView | None = None,
        businessContext: str = "",
        activeEntityKey: str = "",
        draft: dict[str, str] = {},
        uploading: bool = False,
        generating: bool = False,
        saving: bool = False,
        error: str = "",
        notice: str = "";

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
            error = "Could not read the file.";
        };
        reader.readAsDataURL(f);
    }

    async def finishUpload(name: str, dataUrl: str) {
        parts = dataUrl.split(",");
        if len(parts) < 2 {
            uploading = False;
            error = "Empty or unreadable file.";
            return;
        }
        result = await upload_workbook(name, parts[1], businessContext);
        current = result;
        generated = None;
        activeEntityKey = "";
        draft = {};
        uploading = False;
        if result is None {
            error = "Could not infer a model from that file.";
        }
        workbooks = await workbooks_view();
    }

    async def openProposal(checksum: str) {
        current = await proposal_view(checksum);
        generated = await generated_system_view(checksum);
        g = generated;
        if g and g.entities {
            activeEntityKey = g.entities[0].entity_key;
        } else {
            activeEntityKey = "";
        }
        draft = {};
        error = "";
        notice = "";
    }

    async def generateCurrent {
        c = current;
        if not c {
            return;
        }
        generating = True;
        error = "";
        notice = "";
        try {
            result = await generate_system(c.checksum);
            generated = result;
            if result and result.entities {
                activeEntityKey = result.entities[0].entity_key;
                notice = "System generated. Add your first record below.";
            } else {
                error = "Could not generate a system from this proposal.";
            }
        } except Exception as e {
            error = "Generation failed: " + str(e);
        } finally {
            generating = False;
        }
    }

    def selectEntity(entityKey: str) {
        activeEntityKey = entityKey;
        draft = {};
        error = "";
        notice = "";
    }

    def handleGeneratedField(e: ChangeEvent) {
        fieldName = String(e.target.name);
        nextDraft: dict[str, str] = {** draft};
        nextDraft[fieldName] = String(e.target.value);
        draft = nextDraft;
    }

    def draftValue(fieldName: str) -> str {
        return draft[fieldName] if fieldName in draft else "";
    }

    def recordValue(record: GeneratedRecordView, fieldName: str) -> str {
        return record.values[fieldName] if fieldName in record.values else "";
    }

    async def saveGeneratedRecord {
        g = generated;
        if not g or activeEntityKey == "" {
            return;
        }
        saving = True;
        error = "";
        notice = "";
        try {
            outcome = await create_generated_record(g.checksum, activeEntityKey, draft);
            if outcome.ok and outcome.system {
                generated = outcome.system;
                draft = {};
                notice = "Record saved.";
            } else {
                error = outcome.error or "Could not save the record.";
            }
        } except Exception as e {
            error = "Could not save the record: " + str(e);
        } finally {
            saving = False;
        }
    }

    # Precompute behind a truthiness guard. `ProposalView` is a server-side
    # type and must not be referenced as a runtime JavaScript constructor.
    c = current;
    proposalSection: any = None;
    if c {
        proposalSection = <section className="flex flex-col gap-4">
            <h2 className="text-xl font-semibold">
                {"2 · Proposed model - review it before generating"}
            </h2>
            {for entity in c.entities {
                <EntityCard key={entity.source_sheet} entity={entity}/>
            }}
            <Card className="border-primary/40 bg-primary/5">
                <CardHeader>
                    <CardTitle>{"Ready to build?"}</CardTitle>
                    <CardDescription>
                        {"Approve this version and generate a working data application. The source workbook remains unchanged."}
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <Button onClick={generateCurrent} disabled={generating}>
                        {"Generating..." if generating else "Approve & generate system"}
                    </Button>
                </CardContent>
            </Card>
        </section>;
    }

    g = generated;
    generatedSection: any = None;
    if g {
        activeEntity: GeneratedEntityView | None = None;
        for entity in g.entities {
            if entity.entity_key == activeEntityKey {
                activeEntity = entity;
            }
        }
        if activeEntity is None and g.entities {
            activeEntity = g.entities[0];
        }

        workspace: any = None;
        entityForWorkspace = activeEntity;
        if entityForWorkspace {
            workspace = <Card>
                <CardHeader>
                    <CardTitle>{entityForWorkspace.name}</CardTitle>
                    <CardDescription>
                        {entityForWorkspace.description
                        or "Generated module at " + entityForWorkspace.route}
                    </CardDescription>
                </CardHeader>
                <CardContent className="flex flex-col gap-6">
                    <div className="grid gap-4 md:grid-cols-2">
                        {for field in entityForWorkspace.fields {
                            <div key={field.name} className="flex flex-col gap-2">
                                <label className="text-sm font-medium">
                                    {field.name}{" *" if field.required else ""}
                                </label>
                                {<select
                                    name={field.name}
                                    value={draftValue(field.name)}
                                    onChange={handleGeneratedField}
                                    className="border-input bg-background rounded-md border px-3 py-2 text-sm"
                                >
                                    <option value="">
                                        {"Select " + field.relation_target}
                                    </option>
                                    {for option in field.options {
                                        <option key={option} value={option}>
                                            {option}
                                        </option>
                                    }}
                                </select>
                                    if field.input_type == "select"
                                    else <Input
                                        name={field.name}
                                        type={field.input_type}
                                        value={draftValue(field.name)}
                                        placeholder={field.field_type}
                                        onChange={handleGeneratedField}
                                    />}
                            </div>
                        }}
                    </div>
                    <div>
                        <Button onClick={saveGeneratedRecord} disabled={saving}>
                            {"Saving..." if saving else "Add record"}
                        </Button>
                    </div>
                    {<Table>
                        <TableHeader>
                            <TableRow>
                                {for field in entityForWorkspace.fields {
                                    <TableHead key={field.name}>{field.name}</TableHead>
                                }}
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {for record in entityForWorkspace.records {
                                <TableRow key={record.record_id}>
                                    {for field in entityForWorkspace.fields {
                                        <TableCell key={field.name}>
                                            {recordValue(record, field.name)}
                                        </TableCell>
                                    }}
                                </TableRow>
                            }}
                        </TableBody>
                    </Table>
                        if entityForWorkspace.records
                        else <div
                            className="rounded-lg border border-dashed p-8 text-center text-sm text-muted-foreground"
                        >
                            {"No records yet. Use the generated form above to add one."}
                        </div>}
                </CardContent>
            </Card>;
        }

        generatedSection = <section className="flex flex-col gap-4">
            <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h2 className="text-xl font-semibold">{"3 · Generated system"}</h2>
                    <p className="text-sm text-muted-foreground">
                        {g.name + " · deterministic version " + g.version_id}
                    </p>
                </div>
                <Badge variant="secondary">{str(len(g.entities)) + " modules"}</Badge>
            </div>
            <div className="flex flex-wrap gap-2">
                {for entity in g.entities {
                    <Button
                        key={entity.entity_key}
                        variant={"default"
                            if entity.entity_key == activeEntityKey
                            else "outline"}
                        onClick={lambda { selectEntity(entity.entity_key); }}
                    >
                        {entity.name}
                    </Button>
                }}
            </div>
            {workspace}
        </section>;
    }

    return
        <div className="min-h-screen bg-background text-foreground p-6">
            <div className="mx-auto flex max-w-5xl flex-col gap-6">
                <header className="flex flex-col gap-2 py-8 text-center">
                    <h1 className="text-5xl font-bold tracking-tight">
                        {"bye"}
                        <span className="text-primary">{"Excel"}</span>
                    </h1>
                    <p className="text-lg text-muted-foreground">
                        {"Turn the spreadsheet that runs your business into real software - with human review in the middle."}
                    </p>
                </header>
                <Card>
                    <CardHeader>
                        <CardTitle>{"1 · Upload your Excel"}</CardTitle>
                        <CardDescription>
                            {"Tell us about your business (optional) and upload the .xlsx you use today."}
                        </CardDescription>
                    </CardHeader>
                    <CardContent className="flex flex-col gap-3">
                        <Textarea
                            placeholder="What is your business about? This improves the AI-suggested names."
                            value={businessContext}
                            onChange={handleContext}
                        />
                        <Input type="file" accept=".xlsx" onChange={handleFile}/>
                        {<p className="text-sm text-muted-foreground">
                            {"Analyzing your spreadsheet..."}
                        </p>
                            if uploading
                            else None}
                        {<p className="text-sm text-destructive">{error}</p>
                            if error
                            else None}
                        {<p className="text-sm text-primary">{notice}</p>
                            if notice
                            else None}
                    </CardContent>
                </Card>
                {<Card>
                    <CardHeader>
                        <CardTitle>{"Imported workbooks"}</CardTitle>
                    </CardHeader>
                    <CardContent className="flex flex-wrap gap-2">
                        {for wb in workbooks {
                            <Button
                                key={wb.checksum}
                                variant="outline"
                                onClick={lambda { openProposal(wb.checksum); }}
                            >
                                {wb.filename + " (" + str(wb.sheet_count) + " sheets)"}
                            </Button>
                        }}
                    </CardContent>
                </Card>
                    if workbooks
                    else None}
                {proposalSection}
                {generatedSection}
            </div>
        </div>;
}

def:pub EntityCard(entity: EntityView) -> JsxElement {
    return
        <Card>
            <CardHeader>
                <CardTitle className="flex items-center gap-2">
                    {entity.suggested_name or entity.name}
                    <Badge variant="secondary">{"sheet: " + entity.source_sheet}</Badge>
                </CardTitle>
                {<CardDescription>{entity.description}</CardDescription>
                    if entity.description
                    else None}
            </CardHeader>
            <CardContent className="flex flex-col gap-3">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>{"Field"}</TableHead>
                            <TableHead>{"Type"}</TableHead>
                            <TableHead>{"Required"}</TableHead>
                            <TableHead>{"Key"}</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {for f in entity.fields {
                            <TableRow key={f.name}>
                                <TableCell>{f.name}</TableCell>
                                <TableCell>
                                    <Badge variant="outline">{f.field_type}</Badge>
                                </TableCell>
                                <TableCell>{"yes" if f.required else "no"}</TableCell>
                                <TableCell>
                                    {"key" if f.key_candidate else ""}
                                </TableCell>
                            </TableRow>
                        }}
                    </TableBody>
                </Table>
                {for r in entity.relations {
                    <p key={r.via_field} className="text-sm text-muted-foreground">
                        {"→ relates to " + r.target_entity + " via '" + r.via_field + "' (" + r.evidence + ")"}
                    </p>
                }}
            </CardContent>
        </Card>;
}
