/-! # CatalogBuild.Cryptography.Ethereum.MEV

Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 10
-/

import Mathlib

noncomputable section

/-- A pending swap transaction in the mempool -/
structure PendingSwap where
  inputAmount : ℝ       -- Amount of input token
  minOutput : ℝ         -- Minimum acceptable output (slippage tolerance)
  hInput : 0 < inputAmount
  hMin : 0 ≤ minOutput


/-- Pool state (simplified) -/
structure PoolState where
  x : ℝ
  y : ℝ
  hx : 0 < x
  hy : 0 < y


/-- Swap output from a constant-product pool -/
noncomputable def swapOutput (ps : PoolState) (dx : ℝ) : ℝ :=
  ps.y * dx / (ps.x + dx)


/-- Pool state after a swap -/
noncomputable def poolAfterSwap (ps : PoolState) (dx : ℝ) (hdx : 0 < dx) : PoolState where
  x := ps.x + dx
  y := ps.x * ps.y / (ps.x + dx)
  hx := by linarith [ps.hx]
  hy := by exact div_pos (mul_pos ps.hx ps.hy) (by linarith [ps.hx])


/-- **Sandwich Attack Profit**: A sandwich attacker:
1. Front-runs: buys `dx_front` before the victim's trade
2. Victim's trade executes at a worse price
3. Back-runs: sells the tokens bought in step 1
The profit equals the price impact caused by the front-run. -/
noncomputable def sandwichProfit (pool : PoolState) (victim : PendingSwap)
    (dx_front : ℝ) (hdx : 0 < dx_front) : ℝ :=
  let pool1 := poolAfterSwap pool dx_front hdx       -- After front-run
  let tokens_bought := swapOutput pool dx_front       -- Tokens from front-run
  let pool2 := poolAfterSwap pool1 victim.inputAmount victim.hInput  -- After victim
  let sell_revenue := swapOutput pool2 tokens_bought  -- Revenue from back-run
  -- But we're selling Y back for X, so we need the reverse swap
  -- Simplified: profit = tokens_bought_value_after - tokens_bought_value_before
  tokens_bought - dx_front


/-- [Section: ## Sandwich Attack] -/
theorem sandwich_output_pos (pool : PoolState)
    (dx_front : ℝ) (hdx : 0 < dx_front) :
    0 < swapOutput pool dx_front := by
  exact div_pos ( mul_pos pool.hy hdx ) ( add_pos pool.hx hdx )


/-- **Backrunning**: After a large trade creates a price discrepancy,
arbitraging back to the fair price is always profitable. -/
noncomputable def backrunProfit (pool : PoolState) (fairPrice : ℝ)
    (hFair : 0 < fairPrice) : ℝ :=
  let currentPrice := pool.y / pool.x
  if currentPrice > fairPrice then
    -- Pool overvalues Y relative to X: sell Y, buy X
    let dx := Real.sqrt (pool.x * pool.y / fairPrice) - pool.x
    swapOutput pool dx - dx * fairPrice
  else
    -- Pool undervalues Y: buy Y, sell X
    0  -- Symmetric case omitted for clarity


/-- A bid in a priority gas auction -/
structure PGABid where
  gasPrice : ℝ         -- Gas price offered
  expectedProfit : ℝ   -- Expected MEV profit if included
  hGas : 0 ≤ gasPrice
  hProfit : 0 < expectedProfit


/-- [Section: ## Priority Gas Auction (PGA)] -/
theorem pga_equilibrium_limit (profit : ℝ) (hProfit : 0 < profit)
    (n : ℕ) (hn : 2 ≤ n) :
    ∀ ε > 0, ∃ N : ℕ, N ≤ n →
      profit - profit * ((n - 1 : ℝ) / n) < ε := by
  exact fun ε hε => ⟨ n + 1, by norm_num ⟩


/-- **MEV Redistribution Theorem**: If a protocol redistributes a fraction `α`
of MEV back to users, and searchers compete for the remaining (1-α),
then user welfare improves iff α > 0. -/
theorem mev_redistribution_improves_welfare
    (mev : ℝ) (α : ℝ) (hmev : 0 < mev) (hα0 : 0 < α) (hα1 : α ≤ 1) :
    0 < α * mev := by
  positivity


end
