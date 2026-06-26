# Computational Evidence

The two theorems proved this cycle are scalar differential-*inequality* bounds, so
the relevant "evidence" is checking the comparison/bound functions against the
worst case (equality in the inequality, i.e. the comparison ODE). The bounds are
proved rigorously in Lean; the tables below are sanity checks that the constants
and exponents are right.

## 1. Forced dissipative bound `Y' = -aY + b` (worst case: equality)

Exact solution of `Y' = -aY + b`, `Y(0) = Y₀`:
`Y(t) = b/a + (Y₀ - b/a) e^{-at}` — this is exactly the upper bound proved in
`dissipative_apriori`, so equality is attained (the bound is sharp).

Take `a = 1`, `b = 2` (so `b/a = 2`), two initial data:

| t   | Y₀ = 5 (above ball) | Y₀ = 0 (below ball) |
|-----|---------------------|---------------------|
| 0   | 5.000               | 0.000               |
| 1   | 3.104               | 1.264               |
| 2   | 2.406               | 1.729               |
| 5   | 2.020               | 1.987               |
| 10  | 2.0001              | 1.9999              |
| ∞   | 2.000               | 2.000               |

* `dissipative_bound` predicts `Y ≤ max(Y₀, b/a)`: for `Y₀=5`, `≤ 5` ✓ (monotone
  down to 2); for `Y₀=0`, `≤ 2` ✓ (monotone up to 2, never exceeds 2).
* `dissipative_absorbing` / `dissipative_limsup_le` predict entry into `2 + ε` and
  `limsup = 2` ✓ (both columns → 2).

## 2. 3D blow-up lower rate `Z' = C Z³` (worst case: equality)

Exact solution of `Z' = C Z³`: `Z(t)² = Z₀² / (1 - 2C Z₀² t)`, blowing up at
`T* = 1/(2C Z₀²)`. The lower-rate claim is `Z(t)² ≥ 1/(2C(T*-t))`.

Take `C = 1`, `Z₀ = 1`, so `T* = 0.5`:

| t     | Z(t)² (exact) | lower bound 1/(2(T*-t)) | ratio |
|-------|---------------|------------------------|-------|
| 0.0   | 1.000         | 1.000                  | 1.000 |
| 0.25  | 2.000         | 2.000                  | 1.000 |
| 0.40  | 5.000         | 5.000                  | 1.000 |
| 0.49  | 50.00         | 50.00                  | 1.000 |
| →T*   | +∞            | +∞                     | 1.000 |

For the *equality* (pure comparison ODE) the lower bound is attained exactly
(ratio ≡ 1), confirming the constant `2C` and the exponent `-1/2` are sharp. For a
genuine *inequality* `Z' ≤ C Z³` the true `Z` is ≤ the comparison solution, so it
blows up *no earlier*, and the lower bound `Z(t)² ≥ 1/(2C(T*-t))` is exactly the
statement that it cannot blow up *slower*. No counterexample exists by the proof.

## Counterexample hunt

* Removed hypotheses confirmed unnecessary (and thus dropped from the statements):
  `recip_sq_lower_lipschitz` does **not** need `C > 0`; `recip_sq_tendsto_zero_of_blowup`
  does **not** need `Z > 0`. No false generalisation slipped in: both still build.
* `dissipative_limsup_le` genuinely needs `0 ≤ Y` (physical non-negativity) — without
  a lower cobound `limsup` can degenerate; this is recorded as a load-bearing hypothesis.
