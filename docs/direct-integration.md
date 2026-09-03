# Direct integration delivery mode

`direct-integration` is the fourth Firstmate delivery mode, alongside `no-mistakes`, `direct-PR`, and `local-only`.
It exists for a PR-by-exception posture: when no PR trigger is active for a change, the approved work lands as one named-authority direct integration on the remote default branch, with a custody receipt, instead of through a pull request.
It never replaces the other three modes, and no existing task or registry entry migrates onto it.

## What the worker does

The worker contract is the local-only shape with a remote landing.
The crewmate implements on its `fm/<id>` branch, keeps that branch a clean fast-forward of the current default branch, runs the project's own local checks, never pushes, never opens a PR, and reports `done: ready in branch fm/<id>`.
`bin/fm-brief.sh --mode direct-integration` generates that contract.

## How the landing works

Landing is a firstmate action, taken only after the configured merge authority approves the ready branch, exactly as a local-only landing is.
`bin/fm-integrate-direct.sh <id> --authority <captain|yolo> --check <command>|none` is the single owner of the landing.
Its header owns the exact guard sequence, refusal classes, and receipt fields; this page records the contract those mechanics enforce.

- Authority is explicit and named, never inferred: `--authority captain` records a current explicit captain instruction, and `--authority yolo` is accepted only when the task itself records `yolo=on`.
- Uncommitted work in the task worktree is never landed, and a worktree that is not at the branch tip refuses.
- The default branch must be a clean fast-forward ancestor of the branch, the clone must be clean and on its default branch, and the local default branch must match origin after a fresh fetch.
- Revalidation before landing must be declared: `--check` reruns the project's local gate in the task worktree at the exact branch tip, and a non-zero exit refuses the landing; `--check none` is an explicit declaration that the project has no local gate.
- A GitHub origin whose default branch carries classic branch protection or an active ruleset that a direct push would bypass or trip (pull request requirements, required status checks, deployments, signatures, creation or update restrictions, workflows, merge queue) is refused as a PR trigger, and an unreadable protection state refuses rather than guesses.
- The push is plain and never forced, so origin accepts it only as a fast-forward; the remote head is read back and must equal the landed tip before the local default branch is fast-forwarded and the receipt is written.

The receipt at `data/<id>/landing-receipt` records the authority, branch, default branch, remote URL, the remote head before and after, the protection state, the check command and its exit, and the UTC landing time.
The task meta gains `landed=` and `landed_receipt=`, and `bin/fm-teardown.sh` proves the landing through its ordinary content-in-default check before releasing the worktree.

## Limits

Branch protection is inspected only for GitHub origins, through `gh api`.
A GitLab, self-hosted, or file origin records `protection=uninspected:<host>` in the receipt, and a protected branch there surfaces as a push rejection, which is still a loud refusal that leaves every local ref untouched.
Nothing after the push is consulted: checks that run on the remote default branch after landing are outside this path, so a repository that relies on them for gating remains a PR trigger and should register a PR-based mode.
Secondmate homes may hold `direct-integration` projects because the landing has remote custody, while `local-only` projects still stay in the main home.

## Registry

Register the standing posture as `- <name> [direct-integration] - <desc> (added <date>)`, with the orthogonal `+yolo` flag as for any other mode.
`bin/fm-project-mode.sh` parses it as a flat mode, and a ship spawn that picks `direct-integration` on a `direct-PR` or `no-mistakes` project prints the usual rigor-deviation notice.

## Verification

```sh
bin/fm-test-run.sh tests/fm-integrate-direct.test.sh
```

That suite lands and refuses against a real bare origin, so every refusal is proven by the remote head and the local default branch staying put, and every landing by the receipt, the remote head, and the local default branch agreeing on one SHA.
