#!/usr/bin/env bash
# Land an approved direct-integration ship task: fast-forward the project's
# default branch to the crewmate's fm/<id> branch AND push that fast-forward to
# the project's origin, then write a custody receipt only after the remote head
# is verified.
#
# This is the direct-integration counterpart of bin/fm-merge-local.sh (local-only)
# and bin/fm-pr-merge.sh (PR-based modes). It is firstmate's landing gate-action
# for mode=direct-integration tasks only: the configured merge authority approves
# a clean ready branch, then firstmate integrates it directly on the remote
# default branch without a PR. It is one of the sanctioned exceptions to hard
# rule #1 "never run state-changing git in projects/", and it is narrow: it runs
# only for mode=direct-integration tasks, only with an explicit named authority,
# only as a clean fast-forward, only after the declared revalidation passes, and
# only when the remote's branch protections leave direct integration safe.
# Every refusal is loud and nothing is ever forced, stashed, reset, or discarded.
# docs/direct-integration.md owns the path's contract and its limits; AGENTS.md
# section 7 owns the authority rules this script enforces mechanically.
#
# Usage: fm-integrate-direct.sh <task-id> --authority <captain|yolo> --check <command>|none
#   --authority captain  the captain gave a current explicit instruction to land
#                        this exact task; recorded, never inferred.
#   --authority yolo     standing yolo authority; accepted only when the task's
#                        meta records yolo=on, and only for green work.
#   --check <command>    revalidation-before-landing: a shell command run in the
#                        task worktree at the exact branch tip; a non-zero exit
#                        refuses the landing (a "red check"). Output is kept in
#                        data/<id>/landing-check.log.
#   --check none         explicit declaration that the project has no local gate
#                        to rerun; the receipt records check=none.
#
# Guard sequence (any failure prints one "REFUSED: <class>: ..." line, exits 1,
# and leaves every local and remote ref untouched):
#   mode              meta records mode=direct-integration; other modes never
#                     migrate onto this path (local-only lands with
#                     fm-merge-local.sh, PR modes with fm-pr-merge.sh)
#   authority         --authority missing, or yolo while meta says yolo=off
#   check-undeclared  --check missing (pass --check none to declare no gate)
#   branch            fm/<id> does not exist, or the default branch is unknown
#   clone-state       the project clone is not on its default branch or is dirty
#   unlanded-work     the recorded task worktree has uncommitted changes or its
#                     HEAD is not the fm/<id> tip (uncommitted work is never landed)
#   not-fast-forward  the default branch is not an ancestor of fm/<id>
#   no-remote         the clone has no origin remote (use local-only instead)
#   remote-unreachable
#                     fetching origin's default branch failed
#   base-drift        the local default branch differs from origin's after the
#                     fetch (refresh the clone or have the crewmate rebase)
#   branch-protected  origin is a GitHub repository whose classic branch
#                     protection or active rulesets on the default branch would
#                     be bypassed or rejected by a direct push - that repository
#                     remains a PR trigger; use a PR-based mode
#   protection-unknown
#                     origin is on GitHub but its protection could not be read
#                     (gh missing, unauthenticated, network); refuse, never guess
#   red-check         the --check command exited non-zero
#   push-rejected     origin refused the fast-forward push (nothing local changed)
#   remote-mismatch   origin's head after the push is not the landed tip (the
#                     push happened; investigate before any retry)
#
# Non-GitHub remotes (GitLab, self-hosted, file://) cannot have their protections
# inspected here: the receipt records protection=uninspected:<host> and a
# protected branch surfaces as push-rejected, which is still a loud refusal that
# never works around the protection.
#
# Landing order keeps the clone consistent on every failure: the branch tip is
# pushed to origin's default branch first (a plain, non-forced push that origin
# accepts only as a fast-forward), the remote head is read back and must equal
# the tip, and only then is the local default branch fast-forwarded to match.
#
# Receipt: data/<id>/landing-receipt, key=value lines written atomically after
# the remote head verifies, survives teardown:
#   task=<id>  project=<name>  mode=direct-integration  authority=<captain|yolo>
#   branch=fm/<id>  default_branch=<name>  remote=origin  remote_url=<url>
#   before_sha=<origin head before>  landed_sha=<fm/<id> tip>
#   remote_sha=<origin head read back after the push>
#   protection=<unprotected|uninspected:<host>>  check=<command|none>
#   check_exit=<0|none>  landed_at=<UTC ISO 8601>
# The task meta gains landed=<sha> and landed_receipt=<path> so teardown and the
# backlog can name the custody record.
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FM_ROOT="${FM_ROOT_OVERRIDE:-$(cd "$SCRIPT_DIR/.." && pwd)}"
FM_HOME="${FM_HOME:-${FM_ROOT_OVERRIDE:-$FM_ROOT}}"
STATE="${FM_STATE_OVERRIDE:-$FM_HOME/state}"
DATA="${FM_DATA_OVERRIDE:-$FM_HOME/data}"
[ -n "${FM_INTEGRATE_NO_GUARD:-}" ] || "$FM_ROOT/bin/fm-guard.sh" || true

