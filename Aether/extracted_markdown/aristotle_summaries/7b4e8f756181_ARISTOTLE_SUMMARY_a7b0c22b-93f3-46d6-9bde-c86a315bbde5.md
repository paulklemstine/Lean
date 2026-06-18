# Summary of changes
All Scientific American articles have been consolidated into a single `ScientificAmerican/` directory at the project root.

**What was done:**
- Found **274 Scientific American files** scattered across `lean1/`, `lean2/`, `lean3/`, `lean4/`, and `LEAN4-NEW/` directories.
- Extracted the title from each paper (using the first `#` heading in each file).
- Identified duplicates by content hash (MD5) — found **70 duplicate files** across 59 duplicate groups.
- Copied **204 unique files** into `ScientificAmerican/`, each named after its paper title (e.g., `The Equation That Connects Everything.md`, `The Hidden Mathematics Inside AI How Tropical Algebra Could Make ChatGPT 12 Times Faster.md`).
- Where multiple unique papers shared the same title, they were disambiguated with numeric suffixes (e.g., `The Equation That Connects Everything (1).md`).
- Removed all original copies from their scattered locations.

**Result:** 204 unique Scientific American articles in `ScientificAmerican/`, zero duplicates, filenames matching paper titles.