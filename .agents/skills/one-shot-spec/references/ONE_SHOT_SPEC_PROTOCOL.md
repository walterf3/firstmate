# ONE_SHOT_SPEC_PROTOCOL
## Metacognitive Protocol for One-Shot Spec Hardening

**Version:** 2.4

**Last Updated:** 2026-05-10

**Changelog:**
- v2.4 - 2026-05-10 - Tightened Probe Contract schema after F13/F14/F15: one contract tests one claim, per-acceptance-check contracts carry `canonical_probe_inputs[]`, `claim_under_test`, `comparison_mode`, and `discrimination_basis`, and `domain_equivalence` is removed from canonical equivalence relations.
- v2.3 — 2026-05-09 — Added Probe Contract requirement for verification claims that compare live or fixture probes; codifies Invariance Envelope Framing after SPEC-231 Stage B F9/F10/F11.
- v2.2 — 2026-02-25 — Added hypothesis register + promotion gate (hypothesis -> observed -> proven), strict anti-overclaim rules for blocked claim gates, and readiness caps for unresolved high-risk hypotheses.  
- v2.1 — 2026-02-14 — Added Evidence Pack Gate (create/score/lock) per `EVIDENCE_PACK_PLAYBOOK_v1.md`; wired evidence-pack snapshot into telemetry.  
**Source Models:**  
`/Users/walter/Dev/um/docs/official/base-theory/CGEN_OS_CRSM_WHITEPAPER.md`  
`/Users/walter/Dev/um/docs/official/base-theory/CGEN_OS_ACTIVATION_MATRIX.md`  
`/Users/walter/Dev/um/docs/official/base-theory/CGEN_OS_STRATEGY_ONTOLOGY.md`  
`/Users/walter/Dev/um/docs/official/base-theory/PRSBM_EF_MODEL.md`  
`/Users/walter/Dev/um/docs/official/base-theory/PRSBM_EF_STRATEGY_ONTOLOGY.md`  
`/Users/walter/Dev/um/docs/official/base-theory/PRSBM_EF_ACTIVATION_MATRIX.md`  
`/Users/walter/Dev/um/docs/official/base-theory/CBGT_v4.md`  
`/Users/walter/Dev/um/docs/official/base-theory/EVIDENCE_PACK_PLAYBOOK_v1.md`

> Enhancement Protocol Compliance: This paper was enhanced using the UM Paper Enhancement Protocol v2.0 (phases 0-5 + 3A).
> See: ONE_SHOT_SPEC_PROTOCOL_ENHANCEMENT_ACCOUNTING_DOCUMENT.md

---

## Purpose

Harden a spec for **one-shot implementation** by running CGEN-OS + CRSM to generate and filter concepts, then PRSBM-EF to stress-test and refine the best concept, internally scoring RSM each cycle, and stopping when no material improvement remains.

This protocol is for specs (not theory papers). It prioritizes:
- implementation determinism
- falsifiable acceptance checks
- low ambiguity at handoff
- minimal noise / maximal signal

---

## Core Principles

- Predicate-driven activation, not lane-based heuristics.
- Research-before-simulation (CBGT): do not reason deeper when context is insufficient.
- Evidence pack first: create/score/lock an evidence pack as the upstream research context bubble before deep spec hardening.
- Minimal tool sequence that still guarantees coverage.
- No external convergers or automated spec scorers. Internal RSM/CRSM only.
- For code-change specs, include a strategic AB2 discovery tool list to enumerate all change points.
- For code-change specs, explicitly map evidence-pack CTQs to scoring inputs in the spec (no implicit scoring assumptions).
- Evidence-pack CTQs must be surfaced verbatim in the spec (not only in the evidence pack).
- Before implementation, a pre-implementation checklist must be completed and recorded (includes quick AB2 discovery pass and lightweight spec review).
- Hypotheses are first-class artifacts: unresolved claims must live in a `Hypothesis Register` until promoted by evidence or explicitly deferred.
- Claim language must match claim status. Never label a claim "proven" when its claim gate is `BLOCK` or `ASK`.
- Verification claims that compare probes must declare a Probe Contract before pass/fail interpretation.

---

## Inputs

1. `TARGET_SPEC` (required)
2. `NORTH_STAR` (required): one sentence defining intended behavior
3. `EVIDENCE_PACK` (required): an evidence pack for this spec. If none exists, create one first using `/Users/walter/Dev/um/docs/official/base-theory/EVIDENCE_PACK_PLAYBOOK_v1.md`.
4. `EVIDENCE_ANCHORS` (required): curated, concrete code/file anchors that justify claims (should be derived from the evidence pack)
5. `CONSTRAINTS` (required): non-negotiables (compatibility, scope, schema, performance)
6. `STAKES_BAND` (required): LOW | MEDIUM | HIGH | CRITICAL
7. `PREDICATE_VECTOR` (required): semantic predicates and confidence
8. `CTQ_GAPS` (required): missing or weak CTQ axes
9. `EVIDENCE_PACK_CTQS` (required): evidence-pack CTQs (verbatim list)
10. `EVIDENCE_PACK_CTQ_MAP` (required for code-change specs): explicit mapping from evidence-pack CTQs to scoring inputs (primary/secondary + rationale)
11. `CONTEXT_BUDGET` (required): CBGT-derived energy state and bubble intersection (prefer derived from the evidence pack’s context bubbles)
12. `MAX_ITERS` (optional, default `8`)
13. `MATERIAL_DELTA` (optional, default `0.02` absolute RSM)
14. `MATH_BASIS_CANDIDATE` (required): equations/derivations proposed for this spec (or explicit `none`)
15. `EVIDENCE_SCOPE` (required): bounded file/module scope for proof claims (e.g., `um_mcp/server.py`, `um_mcp/tools/expert_audit.py`)
16. `AB2_EVIDENCE_BUDGET` (required): allowed evidence operations and caps (`limit_files`, `runtime_allowed`, `expected_completeness`, `claim_intent`)
17. `TEST_POLICY_PATH` (required): `/Users/walter/Dev/um/docs/TEST_POLICY.md`
18. `AB2_STRATEGIC_TOOLS` (required for code-change specs): discovery checklist used to locate all change points (e.g., `ab2_rg`, `ab2_diff_scope`, `ab2_constant_usage`, `ab2_key_usage`, `ab2_call_site_context` or `ab2_ast_map`, and `ab2_ab2x_run` plan for multi-file coverage)
19. `HYPOTHESIS_REGISTER` (optional, default empty): seed list of unresolved claims with `risk_level`, `claim_type`, and required promotion chain
20. `HYPOTHESIS_PROMOTION_POLICY` (optional): policy for promotion thresholds (`max_unresolved_high`, `max_unresolved_total`, `allow_deferred_hypotheses`)

---

## Evidence Pack Gate (Research-First)

An evidence pack is the upstream research bundle that stabilizes context before spec drafting. In CBGT terms, the evidence pack is the **context bubble**: the minimal structured context that must exist before deeper reasoning or spec hardening.

Reference:
- `/Users/walter/Dev/um/docs/official/base-theory/EVIDENCE_PACK_PLAYBOOK_v1.md`

