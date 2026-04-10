/-
  # Online Portfolio Optimization Engine

  This module implements the decision engine that takes historical price data
  and a current portfolio, and outputs buy/sell recommendations.

  ## Algorithm: Adaptive Exponential Gradient with Momentum

  The engine combines:
  1. Exponential Gradient (EG) updates for online learning
  2. Momentum terms for trend following
  3. Kelly criterion for position sizing
  4. Risk constraints (max position size, turnover limits)

  ## Interface

  Input:
  - Historical price data: List of price vectors over n assets
  - Current portfolio: Current allocation weights
  - Risk parameters: Max position, max turnover

  Output:
  - Target portfolio: New allocation weights
  - Trade list: Stocks to buy/sell with quantities
-/

import Mathlib
-- import StockPrediction.Basic  -- [consolidated: module not available as separate import]

open Finset BigOperators

namespace StockPrediction.Engine

/-- Risk parameters for portfolio constraints. -/
structure RiskParams where
  maxPosition : ℝ    -- Maximum weight in any single asset (e.g., 0.20)
  maxTurnover : ℝ    -- Maximum total turnover per rebalance (e.g., 0.50)
  minWeight : ℝ       -- Minimum nonzero weight (e.g., 0.01)
  maxPosition_pos : 0 < maxPosition
  maxTurnover_pos : 0 < maxTurnover
  minWeight_nonneg : 0 ≤ minWeight

/-- A trade recommendation. -/
structure TradeAction (n : ℕ) where
  asset : Fin n
  direction : Bool    -- true = buy, false = sell
  magnitude : ℝ       -- fraction of portfolio to trade
  magnitude_nonneg : 0 ≤ magnitude

/-- The engine's output: target portfolio and trade list. -/
structure EngineOutput (n : ℕ) where
  targetPortfolio : Portfolio n
  trades : List (TradeAction n)

/-- Compute price relatives from consecutive price vectors. -/
noncomputable def computePriceRelatives {n : ℕ}
    (prevPrices curPrices : Fin n → ℝ)
    (hprev : ∀ i, 0 < prevPrices i)
    (hcur : ∀ i, 0 < curPrices i) : PriceRelatives n where
  values i := curPrices i / prevPrices i
  pos i := div_pos (hcur i) (hprev i)

/-- Exponential moving average for momentum estimation. -/
noncomputable def ema (α : ℝ) : List ℝ → ℝ
  | [] => 0
  | [x] => x
  | x :: xs => α * x + (1 - α) * ema α xs

/-- Optimal learning rate for EG algorithm given time horizon T and n assets. -/
noncomputable def optimalEta (n T : ℕ) : ℝ :=
  Real.sqrt (8 * Real.log n / T)

/-
PROBLEM
The optimal learning rate is positive for valid inputs.

PROVIDED SOLUTION
optimalEta n T = √(8 * log n / T). Since n > 1, log n > 0 (Real.log_pos). T > 0 as a natural number cast to real. So 8 * log n / T > 0, and sqrt of a positive is positive.
-/
theorem optimalEta_pos {n T : ℕ} (hn : 1 < n) (hT : 0 < T) :
    0 < optimalEta n T := by
      exact Real.sqrt_pos.mpr ( div_pos ( mul_pos ( by norm_num ) ( Real.log_pos ( mod_cast hn ) ) ) ( mod_cast hT ) )

/-- Clamp a value to [lo, hi]. -/
noncomputable def clamp (lo hi x : ℝ) : ℝ :=
  max lo (min hi x)

/-- Clamp is bounded above. -/
theorem clamp_le_hi (lo hi x : ℝ) (h : lo ≤ hi) : clamp lo hi x ≤ hi := by
  unfold clamp
  exact max_le h (min_le_left hi x)

/-- Clamp is bounded below. -/
theorem lo_le_clamp (lo hi x : ℝ) : lo ≤ clamp lo hi x := by
  unfold clamp
  exact le_max_left lo (min hi x)

/-- Project weights onto the simplex with position limits. -/
noncomputable def projectToConstrainedSimplex (n : ℕ)
    (weights : Fin n → ℝ) (maxPos : ℝ) : Fin n → ℝ :=
  let clamped := fun i => clamp 0 maxPos (weights i)
  let total := ∑ i : Fin n, clamped i
  if h : total = 0 then fun _ => 1 / n
  else fun i => clamped i / total

/-- Compute the trade list from current and target portfolios. -/
noncomputable def computeTrades (n : ℕ)
    (current target : Portfolio n) : List (TradeAction n) :=
  (List.finRange n).filterMap fun i =>
    let diff := target.weights i - current.weights i
    if h : diff > 0.001 then
      some ⟨i, true, diff, by linarith⟩
    else if h2 : diff < -0.001 then
      some ⟨i, false, -diff, by linarith⟩
    else none

/-- The total turnover (sum of absolute weight changes). -/
noncomputable def turnover (n : ℕ) (current target : Portfolio n) : ℝ :=
  ∑ i : Fin n, |target.weights i - current.weights i|

/-- Turnover is nonneg. -/
theorem turnover_nonneg (n : ℕ) (current target : Portfolio n) :
    0 ≤ turnover n current target := by
  unfold turnover
  apply Finset.sum_nonneg
  intro i _
  exact abs_nonneg _

/-
PROBLEM
Maximum turnover from rebalancing is at most 2.

PROVIDED SOLUTION
turnover = ∑|target_i - current_i|. By triangle inequality for ∑|a_i - b_i| ≤ ∑|a_i| + ∑|b_i| = ∑ a_i + ∑ b_i (since a_i, b_i ≥ 0) = 1 + 1 = 2. Use that portfolio weights are nonneg (so |w_i| = w_i) and sum to 1.
-/
theorem turnover_le_two (n : ℕ) (current target : Portfolio n) :
    turnover n current target ≤ 2 := by
      refine' le_trans _ ( show 2 ≥ ∑ i, |target.weights i| + ∑ i, |current.weights i| from _ );
      · simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun i _ => abs_sub _ _;
      · rw [ Finset.sum_congr rfl fun _ _ => abs_of_nonneg <| target.nonneg _, Finset.sum_congr rfl fun _ _ => abs_of_nonneg <| current.nonneg _ ] ; linarith [ current.sum_one, target.sum_one ]

end StockPrediction.Engine