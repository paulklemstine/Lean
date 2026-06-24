# Computational Evidence — EML Universal Approximation (this cycle)

Concise numerical sanity checks underpinning the two verified Lean files. The claims are
qualitative density statements, so the evidence targets the *decisive* finite mechanisms:
point separation by exponentials and the dimension obstruction for ridge features.

## 1. Exponential features separate points (1-D)
For distinct `x ≠ y`, `exp x ≠ exp y` since `exp` is strictly monotone. Sample:
| x | y | exp x | exp y | separated? |
|---|---|-------|-------|------------|
| 0 | 1 | 1.000 | 2.718 | yes |
| -1| 1 | 0.368 | 2.718 | yes |
| 0.5|0.5001|1.6487|1.6488| yes |
This is the finite core of `injective_expCM_comp` / `coord_exp_family_separates`.

## 2. Exponential monomials are linearly independent (Vandermonde / Wronskian)
The functions `e^{k x}` (k = 0..N) sampled at distinct nodes `x₀ < … < x_N` form an
exponential-Vandermonde matrix `Mₖⱼ = e^{k xⱼ}`. With `tⱼ = e^{xⱼ}` this is the classical
Vandermonde in the distinct positive `tⱼ`, hence `det = ∏_{i<j}(tⱼ − tᵢ) ≠ 0`.
Check (`N = 2`, nodes `0,1,2`, so `t = 1, e, e²`):
det = (e−1)(e²−1)(e²−e) ≈ 1.718 · 6.389 · 4.671 ≈ 51.3 ≠ 0.
This supports that `span{e^{kx}}` has full local rank — consistent with density
(`exp_monomials_span_dense`).

## 3. Ridge non-injectivity in dimension n ≥ 2 (sharpness)
For any weight `w`, the functional `x ↦ ⟨w, x⟩` on `ℝⁿ` (n ≥ 2) has a kernel vector.
Example `n = 2`, `w = (3, 5)`: take `v = (5, −3)`; then `⟨w, v⟩ = 15 − 15 = 0`, so
`x = 0` and `x = v` collide. Hence `exp(⟨w,·⟩)` also collides: `e⁰ = e⁰`.
Generic check: for random `w ∈ ℝ²`, `v = (w₂, −w₁)` always lies in the kernel.
This is the finite witness behind `ridge_not_injective` (proved via the dimension count
`finrank ℝⁿ = n ≤ finrank ℝ = 1`).

## 4. Necessity of n coordinate features (n = 2 spot check)
Using only `x ↦ e^{x₁}` cannot distinguish `(0,0)` from `(0,1)` (both give `e⁰ = 1`).
Adding `x ↦ e^{x₂}` distinguishes them (`e⁰ = 1` vs `e¹ = e`). Confirms that the full
coordinate family, not a strict subset, is needed — matching the positive/negative pair
`coord_exp_family_separates` + `ridge_not_injective`.

## OEIS / sequences
No integer sequence is intrinsic to these (continuous, qualitative) density results; the
only combinatorial datum is the exponential-Vandermonde determinant, which is a product
formula rather than a new sequence. No OEIS entry was pursued.

## Counterexample hunt
No counterexample to density was found: every finite test of point separation succeeded,
and the only "failure" (single ridge feature) is exactly the obstruction we formalized as
`ridge_not_injective`, confirming the hypothesis rather than refuting density.
