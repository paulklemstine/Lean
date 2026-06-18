# Summary of changes for run ed642d3d-0e38-4de7-b9a6-5c1f380ff51a
## Completed: Tropical Assignment Gap Extension

### Formally Verified Mathematics (0 sorries)

Created `Pythagorean/AssignmentGapExtension.lean` (also in `Catalog/Pythagorean/`) with **16 fully proved theorems** building on the catalog's `TropicalUniversality.lean`. Key results:

**New Definitions:**
- `permWeight`, `idWeight`, `assignmentGap` — full assignment gap framework
- `IsTranspositionPerm`, `bestTranspositionWeight` — transposition-specific optimization
- `LongCycleExceptional`, `PermTieHyperplane` — exceptional locus characterization
- `pairDeficit`, `IsSymmetricFn`, `SymmetricPairwiseDiagDom` — structural conditions

**Main Theorems (all machine-verified, standard axioms only):**

1. **`permWeight_le_bestTransposition_of_symmetric_pairwise_dom`** — The central theorem: under symmetric pairwise diagonal dominance, *every* non-identity permutation is dominated by the best transposition. This collapses n!-sized optimization to O(n²).

2. **`idWeight_sub_permWeight_pos_of_symmetric_pairwise_dom`** — Identity strictly beats all non-identity permutations under SPDD.

3. **`symmetric_deficit_identity`** — The algebraic engine: `2*(idWeight - permWeight σ) = Σᵢ pairDeficit(i, σ(i))`, decomposing global deficit into local pairwise penalties without cycle decomposition.

4. **`longCycleExceptional_implies_tie_hyperplane`** — The exceptional locus where long cycles compete is contained in a finite union of permutation-weight tie hyperplanes.

5. **`assignmentGap_eq_neg_tropMargin_of_two`** — Exact bridge: for n=2 and symmetric W, assignmentGap = −tropMargin.

6. **`assignmentGap_neg_of_strict_separation`** — Catalog bridge: strict tropical separation (tropMargin > 0) implies identity is suboptimal (assignmentGap < 0).

7. **`bestCompetitor_exists`**, **`assignmentGap_nonneg_of_symmetric_pairwise_dom`**, **`bestCompetitorWeight_spec`** — Supporting infrastructure.

### Written Deliverables

- **`ARTICLE.md`** — Popular science article (~2000 words) about how pairwise swaps secretly control a vast combinatorial universe
- **`RESEARCH_PAPER.md`** — Full research paper with abstract, theorems, algorithms, experiments, and references
- **`FUTURE_DIRECTIONS.md`** — 5 research directions with structured format including two grand challenges (generic transposition dominance conjecture, tropical discriminant of assignment polytope)

### Computational Deliverables

- **`demo.py`** — Interactive demo testing the falsifiable conjecture on random matrices, showing disagreement frequencies and the phase transition under diagonal boost
- **`algorithms.py`** — Exhaustive and transposition-only algorithms with O(n²) vs O(n!) comparison
- **`applications.py`** — Applications to matching stability, complexity reduction, and robustness certification
- **`viz_heatmap.py`**, **`viz_disagreement.py`**, **`viz_deficit_landscape.py`** — Three visualization scripts
- **`interactive_demo.html`** — Interactive HTML/JS explorer with slider for diagonal boost
- **`PACKAGE.json`** — Complete JSON data package bundling all artifacts

### Falsifiable Conjecture
For i.i.d. continuous random matrices, P(best non-identity permutation is a transposition) → 1 as n → ∞. Demo experiments show ~94% agreement at n=3 (no boost), rising to 100% under diagonal dominance (where the theorem guarantees it).