# Computational Evidence: No-(k+1)-in-line, f_k(n) = kn

We study `f_k(n)`, the maximum number of points inside the `n × n` integer grid
`{0,…,n-1}²` such that no line contains more than `k` of them (equivalently, no
`k+1` of them are collinear).

## 1. The two robust facts

* **Upper bound `f_k(n) ≤ kn`.** Each of the `n` columns is a vertical line, so a
  no-`(k+1)`-in-line configuration has at most `k` points per column, hence at
  most `kn` points overall. This is the "trivial upper bound" of the conjecture,
  and it holds for *all* `k, n`.

* **Trivial regime `n ≤ k`.** Every line meets the `n × n` grid in at most `n`
  points (a non-vertical line has at most one point per column; a vertical line
  is one column). So if `n ≤ k`, the *entire* grid is admissible and
  `f_k(n) = n²`. In particular `f_k(k) = k² = k·k`, the boundary case of the
  conjecture.

## 2. Small-case table for k = 3

`f_3(n)` should equal `n²` for `n ≤ 3` (whole grid) and `3n` for `n ≥ 3`.

| n | trivial UB kn = 3n | grid size n² | conjectured f_3(n) |
|---|--------------------|--------------|--------------------|
| 1 | 3                  | 1            | 1  (= n², n < k)   |
| 2 | 6                  | 4            | 4  (= n², n < k)   |
| 3 | 9                  | 9            | 9  (= n² = kn)     |
| 4 | 12                 | 16           | 12 (= kn)          |
| 5 | 15                 | 25           | 15 (= kn)          |

The first genuinely non-trivial case (`n > k`) is `k = 3, n = 4`, where the
answer `12 = 3·4` is strictly below the grid size `16`.

## 3. Explicit construction for k = 3, n = 4

Take the `4 × 4` grid and delete the four points
`{(0,0), (1,2), (2,1), (3,3)}`. These four cells form a permutation matrix
(one per row, one per column) that meets *both* long diagonals, leaving:

* every row with `3` points (≤ 3),
* every column with `3` points (≤ 3),
* the main diagonal with `2` points and the anti-diagonal with `2` points,
* every other line of the `4 × 4` grid already has `≤ 3` (in fact `≤ 3`) points,
  because the only lines carrying `4` grid points are the 4 rows, 4 columns, and
  2 long diagonals.

This 12-point set therefore has no 4 collinear points, matching the upper bound
`3·4 = 12`. In the Lean development this is `NoKPlus1.T`, and
`NoKPlus1.T_noKp1 : NoKp1 3 T` is checked by the kernel via `decide`.

The determinant collinearity test `Collinear3 p q r` used to encode "no `k+1`
in a line" is decidable, so the property `NoKp1 3 T` reduces to a finite
computation (`12·12·12` triples), verified inside the kernel — no `native_decide`
/ `Lean.ofReduceBool` is used.

## 4. Counterexample hunt

The conjecture `f_k(n) = kn` for `k ≥ 3, n ≥ k` is a strengthening (explicit
threshold) of a published asymptotic theorem, so we did not expect a
counterexample. The upper bound direction `f_k(n) ≤ kn` is proven here for all
`k, n` and admits no counterexample. The remaining (open) direction is the
lower bound / achievability `f_k(n) ≥ kn` for every `n ≥ k`; the case
`k = 3, n = 4` above confirms achievability in the first non-trivial instance.
