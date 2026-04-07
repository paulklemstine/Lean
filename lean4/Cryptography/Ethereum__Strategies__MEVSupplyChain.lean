/-
  # MEV Supply Chain: Proposer-Builder Separation (PBS)
  ## Formal Verification of the Block Building Game

  Post-Merge Ethereum separates block building from block proposing.
  Builders compete to construct the most valuable block, and proposers
  select the highest-bidding builder.

  ### Key Results:
  - Builder competition drives bids toward full MEV value
  - Specialization is weakly beneficial
  - MEV-Share improves user welfare
  - Timing delays increase available MEV

  ### References:
  - "Proposer-Builder Separation" (Buterin, 2021)
  - "MEV-Boost" (Flashbots, 2022)
-/

import Mathlib

namespace Ethereum.MEVSupplyChain

structure Builder where
  efficiency : ℝ
  cost : ℝ
  hEff0 : 0 < efficiency
  hEff1 : efficiency ≤ 1
  hCost : 0 ≤ cost

noncomputable def builderProfit (b : Builder) (totalMEV bid : ℝ) : ℝ :=
  b.efficiency * totalMEV - b.cost - bid

/-
Builder 2 can outbid builder 1 if more efficient and has lower costs.
    The hypothesis h_cost_advantage ensures b₂'s net profit margin exceeds b₁'s.
-/
theorem competition_drives_bids (b₁ b₂ : Builder) (totalMEV : ℝ)
    (hMEV : 0 < totalMEV)
    (h_b2_better : b₂.efficiency > b₁.efficiency)
    (h_cost_advantage : b₂.efficiency * totalMEV - b₂.cost >
                        b₁.efficiency * totalMEV - b₁.cost) :
    ∃ bid₂ : ℝ, bid₂ > b₁.efficiency * totalMEV - b₁.cost ∧
               0 < builderProfit b₂ totalMEV bid₂ := by
  exact ⟨ ( b₁.efficiency * totalMEV - b₁.cost + b₂.efficiency * totalMEV - b₂.cost ) / 2, by linarith, by linarith [ show builderProfit b₂ totalMEV ( ( b₁.efficiency * totalMEV - b₁.cost + b₂.efficiency * totalMEV - b₂.cost ) / 2 ) = b₂.efficiency * totalMEV - b₂.cost - ( ( b₁.efficiency * totalMEV - b₁.cost + b₂.efficiency * totalMEV - b₂.cost ) / 2 ) by exact rfl ] ⟩

/-! ## Builder Specialization -/

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

/-
Specialization is weakly beneficial
-/
theorem specialization_beneficial (sb : SpecializedBuilder)
    (totalMEV : ℝ) (hMEV : 0 ≤ totalMEV) :
    generalCapture sb totalMEV ≤ specializedCapture sb totalMEV := by
  unfold generalCapture specializedCapture
  nlinarith [ mul_nonneg hMEV ( show 0 ≤ sb.specialtyFraction by linarith [ sb.hSpecFrac0 ] ), mul_nonneg hMEV ( show 0 ≤ sb.efficiency by linarith [ sb.hEff0 ] ),sb.hSpecEff, sb.hEff0, sb.hEff1 ]

/-! ## MEV-Share -/

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

/-! ## Relay Model -/

theorem multi_relay_correctness (bid₁ bid₂ : ℝ) :
    max bid₁ bid₂ ≥ bid₁ ∧ max bid₁ bid₂ ≥ bid₂ :=
  ⟨le_max_left _ _, le_max_right _ _⟩

/-! ## Timing Games -/

noncomputable def lateMevGain (baseMEV delayMs mevGrowthRate : ℝ) : ℝ :=
  baseMEV + delayMs * mevGrowthRate

theorem delay_increases_mev (baseMEV delayMs mevGrowthRate : ℝ)
    (hDelay : 0 < delayMs) (hGrowth : 0 < mevGrowthRate) :
    lateMevGain baseMEV delayMs mevGrowthRate > baseMEV := by
  unfold lateMevGain; linarith [mul_pos hDelay hGrowth]

end Ethereum.MEVSupplyChain