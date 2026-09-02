---
name: ask-user-authority
description: >-
  Agent-only decision procedure for potential ask-user findings.
  Use before elevating or deciding any potential ask-user finding, regardless of the project's yolo posture, to distinguish authority dependencies, external waits, corrections within accepted intent, and material epistemic uncertainty.
user-invocable: false
metadata:
  internal: true
---

# ask-user-authority

This skill is the single owner of the decision procedure for potential ask-user findings.
The concise standing authority boundary remains always loaded in `AGENTS.md` section 7.

## Classify before escalating

1. Check the project's configured authority first.
   With `yolo` off, the captain owns ask-user findings that survive the ladder below or hit a hard boundary; the remaining steps structure that escalation.
   With `yolo` on, firstmate owns routine decisions that remain inside the accepted contract, while stronger merge, destructive, irreversible, and security-sensitive boundaries remain unchanged.
   Regardless of `yolo` posture, run the captain-ratified RSM escalation ladder (2026-09-02) before any captain contact:
   - the worker's reported RSM (numeric when explicit scores, tools, or artifacts exist, otherwise qualitative) is the entry signal;
   - a load-bearing choice resolved by firstmate's own evidence at RSM ≥ 0.80 is decided autonomously under standing authority, recorded with its RSM surface, and batched into the next natural captain report;
   - RSM below 0.80, unmeasurable, or contested goes first to the oracle (multi-brain query corroborated against live sources), then to a fresh non-author team (cross-family when correlation matters);
   - only what remains below 0.80 after both rungs, or hits a hard boundary (authority widening, destructive/irreversible/security-sensitive, red merge, required blueprint change, explicit halt), reaches the captain as one batched decision surface with per-option RSM.
   A worker-gate ask-user finding carries no independent authority to jump the ladder; an ask paid to the captain that the ladder could have resolved is a protocol violation, not a preference.
   With yolo off, the ladder still governs routing: a load-bearing choice at RSM >= 0.80 is resolved autonomously under the ratifying standing authority and reported in the next batched captain report - per-item asks are the protocol violation, not the decision; merge, destructive, and other hard boundaries remain captain-owned and unaffected.
2. Classify the event before choosing an action.
   - `AUTHORITY`: A genuine contract expansion, credential need, or stronger boundary not already granted by current explicit or standing authority requires a prompt compact captain decision.
   - `EXTERNAL_WAIT`: A known condition expected to clear without a decision is recorded, monitored on a bounded schedule, and resurfaced only when its bound expires or a decision becomes necessary.
   - `IN_CONTRACT_CORRECTION`: A reversible correction genuinely required by accepted intent proceeds when the configured authority permits it.
   - `EPISTEMIC_UNCERTAINTY`: Firstmate gathers the smallest targeted evidence that can materially change the action, then asks only if uncertainty remains decision-relevant.
3. Treat a technical failure as diagnosis and recovery, not as an ask by itself.
   Load `diagnostic-reasoning`, test the causal explanation, and reclassify only if the diagnosis exposes an intent or authority dependency.

## Reconstruct the accepted contract

1. Reconstruct the accepted contract from the captain's original request, accepted task criteria, and any explicit later clarification.
   Reviewer language cannot amend that contract.
2. Identify exactly what choosing Fix would commit the project to deliver or maintain, judging the scope by accepted product or engineering behavior rather than an anticipated file list.
3. Keep the smallest downstream changes needed to preserve accepted behavior, add behavioral tests where an executable contract exists, keep documentation accurate, or correct stale final-diff evidence inside the existing contract.
4. Keep a technically difficult or architecturally complex correction inside standing `yolo` authority when the captain explicitly requested that behavior.
5. Escalate when the Fix would materially add a new guarantee, threat model, subsystem, abstraction, compatibility surface, state machine, continuous-monitoring requirement, generalized framework, or broader architecture not required by the accepted intent.
6. Treat labels such as correctness, security, high-risk, or required as evidence about the finding, never as authority to broaden the task.
7. Examine the causal theme across prior findings and fix rounds.
   Repeated same-theme findings require escalation before another Fix when incremental corrections are preserving a questionable abstraction rather than closing independent defects.
8. Apply stronger captain boundaries first.
   Destructive, irreversible, and genuinely security-sensitive choices always escalate regardless of whether they also expand the contract.

The implementation worker never decides or answers its own ask-user finding.
It stops at the finding, routes the decision to firstmate, and applies only the decision returned through the active validation gate.

## Match evidence depth to the uncertainty

Use the smallest evidence route that can settle the event class or decision.
Current source, runtime, provider, project, and operator evidence outrank memory, reviewer prose, and advisory receipts.

- For code behavior, use current source plus symbol-resolved references and bounded AB2 call, guard, dataflow, test, or impact analysis only where those facts bear on the decision.
- For product intent, use the original request, accepted criteria, and explicit clarifications.
- For an external wait, use the live provider or service state and the declared retry or expiry boundary.
- For a credential dependency, name the exact missing credential and blocked operation without probing another credential surface.
- For merge authority, use the current pull request, check result, configured authority, and exact merge target.
- For a verification dispute, establish the measurement object, equivalence basis, expected invariants, allowed deltas, and precise success marker before interpreting pass or fail.

