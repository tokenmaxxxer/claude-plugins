# freelunch ⚡

*"The free lunch is over" — so said Herb Sutter in 2005: no more speed for free, go parallel. This plugin takes the deal literally.*

A Claude Code plugin (this repo is its marketplace, `freelunch`; the plugin lives in [freelunch/](freelunch/)) that forces every task onto concurrent background Sonnet agents with zero idle time. It optimizes wall-clock time only, skips quality-verification passes by design, and every rule in it survived an elimination benchmark — the ones that didn't are banned inside the plugin itself, with the numbers.

## Measured results

Same task, same model (Sonnet), same machine:

| Task | Single agent | freelunch | Speedup |
|---|---|---|---|
| 4-page static site + shared CSS | 184s | 43s | 4.3x |
| 11-file Python CLI (cross-module imports, pytest) | 185s | 49s | 3.8x |

The Python build passed all 24 of its tests and a live CLI smoke test on first run, with zero integration fixes — six workers coded against an up-front interface contract without ever seeing each other's files.

Tested and rejected along the way (kept as in-directive bans):

- Pre-racing every chunk with twin workers: 72s vs 57s — slow chunks were slow in both twins (correlated tails), and doubled launch cost.
- Splitting fragments below ~50 output lines: 12-way was no faster than 8-way — agent spin-up dominates small pieces.
- Haiku workers: identical 12-worker fan-out took 78s on Haiku vs 21s on Sonnet — per-request latency dominates, "smaller = faster" is false here.

## How it works

- `freelunch/hooks/freelunch.sh` — `UserPromptSubmit` hook that injects the forcing directive into context on every prompt.
- `freelunch/agents/freelunch-worker.md` — Sonnet-pinned worker agent that finishes one chunk with no verification pass.
- `freelunch/workflows/site-fanout.js`, `freelunch/workflows/code-fanout.js` — reusable fan-out scripts; dispatch passes only compact per-task specs via `args`, prompt templates and contracts live in the script.

The directive's core rules:

1. Decompose immediately; the first response already launches agents (3+ in one message, all in the background).
2. Every worker runs on Sonnet (measured fastest — see above).
3. Partition by file ownership — no two agents ever write the same file.
4. Cut chunks to roughly equal expected duration; the slowest worker sets total time.
5. Keep agent prompts minimal — the main session emits prompts serially, so long prompts delay the whole launch.
6. Existing-codebase tasks start with one scout agent whose file map is injected into every worker prompt.
7. Fan-outs of 4+ workers dispatch via a Workflow script; recurring task families reuse a script file with `{scriptPath, args}`.
8. Heavy files split into contiguous fragments (floor: ~50 lines each) with exact seam contracts, stitched by one mechanical concatenation with seam normalization.
9. Dependencies are sliced away with up-front interface contracts so dependent work starts immediately — never waits.
10. No barriers or phases: the moment one agent finishes, its follow-up dispatches while the rest keep running.
11. Hedging is reactive only — a straggler at ~2x median finish time gets one replacement racer.
12. No review passes, no cross-checks, no confirmation questions.

Sole exception: purely conversational questions with no file or code work.

## Install

**With the `claude` CLI** — no clone needed, inside any CLI session:

```
/plugin marketplace add tokenmaxxxer/freelunch
/plugin install freelunch@freelunch
```

(or from a shell: `claude plugin marketplace add tokenmaxxxer/freelunch && claude plugin install freelunch@freelunch`)

**VSCode extension only** — the extension's chat does not support `/plugin` commands, so use the installer, which finds the CLI bundled inside the extension and runs the real install through it:

```
git clone https://github.com/tokenmaxxxer/freelunch.git
cd freelunch && ./install.sh
```

Then reload the VSCode window. The installer prefers a PATH `claude`, then the extension's bundled CLI, and as a last resort writes `~/.claude/settings.json` directly (backing up the original). Idempotent — safe to re-run.

## Temporarily disable

```
export FREELUNCH_OFF=1   # hook injects nothing
```

## Caveats

- Skipping verification is by design. It cost nothing on the benchmarks above because the specs were precise; when a contract is wrong, seam bugs ship (one duplicated `</html>` did). Turn the plugin off for work where you need to trust the result.
- Tiny single-file tasks pay agent spin-up overhead with nothing to parallelize; only pure conversation is exempted, so expect overkill there.
- Speedup grows with task size: fixed costs (spin-up, dispatch, notifications) are ~35s of every run, so longer tasks approach and pass 5x.

---

v0.1.0 — by Jung Jiwon & Lee Jongkwan.
