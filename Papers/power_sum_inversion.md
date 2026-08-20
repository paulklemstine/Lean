# Computational evidence — power-sum inversion

All numerical claims below were re-checked *inside Lean* (they appear as compiling lemmas or
`example`s in `Catalog/Applications/PowerSumInversion.lean`), so nothing here rests on an
unchecked scratch computation.

## 1. The inverse rows for small `N`

The inversion matrix `vanInv N v k` is the `k`-th coefficient of the Lagrange basis
polynomial `L_v` of the nodes `0, 1, …, N` over `ℚ`.

| `N` | `v` | `L_v`             | row `(k = 0 … N)` | `Λ_N(v) = ∑_k |vanInv N v k|` |
|-----|-----|-------------------|-------------------|-------------------------------|
| 1   | 0   | `1 - X`           | `1, -1`           | `2`                           |
| 1   | 1   | `X`               | `0, 1`            | `1`                           |
| 2   | 0   | `(X-1)(X-2)/2`    | `1, -3/2, 1/2`    | `3`                           |
| 2   | 1   | `2X - X²`         | `0, 2, -1`        | `3`                           |
| 2   | 2   | `(X² - X)/2`      | `0, -1/2, 1/2`    | `1`                           |

Lean-verified instances: `lagBasis_one_zero` (`L_0 = 1 - X` at `N = 1`),
`lagBasis_two_one` (`L_1 = 2X - X²` at `N = 2`), and the `example`s computing
`vanInv 1 0 · = (1, -1)`, `vanInv 2 1 · = (0, 2, -1)` and `lebesgueConst 1 0 = 2`.

## 2. A worked inversion

Take `N = 2` and `f = (0, 1, 1) : Fin 3 → ℕ`.  Then `p_0 = 3`, `p_1 = 2`, `p_2 = 2`
(`powerSumFun ![0,1,1] 2 = 2` is checked by `decide`), and the row for `v = 1` gives

`0·3 + 2·2 + (-1)·2 = 2 = #{i | f i = 1}`   (`countFun ![0,1,1] 1 = 2`, checked by `decide`).

The general instance is the `example` closing with `count_eq_sum_vanInv_powerSum`.

## 3. Counterexample hunt (window `k ≤ N` versus `k < N`)

Search over multiplicity vectors on `{0,…,N}`:

| `N` | multiplicities `≤ M` | pairs with equal `p_k`, `k ≤ N` | pairs with equal `p_k`, `k < N` | minimal witness |
|-----|----------------------|---------------------------------|---------------------------------|------------------|
| 1   | 2                    | none (other than equal pairs)   | present                         | `{0}` vs `{1}`   |
| 2   | 3                    | none                            | present                         | `{0,2}` vs `{1,1}` |
| 3   | 3                    | none                            | present                         | `{0,2,2,2}` vs `{1,1,1,3}` |

The "none" column is not merely empirical: it is the theorem `count_eq_of_powerSums`, which
is proved for all `N` and all bounded functions.  The witnesses in the last column are the
binomial parity pairs `evenPart N` / `oddPart N` of `Shared/PowerSumSharpness.lean`; they are
transported to the function setting in `powerSums_below_top_insufficient`.

## 4. Sparse node sets

The nodal weight recipe of `Catalog/Applications/PowerSumInversionSharp.lean` produces the
extremal near miss on *any* node set `A`:

| `A`        | nodal weights `w_a = ∏_{b≠a}(a-b)⁻¹` | cleared vector `z` | witness pair              |
|------------|---------------------------------------|--------------------|---------------------------|
| `{0,1,2}`  | `1/2, -1, 1/2`                        | `(1,-2,1)`         | `{0,2}` vs `{1,1}`        |
| `{0,1,5}`  | `1/5, -1/4, 1/20`                     | `(4,-5,1)`         | `{0,0,0,0,5}` vs `{1,1,1,1,1}` |

For `A = {0,1,5}` both members have `p_0 = 5` and `p_1 = 5`, and their value distributions
differ — matching `powerSums_below_card_insufficient` with `#A - 1 = 2`.  The positive
counterpart `count_eq_of_powerSums_sparse` says three power sums always suffice here, even
though the largest value is `5`.

## 5. OEIS

No new integer sequence is produced by this development.  The two sequences that do occur —
the alternating binomial kernel `(-1)^j C(N,j)` and the factorial gap `N!` — are already
identified in the catalog file `Shared/PowerSumSharpness.lean`, so no OEIS lookup is claimed
here.
