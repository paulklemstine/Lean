# Computational Evidence — Gumbel law and extreme-value convergence

All quantities below are the exact objects appearing in
`FyodorovHiaryKeating.lean`. The Fyodorov–Hiary–Keating (FHK) conjecture asserts
that the recentered maximum of `log|ζ(1/2+it)|` on `[T,2T]` converges to a sum of
two independent Gumbel variables; the theorems we formalize concern the Gumbel
law `G(x)=exp(-exp(-x))` itself and the extreme-value limit that produces it.

## 1. Extreme-value convergence `(1 - e^{-x}/n)^n → G(x)` (`tendsto_expMax_gumbel`)

`(1 - e^{-x}/n)^n` is the exact CDF of the maximum of `n` i.i.d. `Exp(1)`
variables recentered by `log n`. The table shows convergence to `G(x)=exp(-e^{-x})`.

| x    | n=10    | n=100   | n=1000  | n=10^5  | limit G(x) |
|------|---------|---------|---------|---------|------------|
| -1.0 | 0.04191 | 0.06355 | 0.06574 | 0.06599 | 0.06599    |
|  0.0 | 0.34868 | 0.36603 | 0.36770 | 0.36788 | 0.36788    |
|  1.0 | 0.68742 | 0.69173 | 0.69215 | 0.69220 | 0.69220    |
|  2.0 | 0.87262 | 0.87334 | 0.87342 | 0.87342 | 0.87342    |

Monotone, rapid convergence — consistent with the proven pointwise limit.

## 2. Max-stability `G(x + log n)^n = G(x)` (`gumbel_max_stable`)

This is an exact algebraic identity (not a limit). Numerically it holds to full
double precision for every tested `(x, n)`:

| x    | n  | G(x+log n)^n | G(x)        |
|------|----|--------------|-------------|
| -0.5 | 2  | 0.19229565   | 0.19229565  |
| -0.5 | 5  | 0.19229565   | 0.19229565  |
| -0.5 | 37 | 0.19229565   | 0.19229565  |
|  0.0 | 2  | 0.36787944   | 0.36787944  |
|  0.0 | 37 | 0.36787944   | 0.36787944  |
|  1.5 | 2  | 0.80001071   | 0.80001071  |
|  1.5 | 37 | 0.80001071   | 0.80001071  |

## 3. Median `G(-log(log 2)) = 1/2` (`gumbelCDF_median`)

Direct evaluation: `G(-log(log 2)) = 0.5` exactly.

## 4. Density normalization `∫_ℝ g(x) dx = 1` (`gumbelPDF_integral_eq_one`)

Trapezoidal integration of `g(x)=exp(-x-e^{-x})` over `[-20,40]` with 6·10^5
subintervals gives `0.9999999999996`, confirming the density integrates to 1.

## Notes

- No counterexamples were found for any of the universal claims tested.
- The Gumbel CDF is visibly strictly increasing from 0 to 1 across the tables,
  matching `gumbelCDF_strictMono`, `gumbelCDF_tendsto_atBot`,
  `gumbelCDF_tendsto_atTop`.
- Computations used Python's `math` module (double precision) and a trapezoid
  rule; they are numerical confirmations, while the Lean file contains the exact
  proofs.
