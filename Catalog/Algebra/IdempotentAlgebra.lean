/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Algebra of Idempotent Elements

## Overview

An element `e` of a ring `R` is **idempotent** if `e * e = e`. Despite their
seemingly simple definition, idempotents carry rich algebraic structure:
they form a Boolean algebra (in commutative rings), determine direct product
decompositions, and connect to representation theory and algebraic geometry.

This file develops the theory of idempotents with a focus on:
- Classification in integral domains (only trivial idempotents)
- Orthogonality properties
- The Boolean algebra operations on idempotents (meet, join, complement)
- Concrete characterization in `ZMod p` and product rings

## Main Results

* `IsIdempotentElem.eq_zero_or_one_of_noZeroDivisors` — In an integral domain,
  the only idempotents are `0` and `1`.
* `IsIdempotentElem.mul_one_sub_eq_zero` — Orthogonality: `e * (1 - e) = 0`.
* `IsIdempotentElem.add_sub_mul_idempotent` — Join: `e + f - ef` is idempotent.
* `IsIdempotentElem.sub_mul_idempotent` — Relative complement: `e - ef` is idempotent.
* `ZMod.isIdempotentElem_iff_eq_zero_or_one` — Complete characterization in `ZMod p`.
* `Prod.isIdempotentElem_iff` — Idempotents in product rings are pairs of idempotents.
* `IsIdempotentElem.pow_eq_self` — `e^n = e` for all `n ≥ 1`.

## Applications

Idempotent decomposition is fundamental to:
- **Representation theory**: Decomposing modules via idempotent endomorphisms
- **Algebraic geometry**: Connected components of `Spec(R)` correspond to
  primitive idempotents
- **Coding theory**: Idempotent generators of cyclic codes over finite fields
- **Signal processing**: Projection operators are self-adjoint idempotents
-/

section BasicIdempotentTheory

variable {R : Type*}

/-
An idempotent element multiplied by its complement is zero:
`e * (1 - e) = 0`. This is the fundamental orthogonality property
that underlies all idempotent decompositions.
-/
theorem IsIdempotentElem.mul_one_sub_eq_zero [NonAssocRing R] {e : R}
    (he : IsIdempotentElem e) : e * (1 - e) = 0 := by
  rw [ mul_sub, mul_one, he, sub_self ]

/-
The complement times the idempotent is also zero:
`(1 - e) * e = 0`.
-/
theorem IsIdempotentElem.one_sub_mul_eq_zero [NonAssocRing R] {e : R}
    (he : IsIdempotentElem e) : (1 - e) * e = 0 := by
  rw [ sub_mul, one_mul, he, sub_self ]

/-
**Classification in integral domains.** In a ring with no zero divisors,
the only idempotent elements are `0` and `1`. This is because `e² = e`
implies `e(e - 1) = 0`, so either `e = 0` or `e = 1`.
-/
theorem IsIdempotentElem.eq_zero_or_one_of_noZeroDivisors
    [Ring R] [NoZeroDivisors R] {e : R}
    (he : IsIdempotentElem e) : e = 0 ∨ e = 1 := by
  exact Classical.or_iff_not_imp_left.2 fun h => by simpa [ h, sub_eq_zero ] using he

/-
An idempotent raised to any positive power equals itself.
This follows by a simple induction using `e * e = e`.
-/
theorem IsIdempotentElem.pow_eq_self [Monoid R] {e : R}
    (he : IsIdempotentElem e) {n : ℕ} (hn : 0 < n) : e ^ n = e := by
  induction hn <;> simp_all +decide [ pow_succ ];
  exact he

/-
The Frobenius endomorphism fixes idempotents: in characteristic `p`,
`e^p = e` for any idempotent `e`. This connects the Freshman's Dream
to the theory of idempotents.
-/
theorem IsIdempotentElem.frobenius_fixed [CommSemiring R] {e : R}
    (he : IsIdempotentElem e) (p : ℕ) [Fact (Nat.Prime p)] [CharP R p] :
    frobenius R p e = e := by
  exact IsIdempotentElem.pow_eq_self he ( Nat.Prime.pos Fact.out )

