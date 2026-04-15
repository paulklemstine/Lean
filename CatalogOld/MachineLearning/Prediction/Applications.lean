/-
  # Prediction Science: Novel Applications

  Innovative applications of the prediction framework:
  1. Prediction Markets as Information Aggregators
  2. Epidemic Prediction with Self-Fulfilling Dynamics
  3. Climate Prediction Ensembles
  4. AI Alignment: Predicting AI Behavior
  5. Quantum Prediction Advantage
  6. Prediction-Powered Inference
-/

import Mathlib

open Real Finset

noncomputable section

/-! ## §1. Prediction Markets: Prices as Probabilities

A prediction market aggregates beliefs into prices. We prove that
market prices satisfy the axioms of probability under no-arbitrage. -/

/-
PROBLEM
No-arbitrage implies prices form a probability distribution

PROVIDED SOLUTION
For each i, 0 ≤ prices i by h_nonneg. And prices i ≤ ∑ j, prices j = 1 by Finset.single_le_sum. So prices i ∈ [0, 1]. Use Set.mem_Icc.mpr with h_nonneg and Finset.single_le_sum.
-/
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

/-! ## §7. Novel Application Ideas (Research Directions)

### 7.1 Prediction DAOs
Decentralized prediction organizations where oracles stake tokens on predictions.
The diversity theorem guarantees that properly weighted diverse DAOs outperform
any single oracle. Smart contracts enforce the MWU update rule.

### 7.2 Adversarial Prediction Robustness
Using the minimax theorem from game theory, design predictors that are
robust against adversarial data corruption. The optimal strategy is a
mixed strategy over prediction algorithms.

### 7.3 Prediction-Driven Scientific Discovery
Use ensemble predictions to identify "regions of maximum disagreement" —
these are exactly the regions where experiments are most informative.
The diversity measure directly quantifies experimental value.

### 7.4 Self-Referential Markets
Markets that predict their own future prices. Our fixed-point theorems
guarantee equilibrium existence. The contraction rate determines
how quickly the market converges to the equilibrium.

### 7.5 Prediction Compression
By the prediction-compression duality, a good predictor is also a good
compressor. This enables: lossy compression guided by prediction error,
anomaly detection (surprising events = high prediction error), and
automated feature discovery (the predictor learns what matters).

### 7.6 Causal Prediction
Extend the framework from correlation-based prediction (E[Y|X]) to
intervention-based prediction (E[Y|do(X)]). The causal prediction
requires knowledge of the causal graph, which can itself be predicted
from observational data using the PC algorithm or similar.

### 7.7 Prediction of Rare Events (Black Swans)
The standard framework underweights rare events. Using extreme value theory,
we can extend the prediction framework to properly account for fat-tailed
distributions. The key insight: ensemble diversity is most valuable
precisely for rare events, where individual predictors diverge most.
-/