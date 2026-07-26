import Mathlib

/-! # CatalogBuild.Bridges.BerggrenStructure

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 20
-/

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

/-- [Section: # CatalogBuild.Bridges.BerggrenStructure
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 20] -/
theorem berggren_M1_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    let t := berggrenM1 a b c
    t.1^2 + t.2.1^2 = t.2.2^2 := by
  unfold berggrenM1; linarith;

/-- [Section: # CatalogBuild.Bridges.BerggrenStructure
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 20] -/
theorem berggren_M2_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    let t := berggrenM2 a b c
    t.1^2 + t.2.1^2 = t.2.2^2 := by
  unfold berggrenM2; linarith;

theorem berggren_M3_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    let t := berggrenM3 a b c
    t.1^2 + t.2.1^2 = t.2.2^2 := by
  unfold berggrenM3; linarith

theorem berggren_M1_quad_form (a b c : ℤ) :
    let t := berggrenM1 a b c
    t.1^2 + t.2.1^2 - t.2.2^2 = a^2 + b^2 - c^2 := by
  unfold berggrenM1; ring;

theorem berggren_M2_quad_form (a b c : ℤ) :
    let t := berggrenM2 a b c
    t.1^2 + t.2.1^2 - t.2.2^2 = a^2 + b^2 - c^2 := by
  unfold berggrenM2; ring;

theorem berggren_M3_quad_form (a b c : ℤ) :
    let t := berggrenM3 a b c
    t.1^2 + t.2.1^2 - t.2.2^2 = a^2 + b^2 - c^2 := by
  unfold berggrenM3; ring;

theorem berggren_M1_hyp_increase (a b c : ℤ)
    (h : a^2 + b^2 = c^2) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (berggrenM1 a b c).2.2 := by
  exact show c < 2 * a - 2 * b + 3 * c by nlinarith;

theorem berggren_M2_hyp_increase (a b c : ℤ)
    (h : a^2 + b^2 = c^2) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (berggrenM2 a b c).2.2 := by
  exact show c < 2 * a + 2 * b + 3 * c by linarith

theorem berggren_M3_hyp_increase (a b c : ℤ)
    (h : a^2 + b^2 = c^2) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (berggrenM3 a b c).2.2 := by
  unfold berggrenM3;
  nlinarith

theorem berggren_M2_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a^2 + b^2 = c^2) :
    let t := berggrenM2 a b c
    0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 := by
  exact ⟨ by unfold berggrenM2; linarith, by unfold berggrenM2; linarith, by unfold berggrenM2; linarith ⟩

theorem berggren_M1_sum (a b c : ℤ) :
    let t := berggrenM1 a b c
    t.1 + t.2.1 + t.2.2 = 5*a - 5*b + 7*c := by
  unfold berggrenM1; ring;

theorem berggren_M2_sum (a b c : ℤ) :
    let t := berggrenM2 a b c
    t.1 + t.2.1 + t.2.2 = 5*a + 5*b + 7*c := by
  unfold berggrenM2; ring;

theorem berggren_M3_sum (a b c : ℤ) :
    let t := berggrenM3 a b c
    t.1 + t.2.1 + t.2.2 = -5*a + 5*b + 7*c := by
  unfold berggrenM3; ring

theorem root_is_pythagorean : (3 : ℤ)^2 + 4^2 = 5^2 := by
  norm_num

theorem root_child_M1 : berggrenM1 3 4 5 = (5, 12, 13) := by
  rfl

theorem root_child_M2 : berggrenM2 3 4 5 = (21, 20, 29) := by
  -- By definition of berggrenM2, we have:
  simp [berggrenM2]

theorem root_child_M3 : berggrenM3 3 4 5 = (15, 8, 17) := by
  -- By definition of berggrenM3, we have:
  simp (config := { decide := true }) only [berggrenM3]

end