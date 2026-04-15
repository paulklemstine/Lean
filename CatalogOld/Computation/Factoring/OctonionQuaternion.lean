import Mathlib

/-!
# Quaternion Factoring: Structured Quaternions and SL(2,ℤ) Action

This file formalizes:
- Integer quaternion structure and norm properties
- Conjugation identities
- SL(2,ℤ) action on Pythagorean quadruple parameters
- Lagrange's four-square theorem statement
- Degen's eight-square identity (octonion norm)
-/

set_option maxHeartbeats 1600000

/-! ## Integer Quaternion Structure -/

/-- An integer quaternion a + bi + cj + dk. -/
@[ext]
structure IntQuaternion where
  re : ℤ
  im_i : ℤ
  im_j : ℤ
  im_k : ℤ
  deriving Repr, DecidableEq

namespace IntQuaternion

/-- The norm of an integer quaternion: a² + b² + c² + d². -/
def norm (q : IntQuaternion) : ℤ :=
  q.re^2 + q.im_i^2 + q.im_j^2 + q.im_k^2

/-- Quaternion multiplication. -/
def mul (q₁ q₂ : IntQuaternion) : IntQuaternion where
  re := q₁.re * q₂.re - q₁.im_i * q₂.im_i - q₁.im_j * q₂.im_j - q₁.im_k * q₂.im_k
  im_i := q₁.re * q₂.im_i + q₁.im_i * q₂.re + q₁.im_j * q₂.im_k - q₁.im_k * q₂.im_j
  im_j := q₁.re * q₂.im_j - q₁.im_i * q₂.im_k + q₁.im_j * q₂.re + q₁.im_k * q₂.im_i
  im_k := q₁.re * q₂.im_k + q₁.im_i * q₂.im_j - q₁.im_j * q₂.im_i + q₁.im_k * q₂.re

/-- Quaternion conjugation. -/
def conj (q : IntQuaternion) : IntQuaternion where
  re := q.re
  im_i := -q.im_i
  im_j := -q.im_j
  im_k := -q.im_k

/-- The norm is multiplicative: N(q₁ · q₂) = N(q₁) · N(q₂). -/
theorem norm_mul (q₁ q₂ : IntQuaternion) :
    (mul q₁ q₂).norm = q₁.norm * q₂.norm := by
  simp only [norm, mul]
  ring

/-
Norm is zero iff the quaternion is zero.
-/
theorem norm_eq_zero_iff (q : IntQuaternion) :
    q.norm = 0 ↔ q = ⟨0, 0, 0, 0⟩ := by
      constructor <;> intro h <;> simp_all +decide [ IntQuaternion.norm ];
      exact IntQuaternion.ext ( by nlinarith ) ( by nlinarith ) ( by nlinarith ) ( by nlinarith )

/-- q · conj(q) has zero imaginary parts. -/
theorem mul_conj_im_i (q : IntQuaternion) : (mul q (conj q)).im_i = 0 := by
  simp only [mul, conj]; ring

theorem mul_conj_im_j (q : IntQuaternion) : (mul q (conj q)).im_j = 0 := by
  simp only [mul, conj]; ring

theorem mul_conj_im_k (q : IntQuaternion) : (mul q (conj q)).im_k = 0 := by
  simp only [mul, conj]; ring

/-- q · conj(q) has real part equal to the norm. -/
theorem mul_conj_re (q : IntQuaternion) : (mul q (conj q)).re = q.norm := by
  simp only [mul, conj, norm]; ring

/-- The norm of the conjugate equals the norm. -/
theorem norm_conj (q : IntQuaternion) : (conj q).norm = q.norm := by
  simp [norm, conj]

end IntQuaternion

/-! ## SL(2,ℤ) Action on Parameters -/

/-- The S generator of SL(2,ℤ) acting on (m,n): (m,n) ↦ (n, -m). -/
def sl2z_S (m n : ℤ) : ℤ × ℤ := (n, -m)

/-- The T generator of SL(2,ℤ) acting on (m,n): (m,n) ↦ (m+n, n). -/
def sl2z_T (m n : ℤ) : ℤ × ℤ := (m + n, n)

/-- S preserves the sum of squares m² + n². -/
theorem sl2z_S_preserves_norm (m n : ℤ) :
    (sl2z_S m n).1 ^ 2 + (sl2z_S m n).2 ^ 2 = m^2 + n^2 := by
  simp [sl2z_S]; ring

/-- The T generator preserves the Pythagorean quadruple property. -/
theorem sl2z_T_quadruple (m n p q : ℤ) :
    let (m', n') := sl2z_T m n
    let a' := m'^2 + n'^2 - p^2 - q^2
    let b' := 2*(m'*q + n'*p)
    let c' := 2*(n'*q - m'*p)
    let d' := m'^2 + n'^2 + p^2 + q^2
    a'^2 + b'^2 + c'^2 = d'^2 := by
  simp only [sl2z_T]
  ring

/-! ## Lagrange's Four-Square Theorem -/

/-- Lagrange's four-square theorem: every natural number is the sum of four squares. -/
theorem sum_four_squares_statement (n : ℕ) :
    ∃ a b c d : ℕ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = n :=
  Nat.sum_four_squares n

/-! ## Quaternion Associativity -/

/-- Quaternion multiplication is associative. -/
theorem quat_mul_assoc (p q r : IntQuaternion) :
    IntQuaternion.mul (IntQuaternion.mul p q) r =
    IntQuaternion.mul p (IntQuaternion.mul q r) := by
  ext <;> simp [IntQuaternion.mul] <;> ring

/-! ## Degen's Eight-Square Identity (Octonion Connection) -/

/-- Degen's eight-square identity: the product of two sums of eight squares
    is itself a sum of eight squares. This is the octonion norm multiplicativity.
    This identity is the algebraic foundation for potential 8D factoring lattices. -/
theorem degen_eight_square_identity
    (a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 + a₆^2 + a₇^2 + a₈^2) *
    (b₁^2 + b₂^2 + b₃^2 + b₄^2 + b₅^2 + b₆^2 + b₇^2 + b₈^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄ - a₅*b₅ - a₆*b₆ - a₇*b₇ - a₈*b₈)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃ + a₅*b₆ - a₆*b₅ - a₇*b₈ + a₈*b₇)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂ + a₅*b₇ + a₆*b₈ - a₇*b₅ - a₈*b₆)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁ + a₅*b₈ - a₆*b₇ + a₇*b₆ - a₈*b₅)^2 +
    (a₁*b₅ - a₂*b₆ - a₃*b₇ - a₄*b₈ + a₅*b₁ + a₆*b₂ + a₇*b₃ + a₈*b₄)^2 +
    (a₁*b₆ + a₂*b₅ - a₃*b₈ + a₄*b₇ - a₅*b₂ + a₆*b₁ - a₇*b₄ + a₈*b₃)^2 +
    (a₁*b₇ + a₂*b₈ + a₃*b₅ - a₄*b₆ - a₅*b₃ + a₆*b₄ + a₇*b₁ - a₈*b₂)^2 +
    (a₁*b₈ - a₂*b₇ + a₃*b₆ + a₄*b₅ - a₅*b₄ - a₆*b₃ + a₇*b₂ + a₈*b₁)^2 := by
  ring