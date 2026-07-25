/-
# Transreal Arithmetic: Main Theorems

This file proves the key structural theorems about transreal arithmetic:

1. **Nullity absorbs** under both addition and multiplication
2. **Absorber uniqueness**: nullity is the ONLY double absorber
3. **Distributivity failure**: the transreal extension cannot be a ring
4. **Additive idempotent classification**: exactly 4 elements satisfy x + x = x
5. **Commutativity**: transreal addition and multiplication are commutative

These results characterize the precise algebraic boundary between
what survives and what collapses when division is made total.
-/
import Algebra.TransrealDefs

open Classical Transreal

noncomputable section

namespace Transreal

/-! ## 1. Nullity is a Double Absorber -/

/-- Nullity absorbs under addition: Φ + x = Φ for all x. -/
theorem nullity_add_absorb : ∀ (x : Transreal), nullity + x = nullity := by
  intro x; cases x <;> rfl

/-- Nullity absorbs under addition from the right: x + Φ = Φ for all x. -/
theorem add_nullity_absorb : ∀ (x : Transreal), x + nullity = nullity := by
  intro x; cases x <;> rfl

/-- Nullity absorbs under multiplication: Φ * x = Φ for all x. -/
theorem nullity_mul_absorb : ∀ (x : Transreal), nullity * x = nullity := by
  intro x; cases x <;> rfl

/-- Nullity absorbs under multiplication from the right: x * Φ = Φ for all x. -/
theorem mul_nullity_absorb : ∀ (x : Transreal), x * nullity = nullity := by
  intro x; cases x <;> simp [mul_def, Transreal.mul]

/-- Nullity is a double absorber. -/
theorem nullity_is_double_absorber : IsDoubleAbsorber nullity :=
  ⟨nullity_add_absorb, nullity_mul_absorb⟩

/-! ## 2. Absorber Uniqueness — The Key Theorem

This is the central result: nullity is the UNIQUE element that absorbs
under both addition and multiplication. The proof works by showing:
- posInf fails to absorb additively (posInf + negInf = Φ ≠ posInf)
- negInf fails to absorb additively (negInf + posInf = Φ ≠ negInf)
- ofReal r fails additively: (ofReal r) + (ofReal 1) = ofReal (r+1) ≠ ofReal r for any r
-/

/-- **Absorber Uniqueness Theorem**: Nullity is the only element of Transreal
    that is simultaneously an additive and multiplicative absorber.
    This is the key structural theorem of transreal arithmetic. -/
theorem double_absorber_unique (x : Transreal) (h : IsDoubleAbsorber x) :
    x = nullity := by
  rcases x with (_ | _ | _ | _) <;>
    simp +decide [Transreal.IsDoubleAbsorber] at *
  · have := h.1 (ofReal 1); simp_all +decide [Transreal.add]
  · cases h.1 negInf
  · have := h.1 Transreal.posInf; simp +decide at this

/-! ## 3. Distributivity Failure

Anderson's transreal arithmetic necessarily violates distributivity.
This is not a defect but a theorem: any total extension of a field
that includes 0/0 must break distributivity. -/

/-- **Distributivity fails** in transreal arithmetic.
    Witness: a = ∞₊, b = 1, c = ∞₋.
    a * (b + c) = ∞₊ * ∞₋ = ∞₋, but
    a * b + a * c = ∞₊ + ∞₋ = Φ ≠ ∞₋. -/
theorem distributivity_fails :
    ∃ a b c : Transreal, a * (b + c) ≠ a * b + a * c := by
  exact ⟨posInf, 1, negInf, by simp +decide [Transreal.add, Transreal.mul, realSign]⟩

/-! ## 4. Additive Idempotent Classification

An element x is additively idempotent if x + x = x. In the transreals,
exactly four elements have this property: 0, +∞, -∞, and Φ. -/

/-- Zero is additively idempotent. -/
theorem zero_additive_idempotent : IsAdditiveIdempotent (0 : Transreal) := by
  show ofReal 0 + ofReal 0 = ofReal 0; simp [Transreal.add]

/-- Positive infinity is additively idempotent. -/
theorem posInf_additive_idempotent : IsAdditiveIdempotent posInf := rfl

/-- Negative infinity is additively idempotent. -/
theorem negInf_additive_idempotent : IsAdditiveIdempotent negInf := rfl

/-- Nullity is additively idempotent. -/
theorem nullity_additive_idempotent : IsAdditiveIdempotent nullity := rfl

/-- **Additive Idempotent Classification**: An element is additively idempotent
    if and only if it is 0, +∞, -∞, or Φ. The forward direction requires showing
    that no nonzero real r satisfies r + r = r (which follows from field arithmetic). -/
theorem additive_idempotent_classification (x : Transreal) :
    IsAdditiveIdempotent x ↔ (x = 0 ∨ x = posInf ∨ x = negInf ∨ x = nullity) := by
  unfold IsAdditiveIdempotent
  cases x <;> simp +decide [Transreal.add]

/-! ## 5. Addition is Commutative -/

/-- Transreal addition is commutative. -/
theorem add_comm (a b : Transreal) : a + b = b + a := by
  cases a <;> cases b <;> simp [add_def, Transreal.add]
  · ring

/-! ## 6. Multiplication is Commutative -/

/-- Transreal multiplication is commutative. -/
theorem mul_comm (a b : Transreal) : a * b = b * a := by
  cases a <;> cases b <;> simp [mul_def, Transreal.mul]
  · ring

/-! ## 7. Zero and One Behavior -/

/-- Zero is a right identity for addition. -/
theorem add_zero (a : Transreal) : a + 0 = a := by
  cases a <;> simp [Transreal.add]

/-- Zero is a left identity for addition. -/
theorem zero_add (a : Transreal) : 0 + a = a := by
  rw [add_comm, add_zero]

/-- One is a right identity for multiplication. -/
theorem mul_one (a : Transreal) : a * 1 = a := by
  cases a <;> simp +decide [Transreal.mul, Transreal.one_def]
  · unfold realSign; norm_num
  · unfold realSign; simp +decide

/-- One is a left identity for multiplication. -/
theorem one_mul (a : Transreal) : 1 * a = a := by
  rw [mul_comm, mul_one]

/-! ## 8. Division Totality -/

/-- Division by zero of a positive real yields positive infinity. -/
theorem div_zero_pos (r : ℝ) (hr : r > 0) :
    ofReal r / ofReal 0 = posInf := by
  simp [Transreal.div]
  exact fun h => (hr.not_ge h).elim

/-- 0/0 = Φ: the defining equation of nullity. -/
theorem zero_div_zero : (0 : Transreal) / 0 = nullity := by
  simp [div_def, Transreal.div]

/-! ## 9. Negation Properties -/

/-- Double negation is identity. -/
theorem neg_neg (a : Transreal) : - -a = a := by
  cases a <;> simp [neg_def, Transreal.neg]

/-- Negation of nullity is nullity. -/
theorem neg_nullity : -(nullity : Transreal) = nullity := rfl

end Transreal
end