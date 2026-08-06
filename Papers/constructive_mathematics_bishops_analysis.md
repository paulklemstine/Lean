# Computational evidence

All numbers below were produced by `#eval` inside Lean 4 (exact rational arithmetic,
`ℚ` and `Nat.sqrt`), i.e. with the very same computable definitions that appear in the
formal files.  They are *evidence*, not proofs; every claim they support is proved
separately and without `sorry` in `Catalog/Logic/ConstructiveAnalysis/`.

## 1. The computable real `√2` (`Bishop.sqrtTwo`)

`sqrtTwo.approx n = ⌊√(2(n+1)²)⌋ / (n+1)` is a computable rational; the regularity
requirement is `|x m − x n| ≤ 1/(m+1) + 1/(n+1)`.

| n | `sqrtTwo.approx n` | decimal | error vs √2 (≈) | allowed `1/(n+1)` |
|---|---|---|---|---|
| 0 | 1 | 1.0 | 4.1e−1 | 1.0 |
| 4 | 7/5 | 1.4 | 1.4e−2 | 0.2 |
| 9 | 7/5 | 1.4 | 1.4e−2 | 0.1 |
| 99 | 141/100 | 1.41 | 4.2e−3 | 0.01 |
| 999 | 707/500 | 1.414 | 2.1e−4 | 0.001 |
| 9999 | 7071/5000 | 1.4142 | 1.4e−5 | 0.0001 |

The observed error is always well inside the required `1/(n+1)`, as proved in
`sqrt_two_approx_bound` / `toReal_sqrtTwo`.  Two of these values are also checked at
compile time by `#guard` in `ComputableReals.lean`.

## 2. The explicit grid search of the approximate IVT

Test function `f x = x² − 2` on `[0,2]`.  It is `4`-Lipschitz there, so `ω ε = ε/4`
is a modulus of uniform continuity, and `f 0 = −2 ≤ 0 ≤ 2 = f 2`.  The algorithm of
`exists_grid_abs_le` returns the largest grid index `k ≤ N` with `f(grid k) ≤ 0`.
With mesh `2/N ≤ ω ε` the theorem guarantees `|f(grid k)| ≤ ε = 8/N`.

| N | returned k | grid point | `f` value | guaranteed bound `8/N` |
|---|---|---|---|---|
| 4 | 2 | 1 | −1 | 2 |
| 8 | 5 | 5/4 | −7/16 = −0.4375 | 1 |
| 16 | 11 | 11/8 | −7/64 ≈ −0.109 | 0.5 |
| 64 | 45 | 45/32 | −23/1024 ≈ −0.0225 | 0.125 |
| 256 | 181 | 181/128 | −7/16384 ≈ −4.3e−4 | 0.031 |
| 1024 | 724 | 181/128 | −7/16384 ≈ −4.3e−4 | 0.0078 |

The bound is satisfied in every case, with roughly a factor 10–20 of slack; the
returned points converge to `√2 = 1.41421…` (`181/128 = 1.4140625`).

On `[1,2]` the same `f` has slope bound `c = 2` (`f y − f x = (y+x)(y−x) ≥ 2(y−x)`),
so `abs_sub_root_le` predicts `|grid k − √2| ≤ ε/2`; e.g. for `N = 256`,
`|181/128 − √2| ≈ 1.6e−4 ≤ 0.0156 = ε/2`.

## 3. Counterexample hunt: the shelf family `shelf t x = min(x−1, max(t, x−2))`

Exact root sets computed on the grid `{k/100 : 0 ≤ k ≤ 300}`:

| t | roots found in `[0,3]` |
|---|---|
| 1 | {1} |
| 1/2 | {1} |
| 1/100 | {1} |
| 0 | the whole interval `{1, 1.01, …, 2}` |
| −1/100 | {2} |
| −1/2 | {2} |
| −1 | {2} |

The root jumps from `1` to `2` as `t` crosses `0`, with a whole interval of roots at
`t = 0`.  No choice of root can be continuous in `t`: this is exactly what
`no_continuous_root_selector` proves.  The search over `t ∈ {±1, ±1/2, ±1/100, 0}`
found no counterexample to the discontinuity phenomenon, i.e. no parameter at which
the root set is a singleton varying continuously across `0`.

No OEIS sequence is involved: the objects here are real-number approximations and
piecewise-linear families, not integer sequences.

## 4. The located supremum search (trisection)

For the located set `S = (-∞, 1/2]` with the decidable oracle `L p q = decide (1/2 ≤ q)`
(`Bishop.locatedIic`), the trisection `Bishop.bisect` on `[0,1]` produces the exact
rational enclosures

