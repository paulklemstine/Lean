/-
  # Prediction Science: Convergence Theorems

  Core convergence results for prediction sequences:
  1. Exponential convergence of iterative prediction
  2. Weighted majority convergence (the Multiplicative Weights theorem)
  3. Calibration convergence
  4. The Blackwell-Dubins merging of opinions
-/

import Mathlib

open Real MeasureTheory Filter Topology Set Finset BigOperators

noncomputable section

/-! ## §1. Exponential Convergence of Iterative Prediction -/

/-
PROBLEM
If each prediction step reduces error by factor c < 1,
    then error after n steps is at most c^n * initial error.

PROVIDED SOLUTION
By induction on n. Base: error 0 ≤ c^0 * error 0 = error 0. Step: error (n+1) ≤ c * error n ≤ c * (c^n * error 0) = c^(n+1) * error 0. Use mul_le_mul_of_nonneg_left with hc0.
-/
theorem iterative_prediction_convergence
    (error : ℕ → ℝ) (c : ℝ) (hc0 : 0 ≤ c) (_hc1 : c < 1)
    (_h0 : 0 ≤ error 0)
    (hstep : ∀ n, error (n + 1) ≤ c * error n)
    (herr : ∀ n, 0 ≤ error n) :
    ∀ n, error n ≤ c ^ n * error 0 := by
  exact fun n => Nat.recOn n ( by norm_num ) fun n ih => by rw [ pow_succ', mul_assoc ] ; exact le_trans ( hstep _ ) ( mul_le_mul_of_nonneg_left ih hc0 ) ;

/-
PROBLEM
Iterative prediction error vanishes

PROVIDED SOLUTION
By iterative_prediction_convergence, error n ≤ c^n * error 0. Since c < 1, c^n → 0, so c^n * error 0 → 0. Thus for any ε > 0, ∃ N such that c^N * error 0 < ε, and for n ≥ N, error n ≤ c^n * error 0 ≤ c^N * error 0 < ε. Use exists_pow_lt_of_lt_one or tendsto to get N, then iterative_prediction_convergence for the bound.
-/
theorem iterative_prediction_vanishes
    (error : ℕ → ℝ) (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c < 1)
    (_h0 : 0 ≤ error 0)
    (hstep : ∀ n, error (n + 1) ≤ c * error n)
    (herr : ∀ n, 0 ≤ error n)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ N, ∀ n, N ≤ n → error n < ε := by
  -- By iterative_prediction_convergence, error n ≤ c^n * error 0.
  have h_iter : ∀ n, error n ≤ c^n * error 0 := by
    exact?;
  -- Since $c < 1$, $c^n \to 0$ as $n \to \infty$.
  have h_c_pow_zero : Filter.Tendsto (fun n => c^n * error 0) Filter.atTop (nhds 0) := by
    simpa using Filter.Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one hc0 hc1 ) tendsto_const_nhds;
  exact Filter.eventually_atTop.mp ( h_c_pow_zero.eventually ( gt_mem_nhds hε ) ) |> fun ⟨ N, hN ⟩ ↦ ⟨ N, fun n hn ↦ lt_of_le_of_lt ( h_iter n ) ( hN n hn ) ⟩

/-! ## §2. The Multiplicative Weights Update (MWU) Method -/

-- MWU regret bound: after T rounds with N experts,
-- the regret of MWU with learning rate η is at most ln(N)/η + η*T.
theorem mwu_regret_bound_structure
    (N T : ℕ) (_η : ℝ) (_hη : 0 < _η) (_hN : 0 < N)
    (regret : ℝ)
    (hregret : regret ≤ Real.log N / _η + _η * T) :
    regret ≤ Real.log N / _η + _η * T := hregret

/-
PROBLEM
The optimal learning rate η = sqrt(ln N / T) gives regret ≤ 2*sqrt(T*ln N)

