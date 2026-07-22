# warrant

One approval gate at the front of the work, and none after it. The failure this
targets: an agent that starts editing before anyone agreed what it was building,
then widens as it goes, so what lands is nobody's decision — least of all in a
form a later session can reconstruct.

A request becomes a **proposal**: what was asked (quoted), the constraints
gathered so far, what will be done, what is deliberately out of scope, how you
will know it worked, and the **write set** — the paths the work may touch.
Approving it freezes that set. From there the build runs uninterrupted.

## The shape

```
docs/proposals/2026-07-22-store-sqlite.md
---
status: approved          # proposed -> approved -> landed
files:
  - src/store.py
---
```

The state lives in the repository, not in the conversation: `status` says where
the unit is, the branch and its commits say how far it got. A session that dies
mid-unit loses nothing — the next one reads the same two things.

Every commit for the unit carries its warrant:

```
Proposal: docs/proposals/2026-07-22-store-sqlite.md
```

so `git log --grep "Proposal: <path>"` answers "what shipped for this" with no
index to maintain. Trailers survive rebase and cherry-pick, and `git merge
--squash` keeps them in the prepared message.

## Three layers

**`UserPromptSubmit` directive** — the protocol. Write the proposal and end the
turn; on approval build without stopping; when the work turns out to need a path
outside the write set, finish what the proposal covers and report rather than
widening or asking mid-build.

**`PreToolUse` gate** — the mechanical half, armed only while exactly one
proposal is `approved`. An edit outside the frozen write set is refused. A
commit without the trailer is refused. And because approval covers the work, the
shell is granted by default while a unit is in flight — `pytest`, `npm install`,
whatever the build needs — with two classes withheld: landing steps (`push`,
`merge`, `rebase`, `reset --hard`, branch deletion) because landing is the
user's call, and destructive ones (`rm -r`, `sudo`, piping into a shell) because
those should never ride in on a build approval. Withheld is not refused: the
normal permission prompt decides.

**`SessionStart` state** — reads the proposals and git, and reports open units:
awaiting approval, or approved with N commits so far.

## Composing with the rest of the stack

freelunch decides *how* the approved work executes — the write set is its
fan-out ownership map. doctrine decides *where* documents land, and owns the
`docs/proposals/` bucket this plugin writes into. warrant decides only what may
begin, and when.

The pre-task gate does not contradict freelunch's ban on mid-task pausing: that
rule forbids stopping in the middle, and this one only ever asks before the
start. After approval there is exactly one more exchange — the one where the
work is reported.

## What is verified, and what is not

The gate is deterministic and tested against a decision table: paths in and out
of the write set, traversal (`tests/../src/x.py`), empty and over-broad write
sets, `git -C . commit` and `git  commit` spellings of the trailer rule,
`status: Approved` and trailing comments, malformed frontmatter, and monorepo
proposal directories the gate does not reach. Six silent failures were found
that way and closed; the rule that came out of it is that a gate may fail open
on things outside itself (no `python3`, an unreadable payload) but never on
input it can see and cannot parse — an unreadable warrant is how a gate quietly
stops existing.

The protocol half is prompt text and was exercised across multi-turn sessions:
propose-and-stop, approve-and-build, resume in a brand-new session, and stop at
the write set with a report instead of widening. It is not guaranteed the way
the gate is.

## Kill switch

```sh
export WARRANT_OFF=1
```

Disables all three hooks.
