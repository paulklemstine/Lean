import Mathlib

/-!
# Dual Numbers and Automatic Differentiation

## Overview

This file formalizes the fundamental theorem connecting dual number arithmetic
to polynomial differentiation: evaluating a polynomial `p` at the dual number
`a + bε` (where `ε² = 0`) yields the pair `(p(a), p'(a) · b)`.

This is the algebraic foundation of **automatic differentiation** (AD), one of
the most important algorithms in modern machine learning and scientific computing.
The key insight is that the derivative computation emerges *automatically* from
the ring structure of dual numbers — no symbolic manipulation or finite differences
are needed.

## Main Results

* `dual_aeval_fst` — The real part of `p(a + bε)` is `p(a)`.
* `dual_aeval_snd` — The infinitesimal part of `p(a + bε)` is `p'(a) · b`.
* `dual_aeval_at_one` — Setting `b = 1`, the infinitesimal part is exactly `p'(a)`.
* `dual_aeval_chain_rule` — Composition of polynomials satisfies the chain rule.
* `dual_unit_iff` — A dual number is a unit iff its real part is a unit.
* `dual_eps_isNilpotent` — The element `ε` is nilpotent.

## Mathematical Significance

The dual number ring `R[ε]/(ε²)` is the simplest example of a *jet space* — it
captures first-order tangent information. The automatic differentiation theorem
says that the ring homomorphism property of polynomial evaluation *forces*
derivatives to appear: there is no choice involved, the Leibniz rule is
a consequence of the ring axioms plus `ε² = 0`.

## References

* Clifford, W.K. (1873). "Preliminary Sketch of Biquaternions"
* Wengert, R.E. (1964). "A simple automatic derivative evaluation program"
* Griewank, A. (2008). "Evaluating Derivatives: Principles and Techniques
  of Algorithmic Differentiation"
-/

noncomputable section

open Polynomial TrivSqZeroExt

variable {R : Type*} [CommSemiring R]

namespace DualAutoDiff

/-- Convenient notation: the dual number `a + bε` as a `DualNumber R`. -/
abbrev dualNum (a b : R) : DualNumber R := inl a + inr b

/-! ### Basic dual number properties -/

/-- The infinitesimal element ε is nilpotent: ε² = 0. This is the defining
relation of the dual number ring. -/
theorem dual_eps_sq : (DualNumber.eps : DualNumber R) ^ 2 = 0 := by
  rw [sq]
  exact DualNumber.eps_mul_eps

/-- ε is nilpotent (existential form). -/
theorem dual_eps_isNilpotent : IsNilpotent (DualNumber.eps : DualNumber R) :=
  ⟨2, dual_eps_sq⟩

/-! ### The Automatic Differentiation Theorem

The core result: evaluating a polynomial at the dual number `a + bε` gives
`(p(a), p'(a) · b)` — the derivative appears automatically from the
ring structure.
-/

/-
**Automatic Differentiation Theorem (Real Part).**
The first component of evaluating a polynomial at the dual number `a + bε`
is simply `p(a)` — the polynomial evaluated at the real part.

This follows from the fact that the first projection `fst : R[ε] → R`
is an algebra homomorphism.
-/
theorem dual_aeval_fst (p : R[X]) (a b : R) :
    (aeval (dualNum a b) p).fst = eval a p := by
  induction p using Polynomial.induction_on ; aesop;
  · aesop;
  · simp_all +decide [ pow_succ, mul_assoc, aeval_mul, aeval_X, aeval_C ];
    simp_all +decide [ ← mul_assoc ]

/-
**Automatic Differentiation Theorem (Infinitesimal Part).**
The second component of evaluating a polynomial at the dual number `a + bε`
is `p'(a) · b` — the derivative of `p` evaluated at `a`, scaled by `b`.

This is the heart of automatic differentiation: the derivative emerges
automatically from the ring multiplication rule of dual numbers, which
encodes the Leibniz product rule.
-/
theorem dual_aeval_snd (p : R[X]) (a b : R) :
    (aeval (dualNum a b) p).snd = eval a (derivative p) * b := by
  induction' p using Polynomial.induction_on' with p q hp hq;
  · simp +decide [ *, add_mul ];
  · simp +decide [ Algebra.algebraMap_eq_smul_one, Polynomial.derivative_monomial, mul_assoc, mul_comm, mul_left_comm ]

/-- Setting `b = 1`, the infinitesimal part extracts the derivative directly. -/
theorem dual_aeval_at_one (p : R[X]) (a : R) :
    (aeval (dualNum a 1) p).snd = eval a (derivative p) := by
  rw [dual_aeval_snd, mul_one]

/-- Setting `b = 1` and combining both components: evaluating at `a + ε`
gives the "jet" `(p(a), p'(a))`. -/
theorem dual_aeval_jet (p : R[X]) (a : R) :
    aeval (dualNum a 1) p = dualNum (eval a p) (eval a (derivative p)) := by
  ext
  · simp only [fst_add, fst_inl, fst_inr, add_zero]
    exact dual_aeval_fst p a 1
  · simp only [snd_add, snd_inl, snd_inr, zero_add]
    exact dual_aeval_at_one p a

/-! ### Chain Rule -/

/-
**Chain Rule for Polynomials via Dual Numbers.**
The derivative of a composition `q ∘ p` evaluated at `a` equals
`q'(p(a)) · p'(a)`. This is the chain rule, proved purely algebraically.
-/
theorem dual_aeval_chain_rule (p q : R[X]) (a : R) :
    eval a (derivative (q.comp p)) =
    eval (eval a p) (derivative q) * eval a (derivative p) := by
  convert dual_aeval_snd ( q.comp p ) a 1 using 1;
  · rw [ ← dual_aeval_at_one ];
  · rw [ Polynomial.derivative_comp, Polynomial.eval_mul, Polynomial.eval_comp ];
    rw [ mul_one, mul_comm ]

/-! ### Algebraic Structure of Dual Numbers -/

/-
A dual number is a unit if and only if its real part is a unit.
The infinitesimal part is irrelevant for invertibility.
Requires `CommRing` because the inverse involves negation:
`(a + bε)⁻¹ = a⁻¹ - a⁻²bε`.
-/
theorem dual_unit_iff {S : Type*} [CommRing S] (x : DualNumber S) :
    IsUnit x ↔ IsUnit x.fst := by
  convert TrivSqZeroExt.isUnit_iff_isUnit_fst

end DualAutoDiff

end