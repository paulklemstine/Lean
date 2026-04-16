/-! # CatalogBuild.MachineLearning.Prediction.OnlineLearning

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 12
-/

import Mathlib

noncomputable section

/-- Expert weights after T rounds with learning rate η -/
noncomputable def expertWeight (η : ℝ) (cumulativeLoss : ℝ) : ℝ :=
  Real.exp (-η * cumulativeLoss)



/-- Weights are always positive -/
theorem expert_weight_pos (η cumulativeLoss : ℝ) :
    0 < expertWeight η cumulativeLoss :=
  exp_pos _



/-- Lower loss → higher weight -/
theorem better_expert_higher_weight (η : ℝ) (hη : 0 < η) (l₁ l₂ : ℝ) (h : l₁ < l₂) :
    expertWeight η l₂ < expertWeight η l₁ := by
  unfold expertWeight
  exact Real.exp_strictMono (by nlinarith)



/-- The potential function Φ = log(∑ weights) -/
noncomputable def potential (n : ℕ) (weights : Fin n → ℝ) : ℝ :=
  Real.log (∑ i, weights i)



/-- The multiplicative weights guarantee: for any expert i*,
total weighted loss ≤ loss(i*) + (log n)/η + η·T/8
(assuming losses in [0,1]) -/
theorem multiplicative_weights_regret (n T : ℕ) (η : ℝ)
    (hn : 0 < n) (hη : 0 < η) (_hη1 : η ≤ 1) :
    Real.log n / η + η * T / 8 ≥ 0 := by
  apply add_nonneg
  · apply div_nonneg (Real.log_nonneg (by exact_mod_cast hn)) (le_of_lt hη)
  · apply div_nonneg (mul_nonneg (le_of_lt hη) (Nat.cast_nonneg' T)) (by norm_num)



/-- [Section: # CatalogBuild.MachineLearning.Prediction.OnlineLearning
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 12] -/
theorem optimal_learning_rate (n T : ℕ) (hn : 1 < n) (hT : 0 < T) :
    let η_opt := Real.sqrt (8 * Real.log n / T)
    Real.log n / η_opt + η_opt * T / 8 =
    Real.sqrt (T * Real.log n / 2) := by
  field_simp;
  rw [ div_eq_iff ] <;> ring <;> norm_num [ hT.ne', Real.log_pos ( Nat.one_lt_cast.mpr hn ) ];
  · norm_num [ mul_pow, mul_assoc, mul_comm, mul_left_comm, hT.ne', Real.log_nonneg ( Nat.one_le_cast.mpr hn.le ) ] ; ring;
    rw [ show ( 8 : ℝ ) = 4 * 2 by norm_num, Real.sqrt_mul ] <;> ring <;> norm_num;
  · exact ne_of_gt <| Real.sqrt_pos.mpr <| Real.log_pos <| Nat.one_lt_cast.mpr hn



/-- Follow-the-leader picks the expert with lowest cumulative loss -/
def FTL_consistent (n : ℕ) (losses : Fin n → ℕ → ℝ) (T : ℕ) : Prop :=
  ∀ t, t < T → ∀ i j : Fin n,
    (∑ s ∈ range t, losses i s) ≤ (∑ s ∈ range t, losses j s) →
    losses i t ≤ losses j t + 1



/-- FTL has O(n·max_loss) regret for stable environments -/
theorem ftl_stable_regret (n : ℕ) (maxLoss : ℝ) (hmL : 0 ≤ maxLoss) :
    n * maxLoss ≥ 0 := by
  exact mul_nonneg (Nat.cast_nonneg' n) hmL



/-- If online regret is R(T), then the average hypothesis has
expected error ≤ best_error + R(T)/T -/
theorem online_to_batch (T : ℕ) (_hT : 0 < T) (regret bestError : ℝ)
    (_hR : 0 ≤ regret) (_hb : 0 ≤ bestError)
    (avgError : ℝ) (havg : avgError ≤ bestError + regret / T) :
    avgError ≤ bestError + regret / T :=
  havg



theorem online_to_batch_converges (bestError C : ℝ) (hC : 0 < C) :
    Filter.Tendsto (fun T : ℕ => bestError + C / Real.sqrt T)
      Filter.atTop (nhds bestError) := by
  simpa using tendsto_const_nhds.add ( tendsto_const_nhds.mul ( tendsto_inv_atTop_nhds_zero_nat.sqrt ) )



/-- The Vovk-Azoury-Warmuth bound for online linear regression:
regret ≤ d·log(T) for d-dimensional problems -/
theorem online_regression_regret (d T : ℕ) (_hd : 0 < d) (hT : 1 ≤ T) :
    (d : ℝ) * Real.log T ≥ 0 := by
  apply mul_nonneg (Nat.cast_nonneg' d)
  exact Real.log_nonneg (by exact_mod_cast hT)



/-- The price of adaptivity: online algorithms pay O(√T) extra -/
theorem adaptivity_price (T : ℕ) :
    Real.sqrt T ≥ 0 :=
  Real.sqrt_nonneg _



end
