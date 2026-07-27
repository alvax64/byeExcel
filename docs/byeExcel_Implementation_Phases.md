# byeExcel Implementation Phases

**Phased implementation roadmap derived from the byeExcel Product Description and Comprehensive Functional Requirements Specification**

Document status: Recommended delivery baseline for product planning, architecture, backlog decomposition, staffing, release governance, and design-partner execution.

> This roadmap is a planning recommendation, not a committed delivery schedule. Duration ranges assume stable scope, timely design-partner access, and multiple cross-functional teams. The phases are gated product increments, not a waterfall: platform, security, quality, design, and operational work continue throughout.

## 1. Implementation Strategy

byeExcel should be implemented as a sequence of independently demonstrable and increasingly valuable product increments. Each phase must leave the product in a deployable, observable, and supportable condition, even when access remains limited to internal users or design partners.

The recommended strategy is built on six rules:

1. **Establish trust before intelligence.** Tenant isolation, identity, authorization, audit, secure jobs, and support controls precede customer data analysis and AI-assisted generation.
2. **Prove source understanding before application generation.** Upload and profiling must be reliable before schema inference is treated as a product capability.
3. **Use the blueprint as the governed contract.** Spreadsheet analysis, human decisions, transformations, generated UI, workflows, permissions, and releases must converge on a versioned intermediate representation.
4. **Deliver an end-to-end vertical MVP.** The MVP is complete only when a customer can upload, review, transform, preview, publish, operate, audit, roll back, and export.
5. **Keep high-risk operations human-controlled.** Publication, destructive migration, material permission changes, sensitive-data decisions, and conflict resolution remain gated.
6. **Defer ecosystem breadth until the core is repeatable.** Broad connectors, public templates, SDKs, semantic search, and custom components should follow evidence of reliable core conversions and viable support economics.

## 2. Phase Summary

| Phase | Horizon | Indicative duration* | Milestone | Primary outcome | Formal requirements primarily completed |
|---|---|---:|---|---|---:|
| **Phase 0: Discovery, Validation, and Architecture Readiness** | MVP preparation | 4–6 weeks | M0 — Ready to build | A validated product boundary, representative workbook corpus, approved architecture direction, and measurable quality baseline. | 0 |
| **Phase 1: Secure Multi-Tenant SaaS Foundation** | MVP | 8–12 weeks | M1 — Trusted SaaS shell | A customer can register, create an isolated organization and workspace, invite users, assign governed access, and operate within an auditable SaaS control plane. | 27 |
| **Phase 2: Spreadsheet Intake, Inspection, and Profiling** | MVP | 6–8 weeks | M2 — Trusted source analysis | A customer can securely upload supported files and receive a traceable structural, quality, formula, and reference analysis without altering the source. | 10 |
| **Phase 3: Business Understanding, AI Inference, and Schema Confirmation** | MVP | 8–12 weeks | M3 — Human-approved canonical model | The product combines spreadsheet evidence and business context to propose an explainable model that an authorized user can edit and approve. | 15 |
| **Phase 4: Data Transformation, Migration Planning, and Blueprint** | MVP | 8–12 weeks | M4 — Migration-ready approved blueprint | A customer can map, clean, quarantine, reconcile, and version source data while approving an executable application blueprint and migration plan. | 15 |
| **Phase 5: Generated Application Core and Operational Workflows** | MVP | 10–14 weeks | M5 — Working preview application | The approved blueprint produces a usable, permission-aware application with core data management, search, dashboards, workflows, and notifications. | 19 |
| **Phase 6: Governed Publication and MVP Productionization** | MVP release | 8–12 weeks | M6 — Production MVP | Design partners can validate, publish, operate, roll back, export, archive, and support generated applications under production controls. | 6 |
| **Phase 7: Operational Scale, Collaboration, and Recurring Synchronization** | Post-MVP | 12–20 weeks | M7 — Scaled customer operations | Customers gain advanced identity, collaboration, reporting, workflow, governance, and controlled recurring spreadsheet synchronization. | 38 |
| **Phase 8: Integrations, Reuse, and Governed Extensibility** | Post-MVP | 12–18 weeks | M8 — Extensible platform | byeExcel becomes an integration-capable and safely extensible platform with APIs, connectors, reusable templates, and Jaclang extension controls. | 9 |
| **Phase 9: Strategic Intelligence and Ecosystem** | Future / strategic | Investment-gated; continuous | M9 — Ecosystem and advanced intelligence | The product adds semantic discovery, scheduled analytics, public/private template ecosystems, SDK/CLI capabilities, and advanced component extensibility where validated by demand. | 7 |

*Indicative duration is elapsed phase effort, not a promise. With three coordinated squads, phases can overlap as described below. A single-team implementation would materially increase elapsed time and delivery risk.*

### Release boundaries

- **Production MVP:** Phases 0–6. These phases complete all 92 Must-priority requirements, including the MVP portions of hybrid requirements.
- **Post-MVP product expansion:** Phases 7–8. These phases complete the 47 Should-priority requirements and mature the product for broader operational use and partner delivery.
- **Future / strategic horizon:** Phase 9. This phase covers the seven Could-priority requirements and additional strategic options that require product-market and commercial validation.

### Recommended dependency path

```text
Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6
                                                        ↓
                                                     MVP release
                                                        ↓
                                                   Phase 7 → Phase 8 → Phase 9
```

This is the product dependency path, not a prohibition on parallel engineering. Runtime components can be built against synthetic blueprints during Phases 3–4, and production hardening starts in Phase 1 rather than waiting for Phase 6.

## 3. Cross-Phase Definition of Done

A phase is complete only when all applicable conditions below are met:

| Dimension | Required evidence |
|---|---|
| Functional | Phase acceptance scenarios pass and each completed requirement is linked to tests and release evidence. |
| Security and privacy | Threat-model changes are reviewed; authorization, tenant-isolation, sensitive-data, audit, and abuse-control tests pass. |
| Data integrity | No silent loss; migrations and transformations reconcile; invalid data remains traceable and recoverable. |
| AI quality | Model-assisted behavior has versioned evaluations, evidence display, confidence handling, deterministic validation, and human approval where required. |
| Reliability | Jobs are idempotent or compensating, observable, retryable, and recoverable; failure modes are tested. |
| Performance | Applicable recommended targets are measured with representative data volumes; exceptions are documented and approved. |
| Accessibility and usability | Critical journeys pass accessibility checks and representative users complete tasks at the agreed usability threshold. |
| Operability | Dashboards, alerts, runbooks, ownership, diagnostic data, feature flags, and support procedures exist before exposure expands. |
| Documentation | User, administrator, support, release, limitation, and migration documentation is updated. |
| Rollback and portability | Release rollback or recovery is tested; customer data remains exportable even when a feature or subscription is disabled. |

## 4. Phase 0 — Discovery, Validation, and Architecture Readiness

### Objective

Reduce the largest product, data, AI, architecture, and commercial uncertainties before committing to the full build. This phase does not claim functional-requirement completion; it creates the validated preconditions for the MVP.

### Scope and deliverables

- Select at least three initial spreadsheet-process archetypes. Recommended candidates are customer/order operations, project/task/approval management, and asset/inventory/maintenance management.
- Obtain a representative, permission-cleared corpus of real or faithfully anonymized `.xlsx`, `.xls`, and `.csv` sources, including intentionally difficult examples.
- Define the supported file-feature and complexity matrix: formats, formulas, external links, macros, merged cells, hidden content, sizes, row counts, sheets, tables, locales, and exclusions.
- Create a conversion complexity rubric covering data volume, structural ambiguity, number of entities, relationship quality, formula complexity, workflow complexity, sensitive-data level, synchronization need, and customization need.
- Prototype the end-to-end experience with non-technical process owners and data stewards: upload, issue review, context collection, model correction, migration preview, application preview, and publication approval.
- Define blueprint version 0: stable identifiers, entity/field/relationship schema, UI metadata, workflow definitions, permissions, reports, transformations, lineage, environment configuration, and extension points.
- Approve architecture decisions for tenant isolation, authentication, policy enforcement, object storage, parsing isolation, background jobs, eventing, audit, generated runtime, data lineage, secrets, observability, backups, and deployment.
- Establish the AI evaluation corpus, quality rubric, model/provider policy, prompt-injection threat model, data-minimization policy, fallback behavior, and human-approval matrix.
- Establish recommended non-functional budgets for upload, profiling, generation, interactive response, availability, recovery, backup, and scale; validate them with target customers and engineering.
- Define commercial and delivery assumptions: self-service versus assisted onboarding, partner role, complexity bands, support boundaries, pricing hypotheses, and implementation responsibility.

### Entry criteria

- Executive sponsorship and named product, architecture, security, and delivery owners.
- Access to prospective customers or design partners and representative spreadsheet processes.
- Agreement that unsupported or ambiguous spreadsheet behavior will be surfaced rather than silently emulated.

### Exit gate

- At least 10 representative workbook sets and three target archetypes are approved for the benchmark corpus.
- The support matrix, complexity rubric, blueprint contract, data-flow map, threat model, and key architecture decisions are reviewed and versioned.
- Non-technical prototype tests demonstrate that users can understand issues, evidence, confidence, correction, and approval concepts.
- Baseline expert effort is measured so later phases can prove that byeExcel saves implementation time rather than merely moving effort.
- Design partners accept the governance model, including human approval and explicit handling of unsupported features.

### Primary risks

- The target archetypes may be too diverse for a common MVP.
- Customers may be unable to explain tacit rules without facilitated discovery.
- The blueprint may be defined too narrowly and force customer-specific runtime forks.
- AI inference may appear impressive in demonstrations but fail to reduce total implementation effort.