| n | enclosure `[p n, q n]` | width |
|---|---|---|
| 0 | `[0, 1]` | `1` |
| 1 | `[0, 2/3]` | `2/3` |
| 2 | `[2/9, 2/3]` | `4/9` |
| 3 | `[2/9, 14/27]` | `8/27` |
| 4 | `[26/81, 14/27]` | `16/81` |
| 5 | `[94/243, 14/27]` | `32/243` |
| 10 | `[28826/59049, 9950/19683]` | `(2/3)^10` |

Every enclosure contains `1/2` and the width is exactly `(2/3)^n`, as the theorem
`Bishop.bisect_width` asserts.  The rows for `n ≤ 3` and `n = 10` are checked at
compile time by the `#guard` commands in
`Catalog/Logic/ConstructiveAnalysis/ConstructiveSup.lean`; the remaining rows are
`#eval` output of the same computable definition.

## 5. The witnessed order

The witness index in `Bishop.Reg.Lt` cannot be bounded in advance: for
`x = ofRat 0` and `y = ofRat (1/(N+1))` one has `x < y`, but no index `n ≤ N`
satisfies `x_n + 2/(n+1) < y_n`, since `1/(N+1) ≤ 2/(n+1)` for all such `n`.  This is
proved in general in `Bishop.Reg.no_uniform_lt_witness`; e.g. for `N = 3` the gap is
`1/4` while the required separation at indices `0,1,2,3` is `2, 1, 2/3, 1/2`.

## 6. The faster one-query located search (`2/5, 1/2`)

The same located set `S = (-∞, 1/2]` on `[0,1]`, searched by `Bishop.searchGen` with
query fractions `α = 2/5`, `β = 1/2`, gives the exact rational enclosures

| n | enclosure `[p n, q n]` | width |
|---|---|---|
| 0 | `[0, 1]` | `1` |
| 1 | `[0, 1/2]` | `1/2` |
| 2 | `[1/5, 1/2]` | `3/10` |
| 3 | `[8/25, 1/2]` | `9/50` |
| 4 | `[49/125, 1/2]` | `27/250` |
| 10 | width `19683/3906250 ≈ 5.04·10⁻³` | `≤ (3/5)^10 ≈ 6.05·10⁻³` |

for comparison, the trisection width after ten steps is `(2/3)^10 ≈ 1.73·10⁻²`, about
`3.4` times larger.  The rows for `n ≤ 4` and the two facts about `n = 10` (the width
bound `(3/5)^10` and the enclosure of `1/2`) are checked at compile time by the
`#guard` commands in `Catalog/Logic/ConstructiveAnalysis/Sharpness.lean`.

The general bound `max β (1−α)` on the contraction factor is proved in
`Bishop.searchGen_width_le`, and `Bishop.one_query_contraction_gt_half` shows that no
choice of `α < β` brings it down to `1/2`.

## 7. Failure of the unshifted diagonal

For the family `x k` with `(x k).approx n = 1/(k+1) + (−1)^k/(n+1)`
(`Bishop.Reg.diagWitness`), which denotes the reals `1/(k+1)`:

| k | `(x k).approx k` | denoted real |
|---|---|---|
| 0 | `1 + 1 = 2` | `1` |
| 1 | `1/2 − 1/2 = 0` | `1/2` |
| 2 | `1/3 + 1/3 = 2/3` | `1/3` |
| 3 | `1/4 − 1/4 = 0` | `1/4` |

The unshifted diagonal already fails regularity at `m = 0, n = 1`: the values differ
by `2`, while regularity allows only `1/1 + 1/2 = 3/2`.  This is the content of
`Bishop.Reg.unshifted_diagonal_not_regular`.

## 8. Small values do not locate roots: the dip function

`Bishop.dipFn η x = min (x − 1) (|x − 3| + η)` on `[0,4]` has the single root `x = 1`
and a "near root" of depth `η` at `x = 3`:

| x | 0 | 1 | 2 | 3 | 3.5 | 4 |
|---|---|---|---|---|-----|---|
| `dipFn η x` | `−1` | `0` | `1` | `η` | `1/2 + η` | `1 + η` |

The function is `1`-Lipschitz, and on every interval of length `h` it takes a value of
absolute value at least `h/8` (choose one of the three points `x, x + h/3, x + 2h/3`
that is at distance at least `h/8` from both critical points `1` and `3`).  So local
non-constancy holds with the explicit modulus `ν h = h/8`, yet `|dipFn η 3| = η` is
arbitrarily small at distance `2` from the only root.  All of these facts are proved,
not merely computed, in `Catalog/Logic/ConstructiveAnalysis/RootLocation.lean`
(`Bishop.dipFn_lipschitz`, `Bishop.dipFn_abs_ge`, `Bishop.dipFn_root_unique`,
`Bishop.local_nonconstancy_insufficient`); the table entries are elementary
evaluations of the defining formula (`dipFn` uses real `min` and `abs` and so is not
executable).
