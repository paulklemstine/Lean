import Mathlib

/-! # Polynomial Bridge

Proves fundamental results about polynomials:
1. Degree of sum: deg(p+q) ≤ max(deg p, deg q)
2. Degree of product: deg(p*q) = deg p + deg q (over integral domains)
3. Degree of power: deg(p^n) = n * deg p
4. Degree of monomials and zero

Polynomials are the most fundamental algebraic objects.
-/

namespace PolynomialBridge

/-! ## Section 1: Degree Bounds -/

/-- Degree of sum: deg(p + q) ≤ max(deg p, deg q). -/
theorem degree_add_le_bound {R : Type*} [Semiring R]
    (p q : Polynomial R) :
    (p + q).degree ≤ max p.degree q.degree :=
  Polynomial.degree_add_le p q

/-! ## Section 2: Degree of Product -/

/-- Degree of product: deg(p * q) = deg p + deg q.
    THE fundamental property of polynomial degree over integral domains. -/
theorem degree_mul_eq {R : Type*} [Semiring R] [NoZeroDivisors R]
    {p q : Polynomial R} :
    (p * q).degree = p.degree + q.degree :=
  Polynomial.degree_mul

/-! ## Section 3: Degree of Power -/

/-- Degree of power: deg(p ^ n) = n • deg p. -/
theorem degree_pow_eq {R : Type*} [Semiring R] [NoZeroDivisors R] [Nontrivial R]
    (p : Polynomial R) (n : ℕ) :
    (p ^ n).degree = n • p.degree :=
  Polynomial.degree_pow p n

/-! ## Section 4: Constants and Zero -/

/-- Nonzero constant has degree 0. -/
theorem degree_const_eq_zero {R : Type*} [Semiring R] [Nontrivial R]
    {c : R} (hc : c ≠ 0) :
    (Polynomial.C c).degree = 0 :=
  Polynomial.degree_C hc

/-- Zero polynomial has degree ⊥ (negative infinity). -/
theorem degree_zero_eq_bot {R : Type*} [Semiring R] :
    (0 : Polynomial R).degree = ⊥ :=
  Polynomial.degree_zero

/-! ## Section 5: Evaluation -/

/-- Polynomials can be evaluated at ring elements: the map
    exists and is well-defined. -/
theorem eval_at_element {R : Type*} [Semiring R]
    (p : Polynomial R) (x : R) :
    ∃ y, y = Polynomial.eval x p :=
  ⟨Polynomial.eval x p, rfl⟩

end PolynomialBridge
