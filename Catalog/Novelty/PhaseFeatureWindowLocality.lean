import Novelty.PhaseFeatureLiftCeiling

/-!
# Window locality: why a transferred coefficient makes the fit *worse* (paper 150, exp 482)

## Research context

Experiment 482 (`PHASE-SUBTHRESHOLD-LIFT`, seed 20260901) reports two facts that look
paradoxical side by side:

* in-window, adding the root-position phase block to the footprint dial lifts out-of-sample
  `R²` by a statistically indistinguishable `+0.008` (extended block `+0.004`);
* the *phase-only* arm scores `−0.077`, i.e. **worse than predicting the mean**, and the
  cross-window phase gain is significantly negative (hypothesis H2 confirmed), while the base
  dial itself degrades from `0.600` in-window to `0.400` cross-window.

A negative `R²` is impossible for a least-squares fit evaluated on its own training window, so
the negativity is a *certificate* — of exactly how far the transported coefficient sits from
the test window's own optimum.  This file makes that certificate quantitative.

Companion files: `Novelty.PhaseFeatureLiftCeiling` (the deterministic ceiling on the in-window
lift) and `Novelty.PhaseFeatureCharacterGram` (the arithmetic source of near-orthogonality).

## Main results

* `oosGain_eq`, `oosGain_completed_square` — the transported-coefficient gain is the exact
  quadratic `2β⟪e,f⟫ − β²‖f‖² = ‖f‖²(β*² − (β−β*)²)` around the test window's own optimum `β*`.
* `oosGain_le_gain`, `oosGain_optCoef` — the in-window arm is the maximum, so a *negative*
  measured gain can never come from the window it was fitted on.
* `transfer_deficit_eq` — **the transfer identity**: the whole shortfall of the transported
  model against the test window's optimum is `(β − β*)²‖f‖²`, nothing else.
* `oosGain_neg_of_sign_mismatch` — a sign flip of the covariance between windows forces a
  strictly negative gain, at least `β²‖f‖²` below zero.  This is the mechanism behind H2.
* `coefficient_miss_of_neg_gain` — negativity is equivalent to the transported coefficient
  missing the test optimum by more than the optimum's own size, `|β − β*| > |β*|`.
* `coefficient_miss_lower_bound` — the quantitative form: a measured relative gain of `−ρ`
  forces `(β − β*)² ≥ ρ‖e‖²/‖f‖²`.
* `phase_only_coefficient_miss` — the measured `−0.077` of the phase-only arm therefore
  certifies a standardized coefficient miss of at least `0.277`.
* `base_dial_transfer_deficit` — the `0.600 → 0.400` drop of the footprint dial certifies a
  standardized miss of at least `0.447`, i.e. the base dial is itself window-local, and by a
  larger margin than the phase block.
* `transferred_combo_gain_le` — the capstone joining the two files: whatever window a phase
  coefficient vector was trained on, its gain on the test window is still under the
  near-orthogonality ceiling `K ε²/(1−δ)`; transfer can only lose.
* `no_rescaling_rescues` — even optimally rescaling a transported coefficient cannot beat the
  test window's own single-feature gain.

## Lab notes (exp 482, seed 20260901)

```
arm                          R²        gain vs baseline    certified |β − β*| (‖f‖=‖e‖)
phase-only (transported)   -0.077          -0.077                 ≥ 0.277
base dial cross-window      0.400     0.600 in-window             ≥ 0.447
phase block in-window       0.608          +0.008                 (within ceiling 0.016)
```
-/

open Finset
open Catalog.Novelty.PhaseFeatureLiftCeiling

namespace Catalog.Novelty.PhaseFeatureWindowLocality

variable {ι : Type*} [Fintype ι]

/-- The residual energy removed on the *test* window by the transported coefficient `b`. -/
noncomputable def oosGain (e f : ι → ℝ) (b : ℝ) : ℝ :=
  sqnorm e - sqnorm (fun i => e i - b * f i)

