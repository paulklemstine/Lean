/-! # CatalogBuild.EML.AIResearch.DistillationTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 24
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.DistillationTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 24] -/
def emlStudentParams (layers dim : ℕ) : ℕ := layers * 4 * dim



theorem eml_student_compact (L d : ℕ) (hd : 4 ≤ d) :
    emlStudentParams L d ≤ teacherParams L d := by
  unfold emlStudentParams teacherParams
  have : L * 4 ≤ L * d := Nat.mul_le_mul_left L hd
  exact Nat.mul_le_mul_right d this



def softTarget (logit T : ℝ) : ℝ := Real.exp (logit / T)



theorem higher_temp_softer (z T1 T2 : ℝ) (hz : 0 ≤ z) (hT1 : 0 < T1) (hT : T1 ≤ T2) :
    softTarget z T2 ≤ softTarget z T1 := by
  unfold softTarget; apply Real.exp_le_exp.mpr
  exact div_le_div_of_nonneg_left hz hT1 hT



theorem temp_one_standard (z : ℝ) : softTarget z 1 = Real.exp z := by
  unfold softTarget; simp



def featureProjectionParams (teacherDim studentDim : ℕ) : ℕ := teacherDim * studentDim


def emlFeatureProjectionParams (studentDim : ℕ) : ℕ := 4 * studentDim



theorem eml_feature_projection_efficient (dt ds : ℕ) (hdt : 4 ≤ dt) :
    emlFeatureProjectionParams ds ≤ featureProjectionParams dt ds := by
  unfold emlFeatureProjectionParams featureProjectionParams
  exact Nat.mul_le_mul_right ds hdt



def layerDistillCost (numLayers projCostPerLayer : ℕ) : ℕ := numLayers * projCostPerLayer



theorem eml_layer_distill_cheaper (L proj_eml proj_std : ℕ) (hp : proj_eml ≤ proj_std) :
    layerDistillCost L proj_eml ≤ layerDistillCost L proj_std := by
  unfold layerDistillCost; exact Nat.mul_le_mul_left L hp



def selfDistillPerf (basePerf gain : ℝ) (rounds : ℕ) : ℝ := basePerf + gain * ↑rounds



theorem more_self_distill_better (p g : ℝ) (r1 r2 : ℕ) (hg : 0 ≤ g) (hr : r1 ≤ r2) :
    selfDistillPerf p g r1 ≤ selfDistillPerf p g r2 := by
  unfold selfDistillPerf; nlinarith [Nat.cast_le (α := ℝ).mpr hr]



def progressiveSteps (initialSteps round : ℕ) : ℕ := initialSteps / 2 ^ round



theorem progressive_fewer_steps (s r1 r2 : ℕ) (hr : r1 ≤ r2) :
    progressiveSteps s r2 ≤ progressiveSteps s r1 := by
  unfold progressiveSteps
  exact Nat.div_le_div_left (Nat.pow_le_pow_right (by omega) hr)
    (Nat.pos_of_ne_zero (by positivity))



def ensembleDistillCost (numTeachers teacherCost studentFwdCost : ℕ) : ℕ :=
  numTeachers * teacherCost + studentFwdCost


def emlEnsembleDistillCost (numTeachers teacherCost emlStudentCost : ℕ) : ℕ :=
  numTeachers * teacherCost + emlStudentCost



theorem eml_ensemble_cheaper (n tc sc_eml sc_std : ℕ) (hs : sc_eml ≤ sc_std) :
    emlEnsembleDistillCost n tc sc_eml ≤ ensembleDistillCost n tc sc_std := by
  unfold emlEnsembleDistillCost ensembleDistillCost; omega



def distillLoss (alpha hardLoss T softLoss : ℝ) : ℝ :=
  alpha * hardLoss + (1 - alpha) * T ^ 2 * softLoss



theorem distill_loss_nonneg (a h T s : ℝ) (ha0 : 0 ≤ a) (ha1 : a ≤ 1)
    (hh : 0 ≤ h) (hs : 0 ≤ s) :
    0 ≤ distillLoss a h T s := by
  unfold distillLoss
  have h1 : 0 ≤ a * h := mul_nonneg ha0 hh
  have h2 : 0 ≤ (1 - a) * T ^ 2 * s := mul_nonneg (mul_nonneg (by linarith) (sq_nonneg T)) hs
  linarith



theorem distill_pure_hard (h T s : ℝ) : distillLoss 1 h T s = h := by
  unfold distillLoss; ring



theorem distill_pure_soft (h T s : ℝ) : distillLoss 0 h T s = T ^ 2 * s := by
  unfold distillLoss; ring



theorem smaller_student_more_compression (t s1 s2 : ℕ) (hs1 : 0 < s1) (hs : s1 ≤ s2) :
    compressionRatio t s2 ≤ compressionRatio t s1 := by
  unfold compressionRatio; exact Nat.div_le_div_left hs hs1



def distillEpochs (teacherSize studentSize : ℕ) : ℕ := teacherSize / studentSize



theorem eml_distill_fewer_epochs (t s_eml s_std : ℕ) (hs : 0 < s_std) (h : s_std ≤ s_eml) :
    distillEpochs t s_eml ≤ distillEpochs t s_std := by
  unfold distillEpochs; exact Nat.div_le_div_left h hs



end
