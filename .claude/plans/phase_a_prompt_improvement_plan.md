# Phase A Prompt Improvement Plan

## Goal
Evolve the Phase A Aristotle prompt from the current v15 "PM ticket" style into a family of prompt versions that explicitly run a **research-team scientific-method loop** with built-in self-critique / adversarial review, while keeping v15 as a stable baseline for A/B comparison.

## Current State
- `knowledge_extractor.py` hardcodes `phase_a_version = "v15"`.
- `pi_agent_client.py` contains `_build_v8` through `_build_v15` depth requirements and a v15-specific Phase A prompt.
- `cycle_analytics.py` already records `phase_a_prompt_version`, so we can compare versions.
- Quality metrics (sorry count, triviality, depth, novelty, future-directions quality) are tracked per cycle.

## Proposed Changes

### 1. Create v16: Research-Team Scientific-Method Prompt
Add `_build_phase_a_v16_prompt()` in `pi_agent_client.py` with the following structure:

- **System framing:** Aristotle leads a research team (Hypothesizer, Experimenter, Analyst, Critic, Synthesist).
- **Scientific method loop:**
  1. Hypothesize 5–7 falsifiable conjectures (at least 2 surprising/counter-intuitive).
  2. Experiment: prove or disprove each in Lean 4, prioritizing the most surprising.
  3. Analyze: record what survived, what failed, and **why** failures failed.
  4. Critique: a dedicated adversarial review step that tries to break each proof / find counterexamples.
  5. Synthesize: assemble the verified results into clean `.lean` files and a `FUTURE_DIRECTIONS.md` derived from the surviving hypotheses and failure analysis.
- **Deliverables:**
  - `.lean` files (2–4) with complete main theorems (0 sorries).
  - Inline lab-notebook comment blocks (`-- !-- Lab Notes -- !--`) per file.
  - `FUTURE_DIRECTIONS.md` with 3–5 bold, testable conjectures tied to the cycle’s findings.
- **Anti-trivial guardrails:**
  - Ban `True`, `Inhabited X`, definition-only theorems, `native_decide`, and `simp`/`norm_num`/`decide` as the entire proof.
  - Require at least one theorem to use an insight-bearing tactic (`induction`, `by_contra`, `field_simp`, `ring_nf`, `omega`, `linarith`, `rcases`, custom lemmas).
- **Catalog synthesis:** explicit instructions to read attached catalog files, cite theorems by name, and extend rather than reprove.
- **Failure mode:** if a conjecture is false, produce a disproof or counterexample and suggest a modified conjecture.
- **Self-critique step:** before final output, Aristotle must run an internal review:
  - Are any theorems trivial?
  - Are there remaining sorries on main results?
  - Do the results genuinely extend the catalog?
  - Are future directions falsifiable and specific?

### 2. Add Prompt Version Selection / A/B Registry
Introduce a lightweight prompt registry so we can run multiple versions side-by-side:

- Add `PROMPT_REGISTRY` dict in `pi_agent_client.py` mapping versions to builder functions.
- Add `select_phase_a_prompt_version(...)` helper that picks a version according to configured weights.
- Add support in `knowledge_extractor.py` to override the hardcoded v15 default:
  - Read weights from config (`config.yaml` or env var `AETHER_PHASE_A_PROMPT_WEIGHTS`).
  - Example: `v15: 0.5, v16: 0.3, v17: 0.2`.
- Default config if none provided: keep v15 at 100% until the user opts into experiments.

### 3. Spawn a Family of Variants (v16a, v16b, v17, v18)
To enable rapid A/B testing, create small, focused variants:

- **v16a:** v16 with strong adversarial/self-critique emphasis.
- **v16b:** v16 with stronger catalog-synthesis / bridge-building emphasis.
- **v17:** v16 but shorter / more concise (test prompt-length hypothesis).
- **v18:** v16 with mode-specific templates (prove vs sorry_fill vs discover get distinct team briefs).

Each variant gets its own builder method and is registered in the A/B registry.

### 4. Wire Version Selection into the Pipeline
- Modify `knowledge_extractor.py` around line 757 so it calls `self.pi_agent.select_phase_a_prompt_version(weights)` instead of hardcoding `"v15"`.
- Ensure the chosen version is written to `job.phase_a_prompt_version` (already exists) and saved in `inflight_jobs.json`.
- No changes needed to `cycle_analytics.py`; it already records the version.

### 5. Add Quality Gate / Lint for New Versions
Extend the existing lint logic in `knowledge_extractor.py` (lines ~2253-2300):

- Add v16-specific checks:
  - Lab Notes marker present.
  - FUTURE_DIRECTIONS.md non-empty and contains at least one falsifiable marker (e.g., "Conjecture", "Hypothesis", "Test:").
  - At least one theorem uses an insight-bearing tactic (regex check).
- Keep these checks lightweight; they do not block integration but feed the quality score.

### 6. Dashboard / Analytics
- Ensure `_print_prompt_version_stats()` in `aether_tick.py` reports v16+ variants alongside v8-v15.
- Add a one-line summary per version: `n`, avg Q, world-class rate, avg sorry count, avg theorem count.

### 7. Testing Plan
- Add unit tests in `Aether/tests/`:
  - `test_prompt_v16.py`: verify the v16 prompt contains all required sections (team framing, self-critique, anti-trivial guards, future-directions rules).
  - `test_prompt_registry.py`: verify version selection respects weights.
- Run a dry-run cycle locally with `python3 aether_tick.py --dry-run --max-inflight 1` to inspect generated prompts.

## Files to Modify
1. `Aether/pi_agent_client.py` — add v16 builders, registry, selection helper.
2. `Aether/knowledge_extractor.py` — use registry instead of hardcoded v15.
3. `Aether/config.yaml` (or create `Aether/prompt_weights.yaml`) — default A/B weights.
4. `Aether/aether_tick.py` — update version stats printout.
5. `Aether/tests/test_prompt_v16.py` — new tests.

## Rollout Steps
1. Implement v16 and registry; default weights keep v15 at 100%.
2. After review, enable a 20% v16 experiment (`v15: 0.8, v16: 0.2`).
3. Let run for ~50 cycles, compare metrics per version.
4. If v16 wins, promote it; spawn v16a/b and iterate.
5. If v16 loses, analyze which variant failed and pivot.

## Risks & Mitigations
- **Risk:** New prompt is longer and may exceed Pollinations input budget.
  - **Mitigation:** Keep v17 as a concise variant; truncate examples if needed.
- **Risk:** Self-critique section is ignored by Aristotle.
  - **Mitigation:** Place it immediately before the output-format reminder and require a checklist response.
- **Risk:** A/B weights make it hard to interpret per-cycle quality.
  - **Mitigation:** `cycle_analytics.py` already records version; stats are grouped by version.
