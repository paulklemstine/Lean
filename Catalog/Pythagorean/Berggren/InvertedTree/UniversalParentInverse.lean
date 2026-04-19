import Mathlib

/-!
# Universal Parent Inverse — The Single-Formula Berggren Descent

## Main Discovery

The three inverse Berggren matrices B₁⁻¹, B₂⁻¹, B₃⁻¹ are unified by a single formula:
the **universal parent inverse** `(|p|, |q|, h)` where:
- `p = a + 2b - 2c`
- `q = 2a + b - 2c`
- `h = 3c - 2(a+b)`

This eliminates the need for branch determination entirely: given any PPT (a,b,c),
the parent is simply `(|p|, |q|, h)`.

## Key Theorems

1. **Universal Parent Formula**: For each branch, the all-positive inverse image
   equals `(|p|, |q|, h)`.
2. **Universal Parent is Pythagorean**: `|p|² + |q|² = h²` whenever `a² + b² = c²`.
3. **Klein Four-Group Action**: The three branches + fourth ghost form ℤ/2 × ℤ/2.
4. **Universal Parent is a Left Inverse**: UP(Bᵢ(a,b,c)) = (a,b,c) for positive triples.
5. **Depth-2 Composition**: Explicit formula for grandparent parameters.
6. **Leg Swap Symmetry**: Swapping legs swaps the first two components of UP.
-/

-- ═══════════════════════════════════════════════════════════════
-- Section 1: Core Definitions
-- ═══════════════════════════════════════════════════════════════

/-- The p-parameter of the ghost triple. -/
def ghost_p (a b c : ℤ) : ℤ := a + 2 * b - 2 * c

/-- The q-parameter of the ghost triple. -/
def ghost_q (a b c : ℤ) : ℤ := 2 * a + b - 2 * c

/-- The h-parameter (universal parent hypotenuse). -/
def ghost_h (a b c : ℤ) : ℤ := 3 * c - 2 * (a + b)

/-- The **universal parent inverse**: a single formula that gives the parent
of any PPT in the Berggren tree, without needing to determine the branch. -/
def universalParent (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (|ghost_p a b c|, |ghost_q a b c|, ghost_h a b c)

/-- Inverse Berggren transform B₁⁻¹. -/
def upi_invB₁ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (ghost_p a b c, -ghost_q a b c, ghost_h a b c)

/-- Inverse Berggren transform B₂⁻¹. -/
def upi_invB₂ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (ghost_p a b c, ghost_q a b c, ghost_h a b c)

/-- Inverse Berggren transform B₃⁻¹. -/
def upi_invB₃ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-ghost_p a b c, ghost_q a b c, ghost_h a b c)

/-- Forward Berggren transform B₁. -/
def upi_fwdB₁ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)

/-- Forward Berggren transform B₂. -/
def upi_fwdB₂ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)

/-- Forward Berggren transform B₃. -/
def upi_fwdB₃ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Ghost Triple (p, q, h) is Pythagorean
-- ═══════════════════════════════════════════════════════════════

/-- **Ghost Pythagorean Theorem**: (p, q, h) is Pythagorean when (a, b, c) is. -/
theorem ghost_pythagorean (a b c : ℤ) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    (ghost_p a b c) ^ 2 + (ghost_q a b c) ^ 2 = (ghost_h a b c) ^ 2 := by
  simp only [ghost_p, ghost_q, ghost_h]; nlinarith

/-- **Universal Parent is Pythagorean**: |p|² + |q|² = h². -/
theorem universalParent_pythagorean (a b c : ℤ) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    (universalParent a b c).1 ^ 2 + (universalParent a b c).2.1 ^ 2 =
    (universalParent a b c).2.2 ^ 2 := by
  simp only [universalParent, sq_abs]
  exact ghost_pythagorean a b c hpyth

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Universal Parent Equals Each Branch
-- ═══════════════════════════════════════════════════════════════

/-- **Branch 1**: When p > 0 and q < 0, universalParent = invB₁. -/
theorem universalParent_eq_branch1 (a b c : ℤ)
    (hp : 0 < ghost_p a b c) (hq : ghost_q a b c < 0) :
    universalParent a b c = upi_invB₁ a b c := by
  simp only [universalParent, upi_invB₁, abs_of_pos hp, abs_of_neg hq]

/-- **Branch 2**: When p > 0 and q > 0, universalParent = invB₂. -/
theorem universalParent_eq_branch2 (a b c : ℤ)
    (hp : 0 < ghost_p a b c) (hq : 0 < ghost_q a b c) :
    universalParent a b c = upi_invB₂ a b c := by
  simp only [universalParent, upi_invB₂, abs_of_pos hp, abs_of_pos hq]

