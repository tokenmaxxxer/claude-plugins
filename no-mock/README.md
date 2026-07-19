# no-mock

Steers AI-generated deliverables toward structures that can actually run in
production. The failure this targets: ask AI for a product and it returns
something that *looks* finished — a UI with no backend, an API serving
hardcoded fixtures, integrations routed around because credentials were
missing. no-mock sets the direction at generation time so the real structure
gets built from the first line.

**no-mock is not a verification tool.** It runs no checks, no gates, no
sniffers, and adds no extra runs. It is one `UserPromptSubmit` directive that
shapes what the model builds:

- **Bind to intent**: a deliverable the user will use or sell targets
  production-runnable by default; only an explicitly-requested demo targets
  less. Ambiguity resolves to production.
- **Real path from the start**: real persistence with schema/migrations, real
  integration seams with env-based config (`.env.example` included), errors
  that surface instead of fake success paths, and the backend the frontend
  needs — never fixtures "to be replaced later".
- **No silent downgrade**: placeholders only when asked for or unavoidable,
  and then loudly labeled (`MOCK:` at the site, every mocked seam listed with
  what would make it real).
- **Honest claims**: "works" is only said of things actually run; the rule
  restricts claims and never mandates runs to earn them.

## Relationship to the rest of the stack

freelunch parallelizes generation of the proper thing (quality tied — its goal
was never speed-over-quality). no-mock defines "proper" for runnable
deliverables and steers generation there, so there is nothing to catch
afterwards. Workers inherit the direction through task specs and still deliver
raw — no verification passes anywhere, which is exactly the stack's contract.

## History

v0.1.0 shipped a Stop-hook `proof.sh` gate and a post-write mock sniffer.
Both were removed in v0.2.0: checking after the fact is verification
machinery, and this stack's answer to mockups is direction, not inspection.

## Escape hatch

`NO_MOCK_OFF=1` disables the directive (mirrors `FREELUNCH_OFF`/`TERSE_OFF`).
