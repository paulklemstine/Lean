import Mathlib

/-!
# Layer 1: The isolated cyclotomic algebraic identity

This file is deliberately **independent** of the computational development of
Ramanujan's third–order mock theta function `ρ(q)` in
`Computation.RamanujanRhoSignLaw`.  It imports nothing from that file and is
imported by nothing in it, so there is no possible circular dependency between
the algebraic identity proved here and the sign law proved there.

The single result is the elementary cyclotomic factorisation
`(1 + Xᵏ + X²ᵏ)(1 - Xᵏ) = 1 - X³ᵏ`,
which is the algebraic reason that each cubic factor `1 + q^{2j+1} + q^{4j+2}`
appearing in the denominator of `ρ` is, up to the cyclotomic unit `1 - q^{2j+1}`,
the geometric factor `1 - q^{3(2j+1)}`.

It is proved purely from the ring axioms (`ring`), with no induction and no
reference to any sign-law theorem.
-/

open Polynomial

namespace CyclotomicIdentities

/-- The cyclotomic factorisation `(1 + Xᵏ + X²ᵏ)(1 - Xᵏ) = 1 - X³ᵏ`, valid in the
polynomial ring `R[X]` over an arbitrary commutative ring `R`.  Proved purely
from ring axioms. -/
theorem cyclotomic_factor {R : Type*} [CommRing R] (k : ℕ) :
    (1 + (X : R[X]) ^ k + X ^ (2 * k)) * (1 - X ^ k) = 1 - X ^ (3 * k) := by
  have h2 : (X : R[X]) ^ (2 * k) = X ^ k * X ^ k := by rw [two_mul, pow_add]
  have h3 : (X : R[X]) ^ (3 * k) = X ^ k * X ^ k * X ^ k := by
    rw [show 3 * k = k + k + k by ring, pow_add, pow_add]
  rw [h2, h3]; ring

end CyclotomicIdentities