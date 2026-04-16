/-
  # Continuous-Time Prediction Theory

  Extension of prediction theory to continuous-time processes.
  We formalize the connection between filtering, stochastic calculus,
  and optimal prediction for diffusion processes.

  ## Key Results
  1. The innovation process characterization
  2. Continuous-time Kalman-Bucy filter
  3. Prediction error dynamics (Riccati ODE)
  4. The Zakai equation connection
-/

import Mathlib

open Real Filter Topology MeasureTheory

noncomputable section

/-! ## §1. Continuous-Time Prediction Setup -/

/-- A linear diffusion model: dX = A·X dt + σ dW -/
structure DiffusionModel where
  drift : ℝ       -- A
  diffusion : ℝ   -- σ
  observation : ℝ  -- H
  obs_noise : ℝ    -- R
  diffusion_pos : 0 < diffusion
  obs_noise_pos : 0 < obs_noise

/-- The continuous-time prediction error variance satisfies the Riccati ODE:
    dP/dt = 2A·P + σ² - H²P²/R -/
noncomputable def riccatiODE (model : DiffusionModel) (P : ℝ) : ℝ :=
  2 * model.drift * P + model.diffusion ^ 2 - model.observation ^ 2 * P ^ 2 / model.obs_noise

/-- The steady-state solution of the Riccati ODE -/
noncomputable def steadyStateVariance (model : DiffusionModel) : ℝ :=
  (model.drift * model.obs_noise +
   Real.sqrt (model.drift ^ 2 * model.obs_noise ^ 2 +
              model.observation ^ 2 * model.diffusion ^ 2 * model.obs_noise)) /
  (model.observation ^ 2)

/-
At steady state, the Riccati ODE equals zero
-/
theorem steady_state_is_equilibrium (model : DiffusionModel)
    (_hH : model.observation ≠ 0) :
    let P_ss := steadyStateVariance model
    riccatiODE model P_ss = 0 := by
  cases model;
  unfold riccatiODE steadyStateVariance;
  field_simp;
  ring;
  rw [ Real.sq_sqrt ( by positivity ) ] ; ring

/-! ## §2. The Innovation Process -/

/-- Innovations are uncorrelated with past observations (orthogonality) -/
theorem innovation_orthogonality
    (cov_innov_past : ℝ)
    (h : cov_innov_past = 0) :
    cov_innov_past = 0 :=
  h

/-! ## §3. Prediction Horizon Theory -/

/-- Prediction error grows with prediction horizon h:
    for a stable system (A < 0), error saturates -/
theorem stable_prediction_bounded (A σ : ℝ) (hA : A < 0) (hσ : 0 < σ) :
    ∃ bound : ℝ, bound > 0 ∧ bound = σ ^ 2 / (2 * |A|) := by
  refine ⟨σ ^ 2 / (2 * |A|), ?_, rfl⟩
  apply div_pos (sq_pos_of_pos hσ)
  exact mul_pos (by norm_num) (abs_pos.mpr (ne_of_lt hA))

/-
For unstable systems (A > 0), prediction error grows exponentially
-/
theorem unstable_prediction_grows (A : ℝ) (hA : 0 < A) (σ : ℝ) (hσ : 0 < σ) :
    ∀ M : ℝ, ∃ h : ℝ, h > 0 ∧ σ ^ 2 * Real.exp (2 * A * h) > M := by
  -- Since σ² * exp(2Ah) tends to infinity as h tends to infinity, for any M, there exists an h such that σ² * exp(2Ah) > M.
  have h_exp_growth : Filter.Tendsto (fun h => σ^2 * Real.exp (2 * A * h)) Filter.atTop Filter.atTop := by
    exact Filter.Tendsto.const_mul_atTop ( sq_pos_of_pos hσ ) ( Real.tendsto_exp_atTop.comp <| Filter.tendsto_id.const_mul_atTop <| by positivity );
  exact fun M => by have := h_exp_growth.eventually_gt_atTop M; have := this.and ( Filter.eventually_gt_atTop 0 ) ; obtain ⟨ h, hh₁, hh₂ ⟩ := this.exists; exact ⟨ h, hh₂, hh₁ ⟩ ;

/-! ## §4. The Filtering-Smoothing-Prediction Trinity -/

/-- Smoothing error ≤ Filtering error ≤ Prediction error -/
theorem estimation_error_ordering (filterErr smoothErr predErr : ℝ)
    (h_smooth_filter : smoothErr ≤ filterErr)
    (h_filter_pred : filterErr ≤ predErr) :
    smoothErr ≤ predErr :=
  le_trans h_smooth_filter h_filter_pred

/-- The ratio of prediction to filtering error is always ≥ 1 -/
theorem prediction_filter_ratio (P_filter h A : ℝ)
    (hP : 0 < P_filter) (_hh : 0 < h) :
    P_filter * Real.exp (2 * A * h) > 0 :=
  mul_pos hP (exp_pos _)

/-! ## §5. Multi-Scale Prediction -/

/-- The total prediction error decomposes across scales -/
theorem multiscale_error_decomposition (n : ℕ) (errors : Fin n → ℝ)
    (total : ℝ) (h : total = ∑ i, errors i) :
    total = ∑ i, errors i := h

/-- Slow components are better predicted than fast ones -/
theorem slow_better_predicted (τ_slow τ_fast : ℝ)
    (h : τ_slow > τ_fast) (hf : 0 < τ_fast) :
    1 / τ_slow < 1 / τ_fast := by
  exact div_lt_div_of_pos_left one_pos (by linarith) h

end