### Required behavior

- If `EVIDENCE_PACK` is not provided, create it first using the playbook template (copy/paste).
- The pack must contain, at minimum: North Star, Scope/Actors, Evidence Summary, Contradictions/Open Questions, Assumptions, Examples/Edge Cases, Acceptance Checks, Open Items, Quality Criteria, Change Log.
- Record active predicates (if used) inside the pack (prevents routing drift and keeps the pack reusable).
- Treat `EVIDENCE_ANCHORS` as an extraction from the pack (not a separate research stream).

### Scoring + readiness bands (playbook defaults)

Compute `evidence_pack_score` as a weighted geometric mean of:
- Coverage, Clarity, Risk (0..1 each)

Readiness bands:
- `>= 0.75` → `ready` (draft the spec)
- `0.60..0.75` → `near_ready` (draft with open items tracked; restrict scope expansion)
- `< 0.60` → `not_ready` (gather evidence before drafting)

Gate:
- If `evidence_pack_score < 0.60` and `never_block` is **not** set: halt and gather evidence; do not proceed to CGEN-OS/PRSBM-EF.
- If `never_block` **is** set: proceed best-effort, front-load caveats, and keep the pack’s open items explicit in the spec.

### Locking

Before running PRSBM-EF on a spec intended for one-shot implementation, lock the pack:
- Freeze a version/snapshot used for the run.
- Move new findings into a delta log until the pack is refreshed + re-scored.

---

## Outputs

1. Improved spec text
2. Iteration ledger (CGEN-OS + PRSBM-EF telemetry + score deltas)
3. Final stop reason (`target_reached`, `plateau`, `budget_exhausted`, `frame_bad_unresolved`)
4. Mathematical basis decision (`continue_math`, `heuristic_only`, `defer_math`)
5. `Claim Hygiene (AB2 Stack Applied)` section with claim table (IDs, evidence tier, AB2 tools, and absence-claim guardrails)
6. AB2 run ledger path when AB2 tools were used
7. One-shot readiness scorecard (determinism, falsifiability, traceability, implementation packet, test-policy alignment)
8. Test policy alignment note (including any explicitly obsolete or incompatible tests)
9. Evidence pack snapshot (path, score, readiness band, and open items count)
10. Strategic tooling checklist when code changes are involved (AB2 discovery list and impact plan)
11. Evidence-pack CTQs (verbatim list)
12. Evidence-pack CTQ → scoring input map (explicit, primary/secondary with rationale)
13. Pre-implementation checklist (Green) with status + evidence (must include quick AB2 discovery pass and lightweight spec review)
14. Hypothesis register snapshot (IDs, status, risk level, claim type, owner stage, next evidence step)
15. Hypothesis promotion receipt (promoted claims, blocked claims, deferred claims, and reasons)
16. Probe Contract for any acceptance check, live proof, or closeout claim that compares probe outputs

### Probe Contract Requirement

Use Invariance Envelope Framing for any acceptance check, served proof, fixture comparison, or closeout claim that compares probe outputs.

The first verification move is to determine whether reviewers are measuring the same object under the same input identity and equivalence relation. Do not interpret pass/fail until the contract is explicit.

A Probe Contract must include:
- acceptance check id;
- measurement target;
- claim under test: `determinism`, `robustness`, `sensitivity`, or `discrimination`;
- comparison mode: `repeated_same_input`, `equivalence_class`, `minimal_pair`, or `anchor_set`;
- canonical probe inputs;
- fields pinned verbatim;
- equivalence relation: `verbatim`, `semantic_equivalence`, `substrate_equivalence`, or `none`;
- discrimination basis: `substrate_pressure_fingerprint`, `declared_test_fixture`, `external_oracle`, or `null`;
- expected invariants;
- expected deltas;
- non-claims;
- success marker;
- minimal-pair policy for disputes.

Verification claims are valid only under the claim type, comparison mode, and equivalence relation declared in the Probe Contract. Reviewer shorthand such as "the incident query" is insufficient when the test depends on query text. Verbatim probes must be pinned when the success marker depends on exact input identity.

One Probe Contract tests one claim type. If an acceptance check needs both determinism and discrimination, write two Probe Contracts.

Claim definitions:
- `determinism`: same exact pinned input should produce the same output.
- `robustness`: inputs declared equivalent under the chosen equivalence relation should produce the same or equivalent output.
- `sensitivity`: a controlled minimal change should produce the expected delta.
- `discrimination`: probes expected to differ under the declared discrimination basis should produce distinct outputs.

Do not use domain labels as equivalence relations. If a test appears to need "domain equivalence," state the mechanism instead: use `substrate_equivalence` for substrate-pressure equivalence, `discrimination_basis="declared_test_fixture"` for fixture-class distinctions, or `discrimination_basis="external_oracle"` for externally judged distinctions. Raw or hashed domain labels are not valid Probe Contract discriminants for substrate-facing receipts.

Template:

```json
{
  "schema": "probe_contract.v1",
  "acceptance_check_id": "string",
  "measurement_target": "string",
  "claim_under_test": "determinism | robustness | sensitivity | discrimination",
  "comparison_mode": "repeated_same_input | equivalence_class | minimal_pair | anchor_set",
  "equivalence_relation": "verbatim | semantic_equivalence | substrate_equivalence | none",
  "discrimination_basis": "substrate_pressure_fingerprint | declared_test_fixture | external_oracle | null",
  "canonical_probe_inputs": [
    {
      "probe_id": "string",
      "verbatim_text": "string",
      "pinned_fields": [],
      "declared_params": {},
      "opt_in_flags": {},
      "minimal_pair_partner": "string | null",
      "claim_note": "string | null"
    }
  ],
  "expected_invariants": [],
  "expected_deltas": [],
  "non_claims": [],
  "success_marker": "string",
  "minimal_pair_policy": {
    "required_on_dispute": true,
    "record_variants": true
  }
}
```

### Pre-Implementation Checklist (Green) — Template

| Task | Status | Evidence |
|---|---|---|
| Quick AB2 discovery pass | TODO | (path to run ledger) |
| Lightweight spec review | TODO | (brief notes or spec section reference) |
| Hypothesis register reconciled | TODO | (section reference + promotion receipt) |
| Probe Contract declared for comparison-based tests | TODO | (section reference or `not_applicable` rationale) |

---

## Micro-Ontology (State Model)