## 5. Phase 1 — Secure Multi-Tenant SaaS Foundation

### Objective

Create the minimum trustworthy SaaS control plane on which all later customer-data and generated-application capabilities depend.

### User and business outcome

A customer can register, create an isolated organization and workspace, invite users, assign governed access, and operate within an auditable SaaS control plane.

### Included scope

- Self-service account registration, organization and workspace creation, ownership, settings, and policy defaults.
- Email/password authentication, MFA, session management and revocation, invitations, memberships, teams, custom roles, record-level and field-level authorization.
- Tenant-context enforcement for application, job, storage, cache, search, log, export, and support operations.
- Consent, data-residency selection, sensitive-field classification/masking controls, security alerts, and customer-visible audit foundations.
- Plan/trial, seat/application entitlements, usage metering, limits, and overage notification foundations without finalizing prices.
- Operational dashboards, job orchestration and monitoring, controlled support access, feature flags, abuse controls, incident support, and operational audit.
- Guided onboarding shell, support-ticket diagnostics, and an integration-monitoring framework that later connectors can use.

### Primary architecture and engineering deliverables

- Canonical tenant, organization, workspace, user, membership, role, permission, application, environment, entitlement, audit-event, support-case, and job models.
- A single policy-enforcement path reused by UI, APIs, background jobs, reports, search, exports, and support tooling.
- Immutable audit event envelope with actor, tenant, action, resource, purpose, correlation ID, before/after metadata, source channel, and timestamp.
- Idempotent background-job framework with checkpoints, retries, cancellation, dead-letter handling, progress, correlation, and ownership.
- Secure object-storage boundary, encryption, key-management abstraction, retention metadata, malware-scan integration point, and data-residency tagging.
- Feature-flag and entitlement service that can disable exposure without corrupting or trapping customer data.

### Formal requirement coverage

- **9.1 Account, Tenant, and Organization Management:** `FR-TEN-001`, `FR-TEN-002`, `FR-TEN-003`, `FR-TEN-004`
- **9.2 User Management, Authentication, and Authorization:** `FR-IAM-001`, `FR-IAM-003`, `FR-IAM-005`, `FR-IAM-006`, `FR-IAM-007`, `FR-IAM-008`
- **9.20 Administration and Governance:** `FR-GOV-001`, `FR-GOV-002`, `FR-GOV-003`
- **9.21 Security and Privacy Functions:** `FR-SEC-001`, `FR-SEC-002`, `FR-SEC-003`, `FR-SEC-005`
- **9.22 Billing, Subscription, and Usage Management:** `FR-BIL-001`, `FR-BIL-002`, `FR-BIL-003`
- **9.27 Internal Platform Operations:** `FR-OPS-001`, `FR-OPS-003`, `FR-OPS-004`, `FR-OPS-005`
- **9.23 Support and Product Assistance:** `FR-SUP-001`, `FR-SUP-003`
- **9.19 Integrations and APIs:** `FR-INT-005`

**Requirement count:** 27

### Exit gate

- Automated negative tests demonstrate that users, jobs, support operators, and exports cannot cross tenant boundaries.
- A verified organization owner can create an organization/workspace, invite users, assign roles, preview effective permissions, revoke sessions, and view audit events.
- Record-level and field-level denies are enforced consistently across a reference UI, API, search result, report, and export.
- Support access requires an active case, explicit scope, time limit, step-up authentication, consent or emergency authority, and customer-visible audit.
- Entitlement limits block new use safely while preserving authorized read, export, billing-resolution, and closure paths.
- Job failures expose status, retry, diagnostic correlation, and operator recovery without manual database editing.

### Demonstrable vertical slice

Register a new organization, create a workspace, invite an internal user and an expiring external collaborator, assign a field-restricted role, generate auditable activity, revoke access, and open a consented support case.

### Explicitly deferred from this phase

Passwordless authentication, SSO/JIT, service accounts, formal access-review campaigns, advanced IP/domain restrictions, legal holds, and customer-facing privacy-request orchestration.

## 6. Phase 2 — Spreadsheet Intake, Inspection, and Profiling

### Objective

Build a secure and explainable source-ingestion pipeline that understands spreadsheet structure and limitations before any AI model is asked to design an application.

### User and business outcome

A customer can securely upload supported files and receive a traceable structural, quality, formula, and reference analysis without altering the source.

### Included scope

- Drag-and-drop and multi-file upload for supported `.xlsx`, `.xls`, and `.csv` files with progress, cancellation, resumability where supported, and safe retry.
- File signature validation, malware scanning, quarantine, checksums, duplicate detection, source versioning, provenance, and immutable original preservation.
- Workbook feature inventory covering sheets, hidden content, formulas, named ranges, merged cells, tables, pivot structures, charts, comments/notes, macros, external links, and unsupported constructs.
- Detection of headers, repeated headers, data regions, multiple tables, empty rows/columns, types, formats, locales, candidate keys, duplicates, missing values, outliers, references, lookups, and formula dependencies.
- An issue register with source coordinates, severity, confidence, sampling limitations, impact, blocking status, and correction guidance.

### Primary architecture and engineering deliverables

- Parser isolation so corrupt or malicious files cannot affect the control plane or other tenants.
- Canonical source-file, workbook, sheet, region, column, row-sample, formula, issue, and source-version models.
- Pluggable parser/profile stages with deterministic outputs, stage-level status, and reproducible version metadata.
- Source evidence references that later inference and transformation decisions can cite without copying unnecessary sensitive cell content.
- Profile storage designed to support very large files through streaming, chunking, sampling, and explicit completeness indicators.

### Formal requirement coverage

- **9.3 Spreadsheet Upload and Source Management:** `FR-UPL-001`, `FR-UPL-004`, `FR-UPL-005`, `FR-UPL-006`, `FR-UPL-007`
- **9.4 Spreadsheet Profiling and Structural Analysis:** `FR-PRF-001`, `FR-PRF-002`, `FR-PRF-003`, `FR-PRF-004`, `FR-PRF-005`

**Requirement count:** 10

### Exit gate

- Every file in the approved benchmark corpus is either profiled successfully or rejected/quarantined with a safe and actionable reason.
- Unsupported features are inventoried and preserved as evidence; no macros or arbitrary workbook code execute.
- Repeated upload of the same content does not create an unexplained duplicate source version.
- Profiling results are reproducible for a fixed parser/profile version and expose whether results are complete or sampled.
- All populated regions, ignored regions, broken references, and quality issues are counted and traceable to the source.
- Large-file and interrupted-upload tests demonstrate bounded resource use and recoverable behavior.

### Demonstrable vertical slice

Upload a batch containing a clean workbook, a workbook with hidden sheets and formulas, a duplicate version, a corrupt file, and a macro-enabled workbook; show progress, quarantine, feature inventory, issue register, provenance, and safe unsupported-feature handling.

### Explicitly deferred from this phase

Direct cloud-storage import, password-unlocking workflows, advanced hierarchy/time-series/denormalization inference, and recurring source monitoring.

## 7. Phase 3 — Business Understanding, AI Inference, and Schema Confirmation

### Objective

Translate spreadsheet evidence and user-supplied business context into an explainable, editable, human-approved canonical data model.

### User and business outcome

The product combines spreadsheet evidence and business context to propose an explainable model that an authorized user can edit and approve.

### Included scope

- Adaptive questionnaires and free text covering workbook meaning, process, actors, terminology, status transitions, approvals, rules, reports, sensitivity, frequency, and volumes.
- Context completeness, confidence, unresolved-question tracking, examples, evidence attachment, and role-appropriate follow-up questions.
- AI-assisted entity, field, type, primary-key, foreign-key, cardinality, semantic-match, synonym, and deduplication proposals.
- Confidence scores, explanations, source evidence, alternatives, uncertainty, unsupported-assumption prevention, and explicit approval/rejection.
- Visual and form-based model editing: create, rename, merge, split, delete, fields, constraints, relationships, enumerations, calculated fields, cascade behavior, validation rules, impact preview, undo, and redo.
- Model/provider monitoring, evaluation, versioning, prompt-injection resistance, structured-output validation, and safe fallback to deterministic or manual flows.

### Primary architecture and engineering deliverables

- Inference pipeline that separates untrusted source content, deterministic features, model prompts, model outputs, validators, and human decisions.
- Stable blueprint identifiers created at model confirmation time so later edits and regeneration preserve intent.
- Decision log recording source evidence, model/version, confidence, alternatives, human action, reason, and resulting model version.
- Deterministic schema validators for identifiers, data types, key uniqueness, relationship coverage, cycles, cascade risk, field constraints, and sensitive-data policy.
- Evaluation harness measuring entity/field/key/relationship accuracy, severe-error rate, correction effort, latency, cost, and regression by workbook archetype.

### Formal requirement coverage

- **9.5 Business-Context Collection:** `FR-CTX-001`, `FR-CTX-002`, `FR-CTX-003`
- **9.6 AI-Assisted Schema and Relationship Inference:** `FR-AIG-001`, `FR-AIG-002`, `FR-AIG-003`, `FR-AIG-004`, `FR-AIG-006`
- **9.7 Data Modeling and Schema Editor:** `FR-MOD-001`, `FR-MOD-002`, `FR-MOD-003`, `FR-MOD-004`, `FR-MOD-005`, `FR-MOD-006`
- **9.27 Internal Platform Operations:** `FR-OPS-002`

**Requirement count:** 15

### Exit gate

