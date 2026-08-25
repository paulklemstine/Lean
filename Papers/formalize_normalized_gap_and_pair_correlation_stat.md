# Computational Evidence

All computations below were run inside Lean 4 (`#eval`) before the corresponding
theorems were formalized.  They are exploratory checks, not proofs; every claim they
support is proved separately and `sorry`-free in `Catalog/Computation/Spectral*.lean`.

## 1. Two-level correlation of the picket fence (unfolded quadratic spectrum)

Computable model
`pcc n m = #{(i,j) ∈ [0,n)² : i ≠ j, |i-j| ≤ m}` versus the conjectured closed form
`formula n m = 2 ∑_{d=1}^{m} (n - d)`:

| n \ m | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| 2 | 0 | 2 | 2 | 2 | 2 |
| 3 | 0 | 4 | 6 | 6 | 6 |
| 4 | 0 | 6 | 10 | 12 | 12 |
| 5 | 0 | 8 | 14 | 18 | 20 |
| 6 | 0 | 10 | 18 | 24 | 28 |
| 7 | 0 | 12 | 22 | 30 | 36 |
| 8 | 0 | 14 | 26 | 36 | 44 |

`pcc` and `formula` agree in **all** 45 tested cells (`n ≤ 8`, `m ≤ 4`).  Note the
saturation `pcc n m = n(n-1)` once `m ≥ n-1`, and the plateau structure in `m`, which is
the staircase behaviour.  Formalized as `picket_pairCorr_formula` and
`picket_pairCorr_closed_form` (`2mn - m(m+1)` for `m ≤ n`).

## 2. Normalized gaps of the **raw** quadratic spectrum

`normGap(8, i) = (2i+1)/8` for `i = 0,…,7`:

```
1/8, 3/8, 5/8, 7/8, 9/8, 11/8, 13/8, 15/8
```

These are equally spaced in `(0,2)`: the empirical law is uniform on `[0,2]`, *not*
exponential (Poisson) and *not* Wigner.  Empirical CDF at `n = 1000` versus `t/2`:

| t | empirical CDF | t/2 |
|---|---|---|
| 0.5 | 0.250 | 0.250 |
| 1.0 | 0.500 | 0.500 |
| 1.5 | 0.750 | 0.750 |
| 2.0 | 1.000 | 1.000 |

Formalized as `quad_gapCDF_close_uniform` with the explicit error bound `1/(2n)`.

## 3. Gap ratios of the raw quadratic spectrum

`r_i = (2i+1)/(2i+3)`:

```
1/3, 3/5, 5/7, 7/9, 9/11, 11/13, 13/15, 15/17 → 1
```

The `r`-statistic converges to the rigid value `1` **without unfolding**
(`gapRatio_quad_tendsto_one`), unlike the normalized-gap law, which needs unfolding.

## 4. The two universality classes (numerical integration, step `1e-4`, range `0..20`)

| quantity | numerical | proved value |
|---|---|---|
| `∫₀^∞ p_GUE` | 1.000000 | `1` (`gue_pdf_integral_one`) |
| `∫₀^∞ s p_GUE` | 1.000000 | `1` (`gue_pdf_mean_one`) |
| `∫₀^∞ p_Poisson` | 1.000000 | `1` (`poisson_pdf_integral_one`) |
| `∫₀^∞ s p_Poisson` | 1.000000 | `1` (`poisson_pdf_mean_one`) |

Mode hunt for the Wigner surmise `p(s) = (32/π²)s²e^{-4s²/π}`:

| s | 0.5 | 0.8 | 0.886 | 0.9 | 1.2 |
|---|---|---|---|---|---|
| p(s) | 0.5896 | 0.9186 | **0.9368** | 0.9363 | 0.7464 |

The maximum sits at `√π/2 = 0.886227`, with value `8/(πe) = 0.936797`, matching
`gue_pdf_at_mode` and `gue_pdf_strict_max_at_mode` exactly.

## 5. Counterexample hunt

* Is the raw quadratic normalized-gap law ever close to Poisson?  The empirical CDF is
  `t/2 + O(1/n)` while the Poisson CDF is `1 - e^{-t}`; they differ by `≈ 0.11` at
  `t = 1` and by `0.13` at `t = 2` — no counterexample to the separation.
* Is the picket-fence pair correlation ever positive below distance 1?  Exhaustive
  search over `n ≤ 8`, `m = 0`: always `0`, matching `picket_pairCorr_eq_zero`.
* Is the GUE density ever above the Poisson density near `0`?  Sampling
  `s ∈ {0.01,…,0.25}` gives `p_GUE(s)/p_Poisson(s) ≤ 0.2`, consistent with the proved
  strict inequality on `(0, 1/4]`.

## 6. Kolmogorov–Smirnov distances at the threshold `t = 1/2`

| quantity | numerical | proved bound |
|---|---|---|
| Poisson CDF at 1/2, `1 - e^{-1/2}` | 0.393469 | `≥ 1/3` (`poissonGapCDF_half_lower_bound`) |
| GUE (Wigner surmise) CDF at 1/2 | 0.112 | `≥ 1/12 ≈ 0.0833` (`gueGapCDF_half_ge`) |
| analytic lower bound `(4/3π²)e^{-1/π}` | 0.098265 | `≤` GUE CDF at 1/2 (`gue_cdf_half_lower_bound`) |
| picket-fence CDF at 1/2 | 0 (exact) | `= 0` (`unfoldedQuad_gapCDF_eq_zero`) |

Hence the KS distance from the rigid spectrum is `≥ 1/3` to Poisson and `≥ 1/12` to GUE,
uniformly in the window size `n` (`picket_vs_poisson_KS`, `picket_vs_gue_KS`).
