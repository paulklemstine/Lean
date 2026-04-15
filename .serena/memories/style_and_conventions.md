# Style and Conventions

## Naming
- File names use PascalCase matching module names (e.g., `BerggrenTree.lean`, `HyperbolicGeometry.lean`)
- Declaration names use camelCase (Lean 4 convention)
- Module paths follow `Catalog.Category.Subcategory` pattern

## Code Organization
- Each top-level directory under `Catalog/` is a separate Lean library target
- Files are organized by mathematical domain
- All internal imports use `Catalog.*` module paths (self-contained)
- The project depends on Mathlib v4.28.0

## Lean 4 Conventions
- Standard Lean 4 syntax and conventions
- `theorem` for proven results, `lemma` for helper results
- `def` for definitions, `structure`/`class` for type classes and structures
- `namespace` blocks for organizing declarations
- `import` statements at top of file

## Import Pattern
- All imports from within the project use `Catalog.*` paths
- Mathlib imports use standard `Mathlib.*` paths

## File Encoding
- UTF-8