# Summary of changes for run 493b23fb-3476-4337-83d7-fbb622fa5f40
## Deliverables

**New Lean file: `Catalog/Tropical/Eigenvalue2x2.lean`** — a self-contained, `sorry`-free development of the tropical (max-plus) 2×2 eigenvalue formula, building directly on the existing tropical Collatz–Wielandt theory in `Catalog/Tropical/CollatzWielandt.lean` (reusing its `tropSpec` = maximum cycle mean, `cycleWt`, `cycleSucc`).

Theorems proved (no `sorry`, standard axioms only — `propext`, `Classical.choice`, `Quot.sound`):
- `cycleWt_one`, `cycleWt_two` — closed forms for length-1 and length-2 cycle weights (general `n`).
- `diag_le_tropSpec` — every diagonal entry `Wᵢᵢ ≤ tropSpec W` (dimension-free, general `n`; reusable).
- `twoCycle_le_tropSpec` — every symmetric 2-cycle mean `(Wᵢⱼ+Wⱼᵢ)/2 ≤ tropSpec W` (general `n ≥ 2`; reusable).
- `tropSpec_2x2_le` — the matching 2×2 upper bound.
- `tropSpec_2x2` — the main result: `tropSpec W = max (max W₀₀ W₁₁) ((W₀₁+W₁₀)/2)`.

The file includes the required `-- !-- ... -- !--` proof-sketch blocks for every result and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis). It extends rather than reproves the catalog: the lower-bound lemmas are stated for arbitrary `n` and the 2×2 formula is obtained as the regime where they become exhaustive.

**`FUTURE_DIRECTIONS.md`** — a Synthesis, Results Summary, and 5 falsifiable research directions (general n×n max-cycle-mean formula, tropical Cayley–Hamilton, Lipschitz stability, tie-locus eigenvector degeneracy, and the min-plus dual), each with a "The key insight is..." sentence and a "Why now?" justification.

**Build fix:** the package `lakefile.toml` was missing `srcDir = "Catalog"`, so no module resolved (lake looked under `./Tropical/...` instead of `./Catalog/Tropical/...`). I added that one line, after which the existing modules and the new file build successfully. The new module `Tropical.Eigenvalue2x2` compiles cleanly via `lake build`.