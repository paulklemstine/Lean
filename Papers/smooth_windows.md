# Computational Evidence — Smooth Windows (Phase A, v19c)

All numbers below were produced by direct floating-point evaluation of the *same* formulas that are
formalised in `Catalog/Algebra/SmoothWindows/`. They are **numerical evidence only**; every claim
that is asserted as a theorem is proved without any computation in the Lean files (no
`native_decide`, no `decide`). Notation:

* `g_s(t) = exp(-π t² / s²)` — `SmoothWindows.gaussWin`
* `rect_T = 1_{[-T,T]}` — `SmoothWindows.rectWin`
* `w(t) = 1/(1/4 + t²)` — the harmonic amplitude of the catalog
  (`ReciprocalZeroHarmonics.harmonicSum`)

---

## 1. Sidelobes of the rectangular window vs. the Gaussian tail

The Fourier transform of `rect_T` is `sin(2πTξ)/(πξ)` (`SmoothWindows.fourier_rectWin`), whose main
lobe has height `2T` at `ξ = 0`. The formalised sidelobe frequencies are
`ξ_n = (2n+1)/(4T)` (`SmoothWindows.sidelobeFreq`), where `|sin(2πTξ_n)| = 1` and the transfer
magnitude is exactly `4T/(π(2n+1))` (`SmoothWindows.norm_fourier_rectWin_sidelobeFreq`).

Table for `T = 1` (main lobe `2T = 2`):

| n | ξ_n  | rect \|F\|(ξ_n) = 4T/(π(2n+1)) | ξ_n·\|F\|(ξ_n) | \|F\|(ξ_n)/2T | Gaussian `g_1(ξ_n)` |
|---|------|-------------------------------|----------------|---------------|---------------------|
| 0 | 0.25 | 1.273240                      | 0.318310       | 0.636620      | 8.217e-01           |
| 1 | 0.75 | 0.424413                      | 0.318310       | 0.212207      | 1.708e-01           |
| 2 | 1.25 | 0.254648                      | 0.318310       | 0.127324      | 7.382e-03           |
| 3 | 1.75 | 0.181891                      | 0.318310       | 0.090946      | 6.631e-05           |
| 4 | 2.25 | 0.141471                      | 0.318310       | 0.070736      | 1.238e-07           |
| 5 | 2.75 | 0.115749                      | 0.318310       | 0.057875      | 4.807e-11           |

Observations, each of which became a theorem:

* The scale-invariant product `ξ_n · |F(ξ_n)|` equals the width-independent constant `1/π` for
  **every** `T > 0` and every `n` (`SmoothWindows.sidelobe_normalised_amplitude`). Widening the
  rectangular window moves the sidelobes but never attenuates them relative to their own
  frequency: this is the "sidelobe masquerading as a peak" phenomenon. Numerically, the product
  column for `T = 1` is `0.318310` at every row, to all displayed digits.
* The rectangular column decays like `1/n`, so **the total spurious energy diverges**
  (`SmoothWindows.rect_sidelobes_not_summable`, proved from `Real.not_summable_one_div_natCast`).
* The Gaussian column decays faster than any power — the last entries fall by four orders of
  magnitude per step — hence `SmoothWindows.gauss_sidelobe_summable` and
  `SmoothWindows.gauss_beats_rect_at_sidelobes`.

No counterexample was found in a scan of `T ∈ {1/4, 1/2, 1, 2, 5, 20}` and `n ≤ 200`: the ratio
column is literally constant in `T`, as the closed form predicts.

---

## 2. The Rayleigh criterion on the first Riemann zeros

Ordinates used: `t₁ = 14.134725`, `t₂ = 21.022040` (so `t₁ - t₂ = -6.887315`), giving
`w₁ = 4.99899e-3`, `w₂ = 2.26195e-3`. Criterion of
`SmoothWindows.posProfile_two_resolved`: `3·g_{2s}(t₁-t₂)·w₂ < w₁`.

| s  | u = g_{2s}(t₁-t₂) | 3·u·w₂     | w₁         | crude criterion | sharp criterion |
|----|-------------------|------------|------------|-----------------|-----------------|
| 1  | 6.609e-17         | 4.484e-19  | 4.999e-3   | resolved        | resolved        |
| 2  | 9.017e-05         | 6.117e-7   | 4.999e-3   | resolved        | resolved        |
| 4  | 9.745e-02         | 6.611e-4   | 4.999e-3   | resolved        | resolved        |
| 8  | 5.587e-01         | 3.791e-3   | 4.999e-3   | resolved        | resolved        |
| 16 | 8.646e-01         | 5.866e-3   | 4.999e-3   | fails           | fails           |

