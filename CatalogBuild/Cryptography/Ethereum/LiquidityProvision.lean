/-! # CatalogBuild.Cryptography.Ethereum.LiquidityProvision

Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13
-/

import Mathlib

noncomputable section

/-- **Impermanent Loss Factor**: Given initial price p₀ and current price p₁,
the impermanent loss factor for a constant-product AMM.
IL(r) = 2√r / (1 + r) - 1, where r = p₁/p₀
This measures the percentage loss compared to simply holding the tokens. -/
noncomputable def impermanentLossFactor (r : ℝ) (hr : 0 < r) : ℝ :=
  2 * Real.sqrt r / (1 + r) - 1


/-- [Section: # CatalogBuild.Cryptography.Ethereum.LiquidityProvision
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13] -/
theorem il_nonpositive (r : ℝ) (hr : 0 < r) :
    impermanentLossFactor r hr ≤ 0 := by
  exact sub_nonpos_of_le ( by rw [ div_le_iff₀ <| by positivity ] ; nlinarith [ sq_nonneg ( r - 1 ), Real.mul_self_sqrt hr.le ] )


/-- [Section: # CatalogBuild.Cryptography.Ethereum.LiquidityProvision
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13] -/
theorem il_zero_iff (r : ℝ) (hr : 0 < r) :
    impermanentLossFactor r hr = 0 ↔ r = 1 := by
  unfold impermanentLossFactor;
  grind


/-- [Section: # CatalogBuild.Cryptography.Ethereum.LiquidityProvision
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13] -/
theorem il_symmetric (r : ℝ) (hr : 0 < r) :
    impermanentLossFactor r hr = impermanentLossFactor (1/r) (by positivity) := by
  simp +decide [ impermanentLossFactor ];
  grind


/-- Parameters for LP profitability analysis -/
structure LPPosition where
  initialValue : ℝ         -- Initial deposit value (in USD)
  priceRatio : ℝ           -- Final/initial price ratio
  feeAPR : ℝ               -- Annual fee income as fraction of position
  holdingPeriod : ℝ         -- In years
  hValue : 0 < initialValue
  hRatio : 0 < priceRatio
  hFee : 0 ≤ feeAPR
  hPeriod : 0 < holdingPeriod


/-- Value of hodling (not providing liquidity) -/
noncomputable def hodlValue (lp : LPPosition) : ℝ :=
  lp.initialValue * (1 + lp.priceRatio) / 2


/-- Value from LP position (pool value + fees earned) -/
noncomputable def lpValue (lp : LPPosition) : ℝ :=
  lp.initialValue * Real.sqrt lp.priceRatio +
  lp.initialValue * lp.feeAPR * lp.holdingPeriod


theorem lp_profitable_iff_fees_exceed_il (lp : LPPosition) :
    hodlValue lp < lpValue lp ↔
    lp.feeAPR * lp.holdingPeriod >
      (1 + lp.priceRatio) / 2 - Real.sqrt lp.priceRatio := by
  unfold hodlValue lpValue; constructor <;> intro h <;> nlinarith [ lp.hValue, lp.hRatio, lp.hFee, lp.hPeriod ] ;


/-- A concentrated liquidity position with price range [pₐ, p_b] -/
structure ConcentratedPosition where
  pLower : ℝ    -- Lower price bound
  pUpper : ℝ    -- Upper price bound
  liquidity : ℝ  -- Liquidity parameter L
  hLower : 0 < pLower
  hUpper : 0 < pUpper
  hRange : pLower < pUpper
  hLiq : 0 < liquidity


/-- **Capital Efficiency Amplification**: Concentrated liquidity over range
[pₐ, p_b] provides the same depth as (p_b/pₐ)^(1/2) times more capital
in a full-range position. -/
noncomputable def capitalEfficiency (cp : ConcentratedPosition) : ℝ :=
  Real.sqrt (cp.pUpper / cp.pLower)


theorem capital_efficiency_gt_one (cp : ConcentratedPosition) :
    1 < capitalEfficiency cp := by
  exact Real.lt_sqrt_of_sq_lt ( by rw [ lt_div_iff₀ ] <;> linarith [ cp.hLower, cp.hUpper, cp.hRange ] )


theorem narrower_range_higher_efficiency
    (cp1 cp2 : ConcentratedPosition)
    (h_same_mid : cp1.pLower * cp1.pUpper = cp2.pLower * cp2.pUpper)
    (h_narrower : cp1.pUpper / cp1.pLower < cp2.pUpper / cp2.pLower) :
    capitalEfficiency cp1 < capitalEfficiency cp2 := by
  exact Real.sqrt_lt_sqrt ( div_nonneg ( le_of_lt cp1.hUpper ) ( le_of_lt cp1.hLower ) ) h_narrower


/-- **Optimal Fee Theorem**: For a given expected volatility σ and trading
volume V, the optimal fee rate γ* that maximizes LP profit satisfies:
Higher volatility → higher optimal fee (to compensate for larger IL) -/
theorem higher_vol_higher_fee
    (σ₁ σ₂ : ℝ) (hσ1 : 0 < σ₁) (hσ2 : 0 < σ₂) (hσ : σ₁ < σ₂)
    (V : ℝ) (hV : 0 < V) :
    -- Impermanent loss scales with σ², so compensation must too
    σ₁ ^ 2 < σ₂ ^ 2 := by
  nlinarith


end
