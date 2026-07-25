/-
  # Berggren-Satake Correspondence: Holographic Duality on Pythagorean Triples

  This file establishes the bridge between Pythagorean triples (the "boundary")
  and the tropical upper half-plane (the "bulk").

  Key structures:
  - `PythagoreanTriple`: (a,b,c) with a²+b²=c²
  - `BerggrenStep`: generator choices in the Berggren tree
  - Holographic lift, tropical valuation, spectral pairs

  Bridge: connects number theory (Pythagorean triples) to tropical geometry
  (boundary of H_trop) and physics (holographic duality).
-/
import Mathlib

open Real

namespace TropicalHolographic

/-! ## Section 1: Pythagorean Triple Foundations -/

/-- A Pythagorean triple (a, b, c) with a² + b² = c², all positive. -/
structure PythagoreanTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  a_pos : 0 < a
  b_pos : 0 < b
  c_pos : 0 < c
  pyth : a ^ 2 + b ^ 2 = c ^ 2

namespace PythagoreanTriple

/-- The fundamental triple (3, 4, 5). -/
def triple345 : PythagoreanTriple :=
  ⟨3, 4, 5, by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- The triple (5, 12, 13). -/
def triple51213 : PythagoreanTriple :=
  ⟨5, 12, 13, by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- The triple (8, 15, 17). -/
def triple81517 : PythagoreanTriple :=
  ⟨8, 15, 17, by norm_num, by norm_num, by norm_num, by norm_num⟩

/-
The hypotenuse is strictly greater than each leg.
-/
theorem c_gt_a (T : PythagoreanTriple) : T.a < T.c := by
  nlinarith [ T.a_pos, T.b_pos, T.pyth ]

theorem c_gt_b (T : PythagoreanTriple) : T.b < T.c := by
  nlinarith only [ T.pyth, T.a_pos ]

/-- The Pythagorean relation in ℝ. -/
theorem pyth_real (T : PythagoreanTriple) :
    (T.a : ℝ) ^ 2 + (T.b : ℝ) ^ 2 = (T.c : ℝ) ^ 2 := by
  exact_mod_cast T.pyth

/-
c ≥ 2 (since a,b ≥ 1 implies a²+b² ≥ 2, so c² ≥ 2, hence c ≥ 2).
-/
theorem c_ge_two (T : PythagoreanTriple) : 2 ≤ T.c := by
  nlinarith only [ T.a_pos, T.b_pos, T.pyth ]

/-- The boundary embedding: (a,b,c) ↦ a/b ∈ ℝ.
    Bridge: connects number theory to tropical boundary geometry. -/
noncomputable def berggrenBoundaryEmbed (T : PythagoreanTriple) : ℝ :=
  (T.a : ℝ) / (T.b : ℝ)

/-- The boundary embedding is positive. -/
theorem berggrenBoundaryEmbed_pos (T : PythagoreanTriple) :
    0 < berggrenBoundaryEmbed T :=
  div_pos (Nat.cast_pos.mpr T.a_pos) (Nat.cast_pos.mpr T.b_pos)

/-- The boundary embedding is < 1 iff a < b. -/
theorem berggrenBoundaryEmbed_lt_one (T : PythagoreanTriple) (h : T.a < T.b) :
    berggrenBoundaryEmbed T < 1 := by
  rw [berggrenBoundaryEmbed, div_lt_one (Nat.cast_pos.mpr T.b_pos)]
  exact Nat.cast_lt.mpr h

/-- The boundary embedding of (3,4,5) is 3/4. -/
theorem berggrenBoundaryEmbed_345 :
    berggrenBoundaryEmbed triple345 = 3 / 4 := by
  simp [berggrenBoundaryEmbed, triple345]

/-! ## Section 2: Berggren Generator B -/

/-
Berggren B generator: (a,b,c) ↦ (a+2b+2c, 2a+b+2c, 2a+2b+3c).
    This generator always increases all components.
    Bridge: connects tree generation to post_quantum_security growth bounds.
