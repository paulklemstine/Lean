import Mathlib

/-! # Auxiliary notions for the Berggren tree of Pythagorean triples

This module supplies the vocabulary used by the Berggren catalog files: the
predicate `IsPT` recording that `(a, b, c)` is a Pythagorean triple, the three
inverse Barning–Hall maps `invB1`, `invB2`, `invB3` (the inverses of the three
matrices generating the tree of primitive triples), and the sign analysis of
their components.

The three matrices generating the Berggren (Barning–Hall) tree are

```
A₁ = !![1, -2, 2; 2, -1, 2; 2, -2, 3]
A₂ = !![1,  2, 2; 2,  1, 2; 2,  2, 3]
A₃ = !![-1, 2, 2; -2, 1, 2; -2, 2, 3]
```

and `invB1`, `invB2`, `invB3` below are the linear maps given by `A₁⁻¹`, `A₂⁻¹`
and `A₃⁻¹`.  All three have the same last component `3c - 2a - 2b`, the
"parent hypotenuse".
-/

/-- `(a, b, c)` is a Pythagorean triple. -/
def IsPT (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The inverse of the first Berggren matrix, `A₁⁻¹ = !![1, 2, -2; -2, -1, 2; -2, -2, 3]`. -/
def invB1 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2 * b - 2 * c, -2 * a - b + 2 * c, -2 * a - 2 * b + 3 * c)

/-- The inverse of the second Berggren matrix, `A₂⁻¹ = !![1, 2, -2; 2, 1, -2; -2, -2, 3]`. -/
def invB2 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2 * b - 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)

/-- The inverse of the third Berggren matrix, `A₃⁻¹ = !![-1, -2, 2; 2, 1, -2; -2, -2, 3]`. -/
def invB3 (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2 * b + 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)

/-- The parent hypotenuse `3c - 2a - 2b` of a Pythagorean triple with positive legs and
positive hypotenuse is positive: the maximum of `2(a + b)/c` over the circle `a² + b² = c²`
is `2√2 < 3`. -/
theorem parent_hyp_pos_aux (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c) : 0 < -2 * a - 2 * b + 3 * c := by
  unfold IsPT at hpt
  nlinarith [sq_nonneg (3 * c - 2 * a - 2 * b), sq_nonneg (a - b), mul_pos ha hb]

/-- **The two "small" branches cannot both fail.**  For a Pythagorean triple with positive
legs, `a + 2b ≤ 2c` and `2a + b ≤ 2c` are incompatible: squaring the first gives `4b ≤ 3a`
and squaring the second gives `4a ≤ 3b`. -/
theorem not_both_neg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hpt : IsPT a b c)
    (h1 : a + 2 * b ≤ 2 * c) (h2 : 2 * a + b ≤ 2 * c) : False := by
  unfold IsPT at hpt
  have hc : 0 < c := by nlinarith
  have hb' : 4 * b ≤ 3 * a := by nlinarith
  have ha' : 4 * a ≤ 3 * b := by nlinarith
  nlinarith

/-- Positivity of the first inverse branch: it applies when `a + 2b > 2c` and `2a + b < 2c`. -/
theorem invB1_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hpt : IsPT a b c)
    (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b < 2 * c) :
    0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2 := by
  refine ⟨by simp only [invB1]; omega, by simp only [invB1]; omega, ?_⟩
  simpa [invB1] using parent_hyp_pos_aux a b c ha hb hc hpt

/-- Positivity of the second inverse branch: it applies when `a + 2b > 2c` and `2a + b > 2c`. -/
theorem invB2_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hpt : IsPT a b c)
    (h3 : a + 2 * b > 2 * c) (h4 : 2 * a + b > 2 * c) :
    0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2 := by
  refine ⟨by simp only [invB2]; omega, by simp only [invB2]; omega, ?_⟩
  simpa [invB2] using parent_hyp_pos_aux a b c ha hb hc hpt

/-- Positivity of the third inverse branch: it applies when `a + 2b < 2c` and `2a + b > 2c`. -/
theorem invB3_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hpt : IsPT a b c)
    (h3 : a + 2 * b < 2 * c) (h4 : 2 * a + b > 2 * c) :
    0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2 := by
  refine ⟨by simp only [invB3]; omega, by simp only [invB3]; omega, ?_⟩
  simpa [invB3] using parent_hyp_pos_aux a b c ha hb hc hpt