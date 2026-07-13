# Computational Evidence — Vietoris–Rips size below the √2 threshold

Before committing to a formal argument we mapped the combinatorial landscape of the
equidistant configuration `E_n` (all pairwise distances equal to `d`, realised by the
`n` standard basis vectors of `ℝⁿ`, where `d = √2`).

## 1. Small-case simplex counts

The Vietoris–Rips complex at scale `r` collects every subset whose pairwise distances
are `≤ r`. For `E_n` this depends only on whether `r ≥ d`:

| `n` | simplices at `r < d` (`n+1`) | simplices at `r ≥ d` (`2ⁿ`) | jump ratio |
|----|------------------------------|-----------------------------|------------|
| 1  | 2                            | 2                           | 1          |
| 2  | 3                            | 4                           | 1.33       |
| 3  | 4                            | 8                           | 2.0        |
| 4  | 5                            | 16                          | 3.2        |
| 5  | 6                            | 32                          | 5.33       |
| 8  | 9                            | 256                         | 28.4       |
| 16 | 17                           | 65536                       | 3855       |

The count is exactly `n+1` below the gap and `2ⁿ` at or above it: a single scale `d`
carries the entire exponential blow-up. Both endpoints are proved
(`card_VRcomplex_equi_below`, `card_VRcomplex_equi_eq`).

## 2. The pairwise distance of standard basis vectors

For `i ≠ j`, `‖eᵢ − eⱼ‖ = √(1² + 1²) = √2`, independent of the ambient dimension.
This fixes the gap scale at `d = √2` and is proved as `stdBasis_dist_eq_equiD`.

## 3. The exponent γ(c) = ½ − log₂ c

| `c`       | `log₂ c` | `γ(c) = ½ − log₂ c` |
|-----------|----------|----------------------|
| 1.000     | 0.000    | 0.500                |
| 1.100     | 0.1375   | 0.3625               |
| 1.250     | 0.3219   | 0.1781               |
| 1.350     | 0.4330   | 0.0670               |
| 1.400     | 0.4854   | 0.0146               |
| √2≈1.4142 | 0.5000   | 0.0000               |

`γ` is strictly positive on `[1, √2)` and decreases continuously to `0` at `√2`. Both
facts are proved (`gamma_pos`, `gamma_tendsto_zero`). Note `√2 = 2^{1/2}`, so
`log₂ √2 = ½` exactly, pinning the limit.

## 4. Counterexample hunt

We searched for a `c`-approximation of `VR(E_n)` with fewer than `2ⁿ` simplices at every
scale, for `1 ≤ c`. The interleaving forces `VR(d) ⊆ G(c·d)`, and `VR(d)` already has
`2ⁿ` simplices, so `G(c·d)` cannot be smaller. No counterexample exists; this is the
content of `approx_card_lower_bound`.

## Conclusion

The computational picture is unambiguous: the equidistant gap produces a clean
`(n+1) → 2ⁿ` jump at `√2`, the standard-basis realisation fixes the gap at exactly `√2`,
and the exponent `γ(c) = ½ − log₂ c` interpolates positively down to `0` at the
threshold. The formal development mirrors each of these observations.
