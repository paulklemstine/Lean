import Mathlib

/-! # Self-Learning Foundations

The mathematical foundations of Recursive Self-Improving Learners (RSIL).
Establishes monotone performance bounds, telescoping improvement sums,
finite termination of ε-improvement, EML compression benefits, and
convergence guarantees via contraction on performance gaps.
-/

noncomputable section

open Real BigOperators

/-! ## Core Definitions -/

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

/-- Number of parameters in an EML model of dimension d (4 per neuron). -/
def emlParams (d : ℕ) : ℕ := 4 * d

/-- Search space size for standard model. -/
def standardSearchSpace (d : ℕ) (gridSize : ℕ) : ℕ := gridSize ^ (standardParams d)

/-- Search space size for EML model. -/
def emlSearchSpace (d : ℕ) (gridSize : ℕ) : ℕ := gridSize ^ (emlParams d)

/-- Shannon entropy of a two-outcome distribution with probability p. -/
def shannonEntropy (p : ℝ) : ℝ :=
  if p = 0 ∨ p = 1 then 0
  else -(p * Real.log p + (1 - p) * Real.log (1 - p))

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

/-! ## Theorems -/

/-
Self-improvement performance is bounded by 1.
-/
theorem monotone_performance_bounded (p₀ : ℝ) (improvement : ℕ → ℝ)
    (hp₀ : 0 ≤ p₀) (hp₀_le : p₀ ≤ 1)
    (hmon : MonotoneImprovement improvement)
    (hbnd : BoundedPerformance p₀ improvement) (n : ℕ) :
    selfPerformance p₀ improvement n ≤ 1 := by
  exact hbnd n

/-
Telescoping sum: total improvement ≤ 1 − initial performance.
-/
theorem total_improvement_bounded (p₀ : ℝ) (improvement : ℕ → ℝ)
    (hp₀ : 0 ≤ p₀) (hp₀_le : p₀ ≤ 1)
    (hbnd : BoundedPerformance p₀ improvement)
    (hmon : MonotoneImprovement improvement) (N : ℕ) :
    totalImprovement improvement N ≤ 1 - p₀ := by
  -- By definition of $selfPerformance$, we have $selfPerformance p₀ improvement N = p₀ + ∑ i ∈ Finset.range N, improvement i$.
  have h_selfPerformance : ∀ N, selfPerformance p₀ improvement N = p₀ + ∑ i ∈ Finset.range N, improvement i := by
    intro N
    induction' N with N ih;
    · aesop;
    · rw [ Finset.sum_range_succ, ← add_assoc, ← ih, show selfPerformance p₀ improvement ( N + 1 ) = selfPerformance p₀ improvement N + improvement N from rfl ];
  linarith! [ hbnd N, h_selfPerformance N ]

/-
ε-improvement terminates: if each step gives ≥ ε, can't do more than ⌈(1-p₀)/ε⌉ steps.
-/
theorem finite_improvement_steps (p₀ ε : ℝ) (improvement : ℕ → ℝ)
    (hp₀ : 0 ≤ p₀) (hp₀_le : p₀ ≤ 1)
    (hε : 0 < ε)
    (hbnd : BoundedPerformance p₀ improvement)
    (hmon : MonotoneImprovement improvement)
    (N : ℕ) (hN : ε * N ≤ totalImprovement improvement N) :
    (N : ℝ) ≤ (1 - p₀) / ε := by
  rw [ le_div_iff₀' hε ];
  exact hN.trans ( total_improvement_bounded p₀ improvement hp₀ hp₀_le hbnd hmon N )

/-
EML uses fewer parameters for d ≥ 5.
-/
theorem eml_fewer_params (d : ℕ) (hd : 5 ≤ d) :
    emlParams d < standardParams d := by
  unfold emlParams standardParams;
  nlinarith

/-
EML reduces search space multiplicatively.
-/
theorem eml_search_space_reduction (d : ℕ) (gridSize : ℕ) (hd : 5 ≤ d) (hg : 2 ≤ gridSize) :
    emlSearchSpace d gridSize ≤ standardSearchSpace d gridSize := by
  -- Since `4d ≤ d²` for `d ≥ 5`, we have `gridSize^(4d) ≤ gridSize^(d²)`.
  have h_exp_growth : 4 * d ≤ d * d := by
    nlinarith;
  exact Nat.pow_le_pow_right ( by linarith ) h_exp_growth

/-
Compressed models improve faster (lower cost).
-/
theorem compressed_improvement_cheaper (d : ℕ) (baseCost : ℝ) (hd : 5 ≤ d) (hc : 0 < baseCost) :
    improvementCost (emlParams d) baseCost < improvementCost (standardParams d) baseCost := by
  exact mul_lt_mul_of_pos_left ( mod_cast ( by { unfold emlParams standardParams; nlinarith } ) ) ( mod_cast hc )

/-
Performance contraction gives exponential convergence of the gap.
-/
theorem performance_gap_shrinks (target p₀ c : ℝ) (hc0 : 0 ≤ c) (hc1 : c < 1)
    (n : ℕ) :
    target - contractedPerformance target p₀ c n = c ^ n * (target - p₀) := by
  -- We proceed by induction on $n$.
  induction' n with n ih;
  · aesop;
  · rw [ show contractedPerformance target p₀ c ( n + 1 ) = target - c * ( target - contractedPerformance target p₀ c n ) by rfl ] ; rw [ ih ] ; ring

/-
Shannon entropy is nonneg for p in (0,1).
-/
theorem entropy_nonneg (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    0 ≤ shannonEntropy p := by
  unfold shannonEntropy;
  split_ifs <;> norm_num;
  nlinarith [ Real.log_le_sub_one_of_pos hp0, Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 - p ) ]

/-
MDL generalization bound is nonneg when components are nonneg.
-/
theorem mdl_generalization_bound (trainError complexity n : ℝ)
    (hte : 0 ≤ trainError) (hc : 0 ≤ complexity) (hn : 0 < n) :
    0 ≤ mdlBound trainError complexity n := by
  exact add_nonneg hte ( div_nonneg hc hn.le )

/-
EML yields tighter MDL bounds (smaller complexity term).
-/
theorem eml_tighter_mdl (trainError n baseCost : ℝ) (d : ℕ) (hd : 5 ≤ d)
    (hn : 0 < n) (hbc : 0 < baseCost) :
    mdlBound trainError (baseCost * emlParams d) n ≤
    mdlBound trainError (baseCost * standardParams d) n := by
  unfold emlParams standardParams;
  unfold mdlBound;
  gcongr ; nlinarith

end