# Summary of changes for run 36d5ef16-6910-408a-950c-efc9d1872ace
## Completed: Tropical Factor-Rank-1 Equivalence

### Deliverable 1: Formally Verified Mathematics (Lean 4)

**File**: `Catalog/Tropical/LinearAlgebra/MinPlusRankOne.lean` (283 lines, zero `sorry`, builds cleanly)

All theorems are fully machine-verified with only standard axioms (propext, Classical.choice, Quot.sound). The file contains:

**Definitions:**
- `MinPlusFactorRankLE` — min-plus factor rank via sInf over Set.range
- `MaxPlusFactorRankLE` — max-plus dual
- `AdditivelySeparable` — A(i,j) = p(i) + q(j)
- `TropicalRankOneMinorCondition` — ∀ i i' j j', A i j + A i' j' = A i j' + A i' j
- `delta₂` — discrete curvature defect

**Core Theorems (all proved):**
1. `minPlusFactorRankLE_one_iff_additivelySeparable` — min-plus rank ≤ 1 ↔ additive separability
2. `additivelySeparable_iff_tropicalRankOneMinorCondition` — separability ↔ 2×2 minor vanishing
3. `minPlusFactorRankLE_one_iff_minorCondition` — **flagship synthesis theorem**
4. `additive_separable_of_minorCondition` — constructive basepoint reconstruction
5. `additive_decomposition_unique_up_to_constant` — gauge uniqueness up to constant shift
6. `maxPlusFactorRankLE_one_iff_minorCondition` — max-plus dual theorem
7. `minPlusFactorRankLE_one_iff_maxPlusFactorRankLE_one` — min-plus = max-plus at rank 1
8. `row_diff_constant_of_additivelySeparable` — row-difference invariance
9. `tropicalRankOneMinorCondition_neg` — negation preserves minor condition
10. Helper lemmas: `sInf_range_fin_one`, `sSup_range_fin_one`, `minorCondition_of_additive`, `delta₂_eq_zero_iff`, etc.

### Deliverable 2: Popular Science Article → `ARTICLE.md`
~2500 words. "The Hidden Geometry of Cost Tables" — explores how one equation unifies optimization, network theory, differential geometry, and abstract algebra through the lens of shipping costs and cost tables.

### Deliverable 3: Research Paper → `RESEARCH_PAPER.md`
~4000 words. Complete with abstract, definitions, full theorem statements with proof sketches, algorithmic pseudocode with complexity analysis, applications, computational experiments, and references.

### Deliverable 4: Python Code
- `demo.py` — 5 demonstrations: exact rank-1 recognition, non-rank-1 detection, perturbation stability, min/max-plus duality, row-difference invariance
- `algorithms.py` — O(nm) rank-1 decomposition, minor violation finder, delta₂ computation, best L∞ approximation, tropical matrix multiplication (min-plus and max-plus)
- `applications.py` — 4 real-world applications: logistics cost separation, neural network weight analysis, graph potential detection, DP decomposition
- `visualizations.py` — 4 matplotlib visualizations: decomposition diagram, curvature heatmap, perturbation stability plot, three-way equivalence diagram

### Deliverable 5: `FUTURE_DIRECTIONS.md`
5 concrete directions with formal targets: approximate rank-1, higher rank stratification, WithTop ℝ extension, algorithmic certification, tropical convex geometry.

### Deliverable 6: `PACKAGE.json`
Complete JSON data package with all content, embedded base64 visualizations, and code.