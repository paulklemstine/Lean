import Mathlib

/-! # CatalogBuild.Shared.Parent_hyp_lt

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3

The three inverse Barning–Hall matrices `invB1`, `invB2`, `invB3`, the predicate
`IsPT`, and the auxiliary positivity lemmas used by `parent_exists` were missing
from the catalog; they are supplied here so that the file elaborates.
-/

/-- `IsPT a b c` says that `(a, b, c)` is a Pythagorean triple. -/
def IsPT (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Inverse of the first Barning–Hall matrix
`!![1, -2, 2; 2, -1, 2; 2, -2, 3]`. -/
def invB1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2 * b - 2 * c, -2 * a - b + 2 * c, -2 * a - 2 * b + 3 * c)

/-- Inverse of the second Barning–Hall matrix
`!![1, 2, 2; 2, 1, 2; 2, 2, 3]`. -/
def invB2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2 * b - 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)

/-- Inverse of the third Barning–Hall matrix
`!![-1, 2, 2; -2, 1, 2; -2, 2, 3]`. -/
def invB3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a - 2 * b + 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)

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

/-- For a Pythagorean triple with positive legs, `a + 2b` and `2a + b` cannot both
be at most `2c`. -/
theorem not_both_neg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hpt : IsPT a b c)
    (h3 : a + 2 * b ≤ 2 * c) (h4 : 2 * a + b ≤ 2 * c) : False := by
  unfold IsPT at hpt
  have hc : 0 < c := by nlinarith
  have k1 : 4 * b ≤ 3 * a := by nlinarith
  have k2 : 4 * a ≤ 3 * b := by nlinarith
  nlinarith

/-- In the first branch of the descent the `invB1` parent has positive entries. -/
theorem invB1_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b < 2 * c) :
    0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2 := by
  refine ⟨by simp [invB1]; omega, by simp [invB1]; omega, ?_⟩
  simpa [invB1] using parent_hyp_pos a b c ha hb hc hpt

/-- In the second branch of the descent the `invB2` parent has positive entries. -/
theorem invB2_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b > 2 * c) :
    0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2 := by
  refine ⟨by simp [invB2]; omega, by simp [invB2]; omega, ?_⟩
  simpa [invB2] using parent_hyp_pos a b c ha hb hc hpt

/-- In the third branch of the descent the `invB3` parent has positive entries. -/
theorem invB3_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b < 2 * c) (h4 : 2 * a + b > 2 * c) :
    0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2 := by
  refine ⟨by simp [invB3]; omega, by simp [invB3]; omega, ?_⟩
  simpa [invB3] using parent_hyp_pos a b c ha hb hc hpt

/-- [Section: # CatalogBuild.Shared.Parent_hyp_lt
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 3] -/
theorem parent_exists (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : c > 5) (hprim : Int.gcd a b = 1) :
    (0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2) ∨
    (0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2) ∨
    (0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2) := by
  have hcop : IsCoprime a b := Int.isCoprime_iff_gcd_eq_one.mpr hprim
  by_cases h1 : a + 2 * b = 2 * c
  · -- `a + 2b = 2c` forces `3a = 4b`, hence `(a, b, c) = (4, 3, 5)`, contradicting `c > 5`.
    exfalso
    have heq : 3 * a = 4 * b := by unfold IsPT at hpt; nlinarith
    have hda : a ∣ 4 := hcop.dvd_of_dvd_mul_right ⟨3, by linarith⟩
    have hdb : b ∣ 3 := hcop.symm.dvd_of_dvd_mul_right ⟨4, by linarith⟩
    have ha4 : a ≤ 4 := Int.le_of_dvd (by norm_num) hda
    have hb3 : b ≤ 3 := Int.le_of_dvd (by norm_num) hdb
    omega
  · by_cases h2 : 2 * a + b = 2 * c
    · -- symmetrically, `2a + b = 2c` forces `(a, b, c) = (3, 4, 5)`.
      exfalso
      have heq : 3 * b = 4 * a := by unfold IsPT at hpt; nlinarith
      have hdb : b ∣ 4 := hcop.symm.dvd_of_dvd_mul_right ⟨3, by linarith⟩
      have hda : a ∣ 3 := hcop.dvd_of_dvd_mul_right ⟨4, by linarith⟩
      have hb4 : b ≤ 4 := Int.le_of_dvd (by norm_num) hdb
      have ha3 : a ≤ 3 := Int.le_of_dvd (by norm_num) hda
      omega
    · by_cases h3 : a + 2 * b > 2 * c <;> by_cases h4 : 2 * a + b > 2 * c
      · exact Or.inr <| Or.inl <| invB2_pos_case a b c ha hb hc hpt h3 h4
      · exact Or.inl <| invB1_pos_case a b c ha hb hc hpt h3
          (lt_of_le_of_ne (le_of_not_gt h4) h2)
      · exact Or.inr <| Or.inr <| invB3_pos_case a b c ha hb hc hpt
          (lt_of_le_of_ne (le_of_not_gt h3) h1) h4
      · exact False.elim <| not_both_neg a b c ha hb hpt (le_of_not_gt h3) (le_of_not_gt h4)