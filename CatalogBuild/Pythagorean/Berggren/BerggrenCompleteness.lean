/-! # CatalogBuild.Pythagorean.Berggren.BerggrenCompleteness

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 33
-/

import Mathlib

def invB1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

/-- Apply inverse Berggren B₂⁻¹ -/

def invB2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- Apply inverse Berggren B₃⁻¹ -/

def invB3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- Apply forward Berggren B₁ -/

def fwdB1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Apply forward Berggren B₂ -/

def fwdB2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Apply forward Berggren B₃ -/

def fwdB3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-! ## Forward-Inverse Cancellation -/


theorem invB1_fwdB1 (a b c : ℤ) :
    invB1 (fwdB1 a b c).1 (fwdB1 a b c).2.1 (fwdB1 a b c).2.2 = (a, b, c) := by
  unfold invB1 fwdB1; ext <;> simp <;> ring


theorem invB2_fwdB2 (a b c : ℤ) :
    invB2 (fwdB2 a b c).1 (fwdB2 a b c).2.1 (fwdB2 a b c).2.2 = (a, b, c) := by
  unfold invB2 fwdB2; ext <;> simp <;> ring


theorem invB3_fwdB3 (a b c : ℤ) :
    invB3 (fwdB3 a b c).1 (fwdB3 a b c).2.1 (fwdB3 a b c).2.2 = (a, b, c) := by
  unfold invB3 fwdB3; ext <;> simp <;> ring


theorem fwdB1_invB1 (a b c : ℤ) :
    fwdB1 (invB1 a b c).1 (invB1 a b c).2.1 (invB1 a b c).2.2 = (a, b, c) := by
  unfold invB1 fwdB1; ext <;> simp <;> ring


theorem fwdB2_invB2 (a b c : ℤ) :
    fwdB2 (invB2 a b c).1 (invB2 a b c).2.1 (invB2 a b c).2.2 = (a, b, c) := by
  unfold invB2 fwdB2; ext <;> simp <;> ring


theorem fwdB3_invB3 (a b c : ℤ) :
    fwdB3 (invB3 a b c).1 (invB3 a b c).2.1 (invB3 a b c).2.2 = (a, b, c) := by
  unfold invB3 fwdB3; ext <;> simp <;> ring

/-! ## Inverse transforms preserve the Pythagorean property -/


theorem invB1_preserves_pt (a b c : ℤ) (h : IsPT a b c) :
    IsPT (invB1 a b c).1 (invB1 a b c).2.1 (invB1 a b c).2.2 := by
  unfold IsPT invB1 at *; nlinarith [h, sq_nonneg a, sq_nonneg b, sq_nonneg c,
    sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c), sq_nonneg (b - c)]


theorem invB2_preserves_pt (a b c : ℤ) (h : IsPT a b c) :
    IsPT (invB2 a b c).1 (invB2 a b c).2.1 (invB2 a b c).2.2 := by
  unfold IsPT invB2 at *; nlinarith [h, sq_nonneg a, sq_nonneg b, sq_nonneg c,
    sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c), sq_nonneg (b - c)]


theorem invB3_preserves_pt (a b c : ℤ) (h : IsPT a b c) :
    IsPT (invB3 a b c).1 (invB3 a b c).2.1 (invB3 a b c).2.2 := by
  unfold IsPT invB3 at *; nlinarith [h, sq_nonneg a, sq_nonneg b, sq_nonneg c,
    sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c), sq_nonneg (b - c)]

/-! ## Parent Hypotenuse Properties -/

/-- The parent hypotenuse 3c - 2(a+b) is positive for any PPT with a,b,c > 0. -/

theorem invB1_invB2_first_eq (a b c : ℤ) :
    (invB1 a b c).1 = (invB2 a b c).1 := by
  unfold invB1 invB2; ring

/-- The first component of invB3 is the negation of invB1's first component -/

theorem invB3_neg_invB1_first (a b c : ℤ) :
    (invB3 a b c).1 = -(invB1 a b c).1 := by
  unfold invB1 invB3; ring

/-- The second component of invB1 is the negation of invB2's second component -/

theorem invB1_neg_invB2_second (a b c : ℤ) :
    (invB1 a b c).2.1 = -(invB2 a b c).2.1 := by
  unfold invB1 invB2; ring

/-- The second components of invB2 and invB3 are equal -/

theorem invB2_invB3_second_eq (a b c : ℤ) :
    (invB2 a b c).2.1 = (invB3 a b c).2.1 := by
  unfold invB2 invB3; ring

/-- All three inverse transforms share the same third component (hypotenuse) -/

theorem inv_same_hyp (a b c : ℤ) :
    (invB1 a b c).2.2 = (invB2 a b c).2.2 ∧
    (invB2 a b c).2.2 = (invB3 a b c).2.2 := by
  unfold invB1 invB2 invB3; exact ⟨rfl, rfl⟩

/-! ## Case Analysis for Parent Existence -/

