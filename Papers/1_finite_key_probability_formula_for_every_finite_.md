# Computational evidence

Exploratory (not Lean-verified) enumeration used to sanity-check the statements
before formalizing them in `Catalog/Combinatorics/BernoulliThresholdCoupling.lean`
and `Catalog/Combinatorics/FiniteRussoFormula.lean`.  All numbers below come from
brute-force enumeration of the `2^(n^2)` site configurations of the `n × n` grid
with the nearest-neighbour adjacency of `gridGraph n`, using the same crossing
event as `HasHorizontalCrossing n` (an open path from the column `first
coordinate = 0` to the column `first coordinate = n-1`).  The Lean statements
themselves are proved for all finite site sets and all `n`, so these tables are
only a consistency check.

## 1. Crossing probability polynomials (small grids)

Coefficients are the numbers of crossing configurations with exactly `k` open
sites; the probability is `∑_k c_k p^k (1-p)^{n^2-k}`.

| n | (c_0, c_1, …, c_{n²}) | #crossing configs |
|---|------------------------|-------------------|
| 1 | (0, 1) | 1 |
| 2 | (0, 0, 2, 4, 1) | 7 |
| 3 | (0, 0, 0, 3, 22, 59, 67, 36, 9, 1) | 197 |

Values of the crossing probability:

| n | p=0.1 | p=0.3 | p=0.5 | p=0.7 | p=0.9 |
|---|-------|-------|-------|-------|-------|
| 1 | 0.1 | 0.3 | 0.5 | 0.7 | 0.9 |
| 2 | 0.0199 | 0.1719 | 0.4375 (=7/16) | 0.7399 | 0.9639 |
| 3 | 0.003332 | 0.094947 | 0.384766 (=197/512) | 0.769565 | 0.986265 |

Each row is strictly increasing in `p`, consistent with
`crossing_prob_strictMono` / `crossing_bernProb_strictMono`.

## 2. Russo's formula check

At `p = 1/2` the central difference quotient (step `10^{-3}`) of the crossing
polynomial is compared with the sum over the `n^2` sites of the pivotal
probabilities `P(v is pivotal)`:

| n | numerical derivative | ∑_v P(v pivotal) |
|---|----------------------|------------------|
| 1 | 1.000000 | 1 |
| 2 | 1.499998 | 3/2 |
| 3 | 1.878901 | 1.87890625 = 961/512 |

The agreement (to the accuracy of the difference quotient) matches
`hasDerivAt_bernProb`.

## 3. Counterexample hunt

* Monotonicity in `p` of the crossing probability: checked on a grid of 101
  equally spaced values of `p` for `n = 1, 2, 3`; no violation.
* The strictness construction used in the Lean proof (corner key in `(p,q]`,
  rest of one column below `p`, all other keys above `q`) was verified by
  enumeration for `n = 1, 2, 3` with `p = 3/10`, `q = 3/5`: the resulting
  configuration crosses at level `q` and does not cross at level `p`.
* The finite-key probability formula `P(siteThresholdConfig key p = η) =
  p^{|open|}(1-p)^{|closed|}` was checked by Monte-Carlo sampling of uniform
  keys for `n = 2` at `p = 0.37` (2·10^5 samples, all 16 configurations): the
  largest deviation between empirical frequency and the formula was `0.00097`.

## 4. OEIS

The crossing counts `1, 7, 197` (number of site configurations of the `n × n`
grid admitting a left-right open crossing) were searched; no confident OEIS
match is claimed here.

## 5. Harris/FKG check (added in the present cycle)

Exploratory (not Lean-verified) brute-force check of the positive correlation
between the horizontal crossing event of the `n × n` grid and the event that the
corner site `(0,0)` is open, for the exact Bernoulli weights:

| n | p | P(cross) | P(cross ∩ corner open) | P(cross)·p | inequality holds |
|---|-----|-----------|------------------------|------------|------------------|
| 1 | 1/4 | 1/4       | 1/4                    | 0.0625     | yes |
| 1 | 1/2 | 1/2       | 1/2                    | 0.25       | yes |
| 2 | 1/4 | 31/256    | 19/256                 | 0.030273   | yes |
| 2 | 1/2 | 7/16      | 5/16                   | 0.21875    | yes |
| 2 | 3/4 | 207/256   | 171/256                | 0.606445   | yes |
| 3 | 1/4 | 14473/262144 | 1723/65536          | 0.013803   | yes |
| 3 | 1/2 | 197/512   | 61/256                 | 0.192383   | yes |
| 3 | 3/4 | 222507/262144 | 43443/65536        | 0.636598   | yes |

The crossing probabilities agree with the table of Section 1 (7/16, 197/512),
and in every case `P(cross) · p ≤ P(cross ∩ corner open)`, consistent with the
Lean theorem `crossing_harris_open_site`.  The correlation is strict for
`n ≥ 2`, which is the source of Conjecture 3 in `FUTURE_DIRECTIONS.md`.