- An authorized subject-matter expert can understand why every proposed entity, field, key, and relationship exists and can trace it to source/context evidence.
- Low-confidence or contradictory proposals are never represented as confirmed facts and cannot bypass approval.
- Material model edits invalidate dependent approvals and display downstream migration/UI/workflow impact.
- Prompt-injection tests show that instructions embedded in cells, comments, notes, or filenames cannot change system policy or initiate actions.
- The benchmark meets stakeholder-approved inference thresholds, including a separate limit for severe false relationships and destructive suggestions.
- Every model version and AI-assisted decision is reproducible to the degree allowed by the recorded model/provider configuration.

### Demonstrable vertical slice

Answer guided questions for a multi-sheet workbook, review two alternative relationship proposals with match coverage and evidence, correct a false many-to-one relationship, split an overloaded sheet into entities, add validation, inspect impact, and approve the model.

### Explicitly deferred from this phase

Collaborative multi-reviewer context approval, automatic reference-data/enumeration inference, and organization-wide learning from corrections.

## 8. Phase 4 — Data Transformation, Migration Planning, and Blueprint

### Objective

Turn the approved model into a safe, versioned transformation plan and executable application blueprint with complete lineage and reconciliation.

### User and business outcome

A customer can map, clean, quarantine, reconcile, and version source data while approving an executable application blueprint and migration plan.

### Included scope

- Source-to-target column mapping, value mapping, date/currency/locale/unit normalization, duplicate resolution, record matching, missing-data handling, invalid-data quarantine, and reference reconciliation.
- Transformation preview at record and aggregate level, reusable rules, deterministic execution, lineage, rollback metadata, and explicit no-silent-loss reconciliation.
- One-time migration mode, source-of-truth and formula-result policies, sync logs/retry/rollback foundations, and schema-drift detection for later source refreshes.
- Blueprint creation covering model, navigation, screens, forms, views, roles, permissions, workflows, dashboards, reports, notifications, automations, integrations, branding, and localization metadata.
- Blueprint validation, preview, comparison, decision log, approval, immutable versions, change impact, and migration planning.

### Primary architecture and engineering deliverables

- Versioned transformation language or declarative rule model with deterministic functions, controlled custom expressions, test fixtures, and safe execution limits.
- Lineage graph from source file/version/region/cell or row through transformation rule to target entity/field/record and import job.
- Quarantine store that preserves rejected values, reasons, source coordinates, correction state, disposition, and exportability.
- Blueprint schema registry, semantic diff, compatibility checks, migration-plan generator, and artifact signatures.
- Import/sync job contract with idempotency keys, checkpoints, counts, hashes, reconciliation totals, conflict metadata, and rollback boundaries.

### Formal requirement coverage

- **9.8 Data Cleaning, Mapping, and Transformation:** `FR-DQT-001`, `FR-DQT-003`, `FR-DQT-004`, `FR-DQT-005`, `FR-DQT-006`
- **9.9 Application Blueprint Generation:** `FR-BLP-001`, `FR-BLP-002`, `FR-BLP-003`, `FR-BLP-004`
- **9.16 Spreadsheet Synchronization:** `FR-SYN-001`, `FR-SYN-005`, `FR-SYN-006`, `FR-SYN-007`
- **9.18 Application Lifecycle and Environment Management:** `FR-LCM-002`, `FR-LCM-003`

**Requirement count:** 15

### Exit gate

- Every populated source column and row has an approved target, transformation, quarantine reason, or explicit exclusion.
- Rerunning the same transformation version against the same source version produces equivalent outputs and reconciliation results.
- Count, total, key, duplicate, invalid, and unmatched-reference reconciliation is visible before commit and after import.
- High-impact schema drift, key changes, destructive mappings, narrowing conversions, and cascade behavior require explicit impact review and approval.
- The approved blueprint passes deterministic validation and can be compared semantically with prior versions.
- No migration approval is possible while unexplained data loss or blocking validation issues remain.

### Demonstrable vertical slice

Map two workbooks into a shared customer/order model, normalize locale-specific dates and currency, resolve duplicates, quarantine invalid references, compare blueprint versions, review impact, and approve a deterministic migration package.

### Explicitly deferred from this phase

Advanced structural transformations such as complex pivots/unpivots, selective AI regeneration preserving all edits, and live recurring synchronization.

## 9. Phase 5 — Generated Application Core and Operational Workflows

### Objective

Generate a usable operational application from the approved blueprint and prove that core tasks can be completed without spreadsheet access.

### User and business outcome

The approved blueprint produces a usable, permission-aware application with core data management, search, dashboards, workflows, and notifications.

### Included scope

- Responsive application shell, navigation, list/detail/create/edit screens, accessible empty/loading/error states, search, sort, filters, pagination, saved views, and related core configuration.
- Permission-aware record create/read/update/archive/restore/delete, bulk import/update/edit/delete, ownership, status, history, retention, and export.
- Event-triggered workflows, controlled status transitions, assignments, approvals, conditional routing, retry/error queues, history, and manual recovery.
- In-app notifications, approval requests, reminders, escalations, role-specific dashboards, governed metrics, freshness indicators, and row-level security.
- No-code navigation/page layout, custom views, dashboards, workflows, and validation configuration without editing generated source code.
- Preview provisioning using synthetic, masked, or approved sample data; external side effects disabled or mocked by default.

### Primary architecture and engineering deliverables

- Declarative generated runtime that interprets or compiles blueprints without customer-specific platform forks.
- Consistent authorization and validation enforcement in UI, API, job, search, report, workflow, import, and export paths.
- Generated component library with stable accessibility, responsiveness, localization hooks, telemetry, and error handling.
- Workflow engine with versioned definitions, idempotent actions, correlation IDs, manual tasks, retries, dead-letter queue, and audit history.
- Metric/report query layer that automatically applies tenant, record, and field security and exposes freshness and definition metadata.
- Application-generation contract tests using synthetic blueprints independent of AI inference.

### Formal requirement coverage

- **9.10 Generated User Interface:** `FR-UI-001`, `FR-UI-002`, `FR-UI-003`, `FR-UI-006`
- **9.11 Data and Record Management:** `FR-DAT-001`, `FR-DAT-002`, `FR-DAT-005`
- **9.12 Workflow and Business-Rule Engine:** `FR-WFL-001`, `FR-WFL-003`, `FR-WFL-004`, `FR-WFL-006`
- **9.13 Dashboards, Reports, and Analytics:** `FR-RPT-001`, `FR-RPT-005`
- **9.14 Search and Discovery:** `FR-SRC-001`, `FR-SRC-002`
- **9.15 Notifications and Collaboration:** `FR-NTF-001`, `FR-NTF-002`
- **9.17 Application Customization:** `FR-CUS-002`, `FR-CUS-003`

**Requirement count:** 19

### Exit gate

- The three target archetype applications can be generated from approved blueprints and used to complete their primary operational tasks.
- Authorization tests confirm that hidden or denied data cannot be recovered through search, reports, exports, URLs, bulk actions, or workflow context.
- All required data lifecycle actions produce consistent validation, concurrency handling, audit events, and history.
- Workflow failures are visible, retryable, and recoverable without duplicating already completed effects.
- Critical journeys meet approved accessibility and representative-user task-completion thresholds.
- Customers can make supported layout, view, dashboard, workflow, and validation changes without source-code edits.

### Demonstrable vertical slice

Generate an order/approval application, import approved records, complete create/edit/search/filter/bulk tasks, route a conditional approval, trigger reminders, recover a failed workflow, view a secured dashboard, and modify a layout without code.

### Explicitly deferred from this phase

Kanban/calendar/timeline, comments/mentions/tags, advanced duplicate merge, scheduled workflows, webhooks, workflow simulation, pivot-style reporting, cross-filtering, and notification digests.

## 10. Phase 6 — Governed Publication and MVP Productionization

### Objective

Integrate and harden the complete MVP so design partners can safely publish and operate production applications with rollback, portability, and accountable support.

### User and business outcome

Design partners can validate, publish, operate, roll back, export, archive, and support generated applications under production controls.

### Included scope

- Draft, preview, test, and production lifecycle states for the MVP, with environment isolation, configuration promotion, and production-data protection.
- Publication gates, approval evidence, dependency checks, release records, restore points, post-deployment health checks, rollback, and recovery mode.
- Account suspension/recovery/closure, application archival, complete customer-data export, and preservation of export during billing or closure states.
- End-to-end validation of upload, profiling, context, inference, modeling, transformation, import, generation, permissions, workflows, dashboards, publication, operation, support, audit, and export.
- Production observability, backup and restore testing, disaster-recovery rehearsal, incident runbooks, capacity testing, security testing, support documentation, and customer onboarding materials.
- Design-partner rollout with controlled cohorts, feature flags, explicit support boundaries, and measured business outcomes.

### Primary architecture and engineering deliverables

- Release orchestrator linking blueprint version, transformation version, application build, migration plan, approvals, tests, dependency state, deployment, and restore point.
- Environment policy preventing draft/test jobs, integrations, or credentials from modifying production except through approved release/import paths.
- Backup catalog and restoration workflow with tenant/environment/application scope, integrity checks, authorization, and audit.
- Customer export package manifest covering data, attachments, lineage, schemas, configuration, and documented omissions.
- Operational readiness scorecard and automated release evidence collection.

### Formal requirement coverage

- **9.1 Account, Tenant, and Organization Management:** `FR-TEN-005`
- **9.18 Application Lifecycle and Environment Management:** `FR-LCM-001`, `FR-LCM-004`, `FR-LCM-005`
- **9.26 Import, Export, Portability, and Offboarding:** `FR-EXP-001`, `FR-EXP-003`

**Requirement count:** 6

### Exit gate

