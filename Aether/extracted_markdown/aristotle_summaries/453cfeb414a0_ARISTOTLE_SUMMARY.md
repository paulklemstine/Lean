# Summary of changes for run 5dd34d70-f5bf-40ef-81aa-1066ec3a0528
## Completed Work: Tropical Amoebas and Canonical Forms

### New File: `Catalog/Tropical/Amoeba/Basic.lean` (0 sorries)

Created a new Lean 4 file with **6 fully-proved theorems** establishing foundations of tropical amoeba theory through convex analysis:

1. **`tropPoly_eval_convex`** — The evaluation of a tropical polynomial (pointwise max of affine functions) is convex. This is the fundamental result connecting tropical algebra to convex analysis.

2. **`consecutive_monomials_cross`** — Two tropical monomials with distinct exponents (slopes) cross at exactly one point. This gives the breakpoint structure corresponding to edges of tropical amoebas.

3. **`affine_eq_of_agree_two_points`** — Two tropical monomials agreeing at two distinct points must be identical (tropical Nullstellensatz lemma).

4. **`maslov_dequantization_limit`** — The Maslov dequantization limit: `h · log(exp(a/h) + exp(b/h)) → max(a, b)` as `h → 0⁺`. This formalizes the foundational connection between classical and tropical geometry (Viro/Litvinov–Maslov).

5. **`tropMul_distrib`** — Tropical multiplication distributes over tropical addition (the tropical semiring law).

6. **`foldl_max_convexOn`** — Inductive convexity preservation for max-folds of affine functions (key helper for the convexity theorem).

### Existing File: `Catalog/Tropical/Canonical/Basic.lean` (4 sorries, down from 6)

Proved **2 theorems** and **~10 supporting lemmas** in the tropical canonical forms file:

- **`univReluNet_is_cpl`** — Every univariate ReLU network computes a continuous piecewise-linear function. Proved by structural induction with 4 helper lemmas (`isUnivCPL_affine`, `isUnivCPL_add`, `isUnivCPL_sub`, `isUnivCPL_max_zero`), each fully proved.

- **`relu_network_equiv_iff_canonical`** — ReLU network equivalence reduces to canonical tropical rational form comparison. (Structurally proved; depends on the still-sorry'd `relu_network_has_canonical_tropical_rational`.)

Key infrastructure lemmas proved along the way:
- `locally_affine_imp_globally` — A locally affine function on a connected interval is globally affine
- `isolated_zeros_separated` — Between two isolated zeros of a CPL function, there must be a breakpoint
- `finite_of_separated_by_finset` — A set separated by a finite set is itself finite
- `cpl_isolated_zeros_finite` — The isolated zeros of a CPL function form a finite set

### Remaining Sorries (4)
The 4 remaining sorries are deep, interdependent results:
1. `cpl_is_tropical_rational` — Every CPL function is a tropical rational function
2. `exists_unique_minimal_tropical_rational` — Uniqueness of minimal tropical rational form
3. `minimal_tropical_rational_ext` — Extensionality for minimal tropical rationals
4. `relu_network_has_canonical_tropical_rational` — ReLU network canonical form existence

These require constructing tropical rational representations from CPL functions, which is the subject of Future Direction #1.

### `FUTURE_DIRECTIONS.md`
Contains 5 testable, falsifiable conjectures extending this work, including multivariate tropical convexity, Maslov dequantization for products, and a tropical Bézout theorem.