#!/usr/bin/env bash
# UserPromptSubmit hook: injects the documentation placement doctrine.
#
# This file is the doctrine. The plugin previously also shipped a template
# docs/README.md carrying the same rules; two copies meant two sources of truth
# and nothing installed the template anyway, so the text lives here now.
#
# doctrine has two layers. This one steers the judgment no path check can make
# — which bucket a document belongs in, and when a document must be updated.
# The mechanical half (refusing a markdown write outside the six buckets) is
# placement-gate.sh, a PreToolUse gate on the tool input, not a pass over
# generated content. Nothing here inspects a finished document.
# Kill switch: export DOCTRINE_OFF=1

if [ -n "$DOCTRINE_OFF" ]; then
  exit 0
fi

cat <<'EOF'
<doctrine-directive priority="high">
This directive governs `docs/` — how the repository's documentation is organized there, and when it is updated. Documentation belongs in `docs/`: when a turn produces a document, that is where it goes. Nothing outside `docs/` is this directive's business.

SURFACE GATE: apply only when the turn (a) writes or edits a document, (b) changes code in a way that makes an existing document false, or (c) hits one of the WRITE THE DOCUMENT THE WORK PRODUCED triggers below — a hard-to-reverse choice, a measurement that produced numbers, or a change to how the system is operated. If none apply — routine code with no doc consequence, conversation, config, throwaway analysis — this directive is inert: skip it entirely.

REPOSITORY OVERRIDE: if the repository has its own `docs/README.md`, that file is the doctrine and outranks everything below — read it and follow it.

WRITE THE DOCUMENT THE WORK PRODUCED. These documents are not extra scope added to the request and not a deliverable handed to the user — they are the working record this doctrine requires, and their reader is a later session that has none of this turn's context. Not writing one is not restraint; it is dropping state the next turn will have to guess at. So when one of these fires, write it in the same turn, before reporting back — never batched at the end, never offered as a suggestion, never deferred for permission:
- A hard-to-reverse choice was settled — a library, format, schema, protocol, storage backend, or boundary picked over an alternative. Write `decisions/`: what was chosen, over what, why. A few lines. This holds even when the user dictated the choice: the reason is what evaporates.
- Tests, a benchmark, or an investigation were run and produced results. Write `reports/` while the output is in hand — what was run, what came back, what it means — and report from that document rather than only in the reply. A result that lives only in a chat message is gone next session.
- How the system is operated changed — a new environment variable, dependency, migration, setup or deploy step, or a runbook that is now wrong. Write or update `handbooks/`.
Keep each to what a reader six months out needs, and name the document you wrote in the reply.

READ BEFORE DECIDING: when work touches an area, `decisions/` and `handbooks/` are the first place to look for what was already settled — that is what they are for. Do not re-decide something `decisions/` already answers; follow it, or record a new decision that supersedes it by name.

NOT A TRIGGER, and writing here is the scatter this doctrine prevents: routine code changes, bugfixes, refactors, anything the code, types, tests, or commit message already state, and above all a summary of what this session did. Session recaps belong in the reply, never in `docs/`.

THE SIX BUCKETS. Every repository document lives under `docs/` in exactly one of:
- `decisions/` — why a hard-to-reverse choice was made, fixed at the moment of the decision
- `handbooks/` — current state, edited from now on to stay true
- `reports/` — an observation, measurement, or investigation fixed to a point in time (research in `reports/research/`)
- `specs/` — design and specification, updated in the same PR as the code
- `proposals/` — not adopted yet: proposals, drafts, RFCs
- `_assets/` — images and attachments; the underscore marks it as not a document class

Names are exact. Singular forms (`decision/`, `handbook/`, `report/`, `spec/`, `proposal/`) and near-misses (`adr/`, `design/`, `research/`) are not substitutes; if one already exists, still create the six alongside it. Create any missing bucket before writing. Subdirectory structure and file format inside a bucket are free.

LEAVE WHAT IS ALREADY THERE. This doctrine governs what gets written from now on; it has no claim on anything that already exists. Creating the buckets is `mkdir` and nothing else — a bucket already present is adopted exactly as it is, its contents untouched and unexamined, even when they were filed under other rules. Never delete, move, rename, rewrite, or reorganize a pre-existing file or directory to fit the layout, in `docs/` or anywhere else, and never as a side effect of some other task. Documents sitting in the wrong place stay there. Migration is a human decision, taken deliberately and asked for explicitly — if the layout makes one look overdue, say so in the reply and leave the files alone.

Every file under `docs/` belongs to a bucket, whatever its extension — images, diagrams, exports, and attachments go in `_assets/`, never loose under `docs/`. Only `docs/README.md` may sit at the top of `docs/`.

Write documentation into a bucket rather than beside the code — a document about a module belongs in `docs/`, not next to it. Files that are not documentation are outside this directive entirely: leave them where their ecosystem puts them, and do not move existing ones into `docs/`.

CLASSIFY BY LIFETIME, NOT TOPIC — two documents about the same event split when one will be rewritten from now on and the other is fixed to when it was written. Ask in order, stop at the first yes:
1. Is adoption still undecided? → `proposals/`
2. Does a code change make this document wrong? → `specs/`
3. Will it be edited from now on to describe the current state? → `handbooks/`
4. Does it record why a hard-to-reverse choice was made? → `decisions/`
5. Otherwise it is fixed to a point in time → `reports/`

Order matters. `specs/` and `handbooks/` are both living documents, so question 2 comes first: tied to the code is a spec, describing current state independently of the code is a handbook — and a document still updated alongside the code after implementation stays in `specs/`. `decisions/` and `reports/` are the other confusable pair: what was chosen and why is a decision, what was observed is a report. Evidence numbers live in `reports/`; the decision links to them.

WORKED CASES: incident postmortem → `reports/`; an operational rule changed by it → `handbooks/`; a structural change decided from it → `decisions/`. Benchmark numbers → `reports/`; what was chosen after seeing them → `decisions/`. An RFC as written → `proposals/`; the conclusion of an adopted RFC → `decisions/`, linking to the original. Runbooks, onboarding, environment setup → `handbooks/`. Feature designs and migration plans → `specs/`, or `proposals/` before approval. Meeting notes → `reports/`. Market or technology research → `reports/research/`.

One event splitting across several buckets is normal — split it and link the pieces. When the call is still unclear it is between `handbooks/` and `reports/`: rewritten later → `handbooks/`, otherwise → `reports/`. Wanting to edit a document already in `reports/` or `decisions/` means it was classified wrong; move it to `handbooks/`.

ONE SOURCE OF TRUTH: never restate a fact another document owns. `handbooks/` holds current state; other buckets link to it rather than copying values. Never write down what the code, types, or config already state — a document that duplicates them is the one that goes stale.

SAME-TURN SYNC: when a change makes an existing document false, fix that document in the same turn as the change. This is a write-time obligation on whoever invalidated it, not a scan.

COMPOSITION: this is a direction — fan-out worker task specs inherit it (workers place documents by the same rule and still deliver raw). Prose style, reader adaptation, and document-type voice are out of scope.

NEVER:
- a documentation audit, doc-vs-code diff pass, or re-read of a document just written; placement and classification happen at write time.
- creating any new directory under `docs/` other than the six, including tooling and doc-site scaffolding (`.vitepress/`, `.docusaurus/`) — tooling already present is left alone, but none is introduced here.
- writing a `SUMMARY.md` / `NOTES.md` / `CHANGES.md` at the repository root when a bucket is where it belongs.
- deleting or relocating pre-existing files to satisfy the layout, inside `docs/` or out.
</doctrine-directive>
EOF
exit 0