PROVIDED SOLUTION
eta = sqrt(log N / T). Then log N / eta = log N / sqrt(log N / T) = sqrt(log N) * sqrt(T) = sqrt(T * log N). And eta * T = sqrt(log N / T) * T = sqrt(log N) * sqrt(T) = sqrt(T * log N). So the sum is 2 * sqrt(T * log N). Key: use Real.div_sqrt, sqrt_mul, mul_comm.
-/
theorem optimal_mwu_rate (N T : ℕ) (hN : 1 < N) (hT : 0 < T) :
    let eta := Real.sqrt (Real.log N / T)
    Real.log N / eta + eta * T = 2 * Real.sqrt (T * Real.log N) := by
  field_simp [mul_comm, mul_assoc, mul_left_comm];
  rw [ Real.sq_sqrt <| by positivity, div_eq_iff ] <;> ring_nf <;> norm_num [ hT.ne', hN.le ];
  · ring ; norm_num [ hT.ne', hN.le ];
    rw [ Real.sq_sqrt ( Real.log_nonneg ( Nat.one_le_cast.mpr hN.le ) ) ];
  · exact ne_of_gt <| Real.sqrt_pos.mpr <| Real.log_pos <| Nat.one_lt_cast.mpr hN

/-! ## §3. Calibration -/

-- Brier score decomposition (structural)
theorem brier_score_decomposition
    (n : ℕ) (_hn : 0 < n)
    (forecasts outcomes : Fin n → ℝ)
    (reliability resolution uncertainty : ℝ)
    (hBS : ∑ i, (forecasts i - outcomes i) ^ 2 =
           (n : ℝ) * (reliability - resolution + uncertainty)) :
    ∑ i, (forecasts i - outcomes i) ^ 2 =
    (n : ℝ) * (reliability - resolution + uncertainty) := hBS

/-! ## §4. The Blackwell-Dubins Theorem (Merging of Opinions) -/

/-
PROBLEM
Discrete merging: if predictions converge pointwise, the difference vanishes.

PROVIDED SOLUTION
Use squeeze_zero. We have 0 ≤ |p₁ n - p₂ n| and |p₁ n - p₂ n| ≤ delta n, and delta → 0. So |p₁ n - p₂ n| → 0 by the squeeze theorem. Use tendsto_of_tendsto_of_tendsto_of_le_of_le with the constant zero sequence and delta.
-/
theorem discrete_opinion_merging
    (p₁ p₂ : ℕ → ℝ)
    (delta : ℕ → ℝ)
    (_hdelta_pos : ∀ n, 0 ≤ delta n)
    (hdelta_bound : ∀ n, |p₁ n - p₂ n| ≤ delta n)
    (hdelta_vanish : Filter.Tendsto delta Filter.atTop (nhds 0)) :
    Filter.Tendsto (fun n => |p₁ n - p₂ n|) Filter.atTop (nhds 0) := by
  exact squeeze_zero ( fun n => abs_nonneg _ ) hdelta_bound hdelta_vanish

/-! ## §5. The Doob Decomposition: Separating Signal from Noise -/

/-
PROBLEM
The noise component has zero weighted mean, so the weighted observation
    mean equals the weighted signal mean.

PROVIDED SOLUTION
Rewrite observation i = signal i + noise i everywhere. Then ∑ w i * observation i = ∑ w i * (signal i + noise i) = ∑ w i * signal i + ∑ w i * noise i = ∑ w i * signal i + 0. Use Finset.sum_congr with hdecomp, mul_add, Finset.sum_add_distrib, hnoise.
-/
theorem doob_decomposition_noise_zero_mean
    (signal noise observation : Fin n → ℝ)
    (w : Fin n → ℝ)
    (_hw_nonneg : ∀ i, 0 ≤ w i)
    (_hw_sum : ∑ i, w i = 1)
    (hdecomp : ∀ i, observation i = signal i + noise i)
    (hnoise : ∑ i, w i * noise i = 0) :
    ∑ i, w i * observation i = ∑ i, w i * signal i := by
  simp +decide [ *, mul_add, Finset.sum_add_distrib ]

/-! ## §6. Prediction Horizon Decay -/

/-
PROBLEM
For an AR(1) process with |rho| < 1, autocorrelation rho^k → 0.

PROVIDED SOLUTION
This is tendsto_pow_atTop_nhds_zero_of_abs_lt_one applied to hrho.
-/
theorem ar1_autocorrelation_decay (rho : ℝ) (hrho : |rho| < 1) :
    Filter.Tendsto (fun k => rho ^ k) Filter.atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_abs_lt_one hrho

/-
PROBLEM
Prediction variance grows with horizon for non-stationary processes

PROVIDED SOLUTION
sigma_sq ≤ (k+1) * sigma_sq. Since 0 < sigma_sq and 1 ≤ k+1, we have sigma_sq = 1 * sigma_sq ≤ (k+1) * sigma_sq. Use le_mul_of_one_le_left (le_of_lt hsig) and Nat.one_le_iff_ne_zero or just by omega/positivity for 1 ≤ k+1.
-/
theorem prediction_variance_growth (sigma_sq : ℝ) (hsig : 0 < sigma_sq) (k : ℕ) :
    sigma_sq ≤ (k + 1) * sigma_sq := by
  exact le_mul_of_one_le_left hsig.le ( by linarith )

end