State object `spec_state`:
- `north_star`
- `constraints`
- `stakes_band`
- `predicate_vector`
- `ctq_gaps`
- `evidence_pack_ctqs`
- `evidence_pack_ctq_map`
- `pre_impl_checklist`  # tasks + status + evidence
- `pre_impl_green`  # boolean, true when checklist complete
- `context_budget` (CBGT)
- `evidence_pack_path`
- `evidence_pack_score`
- `evidence_pack_readiness_band`  # ready | near_ready | not_ready
- `evidence_pack_locked`
- `evidence_pack_open_items_count`
- `evidence_pack_traceability_ok`
- `evidence_scope`
- `ab2_evidence_budget`
- `ab2_strategic_tools`
- `ab2_tools_used`
- `ab2_run_ledger_path`
- `claim_hygiene_table`
- `hypothesis_register`
- `hypothesis_promotion_policy`
- `hypothesis_receipt`
- `test_policy_alignment`
- `evidence_scope_level`
- `generated_ctqs` (predicate-derived CTQ surface)
- `predicate_material_delta` (predicate-derived MATERIAL_DELTA)
- `special_flags` (active behavior flags from PRSBM-EF)
- `concept_pool` (candidate spec improvement concepts)
- `internal_signals` (CGEN-OS internal signal snapshot)
- `tone` (derived spec language tone)
- `bubble_intersection` (CBGT context coherence score)
- `e_remaining` (CBGT energy remaining)
- `crsm_scores`
- `selected_concept`
- `prsbm_plan` (strategy + tool sequence)
- `rsm_scores`
- `patch_history`
- `stop_reason`

State transitions:
- `evidence_pack_gate -> context_check -> ctq_generation -> internal_signal_computation -> flag_derivation -> tone_derivation -> material_delta_derivation -> ab2_evidence_pass -> hypothesis_promotion_gate -> test_policy_gate -> cgen_os -> drift_correction -> crsm_gate -> math_gate -> prsbm_route -> apply_patch -> rsm_update -> stop_check`

---

## Entry Locks (CGEN-OS)

Before any concept generation, enforce:
- `EVIDENCE_PACK_LOCK`: evidence pack exists and is at least `near_ready` (or explicit `never_block` best-effort mode is active).
- `NS_LOCK`: North Star stated in one sentence.
- `CONSTRAINT_LOCK`: must-do / must-not-do / output constraints.
- `PLACEMENT_LOCK`: what must appear in the first 20-30% of the spec (e.g., scope + evidence anchors).

---

## Technique Timing (Micro-Ontology)

Apply the minimal tool that matches the signal. Use CGEN-OS activation matrix for CGEN tools and PRSBM activation matrix for PRSBM tools.

CGEN-OS timing rules (examples):
- `predicate_confidence_low` or solution-language detected: Problem Re-Instantiation Operator.
- `external_stakes` or `low_reversibility`: Negative Space Definition.
- `missing_primitives_detected`: Primitive Completeness Check.
- `frame_confidence < 0.60` or `novelty_required`: Frame Enumeration Gate (min 3 frames).
- `hidden_constraint_risk`: Anti-Solution Synthesis.
- `overconstrained_detected`: Constraint Toggle Matrix.
- `analogy_detected`: Invariance-Only Transfer (IOP-Upgrade).
- `candidate_count < 3`: Hypothesis Set Integrity (HYP).
- `concept_generated`: MVP-Lite.
- `concept_complexity_high`: MEP.
- `rule_based_concept`: ARS.

PRSBM-EF timing rules (examples):
- `legal_regulatory`: P + R + CTM + CFB mandatory.
- `counterparty_protected`: CD + CTM mandatory.
- `low_reversibility`: P + R + CFB mandatory.
- `strategic_decision`: S + M mandatory.
- `factual_question` only: Frame Guard only (vanilla eligible).

---

## CBGT Context Gate (Pre-Reasoning)

### Bubble Intersection Computation

Context coherence is measured by how much the active context bubbles overlap:

Preferred bubble sources:
- Evidence pack sections (scope/actors, evidence summary, contradictions, assumptions, examples, acceptance checks)
- Evidence anchors extracted from the pack
- Constraints + predicates derived from the pack

```text
intersection(B_i, B_j) = |B_i ∩ B_j| / |B_i ∪ B_j|
bubble_intersection = mean(intersection(B_i, B_j) for all i < j)
```

Where each bubble `B_i` is a coherent context unit (e.g., a predicate cluster, an evidence scope, a constraint set). Low bubble intersection means fragmented context — the spec's concerns don't cohere.

### Energy Watchdog

Compute remaining attention energy after loading context:

```text
E_cost(B_i) = alpha_i * size(B_i) * complexity(B_i)
alpha_i = alpha_0 * (1 - temperature/2) * eta_model  # adaptive parameter
E_remaining = 1.0 - sum(E_cost(B_i))
```

Where `alpha_0 = 0.01` (base cost), `temperature` is reasoning temperature (0..1), and `eta_model` is model efficiency factor (default `1.0`).

### Halt Conditions

If **any** is true, halt deep reasoning and gather context:
- `evidence_pack_score < 0.60` — pack is not ready (research layer incomplete)
- `RSM < max(predicate_floor, 0.60)` — predicate floor or drift threshold, whichever is higher
- `bubble_intersection < 0.40` — fragmented context
- `E_remaining < 0.25` — attention budget depleted (energy watchdog)
- `predicate_confidence_low` or contradictory predicates

Exception: if `never_block` flag is set, produce best-effort output with explicit caveats instead of halting.

### Drift Detection

From CBGT drift model: `D ~ U^2 * S` (drift scales with uncertainty squared times simulation depth).

- If `RSM < 0.60` regardless of predicate floor: reasoning drift is likely. Do not increase simulation depth.
- If `RSM < predicate_floor` but `RSM >= 0.60`: context is insufficient for this stakes level but reasoning is not yet drifting. Gather targeted context.
- If `E_remaining < 0.25`: pause low-priority branches; route to ASK or finalize with what's available.

Actions when halted:
- Ask clarifying questions (unless `never_block`)
- Expand evidence anchors
- Build/refresh the evidence pack (add missing sections, resolve contradictions, add edge cases, re-score)
- Recompute predicates and CTQs
- Re-derive bubble intersection after context expansion

---

## Predicate-Specific CTQ Generation

Purpose:
- Auto-generate CTQ surface from active predicates so concept generation and scoring reflect the actual quality dimensions that matter for this spec.

Inputs:
- `PREDICATE_VECTOR` (from inputs)
- CTQ mappings from `PRSBM_EF_ACTIVATION_MATRIX.md` §7

Computation:
```text
ctqs = dict(base_ctqs)  # relevance:0.20, accuracy:0.20, clarity:0.15, completeness:0.10
for predicate in active_predicates:
  if predicate.is_present:
    for ctq, weight in ctq_mappings[predicate].items():
      scaled_weight = weight * predicate.confidence
      if ctq in ctqs:
        ctqs[ctq] += scaled_weight
      else:
        ctqs[ctq] = scaled_weight
total = sum(ctqs.values())
ctqs = {k: v/total for k, v in ctqs.items()}
```

Predicate → CTQ additions (reference):
- `legal_regulatory`: legal_framework (0.25), lawful_basis_clarity (0.20), risk_disclosure (0.15), documentation_readiness (0.10)
- `active_incident`: containment_speed (0.25), blast_radius_understanding (0.20), escalation_path (0.15), recovery_steps (0.15)
- `emotional_dimension`: emotional_intelligence (0.20), tone_appropriateness (0.15)
- `power_dynamics`: power_balance_awareness (0.20), protective_framing (0.15)
- `livelihood_impact`: consequence_awareness (0.20), reversibility_check (0.15)
- `explicit_choice`: option_coverage (0.20), comparison_clarity (0.15)
- `quantifiable_tradeoffs`: data_grounding (0.20), tradeoff_transparency (0.15), criteria_explicitness (0.15)
- `low_reversibility`: reversibility_awareness (0.20), caution_signals (0.15)
- `factual_question`: factual_accuracy (0.25), source_quality (0.15)
- `procedural_question`: step_clarity (0.20), sequence_correctness (0.15)

