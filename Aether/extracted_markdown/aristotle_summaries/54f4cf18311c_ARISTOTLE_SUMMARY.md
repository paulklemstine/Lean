# Summary of changes for run 1faf0627-c8ea-48a1-9d4b-d4ec30af8d1c
Created a self-contained, fully verified Lean 4 file `Catalog/Tropical/FermatCore.lean` (module `Tropical.FermatCore`) developing a conservative core of the tropical (min-plus) Fermat equation over `ℤ`. The file compiles cleanly with no `sorry`s; every theorem was checked to depend only on the standard axioms `propext`, `Classical.choice`, and `Quot.sound`.

Contents:

1. Tropical operations on `ℤ`: `tadd a b = min a b`, `tmul a b = a + b`, `tpow a n = (n:ℤ)*a`, with definitional simp lemmas. Proved commutativity/associativity of `tadd` and `tmul` (`tadd_comm`, `tadd_assoc`, `tmul_comm`, `tmul_assoc`), both distributive identities (`tmul_tadd`, `tadd_tmul`), and the reusable min characterization `eq_min_iff : z = min x y ↔ z ≤ x ∧ z ≤ y ∧ (z = x ∨ z = y)` (plus a `tadd` form).

2. Binary tropical Fermat equation `TropFermatEq n x y z := tadd (tpow x n) (tpow y n) = tpow z n`, with the exponent split handled explicitly:
   - `tropFermat_zero`: for `n = 0` the equation holds for all `x, y, z`;
   - `tropFermat_pos_iff`: for `0 < n`, equivalent to `z = min x y` (proved via strict positivity of `(n:ℤ)`, using `mul_min_of_nonneg` and `mul_left_cancel₀` so multiplication by `(n:ℤ)` both preserves and reflects order);
   - `tropFermat_pos_iff_order`: the order-theoretic form `↔ z ≤ x ∧ z ≤ y ∧ (z = x ∨ z = y)`.
   Exponent-independence is deliberately not claimed without `0 < n`.

3. One-variable tropical polynomials as `List (ℤ × ℤ)` of `(slope, intercept)` terms, with affine evaluation `affEval` and a clean three-clause recursive `tropEval` (pointwise minimum). Proved `tropEval_le_of_mem` (each term is an upper bound), `tropEval_mem` (value attained on nonempty support), `tropEval_isLeast` (the value is the least affine value, i.e. the pointwise minimum), and `tropEval_mono` (monotonicity under nonnegative slopes).

4. Connection lemmas: `tropFermat_as_poly` identifies `x ↦ min ((n:ℤ)*x) ((n:ℤ)*y)` as evaluation of the concrete polynomial `[(n,0),(0,n*y)]`, and `tropFermat_poly_iff` restates the positive-exponent classification through that polynomial evaluation.

The file includes a module docstring explaining the min-plus convention and the `n = 0` / `0 < n` split, and per-declaration docstrings. Note: the project's `lakefile.toml` is missing a `srcDir = "Catalog"` setting so `lake build` cannot locate any of the catalog files (none have ever been built); I left the build configuration untouched and verified the new file independently in the Lean/Mathlib toolchain, confirming it elaborates with no errors, no sorries, and only standard axioms.