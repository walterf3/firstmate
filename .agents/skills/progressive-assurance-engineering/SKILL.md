---
name: progressive-assurance-engineering
description: >-
  Agent-only default engineering and verification sequencing for every registered project.
  Load before commissioning or performing mutable implementation or verification so focused falsifiers, dependency-scoped invalidation, frozen-candidate custody, and authority boundaries complement rather than replace each project's own contracts and selected Firstmate delivery path.
user-invocable: false
metadata:
  internal: true
---

# Progressive assurance engineering

This skill controls the default sequence for mutable engineering and verification across registered projects and complements Firstmate's task lifecycle, generated ship briefs, selected delivery path, and each project's own engineering and release contracts.
Those existing owners control routing and shipping but do not define dependency-aware engineering evidence sequencing, while the conditional method is too large for the always-loaded `AGENTS.md`.
Generated ship briefs point implementation workers to this owner so the method reaches project work without copying the contract into every project.

## Provenance and adoption boundary

This project-neutral contract adopts the method from **UM5 Progressive Assurance Engineering Protocol v0.4.0**, SHA-256 `d2b2bc5fb311311aa5330b088ab1b7675f70ccf4fcdf4d8f361d0a1f7c046e8f`.
The source's embedded `proposal_only` front matter records its historical pre-adoption state and remains distinct from the later operator decision.
**UM5 Progressive Assurance Engineering Protocol v0.4 Ratification and Adoption Record v1.0.0**, SHA-256 `77bf7d8b6f4325b3eac0692d5c763cb15172b5e7583ce71508daa4a66eb8e674`, has `status: ratified_current_engineering_policy` and separately records Walter's adoption of the exact source as governing mutable-engineering methodology and verification orchestration.
The hashes and versions preserve provenance without making this contract depend on a UM5 checkout or any machine-local path.
That adoption superseded only the proposal-to-policy hold and the older default of exact-byte custody ceremony throughout mutable work.
It did not accept a shadow pilot, local evidence, candidate, implementation, or release.

## Scope and precedence

Apply this method to mutable implementation and verification for every registered project.
A project's `AGENTS.md`, test policy, source locks, acceptance criteria, required release checks, and final approval authority remain binding.
Use the project's own names and surfaces rather than importing UM5 gate names, One-Pass terms, Lean targets, or runtime assumptions.
A named project-specific requirement for broader reruns, exact checks, or stricter custody remains binding, while an older generic habit is not a reason to repeat non-bearing work.
The selected Firstmate delivery path still owns review, fixes, tests, documentation, push, PR, and CI where its contract says it does.
Do not skip, duplicate, or replace required no-mistakes steps in the name of this method.
Use existing commit or tree identities, test runners, CI, review, and release records wherever sufficient.
Do not add a manifest, evidence graph, deployment identity, wrapper, or control plane unless a concrete project contract or demonstrated substrate gap requires it.

## Working identities

- The **mutable workspace** is where discovery, editing, and diagnostic iteration happen, and observations from unidentified changing bytes are not durable candidate evidence.
- The **candidate** is one immutable byte set identified by the project's strongest available content identity, and any subject-byte change creates a new candidate.
- The **run snapshot** immutably binds the candidate plus the relevant environment, toolchain, dependency locks, check definitions, flags, fixtures, seeds, and policy inputs needed to interpret a result.
- A run-input, command, fixture, environment, or harness repair creates a new run snapshot but does not create a new candidate when candidate bytes are unchanged.
- The **deployment identity** is separate from the candidate only where a project contract qualifies served behavior, and it binds the exact candidate to the mounted code, runtime, configuration, routes, and relevant environment actually qualified.
- Evidence and attestations describe a candidate or candidate-deployment pair and remain external to the subject they describe.

Scale these identities to the project's real substrate rather than inventing ceremony.
For example, a commit or tree plus the CI job's pinned inputs may already provide the candidate and run identities a routine project needs.

## Default sequence

1. Establish the project's required contracts, affected boundaries, and known dependencies before choosing checks.
2. Iterate freely in the mutable workspace and use cheap diagnostics without presenting them as durable final-candidate evidence.
3. Before collecting durable acceptance evidence, checkpoint one immutable candidate and one immutable run snapshot.
4. Before expensive dependent work, preflight the required environment, toolchain, credentials, services, fixtures, and check invocation so later execution can produce meaningful evidence.
5. Run the smallest focused negative and positive falsifiers capable of disproving the repair before broad suites.
6. Then check stable structural invariants and the affected consumers, integrations, and boundaries required by the proven dependency closure.
7. Require one complete project-required behavioral closure for one unchanged candidate before final custody.
8. If the project enters final custody, freeze that same candidate before creating any human-reviewed custody package, and never place a changing subject under human-reviewed custody.
9. Use the independent review required by the selected delivery or release contract to inspect the frozen subject and its required evidence without inventing a second reviewer.
10. Where the project requires served qualification, create or verify a distinct deployment identity and perform fresh qualification against the exact candidate-deployment pair.
11. Keep independent review, deployment-bound qualification, and final operator or release approval as separate authorities.

Exact-byte custody controls the final candidate or release subject, not every mutable iteration.
If candidate bytes change at any point after checkpointing, identify a new candidate and recompute the evidence state before making downstream claims.

## Evidence meanings

Use these distinctions wherever a check result is recorded or interpreted, without inventing a new state machine for projects that do not need one.

- `PASS` means the check passed for its exact verified evidence key and supports no broader claim.
- `FAIL` means a valid check found a product or construction violation.
- `BLOCKED` means a prerequisite or environment condition prevented a meaningful check.
- `INVALID` means the command, harness, fixture, or check definition was malformed.
- `INCONCLUSIVE` means instability or nondeterminism prevented a reliable conclusion.
- `STALE` means a relevant input changed after the result was produced, so the result is unusable.
- `PIVOT` means evidence contradicted a foundational architectural assumption, so local patching stops and architecture is reopened.

A wrong environment, unavailable prerequisite, or malformed invocation is not a product failure.
Preserve unchanged candidate bytes when only run inputs need repair, then create a fresh run snapshot and rerun the missing evidence.

## Termination, invalidation, and reuse

Terminate active dependent work as soon as a discovered defect means its eventual result will be stale or otherwise non-bearing after repair.
Independent work may continue only when its complete evidence key remains unchanged.
An evidence key is no broader than its verified check definition, relevant subject inputs, environment and toolchain inputs, dependency evidence, and governing policy inputs.
Never reuse evidence beyond that verified key or combine evidence from incompatible candidate identities into one closure.

After a mutation or relevant run-input change:

1. Locate running and completed evidence whose declared input closure intersects the change.
2. Cancel affected running work and mark affected completed evidence `STALE`.
3. Preserve only evidence whose complete key is proven unchanged.
4. Create replacement run snapshots and recompute aggregate conclusions after all input mutations.

Use exact descendant invalidation only when dependency declarations are proven complete.
Widen to the affected subsystem when dependency knowledge is partial.
Widen globally when a dependency is unknown, global, or cannot be bounded safely.
An undeclared dependency is a defect in the assurance substrate, not permission for optimistic reuse.

## Claim ceiling

Adopting this methodology is not acceptance or ratification of any project's candidate or release.
This skill grants no runtime, model, serving, mounting, deployment, product, readiness, quality, speed, effectiveness, non-inferiority, promotion, merge, or release authority.
It does not weaken destructive, irreversible, security-sensitive, review, merge, or final approval boundaries.
Every result remains limited to the subject, run inputs, deployment pair where applicable, checks, dependencies, and authority that were actually verified.
