# Summary of changes
All research papers have been sorted into a single directory: `LEAN4-NEW/papers/`

**What was done:**
- Scanned all 24+ subdirectories under `LEAN4-NEW/` for research papers and scientific articles (`.md` files with paper/article content).
- Found 63 total paper files across the project.
- Identified and removed **1 exact duplicate** (identical content confirmed via MD5 checksum): `PythagoreanPhotonics2/paper/scientific_american_article.md` was an exact copy of `PythagoreanPhotonics1/paper/scientific_american_article.md`.
- For 2 pairs of papers that share the same title but have different content, disambiguating suffixes were added:
  - "The Secret Arithmetic of the Golden Ratio" → `(Fibonacci Arithmetic)` and `(Fibonacci Factoring)` variants
  - "The Eight Bridges: A Unified Framework for Space–Algebra Correspondences" → `(v1)` and `(v2)` variants

**Result:** 62 unique papers now reside in `LEAN4-NEW/papers/`, each named after its title (extracted from the first `# heading` in the markdown). The original files remain in their source locations.