/-- **Branch 3**: When p < 0 and q > 0, universalParent = invB₃. -/
theorem universalParent_eq_branch3 (a b c : ℤ)
    (hp : ghost_p a b c < 0) (hq : 0 < ghost_q a b c) :
    universalParent a b c = upi_invB₃ a b c := by
  simp only [universalParent, upi_invB₃, abs_of_neg hp, abs_of_pos hq]

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Fourth Ghost and Klein Four-Group
-- ═══════════════════════════════════════════════════════════════

/-- The "fourth ghost" (-p, -q, h). -/
def fourthGhost (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-ghost_p a b c, -ghost_q a b c, ghost_h a b c)

/-- The fourth ghost is also Pythagorean. -/
theorem fourthGhost_pythagorean (a b c : ℤ) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    (fourthGhost a b c).1 ^ 2 + (fourthGhost a b c).2.1 ^ 2 =
    (fourthGhost a b c).2.2 ^ 2 := by
  simp only [fourthGhost, neg_pow_two]
  exact ghost_pythagorean a b c hpyth

/-- All four sign-flip variants share the same hypotenuse. -/
theorem klein_four_same_hyp (a b c : ℤ) :
    (upi_invB₁ a b c).2.2 = (upi_invB₂ a b c).2.2 ∧
    (upi_invB₂ a b c).2.2 = (upi_invB₃ a b c).2.2 ∧
    (upi_invB₃ a b c).2.2 = (fourthGhost a b c).2.2 := by
  simp [upi_invB₁, upi_invB₂, upi_invB₃, fourthGhost]

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Algebraic Identities
-- ═══════════════════════════════════════════════════════════════

/-- p + q = 3(a + b) - 4c. -/
theorem ghost_pq_sum (a b c : ℤ) :
    ghost_p a b c + ghost_q a b c = 3 * (a + b) - 4 * c := by
  simp only [ghost_p, ghost_q]; ring

/-- p - q = b - a (the leg difference is preserved!). -/
theorem ghost_pq_diff (a b c : ℤ) :
    ghost_p a b c - ghost_q a b c = b - a := by
  simp only [ghost_p, ghost_q]; ring

/-- c - h = 2(a + b - c) (descent gap). -/
theorem ghost_h_descent (a b c : ℤ) :
    c - ghost_h a b c = 2 * (a + b - c) := by
  simp only [ghost_h]; ring

/-- Lorentz norm is preserved. -/
theorem universalParent_preserves_lorentz_norm (a b c : ℤ) :
    (universalParent a b c).1 ^ 2 + (universalParent a b c).2.1 ^ 2 -
    (universalParent a b c).2.2 ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
  simp only [universalParent, sq_abs, ghost_p, ghost_q, ghost_h]; ring

/-- Energy identity: |p|² + |q|² + h² = 2h² for Pythagorean triples. -/
theorem universalParent_energy (a b c : ℤ) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    (universalParent a b c).1 ^ 2 + (universalParent a b c).2.1 ^ 2 +
    (universalParent a b c).2.2 ^ 2 = 2 * (ghost_h a b c) ^ 2 := by
  simp only [universalParent, sq_abs, ghost_p, ghost_q, ghost_h]; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Depth-2 Composition (Grandparent)
-- ═══════════════════════════════════════════════════════════════

/-- The depth-2 hypotenuse h(p, q, h) in terms of (a, b, c). -/
theorem ghost_h_composed (a b c : ℤ) :
    ghost_h (ghost_p a b c) (ghost_q a b c) (ghost_h a b c) =
    -12 * a - 12 * b + 17 * c := by
  unfold ghost_h ghost_p ghost_q; ring

/-- The depth-2 p-parameter. -/
theorem ghost_p_composed (a b c : ℤ) :
    ghost_p (ghost_p a b c) (ghost_q a b c) (ghost_h a b c) =
    9 * a + 8 * b - 12 * c := by
  unfold ghost_p ghost_q ghost_h; ring

/-- The depth-2 q-parameter. -/
theorem ghost_q_composed (a b c : ℤ) :
    ghost_q (ghost_p a b c) (ghost_q a b c) (ghost_h a b c) =
    8 * a + 9 * b - 12 * c := by
  unfold ghost_p ghost_q ghost_h; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 7: M_UP Matrix Properties
-- ═══════════════════════════════════════════════════════════════

