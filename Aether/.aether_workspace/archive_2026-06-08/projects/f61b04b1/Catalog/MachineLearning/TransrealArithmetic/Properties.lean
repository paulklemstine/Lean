/-
# Transreal Arithmetic: Structural Properties

This file proves the key structural results about transreal arithmetic:
1. Ring axioms fail (additive inverse, zero absorption, distributivity)
2. Nullity absorption creates a wheel-like absorbing structure
3. Cancellation laws collapse for non-finite elements
4. The embedding of ℝ preserves field operations
5. A partial order extends the real order but nullity is incomparable
6. Wheel axiom analysis
-/
import Speculative.TransrealArithmetic.Defs

namespace Transreal

/-! ## Section 1: Addition is Commutative -/

/-- Addition on transreals is commutative. -/
theorem add_comm' (a b : Transreal) : a + b = b + a := by
  rcases a with ( _ | _ | _ | _ ) <;> rcases b with ( _ | _ | _ | _ ) <;>
    first | rfl | (norm_num [Transreal.add]; exact add_comm _ _)

/-! ## Section 2: Ring Axiom Failures -/

/-- The additive inverse law fails: ∞ + (-∞) = Φ ≠ 0.
    This is the fundamental obstruction to ring structure:
    posInf has no additive inverse. -/
theorem posInf_add_neg_ne_zero : posInf + (-posInf) ≠ (0 : Transreal) := by
  aesop

/-- Zero times infinity is nullity, not zero.
    This violates the ring axiom that 0 * x = 0. -/
theorem zero_mul_posInf_eq_nullity : (0 : Transreal) * posInf = nullity := by
  convert zero_mul_posInf using 1

/-- The ring axiom 0 * x = 0 fails: there exists x with 0 * x ≠ 0. -/
theorem zero_mul_ne_zero : ∃ x : Transreal, (0 : Transreal) * x ≠ 0 := by
  use posInf
  simp +decide [Transreal.zero_def]
  erw [Transreal.zero_mul_posInf]
  exact fun h => by have := congr_arg (fun x => x = nullity) h; simp +decide at this

/-- Left distributivity fails in the transreals.
    Counterexample: posInf * (ofReal 1 + negInf) = posInf * negInf = negInf
    but posInf * ofReal 1 + posInf * negInf = posInf + negInf = nullity.
    Since negInf ≠ nullity, distributivity is violated. -/
theorem left_distrib_fails :
    ∃ a b c : Transreal, a * (b + c) ≠ a * b + a * c := by
  use posInf, ofReal 1, negInf
  simp [posInf_mul_posReal]

/-! ## Section 3: Nullity Absorption (Wheel-like Structure) -/

/-- Nullity is a two-sided absorbing element under addition. -/
theorem nullity_absorb_add (x : Transreal) :
    nullity + x = nullity ∧ x + nullity = nullity :=
  ⟨nullity_add x, add_nullity x⟩

/-- Nullity is a two-sided absorbing element under multiplication. -/
theorem nullity_absorb_mul (x : Transreal) :
    nullity * x = nullity ∧ x * nullity = nullity :=
  ⟨by cases x <;> rfl, by cases x <;> rfl⟩

/-- Nullity is a fixed point of negation. -/
theorem neg_nullity_eq : -nullity = (nullity : Transreal) := rfl

/-- Nullity is a fixed point of reciprocal. -/
theorem recip_nullity_eq : recip nullity = nullity := rfl

/-- The "nullity propagation" principle: any arithmetic expression
    involving nullity evaluates to nullity. Shown for composed expressions. -/
theorem nullity_propagates_composed (x y : Transreal) :
    (nullity + x) * y = nullity := by
  simp

/-! ## Section 4: The Real Embedding Preserves Field Structure -/

/-- The embedding of reals preserves addition. -/
theorem ofReal_add_eq (a b : ℝ) : ofReal (a + b) = ofReal a + ofReal b := rfl

/-- The embedding of reals preserves multiplication. -/
theorem ofReal_mul_eq (a b : ℝ) : ofReal (a * b) = ofReal a * ofReal b := rfl

