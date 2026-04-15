/-! # CatalogBuild.Computation.Oracles.OracleNetworks

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 14
-/

import Mathlib

noncomputable section

/-- Contraction condition for oracle update. -/
def IsContracting (n : ℕ) (f : (Fin n → ℝ) → (Fin n → ℝ)) (c : ℝ) : Prop :=
  0 ≤ c ∧ c < 1 ∧ ∀ x y, ‖f x - f y‖ ≤ c * ‖x - y‖


/-- Iterated oracle update. -/
def iterateOracle {n : ℕ} (f : (Fin n → ℝ) → (Fin n → ℝ)) (x₀ : Fin n → ℝ) : ℕ → Fin n → ℝ
  | 0 => x₀
  | k + 1 => f (iterateOracle f x₀ k)


/-- [Section: ## §1: Oracle Iteration and Convergence] -/
theorem contracting_oracle_cauchy {n : ℕ} (f : (Fin n → ℝ) → (Fin n → ℝ))
    (c : ℝ) (hc : IsContracting n f c) (x₀ : Fin n → ℝ) :
    ∀ k : ℕ, ‖iterateOracle f x₀ (k + 1) - iterateOracle f x₀ k‖ ≤
      c ^ k * ‖f x₀ - x₀‖ := by
        intro k;
        induction' k with k ih;
        · aesop;
        · simpa only [ pow_succ', mul_assoc ] using le_trans ( hc.2.2 _ _ ) ( mul_le_mul_of_nonneg_left ih hc.1 )


/-- A council of k oracles, each providing a real-valued estimate. -/
structure OracleCouncil (k : ℕ) where
  estimates : Fin k → ℝ


/-- The council's aggregate answer (mean). -/
def OracleCouncil.mean {k : ℕ} (hk : 0 < k) (council : OracleCouncil k) : ℝ :=
  (∑ i, council.estimates i) / k


/-- **Variance reduction**: The variance of the mean is at most the individual variance. -/
theorem variance_reduction (k : ℕ) (hk : 0 < k) (sigma_sq : ℝ) (hs : 0 ≤ sigma_sq) :
    sigma_sq / k ≤ sigma_sq := by
  exact div_le_self hs (by exact_mod_cast hk)


/-- [Section: ## §2: Oracle Council (Ensemble) Theory] -/
theorem diminishing_returns (k : ℕ) (hk : 0 < k) (sigma_sq : ℝ) (hs : 0 < sigma_sq) :
    sigma_sq / k - sigma_sq / (k + 1) = sigma_sq / (k * (k + 1)) := by
      -- Combine the fractions over a common denominator.
      field_simp
      ring


/-- Error after k rounds of self-improvement with factor r reduction. -/
def selfImprovementError (e0 r : ℝ) (k : ℕ) : ℝ := e0 * r ^ k


/-- Self-improvement error is non-negative. -/
theorem selfImprovementError_nonneg (e0 r : ℝ) (he : 0 ≤ e0) (hr : 0 ≤ r) (k : ℕ) :
    0 ≤ selfImprovementError e0 r k :=
  mul_nonneg he (pow_nonneg hr k)


/-- [Section: ## §3: Information-Theoretic Self-Improvement Bounds] -/
theorem selfImprovementError_decreasing (e0 r : ℝ) (he : 0 < e0) (hr : 0 < r) (hr1 : r < 1) :
    StrictAnti (fun k => selfImprovementError e0 r k) := by
      exact strictAnti_nat_of_succ_lt fun k => mul_lt_mul_of_pos_left ( pow_lt_pow_right_of_lt_one₀ hr hr1 k.lt_succ_self ) he


theorem selfImprovementError_tendsto_zero (e0 r : ℝ) (he : 0 ≤ e0) (hr : 0 ≤ r) (hr1 : r < 1) :
    Tendsto (fun k => selfImprovementError e0 r k) atTop (nhds 0) := by
      simpa [ selfImprovementError ] using tendsto_const_nhds.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one hr hr1 )


/-- Total cost function: accuracy_loss + coordination_cost. -/
def councilCost (sigma c : ℝ) (k : ℕ) : ℝ :=
  sigma / Real.sqrt k + c * k


/-- [Section: ## §4: Optimal Council Composition] -/
theorem council_cost_grows (sigma c : ℝ) (hs : 0 < sigma) (hc : 0 < c) :
    Tendsto (fun k => councilCost sigma c k) atTop atTop := by
      exact Filter.tendsto_atTop_mono ( fun _ => le_add_of_nonneg_left <| by positivity ) <| tendsto_natCast_atTop_atTop.const_mul_atTop hc


/-- [Section: ## §5: Oracle Phase Transition] -/
theorem expected_degree_threshold (n : ℕ) (hn : 2 ≤ n) (p : ℝ) (hp : 0 ≤ p) (hp1 : p ≤ 1) :
    (n - 1 : ℝ) * p ≥ 1 ↔ p ≥ 1 / (n - 1 : ℝ) := by
      exact ⟨ fun h => by rw [ ge_iff_le, div_le_iff₀ ] <;> linarith [ show ( n : ℝ ) ≥ 2 by norm_cast ], fun h => by rw [ ge_iff_le, div_le_iff₀ ] at h <;> linarith [ show ( n : ℝ ) ≥ 2 by norm_cast ] ⟩


end
