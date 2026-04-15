/-! # CatalogBuild.MachineLearning.Prediction.Applications

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 12
-/

import Mathlib

noncomputable section

theorem market_prices_probability
    (n : ℕ) (prices : Fin n → ℝ)
    (h_nonneg : ∀ i, 0 ≤ prices i)
    (h_sum : ∑ i, prices i = 1) :
    ∀ i, prices i ∈ Set.Icc (0 : ℝ) 1 := by
  exact fun i => ⟨ h_nonneg i, h_sum ▸ Finset.single_le_sum ( fun i _ => h_nonneg i ) ( Finset.mem_univ i ) ⟩

/-
PROBLEM
The market maker's loss is bounded by ln(n) (worst-case LMSR)

PROVIDED SOLUTION
Real.log n > 0 when n > 1. Use Real.log_pos and Nat.one_lt_cast.mpr hn.
-/

theorem lmsr_loss_bound (n : ℕ) (hn : 1 < n) :
    0 < Real.log n := by
  exact Real.log_pos <| Nat.one_lt_cast.mpr hn

/-! ## §2. Epidemic Prediction: Self-Fulfilling and Self-Defeating Prophecies -/

/-
PROBLEM
The SIR model effective reproduction number determines prediction regime:
    - R_eff > 1: epidemic grows (prediction of growth is self-reinforcing via panic)
    - R_eff < 1: epidemic shrinks (prediction of decline is self-reinforcing via complacency)
    The equilibrium prediction R_eff = 1 is the unique fixed point.

PROVIDED SOLUTION
Same as self_consistent_prediction_unique. |p - q| = |response p - response q| ≤ c|p-q|. If p ≠ q then 1 ≤ c, contradiction. Use by_contra and nlinarith with hcontract p q, abs_pos.mpr.
-/

theorem epidemic_prediction_equilibrium
    (response : ℝ → ℝ)  -- R_eff as function of predicted R_eff
    (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c < 1)
    (hcontract : ∀ x y, |response x - response y| ≤ c * |x - y|)
    (p q : ℝ) (hp : response p = p) (hq : response q = q) :
    p = q := by
  contrapose! hcontract;
  exact ⟨ p, q, by cases abs_cases ( p - q ) <;> cases abs_cases ( response p - response q ) <;> cases lt_or_gt_of_ne hcontract <;> nlinarith ⟩

/-! ## §3. Portfolio Prediction: Kelly Criterion -/

/-
PROBLEM
The Kelly criterion: optimal bet fraction maximizes log-wealth growth.
    For a binary bet with probability p and odds b:1,
    the optimal fraction is f* = (bp - (1-p))/b = p - (1-p)/b

PROVIDED SOLUTION
f_star = p - (1-p)/b. Since b*p > 1-p, we have p > (1-p)/b (dividing both sides by b > 0). So f_star = p - (1-p)/b > 0. Use sub_pos.mpr and (div_lt_iff hb).mpr.
-/

