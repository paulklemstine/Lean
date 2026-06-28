# Computational Evidence

Concise numerical support for the theorems in this directory.

## 1. Dirichlet bound `Lc x ≤ 1` (file `LagrangeConstantBridge.lean`)

The Lagrange constant is `Lc x = liminf_{q→∞} q·‖q·x‖`, where `‖·‖` is the
distance to the nearest integer.  For `x = √2`, evaluating `q·‖q·x‖` along the
continued-fraction convergents `p/q` of `√2`:

| p   | q   | q·‖q·√2‖ |
|-----|-----|----------|
| 1   | 1   | 0.41421  |
| 3   | 2   | 0.34315  |
| 7   | 5   | 0.35534  |
| 17  | 12  | 0.35325  |
| 41  | 29  | 0.35361  |
| 99  | 70  | 0.35354  |
| 239 | 169 | 0.35355  |

The sequence converges to `1/(2√2) ≈ 0.35355`, comfortably below `1`.  This is
consistent with `Lc_le_one_of_irrational` (every irrational has `Lc ≤ 1`) and in
fact below the Hurwitz threshold `1/√5 ≈ 0.4472`, illustrating that the `≤ 1`
bound is far from tight for quadratic irrationals.  Computed with
`#eval` over `Float`-valued convergents.

## 2. Denominator unboundedness (`DiophantineApproximation.lean`)

The convergents `1/1, 3/2, 7/5, 17/12, 41/29, 99/70, 239/169, …` of `√2` have
strictly increasing denominators `1 < 2 < 5 < 12 < 29 < 70 < 169 < …`, each
satisfying `|√2 − p/q| < 1/q²`.  This is the finite-sample shadow of
`irrational_den_unbounded`: arbitrarily large denominators occur among the
Dirichlet-good approximations.

## 3. Liouville vanishing constant (`LagrangeConstantBridge.lean`)

For the Liouville number `L = Σ 10^{−k!}`, the truncations `a_n / 10^{n!}` give
`|L − a_n/b_n| < 1/b_n^{n}` with denominators `b_n = 10^{n!}` growing as
`10^{1}, 10^{1}, 10^{2}, 10^{6}, 10^{24}, …` (since `n! = 1,1,2,6,24,…`).
Then `b_n·‖b_n·L‖ < b_n · b_n / b_n^{n} = 1/b_n^{n−2} → 0`, so the Lagrange
constant collapses to `0`, matching `Lc_eq_zero_of_liouville`.

## 4. Counterexample hunt

* `Lc x ≤ 1` for irrationals: no counterexample possible — Dirichlet guarantees
  `q·‖q·x‖ < 1` infinitely often.  The rational `x = 1/2` has `Lc = 0` as well
  (eventually `‖q·x‖ = 0`), so the bound is not specific to irrationals, but the
  catalog framing is about irrational `x` where `Lc > 0` is possible.
* Liouville quadratic non-root: tested that `transcendental_liouvilleNumber`
  numbers are never roots of small integer quadratics; consistent with
  `liouville_not_root_quadratic`.

All formal statements are verified in Lean with only the standard axioms
`propext, Classical.choice, Quot.sound`.
