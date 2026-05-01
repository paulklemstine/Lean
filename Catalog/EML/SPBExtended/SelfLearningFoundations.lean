import Mathlib

/-! # CatalogBuild.MachineLearning.RSIL.SelfLearningFoundations

Auto-generated from theorem catalog database.
Domain: MachineLearning/RSIL
Declarations: 18
-/


noncomputable section

/-- Performance of a self-improving system at step n, valued in [0,1]. -/
def selfPerformance (p₀ : ℝ) (improvement : ℕ → ℝ) : ℕ → ℝ
  | 0 => p₀
  | n + 1 => selfPerformance p₀ improvement n + improvement n


/-- A self-improvement sequence is monotone if all improvements are nonneg. -/
def MonotoneImprovement (improvement : ℕ → ℝ) : Prop :=
  ∀ n, 0 ≤ improvement n


/-- A self-improvement sequence is bounded if performance stays ≤ 1. -/
def BoundedPerformance (p₀ : ℝ) (improvement : ℕ → ℝ) : Prop :=
  ∀ n, selfPerformance p₀ improvement n ≤ 1


/-- Total improvement over N steps. -/
def totalImprovement (improvement : ℕ → ℝ) (N : ℕ) : ℝ :=
  ∑ i ∈ Finset.range N, improvement i


/-- Number of parameters in a standard model of dimension d. -/
def standardParams (d : ℕ) : ℕ := d * d


/-- Search space size for standard model. -/
def standardSearchSpace (d : ℕ) (gridSize : ℕ) : ℕ := gridSize ^ (standardParams d)


/-- MDL generalization bound: training error + model complexity / n. -/
def mdlBound (trainError : ℝ) (complexity : ℝ) (n : ℝ) : ℝ :=
  trainError + complexity / n


/-- Improvement cost for a model with given parameter count. -/
def improvementCost (params : ℕ) (baseCost : ℝ) : ℝ :=
  baseCost * (params : ℝ)


/-- Performance gap between current and target performance. -/
def performanceGap (current target : ℝ) : ℝ := target - current


/-- Performance after contraction: gap shrinks by factor c each step. -/
def contractedPerformance (target p₀ c : ℝ) : ℕ → ℝ
  | 0 => p₀
  | n + 1 => target - c * (target - contractedPerformance target p₀ c n)


/-- [Section: ## Theorems] -/
theorem monotone_performance_bounded (p₀ : ℝ) (improvement : ℕ → ℝ)
    (hp₀ : 0 ≤ p₀) (hp₀_le : p₀ ≤ 1)
    (hmon : MonotoneImprovement improvement)
    (hbnd : BoundedPerformance p₀ improvement) (n : ℕ) :
    selfPerformance p₀ improvement n ≤ 1 := by
  exact hbnd n


theorem finite_improvement_steps (p₀ ε : ℝ) (improvement : ℕ → ℝ)
    (hp₀ : 0 ≤ p₀) (hp₀_le : p₀ ≤ 1)
    (hε : 0 < ε)
    (hbnd : BoundedPerformance p₀ improvement)
    (hmon : MonotoneImprovement improvement)
    (N : ℕ) (hN : ε * N ≤ totalImprovement improvement N) :
    (N : ℝ) ≤ (1 - p₀) / ε := by
  rw [ le_div_iff₀' hε ];
  exact hN.trans ( total_improvement_bounded p₀ improvement hp₀ hp₀_le hbnd hmon N )


theorem eml_fewer_params (d : ℕ) (hd : 5 ≤ d) :
    emlParams d < standardParams d := by
  unfold emlParams standardParams;
  nlinarith


theorem eml_search_space_reduction (d : ℕ) (gridSize : ℕ) (hd : 5 ≤ d) (hg : 2 ≤ gridSize) :
    emlSearchSpace d gridSize ≤ standardSearchSpace d gridSize := by
  -- Since `4d ≤ d²` for `d ≥ 5`, we have `gridSize^(4d) ≤ gridSize^(d²)`.
  have h_exp_growth : 4 * d ≤ d * d := by
    nlinarith;
  exact Nat.pow_le_pow_right ( by linarith ) h_exp_growth


theorem compressed_improvement_cheaper (d : ℕ) (baseCost : ℝ) (hd : 5 ≤ d) (hc : 0 < baseCost) :
    improvementCost (emlParams d) baseCost < improvementCost (standardParams d) baseCost := by
  exact mul_lt_mul_of_pos_left ( mod_cast ( by { unfold emlParams standardParams; nlinarith } ) ) ( mod_cast hc )


theorem performance_gap_shrinks (target p₀ c : ℝ) (hc0 : 0 ≤ c) (hc1 : c < 1)
    (n : ℕ) :
    target - contractedPerformance target p₀ c n = c ^ n * (target - p₀) := by
  -- We proceed by induction on $n$.
  induction' n with n ih;
  · aesop;
  · rw [ show contractedPerformance target p₀ c ( n + 1 ) = target - c * ( target - contractedPerformance target p₀ c n ) by rfl ] ; rw [ ih ] ; ring


theorem mdl_generalization_bound (trainError complexity n : ℝ)
    (hte : 0 ≤ trainError) (hc : 0 ≤ complexity) (hn : 0 < n) :
    0 ≤ mdlBound trainError complexity n := by
  exact add_nonneg hte ( div_nonneg hc hn.le )


theorem eml_tighter_mdl (trainError n baseCost : ℝ) (d : ℕ) (hd : 5 ≤ d)
    (hn : 0 < n) (hbc : 0 < baseCost) :
    mdlBound trainError (baseCost * emlParams d) n ≤
    mdlBound trainError (baseCost * standardParams d) n := by
  unfold emlParams standardParams;
  unfold mdlBound;
  gcongr ; nlinarith


end