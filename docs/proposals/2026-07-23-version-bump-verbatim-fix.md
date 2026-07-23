---
status: landed
files:
  - warrant/.claude-plugin/plugin.json
  - dispatch/.claude-plugin/plugin.json
---

# Bump warrant & dispatch versions so the soften-verbatim-capture fix reaches sessions

Issue: #24

## Request
The user confirmed the plan: bump warrant (and dispatch, since it is stale too) versions and reinstall so the paraphrase-and-scrub directive text actually takes effect. ("응 해.")

## Constraints that change what gets built
- Root cause is a stale versioned cache, not a text defect: commit c72a9f6 corrected the directive source but left both plugin versions unchanged, so `~/.claude/plugins/cache/tokenmaxxxer/<plugin>/<version>/` was never refreshed.
- Claude Code keys its plugin cache by version number. A cache refresh happens only when the version string changes — editing hook text under an unchanged version is invisible to installed sessions.
- Confirmed stale: warrant 0.4.0 cache reads "the request quoted verbatim"; dispatch 0.5.0 cache has zero `paraphrase` occurrences. Both predate the fix.
- `marketplace.json` pins no versions (source paths only), so the manifest needs no edit — only each plugin's `plugin.json`.

## What will be done
- warrant `version` 0.4.0 → 0.4.1 in `warrant/.claude-plugin/plugin.json`.
- dispatch `version` 0.5.0 → 0.5.1 in `dispatch/.claude-plugin/plugin.json`.
- After merge: reinstall both plugins so the new-version caches are written from the corrected source. (Operational step, outside the repo write set — reported at landing, not a file edit.)

## Out of scope
- No change to the directive TEXT — the source is already correct; this is purely a version bump to force cache invalidation.
- No audit of other plugins for the same stale-cache pattern beyond warrant/dispatch. If a broader sweep is wanted (do any other edited-but-unbumped plugins exist?), that is a separate proposal.
- No release/tag orchestration beyond the two version fields.

## How I will know it worked
- After reinstall, `~/.claude/plugins/cache/tokenmaxxxer/warrant/0.4.1/hooks/directive.sh` contains "paraphrased sentences" (not "quoted verbatim"), and the dispatch 0.5.1 cache contains "paraphrase".
- A subsequent session's injected warrant directive body reads the paraphrase wording, so a new proposal captures request intent in paraphrase with secrets stripped — not a verbatim paste.