Gate:
- If generated CTQ set has fewer than 4 dimensions after normalization, flag as `ctq_surface_thin` and add base CTQs at minimum weights.

Required output:
- `generated_ctqs`: normalized CTQ dictionary
- Replace `CTQ_GAPS` input with the union of user-provided gaps and any generated CTQ scoring below 0.10.

Integration:
- The generated CTQ surface feeds into CGEN-OS (concept evaluation), CRSM (CS_conf scoring), and PRSBM-EF (stage selection). It does not replace user-provided `CTQ_GAPS` but augments them.

---

## Predicate-Derived MATERIAL_DELTA

Purpose:
- Replace the generic `MATERIAL_DELTA = 0.02` with a predicate-sensitive threshold so high-stakes specs iterate more aggressively while low-stakes specs stop earlier.

Computation (from `PRSBM_EF_ACTIVATION_MATRIX.md` §4):
```text
threshold = 0.20  # default
for predicate in active_predicates:
  if predicate.is_present:
    threshold = min(threshold, delta_rsm_thresholds[predicate])
return threshold
```

Predicate → ΔRSM thresholds (reference):
- `legal_regulatory`: 0.10 (small gains matter in compliance)
- `active_incident`: 0.10 (clarity crucial during incidents)
- `external_stakes`: 0.15 (worth iterating when others affected)
- `livelihood_impact`: 0.15 (worth iterating for career decisions)
- `explicit_choice`: 0.15 (clearer tradeoffs help decisions)
- `power_dynamics`: 0.15 (worth iterating for sensitive dynamics)
- `factual_question`: 0.25 (only iterate if dramatically helpful)
- `creative_output`: 0.25 (only iterate if dramatically helpful)
- `default`: 0.20

Rule:
- The computed threshold replaces `MATERIAL_DELTA` in all stop/plateau checks for this run.
- If user provides an explicit `MATERIAL_DELTA` input, use `min(user_delta, predicate_derived_delta)`.

---

## AB2 Evidence Pass (Proof Discipline)

Purpose:
- Ensure the spec's strongest claims are *actually proven in-scope*, and that any absence claims are explicitly gated.
- Generate a `Claim Hygiene (AB2 Stack Applied)` section like SPEC-116/SPEC-117, so implementers can trust and reproduce evidence.

Rules:
- Respect `EVIDENCE_SCOPE`: proof claims must be bounded to the declared files/modules.
- No runtime tools unless `AB2_EVIDENCE_BUDGET.runtime_allowed=true`.
- Every claim labeled "proven" must have an AB2 basis entry with tool(s) used and evidence tier.

Claim types and required evidence (minimums):
- Presence claim ("X exists / is called"):
  - `ab2_function_source` or `ab2_call_site_context` (plus `ab2_constant_usage` when driven by constants).
- Ordering/reachability claim ("A runs before B", "guard blocks path"):
  - `ab2_execution_order` or `ab2_early_returns` + `ab2_reach_conditions` (guard context required).
- Dataflow claim ("this field is last written here", "this key is never read"):
  - `ab2_last_writer` or `ab2_key_usage` / `ab2_constant_usage` (file-scoped).
- Absence claim ("no override mechanism", "no reads of key"):
  - `ab2_key_usage` + `ab2_constant_usage` (as applicable) then **gate the claim** with:
  - `ab2_claim_gate` with `enforce_absence_guard=true` and explicit scope statement.

Evidence tiers (recommended):
- `E1`: static/proven (AB2 static tools within `EVIDENCE_SCOPE`)
- `E0`: runtime/observed (allowed only when runtime capture is explicitly permitted; otherwise mark as prior observation and "not re-verified")

Evidence scope ladder (absence-claim reliability):
1. **L0 — File-scoped**: `ab2_key_usage` / `ab2_constant_usage` within `EVIDENCE_SCOPE` file(s).
2. **L1 — Module-localization**: `ab2_rg` over relevant module globs (e.g., `um_mcp/**/*.py`) to find additional occurrences (localization only, not proof).
3. **L2 — Repo-limited proof**: bounded static scans over relevant directories with `ab2_key_usage` on discovered files; re-run `ab2_claim_gate` with updated scope.
4. **L3 — Runtime** (only if allowed): confirm dynamic reads/writes.

Rule: absence claims can be marked “proven” **only within the current evidence scope level**. If global absence is required, escalate to L2 (and L3 if runtime allowed) and re-gate.

Hypothesis promotion ladder:
1. `hypothesis`: claim exists but required evidence chain has not run or is incomplete.
2. `observed`: at least one required tool result exists, but proof chain is incomplete or scope is below target.
3. `proven`: full required chain satisfied for claim type and `ab2_claim_gate` returns `OK` in declared scope.
4. `blocked`: `ab2_claim_gate` returns `BLOCK`, or scope/partiality flags prevent promotion.

Mandatory promotion rules:
- A claim may be promoted to `proven` only if all required chain tools are present and non-partial, and `ab2_claim_gate` is `OK`.
- `ab2_claim_gate=BLOCK` or `ab2_claim_gate=ASK` forbids `proven` labeling.
- All blocked claims must be listed in the hypothesis register with a deterministic next evidence step.
- Absence claims must include `claim_type=absence` and carry `enforce_absence_guard=true` in claim-gate receipts.

Hypothesis register minimum fields:
- `id`, `claim_text`, `claim_type`, `risk_level`, `status`, `scope_level`, `required_chain`, `last_gate_decision`, `next_step`

Required output format:
- Add a spec section `## Claim Hygiene (AB2 Stack Applied)` containing:
  - a claim table (`C1..Cn`) with `{Claim, Evidence Tier, Basis, AB2 Tool}`
  - an explicit absence-claim guard when any `E1` absence claim exists

Decision point (partial evidence):
- If `AB2_EVIDENCE_BUDGET` reports `LIKELY_PARTIAL` **and** any absence claim would be labeled “proven,” you must do one of:
  - Expand evidence budget and re-run claim gate, or
  - Downgrade the claim to hypothesis and adjust spec language to avoid “proven/never” phrasing.
- Do not keep an absence claim labeled “proven” under partial evidence.
- If unresolved hypotheses remain above promotion policy thresholds, cap readiness and stop with an evidence-blocked reason instead of escalating prose confidence.

Traceability requirement:
- If AB2 tools are used in the run, persist a ledger so the evidence can be audited:
  - `ab2_run_ledger save_to_workspace=true workspace_dir=/Users/walter/Dev/um/workspaces`
  - Include the resulting ledger path in the spec's Claim Hygiene section.

## Test Policy Alignment Gate

