# Aether Tick Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the unused Lean toolchain from the Aether CI workflow (saving ~7 min/run) and correct a misleading comment in the Aristotle dispatch path.

**Architecture:** Two independent edits. (1) Delete the three Lean-toolchain steps (elan cache, Mathlib cache, install + `lake exe cache get`) from `.github/workflows/aether-research.yml`; nothing in the tick compiles Lean and the Aristotle SDK strips oleans on upload, so the toolchain was pure waste. (2) Replace the inaccurate "Retain .lake build-cache dirs... speeds up remote compilation" comment at `Aether/knowledge_extractor.py:1668-1672` with an accurate description (empty skeleton dirs silence SDK warnings; compiled artifacts are never sent).

**Tech Stack:** GitHub Actions YAML, Python 3.12 (Aether), no new dependencies.

## Global Constraints

- The `17 * * * *` cron, `concurrency` block, `permissions`, and `env` in `.github/workflows/aether-research.yml` are **untouched** — only the three toolchain steps are removed.
- `AETHER_MAX_INFLIGHT`, `GH_TOKEN`, `GITHUB_TOKEN` env vars and the `--max-inflight` invocation of `aether_tick.py` are unchanged.
- The comment fix at `knowledge_extractor.py:1668-1672` must make only the factual correction — no logic changes in `_dispatch_to_aristotle`.
- Do not edit `docs/` directly (rsync-synced from `Packages/` each tick); this plan touches only `.github/workflows/` and `Aether/`.
- Every `git commit` will auto-bump `Packages/version.js` + `docs/version.js` and force-push `catalog-lean` via installed hooks — this is expected, not an error.

---

### Task 1: Remove Lean toolchain steps from CI workflow

**Files:**
- Modify: `.github/workflows/aether-research.yml:47-71`

**Interfaces:**
- Consumes: nothing.
- Produces: a workflow with the "Set up Python", "Install dependencies", "Create workspace directories", "Configure Git and install hooks", and "Run Aether tick" steps back-to-back. Later tasks don't consume this; the effect is a shorter tick run (~3 min instead of ~10 min).

- [ ] **Step 1: Read the current workflow**

Run: `sed -n '30,90p' .github/workflows/aether-research.yml`
Expected: confirm the three steps to remove at lines 47-71 ("Cache elan toolchain", "Cache Mathlib build artifacts", "Install elan and fetch Lean cache").

- [ ] **Step 2: Delete the three toolchain steps**

In `.github/workflows/aether-research.yml`, delete the block from line 47 through line 71, inclusive (the blank line separating "Install dependencies" from "Create workspace directories" should be preserved so the remaining steps remain separated by single blank lines). The removed block is exactly:

```yaml
      - name: Cache elan toolchain
        uses: actions/cache@v4
        with:
          path: ~/.elan
          key: ${{ runner.os }}-elan-${{ hashFiles('Catalog/lean-toolchain') }}

      - name: Cache Mathlib build artifacts
        uses: actions/cache@v4
        with:
          path: |
            Catalog/.lake/build
            Catalog/.lake/packages
          key: ${{ runner.os }}-lake-${{ hashFiles('Catalog/lean-toolchain', 'Catalog/lake-manifest.json') }}
          restore-keys: |
            ${{ runner.os }}-lake-

      - name: Install elan and fetch Lean cache
        run: |
          if [ ! -d "$HOME/.elan/bin" ]; then
            curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y --default-toolchain none
          fi
          echo "$HOME/.elan/bin" >> $GITHUB_PATH
          export PATH="$HOME/.elan/bin:$PATH"
          cd Catalog
          lake exe cache get || true
```

- [ ] **Step 3: Verify the result**

Run: `sed -n '38,58p' .github/workflows/aether-research.yml`
Expected: steps now read "Install dependencies" → "Create workspace directories" → "Configure Git and install hooks" → "Run Aether tick", with the toolchain steps gone and no leftover blank-line runs (single blank lines only).

