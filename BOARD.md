# 🗂️ Mission Control board — how it works

_The single cross-repo kanban that holds issues from ALL Tom's GitHub repos — the live, visual cross-project status. Built on GitHub — we don't rebuild GitHub._

- **Board:** account-level GitHub Project **#1** — "Tom's feature list" — owner `iwantedjusttom`
- **URL:** https://github.com/users/iwantedjusttom/projects/1
- **Columns (the `Status` field):** `Idea → Ready → Building → In Review → Migrations → Closed` (`Migrations` is a side-lane for `needs-migration` deploy issues — DB migrations written/merged but not yet run on Supabase; closing the issue moves it to `Closed`)

## The maturity model — label = where it sits

An issue can exist at **any** maturity. The **label** is the signal; the board column mirrors it.

| Label | Column | Meaning | Who sets it |
|-------|--------|---------|-------------|
| `idea` | Idea | anything captured but not yet designed | design-queue (or any agent on "capture this") |
| `ready` | Ready | designed + spec'd, buildable | design-queue |
| `building` | Building | a build agent is on it | build-loop |
| `in-review` | In Review | PR open, awaiting Tom's merge | build-loop |
| `needs-migration` | Migrations | a DB migration written/merged but not yet run on Supabase | build-loop opens it; Tom **closes** it when he's run the SQL |
| _(closed)_ | Closed | shipped (or, for a `needs-migration` issue, the migration has been run) | GitHub auto-workflow on close |

**The design gate holds:** capture is one line, but nothing skips to `building` — design-queue is the only thing that produces `ready`.

> **Why no `backlog`?** We retired it (2026-06-12). `idea` and `backlog` sat on the same side of the only gate that matters — *not yet designed* — so the second bucket only added a "which one is this?" decision without doing work. Prioritise within `Idea` by board ordering (committed ones up top), not a separate stage. Don't reintroduce it unless real use proves a gap.

## Driving the board — `board-status.sh`

`C:\Users\iwant\projects\skills\command-center\board-status.sh` is the one helper that slides a card.

```
bash /c/Users/iwant/.claude/skills/command-center/board-status.sh <repo> <#> "<Column>"
#   e.g. bash .../board-status.sh samcamp 98 Ready
```

- Auto-adds the issue/PR to the board if it isn't on it yet, then sets `Status`.
- Idempotent; resolves project/field/option IDs **by name** each run, so renaming a column never breaks it.
- The agents call it themselves: **design-queue** sets `Idea`/`Ready` as it files & promotes; **build-loop** sets `Building` (on claim) and `In Review` (on PR). `Closed` is automatic (see below). That's all the board bookkeeping — nothing manual in the normal flow.

Capture an idea instantly (any agent):
```
gh issue create --repo <repo> --title "Idea: …" --label idea
bash /c/Users/iwant/.claude/skills/command-center/board-status.sh <repo> <#> Idea
```

## One-time UI setup (no CLI/API for these — Tom does them once)

In the board → **⋯ → Workflows**:
1. **Item closed → Set `Status` = Closed** — makes a merged/closed issue slide to Closed automatically. (Enable this so build-loop doesn't have to touch Closed.)
2. **Auto-add to project** — one per repo: filter `repo:iwantedjusttom/<repo> is:issue,pr`. New issues then appear on the board automatically (in no column until a label/helper sets one). Add `samcamp` now; add each repo as it migrates.
3. _(optional)_ **Item added → Set `Status` = Idea** — gives auto-added issues a default column.

The helper auto-adds items regardless, so the board is never wrong without these — they just save the explicit add and handle the close transition.

## How a new repo joins the board

The board can only show issues from repos that **exist on GitHub**. To onboard a repo:
1. It must be a GitHub repo (push it if local-only — see build-loop's one-time `gh repo create`).
2. Give it the pipeline labels: `idea ready building in-review`.
3. In the board, add an **Auto-add** workflow for it (step 2 above) — or just let `board-status.sh` add items on first status-set.
4. From then on design-queue/build-loop drive its cards exactly like Sam Camp's.

**Migration sequencing (agreed):** tatman-schedule (born native) → OverYay (after 6/15 crunch) → callschedule → T3Academy (when it reactivates). Client sites / single-file apps don't migrate. Lesson from Sam Camp: **shipped history doesn't backfill** — migrate forward-looking projects, not near-finished ones.

## Current state (2026-06-12)

On the board: **2 repos, 21 items.**
- **samcamp (14):** PR #97 (In Review), #98 SC-021 (Ready), #75–#86 (Idea).
- **farm-tracker (7):** #2–#7 (Idea), PR #9 (In Review). Onboarded 2026-06-12 — labels reconciled to lowercase (`Idea`→`idea`).

All pipeline labels (`idea, ready, building, in-review`) present on both repos. `backlog` retired 2026-06-12 (merged into `idea`).

## Later — `mission-control.html`

A single-file cockpit reading the GitHub API (issues + milestones + this board): "today's one thing," deadline burn-down, cross-project status — the personalized prioritization layer GitHub doesn't give. Worth building once more repos are on GitHub so there's real cross-project data.
