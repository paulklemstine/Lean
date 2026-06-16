# Plan: Archive Packages, Theorem Metadata, and Planning Guidance

## Goal

Extend the SQLite archive and backfill pipeline so it captures research packages and rich theorem metadata, make it possible to package a single job on demand, and add an interactive planning questionnaire for users.

## Scope

1. **Database schema extensions** in `Aether/archive_manager.py`.
2. **Backfill process enhancements** in `Aether/backfill_aristotle_archive.py`.
3. **Single-job package processor** (`Aether/package_single_job.py`).
4. **Enhanced theorem parsing** (reusable module `Aether/theorem_extractor.py`).
5. **Interactive planning questionnaire** (`Aether/planning_guide.py`).
6. **README updates** and basic validation/tests.

---

## 1. Database schema extensions

### 1.1 New `packages` table

| Column | Type | Notes |
|--------|------|-------|
| `project_id` | TEXT PK | FK to `projects` |
| `package_hash` | TEXT | SHA-256 of canonical JSON |
| `title` | TEXT | package title |
| `domain` | TEXT | resolved catalog domain |
| `description` | TEXT | short description |
| `exp_id` | TEXT | experiment id |
| `date` | TEXT | ISO date from package |
| `key_results_json` | TEXT | JSON array of strings |
| `keywords_json` | TEXT | JSON array of strings |
| `lean_files_json` | TEXT | JSON array of paths |
| `article_hash` | TEXT | FK to `files.hash` (nullable) |
| `research_paper_hash` | TEXT | FK to `files.hash` (nullable) |
| `future_directions_hash` | TEXT | FK to `files.hash` (nullable) |
| `json_payload` | TEXT | full canonicalized JSON content |

`archive_project()` will detect `PACKAGE.json` in output files, parse it, store the blob in `files`, and insert a row into `packages`.

### 1.2 Enhanced `theorems` table

Add columns:

| Column | Type | Notes |
|--------|------|-------|
| `project_id` | TEXT | FK to `projects` (nullable; theorems may come from packages or bare projects) |
| `full_statement` | TEXT | full theorem/lemma statement (first 4000 chars) |
| `docstring` | TEXT | `/-! ... -/` or `--` header preceding the declaration |
| `proof_text` | TEXT | body after `:= by` (first 4000 chars) |
| `line_number` | INT | line in the archived file where declaration starts |
| `file_path` | TEXT | path inside the archive |
| `is_complete` | INT | 1 if no `sorry` and no `admit` in proof body |
| `uses_sorry` | INT | 1 if body contains `sorry` |
| `parameters` | TEXT | parameter string after the name |
| `return_type` | TEXT | type after `: ` before `:=` |
| `declaration_kind` | TEXT | `theorem`, `lemma`, `example`, etc. |
| `metadata_json` | TEXT | JSON object with extra parsed fields |

A new reusable `TheoremExtractor` class will replace the simple regex scanner.

### 1.3 Helper methods on `ArchiveManager`

- `store_package(project_id, package_json_str) -> str`: hash, store blob, insert `packages` row.
- `get_package(project_id) -> Optional[dict]`.
- `get_project_theorems(project_id) -> List[dict]`.
- `rebuild_packages_from_blobs()`: scan all manifests and re-extract packages.

---

## 2. Backfill process enhancements

### 2.1 Package extraction during backfill

- After `_archive_one_api()` downloads/extracts a project, call a new helper `_process_project_packages(am, tmpdir, project_id, telemetry)`.
- It searches `output_dir` for `PACKAGE.json` (case-insensitive) or any file matching `*.package.json`.
- For each package found: read text, validate JSON, call `am.store_package()`.
- Telemetry counter: `packages_stored`.

### 2.2 Enhanced theorem extraction during backfill

- After files are archived, scan every newly-seen `.lean` file with `TheoremExtractor`.
- Insert rows into `theorems` with all new metadata fields.
- Telemetry counter: `theorem_metadata_extracted`.

### 2.3 CLI additions

Add flags to `backfill_aristotle_archive.py`:

| Flag | Purpose |
|------|---------|
| `--extract-packages` | Enable package extraction (default: on) |
| `--extract-theorem-metadata` | Enable rich theorem metadata (default: on) |
| `--reprocess-existing` | Re-scan already-archived projects for packages/theorems |
| `--skip-downloads` | Only process local archive (useful for reprocessing) |

