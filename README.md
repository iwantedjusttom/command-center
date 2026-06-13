# command-center

Personal **mission control** — one place to see where every project stands without opening each project's docs.

It reads across all projects (GitHub-Issues pipeline projects using `design-queue → build-loop`, legacy three-file build-loop projects with `FEATURES.md`/`ROADMAP.md`/`PROJECT-LOG.md`, and standalone apps) and gives a single rundown: what's in progress, what's next, what shipped recently, what deadlines are coming, and what's blocked or waiting on you.

Status lives in GitHub (issues, milestones, the Mission Control board); this skill reads it **live** and reports — it keeps no local status files.

## Triggers

Use it for a **cross-project** status when you're *not* naming a single project to work in:

- "where do my projects stand", "where am I on everything"
- "what am I working on", "what should I work on today/next"
- "give me the rundown", "catch me up", "any deadlines coming up"
- "mission control", "what's the state of things", or `/command-center`

## Not for

Building a feature inside one named project (that's **build-loop** / **design-queue**) or one project's own timeline (that's design-queue milestones, or a legacy ROADMAP). command-center is the layer **above** individual projects.

## Install

```powershell
git clone https://github.com/iwantedjusttom/command-center.git
New-Item -ItemType Junction -Path "$HOME\.claude\skills\command-center" -Target "<path>\command-center"
```