/-- If a + 2b > 2c and 2a + b > 2c, then invB2 has all positive components -/

theorem invB2_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c)
    (h1 : a + 2*b > 2*c) (h2 : 2*a + b > 2*c) :
    0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2 := by
  refine ⟨?_, ?_, parent_hyp_pos a b c ha hb hc hpt⟩
  · show 0 < a + 2 * b - 2 * c; linarith
  · show 0 < 2 * a + b - 2 * c; linarith

/-- If a + 2b > 2c and 2a + b < 2c, then invB1 has all positive components -/

theorem invB1_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c)
    (h1 : a + 2*b > 2*c) (h2 : 2*a + b < 2*c) :
    0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2 := by
  refine ⟨?_, ?_, parent_hyp_pos a b c ha hb hc hpt⟩
  · show 0 < a + 2 * b - 2 * c; linarith
  · show 0 < -2 * a - b + 2 * c; linarith

/-- If a + 2b < 2c and 2a + b > 2c, then invB3 has all positive components -/

theorem invB3_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c)
    (h1 : a + 2*b < 2*c) (h2 : 2*a + b > 2*c) :
    0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2 := by
  refine ⟨?_, ?_, parent_hyp_pos a b c ha hb hc hpt⟩
  · show 0 < -a - 2 * b + 2 * c; linarith
  · show 0 < 2 * a + b - 2 * c; linarith

/-- The case 2a + b = 2c and a + 2b = 2c simultaneously is impossible for a PPT with a > 0 -/

theorem no_simultaneous_zero (a b c : ℤ) (ha : 0 < a)
    (hpt : IsPT a b c)
    (h1 : a + 2*b = 2*c) (h2 : 2*a + b = 2*c) : False := by
  unfold IsPT at hpt
  have hab : a = b := by linarith
  subst hab
  have h2eq : 2 * c = 3 * a := by linarith
  have h3 : (2*c)^2 = (3*a)^2 := by rw [h2eq]
  have h4 : 4 * c^2 = 9 * a^2 := by ring_nf at h3 ⊢; linarith
  have h5 : 4 * (2 * a^2) = 9 * a^2 := by linarith
  have h6 : a^2 = 0 := by linarith
  have ha0 : a = 0 := pow_eq_zero_iff (n := 2) (by omega) |>.mp h6
  linarith

/-- Both a+2b ≤ 2c and 2a+b ≤ 2c is impossible for a PPT with positive legs -/

theorem not_both_neg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpt : IsPT a b c)
    (h1 : a + 2*b ≤ 2*c) (h2 : 2*a + b ≤ 2*c) : False := by
  unfold IsPT at hpt
  nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b, sq_nonneg (a + b - c),
    sq_nonneg (2*a + b - 2*c), sq_nonneg (a + 2*b - 2*c)]

/-- For the root (3,4,5), no inverse branch gives all-positive components -/

theorem root_no_parent :
    ¬(0 < (invB1 3 4 5).1 ∧ 0 < (invB1 3 4 5).2.1 ∧ 0 < (invB1 3 4 5).2.2) ∧
    ¬(0 < (invB2 3 4 5).1 ∧ 0 < (invB2 3 4 5).2.1 ∧ 0 < (invB2 3 4 5).2.2) ∧
    ¬(0 < (invB3 3 4 5).1 ∧ 0 < (invB3 3 4 5).2.1 ∧ 0 < (invB3 3 4 5).2.2) := by
  simp only [invB1, invB2, invB3]; omega

/-
Main parent existence: for every PPT with a,b,c > 0 and c > 5 (non-root),
    at least one inverse transform produces all-positive components
-/

theorem descent_5_12_13 : invB1 5 12 13 = (3, 4, 5) := by
  unfold invB1; norm_num

/-- (21,20,29) descends to (3,4,5) via invB2 -/

theorem descent_21_20_29 : invB2 21 20 29 = (3, 4, 5) := by
  unfold invB2; norm_num

/-- (15,8,17) descends to (3,4,5) via invB3 -/

theorem descent_15_8_17 : invB3 15 8 17 = (3, 4, 5) := by
  unfold invB3; norm_num

/-- (7,24,25) descends to (5,12,13) via invB1 -/

theorem descent_7_24_25 : invB1 7 24 25 = (5, 12, 13) := by
  unfold invB1; norm_num

/-- Two-step descent: (7,24,25) → (5,12,13) → (3,4,5) -/

theorem descent_7_24_25_full :
    let t1 := invB1 7 24 25
    invB1 t1.1 t1.2.1 t1.2.2 = (3, 4, 5) := by
  unfold invB1; norm_num

/-- (9,40,41) descends via invB1 -/

theorem descent_9_40_41 : invB1 9 40 41 = (7, 24, 25) := by
  unfold invB1; norm_num

/-- (119,120,169) descends via invB2 -/

theorem descent_119_120_169 : invB2 119 120 169 = (21, 20, 29) := by
  unfold invB2; norm_num
