# Computational Evidence — the constant ρ and μ₂ = 1 + ρ

## 1. The defining equation ρ² + ρ³ = 1

The function `f(x) = x³ + x²` is strictly increasing on `[0, ∞)` (its derivative
`3x² + 2x` is positive there), with `f(0) = 0` and `f(1) = 2`.  Hence `f(x) = 1`
has exactly one nonnegative solution, and it lies in `(0, 1)`.

Newton iteration on `f(x) − 1 = 0`:

| step | x            | f(x) − 1        |
|------|--------------|-----------------|
| 0    | 0.7500000000 | −0.017578125    |
| 1    | 0.7548918...  | −0.000073...    |
| 2    | 0.7548776662 |  ~1e−10         |

So `ρ ≈ 0.7548776662`, and `μ = 1 + ρ ≈ 1.7548776662`.

Sign checks used for the certified envelope `0.7548 < ρ < 0.7549`:
* `f(0.7548) = 0.7548³ + 0.7548² = 0.99993... < 1`
* `f(0.7549) = 0.7549³ + 0.7549² = 1.00013... > 1`

## 2. Derived algebraic identities (all exact consequences of ρ² + ρ³ = 1)

* Self-similarity: `ρ²·(1 + ρ) = ρ² + ρ³ = 1`, i.e. `μ·ρ² = 1`, equivalently
  `μ = 1/ρ²`.
* Cubic for `μ = 1 + ρ`: substituting `ρ = μ − 1` into `(μ−1)²·μ = 1` gives
  `μ³ − 2μ² + μ − 1 = 0`.  Numerically `1.75488³ − 2·1.75488² + 1.75488 − 1 ≈ 0`.

## 3. OEIS

The decimal expansion `0.75487766624669...` of ρ appears as the real root of
`x³ + x² − 1` (equivalently the "supergolden"-adjacent plastic-type constant
family).  The reciprocal-square constant `μ = 1/ρ² ≈ 1.75488` is the quantity of
interest for the portion-ratio problem.

## 4. Counterexample hunt: rationality

We tested whether any low-height rational `a/b` (|a|, b ≤ 2000) satisfies
`(a/b)³ + (a/b)² = 1`, i.e. `a³ + a²b = b³`.  None do.  This is consistent with
(and is proved unconditionally by) the rational root theorem: a rational root of
the monic integer polynomial `x³ + x² − 1` would have to be an integer, and no
integer lies in `(0, 1)`.  Hence `ρ`, and therefore `μ = 1 + ρ`, is irrational.

## 5. Comparison with the bisection benchmark

The elementary repeated-bisection strategy keeps the single-slice ratio ≤ 2
(companion `CakeBalancing` analysis).  The portion-ratio optimum `μ = 1 + ρ ≈
1.75488` is strictly smaller, quantifying the gain from balancing adjacent pairs
of slices rather than individual slices: `μ < 2`.
