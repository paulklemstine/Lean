# Computational Evidence — Weighted Riesz Means and Power–Logarithm Asymptotics

The formal results in `Catalog/Applications/WeightedRieszMean.lean` concern the
leading-order asymptotics of partial sums (Riesz/Cesàro means). Below is the
small-case numerical evidence that motivated and sanity-checked the constants.

## 1. Power law `∑_{n<N} n^p ~ N^(p+1)/(p+1)`

Take `p = 1/2`. Comparison of `S(N) = ∑_{n=1}^{N-1} n^{1/2}` with the predicted
main term `M(N) = N^{3/2}/(3/2) = (2/3) N^{3/2}`:

| N     | S(N)        | M(N)        | S(N)/M(N) |
|-------|-------------|-------------|-----------|
| 10    | 19.31       | 21.08       | 0.916     |
| 100   | 661.5       | 666.7       | 0.992     |
| 1000  | 21065       | 21082       | 0.99923   |
| 10000 | 666617      | 666667      | 0.999925  |

The ratio → 1, matching `power_sum_isEquivalent`. For `p = 2` this reduces to the
classical `∑_{n<N} n² ≈ N³/3`.

## 2. Logarithm law (Stirling leading term) `∑_{n<N} log n ~ N log N`

`S(N) = ∑_{n=1}^{N-1} log n = log((N-1)!)`, predicted main term `M(N) = N log N`:

| N     | S(N)=log((N-1)!) | M(N)=N log N | S(N)/M(N) |
|-------|------------------|--------------|-----------|
| 10    | 12.80            | 23.03        | 0.556     |
| 100   | 359.1            | 460.5        | 0.780     |
| 1000  | 5905.2           | 6907.8       | 0.855     |
| 10^4  | 82099            | 92103        | 0.891     |
| 10^6  | 1.281e7          | 1.382e7      | 0.9271    |

Convergence is slow (the correction term is `-N`, i.e. `S/M ≈ 1 - 1/log N`), but
the ratio increases monotonically toward 1, consistent with
`log_sum_isEquivalent`. This is the `α = 1, k = 1` (`X log X`) regime — the log
power showing up explicitly.

## 3. Second-order Riesz mean `∑_{n<N} ∑_{m<n} m^p ~ N^(p+2)/((p+1)(p+2))`

Take `p = 1`, so the inner sum is `∑_{m<n} m = n(n-1)/2` and the predicted main
term is `N^3/((2)(3)) = N^3/6`.

| N     | T(N)=∑ inner | N^3/6       | ratio   |
|-------|--------------|-------------|---------|
| 10    | 120          | 166.7       | 0.720   |
| 100   | 161700       | 166667      | 0.9702  |
| 1000  | 1.6617e8     | 1.6667e8    | 0.99700 |
| 10000 | 1.66617e11   | 1.66667e11  | 0.99970 |

Ratio → 1, matching `iterated_power_sum_isEquivalent` (obtained by feeding the
power law through the Stolz–Cesàro summation engine `isEquivalent_sum`).

## 4. Counterexample hunt

- The Stolz–Cesàro engine `sum_isLittleO_of_isLittleO` **requires** the
  divergence hypothesis `∑ g → ∞`. Without it the statement is false: take
  `g(n) = 2^{-n}` (so `∑ g` converges) and `h(n) = 1/n` with `h = o(g)` failing —
  more simply, if `∑ g` converges then `∑ h = o(∑ g)` forces `∑ h → 0`, which need
  not hold. The hypothesis is therefore load-bearing, and is included.
- The eventual-positivity hypothesis on `g` is likewise necessary to identify
  `‖∑ g‖` with `∑ g`; a sign-oscillating `g` with bounded partial sums breaks the
  conclusion.

No counterexamples were found to the stated theorems within these ranges; all
observed ratios converge to the predicted constants.

## Method

All tables were produced by direct finite summation in exact/`Float` arithmetic
(the quantities are elementary). The purpose is confirmation of the *constants*
`1/(p+1)`, `1` (for `N log N`) and `1/((p+1)(p+2))`; the convergence itself is
what is proved rigorously in Lean.
