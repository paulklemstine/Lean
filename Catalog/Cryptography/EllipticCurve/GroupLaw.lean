import Mathlib
import Cryptography.EllipticCurve.Basic

/-!
# Elliptic Curve Group Law Properties

This file proves the fundamental group law properties for elliptic curve point addition:
- Left and right identity (`ecAdd_left_identity`, `ecAdd_right_identity`)
- Negation is an involution (`ecNeg_involutive`)
- Left and right inverse (`ecAdd_right_inv`, `ecAdd_left_inv`)
- Commutativity (`ecAdd_comm`)
-/

noncomputable section

open Classical ECPoint

variable {K : Type*} [Field K] (E : ShortWeierstrassModel K)

/-! ## Identity element -/

/-- The point at infinity is a left identity for addition. -/
theorem ecAdd_left_identity : ∀ P : ECPoint E, ecAdd E infinity P = P := by
  intro P; cases P <;> simp [ecAdd]

/-- The point at infinity is a right identity for addition. -/
theorem ecAdd_right_identity : ∀ P : ECPoint E, ecAdd E P infinity = P := by
  intro P; cases P <;> simp [ecAdd]

/-! ## Negation involution -/

/-- Negation is an involution: negating twice returns the original point.
    Uses `rcases` on point structure. -/
theorem ecNeg_involutive : ∀ P : ECPoint E, ecNeg E (ecNeg E P) = P := by
  intro P
  rcases P with _ | ⟨x, y, h⟩
  · simp [ecNeg]
  · simp only [ecNeg]
    exact affine_eq rfl (neg_neg y)

/-! ## Inverse laws -/

/-
Adding a point to its negation gives infinity (right inverse).
-/
theorem ecAdd_right_inv : ∀ P : ECPoint E, ecAdd E P (ecNeg E P) = infinity := by
  unfold ecAdd ecNeg;
  intro P;
  rcases P with ( _ | ⟨ x, y, h ⟩ ) <;> simp +decide;
  intro hy
  have h_char : (2 : K) ≠ 0 := by
    exact E.char_ne_two;
  exact mul_left_cancel₀ h_char ( by linear_combination' hy )

/-
Adding the negation on the left gives infinity (left inverse).
-/
theorem ecAdd_left_inv : ∀ P : ECPoint E, ecAdd E (ecNeg E P) P = infinity := by
  -- By definition of addition on the elliptic curve, we can split into cases based on whether P is the point at infinity or not.
  intros P
  cases P <;> simp [ecAdd, ecNeg];
  intro h; rw [ neg_eq_iff_add_eq_zero ] at h; ring_nf at h;
  exact eq_zero_of_ne_zero_of_mul_right_eq_zero ( by have := E.char_ne_two; aesop ) h

/-! ## Commutativity -/

/-
Point addition is commutative.
-/
theorem ecAdd_comm :
    ∀ P Q : ECPoint E, ecAdd E P Q = ecAdd E Q P := by
  intro P Q; cases P <;> cases Q <;> simp +decide [ ecAdd ] ;
  grind +qlia

end