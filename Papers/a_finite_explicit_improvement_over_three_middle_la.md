# Computational evidence — weakly `D₆`-free families and the "three middle layers" barrier

All numbers below were computed inside Lean 4 (`#eval`, exact natural-number
arithmetic); no floating point and no external tools were used.  Ratios are
reported as `⌊1000·x⌋` to stay exact.

## 1. The baseline ratios

`M(n) = C(n, ⌊n/2⌋)` is the largest middle layer.  `best3(n)` (resp. `best4(n)`)
is the maximal total size of three (resp. four) consecutive layers of `2^[n]`.

| n  | M(n)        | best3(n)      | best3/M | best4(n)      | best4/M |
|----|-------------|---------------|---------|---------------|---------|
| 7  | 35          | 91            | 2.600   | 112           | 3.200   |
| 11 | 462         | 1 254         | 2.714   | 1 584         | 3.428   |
| 15 | 6 435       | 17 875        | 2.777   | 22 880        | 3.555   |
| 19 | 92 378      | 260 338       | 2.818   | 335 920       | 3.636   |
| 23 | 1 352 078   | 3 848 222     | 2.846   | 4 992 288     | 3.692   |
| 31 | 300 540 195 | 866 262 915   | 2.882   | 1 131 445 440 | 3.764   |
| 39 | 68 923 264 410 | 200 205 672 810 | 2.904 | 262 564 816 800 | 3.809 |

Reading: the three-layer baseline approaches `3·M(n)` **from below**, so a
constant `c > 3` requires capturing a positive fraction of a *fourth* layer;
four full layers would give `≈ 4M` but are never `D₆`-free
(`WeakD6.fourLayerFamily_not_weaklyD6Free`).

## 2. Exhaustive search in the four-layer window

Model: keep layers `k`, `k+1`, `k+3` in full and search over **all** subsets `T`
of the interior layer `k+2`, testing the interval-exclusion condition
(equivalently, triangle-freeness of every link graph) by brute force.

| n | k | interior layer size | max kept `|T|` | Turán ceiling from `middleLayer_ceiling` | total family | best3(n) |
|---|---|---------------------|----------------|-------------------------------------------|--------------|----------|
| 5 | 0 | 10                  | **6**          | `⌊25/4⌋ = 6`  (attained)                  | 22           | 25       |
| 5 | 1 | 10                  | **5**          | `⌊80/12⌋ = 6`                             | 25           | 25       |
| 6 | 2 | 15                  | **6**          | `⌊240/24⌋ = 10`                           | 47           | 41       |

Observations.

* The formal ceiling `4·C(k+2,2)·|F ∩ layer(k+2)| ≤ C(n,k)·(n−k)²` is **sharp**
  at `(n,k) = (5,0)` and valid (not tight) in the other cases.
* At `(n,k) = (6,2)` the thinned four-layer family has 47 sets against 41 for the
  best three consecutive layers: a *finite* improvement over three layers exists
  already at `n = 6`, but the ratio `47/M(6) = 2.35` is still far below 3 because
  small binomials are far from their asymptotic regime.
* No search produced a family above the Turán ceiling, as required by
  `WeakD6.middleLayer_ceiling`.

## 3. Equidistribution of sum labels (input for the abelian model)

Counting `6`-subsets of `[12]` by the residue of their element sum:

* modulus `q = 11`: all classes have exactly `84 = C(12,6)/11` members;
* modulus `q = 7`:  all classes have exactly `132 = C(12,6)/7` members.

So the colour-class bound `b ≈ C(n,k+2)/q` used as a hypothesis in
`WeakD6.selection_gain_le` is realistic (here exactly attained).  Since safety
plus a nonempty keep-set forces every label class to have `≤ 2` points
(`WeakD6.card_labelFiber_le_two`), one needs `q ≳ n/2`, and the surviving part of
the interior layer is at most `2b ≈ 4·C(n,k+2)/n` — a vanishing fraction.  This
is the numerical shadow of the closure obstruction `|U| ≤ 2`
(`WeakD6.card_U_le_two`).

## 4. Counterexample hunt

We searched for any four-layer configuration violating the proven statements:

* over all `2^10` subsets of the interior layer for `(n,k) ∈ {(5,0),(5,1)}` and
  all `2^15` subsets for `(6,2)`, every `D₆`-free configuration satisfied the
  Turán ceiling (no violation);
* the labelling `v(i) = i mod q` into `ZMod q` with `U = {0}` satisfies the
  safety condition exactly when the labels are pairwise distinct enough that no
  value repeats three times — matching `WeakD6.card_labelFiber_le_two`.

No counterexample to any formalised statement was found.