/-- The test window's own least-squares coefficient `β* = ⟪e,f⟫/‖f‖²`. -/
noncomputable def optCoef (e f : ι → ℝ) : ℝ := dot e f / sqnorm f

/-- The transported gain is an exact downward parabola in the coefficient. -/
theorem oosGain_eq (e f : ι → ℝ) (b : ℝ) :
    oosGain e f b = 2 * b * dot e f - b ^ 2 * sqnorm f := by
  rw [oosGain, sqnorm_sub_smul]; ring

/-- **Completed square.**  Everything is measured from the test window's own optimum. -/
theorem oosGain_completed_square (e f : ι → ℝ) (b : ℝ) (hf : 0 < sqnorm f) :
    oosGain e f b = sqnorm f * ((optCoef e f) ^ 2 - (b - optCoef e f) ^ 2) := by
  rw [oosGain_eq, optCoef]
  field_simp
  ring

/-- At its own optimum the transported gain is the in-window gain. -/
theorem oosGain_optCoef (e f : ι → ℝ) (hf : 0 < sqnorm f) :
    oosGain e f (optCoef e f) = gain e f := by
  rw [oosGain_eq, optCoef, gain]
  field_simp
  ring

/-- **The transfer identity.**  The shortfall of a transported coefficient against the test
window's optimum is exactly the squared coefficient miss, scaled by the feature energy. -/
theorem transfer_deficit_eq (e f : ι → ℝ) (b : ℝ) (hf : 0 < sqnorm f) :
    gain e f - oosGain e f b = (b - optCoef e f) ^ 2 * sqnorm f := by
  rw [← oosGain_optCoef e f hf, oosGain_completed_square e f b hf,
    oosGain_completed_square e f (optCoef e f) hf]
  ring

/-- No transported coefficient can beat the test window's own fit. -/
theorem oosGain_le_gain (e f : ι → ℝ) (b : ℝ) : oosGain e f b ≤ gain e f := by
  rcases eq_or_lt_of_le (sqnorm_nonneg f) with hzero | hpos
  · have hd : dot e f = 0 := by
      have h := dot_sq_le e f
      rw [← hzero, mul_zero] at h
      exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp (le_antisymm h (sq_nonneg _))
    rw [oosGain_eq, hd, gain, hd, ← hzero]
    simp
  · have := transfer_deficit_eq e f b hpos
    nlinarith [sq_nonneg (b - optCoef e f), hpos]

/-- **A negative measured gain certifies a foreign coefficient.**  The in-window arm is always
nonnegative, so `oosGain < 0` proves the coefficient did not come from this window. -/
theorem neg_gain_certifies_window_mismatch (e f : ι → ℝ) (b : ℝ) (hf : 0 < sqnorm f)
    (hneg : oosGain e f b < 0) : b ≠ optCoef e f := by
  intro h
  rw [h, oosGain_optCoef e f hf] at hneg
  exact absurd (gain_nonneg e f) (not_le.mpr hneg)

/-- **Sign-flip mechanism (H2).**  If the covariance of feature and target flips sign between
the training and the test window, the transported coefficient is guaranteed to *hurt*, by at
least `β²‖f‖²`. -/
theorem oosGain_neg_of_sign_mismatch (e f : ι → ℝ) (b : ℝ) (hf : 0 < sqnorm f) (hb : b ≠ 0)
    (hsign : b * dot e f ≤ 0) : oosGain e f b ≤ -(b ^ 2 * sqnorm f) ∧ oosGain e f b < 0 := by
  have hb2 : 0 < b ^ 2 := by positivity
  have h1 : oosGain e f b ≤ -(b ^ 2 * sqnorm f) := by
    rw [oosGain_eq]
    nlinarith [hsign]
  exact ⟨h1, lt_of_le_of_lt h1 (by nlinarith)⟩

