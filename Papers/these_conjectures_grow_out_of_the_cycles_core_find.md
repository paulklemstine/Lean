# Computational Evidence

The theorems in `ThermodynamicHorizon.lean` are asymptotic/analytic statements, so
"evidence" here means checking the elementary numerics behind each claim.

## Discoverable fraction `|S ∩ [0,N)| / N` (measure zero, order `1/N`)

Take a fixed finite budget `S = {0, 3, 7}` (`|S| = 3`). The fraction of the first
`N` indices that lie in `S`:

| N   | discovered | fraction | 1/N    | |S|/N  |
|-----|-----------:|---------:|-------:|-------:|
| 10  | 3          | 0.300    | 0.100  | 0.300  |
| 100 | 3          | 0.030    | 0.010  | 0.030  |
| 1000| 3          | 0.003    | 0.001  | 0.003  |

Once `N > max S = 7` the count is constant `3`, so the fraction is exactly `3/N`,
bracketed by `1/N ≤ fraction ≤ 3/N` — matching `discoverable_fraction_upper_bound`,
`discoverable_fraction_reciprocal_lower`, and the `→ 0` limit.

## Robustness dichotomy `s / N`

For finite `s`, `s/N → 0`. For `s = ⊤` (infinite budget), `⊤/N = ⊤` for every
`N ≥ 1`, so the sequence is constantly `⊤` and does not approach `0`. This is the
finite-vs-infinite split of `robustness_finite_iff`; no intermediate growth law
changes the verdict.

## Area-law crossover `c·m² ≥ L·m`

With `c = 1`, `L = 5` the crossover mass is `L/c = 5`:

| m | c·m² | L·m | c·m² ≥ L·m ? |
|---|-----:|----:|:-----------:|
| 0 | 0    | 0   | yes (equal) |
| 3 | 9    | 15  | no          |
| 5 | 25   | 25  | yes (equal) |
| 8 | 64   | 40  | yes         |

Quadratic overtakes linear exactly at `m = 5`, confirming `area_law_crossover`.
The ratio `L·m / (c·m²) = 5/m → 0`, confirming
`linear_over_quadratic_tendsto_zero`.

No counterexamples were found; the numerics agree with every formal statement.
