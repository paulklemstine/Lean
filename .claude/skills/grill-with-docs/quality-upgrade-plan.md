# Aether Quality Upgrade Plan

Generated from `/grilling` session on 2026-06-17.

## Summary

Aristotle will be rebuilt around **deep, impactful research threads**. Correctness remains the floor. The pipeline will guide Aristotle with a constrained menu (50/50 famous-problem subtasks vs. cross-domain bridges), measure every cycle with specialized critics, and allow Aristotle to pursue recursive abduction threads until they either produce genuine knowledge deltas or hit automatic termination gates.

## Design Decisions

| Decision | Value |
|---|---|
| Primary quality goal | Depth + impact |
| Correctness stance | Hard floor; no sorries, must compile |
| Selection principle | Aristotle decides exact target each cycle |
| Research menu | 50/50 split between famous-problem subtasks and cross-domain bridges |
| Primary signal source | Internal abduction loop (research threads) |
| Secondary signal source | External signal feed (arXiv, OEIS, LMFDB, trackers) |
| Tertiary signal source | Curated open-problem list |
| Thread depth | Multi-cycle threads with shared context |
| Thread budget | No explicit cycle cap |
| Progress definition | Knowledge delta (new definition, lemma, or connection) |
| Stagnation limit | Auto-kill after 4 cycles without knowledge delta |
| Novelty failure | Auto-kill known/wrapper/trivial results |
| Counterexample found | Positive result; close thread cleanly |
| Primary measure | Specialized triviality/depth critics |
| Secondary measure | Thread promise scoring |
| Human backstop | None — fully automatic |
| Per-result critic architecture | Specialized critics: novelty, depth, correctness, presentation |
| Thread critic | Yes, separate from per-cycle critics |
| Critic scope | Phase A output only |
| Computational experimentation | Recommended; Aristotle justifies skipping |
| Rollout | Big bang, no throughput reduction |

## Implementation Phases

Because the rollout is big-bang with no throughput reduction, every phase must be backward-compatible and additive. The pipeline continues running with old behavior until a feature flag flips.

### Phase 1: Thread Infrastructure

**Files to touch:** `Aether/research_memory.py`, `Aether/knowledge_extractor.py`, `Aether/aether_tick.py`

1. Add `ResearchThread` dataclass with:
   - `thread_id`, `root_direction_id`, `status` (`active`, `terminated`, `completed`)
   - `cycles: list[str]` of `exp_id`s
   - `thread_context: str` — accumulated hypotheses, failures, revised conjectures
   - `last_progress_cycle: int` — cycle index of last knowledge delta
   - `created_at`, `updated_at`

2. Extend `ResearchJob` with optional `thread_id` and `cycle_index`.

3. On integration, if a completed job belongs to a thread:
   - Append its artifacts to the thread state.
   - Compute knowledge delta by diffing against the previous cycle's extracted definitions/lemmas/theorems.
   - If delta exists, update `last_progress_cycle` and continue the thread.
   - If 4 consecutive cycles with no delta, mark thread `terminated` with reason `stagnation`.

4. When a thread terminates or completes, release its direction back to `available` only if the final result was a positive counterexample or a publishable theorem.

### Phase 2: Specialized Critics

**Files to touch:** `Aether/quality_evaluator.py`, `Aether/pi_agent_client.py`

1. Replace single adversarial judge with four specialized critics:
   - **NoveltyCritic** — scores overlap with Mathlib/catalog, arXiv exact-match search, wrapper detection.
   - **DepthCritic** — scores proof complexity, concept count, non-trivial tactic usage, whether the result connects distant ideas.
   - **CorrectnessCritic** — lake build, zero sorry, valid imports, type errors.
   - **PresentationCritic** — clarity of theorem statements, docstrings, naming.

2. Each critic returns a score 0–1 and a short rationale. Aggregate into a weighted score:
   - Correctness: gate (must be 1.0 or kill)
   - Novelty: 0.35
   - Depth: 0.45
   - Presentation: 0.20

3. Persist per-critic scores in the job result and use them for thread promise scoring.

### Phase 3: Thread Promise Critic

**Files to touch:** `Aether/quality_evaluator.py`, `Aether/knowledge_extractor.py`

1. Add `ThreadPromiseCritic` that receives:
   - Full thread context
   - Per-cycle critic scores
   - Extracted definitions/lemmas/theorems per cycle

2. It returns:
   - `promise_score` 0–1 (is this thread going somewhere?)
   - `recommendation`: `continue`, `pivot`, `terminate`
   - If `terminate`: the thread is killed regardless of knowledge delta.

3. Run this critic after every cycle of a thread with ≥2 cycles.

### Phase 4: Abduction Loop

**Files to touch:** `Aether/pi_agent_client.py`, `Aether/knowledge_extractor.py`

