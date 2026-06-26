# Computational Evidence

Mission: *Exponential diameter contraction under Delaunay minicenter refinement*,
with catalog references *approximate Carathéodory theorem* and *Maurey's empirical
method*. All numbers below were produced with Lean `#eval` over exact rationals
(`ℚ`), so they are exact, not floating point.

## 1. Exponential contraction (segment bisection, the proved base case)

The minicenter of a 1-simplex `[a,b]` is its midpoint; bisecting halves the
diameter. Starting diameter `D = 12`, the diameters `d k = D / 2^k` are:

| k | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| d k | 12 | 6 | 3 | 3/2 | 3/4 | 3/8 |

This is the contraction factor `λ = 2` realized exactly (`Contraction.lean`,
`segmentBisection`, `minicenter_segment_halves`).

## 2. Finite refinement budget (geometric series)

Summing the diameters of an infinite bisection refinement:

```
∑_{k=0}^{19} 12 / 2^k = 3145725 / 131072 ≈ 23.99998
```

converging to the closed form `D·λ/(λ-1) = 12·2/(2-1) = 24`, matching
`Bridge.total_budget`. So exponential per-step contraction makes the *cumulative*
diameter finite — a strictly stronger fact than mere decay to zero, and one that
fails at `λ = 1`.

## 3. Approximate Carathéodory / Maurey, base case k = 1

Square vertices `(±1, ±1)` with uniform weights `p = 1/4` give convex-hull point
`x = (0,0)`, radius `R² = 2`. The mean squared distance from `x` to a random
vertex equals the variance `R² - ‖x‖² = 2`, and every vertex is at squared
distance exactly `2 = R²` — the bound `maurey_one_point` is **tight** here.

> Pitfall found during the evidence stage: an earlier "shifted" test put
> `x = (1/2, 0)` while keeping *uniform* weights. The variance identity then
> appeared to fail (mean `9/4 ≠ R² - ‖x‖² = 7/4`). The resolution: the identity
> requires `x = Σ pᵢ Vᵢ`; with uniform weights the only valid `x` is the centroid
> `(0,0)`. This is exactly why the hypothesis `∑ pᵢ = 1` with the *matching* `x`
> is load-bearing in `weighted_mean_sq_dist`.

## 4. Maurey rate `R²/k` (counterexample hunt — none found)

Brute-force minimization over all `k`-tuples of square vertices (`x = (0,0)`,
`R² = 2`), reporting the best squared error of the empirical average vs the Maurey
bound `R²/k = 2/k`:

| k | best ‖x − avg‖² | bound 2/k |
|---|-----------------|-----------|
| 1 | 2     | 2   |
| 2 | 0     | 1   |
| 3 | 2/9   | 2/3 |
| 4 | 0     | 1/2 |
| 5 | 2/25  | 2/5 |
| 6 | 0     | 1/3 |

The empirical best is `≤ 2/k` in **every** case (no counterexample), supporting
the general `R/√k` approximate-Carathéodory theorem. The `R²/k` bound is not tight
for `k ≥ 2` here because the symmetric vertex set permits exact cancellation; the
bound is a worst-case guarantee. This motivates the formalization target recorded
in `FUTURE_DIRECTIONS.md`.