/-- Cross-window version: a coefficient fitted on window `1` with positive covariance, applied
to a window `2` on which the covariance is nonpositive, gives a strictly negative gain. -/
theorem cross_window_gain_neg_of_covariance_flip
    (e₁ f₁ e₂ f₂ : ι → ℝ) (h1 : 0 < sqnorm f₁) (h2 : 0 < sqnorm f₂)
    (hpos : 0 < dot e₁ f₁) (hflip : dot e₂ f₂ ≤ 0) :
    oosGain e₂ f₂ (optCoef e₁ f₁) < 0 := by
  have hb : 0 < optCoef e₁ f₁ := div_pos hpos h1
  have hsign : optCoef e₁ f₁ * dot e₂ f₂ ≤ 0 := mul_nonpos_of_nonneg_of_nonpos hb.le hflip
  exact (oosGain_neg_of_sign_mismatch e₂ f₂ _ h2 (ne_of_gt hb) hsign).2

/-- **Negativity ⇔ large coefficient miss.**  A negative transported gain says precisely that
the imported coefficient misses the local optimum by more than the local optimum's own size. -/
theorem coefficient_miss_of_neg_gain (e f : ι → ℝ) (b : ℝ) (hf : 0 < sqnorm f)
    (hneg : oosGain e f b < 0) : |optCoef e f| < |b - optCoef e f| := by
  have h := oosGain_completed_square e f b hf
  have hlt : (optCoef e f) ^ 2 < (b - optCoef e f) ^ 2 := by nlinarith
  calc |optCoef e f| = Real.sqrt ((optCoef e f) ^ 2) := (Real.sqrt_sq_eq_abs _).symm
    _ < Real.sqrt ((b - optCoef e f) ^ 2) := by
        exact Real.sqrt_lt_sqrt (sq_nonneg _) hlt
    _ = |b - optCoef e f| := Real.sqrt_sq_eq_abs _

/-- **Quantitative window-locality certificate.**  A measured relative out-of-sample gain of
`−ρ` (fraction of the test target energy) forces a coefficient miss of at least
`ρ ‖e‖² / ‖f‖²` in squared units. -/
theorem coefficient_miss_lower_bound (e f : ι → ℝ) (b ρ : ℝ) (hf : 0 < sqnorm f)
    (hmeas : oosGain e f b = -(ρ * sqnorm e)) :
    ρ * sqnorm e / sqnorm f ≤ (b - optCoef e f) ^ 2 := by
  have h := oosGain_completed_square e f b hf
  rw [hmeas] at h
  rw [div_le_iff₀ hf]
  nlinarith [sq_nonneg (optCoef e f)]

/-- Standardized form: with features scaled to the target energy (`‖f‖² = ‖e‖² > 0`), a
measured gain of `−ρ` forces `|β − β*| ≥ √ρ`. -/
theorem coefficient_miss_standardized (e f : ι → ℝ) (b ρ : ℝ) (hf : 0 < sqnorm f)
    (hstd : sqnorm f = sqnorm e)
    (hmeas : oosGain e f b = -(ρ * sqnorm e)) :
    Real.sqrt ρ ≤ |b - optCoef e f| := by
  have h := coefficient_miss_lower_bound e f b ρ hf hmeas
  rw [hstd] at h
  have he : 0 < sqnorm e := hstd ▸ hf
  have hρ' : ρ ≤ (b - optCoef e f) ^ 2 := by
    rwa [mul_div_assoc, div_self (ne_of_gt he), mul_one] at h
  calc Real.sqrt ρ ≤ Real.sqrt ((b - optCoef e f) ^ 2) := Real.sqrt_le_sqrt hρ'
    _ = |b - optCoef e f| := Real.sqrt_sq_eq_abs _

