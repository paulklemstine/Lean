import Mathlib

/-! # CatalogBuild.Shared.Parent_hyp_lt

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3

Berggren / Barning–Hall tree of primitive Pythagorean triples.  The three
children of a triple `(a,b,c)` are obtained by the Barning matrices

```
B1 = !![1,-2,2; 2,-1,2; 2,-2,3]
B2 = !![1, 2,2; 2, 1,2; 2, 2,3]
B3 = !![-1,2,2; -2,1,2; -2,2,3]
```

and `invB1, invB2, invB3` below are the corresponding inverse (parent) maps.
-/

/-- `(a,b,c)` is a Pythagorean triple. -/
def IsPT (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Inverse of the first Barning matrix. -/
def invB1 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2 * b - 2 * c, -2 * a - b + 2 * c, -2 * a - 2 * b + 3 * c)

/-- Inverse of the second Barning matrix. -/
def invB2 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2 * b - 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)

/-- Inverse of the third Barning matrix. -/
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

/-- For a genuine triple with positive legs, the two "descent" inequalities cannot
both fail. -/
theorem not_both_neg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpt : IsPT a b c) (h3 : a + 2 * b ≤ 2 * c) (h4 : 2 * a + b ≤ 2 * c) : False := by
  unfold IsPT at hpt
  have hc : 0 < c := by omega
  have e1 : 4 * a * b ≤ 3 * a ^ 2 := by nlinarith
  have e2 : 4 * a * b ≤ 3 * b ^ 2 := by nlinarith
  have f1 : 4 * b ≤ 3 * a := by nlinarith
  have f2 : 4 * a ≤ 3 * b := by nlinarith
  nlinarith [mul_pos ha hb]

theorem invB1_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b < 2 * c) :
    0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2 := by
  have hp := parent_hyp_pos a b c ha hb hc hpt
  refine ⟨?_, ?_, ?_⟩ <;> simp only [invB1] <;> omega

theorem invB2_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b > 2 * c) :
    0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2 := by
  have hp := parent_hyp_pos a b c ha hb hc hpt
  refine ⟨?_, ?_, ?_⟩ <;> simp only [invB2] <;> omega

theorem invB3_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b < 2 * c) (h4 : 2 * a + b > 2 * c) :
    0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2 := by
  have hp := parent_hyp_pos a b c ha hb hc hpt
  refine ⟨?_, ?_, ?_⟩ <;> simp only [invB3] <;> omega

/-- [Section: # CatalogBuild.Shared.Parent_hyp_lt
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 3] -/
theorem parent_exists (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : c > 5) (hprim : Int.gcd a b = 1) :
    (0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2) ∨
    (0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2) ∨
    (0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2) := by
  by_cases h1 : a + 2 * b = 2 * c
  · -- `a + 2b = 2c` forces `3a = 4b`, hence `(a,b,c) = (4,3,5)`, contradicting `c > 5`.
    exfalso
    have hpt' : a ^ 2 + b ^ 2 = c ^ 2 := hpt
    have h_eq : 3 * a = 4 * b := by nlinarith
    obtain ⟨t, rfl, rfl⟩ : ∃ t : ℤ, a = 4 * t ∧ b = 3 * t := ⟨a / 4, by omega, by omega⟩
    have ht : t = 1 := by
      have hg : Int.gcd (4 * t) (3 * t) = t.natAbs := by
        rw [Int.gcd_mul_right]
        norm_num [Int.gcd]
      rw [hg] at hprim
      omega
    subst ht
    nlinarith
  · by_cases h2 : 2 * a + b = 2 * c
    · -- `2a + b = 2c` forces `3b = 4a`, hence `(a,b,c) = (3,4,5)`, contradicting `c > 5`.
      exfalso
      have hpt' : a ^ 2 + b ^ 2 = c ^ 2 := hpt
      have h_eq : 3 * b = 4 * a := by nlinarith
      obtain ⟨t, rfl, rfl⟩ : ∃ t : ℤ, a = 3 * t ∧ b = 4 * t := ⟨a / 3, by omega, by omega⟩
      have ht : t = 1 := by
        have hg : Int.gcd (3 * t) (4 * t) = t.natAbs := by
          rw [Int.gcd_mul_right]
          norm_num [Int.gcd]
        rw [hg] at hprim
        omega
      subst ht
      nlinarith
    · by_cases h3 : a + 2 * b > 2 * c <;> by_cases h4 : 2 * a + b > 2 * c
      · exact Or.inr (Or.inl (invB2_pos_case a b c ha hb hc hpt h3 h4))
      · exact Or.inl (invB1_pos_case a b c ha hb hc hpt h3
          (lt_of_le_of_ne (le_of_not_gt h4) h2))
      · exact Or.inr (Or.inr (invB3_pos_case a b c ha hb hc hpt
          (lt_of_le_of_ne (le_of_not_gt h3) h1) h4))
      · exact absurd (not_both_neg a b c ha hb hpt (le_of_not_gt h3) (le_of_not_gt h4))
          not_false