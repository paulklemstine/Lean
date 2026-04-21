import Mathlib

/-! # Reverse Solving and Fixed-Point Analysis on the Berggren Tree

This file formalizes the core mathematics of §11 from the research program:
- **Reverse Problem**: Given N, embed it into a Pythagorean triple and ascend the
  Berggren tree. The GCDs encountered along the path can reveal non-trivial factors.
- **Fixed-Point Analysis**: Characterize fixed points of Berggren matrix powers.
  For symmetric Berggren products (including all powers of B₂), fixed points
  satisfy a = b, collapsing the 3-equation system to a single equation.

Machine-verified with 0 sorries.
-/

/-! ## Part I: Berggren Matrices and Inverse Transforms -/

/-- The three Berggren matrices as functions on ℤ³. -/
def berggrenB1 (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def berggrenB2 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def berggrenB3 (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The three inverse Berggren matrices as functions on ℤ³. -/
def invB1 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)
def invB2 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)
def invB3 (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- A Pythagorean triple is (a, b, c) with a² + b² = c². -/
def IsPythTriple' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-! ## Part II: Descent Preserves Pythagorean Property -/

theorem invB1_preserves_pyth (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (invB1 a b c).1 (invB1 a b c).2.1 (invB1 a b c).2.2 := by
  unfold IsPythTriple' invB1 at *; nlinarith [h]

theorem invB2_preserves_pyth (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (invB2 a b c).1 (invB2 a b c).2.1 (invB2 a b c).2.2 := by
  unfold IsPythTriple' invB2 at *; nlinarith [h]

theorem invB3_preserves_pyth (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (invB3 a b c).1 (invB3 a b c).2.1 (invB3 a b c).2.2 := by
  unfold IsPythTriple' invB3 at *; nlinarith [h]

/-! ## Part III: Lorentz Form Invariance -/

theorem invB1_lorentz_invariant (a b c : ℤ) :
    (invB1 a b c).1 ^ 2 + (invB1 a b c).2.1 ^ 2 - (invB1 a b c).2.2 ^ 2 =
    a ^ 2 + b ^ 2 - c ^ 2 := by
  unfold invB1; ring

theorem invB2_lorentz_invariant (a b c : ℤ) :
    (invB2 a b c).1 ^ 2 + (invB2 a b c).2.1 ^ 2 - (invB2 a b c).2.2 ^ 2 =
    a ^ 2 + b ^ 2 - c ^ 2 := by
  unfold invB2; ring

theorem invB3_lorentz_invariant (a b c : ℤ) :
    (invB3 a b c).1 ^ 2 + (invB3 a b c).2.1 ^ 2 - (invB3 a b c).2.2 ^ 2 =
    a ^ 2 + b ^ 2 - c ^ 2 := by
  unfold invB3; ring

/-! ## Part IV: Universal Parent Hypotenuse Formula -/

theorem universal_parent_hyp_B1 (a b c : ℤ) :
    (invB1 a b c).2.2 = 3*c - 2*a - 2*b := by unfold invB1; ring

theorem universal_parent_hyp_B2 (a b c : ℤ) :
    (invB2 a b c).2.2 = 3*c - 2*a - 2*b := by unfold invB2; ring

theorem universal_parent_hyp_B3 (a b c : ℤ) :
    (invB3 a b c).2.2 = 3*c - 2*a - 2*b := by unfold invB3; ring

/-- For a PPT with positive legs, a + b > c. -/
theorem ppt_sum_gt_hyp (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : IsPythTriple' a b c) : a + b > c := by
  unfold IsPythTriple' at hpyth
  nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b, sq_abs (a + b)]

/-- Hypotenuse decreases during descent. -/
theorem descent_hyp_decreases (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : IsPythTriple' a b c) :
    3 * c - 2 * (a + b) < c := by
  have := ppt_sum_gt_hyp a b c ha hb hpyth
  linarith

/-! ## Part V: GCD Factor Extraction -/

/-
If gcd(d, N) is between 1 and N, it gives a non-trivial factorization.
-/
theorem gcd_nontrivial_factor (N d : ℕ) (_hN : 1 < N)
    (hg1 : 1 < Nat.gcd d N) (hg2 : Nat.gcd d N < N) :
    ∃ p q : ℕ, 1 < p ∧ 1 < q ∧ N = p * q := by
  exact ⟨ Nat.gcd d N, N / Nat.gcd d N, hg1, by nlinarith [ Nat.div_mul_cancel ( Nat.gcd_dvd_right d N ) ], by rw [ Nat.mul_div_cancel' ( Nat.gcd_dvd_right _ _ ) ] ⟩

/-! ## Part VI: Fixed-Point Analysis of Berggren Words -/

/-- Any fixed point of B₂ has a = b. -/
theorem B2_fixed_point_ab_eq (a b c : ℤ)
    (h1 : a + 2*b + 2*c = a)
    (h2 : 2*a + b + 2*c = b) :
    a = b := by linarith

/-- For B₂, the fixed-point system reduces: a = b and b + c = 0. -/
theorem B2_fixed_point_system (a b c : ℤ)
    (h1 : a + 2*b + 2*c = a)
    (h2 : 2*a + b + 2*c = b)
    (_h3 : 2*a + 2*b + 3*c = c) :
    a = b ∧ b + c = 0 := ⟨by linarith, by linarith⟩

/-- The only integer fixed point of B₂ is (0, 0, 0). -/
theorem B2_fixed_point_trivial (a b c : ℤ)
    (h1 : a + 2*b + 2*c = a)
    (h2 : 2*a + b + 2*c = b)
    (h3 : 2*a + 2*b + 3*c = c) :
    a = 0 ∧ b = 0 ∧ c = 0 := by
  have hab : a = b := by linarith
  have hbc : b + c = 0 := by linarith
  have hb : b = 0 := by nlinarith
  exact ⟨by linarith, hb, by linarith⟩

/-! ## Part VII: Fixed Points of B₂² -/

/-- Fixed points of B₂² also satisfy a = b. -/
theorem B2sq_fixed_point_ab_eq (a b c : ℤ)
    (h1 : 9*a + 16*b + 18*c = a)
    (h2 : 16*a + 9*b + 18*c = b) :
    a = b := by linarith

/-
The only integer fixed point of B₂² is (0, 0, 0).
-/
theorem B2sq_fixed_point_trivial (a b c : ℤ)
    (h1 : 9*a + 16*b + 18*c = a)
    (h2 : 16*a + 9*b + 18*c = b)
    (h3 : 18*a + 18*b + 21*c = c) :
    a = 0 ∧ b = 0 ∧ c = 0 := by
  omega

/-! ## Part VIII: Branch Choice Encodes Number Theory -/

/-- The branch discriminant for B₁⁻¹. -/
theorem branch1_discriminant (a b c : ℤ) :
    (invB1 a b c).2.1 = 2*c - 2*a - b := by unfold invB1; ring

/-- The branch discriminant for B₂⁻¹. -/
theorem branch2_discriminant (a b c : ℤ) :
    (invB2 a b c).2.1 = 2*a + b - 2*c := by unfold invB2; ring

/-- B₁⁻¹ and B₂⁻¹ second components are negations. -/
theorem branch12_exclusive (a b c : ℤ) :
    (invB1 a b c).2.1 + (invB2 a b c).2.1 = 0 := by unfold invB1 invB2; ring

/-- The first components of B₁⁻¹ and B₂⁻¹ are identical. -/
theorem branch12_first_eq (a b c : ℤ) :
    (invB1 a b c).1 = (invB2 a b c).1 := by unfold invB1 invB2; ring

/-- The sign of (2a + b - 2c) determines the branch choice. -/
theorem branch_choice_criterion (a b c : ℤ) (hne : 2*a + b ≠ 2*c) :
    (0 < 2*a + b - 2*c) ∨ (0 < 2*c - 2*a - b) := by omega

/-! ## Part IX: Inverse Composition Identities -/

/-- B₁⁻¹ ∘ B₁ = Id -/
theorem invB1_comp_B1 (a b c : ℤ) :
    invB1 (berggrenB1 a b c).1 (berggrenB1 a b c).2.1 (berggrenB1 a b c).2.2 = (a, b, c) := by
  unfold invB1 berggrenB1; simp; exact ⟨by ring, by ring, by ring⟩

/-- B₂⁻¹ ∘ B₂ = Id -/
theorem invB2_comp_B2 (a b c : ℤ) :
    invB2 (berggrenB2 a b c).1 (berggrenB2 a b c).2.1 (berggrenB2 a b c).2.2 = (a, b, c) := by
  unfold invB2 berggrenB2; simp; exact ⟨by ring, by ring, by ring⟩

/-- B₃⁻¹ ∘ B₃ = Id -/
theorem invB3_comp_B3 (a b c : ℤ) :
    invB3 (berggrenB3 a b c).1 (berggrenB3 a b c).2.1 (berggrenB3 a b c).2.2 = (a, b, c) := by
  unfold invB3 berggrenB3; simp; exact ⟨by ring, by ring, by ring⟩

/-- B₁ ∘ B₁⁻¹ = Id -/
theorem B1_comp_invB1 (a b c : ℤ) :
    berggrenB1 (invB1 a b c).1 (invB1 a b c).2.1 (invB1 a b c).2.2 = (a, b, c) := by
  unfold berggrenB1 invB1; simp; exact ⟨by ring, by ring, by ring⟩

/-- B₂ ∘ B₂⁻¹ = Id -/
theorem B2_comp_invB2 (a b c : ℤ) :
    berggrenB2 (invB2 a b c).1 (invB2 a b c).2.1 (invB2 a b c).2.2 = (a, b, c) := by
  unfold berggrenB2 invB2; simp; exact ⟨by ring, by ring, by ring⟩

/-- B₃ ∘ B₃⁻¹ = Id -/
theorem B3_comp_invB3 (a b c : ℤ) :
    berggrenB3 (invB3 a b c).1 (invB3 a b c).2.1 (invB3 a b c).2.2 = (a, b, c) := by
  unfold berggrenB3 invB3; simp; exact ⟨by ring, by ring, by ring⟩