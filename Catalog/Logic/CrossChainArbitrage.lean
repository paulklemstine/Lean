import Mathlib

/-! # CatalogBuild.Cryptography.Ethereum.CrossChainArbitrage

Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13
-/

noncomputable section

/-- [Section: # CatalogBuild.Cryptography.Ethereum.CrossChainArbitrage
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13] -/
structure ChainPool where
  x : ℝ
  y : ℝ
  hx : 0 < x
  hy : 0 < y

/-- [Section: # CatalogBuild.Cryptography.Ethereum.CrossChainArbitrage
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13] -/
noncomputable def ChainPool.spotPrice (p : ChainPool) : ℝ := p.y / p.x

noncomputable def ChainPool.swapOut (p : ChainPool) (dx : ℝ) (hdx : 0 < dx) : ℝ :=
  p.y * dx / (p.x + dx)

structure BridgeParams where
  fee : ℝ
  latencyBlocks : ℕ
  hFee : 0 ≤ fee

noncomputable def crossChainProfit
    (poolA poolB : ChainPool)
    (bridge : BridgeParams)
    (dx : ℝ) (hdx : 0 < dx) : ℝ :=
  let dy := poolA.swapOut dx hdx
  let dy_after_fee := dy - bridge.fee
  dy_after_fee * (poolB.x / poolB.y) - dx

/-- No-arb band: with equal prices and positive bridge fee, no profit. -/
theorem no_arb_band (poolA poolB : ChainPool) (bridge : BridgeParams)
    (dx : ℝ) (hdx : 0 < dx)
    (h_prices : poolA.spotPrice = poolB.spotPrice)
    (h_fee_pos : 0 < bridge.fee) :
    crossChainProfit poolA poolB bridge dx hdx <
    crossChainProfit poolA poolB ⟨0, bridge.latencyBlocks, le_refl 0⟩ dx hdx := by
  unfold crossChainProfit
  simp only
  linarith [mul_pos h_fee_pos (div_pos poolB.hx poolB.hy)]

/-- Minimum price discrepancy needed for profitable arbitrage -/
noncomputable def minPriceDiscrepancy (bridge : BridgeParams) (tradeSize : ℝ) : ℝ :=
  bridge.fee / tradeSize

/-- Larger trades reduce the minimum discrepancy needed -/
theorem larger_trades_easier (bridge : BridgeParams) (d₁ d₂ : ℝ)
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂) (hle : d₁ ≤ d₂) :
    minPriceDiscrepancy bridge d₂ ≤ minPriceDiscrepancy bridge d₁ := by
  unfold minPriceDiscrepancy
  exact div_le_div_of_nonneg_left bridge.hFee hd₁ hle

noncomputable def priceGap (pA pB : ℝ) : ℝ := |pA - pB|

/-- Each arbitrage trade reduces the price gap -/
theorem arbitrage_reduces_gap (pA pB : ℝ) (hA : 0 < pA) (hB : 0 < pB)
    (hgap : pA < pB) (tradeImpact : ℝ) (ht : 0 < tradeImpact)
    (ht_bound : tradeImpact ≤ (pB - pA) / 2) :
    priceGap (pA + tradeImpact) (pB - tradeImpact) < priceGap pA pB := by
  unfold priceGap
  rw [abs_of_nonpos (by linarith : pA + tradeImpact - (pB - tradeImpact) ≤ 0),
      abs_of_neg (by linarith : pA - pB < 0)]
  linarith

theorem safe_arbitrage_condition (profit maxLoss : ℝ) (hprofit : 0 < profit)
    (hloss : 0 ≤ maxLoss) :
    0 < profit - maxLoss ↔ maxLoss < profit := by
  constructor <;> intro h <;> linarith

noncomputable def triangularProfit (rateAB rateBC rateCA : ℝ) (amount : ℝ) : ℝ :=
  amount * rateAB * rateBC * rateCA - amount

/-- Triangular arbitrage is profitable iff product of rates > 1 -/
theorem triangular_profitable_iff (rateAB rateBC rateCA amount : ℝ)
    (hamount : 0 < amount) :
    0 < triangularProfit rateAB rateBC rateCA amount ↔
    1 < rateAB * rateBC * rateCA := by
  unfold triangularProfit
  constructor <;> intro h <;> nlinarith

end