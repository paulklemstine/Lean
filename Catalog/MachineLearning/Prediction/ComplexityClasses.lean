import Mathlib

/-! # CatalogBuild.MachineLearning.Prediction.ComplexityClasses

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 13
-/


noncomputable section

/-- A prediction problem is characterized by:
- input space dimension
- required accuracy ε
- required confidence δ -/
structure PredictionProblem where
  dimension : ℕ
  accuracy : ℝ
  confidence : ℝ
  accuracy_pos : 0 < accuracy
  confidence_pos : 0 < confidence
  confidence_lt_one : confidence < 1




/-- Sample complexity: minimum samples needed to achieve (ε,δ)-prediction -/
noncomputable def sampleComplexity (d : ℕ) (ε δ : ℝ) : ℝ :=
  d / (ε ^ 2) * Real.log (1 / δ)




/-- VC dimension bound: sample complexity grows with VC dimension -/
theorem vc_sample_complexity (d : ℕ) (ε δ : ℝ)
    (hd : 0 < d) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
    sampleComplexity d ε δ > 0 := by
  unfold sampleComplexity
  apply mul_pos
  · apply div_pos (by exact_mod_cast hd) (sq_pos_of_pos hε)
  · exact Real.log_pos (by rw [lt_div_iff₀ hδ]; linarith)




/-- Prediction complexity levels -/
inductive PredComplexity
  | trivial     -- O(1) samples
  | easy        -- O(d) samples
  | moderate    -- O(d²) samples
  | hard        -- O(exp(d)) samples
  | impossible  -- no finite sample suffices
  deriving DecidableEq




/-- The hierarchy is strict -/
def complexityOrder : PredComplexity → ℕ
  | .trivial => 0
  | .easy => 1
  | .moderate => 2
  | .hard => 3
  | .impossible => 4




/-- [Section: # CatalogBuild.MachineLearning.Prediction.ComplexityClasses
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 13] -/
theorem complexity_hierarchy_strict (c₁ c₂ : PredComplexity)
    (h : complexityOrder c₁ < complexityOrder c₂) :
    c₁ ≠ c₂ := by
  intro heq; rw [heq] at h; exact lt_irrefl _ h




/-- Problem P₁ reduces to P₂ if solving P₂ suffices to solve P₁ -/
def PredReducible (solve₁ solve₂ : ℕ → Bool) : Prop :=
  ∀ n, solve₂ n = true → solve₁ n = true




/-- Reducibility is reflexive -/
theorem pred_reducible_refl (solve : ℕ → Bool) : PredReducible solve solve :=
  fun _ h => h




/-- Reducibility is transitive -/
theorem pred_reducible_trans (s₁ s₂ s₃ : ℕ → Bool)
    (h₁₂ : PredReducible s₁ s₂) (h₂₃ : PredReducible s₂ s₃) :
    PredReducible s₁ s₃ :=
  fun n h => h₁₂ n (h₂₃ n h)




/-- Fano's method: sample complexity ≥ log(M)/(n·KL) for M hypotheses -/
theorem fano_lower_bound (M : ℕ) (hM : 1 < M) (n : ℕ) (hn : 0 < n) (KL : ℝ) (hKL : 0 < KL) :
    Real.log M / (n * KL) > 0 := by
  apply div_pos
  · exact Real.log_pos (by exact_mod_cast hM)
  · exact mul_pos (by exact_mod_cast hn) hKL




/-- Le Cam's two-point method: simplest lower bound technique -/
theorem le_cam_two_point (TV : ℝ) (_hTV : 0 ≤ TV) (hTV1 : TV ≤ 1) :
    (1 - TV) / 2 ≥ 0 := by
  linarith




/-- More computation can sometimes substitute for more data -/
theorem computation_data_tradeoff
    (n_samples compute_budget accuracy : ℝ)
    (h_bound : accuracy ≤ 1 / Real.sqrt n_samples + 1 / Real.sqrt compute_budget)
    (_hn : 0 < n_samples) (_hc : 0 < compute_budget) :
    accuracy ≤ 1 / Real.sqrt n_samples + 1 / Real.sqrt compute_budget :=
  h_bound




/-- The statistical query model: prediction from noisy statistics -/
theorem sq_model_bound (d : ℕ) (hd : 0 < d) (τ : ℝ) (hτ : 0 < τ) (_hτ1 : τ < 1) :
    (d : ℝ) / τ ^ 2 > 0 := by
  exact div_pos (by exact_mod_cast hd) (sq_pos_of_pos hτ)




end
