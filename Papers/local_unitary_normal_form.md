# Computational evidence — local-unitary normal form of sharp maximizers

All numbers below come from *exploratory* floating-point scripts (plain Python, no external
libraries) run before the formalization. They are **not** verified artifacts; the verified
statements are the theorems in `Catalog/Combinatorics/LocalUnitaryNormalForm.lean`, which build
with no `sorry` and use only the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

Setting: a two-qubit pure state is a matrix `M ∈ ℂ^{2×2}`, `‖M‖_F² = Σ|M_ij|²`,
concurrence `C(M) = 2|det M|`, marginal `ρ = M Mᴴ`, purity `tr ρ²`.

## 1. The bound `2|det M| ≤ ‖M‖_F²` (small-case / random search)

| experiment | samples | result |
|---|---|---|
| minimum of `‖M‖_F² − 2|det M|` over normalized complex Gaussian matrices | 200 000 | `1.57e-04 > 0` (no violation) |
| the same quantity for `M = U/√2`, `U` unitary | 3 exact constructions | `0` to 12 decimals (equality attained) |

The minimum over random samples is positive but can be made arbitrarily small, which is exactly
what one expects from a *sharp* inequality whose equality set is a positive-codimension
submanifold. Formalized as `two_mul_norm_det_le_frobSq` and `concurrence_le_one`.

## 2. Equality forces a maximally mixed marginal

| experiment | samples | result |
|---|---|---|
| normalized samples with `|C(M) − 1| < 1e−6` that violate `ρ = I/2` (tolerance `1e−5`) | 50 000 | `0` counterexamples |
| `ρ` and purity for `M = U/√2` | 3 | `tr ρ² = 0.500000000000` |

Formalized as `rowGram_of_sharp` / `sharp_iff_rowGram` (row classification) and
`sqrtTwo_smul_mem_unitaryGroup` (`√2·M` is unitary), which give the normal form
`sharp_iff_localAct_bell`.

## 3. Flat maximizers = complex Hadamard matrices of order two

Sampling the three-phase family `h = [[e^{iα}, e^{iβ}], [e^{iγ}, −e^{i(β+γ−α)}]]`, `M = h/2`:

| experiment | samples | result |
|---|---|---|
| all members normalized **and** of concurrence 1 (tolerance `1e−9`) | 20 000 | `True` |

This is the dephasing formula `M₁₁ = −M₀₁M₁₀/M₀₀` proved in `flat_sharp_dephase`, i.e. every
order-two complex Hadamard matrix is `D₁ F₂ D₂`.

## 4. Real sign patterns: an exact finite count

Enumerating all `16` matrices `(1/2)·(±1)_{2×2}`:

```
real sign patterns with concurrence 1: 8 out of 16
patterns: (1,1,1,-1) (1,1,-1,1) (1,-1,1,1) (1,-1,-1,-1)
          (-1,1,1,1) (-1,1,-1,-1) (-1,-1,1,-1) (-1,-1,-1,1)
```

This is the sequence "number of `2×2` sign matrices with orthogonal rows"; the count `8 = 2³`
matches the diagonal-sign orbit `{±1}³ · F₂`. Formalized (and hence verified) as
`signMat_sharp_iff` together with `card_sharp_signMats`.

## 5. Linear-entropy identity

| experiment | samples | result |
|---|---|---|
| `max |C(M)² − 2(1 − tr ρ²)|` over normalized complex Gaussian matrices | 50 000 | `2.5e−15` (floating-point noise) |

Formalized as `concurrence_sq_eq_two_mul_linearEntropy`, with the corollaries
`sharp_iff_purity` and `half_le_purity`.

## OEIS

No new integer sequence arises: the only count produced here is the single number `8`
(sign patterns), which is the order of the diagonal sign group `{±1}³` acting on `F₂`; we did
not find, and do not claim, an OEIS entry specific to this computation.