Purpose:
- Ensure specs reflect intent over legacy tests and prevent bloated workarounds.

Steps:
1. Read `TEST_POLICY_PATH` and extract the intent hierarchy (intent > tests).
2. Map each acceptance criterion to:
   - an existing test (if aligned), or
   - a proposed new test (if necessary), or
   - an explicit **test exception** (obsolete or contradictory with North Star).
3. If any test exception is declared, add a short “Test Policy Alignment” note in the spec with rationale.

Gate:
- If a test conflicts with North Star and no exception note is written, **fail the gate** and stop.

---

## CGEN-OS Phase (Concept Generation)

### Internal Signal Computation

Before selecting a CGEN-OS strategy, compute internal signals that drive tool activation:

```text
internal_signals = {
  predicate_confidence_low:  any(p.confidence < 0.50 for p in active_predicates),
  contradictory_predicates:  any conflicting predicate pair detected,
  frame_confidence:          estimated confidence in problem framing (0..1),
  missing_primitives_detected: spec references undefined terms or missing constraints,
  hidden_constraint_risk:    spec has implicit assumptions not stated as constraints,
  overconstrained_detected:  constraints are mutually exclusive or leave no solution space,
  candidate_count:           number of viable improvement concepts generated so far,
  concept_complexity_high:   selected concept requires 3+ coordinated changes,
  analogy_detected:          spec references patterns from other domains,
  novelty_required:          problem has no known precedent in codebase
}
```

These signals feed into the activation matrix to select which CGEN tools to run. Tools are only activated when their trigger conditions are met.

Use CGEN-OS activation matrix and strategy ontology to select the smallest tool sequence that guarantees coverage.

Phases (from activation matrix):
- A_define_manifold
- B_expand_safely
- C_cull_cheaply
- D_monitor

Minimum outputs:
- problem restatement
- must-not list
- invariants
- frames (>=3 when required)
- feasibility conditions (MVP-Lite)
- adversarial counterexamples (ARS)
- CS_conf, CP_conf, CRSM per concept

Strategy selection (CGEN-OS):
- Match predicates + stakes to strategy ontology.
- Resolve ties by priority order (high_stakes_creativity > ambiguous_frame_risk_start > debug_existing_concept > over_constrained > analogical_transfer_heavy > execution_first > novel_project_creation > exploration_no_commit).
- Execute only the phases required by the matched strategy and activation matrix.

### Creative Drift Correction

After CGEN-OS concept generation, check for drift signals:

| Drift Signal | Correction Tools |
|---|---|
| `novelty_up AND invariant_coverage_down` | Invariance Discovery Operator, Negative Space Definition |
| `invariant_coverage_up AND novelty_down` | Frame Enumeration Gate, Constraint Toggle Matrix |
| `candidate_count < 3` after generation | Hypothesis Set Integrity (HYP) — force min 3 candidates |
| `concept_complexity_high AND frame_confidence < 0.60` | Problem Re-Instantiation Operator — re-anchor before continuing |

Rule: if drift correction adds new concepts, re-run CRSM gate on the expanded pool. Do not skip filtering.

---

## CRSM Gate (Concept Filtering)

Compute:

`CRSM = CS_conf * CP_conf`

Floors by stakes (from CGEN-OS policy):
- LOW: `0.55`
- MEDIUM: `0.60`
- HIGH: `0.70`
- CRITICAL: `0.75`

If no concept passes:
- Trigger Concept Genesis Loop (max 2 cycles)
- If still none, stop with `budget_exhausted`

---

## Mathematical Basis Continuation Gate

Purpose:
- Decide whether the spec should keep a mathematical basis, downgrade to heuristic framing, or defer mathematical formalization.

Run this gate after CRSM and before PRSBM routing.

Inputs:
- `stakes_band`
- `math_basis_candidate`
- `invariants`
- `falsification_checks`
- `acceptance_criteria`
- `implementation_delta`

Scoring (0..1):
- `math_traceability`: each equation/term maps to at least one invariant and one acceptance criterion.
- `math_falsifiability`: at least one falsification path can disconfirm the math claim.
- `math_operationality`: math changes implementation or test behavior (not decorative).
- `math_calibration`: constants/thresholds have justification or bounded heuristic labels.

`math_basis_score = 0.30*math_traceability + 0.30*math_falsifiability + 0.30*math_operationality + 0.10*math_calibration`

Decision policy:
- `continue_math` when:
- `math_basis_score >= 0.70`
- and `math_traceability >= 0.70`
- and `math_falsifiability >= 0.60`
- `heuristic_only` when:
- `0.45 <= math_basis_score < 0.70`
- or traceability/falsifiability minima fail but operational spec is still strong
- `defer_math` when:
- `math_basis_score < 0.45`
- or equations are non-operational (no AC/test linkage)

Hard fail conditions (force `defer_math`):
- equation has no mapped invariant
- equation has no mapped acceptance criterion
- mathematical section increases verbosity without changing implementation/test contracts

Required output:
- `math_basis_decision`
- `math_basis_rationale`
- `math_basis_score`
- `math_mapping_table` (equation -> invariant -> AC/test)

---

## PRSBM-EF Strategy Routing

Select PRSBM strategy based on predicates and stakes:
- Use PRSBM_EF_ACTIVATION_MATRIX.md for mandatory stages
- Use PRSBM_EF_STRATEGY_ONTOLOGY.md for sequence and outputs

Required outputs per strategy must be produced before patching:
- frame_check
- failure_preview
- fragility_check (if required)
- evidence_trace (CTM)

Mandatory-stage mapping:
- Use PRSBM_EF_ACTIVATION_MATRIX.md for predicate-to-stage rules.
- If multiple strategies match, select the highest priority strategy that satisfies stakes constraints.

---

## Special Behavior Flags (PRSBM-EF)

Purpose:
- Activate behavioral modifiers derived from predicates that change how PRSBM stages execute, how the spec is written, or whether stages can be skipped.

Computation:
- Derive flags from active predicates using `PRSBM_EF_ACTIVATION_MATRIX.md` §9.
- Flags are additive: if any setting predicate is active and present, the flag is set.

Flag definitions:

**`never_block`**
- Set by: `active_incident`, `delay_increases_harm`
- Effect: Always produce output; never wait for clarifiers. Skip ASK mode entirely.
- Protocol impact: If set, CBGT context gate routes to "best-effort with caveats" instead of "halt and gather context."

**`requires_evidence_trace`**
- Set by: `legal_regulatory`, `audit_required`, `counterparty_protected`
- Effect: CTM (Claim Traceability Map) is mandatory in E-layer. Every major claim must map to evidence or explicit invariant.
- Protocol impact: E-layer cannot skip CTM step.

**`requires_perspective_swap`**
- Set by: `emotional_dimension`, `power_dynamics`, `counterparty_protected`
- Effect: CD (Constraint Discovery via perspective swap) is mandatory in E-layer.
- Protocol impact: E-layer must include CD pass before SAA.

**`requires_fragility_check`**
- Set by: `external_stakes`, `low_reversibility`, `livelihood_impact`, `high_harm_potential`
- Effect: CFB (Counter-Factual Breaker) is mandatory in E-layer.
- Protocol impact: E-layer cannot skip CFB step.

