# Aristotle Archive

This directory contains a durable, content-addressable archive of every
Aristotle project input and output, plus a SQLite master catalog of all archived
files and theorems.

## Layout

```
Archive/
├── catalog.sqlite      # Master SQLite index
├── manifests/          # One JSON file per Aristotle project
└── blobs/              # Content-addressable file store
    └── {hash[0:2]}/{hash[2:4]}/{full_sha256_hash}
```

## Content-addressable storage

Every file is stored exactly once, keyed by its SHA-256 hash. Identical files
across different projects (for example, the same catalog context copied into
many Aristotle inputs) are automatically deduplicated.

## Master catalog (`catalog.sqlite`)

Tables:

- `projects` — one row per Aristotle project
- `files` — one row per unique file hash
- `project_files` — which files belonged to which project and in what role
- `theorems` — every theorem/lemma/example found in archived `.lean` files
- `prompts` — extracted Aristotle prompts with detected prompt version

## Git tracking

- `catalog.sqlite`, `manifests/`, this `README.md`, and `blobs/` are tracked
  by git.
- `Archive/.gitattributes` routes `Archive/blobs/**` through git-lfs if
  available. Because blobs can be large, **git-lfs is strongly recommended**.
- If git-lfs is not installed, the archive will still work locally and push to
  GitHub as long as no single blob exceeds ~100 MB and the total repo size stays
  within GitHub limits.

## Updating the archive

- **Auto:** after each Aether integration, `ArchiveManager` archives the
  project's input/output files.
- **Manual backfill:** run `python3 Aether/backfill_aristotle_archive.py`.