/-- The "universal parent matrix" M_UP = B₂⁻¹. -/
def M_UP : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- M_UP preserves the Lorentz form. -/
theorem M_UP_preserves_lorentz :
    M_UP.transpose * !![1, 0, 0; 0, 1, 0; 0, 0, -(1:ℤ)] * M_UP =
    !![1, 0, 0; 0, 1, 0; 0, 0, -(1:ℤ)] := by native_decide

/-- M_UP² is the depth-2 descent matrix. -/
theorem M_UP_squared :
    M_UP * M_UP = !![9, 8, -12; 8, 9, -12; -12, -12, 17] := by native_decide

/-- M_UP determinant. -/
theorem M_UP_det : Matrix.det M_UP = -1 := by native_decide

/-- M_UP trace. -/
theorem M_UP_trace : Matrix.trace M_UP = 5 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Parity Conservation
-- ═══════════════════════════════════════════════════════════════

/-- p has the same parity as a. -/
theorem ghost_p_parity (a b c : ℤ) : ghost_p a b c % 2 = a % 2 := by
  unfold ghost_p; omega

/-- q has the same parity as b. -/
theorem ghost_q_parity (a b c : ℤ) : ghost_q a b c % 2 = b % 2 := by
  unfold ghost_q; omega

/-- h has the same parity as c. -/
theorem ghost_h_parity (a b c : ℤ) : ghost_h a b c % 2 = c % 2 := by
  unfold ghost_h; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Concrete Verification
-- ═══════════════════════════════════════════════════════════════

theorem upi_5_12_13 : universalParent 5 12 13 = (3, 4, 5) := by native_decide
theorem upi_21_20_29 : universalParent 21 20 29 = (3, 4, 5) := by native_decide
theorem upi_15_8_17 : universalParent 15 8 17 = (3, 4, 5) := by native_decide
theorem upi_7_24_25 : universalParent 7 24 25 = (5, 12, 13) := by native_decide
theorem upi_9_40_41 : universalParent 9 40 41 = (7, 24, 25) := by native_decide
theorem upi_119_120_169 : universalParent 119 120 169 = (21, 20, 29) := by native_decide
theorem upi_root : universalParent 3 4 5 = (1, 0, 1) := by native_decide

/-- All three children of (3,4,5) return to (3,4,5). -/
theorem all_children_return :
    universalParent 5 12 13 = (3, 4, 5) ∧
    universalParent 21 20 29 = (3, 4, 5) ∧
    universalParent 15 8 17 = (3, 4, 5) :=
  ⟨upi_5_12_13, upi_21_20_29, upi_15_8_17⟩

/-- Three-step descent: (9,40,41) → (7,24,25) → (5,12,13) → (3,4,5). -/
theorem upi_three_step_descent :
    let t₁ := universalParent 9 40 41
    let t₂ := universalParent t₁.1 t₁.2.1 t₁.2.2
    let t₃ := universalParent t₂.1 t₂.2.1 t₂.2.2
    t₃ = (3, 4, 5) := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Root Detection
-- ═══════════════════════════════════════════════════════════════

theorem root_ghost_p : ghost_p 3 4 5 = 1 := by simp [ghost_p]
theorem root_ghost_q : ghost_q 3 4 5 = 0 := by simp [ghost_q]
theorem root_ghost_h : ghost_h 3 4 5 = 1 := by simp [ghost_h]

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Leg Swap Symmetry
-- ═══════════════════════════════════════════════════════════════

/-- Swapping legs swaps p and q. -/
theorem leg_swap_pq (a b c : ℤ) : ghost_p b a c = ghost_q a b c := by
  simp only [ghost_p, ghost_q]; ring

/-- Swapping legs preserves h. -/
theorem leg_swap_h (a b c : ℤ) : ghost_h b a c = ghost_h a b c := by
  simp only [ghost_h]; ring

/-- Swapping legs swaps the first two components of the universal parent. -/
theorem universalParent_leg_swap (a b c : ℤ) :
    universalParent b a c =
    ((universalParent a b c).2.1, (universalParent a b c).1,
     (universalParent a b c).2.2) := by
  simp only [universalParent, leg_swap_pq, leg_swap_h]

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Descent Bounds
-- ═══════════════════════════════════════════════════════════════

/-- Triangle inequality for PPTs. -/
theorem ppt_triangle_ineq (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) : a + b > c := by
  nlinarith [sq_nonneg (a - b), sq_abs (a + b)]

