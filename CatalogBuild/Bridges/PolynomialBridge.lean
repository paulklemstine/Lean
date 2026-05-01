/-! # CatalogBuild.Bridges.PolynomialBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 6
-/

import Mathlib

/-- Degree of sum: deg(p + q) ≤ max(deg p, deg q). -/
theorem degree_add_le_bound {R : Type*} [Semiring R]
    (p q : Polynomial R) :
    (p + q).degree ≤ max p.degree q.degree :=
  Polynomial.degree_add_le p q


/-- Degree of product: deg(p * q) = deg p + deg q.
THE fundamental property of polynomial degree over integral domains. -/
theorem degree_mul_eq {R : Type*} [Semiring R] [NoZeroDivisors R]
    {p q : Polynomial R} :
    (p * q).degree = p.degree + q.degree :=
  Polynomial.degree_mul


/-- Degree of power: deg(p ^ n) = n • deg p. -/
theorem degree_pow_eq {R : Type*} [Semiring R] [NoZeroDivisors R] [Nontrivial R]
    (p : Polynomial R) (n : ℕ) :
    (p ^ n).degree = n • p.degree :=
  Polynomial.degree_pow p n


/-- Nonzero constant has degree 0. -/
theorem degree_const_eq_zero {R : Type*} [Semiring R] [Nontrivial R]
    {c : R} (hc : c ≠ 0) :
    (Polynomial.C c).degree = 0 :=
  Polynomial.degree_C hc


/-- Zero polynomial has degree ⊥ (negative infinity). -/
theorem degree_zero_eq_bot {R : Type*} [Semiring R] :
    (0 : Polynomial R).degree = ⊥ :=
  Polynomial.degree_zero


/-- Polynomials can be evaluated at ring elements: the map
exists and is well-defined. -/
theorem eval_at_element {R : Type*} [Semiring R]
    (p : Polynomial R) (x : R) :
    ∃ y, y = Polynomial.eval x p :=
  ⟨Polynomial.eval x p, rfl⟩

