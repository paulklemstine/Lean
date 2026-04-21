/-! # CatalogBuild.MachineLearning.Prediction.PredictionGeometry

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 26
-/

import Mathlib

noncomputable section

/-- A prediction oracle on a type α is an idempotent endomorphism.
Asking the oracle twice yields the same answer: the oracle is "settled." -/
structure PredictionOracle (α : Type*) where
  predict : α → α
  idempotent : ∀ x, predict (predict x) = predict x




/-- The fixed points of an oracle — the "settled predictions" -/
def PredictionOracle.fixedPoints {α : Type*} (O : PredictionOracle α) : Set α :=
  {x | O.predict x = x}




/-- [Section: # CatalogBuild.MachineLearning.Prediction.PredictionGeometry
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 26] -/
theorem PredictionOracle.predict_mem_fixedPoints {α : Type*} (O : PredictionOracle α)
    (x : α) : O.predict x ∈ O.fixedPoints := by
  exact O.idempotent x




/-- [Section: # CatalogBuild.MachineLearning.Prediction.PredictionGeometry
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 26] -/
def PredictionOracle.identity (α : Type*) : PredictionOracle α where
  predict := id
  idempotent := by
    exact fun x => rfl




theorem PredictionOracle.identity_fixedPoints (α : Type*) :
    (PredictionOracle.identity α).fixedPoints = Set.univ := by
  exact Set.eq_univ_iff_forall.mpr fun x => rfl




/-- The prediction horizon: after H steps, prediction error exceeds threshold.
This captures the "butterfly effect" — chaos limits prediction depth. -/
structure PredictionHorizon where
  lyapunov : ℝ
  epsilon_0 : ℝ
  delta : ℝ
  lyapunov_pos : 0 < lyapunov
  epsilon_pos : 0 < epsilon_0
  delta_pos : 0 < delta
  delta_gt_eps : epsilon_0 < delta




/-- The prediction horizon formula: H = ln(δ/ε₀) / λ -/
noncomputable def PredictionHorizon.horizon (h : PredictionHorizon) : ℝ :=
  Real.log (h.delta / h.epsilon_0) / h.lyapunov




theorem PredictionHorizon.horizon_pos (h : PredictionHorizon) : 0 < h.horizon := by
  exact div_pos ( Real.log_pos <| by rw [ lt_div_iff₀ h.epsilon_pos ] ; linarith [ h.delta_gt_eps ] ) h.lyapunov_pos




theorem PredictionHorizon.doubling_precision_gain (h : PredictionHorizon) :
    let h' : PredictionHorizon := {
      lyapunov := h.lyapunov
      epsilon_0 := h.epsilon_0 / 2
      delta := h.delta
      lyapunov_pos := h.lyapunov_pos
      epsilon_pos := by linarith [h.epsilon_pos]
      delta_pos := h.delta_pos
      delta_gt_eps := by linarith [h.delta_gt_eps, h.epsilon_pos]
    }
    h'.horizon = h.horizon + Real.log 2 / h.lyapunov := by
  unfold PredictionHorizon.horizon;
  field_simp;
  rw [ ← Real.log_mul ( by exact div_ne_zero ( by linarith [ h.delta_pos, h.epsilon_pos ] ) ( by linarith [ h.delta_pos, h.epsilon_pos ] ) ) ( by linarith [ h.delta_pos, h.epsilon_pos ] ), mul_div_right_comm ]




theorem horizon_decreases_with_chaos (delta eps0 : ℝ) (hdelta : 0 < delta) (heps : 0 < eps0)
    (hlt : eps0 < delta)
    (lam1 lam2 : ℝ) (hlam1 : 0 < lam1) (hlam2 : 0 < lam2) (hlam : lam1 < lam2) :
    let h2 : PredictionHorizon := ⟨lam2, eps0, delta, hlam2, heps, hdelta, hlt⟩
    let h1 : PredictionHorizon := ⟨lam1, eps0, delta, hlam1, heps, hdelta, hlt⟩
    h2.horizon < h1.horizon := by
  exact div_lt_div_of_pos_left ( Real.log_pos <| by rw [ lt_div_iff₀ heps ] ; linarith ) ( by positivity ) hlam




theorem max_entropy_uniform (n : ℕ) (hn : 0 < n) (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : ∑ i, p i = 1) :
    shannonEntropy p ≤ Real.log n := by
  by_cases hn2 : n = 0 <;> simp_all +decide [ shannonEntropy ];
  have h_jensen : (∑ i : Fin n, (1 / n : ℝ) * (p i * Real.log (p i))) ≥ ((∑ i : Fin n, (1 / n : ℝ) * p i)) * Real.log ((∑ i : Fin n, (1 / n : ℝ) * p i)) := by
    have h_jensen : ConvexOn ℝ (Set.Ici 0) (fun x => x * Real.log x) := by
      exact ( Real.convexOn_mul_log );
    apply ConvexOn.map_sum_le h_jensen;
    · finiteness;
    · norm_num [ hn2 ];
    · aesop;
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  nlinarith [ inv_pos.mpr ( by positivity : 0 < ( n : ℝ ) ) ]




/-- Predictability: how far below maximum entropy a source is. -/
noncomputable def predictability {n : ℕ} (p : Fin n → ℝ) (hn : 0 < n) : ℝ :=
  Real.log n - shannonEntropy p




theorem predictability_nonneg {n : ℕ} (p : Fin n → ℝ) (hn : 0 < n)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : ∑ i, p i = 1) :
    0 ≤ predictability p hn := by
  exact sub_nonneg_of_le ( max_entropy_uniform n hn p hp_nonneg hp_sum )