**`hedge_language`**
- Set by: `low_reversibility`
- Effect: Spec language uses cautious, hedged framing for recommendations and predictions.
- Protocol impact: Red-team (Stage R) must check for overconfident language.

**`vanilla_eligible`**
- Set by: `factual_question` (alone)
- Conditions: `stakes == LOW` AND no high-stakes predicates present
- Effect: Can skip PRSBM entirely; answer directly with Frame Guard only.
- Protocol impact: If set, skip Stages P/R/S/E-layer and go directly to scoring.

**`arc_tune_enabled`**
- Set by: `novelty_required`
- Conditions: `stakes not in [HIGH, CRITICAL]`
- Effect: Enable HYP (Hypothesis Set Integrity) and MEP (Minimum Experiment Protocol) creative modes in CGEN-OS.
- Protocol impact: CGEN-OS may use expanded tool set.

Integration:
- Flags are computed once after predicate classification and before CGEN-OS phase.
- Flags are recorded in telemetry under `special_flags_active`.
- Flags override default stage skip/include decisions in PRSBM-EF routing.

---

## Tone Derivation (PRSBM-EF)

Purpose:
- Select spec language tone from active predicates so the spec matches its stakes and audience.

Priority order (highest wins):
1. **URGENT** — set by: `active_incident`, `delay_increases_harm`. Short sentences, imperative verbs, no hedging.
2. **FORMAL** — set by: `legal_regulatory`, `audit_required`, `counterparty_protected`. Precise language, defined terms, no colloquialisms.
3. **WARM** — set by: `emotional_dimension`, `power_dynamics`. Empathetic framing, acknowledge impact.
4. **ANALYTICAL** — set by: `quantifiable_tradeoffs`, `strategic_decision`. Data-first, comparison tables, explicit criteria.
5. **PEDAGOGICAL** — set by: `procedural_question`, `factual_question`. Step-by-step, examples, progressive disclosure.
6. **NEUTRAL** — default when no tone-setting predicate is active.

Rule:
- Tone is advisory, not gating. It guides spec language choices in Stage R (Red-Team checks overconfident language when `hedge_language` is set) and Stage EAR (removes tone-inappropriate verbosity).
- If `hedge_language` flag is set, URGENT tone is downgraded to FORMAL (cannot be both urgent and hedged).

---

## Scoring Model (Internal RSM)

Use:

`RSM = NS_conf * NAV_conf`

### NS_conf (0..1)
Weighted average:
- `0.20` Problem clarity and bounded scope
- `0.20` Decision lock (chosen options + rejected alternatives + rationale)
- `0.20` Falsifiable acceptance criteria quality
- `0.20` Implementation delta specificity (file/function/test mapping)
- `0.20` Schema/behavioral contract strictness

### NAV_conf (0..1)
Compute:
- `overlap_nav`: evidence-anchor overlap across critical sections
- `execution_conf`: deterministic executability for implementers
- `evidence_conf`: claim hygiene completeness and evidence tier quality (AB2-backed where required)
- `context_coherence`: bubble intersection score from CBGT (how well context units cohere)
- `anchor_bloat_penalty`: repeated anchor blocks/noise

Formula:

`NAV_conf = clamp(0,1, (0.45 * overlap_nav) + (0.25 * execution_conf) + (0.20 * evidence_conf) + (0.10 * context_coherence) - anchor_bloat_penalty )`

Context coherence (from CBGT bubble intersection):
```text
context_coherence = bubble_intersection  # already computed in CBGT gate (0..1)
```

If `context_coherence < 0.40`, NAV_conf is likely suppressed. This is intentional — fragmented context should lower navigation confidence.

Evidence confidence:

`evidence_conf = clamp(0,1, (proven_claims / max(1,total_claims)) - 0.05 * (blocked_absence_claims / max(1,total_claims)) )`

Claim tier definitions for scoring:
- **Proven**: claim has AB2 basis entry at E1 tier (static tools, within evidence scope), claim gate passed.
- **Observed**: claim has E0 tier (runtime observation or prior verification), not re-verified in this pass.
- **Hypothesis**: claim lacks AB2 basis or has partial evidence. Must not use "proven/never/always" language.
- **Blocked**: absence claim that failed claim gate or has partial evidence and was not expanded/downgraded.

Only "proven" claims count in the `proven_claims` numerator. "Observed" claims count in `total_claims` but not `proven_claims`. "Blocked" claims add to the penalty term.

Execution confidence (recommendation):

`execution_conf = 0.40 * impl_delta_specificity + 0.30 * ac_executability + 0.30 * test_policy_alignment`

Where:
- `impl_delta_specificity`: fraction of implementation changes that name concrete files, functions, and operations (not vague directives). Score 1.0 when every change maps to `file:function:operation`. Score 0.0 when changes are abstract ("improve error handling").
- `ac_executability`: fraction of acceptance criteria that have measurable pass/fail signals and explicit failure cases. Score 1.0 when every AC has a testable assertion. Score 0.0 when ACs are subjective ("should be robust").
- `test_policy_alignment`: 1.0 when all ACs map to existing tests or have explicit exception notes. Deduct 0.25 per unmapped AC without exception rationale. Floor at 0.0.

Recommended penalty:
- duplicate canonical evidence block beyond first occurrence: `+0.12` each (cap `0.36`)

Canonical evidence block detection:
- A "canonical evidence block" is any AB2-backed claim table, evidence scope declaration, or claim hygiene section.
- First occurrence in the spec is free; each additional copy of substantially the same content (>70% token overlap) incurs the penalty.
- Detection method: compare each evidence-bearing section's claim IDs. If the same claim ID set appears in multiple sections, the later occurrences are duplicates.

---

## Recursive Loop (CGEN-OS + PRSBM-EF)

Run for `i in 1..MAX_ITERS`.

### Stage 0.0: Evidence Pack Gate
Ensure an evidence pack exists, score it, derive readiness band, and lock a version for this run.

- If `not_ready` (< 0.60) and `never_block` is not set: gather evidence and retry Stage 0.0.
- If `near_ready` (0.60–0.75): proceed, but keep open items explicit and restrict scope expansion.
- If `ready` (>= 0.75): proceed.

### Stage 0: Context Check (CBGT)
Confirm context sufficiency. If insufficient, gather context and re-derive predicates.
Exception: if `never_block` flag is set, produce best-effort output with explicit caveats instead of halting.

### Stage 0.1: CTQ Generation
Compute predicate-specific CTQ surface. Replace `CTQ_GAPS` with union of user-provided gaps and generated CTQs below 0.10 weight.

### Stage 0.15: Internal Signal Computation
Compute CGEN-OS internal signals (frame_confidence, candidate_count, hidden_constraint_risk, etc.) from current spec state. These drive tool activation in Stage 1.

### Stage 0.2: Flag Derivation
Compute special behavior flags from active predicates. Record in state. These flags modify downstream stage execution.

