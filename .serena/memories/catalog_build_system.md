# Catalog Build System

The project has a theorem catalog build system at `Catalog/tools/`.

## Architecture (Inside-Out)
- **Database is source of truth**: `Catalog/tools/output/catalog.json` contains all declarations
- **Source files are generated FROM the database**: `CatalogBuild/` is the output
- **Original Catalog/ is input-only**: scanned once to populate the database

## Commands
```bash
python3 tools/catalog.py extract --source Catalog/ --output tools/output/catalog.json --verbose
python3 tools/catalog.py build --db tools/output/catalog.json --output CatalogBuild/ --verbose
python3 tools/catalog.py validate --build-dir CatalogBuild/ --db tools/output/catalog.json
python3 tools/catalog.py all --source Catalog/ --output-dir CatalogBuild/ --verbose
```

## Files
- `tools/extract_catalog.py` — Scans .lean files, parses declarations, resolves duplicates
- `tools/build_catalog.py` — Generates clean .lean source from DB with dedup and fixed imports
- `tools/validate_catalog.py` — Validates build output
- `tools/catalog.py` — Unified CLI
- `tools/schema/v1/catalog_database.schema.json` — JSON Schema
- `tools/output/catalog.json` — Master database (~29K declarations, ~23K canonical)

## Key Stats
- 1,324 input .lean files → 1,201 output files (deduped)
- 29,162 total declarations → 23,209 canonical (6K duplicates removed)
- 3,652 duplicate groups identified
- Shared modules generated for declarations appearing in 5+ files

## Rescan Workflow

After adding new theorems to `Catalog/`:
```bash
python3 tools/catalog.py rescan --source Catalog/ --db tools/output/catalog.json --output-dir CatalogBuild/
```
- Only parses new/modified files (detected by mtime comparison)
- Merges into existing DB, re-resolves duplicates
- Auto-rebuilds CatalogBuild/
- Subsequent rescans with no changes take <1 second

## Why: The database owns the theorems; source files are compiled output