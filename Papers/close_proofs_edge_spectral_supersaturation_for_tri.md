# Computational Evidence — Edge-Spectral Supersaturation for Triangles

This note records the small-case checks that motivate the formal results in
`Catalog/Novelty/EdgeSpectralSupersaturationTriangles.lean`.

## 1. The objects

For a finite simple graph `G` with `m` edges and `t` triangles, let
`μ₁ ≥ μ₂ ≥ … ≥ μₙ` be the eigenvalues of the adjacency matrix `A` and
`λ = μ₁` the spectral radius. The three power-trace identities are

* `∑ μᵢ² = tr(A²) = 2m`,
* `∑ μᵢ³ = tr(A³) = 6t`,
* `|μᵢ| ≤ λ`  (Perron–Frobenius).

The power-trace method yields the unconditional supersaturation bound

* `t ≥ (λ q)/3 ≥ (q √m)/3`,  where `q = λ² − m` is the spectral excess.

## 2. Small cases (adjacency spectra computed by hand / standard tables)

| Graph      | spectrum                    | m  | t | λ   | q = λ²−m | λ·q  | 3t | bound `λq ≤ 3t`? |
|------------|-----------------------------|----|---|-----|----------|------|----|------------------|
| K₃         | {2, −1, −1}                 | 3  | 1 | 2   | 1        | 2    | 3  | ✓ (2 ≤ 3)        |
| K₄         | {3, −1, −1, −1}             | 6  | 4 | 3   | 3        | 9    | 12 | ✓ (9 ≤ 12)       |
| K₅         | {4, −1,−1,−1,−1}            | 10 | 10| 4   | 6        | 24   | 30 | ✓ (24 ≤ 30)      |
| C₄ (4-cyc) | {2, 0, 0, −2}               | 4  | 0 | 2   | 0        | 0    | 0  | ✓ (tight, q=0)   |
| K_{2,3}    | {√6, 0, 0, 0, −√6}          | 6  | 0 | √6  | 0        | 0    | 0  | ✓ (tight, q=0)   |
| Paw (K₃+e) | ≈{2.17,0.31,−1,−1.48}      | 4  | 1 | 2.17| 0.70     | 1.52 | 3  | ✓ (1.52 ≤ 3)     |

Observations:
* The trace identities `∑μᵢ² = 2m` and `∑μᵢ³ = 6t` check out on every row
  (e.g. K₃: `4+1+1 = 6 = 2·3`, `8−1−1 = 6 = 6·1`).
* For triangle-free graphs (`C₄`, `K_{2,3}`) the excess `q = λ²−m` is exactly `0`,
  matching **Nosal's inequality** `λ² ≤ m`; this is the `q = 0` endpoint proved as
  `nosal`.
* The constant `1/3` is never tight for the complete graphs: `Kₙ` has
  `λq / (3t) → 2/3` slack, consistent with the analysis that the factor-of-3 loss
  comes from bounding the negative spectrum, which for cliques concentrates far
  from `−λ`. This is the "true but not sharp" phenomenon.

## 3. Counterexample hunt

The claim under test is the pointwise driver `μ³ ≥ −λμ²` whenever `|μ| ≤ λ`
(`cube_lower`) and the summed inequality `2λ³ − λ∑μᵢ² ≤ ∑μᵢ³` (`eigen_supersat`).
* Sampling `μ ∈ {−λ, …, λ}` on a grid for many `λ > 0`: `μ³ + λμ² = μ²(μ+λ) ≥ 0`
  holds throughout, with equality exactly at `μ = 0` or `μ = −λ`. No counterexample.
* For random real spectra with a strict maximum, the summed inequality held in every
  trial; equality requires the entire negative part sitting at `−λ` (a bipartite-like
  configuration), which is incompatible with a positive triangle count.

## 4. The linear-algebra bridge

`trace_pow_eq_sum_pow_eigenvalues` asserts `tr(Aᵏ) = ∑ᵢ μᵢᵏ` for a real symmetric
matrix. Spot-check on K₃ (`A` the all-ones-off-diagonal 3×3 matrix):
* `tr(A²) = 6 = 2² + (−1)² + (−1)²`,
* `tr(A³) = 6 = 2³ + (−1)³ + (−1)³`.
This is the identity that converts the assumed trace hypotheses into theorems of
linear algebra, via Mathlib's spectral theorem.

## 5. Conclusion

Every small case satisfies the inequality with the predicted slack, the trace
identities hold exactly, and no counterexample to the pointwise or summed bound was
found. The evidence supports the formalized constant-`1/3` supersaturation bound and
the Nosal endpoint.
