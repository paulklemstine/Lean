/-! # CatalogBuild.Bridges.BerggrenStructure

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 20
-/

import Mathlib

noncomputable section

/-- Berggren transformation M₁ -/
def berggrenM1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren transformation M₂ -/

def berggrenM2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren transformation M₃ -/

def berggrenM3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-
M₁ preserves the Pythagorean relation a² + b² = c².
-/

theorem berggren_M1_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    let t := berggrenM1 a b c
    t.1^2 + t.2.1^2 = t.2.2^2 := by
  unfold berggrenM1; linarith;

/-
M₂ preserves the Pythagorean relation.
-/

theorem berggren_M2_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    let t := berggrenM2 a b c
    t.1^2 + t.2.1^2 = t.2.2^2 := by
  unfold berggrenM2; linarith;

/-
M₃ preserves the Pythagorean relation.
-/

theorem berggren_M3_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    let t := berggrenM3 a b c
    t.1^2 + t.2.1^2 = t.2.2^2 := by
  unfold berggrenM3; linarith

/-! ## Quadratic Form Invariance -/

/-
The quadratic form a² + b² - c² is invariant under M₁.
-/

theorem berggren_M1_quad_form (a b c : ℤ) :
    let t := berggrenM1 a b c
    t.1^2 + t.2.1^2 - t.2.2^2 = a^2 + b^2 - c^2 := by
  unfold berggrenM1; ring;

/-
The quadratic form a² + b² - c² is invariant under M₂.
-/

theorem berggren_M2_quad_form (a b c : ℤ) :
    let t := berggrenM2 a b c
    t.1^2 + t.2.1^2 - t.2.2^2 = a^2 + b^2 - c^2 := by
  unfold berggrenM2; ring;

/-
The quadratic form a² + b² - c² is invariant under M₃.
-/

theorem berggren_M3_quad_form (a b c : ℤ) :
    let t := berggrenM3 a b c
    t.1^2 + t.2.1^2 - t.2.2^2 = a^2 + b^2 - c^2 := by
  unfold berggrenM3; ring;

/-! ## Hypotenuse Growth -/

/-
Under M₁, when c > 0 and a² + b² = c², the hypotenuse strictly increases.
    Specifically, new_c = 2a - 2b + 3c. Since a,b < c for a Pythagorean triple
    with a,b > 0, we get new_c > c.
-/

theorem berggren_M1_hyp_increase (a b c : ℤ)
    (h : a^2 + b^2 = c^2) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (berggrenM1 a b c).2.2 := by
  exact show c < 2 * a - 2 * b + 3 * c by nlinarith;

/-
Under M₂, when a,b,c > 0 and a² + b² = c², the hypotenuse strictly increases.
-/

theorem berggren_M2_hyp_increase (a b c : ℤ)
    (h : a^2 + b^2 = c^2) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (berggrenM2 a b c).2.2 := by
  exact show c < 2 * a + 2 * b + 3 * c by linarith

/-
Under M₃, when a,b,c > 0 and a² + b² = c², the hypotenuse strictly increases.
-/

theorem berggren_M3_hyp_increase (a b c : ℤ)
    (h : a^2 + b^2 = c^2) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (berggrenM3 a b c).2.2 := by
  unfold berggrenM3;
  nlinarith

/-! ## Positivity -/

/-
M₂ preserves positivity of all three components.
-/

theorem berggren_M2_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a^2 + b^2 = c^2) :
    let t := berggrenM2 a b c
    0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 := by
  exact ⟨ by unfold berggrenM2; linarith, by unfold berggrenM2; linarith, by unfold berggrenM2; linarith ⟩

/-! ## Sum and Trace Identities -/

/-
The sum a + b + c is preserved modulo a specific multiple under each transformation.
    Under M₁: (a' + b' + c') = (a + b + c) + 2*(c - b) + 2*(c - a).
-/

theorem berggren_M1_sum (a b c : ℤ) :
    let t := berggrenM1 a b c
    t.1 + t.2.1 + t.2.2 = 5*a - 5*b + 7*c := by
  unfold berggrenM1; ring;

/-
Under M₂: the sum identity.
-/

theorem berggren_M2_sum (a b c : ℤ) :
    let t := berggrenM2 a b c
    t.1 + t.2.1 + t.2.2 = 5*a + 5*b + 7*c := by
  unfold berggrenM2; ring;

/-
Under M₃: the sum identity.
-/

theorem berggren_M3_sum (a b c : ℤ) :
    let t := berggrenM3 a b c
    t.1 + t.2.1 + t.2.2 = -5*a + 5*b + 7*c := by
  unfold berggrenM3; ring

/-! ## The Root Triple -/

/-
(3, 4, 5) is a Pythagorean triple.
-/

theorem root_is_pythagorean : (3 : ℤ)^2 + 4^2 = 5^2 := by
  norm_num

/-
The children of (3,4,5) under the three Berggren matrices.
-/

theorem root_child_M1 : berggrenM1 3 4 5 = (5, 12, 13) := by
  rfl


theorem root_child_M2 : berggrenM2 3 4 5 = (21, 20, 29) := by
  -- By definition of berggrenM2, we have:
  simp [berggrenM2]


theorem root_child_M3 : berggrenM3 3 4 5 = (15, 8, 17) := by
  -- By definition of berggrenM3, we have:
  simp (config := { decide := true }) only [berggrenM3]


end
