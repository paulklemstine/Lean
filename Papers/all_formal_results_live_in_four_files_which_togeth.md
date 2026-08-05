# Computational evidence

All numbers below were produced with `#eval` inside the project (Lean's compiler
evaluation, *not* kernel-checked), using the definitions of
`Catalog/Applications/AffineSubspaceStats/AffineStats.lean`.  They guided the choice of the
theorems that are now formally proved in `Catalog/Geometry/AffineParity*.lean`; every claim
that appears as a theorem there is proved from first principles and does not rely on these
computations.  Statements in this file that are **not** matched by a theorem are explicitly
marked *(not verified)*.

## The quantities

For `n` (ambient dimension) and `D` (cube dimension) put

```
maxOP n D  =  max_{A ⊆ 𝔽₂ⁿ} P[ |cube ∩ A| is odd ]      (= AffineStats.maxOddProb n D)
bound n d  =  #{independent d-tuples in 𝔽₂ⁿ} / (2 · 2^{nd}),   d = D - 1
```

`bound` is the upper bound proved in `AffineParityGap.oddProb_le_indepRatio`; by
`AffineParityGap.indepRatio_eq_prod` it equals `(1/2)∏_{i<d}(1 - 2^{i-n})` when `d ≤ n`.

## Exhaustive search over all `2^{2ⁿ}` subsets

```lean
def maxOP (n D : ℕ) : ℚ :=
  ((univ : Finset (Vec n)).powerset).fold max 0 (fun A => oddProb n D A)
```

| `n` | `D` | `maxOP n D` | `bound n (D-1)` | equality? |
|---|---|---|---|---|
| 1 | 1 | `1/2`   | `1/2`   | yes |
| 1 | 2 | `0`     | `1/4`   | no  |
| 1 | 3 | `0`     | `0`     | yes (trivially) |
| 2 | 2 | `3/8`   | `3/8`   | **yes** |
| 2 | 3 | `0`     | `3/16`  | no  |
| 2 | 4 | `0`     | `0`     | yes (trivially) |
| 3 | 2 | `3/8`   | `7/16`  | no  |
| 3 | 3 | `21/64` | `21/64` | **yes** |

Two families of equality cases are visible, and both are now theorems:

* `n = D` (rows `(1,1)`, `(2,2)`, `(3,3)`): proved in
  `AffineParitySingleton.maxOddProb_full_eq`; a **single point** is extremal.
* `D = 2` with `n` even (row `(2,2)`): proved in `AffineParityBent.maxOddProb_two_eq`; the
  extremal sets are supports of **bent functions**.  Direct check in dimension 4 with the
  bent set `A = {x : x₀x₂ + x₁x₃ = 1}`:

  ```
  oddProb 4 2 A = 15/32 = bound 4 1 = 1/2 - 2^{-5}     ✓
  ```

* `D = 2` with `n` odd (rows `(1,2)`, `(3,2)`): equality *fails*, as proved in
  `AffineParityOdd.maxOddProb_two_lt_of_odd`.  Moreover the observed values are
  `0 = 1/2 - 2^{-1}` for `n = 1` and `3/8 = 1/2 - 2^{-3}` for `n = 3`, i.e. exactly
  `1/2 - 2^{-n}` — the basis for Conjecture 1 of `FUTURE_DIRECTIONS.md` *(not verified)*.

## Counting the extremal sets

```
#{A ⊆ 𝔽₂² : oddProb 2 2 A = 3/8}   = 8
#{A ⊆ 𝔽₂³ : oddProb 3 2 A = 3/8}   = 112
#{A ⊆ 𝔽₂³ : oddProb 3 3 A = 21/64} = 128
```

* `8` is the number of bent functions in `2` variables (OEIS A118437 begins
  `1, 8, 896, 5425430528` for `n = 0, 2, 4, 6`… bent functions in `n` variables), matching
  the theorem that for `D = 2`, `n` even, the extremal `A` are exactly the bent supports.
