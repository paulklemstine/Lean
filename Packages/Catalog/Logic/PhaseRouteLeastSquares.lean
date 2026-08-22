/-
# Finite-sample least squares: the exact incremental-`R²` calculus

This file builds, from scratch, the algebraic core needed to state and prove
*negative* results about feature encodings in a finite-sample linear model:

* `Logic.PhaseRoute.avg`, `cov`, `varr`   — empirical mean / covariance / variance,
* `Logic.PhaseRoute.msse`                — mean squared error of a predictor,
* `Logic.PhaseRoute.Rsq`                 — coefficient of determination against the
  constant (intercept-only) baseline.

The main results are exact identities, not inequalities-with-slack:

* `msse_decomp` : `msse y h = varr y - 2*cov y h + varr h + (avg y - avg h)^2`,
  the complete bias/variance/alignment split of the error of *any* predictor;
* `msse_ge_varr_of_cov_eq_zero` and its strict form `msse_gt_varr_of_cov_eq_zero`
  : a predictor uncorrelated with the target is *never* useful and is strictly
  harmful unless it is constant;
* `msse_affine_lower_bound` / `msse_affine_opt` : the optimal single-feature
  affine fit and its exact error, hence
* `Rsq_affine_le_corr_sq` / `Rsq_affine_opt_eq_corr_sq` : the best attainable
  `R²` of a one-feature model is *exactly* the squared empirical correlation.

As a by-product we derive Cauchy–Schwarz for the empirical covariance
(`cov_sq_le`) from the regression identity rather than the other way round.

This is the "dial" calculus used in `Logic.PhaseRouteAlignment` to prove that a
whole family of encodings is provably worthless while a degree-`2` interaction
encoding is provably perfect.
-/
import Mathlib

namespace Logic.PhaseRoute

open Finset

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- Empirical mean of `f` over the (finite, nonempty) sample space. -/
noncomputable def avg (f : ι → ℝ) : ℝ := (∑ i, f i) / (Fintype.card ι : ℝ)

/-- Empirical covariance. -/
noncomputable def cov (f g : ι → ℝ) : ℝ := avg (fun i => f i * g i) - avg f * avg g

/-- Empirical variance. -/
noncomputable def varr (f : ι → ℝ) : ℝ := cov f f

/-- Mean squared error of the predictor `h` for the target `y`. -/
noncomputable def msse (y h : ι → ℝ) : ℝ := avg (fun i => (y i - h i) * (y i - h i))

/-- Coefficient of determination of `h` relative to the intercept-only baseline. -/
noncomputable def Rsq (y h : ι → ℝ) : ℝ := 1 - msse y h / varr y

lemma card_ne_zero : ((Fintype.card ι : ℝ)) ≠ 0 := by
  have : 0 < Fintype.card ι := Fintype.card_pos
  positivity

/-! ### Linearity of the empirical mean -/

omit [Nonempty ι] in
lemma avg_add (f g : ι → ℝ) : avg (fun i => f i + g i) = avg f + avg g := by
  simp [avg, Finset.sum_add_distrib, add_div]

omit [Nonempty ι] in
lemma avg_sub (f g : ι → ℝ) : avg (fun i => f i - g i) = avg f - avg g := by
  simp [avg, Finset.sum_sub_distrib, sub_div]

omit [Nonempty ι] in
lemma avg_const_mul (c : ℝ) (f : ι → ℝ) : avg (fun i => c * f i) = c * avg f := by
  simp [avg, ← Finset.mul_sum, mul_div_assoc]

