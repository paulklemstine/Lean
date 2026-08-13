import Mathlib

/-! # CatalogBuild.Shared.Parent_hyp_lt

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3

Repaired: the file used seven objects that were never declared anywhere in the
catalog — the Pythagorean predicate `IsPT`, the three inverse Berggren maps
`invB1`, `invB2`, `invB3`, their positivity lemmas and the exclusion lemma
`not_both_neg`.  They are supplied here (the maps are the inverses of the three
Berggren matrices `[[1,-2,2],[2,-1,2],[2,-2,3]]`, `[[1,2,2],[2,1,2],[2,2,3]]`,
`[[-1,2,2],[-2,1,2],[-2,2,3]]`), and `parent_exists` is proved from them.
-/

/-- `IsPT a b c` says that `(a, b, c)` satisfies the Pythagorean equation. -/
def IsPT (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The inverse of the first Berggren matrix. -/
def invB1 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

/-- The inverse of the second Berggren matrix. -/
def invB2 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- The inverse of the third Berggren matrix. -/
def invB3 (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- The parent hypotenuse is strictly less than c for any PPT with a,b > 0. -/
theorem parent_hyp_lt (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpt : IsPT a b c) : -2*a - 2*b + 3*c < c := by
  unfold IsPT at hpt
  nlinarith [sq_nonneg (a + b - c), sq_nonneg (a - b)]

/-- The parent hypotenuse 3c - 2(a+b) is positive for any PPT with a,b,c > 0. -/
theorem parent_hyp_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) : 0 < -2*a - 2*b + 3*c := by
  unfold IsPT at hpt
  nlinarith [sq_nonneg (3*c - 2*a - 2*b), sq_nonneg (a - b), mul_pos ha hb]

/-- If `a + 2b > 2c` and `2a + b < 2c` then the first inverse map is positive. -/
theorem invB1_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2*b > 2*c) (h4 : 2*a + b < 2*c) :
    0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2 := by
  refine ⟨by simp [invB1]; linarith, by simp [invB1]; linarith, ?_⟩
  simpa [invB1] using parent_hyp_pos a b c ha hb hc hpt

/-- If `a + 2b > 2c` and `2a + b > 2c` then the second inverse map is positive. -/
theorem invB2_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2*b > 2*c) (h4 : 2*a + b > 2*c) :
    0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2 := by
  refine ⟨by simp [invB2]; linarith, by simp [invB2]; linarith, ?_⟩
  simpa [invB2] using parent_hyp_pos a b c ha hb hc hpt

/-- If `a + 2b < 2c` and `2a + b > 2c` then the third inverse map is positive. -/
theorem invB3_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2*b < 2*c) (h4 : 2*a + b > 2*c) :
    0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2 := by
  refine ⟨by simp [invB3]; linarith, by simp [invB3]; linarith, ?_⟩
  simpa [invB3] using parent_hyp_pos a b c ha hb hc hpt

/-- The two Berggren inequalities cannot both fail: `a + 2b ≤ 2c` and
`2a + b ≤ 2c` are incompatible for a genuine Pythagorean triple. -/
theorem not_both_neg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpt : IsPT a b c) (h3 : a + 2*b ≤ 2*c) (h4 : 2*a + b ≤ 2*c) : False := by
  unfold IsPT at hpt
  have hc : 0 < c := by nlinarith
  nlinarith [mul_pos ha hb, sq_nonneg (a - b), sq_nonneg (a + b)]

/-- Every primitive Pythagorean triple with `c > 5` has a Berggren parent with
strictly positive entries. -/
theorem parent_exists (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : c > 5) (hprim : Int.gcd a b = 1) :
    (0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2) ∨
    (0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2) ∨
    (0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2) := by
  have hpt' : a ^ 2 + b ^ 2 = c ^ 2 := hpt
  by_cases h1 : a + 2 * b = 2 * c
  · -- this forces `(a, b, c) = (4, 3, 5)`, contradicting `c > 5`
    exfalso
    have h3a : 3 * a = 4 * b := by nlinarith
    have hda : a ∣ 4 := Int.dvd_of_dvd_mul_left_of_gcd_one ⟨3, by linarith⟩ hprim
    have hdb : b ∣ 3 :=
      Int.dvd_of_dvd_mul_left_of_gcd_one ⟨4, by linarith⟩ (Int.gcd_comm a b ▸ hprim)
    have ha4 : a ≤ 4 := Int.le_of_dvd (by norm_num) hda
    have hb3 : b ≤ 3 := Int.le_of_dvd (by norm_num) hdb
    interval_cases a <;> interval_cases b <;> omega
  · by_cases h2 : 2 * a + b = 2 * c
    · -- this forces `(a, b, c) = (3, 4, 5)`, contradicting `c > 5`
      exfalso
      have h3b : 3 * b = 4 * a := by nlinarith
      have hdb : b ∣ 4 :=
        Int.dvd_of_dvd_mul_left_of_gcd_one ⟨3, by linarith⟩ (Int.gcd_comm a b ▸ hprim)
      have hda : a ∣ 3 := Int.dvd_of_dvd_mul_left_of_gcd_one ⟨4, by linarith⟩ hprim
      have hb4 : b ≤ 4 := Int.le_of_dvd (by norm_num) hdb
      have ha3 : a ≤ 3 := Int.le_of_dvd (by norm_num) hda
      interval_cases a <;> interval_cases b <;> omega
    · by_cases h3 : a + 2 * b > 2 * c <;> by_cases h4 : 2 * a + b > 2 * c
      · exact Or.inr (Or.inl (invB2_pos_case a b c ha hb hc hpt h3 h4))
      · exact Or.inl (invB1_pos_case a b c ha hb hc hpt h3
          (lt_of_le_of_ne (le_of_not_gt h4) h2))
      · exact Or.inr (Or.inr (invB3_pos_case a b c ha hb hc hpt
          (lt_of_le_of_ne (le_of_not_gt h3) h1) h4))
      · exact absurd (not_both_neg a b c ha hb hpt (le_of_not_gt h3) (le_of_not_gt h4)) id