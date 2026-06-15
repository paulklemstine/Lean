# Aristotle Archive

The archive is now kept **local-only** under `Archive/` and is no longer tracked
by git because it can grow to multiple gigabytes (manifests, blobs, and the
SQLite master catalog).

## Layout (local)

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

## Updating the archive

- **Auto:** after each Aether integration, `ArchiveManager` archives the
  project's input/output files into `Archive/`.
- **Manual backfill:** run `python3 Aether/backfill_aristotle_archive.py`.

## Git

`Archive/` is listed in `.gitignore`. Keep the archive on local disk or
another storage backend; do not commit it to git.
