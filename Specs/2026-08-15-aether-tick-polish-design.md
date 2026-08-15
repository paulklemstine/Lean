# Aether Tick Polish — Design

**Date:** 2026-08-15
**Status:** Approved
**Scope:** Two tightly-scoped changes to the Aether tick. No behavior change to the research pipeline.

## 1. Remove the unused Lean toolchain from CI

### What changes

`.github/workflows/aether-research.yml` — delete three steps:

1. **"Cache elan toolchain"** (lines 47-51)
2. **"Cache Mathlib build artifacts"** (lines 53-61)
3. **"Install elan and fetch Lean cache"** (lines 63-71, the `lake exe cache get`)

Everything else stays: checkout (`fetch-depth: 0`), set up Python, pip install, workspace dirs, git hooks, "Run Aether tick". Env vars, permissions, `concurrency`, and the `17 * * * *` cron are untouched.

### Why it is safe (verified, not assumed)

- The tick **never compiles Lean**. Theorem/sorry counts are regex over source text (`knowledge_extractor.py:2456` `theorem_pattern`). No `lake build` appears anywhere in the tick's call graph (`aether_tick.py` → `knowledge_extractor.py`). `integrator.py`/`engine.py`/`cycle_master.py` (which can build) are not referenced by the tick.
- The Aristotle SDK **strips `.olean`/`.ilean`/build artifacts on upload regardless** (`aristotlelib/local_file_utils.py` `LEAN_PROJECT_IGNORED_FILE_PATTERNS`), so even a locally-built cache never reaches the server.
- `_build_project_dir` (`knowledge_extractor.py:1303`) **creates empty `.lake` skeletons from scratch** (lines 1377-1378) for each upload; it never copies `Catalog/.lake`. The CI Mathlib cache was therefore never read by the upload path.

### Effect

Run wall-clock drops from ~10 min to ~3 min (measured: tick runs were 8-11 min, of which the elan+`lake exe cache get` setup was the dominant cost). The 40-min `timeout-minutes` stays; shorter runs reduce contention with the ceiling. Hourly cadence is unaffected.

### History context (why the toolchain was added)

Commit `cf1e3e6ccb` (2026-07-16) added `lake exe cache get` intending to "speed up Aristotle jobs" by shipping Mathlib build cache, and flipped the `knowledge_extractor.py` comment from "Strip .lake build-cache dirs" to "Retain .lake build-cache dirs." That intent was never realized: the SDK strips oleans on upload, and the workspace `.lake` dirs are empty skeletons created from scratch. This change removes the wasted setup.

## 2. Fix the misleading `.lake` comment

`knowledge_extractor.py:1668-1672` currently says the retained `.lake` skeleton "silences SDK warnings and drastically speeds up remote compilation times."

That comment is **wrong about what happens**: the dirs are empty; nothing compiled is ever sent; the only true statement is the SDK-warning-silencing effect.

Replace with an accurate comment stating:
- `.lake` skeleton dirs are created empty to satisfy the SDK's expected project layout (silencing warnings)
- Compiled artifacts (`.olean`, `.ilean`, build caches) are stripped by the SDK on upload and are never sent
- Therefore no Lean toolchain or build step is needed in the tick or CI

This prevents a future maintainer from re-adding toolchain caching on the mistaken premise that build artifacts reach Aristotle.

## Explicitly out of scope

- **Notification on tick failure** — deliberately declined (user monitors manually). The existing `AETHER_ALERT_WEBHOOK` commit/push alerting stays as-is.
- **Starvation alert** ("no packages for N ticks") — not added.
- **Stall/zombie cap tuning** — audited healthy (`poll_all`: 24h hard cap, 30-min preparing timeout, 90-min warn, 4h no-progress zombie cap); no change.
- **Phase B gate** — audited healthy (0.55 ceiling; 1016/1324 jobs received Phase B at quality 0.55–0.88 in recent records); no change.
- **`Catalog/.lake` (6.7 GB local dead weight)** — already deleted manually; gitignored, so no repo impact.

## Verification

- After the workflow edit: workflow YAML parses (e.g. `actionlint` if available, or a dry-run read by the scheduler); tick run duration should drop to ~3 min on the next schedule; tick still integrates/dispatches/pushes as before.
- After the comment edit: no functional change; run the Aether test suite (`pytest Aether/tests -v`) to confirm nothing regressed.
