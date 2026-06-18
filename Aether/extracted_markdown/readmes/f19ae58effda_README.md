# Theorem Catalog Tools

Build system for generating canonical, deduplicated Lean 4 source files from a theorem database.

## Architecture

```
  Existing .lean files ──► extract ──► catalog.json (master DB)
                                            │
                                            ▼
                                       build ──► CatalogBuild/ (clean source tree)
                                            │
                                            ▼
                                       validate ──► PASS/FAIL
```

The **database is the source of truth**. Source files are generated from it.

## Commands

### Extract — scan existing files into the database

```bash
python3 tools/catalog.py extract \
  --source Catalog/ \
  --output tools/output/catalog.json \
  --verbose
```

### Build — generate clean source tree from the database

```bash
python3 tools/catalog.py build \
  --db tools/output/catalog.json \
  --output-dir CatalogBuild/ \
  --shared-threshold 5 \
  --verbose
```

Options:
- `--shared-threshold N` — declarations appearing in N+ files get extracted to shared modules (default: 5)
- `--prefix` — Lean module path prefix (default: CatalogBuild)

### Validate — check build output

```bash
python3 tools/catalog.py validate \
  --build-dir CatalogBuild/ \
  --db tools/output/catalog.json \
  --verbose
```

### Full pipeline

```bash
python3 tools/catalog.py all \
  --source Catalog/ \
  --output-dir CatalogBuild/ \
  --verbose
```

## What the build does

1. **Deduplication**: Only canonical declarations are emitted (one per duplicate group)
2. **Shared modules**: High-frequency duplicates (e.g., `brahmagupta_fibonacci` in 63 files) get extracted to `Shared/` modules
3. **Import fixup**: All `import` statements are recalculated — removed declarations are replaced by imports to their canonical location
4. **Hierarchy**: Files are organized by domain/subdomain matching the directory structure
5. **Build config**: `lakefile.toml` and `lean-toolchain` are auto-generated

## Output structure

```
CatalogBuild/
├── lakefile.toml
├── lean-toolchain
├── Algebra/
│   ├── Foundations/
│   │   └── QuadraticForms.lean
│   └── DivisionAlgebras/
│       └── BrahmaguptaFibonacci.lean
├── Bridges/
│   └── UnifiedFramework.lean
├── Shared/
│   ├── BrahmaguptaFibonacci.lean
│   ├── ReLU.lean
│   └── Oracle.lean
└── ...
```

## Files

| File | Purpose |
|------|---------|
| `catalog.py` | Unified CLI entry point |
| `extract_catalog.py` | Extraction logic — scans .lean files into DB |
| `build_catalog.py` | Build logic — generates source from DB |
| `validate_catalog.py` | Validation — checks build integrity |
| `schema/v1/catalog_database.schema.json` | JSON Schema for the database |
| `output/catalog.json` | The master theorem database |