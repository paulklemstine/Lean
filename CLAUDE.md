# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a large Lean 4 theorem catalog (~24,700 declarations across 456+ source files) organized into 13 mathematical domains. The actual Lean project lives in `Catalog/`; the repo root only contains the project directory and git metadata.

## Working Directory

**Always operate from `Catalog/`** for Lean-related commands. The top-level repo root (`/home/raver1975/lean/`) has no build configuration.

```bash
cd Catalog/
```

## Build Commands

The project uses `lake` (Lean's package manager) with `mathlib4` pinned to `v4.28.0`.

```bash
# Build all default targets (all 13 libraries)
lake build

# Build a specific library
lake build Algebra
lake build Pythagorean
lake build EML
# ... etc. See lakefile.toml for all library names.

# Build a specific file
lake build ./Algebra/Foundations/Algebra.lean
```

There is no executable target (`Main.lean`); this is a pure library project.

## Custom Tooling (Theorem Catalog Pipeline)

The project has a Python-based toolchain in `Catalog/tools/` that treats a JSON database as the source of truth. Source files in `Catalog/` are scanned into this database, and a clean output tree can be generated at `CatalogBuild/`.

Key commands (run from repo root or `Catalog/`):

```bash
# Incremental rescan: detects changed .lean files, updates DB, rebuilds CatalogBuild/
python3 tools/catalog.py rescan --source Catalog/ --db tools/output/catalog.json --output-dir ../CatalogBuild/ --shared-threshold 5

# Shortcut for the above:
tools/rescan

# Validate the generated build tree against the database
python3 tools/catalog.py validate --build-dir ../CatalogBuild/ --db tools/output/catalog.json

# Full pipeline (extract + build + validate)
python3 tools/catalog.py all --source Catalog/ --output-dir ../CatalogBuild/
```

See `Catalog/tools/README.md` for full documentation.

## Architecture

### 13 Top-Level Libraries

Defined in `lakefile.toml`:

| Library | Approx. Declarations | Topics |
|---------|----------------------|--------|
| Algebra | ~1,475 | Division algebras, Galois theory, Lie algebras, linear algebra, representation theory |
| Geometry | ~1,103 | Gravitational factoring, geometric algebra |
| Logic | ~1,527 | Complexity theory, formal logic |
| Physics | ~3,095 | Prime gaps, Chebyshev bias, Carmichael numbers, perfect numbers |
| Computation | ~3,473 | Oracles, factoring, information theory, OISCC |
| Cryptography | ~720 | Factoring, cyclotomic methods, RSA-related |
| Pythagorean | ~4,570 | Berggren tree, nilpotent power, closed-form descent, quadruples, hyperbolic factoring |
| Tropical | ~1,747 | Tropical geometry/algebra |
| EML | ~3,570 | Emergent meta-language, self-pairing, diagonal forms |
| MachineLearning | ~878 | Neural compilation, RSIL, adaptive distillation |
| Bridges | ~921 | Unified frameworks spanning domains |
| Speculative | ~6,513 | Future research, open questions, experimental directions |
| Shared | — | Deduplicated common definitions (softplus, logistic sigmoid, SPB, EML, etc.) |

### Deduplication Model

Many declarations (e.g., `softplus`, `brahmagupta_fibonacci`, `eml`) are duplicated across dozens of files. The catalog pipeline resolves these into canonical declarations. High-frequency duplicates are extracted to `Catalog/Shared/`.

When editing, be aware that changing a declaration that exists in multiple files may affect deduplication. The `rescan` tool handles this automatically.

### Imports

Most source files use only:

```lean
import Mathlib
```

Some `Shared/` files and cross-domain files import other catalog modules (e.g., `import Speculative.PisanoPeriodFactoring`).

### File Headers

Source files contain auto-generated headers from the catalog pipeline:

```lean
/-! # CatalogBuild.Algebra.Foundations.Algebra
Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 5
-/
```

These headers are rewritten by the `rescan`/`build` tools. Do not treat them as manual documentation.

## Important Files

- `Catalog/lakefile.toml` — Lean package configuration (libraries, mathlib dependency)
- `Catalog/lean-toolchain` — Pins Lean to `v4.28.0`
- `Catalog/DECLARATION_INDEX.md` — Auto-generated alphabetical index of all ~24,737 declarations
- `Catalog/CATALOG.md` — Auto-generated category overview
- `Catalog/tools/README.md` — Full documentation for the Python toolchain
- `Catalog/tools/output/catalog.json` — Master theorem database (source of truth)

## Validation

There is no traditional test suite. Correctness is verified by:

1. `lake build` compiling all Lean libraries successfully.
2. `tools/catalog.py validate` checking that the generated `CatalogBuild/` matches the database.

## Python Demos

Various subdirectories contain standalone Python demos and experiment scripts (e.g., `Pythagorean/ClosedFormAncestor/*.py`, `Physics/demos/*.py`, `ShefferAI/python_demos/*.py`). These are not part of the build system and can be run independently.
