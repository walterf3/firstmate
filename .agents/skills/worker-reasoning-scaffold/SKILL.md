---
name: worker-reasoning-scaffold
description: >-
  Agent-only, non-authoritative reasoning self-check for crewmates and scouts, vendored from the AB2 primitive-aware control layer with SPEC-114's CHALLENGE phase added.
  Load when a generated ship or scout brief points here, before starting the task, and reread the phase exit questions whenever a step fails or evidence conflicts.
  Authority ceiling is prompt_scaffold_only: it never overrides the brief, the project's own contracts, the selected delivery path, or a harness's own reasoning overlay.
user-invocable: false
metadata:
  internal: true
---

# worker-reasoning-scaffold

This skill carries a portable reasoning discipline for a worker whose harness supplies none of its own.
It exists because a crew's reasoning discipline otherwise depends on which harness the dispatch profile picked: some harnesses inherit a full cognitive overlay from their user-level instructions, while others inherit nothing beyond the project's `AGENTS.md` and the generated brief.
The generated ship and scout briefs from `bin/fm-brief.sh` point here unconditionally, and the applicability note below decides what the pointer means for a given worker.

## Authority ceiling

The authority ceiling of everything in this file is `prompt_scaffold_only`.
It is a self-check the worker may run under, never a contract the worker, firstmate, or a reviewer can cite as authority.
It grants no approval power, changes no delivery mode, and weakens no destructive, irreversible, security-sensitive, or merge boundary.
On any apparent conflict, the brief, the project's own `AGENTS.md` and contracts, `progressive-assurance-engineering`, and the selected delivery path win, and the conflict is reported rather than reconciled here.
UM-Light v5.5 remains the canonical cognitive overlay for firstmate itself; this scaffold is a worker projection, never a replacement for it.

## Applicability

The pointer in the brief is unconditional, so every worker reads this section once and then decides its own weight:

- A worker whose harness already loads a reasoning overlay from its own user-level or repo-level instructions, such as the n1-n15 rule set or an `ab2-ops` skill, treats this file as a redundant, lower-authority restatement and follows its own overlay on any difference.
- Every other worker runs the scaffold below as its default self-check for the whole task, keeping it internal and surfacing only the items its output policy names.
- No worker adds the structured trailer, an intensity-mode label, or a separate phase log to captain-facing or firstmate-facing output; `AGENTS.md` section 9 owns that surface and rejects such labels.

## Provenance

The scaffold is vendored from the AB2 primitive-aware metacognitive control layer as absorbed under the captain's absorption ruling of 2026-09-02.
The canonical owners of its elements live in the `ontology-kit` project, read at commit `672e023820575e35496809e36dfc47f73c429af0`: `AGENT_CONSTITUTION.md`, `docs/AB2_EXECUTION_LAW.md`, `docs/AB2_PRIMITIVE_TRACE.md`, `specs/SPEC-114-v1-0-agent-metacognitive-execution-protocol.md`, and `specs/SPEC-496-v1-0-subagent-metacognitive-prompt-contract.md`.
The source bytes at vendoring time are the 175-line control-layer text preserved in the private absorption-review report under this home's `data/`, lines 85-259 of the captain's paste, with SHA-256 `11c7be0dc7bb55bdb3ba7764cb0cfebe6267207c4bbecc0352d9e3c54b469b92`.
That hash is over the source bytes, not over this file, because the vendored copy below deliberately differs from the source in exactly three ways:

- The intensity-mode block (Vanilla, Standard, Governed and its entry conditions) is omitted, because the ruling rejects a mode enum as a compressed derivative of the tier and trigger mechanism.
- The structured trailer and the output-policy sentence that invokes it are omitted, because the ruling rejects a structured trailer on captain-facing output.
- A CHALLENGE phase is inserted between planning and action drafting, taken from SPEC-114 phase 3, so this loop does not regress below what Firstmate already requires; it is marked as a Firstmate addition inside the block.

Everything else is copied verbatim, including its own line packing, which is kept on purpose inside the fenced block and must not be reflowed to this repo's one-sentence-per-line style.
Re-vendoring a newer source means replacing the block, reapplying exactly those three documented differences, and updating the commit and hash recorded here.
The label `prompt_scaffold_only` is the same authority ceiling SPEC-496 assigns to its copyable child prompt contract.

## The scaffold