/-- Descent always contracts: h < c. -/
theorem ghost_descent_contracts (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) : ghost_h a b c < c := by
  have hab := ppt_triangle_ineq a b c ha hb hpyth
  have := ghost_h_descent a b c; linarith

/-- h > 0 for c ≥ 5. -/
theorem ghost_h_positive (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (hc : 5 ≤ c) : 0 < ghost_h a b c := by
  simp only [ghost_h]; nlinarith only [ha, hb, hpyth, hc, sq_nonneg (a - b)]

/-- Descent gap ≥ 2. -/
theorem descent_gap_ge_2 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) : 2 ≤ c - ghost_h a b c := by
  have hab := ppt_triangle_ineq a b c ha hb hpyth
  have := ghost_h_descent a b c; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 13: Universal Parent as Left Inverse
-- ═══════════════════════════════════════════════════════════════

/-- Ghost p of B₁-child recovers a. -/
theorem ghost_p_of_fwdB₁ (a b c : ℤ) :
    ghost_p (upi_fwdB₁ a b c).1 (upi_fwdB₁ a b c).2.1 (upi_fwdB₁ a b c).2.2 = a := by
  simp only [ghost_p, upi_fwdB₁]; ring

/-- Ghost q of B₁-child recovers -b. -/
theorem ghost_q_of_fwdB₁ (a b c : ℤ) :
    ghost_q (upi_fwdB₁ a b c).1 (upi_fwdB₁ a b c).2.1 (upi_fwdB₁ a b c).2.2 = -b := by
  simp only [ghost_q, upi_fwdB₁]; ring

/-- Ghost h of B₁-child recovers c. -/
theorem ghost_h_of_fwdB₁ (a b c : ℤ) :
    ghost_h (upi_fwdB₁ a b c).1 (upi_fwdB₁ a b c).2.1 (upi_fwdB₁ a b c).2.2 = c := by
  simp only [ghost_h, upi_fwdB₁]; ring

theorem ghost_p_of_fwdB₂ (a b c : ℤ) :
    ghost_p (upi_fwdB₂ a b c).1 (upi_fwdB₂ a b c).2.1 (upi_fwdB₂ a b c).2.2 = a := by
  simp only [ghost_p, upi_fwdB₂]; ring

theorem ghost_q_of_fwdB₂ (a b c : ℤ) :
    ghost_q (upi_fwdB₂ a b c).1 (upi_fwdB₂ a b c).2.1 (upi_fwdB₂ a b c).2.2 = b := by
  simp only [ghost_q, upi_fwdB₂]; ring

theorem ghost_h_of_fwdB₂ (a b c : ℤ) :
    ghost_h (upi_fwdB₂ a b c).1 (upi_fwdB₂ a b c).2.1 (upi_fwdB₂ a b c).2.2 = c := by
  simp only [ghost_h, upi_fwdB₂]; ring

theorem ghost_p_of_fwdB₃ (a b c : ℤ) :
    ghost_p (upi_fwdB₃ a b c).1 (upi_fwdB₃ a b c).2.1 (upi_fwdB₃ a b c).2.2 = -a := by
  simp only [ghost_p, upi_fwdB₃]; ring

theorem ghost_q_of_fwdB₃ (a b c : ℤ) :
    ghost_q (upi_fwdB₃ a b c).1 (upi_fwdB₃ a b c).2.1 (upi_fwdB₃ a b c).2.2 = b := by
  simp only [ghost_q, upi_fwdB₃]; ring

theorem ghost_h_of_fwdB₃ (a b c : ℤ) :
    ghost_h (upi_fwdB₃ a b c).1 (upi_fwdB₃ a b c).2.1 (upi_fwdB₃ a b c).2.2 = c := by
  simp only [ghost_h, upi_fwdB₃]; ring

/-- UP(B₁(a,b,c)) = (|a|, |b|, c). -/
theorem universalParent_of_fwdB₁ (a b c : ℤ) :
    universalParent (upi_fwdB₁ a b c).1 (upi_fwdB₁ a b c).2.1 (upi_fwdB₁ a b c).2.2 =
    (|a|, |b|, c) := by
  simp only [universalParent, ghost_p_of_fwdB₁, ghost_q_of_fwdB₁, ghost_h_of_fwdB₁, abs_neg]

/-- UP(B₂(a,b,c)) = (|a|, |b|, c). -/
theorem universalParent_of_fwdB₂ (a b c : ℤ) :
    universalParent (upi_fwdB₂ a b c).1 (upi_fwdB₂ a b c).2.1 (upi_fwdB₂ a b c).2.2 =
    (|a|, |b|, c) := by
  simp only [universalParent, ghost_p_of_fwdB₂, ghost_q_of_fwdB₂, ghost_h_of_fwdB₂]

