import Mathlib

/-! # CatalogBuild.Shared.Parent_hyp_lt

Berggren's tree of primitive Pythagorean triples: every primitive triple other
than `(3,4,5)` has a strictly smaller parent, obtained by one of the three
inverse Berggren maps `invB1`, `invB2`, `invB3`.

The original auto-generated source was truncated: it referenced `IsPT`, the
inverse Berggren maps and their positivity lemmas, none of which were emitted
(and none of which occur anywhere else in the catalog).  They are reconstructed
here with full proofs.
-/

namespace BerggrenTrees

/-- `IsPT a b c` says `(a, b, c)` is a Pythagorean triple. -/
def IsPT (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- First inverse Berggren map. -/
def invB1 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

/-- Second inverse Berggren map. -/
def invB2 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- Third inverse Berggren map. -/
def invB3 (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- The parent hypotenuse is strictly less than `c` for any PPT with `a, b > 0`. -/
theorem parent_hyp_lt (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpt : IsPT a b c) : -2*a - 2*b + 3*c < c := by
  unfold IsPT at hpt
  nlinarith [sq_nonneg (a + b - c), sq_nonneg (a - b)]

/-- The parent hypotenuse `3c - 2(a+b)` is positive for any PPT with `a, b, c > 0`. -/
theorem parent_hyp_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) : 0 < -2*a - 2*b + 3*c := by
  unfold IsPT at hpt
  nlinarith [sq_nonneg (3*c - 2*a - 2*b), sq_nonneg (a - b), mul_pos ha hb]

/-- For a Pythagorean triple with positive legs, `a + 2b` and `2a + b` cannot both
be at most `2c`: squaring gives `4b ≤ 3a` and `4a ≤ 3b`, hence `7ab ≤ 0`. -/
theorem not_both_neg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hpt : IsPT a b c)
    (h3 : a + 2 * b ≤ 2 * c) (h4 : 2 * a + b ≤ 2 * c) : False := by
  unfold IsPT at hpt
  have hc : 0 < c := by nlinarith
  have k1 : 4 * b ≤ 3 * a := by nlinarith
  have k2 : 4 * a ≤ 3 * b := by nlinarith
  nlinarith

/-- If `a + 2b > 2c` and `2a + b < 2c`, the first inverse map has positive entries. -/
theorem invB1_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b < 2 * c) :
    0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2 := by
  refine ⟨by simp only [invB1]; omega, by simp only [invB1]; omega, ?_⟩
  simpa [invB1] using parent_hyp_pos a b c ha hb hc hpt

/-- If `a + 2b > 2c` and `2a + b > 2c`, the second inverse map has positive entries. -/
theorem invB2_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b > 2 * c) :
    0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2 := by
  refine ⟨by simp only [invB2]; omega, by simp only [invB2]; omega, ?_⟩
  simpa [invB2] using parent_hyp_pos a b c ha hb hc hpt

/-- If `a + 2b < 2c` and `2a + b > 2c`, the third inverse map has positive entries. -/
theorem invB3_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (h3 : a + 2 * b < 2 * c) (h4 : 2 * a + b > 2 * c) :
    0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2 := by
  refine ⟨by simp only [invB3]; omega, by simp only [invB3]; omega, ?_⟩
  simpa [invB3] using parent_hyp_pos a b c ha hb hc hpt

/-- The boundary case `a + 2b = 2c` forces `(a,b,c) = (4,3,5)`, contradicting `c > 5`. -/
theorem no_boundary_case_one (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : c > 5) (hprim : Int.gcd a b = 1)
    (h1 : a + 2 * b = 2 * c) : False := by
  unfold IsPT at hpt
  have h_eq : 3 * a = 4 * b := by nlinarith
  obtain ⟨k, hak, hbk⟩ : ∃ k : ℤ, a = 4 * k ∧ b = 3 * k := ⟨a / 4, by omega, by omega⟩
  subst hak
  subst hbk
  have hg : Int.gcd (4 * k) (3 * k) = k.natAbs := by
    rw [show (4:ℤ) * k = k * 4 by ring, show (3:ℤ) * k = k * 3 by ring, Int.gcd_mul_left]
    norm_num [Int.gcd]
  rw [hg] at hprim
  have hk : k = 1 := by omega
  subst hk
  omega

/-- The boundary case `2a + b = 2c` forces `(a,b,c) = (3,4,5)`, contradicting `c > 5`. -/
theorem no_boundary_case_two (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : c > 5) (hprim : Int.gcd a b = 1)
    (h2 : 2 * a + b = 2 * c) : False := by
  unfold IsPT at hpt
  have h_eq : 3 * b = 4 * a := by nlinarith
  obtain ⟨t, hat, hbt⟩ : ∃ t : ℤ, a = 3 * t ∧ b = 4 * t := ⟨a / 3, by omega, by omega⟩
  subst hat
  subst hbt
  have hg : Int.gcd (3 * t) (4 * t) = t.natAbs := by
    rw [show (3:ℤ) * t = t * 3 by ring, show (4:ℤ) * t = t * 4 by ring, Int.gcd_mul_left]
    norm_num [Int.gcd]
  rw [hg] at hprim
  have ht : t = 1 := by omega
  subst ht
  omega

/-- **Berggren parent existence.** Every primitive Pythagorean triple with
hypotenuse `c > 5` admits a parent under one of the three inverse Berggren maps,
i.e. one of `invB1`, `invB2`, `invB3` produces a triple with all entries positive. -/
theorem parent_exists (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) (hc5 : c > 5) (hprim : Int.gcd a b = 1) :
    (0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2) ∨
    (0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2) ∨
    (0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2) := by
  by_cases h1 : a + 2 * b = 2 * c
  · exact absurd h1 fun h => no_boundary_case_one a b c ha hb hc hpt hc5 hprim h
  · by_cases h2 : 2 * a + b = 2 * c
    · exact absurd h2 fun h => no_boundary_case_two a b c ha hb hc hpt hc5 hprim h
    · by_cases h3 : a + 2 * b > 2 * c <;> by_cases h4 : 2 * a + b > 2 * c
      · exact Or.inr <| Or.inl <| invB2_pos_case a b c ha hb hc hpt h3 h4
      · exact Or.inl <| invB1_pos_case a b c ha hb hc hpt h3 <|
          lt_of_le_of_ne (le_of_not_gt h4) h2
      · exact Or.inr <| Or.inr <| invB3_pos_case a b c ha hb hc hpt
          (lt_of_le_of_ne (le_of_not_gt h3) h1) h4
      · exact False.elim <| not_both_neg a b c ha hb hpt (le_of_not_gt h3) (le_of_not_gt h4)

end BerggrenTrees