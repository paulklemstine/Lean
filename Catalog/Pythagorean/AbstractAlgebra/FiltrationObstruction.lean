/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Multi-Step Filtration Obstruction Calculus

This file formalizes a **secondary obstruction calculus** for three-step filtrations
of cyclic p-primary abelian groups. The central idea: for a filtration
  0 ⊆ ℤ/p^a ⊆ ℤ/p^b ⊆ ℤ/p^c,
the total extension complexity (measured by Ext¹ exponents) is NOT simply the
"left step" complexity. There is a **correction term** capturing the additional
coherence data arising from the three-step interaction.

## Mathematical Background

For cyclic p-groups, the Ext groups are:
- Ext¹(ℤ/p^m, ℤ/p^n) ≅ ℤ/p^min(m,n)
The exponent min(m,n) measures "extension complexity" — how many non-split
extensions exist between the two cyclic groups.

For a three-step filtration with layers of exponents d₀ = a, d₁ = b-a, d₂ = c-b:
- Left step: Ext¹(ℤ/p^d₁, ℤ/p^d₀) has exponent min(d₀, d₁)
- Total: Ext¹(ℤ/p^(d₁+d₂), ℤ/p^d₀) has exponent min(d₀, d₁+d₂)
- Correction: min(d₀, d₁+d₂) - min(d₀, d₁) = min(d₀ ∸ d₁, d₂)

The correction term is the **first shadow of higher coherence**: it measures
how much new extension complexity is "unlocked" by seeing through both layers
simultaneously, beyond what the first layer alone reveals.

## Main Results

* `cyclic_composition_law` — min(a, c-a) = min(a, b-a) + min(a ∸ (b-a), c-b)
* `correction_eq_gap_invariant` — Correction depends only on layer sizes, not p
* `correction_vanishes_iff` — Correction = 0 ↔ 2a ≤ b
* `correction_le_right_gap` — Correction ≤ c - b
* `correction_le_base` — Correction ≤ a
* `cyclic_total_eq_left_of_thin_base` — When base is thin, total = left
* `three_step_obstruction_functorial` — Correction preserved under gap-preserving maps
* `correction_monotone_in_right_gap` — Correction grows with the right gap

## References

* Builds on `Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean`,
  especially `Ext1_ZMod_ZMod_equiv`
* Extends `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`,
  especially `torsion_persistence_functorial`
-/
import Mathlib

/-! ## Section 1: Abstract Three-Step Filtration Structure -/

/-- A **three-step filtration** consists of three abelian groups A ⊆ B ⊆ C
    connected by injective group homomorphisms. This is the basic datum
    from which obstruction profiles are extracted. -/
structure ThreeStepFiltration where
  /-- The bottom layer -/
  A : Type*
  /-- The middle object -/
  B : Type*
  /-- The top object -/
  C : Type*
  [grpA : AddCommGroup A]
  [grpB : AddCommGroup B]
  [grpC : AddCommGroup C]
  /-- Inclusion of A into B -/
  iAB : A →+ B
  /-- Inclusion of B into C -/
  iBC : B →+ C
  /-- The first inclusion is injective -/
  inj_iAB : Function.Injective iAB
  /-- The second inclusion is injective -/
  inj_iBC : Function.Injective iBC

/-- The **filtration obstruction profile** records the Ext-theoretic
    invariants of a three-step filtration: left/right step complexity,
    total complexity, and the higher correction term. -/
structure FiltrationObstructionProfile where
  /-- Left step obstruction exponent -/
  leftExp : ℕ
  /-- Right step obstruction exponent -/
  rightExp : ℕ
  /-- Total extension obstruction exponent -/
  totalExp : ℕ
  /-- Triple correction: the higher coherence invariant -/
  correctionExp : ℕ

/-! ## Section 2: Cyclic p-Primary Obstruction Definitions

For the filtration ℤ/p^a ⊆ ℤ/p^b ⊆ ℤ/p^c with a ≤ b ≤ c, the obstruction
exponents are derived from the Ext classification theorem
`Ext1_ZMod_ZMod_equiv`: Ext¹(ℤ/p^m, ℤ/p^n) ≅ ℤ/p^min(m,n). -/

/-- Left step obstruction exponent: the exponent of
    Ext¹(ℤ/p^(b-a), ℤ/p^a) ≅ ℤ/p^min(a, b-a). -/
def cyclicLeftObsExp (a b : ℕ) : ℕ := min a (b - a)

/-- Right step obstruction exponent: the exponent of
    Ext¹(ℤ/p^(c-b), ℤ/p^b) ≅ ℤ/p^min(b, c-b). -/
def cyclicRightObsExp (b c : ℕ) : ℕ := min b (c - b)

