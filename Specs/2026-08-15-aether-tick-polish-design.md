# Aether Tick Polish — Design

**Date:** 2026-08-15
**Status:** Approved (executed; updated 2026-08-16 with measured results)
**Scope:** Three tightly-scoped changes to the Aether tick CI path. No behavior change to the research pipeline.

## Summary

Three changes cut the hourly CI tick runtime from **~9-10 min to ~2 min** (measured 1:51):

1. Remove the unused Lean toolchain from CI
2. Fix a misleading `.lake` build-cache comment
3. Shallow checkout (`fetch-depth: 1`) to stop re-downloading 6 GB of pack history every run

Changes 1 and 2 were designed up front; change 3 was discovered by measuring the real bottleneck after 1 and 2 landed (the toolchain was only ~1 min of the ~9; full-history checkout was ~6.5 min).

## 1. Remove the unused Lean toolchain from CI

### What changes

`.github/workflows/aether-research.yml` — delete three steps:

1. **"Cache elan toolchain"** (lines 47-51)
2. **"Cache Mathlib build artifacts"** (lines 53-61)
3. **"Install elan and fetch Lean cache"** (lines 63-71, the `lake exe cache get`)

Everything else stays: checkout, set up Python, pip install, workspace dirs, git hooks, "Run Aether tick". Env vars, permissions, `concurrency`, and the `17 * * * *` cron are untouched.

### Why it is safe (verified, not assumed)

- The tick **never compiles Lean**. Theorem/sorry counts are regex over source text (`knowledge_extractor.py:2456` `theorem_pattern`). No `lake build` appears anywhere in the tick's call graph (`aether_tick.py` → `knowledge_extractor.py`). `integrator.py`/`engine.py`/`cycle_master.py` (which can build) are not referenced by the tick.
- The Aristotle SDK **strips `.olean`/`.ilean`/build artifacts on upload regardless** (`aristotlelib/local_file_utils.py` `LEAN_PROJECT_IGNORED_FILE_PATTERNS`), so even a locally-built cache never reaches the server.
- `_build_project_dir` (`knowledge_extractor.py:1303`) **creates empty `.lake` skeletons from scratch** (lines 1377-1378) for each upload; it never copies `Catalog/.lake`. The CI Mathlib cache was therefore never read by the upload path.

### Effect (measured)

Toolchain removal alone: 9:15 → 8:13 (the elan/`lake exe cache get` steps were only ~1 min — smaller than the original estimate, because the cache steps hit warm caches).

### History context (why the toolchain was added)

Commit `cf1e3e6ccb` (2026-07-16) added `lake exe cache get` intending to "speed up Aristotle jobs" by shipping Mathlib build cache, and flipped the `knowledge_extractor.py` comment from "Strip .lake build-cache dirs" to "Retain .lake build-cache dirs." That intent was never realized: the SDK strips oleans on upload, and the workspace `.lake` dirs are empty skeletons created from scratch. This change removes the wasted setup.

## 2. Fix the misleading `.lake` comment

`knowledge_extractor.py:1668-1672` previously said the retained `.lake` skeleton "silences SDK warnings and drastically speeds up remote compilation times."

That comment was **wrong about what happens**: the dirs are empty; nothing compiled is ever sent; the only true statement is the SDK-warning-silencing effect.

Replaced with an accurate comment stating:
- `.lake` skeleton dirs are created empty to satisfy the SDK's expected project layout (silencing warnings)
- Compiled artifacts (`.olean`, `.ilean`, build caches) are stripped by the SDK on upload and are never sent
- Therefore no Lean toolchain or build step is needed in the tick or CI

This prevents a future maintainer from re-adding toolchain caching on the mistaken premise that build artifacts reach Aristotle.

## 3. Shallow checkout (`fetch-depth: 1`)

### Why (measured)

The full-history checkout pulled **5.2 GB of pack data / 13,390 commits** every run, including 100 MB+ historical blobs (`CarmichaelProof.lean` was 103 MB before being slimmed to 6 KB; an 87 MB PDF). This cost **~6.5 min** per run — the actual dominant cost, discovered only after changes 1-2 landed.

### What changes

`.github/workflows/aether-research.yml` — `actions/checkout` step: `fetch-depth: 0` → `fetch-depth: 1`.

### Why it is safe (verified in trial run 31917618749)

- The tick's in-run git operations (`aether_tick.py:2119-2163`) are `git fetch origin master` → `git merge origin/master` → `git push origin master`. The runtime `git fetch` pulls whatever the remote moved to during the run; the tick's own shallow tip is the merge base, so the merge works. Push needs no history.
- `update-catalog-branch.sh` (pre-commit hook, `Aether/.aether_workspace/`) uses `git archive`, `git commit-tree`, and `git fetch origin catalog-lean` — none require full history.
- post-commit hook force-with-lease push of `catalog-lean` only needs the remote-tracking ref, which it fetches itself.
- No `rev-list --all`, `filter-branch`, `rebase`, or full-history scan anywhere in the tick or hooks.

### Effect (measured, trial run 31917618749)

| Phase | Full history (`fetch-depth: 0`) | Shallow (`fetch-depth: 1`) |
|---|---|---|
| Checkout | ~6.5 min | **23s** |
| Set up Python + pip | ~7s | ~7s |
| Run Aether tick | ~81s | ~65s |
| **Total** | **8:13** | **1:51** |

Log confirmed `[Tick] Changes committed and pushed to origin/master` — merge + push healthy on the shallow clone. No "unrelated histories", no conflict. The hourly cron run (2026-08-16T01:56Z) also succeeded under the new config.

## Explicitly out of scope

- **Notification on tick failure** — deliberately declined (user monitors manually). The existing `AETHER_ALERT_WEBHOOK` commit/push alerting stays as-is.
- **Starvation alert** ("no packages for N ticks") — not added.
- **Stall/zombie cap tuning** — audited healthy (`poll_all`: 24h hard cap, 30-min preparing timeout, 90-min warn, 4h no-progress zombie cap); no change.
- **Phase B gate** — audited healthy (0.55 ceiling; 1016/1324 jobs received Phase B at quality 0.55–0.88 in recent records); no change.
- **`Catalog/.lake` (6.7 GB local dead weight)** — deleted manually; gitignored, so no repo impact.

## Verification

All changes executed and verified in CI:
- Workflow YAML parses; tick run duration measured 1:51 (was ~9-10 min).
- Tick still integrates/dispatches/pushes as before (log: "Changes committed and pushed to origin/master").
- Aether test suite: **378 passed, 1 skipped** — no regression.
- Next hourly cron run (2026-08-16T01:56Z) succeeded under the new config.