At `s = 4` the profile values are, from the closed forms `posProfile_pair_at` /
`posProfile_pair_mid`,

```
P(t₁)          = w₁ + u⁴ w₂ = 4.99919e-3
P((t₁+t₂)/2)   = u (w₁ + w₂) = 7.07504e-4
```

so the midpoint is a genuine valley, by a factor of about 7. At `s = 16` the two lines merge into a
single blob and both the crude and the sharp criteria correctly report failure — the crude
constant `3` therefore loses very little here (the sharp threshold `u(1+u+u²)w₂ < w₁` flips at
`u ≈ 0.855`, the crude one at `u ≈ 0.737`).

**Counterexample hunt.** The criterion was tested on all `30` ordered pairs `(i,j)`, `i ≠ j`, from
the first six ordinates `14.134725, 21.022040, 25.010858, 30.424876, 32.935062, 37.586178`, with
`s` on a logarithmic grid `2^(k/10)`, `-30 ≤ k ≤ 60` — `2730` configurations in total. The crude
criterion held in `1898` of them, and in **every** one of those the midpoint was strictly below the
value at `t_i`: `0` violations. As `s → 0⁺` every pair becomes resolved, which is
`SmoothWindows.posProfile_two_resolved_eventually`.

---

## 3. The Gaussian scale space

`gaussSpectral S s = Σ_t g_s(t) w(t)` for the same six ordinates (`harmonicSum = 0.011568`):

| s    | gaussSpectral |
|------|---------------|
| 1    | 0.000000      |
| 5    | 0.000000      |
| 10   | 0.000009      |
| 20   | 0.001124      |
| 50   | 0.006608      |
| 100  | 0.009893      |
| 1000 | 0.011549      |

The column is strictly increasing and converges to `0.011568` — matching
`SmoothWindows.gaussSpectral_strictMono` and `SmoothWindows.gaussSpectral_tendsto_harmonicSum`. By
contrast the rectangular statistic `windowSum` on the same data is a step function taking only the
seven values `0, w(t₁), w(t₁)+w(t₂), …` with jumps exactly at `T = t_i` — the discontinuity proved
in `SmoothWindows.rect_scale_not_continuousAt`.

---

## 4. OEIS

The sidelobe amplitude sequence `4T/(π(2n+1))` at `T = 1` is `4/π` times the reciprocals of the odd
numbers; the underlying integer sequence of denominators `1, 3, 5, 7, 9, …` is
[A005408](https://oeis.org/A005408) (the odd numbers). The partial sums `Σ 1/(2n+1)` diverge
logarithmically, which is precisely the divergence formalised in
`SmoothWindows.rect_sidelobes_not_summable`. No other integer sequence arose: the Gaussian side of
the story is transcendental at every step.

---

## 5. Gaussian regularisation on the threshold family

Take `t_k = √(k+1)`, so `t_k² = k+1` exactly — the boundary case of the growth hypothesis of
`SmoothWindows.gaussSum_summable_of_sq_growth`. The unwindowed terms are `1/(k + 5/4)` and the
windowed terms are `g_1(t_k)/(k + 5/4)`. Partial sums:

| K     | Σ_{k<K} 1/(k+5/4) | Σ_{k<K} g_1(√(k+1))/(k+5/4) |
|-------|-------------------|------------------------------|
| 1     | 0.800000          | 0.034571                     |
| 2     | 1.244444          | 0.035401                     |
| 4     | 1.787431          | 0.035427                     |
| 8     | 2.397050          | 0.035427                     |
| 10⁴   | 9.437869          | 0.035427                     |

The left column grows like `log K` without bound; the right column is constant to five decimal
digits from `K = 4` onwards. This is the numerical content of the pair
`gaussSum_summable_of_sq_growth` / `harmonic_not_summable_sqrt_ordinates`: on this family the
Gaussian window turns a divergent catalog statistic into a convergent one.

**Sharpness of the additive `1` in `gaussWin_abs_pow_mul_le`.** The function `|t|ᵐ g_s(t)` is
maximised at `|t| = s√(m/2π)`. For `m = 1`, `s = 1/2` the maximum is `0.120985`, while the pure
power bound `(s²/π)¹·1!` equals `0.079577`; the pure bound is therefore false, and the additive
`1` in the formalised statement is not cosmetic. Numerically the pure bound fails for every
`s < 0.760` at `m = 1`.
