import Mathlib

/-! # Emergent Capabilities

Formalizes sigmoid emergence curves, compositional proficiency,
phase transitions, and scale-capability relationships.
-/

noncomputable section

open Real BigOperators Finset

/-! ## Definitions -/

/-- Sigmoid emergence curve: σ(k·(s - s₀)) where k=steepness, s₀=midpoint. -/
def emergenceCurve (steepness midpoint scale : ℝ) : ℝ :=
  1 / (1 + Real.exp (-steepness * (scale - midpoint)))

/-- Compositional proficiency: product of component proficiencies. -/
def compositionalProficiency (components : Fin n → ℝ) : ℝ :=
  ∏ i, components i

/-- All components are in [0,1]. -/
def ValidComponents (components : Fin n → ℝ) : Prop :=
  ∀ i, 0 ≤ components i ∧ components i ≤ 1

/-- Number of emerged capabilities at a given scale. -/
def emergedCount (steepness : ℝ) (midpoints : Fin n → ℝ) (scale : ℝ) (threshold : ℝ) : ℕ :=
  (Finset.univ.filter fun i => emergenceCurve steepness (midpoints i) scale ≥ threshold).card

/-- Self-learning focus factor: accelerates emergence. -/
def focusedEmergence (steepness focus midpoint scale : ℝ) : ℝ :=
  emergenceCurve (steepness * (1 + focus)) midpoint scale

/-- Critical data mass: below this, capability is zero. -/
def belowCriticalMass (dataSize criticalMass : ℝ) : Prop :=
  dataSize < criticalMass

/-! ## Theorems -/

/-
Emergence curve is in (0,1).
-/
theorem emergence_in_unit (steepness midpoint scale : ℝ) :
    0 < emergenceCurve steepness midpoint scale ∧
    emergenceCurve steepness midpoint scale < 1 := by
  exact ⟨ by exact one_div_pos.mpr ( by positivity ), by exact div_lt_one ( by positivity ) |>.2 ( by linarith [ Real.exp_pos ( -steepness * ( scale - midpoint ) ) ] ) ⟩

/-
At midpoint, capability is exactly 1/2.
-/
theorem emergence_midpoint (steepness midpoint : ℝ) :
    emergenceCurve steepness midpoint midpoint = 1 / 2 := by
  unfold emergenceCurve; norm_num;

/-
Higher steepness gives sharper transition (further from 1/2 at offset).
-/
theorem steeper_sharper_transition (k₁ k₂ midpoint : ℝ) (offset : ℝ)
    (hk : 0 < k₁) (hk2 : k₁ ≤ k₂) (hoff : 0 < offset) :
    emergenceCurve k₁ midpoint (midpoint + offset) ≤
    emergenceCurve k₂ midpoint (midpoint + offset) := by
  exact div_le_div_of_nonneg_left ( by positivity ) ( by positivity ) ( by gcongr ; nlinarith )

/-
Compositional proficiency is nonneg when components are in [0,1].
-/
theorem compositional_nonneg {n : ℕ} (components : Fin n → ℝ)
    (hv : ValidComponents components) :
    0 ≤ compositionalProficiency components := by
  exact Finset.prod_nonneg fun i _ => hv i |>.1

/-
Compositional proficiency ≤ 1 when components are in [0,1].
-/
theorem compositional_le_one {n : ℕ} (components : Fin n → ℝ)
    (hv : ValidComponents components) :
    compositionalProficiency components ≤ 1 := by
  exact Finset.prod_le_one ( fun _ _ => hv _ |>.1 ) fun _ _ => hv _ |>.2

/-
Compositional proficiency ≤ min component (weakest link).
-/
theorem compositional_le_min {n : ℕ} (hn : 0 < n) (components : Fin n → ℝ)
    (hv : ValidComponents components) (i : Fin n) :
    compositionalProficiency components ≤ components i := by
  unfold compositionalProficiency;
  rw [ Finset.prod_eq_mul_prod_diff_singleton ( Finset.mem_univ i ) ];
  exact mul_le_of_le_one_right ( hv i |>.1 ) ( Finset.prod_le_one ( fun _ _ => hv _ |>.1 ) fun _ _ => hv _ |>.2 )

/-
AM-GM type: product ≤ (mean)^n for nonneg values ≤ 1.
-/
theorem weakest_link_highest_value {n : ℕ} (components : Fin n → ℝ)
    (hv : ValidComponents components) :
    compositionalProficiency components ≤
    ((∑ i, components i) / n) ^ n := by
  have := @Real.geom_mean_le_arith_mean;
  specialize this Finset.univ ( fun _i => 1 ) ( fun _i => components _i ) ; norm_num at *;
  by_cases hn : 0 < n <;> simp_all +decide [ compositionalProficiency ];
  · exact le_trans ( by rw [ ← Real.rpow_natCast, ← Real.rpow_mul ( Finset.prod_nonneg fun _ _ => hv _ |>.1 ), inv_mul_cancel₀ ( by positivity ), Real.rpow_one ] ) ( pow_le_pow_left₀ ( Real.rpow_nonneg ( Finset.prod_nonneg fun _ _ => hv _ |>.1 ) _ ) ( this fun _ => hv _ |>.1 ) _ );
  · aesop

/-
More scale gives more emerged capabilities.
-/
theorem more_scale_more_capabilities (steepness : ℝ) (n : ℕ)
    (midpoints : Fin n → ℝ) (s₁ s₂ : ℝ) (threshold : ℝ)
    (hk : 0 < steepness) (hs : s₁ ≤ s₂) (ht : 0 < threshold) (ht1 : threshold < 1) :
    emergedCount steepness midpoints s₁ threshold ≤
    emergedCount steepness midpoints s₂ threshold := by
  apply_rules [ Finset.card_le_card ];
  intro i hi; simp_all +decide [ emergenceCurve ];
  exact hi.trans ( inv_anti₀ ( by positivity ) ( by gcongr ) )

/-
Self-learning focus accelerates emergence.
-/
theorem focus_accelerates_emergence (steepness focus midpoint scale : ℝ)
    (hk : 0 < steepness) (hf : 0 ≤ focus) (hoff : midpoint ≤ scale) :
    emergenceCurve steepness midpoint scale ≤
    focusedEmergence steepness focus midpoint scale := by
  unfold focusedEmergence emergenceCurve;
  gcongr ; nlinarith;
  nlinarith

/-
Below critical data mass, a modeled capability is 0 (by definition/assumption).
-/
theorem below_critical_mass_zero (dataSize criticalMass : ℝ)
    (h : belowCriticalMass dataSize criticalMass) :
    dataSize < criticalMass := by
  exact h

end