usage() {
  echo "usage: fm-integrate-direct.sh <task-id> --authority <captain|yolo> --check <command>|none" >&2
  exit 2
}

refuse() {  # <class> <message...>
  local class=$1
  shift
  echo "REFUSED: $class: $*" >&2
  exit 1
}

ID=
AUTHORITY=
CHECK=
CHECK_SET=0
want_value=
for a in "$@"; do
  if [ -n "$want_value" ]; then
    case "$want_value" in
      authority) AUTHORITY=$a ;;
      check) CHECK=$a; CHECK_SET=1 ;;
    esac
    want_value=
    continue
  fi
  case "$a" in
    --authority) want_value=authority ;;
    --check) want_value=check ;;
    -h|--help) usage ;;
    --*) echo "error: unknown flag $a" >&2; usage ;;
    *)
      [ -z "$ID" ] || usage
      ID=$a
      ;;
  esac
done
[ -z "$want_value" ] || { echo "error: --$want_value requires a value" >&2; usage; }
[ -n "$ID" ] || usage
case "$ID" in
  ''|*/*|.*|*' '*) echo "error: invalid task id" >&2; exit 2 ;;
esac

META="$STATE/$ID.meta"
if [ ! -f "$META" ] || [ -L "$META" ]; then
  echo "error: no meta for task $ID at $META" >&2
  exit 1
fi
meta_get() { grep "^$1=" "$META" | head -n 1 | cut -d= -f2- || true; }
PROJ=$(meta_get project)
MODE=$(meta_get mode)
YOLO=$(meta_get yolo)
KIND=$(meta_get kind)
WT=$(meta_get worktree)

# --- mode ---------------------------------------------------------------------
[ "$MODE" = direct-integration ] || refuse mode "task $ID is mode=${MODE:-unset}, not direct-integration; local-only lands with bin/fm-merge-local.sh and PR modes with bin/fm-pr-merge.sh - no task migrates onto this path"
[ "${KIND:-ship}" = ship ] || refuse mode "task $ID is kind=$KIND; only a ship task lands"

# --- authority ----------------------------------------------------------------
case "$AUTHORITY" in
  captain) ;;
  yolo)
    [ "$YOLO" = on ] || refuse authority "task $ID records yolo=${YOLO:-off}; standing yolo authority does not apply, so landing needs the captain's explicit instruction (--authority captain)"
    ;;
  '') refuse authority "landing needs an explicit named authority: --authority captain (the captain's current explicit instruction) or --authority yolo (standing yolo on a yolo=on task); authority is never inferred" ;;
  *) refuse authority "unknown authority '$AUTHORITY'; expected captain or yolo" ;;
esac

# --- check declaration --------------------------------------------------------
[ "$CHECK_SET" -eq 1 ] || refuse check-undeclared "revalidation-before-landing must be declared: --check '<command>' reruns the project's local gate at the branch tip, or --check none declares that no local gate exists"
[ -n "$CHECK" ] || refuse check-undeclared "--check needs a command or the literal none"

# --- branch and clone state ---------------------------------------------------
[ -d "$PROJ" ] || refuse branch "project clone $PROJ does not exist"

default_branch() {
  local ref branch
  ref=$(git -C "$PROJ" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
  if [ -n "$ref" ]; then
    echo "${ref#origin/}"
    return 0
  fi
  for branch in main master; do
    if git -C "$PROJ" show-ref --verify --quiet "refs/heads/$branch"; then
      echo "$branch"
      return 0
    fi
  done
  return 1
}

BRANCH="fm/$ID"
git -C "$PROJ" rev-parse --verify --quiet "refs/heads/$BRANCH" >/dev/null || refuse branch "branch $BRANCH does not exist in $PROJ"
DEFAULT=$(default_branch) || refuse branch "cannot determine default branch for $PROJ; expected origin/HEAD, main, or master"
TIP=$(git -C "$PROJ" rev-parse --verify "refs/heads/$BRANCH")

cur=$(git -C "$PROJ" symbolic-ref --short HEAD 2>/dev/null || echo "")
[ "$cur" = "$DEFAULT" ] || refuse clone-state "$PROJ is on '$cur', expected default branch '$DEFAULT'"
if [ -n "$(git -C "$PROJ" status --porcelain 2>/dev/null | head -1)" ]; then
  refuse clone-state "$PROJ has a dirty working tree"
fi

# --- unlanded work ------------------------------------------------------------
# Uncommitted changes are never landed. The untracked-file filter matches the
# harness-owned files bin/fm-teardown.sh's landed-work test also ignores.
if [ -n "$WT" ] && [ -d "$WT" ]; then
  dirty_raw=$(git -C "$WT" status --porcelain 2>/dev/null) || refuse unlanded-work "cannot inspect task worktree $WT for uncommitted changes"
  dirty=$(printf '%s\n' "$dirty_raw" | grep -vE '^\?\? (\.claude/|\.fm-(grok|kimi)-turnend$)' | grep -v '^$' | head -5 || true)
  if [ -n "$dirty" ]; then
    printf 'uncommitted changes in %s:\n%s\n' "$WT" "$dirty" >&2
    refuse unlanded-work "task worktree $WT has uncommitted changes; have the crewmate commit them (or the captain explicitly discard them) before landing"
  fi
  wt_head=$(git -C "$WT" rev-parse --verify HEAD 2>/dev/null || true)
  [ "$wt_head" = "$TIP" ] || refuse unlanded-work "task worktree $WT is at ${wt_head:-unknown}, not the $BRANCH tip $TIP; reconcile the worktree with the branch before landing"
fi

# --- fast-forward -------------------------------------------------------------
if ! git -C "$PROJ" merge-base --is-ancestor "$DEFAULT" "$BRANCH"; then
  refuse not-fast-forward "$BRANCH is not a fast-forward of $DEFAULT (it has diverged); have the crewmate rebase $BRANCH onto $DEFAULT, then retry"
fi

# --- remote custody preflight -------------------------------------------------
REMOTE=origin
# The configured URL (not the insteadOf-rewritten one) names the hosting forge.
REMOTE_URL=$(git -C "$PROJ" config --get "remote.$REMOTE.url" 2>/dev/null || true)
[ -n "$REMOTE_URL" ] || refuse no-remote "$PROJ has no $REMOTE remote; direct integration needs one (a project with no remote is local-only)"
git -C "$PROJ" fetch --quiet "$REMOTE" "+refs/heads/$DEFAULT:refs/remotes/$REMOTE/$DEFAULT" >/dev/null 2>&1 \
  || refuse remote-unreachable "could not fetch $REMOTE $DEFAULT for $PROJ"
BEFORE=$(git -C "$PROJ" rev-parse --verify "refs/remotes/$REMOTE/$DEFAULT")
LOCAL_DEFAULT=$(git -C "$PROJ" rev-parse --verify "refs/heads/$DEFAULT")
[ "$LOCAL_DEFAULT" = "$BEFORE" ] || refuse base-drift "local $DEFAULT ($LOCAL_DEFAULT) differs from $REMOTE/$DEFAULT ($BEFORE); refresh the clone through fleet sync and have the crewmate rebase onto the current $DEFAULT, then retry"
if [ "$TIP" = "$BEFORE" ]; then
  refuse not-fast-forward "$BRANCH is already $REMOTE/$DEFAULT; there is nothing to land"
fi

# GitHub owner/repo from an origin URL; fails for any other host.
github_owner_repo() {
  local url=$1 rest
  case "$url" in
    https://github.com/*) rest=${url#https://github.com/} ;;
    http://github.com/*) rest=${url#http://github.com/} ;;
    ssh://git@github.com/*) rest=${url#ssh://git@github.com/} ;;
    git@github.com:*) rest=${url#git@github.com:} ;;
    *) return 1 ;;
  esac
  rest=${rest%/}
  rest=${rest%.git}
  case "$rest" in
    */*/*|*/|/*|'') return 1 ;;
  esac
  [[ "$rest" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || return 1
  printf '%s\n' "$rest"
}

remote_host() {
  local url=$1 rest host=
  case "$url" in
    *://*) rest=${url#*://}; rest=${rest#*@}; host=${rest%%[/:]*} ;;
    *@*:*) rest=${url#*@}; host=${rest%%:*} ;;
  esac
  printf '%s\n' "${host:-local}"
}

# Rule types that a plain fast-forward push neither bypasses nor trips.
ruleset_type_is_harmless() {
  case "$1" in
    deletion|non_fast_forward|required_linear_history) return 0 ;;
    *) return 1 ;;
  esac
}

# Prints "unprotected" or "protected: <reason>"; returns 2 when GitHub could not
# be read so the caller refuses rather than guessing.
github_protection_state() {
  local repo=$1 branch=$2 out rc types t blocking=
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh is not installed" >&2
    return 2
  fi
  set +e
  out=$(gh api "repos/$repo/branches/$branch/protection" 2>&1)
  rc=$?
  set -e
  if [ "$rc" -eq 0 ]; then
    printf 'protected: classic branch protection is enabled on %s\n' "$branch"
    return 0
  fi
  case "$out" in
    *'HTTP 404'*) ;;
    *) printf '%s\n' "$out" >&2; return 2 ;;
  esac
  set +e
  out=$(gh api "repos/$repo/rules/branches/$branch" 2>&1)
  rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    case "$out" in
      *'HTTP 404'*) printf 'unprotected\n'; return 0 ;;
      *) printf '%s\n' "$out" >&2; return 2 ;;
    esac
  fi
  types=$(printf '%s\n' "$out" | grep -oE '"type"[[:space:]]*:[[:space:]]*"[a-z_]+"' | sed -E 's/.*"([a-z_]+)"$/\1/' | sort -u || true)
  for t in $types; do
    ruleset_type_is_harmless "$t" || blocking="${blocking:+$blocking,}$t"
  done
  if [ -n "$blocking" ]; then
    printf 'protected: active rulesets on %s require %s\n' "$branch" "$blocking"
  else
    printf 'unprotected\n'
  fi
}

if GH_REPO=$(github_owner_repo "$REMOTE_URL"); then
  set +e
  PROTECTION=$(github_protection_state "$GH_REPO" "$DEFAULT")
  prc=$?
  set -e
  [ "$prc" -eq 0 ] || refuse protection-unknown "could not read branch protection for $GH_REPO $DEFAULT; direct integration refuses rather than guesses (check gh auth status and network, or use a PR-based mode)"
  case "$PROTECTION" in
    unprotected) ;;
    protected:*) refuse branch-protected "$GH_REPO $DEFAULT: ${PROTECTION#protected: }; this repository remains a PR trigger, so ship it through a PR-based mode instead of working around the protection" ;;
    *) refuse protection-unknown "unexpected protection state '$PROTECTION'" ;;
  esac
else
  PROTECTION="uninspected:$(remote_host "$REMOTE_URL")"
fi

# --- revalidation before landing ----------------------------------------------
mkdir -p "$DATA/$ID"
CHECK_LOG="$DATA/$ID/landing-check.log"
if [ "$CHECK" = none ]; then
  CHECK_EXIT=none
  : > "$CHECK_LOG"
else
  [ -n "$WT" ] && [ -d "$WT" ] || refuse red-check "no task worktree to revalidate in (meta worktree=${WT:-unset}); the check must run at the branch tip"
  set +e
  ( cd "$WT" && bash -c "$CHECK" ) > "$CHECK_LOG" 2>&1
  CHECK_EXIT=$?
  set -e
  if [ "$CHECK_EXIT" -ne 0 ]; then
    tail -n 20 "$CHECK_LOG" >&2
    refuse red-check "revalidation '$CHECK' exited $CHECK_EXIT in $WT at $TIP (full output: $CHECK_LOG); a red check never lands"
  fi
fi

# --- land: push first, verify, then fast-forward the clone --------------------
[ "$(git -C "$PROJ" rev-parse --verify "refs/heads/$DEFAULT")" = "$BEFORE" ] || refuse base-drift "local $DEFAULT moved during preflight"
if ! push_out=$(git -C "$PROJ" push "$REMOTE" "$TIP:refs/heads/$DEFAULT" 2>&1); then
  printf '%s\n' "$push_out" >&2
  refuse push-rejected "$REMOTE refused the fast-forward push of $BRANCH ($TIP) to $DEFAULT; nothing local changed"
fi
REMOTE_SHA=$(git -C "$PROJ" ls-remote "$REMOTE" "refs/heads/$DEFAULT" 2>/dev/null | cut -f1 | head -n 1 || true)
if [ "$REMOTE_SHA" != "$TIP" ]; then
  echo "error: the push completed but $REMOTE $DEFAULT reads back as '${REMOTE_SHA:-unreadable}', expected $TIP; investigate before any retry" >&2
  refuse remote-mismatch "remote head after push is not the landed tip"
fi
git -C "$PROJ" fetch --quiet "$REMOTE" "+refs/heads/$DEFAULT:refs/remotes/$REMOTE/$DEFAULT" >/dev/null 2>&1 || true
git -C "$PROJ" merge --ff-only "$TIP" >/dev/null

# --- receipt --------------------------------------------------------------------
RECEIPT="$DATA/$ID/landing-receipt"
LANDED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
tmp=$(mktemp "$DATA/$ID/.landing-receipt.XXXXXX")
cat > "$tmp" <<EOF
task=$ID
project=$(basename "$PROJ")
mode=direct-integration
authority=$AUTHORITY
branch=$BRANCH
default_branch=$DEFAULT
remote=$REMOTE
remote_url=$REMOTE_URL
before_sha=$BEFORE
landed_sha=$TIP
remote_sha=$REMOTE_SHA
protection=$PROTECTION
check=$CHECK
check_exit=$CHECK_EXIT
landed_at=$LANDED_AT
EOF
mv -f "$tmp" "$RECEIPT"
printf 'landed=%s\nlanded_receipt=%s\n' "$TIP" "$RECEIPT" >> "$META"
echo "landed $BRANCH on $REMOTE/$DEFAULT (${BEFORE:0:7} -> ${TIP:0:7}) and local $DEFAULT in $PROJ; receipt $RECEIPT"
