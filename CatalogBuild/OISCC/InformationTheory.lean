/-! # CatalogBuild.OISCC.InformationTheory

Auto-generated from theorem catalog database.
Domain: OISCC
Declarations: 15
-/

import Mathlib

noncomputable section

def EML_info (a b : ℝ) : ℝ := Real.exp a - Real.log b


/-- ∂EML/∂a = exp(a). -/
theorem channel_gain (a b : ℝ) :
    HasDerivAt (fun x => EML_info x b) (Real.exp a) a := by
  have h1 : HasDerivAt (fun x => Real.exp x) (Real.exp a) a := Real.hasDerivAt_exp a
  have h2 : HasDerivAt (fun _ => Real.log b) 0 a := hasDerivAt_const a (Real.log b)
  convert h1.sub h2 using 1; ring


/-- ∂EML/∂b = -1/b for b > 0. -/
theorem noise_sensitivity (a b : ℝ) (hb : 0 < b) :
    HasDerivAt (fun y => EML_info a y) (-(b⁻¹)) b := by
  have h1 : HasDerivAt (fun _ => Real.exp a) 0 b := hasDerivAt_const b (Real.exp a)
  have h2 : HasDerivAt Real.log (b⁻¹) b := Real.hasDerivAt_log hb.ne'
  convert h1.sub h2 using 1; ring


def EML_SNR (a b : ℝ) : ℝ := Real.exp a * b


theorem EML_SNR_pos (a b : ℝ) (hb : 0 < b) : EML_SNR a b > 0 :=
  mul_pos (Real.exp_pos a) hb


theorem EML_SNR_mono_a (b : ℝ) (hb : 0 < b) : StrictMono (fun a => EML_SNR a b) :=
  fun _ _ h => by simp [EML_SNR]; exact mul_lt_mul_of_pos_right (Real.exp_lt_exp.mpr h) hb


theorem EML_SNR_critical (a : ℝ) : EML_SNR a (Real.exp (-a)) = 1 := by
  simp [EML_SNR, ← Real.exp_add]


theorem EML_amplification_precise (a b δ : ℝ) :
    EML_info (a + δ) b - EML_info a b = Real.exp a * (Real.exp δ - 1) := by
  simp [EML_info, Real.exp_add]; ring


theorem EML_amplification_lower (a b δ : ℝ) (ha : 0 ≤ a) (hδ : 0 < δ) :
    EML_info (a + δ) b - EML_info a b ≥ δ := by
  rw [EML_amplification_precise]
  nlinarith [Real.one_le_exp ha, Real.add_one_le_exp δ]


theorem EML_amplification_exponential (a b δ : ℝ) (_hδ : 0 < δ) :
    EML_info (a + δ) b - EML_info a b ≥ Real.exp a * δ := by
  rw [EML_amplification_precise]
  nlinarith [Real.exp_pos a, Real.add_one_le_exp δ]


def EML_MI (x y : ℝ) : ℝ :=
  EML_info x y + EML_info y x - EML_info x x - EML_info y y


/-- EML mutual information is always zero — separability. -/
theorem EML_MI_zero (x y : ℝ) : EML_MI x y = 0 := by
  simp [EML_MI, EML_info]; ring


def fisher_info_a (a : ℝ) : ℝ := (Real.exp a) ^ 2


theorem fisher_info_pos (a : ℝ) : fisher_info_a a > 0 := by
  simp [fisher_info_a]; positivity


theorem fisher_info_grows (a : ℝ) (ha : 0 ≤ a) :
    fisher_info_a a ≥ (1 + a) ^ 2 := by
  simp [fisher_info_a]
  exact sq_le_sq' (by nlinarith [Real.add_one_le_exp a]) (by linarith [Real.add_one_le_exp a])


end
