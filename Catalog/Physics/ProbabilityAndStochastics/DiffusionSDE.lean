/-
  Diffusion Models as Stochastic Differential Equations
  =====================================================

  We formalize key properties of the Ornstein-Uhlenbeck (OU) process
    dX_t = -θ X_t dt + σ dW_t
  which underpins score-based diffusion models. Rather than axiomatizing
  Itô calculus (absent from Mathlib), we work with the *deterministic*
  signatures of the process — its mean, variance, and information-theoretic
  convergence — which are the quantities that matter for diffusion model theory.

  Main results:
  1. The OU mean decays exponentially to zero (ou_mean_tendsto_zero)
  2. The OU variance converges to the stationary value σ²/(2θ) (ou_variance_tendsto_stationary)
  3. KL divergence between identical Gaussians is zero (kl_div_gaussian_self_eq_zero)
  4. KL divergence between Gaussians is nonneg (kl_div_gaussian_nonneg) — Gibbs' inequality
  5. OU variance stays positive (ou_variance_pos) — well-definedness of Gaussian marginals
-/
import Mathlib

noncomputable section

open Real Filter Topology

-- ═══════════════════════════════════════════════════════════════════════
-- Section 1: Ornstein-Uhlenbeck Process Parameters
-- ═══════════════════════════════════════════════════════════════════════

/-- Mean of the OU process at time t, given initial mean m₀ and rate θ.
    Solves dm/dt = -θ m with m(0) = m₀. -/
def ouMean (m₀ θ t : ℝ) : ℝ := m₀ * exp (-θ * t)

/-- Variance of the OU process at time t.
    Solves dv/dt = -2θv + σ² with v(0) = v₀. -/
def ouVariance (v₀ σsq θ t : ℝ) : ℝ :=
  v₀ * exp (-2 * θ * t) + (σsq / (2 * θ)) * (1 - exp (-2 * θ * t))

/-- Stationary variance of the OU process: σ²/(2θ). -/
def ouStationaryVariance (σsq θ : ℝ) : ℝ := σsq / (2 * θ)

/-- KL divergence between univariate Gaussians N(m₁,v₁) and N(m₂,v₂),
    where v₁, v₂ are variances (not std devs).
    Formula: KL = ½[log(v₂/v₁) + v₁/v₂ + (m₁-m₂)²/v₂ - 1] -/
def klDivGaussian (m₁ v₁ m₂ v₂ : ℝ) : ℝ :=
  (1 / 2) * (log (v₂ / v₁) + v₁ / v₂ + (m₁ - m₂) ^ 2 / v₂ - 1)

-- ═══════════════════════════════════════════════════════════════════════
-- Section 2: OU Mean Convergence
-- ═══════════════════════════════════════════════════════════════════════

-- !-- Proof sketch: ou_mean_tendsto_zero -- !--
-- The OU mean is m₀ · exp(-θt). For θ > 0, the linear map t ↦ θt
-- sends atTop to atTop, negation sends it to atBot, and exp∘neg
-- converges to 0 by Real.tendsto_exp_atBot.
-- !-- End proof sketch -- !--

theorem ou_mean_tendsto_zero (m₀ θ : ℝ) (hθ : 0 < θ) :
    Tendsto (fun t => ouMean m₀ θ t) atTop (nhds 0) := by
  simpa [ouMean] using tendsto_const_nhds.mul
    (Real.tendsto_exp_atBot.comp <|
      Filter.tendsto_neg_atTop_atBot.comp <|
        Filter.tendsto_id.const_mul_atTop hθ)

-- ═══════════════════════════════════════════════════════════════════════
-- Section 3: OU Variance Convergence
-- ═══════════════════════════════════════════════════════════════════════

-- !-- Proof sketch: ou_variance_tendsto_stationary -- !--
-- ouVariance = v₀·exp(-2θt) + (σsq/(2θ))·(1 - exp(-2θt)).
-- As t→∞, exp(-2θt)→0 (since 2θ>0), so the first term → 0
-- and the second → σsq/(2θ) = ouStationaryVariance.
-- !-- End proof sketch -- !--

theorem ou_variance_tendsto_stationary (v₀ σsq θ : ℝ) (hθ : 0 < θ) :
    Tendsto (fun t => ouVariance v₀ σsq θ t) atTop
      (nhds (ouStationaryVariance σsq θ)) := by
  unfold ouVariance ouStationaryVariance
  exact le_trans
    (Filter.Tendsto.add
      (tendsto_const_nhds.mul <|
        Real.tendsto_exp_atBot.comp <|
          Filter.tendsto_id.const_mul_atTop_of_neg <| by linarith)
      <| tendsto_const_nhds.mul <|
        tendsto_const_nhds.sub <|
          Real.tendsto_exp_atBot.comp <|
            Filter.tendsto_id.const_mul_atTop_of_neg <| by linarith)
    <| by norm_num

-- ═══════════════════════════════════════════════════════════════════════
-- Section 4: KL Divergence Properties
-- ═══════════════════════════════════════════════════════════════════════

-- !-- Proof sketch: kl_div_gaussian_self_eq_zero -- !--
-- When m₁=m₂=m and v₁=v₂=v with v≠0: v/v=1, log(1)=0, (m-m)²=0.
-- So KL = ½(0+1+0-1) = 0.
-- !-- End proof sketch -- !--

theorem kl_div_gaussian_self_eq_zero (m v : ℝ) (hv : v ≠ 0) :
    klDivGaussian m v m v = 0 := by
  unfold klDivGaussian; norm_num [hv]

