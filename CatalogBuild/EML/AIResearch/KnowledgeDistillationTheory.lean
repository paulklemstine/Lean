/-! # CatalogBuild.EML.AIResearch.KnowledgeDistillationTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 15
-/

import Mathlib

noncomputable section

theorem larger_teacher_higher_ratio (t1 t2 s : ℕ) (ht : t1 ≤ t2) :
    compressionRatio t1 s ≤ compressionRatio t2 s := by
  unfold compressionRatio; exact Nat.div_le_div_right ht


/-- [Section: ## §2. Temperature Scaling] -/
def scaledLogit (logit temperature : ℝ) : ℝ := logit / temperature


theorem higher_temp_smaller_logit (z T1 T2 : ℝ) (hz : 0 < z)
    (hT1 : 0 < T1) (hT : T1 ≤ T2) :
    scaledLogit z T2 ≤ scaledLogit z T1 := by
  unfold scaledLogit
  exact div_le_div_of_nonneg_left (le_of_lt hz) (by linarith) hT


theorem unit_temp_identity (z : ℝ) : scaledLogit z 1 = z := by
  unfold scaledLogit; ring


/-- [Section: ## §3. Feature Distillation] -/
def stdFeatureMatchParams (d_teacher d_student : ℕ) : ℕ := d_teacher * d_student

def emlFeatureMatchParams (d_student : ℕ) : ℕ := 4 * d_student


theorem eml_feature_match_compact (dt ds : ℕ) (ht : 4 ≤ dt) :
    emlFeatureMatchParams ds ≤ stdFeatureMatchParams dt ds := by
  unfold emlFeatureMatchParams stdFeatureMatchParams
  exact Nat.mul_le_mul_right ds ht


/-- [Section: ## §4. Multi-Teacher Distillation] -/
def ensembleCost (numTeachers teacherCost : ℕ) : ℕ := numTeachers * teacherCost


theorem more_teachers_costlier (n1 n2 tc : ℕ) (hn : n1 ≤ n2) :
    ensembleCost n1 tc ≤ ensembleCost n2 tc := by
  unfold ensembleCost; exact Nat.mul_le_mul_right tc hn


def distillFromEnsembleCost (numTeachers teacherCost studentCost : ℕ) : ℕ :=
  numTeachers * teacherCost + studentCost


theorem eml_ensemble_distill_cheaper (nt tc sc_eml sc_std : ℕ) (hs : sc_eml ≤ sc_std) :
    distillFromEnsembleCost nt tc sc_eml ≤ distillFromEnsembleCost nt tc sc_std := by
  unfold distillFromEnsembleCost; omega


/-- [Section: ## §5. Progressive Distillation] -/
def progressiveDistillCost (numStages avgCostPerStage : ℕ) : ℕ :=
  numStages * avgCostPerStage


theorem more_stages_costlier (s1 s2 c : ℕ) (hs : s1 ≤ s2) :
    progressiveDistillCost s1 c ≤ progressiveDistillCost s2 c := by
  unfold progressiveDistillCost; exact Nat.mul_le_mul_right c hs


/-- [Section: ## §6. Total Pipeline Cost] -/
def totalDistillPipelineCost (teacherTrainCost distillCost fineTuneCost : ℕ) : ℕ :=
  teacherTrainCost + distillCost + fineTuneCost


theorem eml_pipeline_cheaper (ttc dc ft_eml ft_std : ℕ) (hft : ft_eml ≤ ft_std) :
    totalDistillPipelineCost ttc dc ft_eml ≤ totalDistillPipelineCost ttc dc ft_std := by
  unfold totalDistillPipelineCost; omega


end