### Stage 0.25: Tone Derivation
Select spec language tone from active predicates using priority order. Record in state for use in Stages R and EAR.

### Stage 0.3: MATERIAL_DELTA Derivation
Compute predicate-derived MATERIAL_DELTA. Use `min(user_delta, predicate_derived_delta)` for all stop/plateau checks.

### Stage 0.5: AB2 Evidence Pass
Run a bounded AB2 pass to prove or downgrade critical claims, generate `Claim Hygiene (AB2 Stack Applied)`, and gate any absence claims.

### Stage 0.55: Hypothesis Promotion Gate
Reconcile claim statuses using AB2 receipts and enforce promotion policy.
- Promote only when full chain + claim gate allows.
- Keep blocked claims explicit with next-step evidence calls.
- Update hypothesis register and promotion receipt before scoring.

### Stage 0.6: Test Policy Alignment Gate
Map ACs to tests or exceptions; add a Test Policy Alignment note when exceptions exist.

### Stage 1: CGEN-OS Concept Pass
Generate and filter candidate improvement concepts using the selected CGEN strategy.

### Stage 2: CRSM Gate
Drop sub-floor concepts. Select highest CRSM concept for PRSBM.

### Stage 2.5: Mathematical Basis Gate
Evaluate whether mathematical formalization should continue, be downgraded to heuristics, or be deferred.

### Stage 3: PRSBM-EF (Strategy-Based)
Run the cognitive sequence dictated by the selected PRSBM strategy.

### Stage P: Premortem
Assume one-shot implementation fails. Enumerate concrete failure paths:
- wrong behavior shipped
- unsafe override path
- ambiguous acceptance criteria
- schema drift / compatibility break
- test blind spots

### Stage R: Red-Team
Write strongest counter-argument against current draft:
- where it can be misread
- where it can be gamed
- where it allows soft-fail behavior

### Stage S: Precision Sniping
Generate at least 2 patch plans. Choose the smallest patch with highest expected RSM delta.

### Stage E-Layer (mandatory for governed specs)

Apply in order:
- `CTM`: every major claim maps to evidence or explicit invariant
- `CFB`: flip key assumptions; add guards where behavior breaks
- `SAA`: verify all changes align with North Star
- `EAR`: remove low-signal verbosity
- `ERC`: remove generic statements with no implementation impact
- `MC` (optional): if multiple candidate rewrites remain, fuse only consistent components

### Stage B: Bayesian Update
Re-score NS_conf/NAV_conf after edits. Compare against previous iteration.

### Stage M: Markov Projection
Project 3 branches:
- good: patch improves implementability and stability
- neutral: mostly formatting/no structural gain
- bad: introduces ambiguity or policy loophole

Choose next action from highest expected value branch.

### Stage F: Frame Guard
Validate we are still solving original spec problem.

If `Frame_BAD`:
- allow one reclassification pass
- if still `Frame_BAD`, stop with `frame_bad_unresolved`

---

## Material Improvement / Stop Rules

Stop when any is true:

1. `RSM >= target` (recommended target `>= 0.85` for one-shot readiness)
2. Two consecutive iterations with `delta_rsm < predicate_material_delta` (predicate-derived, not generic 0.02)
3. No actionable CGEN-OS or PRSBM-EF operator remains (operator exhausted)
4. Reclassification limit reached (`Frame_BAD` unresolved)
5. Hypothesis policy breached (`unresolved_high_risk > max_unresolved_high` or blocked critical claim exists)

Decision acceptance:
- When stop rule (1) triggers (`RSM >= target`), accept the decision as one-shot-ready and finalize (do not route to ASK/gather unless an external constraint changes).
- Acceptance is valid only if Hypothesis Gate passes (no blocked critical claims and unresolved hypotheses are within policy).

Plateau rule:
- if `delta_rsm < predicate_material_delta` twice and no new falsifiable checks were added, terminate.

---

## One-Shot Hard Gates (Must Pass)

Before finalizing, all must pass:

1. **Determinism Gate:** behavior and override logic have explicit step order and machine-readable error codes.
2. **Falsifiability Gate:** at least one adversarial falsification check per high-risk area.
3. **Traceability Gate:** claims -> anchors/invariants (no orphan claims).
4. **Noise Gate:** no repeated canonical evidence sections; no decorative framework text without executable impact.
5. **Implementation Gate:** explicit file/function/test delta is complete enough for one-pass coding.
6. **Evidence Gate:** `Claim Hygiene (AB2 Stack Applied)` exists; all "proven" claims have an evidence tier and AB2 basis entry; any absence claims are explicitly scoped and claim-gated.
7. **Test Policy Gate:** any conflict with `TEST_POLICY_PATH` is explicitly resolved (mapped test or exception note).
8. **Hypothesis Gate:** all critical/high-risk claims are either proven or explicitly deferred within policy; no claim-gate `BLOCK` item may be presented as proven.

---

## Anti-Patterns (Fail Conditions)

Reject revision if any appears:

- Premortem theater (generic risks without failure mechanics)
- Red-team softball (no meaningful challenge)
- Sniping without alternatives (single-option rubber stamp)
- E-layer cargo cult (naming CTM/CFB/etc without changing constraints)
- Frame guard paralysis (infinite reframing loop)
- Markov happy path only (no neutral/bad branch)
- Anchor bloat (same evidence block repeated across sections)

---

## Spec Patch Heuristics

When improving a spec, prefer this patch order:

1. Remove duplicated evidence/noise blocks
2. Add concrete implementation constraints
3. Add falsification checks tied to highest-risk paths
4. Tighten policy/decision step ordering and error shapes
5. Add PRSBM-EF traceability table only if it drives executable checks

---

## Plateau Attack Subroutine (Last Levers, Hands-Off)

Trigger:
- `delta_rsm < MATERIAL_DELTA` and no new falsification checks were added in the last iteration.

Goal:
- Add **mechanical, low-risk** falsification/guard rails that are spec-tightening, not behavior-changing. This is intended to be safe for hands-off use.

Run the following in order; stop as soon as `delta_rsm >= MATERIAL_DELTA`:

1. **Audit Mutation Guard**
   - If any override/allow/deny path exists, add an AC + FC:
   - “Denied overrides must not emit or persist override audit fields.”
   - Add explicit state mutation rule: allow only mutates audit; deny does not.

2. **Reason Normalization Guard**
   - If any `reason_len` or reason-based gate exists, define:
   - normalize `reason` by trimming and collapsing whitespace.
   - whitespace-only reasons are treated as missing.
   - Add AC + FC for whitespace/padding reasons.

3. **Idempotency Guard (Decision Tuple)**
   - If an allow/deny decision is based on a tuple, add AC for determinism:
   - same tuple -> same allow/deny + same `details.reason`.

4. **Explicit Error Codes**
   - If any denial path lacks machine code, add structured `{code,message,details}` with a stable code.

5. **Test Policy Alignment Note**
   - If the spec introduces new policy behavior, add a Test Policy Alignment note mapping ACs to tests, or declare legacy-exception handling.

If none apply, declare `operator_exhausted` and stop.

---

## Telemetry Schema