lemma avg_const (c : ℝ) : avg (fun _ : ι => c) = c := by
  have h := card_ne_zero (ι := ι)
  simp only [avg, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

lemma avg_nonneg {f : ι → ℝ} (hf : ∀ i, 0 ≤ f i) : 0 ≤ avg f := by
  have h1 : (0:ℝ) ≤ ∑ i, f i := Finset.sum_nonneg fun i _ => hf i
  have h2 : (0:ℝ) < (Fintype.card ι : ℝ) := by
    have : 0 < Fintype.card ι := Fintype.card_pos
    positivity
  exact div_nonneg h1 h2.le

/-- The mean of a nonnegative function vanishes only if the function vanishes. -/
lemma avg_eq_zero_iff {f : ι → ℝ} (hf : ∀ i, 0 ≤ f i) : avg f = 0 ↔ ∀ i, f i = 0 := by
  have h2 : ((Fintype.card ι : ℝ)) ≠ 0 := card_ne_zero
  constructor
  · intro h i
    have hs : (∑ i, f i) = 0 := by
      rw [avg, div_eq_zero_iff] at h
      rcases h with h | h
      · exact h
      · exact absurd h h2
    exact (Finset.sum_eq_zero_iff_of_nonneg (fun j _ => hf j)).1 hs i (Finset.mem_univ i)
  · intro h
    simp [avg, h]

/-! ### Variance -/

lemma varr_eq_avg_centered_sq (f : ι → ℝ) :
    varr f = avg (fun i => (f i - avg f) * (f i - avg f)) := by
  have hcong : (fun i => (f i - avg f) * (f i - avg f))
      = (fun i => (f i * f i - 2 * (avg f * f i)) + avg f * avg f) := by
    funext i; ring
  rw [hcong, avg_add, avg_sub, avg_const_mul, avg_const_mul, avg_const]
  simp only [varr, cov]
  ring

lemma varr_nonneg (f : ι → ℝ) : 0 ≤ varr f := by
  rw [varr_eq_avg_centered_sq]
  exact avg_nonneg fun i => mul_self_nonneg _

/-- Zero variance forces the function to be (everywhere) equal to its mean. -/
lemma eq_avg_of_varr_eq_zero {f : ι → ℝ} (h : varr f = 0) (i : ι) : f i = avg f := by
  rw [varr_eq_avg_centered_sq] at h
  have := (avg_eq_zero_iff (f := fun i => (f i - avg f) * (f i - avg f))
    (fun i => mul_self_nonneg _)).1 h i
  have : f i - avg f = 0 := by
    rcases mul_self_eq_zero.1 this with h'
    exact h'
  linarith

lemma varr_const (c : ℝ) : varr (fun _ : ι => c) = 0 := by
  simp [varr, cov, avg_const]

/-! ### The exact error decomposition -/

omit [Nonempty ι] in
lemma msse_eq (y h : ι → ℝ) :
    msse y h = avg (fun i => y i * y i) - 2 * avg (fun i => y i * h i)
      + avg (fun i => h i * h i) := by
  have hcong : (fun i => (y i - h i) * (y i - h i))
      = (fun i => (y i * y i - 2 * (y i * h i)) + h i * h i) := by
    funext i; ring
  rw [msse, hcong, avg_add, avg_sub, avg_const_mul]

omit [Nonempty ι] in
/-- **Exact bias/variance/alignment split.** For every predictor `h`, the mean
squared error decomposes into the target variance, minus twice the covariance,
plus the predictor variance, plus the squared mean offset. -/
theorem msse_decomp (y h : ι → ℝ) :
    msse y h = varr y - 2 * cov y h + varr h + (avg y - avg h) * (avg y - avg h) := by
  rw [msse_eq]
  simp [varr, cov]
  ring

lemma msse_nonneg (y h : ι → ℝ) : 0 ≤ msse y h :=
  avg_nonneg fun _ => mul_self_nonneg _

/-- The intercept-only baseline attains exactly the target variance. -/
theorem cov_const_right (y : ι → ℝ) (c : ℝ) : cov y (fun _ => c) = 0 := by
  have hfun : (fun i => y i * c) = (fun i => c * y i) := by funext i; ring
  simp only [cov, hfun, avg_const, avg_const_mul]
  ring

theorem msse_const_baseline (y : ι → ℝ) : msse y (fun _ => avg y) = varr y := by
  rw [msse_decomp, cov_const_right, varr_const, avg_const]
  ring

theorem Rsq_const_baseline (y : ι → ℝ) : Rsq y (fun _ => avg y) = 1 - varr y / varr y := by
  rw [Rsq, msse_const_baseline]

/-- With a nondegenerate target the baseline `R²` is `0`: this is the zero point
against which every "gain" is measured. -/
theorem Rsq_const_baseline_eq_zero {y : ι → ℝ} (hy : varr y ≠ 0) :
    Rsq y (fun _ => avg y) = 0 := by
  rw [Rsq_const_baseline, div_self hy, sub_self]

/-! ### Uncorrelated predictors are useless, and strictly harmful unless constant -/

/-- **No-gain theorem.** A predictor with zero empirical covariance with the
target can never beat the constant baseline. -/
theorem msse_ge_varr_of_cov_eq_zero {y h : ι → ℝ} (hc : cov y h = 0) :
    varr y ≤ msse y h := by
  have hv := varr_nonneg h
  have hsq : 0 ≤ (avg y - avg h) * (avg y - avg h) := mul_self_nonneg _
  rw [msse_decomp, hc]
  linarith

/-- **Strict-harm theorem.** An uncorrelated *nonconstant* predictor is strictly
worse than the baseline: the excess error is exactly its own variance. -/
theorem msse_gt_varr_of_cov_eq_zero {y h : ι → ℝ} (hc : cov y h = 0)
    (hv : varr h ≠ 0) : varr y < msse y h := by
  have hv' : 0 < varr h := lt_of_le_of_ne (varr_nonneg h) (Ne.symm hv)
  have hsq : 0 ≤ (avg y - avg h) * (avg y - avg h) := mul_self_nonneg _
  rw [msse_decomp, hc]
  linarith

omit [Nonempty ι] in
/-- The excess error of an uncorrelated predictor is *exactly* its variance plus
its squared mean offset — no hidden slack. -/
theorem msse_excess_of_cov_eq_zero {y h : ι → ℝ} (hc : cov y h = 0) :
    msse y h - varr y = varr h + (avg y - avg h) * (avg y - avg h) := by
  rw [msse_decomp, hc]; ring

/-- In `R²` terms: an uncorrelated predictor has nonpositive `R²`. -/
theorem Rsq_nonpos_of_cov_eq_zero {y h : ι → ℝ} (hc : cov y h = 0) (hy : 0 < varr y) :
    Rsq y h ≤ 0 := by
  have hle := msse_ge_varr_of_cov_eq_zero hc
  have : 1 ≤ msse y h / varr y := by
    rw [le_div_iff₀ hy]; linarith
  simp only [Rsq]
  linarith

/-! ### The optimal single-feature affine model -/

lemma cov_affine (y f : ι → ℝ) (a b : ℝ) :
    cov y (fun i => a * f i + b) = a * cov y f := by
  have h1 : (fun i => y i * (a * f i + b)) = (fun i => a * (y i * f i) + b * y i) := by
    funext i; ring
  simp only [cov, h1]
  rw [avg_add, avg_const_mul, avg_const_mul, avg_add, avg_const_mul, avg_const]
  ring

lemma varr_affine (f : ι → ℝ) (a b : ℝ) :
    varr (fun i => a * f i + b) = a * a * varr f := by
  have h1 : (fun i => (a * f i + b) * (a * f i + b))
      = (fun i => (a * a) * (f i * f i) + (2 * (a * b) * f i + b * b)) := by
    funext i; ring
  simp only [varr, cov, h1]
  rw [avg_add, avg_const_mul, avg_add, avg_const_mul, avg_const, avg_add,
    avg_const_mul, avg_const]
  ring

lemma avg_affine (f : ι → ℝ) (a b : ℝ) : avg (fun i => a * f i + b) = a * avg f + b := by
  rw [avg_add, avg_const_mul, avg_const]

/-- **Lower bound for one-feature regression.** No affine function of a single
feature `f` can beat `varr y - cov y f ^ 2 / varr f`. -/
theorem msse_affine_lower_bound {y f : ι → ℝ} (hf : 0 < varr f) (a b : ℝ) :
    varr y - cov y f * cov y f / varr f ≤ msse y (fun i => a * f i + b) := by
  have hd := msse_decomp y (fun i => a * f i + b)
  rw [cov_affine, varr_affine] at hd
  have hsq : 0 ≤ (avg y - avg (fun i => a * f i + b)) * (avg y - avg (fun i => a * f i + b)) :=
    mul_self_nonneg _
  have key : 0 ≤ (a * varr f - cov y f) * (a * varr f - cov y f) / varr f :=
    div_nonneg (mul_self_nonneg _) hf.le
  have expand : (a * varr f - cov y f) * (a * varr f - cov y f) / varr f
      = a * a * varr f - 2 * (a * cov y f) + cov y f * cov y f / varr f := by
    field_simp; ring
  rw [expand] at key
  linarith

/-- The optimal slope/intercept attain the bound exactly. -/
theorem msse_affine_opt {y f : ι → ℝ} (hf : 0 < varr f) :
    msse y (fun i => (cov y f / varr f) * f i + (avg y - (cov y f / varr f) * avg f))
      = varr y - cov y f * cov y f / varr f := by
  set a := cov y f / varr f with ha
  set b := avg y - a * avg f with hb
  have hd := msse_decomp y (fun i => a * f i + b)
  rw [cov_affine, varr_affine, avg_affine] at hd
  have hmean : avg y - (a * avg f + b) = 0 := by rw [hb]; ring
  rw [hmean] at hd
  rw [hd, ha]
  field_simp
  ring

/-- Cauchy–Schwarz for the empirical covariance, obtained from the regression
identity: the optimal residual error is nonnegative. -/
theorem cov_sq_le (y f : ι → ℝ) : cov y f * cov y f ≤ varr y * varr f := by
  rcases eq_or_lt_of_le (varr_nonneg f) with h | h
  · -- degenerate feature: it is constant, so the covariance vanishes
    have hconst : ∀ i, f i = avg f := eq_avg_of_varr_eq_zero h.symm
    have hcov : cov y f = 0 := by
      have hfun : (fun i => y i * f i) = (fun i => avg f * y i) := by
        funext i; rw [hconst i]; ring
      simp only [cov, hfun, avg_const_mul]
      ring
    rw [hcov, ← h]
    simp
  · have h0 := msse_nonneg y (fun i => (cov y f / varr f) * f i + (avg y - (cov y f / varr f) * avg f))
    rw [msse_affine_opt h] at h0
    have : cov y f * cov y f / varr f ≤ varr y := by linarith
    rw [div_le_iff₀ h] at this
    linarith

/-- **Best attainable `R²` of a one-feature model is the squared correlation.** -/
theorem Rsq_affine_le_corr_sq {y f : ι → ℝ} (hf : 0 < varr f) (hy : 0 < varr y) (a b : ℝ) :
    Rsq y (fun i => a * f i + b) ≤ cov y f * cov y f / (varr y * varr f) := by
  have hlb := msse_affine_lower_bound (y := y) hf a b
  have hdiv : (varr y - cov y f * cov y f / varr f) / varr y
      ≤ msse y (fun i => a * f i + b) / varr y := by
    gcongr
  have hrw : (varr y - cov y f * cov y f / varr f) / varr y
      = 1 - cov y f * cov y f / (varr y * varr f) := by
    field_simp
  rw [hrw] at hdiv
  simp only [Rsq]
  linarith

theorem Rsq_affine_opt_eq_corr_sq {y f : ι → ℝ} (hf : 0 < varr f) (hy : 0 < varr y) :
    Rsq y (fun i => (cov y f / varr f) * f i + (avg y - (cov y f / varr f) * avg f))
      = cov y f * cov y f / (varr y * varr f) := by
  simp only [Rsq, msse_affine_opt hf]
  field_simp
  ring

omit [Nonempty ι] in
/-- A perfect predictor has `R² = 1`. -/
theorem Rsq_self (y : ι → ℝ) : Rsq y y = 1 := by
  have : msse y y = 0 := by simp [msse, avg]
  simp [Rsq, this]

end Logic.PhaseRoute