---

## 3. Single-job package processor

New file: `Aether/package_single_job.py`

Usage:

```bash
cd Aether
python3 package_single_job.py <project-id> \
  --archive-root ../Archive \
  --output ../Archive/packages/<project-id>.package.json
```

Behavior:

1. Load `ArchiveManager`.
2. Check if project exists in archive; if not, download input/output via streaming (using existing `_stream_download` logic, moved to a shared module or duplicated minimally).
3. Extract project files to temp dir.
4. Run the same extraction logic used during backfill to find/create `PACKAGE.json`.
5. If no package exists, build a minimal package from available artifacts (lean files, demos, article, research paper).
6. Store the package in the database and optionally write it to disk.

To avoid circular imports, shared download/helpers will move into a small module `Aether/archive_utils.py`.

---

## 4. Enhanced theorem extraction

New file: `Aether/theorem_extractor.py`

Responsibilities:

- Parse Lean 4 source into theorem declarations.
- Extract docstrings:
  - `/-! ... -/` module/file comments before a declaration.
  - `--` line comments immediately preceding a declaration.
- Capture full statement and proof body with line numbers.
- Detect `sorry`, `admit`, `PartiallyAccessibleType`, and incomplete tactics.
- Return structured `TheoremRecord` dataclass.

This module will be used by both `archive_manager.py` (backfill) and `package_single_job.py`.

---

## 5. Interactive planning questionnaire

New file: `Aether/planning_guide.py`

Usage:

```bash
cd Aether && python3 planning_guide.py
```

It interactively asks:

1. What is your primary goal? (backfill existing jobs / package one job / build a clean catalog / analyze theorems / all)
2. How much RAM can the process use? (auto-detect suggests a `--max-memory-mb` value)
3. Do you want to reprocess already-archived projects? (yes/no)
4. Target domain filter, if any?
5. Output preference? (database-only / also write files / generate a run script)

It then prints a concrete command to run and, if requested, writes a shell script to `.aether_workspace/run_plan.sh`.

---

## 6. README updates

Add sections for:

- `package_single_job.py` usage.
- The new backfill flags.
- `planning_guide.py` usage.
- WSL2 memory tuning reminders.

---

## 7. Testing / validation

- Add a smoke test that parses a known `PACKAGE.json` and verifies schema insert/select roundtrip.
- Add a theorem extractor test using a sample Lean snippet.
- Validate `backfill_aristotle_archive.py` still compiles and `--help` works after refactoring.

---

## Files to modify or create

| File | Action |
|------|--------|
| `Aether/archive_manager.py` | Extend schema, add package/theorem helpers |
| `Aether/backfill_aristotle_archive.py` | Extract packages and theorem metadata, new CLI flags |
| `Aether/archive_utils.py` | New shared helpers (streaming download, API key, temp cleanup) |
| `Aether/theorem_extractor.py` | New Lean theorem parser |
| `Aether/package_single_job.py` | New single-job package processor |
| `Aether/planning_guide.py` | New interactive questionnaire |
| `README.md` | Document new tools |
| `Aether/tests/test_archive_extensions.py` | New tests (optional) |

---

## Risks and mitigations

| Risk | Mitigation |
|------|------------|
| Refactor breaks existing backfill | Keep changes additive; run `--help` and a short `--max-pages 1` dry run after each chunk. |
| Large `lean_proofs` strings overflow memory | Store only hashes in `packages`; keep `json_payload` as the canonical package JSON. |
| Theorem parser is slow on huge files | Only parse newly-seen files; reuse `is_new_file` guard. |
| WSL2 still OOMs | Default `--max-memory-mb 5500` and document WSL2 `.wslconfig`. |

---

## Recommended first steps after approval

1. Create `Aether/archive_utils.py` and migrate shared download helpers.
2. Extend `archive_manager.py` schema and helpers.
3. Create `Aether/theorem_extractor.py`.
4. Wire extraction into `backfill_aristotle_archive.py`.
5. Create `Aether/package_single_job.py`.
6. Create `Aether/planning_guide.py`.
7. Update README and validate.