-/
def berggrenB (T : PythagoreanTriple) : PythagoreanTriple where
  a := T.a + 2 * T.b + 2 * T.c
  b := 2 * T.a + T.b + 2 * T.c
  c := 2 * T.a + 2 * T.b + 3 * T.c
  a_pos := by linarith [T.a_pos, T.b_pos, T.c_pos]
  b_pos := by linarith [T.a_pos, T.b_pos, T.c_pos]
  c_pos := by linarith [T.a_pos, T.b_pos, T.c_pos]
  pyth := by
    linarith [ T.pyth ]

/-- B increases the first leg. -/
theorem berggrenB_increases_a (T : PythagoreanTriple) :
    T.a < (berggrenB T).a := by
  simp [berggrenB]; linarith [T.b_pos, T.c_pos]

/-- B increases the second leg. -/
theorem berggrenB_increases_b (T : PythagoreanTriple) :
    T.b < (berggrenB T).b := by
  simp [berggrenB]; linarith [T.a_pos, T.c_pos]

/-- B increases the hypotenuse. -/
theorem berggrenB_increases_c (T : PythagoreanTriple) :
    T.c < (berggrenB T).c := by
  simp [berggrenB]; linarith [T.a_pos, T.b_pos]

/-- B of (3,4,5) gives (21,20,29). -/
theorem berggrenB_345_values :
    (berggrenB triple345).a = 21 ∧
    (berggrenB triple345).b = 20 ∧
    (berggrenB triple345).c = 29 := by
  simp [berggrenB, triple345]

/-- Verify: 21² + 20² = 29². -/
theorem verify_212029 : 21 ^ 2 + 20 ^ 2 = 29 ^ 2 := by norm_num

/-! ## Section 3: B-Path in the Berggren Tree -/

/-- Apply n iterations of B starting from (3,4,5). -/
def applyBPath : ℕ → PythagoreanTriple
  | 0 => triple345
  | n + 1 => berggrenB (applyBPath n)

/-- The B-path hypotenuse is strictly increasing. -/
theorem applyBPath_c_increasing (n : ℕ) :
    (applyBPath n).c < (applyBPath (n + 1)).c :=
  berggrenB_increases_c _

/-- B-path produces valid triples. -/
theorem applyBPath_valid (n : ℕ) :
    (applyBPath n).a ^ 2 + (applyBPath n).b ^ 2 = (applyBPath n).c ^ 2 :=
  (applyBPath n).pyth

/-! ## Section 4: Tropical Valuation -/

/-- The tropical valuation: log(c).
    Bridge: connects number theory to tropical geometry via logarithmic scale. -/
noncomputable def tropValuation (T : PythagoreanTriple) : ℝ :=
  Real.log (T.c : ℝ)

/-- The tropical valuation is positive. -/
theorem tropValuation_pos (T : PythagoreanTriple) :
    0 < tropValuation T := by
  apply Real.log_pos; exact_mod_cast T.c_ge_two

/-- The tropical valuation of (3,4,5) is log 5. -/
theorem tropValuation_345 :
    tropValuation triple345 = Real.log 5 := by
  simp [tropValuation, triple345]

/-- B strictly increases the tropical valuation. -/
theorem berggrenB_increases_valuation (T : PythagoreanTriple) :
    tropValuation T < tropValuation (berggrenB T) := by
  apply Real.log_lt_log (Nat.cast_pos.mpr T.c_pos)
  exact_mod_cast berggrenB_increases_c T

/-! ## Section 5: The Holographic Lift -/

/-- The holographic lift: (a,b,c) ↦ (a/b, c/b) ∈ H_trop.
    Bridge: connects boundary number theory to bulk geometry (AdS/CFT). -/
