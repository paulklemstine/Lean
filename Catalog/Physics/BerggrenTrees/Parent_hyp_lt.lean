import Mathlib

/-! # CatalogBuild.Shared.Parent_hyp_lt

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3

Repaired: the Berggren-tree scaffolding used by `parent_exists` (the predicate
`IsPT`, the three inverse branch maps `invB1`, `invB2`, `invB3`, their
positivity lemmas and `not_both_neg`) was missing from the generated file and
has been supplied here, with full proofs.
-/

/-- A Pythagorean triple: `a² + b² = c²`. -/
abbrev IsPT (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Inverse of the first Berggren branch matrix. -/
def invB1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2 * b - 2 * c, -2 * a - b + 2 * c, -2 * a - 2 * b + 3 * c)

/-- Inverse of the second Berggren branch matrix. -/
def invB2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2 * b - 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)

/-- Inverse of the third Berggren branch matrix. -/
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

/-- For a genuine triple with positive legs, the two branch inequalities cannot
both fail: `a + 2b ≤ 2c` and `2a + b ≤ 2c` are contradictory. -/
theorem not_both_neg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hpt : IsPT a b c)
    (h3 : a + 2 * b ≤ 2 * c) (h4 : 2 * a + b ≤ 2 * c) : False := by
  unfold IsPT at hpt
  have hc : 0 < c := by nlinarith
  nlinarith [mul_pos ha hb, sq_nonneg (a - b), sq_nonneg (a + b)]

theorem invB1_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b < 2 * c) :
    0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2 := by
  refine ⟨by simp [invB1]; omega, by simp [invB1]; omega, ?_⟩
  simpa [invB1] using parent_hyp_pos a b c ha hb hc hpt

theorem invB2_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b > 2 * c) :
    0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2 := by
  refine ⟨by simp [invB2]; omega, by simp [invB2]; omega, ?_⟩
  simpa [invB2] using parent_hyp_pos a b c ha hb hc hpt

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
  by_cases h1 : a + 2 * b = 2 * c
  · -- If `a + 2b = 2c`, then `a² + b² = c²` forces `3a = 4b`, hence `(a,b,c)` is
    -- a multiple of `(4,3,5)`; primitivity then gives `c = 5`, contradicting `c > 5`.
    have h_eq : 3 * a = 4 * b := by
      unfold IsPT at hpt; nlinarith
    obtain ⟨k, rfl, rfl⟩ : ∃ k : ℤ, a = 4 * k ∧ b = 3 * k :=
      ⟨a / 4, by omega, by omega⟩
    simp_all +decide [Int.gcd_mul_right]
    grind
  · by_cases h2 : 2 * a + b = 2 * c
    · -- Symmetrically, `2a + b = 2c` forces `(a,b,c)` to be a multiple of `(3,4,5)`.
      obtain ⟨t, ht⟩ : ∃ t : ℤ, a = 3 * t ∧ b = 4 * t ∧ c = 5 * t := by
        use a / 3
        have h_eq : 3 * b = 4 * a := by
          nlinarith only [ha, hb, hc, h2, hpt.symm]
        omega
      simp_all +decide [Int.gcd_mul_right]
      grind
    · by_cases h3 : a + 2 * b > 2 * c <;> by_cases h4 : 2 * a + b > 2 * c
      · exact Or.inr <| Or.inl <| invB2_pos_case a b c ha hb hc hpt h3 h4
      · exact Or.inl <| invB1_pos_case a b c ha hb hc hpt h3 <|
          lt_of_le_of_ne (le_of_not_gt h4) h2
      · exact Or.inr <| Or.inr <| invB3_pos_case a b c ha hb hc hpt
          (lt_of_le_of_ne (le_of_not_gt h3) h1) h4
      · exact False.elim <| not_both_neg a b c ha hb hpt (le_of_not_gt h3) (le_of_not_gt h4)