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
- Every `github.com` origin URL shape is inspected, whether https with or without userinfo, ssh with or without a port, git, or scp-style; a `github.com` URL whose owner and repository cannot be parsed refuses as unreadable rather than falling back to uninspected.
- A repository that is not visible to the `gh` identity answers with a plain not-found, and that is treated as unreadable, never as unprotected.
- The push is plain and never forced, so origin accepts it only as a fast-forward; the remote head is read back and must equal the landed tip before the receipt is written, and only then is the local default branch fast-forwarded.

The receipt at `data/<id>/landing-receipt` records the authority, branch, default branch, remote URL, the remote head before and after, the protection state, the check command and its exit, and the UTC landing time.
The task meta gains `landed=` and `landed_receipt=`, and `bin/fm-teardown.sh` proves the landing through its ordinary content-in-default check before releasing the worktree.
The receipt and the meta are written as soon as origin verifiably carries the landing, before the local default branch moves, so custody is never lost to a local failure.

## Limits

Branch protection is inspected only for GitHub origins, through `gh api`.
A GitLab, self-hosted, or file origin records `protection=uninspected:<host>` in the receipt, and a protected branch there surfaces as a push rejection, which is still a loud refusal that leaves every local ref untouched.
A private repository on GitHub Free cannot carry branch protection or enforced rulesets, and GitHub answers the protection query with its exact "Upgrade to GitHub Pro or make this repository public to enable this feature" notice.
That one notice lands and is recorded as `protection=unprotected-noted:github-free-private` in the receipt, so the receipt says why no protection was found; any other 403 stays unreadable and refuses.
If origin accepts the push but the local default branch cannot be fast-forwarded afterwards (an index lock, a hook, a concurrent write to the clone), the script exits non-zero with `local-ff-failed`, names the receipt, and leaves every local ref where it was.
Origin already carries the landing in that case, so the recovery is the guarded refresh through `bin/fm-fleet-sync.sh <project>`, never a force, stash, or reset.
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
