# Summary of changes for run ee256e2e-7c09-42d0-9497-e0327ad04852
## MDS–Uncertainty Equivalence: Complete Research Deliverables

### Lean 4 Proofs (all sorry-free, machine-verified)

**`Algebra/MDSUncertainty/Defs.lean`** — Core definitions:
- `vecSupport`, `vecZeros` — vector support and zero set as Finsets
- `IsMDS` — the MDS property (every square submatrix has nonzero determinant)
- `SatisfiesUP` — the discrete uncertainty principle (|supp(f)| + |supp(Mf)| ≥ n+1)
- `CriticalSubmatrix` — **novel structure**: a constructive certificate witnessing MDS failure, consisting of a singular submatrix together with its kernel vector
- Supporting lemmas about support/zeros complementarity

**`Algebra/MDSUncertainty/Theorems.lean`** — Main results (7 theorems, 0 sorries):
1. **`vandermonde_det_ne_zero`** — Vandermonde matrices with injective nodes are nonsingular (via the product formula)
2. **`critical_submatrix_breaks_uncertainty`** — A singular submatrix yields an explicit vector violating the uncertainty principle
3. **`critical_of_not_mds`** — Every non-MDS matrix admits a critical submatrix certificate
4. **`uncertainty_implies_mds`** — SatisfiesUP → IsMDS (backward direction)
5. **`mulVec_eq_zero_of_det_ne_zero`** — Nonsingular matrices have trivial kernel
6. **`mds_implies_uncertainty`** — IsMDS → SatisfiesUP (the hard forward direction, via submatrix extraction)
7. **`mds_iff_uncertainty`** — **The main equivalence**: IsMDS ↔ SatisfiesUP

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

### Key Mathematical Result

The MDS–Uncertainty equivalence unifies three domains:
- **Coding theory**: MDS codes achieve the Singleton bound
- **Harmonic analysis**: The discrete uncertainty principle
- **Linear algebra**: Submatrix invertibility

A matrix M satisfies |supp(f)| + |supp(Mf)| ≥ n+1 for all nonzero f **if and only if** every square submatrix of M has nonzero determinant.

### Other Deliverables

- **ARTICLE.md** — Popular science article (~1500 words) about the ideas, not verification
- **RESEARCH_PAPER.md** — Full research paper with proofs, experiments, and references
- **FUTURE_DIRECTIONS.md** — 5 research directions including Schur polynomial positivity, DFT MDS, AES cryptographic diffusion, and tensor products
- **demo.py** — Numerical demonstrations including finite field MDS analysis
- **algorithms.py** — Type-hinted implementations of MDS checking, critical submatrix finding, and GF(p) arithmetic
- **viz_uncertainty.py** — Matplotlib visualization of the uncertainty heatmap
- **PACKAGE.json** — Full package with 3 interactive HTML widgets:
  1. MDS–Uncertainty Explorer (live matrix analysis)
  2. Finite Field MDS Checker (GF(p) Vandermonde analysis)
  3. Uncertainty Principle Visualizer (interactive bound visualization)

### Falsifiable Conjecture

Computational experiments revealed that Vandermonde matrices V(1,...,n) fail to be MDS over most finite fields — with non-monotone behavior in the characteristic (MDS at GF(17) but not GF(13) for n=4). This motivates the conjecture that over characteristic 0 fields, Vandermonde with distinct positive evaluation points is always MDS (via Schur polynomial positivity).