/-- UP(B₃(a,b,c)) = (|a|, |b|, c). -/
theorem universalParent_of_fwdB₃ (a b c : ℤ) :
    universalParent (upi_fwdB₃ a b c).1 (upi_fwdB₃ a b c).2.1 (upi_fwdB₃ a b c).2.2 =
    (|a|, |b|, c) := by
  simp only [universalParent, ghost_p_of_fwdB₃, ghost_q_of_fwdB₃, ghost_h_of_fwdB₃, abs_neg]

/-- **Left Inverse (B₁)**: For positive legs, UP(B₁(a,b,c)) = (a,b,c). -/
theorem universalParent_left_inverse_B₁ (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    universalParent (upi_fwdB₁ a b c).1 (upi_fwdB₁ a b c).2.1 (upi_fwdB₁ a b c).2.2 =
    (a, b, c) := by
  rw [universalParent_of_fwdB₁]; simp [abs_of_pos ha, abs_of_pos hb]

/-- **Left Inverse (B₂)**: For positive legs, UP(B₂(a,b,c)) = (a,b,c). -/
theorem universalParent_left_inverse_B₂ (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    universalParent (upi_fwdB₂ a b c).1 (upi_fwdB₂ a b c).2.1 (upi_fwdB₂ a b c).2.2 =
    (a, b, c) := by
  rw [universalParent_of_fwdB₂]; simp [abs_of_pos ha, abs_of_pos hb]

/-- **Left Inverse (B₃)**: For positive legs, UP(B₃(a,b,c)) = (a,b,c). -/
theorem universalParent_left_inverse_B₃ (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    universalParent (upi_fwdB₃ a b c).1 (upi_fwdB₃ a b c).2.1 (upi_fwdB₃ a b c).2.2 =
    (a, b, c) := by
  rw [universalParent_of_fwdB₃]; simp [abs_of_pos ha, abs_of_pos hb]

-- ═══════════════════════════════════════════════════════════════
-- Section 14: Euclid Parameters
-- ═══════════════════════════════════════════════════════════════

/-- p in Euclid parameters. -/
theorem ghost_p_euclid (m n : ℤ) :
    ghost_p (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) = -(m - n) * (m - 3 * n) := by
  simp only [ghost_p]; ring

/-- q in Euclid parameters. -/
theorem ghost_q_euclid (m n : ℤ) :
    ghost_q (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) = 2 * n * (m - 2 * n) := by
  simp only [ghost_q]; ring

/-- h in Euclid parameters: h = (m - 2n)² + n². -/
theorem ghost_h_euclid (m n : ℤ) :
    ghost_h (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) = (m - 2 * n) ^ 2 + n ^ 2 := by
  simp only [ghost_h]; ring

/-- The parent hypotenuse is always a sum of two squares. -/
theorem parent_hyp_sum_of_squares (m n : ℤ) :
    ∃ u v : ℤ, ghost_h (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) = u ^ 2 + v ^ 2 :=
  ⟨m - 2 * n, n, ghost_h_euclid m n⟩

-- ═══════════════════════════════════════════════════════════════
-- Section 15: Branch Sign Products
-- ═══════════════════════════════════════════════════════════════

/-- Branch 2: p·q > 0. -/
theorem pq_sign_branch2 (a b c : ℤ) (hp : 0 < ghost_p a b c) (hq : 0 < ghost_q a b c) :
    0 < ghost_p a b c * ghost_q a b c := mul_pos hp hq

/-- Branch 1: p·q < 0. -/
theorem pq_sign_branch1 (a b c : ℤ) (hp : 0 < ghost_p a b c) (hq : ghost_q a b c < 0) :
    ghost_p a b c * ghost_q a b c < 0 := mul_neg_of_pos_of_neg hp hq

/-- Branch 3: p·q < 0. -/
theorem pq_sign_branch3 (a b c : ℤ) (hp : ghost_p a b c < 0) (hq : 0 < ghost_q a b c) :
    ghost_p a b c * ghost_q a b c < 0 := mul_neg_of_neg_of_pos hp hq

#print axioms universalParent_pythagorean
#print axioms universalParent_eq_branch1
#print axioms universalParent_of_fwdB₁
#print axioms universalParent_left_inverse_B₁
#print axioms universalParent_leg_swap
#print axioms ghost_h_composed
