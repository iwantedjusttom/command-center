# 🤝 Handoff — Unified GitHub Projects board ("Mission Control")

_Written 2026-06-12. Purpose: let a fresh Claude session (which will see the new token scope this one couldn't) finish wiring up Tom's cross-repo Project board._

---

## ✅ DONE (2026-06-12, later session) — see `BOARD.md` for the living doc

The token scope took, and the board is wired up. What got finished:
- **Columns** already complete on Project #1: `Idea → backlog → Ready → Building → In Review → Closed`. (Tom had renamed Future→Idea in the UI; reconciled with his "idea" choice for the capture label.)
- **`idea` label created** on samcamp; capture model is `idea → backlog → ready → building → in-review → closed`.
- **Sam Camp populated** — 14 items: PR #97 (In Review), #98 (Ready), #75–#86 (backlog).
- **Automation wired:** new helper `command-center/board-status.sh` slides any card (auto-adds, resolves IDs by name). **build-loop** now sets `Building`/`In Review`; **design-queue** sets `Idea`/`backlog`/`Ready`. `Closed` is left to GitHub's built-in close-workflow.
- **Stale items resolved:** PR #66 is long gone; the only open PR is #97 (legit in-review). The old #68–#74 ready batch shipped.

**Remaining = Tom's one-time UI toggles** (no CLI/API): in board ⋯→Workflows enable *Item closed → Closed* and *Auto-add* for `samcamp`. Then migrate repos per the sequencing below. Full instructions in `BOARD.md`.

---

## The goal (what Tom wants)

**One GitHub Project board that holds issues from ALL his repos** — a single "Mission Control" kanban where every project's work flows through the same columns. Plus the ability to **capture a raw idea as an issue at any maturity** (not only once it's designed), and have agents **drive the board automatically as work happens**.

This is the live, visual version of the `command-center` LEDGER. Build on top of GitHub — do NOT rebuild GitHub.

---

## START HERE (first actions for the fresh session)

