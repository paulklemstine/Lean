# Plan: Aristotle Package Archive + Master `.lean` Catalog

## Goal
Build a durable archive of every Aristotle project (inputs and outputs) and a
searchable SQLite master catalog of every `.lean` file ever produced or submitted,
using content-addressable storage for deduplication.

## Design Decisions (from questionnaire)
- **Scope:** both package archives + master catalog
- **Storage:** git-tracked `Archive/` directory at repo root
- **Deduplication:** content-addressable storage (CAS) keyed by file hash
- **Index format:** SQLite master index

## Key Constraints Discovered
- Existing project directories are ~30–35 MB each because they copy the full
  Catalog as context for Aristotle.
- ~134 projects exist locally today (~1.9 GB total).
- Aristotle **output** archives (`result.tar.gz`) are downloaded and then
  extracted/deleted by the current pipeline; they are not retained.
- `git-lfs` is **not** initialized in this repo.
- With CAS, catalog context files common across projects will be stored once,
  so actual unique blob storage should be far less than the raw 1.9 GB.

## Proposed Architecture

### Directory Layout
```
Archive/
├── README.md                 # What this directory is
├── .gitattributes            # Optional: route large CAS blobs to git-lfs
├── catalog.sqlite            # Master SQLite index (git-tracked)
├── manifests/                # One small JSON per project (git-tracked)
│   ├── 37b12e88.json
│   └── ...
└── blobs/                    # Content-addressable file store (git-tracked)
    ├── 00/
    │   ├── 01/
    │   │   └── 0001...dead  # actual file bytes
    │   └── ...
    └── ...
```

### Content-Addressable Storage (CAS)
- Each file (input `PROMPT.md`, `Main.lean`, output `.lean` files,
  `lakefile.toml`, etc.) is hashed with SHA-256.
- Stored at `Archive/blobs/{hash[0:2]}/{hash[2:4]}/{full_hash}`.
- A file with identical content is never stored twice, regardless of how many
  projects copied the same catalog file.
- This is the deduplication mechanism.

### SQLite Master Catalog (`Archive/catalog.sqlite`)
Tables:
1. **`projects`** — one row per Aristotle project
   - `project_id`, `description`, `status`, `created_at`, `last_updated`, `input_hash`, `output_hash`, `prompt_blob_hash`, `manifest_path`
2. **`files`** — one row per archived file
   - `hash` (PK), `size`, `content_type`, `first_seen_at`
3. **`project_files`** — many-to-many linking projects to the files they contained
   - `project_id`, `file_hash`, `path_inside_archive`, `role` (`input`/`output`/`catalog_context`)
4. **`theorems`** — every theorem/lemma/example found in any archived `.lean`
   - `name`, `file_hash`, `project_id`, `domain`, `statement_text`, `is_sorry`, `theorem_type`
5. **`prompts`** — extracted prompts with metadata
   - `project_id`, `prompt_blob_hash`, `length`, `phase_a_prompt_version` (if detectable)

### Manifests (`Archive/manifests/*.json`)
- One small JSON per project for human readability and git diffs.
- Contains project metadata + list of file hashes and their original paths.
- SQLite is the queryable source of truth; manifests are for inspection.

## Implementation Steps

### 1. Create `Archive/` content-addressable archive module
New file: `Aether/archive_manager.py`
- `ArchiveManager` class with methods:
  - `store_file(path_or_bytes) -> hash`
  - `read_file(hash) -> bytes`
  - `exists(hash) -> bool`
  - `store_project(project_id, input_dir, output_dir) -> manifest`
  - `rebuild_index()`

### 2. Extend input gatherer to also archive outputs
Modify `Aether/gather_aristotle_inputs.py` (or create
`Aether/gather_aristotle_history.py`):
- For each project:
  1. Download `/input` archive → extract to temp dir.
  2. Download `/files` (output) archive if `has_files=True`.
  3. CAS-store every file.
  4. Build manifest and write to `Archive/manifests/{project_id}.json`.
  5. Insert rows into `Archive/catalog.sqlite`.
- Support `--resume` using existing CAS blobs and manifests.

### 3. Auto-archive future jobs
Hook into `Aether/knowledge_extractor.py` after a job is integrated:
- In `cleanup_catalog()` or `commit()`, after files are written to `Catalog/`,
  call `ArchiveManager.archive_project(job.project_id, input_dir, output_dir)`.
- This only archives **output** files; the input archive can be re-downloaded
  from the API lazily by the backfill script.

### 4. Build backfill script
New file: `Aether/backfill_aristotle_archive.py`
- Reads `Aether/.aether_workspace/inflight_jobs.json` and existing project dirs.
- For each historical `project_id`, downloads input/output archives via API.
- Feeds them to `ArchiveManager`.
- Idempotent: safe to rerun.

### 5. Initialize git tracking
- Create `Archive/.gitattributes`:
  - Route `blobs/**` to `git-lfs` (recommended because some output archives may
    still be large even after CAS).
- Add `Archive/` to `.gitignore` **except** `catalog.sqlite`, `manifests/`, and
  `README.md`? No — user wants the whole directory tracked.
- We will track `Archive/` but strongly recommend enabling git-lfs for
  `Archive/blobs/**`.

### 6. Tests
- Add `Aether/tests/test_archive_manager.py` to verify:
  - CAS dedup stores identical content once.
  - SQLite index is updated correctly.
  - Manifest round-trips.

## Trade-offs & Risks

| Concern | Mitigation |
|---|---|
| Repo size explosion from 30 MB project archives | CAS dedup of catalog files; raw archives not stored, only extracted files. |
| GitHub 100 MB file limit / 2 GB push limit | Use git-lfs for `Archive/blobs/**`; otherwise keep blobs small. |
| Output archives currently deleted after extraction | Backfill script re-downloads historical outputs via API. |
| SQLite index in git causes merge conflicts | Index is rebuilt from manifests on demand; `.sqlite` can be gitignored if it becomes noisy. |
| Performance of hashing thousands of files | SHA-256 over file bytes is fast; only new files are hashed on incremental runs. |

## Recommended Rollout
1. **Phase 1:** Implement `ArchiveManager`, CAS, and SQLite schema.
2. **Phase 2:** Run backfill script over the 134 existing projects to populate
   the archive.
3. **Phase 3:** Wire auto-archive into `knowledge_extractor.py`.
4. **Phase 4:** Enable git-lfs for `Archive/blobs/**` and push to GitHub.

## Open Question for User
Git LFS is not currently initialized. Do you want to **enable git-lfs** for
`Archive/blobs/**` before we push the archive to GitHub? Without LFS, the repo
may exceed GitHub's recommended size limits once the archive grows.