/-- A contractive oracle shrinks prediction error at each step. -/
structure ContractiveOracle (α : Type*) [PseudoMetricSpace α] extends PredictionOracle α where
  contraction_rate : ℝ
  rate_bound : contraction_rate ∈ Set.Ico 0 1
  contractive : ∀ x y, dist (predict x) (predict y) ≤ contraction_rate * dist x y




theorem contractive_oracle_error_decay {α : Type*} [PseudoMetricSpace α]
    (O : ContractiveOracle α) (x y : α) (n : ℕ) :
    dist (O.predict^[n] x) (O.predict^[n] y) ≤ O.contraction_rate ^ n * dist x y := by
  induction' n with n ih generalizing x y <;> simp_all +decide [ Function.iterate_succ_apply', pow_succ' ];
  simpa only [ mul_assoc ] using le_trans ( O.contractive _ _ ) ( mul_le_mul_of_nonneg_left ( ih _ _ ) ( O.rate_bound.1 ) )




theorem contractive_oracle_unique_fixpoint {α : Type*} [MetricSpace α]
    (O : ContractiveOracle α)
    (hc : O.contraction_rate < 1)
    (x y : α) (hx : x ∈ O.fixedPoints) (hy : y ∈ O.fixedPoints) : x = y := by
  -- By the properties of the contraction mapping, we have dist x y ≤ contraction_rate * dist x y.
  have h_dist : dist x y ≤ O.contraction_rate * dist x y := by
    -- By the properties of the contraction mapping, we have dist x y ≤ contraction_rate * dist x y. This follows directly from the definition of the contraction rate and the fact that x and y are fixed points.
    have h_dist : dist (O.predict x) (O.predict y) = dist x y := by
      rw [ hx, hy ];
    exact h_dist ▸ O.contractive x y;
  contrapose! h_dist; aesop;




/-- Two prediction oracles commute if their composition order doesn't matter -/
def PredictionOracle.commute {α : Type*} (O₁ O₂ : PredictionOracle α) : Prop :=
  ∀ x, O₁.predict (O₂.predict x) = O₂.predict (O₁.predict x)




def PredictionOracle.compose {α : Type*} (O₁ O₂ : PredictionOracle α)
    (hc : O₁.commute O₂) : PredictionOracle α where
  predict := O₁.predict ∘ O₂.predict
  idempotent := by
    simp +zetaDelta at *;
    intro x
    rw [hc] -- Use the commutativity of O₁ and O₂;
    rw [ O₁.idempotent, hc ];
    exact O₂.idempotent _




theorem PredictionOracle.compose_fixedPoints {α : Type*} (O₁ O₂ : PredictionOracle α)
    (hc : O₁.commute O₂) :
    (O₁.compose O₂ hc).fixedPoints = O₁.fixedPoints ∩ O₂.fixedPoints := by
  -- To prove equality of sets, we show each set is a subset of the other.
  apply Set.ext
  intro x
  simp [PredictionOracle.fixedPoints, PredictionOracle.compose];
  constructor;
  · intro hx
    have h1 : O₂.predict (O₁.predict (O₂.predict x)) = O₂.predict x := by
      rw [ hx ]
    have h2 : O₁.predict (O₂.predict (O₂.predict x)) = O₁.predict (O₂.predict x) := by
      rw [ O₂.idempotent ]
    have h3 : O₂.predict (O₂.predict x) = O₂.predict x := by
      exact O₂.idempotent _
    have h4 : O₁.predict (O₂.predict x) = x := by
      exact hx
    have h5 : O₂.predict x = x := by
      grind +locals
    exact ⟨by
    simpa [ h5 ] using h4, by
      exact h5⟩;
  · aesop




/-- Error probability after majority vote of (2k+1) queries -/
noncomputable def majorityErrorBound (p : ℝ) (k : ℕ) : ℝ :=
  (4 * p * (1 - p)) ^ k




theorem amplification_factor_lt_one (p : ℝ) (hp : 1/2 < p) (hp1 : p ≤ 1) :
    4 * p * (1 - p) < 1 := by
  nlinarith [ sq_nonneg ( p - 1 / 2 ) ]




theorem noisy_oracle_convergence (p : ℝ) (hp : 1/2 < p) (hp1 : p ≤ 1)
    (ε : ℝ) (hε : 0 < ε) : ∃ k : ℕ, majorityErrorBound p k < ε := by
  exact ( exists_pow_lt_of_lt_one hε ( by linarith [ show 4 * p * ( 1 - p ) < 1 by nlinarith [ mul_self_nonneg ( p - 1 / 2 ) ] ] ) )




def PredictionOracle.constant {α : Type*} (c : α) : PredictionOracle α where
  predict := fun _ => c
  idempotent := by
    exact fun _ => rfl




theorem PredictionOracle.restrict_fixedPoints_id {α : Type*}
    (O : PredictionOracle α) (x : α) (hx : x ∈ O.fixedPoints) :
    O.predict x = x := by
  exact?




theorem cramer_rao_informal (I_theta : ℝ) (hI : 0 < I_theta)
    (variance : ℝ) (hv : 0 < variance)
    (is_efficient : variance = 1 / I_theta) :
    variance * I_theta = 1 := by
  grind +qlia




theorem joint_horizon_min (h₁ h₂ : PredictionHorizon)
    (h_same_lyap : h₁.lyapunov = h₂.lyapunov) :
    min h₁.horizon h₂.horizon ≤ max h₁.horizon h₂.horizon := by
  exact min_le_max




end