1. **Verify the token scope finally took** (this session kept seeing the old scopes — the `gh auth refresh -s project` wasn't completing the browser-authorize step):
   ```
   gh auth status                      # want 'project' in the Token scopes line
   gh project list --owner iwantedjusttom
   ```
   - If `project` is present and `project list` works → proceed to **The build plan** below.
   - If still missing → Tom must re-run, in his OWN terminal (not via Claude's `!`):
     `gh auth refresh -s project --hostname github.com` → copy the code → authorize **project** at github.com/login/device → confirm terminal says "✓ Authentication complete".
     Fallback (more reliable): a classic PAT at github.com/settings/tokens with `project`+`repo` scope, then `echo TOKEN | gh auth login --hostname github.com --with-token`.

2. **Find Tom's existing board.** He already created a Project board in the GitHub UI with **Future** and **Backlog** columns (account-level). Get its number:
   ```
   gh project list --owner iwantedjusttom
   gh project view <NUMBER> --owner iwantedjusttom
   ```
   Reuse it — do NOT create a new one.

---

## The build plan (once scope works)

1. **Finish the Status columns** to match the label pipeline (Tom has Future + Backlog so far):
   `Future → Backlog → Ready → Building → Review → Done`
2. **Add labels that mirror the columns** on each repo. Board columns (the Status field) only show ON the board; **labels show in BOTH the board and the Issues list** — and Tom explicitly wants ideas visible in the issues list too. samcamp already has `ready`/`building`/`in-review`/`backlog`; it is **missing `future`** (and we never added `idea`). Add `future` (decide with Tom: `future` vs `idea` — his lean was `idea` for capture speed, but he built a "Future" column, so reconcile the naming).
3. **Add Sam Camp's issues to the board**, each dropped into the column matching its label:
   ```
   gh project item-add <NUM> --owner iwantedjusttom --url <issue-url>
   gh project item-edit ... (set Status field)
   ```
   Sam Camp issues: 7 `ready` (#68–#74), 12 `backlog` (#75–#86), 1 open PR #66.
4. **Set up "drives itself as you work" automation:**
   - GitHub's built-in Project workflows (Settings → Workflows): "item closed → Done", "new issue → Future", auto-add from repo.
   - The **build-loop agent**: when it moves an issue `ready→building→in-review`, also have it set the Project Status field (one extra `gh project item-edit`), so the card slides across the board live.
5. **Document how a new repo joins** the board (one `project item-add` per issue, or an auto-add workflow per repo) — so migrating OverYay/callschedule/tatman is trivial.

---

## Critical constraint (why unification matters)

A Project board can only show issues from repos **that exist on GitHub**. Right now **only Sam Camp is on GitHub** — OverYay, callschedule, T3Academy, tatman-schedule are still local folders. So "all repos on one board" requires migrating those projects to GitHub repos with issues first. **The board is the payoff that makes migration worth doing.**

**Migration sequencing (agreed):**
- **tatman-schedule** — born native on GitHub (it's brand new, no legacy files → cleanest first migration). Use design-queue.
- **OverYay** — next, AFTER the 6/15 Sam Camp crunch.
- **callschedule** — after that.
- **T3Academy** — only when it reactivates (T3-010 Stripe).
- Client sites / single-file apps — do NOT migrate.
- Lesson from Sam Camp's migration: **shipped history does NOT backfill** — a freshly-migrated project shows 0% milestone completion even if mostly done. So migrate new/forward-looking projects, not near-finished ones.

---

## The idea-capture model (agreed)

Issues can exist at ANY maturity; the **label is the maturity signal**. The funnel:
`idea/future` (a possibility, may never happen) → `backlog` (intend to do, not designed) → `ready` (designed, buildable) → `building` → `in-review` → closed (done).
- Capture is one line: `gh issue create --repo <r> --title "Idea: ..." --label future`. An agent can do this instantly when Tom says "capture this idea."
- The **design gate stays intact**: an idea can't skip to `building` — **design-queue** promotes `idea→backlog→ready`. Frictionless capture + design discipline.

---

## State snapshot (as of 2026-06-12)

- **Sam Camp** (`iwantedjusttom/samcamp`) — on GitHub. Milestones: ALL ADMIN IN (6/15, **7 open/0 closed, nothing building** → tightening), Admin follow-on (6/17), Audit & open up (6/20). The 0-closed is partly a migration artifact (history not backfilled) but the 7 `ready` features are genuinely unbuilt.
- **Open owner-actions (losable!):** run Supabase migrations **0015** + **0016** (Buddies/Support tabs broken until then); **merge or close stale PR #66**; answer **SC-026** design question (per-student vs per-team); confirm migrations 0007–0014 applied; verify SC-002 RLS at the 6/19 audit.
- **Other projects:** OverYay (now at `C:\Users\iwant\projects\overYay`, VA-049 deploy in flight), callschedule (CS-013 in progress), T3Academy (paused, next T3-010), tatman-schedule (NEW, Jim's Towing, intake/spec stage).
- **Permissions:** `~/.claude/settings.json` now allows `gh`, `git`, `npm`, etc. with a deny-list for destructive ops (repo delete, force push, supabase db push/reset). So agents can run `gh project` commands without prompts once the scope exists.
- **command-center:** the LEDGER.md + REGISTRY.md status files were retired 2026-06-13 — status is now read live from GitHub (issues, milestones, this board); no local status files.

---

## Later (the fun build)

A single-file **`mission-control.html`** that reads the GitHub API (issues + milestones + the Project board) and renders Tom's daily cockpit — "today's one thing," deadline burn-down, cross-project status. Worth building AFTER more repos are on GitHub (so there's cross-project data). It's the "build the brain GitHub doesn't give you" project — personalized prioritization on top of GitHub's plumbing.

---

## How to pick this up in a fresh session

Say: _"Read C:\Users\iwant\projects\skills\command-center\HANDOFF-projects-board.md and continue — start at START HERE."_ A new session will see the refreshed token scope and can run `gh project` commands this one couldn't.
