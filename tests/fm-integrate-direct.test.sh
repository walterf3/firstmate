#!/usr/bin/env bash
# Behavior tests for bin/fm-integrate-direct.sh: the guarded direct-integration
# landing path (mode=direct-integration). Every case runs against a real bare
# origin over file://, a real project clone, and a real task worktree on the
# shared fm/<id> branch, so refusals are proven by the remote head and the local
# default branch staying exactly where they were, and a landing is proven by the
# remote head, the local default branch, and the receipt agreeing on one SHA.
#
# Matrix:
#   (a) authority-required refusal: no --authority, and --authority yolo on yolo=off
#   (b) unlanded-work refusal: uncommitted changes in the task worktree
#   (c) branch-protection refusal: GitHub classic protection, blocking rulesets,
#       and an unreadable protection state; harmless rulesets do not refuse
#   (d) red-check refusal: the declared revalidation exits non-zero
#   (e) successful guarded landing with receipt, under captain and under yolo
#   (f) mode refusal: a local-only task never migrates onto this path
#   (g) check-undeclared refusal: --check must be declared, none included
#   (h) push-rejected refusal: an origin pre-receive hook rejects, nothing local moves
#   (i) base-drift refusal: origin advanced past the local default branch
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
fm_git_identity fmtest fmtest@example.invalid

INTEGRATE="$ROOT/bin/fm-integrate-direct.sh"
TMP_ROOT=$(fm_test_tmproot fm-integrate-direct-tests)
ID=task-di1

# Build one sandbox: bare origin, project clone on main, worktree on fm/<id> with
# one feature commit, task meta, and a gh mock. Echoes the case dir.
#   make_case <name> [yolo=off|on] [origin-url-shape=file|github]
make_case() {
  local name=$1 yolo=${2:-off} shape=${3:-file} case_dir proj remote remote_abs wt
  case_dir="$TMP_ROOT/$name"
  proj="$case_dir/project"
  remote="$case_dir/remote.git"
  wt="$case_dir/wt"
  mkdir -p "$case_dir/state" "$case_dir/data" "$case_dir/fakebin"
  mkdir -p "$proj"
  git -C "$proj" init -q -b main
  printf '# fixture\n' > "$proj/README.md"
  git -C "$proj" add README.md
  git -C "$proj" commit -qm initial
  git clone --quiet --bare "$proj" "$remote"
  remote_abs=$(cd "$remote" && pwd)
  if [ "$shape" = github ]; then
    # The configured URL names GitHub so protection is inspected, while every
    # fetch and push is rewritten to the local bare origin.
    git -C "$proj" remote add origin https://github.com/example/repo
    git -C "$proj" config "url.file://$remote_abs.insteadOf" https://github.com/example/repo
  else
    git -C "$proj" remote add origin "file://$remote_abs"
  fi
  git -C "$proj" fetch --quiet origin
  git -C "$proj" worktree add --quiet -b "fm/$ID" "$wt"
  printf 'feature\n' > "$wt/feature.txt"
  git -C "$wt" add feature.txt
  git -C "$wt" commit -qm "add feature"
  fm_write_meta "$case_dir/state/$ID.meta" \
    "window=fm-$ID" \
    "worktree=$wt" \
    "project=$proj" \
    "kind=ship" \
    "mode=direct-integration" \
    "yolo=$yolo"
  cat > "$case_dir/fakebin/gh" <<'SH'
#!/usr/bin/env bash
# gh mock: FM_TEST_GH_MODE drives the protection endpoints.
case "${1:-} ${2:-}" in
  "api repos/example/repo/branches/main/protection")
    case "${FM_TEST_GH_MODE:-unprotected}" in
      protected) printf '{"required_pull_request_reviews":{"required_approving_review_count":1}}\n'; exit 0 ;;
      error) echo "gh: HTTP 401: Bad credentials" >&2; exit 1 ;;
      *) echo "gh: Branch not protected (HTTP 404)" >&2; exit 1 ;;
    esac
    ;;
  "api repos/example/repo/rules/branches/main")
    case "${FM_TEST_GH_MODE:-unprotected}" in
      rules-pr) printf '[{"type": "deletion"},{"type": "pull_request","parameters":{}}]\n'; exit 0 ;;
      rules-harmless) printf '[{"type":"deletion"},{"type":"non_fast_forward"}]\n'; exit 0 ;;
      *) printf '[]\n'; exit 0 ;;
    esac
    ;;
esac
echo "gh mock: unexpected call $*" >&2
exit 1
SH
  chmod +x "$case_dir/fakebin/gh"
  printf '%s\n' "$case_dir"
}

