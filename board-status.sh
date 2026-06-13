#!/usr/bin/env bash
# Mission Control board helper — set a repo issue/PR's Status on Tom's unified board.
#
# Usage:  board-status.sh <repo-name> <issue-or-pr-number> "<Status name>"
#   e.g.  board-status.sh samcamp 98 Ready
#
# - Tom's unified board is account-level Project #1 ("Tom's feature list"),
#   shared across ALL his repos. owner + project number below are stable.
# - Idempotently adds the item to the board if it isn't there yet, then sets Status.
# - Resolves the project/field/option IDs BY NAME every run, so renaming a
#   column (e.g. Future -> Idea) never breaks callers. Status name is matched
#   case-sensitively to a column: Idea | backlog | Ready | Building | In Review | Closed
set -euo pipefail

OWNER="iwantedjusttom"
PROJ_NUM=1
REPO="${1:?repo name}"; NUM="${2:?issue/PR number}"; export STATUS="${3:?status name}"

# Project id + Status field id + the requested option id (all resolved by name)
eval "$(gh api graphql -f query="
query {
  user(login: \"$OWNER\") {
    projectV2(number: $PROJ_NUM) {
      id
      field(name: \"Status\") { ... on ProjectV2SingleSelectField { id options { id name } } }
    }
  }
}" --jq '
  "PID=\(.data.user.projectV2.id); FID=\(.data.user.projectV2.field.id); " +
  ((.data.user.projectV2.field.options[] | select(.name==env.STATUS) | "OID=\(.id)") // "OID=")
')"

if [ -z "${OID:-}" ]; then
  echo "board-status: no column named \"$STATUS\" on Project #$PROJ_NUM" >&2; exit 1
fi

# Content node id (works for both issues and PRs)
CID=$(gh api graphql -f query="query { repository(owner:\"$OWNER\", name:\"$REPO\") { issueOrPullRequest(number:$NUM) { ... on Issue { id } ... on PullRequest { id } } } }" \
  --jq '.data.repository.issueOrPullRequest.id')

# Add to board (idempotent: returns the existing item id if already present)
ITEM=$(gh api graphql -f query="mutation { addProjectV2ItemById(input:{projectId:\"$PID\", contentId:\"$CID\"}) { item { id } } }" \
  --jq '.data.addProjectV2ItemById.item.id')

# Set the Status field
gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input:{projectId:\"$PID\", itemId:\"$ITEM\", fieldId:\"$FID\", value:{singleSelectOptionId:\"$OID\"}}) { projectV2Item { id } } }" \
  --jq '.data.updateProjectV2ItemFieldValue.projectV2Item.id' >/dev/null

echo "board: $REPO#$NUM -> $STATUS"
