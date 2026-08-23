---
name: one-shot-spec
description: >-
  Harden a target specification to one-shot implementation readiness under ONE_SHOT_SPEC_PROTOCOL v2.4.
  Use when the captain invokes /one-shot-spec, asks to harden or tighten a specification before it is built, or asks whether a spec is ready to implement in one pass.
  Produces a readiness verdict and the protocol's own artifacts only, and never carries implementation, merge, release, or project-write authority.
user-invocable: true
metadata:
  internal: true
---

# one-shot-spec

Harden a target specification under ONE_SHOT_SPEC_PROTOCOL v2.4 so an implementer can build it in one pass.
The protocol owns the method; this file owns only the Firstmate entry point, input binding, output routing, and authority boundary.
Keeping this adapter thin is deliberate, because a second description of the protocol would drift from the reference and become a competing authority.

## Protocol authority and provenance

[`references/ONE_SHOT_SPEC_PROTOCOL.md`](references/ONE_SHOT_SPEC_PROTOCOL.md) is the complete protocol and its only owner in this repository.
It is vendored verbatim from `ONE_SHOT_SPEC_PROTOCOL` version 2.4, last updated 2026-05-10, SHA-256 `288384e2fdaae4f9e068fdf1d99e05754855a9facd185c941154ef229b332ddc`.
The upstream owner is `engineering/ONE_SHOT_SPEC_PROTOCOL.md` in the captain's engineering docs corpus, which lives outside this repository and is never read at run time, so re-vendoring a newer version means copying that file byte-for-byte and updating the version, date, and hash recorded here.
The vendored bytes are unmodified, so `shasum -a 256` over that file still prints the hash above, and a mismatch means the copy drifted and must be reported before any run.
Read the reference before running, then follow its inputs, gates, promotion ladders, scoring model, stop rules, and hard gates exactly as written.
This file never restates, summarizes, or relaxes a protocol requirement, so an apparent conflict between the two resolves in the reference's favor and is reported rather than reconciled here.
The reference keeps the source's own sentence packing, punctuation, and trailing hard-break whitespace on purpose, so do not reflow it to this repo's Markdown style and do not strip what `git diff --check` reports inside it; either edit breaks the recorded hash without improving the protocol.

## When to invoke

Invoke on `/one-shot-spec`, or when the captain asks to harden, tighten, or readiness-check a specification before it is implemented.
Do not invoke it to diagnose a reported bug, which `diagnostic-reasoning` owns, or to sequence mutable implementation and verification, which `progressive-assurance-engineering` owns.
`AGENTS.md` section 7 still classifies the deliverable and decides whether a run is dispatched or handled inline; this skill does not change that classification.

## Binding the required inputs

The reference's `Inputs` section is the required list, and a run starts only once every required input is bound to this target.
Two bindings are the invoker's to supply, because the reference states them from its own source environment:

- Where the reference names an absolute path for a required input or a source model, resolve it to the document that actually governs this target rather than to a path copied out of the reference.
- `EVIDENCE_SCOPE` binds to real files in the target's own repository, which Firstmate may read but never write.

Never substitute an unverified local file for a named reference, and never reconstruct a missing document from memory.

## Outputs and where they go

The reference's `Outputs` section defines the deliverable shape, including the improved spec text, iteration ledger, readiness scorecard, claim hygiene table, hypothesis register and promotion receipt, any Probe Contracts, and the final stop reason.
All of it is knowledge, so route it to destinations Firstmate already owns:

- A dispatched run records the artifacts in that task's `data/<id>/report.md` under `AGENTS.md` section 7's scout contract.
- An inline run relays the readiness verdict and the material findings in chat, in `AGENTS.md` section 9's outcome-first style.

This skill never writes the target specification itself.
It produces the hardened text and hands it back, and applying that text stays governed by Firstmate's existing rules, including hard rule 1 for anything under a project.

## Authority boundary

One-shot readiness is a property of the specification and is never authorization to act on it.
A `target_reached` stop, a passing hard-gate set, or a high readiness score means the spec is implementable in one pass, not that implementation, a delivery mode, a merge, a release, or any provider or model run has been approved.
Firstmate's project resolution, ship and scout classification, delivery mode, yolo posture, captain approval, and no-mistakes path continue to decide whether anything is built and how it ships.
This skill grants no new approval power and weakens no destructive, irreversible, or security-sensitive boundary.

## Stop and report

Stop and report rather than proceeding when any of these holds:

- The vendored reference is missing, unreadable, or no longer matches its recorded hash.
- A document or tool the reference requires for this run is unavailable in this environment.
- Evidence is insufficient for a claim the protocol requires to be proven, so the protocol's own downgrade, blocked, or readiness-cap path applies.

Name the exact missing dependency or capped claim in the report.
Do not substitute an unverified copy, approximate a tool result, or invent a fact to clear a gate.

## Not an executable

This capability is a skill, not a program.
There is no `one-shot-spec` binary, script, or AXI tool in this repository, so never announce or attempt to run one.
Tools named inside the reference are external to Firstmate and fall under the stop-and-report rule above.