remote_head() { git --git-dir "$1/remote.git" rev-parse --verify refs/heads/main; }
local_main() { git -C "$1/project" rev-parse --verify refs/heads/main; }
branch_tip() { git -C "$1/project" rev-parse --verify "refs/heads/fm/$ID"; }

run_integrate() {  # <case_dir> [args...]
  local case_dir=$1
  shift
  FM_ROOT_OVERRIDE="$ROOT" \
  FM_STATE_OVERRIDE="$case_dir/state" \
  FM_DATA_OVERRIDE="$case_dir/data" \
  FM_INTEGRATE_NO_GUARD=1 \
  PATH="$case_dir/fakebin:$PATH" \
    "$INTEGRATE" "$@" > "$case_dir/stdout" 2> "$case_dir/stderr"
}

# assert_untouched <case_dir> <label>: remote and local main still at the
# initial commit, no receipt, no landed= in meta.
assert_untouched() {
  local case_dir=$1 label=$2 initial
  initial=$(git -C "$case_dir/project" rev-parse --verify "refs/heads/fm/$ID~1")
  [ "$(remote_head "$case_dir")" = "$initial" ] || fail "$label: remote main moved"
  [ "$(local_main "$case_dir")" = "$initial" ] || fail "$label: local main moved"
  assert_absent "$case_dir/data/$ID/landing-receipt" "$label: a receipt was written on refusal"
  assert_no_grep 'landed=' "$case_dir/state/$ID.meta" "$label: meta recorded landed= on refusal"
}

test_authority_required() {
  local case_dir rc
  case_dir=$(make_case no-authority)
  set +e
  run_integrate "$case_dir" "$ID" --check none
  rc=$?
  set -e
  expect_code 1 "$rc" "no-authority: landing without --authority should refuse"
  assert_grep 'REFUSED: authority:' "$case_dir/stderr" "no-authority: refusal did not name the authority class"
  assert_untouched "$case_dir" no-authority

  case_dir=$(make_case yolo-off-authority off)
  set +e
  run_integrate "$case_dir" "$ID" --authority yolo --check none
  rc=$?
  set -e
  expect_code 1 "$rc" "yolo-off: --authority yolo on a yolo=off task should refuse"
  assert_grep 'REFUSED: authority:' "$case_dir/stderr" "yolo-off: refusal did not name the authority class"
  assert_grep 'yolo=off' "$case_dir/stderr" "yolo-off: refusal did not state the recorded posture"
  assert_untouched "$case_dir" yolo-off
  pass "fm-integrate-direct refuses without an explicit named authority and never infers one from yolo=off"
}

test_unlanded_work_refused() {
  local case_dir rc
  case_dir=$(make_case unlanded-work)
  printf 'edited\n' >> "$case_dir/wt/README.md"
  printf 'scratch\n' > "$case_dir/wt/scratch.txt"
  set +e
  run_integrate "$case_dir" "$ID" --authority captain --check none
  rc=$?
  set -e
  expect_code 1 "$rc" "unlanded-work: dirty task worktree should refuse"
  assert_grep 'REFUSED: unlanded-work:' "$case_dir/stderr" "unlanded-work: refusal did not name the class"
  assert_grep 'scratch.txt' "$case_dir/stderr" "unlanded-work: refusal did not list the uncommitted file"
  assert_untouched "$case_dir" unlanded-work
  [ -f "$case_dir/wt/scratch.txt" ] || fail "unlanded-work: the uncommitted file was discarded"
  pass "fm-integrate-direct refuses to land while the task worktree has uncommitted changes"
}

