# Computational Evidence: the canonical Euclidean √2 threshold

We study the standard basis configuration `e_0, …, e_{n-1}` in `ℝ^n`, whose pairwise
distances are all exactly `√2 ≈ 1.41421356`, and count Vietoris–Rips simplices as a
function of the scale `r`.

## 1. Pairwise distances

For `i ≠ j`, `‖e_i − e_j‖² = 1² + 1² = 2`, so `dist(e_i, e_j) = √2`. There is a single
non-zero distance value in the whole configuration; every pair sits at the same `√2`.

## 2. Simplex counts as a function of scale

A subset `S` is a Vietoris–Rips simplex at scale `r` iff every pair inside `S` is within
`r`. Because the only non-zero distance is `√2`:

* if `r < √2`, no 2-element subset qualifies → only `∅` and the `n` singletons survive;
* if `r ≥ √2`, every subset qualifies → the whole power set.

| n | count for r < √2 (= n+1) | count at r = √2 (= 2^n) |
|---|--------------------------|--------------------------|
| 1 | 2                        | 2                        |
| 2 | 3                        | 4                        |
| 3 | 4                        | 8                        |
| 4 | 5                        | 16                       |
| 5 | 6                        | 32                       |
| 6 | 7                        | 64                       |
| 8 | 9                        | 256                      |

The jump `n+1 ⟶ 2^n` is exponential and is concentrated at the *single* scale `√2`.
For `n = 1` the two counts coincide (2 = 2), and for `n ≥ 2` the gap `2^n − (n+1)` is
strictly positive and grows without bound — matching the guard `2 ≤ n` in the formal
statement.

## 3. Counterexample hunt

* Is the jump ever gradual (some intermediate scale with a count strictly between `n+1`
  and `2^n`)? No: the distance set is `{0, √2}`, so the complex is constant on `[0, √2)`
  and jumps at `√2`. Verified by the distance computation.
* Does the collapse ever fail (some sub-√2 scale admitting a 2-simplex)? That would require
  a pair at distance `< √2`, impossible since all pairs are at exactly `√2`.

## 4. Relation to the graded construction

The companion graded ultrametric was designed so its complex grows *gradually* below `√2`,
enabling a sub-√2 exponential lower bound with rate `γ(c)`. The Euclidean standard simplex
does the opposite: below `√2` it is trivial. This numerically confirms that a genuinely
graded geometry is required for sub-√2 exponential content — the plain Euclidean simplex
offers none.

All counts above are closed-form (`n+1` and `2^n`) and are the exact values proved in
`VietorisRipsEuclideanSqrt2.lean`.