- At least 10–20 design-partner applications complete the full path using production-like data with accountable business and technical sign-off.
- No unresolved critical tenant-isolation, authorization, data-loss, release, or sensitive-data defect remains.
- Accepted migrations reconcile with zero unexplained loss; rejected records and exclusions remain traceable and exportable.
- Rollback or documented recovery succeeds for representative application, schema, workflow, and migration failures.
- Backup restoration, incident response, support access, billing limits, export, archival, and closure are tested under production controls.
- Published support matrix, complexity limits, service objectives, known limitations, implementation responsibilities, and customer operating guidance are available.
- Product metrics show that the end-to-end path saves measurable expert/customer effort for the selected archetypes.

### Demonstrable vertical slice

Move a design-partner application from approved preview through gated production release, invite real users, operate a workflow, detect a post-release fault, roll back safely, produce a complete export, and archive the application with audit evidence.

### Explicitly deferred from this phase

Unattended recurring synchronization, broader environment topologies, SSO/JIT, advanced collaboration/analytics, broad connectors, public templates, and unrestricted extensions.

## 11. Phase 7 — Operational Scale, Collaboration, and Recurring Synchronization

### Objective

Expand the proven MVP for ongoing customer operations, richer collaboration, more sophisticated analysis, stronger governance, and controlled recurring spreadsheet coexistence.

### User and business outcome

Customers gain advanced identity, collaboration, reporting, workflow, governance, and controlled recurring spreadsheet synchronization.

### Included scope

- Passwordless authentication, SSO and identity-provider mapping, service accounts, temporary access maturity, and periodic access-review campaigns.
- Password-protected file handling, advanced time-series/hierarchy/denormalization profiling, collaborative context review, reference-data inference, and governed learning from corrections.
- Advanced structural transformations and selective regeneration that preserves human edits.
- Bulk actions, related-record panels, Kanban/calendar/timeline views, duplicate merge, attachments, comments, mentions, tags, notification preferences, templates, and digests.
- Scheduled workflows, service-level timers, calculations, webhooks, human tasks, workflow simulation/versioning, custom reports, pivot-style analysis, drill-down, cross-filtering, and typo-tolerant search.
- Manual, scheduled, and incremental spreadsheet synchronization; change/deletion detection; conflicts; source-of-truth policies; schema drift; logs; retries; rollback; and high-impact approval.
- Branding, terminology, email templates, localization, feature toggles, cloning, sandbox data, release notes, configuration policies, audit retention/legal holds, security restrictions, privacy requests, billing lifecycle, AI assistance, troubleshooting, richer export, and secure deletion evidence.

### Primary architecture and engineering deliverables

- Identity-provider abstraction and provisioning/audit model suitable for multiple SSO providers and service identities.
- Incremental synchronization state store with stable matching keys, source/application versions, tombstones, field-level provenance, conflict records, policies, and reconciliation.
- Workflow scheduler and timer service with calendars, deduplication, late execution handling, and safe retries.
- Collaboration and notification preference model that respects record/field permissions and external-user boundaries.
- Reporting query and cache layer supporting pivot-style analysis and cross-filtering while preserving row-level security.
- Configuration-policy and retention/hold services that can lock lower-level settings without creating hidden privilege escalation.

### Formal requirement coverage

- **9.2 User Management, Authentication, and Authorization:** `FR-IAM-002`, `FR-IAM-004`, `FR-IAM-009`
- **9.3 Spreadsheet Upload and Source Management:** `FR-UPL-003`
- **9.4 Spreadsheet Profiling and Structural Analysis:** `FR-PRF-006`
- **9.5 Business-Context Collection:** `FR-CTX-004`
- **9.6 AI-Assisted Schema and Relationship Inference:** `FR-AIG-005`, `FR-AIG-007`
- **9.8 Data Cleaning, Mapping, and Transformation:** `FR-DQT-002`
- **9.9 Application Blueprint Generation:** `FR-BLP-005`
- **9.10 Generated User Interface:** `FR-UI-004`, `FR-UI-005`
- **9.11 Data and Record Management:** `FR-DAT-003`, `FR-DAT-004`
- **9.12 Workflow and Business-Rule Engine:** `FR-WFL-002`, `FR-WFL-005`, `FR-WFL-007`
- **9.13 Dashboards, Reports, and Analytics:** `FR-RPT-002`, `FR-RPT-003`
- **9.14 Search and Discovery:** `FR-SRC-003`
- **9.15 Notifications and Collaboration:** `FR-NTF-003`, `FR-NTF-004`
- **9.16 Spreadsheet Synchronization:** `FR-SYN-002`, `FR-SYN-003`, `FR-SYN-004`
- **9.17 Application Customization:** `FR-CUS-001`, `FR-CUS-004`, `FR-CUS-005`
- **9.18 Application Lifecycle and Environment Management:** `FR-LCM-006`
- **9.20 Administration and Governance:** `FR-GOV-004`, `FR-GOV-005`
- **9.21 Security and Privacy Functions:** `FR-SEC-004`, `FR-SEC-006`
- **9.22 Billing, Subscription, and Usage Management:** `FR-BIL-004`
- **9.23 Support and Product Assistance:** `FR-SUP-002`, `FR-SUP-004`
- **9.26 Import, Export, Portability, and Offboarding:** `FR-EXP-002`, `FR-EXP-004`

**Requirement count:** 38

### Exit gate

- Recurring sync is enabled only for entities with stable matching, explicit source-of-truth policies, deletion rules, and approved conflict handling.
- Concurrent spreadsheet and application edits generate deterministic conflicts or governed merges; neither side is silently overwritten.
- SSO, service-account, and access-review flows pass lifecycle, least-privilege, revocation, and audit tests.
- Advanced views, collaboration, workflows, notifications, and reports consistently enforce field/record security.
- Privacy, legal-hold, secure-deletion, and billing lifecycle actions preserve required evidence and do not block authorized portability.
- Selective regeneration and advanced customization do not overwrite protected human changes or break deployed applications without impact review.

### Demonstrable vertical slice

Connect SSO, schedule an incremental source refresh, detect a renamed column and a conflicting edit, resolve it under an approved policy, run a scheduled escalation, collaborate on a record, analyze results in a secured pivot report, and complete an access review.

### Explicitly deferred from this phase

Broad external connector ecosystem, stable public APIs, partner extension packaging, SDK/CLI, public template marketplace, semantic search, and custom component marketplace.

## 12. Phase 8 — Integrations, Reuse, and Governed Extensibility

### Objective

Turn byeExcel from a powerful product into a reusable delivery platform that can integrate with surrounding systems and support governed partner/developer extensions.

### User and business outcome

byeExcel becomes an integration-capable and safely extensible platform with APIs, connectors, reusable templates, and Jaclang extension controls.

### Included scope

- Cloud-storage import and source refresh foundations.
- Application REST and/or GraphQL APIs, generated documentation, API authentication, keys, OAuth, rate limits, import/export endpoints, and permission parity with the UI.
- Outbound and inbound webhooks with signing, retries, idempotency, delivery logs, replay, and dead-letter handling.
- Prioritized connectors for cloud storage, email, accounting, CRM, collaboration, identity, and automation platforms, selected using validated customer demand rather than breadth targets alone.
- Reusable application/schema/workflow/dashboard templates with compatibility metadata and controlled instantiation.
- Jaclang extension points, custom logic boundaries, event hooks, secrets management, source-control integration, automated tests, deployment pipelines, permission manifests, isolation, and upgrade compatibility.

### Primary architecture and engineering deliverables

- Versioned public API and event contracts with deprecation policy, scopes, rate limits, idempotency, tenant context, and audit.
- Connector runtime separated from core transactions, with secrets isolation, least privilege, health, retry, replay, mapping, and customer-visible status.
- Extension manifest defining permissions, events, data access, configuration, dependencies, resource limits, version compatibility, and deployment scope.
- Template package format linking blueprint fragments, transformations, sample data, documentation, compatibility, tests, and version metadata.
- Partner/developer environment with non-production test data and no implicit production-data access.

### Formal requirement coverage

- **9.3 Spreadsheet Upload and Source Management:** `FR-UPL-002`
- **9.19 Integrations and APIs:** `FR-INT-001`, `FR-INT-002`, `FR-INT-003`, `FR-INT-004`
- **9.24 Templates and Reuse:** `FR-TPL-001`
- **9.25 Developer and Extensibility Capabilities:** `FR-DEV-001`, `FR-DEV-004`, `FR-DEV-005`

**Requirement count:** 9

### Exit gate

- Public API operations enforce the same validation, authorization, audit, concurrency, and retention rules as first-party UI operations.
- At least three demand-validated connectors operate with health monitoring, retry/replay, customer-visible errors, and safe credential revocation.
- Webhook delivery is signed, idempotent, replayable, rate-controlled, and cannot expose unauthorized field content.
- A partner can instantiate a supported template and deliver a customer preview faster than starting from a blank blueprint without creating a runtime fork.
- A Jaclang extension can be built, tested, permission-reviewed, deployed to a non-production environment, promoted, monitored, disabled, and upgraded under isolation controls.
- API, connector, template, and extension compatibility are covered by automated contract and regression tests.

### Demonstrable vertical slice

Import a workbook from cloud storage, create records through a scoped API, emit a signed webhook, synchronize a prioritized business connector, instantiate a reusable template, and deploy a permission-scoped Jaclang extension through a tested pipeline.

### Explicitly deferred from this phase

Public marketplace economics, unrestricted third-party components, broad connector parity, end-user SDK/CLI, semantic search, and advanced natural-language analytics.

## 13. Phase 9 — Strategic Intelligence and Ecosystem

### Objective

Invest selectively in ecosystem and intelligence capabilities only after the core conversion, operation, synchronization, and extension models demonstrate product-market fit and sustainable support economics.

### User and business outcome

The product adds semantic discovery, scheduled analytics, public/private template ecosystems, SDK/CLI capabilities, and advanced component extensibility where validated by demand.

