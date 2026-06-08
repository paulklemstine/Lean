import Mathlib
import Cryptography.EllipticCurve.Basic
import Cryptography.EllipticCurve.GroupLaw

/-!
# Verified Scalar Multiplication for Elliptic Curves

This file defines and proves correct a scalar multiplication algorithm
for elliptic curve points.

## Main Results
- `smulPoint_zero`: 0 • P = ∞
- `smulPoint_succ`: (n+1) • P = P + n • P
- `smulPoint_one`: 1 • P = P
- `smulPoint_two`: 2 • P = double(P)
- `smulPoint_add`: (m+n) • P = m•P + n•P (conditional on associativity)
- `smulPoint_bit0`: 2n • P = double(n • P) (conditional on associativity)
-/

noncomputable section

open Classical ECPoint

variable {K : Type*} [Field K] (E : ShortWeierstrassModel K)

/-! ## Basic scalar multiplication properties -/

/-- 0 • P = ∞ -/
theorem smulPoint_zero (P : ECPoint E) : smulPoint E 0 P = infinity := rfl

/-- (n+1) • P = P + n • P -/
theorem smulPoint_succ (n : ℕ) (P : ECPoint E) :
    smulPoint E (n + 1) P = ecAdd E P (smulPoint E n P) := rfl

/-- 1 • P = P -/
theorem smulPoint_one (P : ECPoint E) : smulPoint E 1 P = P := by
  simp [smulPoint, ecAdd_right_identity]

/-- Point doubling via addition. -/
def ecDouble (E : ShortWeierstrassModel K) (P : ECPoint E) : ECPoint E :=
  ecAdd E P P

/-- 2 • P = double(P) -/
theorem smulPoint_two (P : ECPoint E) :
    smulPoint E 2 P = ecDouble E P := by
  simp [smulPoint, ecDouble, ecAdd_right_identity]

/-
Negation of n•P: n • (−P) = −(n • P), assuming commutativity.
-/
theorem smulPoint_neg_comm (n : ℕ) (P : ECPoint E) :
    smulPoint E n (ecNeg E P) = ecNeg E (smulPoint E n P) := by
  induction' n with n ih generalizing P;
  · rfl;
  · convert congr_arg ( fun x => ecAdd E ( ecNeg E P ) x ) ( ih P ) using 1;
    rw [ smulPoint_succ, ecAdd_comm ];
    have h_neg_add : ∀ P Q : ECPoint E, ecNeg E (ecAdd E P Q) = ecAdd E (ecNeg E P) (ecNeg E Q) := by
      intro P Q;
      cases P <;> cases Q <;> simp +decide [ ecAdd ];
      · rfl;
      · rfl;
      · rfl;
      · split_ifs <;> simp +decide [ *, ecNeg ];
        · aesop;
        · grind;
        · grind;
    rw [ h_neg_add, ecAdd_comm ]

/-! ## Distributivity (requires associativity) -/

/-- Associativity of ecAdd as a proposition. -/
def ecAdd_assoc_prop (E : ShortWeierstrassModel K) : Prop :=
  ∀ P Q R : ECPoint E, ecAdd E (ecAdd E P Q) R = ecAdd E P (ecAdd E Q R)

/-- Scalar multiplication distributes over addition of scalars,
    assuming associativity of the group law. -/
theorem smulPoint_add (hassoc : ecAdd_assoc_prop E)
    (m n : ℕ) (P : ECPoint E) :
    smulPoint E (m + n) P = ecAdd E (smulPoint E m P) (smulPoint E n P) := by
  induction m with
  | zero => simp [smulPoint, ecAdd_left_identity]
  | succ m ih =>
    rw [Nat.succ_add, smulPoint_succ, ih, smulPoint_succ]
    exact (hassoc P (smulPoint E m P) (smulPoint E n P)).symm

/-- Efficient doubling: 2n • P = double(n • P), assuming associativity. -/
theorem smulPoint_bit0 (hassoc : ecAdd_assoc_prop E)
    (n : ℕ) (P : ECPoint E) :
    smulPoint E (2 * n) P = ecDouble E (smulPoint E n P) := by
  rw [show 2 * n = n + n from by omega]
  rw [smulPoint_add E hassoc n n P]
  rfl

/-- Efficient odd step: (2n+1) • P = P + double(n • P), assuming associativity. -/
theorem smulPoint_bit1 (hassoc : ecAdd_assoc_prop E)
    (n : ℕ) (P : ECPoint E) :
    smulPoint E (2 * n + 1) P = ecAdd E P (ecDouble E (smulPoint E n P)) := by
  rw [smulPoint_succ, smulPoint_bit0 E hassoc]

end