# Computational evidence — FACT round-70 #1 (TDIAL-U112), exp 545

All numeric claims listed here were re-derived inside Lean as exact rational or real
statements (see the "Lean theorem" column); the exploratory scripts below were used only to
find the constants before formalising them.  Nothing in this file is claimed as verified
except through the Lean theorems named.

## 1. The recorded ladder and its steps

```
bitlen :  96      100     104     108     112   | (116)   (120)
rho    :  0.5739  0.5436  0.5005  0.4880  0.4621| 0.4847  0.43636
step   :         -0.0303 -0.0431 -0.0125 -0.0259| +0.0226 -0.0483
ratio  :          --      1.4224  0.2900  2.0720
```

* The step from U108 to U112 (`−0.0259`) is more than twice the previous step (`−0.0125`):
  the fade re-accelerates.  Lean: `u112_step_reaccelerates`.
* The three-rung ratio at U112 is `259/125 = 2.072 > 1` — an **expansive** local fit.
  Lean: `u112_fitted_ratio_gt_one`.
* The extrapolation this licensed for U116 is `68412896/167500000 ≈ 0.40843`, against the
  recorded `0.4847`: error `95331/1250000 ≈ 0.07626`.  Lean: `u112_extrapolation_error`.

## 2. Minimal noise of a single-`(L, λ)` affine model

Grid search over `λ ∈ {0, 1/20000, …, 1}` of the half-range of
`v_k(λ) = ρ_{k+1} − λ ρ_k`, `k = 0..3` (the exact optimum of the Chebyshev fit):

```
grid minimiser   λ = 0.7575          half-range 0.010074125
exact optimum    λ* = 278/367        η* = 73943/7340000 = 0.0100739782…
optimal floor    L* = 725197/1780000 = 0.4074140…
residuals at (L*, λ*)   +η*, −η*, +η*, −46663/7340000     (3 alternations)
```

Lean: lower bound `u112_noise_floor` (ratio elimination) and
`u112_noise_floor_by_alternation` (Chebyshev alternation); attainment
`rhoStar_isNoisyFade`; the two combined in `u112_minimal_noise_exact`.  The two independent
lower-bound routes give the *same* constant, and the grid search agrees to `1.5 · 10⁻⁷`.

## 3. Sharp versus previous decorrelation certificate

At the recorded `a = corr(T, rate) = 0.462`, `b = corr(count, rate) = 0.415`:

```
sharp bound   a b + sqrt((1−a²)(1−b²)) = 0.99863234…
old catalog bound 1 − (a−b)²/2         = 0.9988955
```

Lean: `corr_le_sharp`, `u112_advantage_forces_decorrelation_sharp` (`≤ 0.99864`) and
`u112_sharp_beats_crude`.  Sharpness of the new bound is witnessed by an explicit planar
configuration (`sharp_bound_attained`), and the exact defect between the two bounds is the
identity `(1 − ab − (a−b)²/2)² − (1−a²)(1−b²) = (a−b)²(a+b)²/4`
(`crude_sub_sharp_identity`).

## 4. Small-prime quadratic-residue counts

```
p          :  3   5   7  11  13
#QR(p)     :  1   2   3   5   6
(p−1)/2    :  1   2   3   5   6
```

Two-prime dial law, `p = 7`, `q = 11` (over the `60` units of `ℤ/77`):

```
T = 0 : 15     T = 1 : 30     T = 2 : 15        (p−1)(q−1)/4 = 15
```

Lean: `two_mul_card_qrSet`, `card_pattern_SS/SN/NS/NN`, `qrDial_binomial`,
`two_mul_dial_variance` (variance exactly `1/2`, uniformly in `p, q`).

## 5. Counterexample hunt

* Searched for a `λ` making the four residuals of the recorded ladder smaller than `η*`
  (20001-point grid): none exists, consistent with the proved optimality.
* Checked whether the crude bound `1 − δ²/2` could ever beat the new sharp bound: the defect
  identity shows the difference is `(a−b)²(a+b)²/4 ≥ 0`, so never; equality only at
  `a = ±b` (`sharp_lt_crude` is strict off that locus).
* Checked whether the "plateau" reading of U108 survives: the second differences of the ladder
  are `−0.0128, +0.0306, −0.0134`, alternating in sign, so no single-sign convex fade fits —
  this is what forces the positive noise floor.