### Included scope

- Scheduled report delivery and governed distribution.
- Permission-aware semantic search with evidence, confidence, traceability, and sensitive-data controls.
- Curated industry/process template catalog, organization-private templates, controlled publishing, versioning, compatibility, update propagation, and marketplace governance where commercially justified.
- SDK and CLI for model, blueprint, data, test, deployment, and administrative automation.
- Custom UI components and connectors with stronger sandboxing, review, signing, distribution, compatibility, and lifecycle management.
- Potential strategic extensions: natural-language analytics, metric catalog, multi-application composition, shared master data, process discovery from documents/activity/integrations, private networking, customer-managed keys, multi-region or private deployment.

### Primary architecture and engineering deliverables

- Semantic indexing that preserves tenant, record, and field security at indexing and retrieval time and can show source evidence.
- Marketplace trust model covering publisher identity, review, signing, permissions, vulnerabilities, compatibility, licensing, billing, support, revocation, and customer consent.
- SDK/CLI contract generated from the same versioned blueprint/API schemas used internally.
- Component sandbox and resource-governance model preventing extensions from escaping tenant, data, network, or secret boundaries.
- Advanced analytics architecture that separates governed metrics from unconstrained model-generated queries.

### Formal requirement coverage

- **9.13 Dashboards, Reports, and Analytics:** `FR-RPT-004`
- **9.14 Search and Discovery:** `FR-SRC-004`
- **9.24 Templates and Reuse:** `FR-TPL-002`, `FR-TPL-003`, `FR-TPL-004`
- **9.25 Developer and Extensibility Capabilities:** `FR-DEV-002`, `FR-DEV-003`

**Requirement count:** 7

### Exit gate

- Each strategic capability has a validated customer segment, measurable outcome, sustainable cost/support model, and explicit security/privacy approval before general availability.
- Semantic or natural-language features never bypass authorization, metric definitions, evidence requirements, or human approval for material changes.
- Template/component marketplace assets are signed, permission-declared, scanned, versioned, reversible, and supportable.
- SDK/CLI and custom components have published compatibility and deprecation policies with automated conformance tests.
- Enterprise deployment options are introduced only with sufficient revenue, operational maturity, and incident-response capability.

### Demonstrable vertical slice

Search across an application semantically with evidence and permissions, schedule a governed report, install a signed template/component through an approval flow, automate deployment with the CLI, and demonstrate safe rollback or revocation.

### Explicitly deferred from this phase

Any strategic capability without validated demand, safe operating model, and positive unit economics remains out of scope.

## 14. Parallel Workstreams and Recommended Team Topology

### Recommended workstreams

| Workstream | Primary responsibility | Starts | Continues through |
|---|---|---|---|
| Product, discovery, and design | Archetypes, research, journey, blueprint UX, usability, prioritization, design-partner acceptance, metrics. | Phase 0 | All phases |
| Platform, identity, and security | Tenancy, IAM, policy enforcement, audit, environments, billing controls, support access, privacy/security functions. | Phase 0/1 | All phases |
| Spreadsheet, data, and AI | Parsing, profiling, context, inference, transformations, lineage, migration, synchronization, AI evaluation. | Phase 0 | Phase 9 |
| Generator and application runtime | Blueprint contracts, generated components, CRUD, workflows, search, reports, customization, release/runtime compatibility. | Phase 0/1 | Phase 9 |
| Reliability and internal operations | Jobs, observability, feature flags, deployment, backups, incident response, support diagnostics, capacity, cost. | Phase 1 | All phases |
| Quality engineering | Test strategy, benchmark corpus, authorization/security tests, data reconciliation, AI evaluation, contract tests, E2E and recovery. | Phase 0 | All phases |
| Partner/customer implementation | Context workshops, data remediation, acceptance, training, change management, template feedback, outcomes. | Phase 0 | All customer-facing phases |

### Planning assumption

A credible MVP plan should assume at least three cross-functional delivery squads plus shared product/design, security, SRE/DevOps, data/AI evaluation, and quality leadership. One possible topology is:

- **Trust and platform squad:** multi-tenancy, IAM, governance, billing, lifecycle, operations, security, and support controls.
- **Data intelligence squad:** upload, parsing, profiling, context, inference, transformations, lineage, migration, and synchronization.
- **Generator and runtime squad:** blueprint, generated UI, records, workflows, search, dashboards, notifications, customization, and release runtime.
- **Shared enabling group:** product owner, business analysis, UX research/design, architecture, security/privacy, SRE, quality automation, AI evaluation, documentation, and implementation-partner operations.

This staffing assumption requires validation against available Jaclang platform capabilities. Existing reusable authentication, RBAC, UI, dashboard, CRUD, notification, audit, and configuration services should reduce effort only after their production quality and integration contracts are verified.

### Safe parallelization

- Phase 2 parsing/profiling can begin once Phase 1 storage, tenant context, job, and audit contracts stabilize.
- Phase 3 AI evaluation can begin during Phase 0 using an isolated corpus, but customer-facing inference must integrate Phase 2 evidence and Phase 1 security controls.
- Phase 5 runtime components can be built during Phases 3–4 using synthetic, hand-authored blueprints, provided the blueprint contract is versioned and contract-tested.
- Phase 6 production hardening begins in Phase 1; it is a culmination gate, not a final cleanup sprint.
- Phase 8 API/extension design can start during Phase 5 to prevent internal contracts from becoming unusable, but public stability should wait until after the MVP runtime proves repeatable.

## 15. Backlog Decomposition

The functional requirements are acceptance baselines, not one-to-one backlog items. Recommended hierarchy:

```text
Product outcome
  → Implementation phase
    → Epic
      → Capability increment
        → User story / operator story
          → Engineering, data, security, QA, and documentation tasks
            → Automated and manual acceptance evidence
```

### Recommended vertical MVP slices

| Slice | End-to-end result | Principal phases |
|---|---|---|
| Slice A — Secure source diagnosis | Register → create workspace → upload workbook → scan → profile → issue report. | 1–2 |
| Slice B — Confirmed business model | Profile → context questions → inference → evidence → correction → model approval. | 2–3 |
| Slice C — Reconciled migration package | Approved model → mapping → cleaning → quarantine → reconciliation → blueprint approval. | 3–4 |
| Slice D — Working preview application | Blueprint → generated UI/data model → import → workflow → dashboard → permission test. | 4–5 |
| Slice E — Production release | Preview acceptance → approval gates → publish → health check → users → support → rollback/export. | 5–6 |
| Slice F — Controlled coexistence | Updated spreadsheet → drift/change detection → conflict → policy/human resolution → reconciled sync. | 7 |
| Slice G — Ecosystem delivery | API/connector/template/extension → test → permission review → deployment → monitoring → rollback. | 8–9 |

### Story readiness checklist

A story should not enter implementation until it identifies the actor, tenant/application/environment scope, preconditions, normal flow, failure behavior, audit events, permissions, sensitive-data behavior, idempotency/concurrency needs, observability, acceptance scenarios, and release/rollback implications.

## 16. Business-Rule Introduction and Maturity

| Rule | First enforced | Full maturity | Implementation note |
|---|---|---|---|
| BR-001 Tenant data isolation | Phase 1 | Phase 1 and continuous | Architectural invariant tested in every new channel and feature. |
| BR-002 Publication approval | Phase 4 draft approvals | Phase 6 | Blueprint approval begins earlier; production release gates complete in Phase 6. |
| BR-003 Destructive-change confirmation | Phase 3 | Phase 7 | Model/schema impact begins in Phase 3; sync, retention, and extension impacts mature later. |
| BR-004 Permission precedence | Phase 1 | Phase 1 and continuous | One effective-access calculation must govern all channels. |
| BR-005 Record ownership | Phase 5 | Phase 7 | Core ownership/status in Phase 5; collaboration and advanced routing mature in Phase 7. |
| BR-006 Data validation and state integrity | Phase 3 | Phase 5 and continuous | Schema validation starts in modeling and becomes channel-wide in the generated runtime. |
| BR-007 Synchronization precedence | Phase 4 | Phase 7 | One-time migration policy is recorded in Phase 4; recurring source precedence operates in Phase 7. |
| BR-008 Conflict handling | Phase 4 | Phase 7 | Import/mapping conflicts are handled first; concurrent bidirectional conflicts mature with recurring sync. |
| BR-009 Application and job versioning | Phase 1 | Phase 6 | Job/audit versions begin in Phase 1; full blueprint/build/release/migration lineage completes by MVP release. |
| BR-010 AI recommendation approval | Phase 3 | Phase 3 and continuous | AI remains advisory for all material decisions. |
| BR-011 Sensitive-data treatment | Phase 1 | Phase 7 | Conservative classification/masking begins in Phase 1; privacy/legal-hold lifecycle matures later. |
| BR-012 Subscription limit enforcement | Phase 1 | Phase 7 | Entitlements and safe limits begin in MVP; full invoice/payment/grace lifecycle follows. |
| BR-013 Customer portability | Phase 6 | Phase 7 | Complete data export is MVP; richer schema/config/audit export and deletion evidence follow. |
| BR-014 Support access | Phase 1 | Phase 1 and continuous | No standing support access at any phase. |
| BR-015 No silent data loss | Phase 2 | Phase 4 and continuous | Source-region counting begins in profiling; full transformation/import reconciliation completes in Phase 4. |
| BR-016 Separation of production and draft | Phase 1 architecture | Phase 6 | Environment scope is foundational; complete preview/test/production release enforcement is an MVP gate. |

## 17. Phase Metrics and Decision Gates

