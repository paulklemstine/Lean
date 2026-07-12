# Computational Evidence — The Last Theorem

## 1. Countability of finite strings (small cases)

Number of strings of length `≤ L` over a `b`-symbol alphabet is
`(b^{L+1} - 1)/(b - 1)` for `b ≥ 2`.

| b | L | # strings of length ≤ L |
|---|---|--------------------------|
| 2 | 0 | 1 |
| 2 | 1 | 3 |
| 2 | 2 | 7 |
| 2 | 3 | 15 |
| 2 | 10 | 2047 |
| 3 | 3 | 40 |

The counts are finite for each `L` but unbounded as `L → ∞`: the union over all `L`
is countably infinite. This is exactly the content of `theorems_denumerable` for the
full language, and of the boundary remark that `Fin 0` (b = 0) degenerates to a single
empty string.

## 2. Discoverable fraction (budget N, first n theorems)

`discoverableFraction N n = min(N, n) / n`. With a fixed finite budget `N`:

| N | n | fraction |
|---|-----|----------|
| 10^3 | 10^3 | 1.000 |
| 10^3 | 10^6 | 0.001 |
| 10^3 | 10^9 | 10^{-6} |
| 10^{120} | 10^{120} | 1.000 |
| 10^{120} | 10^{240} | 10^{-120} |

For any fixed `N` the fraction → 0 as `n → ∞`, matching
`discoverable_fraction_tendsto_zero`.

## 3. Bekenstein–Hawking M² scaling (Planck units)

`bekensteinEntropy a M = π a² M²`. Doubling the mass quadruples storage:

| M | π a² M² / (π a²) |
|---|-------------------|
| 1 | 1 |
| 2 | 4 |
| 3 | 9 |
| 10 | 100 |

This is `entropy_mass_quadratic` (M → 2M gives ×4) and `entropy_mass_scaling`
(M → cM gives ×c²).

## 4. Quadratic-beats-linear crossover

For coefficient `k = π a²` and linear budget `c·M`, the quadratic law overtakes the
linear one at `M = c/k`:

| c | k | crossover M = c/k |
|---|---|-------------------|
| 1 | 1 | 1 |
| 100 | 1 | 100 |
| 1 | 100 | 0.01 |

Above the crossover, `c·M ≤ k·M²` — this is `entropy_eventually_dominates_linear`.

## 5. Counterexample hunt

- Fraction positivity: no fixed finite `N` yields a positive limiting fraction —
  every tested `N` gives fraction → 0. No counterexample found.
- Quadratic dominance below crossover: for `M < c/k` the inequality `c·M ≤ k·M²` can
  fail (e.g. `c = 100, k = 1, M = 1`: `100 > 1`), which is why the theorem requires
  `M ≥ c/k`. This is a genuine boundary, correctly guarded in the statement.

All numerical observations are consistent with the formal theorems; no counterexample
to any stated result was found.