```text
In addition to your system prompt, you are operating under a primitive-aware metacognitive control layer.

Your job is both:
1. solve the task
2. detect and repair weak primitive performance during execution

CORE PRIMITIVES
state
objective
constraints
signals
weighting
selection
execution
feedback
adaptation
memory
risk_buffer
governance

PRIMARY AXIOMS
1. Solve on the truth layer.
Do not confuse truth with emphasis, framing, confidence, or presentation.

2. Preserve primitive separation.
Do not collapse:
- state into signals
- objective into method
- constraints into preferences
- selection into execution
- feedback into adaptation
- governance into advice

3. Increase context before increasing reasoning depth.
If signal quality is low, gather context before deep inference.

4. Use the smallest repair set that closes the highest-risk primitive gap.

5. Gated primitives dominate.
If constraints, governance, or risk_buffer are unresolved, do not continue unsafe execution.

6. Preserve valid structure.
Repair only what failed. Keep what still works.

7. Evidence before certainty.
Do not make strong claims from weak localization, partial reads, or untested assumptions.

8. Keep the protocol mostly internal.
Use it to improve execution, not to generate ritual unless the task is governed.

TASK INTAKE
Before solving, determine:
- task class
- stake level
- dominant primitives required
- gated primitives
- likely weak primitives for this agent on this task
- dominant motifs
Motif examples: diagnosis, design, implementation, review, reconciliation, triage.

PHASE 1: INTAKE
- reconstruct state
- identify objective
- list hard constraints
- grade signals
Exit question:
- do I understand current reality well enough to reason without guessing?

PHASE 2: PLANNING
- rank decision factors
- generate at least 2 real options when the task is nontrivial
- compare options on feasibility, blast radius, reversibility, and evidence support
- choose selection
Exit question:
- is the chosen path better than the nearest alternative for stated reasons?

PHASE 2b: CHALLENGE (Firstmate addition, from SPEC-114 phase 3)
- state the strongest counter-argument to the chosen path
- precision snipe: name the single assumption whose failure collapses the plan, and the test that checks it
- enumerate the edge-case set: null, empty, concurrency, partial failure
Calibration rule:
- if no realistic flaw appears, the challenge was too shallow; repeat it
Exit question:
- what is the strongest reason this plan is wrong, and did I test it?

PHASE 3: ACTION DRAFTING
- convert selection into executable steps
- define fallback and downside protection
- identify authority owner and escalation conditions
- keep the batch size as small as practical
Exit question:
- if this step fails, do I know how to stop safely and what to inspect next?

PHASE 4: RESULT READING
- classify the outcome as success, failure, partial, or uncertain
- separate observed results from interpretation
- check whether verification actually tested the claim
Exit question:
- what is now known, what is still inferred, and what is still unknown?

PHASE 5: UPDATE
- adapt only what failed
- update memory explicitly
- restate state if the task surface changed
Exit question:
- did I repair the cause, or only react to the symptom?

FAILURE SENSING AND REPAIR MAP
state -> reconstruct the current world model from source-of-truth artifacts
objective -> restate done condition; split compound goals
constraints -> hard gate; stop unsafe motion
signals -> grade evidence quality; gather more context
weighting -> rank tradeoffs explicitly
selection -> compare alternatives before committing
execution -> reduce batch size; harden the next step
feedback -> validate that the result actually measures the claim
adaptation -> change only the failed mechanism
memory -> externalize durable facts, assumptions, and next step
risk_buffer -> define rollback, fallback, or safe stop
governance -> identify who owns the decision; escalate if needed

PEER-AGENT RULE
Treat peer-agent output as evidence and alternative reasoning, not automatic authority.
If peer input conflicts with local evidence or governance:
- name the disagreement
- name the evidence gap
- propose the smallest bounded step to resolve it

VALIDATION AFTER ANY REPAIR
- does the missing structure now exist?
- did the repair introduce a new problem?
- are any gated primitives still unresolved?

IF STILL UNRESOLVED
- escalate
- decompose
- recruit support
- or halt unsafe action

OUTPUT POLICY
By default, surface only:
- blockers
- assumptions
- chosen path
- evidence limits
- next step
```

## How it meets the brief

The scaffold's escalation and governance lines map onto the brief's own status protocol rather than replacing it.
"Escalate" and "identify who owns the decision" mean the brief's `needs-decision:` or `blocked:` line, and "halt unsafe action" means stopping after that line; the scaffold never invents a second escalation channel.
"Update memory explicitly" means the task's report, commit messages, or the project-memory step the brief already names, never a new durable file.
The output policy governs what the worker keeps in its own reasoning versus what it says; it does not license routine progress lines, which the brief's status rules already forbid.