| Phase | Leading measures | Gate question |
|---|---|---|
| Phase 0 | Representative corpus coverage; prototype task completion; unanswered context rate; baseline expert effort; architecture-risk closure. | Do we have a bounded, valuable, technically credible MVP with evidence that target users understand the governed process? |
| Phase 1 | Tenant-isolation test pass rate; auth success/failure; invitation completion; permission-defect rate; job recovery rate; audit coverage. | Can the platform be trusted with multiple customers and sensitive business data? |
| Phase 2 | Upload success; safe rejection; profiling completion; issue precision/recall; unsupported-feature detection; time to profile; unexplained-region count. | Can byeExcel reliably explain what is in the source without losing or executing anything unsafe? |
| Phase 3 | Entity/key/relationship acceptance; severe inference error rate; correction time; context completeness; AI cost/latency; evidence usage. | Does inference measurably reduce modeling effort while preserving human understanding and control? |
| Phase 4 | Mapping completion; invalid/quarantine rate; duplicate resolution; reconciliation variance; deterministic replay; blueprint validation success. | Can source data be transformed and represented without unexplained loss or irreproducible decisions? |
| Phase 5 | Generation success; task completion; permission negative-test success; workflow execution/recovery; page performance; accessibility defects; customization effort. | Is the generated application operationally usable for the selected archetypes? |
| Phase 6 | Time upload-to-production; migration success; release success/rollback; backup restore; production incidents; user adoption; spreadsheet usage reduction; support volume. | Is the full MVP safe, supportable, commercially deliverable, and valuable in production? |
| Phase 7 | Sync success; conflict rate/time to resolve; SSO adoption; access-review completion; collaboration usage; advanced workflow/report reliability. | Can customers operate continuously at higher complexity without uncontrolled coexistence or governance burden? |
| Phase 8 | API/connector success; webhook delivery; integration incident rate; template reuse; extension deployment success; partner delivery time; compatibility defects. | Can the platform expand safely through integrations, reuse, and governed extensions? |
| Phase 9 | Marketplace adoption; semantic-search precision and evidence use; scheduled-report success; SDK usage; ecosystem revenue/support cost; enterprise demand. | Does each strategic investment create differentiated value with an acceptable trust and operating model? |

## 18. MVP Entry and Exit Summary

### MVP entry

- Phase 0 exit gate is approved.
- The Jaclang platform services to be reused have passed a capability and production-readiness assessment.
- Security/privacy threat model, AI provider policy, data-processing boundaries, and source-file support matrix are approved.
- Product, architecture, quality, operations, and design-partner owners are named and available.

### MVP exit

- Phases 1–6 exit gates are satisfied and all 92 Must-priority requirements have acceptance evidence.
- At least 10–20 design-partner applications complete the end-to-end journey with production-like data and accountable sign-off.
- There are no unresolved critical tenant-isolation, data-loss, permission, publication, or sensitive-data defects.
- Accepted migrations show zero unexplained data loss; invalid or excluded records are traceable, recoverable, and exportable.
- Representative non-technical users can complete critical model-review and operational tasks at validated usability thresholds.
- Monitoring, backup/restore, incident response, support access, billing entitlements, export, archival, and closure are production-ready.
- Commercial packaging, implementation responsibilities, support limits, file/complexity support matrix, and known limitations are explicit.

## 19. Implementation Risks by Phase

| Phase | Highest implementation risk | Required mitigation before exit |
|---|---|---|
| Phase 0 | Building for an unbounded set of spreadsheet processes. | Approve archetypes, complexity bands, support matrix, and design-partner qualification. |
| Phase 1 | Cross-tenant or cross-channel authorization inconsistency. | Central policy enforcement, negative tests, audit coverage, threat review, and penetration testing. |
| Phase 2 | Parser variability, hidden content, corrupt files, or unsupported constructs create unsafe or incomplete analysis. | Isolation, feature inventory, conformance corpus, explicit sampling/completeness, and no macro execution. |
| Phase 3 | Plausible but wrong AI model decisions create false confidence. | Evidence, alternatives, deterministic validators, severe-error thresholds, human approval, and regression evaluation. |
| Phase 4 | Silent transformation loss or irreproducible migrations. | Lineage, quarantine, deterministic rules, complete reconciliation, versioning, idempotency, and rollback analysis. |
| Phase 5 | Generated applications are generic, slow, insecure, or difficult for frontline users. | Archetype-specific usability tests, shared runtime, authorization parity, performance budgets, accessibility, and configuration-first customization. |
| Phase 6 | Production release and support fail under real customer conditions. | Controlled cohorts, operational readiness gate, restore tests, incident drills, feature flags, explicit limits, and measured design-partner outcomes. |
| Phase 7 | Recurring synchronization creates competing sources of truth and data conflicts. | Stable-key qualification, field/entity source policies, conflict records, human resolution, drift approval, and retirement strategy. |
| Phase 8 | Connectors and extensions create security, support, and upgrade fragmentation. | Scoped contracts, isolation, secrets, signing, compatibility tests, observability, deprecation, and partner certification. |
| Phase 9 | Marketplace or advanced AI breadth consumes investment without differentiated value. | Demand, unit-economics, quality, trust, and operating-model gates for each capability. |

## 20. Recommended Phase Approval Authority

| Gate | Minimum accountable approvers |
|---|---|
| Phase 0 → 1 | Product executive, product owner, principal architect, security/privacy lead, engineering lead, design-partner lead. |
| Phase 1 → 2 | Engineering, security, platform operations, product owner. |
| Phase 2 → 3 | Product owner, data/AI lead, security/privacy lead, quality lead. |
| Phase 3 → 4 | Product owner, domain/BA lead, AI governance owner, data architecture lead. |
| Phase 4 → 5 | Product owner, data migration owner, application/runtime architect, QA lead. |
| Phase 5 → 6 | Product owner, UX lead, security lead, SRE/operations lead, design-partner representative. |
| MVP general availability | Executive sponsor, product, engineering, security/privacy, operations/support, commercial/legal, and documented design-partner evidence. |
| Post-MVP / strategic gates | Product portfolio owner plus capability-specific security, architecture, operations, and commercial owners. |

## 21. Full Functional Requirement-to-Phase Mapping

Each functional requirement from the source specification is assigned to one primary implementation phase. A requirement may require foundational work earlier and continued hardening later; this table identifies the phase in which its complete planned behavior is accepted for the stated release recommendation.