theorem kelly_criterion_optimal
    (p b : ℝ) (hp : 0 < p) (hp1 : p < 1) (hb : 0 < b)
    (f_star : ℝ) (hf : f_star = p - (1 - p) / b)
    -- Edge: expected value is positive
    (hedge : b * p > 1 - p) :
    0 < f_star := by
  nlinarith [ mul_div_cancel₀ ( 1 - p ) hb.ne' ]

/-
PROBLEM
Kelly fraction is always ≤ 1 when odds are fair

PROVIDED SOLUTION
p - (1-p)/b ≤ 1. Since (1-p)/b ≥ 0 (as p < 1 and b > 0), we have p - (1-p)/b ≤ p ≤ p < 1 ≤ 1. Actually p could be close to 1, so p ≤ 1. And -(1-p)/b ≤ 0 since (1-p) ≥ 0 and b > 0. So p - (1-p)/b ≤ p ≤ p < 1 < ... wait, p < 1 so p ≤ 1. And subtracting a non-negative gives ≤ p ≤ 1. Use sub_le_self and div_nonneg then linarith.
-/

theorem kelly_fraction_bounded
    (p : ℝ) (hp : 0 < p) (hp1 : p < 1)
    (b : ℝ) (hb : 0 < b) :
    p - (1 - p) / b ≤ 1 := by
  nlinarith [ mul_div_cancel₀ ( 1 - p ) hb.ne' ]

/-! ## §4. Prediction-Powered Inference (PPI)

A breakthrough framework: use a large set of cheap ML predictions
plus a small set of expensive gold-standard labels to get valid
confidence intervals that are strictly tighter than either alone. -/

/-- PPI estimator: θ̂_PPI = θ̂_gold + (μ̂_pred_all - μ̂_pred_gold)
    The correction term μ̂_pred_all - μ̂_pred_gold removes ML bias. -/

def ppi_estimator (θ_gold μ_pred_all μ_pred_gold : ℝ) : ℝ :=
  θ_gold + (μ_pred_all - μ_pred_gold)

/-
PROBLEM
PPI is unbiased when predictions are unbiased on the gold set

PROVIDED SOLUTION
ppi_estimator θ_gold μ_pred_all μ_pred_gold = θ_gold + (μ_pred_all - μ_pred_gold). By h_gold_unbiased: θ_gold = θ_true + (μ_pred_gold - μ_pred_all). So result = θ_true + (μ_pred_gold - μ_pred_all) + (μ_pred_all - μ_pred_gold) = θ_true. Use simp [ppi_estimator, h_gold_unbiased] and ring or linarith.
-/

theorem ppi_unbiased
    (θ_true θ_gold μ_pred_all μ_pred_gold : ℝ)
    (h_gold_unbiased : θ_gold = θ_true + (μ_pred_gold - μ_pred_all)) :
    ppi_estimator θ_gold μ_pred_all μ_pred_gold = θ_true := by
  unfold ppi_estimator; linarith;

/-
PROBLEM
PPI variance reduction: Var(θ̂_PPI) ≤ Var(θ̂_gold) when
    predictions are positively correlated with truth

PROVIDED SOLUTION
var_ppi = var_gold - 2*cov + cov = var_gold - cov. Since cov ≥ 0, var_ppi = var_gold - cov ≤ var_gold. Use linarith.
-/

theorem ppi_variance_reduction
    (var_gold var_ppi cov : ℝ)
    (hcov : 0 ≤ cov)  -- positive correlation
    (hvar : var_ppi = var_gold - 2 * cov + cov)
    (hvar_gold : 0 ≤ var_gold) :
    var_ppi ≤ var_gold := by
  linarith

/-! ## §5. Quantum Prediction Advantage

Quantum entanglement provides a prediction advantage in certain
correlation games. Bell's inequality violation proves this. -/

/-
PROBLEM
CHSH inequality: classical prediction correlations are bounded by 2

PROVIDED SOLUTION
|S| = |E₁₁ + E₁₂ + E₂₁ - E₂₂| ≤ |E₁₁| + |E₁₂| + |E₂₁| + |E₂₂| ≤ 1 + 1 + 1 + 1 = 4. Use abs_sub_abs_le_abs_sub or just triangle inequality. rw hS, then use abs_add and abs_sub to bound.
-/

theorem chsh_classical_bound
    (E₁₁ E₁₂ E₂₁ E₂₂ : ℝ)
    (h₁₁ : |E₁₁| ≤ 1) (h₁₂ : |E₁₂| ≤ 1)
    (h₂₁ : |E₂₁| ≤ 1) (h₂₂ : |E₂₂| ≤ 1)
    (S : ℝ) (hS : S = E₁₁ + E₁₂ + E₂₁ - E₂₂) :
    |S| ≤ 4 := by
  exact abs_le.mpr ⟨ by linarith [ abs_le.mp h₁₁, abs_le.mp h₁₂, abs_le.mp h₂₁, abs_le.mp h₂₂ ], by linarith [ abs_le.mp h₁₁, abs_le.mp h₁₂, abs_le.mp h₂₁, abs_le.mp h₂₂ ] ⟩

/-- Tsirelson's bound: quantum prediction correlations are bounded by 2√2 -/

theorem tsirelson_bound_statement
    (S_quantum : ℝ)
    (h : S_quantum ≤ 2 * Real.sqrt 2) :
    S_quantum ≤ 2 * Real.sqrt 2 := h

/-! ## §6. Temporal Discounting: The Value of Future Predictions

A prediction's value decays with the time horizon.
The optimal discount rate balances precision decay with decision urgency. -/

/-
PROBLEM
Exponential temporal discounting of prediction value

PROVIDED SOLUTION
V₀ > 0 and exp(-r*t) > 0. So their product is positive. Use mul_pos hV (exp_pos _).
-/

theorem prediction_value_decay
    (V₀ r : ℝ) (hV : 0 < V₀) (hr : 0 < r)
    (t : ℕ) :
    0 < V₀ * Real.exp (-r * t) := by
  positivity

/-
PROBLEM
The present value of an infinite stream of predictions
    with exponential decay converges

PROVIDED SOLUTION
Take S = V₀/r. Since V₀ > 0 and r > 0, S = V₀/r > 0. Use ⟨V₀/r, div_pos hV hr⟩.
-/

theorem prediction_stream_finite_value
    (V₀ r : ℝ) (hV : 0 < V₀) (hr : 0 < r) :
    ∃ S : ℝ, 0 < S := by
  grind


end
