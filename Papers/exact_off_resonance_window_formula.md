# Computational Evidence — exact off-resonance window formula

All numbers below were produced with `Float` computations inside Lean 4 (`#eval`),
before and alongside the formal development in
`Catalog/NumberTheory/OffResonanceWindow.lean`.  They are *evidence*, not proof:
every claim that appears as a theorem in the Lean file is proved there without
`sorry` and without `native_decide`.

## 1. The sinc law against a numerical quadrature

Midpoint Riemann sums with `n = 20000` nodes for
`∫_{-T}^{T} e^{iωt} dt`, compared with the closed form `2T·sinc(ωT)`:

| `T` | `ω` | Riemann (Re, Im) | `2T·sinc(ωT)` |
|---|---|---|---|
| 1.0 | 0.0 | (2.000000, 0.000000) | 2.000000 |
| 1.0 | 0.5 | (1.917702, 0.000000) | 1.917702 |
| 1.0 | π | (0.000000, −0.000000) | 0.000000 |
| 2.0 | 1.7 | (−0.300637, 0.000000) | −0.300637 |
| 0.5 | 10.0 | (−0.191785, −0.000000) | −0.191785 |
| 3.0 | −2.3 | (0.502991, −0.000000) | 0.502991 |

Two structural facts visible here are proved formally: the imaginary part
vanishes identically (`windowedTone_im`), and `ω = π/T` is a zero
(`windowedTone_eq_zero_iff`).  The resonance row `T = 1, ω = 0` gives `2T = 2`.

## 2. The discrete (Dirichlet) sinc law

`‖∑_{n<N} e(nα)‖` against `|sin(πNα)| / |sin(πα)|`:

| `N` | `α` | numeric `‖S_N(α)‖` | Dirichlet formula |
|---|---|---|---|
| 10 | 0.13 | 2.037067 | 2.037067 |
| 37 | 0.6180339887 | 0.434577 | 0.434577 |
| 100 | 0.0031 | 84.926479 | 84.926479 |
| 5 | 0.4999 | 0.999999 | 0.999999 |
| 64 | 0.7071067812 | 0.902060 | 0.902060 |

Agreement to all printed digits; formalized as `norm_weylSum`.

## 3. Sharpness of the `2/π` main-lobe constant

Minimum of `‖S_N(α)‖ / N` over a 201-point grid of `α ∈ [0, 1/(2N)]`:

| `N` | min of `‖S_N(α)‖ / N` |
|---|---|
| 5 | 0.647214 |
| 20 | 0.637275 |
| 100 | 0.636646 |
| — | `2/π = 0.636620` |

The theorem `norm_weylSum_ge_jordan` proves `‖S_N(α)‖ ≥ (2/π)N` on this window;
the table shows the constant `2/π` is asymptotically attained, so the bound
cannot be improved.

## 4. Rayleigh criterion: where the central dip appears

With `x = ΔT/2`, the "no central dip" inequality is
`g(x) = 2·sinc(x) − (1 + sinc(2x)) ≥ 0`:

| `x` | `g(x)` |
|---|---|
| 0.05 | 0.000833 |
| 0.25 | 0.020381 |
| 0.50 | 0.076231 |
| 1.00 | 0.228293 |
| 1.3920 | 0.288153 (maximum) |
| 1.50 | 0.282953 |
| 2.00 | 0.098498 |
| 2.60 | −0.433565 |
| π | −1.000000 |

Bisection locates the sign change at `x* = 2.13918217377`, i.e.
`(ΔT)_crit = 4.27836434755`.
The formal theorem `rayleigh_no_central_dip` proves the inequality for the whole
range `ΔT ≤ 4.2` (`x ≤ 2.1`), and `sin_mul_two_sub_cos_lt` proves the strict
reverse from `x ≥ 2.2` onwards, so `rayleigh_strict_dip` gives a dip for
`ΔT ≥ 4.4`.  Together `rayleigh_threshold_bracket` confines the critical product
to `(4.2, 4.4]`, a bracket of relative width under `5%` containing the true value
`4.27836…`.  The complementary theorem `rayleigh_full_dip` shows the dip is
*total* at `Δ = 2π/T ≈ 6.283/T`, consistent with `g(π) = −1`.

## 5. Counterexample hunt

* `‖W(T,ω)‖ ≤ 2T` was tested on a grid of `(T, ω) ∈ [0,5] × [−50,50]`-type samples
  through the closed form; no violation (and it is now a theorem).
* `‖S_N(α)‖ ≤ 1/(2‖α‖)` was checked on the samples of §2; the closest case,
  `N = 5, α = 0.4999`, gives `0.999999 ≤ 1/(2·0.0001) = 5000`, and the tight
  regime `α → 1/2` with `N` odd approaches `1`, consistent with the bound.
* No counterexample was found to any statement that was subsequently formalized.

## 6. Fejér's triangular identity and the lobe edge

`‖S_N(α)‖²` against the triangular polynomial `2 ∑_{d<N} (N-d) cos(2πdα) − N`:

| `N` | `α` | `‖S_N(α)‖²` | triangular polynomial |
|---|---|---|---|
| 1 | 0.3 | 1.000000 | 1.000000 |
| 4 | 0.13 | 6.315094 | 6.315094 |
| 9 | 0.6180339887 | 1.107621 | 1.107621 |
| 20 | 0.4999 | 0.000039 | 0.000039 |
| 50 | 0.01 | 1013.545236 | 1013.545236 |