1. Extend Phase A prompt (`write_aristotle_prompt`) with thread context when `thread_id` is set:
   - Summarize previous cycles, hypotheses tested, failures, revised conjectures.
   - Ask Aristotle to either prove a target, produce a tighter sub-conjecture, find a counterexample, or pivot.

2. If a cycle produces a publishable theorem or counterexample, the thread closes.
   - Counterexample is packaged as a normal result with a `counterexample_of` field.

3. If a cycle produces partial progress, the next direction is auto-generated from the thread context rather than sampled from the global pool.

### Phase 5: 50/50 Menu Split

**Files to touch:** `Aether/aristotle_loop.py`, `Aether/research_memory.py`, `Aether/seed_directions.py`

1. Tag every `FutureDirection` with one of:
   - `famous_subtask` — decomposed from curated open problems
   - `cross_domain_bridge` — explicitly bridges two domains
   - `abduction_followup` — generated from an active thread (does not count toward the 50/50 split)

2. In `discover()`:
   - Compute current ratio of `famous_subtask` vs `cross_domain_bridge` selections over the last N=20 cycles.
   - If one side is below 40%, boost its weight until balance is restored.
   - Abduction follow-ups take priority when an active thread exists and the thread critic says `continue`.

3. Add a curated open-problem seed file (`Aether/open_problems_seed.py`) with decomposed subtasks:
   - Millennium Problems
   - Erdős conjectures
   - Long-standing domain-specific problems (e.g., Collatz, Goldbach, P vs NP formulations)
   - These are tagged `famous_subtask`.

### Phase 6: External Signal Feed

**Files to touch:** New module `Aether/external_signal.py`, `Aether/seed_directions.py`

1. Implement lightweight fetchers:
   - arXiv daily math feed abstracts (API)
   - OEIS search for sequences from recent package keywords
   - LMFDB keyword search for number theory/geometry directions

2. Convert interesting signals into `FutureDirection` objects tagged `cross_domain_bridge` or `famous_subtask` depending on content.

3. Run the feed as a background task during `aether_tick.py` startup, refreshing every 6 hours.

### Phase 7: Computational Experimentation Stage

**Files to touch:** `Aether/pi_agent_client.py`, `Catalog/Applications/Packages/js/pyodide-runner.js`

1. Extend Phase A prompt to ask Aristotle to produce a `ComputationalEvidence.md` section before formal proof:
   - Small-case calculations
   - Plots or tables
   - OEIS / LMFDB search results
   - If evidence contradicts the conjecture, pivot or close the thread.

2. Add a lightweight Python sandbox execution step in `knowledge_extractor.py` before dispatching to Phase A proof generation. This can reuse the existing Pyodide runner infrastructure.

3. If Aristotle skips the experiment stage, the CorrectnessCritic requires a written justification in the package.

### Phase 8: Big-Bang Integration

**Files to touch:** `Aether/aether_tick.py`, feature flags in `.aether_workspace/config.json`

1. Add feature flags:
   - `enable_threads`
   - `enable_specialized_critics`
   - `enable_thread_promise_critic`
   - `enable_abduction_loop`
   - `enable_5050_menu`
   - `enable_external_signal`
   - `enable_computational_stage`

2. Default all to `false`. On a single command, flip all to `true` for the big bang.

3. Because throughput must not drop, the new pipeline runs the same dispatch/integration cadence but with the new gates applied. Any job that fails a gate is salvaged or discarded as quickly as before.

## Milestones and Exit Criteria

| Milestone | Exit Criteria |
|---|---|
| Thread infra shipped | Active threads are created, cycles linked, stagnation kills correctly |
| Specialized critics shipped | Every Phase A job gets 4 critic scores; low-quality jobs are filtered |
| Thread promise critic shipped | Threads with no trajectory are terminated before wasting more slots |
| Abduction loop shipped | Threads auto-extend on knowledge delta |
| 50/50 menu shipped | Last 20 selections are within 35–65% for both categories |
| External signal shipped | At least 5 new directions per day from external feeds |
| Computational stage shipped | 80% of Phase A jobs include an experiment section |
| Big bang flipped | All flags enabled; throughput unchanged; quality dashboard shows improved scores |

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Big-bang breaks running pipeline | Every feature is flag-guarded; old path remains the default until explicit flip |
| Specialized critics are too expensive | Run cheap filters first; only invoke full panel on survivors |
| Threads waste slots on dead ends | Stagnation gate and thread promise critic terminate early |
| 50/50 split feels artificial | Treat it as a soft balancing force, not a hard quota; abduction follow-ups are exempt |
| No human backstop means bad results slip through | Add automatic sampling dashboard; you can still manually review and retroactively adjust critics |

## Files Created by This Session

- `.claude/skills/grill-with-docs/quality-upgrade-adr-001.md` — Architecture Decision Record
- `.claude/skills/grill-with-docs/glossary.md` — Terms and definitions
- `.claude/skills/grill-with-docs/quality-upgrade-plan.md` — This plan