/-- **The phase-only arm.**  `R² = −0.077` on the test window certifies a standardized
coefficient miss of at least `0.277`: the phase coefficients are genuinely window-local, not
merely noisy. -/
theorem phase_only_coefficient_miss (e f : ι → ℝ) (b : ℝ) (hf : 0 < sqnorm f)
    (hstd : sqnorm f = sqnorm e)
    (hmeas : oosGain e f b = -((0.077 : ℝ) * sqnorm e)) :
    (0.277 : ℝ) ≤ |b - optCoef e f| := by
  have h := coefficient_miss_standardized e f b 0.077 hf hstd hmeas
  have hs : (0.277 : ℝ) ≤ Real.sqrt 0.077 := by
    rw [show (0.277 : ℝ) = Real.sqrt (0.277 ^ 2) by rw [Real.sqrt_sq] ; norm_num]
    exact Real.sqrt_le_sqrt (by norm_num)
  linarith

/-- **The base dial is window-local too.**  A `0.600` in-window score dropping to `0.400`
cross-window is a deficit of `0.200` of the target energy, certifying a standardized
coefficient miss of at least `0.447` — larger than the phase block's. -/
theorem base_dial_transfer_deficit (e f : ι → ℝ) (b : ℝ) (hf : 0 < sqnorm f)
    (hstd : sqnorm f = sqnorm e)
    (hopt : gain e f = (0.600 : ℝ) * sqnorm e)
    (hmeas : oosGain e f b = (0.400 : ℝ) * sqnorm e) :
    (0.447 : ℝ) ≤ |b - optCoef e f| := by
  have hdef := transfer_deficit_eq e f b hf
  rw [hopt, hmeas, hstd] at hdef
  have he : 0 < sqnorm e := hstd ▸ hf
  have hsq : (0.2 : ℝ) ≤ (b - optCoef e f) ^ 2 := by
    have : (0.600 : ℝ) * sqnorm e - 0.400 * sqnorm e = (b - optCoef e f) ^ 2 * sqnorm e := hdef
    nlinarith
  calc (0.447 : ℝ) = Real.sqrt (0.447 ^ 2) := by rw [Real.sqrt_sq] ; norm_num
    _ ≤ Real.sqrt ((b - optCoef e f) ^ 2) := Real.sqrt_le_sqrt (by nlinarith)
    _ = |b - optCoef e f| := Real.sqrt_sq_eq_abs _

/-- Rescaling a transported coefficient cannot beat the local optimum either. -/
theorem no_rescaling_rescues (e f : ι → ℝ) (b lam : ℝ) : oosGain e f (lam * b) ≤ gain e f :=
  oosGain_le_gain e f (lam * b)

section Capstone

variable {κ : Type*} [Fintype κ]

/-- **Capstone.**  Combining the two halves of the analysis: for a feature block that is
near-orthogonal on the test window (Gram off-diagonal `≤ δ`, residual correlations `≤ ε`),
*every* transported coefficient — trained on any other window, by any procedure — gains at most
`K ε² / (1 − δ)` of the residual energy.  Cross-window transfer can only subtract from an
already sub-threshold ceiling; it can never manufacture the split-ceiling excess. -/
theorem transferred_combo_gain_le (e : ι → ℝ) (f : κ → ι → ℝ) (ε δ : ℝ) (a : κ → ℝ) (b : ℝ)
    (hpos : ∀ k, 0 < sqnorm (f k))
    (hcorr : ∀ k, (dot e (f k)) ^ 2 ≤ ε ^ 2 * (sqnorm e * sqnorm (f k)))
    (hδ : δ < 1)
    (hstab : ∀ a : κ → ℝ, (1 - δ) * (∑ k, (a k) ^ 2 * sqnorm (f k)) ≤ sqnorm (combo a f)) :
    oosGain e (combo a f) b ≤ ((Fintype.card κ : ℝ) * ε ^ 2 / (1 - δ)) * sqnorm e :=
  le_trans (oosGain_le_gain e (combo a f) b) (span_gain_le e f ε δ hpos hcorr hδ hstab a)

end Capstone

end Catalog.Novelty.PhaseFeatureWindowLocality