test_branch_protection_refused() {
  local case_dir rc mode
  for mode in protected rules-pr; do
    case_dir=$(make_case "protection-$mode" off github)
    set +e
    FM_TEST_GH_MODE=$mode run_integrate "$case_dir" "$ID" --authority captain --check none
    rc=$?
    set -e
    expect_code 1 "$rc" "protection-$mode: a protected default branch should refuse"
    assert_grep 'REFUSED: branch-protected:' "$case_dir/stderr" "protection-$mode: refusal did not name the class"
    assert_grep 'PR trigger' "$case_dir/stderr" "protection-$mode: refusal did not route to a PR-based mode"
    assert_untouched "$case_dir" "protection-$mode"
  done
  assert_grep 'pull_request' "$case_dir/stderr" "protection-rules-pr: refusal did not name the blocking rule type"

  case_dir=$(make_case protection-error off github)
  set +e
  FM_TEST_GH_MODE=error run_integrate "$case_dir" "$ID" --authority captain --check none
  rc=$?
  set -e
  expect_code 1 "$rc" "protection-error: an unreadable protection state should refuse"
  assert_grep 'REFUSED: protection-unknown:' "$case_dir/stderr" "protection-error: refusal did not name the class"
  assert_untouched "$case_dir" protection-error

  case_dir=$(make_case protection-harmless off github)
  FM_TEST_GH_MODE=rules-harmless run_integrate "$case_dir" "$ID" --authority captain --check none \
    || fail "protection-harmless: harmless rulesets (deletion, non_fast_forward) should not refuse: $(cat "$case_dir/stderr")"
  assert_grep 'protection=unprotected' "$case_dir/data/$ID/landing-receipt" "protection-harmless: receipt did not record unprotected"
  pass "fm-integrate-direct refuses a protected or unreadable GitHub default branch and lands past harmless rulesets"
}

test_red_check_refused() {
  local case_dir rc
  case_dir=$(make_case red-check)
  set +e
  run_integrate "$case_dir" "$ID" --authority captain --check 'echo gate output; exit 3'
  rc=$?
  set -e
  expect_code 1 "$rc" "red-check: a failing revalidation should refuse"
  assert_grep 'REFUSED: red-check:' "$case_dir/stderr" "red-check: refusal did not name the class"
  assert_grep 'exited 3' "$case_dir/stderr" "red-check: refusal did not carry the check exit code"
  assert_grep 'gate output' "$case_dir/data/$ID/landing-check.log" "red-check: check output was not kept"
  assert_untouched "$case_dir" red-check
  pass "fm-integrate-direct refuses to land a red check and keeps its output"
}

test_successful_landing_with_receipt() {
  local case_dir tip initial receipt
  case_dir=$(make_case land-captain)
  tip=$(branch_tip "$case_dir")
  initial=$(git -C "$case_dir/project" rev-parse --verify "refs/heads/fm/$ID~1")
  # shellcheck disable=SC2016  # The check runs later in the worktree; $(git rev-parse HEAD) must reach it unexpanded.
  run_integrate "$case_dir" "$ID" --authority captain --check 'test -f README.md && test -f feature.txt && test "$(git rev-parse HEAD)" = "'"$tip"'"' \
    || fail "land-captain: landing failed: $(cat "$case_dir/stderr")"
  [ "$(remote_head "$case_dir")" = "$tip" ] || fail "land-captain: remote main is not the branch tip"
  [ "$(local_main "$case_dir")" = "$tip" ] || fail "land-captain: local main is not the branch tip"
  [ "$(git -C "$case_dir/project" rev-parse --verify refs/remotes/origin/main)" = "$tip" ] || fail "land-captain: origin/main tracking ref not refreshed"
  receipt="$case_dir/data/$ID/landing-receipt"
  assert_present "$receipt" "land-captain: no receipt"
  assert_grep "task=$ID" "$receipt" "land-captain: receipt task"
  assert_grep 'mode=direct-integration' "$receipt" "land-captain: receipt mode"
  assert_grep 'authority=captain' "$receipt" "land-captain: receipt authority"
  assert_grep "branch=fm/$ID" "$receipt" "land-captain: receipt branch"
  assert_grep 'default_branch=main' "$receipt" "land-captain: receipt default branch"
  assert_grep "before_sha=$initial" "$receipt" "land-captain: receipt before_sha"
  assert_grep "landed_sha=$tip" "$receipt" "land-captain: receipt landed_sha"
  assert_grep "remote_sha=$tip" "$receipt" "land-captain: receipt remote_sha"
  assert_grep 'protection=uninspected:local' "$receipt" "land-captain: receipt protection for a file:// origin"
  assert_grep 'check_exit=0' "$receipt" "land-captain: receipt check_exit"
  grep -Eq '^landed_at=[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' "$receipt" || fail "land-captain: receipt landed_at is not UTC ISO 8601"
  assert_grep "landed=$tip" "$case_dir/state/$ID.meta" "land-captain: meta landed="
  assert_grep "landed_receipt=$receipt" "$case_dir/state/$ID.meta" "land-captain: meta landed_receipt="
  assert_grep "receipt $receipt" "$case_dir/stdout" "land-captain: stdout did not name the receipt"

  case_dir=$(make_case land-yolo on github)
  tip=$(branch_tip "$case_dir")
  FM_TEST_GH_MODE=unprotected run_integrate "$case_dir" "$ID" --authority yolo --check none \
    || fail "land-yolo: landing failed: $(cat "$case_dir/stderr")"
  [ "$(remote_head "$case_dir")" = "$tip" ] || fail "land-yolo: remote main is not the branch tip"
  receipt="$case_dir/data/$ID/landing-receipt"
  assert_grep 'authority=yolo' "$receipt" "land-yolo: receipt authority"
  assert_grep 'protection=unprotected' "$receipt" "land-yolo: receipt protection"
  assert_grep 'check=none' "$receipt" "land-yolo: receipt check"
  assert_grep 'check_exit=none' "$receipt" "land-yolo: receipt check_exit"
  assert_grep 'remote_url=https://github.com/example/repo' "$receipt" "land-yolo: receipt remote_url"
  pass "fm-integrate-direct lands a clean approved branch on origin and writes a verified custody receipt"
}