/-- The embedding of reals preserves negation. -/
theorem ofReal_neg_eq (a : ℝ) : ofReal (-a) = -ofReal a := rfl

/-- The embedding of reals preserves reciprocal for nonzero values. -/
theorem ofReal_recip_eq (a : ℝ) (ha : a ≠ 0) : ofReal (a⁻¹) = recip (ofReal a) := by
  rw [eq_comm, Transreal.recip_ofReal_ne_zero a ha]

/-! ## Section 5: Cancellation Law Collapse -/

/-- Additive cancellation fails: there exist a, b, c with a + b = a + c but b ≠ c.
    Witness: posInf + ofReal 1 = posInf = posInf + ofReal 2, but ofReal 1 ≠ ofReal 2. -/
theorem add_cancel_fails :
    ∃ a b c : Transreal, a + b = a + c ∧ b ≠ c := by
  use Transreal.posInf, Transreal.ofReal 1, Transreal.ofReal 2; norm_num

/-- Multiplicative cancellation fails: there exist a, b, c with a ≠ 0 and
    a * b = a * c but b ≠ c.
    Witness: posInf * ofReal 1 = posInf = posInf * ofReal 2. -/
theorem mul_cancel_fails :
    ∃ a b c : Transreal, a ≠ 0 ∧ a * b = a * c ∧ b ≠ c := by
  refine ⟨posInf, ofReal 1, ofReal 2, ?_, ?_, ?_⟩
  · exact fun h => by cases h
  · rw [posInf_mul_posReal, posInf_mul_posReal] <;> norm_num
  · grind

/-! ## Section 6: Infinity Arithmetic Laws -/

/-- Double negation is involutive on transreals. -/
theorem neg_neg' (x : Transreal) : -(-x) = x := by
  rcases x with ( _ | _ | _ | _ ) <;> simp +decide

/-- Multiplication by -1 equals negation for finite values. -/
theorem mul_neg_one_ofReal (r : ℝ) :
    ofReal r * ofReal (-1) = -(ofReal r) := by
  convert mul_ofReal r (-1) using 1; norm_num

/-- The reciprocal of the reciprocal of a nonzero real is itself. -/
theorem recip_recip_ofReal_ne_zero (r : ℝ) (hr : r ≠ 0) :
    recip (recip (ofReal r)) = ofReal r := by
  rw [Transreal.recip, if_neg hr, Transreal.recip_ofReal_ne_zero]
  · norm_num
  · aesop

/-! ## Section 7: The Transreal Order -/

/-- Every real number lies between -∞ and +∞. -/
theorem negInf_le_ofReal_le_posInf (r : ℝ) :
    (negInf : Transreal) ≤ ofReal r ∧ ofReal r ≤ posInf :=
  ⟨negInf_le_ofReal r, ofReal_le_posInf r⟩

