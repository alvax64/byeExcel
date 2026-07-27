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
    approve_proposal,
    ProposalView,
    WorkbookView,
    EntityView,
    FieldView,
    RelationView,
    ApprovedView
}

def:pub ReviewShell -> JsxElement {
    has workbooks: list[WorkbookView] = [],
        current: ProposalView | None = None,
        approved: ApprovedView | None = None,
        businessContext: str = "",
        uploading: bool = False,
        approving: bool = False,
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
        approved = None;
        uploading = False;
        if result is None {
            error = "Could not infer a model from that file.";
        }
        workbooks = await workbooks_view();
    }

    async def openProposal(checksum: str) {
        current = await proposal_view(checksum);
        approved = None;
    }

    async def approveNow {
        cur: any = current;
        if not cur {
            return;
        }
        approving = True;
        approved = await approve_proposal(cur.checksum);
        approving = False;
    }

    # Precompute behind a truthiness guard. `ProposalView` is a server-side
    # type and must not be referenced as a runtime JavaScript constructor.
    c = current;
    proposalSection: any = None;
    if c {
        proposalSection = <section className="flex flex-col gap-4">
            <div className="flex items-center justify-between gap-4">
                <h2 className="text-xl font-semibold">
                    {"2 · Proposed model - review it before generating"}
                </h2>
                <Button onClick={approveNow} disabled={approving}>
                    {"Approving..." if approving else "Approve model"}
                </Button>
            </div>
            {for entity in c.entities {
                <EntityCard key={entity.source_sheet} entity={entity}/>
            }}
        </section>;
    }

    a = approved;
    approvedSection: any = None;
    if a {
        approvedSection = <Card className="border-primary">
            <CardHeader>
                <CardTitle className="text-primary">
                    {"Model v" + str(a.version) + " approved ✓"}
                </CardTitle>
                <CardDescription>
                    {"Frozen as an immutable version with full provenance - ready for generation."}
                </CardDescription>
            </CardHeader>
            <CardContent className="flex flex-wrap gap-2">
                {for name in a.entity_names {
                    <Badge key={name}>{name}</Badge>
                }}
            </CardContent>
        </Card>;
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
                {approvedSection}
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
