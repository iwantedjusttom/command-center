---
name: command-center
description: Tom's personal mission control — one place to see where every project stands without opening each project's docs. Reads across all of Tom's projects — GitHub-Issues pipeline projects (design-queue → build-loop; hopper = issues + milestones) and legacy three-file build-loop projects (FEATURES.md/ROADMAP.md/PROJECT-LOG.md) alike, plus standalone apps — and gives a single rundown: what's in progress, what's next, what shipped recently, what deadlines are coming, and what's blocked or waiting on him. The status lives in GitHub (issues, milestones, the Mission Control board); this skill reads it live and reports — it keeps no local status files. USE THIS whenever Tom wants a cross-project status and is NOT naming a single project to work in — e.g. "where do my projects stand", "where am I on everything", "what am I working on", "what should I work on today/next", "give me the rundown", "catch me up", "any deadlines coming up", "mission control", "what's the state of things", or /command-center. Do NOT use it for building a feature inside one named project (that's build-loop / design-queue) or for one project's own timeline (that's design-queue's milestones, or legacy build-loop's ROADMAP section) — command-center is the layer ABOVE individual projects.
---

# Command Center — Tom's Mission Control

> ⚠️ **RETIRED 2026-06-13.** This reporting skill is unregistered (its `.claude/skills` symlink was removed); the source is preserved here and revivable, the same way `walk-away` was parked. **Why:** once work moved fully to GitHub Issues, this skill kept no local data — it only re-read GitHub and reformatted it, duplicating GitHub's own boards + milestones (which Tom uses directly and likes). A cross-repo "catch me up" is now just an ask — Claude runs `gh` across the repos live, no skill needed. Its one piece of real machinery, **`board-status.sh`** (plus the **`BOARD.md`** reference doc), was **moved into the `board-mechanic` skill**, where `pipeline.sh` lives. **Before reviving:** re-read this why. If you genuinely want a one-shot cross-repo rundown often enough to not re-describe it each time, revive it as a thin ~10-line recipe — not this full scaffold.

The point of this skill: Tom runs many projects at once and doesn't want to hold them all in his head or open each project's docs to remember what he's doing. This skill is the **layer above the individual projects** — it reads across all of them and answers "where does everything stand?" in one place, both as a chat rundown and as a standing file Tom can open.

It pairs with the per-project skills — `design-queue` + `build-loop` (the GitHub-Issues pipeline) or legacy `build-loop` (three files) — which govern work *inside* one project. Command-center never builds features — it **reports and organizes across** projects. When Tom wants to actually work an item, hand off to the project (design-queue/build-loop take over there).

## No local status files — GitHub is the truth

This skill keeps **no ledger and no registry**. Tom tracks everything in GitHub now (issues, milestones, and the cross-repo **Mission Control** board, account-level GitHub Project #1). The rundown is generated **live from GitHub every time** and delivered in chat — nothing is persisted to a local `.md`. The project list isn't a file either: discover it each run (below).

**Discovering the project list** (each run, fresh):
- `gh repo list` for Tom's GitHub repos, and the **Mission Control board** (GitHub Project #1) for what's actively in flight.
- A scan of `C:\Users\iwant\projects\` for legacy three-file projects (a folder with a `FEATURES.md`) and standalone apps (a stray `*.html` app folder).

## What to do when invoked

Figure out which of these Tom is asking for, then do it. When in doubt, give the full rundown (the default).

### 1. Full rundown / "where do things stand" (the default)

1. **Build the project list live** (per *Discovering the project list* above): `gh repo list` + the Mission Control board for GitHub-tracked projects, and a scan of `C:\Users\iwant\projects\` for legacy three-file projects (a `FEATURES.md`) and standalone apps (a stray `*.html` app folder).
2. **For each project, read it by its tracking type:**
   - **github-issues projects** (the design-queue → build-loop pipeline — e.g. Sam Camp): the hopper is GitHub Issues, so read it with `gh` (the issues ARE the truth — don't read the frozen `FEATURES.md`):
     - **In flight** — `gh issue list --repo <repo> --label building` (a build agent is on it) plus any open PRs (`gh pr list --repo <repo>`, which are `in-review`).
     - **Next up** — `gh issue list --repo <repo> --label ready` (build-ready), in milestone-due order. `backlog`-labeled issues are known-but-not-yet-designed (design-queue's queue), list 1–2 if nothing's `ready`.
     - **Recently shipped** — recently **closed** issues with their merged PRs: `gh issue list --repo <repo> --state closed --limit 3` (and/or `gh pr list --state merged`).
     - **⚠ Pending migrations** — `gh issue list --repo <repo> --label needs-migration --state open`. Each open one is a DB migration that's been **written/merged but not yet run against Supabase** — a deploy step Tom owns, separate from merging. Surface these prominently (they silently rot if a feature is "shipped" in code but its schema change was never applied). build-loop opens one per migration file; Tom closes it when he's run the SQL, so **open = not yet applied**.
     - **Flags** — owner actions and gotchas pulled from **issue comments** and labels, plus **milestone** drift (open vs. closed in the nearest-due milestone = ahead / on track / behind).
   - **legacy build-loop (three-file) projects** (e.g. OverYay, callschedule, T3Academy): read `FEATURES.md` (+ `ROADMAP.md` if present, + the top of `PROJECT-LOG.md`). Extract **In flight** (`in-progress` items), **Next up** (top 1–3 unblocked `todo`, respecting ROADMAP order), **Recently shipped** (newest 1–3 `PROJECT-LOG.md` entries), and **Flags** (owner actions, open questions, ROADMAP drift).
3. **For standalone apps** (no tracking docs), give status from agent memory + the file's recency. These won't have IDs — describe in plain words and note likely next steps from memory.
4. **Compute the deadline radar** — pull every dated target (GitHub **milestone** due dates, legacy ROADMAP finish lines, the $10K goal date) and sort by how close it is. Convert to "in N days" against today's date.
5. **Deliver the chat rundown** — lead with deadlines and anything on fire, then a tight per-project line (status · now · next · flag). Keep it scannable, not a wall of text. End with a crisp "if you want to move the needle today, here's the one thing per active project." The rundown **is** the output — there's nothing to persist; if Tom wants a durable cross-project view, that's the Mission Control board (GitHub Project #1).

### 2. "What should I work on?" (focus, not breadth)

Same reads as above, but the output is a **recommendation, not a survey**: pick the single highest-leverage thing, justified by deadline pressure and unblocked-ness. Sam Camp's dated benchmarks usually dominate when its finish line is near. Offer one primary + one backup, then ask if he wants to dive in (which hands off to that project + build-loop).

### 3. One project, drilled in

If Tom names a project ("where's OverYay at"), skip the others — read just that project by its tracking type (its GitHub issues + milestones, or its three files) and give the in-flight / next / recent / flags for it, in more depth. Just answer; there's nothing to regenerate.

### 4. New project / cross-project idea

- **A new project** needs no registration here — it's discovered on the next run (its GitHub repo, or its `projects/` folder). If it needs a tracking setup, that's a `project-bootstrapper` / build-loop job — point there.
- **A cross-project idea/note** goes into GitHub, not a local file. If it's clearly a feature for one project, file it as an `idea` issue on that repo (design-queue's capture flow) and offer to route it there. If it's genuinely cross-cutting with no home repo, say so — there's no ledger to park it in; suggest the most relevant repo or a dedicated tracking repo rather than inventing a local file.

## How to keep the rundown honest

- **The live hopper is the source of truth, not memory.** Re-read it every time — for github-issues projects re-run `gh issue list`/milestones, for legacy projects re-read the files; memories are point-in-time and drift. Flag it when a memory and the current state disagree. (Don't read a *frozen* `FEATURES.md`/`ROADMAP.md` for a migrated project — its banner points to the issues; trust those.)
- **Surface owner actions loudly.** The most valuable thing this skill does is catch the "Tom needs to run migration 0015 or the Buddies tab is broken" items that are easy to lose. Pull these from issue comments + labels (github-issues projects) and ROADMAP watch-outs + PROJECT-LOG entries ("Owner runs ...") (legacy projects).
- **Respect benchmarks over raw backlog order.** If a project has dated targets — GitHub **milestones** or a legacy `ROADMAP.md` — those set the priority, not the raw issue/backlog order.
- **Don't invent status.** If a project's tree is mid-work or a doc is missing, say "unclear, last shipped X on DATE" rather than guessing.

## The rundown shape (deliver to this skeleton, in chat)

```
🛰 Mission Control — <date>

⏱ Deadlines on the radar
- <date> (<N days>) — <project>: <what>

⚠ Pending migrations (written but not yet run on Supabase)
- <project> #<issue> — migration <NNNN> <slug>   ← only show this block if any are open

📊 At a glance
| Project | Status | Now (in flight) | Next up | Needs Tom |
|---|---|---|---|---|

Per-project
<Project> · <status> · <deadline if any>
- Now / Next / Recently shipped / Flags

🗂 Other projects (untracked / dormant): <one line each>
```

Adjust freely — this is a guide, not a straitjacket. The job is: Tom asks, and instantly knows where everything is and what needs him. The job is done in the message, not in a file.