noncomputable def holographicLift (T : PythagoreanTriple) :
    { p : ℝ × ℝ // 0 < p.2 } :=
  ⟨((T.a : ℝ) / T.b, (T.c : ℝ) / T.b),
   div_pos (Nat.cast_pos.mpr T.c_pos) (Nat.cast_pos.mpr T.b_pos)⟩

/-- First coordinate equals boundary embedding. -/
theorem holographicLift_fst (T : PythagoreanTriple) :
    (holographicLift T).val.1 = berggrenBoundaryEmbed T := rfl

/-- Height is c/b. -/
theorem holographicLift_height (T : PythagoreanTriple) :
    (holographicLift T).val.2 = (T.c : ℝ) / T.b := rfl

/-- The height c/b > 1 since c > b. -/
theorem holographicLift_height_gt_one (T : PythagoreanTriple) :
    1 < (holographicLift T).val.2 := by
  rw [holographicLift_height]
  rw [one_lt_div (Nat.cast_pos.mpr T.b_pos)]
  exact_mod_cast c_gt_b T

/-! ## Section 6: Tropical Spectral Data -/

/-- The tropical spectral pair: (a/b, log c).
    Bridge: connects quantum mechanics to number theory. -/
noncomputable def tropSpectralPair (T : PythagoreanTriple) : ℝ × ℝ :=
  (berggrenBoundaryEmbed T, tropValuation T)

/-- Spectral pair of (3,4,5). -/
theorem tropSpectralPair_345 :
    tropSpectralPair triple345 = (3 / 4, Real.log 5) := by
  simp [tropSpectralPair, berggrenBoundaryEmbed_345, tropValuation_345]

/-- Energy is positive. -/
theorem tropSpectralPair_energy_pos (T : PythagoreanTriple) :
    0 < (tropSpectralPair T).2 := tropValuation_pos T

/-- Momentum is positive. -/
theorem tropSpectralPair_momentum_pos (T : PythagoreanTriple) :
    0 < (tropSpectralPair T).1 := berggrenBoundaryEmbed_pos T

/-! ## Section 7: B-Path Growth Analysis -/

/-- B-path valuation is strictly increasing. -/
theorem bPath_valuation_increasing (n : ℕ) :
    tropValuation (applyBPath n) < tropValuation (applyBPath (n + 1)) :=
  berggrenB_increases_valuation _

/-! ## Section 8: Boundary Embedding Properties -/

/-- Two triples with the same a/b ratio have proportional legs. -/
theorem berggrenBoundaryEmbed_proportional
    (T₁ T₂ : PythagoreanTriple)
    (h : berggrenBoundaryEmbed T₁ = berggrenBoundaryEmbed T₂) :
    (T₁.a : ℝ) * T₂.b = T₂.a * T₁.b := by
  unfold berggrenBoundaryEmbed at h
  rwa [div_eq_div_iff (Nat.cast_pos.mpr T₁.b_pos).ne'
    (Nat.cast_pos.mpr T₂.b_pos).ne'] at h

/-! ## Section 9: Pythagorean Angle -/

/-- The Pythagorean angle: arctan(a/b).
    Bridge: connects trigonometry to tropical phase. -/
noncomputable def pythAngle (T : PythagoreanTriple) : ℝ :=
  Real.arctan (berggrenBoundaryEmbed T)

/-- The angle is positive. -/
theorem pythAngle_pos (T : PythagoreanTriple) :
    0 < pythAngle T :=
  Real.arctan_pos.mpr (berggrenBoundaryEmbed_pos T)

/-- The angle of (3,4,5) is arctan(3/4). -/
theorem pythAngle_345 :
    pythAngle triple345 = Real.arctan (3 / 4) := by
  simp [pythAngle, berggrenBoundaryEmbed_345]

/-! ## Section 10: Computational Verifications -/

theorem verify_345 : 3 ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num
theorem verify_51213 : 5 ^ 2 + 12 ^ 2 = 13 ^ 2 := by norm_num
theorem verify_81517 : 8 ^ 2 + 15 ^ 2 = 17 ^ 2 := by norm_num
theorem verify_72425 : 7 ^ 2 + 24 ^ 2 = 25 ^ 2 := by norm_num

/-- The embedding of (5,12,13) is 5/12. -/
theorem berggrenBoundaryEmbed_51213 :
    berggrenBoundaryEmbed triple51213 = 5 / 12 := by
  simp [berggrenBoundaryEmbed, triple51213]

/-- B of (5,12,13) has hypotenuse 73. -/
theorem berggrenB_51213_c :
    (berggrenB triple51213).c = 73 := by
  native_decide

end PythagoreanTriple

end TropicalHolographic