The `N = 20, α = 0.4999` row also illustrates Fejér positivity in the hardest
regime: the polynomial is tiny but nonnegative.  Formalized as
`weylSum_normSq_fejer` and `fejer_nonneg`.

At the lobe edge `α = 1/(2N)` the proved sandwich
`(2/π)N ≤ ‖S_N(1/(2N))‖ ≤ (2/π)N + 1/N` reads:

| `N` | `‖S_N(1/(2N))‖ = 1/sin(π/(2N))` | `(2/π)N` | `(2/π)N + 1/N` |
|---|---|---|---|
| 1 | 1.000000 | 0.636620 | 1.636620 |
| 2 | 1.414214 | 1.273240 | 1.773240 |
| 5 | 3.236068 | 3.183099 | 3.383099 |
| 20 | 12.745495 | 12.732395 | 12.782395 |
| 200 | 127.325263 | 127.323954 | 127.328954 |

## 7. The recentred bounds behind the `(0, 2]` inequality

The Maclaurin bounds `sin x ≥ x - x³/4`, `cos x ≤ 1 - x²/2 + …` are too lossy
beyond `x ≈ 1`.  Recentring at `π/2` (`y = x - π/2`, `sin x = cos y`,
`cos x = -sin y`) and using only `cos y ≥ 1 - y²/2` with `sin y ≥ y` (`y ≤ 0`)
resp. `sin y ≥ y - y³/4` (`y ≥ 0`) gives, on `[1, 2]`:

| `x` | `y = x - π/2` | recentred lower bound | exact `sin x (2-cos x)` | `≥ x`? |
|---|---|---|---|---|
| 1.0000 | −0.5708 | 1.196380 | 1.228293 | yes |
| 1.2000 | −0.3708 | 1.517204 | 1.526347 | yes |
| 1.4000 | −0.1708 | 1.802523 | 1.803405 | yes |
| 1.5708 | +0.0000 | 2.000004 | 2.000004 | yes |
| 1.8000 | +0.2292 | 2.167718 | 2.168955 | yes |
| 2.0000 | +0.4292 | 2.187509 | 2.196996 | yes |
| 2.1000 | +0.5292 | 2.143180 | 2.162207 | yes |

The bound tracks the exact value to within `0.02` across the range, and the
margin at the right endpoint `x = 2.1` is `0.043`.  Pushing the same bounds
further, they first fail near `x ≈ 2.126` — only `0.6%` short of the true
breakdown `x* = 2.1392` — so `x ≤ 2.1` is a safe and nearly optimal choice for
this method.  This is exactly the content of `le_sin_mul_two_sub_cos_mid`.

For the *reversal* the same recentring is used with the inequality turned around:
`sin y ≤ y` and the cubic **upper** bound
`cos y ≤ 1 - 2(y/2 - (y/2)³/4)²` obtained from the half-angle identity
`cos y = 1 - 2 sin²(y/2)` (Mathlib supplies no direct quartic cosine upper
bound).  Writing `B(y)` for that upper bound:

| `x` | `y = x - π/2` | `B(y)` | exact `cos y` | `B(y)(2+y)` | `< x`? |
|---|---|---|---|---|---|
| 2.2000 | 0.6292 | 0.811726 | 0.808496 | 2.134193 | yes |
| 2.4000 | 0.8292 | 0.685124 | 0.675463 | 1.938354 | yes |
| 2.6000 | 1.0292 | 0.538176 | 0.515501 | 1.630243 | yes |
| 2.8000 | 1.2292 | 0.380476 | 0.334988 | 1.228635 | yes |
| 3.0000 | 1.4292 | 0.222812 | 0.141120 | 0.764069 | yes |
| 3.1416 | 1.5708 | 0.117464 | 0.000000 | 0.419442 | yes |

The binding case is again the left endpoint, with margin `2.2 - 2.1342 = 0.066`.
Beyond `x = π` the crude estimate `|sin x (2 - cos x)| ≤ 3 < π` suffices.  This is
the content of `sin_mul_two_sub_cos_lt_mid` and `sin_mul_two_sub_cos_lt_pi`.

## 8. Sharpness of the sidelobe envelope

At `T = 1` the half-integer detunings `ω = (2k+1)π/2` sit midway between
consecutive zeros `kπ`, and there `|W(1,ω)| = 2/|ω|` exactly:

| `k` | `ω = (2k+1)π/2` | `|W(1,ω)|` | `2/|ω|` |
|---|---|---|---|
| 0 | 1.57080 | 1.2732395447 | 1.2732395447 |
| 1 | 4.71239 | 0.4244131816 | 0.4244131816 |
| 2 | 7.85398 | 0.2546479089 | 0.2546479089 |
| 3 | 10.99557 | 0.1818913635 | 0.1818913635 |
| 4 | 14.13717 | 0.1414710605 | 0.1414710605 |

Equality to every printed digit, as proved in
`norm_windowedTone_sidelobe_peak`.  So the `2/|ω|` decay rate in
`norm_windowedTone_le_sidelobe` cannot be improved.

## 9. Sequences

No new integer sequence arises: the objects here are the classical Dirichlet
kernel and the cardinal sine, so no OEIS lookup applies.  The one integer-valued
specialization, `S_N(k) = N` for `k ∈ ℤ`, is the constant sequence of window
lengths and is proved as `weylSum_resonance`.