- [ ] **Step 4: Validate YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/aether-research.yml')); print('YAML OK')"`
Expected: prints `YAML OK`.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/aether-research.yml
git commit -m "ci(aether): remove unused Lean toolchain steps from tick workflow

The tick never compiles Lean (regex theorem counting) and the Aristotle SDK
strips .olean artifacts on upload, so elan + Mathlib cache setup was pure
waste. Cuts tick runtime ~10min to ~3min."
```

---

### Task 2: Fix misleading .lake comment in dispatch path

**Files:**
- Modify: `Aether/knowledge_extractor.py:1668-1672`

**Interfaces:**
- Consumes: nothing.
- Produces: an accurate comment above `Project.create_from_directory` in `_dispatch_to_aristotle`. No logic changes.

- [ ] **Step 1: Read the current comment**

Run: `sed -n '1668,1673p' Aether/knowledge_extractor.py`
Expected: the comment reads "Retain .lake build-cache dirs! The Aristotle SDK automatically strips massive source directories (like packages/mathlib), but keeping the lightweight skeleton structure (e.g., manifest, minimal packages, and local build oleans) silences SDK warnings and drastically speeds up remote compilation times."

- [ ] **Step 2: Replace the comment**

In `Aether/knowledge_extractor.py`, replace lines 1668-1672 (the five-line comment) with:

```python
        # Keep the .lake skeleton dirs (empty) to satisfy the SDK's expected
        # project layout and silence upload warnings. Compiled artifacts
        # (.olean/.ilean, build caches) are stripped by the SDK on upload and
        # are never sent, so no Lean toolchain or lake build is needed here.
```

- [ ] **Step 3: Run the Aether test suite**

Run: `cd Aether && python3 -m pytest tests -q 2>&1 | tail -5`
Expected: all tests pass (no behavior change; comment-only edit). If any tests fail, they were already failing before this change — re-run on `master` (`git stash && pytest tests -q` then `git stash pop`) to confirm, and report rather than "fixing" unrelated failures.

- [ ] **Step 4: Commit**

```bash
git add Aether/knowledge_extractor.py
git commit -m "docs(aether): correct misleading .lake build-cache comment

The retained .lake dirs are empty skeletons; the SDK strips .olean on upload,
so nothing compiled is ever sent. The old comment implied build artifacts
reach Aristotle, which led to the wasted CI toolchain setup now removed."
```

---

### Task 3: Verify the full change end-to-end

**Files:**
- Test: `.github/workflows/aether-research.yml` (already modified in Task 1)
- Test: `Aether/knowledge_extractor.py` (already modified in Task 2)

**Interfaces:**
- Consumes: Task 1 and Task 2 results.
- Produces: confirmation the two edits are coherent and pushed.

- [ ] **Step 1: Re-run YAML validation on the final file**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/aether-research.yml')); print('YAML OK')"`
Expected: prints `YAML OK`.

- [ ] **Step 2: Confirm workflow has no leftover Lean references**

Run: `grep -nE "elan|lake exe|Mathlib build|lean-toolchain" .github/workflows/aether-research.yml`
Expected: **no output** (all Lean toolchain references removed).

- [ ] **Step 3: Confirm the comment fix is in place**

Run: `sed -n '1668,1673p' Aether/knowledge_extractor.py`
Expected: the new four-line comment from Task 2 Step 2 is present.

- [ ] **Step 4: Confirm the tick path still has zero compile references**

Run: `grep -rn "lake build" Aether/aether_tick.py Aether/knowledge_extractor.py`
Expected: **no output** (confirms the tick never compiles, backing the CI removal).

- [ ] **Step 5: Push to master**

```bash
git push origin master
```

Expected: push succeeds; the post-commit hook also force-pushes `catalog-lean` (expected, non-fatal if it races).

- [ ] **Step 6: Confirm the next scheduled tick succeeds**

Check the hourly run after this change lands: `gh run list --workflow aether-research.yml --limit 1 --json status,conclusion,createdAt`.
Expected: `completed / success`, and the run duration drops from ~8-11 min to ~3 min (compare `createdAt` vs `updatedAt`).