```yaml
one_shot_spec_telemetry:
  target_spec: string
  north_star: string
  evidence_pack:
    path: string
    pack_id: string
    version: int
    weighted_score: float
    readiness_band: enum [ready, near_ready, not_ready]
    open_items_count: int
    traceability_ok: bool
  settings:
    max_iters: int
    material_delta: float
    predicate_material_delta: float
  generated_ctqs: {string: float}
  special_flags_active: [string]
  tone: string  # URGENT | FORMAL | WARM | ANALYTICAL | PEDAGOGICAL | NEUTRAL
  iterations:
    - iter: int
      cgen_strategy: string
      prsbm_strategy: string
      internal_signals: {string: any}  # CGEN-OS internal signals snapshot
      drift_correction_applied: [string]  # tools applied for drift correction, if any
      math_basis_decision: enum [continue_math, heuristic_only, defer_math]
      math_basis_score: float
      predicates: [string]
      cbgt:
        e_remaining: float
        bubble_intersection: float
        energy_watchdog_triggered: boolean
        drift_detected: boolean
      evidence_pack_score: float
      evidence_pack_band: enum [ready, near_ready, not_ready]
      rsm_before: float
      rsm_after: float
      delta_rsm: float
      crsm_scores: [float]
      ab2:
        evidence_scope: [string]
        tools_used: [string]
        run_ledger_path: string
        claims_total: int
        absence_claims: int
        proven_claims: int
        observed_claims: int
        blocked_claims: int
        hypothesis_claims: int
      hypothesis:
        unresolved_total: int
        unresolved_high_risk: int
        promoted_ids: [string]
        blocked_ids: [string]
        deferred_ids: [string]
      ns_conf: float
      nav_conf: float
      context_coherence: float  # bubble_intersection fed into NAV_conf
      overlap_nav: float
      execution_conf: float
      evidence_conf: float
      anchor_bloat_penalty: float
      applied_changes: [string]
      new_falsification_checks: [string]
      frame_guard_status: enum [Frame_OK, Frame_WARN, Frame_BAD]
      stop_candidate: boolean
  final:
    rsm: float
    stop_reason: string
    math_basis_decision: enum [continue_math, heuristic_only, defer_math]
    hard_gates_passed: boolean
    hypothesis_gate_passed: boolean
```

---

## Minimal Execution Pseudocode

```text
flags = derive_flags(predicate_vector)      # special behavior flags (e.g., never_block)
pack = ensure_evidence_pack()               # create if missing (playbook template)
pack_score, pack_band = score_evidence_pack(pack)
if (pack_band == not_ready) and (not flags.never_block):
  gather_evidence(); stop_or_retry()
score = score_spec(spec)
ctqs = generate_ctqs(predicate_vector)  # predicate-specific CTQ surface
signals = compute_internal_signals(spec, predicate_vector)  # CGEN-OS internal signals
tone = derive_tone(predicate_vector, flags)  # spec language tone
mat_delta = derive_material_delta(predicate_vector, user_delta)
for i in 1..MAX_ITERS:
  bubble_int = compute_bubble_intersection(pack, spec)  # prefer pack bubbles
  e_remaining = compute_energy_remaining(spec)
  if cbgt_halt_condition(spec, bubble_int, e_remaining):
    if flags.never_block: add_caveats(spec); continue
    else: gather_context(); continue
  if rsm < 0.60: log_drift_warning(); limit_simulation_depth()
  ab2_evidence = run_ab2_evidence_pass(spec, evidence_scope, budget)
  spec = write_claim_hygiene_section(spec, ab2_evidence)
  hypothesis_receipt = reconcile_hypotheses(spec, ab2_evidence, hypothesis_policy)
  spec = write_hypothesis_register(spec, hypothesis_receipt)
  if hypothesis_receipt.policy_breached: stop("evidence_blocked_hypotheses")
  signals = update_internal_signals(spec, signals)  # refresh after evidence pass
  cgen_plan = select_cgen_strategy(predicates, stakes, flags, signals)
  concepts = run_cgen_sequence(cgen_plan)
  concepts = apply_drift_correction(concepts, signals)  # if drift detected, run correction tools
  concepts = filter_by_crsm(concepts, stakes)
  if empty(concepts): genesis_loop_or_stop()
  math_decision = evaluate_math_basis(spec, invariants, acs, tests, stakes)
  spec = apply_math_basis_decision(spec, math_decision)
  prsbm_plan = select_prsbm_strategy(predicates, stakes, flags)
  if flags.vanilla_eligible: skip to scoring
  P = premortem(spec)
  R = red_team(spec, P, tone)  # tone-aware red-team
  if flags.hedge_language: R += check_overconfident_language(spec)
  candidates = generate_patch_options(spec, P, R, min_options=2)
  spec = apply_best_patch_by_expected_delta(candidates)
  spec = run_e_layer(spec, flags)  # CTM (mandatory if requires_evidence_trace)
                                    # CD (mandatory if requires_perspective_swap)
                                    # CFB (mandatory if requires_fragility_check)
                                    # -> SAA -> EAR (tone-aware) -> ERC (-> MC optional)
  new_score = score_spec(spec)
  log_iteration(i, score, new_score, ctqs, flags, tone, signals, mat_delta, bubble_int)
  if frame_guard(spec) == Frame_BAD:
    if reclassifications >= 1: stop("frame_bad_unresolved")
    spec = reclassify_once(spec); continue
  if stop_condition(score, new_score, mat_delta): break
  score = new_score
return spec, telemetry
```

---

## Notes

- This protocol is metacognitive discipline, not decoration.  
- Mentioning PRSBM-EF terms without measurable spec deltas is a failed run.  
- No use of external convergers or automated spec scoring tools.
- Mathematical basis is conditional: keep only when traceable, falsifiable, and operational.

### v2.0 Changelog (from v1.5)
- Added: CBGT bubble intersection formula with explicit computation and NAV_conf integration (0.10 weight).
- Added: Energy watchdog threshold (0.25) with adaptive alpha parameters.
- Added: Drift detection threshold (0.60 hard floor) with drift model integration.
- Added: CGEN-OS internal signal computation step with 10 named signals.
- Added: Creative drift correction subroutine with 4 signal→tool correction mappings.
- Added: Tone derivation rules (6 priority-ordered tones from predicates).
- Added: Claim tier definitions (proven/observed/hypothesis/blocked) for evidence_conf scoring.
- Added: Execution confidence component scoring definitions with concrete 0..1 scales.
- Added: Canonical evidence block detection rules for anchor bloat penalty.
- Added: Stages 0.15 (internal signals), 0.25 (tone derivation) to recursive loop.
- Added: Stage 0.55 hypothesis promotion gate with anti-overclaim policy and readiness caps.
- Updated: State model with internal_signals, tone, bubble_intersection, e_remaining, and hypothesis register artifacts.
- Updated: State transitions to include new stages.
- Updated: Telemetry schema with tone, internal_signals, drift_correction_applied, energy_watchdog_triggered, drift_detected, context_coherence, and hypothesis counters.
- Updated: Pseudocode to reflect all new computation steps.
