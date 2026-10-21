# Computational evidence — round 43, adaptive B

All numbers below were computed with Lean `#eval` while developing
`Catalog/MachineLearning/AdaptiveBOracleOnly.lean` (they are exploratory; the
*theorems* in that file are the verified statements).

## 1. Root counts (supports `card_sq_roots_eq_two`)
`N = 1000000016000000063 = (10^9+7)(10^9+9)`.  Number of roots of `x² ≡ N (mod p)`:

| p | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 |
|---|---|---|---|----|----|----|----|----|----|----|----|
| roots | 0 | 0 | 0 | 2 | 2 | 0 | 0 | 2 | 0 | 0 | 0 |

Always 0 or 2 for odd `p ∤ N`, never 1 — no counterexample.

## 2. Paid touch vs closed form (supports `abs_paidTouch_sub_qs_closedForm_le`)
Same `N`, sieve length `M = 20000`, `S` = factor base (2 plus split odd primes ≤ B).

| B | |S| | paid touch | `2MΣ_odd 1/p + M/2` | abs. dev. | proved bound `2|S|−1` |
|---|----|-----------|---------------------|-----------|-----------------------|
| 150 | 13 | 22942 | 22942.10 | 0.10 | 25 |
| 500 | 45 | 26996 | 26995.78 | 0.22 | 89 |
| 1000 | 76 | 28681 | 28679.84 | 1.16 | 151 |

The proved bound is worst-case (each class error < 1); the observed deviation
is far smaller because rounding errors cancel. Round-43's reported max relative
deviation `2.01e-4` is consistent with the proved bound `(2|S|−1)/closed form`.

## 3. Oracle / rule data (from round-43 assignment, not re-run here)
oracle `0.9533×` vs best fixed B=9600, 102/120 improved, **0/120 worsened**
(forced by `oracle_pointwise_le`); held-out free rules `1.0047×`, `1.0290×`
(the second consistent with `train_fit_rule_can_lose_on_test`).

## 4. Q vs m
Measured `d log Q / d log m = 0.99718 ± 0.03722`.  `elasticity_bounds` and the
secant theorems give `1 ≤ slope ≤ 1 + c/Q`; with `c ≤ 2` and `Q` in the
hundreds this is `1.000–1.01`, inside the measured error bar.  The measured
sub-1 slopes (range down to 0.923) are therefore noise / instance effects, not
structure.

## OEIS
No integer sequence of interest arises (data are cost measurements).