test_other_modes_never_migrate() {
  local case_dir rc
  case_dir=$(make_case mode-local-only)
  fm_write_meta "$case_dir/state/$ID.meta" \
    "window=fm-$ID" "worktree=$case_dir/wt" "project=$case_dir/project" \
    "kind=ship" "mode=local-only" "yolo=on"
  set +e
  run_integrate "$case_dir" "$ID" --authority yolo --check none
  rc=$?
  set -e
  expect_code 1 "$rc" "mode-local-only: a local-only task should refuse"
  assert_grep 'REFUSED: mode:' "$case_dir/stderr" "mode-local-only: refusal did not name the class"
  assert_grep 'fm-merge-local.sh' "$case_dir/stderr" "mode-local-only: refusal did not point at the local-only owner"
  assert_untouched "$case_dir" mode-local-only
  pass "fm-integrate-direct refuses every other delivery mode instead of migrating it"
}

test_check_must_be_declared() {
  local case_dir rc
  case_dir=$(make_case check-undeclared)
  set +e
  run_integrate "$case_dir" "$ID" --authority captain
  rc=$?
  set -e
  expect_code 1 "$rc" "check-undeclared: landing without --check should refuse"
  assert_grep 'REFUSED: check-undeclared:' "$case_dir/stderr" "check-undeclared: refusal did not name the class"
  assert_untouched "$case_dir" check-undeclared
  pass "fm-integrate-direct refuses until revalidation is declared, none included"
}

test_push_rejected_leaves_local_untouched() {
  local case_dir rc
  case_dir=$(make_case push-rejected)
  printf '#!/bin/sh\necho "remote: protected branch" >&2\nexit 1\n' > "$case_dir/remote.git/hooks/pre-receive"
  chmod +x "$case_dir/remote.git/hooks/pre-receive"
  set +e
  run_integrate "$case_dir" "$ID" --authority captain --check none
  rc=$?
  set -e
  expect_code 1 "$rc" "push-rejected: an origin rejection should refuse"
  assert_grep 'REFUSED: push-rejected:' "$case_dir/stderr" "push-rejected: refusal did not name the class"
  assert_grep 'protected branch' "$case_dir/stderr" "push-rejected: origin's own rejection was not surfaced"
  assert_untouched "$case_dir" push-rejected
  pass "fm-integrate-direct surfaces an origin rejection loudly and moves nothing locally"
}

test_base_drift_refused() {
  local case_dir rc other
  case_dir=$(make_case base-drift)
  other="$case_dir/other"
  git clone --quiet "file://$(cd "$case_dir/remote.git" && pwd)" "$other"
  printf 'upstream\n' > "$other/upstream.txt"
  git -C "$other" add upstream.txt
  git -C "$other" commit -qm "upstream advance"
  git -C "$other" push --quiet origin main
  set +e
  run_integrate "$case_dir" "$ID" --authority captain --check none
  rc=$?
  set -e
  expect_code 1 "$rc" "base-drift: an advanced origin should refuse"
  assert_grep 'REFUSED: base-drift:' "$case_dir/stderr" "base-drift: refusal did not name the class"
  [ "$(local_main "$case_dir")" = "$(git -C "$case_dir/project" rev-parse --verify "refs/heads/fm/$ID~1")" ] || fail "base-drift: local main moved"
  assert_absent "$case_dir/data/$ID/landing-receipt" "base-drift: a receipt was written"
  pass "fm-integrate-direct refuses when origin has advanced past the local default branch"
}

test_authority_required
test_unlanded_work_refused
test_branch_protection_refused
test_red_check_refused
test_successful_landing_with_receipt
test_other_modes_never_migrate
test_check_must_be_declared
test_push_rejected_leaves_local_untouched
test_base_drift_refused
