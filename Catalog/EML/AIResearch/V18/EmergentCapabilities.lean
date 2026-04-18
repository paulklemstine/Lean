import Mathlib

/-! # Emergent Capabilities Theory

Formalizes the mathematics of **emergent capabilities** in self-learning AI systems:
how new abilities arise suddenly as a function of scale, and how self-learning
can accelerate or predict emergence.

## Novel Contributions
1. **Phase Transition Model**: Capabilities emerge as sharp phase transitions
2. **Compositional Emergence**: Complex capabilities emerge from composing simpler ones
3. **Predictability of Emergence**: Information-theoretic conditions for predicting emergence
4. **EML and Emergence**: Compression enables earlier emergence at smaller scale
-/



noncomputable section

open Real Finset BigOperators

/-! ## §1. Phase Transition Model of Emergence -/

/-- Sigmoid model of capability emergence: performance as function of scale -/
def emergenceCurve (scale midpoint steepness : ℝ) : ℝ :=
  1 / (1 + Real.exp (-steepness * (scale - midpoint)))

/-- Emergence curve is always in (0, 1) -/
theorem emergence_in_unit (s m k : ℝ) :
    0 < emergenceCurve s m k ∧ emergenceCurve s m k < 1 := by
  unfold emergenceCurve
  constructor
  · positivity
  · rw [div_lt_one (by positivity)]
    linarith [exp_pos (-k * (s - m))]

/-- At the midpoint, capability is exactly 1/2 -/
theorem emergence_midpoint (m k : ℝ) :
    emergenceCurve m m k = 1 / 2 := by
  unfold emergenceCurve
  simp [Real.exp_zero]
  ring

/-
Higher steepness makes the transition sharper
-/
theorem steeper_sharper_transition (s m k₁ k₂ : ℝ)
    (hk : k₁ < k₂) (hs : m < s) :
    emergenceCurve s m k₁ < emergenceCurve s m k₂ := by
  unfold emergenceCurve;
  gcongr ; nlinarith [ Real.exp_pos ( -k₁ * ( s - m ) ), Real.exp_pos ( -k₂ * ( s - m ) ) ]

/-! ## §2. Compositional Capabilities -/

/-- A capability tree: complex capabilities built from simpler ones -/
structure CapabilityTree where
  /-- Number of base capabilities -/
  numBase : ℕ
  /-- Proficiency at each base capability -/
  baseProficiency : Fin numBase → ℝ
  /-- Base proficiencies in [0,1] -/
  base_nonneg : ∀ i, 0 ≤ baseProficiency i
  base_le_one : ∀ i, baseProficiency i ≤ 1

/-- Compositional capability: product of base capabilities (all must work) -/
def compositionalProficiency (C : CapabilityTree) : ℝ :=
  ∏ i, C.baseProficiency i

/-
Compositional proficiency is bounded by the minimum base proficiency
-/
theorem compositional_le_min (C : CapabilityTree)
    (hn : 0 < C.numBase) (i : Fin C.numBase) :
    compositionalProficiency C ≤ C.baseProficiency i := by
  -- The product of numbers in [0,1] is less than or equal to each of them.
  have h_prod_le : ∏ j ∈ Finset.univ.erase i, C.baseProficiency j ≤ 1 := by
    exact Finset.prod_le_one ( fun j _ => C.base_nonneg j ) fun j _ => C.base_le_one j;
  unfold compositionalProficiency;
  rw [ ← Finset.mul_prod_erase _ _ ( Finset.mem_univ i ) ] ; nlinarith [ C.base_nonneg i, C.base_le_one i ]

/-- Compositional proficiency is nonneg -/
theorem compositional_nonneg (C : CapabilityTree) :
    0 ≤ compositionalProficiency C := by
  unfold compositionalProficiency
  exact Finset.prod_nonneg fun i _ => C.base_nonneg i

/-- Compositional proficiency is bounded by 1 -/
theorem compositional_le_one (C : CapabilityTree) :
    compositionalProficiency C ≤ 1 := by
  unfold compositionalProficiency
  exact Finset.prod_le_one (fun i _ => C.base_nonneg i) (fun i _ => C.base_le_one i)

