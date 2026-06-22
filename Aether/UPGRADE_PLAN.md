# Aether Upgrade Plan — implementation spec for agy

## Context (READ FIRST)
- This is a **live production daemon** (`aether_tick.py --loop`, runs every 900s, auto-commits+pushes to `origin/master`).
- You are working in an **isolated git worktree** (branch `worktree-aether-upgrades`). The live daemon runs from the main checkout — your edits here do NOT affect it until merged. Keep it that way.
- **NEVER touch `.aether_workspace/`** (runtime data: sqlite, logs, jsonl, project dirs). Never touch `theorems.sqlite`, `inflight_jobs.json`, `future_directions.json`, `research_memory.jsonl`, any `*.log`, or any runtime state. Only edit source files.
- **NEVER delete or weaken existing tests.** You may add new test files under `Aether/tests/` for new behavior.
- Make **surgical, minimal** changes. Preserve existing behavior except where this spec says to change it. Match surrounding style (no new deps; stdlib + what's already imported).
- North star: world-class novel math, maximum autonomy, 100% AI-directed. Objective metric: **average concept_quality** of integrated jobs.

## File map (verified symbols)
- `aether_tick.py` (1801 lines): `async def tick` (394) → `async def _tick_impl` (409-~1175, the monolithic loop). Phase A/B logic ~464-720. Quality-retry at 525-535. Phase B dispatch threshold at 564-604. `def rebuild_commit_push` (1328-~1605, git commit/push; push-fail print at ~1576, commit-fail at ~1504). `def main` (1721), loop at 1770. `_print_prompt_version_stats` (138).
- `pi_agent_client.py`: `class PiAgentClient` (271). `def _call_ollama` (388) = 3-tier fallback chain (Tier1 Pollinations @405-406 → Tier2 Ollama Cloud @413-419 → Tier3 OpenRouter @427 → pollen-reset retry loop @443-459). `def _call_pollinations` (463, raises/returns 402). `self.pollen_gate` = `PollinationsPollenGate` (from `pollinations_pollen.py`), state persisted to `.aether_workspace/pollinations_pollen_state.json` (372). `def select_phase_a_prompt_version(weights)` (72) and `select_phase_b_prompt_version` (82) via `_select_version_from_weights` (47) using `DEFAULT_PHASE_A_PROMPT_WEIGHTS` / `DEFAULT_PHASE_B_PROMPT_WEIGHTS`. Prompt-version prompt body selected at ~2295-2305.
- `cycle_analytics.py`: `CycleAnalytics` with `get_prompt_version_stats()` (262) → per-version `{n, avg_Q, world_class_rate, avg_dur}`. `CycleRecord.prompt_version` / `phase_a_prompt_version` / `phase_b_prompt_version`.
- `knowledge_extractor.py`: `JobResult.quality_score` (89), `quality_assessment` (90), `self.max_retries` (235, default 2), `def _adaptive_phase_b_threshold()` (309). `KnowledgeExtractor` is the orchestrator extractor.
- `pollinations_pollen.py`: `PollinationsPollenConfig`, `PollinationsPollenGate` — pollen accounting + 402 handling.
- `cycle_master.py`: `selected_prompt_version = cycle_variants[cycle_n % len(cycle_variants)]` (537) — round-robin prompt selection in some paths.

## FEATURES TO IMPLEMENT

### 0.1 Pollinations circuit breaker (file: pi_agent_client.py)
**Problem:** 132 `Pollen depleted (402)` lines per 1000 in daemon.log; every call pays a Pollinations round-trip before falling back to Ollama.
**Change:** In `_call_ollama`, before Tier 1 (`_call_pollinations` at 405), check a circuit-breaker. Track consecutive 402s; after **N=5** consecutive 402s, enter OPEN state for a **20-minute cooldown** — skip Tier 1 entirely and go straight to Tier 2 (Ollama Cloud). After cooldown expires, go to HALF-OPEN: allow ONE Pollinations probe; on success reset to CLOSED + zero counter; on 402 re-enter OPEN for 20 min.
- Persist breaker state (consecutive_402, state, opened_at timestamp) in the existing `pollinations_pollen_state.json` (add new keys, do not remove existing ones). Use the same file `self.pollen_state_path`/the path already used at 372.
- Detect 402 from `_call_pollinations` result (it returns/raises with "402"/"Pollen depleted" — match the existing detection the code already uses around 413-419).
- Log: `[Pi-Agent] Circuit OPEN (consecutive 402s={n}) — skipping Pollinations for {min}min, going to Ollama Cloud` and `[Pi-Agent] Circuit HALF-OPEN — probing Pollinations` and `[Pi-Agent] Circuit CLOSED — Pollinations recovered`.
- When `use_ollama=True` (dev mode, line 401), bypass the breaker as today.
- Do NOT change Tier 2/3 behavior. Do NOT remove the pollen-reset retry loop (443-459) — keep it for CLOSED-state recovery.
**Acceptance:** With breaker, a run against a depleted Pollinations should log `Circuit OPEN` once and then stop emitting 402 round-trips for 20 min. Existing tests still pass.

### 0.2 Extract Pi-Agent rationales to JSONL (files: pi_agent_client.py, catalog_scorer.py, wherever the multi-line JSON rationale is printed)
**Problem:** daemon.log is cluttered with multi-line JSON `rationale` blocks from Pi-Agent quality evaluation.
**Change:** Find every place a Pi-Agent quality-eval `rationale` (the big JSON dict) is printed to stdout/daemon.log. Redirect the full rationale dict to a dedicated append-only JSONL file `.aether_workspace/pi_agent_evals.jsonl` (one JSON object per line: `{ts, job_id, score, grade, rationale}`), and replace the stdout/log line with a ONE-LINE summary: `[Pi-Agent] eval job={id} score={q:.3f} grade={grade}` (no JSON blob).
- If you cannot find a single chokepoint, wrap with a small helper `def _log_pi_agent_eval(self, job_id, score, grade, rationale):` that appends JSONL + prints the one-liner, and route callers through it.
- Do NOT lose the rationale data — it must go to the JSONL.
**Acceptance:** `grep -c rationale aether_daemon.log` (future) stays near 0; `pi_agent_evals.jsonl` gains one line per eval. Existing tests pass.

### 1.1 Decouple loop into Poller / Evaluator / Publisher workers (file: aether_tick.py) — THE BIG REFACTOR
**Problem:** `_tick_impl` (409-1175) is a monolithic async loop: slow LLM quality-evals and sync git-push block discovery. With long-running jobs (user accepts 6h+ stalls), slots stay full and polling/dispatch freezes during eval/publish.
**Change:** Refactor `_tick_impl` so polling/dispatch, evaluation, and publishing run as **cooperatively-scheduled async tasks** (use `asyncio` — already async) rather than one sequential pass. Concretely:
- Split into three async coroutines sharing the existing in-memory structures (do NOT introduce a new DB queue — keep using `inflight_jobs.json` + the existing `KnowledgeExtractor` state; the goal is concurrency, not a new persistence layer):
  - **Poller:** Aristotle status poll + integrate completed + dispatch new (the dispatch/poll parts of `_tick_impl`).
  - **Evaluator:** the Pi-Agent quality assessment + retry-decision (the `should_retry` / quality_check path ~525-535 and quality scoring).
  - **Publisher:** `rebuild_commit_push` (1328) + Phase B trigger, run without blocking the Poller.
- Run them with `asyncio.gather` / per-task `asyncio.sleep` loops inside `_tick_impl`, OR an `asyncio.Queue` if a clean seam exists. Preserve the **Phase A/B state machine EXACTLY** (the `already_dispatched_b` guard at 464-473, `is_phase_b_completion` at 481-525, phase_a_lean_backup at 497-500) — the code comments warn of a past "infinite Phase B loop" bug; do not reintroduce it. Keep the lock file `.aether_workspace/aether_tick.lock` semantics (single tick concurrency).
- **Constraint:** If a clean async split is too risky given the state-machine subtlety, the MINIMUM acceptable change is: move `rebuild_commit_push` (publish) to a **fire-and-forget `asyncio.create_task`** so git push never blocks the poll/dispatch loop, AND make the quality-eval step `await`-friendly (wrap any blocking LLM eval in `asyncio.to_thread` so it doesn't block the loop). That is the floor; the 3-worker split is the ceiling. Aim for the ceiling but ship the floor if the ceiling risks the state machine.
**Acceptance:** `python -c "import aether_tick"` imports clean; `py_compile` passes; `test_two_phase.py`, `test_retry_loop.py`, `test_race_conditions.py` still pass; a dry-run `--max-inflight 1` tick with mocked extractor advances without deadlock (see new test 1.1-verify below). NEVER break the Phase A/B guard.

### 2.1 Decompose-and-retry on 3× verification fail (files: aether_tick.py, pi_agent_client.py, knowledge_extractor.py as needed)
**Problem:** After max retries a direction is given up on. User wants: keep the idea alive by decomposing.
**Change:** Where a direction reaches `retry_count >= max_retries` and is about to be archived/abandoned, instead dispatch an LLM call (via `PiAgentClient`) to **split the direction into 2-3 smaller sub-lemmas**, and enqueue those as new future directions with parent lineage. Track lineage: add `parent_direction` (and `decomposed_from_job`) fields to the new direction entries in `future_directions.json`. Cap decomposition depth at **2** (don't decompose decomposed directions forever) — track via a `decomposition_depth` field.
- Reuse existing direction-creation helpers if present; if not, add a small `async def decompose_direction(self, concept, job) -> List[direction]` on `KnowledgeExtractor` or `PiAgentClient`.
- On decomposition failure (LLM error), fall back to the current archive behavior — do not hang the loop.
**Acceptance:** New unit test feeds a 3x-failed job and asserts 2-3 child directions are created with `parent_direction` set and `decomposition_depth=1`. Existing tests pass.

### 2.2 LLM-driven novelty replenishment (files: aether_tick.py / knowledge_extractor.py / pi_agent_client.py)
**Problem:** Novelty pool refilled from a static seed list. User wants LLM-generated wildcard directions seeded by recent breakthroughs.
**Change:** When the novelty pool drops below **5** (the `novelty_slots` reserve area; find where directions are seeded/refilled in `_tick_impl` — search for where `novelty_slots` is consumed and where future_directions are generated), call `PiAgentClient` to generate **wildcard research directions** seeded by the most recent `world_class`/high-quality integrated jobs (read from `cycle_analytics.json` or `research_journal.json`). Dedup new directions against `research_memory.jsonl` / existing `future_directions.json` (no exact-duplicate titles). Tag generated directions `source="llm_novelty"`.
- Keep a fallback to the static seed list if the LLM call fails (never block the loop on this).
**Acceptance:** New unit test mocks the LLM and, with pool forced <5, asserts ≥1 `source="llm_novelty"` direction is generated and is non-duplicate. Existing tests pass.

### 2.3 Multi-armed bandit for prompt A/B (files: pi_agent_client.py, cycle_analytics.py)
**Problem:** Prompt selection is round-robin / static-weighted (`select_phase_a_prompt_version` + `cycle_master` 537). User wants autonomous routing to winners.
**Change:** Replace the static-weight selection in `select_phase_a_prompt_version` with **Thompson sampling** over prompt variants, reward = `concept_quality` (avg_Q from `cycle_analytics.get_prompt_version_stats()`).
- **Guardrail (non-negotiable):** maintain a per-arm sample count; if any arm has **n < 30**, force exploration (don't exploit) until all active arms reach n≥30. This is because the full-run v16-vs-v19b gap was thin (0.533 vs 0.508); only the n=2 window looked decisive.
- Beta(α,β) per arm where reward is quality in [0,1]; α = 1 + sum(quality), β = 1 + sum(1-quality). Sample each arm, pick argmax. Persist α/β (or sufficient stats) to `.aether_workspace/prompt_bandit_state.json`.
- Provide a way to read stats: log `[Bandit] arm={version} n={n} avg_Q={q:.3f} sampled={chosen}` on each selection (one line, no JSON blob).
- Keep `select_phase_b_prompt_version` as-is (only one Phase B prompt; user didn't ask to bandit Phase B).
**Acceptance:** New unit test: with mocked stats where arm A has high α (n≥30, high avg_Q) and arm B low, asserts A is picked >80% over 200 trials AND that with all arms n<30 the distribution is ~uniform. Existing tests pass.

### 2.4 Early-accept incremental + Phase B gate (file: aether_tick.py, knowledge_extractor.py)
**Problem:** Jobs scoring 0.5-0.6 auto-retry burning compute; Phase B runs at a floating adaptive threshold.
**Change (two parts):**
1. **Early-accept:** At the quality-retry decision (~525-535), if `quality_score >= 0.6` AND `quality_assessment.quality == "partial"`, **do NOT retry** — accept and integrate as `incremental` (set a marker, e.g. `quality_assessment["accepted_as"] = "incremental"`). Only retry if score < 0.6 OR quality is worse than "partial". Keep the existing `should_retry` path for <0.6.
2. **Phase B gate:** Phase B dispatch (~564-566) currently fires when `phase_a_q >= phase_b_threshold` (adaptive). Change to fire only when `phase_a_q >= 0.7` (fixed floor). Make it configurable via `self.phase_b_min_score` (default 0.7) read from config `phase_b.min_score`. Keep `_adaptive_phase_b_threshold` for logging but the gate is `max(phase_b_min_score, ...)` — effectively Phase B only for score ≥ 0.7.
**Acceptance:** New unit test: a job with Q=0.55, quality=partial → integrated, `accepted_as="incremental"`, no retry dispatched. Q=0.65 → no Phase B dispatched. Q=0.75 → Phase B dispatched. Existing `test_two_phase.py` / `test_retry_loop.py` pass (adjust thresholds in those tests ONLY if they hardcode the old 0.5-threshold and would now be wrong — prefer adding new tests over editing old ones; if an old test asserts Phase B at 0.55, update that assertion to 0.75 and note it).

### 3.2 Git-push failure alert (file: aether_tick.py, `rebuild_commit_push` ~1504/1576)
**Problem:** commit/push failures print a line but can fail silently otherwise.
**Change:** In `rebuild_commit_push`, when `git commit` (1504) or `git push` (1576) returns non-zero, in addition to the existing print, emit a prominent structured alert line: `[ALERT] git_publish_failed step={commit|push} rc={rc} detail={short_stderr}` to stdout (so it lands in daemon.log). If env var `AETHER_ALERT_WEBHOOK` is set (URL), POST a small JSON `{severity, step, rc, detail, ts}` to it (best-effort, `requests` if already imported else `urllib.request`, short timeout=5s, never raise on failure). Do not change the return semantics of `rebuild_commit_push`.
**Acceptance:** New unit test monkeypatches `subprocess.run` to make push exit non-zero, calls `rebuild_commit_push`, asserts the `[ALERT] git_publish_failed step=push` line appears. Existing tests pass.

## Verification YOU (agy) must run before reporting done
1. `python -m py_compile aether_tick.py pi_agent_client.py knowledge_extractor.py cycle_analytics.py pollinations_pollen.py` — must pass.
2. `cd Aether && python -m pytest tests/ -q` AND `python -m pytest test_two_phase.py test_retry_loop.py test_race_conditions.py test_prompt_v16.py test_prompt_v19.py -q` (run from Aether/) — must pass (or report exactly which fail and why).
3. `python test_syntax.py` — must pass.
4. For each feature, run its NEW acceptance unit test (you write these under `Aether/tests/test_upgrade_<feature>.py`).
5. Do NOT run the live `--loop` daemon. Do NOT touch `.aether_workspace/`.

## Digest (your final reply MUST end with this fenced block)
```text
===DIGEST===
files_changed: <list>
features_implemented: <which of 0.1,0.2,1.1,2.1,2.2,2.3,2.4,3.2 — done|partial|skipped with one-line reason>
verification: py_compile=pass|fail; pytest=<pass/fail counts>; test_syntax=pass|fail
new_tests_added: <list>
acceptance_results: <per-feature pass/fail>
could_not_do: <anything you couldn't safely do and why>
context_for_next_step: <1 paragraph>
```
Put bulky detail in files, not in your prose. Do not dump code in your reply.