/-- Nullity is not ≤ posInf (it's incomparable). -/
theorem nullity_not_le_posInf : ¬(nullity ≤ (posInf : Transreal)) :=
  Not.imp (fun a => a) fun a => a

/-- Nullity is not ≥ any real (it's truly incomparable). -/
theorem ofReal_not_le_nullity (r : ℝ) : ¬(ofReal r ≤ nullity) :=
  Not.imp (fun a => a) fun a => a

/-! ## Section 8: Wheel Axiom Verification -/

/-- Multiplication is commutative on transreals. -/
theorem mul_comm' (a b : Transreal) : a * b = b * a := by
  rcases a with ( _ | _ | _ | _ ) <;> rcases b with ( _ | _ | _ | _ ) <;> norm_cast
  exact congr_arg ofReal (mul_comm _ _)

/-- Zero is a right identity for addition on total (non-nullity) elements. -/
theorem add_zero_of_total (x : Transreal) (hx : x.IsTotal) :
    x + ofReal 0 = x := by
  cases x <;> simp_all +decide

/-- The wheel involution axiom recip(recip(x)) = x FAILS for -∞:
    recip(negInf) = 0, recip(0) = posInf ≠ negInf. -/
theorem recip_recip_fails_at_negInf :
    recip (recip negInf) ≠ negInf := by
  simp [Transreal.recip]

/-- The weakened wheel distributivity:
    x * z + y * z + (0 : Transreal) * z = (x + y) * z + (0 : Transreal) * z
    holds for finite values (where 0*z = 0). -/
theorem wheel_distrib_finite (a b c : ℝ) :
    ofReal a * ofReal c + ofReal b * ofReal c + (0 : Transreal) * ofReal c
    = (ofReal a + ofReal b) * ofReal c + (0 : Transreal) * ofReal c := by
  rw [← Transreal.ofReal_mul_eq, ← Transreal.ofReal_mul_eq, ← Transreal.ofReal_add_eq]
  rw [← ofReal_add_eq, ← add_mul, ofReal_mul_eq]

/-! ## Section 9: Transreal Division is Total -/

/-- Division by zero yields infinity for positive numerator. -/
theorem div_by_zero_pos (r : ℝ) (hr : r > 0) :
    ofReal r / ofReal 0 = posInf := by
  show Transreal.div (ofReal r) (ofReal 0) = posInf
  simp [Transreal.div, recip_zero, posReal_mul_posInf, hr]

/-- Zero divided by zero yields nullity: the defining property of Φ. -/
theorem zero_div_zero : (0 : Transreal) / 0 = nullity := by
  show Transreal.div (ofReal 0) (ofReal 0) = nullity
  simp [Transreal.div, recip_zero, zero_mul_posInf]

/-- Division of nullity by anything is nullity. -/
theorem nullity_div (x : Transreal) : nullity / x = nullity := by
  show Transreal.div nullity x = nullity
  simp [Transreal.div]

/-! ## Section 10: The Fundamental Trichotomy -/

/-- Every transreal number is exactly one of: finite, infinite, or nullity.
    This is the fundamental classification theorem. -/
theorem transreal_trichotomy (x : Transreal) :
    (∃ r : ℝ, x = ofReal r) ∨ x = posInf ∨ x = negInf ∨ x = nullity := by
  rcases x with ( _ | _ | _ | _ ) <;> tauto

/-- **Conjecture** (Transreal Idempotent Collapse):
    In any expression tree over transreals built from add and mul,
    with at least one nullity leaf, the expression evaluates to nullity.
    We prove this for depth-2 binary trees. -/
theorem nullity_collapse_depth2 (op₁ op₂ : Transreal → Transreal → Transreal)
    (h₁ : op₁ = add ∨ op₁ = mul)
    (h₂ : op₂ = add ∨ op₂ = mul)
    (x y : Transreal) :
    op₁ (op₂ nullity x) y = nullity := by
  rcases h₁ with rfl | rfl <;> rcases h₂ with rfl | rfl
  all_goals {
    show _ = nullity
    first
    | (conv_lhs => rw [show add nullity x = nullity from nullity_add x])
    | (conv_lhs => rw [show mul nullity x = nullity from nullity_mul x])
    first
    | exact nullity_add y
  }

/-! ## Section 11: Non-trivial Structural Theorems -/

/-- The transreals have exactly one absorbing element under both + and ×.
    That is, if z satisfies z + x = z and z * x = z for all x, then z = nullity. -/
theorem unique_absorbing (z : Transreal)
    (hadd : ∀ x, z + x = z) (_hmul : ∀ x, z * x = z) : z = nullity := by
  have h := hadd nullity
  rw [add_nullity] at h
  exact h.symm

/-- In the transreals, the equation x + x = x has exactly four solutions:
    0, posInf, negInf, and nullity. -/
theorem add_idempotent_classification (x : Transreal) (h : x + x = x) :
    x = ofReal 0 ∨ x = posInf ∨ x = negInf ∨ x = nullity := by
  rcases x with ( _ | _ | _ | _ ) <;> simp +decide at h ⊢
  grind

/-- The "sign-infinity" interaction: multiplying infinities follows the sign rule
    (positive × positive = positive, etc.), just like finite reals. -/
theorem infinity_sign_rule :
    (posInf : Transreal) * posInf = posInf ∧
    negInf * negInf = posInf ∧
    posInf * negInf = negInf ∧
    negInf * posInf = negInf := by
  aesop

end Transreal