-- !-- Proof sketch: kl_div_gaussian_nonneg -- !--
-- KL = ½[log(v₂/v₁) + v₁/v₂ + (m₁-m₂)²/v₂ - 1].
-- Rewrite log(v₂/v₁) = log v₂ - log v₁ = -(log v₁ - log v₂) = -log(v₁/v₂).
-- Set r = v₁/v₂ > 0. By log(r) ≤ r-1 (Real.log_le_sub_one_of_pos),
-- we get -log(r) ≥ 1-r, hence -log(r)+r-1 ≥ 0.
-- The mean term (m₁-m₂)²/v₂ ≥ 0 adds further nonnegativity.
-- !-- End proof sketch -- !--

theorem kl_div_gaussian_nonneg (m₁ v₁ m₂ v₂ : ℝ) (hv₁ : 0 < v₁) (hv₂ : 0 < v₂) :
    0 ≤ klDivGaussian m₁ v₁ m₂ v₂ := by
  unfold klDivGaussian
  rw [Real.log_div hv₂.ne' hv₁.ne']
  have := Real.log_le_sub_one_of_pos (div_pos hv₁ hv₂)
  rw [Real.log_div] at this <;>
    nlinarith [mul_div_cancel₀ ((m₁ - m₂) ^ 2) hv₂.ne']

-- ═══════════════════════════════════════════════════════════════════════
-- Section 5: OU Variance Positivity (well-definedness of Gaussian marginals)
-- ═══════════════════════════════════════════════════════════════════════

-- !-- Proof sketch: ou_variance_pos -- !--
-- First term v₀·exp(-2θt) > 0 since v₀ > 0 and exp > 0.
-- Second term (σsq/(2θ))·(1-exp(-2θt)) ≥ 0 since σsq/(2θ) > 0
-- and exp(-2θt) ≤ 1 for t ≥ 0. Sum is positive.
-- !-- End proof sketch -- !--

theorem ou_variance_pos (v₀ σsq θ t : ℝ) (hv₀ : 0 < v₀)
    (hσ : 0 < σsq) (hθ : 0 < θ) (ht : 0 ≤ t) :
    0 < ouVariance v₀ σsq θ t := by
  exact add_pos_of_pos_of_nonneg
    (mul_pos hv₀ (Real.exp_pos _))
    (mul_nonneg
      (div_nonneg hσ.le (mul_nonneg zero_le_two hθ.le))
      (sub_nonneg.mpr (Real.exp_le_one_iff.mpr (by nlinarith))))

-- ═══════════════════════════════════════════════════════════════════════
-- Lab Notebooks
-- ═══════════════════════════════════════════════════════════════════════

-- !-- Lab Notebook: ou_mean_tendsto_zero -- !--
-- Hypothesis: The OU mean m₀·exp(-θt) converges to 0 for θ > 0
-- Result: PROVED. Clean composition of tendsto lemmas.
-- Insight: The proof factors as (const * exp ∘ neg ∘ linear),
--   each piece handled by a dedicated Mathlib tendsto lemma.
--   This is the fundamental "forgetting" property of diffusion models.
-- Failure analysis: None — straightforward once the composition was identified.
-- !-- End Lab Notebook -- !--

-- !-- Lab Notebook: ou_variance_tendsto_stationary -- !--
-- Hypothesis: OU variance converges to σ²/(2θ) regardless of initial variance
-- Result: PROVED. Similar tendsto composition + norm_num for final simplification.
-- Insight: The universality of the stationary variance (independent of v₀) is
--   the mathematical reason diffusion models can generate from any noise level.
--   The proof required careful handling of the (1 - exp(-2θt)) factor.
-- Failure analysis: Initial attempt with simpa failed; explicit unfold + le_trans worked.
-- !-- End Lab Notebook -- !--

-- !-- Lab Notebook: kl_div_gaussian_nonneg -- !--
-- Hypothesis: KL divergence between Gaussians is nonneg (Gibbs' inequality for Gaussians)
-- Result: PROVED. Core inequality is Real.log_le_sub_one_of_pos; nlinarith closes the rest.
-- Insight: The proof strategy of splitting log(v₂/v₁) via Real.log_div and then
--   applying the log inequality to the ratio v₁/v₂ is clean and generalizable.
--   This is the information-theoretic foundation for diffusion model convergence.
-- Failure analysis: None — the Mathlib log inequality was the key enabler.
-- !-- End Lab Notebook -- !--

-- !-- Lab Notebook: kl_div_gaussian_self_eq_zero -- !--
-- Hypothesis: KL(p||p) = 0 is a basic algebraic identity
-- Result: PROVED. norm_num with div_self handles everything.
-- Insight: Combined with kl_div_gaussian_nonneg, this shows KL is a
--   pre-metric on the space of Gaussians (it separates points but is not symmetric).
-- Failure analysis: None.
-- !-- End Lab Notebook -- !--

-- !-- Lab Notebook: ou_variance_pos -- !--
-- Hypothesis: OU variance stays positive when v₀ > 0, σsq > 0, θ > 0, t ≥ 0
-- Result: PROVED. Decomposition into pos + nonneg terms.
-- Insight: Positivity of the variance is essential for the Gaussian marginals
--   to be well-defined probability distributions. The exp(-2θt) ≤ 1 bound
--   (from t ≥ 0) is the key step for the second term's nonnegativity.
-- Failure analysis: None.
-- !-- End Lab Notebook -- !--

end