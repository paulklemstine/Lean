# Computational evidence

All computations below use the winnability criterion that is *proved* in
`Catalog/Combinatorics/CompleteGraphWinnable.lean`
(`TropicalRR.winnable_top_iff`):

> On `K_n` a divisor `A` is linearly equivalent to an effective divisor **iff**
> there is an integer shift `S` with `S ≤ ∑_v ⌊(A v + S) / n⌋`,
> and (by `sum_ediv_add_period`) it is enough to test `S` in one window of length `n`.

Because the criterion is a theorem, the brute-force enumeration below is a faithful
computation of the Baker–Norine rank
`r(D) = max { k : ∀ E ≥ 0 with deg E = k, D − E is winnable }`.

*These enumerations are exploratory scripts, not Lean artefacts; the statements
that are actually certified are the Lean theorems listed at the end.*

## 1. The uniform divisor `m · 1` on `K_n`

Rank computed by exhaustive enumeration of all effective test divisors.

| `n \ m` | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| 2 | 0 | 2 | – | – | – |
| 3 | 0 | 2 | 5 | – | – |
| 4 | 0 | 2 | 5 | 9 | – |
| 5 | 0 | 2 | 5 | 9 | 14 |
| 6 | 0 | 2 | 5 | 9 | 14 |
| 7 | 0 | 2 | 5 | 9 | 14 |

(entries only for `m + 1 ≤ n`).  The row is constant in `n`, and equals

```
0, 2, 5, 9, 14, 20, 27, …   =   m(m+3)/2
```

which is **OEIS A000096** (`n(n+3)/2`).  This is now the theorem
`TropicalRR.rank_const_top`.

The minimal *failing* test divisor found in every case is the monotone staircase
`(m+1, m, …, 1, 0, …, 0)` of degree `(m+1)(m+2)/2 = m(m+3)/2 + 1`, formalised as
`TropicalRR.stairE`.

## 2. The maximum rank at the half-canonical degree `d = g − 1`

Exhaustive search over all effective divisors of degree `g − 1`, up to relabelling.

| `n` | `g` | `d = g−1` | max rank | argmax | `m = ⌊(n−3)/2⌋`, `m(m+3)/2` |
|---|---|---|---|---|---|
| 3 | 1 | 0 | 0 | `(0,0,0)` | 0, 0 |
| 4 | 3 | 2 | 0 | `(0,0,0,2)` | 0, 0 |
| 5 | 6 | 5 | 2 | `(0,0,0,0,5)` | 1, 2 |
| 6 | 10 | 9 | 2 | `(0,0,0,0,0,9)` | 1, 2 |

So the half-canonical maxima start `0, 0, 2, 2, …`, consistent with the value
`m(m+3)/2` of the uniform theta characteristic (`rank_const_top` at `n = 2m+3`).

## 3. Counterexample hunt: the conjectured closed formula

The previously conjectured formula for the maximum rank in degree `d` on `K_n`,
`a(a+1)/2 + min(b, a)` where `d = a(n−1) + b`, was tested against the concentrated
divisor `d · q` for `2 ≤ n ≤ 6`, `0 ≤ d ≤ 13`:

| `n` | `d` | rank of `d·q` | formula |
|---|---|---|---|
| 3 | 5 | 4 | 4 |
| 3 | **6** | **5** | **6** |
| 3 | 8 | 7 | 10 |
| 4 | 12 | 9 | 10 |
| 5 | 13 | 7 | 7 |

The formula **fails** as soon as `d` exceeds the canonical degree `2g − 2`: for
`n = 3`, `d = 6` it predicts `6`, while Riemann–Roch forces every degree-`6`
divisor on `K_3` (genus `1`) to have rank `6 − 1 = 5`.  This is now the theorem
`TropicalRR.no_divisor_attains_concFormula_K3`.  In the range `d ≤ g − 1` no
counterexample was found (§2).

## 4. The staircase formula for divisors in the window `0 ≤ D i ≤ n − 1`

For every `n ≤ 6` and **every** divisor `D : Fin n → {0, …, n−1}` (that is
`2^… = 4 + 27 + 256 + 3125 + 46656` tuples) we compared the rank with

```
stairDeg D − 1 ,    stairDeg D = ∑_i max(0, D i − i + 1).
```

* `r(D) ≤ stairDeg D − 1` held in **all** cases (0 failures) — now the theorem
  `TropicalRR.rank_le_stairDeg`;
* for the `636` *nondecreasing* `D` in that range, `r(D) = stairDeg D − 1`
  **exactly** (0 failures).  The equality is Conjecture 1 of
  `FUTURE_DIRECTIONS.md`; its `≤` half and the constant case of its `≥` half are
  theorems in this cycle.

Sample (`n = 6`):

| `D` | `stairDeg D − 1` | rank |
|---|---|---|
| `(1,1,1,1,1,1)` | 2 | 2 |
| `(1,1,1,2,3,4)` | 2 | 2 |
| `(2,2,2,2,3,4)` | 5 | 5 |
| `(0,0,0,0,0,5)` | 1 | 1 |

The middle two rows are covered by the new theorem
`TropicalRR.rank_eq_uniformRank_of_staircase_dominated`.

## What is certified in Lean (0 sorries)

* `winnable_top_iff`, `not_winnable_top_of_window`, `sum_window_ediv_ge`;
* `rank_const_top` : `r(m·1) = m(m+3)/2` on `K_n` for `n ≥ m+1`;
* `two_mul_rank_const_top_complete` : the rank of *every* uniform divisor on
  *every* complete graph;
* `not_winnable_stairFloor`, `rank_le_stairDeg` : the general staircase obstruction;
* `rank_mono`, `rank_sandwich_top`, `rank_eq_uniformRank_of_staircase_dominated`;
* `four_mul_rank_gt_genus_top`, `rank_const_top_gt_regularity`,
  `thetaChar_const_top`;
* `no_divisor_attains_concFormula_K3` (the counterexample of §3).
