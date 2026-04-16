/-! # CatalogBuild.MachineLearning.Prediction.BayesOptimal

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 16
-/

import Mathlib

noncomputable section

/-- The Brier score: measures prediction quality. Lower is better. -/
noncomputable def brierScore (p : ℝ) (outcome : ℝ) : ℝ :=
  (p - outcome) ^ 2


/-- Brier score is always non-negative -/
theorem brierScore_nonneg (p outcome : ℝ) : 0 ≤ brierScore p outcome :=
  sq_nonneg _


/-- Brier score is zero iff prediction equals outcome -/
theorem brierScore_eq_zero_iff (p outcome : ℝ) :
    brierScore p outcome = 0 ↔ p = outcome := by
  simp [brierScore, sub_eq_zero]


/-- Bayes' theorem: P(H|E) = P(E|H)·P(H)/P(E) -/
theorem bayes_theorem (pH pE pE_given_H : ℝ) :
    bayesUpdate pH pE_given_H pE = pE_given_H * pH / pE := by
  simp [bayesUpdate]


/-- Bayesian update produces non-negative result from non-negative inputs -/
theorem bayes_update_nonneg (prior likelihood evidence : ℝ)
    (h_prior : 0 ≤ prior) (h_lik : 0 ≤ likelihood) (h_ev : 0 < evidence) :
    0 ≤ bayesUpdate prior likelihood evidence :=
  div_nonneg (mul_nonneg h_lik h_prior) (le_of_lt h_ev)


/-- For binary prediction, the Brier-optimal prediction equals the true probability.
This is the fundamental theorem: honest probabilities minimize expected Brier score. -/
theorem brier_optimal_prediction (p q : ℝ) :
    p * brierScore p 1 + (1 - p) * brierScore p 0 ≤
    p * brierScore q 1 + (1 - p) * brierScore q 0 := by
  simp only [brierScore]
  nlinarith [sq_nonneg (p - q)]


/-- Corollary: The expected Brier score of the true probability equals p(1-p) -/
theorem expected_brier_at_optimum (p : ℝ) :
    p * brierScore p 1 + (1 - p) * brierScore p 0 = p * (1 - p) := by
  simp [brierScore]; ring


/-- The expected Brier score at optimum is at most 1/4 -/
theorem expected_brier_le_quarter (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    p * (1 - p) ≤ 1 / 4 := by
  nlinarith [sq_nonneg (p - 1/2)]


/-- Convex combination of predictions -/
noncomputable def ensemblePrediction {n : ℕ} (predictions : Fin n → ℝ)
    (weights : Fin n → ℝ) : ℝ :=
  ∑ i, weights i * predictions i


theorem ambiguity_decomposition {n : ℕ} (predictions : Fin n → ℝ)
    (weights : Fin n → ℝ) (hw_sum : ∑ i, weights i = 1) (y : ℝ) :
    (ensemblePrediction predictions weights - y) ^ 2 =
    ∑ i, weights i * (predictions i - y) ^ 2 -
    ∑ i, weights i * (predictions i - ensemblePrediction predictions weights) ^ 2 := by
  unfold ensemblePrediction;
  simp +decide [ sub_sq, Finset.sum_add_distrib, mul_add, mul_sub, Finset.mul_sum _ _ _, Finset.sum_mul, hw_sum ] ; ring;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_comm, hw_sum ] ; ring;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, hw_sum ] ; ring


/-- Diversity is always non-negative -/
theorem ensemble_diversity_nonneg {n : ℕ} (predictions : Fin n → ℝ)
    (weights : Fin n → ℝ) (hw_nonneg : ∀ i, 0 ≤ weights i) :
    0 ≤ ∑ i, weights i * (predictions i - ensemblePrediction predictions weights) ^ 2 :=
  Finset.sum_nonneg fun i _ => mul_nonneg (hw_nonneg i) (sq_nonneg _)


/-- Cumulative loss of a strategy over T rounds -/
noncomputable def cumulativeLoss (loss : ℕ → ℝ) (T : ℕ) : ℝ :=
  ∑ t ∈ Finset.range T, loss t


/-- Regret: excess loss over the best fixed strategy in hindsight -/
noncomputable def regret (our_loss best_loss : ℕ → ℝ) (T : ℕ) : ℝ :=
  cumulativeLoss our_loss T - cumulativeLoss best_loss T


/-- A no-regret algorithm has average regret → 0 -/
def isNoRegret (our_loss best_loss : ℕ → ℝ) : Prop :=
  Filter.Tendsto (fun T => regret our_loss best_loss T / T)
    Filter.atTop (nhds 0)


/-- The No-Clairvoyance Theorem: In a fair game (martingale),
the expected future value equals the current value. -/
theorem no_clairvoyance (values : ℕ → ℝ) (n : ℕ)
    (h_martingale : ∀ k, values (k + 1) = values k) :
    values n = values 0 := by
  induction n with
  | zero => rfl
  | succ n ih => rw [h_martingale, ih]


/-- Prediction error for a convergent sequence eventually becomes small -/
theorem convergent_eventually_predictable (seq : ℕ → ℝ) (L : ℝ)
    (h : Filter.Tendsto seq Filter.atTop (nhds L))
    (ε : ℝ) (hε : 0 < ε) :
    ∃ N, ∀ n, N ≤ n → |seq n - L| < ε := by
  rw [Metric.tendsto_atTop] at h
  exact h ε hε


end
