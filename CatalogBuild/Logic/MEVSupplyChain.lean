/-! # CatalogBuild.Logic.MEVSupplyChain

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Cryptography.Ethereum.MEVSupplyChain
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13] -/
structure Builder where
  efficiency : ℝ
  cost : ℝ
  hEff0 : 0 < efficiency
  hEff1 : efficiency ≤ 1
  hCost : 0 ≤ cost


/-- [Section: # CatalogBuild.Cryptography.Ethereum.MEVSupplyChain
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13] -/
noncomputable def builderProfit (b : Builder) (totalMEV bid : ℝ) : ℝ :=
  b.efficiency * totalMEV - b.cost - bid


/-- [Section: # CatalogBuild.Cryptography.Ethereum.MEVSupplyChain
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13] -/
theorem competition_drives_bids (b₁ b₂ : Builder) (totalMEV : ℝ)
    (hMEV : 0 < totalMEV)
    (h_b2_better : b₂.efficiency > b₁.efficiency)
    (h_cost_advantage : b₂.efficiency * totalMEV - b₂.cost >
                        b₁.efficiency * totalMEV - b₁.cost) :
    ∃ bid₂ : ℝ, bid₂ > b₁.efficiency * totalMEV - b₁.cost ∧
               0 < builderProfit b₂ totalMEV bid₂ := by
  exact ⟨ ( b₁.efficiency * totalMEV - b₁.cost + b₂.efficiency * totalMEV - b₂.cost ) / 2, by linarith, by linarith [ show builderProfit b₂ totalMEV ( ( b₁.efficiency * totalMEV - b₁.cost + b₂.efficiency * totalMEV - b₂.cost ) / 2 ) = b₂.efficiency * totalMEV - b₂.cost - ( ( b₁.efficiency * totalMEV - b₁.cost + b₂.efficiency * totalMEV - b₂.cost ) / 2 ) by exact rfl ] ⟩


structure SpecializedBuilder extends Builder where
  specialtyFraction : ℝ
  specialtyEfficiency : ℝ
  hSpecFrac0 : 0 ≤ specialtyFraction
  hSpecFrac1 : specialtyFraction ≤ 1
  hSpecEff : efficiency ≤ specialtyEfficiency
  hSpecEff1 : specialtyEfficiency ≤ 1


noncomputable def specializedCapture (sb : SpecializedBuilder) (totalMEV : ℝ) : ℝ :=
  sb.specialtyEfficiency * sb.specialtyFraction * totalMEV +
  sb.efficiency * (1 - sb.specialtyFraction) * totalMEV


noncomputable def generalCapture (sb : SpecializedBuilder) (totalMEV : ℝ) : ℝ :=
  sb.efficiency * totalMEV


theorem specialization_beneficial (sb : SpecializedBuilder)
    (totalMEV : ℝ) (hMEV : 0 ≤ totalMEV) :
    generalCapture sb totalMEV ≤ specializedCapture sb totalMEV := by
  unfold generalCapture specializedCapture
  nlinarith [ mul_nonneg hMEV ( show 0 ≤ sb.specialtyFraction by linarith [ sb.hSpecFrac0 ] ), mul_nonneg hMEV ( show 0 ≤ sb.efficiency by linarith [ sb.hEff0 ] ),sb.hSpecEff, sb.hEff0, sb.hEff1 ]


noncomputable def mevShareUserReturn (totalMEV userShare : ℝ) : ℝ :=
  userShare * totalMEV


theorem mev_share_improves_welfare (totalMEV userShare : ℝ)
    (hMEV : 0 < totalMEV) (hShare0 : 0 < userShare) :
    0 < mevShareUserReturn totalMEV userShare := by
  unfold mevShareUserReturn; exact mul_pos hShare0 hMEV


theorem mev_share_tradeoff (totalMEV s₁ s₂ : ℝ)
    (hMEV : 0 < totalMEV) (hle : s₁ ≤ s₂) :
    (1 - s₂) * totalMEV ≤ (1 - s₁) * totalMEV := by
  nlinarith


theorem multi_relay_correctness (bid₁ bid₂ : ℝ) :
    max bid₁ bid₂ ≥ bid₁ ∧ max bid₁ bid₂ ≥ bid₂ :=
  ⟨le_max_left _ _, le_max_right _ _⟩


noncomputable def lateMevGain (baseMEV delayMs mevGrowthRate : ℝ) : ℝ :=
  baseMEV + delayMs * mevGrowthRate


theorem delay_increases_mev (baseMEV delayMs mevGrowthRate : ℝ)
    (hDelay : 0 < delayMs) (hGrowth : 0 < mevGrowthRate) :
    lateMevGain baseMEV delayMs mevGrowthRate > baseMEV := by
  unfold lateMevGain; linarith [mul_pos hDelay hGrowth]


end
