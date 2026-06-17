# ADR-001: Aether Quality Upgrade Strategy

## Status

Accepted.

## Context

Aether produces mathematical research packages through a two-phase pipeline: Aristotle (Phase A) generates Lean 4 proofs and future directions, then a packaging phase (Phase B) produces human-readable articles, demos, and visualizations. Quality complaints center on shallow, trivial, or rediscovered results rather than on Lean compilation failures.

## Decision

Quality will be defined primarily as **depth + impact**. Correctness (Lean files compile with no sorries on Aristotle's end) is treated as a hard floor, not a differentiating goal.

## Consequences

- Engineering budget shifts from "make proofs compile" to "choose better targets and discovery strategies."
- New mechanisms are needed to guide Aristotle's research focus without micromanaging it.
- A 50/50 split between famous-problem subtasks and cross-domain bridge research is tentatively agreed as the target menu from which Aristotle can select.

## Locked-in Decisions

- **Primary quality goal:** depth + impact, with correctness as a hard floor.
- **Selection principle:** Aristotle chooses the exact target each cycle, within a 50/50 menu split between (1) famous-problem subtasks and (2) cross-domain bridge research.
- **Primary signal source:** internal abduction loop — Aristotle generates conjectures and pursues its own research threads.
- **Secondary signal source:** external signal feed (arXiv, OEIS, LMFDB, open-problem trackers) to prevent drift.
- **Tertiary signal source:** curated open-problem list as a gravity well for named hard targets.
- **Thread policy:** Aristotle maintains multi-cycle research threads with shared context. No explicit cycle budget; termination is decided by quality gates.
- **Progress definition:** A cycle is considered progress if it produces a knowledge delta (new definition, lemma, or connection) relative to the thread state.
- **Stagnation limit:** A thread is auto-killed after 4 consecutive cycles without knowledge delta.
- **Novelty failure:** Auto-kill if the result is a known theorem, trivial restatement, or wrapper.
- **Counterexample found:** Treated as a positive result; thread closes cleanly with the counterexample published.
- **Primary quality measure:** Triviality / depth critics — multiple LLM critics score each result.
- **Secondary quality measure:** Thread promise scoring — a critic reads the full thread and scores whether the cumulative output has trajectory.
- **Human backstop:** None. The quality system must be fully automatic.
- **Per-result critic architecture:** Specialized critics for novelty, depth, correctness, and presentation.
- **Critic scope:** Phase A output only.
- **Thread-level critic:** Yes — a distinct critic reviews the cumulative trajectory of a research thread.
- **Computational experimentation:** Recommended before formal proof attempts; Aristotle must justify skipping it.
- **Rollout strategy:** Big-bang implementation; throughput must not be reduced during rollout.

## Open Questions

1. How is "depth" measured automatically?
2. How is "impact" measured automatically?
3. What quality gates terminate a thread?
4. What ratio is enforced and how strictly?
5. What existing pipeline components must change?