* `128 = 2^8 - 2^7` is the number of Boolean functions on `𝔽₂³` of degree exactly `3`.
  This suggested the general mechanism behind `AffineParitySingleton`: the `d`-th
  derivatives of a degree-`(d+1)` function are affine, and are nonconstant — hence balanced
  — exactly when the top-degree form is nondegenerate.  The singleton `{p}` is the support
  of `x₁x₂⋯x_n` up to translation.
* `112 = 2 · 7 · 8`: for `n = 3` the `7 · 8 = 56` pullbacks of the `8` bent functions on
  `𝔽₂²` along the `7` linear projections `𝔽₂³ → 𝔽₂²` are optimal, and a second family of
  `56` sets (with four autocorrelation deviations of size `2` instead of one of size `4`)
  makes up the rest *(not verified)*.  The observed cardinalities of the optimal sets are
  `{2, 4, 6}`.

## Sanity checks of the identities used

The two counting identities behind `AffineParityOdd` were checked on random subsets before
being formalised, and are now theorems (`dSet_card_add_autoCorr`, `sum_autoCorr`).  The
Diophantine consequence `(2|A| - 2ⁿ)² = 2ⁿ` predicts `|A| = (2ⁿ ± 2^{n/2})/2`; for `n = 2`
this gives `|A| ∈ {1, 3}`, and the `8` extremal sets found above do have cardinalities
`{1, 3}` (the `4` singletons and the `4` complements of singletons).  For `n = 3`, `D = 3`
the `128` extremal sets have cardinalities `{1, 3, 5, 7}`, i.e. exactly the odd ones, as the
theorem `AffineParityTopDim.oddProb_eq_max_iff` now asserts.

## Addendum: the odd-dimension construction

The exhaustive searches above gave `maxOddProb 3 2 = 3/8 = 1/2 - 2^{-3}`, one step below the
even-dimensional value `1/2 - 2^{-(n+1)} = 7/16`.  Inspecting an optimal set for `n = 3`
showed the pattern that became `Catalog/Geometry/AffineParityOddLower.lean`: exactly one
nonzero direction `w` has an empty derivative set `Δ_w` and all the other `2ⁿ - 2` nonzero
directions are balanced.  The pullback of a bent set of `𝔽₂^{n-1}` along the coordinate
projection has precisely this profile, and its odd-intersection probability is now proved
(not merely evaluated) to equal `1/2 - 2^{-n}` for every odd `n`
(`AffineParityOddLower.oddProb_liftSet`).

## Addendum: the flat model (this cycle)

The cube model draws all `D` direction vectors uniformly; the *flat* model conditions on the
direction tuple being linearly independent, i.e. draws a genuine affine `D`-flat.  Since a
degenerate tuple always gives an even intersection count
(`AffineParityGap.cnt_even_of_not_indep`), the two probabilities differ by the exact factor
`K_D / 2^{nD}`, where `K_D = ∏_{i<D}(2ⁿ - 2^i)` is the number of independent `D`-tuples.
This is now the theorem `AffineFlatModel.oddProb_eq_flatOddProb_mul`.

Compiler evaluations (`#eval`, not kernel-checked) used to check that identity and to
calibrate the new bound:

```
maxOddProb      3 2 = 3/8      (cube model,  known)
maxFlatOddProb  3 2 = 4/7      (flat model)
2^3/(2·(2^3-2))     = 2/3      (the proved flat upper bound at n = 3)
2^3/(2·(2^3-1))     = 4/7      (the proved flat lower bound at n = 3, odd n)
maxFlatOddProb  2 2 = 1
```

Consistency: `(3/8) · 2^{2·3} / K_2 = (3/8)·64/(7·6) = 4/7`, exactly the flat value, as the
identity predicts.  At `n = 3` the odd-dimension sandwich
`2ⁿ/(2(2ⁿ-1)) ≤ maxFlatOddProb n 2 < 2ⁿ/(2(2ⁿ-2))` reads `4/7 ≤ · < 2/3`, and the search says
the lower end is attained — the evidence for Conjecture 6 below.  Note `4/7 > 1/2`: unlike in
the cube model, the parity bound `1/2` is *false* in the flat model, and the sharp constant
`2ⁿ/(2(2ⁿ-2^{D-1}))` is attained by bent sets in even dimension
(`AffineFlatModel.flatOddProb_bentSet`).