| Requirement ID | Requirement name | Capability area | Priority | Source release recommendation | Primary phase |
|---|---|---|---|---|---|
| `FR-TEN-001` | Self-service registration and verification | 9.1 Account, Tenant, and Organization Management | Must | MVP | Phase 1 |
| `FR-TEN-002` | Organization creation and ownership | 9.1 Account, Tenant, and Organization Management | Must | MVP | Phase 1 |
| `FR-TEN-003` | Workspace lifecycle | 9.1 Account, Tenant, and Organization Management | Must | MVP | Phase 1 |
| `FR-TEN-004` | Organization settings and policy defaults | 9.1 Account, Tenant, and Organization Management | Must | MVP | Phase 1 |
| `FR-TEN-005` | Account suspension, recovery, and closure | 9.1 Account, Tenant, and Organization Management | Must | MVP | Phase 6 |
| `FR-IAM-001` | Email and password authentication | 9.2 User Management, Authentication, and Authorization | Must | MVP | Phase 1 |
| `FR-IAM-002` | Passwordless authentication | 9.2 User Management, Authentication, and Authorization | Should | Post-MVP | Phase 7 |
| `FR-IAM-003` | Multi-factor authentication | 9.2 User Management, Authentication, and Authorization | Must | MVP | Phase 1 |
| `FR-IAM-004` | Single sign-on and identity-provider mapping | 9.2 User Management, Authentication, and Authorization | Should | Post-MVP | Phase 7 |
| `FR-IAM-005` | Session management and revocation | 9.2 User Management, Authentication, and Authorization | Must | MVP | Phase 1 |
| `FR-IAM-006` | Invitations, membership, and temporary access | 9.2 User Management, Authentication, and Authorization | Must | MVP | Phase 1 |
| `FR-IAM-007` | Teams, custom roles, and effective permissions | 9.2 User Management, Authentication, and Authorization | Must | MVP | Phase 1 |
| `FR-IAM-008` | Record-level and field-level authorization | 9.2 User Management, Authentication, and Authorization | Must | MVP | Phase 1 |
| `FR-IAM-009` | Service accounts and access reviews | 9.2 User Management, Authentication, and Authorization | Should | Post-MVP | Phase 7 |
| `FR-UPL-001` | Supported file upload and progress | 9.3 Spreadsheet Upload and Source Management | Must | MVP | Phase 2 |
| `FR-UPL-002` | Cloud-storage source import | 9.3 Spreadsheet Upload and Source Management | Should | Post-MVP | Phase 8 |
| `FR-UPL-003` | Encrypted and password-protected files | 9.3 Spreadsheet Upload and Source Management | Should | Post-MVP | Phase 7 |
| `FR-UPL-004` | Spreadsheet feature inventory and preservation | 9.3 Spreadsheet Upload and Source Management | Must | MVP | Phase 2 |
| `FR-UPL-005` | Unsupported feature handling | 9.3 Spreadsheet Upload and Source Management | Must | MVP | Phase 2 |
| `FR-UPL-006` | Source versioning and duplicate detection | 9.3 Spreadsheet Upload and Source Management | Must | MVP | Phase 2 |
| `FR-UPL-007` | Malware scanning and secure quarantine | 9.3 Spreadsheet Upload and Source Management | Must | MVP | Phase 2 |
| `FR-PRF-001` | Data-region and header detection | 9.4 Spreadsheet Profiling and Structural Analysis | Must | MVP | Phase 2 |
| `FR-PRF-002` | Data-type, format, and locale profiling | 9.4 Spreadsheet Profiling and Structural Analysis | Must | MVP | Phase 2 |
| `FR-PRF-003` | Keys, duplicates, missing values, and outliers | 9.4 Spreadsheet Profiling and Structural Analysis | Must | MVP | Phase 2 |
| `FR-PRF-004` | Cross-dataset reference and lookup analysis | 9.4 Spreadsheet Profiling and Structural Analysis | Must | MVP | Phase 2 |
| `FR-PRF-005` | Formula and dependency analysis | 9.4 Spreadsheet Profiling and Structural Analysis | Must | MVP | Phase 2 |
| `FR-PRF-006` | Time-series, hierarchy, and denormalization detection | 9.4 Spreadsheet Profiling and Structural Analysis | Should | Post-MVP | Phase 7 |
| `FR-CTX-001` | Adaptive guided questionnaire | 9.5 Business-Context Collection | Must | MVP | Phase 3 |
| `FR-CTX-002` | Free-text, examples, and supporting evidence | 9.5 Business-Context Collection | Must | MVP | Phase 3 |
| `FR-CTX-003` | Confidence, completeness, and follow-up management | 9.5 Business-Context Collection | Must | MVP | Phase 3 |
| `FR-CTX-004` | Collaborative context review and approval | 9.5 Business-Context Collection | Should | Post-MVP | Phase 7 |
| `FR-AIG-001` | Entity and field inference | 9.6 AI-Assisted Schema and Relationship Inference | Must | MVP | Phase 3 |
| `FR-AIG-002` | Semantic matching, synonyms, and deduplication | 9.6 AI-Assisted Schema and Relationship Inference | Must | MVP | Phase 3 |
| `FR-AIG-003` | Data-type and primary-key inference | 9.6 AI-Assisted Schema and Relationship Inference | Must | MVP | Phase 3 |
| `FR-AIG-004` | Foreign-key and cardinality inference | 9.6 AI-Assisted Schema and Relationship Inference | Must | MVP | Phase 3 |
| `FR-AIG-005` | Reference-data and enumeration inference | 9.6 AI-Assisted Schema and Relationship Inference | Should | Post-MVP | Phase 7 |
| `FR-AIG-006` | Inference explanation and alternatives | 9.6 AI-Assisted Schema and Relationship Inference | Must | MVP | Phase 3 |
| `FR-AIG-007` | Correction capture and governed learning | 9.6 AI-Assisted Schema and Relationship Inference | Should | Post-MVP | Phase 7 |
| `FR-MOD-001` | Visual and form-based schema editing | 9.7 Data Modeling and Schema Editor | Must | MVP | Phase 3 |
| `FR-MOD-002` | Create, rename, merge, split, and delete entities | 9.7 Data Modeling and Schema Editor | Must | MVP | Phase 3 |
| `FR-MOD-003` | Field definition and constraints | 9.7 Data Modeling and Schema Editor | Must | MVP | Phase 3 |
| `FR-MOD-004` | Relationships, enumerations, calculated fields, and cascade behavior | 9.7 Data Modeling and Schema Editor | Must | MVP | Phase 3 |
| `FR-MOD-005` | Validation-rule authoring | 9.7 Data Modeling and Schema Editor | Must | MVP | Phase 3 |
| `FR-MOD-006` | Schema impact preview, undo, and redo | 9.7 Data Modeling and Schema Editor | Must | MVP | Phase 3 |
| `FR-DQT-001` | Source-to-target column mapping | 9.8 Data Cleaning, Mapping, and Transformation | Must | MVP | Phase 4 |
| `FR-DQT-002` | Structural transformations | 9.8 Data Cleaning, Mapping, and Transformation | Should | Post-MVP | Phase 7 |
| `FR-DQT-003` | Format, locale, currency, and unit normalization | 9.8 Data Cleaning, Mapping, and Transformation | Must | MVP | Phase 4 |
| `FR-DQT-004` | Duplicate resolution and record matching | 9.8 Data Cleaning, Mapping, and Transformation | Must | MVP | Phase 4 |
| `FR-DQT-005` | Missing, invalid, and reference-data handling | 9.8 Data Cleaning, Mapping, and Transformation | Must | MVP | Phase 4 |
| `FR-DQT-006` | Transformation preview, lineage, and reuse | 9.8 Data Cleaning, Mapping, and Transformation | Must | MVP | Phase 4 |
| `FR-BLP-001` | Blueprint creation as editable intermediate representation | 9.9 Application Blueprint Generation | Must | MVP | Phase 4 |
| `FR-BLP-002` | Blueprint validation | 9.9 Application Blueprint Generation | Must | MVP | Phase 4 |
| `FR-BLP-003` | Blueprint preview and comparison | 9.9 Application Blueprint Generation | Must | MVP | Phase 4 |
| `FR-BLP-004` | Blueprint approval and decision log | 9.9 Application Blueprint Generation | Must | MVP | Phase 4 |
| `FR-BLP-005` | Selective regeneration and preservation of edits | 9.9 Application Blueprint Generation | Should | Post-MVP | Phase 7 |
| `FR-UI-001` | Responsive navigation and application shell | 9.10 Generated User Interface | Must | MVP | Phase 5 |
| `FR-UI-002` | Generated list, detail, create, and edit screens | 9.10 Generated User Interface | Must | MVP | Phase 5 |
| `FR-UI-003` | Search, sort, filter, pagination, and saved views | 9.10 Generated User Interface | Must | MVP | Phase 5 |
| `FR-UI-004` | Bulk actions and related-record panels | 9.10 Generated User Interface | Should | Post-MVP | Phase 7 |
| `FR-UI-005` | Kanban, calendar, and timeline views | 9.10 Generated User Interface | Should | Post-MVP | Phase 7 |
| `FR-UI-006` | Empty, loading, error, and accessibility states | 9.10 Generated User Interface | Must | MVP | Phase 5 |
| `FR-DAT-001` | Record lifecycle operations | 9.11 Data and Record Management | Must | MVP | Phase 5 |
| `FR-DAT-002` | Bulk import, update, edit, and delete | 9.11 Data and Record Management | Must | MVP | Phase 5 |
| `FR-DAT-003` | Duplicate detection and record merge | 9.11 Data and Record Management | Should | Post-MVP | Phase 7 |
| `FR-DAT-004` | Attachments, comments, mentions, and tags | 9.11 Data and Record Management | Should | Post-MVP | Phase 7 |
| `FR-DAT-005` | Ownership, status, history, retention, and export | 9.11 Data and Record Management | Must | MVP | Phase 5 |
| `FR-WFL-001` | Event-triggered workflows | 9.12 Workflow and Business-Rule Engine | Must | MVP | Phase 5 |
| `FR-WFL-002` | Scheduled workflows and service-level timers | 9.12 Workflow and Business-Rule Engine | Should | Post-MVP | Phase 7 |
| `FR-WFL-003` | Status transitions and assignments | 9.12 Workflow and Business-Rule Engine | Must | MVP | Phase 5 |
| `FR-WFL-004` | Approval processes and conditional routing | 9.12 Workflow and Business-Rule Engine | Must | MVP | Phase 5 |
| `FR-WFL-005` | Calculations, notifications, webhooks, and human tasks | 9.12 Workflow and Business-Rule Engine | Should | Post-MVP | Phase 7 |
| `FR-WFL-006` | Retry, error queues, history, and manual recovery | 9.12 Workflow and Business-Rule Engine | Must | MVP | Phase 5 |
| `FR-WFL-007` | Workflow simulation and versioning | 9.12 Workflow and Business-Rule Engine | Should | Post-MVP | Phase 7 |
| `FR-RPT-001` | Auto-generated and role-specific dashboards | 9.13 Dashboards, Reports, and Analytics | Must | MVP | Phase 5 |
| `FR-RPT-002` | Custom reports and pivot-style analysis | 9.13 Dashboards, Reports, and Analytics | Should | Post-MVP | Phase 7 |
| `FR-RPT-003` | Interactive filters, drill-down, and cross-filtering | 9.13 Dashboards, Reports, and Analytics | Should | Post-MVP | Phase 7 |
| `FR-RPT-004` | Scheduled report delivery and export | 9.13 Dashboards, Reports, and Analytics | Could | Future | Phase 9 |
| `FR-RPT-005` | Metric governance, freshness, and row-level security | 9.13 Dashboards, Reports, and Analytics | Must | MVP | Phase 5 |
| `FR-SRC-001` | Global and entity-specific search | 9.14 Search and Discovery | Must | MVP | Phase 5 |
| `FR-SRC-002` | Structured filters and saved searches | 9.14 Search and Discovery | Must | MVP | Phase 5 |
| `FR-SRC-003` | Suggestions and typo tolerance | 9.14 Search and Discovery | Should | Post-MVP | Phase 7 |
| `FR-SRC-004` | Semantic search with evidence controls | 9.14 Search and Discovery | Could | Future | Phase 9 |
| `FR-NTF-001` | In-app notifications and read state | 9.15 Notifications and Collaboration | Must | MVP | Phase 5 |
| `FR-NTF-002` | Approval requests, reminders, and escalations | 9.15 Notifications and Collaboration | Must | MVP | Phase 5 |
| `FR-NTF-003` | Comments, mentions, and assignments | 9.15 Notifications and Collaboration | Should | Post-MVP | Phase 7 |
| `FR-NTF-004` | Channel preferences, templates, and digests | 9.15 Notifications and Collaboration | Should | Post-MVP | Phase 7 |
| `FR-SYN-001` | One-time migration mode | 9.16 Spreadsheet Synchronization | Must | MVP | Phase 4 |
| `FR-SYN-002` | Manual and scheduled synchronization | 9.16 Spreadsheet Synchronization | Should | Post-MVP | Phase 7 |
| `FR-SYN-003` | Incremental change and deletion detection | 9.16 Spreadsheet Synchronization | Should | Post-MVP | Phase 7 |
| `FR-SYN-004` | Conflict detection and resolution | 9.16 Spreadsheet Synchronization | Should | Post-MVP | Phase 7 |
| `FR-SYN-005` | Schema-drift detection and impact control | 9.16 Spreadsheet Synchronization | Must | MVP for detection; post-MVP for recurring sync | Phase 4 |
| `FR-SYN-006` | Sync logs, retry, rollback, and reconciliation | 9.16 Spreadsheet Synchronization | Must | MVP | Phase 4 |
| `FR-SYN-007` | Formula-result and source-of-truth policies | 9.16 Spreadsheet Synchronization | Must | MVP | Phase 4 |
| `FR-CUS-001` | Branding and terminology | 9.17 Application Customization | Should | Post-MVP | Phase 7 |
| `FR-CUS-002` | Navigation and page-layout customization | 9.17 Application Customization | Must | MVP | Phase 5 |
| `FR-CUS-003` | Custom views, dashboards, workflows, and validations | 9.17 Application Customization | Must | MVP | Phase 5 |
| `FR-CUS-004` | Email and notification templates | 9.17 Application Customization | Should | Post-MVP | Phase 7 |
| `FR-CUS-005` | Localization and feature toggles | 9.17 Application Customization | Should | Post-MVP | Phase 7 |
| `FR-LCM-001` | Draft, preview, development, test, staging, and production states | 9.18 Application Lifecycle and Environment Management | Must | MVP with preview/test/production; additional environments post-MVP | Phase 6 |
| `FR-LCM-002` | Application and blueprint version history | 9.18 Application Lifecycle and Environment Management | Must | MVP | Phase 4 |
| `FR-LCM-003` | Change impact and migration planning | 9.18 Application Lifecycle and Environment Management | Must | MVP | Phase 4 |
| `FR-LCM-004` | Publishing and approval gates | 9.18 Application Lifecycle and Environment Management | Must | MVP | Phase 6 |
| `FR-LCM-005` | Rollback and restore | 9.18 Application Lifecycle and Environment Management | Must | MVP | Phase 6 |
| `FR-LCM-006` | Cloning, sandbox data, templates, and release notes | 9.18 Application Lifecycle and Environment Management | Should | Post-MVP | Phase 7 |
| `FR-INT-001` | Application APIs and documentation | 9.19 Integrations and APIs | Should | Post-MVP | Phase 8 |
| `FR-INT-002` | API authentication, keys, OAuth, and rate limits | 9.19 Integrations and APIs | Should | Post-MVP | Phase 8 |
| `FR-INT-003` | Webhooks and event delivery | 9.19 Integrations and APIs | Should | Post-MVP | Phase 8 |
| `FR-INT-004` | Standard connectors and identity providers | 9.19 Integrations and APIs | Should | Post-MVP | Phase 8 |
| `FR-INT-005` | Integration monitoring and recovery | 9.19 Integrations and APIs | Must | MVP for monitoring framework; connectors post-MVP | Phase 1 |
| `FR-GOV-001` | Platform and tenant administration boundaries | 9.20 Administration and Governance | Must | MVP | Phase 1 |
| `FR-GOV-002` | Usage, storage, and activity monitoring | 9.20 Administration and Governance | Must | MVP | Phase 1 |
| `FR-GOV-003` | Ownership, support contacts, and operational responsibility | 9.20 Administration and Governance | Must | MVP | Phase 1 |
| `FR-GOV-004` | Configuration policies and access reviews | 9.20 Administration and Governance | Should | Post-MVP | Phase 7 |
| `FR-GOV-005` | Audit log access, retention, and legal hold | 9.20 Administration and Governance | Should | Post-MVP | Phase 7 |
| `FR-SEC-001` | Consent and privacy preference management | 9.21 Security and Privacy Functions | Must | MVP | Phase 1 |
| `FR-SEC-002` | Data-residency and tenant isolation controls | 9.21 Security and Privacy Functions | Must | MVP | Phase 1 |
| `FR-SEC-003` | Sensitive fields, classification, masking, and AI controls | 9.21 Security and Privacy Functions | Must | MVP | Phase 1 |
| `FR-SEC-004` | Security policies for sessions, IPs, and domains | 9.21 Security and Privacy Functions | Should | Post-MVP | Phase 7 |
| `FR-SEC-005` | Security alerts and audit access | 9.21 Security and Privacy Functions | Must | MVP | Phase 1 |
| `FR-SEC-006` | Privacy requests, portability, deletion, and backup restoration | 9.21 Security and Privacy Functions | Should | Post-MVP | Phase 7 |
| `FR-BIL-001` | Plans and trials | 9.22 Billing, Subscription, and Usage Management | Must | MVP | Phase 1 |
| `FR-BIL-002` | Seat and application entitlement management | 9.22 Billing, Subscription, and Usage Management | Must | MVP | Phase 1 |
| `FR-BIL-003` | Usage limits and overage notifications | 9.22 Billing, Subscription, and Usage Management | Must | MVP | Phase 1 |
| `FR-BIL-004` | Invoices, payments, subscription change, and grace states | 9.22 Billing, Subscription, and Usage Management | Should | Post-MVP | Phase 7 |
| `FR-SUP-001` | Guided onboarding, tours, and contextual help | 9.23 Support and Product Assistance | Must | MVP | Phase 1 |
| `FR-SUP-002` | In-product AI assistant with grounded scope | 9.23 Support and Product Assistance | Should | Post-MVP | Phase 7 |
| `FR-SUP-003` | Support tickets, diagnostics, and status information | 9.23 Support and Product Assistance | Must | MVP | Phase 1 |
| `FR-SUP-004` | Feedback and context-aware troubleshooting | 9.23 Support and Product Assistance | Should | Post-MVP | Phase 7 |
| `FR-TPL-001` | Application, schema, workflow, and dashboard templates | 9.24 Templates and Reuse | Should | Post-MVP | Phase 8 |
| `FR-TPL-002` | Industry and process template catalog | 9.24 Templates and Reuse | Could | Future | Phase 9 |
| `FR-TPL-003` | Organization-private templates | 9.24 Templates and Reuse | Could | Future | Phase 9 |
| `FR-TPL-004` | Template publishing and versioning | 9.24 Templates and Reuse | Could | Future | Phase 9 |
| `FR-DEV-001` | Jaclang extension points and custom logic | 9.25 Developer and Extensibility Capabilities | Should | Post-MVP | Phase 8 |
| `FR-DEV-002` | SDK, CLI, and generated contracts | 9.25 Developer and Extensibility Capabilities | Could | Future | Phase 9 |
| `FR-DEV-003` | Custom UI components and connectors | 9.25 Developer and Extensibility Capabilities | Could | Future | Phase 9 |
| `FR-DEV-004` | Event hooks and secrets management | 9.25 Developer and Extensibility Capabilities | Should | Post-MVP | Phase 8 |
| `FR-DEV-005` | Source control, tests, pipelines, and extension isolation | 9.25 Developer and Extensibility Capabilities | Should | Post-MVP | Phase 8 |
| `FR-EXP-001` | Complete customer data export | 9.26 Import, Export, Portability, and Offboarding | Must | MVP | Phase 6 |
| `FR-EXP-002` | Schema, configuration, audit, and Excel/CSV export | 9.26 Import, Export, Portability, and Offboarding | Should | Post-MVP | Phase 7 |
| `FR-EXP-003` | Application archival, account closure, and retention | 9.26 Import, Export, Portability, and Offboarding | Must | MVP | Phase 6 |
| `FR-EXP-004` | Secure deletion and deletion evidence | 9.26 Import, Export, Portability, and Offboarding | Should | Post-MVP | Phase 7 |
| `FR-OPS-001` | Operational dashboards and usage analytics | 9.27 Internal Platform Operations | Must | MVP | Phase 1 |
| `FR-OPS-002` | AI/model monitoring and quality evaluation | 9.27 Internal Platform Operations | Must | MVP | Phase 3 |
| `FR-OPS-003` | Generation, import, sync, and workflow job monitoring | 9.27 Internal Platform Operations | Must | MVP | Phase 1 |
| `FR-OPS-004` | Controlled customer support and troubleshooting access | 9.27 Internal Platform Operations | Must | MVP | Phase 1 |
| `FR-OPS-005` | Feature flags, abuse controls, incidents, and operational audit | 9.27 Internal Platform Operations | Must | MVP | Phase 1 |

## 22. Immediate Next Actions

1. Approve or revise the phase boundaries, particularly whether recurring synchronization is commercially required for the first production release.
2. Nominate the first three process archetypes and recruit design partners with representative workbook complexity and sensitive-data profiles.
3. Run the Phase 0 architecture and product-validation work, including the blueprint contract, file support matrix, benchmark corpus, and threat model.
4. Convert Phase 1 into an outcome-based program backlog, then identify which Jaclang platform capabilities are production-ready, need hardening, or must be built.
5. Establish traceability in the delivery tool so every requirement links to phase, epic, stories, design, architecture decision, tests, release evidence, and metrics.
6. Review the indicative durations and team topology against actual staffing, platform maturity, procurement, compliance, and design-partner availability before publishing dates.

---

**Source baseline:** `byeExcel_Product_Description_and_Functional_Requirements.md`

**Coverage check:** 146 of 146 functional requirements allocated exactly once; Phases 1–6 cover 92 Must-priority/hybrid MVP requirements.
