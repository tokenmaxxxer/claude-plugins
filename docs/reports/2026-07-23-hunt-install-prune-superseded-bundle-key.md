
## after-proposal — stance 1: assume this change and another plugin's rule cancel each other — find the pair

Verdict: NO FINDING
Seed: docs/proposals/2026-07-23-install-prune-superseded-bundle-key.md — install.sh write_settings() pruning SUPERSEDED={tokenmaxxxer-env@<market>} from enabledPlugins before adding coding-agent-env@<market>

Checked:
- `grep -rln tokenmaxxxer-env` across the repo (excluding docs/reports): only hits are the three proposal docs themselves (rename-bundle, release-version-bump, this one). No plugin.json, hooks.json, marketplace.json, or script references the old name as a live dependency or key.
- coding-agent-env/.claude-plugin/plugin.json `dependencies` list names the nine steering plugins by their current names only; no `tokenmaxxxer-env` entry to re-resolve.
- marketplace.json plugins list has no `tokenmaxxxer-env` entry (it was renamed to `coding-agent-env` in commit 2d26992, not duplicated).
- No install-stack hook remains in the repo (removed per commit b66955b); nothing besides install.sh itself reads or writes enabledPlugins.
- The CLI path and the write_settings fallback are mutually exclusive branches of the same `if [ -n "$CLI" ]` in one invocation — they cannot run against the same settings.json in the same execution to fight over enabledPlugins. Proposal explicitly scopes the prune to the fallback branch only, leaving CLI-path bookkeeping (which never wrote the old key format under the new bundle name) untouched.

No other rule, hook, or plugin declaration in this repository still reads, writes, or depends on `tokenmaxxxer-env@<market>` as a key. Pruning it has nothing live to cancel against.