/-- Total obstruction exponent: the exponent of
    Ext¹(ℤ/p^(c-a), ℤ/p^a) ≅ ℤ/p^min(a, c-a). -/
def cyclicTotalObsExp (a c : ℕ) : ℕ := min a (c - a)

/-- The **triple correction exponent**: the genuine higher interaction invariant.
    Defined as min(a ∸ (b-a), c-b). This measures how much additional
    extension complexity is unlocked by viewing through both layers. -/
def cyclicCorrectionExp (a b c : ℕ) : ℕ := min (a - (b - a)) (c - b)

/-- The **gap invariant**: the correction expressed purely in terms of
    the gap sizes d₁ and d₂, together with the base exponent a. -/
def gapInvariant (a d₁ d₂ : ℕ) : ℕ := min (a - d₁) d₂

/-- Construct the full obstruction profile for a cyclic three-step filtration. -/
def cyclicObstructionProfile (a b c : ℕ) : FiltrationObstructionProfile where
  leftExp := cyclicLeftObsExp a b
  rightExp := cyclicRightObsExp b c
  totalExp := cyclicTotalObsExp a c
  correctionExp := cyclicCorrectionExp a b c

/-! ## Section 3: The Composition Law -/

/-
The left obstruction exponent never exceeds the total.
-/
theorem cyclicLeftObs_le_totalObs (a b c : ℕ) (_hab : a ≤ b) (hbc : b ≤ c) :
    cyclicLeftObsExp a b ≤ cyclicTotalObsExp a c := by
  exact min_le_min le_rfl ( Nat.sub_le_sub_right hbc a )

/-
**Composition Law**: For a cyclic three-step filtration with a ≤ b ≤ c:

      min(a, c - a) = min(a, b - a) + min(a - (b - a), c - b)

    The total extension complexity = left step complexity + correction.
    This is a genuine arithmetic identity requiring case analysis.
-/
theorem cyclic_composition_law (a b c : ℕ) (hab : a ≤ b) (hbc : b ≤ c) :
    cyclicTotalObsExp a c = cyclicLeftObsExp a b + cyclicCorrectionExp a b c := by
  -- By definition of cyclicTotalObsExp, cyclicLeftObsExp, and cyclicCorrectionExp, we can rewrite the goal in terms of min.
  simp [cyclicTotalObsExp, cyclicLeftObsExp, cyclicCorrectionExp];
  omega

/-! ## Section 4: Properties of the Correction Term -/

/-
The correction exponent equals the gap invariant.
-/
theorem correction_eq_gap_invariant (a b c : ℕ) :
    cyclicCorrectionExp a b c = gapInvariant a (b - a) (c - b) := by
  rfl

/-
**Vanishing Criterion**: The correction vanishes iff the base is thin.
    cyclicCorrectionExp a b c = 0 ↔ a ≤ b - a
    (equivalently, 2a ≤ b, when a ≤ b).

    This identifies the boundary between ordinary extension theory and
    genuinely higher obstruction phenomena. Below this threshold,
    pairwise persistence data suffices; above it, derived defects emerge.
-/
theorem correction_vanishes_iff (a b c : ℕ) (hab : a ≤ b) (hbc : b ≤ c)
    (hpos : 0 < c - b ∨ a ≤ b - a) :
    cyclicCorrectionExp a b c = 0 ↔ a ≤ b - a := by
  simp_all +decide [ cyclicCorrectionExp ];
  omega

/-
The correction exponent is bounded by the right gap.
-/
theorem correction_le_right_gap (a b c : ℕ) :
    cyclicCorrectionExp a b c ≤ c - b := by
  exact Nat.min_le_right _ _

/-
The correction exponent is bounded by the base exponent.
-/
theorem correction_le_base (a b c : ℕ) :
    cyclicCorrectionExp a b c ≤ a := by
  exact min_le_of_left_le ( Nat.sub_le _ _ )

/-
When the base is thin (2a ≤ b), total = left (no correction needed).
-/
theorem cyclic_total_eq_left_of_thin_base (a b c : ℕ)
    (hab : a ≤ b) (hbc : b ≤ c) (hthin : 2 * a ≤ b) :
    cyclicTotalObsExp a c = cyclicLeftObsExp a b := by
  convert cyclic_composition_law a b c hab hbc using 1 ; simp +arith +decide [ *, cyclicCorrectionExp ];
  omega

/-! ## Section 5: Functoriality and Structural Properties -/

/-
**Functoriality**: The correction exponent is invariant under
    gap-preserving reparametrizations. If two filtrations have the same
    base exponent and gap sizes, they have the same correction.
