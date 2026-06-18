# Cleanup Directory Index

All 6,405 files from the project have been sorted into the following categories:

| Directory | Files | Description |
|-----------|------:|-------------|
| `project/` | 2,707 | Lean 4 source files (`.lean`) and project configuration (`lakefile.toml`, `lean-toolchain`, `lake-manifest.json`) |
| `sciam/` | 256 | Scientific American articles and related materials |
| `research/` | 363 | Research papers and publications |
| `notes/` | 151 | Research notes, lab notebooks, oracle council notes |
| `demos/` | 1,044 | Demo scripts, experiments, and interactive examples |
| `visuals/` | 762 | Visualizations, images, charts, and visual generation scripts |
| `misc/` | 1,122 | All other files (READMEs, books, LaTeX, HTML apps, Python utilities, etc.) |

## Categorization Rules (priority order)

1. **project/** — Files ending in `.lean`, plus `lakefile.toml`, `lean-toolchain`, `lake-manifest.json`
2. **sciam/** — Files/paths containing "Scientific American" (any separator style)
3. **research/** — Files/paths containing "Research Paper" (any separator style)
4. **notes/** — Files with "note" in the filename (case-insensitive)
5. **demos/** — Files inside `/demos/` or `/demo/` directories
6. **visuals/** — Files inside `/visuals/` or `/images/` directories, or with "visual" in filename
7. **misc/** — Everything else

All files preserve their original directory structure within each category.
