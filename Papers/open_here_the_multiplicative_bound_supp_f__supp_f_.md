# Computational evidence — additive uncertainty on `ZMod n`

All computations below were run with exact permutation combinatorics or double-precision
DFTs (tolerance `1e-9`) before the Lean formalisation.  They are *evidence*, not proof:
every claim that is asserted in the deliverable is proved in Lean without `sorry`
(see `Catalog/MachineLearning/PrimeUncertainty/`).

## 1. Minimum of `|supp f| + |supp f̂|` over 0/1 indicators

For each modulus `n` we minimised `|supp f| + |supp f̂|` over all `2^n − 1` nonempty
indicator functions.

| `n`  | min sum | `n + 1` | additive bound holds? |
|------|---------|---------|-----------------------|
| 3    | 4       | 4       | yes (tight)           |
| 4    | **4**   | 5       | **no** (`A = {0,2}`)  |
| 5    | 6       | 6       | yes (tight)           |
| 6    | **5**   | 7       | **no**                |
| 7    | 8       | 8       | yes (tight)           |
| 8    | **6**   | 9       | **no**                |
| 9    | **6**   | 10      | **no**                |
| 11   | 12      | 12      | yes (tight)           |
| 12   | **7**   | 13      | **no**                |

The minimum equals exactly `n + 1` for every prime in the range and drops strictly below
`n + 1` for every composite.  The extremal cases at a prime are `|supp f| = 1`
(Dirac delta) and `|supp f| = n` (character) — both are formalised as
`sum_bound_sharp_delta` and `sum_bound_sharp_character`.

The composite witness `n = 4`, `A = {0, 2}` (an index-2 subgroup, `|supp f| = |supp f̂| = 2`)
is formalised as `sum_bound_fails_zmod_four`.

## 2. Chebotarev test: minimum modulus of a DFT minor

Minimum of `|det (ω^{st})_{s∈S,t∈T}|` over all pairs of equal-size subsets:

| `n`  | min &#124;det&#124; | attained at |
|------|--------------|-------------|
| 4    | 0            | `S = T = {0,2}` |
| 5    | 1.000        | — |
| 6    | 0            | `S = {0,2}, T = {0,3}` |
| 7    | 0.868        | `S = {1,3}, T = {2,5}` |
| 8    | 0            | `S = {0,2}, T = {0,4}` |
| 9    | 0            | `S = {0,3}, T = {0,3}` |
| 11   | 0.316        | `S = {2,5,6,9}, T = {1,4,7,10}` |

Consistent with `chebotarev_iff_sumUncertainty`: singular minors exist exactly for the
composite moduli, i.e. exactly where the additive bound fails.

## 3. The parity-weighted exponent criterion

For every pair `(S, T)` of `n`-subsets we computed the coefficients

`c_r = #{σ even : ∑_j s_j t_{σ(j)} ≡ r} − #{σ odd : …}`  (mod `p`).

* `p = 5, 7` and `n = 3`; `p = 7, 11, 13` and `n = 4`; `p = 11`, `n = 5`:
  **no** pair ever produced `c ≡ 0`, in agreement with Chebotarev's theorem and with
  `chebotarev_criterion`.
* For `n = 3` **every** pair admits a permutation whose exponent is realised uniquely
  (`0` failures out of `100` for `p=5` and `1225` for `p=7`).  This is exactly the mechanism
  used by the Lean proof `det_fin_three_ne_zero`.
* For `n ≥ 4` uniqueness fails frequently (all `1225` pairs for `p = 7`, `12100/108900`
  for `p = 11`, `46644/511225` for `p = 13`), so the `n = 3` argument does **not** extend
  verbatim; the maximal `|c_r|` observed for `n = 4` ranges over `1 … 6`.  This is the precise
  obstruction discussed in `FUTURE_DIRECTIONS.md`.

## 4. Strictness of the product bound

`|supp f| · |supp f̂| ≥ p` allows `|supp f| = |supp f̂| = ⌈√p⌉`; e.g. for `p = 11` the pair
`(3, 4)` satisfies `12 ≥ 11` but `3 + 4 = 7 < 12`.  Formalised in general as
`product_bound_does_not_imply_sum_bound` (any `p ≥ 5`), with the converse implication
`product_bound_of_sum_bound` proved as well.
