# Summary of changes for run 08a67430-2236-424b-9501-aabd03f51093
Developed a new self-contained Lean 4 theory of the **tropical (min-plus) eigenvalue** of a real square matrix, defined as the normalized optimal-assignment value λ*(A) = (1/n)·min_σ ∑_i A(i, σ(i)) over permutations σ.

## Deliverables

**1. Lean file** — `Catalog/Tropical/Applications/TropicalEigenvalue.lean`
Defines `assignCost` and `tropEig`, and proves **7 theorems with complete proofs (zero `sorry`)**, all depending only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`:
- `tropEig_add_const` — translation law: λ*(A+c) = λ*(A)+c (n>0).
- `tropEig_transpose` — λ*(Aᵀ) = λ*(A) via σ ↦ σ⁻¹.
- `tropEig_conj` — invariance under common row/column relabeling (conjugation).
- `tropEig_mono` — monotonicity under entrywise ≤.
- `tropEig_le_trace` — diagonal/trace upper bound.
- `tropEig_smul_nonneg` — positive homogeneity λ*(c·A) = c·λ*(A) for c ≥ 0.
- `tropEig_min_entry_le` — floor bound by the matrix minimum.

These were verified to elaborate with zero warnings/errors.

**2. Catalog synthesis** — The work bridges the existing catalog file `Catalog/Tropical/Applications/TropicalEquivalenceInvariance.lean`: its vector-level ranking-invariance under tropical shifts (`tropical_shift_preserves_pairwise_order`) is shown to be the same min-plus additive ℝ-action that, at the matrix level, governs the eigenvalue (`tropEig_add_const`). This is cited explicitly in the file's docstring and Lab Notebook.

**3. Brief proof sketches** — included as `-- !-- comment -- !--` blocks above each theorem.

**4. Lab Notebook** — `-- !-- Lab Notebook -- !--` blocks documenting Hypothesis / Result / Insight / Failure analysis, with adversarially identified boundary conditions (the laws genuinely fail at n = 0 for the translation/trace/floor results and at c < 0 for homogeneity, where the assignment minimum flips to a maximum).

**5. `FUTURE_DIRECTIONS.md`** — narrative synthesis, a results-summary table, and 5 falsifiable research directions (negative-scalar max-plus dual, tropical spectral-gap sandwich, Fekete/minimum-cycle-mean limit, critical-graph perturbation stability, Birkhoff-polytope convex relaxation), each with a "The key insight is..." sentence and a "Why now?" justification.

Note: the project's pre-existing tropical files contained no remaining `sorry` placeholders, so the cycle's value is the new eigenvalue theory and cross-domain bridge rather than gap-filling.