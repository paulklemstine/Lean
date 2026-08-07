import Mathlib

/-! # CatalogBuild.Shared.Parent_hyp_lt

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3

The definitions `IsPT`, `invB1`, `invB2`, `invB3` and the auxiliary positivity
lemmas were missing from the auto-generated file; they are supplied here so that
the module compiles.  `invB1`, `invB2`, `invB3` are the inverses of the three
Berggren (Barning–Hall) matrices

```
B1 = [[ 1,-2,2],[ 2,-1,2],[ 2,-2,3]]
B2 = [[ 1, 2,2],[ 2, 1,2],[ 2, 2,3]]
B3 = [[-1, 2,2],[-2, 1,2],[-2, 2,3]]
```

whose third coordinate is in every case the *parent hypotenuse* `3c - 2a - 2b`.
-/

/-- `IsPT a b c` says that `(a, b, c)` satisfies the Pythagorean relation. -/
def IsPT (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Inverse of the first Berggren matrix. -/
def invB1 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2 * b - 2 * c, -2 * a - b + 2 * c, -2 * a - 2 * b + 3 * c)

/-- Inverse of the second Berggren matrix. -/
def invB2 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2 * b - 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)

/-- Inverse of the third Berggren matrix. -/
def invB3 (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2 * b + 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)

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

/-- Each inverse Berggren map preserves the Pythagorean relation. -/
theorem isPT_invB1 (a b c : ℤ) (hpt : IsPT a b c) :
    IsPT (invB1 a b c).1 (invB1 a b c).2.1 (invB1 a b c).2.2 := by
  unfold IsPT invB1 at *
  linear_combination hpt

theorem isPT_invB2 (a b c : ℤ) (hpt : IsPT a b c) :
    IsPT (invB2 a b c).1 (invB2 a b c).2.1 (invB2 a b c).2.2 := by
  unfold IsPT invB2 at *
  linear_combination hpt

theorem isPT_invB3 (a b c : ℤ) (hpt : IsPT a b c) :
    IsPT (invB3 a b c).1 (invB3 a b c).2.1 (invB3 a b c).2.2 := by
  unfold IsPT invB3 at *
  linear_combination hpt

/-- Positivity of the first inverse branch. -/
theorem invB1_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b < 2 * c) :
    0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2 := by
  refine ⟨by simp only [invB1]; omega, by simp only [invB1]; omega, ?_⟩
  simpa [invB1] using parent_hyp_pos a b c ha hb hc hpt

/-- Positivity of the second inverse branch. -/
theorem invB2_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b > 2 * c) :
    0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2 := by
  refine ⟨by simp only [invB2]; omega, by simp only [invB2]; omega, ?_⟩
  simpa [invB2] using parent_hyp_pos a b c ha hb hc hpt

/-- Positivity of the third inverse branch. -/
theorem invB3_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b < 2 * c) (h4 : 2 * a + b > 2 * c) :
    0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2 := by
  refine ⟨by simp only [invB3]; omega, by simp only [invB3]; omega, ?_⟩
  simpa [invB3] using parent_hyp_pos a b c ha hb hc hpt

/-- For a Pythagorean triple with positive legs, `a + 2b` and `2a + b` cannot both be
at most `2c`: otherwise `4b ≤ 3a` and `4a ≤ 3b`, forcing `16ab ≤ 9ab`. -/
theorem not_both_neg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpt : IsPT a b c) (h3 : a + 2 * b ≤ 2 * c) (h4 : 2 * a + b ≤ 2 * c) : False := by
  unfold IsPT at hpt
  have hc : 0 < c := by nlinarith
  have k1 : 4 * b ≤ 3 * a := by nlinarith
  have k2 : 4 * a ≤ 3 * b := by nlinarith
  nlinarith

/-- If `a + 2b = 2c` for a primitive triple with `c > 5`, we get a contradiction:
the relation forces `3a = 4b`, hence `(a,b,c) = (4,3,5)`. -/
theorem no_eq_case_one (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : c > 5) (hprim : Int.gcd a b = 1)
    (h1 : a + 2 * b = 2 * c) : False := by
  unfold IsPT at hpt
  have h34 : 3 * a = 4 * b := by nlinarith
  have hcop : IsCoprime b a := (Int.isCoprime_iff_gcd_eq_one.mpr (by rwa [Int.gcd_comm]))
  have hbd : b ∣ 3 := hcop.dvd_of_dvd_mul_right ⟨4, by linarith⟩
  have hb3 : b ≤ 3 := Int.le_of_dvd (by norm_num) hbd
  interval_cases b <;> omega

/-- If `2a + b = 2c` for a primitive triple with `c > 5`, we get a contradiction:
the relation forces `3b = 4a`, hence `(a,b,c) = (3,4,5)`. -/
theorem no_eq_case_two (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : c > 5) (hprim : Int.gcd a b = 1)
    (h2 : 2 * a + b = 2 * c) : False := by
  unfold IsPT at hpt
  have h34 : 3 * b = 4 * a := by nlinarith
  have hcop : IsCoprime a b := Int.isCoprime_iff_gcd_eq_one.mpr hprim
  have had : a ∣ 3 := hcop.dvd_of_dvd_mul_right ⟨4, by linarith⟩
  have ha3 : a ≤ 3 := Int.le_of_dvd (by norm_num) had
  interval_cases a <;> omega

/-- [Section: # CatalogBuild.Shared.Parent_hyp_lt
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 3] -/
theorem parent_exists (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : c > 5) (hprim : Int.gcd a b = 1) :
    (0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2) ∨
    (0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2) ∨
    (0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2) := by
  have h1 : a + 2 * b ≠ 2 * c := fun h => no_eq_case_one a b c ha hb hc hpt hc5 hprim h
  have h2 : 2 * a + b ≠ 2 * c := fun h => no_eq_case_two a b c ha hb hc hpt hc5 hprim h
  rcases lt_or_gt_of_ne h1 with h3 | h3
  · rcases lt_or_gt_of_ne h2 with h4 | h4
    · exact (not_both_neg a b c ha hb hpt h3.le h4.le).elim
    · exact Or.inr (Or.inr (invB3_pos_case a b c ha hb hc hpt h3 h4))
  · rcases lt_or_gt_of_ne h2 with h4 | h4
    · exact Or.inl (invB1_pos_case a b c ha hb hc hpt h3 h4)
    · exact Or.inr (Or.inl (invB2_pos_case a b c ha hb hc hpt h3 h4))