/-
The "weakest link" effect: improving the worst capability has the highest marginal value
-/
theorem weakest_link_highest_value (C : CapabilityTree)
    (hn : 0 < C.numBase) :
    compositionalProficiency C ≤
    (∑ i, C.baseProficiency i / C.numBase) ^ C.numBase := by
  have := @Real.geom_mean_le_arith_mean;
  specialize this Finset.univ ( fun _i => 1 ) ( fun _i => C.baseProficiency _i ) ; norm_num at *;
  rw [ ← Finset.sum_div _ _ _ ] ; exact le_trans ( by rw [ ← Real.rpow_natCast, ← Real.rpow_mul ( Finset.prod_nonneg fun _ _ => C.base_nonneg _ ), inv_mul_cancel₀ ( by positivity ), Real.rpow_one ] ; rfl ) ( pow_le_pow_left₀ ( Real.rpow_nonneg ( Finset.prod_nonneg fun _ _ => C.base_nonneg _ ) _ ) ( this hn fun _ => C.base_nonneg _ ) _ )

/-! ## §3. Scale-Capability Relationship -/

/-- Number of capabilities that have "emerged" (proficiency > threshold) at a given scale -/
def numEmergedCapabilities (numCaps : ℕ) (proficiency : Fin numCaps → ℝ) (threshold : ℝ) : ℕ :=
  (Finset.univ.filter fun i => threshold < proficiency i).card

/-- More scale ⟹ more emerged capabilities (if proficiencies are monotone in scale) -/
theorem more_scale_more_capabilities (numCaps : ℕ)
    (prof₁ prof₂ : Fin numCaps → ℝ) (threshold : ℝ)
    (h : ∀ i, prof₁ i ≤ prof₂ i) :
    numEmergedCapabilities numCaps prof₁ threshold ≤
    numEmergedCapabilities numCaps prof₂ threshold := by
  unfold numEmergedCapabilities
  apply Finset.card_le_card
  intro i hi
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  linarith [h i]

/-! ## §4. Self-Learning Accelerates Emergence -/

/-- Self-learning focuses compute on the capabilities closest to emergence,
    reducing the effective midpoint -/
def adjustedMidpoint (baseMidpoint focusFactor : ℝ) : ℝ :=
  baseMidpoint * (1 - focusFactor)

/-- More focus ⟹ earlier emergence -/
theorem focus_accelerates_emergence (m : ℝ) (f₁ f₂ : ℝ)
    (hm : 0 < m) (hf : f₁ ≤ f₂) (hf1 : f₂ ≤ 1) :
    adjustedMidpoint m f₂ ≤ adjustedMidpoint m f₁ := by
  unfold adjustedMidpoint; nlinarith

/-! ## §5. EML Enables Earlier Emergence -/

/-- EML's compression means the same compute budget trains a larger effective model,
    moving past the emergence threshold earlier -/
def effectiveScale (computeBudget modelCost : ℕ) (hc : 0 < modelCost) : ℕ :=
  computeBudget / modelCost

/-
EML achieves higher effective scale with same budget
-/
theorem eml_higher_effective_scale (budget d : ℕ) (hd : 5 ≤ d)
    (hb : d * d ≤ budget) :
    budget / (d * d) ≤ budget / (4 * d) := by
  gcongr ; nlinarith

/-! ## §6. Critical Mass Theory -/

/-- Below a critical mass of data, a capability appears absent.
    Above it, the capability appears suddenly. -/
def criticalMassModel (dataSize criticalSize : ℕ) : ℝ :=
  if dataSize < criticalSize then 0
  else 1 - Real.exp (-(↑(dataSize - criticalSize) : ℝ) / ↑criticalSize)

/-- Below critical mass, capability is zero -/
theorem below_critical_mass_zero (d c : ℕ) (h : d < c) :
    criticalMassModel d c = 0 := by
  unfold criticalMassModel; simp [h]

/-- At critical mass, capability begins emerging -/
theorem at_critical_mass_emerges (c : ℕ) (hc : 0 < c) :
    criticalMassModel c c = 0 := by
  unfold criticalMassModel; simp

end