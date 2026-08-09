# Computational Evidence — Occurrences of numbers in Pascal's triangle

All numbers in this file come from *unverified* exploratory computation (a small Python
enumeration of Pascal's triangle) used only to choose which statements to formalize.
The verified artifacts of this project are the Lean theorems in `Catalog/Novelty/`;
nothing below should be read as a proof.

Notation: `mult t` is the number of pairs `(n,k)` with `C(n,k) = t` (Singmaster
multiplicity), counted over the whole infinite triangle. `mult 1 = ∞`; for `t ≥ 2`
the count is finite because `t` can only occur in rows `n ≤ t`.

## 1. Multiplicity distribution up to 10^6

Enumerating all binomial coefficients `C(n,k) ≤ 10^6`:

| multiplicity | count of `t ≤ 10^6` |
|---|---|
| 1 | 1  (`t = 2`) |
| 2 | 998266 |
| 3 | 10 |
| 4 | 1715 |
| 6 | 6 |
| 8 | 1  (`t = 3003`) |
| 5, 7 | 0 |

* `mult t ≥ 6` occurs exactly at `t ∈ {120, 210, 1540, 3003, 7140, 11628, 24310}`
  (`3003` is the unique value with multiplicity 8; the others have multiplicity 6).
* `#{t ≤ 10^6 : mult t ≥ 3} = 1732`.
* No `t ≤ 10^6` has multiplicity 5 or 7, matching the classical open problem.
* The *first* value of each multiplicity is `6` (mult 3), `10` (mult 4), `120` (mult 6),
  `3003` (mult 8).  These thresholds are now theorems: `min_value_of_six_le_mult`,
  `min_value_of_eight_le_mult` and companions in
  `Catalog/Novelty/SingmasterMinimalValues.lean`.
* A near-miss that shapes the proof of the `3003` threshold: `210 = C(10,4) = C(21,2)`
  has an occurrence in a column `≥ 4` *and* a second interior column, yet only
  multiplicity 6 — so a two-column argument cannot prove the threshold; three interior
  columns are genuinely needed (this is exactly how the first version of the formal
  finite search failed, and Lean's `decide` refuted it).

Formalized counterparts: `Catalog/Novelty/SingmasterDensity.lean`
(`card_highMult_le`, `eventually_high_mult_small`) proves
`#{t ≤ X : mult t ≥ 3} ≤ (√(2X)+2)(log₂X+1)`; at `X = 10^6` the bound evaluates to
`28320` against the true value `1732`, i.e. the proved bound has the right shape
(`X^{1/2+o(1)}`) and is loose by a factor ≈ 16.

## 2. Smoothness of high-multiplicity numbers

Prediction tested: if `mult t ≥ 3` then every prime `p ∣ t` satisfies `p(p−1) ≤ 2t`.
Checked for all `t ≤ 10^6` with `mult t ≥ 3`: **0 violations**.
Sample: `3003 = 3·7·11·13`, largest prime factor 13 with `13·12 = 156 ≤ 6006`;
`24310 = 2·5·11·13·17`, `17·16 = 272 ≤ 48620`.

Formalized: `prime_factor_bound_of_three_le_mult` and the contrapositive
`mult_eq_two_of_large_prime_factor` in `Catalog/Novelty/SingmasterSmoothness.lean`;
the higher-multiplicity refinement `C(p, m+1) ≤ t` when `mult t ≥ 2m+2` is
`choose_prime_le_of_mult` in `Catalog/Novelty/SingmasterSmoothHierarchy.lean`
(for `t = 3003` this forces every prime factor `≤ 17`, verified as
`prime_factor_le_seventeen_of_3003`).

## 3. Adjacent repetitions `C(n,k) = C(n−1,k+1)`

Search over `n < 4000`: the only solutions with `1 ≤ k`, `k+2 ≤ n` are

```
(n,k) = (15,5), (104,39), (714,272)      C = 3003, 61218182743304701891431482520, ...
```

with the next term `(4895, 1869)`. The row/column sequences are
`15, 104, 714, 4895, …` (products of alternate Fibonacci numbers,
`F_{2i+4}F_{2i+5}`) and `5, 39, 272, 1869, …` (`F_{2i+2}F_{2i+5}`); cf. OEIS
A001906/A001519-type Fibonacci-product families. Equivalently `5n+1` runs through the
Lucas numbers `L_9 = 76, L_13 = 521, L_17 = 3571, …`:

```
L: 2, 1, 3, 4, 7, 11, 18, 29, 47, 76, 123, 199, 322, 521, 843, 1364, 2207, 3571, ...
```

Formalized: `adjacent_iff_luc` (complete Lucas classification, via the Pell-like
equation `x² − xy − y² = ±5` and a descent, `luc_of_sol`) in
`Catalog/Novelty/AdjacentBinomialLucas.lean`, and the equivalent Fibonacci
parametrisation `adjacent_iff_fib` in `Catalog/Novelty/AdjacentBinomialFibonacci.lean`.
Each such solution gives multiplicity `≥ 6` (`six_le_mult_of_adjacent`), which is the
classical source of infinitely many numbers occurring at least six times; and
`adjacent_value_below_million` shows `3003` is the only such value below `10^6`.

## 4. Quality of the logarithmic bound

Catalog bound `mult t ≤ 2 log₂ t` versus the new bound
`mult t ≤ log₂ t + log₂(2 log₂ t + 1) + 1`:

| t | old bound | new bound | true `mult t` |
|---|---|---|---|
| 3003 | 22 | 16 | 8 |
| 24310 | 28 | 20 | 6 |
| ≈ 10^6 | 38 | 25 | ≤ 8 |

Formalized: `mult_le_log_add_log_log` and `mult_lt_two_mul_log`
(strict improvement for `t ≥ 2^16`) in `Catalog/Novelty/SingmasterSharpLog.lean`.

## 5. What the data does *not* support

No evidence was found for a value of multiplicity 5 or 7, nor for a second value of
multiplicity 8, up to `10^6` — but the searched range is far too small to be
suggestive either way, and none of these are claimed in Lean.
