# Computational Evidence — Cubic Rayleigh quotient of the one-dimensional swap chain

We study the canonical one-dimensional swap chain: the weighted path on `n`
positions with unit conductance between consecutive positions, together with the
monotone "position" test function `f(i) = i`.  The two relevant functionals are

* the Dirichlet energy `E = Σ_{x,y} Q(x,y) (f(x) − f(y))²`, and
* the pairwise variation `V = Σ_{x,y} (f(x) − f(y))²`,

whose ratio `R(n) = E / V` upper-bounds the combinatorial spectral gap.

## 1. Small-case calculations

The values below are exact rational computations of `E`, `V`, and `R = E/V`.

| n | E = 2(n−1) | V = n²(n²−1)/6 | R = E/V   | 12/(n²(n+1)) |
|---|------------|-----------------|-----------|---------------|
| 2 | 2          | 2               | 1         | 1             |
| 3 | 4          | 12              | 1/3       | 1/3           |
| 4 | 6          | 40              | 3/20      | 3/20          |
| 5 | 8          | 100             | 2/25      | 2/25          |
| 6 | 10         | 210             | 1/21      | 1/21          |

In every case `R(n) = 12 / (n²(n+1))` exactly, confirming the closed form used
in the formal development (`path_RQ_eq`).

## 2. Asymptotics and the exponent

Since `n²(n+1) = n³ + n²`, we have

```
6 / n³  ≤  R(n) = 12 / (n²(n+1))  ≤  12 / n³      for all n ≥ 2,
```

so `R(n) = Θ(n^{-3})`.  Numerically `n³ · R(n) → 12` from below:

| n   | n³·R(n) = 12n/(n+1) |
|-----|----------------------|
| 2   | 8.000                |
| 10  | 10.909               |
| 100 | 11.881               |
| 1000| 11.988               |

The limit `12` and the two-sided window `[6, 12]` for `n³·R(n)` are exactly the
bounds proved in `path_RQ_Theta`.

## 3. Why the exponent is 3

The mechanism is a ratio of growth rates:

* the energy `E = 2(n−1) = Θ(n)` counts oriented edges — linear growth, because a
  monotone statistic changes by `±1` across each of the `n−1` edges;
* the variation `V = n²(n²−1)/6 = Θ(n⁴)` is quartic, the discrete second moment of
  a spread-out monotone statistic.

Their quotient is `Θ(n^{-3})`, and `3 = 4 − 1` is precisely the difference of the
two exponents.  This is the same one-dimensional signature expected for a
fixed-genus chord-swap statistic that moves by `±1` per swap.

## 4. Counterexample hunt

We checked the identity `R(n) = 12/(n²(n+1))` and the window `6/n³ ≤ R(n) ≤ 12/n³`
for all `2 ≤ n ≤ 200` by exact rational arithmetic; no discrepancy was found.  The
identity and both inequalities are established in general in the accompanying
development, so no counterexample exists.
