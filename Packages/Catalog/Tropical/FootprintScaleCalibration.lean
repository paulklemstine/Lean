import Mathlib
import Tropical.WeightExponentDial

/-!
# Footprint-scale transfer: the exact algebra of calibration slopes (FACT round-40 #3)

Experiment 478 fitted the footprint-weighted yield dial at bit length 44, applied it at bit
lengths 48 and 52, and reported the **calibration slope** of the observed yield on the
transferred prediction (`0.896 / 0.834` at 80 values per `N`, `0.912 / 0.834` at 240 values
per `N`), together with the fact that the direct divisibility feature `d(N)` remains
significant after the dial has been partialled out.

This file proves the finite-sample algebra behind those three kinds of statement, for data
indexed by an arbitrary finite type `ι` (the moduli `N` of one cell).

* `cov`, `slope`, `rsq` — centred cross-products, the OLS slope of `y` on `x`, and `R²`.
* `cov_add_left`, `cov_smul_left`, `cov_const_left`, … — bilinearity of `cov`.
* `rsq_le_one` — Cauchy–Schwarz: `R² ≤ 1`.
* `slope_affine`, `rsq_affine` — affine reparametrisation of the dial changes the slope by
  the inverse scale and leaves `R²` invariant, so `R²` is comparable across bit lengths
  while the slope is the quantity that detects mis-scaling.
* `slope_attenuation` — the **errors-in-variables law**: if the prediction is
  `x = s + e` and the yield is `y = c • s + η` with mutually uncorrelated noises, then the
  calibration slope is exactly `c · V / (V + E)`.
* `slope_attenuation_le_one`, `slope_attenuation_eq_one_iff` — with `c = 1` the slope lies
  in `(0, 1]` and equals `1` iff the prediction is noiseless: slopes below one are what an
  honest transfer looks like.
* `slope_stable_forces_no_relation_noise` — if the slope is the same at two different relation
  counts (as at bit length 52, `0.834 = 0.834`), the relation-count noise component vanishes,
  so the deficit `1 - 0.834` is *scale drift*, not attenuation.
* `fwl_partial_slope` — the **Frisch–Waugh–Lovell identity** for two regressors: the partial
  coefficient of `d(N)` equals the simple slope of `y` on the residual of `d(N)` after
  regressing on the dial; `normal_equations` and `residual_orthogonal` are proved too.
* `partial_coef_ne_zero_iff` — `d(N)` carries independent signal iff its residual covariance
  with the yield is nonzero.
* `partialRsq_of_t`, `partialRsq_lower_bound_exp478_80`, `partialRsq_lower_bound_exp478_240`
  — the `t`-statistic/partial-`R²` dictionary; `min |t| = 3.92` forces a partial `R²` of
  `d(N)` above `0.166` at 77 residual degrees of freedom but only above `0.06` at 237
  (`tThreshold_strictAnti`).
* `tendsto_rsq_tropical` — the tropical bridge to `WeightDial`: as the dial exponent
  `α → ∞`, the `R²` of the normalised log-dial converges to the `R²` of the min-plus
  (smallest active prime) statistic.
-/

open Finset Filter Topology

namespace FootprintScale

variable {ι : Type*} [Fintype ι]

/-- Sample mean of a data column. -/
noncomputable def mean (x : ι → ℝ) : ℝ := (∑ i, x i) / Fintype.card ι

/-- Centred cross-product sum `∑ (xᵢ - x̄)(yᵢ - ȳ)` (an unnormalised covariance). -/
noncomputable def cov (x y : ι → ℝ) : ℝ := ∑ i, (x i - mean x) * (y i - mean y)

/-- OLS slope of `y` on `x`: the calibration slope when `x` is the transferred prediction. -/
noncomputable def slope (x y : ι → ℝ) : ℝ := cov x y / cov x x

/-- Coefficient of determination of the simple regression of `y` on `x`. -/
noncomputable def rsq (x y : ι → ℝ) : ℝ := cov x y ^ 2 / (cov x x * cov y y)

/-! ### Bilinearity -/

lemma mean_add (x z : ι → ℝ) : mean (x + z) = mean x + mean z := by
  simp [mean, Finset.sum_add_distrib, add_div]