end BasicIdempotentTheory

section IdempotentLattice

variable {R : Type*} [CommRing R]

/-
**Join of idempotents.** If `e` and `f` are idempotents in a commutative
ring, then `e + f - e * f` is idempotent. This operation serves as the
"join" (supremum) in the Boolean algebra of idempotents. Intuitively,
it corresponds to the union of the "support" of `e` and `f`.
-/
theorem IsIdempotentElem.add_sub_mul_idempotent {e f : R}
    (he : IsIdempotentElem e) (hf : IsIdempotentElem f) :
    IsIdempotentElem (e + f - e * f) := by
  simp_all +decide [IsIdempotentElem, mul_sub, mul_comm, mul_left_comm]
  grobner

/-
**Relative complement of idempotents.** If `e` and `f` are idempotents
in a commutative ring, then `e - e * f` is idempotent. This gives the
part of `e`'s "support" that doesn't overlap with `f`'s support.
-/
theorem IsIdempotentElem.sub_mul_idempotent {e f : R}
    (he : IsIdempotentElem e) (hf : IsIdempotentElem f) :
    IsIdempotentElem (e - e * f) := by
  unfold IsIdempotentElem at *;
  grind

/-
**Complementary orthogonality.** If `e` is idempotent, then
`e` and `1 - e` form a complete orthogonal idempotent system:
they are both idempotent, their product is zero, and they sum to 1.
This is the algebraic basis for direct sum decompositions `R = eR ⊕ (1-e)R`.
-/
theorem IsIdempotentElem.orthogonal_system {e : R}
    (he : IsIdempotentElem e) :
    IsIdempotentElem e ∧ IsIdempotentElem (1 - e) ∧
    e * (1 - e) = 0 ∧ e + (1 - e) = 1 := by
  simp_all +decide [ IsIdempotentElem, sub_mul, mul_sub ]

end IdempotentLattice

section ConcreteIdempotents

/-
**Idempotents in prime fields.** In `ZMod p` for a prime `p`,
an element is idempotent if and only if it equals `0` or `1`.
This follows from `ZMod p` being a field (hence an integral domain).
-/
theorem ZMod.isIdempotentElem_iff_eq_zero_or_one {p : ℕ} [Fact (Nat.Prime p)]
    (a : ZMod p) :
    IsIdempotentElem a ↔ a = 0 ∨ a = 1 :=
  IsIdempotentElem.iff_eq_zero_or_one

/-
**Idempotents in product rings.** An element of a product ring `R × S`
is idempotent if and only if both components are idempotent. This is the
key structural result that, combined with the Chinese Remainder Theorem,
allows counting idempotents in `ZMod n`.
-/
theorem Prod.isIdempotentElem_iff {R S : Type*} [Mul R] [Mul S]
    (x : R × S) :
    IsIdempotentElem x ↔ IsIdempotentElem x.1 ∧ IsIdempotentElem x.2 := by
  exact ⟨ fun h => ⟨ Prod.ext_iff.mp h |>.1, Prod.ext_iff.mp h |>.2 ⟩, fun h => Prod.ext h.1 h.2 ⟩

/-- The four idempotents of `ZMod 2 × ZMod 2` can be explicitly listed.
This is the simplest non-trivial example of the product idempotent theorem. -/
example : IsIdempotentElem ((0, 0) : ZMod 2 × ZMod 2) := by
  show (0, 0) * (0, 0) = (0, 0); decide
example : IsIdempotentElem ((1, 0) : ZMod 2 × ZMod 2) := by
  show (1, 0) * (1, 0) = (1, 0); decide
example : IsIdempotentElem ((0, 1) : ZMod 2 × ZMod 2) := by
  show (0, 1) * (0, 1) = (0, 1); decide
example : IsIdempotentElem ((1, 1) : ZMod 2 × ZMod 2) := by
  show (1, 1) * (1, 1) = (1, 1); decide

end ConcreteIdempotents