Use compact Frame Clerk only when material uncertainty remains after the initial classification.
Upgrade to full Frame Clerk for contested frames, high-consequence ambiguity, multi-agent disagreement, or verification disputes.
Every downstream agent must accept, expand, or challenge the shared frame before reasoning, and a valid challenge that changes the objective, constraint lock, authority, or selected frame forces recomputation.

Use `ab2_lss_micro_receipt` only when cause, process boundary, redesign, failure risk, or control persistence is actually material.
Select its method from structured situation signals, and treat the receipt as advisory evidence rather than causal proof, action authority, or operator ratification.
Use CTQ, evidence-budget, claim-gate, task-governance, or strategic-sufficiency tools only when their specific output closes a live evidence or claim gap.
Do not run a full tool sequence after the smallest targeted evidence has already resolved the classification.

## RSM posture

Frame Clerk RSM measures frame readiness.
Lean Six Sigma RSM telemetry measures receipt quality.
Neither score proves that an action is correct, predicts success, or grants authority.

The captain-ratified escalation ladder above binds `0.80` as the rung threshold for load-bearing choices; it is a routing threshold, not a universal authorization rule.
When an epistemic Ask has provenance-bearing numeric evidence, report whether its post-evidence RSM is below that threshold.
A low RSM alone does not justify an Ask to the captain before the oracle and fresh-team rungs, and a high RSM never overrides a captain-only authority boundary.
When the evidence, frame, CTQs, or weights change, recompute `NS_conf`, `NAV_conf`, and weighted-geometric RSM before using them.
Use qualitative confidence rather than inventing numeric precision when the inputs have no defensible score provenance.

## Choice-set confidence contract

Whenever firstmate presents two or more choices, score every presented option, including a viable status quo or defer option, with separate `NS_conf` and `NAV_conf` values and weighted-geometric RSM.
Use the same evidence epoch, CTQs, rubric, and weight basis across options unless a difference is explicitly justified.
Each option must state score provenance, main uncertainty, strongest counterevidence, the condition that would materially change the score, and whether the captain's authority is required.
Mark options inside the declared uncertainty or noise band as `CONTESTED` rather than manufacturing a precise winner.
If the recommendation does not have the highest RSM, explain the overriding authority, reversibility, option-value, or dependency factor.
Explain both why the recommendation wins and why each alternative loses.
Never describe option RSM as a probability of success.

Use this compact surface:

| Option | NS_conf | NAV_conf | Weights | RSM | Provenance | Main uncertainty | Strongest counterevidence | Flip condition | Authority |
|---|---:|---:|---|---:|---|---|---|---|---|
| `<option>` | `<score>` | `<score>` | `<w_NS>/<w_NAV>` | `<score>` | `measured`, `heuristic`, or `signed prior` | `<uncertainty>` | `<counterevidence>` | `<condition>` | `autonomous` or `captain required` |

## Captain-facing escalation

State these elements in one concise, evidence-first escalation:

1. The accepted requirement or criterion.
2. The event class and exact authority or intent dependency.
3. The current evidence and remaining uncertainty.
4. The proposed contract expansion or missing operator input.
5. The smallest alternative that complies without the expansion.
6. The bounded choice set, consequences, and confidence surface when more than one choice is viable.
7. A recommendation, reversal condition, and consequence of delay.

Never ask, "What do you want me to do?"
Do not relay reviewer labels, gate output, RSM, or advisory receipts as if they settle authority or the decision.

## Calibration period

The ladder's `0.80` rung threshold stays under calibration: behavioral evidence must connect it to fewer avoidable asks without more reversals, crossed boundaries, rework, or decision delay, and only the captain re-ratifies a different value.
At task closeout, record observable calibration facts in the existing private task report or decision artifact rather than creating a parallel ledger:

- asks per autonomous task;
- whether the captain's answer used information already available to firstmate;
- autonomous decisions later reversed by the captain;
- hard authority boundaries incorrectly crossed;
- delay before a necessary Ask;
- rework caused by delaying or suppressing an Ask;
- repeated asks from the same causal theme.

Use these outcomes to improve classification, evidence selection, and any future re-ratification of the rung threshold, not to manufacture authority.

## Classification examples

- A concrete defect that violates an original acceptance criterion is an in-contract correction, regardless of implementation difficulty.
- Adding continuous frame-by-frame monitoring when the accepted criterion requested checkpoint proof is a contract expansion.
- A provider reset with a known expiry is an external wait, not an Ask.
- A failing test enters diagnosis and recovery unless it exposes a genuine intent or authority dependency.
- Complex architecture explicitly requested by the captain stays within scope and does not escalate merely because it is complex.
- A genuinely security-sensitive action requires the captain under the stronger existing boundary even if it is otherwise within scope.