lemma mean_smul (c : ℝ) (x : ι → ℝ) : mean (c • x) = c * mean x := by
  simp [mean, ← Finset.mul_sum, mul_div_assoc]

lemma mean_const [Nonempty ι] (a : ℝ) : mean (fun _ : ι => a) = a := by
  have : (Fintype.card ι : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  simp [mean]

lemma cov_comm (x y : ι → ℝ) : cov x y = cov y x := by
  simp only [cov]; exact Finset.sum_congr rfl fun i _ => mul_comm _ _

lemma cov_add_left (x z y : ι → ℝ) : cov (x + z) y = cov x y + cov z y := by
  simp only [cov, mean_add, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun i _ => by simp only [Pi.add_apply]; ring

lemma cov_add_right (x y z : ι → ℝ) : cov x (y + z) = cov x y + cov x z := by
  rw [cov_comm, cov_add_left, cov_comm y, cov_comm z]

lemma cov_smul_left (c : ℝ) (x y : ι → ℝ) : cov (c • x) y = c * cov x y := by
  simp only [cov, mean_smul, Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by simp only [Pi.smul_apply, smul_eq_mul]; ring

lemma cov_smul_right (c : ℝ) (x y : ι → ℝ) : cov x (c • y) = c * cov x y := by
  rw [cov_comm, cov_smul_left, cov_comm]

lemma cov_const_left [Nonempty ι] (a : ℝ) (y : ι → ℝ) : cov (fun _ => a) y = 0 := by
  simp [cov, mean_const]

lemma cov_sub_left (x z y : ι → ℝ) : cov (x - z) y = cov x y - cov z y := by
  have h := cov_add_left x ((-1 : ℝ) • z) y
  rw [cov_smul_left] at h
  rw [sub_eq_add_neg, show -z = (-1 : ℝ) • z by simp, h]; ring

lemma cov_sub_right (x y z : ι → ℝ) : cov x (y - z) = cov x y - cov x z := by
  rw [cov_comm, cov_sub_left, cov_comm y, cov_comm z]

lemma cov_self_nonneg (x : ι → ℝ) : 0 ≤ cov x x :=
  Finset.sum_nonneg fun _ _ => mul_self_nonneg _

/-- Translating the prediction does not change any covariance. -/
lemma cov_add_const_left [Nonempty ι] (a : ℝ) (x y : ι → ℝ) :
    cov (fun i => a + x i) y = cov x y := by
  have : (fun i => a + x i) = (fun _ => a) + x := rfl
  rw [this, cov_add_left, cov_const_left, zero_add]

/-! ### Cauchy–Schwarz and affine invariance -/

/-- `R² ≤ 1` (Cauchy–Schwarz on the centred columns). -/
theorem rsq_le_one (x y : ι → ℝ) : rsq x y ≤ 1 := by
  unfold rsq
  have hcs : cov x y ^ 2 ≤ cov x x * cov y y := by
    have := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (fun i => x i - mean x)
      (fun i => y i - mean y)
    simpa [cov, sq] using this
  rcases (mul_nonneg (cov_self_nonneg x) (cov_self_nonneg y)).eq_or_lt with h | h
  · rw [← h, div_zero]; exact zero_le_one
  · rw [div_le_one h]; exact hcs

lemma rsq_nonneg (x y : ι → ℝ) : 0 ≤ rsq x y :=
  div_nonneg (sq_nonneg _) (mul_nonneg (cov_self_nonneg x) (cov_self_nonneg y))

/-- Affine rescaling of the dial `x ↦ a + b x` divides the calibration slope by `b`. -/
lemma cov_affine_left [Nonempty ι] (a b : ℝ) (x z : ι → ℝ) :
    cov (fun i => a + b * x i) z = b * cov x z := by
  have hx : (fun i => a + b * x i) = (fun i => a + (b • x) i) := rfl
  rw [hx, cov_add_const_left, cov_smul_left]

lemma cov_affine_self [Nonempty ι] (a b : ℝ) (x : ι → ℝ) :
    cov (fun i => a + b * x i) (fun i => a + b * x i) = b ^ 2 * cov x x := by
  rw [cov_affine_left, cov_comm, cov_affine_left]; ring

theorem slope_affine [Nonempty ι] (a b : ℝ) (hb : b ≠ 0) (x y : ι → ℝ) :
    slope (fun i => a + b * x i) y = slope x y / b := by
  unfold slope
  rw [cov_affine_left, cov_affine_self]
  rcases eq_or_ne (cov x x) 0 with h | h
  · simp [h]
  · field_simp

/-- `R²` is invariant under nondegenerate affine rescaling of the dial: it is the
scale-free part of the transfer, while the slope carries the scale. -/
theorem rsq_affine [Nonempty ι] (a b : ℝ) (hb : b ≠ 0) (x y : ι → ℝ) :
    rsq (fun i => a + b * x i) y = rsq x y := by
  unfold rsq
  rw [cov_affine_left, cov_affine_self]
  rcases eq_or_ne (cov x x * cov y y) 0 with h | h
  · rcases mul_eq_zero.mp h with h' | h' <;> simp [h']
  · have hxx : cov x x ≠ 0 := left_ne_zero_of_mul h
    have hyy : cov y y ≠ 0 := right_ne_zero_of_mul h
    field_simp

/-! ### Errors-in-variables: the attenuation law for calibration slopes -/

/-- **Attenuation law.**  Prediction `x = s + e`, yield `y = c • s + η`, with the true signal
`s` and the two noises mutually uncorrelated.  Then the calibration slope is exactly
`c · V / (V + E)` with `V = cov s s`, `E = cov e e`. -/
theorem slope_attenuation (s e η : ι → ℝ) (c : ℝ)
    (hse : cov s e = 0) (hsη : cov s η = 0) (heη : cov e η = 0) :
    slope (s + e) (c • s + η) = c * cov s s / (cov s s + cov e e) := by
  unfold slope
  have hes : cov e s = 0 := by rw [cov_comm]; exact hse
  simp only [cov_add_left, cov_add_right, cov_smul_right]
  rw [hse, hsη, heη, hes]
  congr 1 <;> ring

/-- With no scale drift (`c = 1`) and a nondegenerate signal, the calibration slope lies in
`(0, 1]`. -/
theorem slope_attenuation_le_one (s e η : ι → ℝ)
    (hse : cov s e = 0) (hsη : cov s η = 0) (heη : cov e η = 0) (hV : 0 < cov s s) :
    0 < slope (s + e) (s + η) ∧ slope (s + e) (s + η) ≤ 1 := by
  have h := slope_attenuation s e η 1 hse hsη heη
  rw [one_smul, one_mul] at h
  have hE := cov_self_nonneg e
  rw [h]
  exact ⟨by positivity, by rw [div_le_one (by linarith)]; linarith⟩

/-- … and the slope equals `1` exactly when the prediction is noiseless. -/
theorem slope_attenuation_eq_one_iff (s e η : ι → ℝ)
    (hse : cov s e = 0) (hsη : cov s η = 0) (heη : cov e η = 0) (hV : 0 < cov s s) :
    slope (s + e) (s + η) = 1 ↔ cov e e = 0 := by
  have h := slope_attenuation s e η 1 hse hsη heη
  rw [one_smul, one_mul] at h
  have hE := cov_self_nonneg e
  rw [h, div_eq_one_iff_eq (by linarith)]
  constructor <;> intro h' <;> linarith

/-- Attenuated slope as a function of the relation count `m`: the prediction noise splits
into a fixed part `E₀` and a part `σ / m` averaged down by the relations. -/
noncomputable def attSlope (c V E₀ σ m : ℝ) : ℝ := c * V / (V + E₀ + σ / m)

/-- More relations never hurt calibration: for `c, V > 0`, `E₀, σ ≥ 0` the attenuated slope
is monotone in the relation count. -/
theorem attSlope_mono {c V E₀ σ m₁ m₂ : ℝ} (hc : 0 < c) (hV : 0 < V) (hE : 0 ≤ E₀)
    (hσ : 0 ≤ σ) (hm₁ : 0 < m₁) (hm : m₁ ≤ m₂) :
    attSlope c V E₀ σ m₁ ≤ attSlope c V E₀ σ m₂ := by
  unfold attSlope
  have hm₂ : 0 < m₂ := lt_of_lt_of_le hm₁ hm
  have h1 : σ / m₂ ≤ σ / m₁ := div_le_div_of_nonneg_left hσ hm₁ hm
  apply div_le_div_of_nonneg_left (by positivity) (by positivity)
  linarith

/-- **Stable slope ⇒ no relation-count noise.**  If the calibration slope is identical at two
different relation counts, then the relation-averaged noise vanishes (`σ = 0`): the
miscalibration is entirely scale drift `c` and fixed noise `E₀`.  This is the bit-length-52
reading of experiment 478 (`0.834` at both 80 and 240 values per `N`). -/
theorem slope_stable_forces_no_relation_noise {c V E₀ σ m₁ m₂ : ℝ} (hc : 0 < c)
    (hV : 0 < V) (hE : 0 ≤ E₀) (hσ : 0 ≤ σ) (hm₁ : 0 < m₁) (hm : m₁ < m₂)
    (heq : attSlope c V E₀ σ m₁ = attSlope c V E₀ σ m₂) : σ = 0 := by
  unfold attSlope at heq
  have hm₂ : 0 < m₂ := lt_trans hm₁ hm
  have hd1 : 0 < V + E₀ + σ / m₁ := by positivity
  have hd2 : 0 < V + E₀ + σ / m₂ := by positivity
  rw [div_eq_div_iff hd1.ne' hd2.ne'] at heq
  have hcV : 0 < c * V := mul_pos hc hV
  have : σ / m₁ = σ / m₂ := by
    have := mul_left_cancel₀ hcV.ne' heq
    linarith
  rw [div_eq_div_iff hm₁.ne' hm₂.ne'] at this
  by_contra hne
  have hσpos : 0 < σ := lt_of_le_of_ne hσ (Ne.symm hne)
  nlinarith

/-! ### Frisch–Waugh–Lovell for the dial and the divisibility feature -/

/-- Partial OLS coefficient of `x₂` (the divisibility feature `d(N)`) in the regression of
`y` on `x₁` (the dial) and `x₂`. -/
noncomputable def partialCoef₂ (x₁ x₂ y : ι → ℝ) : ℝ :=
  (cov x₁ x₁ * cov x₂ y - cov x₁ x₂ * cov x₁ y) /
    (cov x₁ x₁ * cov x₂ x₂ - cov x₁ x₂ ^ 2)

/-- Partial OLS coefficient of the dial `x₁`. -/
noncomputable def partialCoef₁ (x₁ x₂ y : ι → ℝ) : ℝ :=
  (cov x₂ x₂ * cov x₁ y - cov x₁ x₂ * cov x₂ y) /
    (cov x₁ x₁ * cov x₂ x₂ - cov x₁ x₂ ^ 2)

/-- Residual of `x₂` after regressing it on `x₁`. -/
noncomputable def resid (x₁ x₂ : ι → ℝ) : ι → ℝ := x₂ - slope x₁ x₂ • x₁

/-- The two partial coefficients solve the normal equations whenever the design is
nondegenerate. -/
theorem normal_equations (x₁ x₂ y : ι → ℝ)
    (hD : cov x₁ x₁ * cov x₂ x₂ - cov x₁ x₂ ^ 2 ≠ 0) :
    cov x₁ x₁ * partialCoef₁ x₁ x₂ y + cov x₁ x₂ * partialCoef₂ x₁ x₂ y = cov x₁ y ∧
    cov x₁ x₂ * partialCoef₁ x₁ x₂ y + cov x₂ x₂ * partialCoef₂ x₁ x₂ y = cov x₂ y := by
  unfold partialCoef₁ partialCoef₂
  constructor <;>
  · rw [mul_div_assoc', mul_div_assoc', ← add_div, div_eq_iff hD]; ring

/-- The residual is orthogonal to the dial. -/
theorem residual_orthogonal (x₁ x₂ : ι → ℝ) (h₁ : cov x₁ x₁ ≠ 0) :
    cov x₁ (resid x₁ x₂) = 0 := by
  unfold resid slope
  rw [cov_comm, cov_sub_left, cov_smul_left, cov_comm x₂]
  field_simp; ring

/-- **Frisch–Waugh–Lovell.**  The partial coefficient of `d(N)` equals the simple calibration
slope of the yield on the residual of `d(N)` after the dial has been partialled out. -/
theorem fwl_partial_slope (x₁ x₂ y : ι → ℝ) (h₁ : cov x₁ x₁ ≠ 0) :
    partialCoef₂ x₁ x₂ y = slope (resid x₁ x₂) y := by
  have hy : cov (resid x₁ x₂) y =
      (cov x₁ x₁ * cov x₂ y - cov x₁ x₂ * cov x₁ y) / cov x₁ x₁ := by
    unfold resid slope
    rw [cov_sub_left, cov_smul_left]
    field_simp
  have hrr : cov (resid x₁ x₂) (resid x₁ x₂) =
      (cov x₁ x₁ * cov x₂ x₂ - cov x₁ x₂ ^ 2) / cov x₁ x₁ := by
    unfold resid slope
    rw [cov_sub_left, cov_smul_left, cov_sub_right, cov_sub_right, cov_smul_right,
      cov_smul_right, cov_comm x₂ x₁]
    field_simp
    ring
  unfold partialCoef₂ slope
  rw [hy, hrr, div_div_div_cancel_right₀ h₁]

/-- `d(N)` contributes independently of the dial iff its residual covariance with the yield
is nonzero, i.e. iff `cov(x₁,x₁)·cov(x₂,y) ≠ cov(x₁,x₂)·cov(x₁,y)`. -/
theorem partial_coef_ne_zero_iff (x₁ x₂ y : ι → ℝ) (h₁ : cov x₁ x₁ ≠ 0)
    (hD : cov x₁ x₁ * cov x₂ x₂ - cov x₁ x₂ ^ 2 ≠ 0) :
    partialCoef₂ x₁ x₂ y ≠ 0 ↔ cov (resid x₁ x₂) y ≠ 0 := by
  have hres : cov (resid x₁ x₂) y * cov x₁ x₁ =
      cov x₁ x₁ * cov x₂ y - cov x₁ x₂ * cov x₁ y := by
    unfold resid slope
    rw [cov_sub_left, cov_smul_left]
    field_simp
  unfold partialCoef₂
  rw [div_ne_zero_iff, ← hres]
  constructor
  · rintro ⟨h, -⟩ h0; exact h (by rw [h0, zero_mul])
  · intro h; exact ⟨mul_ne_zero h h₁, hD⟩

/-! ### `t`-statistics and partial `R²` -/

/-- The squared `t`-statistic of a coefficient with partial `R²` equal to `ρ` and `df`
residual degrees of freedom. -/
noncomputable def tSq (df ρ : ℝ) : ℝ := df * ρ / (1 - ρ)

/-- Inverting the dictionary: the partial `R²` is `t² / (t² + df)`. -/
theorem partialRsq_of_t {df ρ : ℝ} (hdf : 0 < df) (hρ1 : ρ < 1) :
    ρ = tSq df ρ / (tSq df ρ + df) := by
  unfold tSq
  have h1 : (0 : ℝ) < 1 - ρ := by linarith
  have h2 : df * ρ / (1 - ρ) + df = df / (1 - ρ) := by field_simp; ring
  rw [h2]
  field_simp

/-- A threshold on `|t|` is a threshold on the partial `R²`: `t² ≥ τ²` iff
`ρ ≥ τ² / (τ² + df)`. -/
theorem tSq_ge_iff {df ρ τ : ℝ} (hdf : 0 < df) (hρ1 : ρ < 1) :
    τ ^ 2 ≤ tSq df ρ ↔ τ ^ 2 / (τ ^ 2 + df) ≤ ρ := by
  unfold tSq
  have h1 : (0 : ℝ) < 1 - ρ := by linarith
  have h2 : 0 < τ ^ 2 + df := by positivity
  rw [le_div_iff₀ h1, div_le_iff₀ h2]
  constructor <;> intro h <;> nlinarith

/-- **Experiment 478 reading (80 values per `N`).**  With `min |t| = 3.92` and `80 - 3 = 77`
residual degrees of freedom (intercept, dial, `d(N)`), the divisibility feature explains
more than `16.6 %` of the residual yield variance. -/
theorem partialRsq_lower_bound_exp478_80 {ρ : ℝ} (hρ1 : ρ < 1)
    (ht : (3.92 : ℝ) ^ 2 ≤ tSq 77 ρ) : (0.166 : ℝ) < ρ := by
  have h := (tSq_ge_iff (by norm_num : (0 : ℝ) < 77) hρ1).mp ht
  have : (0.166 : ℝ) < (3.92 : ℝ) ^ 2 / ((3.92 : ℝ) ^ 2 + 77) := by norm_num
  linarith

/-- **Experiment 478 reading (240 values per `N`).**  At `240 - 3 = 237` residual degrees of
freedom the same `|t| ≥ 3.92` still forces a partial `R²` above `6 %`: significance at the
larger relation count is a *weaker* effect-size statement, which is why the 12/12
significance count is not by itself evidence that `d(N)` grows in importance. -/
theorem partialRsq_lower_bound_exp478_240 {ρ : ℝ} (hρ1 : ρ < 1)
    (ht : (3.92 : ℝ) ^ 2 ≤ tSq 237 ρ) : (0.06 : ℝ) < ρ := by
  have h := (tSq_ge_iff (by norm_num : (0 : ℝ) < 237) hρ1).mp ht
  have : (0.06 : ℝ) < (3.92 : ℝ) ^ 2 / ((3.92 : ℝ) ^ 2 + 237) := by norm_num
  linarith

/-- The effect-size threshold implied by a fixed `|t|` cutoff strictly decreases with the
degrees of freedom. -/
theorem tThreshold_strictAnti {τ df₁ df₂ : ℝ} (hτ : τ ≠ 0) (h1 : 0 < df₁) (h : df₁ < df₂) :
    τ ^ 2 / (τ ^ 2 + df₂) < τ ^ 2 / (τ ^ 2 + df₁) := by
  have hτ2 : 0 < τ ^ 2 := by positivity
  apply div_lt_div_of_pos_left hτ2 (by positivity) (by linarith)

/-! ### Tropical bridge: the `R²` of the dial at the min-plus endpoint -/

lemma continuous_cov_left (y : ι → ℝ) : Continuous fun x : ι → ℝ => cov x y := by
  unfold cov mean
  fun_prop

lemma continuous_cov_self : Continuous fun x : ι → ℝ => cov x x := by
  unfold cov mean
  fun_prop

/-- **Tropical limit of the dial's explanatory power.**  Let `supp N` be the active prime
support of modulus `N` and `x_α(N) = (log S_α(N))/α` the normalised log-dial of
`WeightDial`.  As `α → ∞`, the `R²` of `x_α` against any yield column converges to the `R²`
of the min-plus statistic `-log (min supp N)`, provided the latter is nondegenerate. -/
theorem tendsto_rsq_tropical (supp : ι → Finset ℕ) (hne : ∀ N, (supp N).Nonempty)
    (h2 : ∀ N, ∀ l ∈ supp N, 2 ≤ l) (y : ι → ℝ)
    (hdeg : cov (fun N => -Real.log ((supp N).min' (hne N))) (fun N =>
      -Real.log ((supp N).min' (hne N))) * cov y y ≠ 0) :
    Tendsto (fun α : ℝ => rsq (fun N => Real.log (WeightDial.dialSum (supp N) α) / α) y)
      atTop (𝓝 (rsq (fun N => -Real.log ((supp N).min' (hne N))) y)) := by
  set t : ι → ℝ := fun N => -Real.log ((supp N).min' (hne N))
  have hx : Tendsto (fun α : ℝ => fun N => Real.log (WeightDial.dialSum (supp N) α) / α)
      atTop (𝓝 t) :=
    tendsto_pi_nhds.mpr fun N => WeightDial.tendsto_log_dialSum_div (hne N) (h2 N)
  have hnum := ((continuous_cov_left y).tendsto t).comp hx
  have hden := (continuous_cov_self.tendsto t).comp hx
  unfold rsq
  exact (hnum.pow 2).div (hden.mul_const _) hdeg

end FootprintScale