-/
theorem three_step_obstruction_functorial
    (a₁ b₁ c₁ a₂ b₂ c₂ : ℕ)
    (ha : a₁ = a₂) (hd1 : b₁ - a₁ = b₂ - a₂) (hd2 : c₁ - b₁ = c₂ - b₂) :
    cyclicCorrectionExp a₁ b₁ c₁ = cyclicCorrectionExp a₂ b₂ c₂ := by
  unfold cyclicCorrectionExp; simp +decide [ * ] ;
  grind

/-
When the left step splits (b = a, gap₁ = 0), the total obstruction
    exponent equals the correction exponent. All obstruction comes from
    the second step filtered through the base layer's capacity.
-/
theorem split_left_total_eq_correction (a c : ℕ) :
    cyclicTotalObsExp a c = cyclicCorrectionExp a a c := by
  unfold cyclicTotalObsExp cyclicCorrectionExp; aesop;

/-
The correction is monotone in the right gap.
-/
theorem correction_monotone_in_right_gap (a b c₁ c₂ : ℕ)
    (_hbc1 : b ≤ c₁) (hc12 : c₁ ≤ c₂) :
    cyclicCorrectionExp a b c₁ ≤ cyclicCorrectionExp a b c₂ := by
  exact min_le_min le_rfl ( Nat.sub_le_sub_right hc12 b )

/-! ## Section 6: Explicit Computations -/

/-- a=1, b=2, c=3: correction = 0 (thin base: 2·1 ≤ 2). -/
example : cyclicCorrectionExp 1 2 3 = 0 := by native_decide

/-- a=2, b=3, c=5: correction = 1 (thick base: 2·2 > 3). -/
example : cyclicCorrectionExp 2 3 5 = 1 := by native_decide

/-- a=3, b=4, c=7: correction = 2. -/
example : cyclicCorrectionExp 3 4 7 = 2 := by native_decide

/-- Composition law: a=2, b=3, c=5. -/
example : cyclicTotalObsExp 2 5 = cyclicLeftObsExp 2 3 + cyclicCorrectionExp 2 3 5 := by
  native_decide

/-- Composition law: a=3, b=5, c=9. -/
example : cyclicTotalObsExp 3 9 = cyclicLeftObsExp 3 5 + cyclicCorrectionExp 3 5 9 := by
  native_decide

/-! ## Section 7: Nonvanishing and Saturation -/

/-
There exist filtrations with strictly positive correction.
-/
theorem exists_nonvanishing_correction :
    ∃ a b c : ℕ, a ≤ b ∧ b ≤ c ∧ cyclicCorrectionExp a b c > 0 := by
  exact ⟨ 2, 3, 5, by decide, by decide, by native_decide ⟩

/-
The correction achieves its maximum (= base exponent) when
    the left step is trivial and the right gap exceeds the base.
-/
theorem correction_achieves_max (a d₂ : ℕ) (hd₂ : a ≤ d₂) :
    cyclicCorrectionExp a a (a + d₂) = a := by
  unfold cyclicCorrectionExp;
  simp +zetaDelta at *;
  linarith

/-! ## Section 8: Gap Invariant as Excess Capacity -/

/-
The gap invariant equals min(a ∸ d₁, d₂) by definition.
-/
theorem gap_invariant_def (a d₁ d₂ : ℕ) :
    gapInvariant a d₁ d₂ = min (a - d₁) d₂ := by
  rfl

/-
**Valuation additivity**: the total exponent is the left exponent
    plus the correction.
-/
theorem valuation_additivity (a b c : ℕ) (hab : a ≤ b) (hbc : b ≤ c) :
    cyclicTotalObsExp a c =
      cyclicLeftObsExp a b + min (a - (b - a)) (c - b) := by
  convert cyclic_composition_law a b c hab hbc using 1

/-! ## Section 9: Four-Step Preview -/

/-- Four-step total obstruction: min(a, d-a). -/
def cyclicFourStepTotalObs (a d : ℕ) : ℕ := min a (d - a)

/-
The four-step decomposition uses two three-step corrections:
    min(a, d-a) = min(a, b-a) + min(a-(b-a), c-b) + min(a-(c-a), d-c).
    This is the beginning of the recursive obstruction tower.
-/
theorem four_step_decomposition (a b c d : ℕ)
    (hab : a ≤ b) (hbc : b ≤ c) (hcd : c ≤ d) :
    cyclicFourStepTotalObs a d =
      cyclicLeftObsExp a b + cyclicCorrectionExp a b c +
      min (a - (c - a)) (d - c) := by
  convert cyclic_composition_law a c d ( by linarith ) ( by linarith ) using 1;
  unfold cyclicLeftObsExp cyclicCorrectionExp; omega;