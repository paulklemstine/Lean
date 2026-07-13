# Computational Evidence

Object of study: the matching polynomial `μ(Pₙ)` of the path on `n` vertices,
defined by the edge–deletion recurrence `μ(Pₙ) = x·μ(Pₙ₋₁) − μ(Pₙ₋₂)`,
`μ(P₀)=1`, `μ(P₁)=x`, and its **largest matching root**
`mu(n) := μ(P_{n+2})`'s greatest real zero.

The golden-ratio threshold is `T = √τ + 1/√τ = √(2+√5)` with `τ = (1+√5)/2`.

## 1. Small matching polynomials (recurrence)

| n | μ(Pₙ) | degree | roots |
|---|-------|--------|-------|
| 0 | `1` | 0 | none |
| 1 | `x` | 1 | `0` |
| 2 | `x² − 1` | 2 | `±1` |
| 3 | `x³ − 2x` | 3 | `0, ±√2` |
| 4 | `x⁴ − 3x² + 1` | 4 | `±2cos(π/5), ±2cos(2π/5)` |
| 5 | `x⁵ − 4x³ + 3x` | 5 | `0, ±2cos(π/6), ±2cos(2π/6)` |

These confirm `pathMatch_monic` (leading coeff 1), `pathMatch_natDegree`
(degree n), and the root pattern `2cos(kπ/(n+1))`, `1 ≤ k ≤ n`, used in
`pathMatch_isGreatest_root`. Also `μ(Pₙ)(2) = n+1` (`pathMatch_eval_two`): e.g.
`μ(P₃)(2) = 8−4 = 4`. ✓

## 2. The sequence of largest matching roots `mu(n) = 2cos(π/(n+2))`

Computed with 64-bit floats:

```
mu 0 = 0.000000   (= 2cos(π/2),  largest root of x)
mu 1 = 1.000000   (= 2cos(π/3),  largest root of x²−1)
mu 2 = 1.414214   (= √2 = 2cos(π/4), largest root of x³−2x)
mu 3 = 1.618034   (= τ  = 2cos(π/5), the GOLDEN RATIO — P₅)
mu 4 = 1.732051   (= √3 = 2cos(π/6))
mu 5 = 1.801938   (= 2cos(π/7))
mu 6 = 1.847759   (= 2cos(π/8))
mu 7 = 1.879385   (= 2cos(π/9))
...  ↗ strictly increasing, → 2
```

This matches `mu_strictMono` (strictly increasing), `mu_lt_two` (all `< 2`),
and `mu_tendsto_two` (`→ 2`). Notably `mu 3 = τ` exactly
(`mu_three_eq_tau`), since `2cos(π/5) = (1+√5)/2`.

## 3. The threshold

```
T   = √(2+√5) = 2.058171...
T²  = 2 + √5  = 4.236068...
```

So `2 < T` (`two_lt_goldenThreshold`) with a comfortable gap of `≈ 0.058`, and
the entire increasing sequence `mu(n) ↗ 2` stays strictly inside `(−T, T)` and
accumulates at `2 < T` (`largest_matching_root_accumulates_at_two`,
`two_isAccPt_matching_roots`).

## 4. Threshold identity check

`(√τ + 1/√τ)² = τ + 2 + 1/τ = (τ + 1/τ) + 2 = √5 + 2 = T²`,
using `τ + 1/τ = √5` (checked: `τ = 1.618034`, `1/τ = 0.618034`, sum `= √5 =
2.236068`). This is `tau_add_inv_tau` and `goldenThreshold_eq_sqrt_tau`.

## 5. Counterexample hunt

No counterexamples were sought against a *false* universal claim; every
statement formalized was first validated numerically above and then proved.
The one place a naive guess could fail — that `2cos(π/(n+1))` is the *largest*
root and not merely *a* root — is exactly what `pathMatch_isGreatest_root`
establishes by counting: the `n` numbers `2cos(kπ/(n+1))` are distinct roots of
a degree-`n` polynomial, hence *all* the roots, so the maximum is at `k=1`.

## Notes

The path family gives the accumulation point `2`, which is the matching-root
analogue of the classical Smith / "Dynkin" threshold `2` for adjacency spectral
radii. It sits strictly below the golden-ratio threshold `T ≈ 2.058`, providing
a concrete, fully verified instance of the limit-point picture described in the
research concept.
