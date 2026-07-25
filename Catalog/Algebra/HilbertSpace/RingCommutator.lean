/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Ring Commutator Calculus

## Overview

In any ring `R`, the **ring commutator** of two elements `a` and `b`
is defined as `rc a b = a * b - b * a`. This operation measures the failure of
commutativity and turns any associative ring into a Lie ring.

This file develops the algebraic calculus of ring commutators, proving fundamental
identities that are central to noncommutative algebra, quantum mechanics, and
representation theory.

## Main Definitions

* `rc a b` — The ring commutator `a * b - b * a`

## Main Results

### Basic Identities
* `rc_antisymm` — Antisymmetry: `rc a b = -(rc b a)`
* `rc_self` — `rc a a = 0`
* `rc_add_left` — Left additivity: `rc (a + b) c = rc a c + rc b c`
* `rc_add_right` — Right additivity: `rc a (b + c) = rc a b + rc a c`

### Product Rules (Leibniz Rules)
* `rc_mul_right` — `rc a (b * c) = rc a b * c + b * rc a c`
* `rc_mul_left` — `rc (a * b) c = a * rc b c + rc a c * b`

### The Jacobi Identity
* `rc_jacobi` — `rc a (rc b c) + rc b (rc c a) + rc c (rc a b) = 0`

### Power Formulas
* `rc_pow_of_comm_right` — When `rc a b` commutes with `b`:
  `rc a (b ^ n) = n • (rc a b * b ^ (n - 1))`
* `comm_iff_rc_eq_zero` — `a * b = b * a ↔ rc a b = 0`

### Double Commutator
* `rc_rc_left` — `rc a (rc a b) = a ^ 2 * b - 2 • (a * b * a) + b * a ^ 2`

## Mathematical Significance

The ring commutator is the algebraic engine behind:

1. **Quantum Mechanics**: The canonical commutation relation `[x̂, p̂] = iℏ`
   encodes the Heisenberg uncertainty principle. Our Leibniz rule generalizes
   to the quantum operator product expansion.

2. **Lie Theory**: Every associative algebra becomes a Lie algebra under the
   commutator bracket. The Jacobi identity is the foundational axiom.

3. **Matrix Analysis**: Commutator identities yield trace equalities
   (`tr([A,B]) = 0`) and are essential for studying matrix logarithms.

4. **Noncommutative Geometry**: Commutators replace derivatives in Connes'
   noncommutative differential calculus, with `[D, f]` playing the role of `df`.

## References

* Jacobson, N., "Structure of Rings", AMS Colloquium Publications
* Herstein, I.N., "Noncommutative Rings", MAA Carus Mathematical Monographs
-/

noncomputable section

variable {R : Type*} [Ring R]

/-! ### Definition -/

/-- The **ring commutator** of two elements in a ring.
`rc a b = a * b - b * a` measures the failure of commutativity. -/
def rc (a b : R) : R := a * b - b * a

/-! ### Basic Properties -/

/-
The commutator of an element with itself vanishes.
-/
theorem rc_self (a : R) : rc a a = 0 := by
  exact sub_self _

/-
**Antisymmetry**: swapping the arguments negates the commutator.
-/
theorem rc_antisymm (a b : R) : rc a b = -(rc b a) := by
  unfold rc;
  rw [ neg_sub ]

/-
Left additivity of the commutator.
-/
theorem rc_add_left (a b c : R) : rc (a + b) c = rc a c + rc b c := by
  unfold rc;
  rw [ add_mul, mul_add, sub_add_sub_comm ]

/-
Right additivity of the commutator.
-/
theorem rc_add_right (a b c : R) : rc a (b + c) = rc a b + rc a c := by
  unfold rc; simp +decide [ mul_add, add_mul ] ;
  abel1

/-
The commutator with zero on the left vanishes.
-/
theorem rc_zero_left (a : R) : rc (0 : R) a = 0 := by
  -- By definition of rc, we have rc 0 a = 0 * a - a * 0.
  simp [rc]

/-
The commutator with zero on the right vanishes.
-/
theorem rc_zero_right (a : R) : rc a (0 : R) = 0 := by
  -- Unfold rc, simp.
  simp [rc]

/-
The commutator with the multiplicative identity vanishes on the left.
-/
theorem rc_one_left (a : R) : rc (1 : R) a = 0 := by
  simp_all +decide [ rc ]

/-
The commutator with the multiplicative identity vanishes on the right.
-/
theorem rc_one_right (a : R) : rc a (1 : R) = 0 := by
  exact sub_eq_zero.mpr ( by simp +decide )

/-
Negation on the left negates the commutator.
-/
theorem rc_neg_left (a b : R) : rc (-a) b = -(rc a b) := by
  simp +decide [ rc ];
  rw [ neg_add_eq_sub ]

/-
Negation on the right negates the commutator.
-/
theorem rc_neg_right (a b : R) : rc a (-b) = -(rc a b) := by
  unfold rc;
  grind

/-! ### Integer Scalar Multiples -/

/-
Integer scalar multiplication on the left factors out.
-/
theorem rc_zsmul_left (n : ℤ) (a b : R) : rc (n • a) b = n • rc a b := by
  unfold rc;
  rw [ smul_sub, mul_smul_comm, smul_mul_assoc ]

/-
Integer scalar multiplication on the right factors out.
-/
theorem rc_zsmul_right (n : ℤ) (a b : R) : rc a (n • b) = n • rc a b := by
  unfold rc;
  rw [ smul_sub, mul_smul_comm, smul_mul_assoc ]

/-! ### Product Rules (Leibniz Rules)

These identities show that `rc a ·` acts as a derivation on the ring. -/

/-
**Right Leibniz Rule**: The commutator distributes over right multiplication.
This says that `b ↦ rc a b` is a derivation on `R`.
-/
theorem rc_mul_right (a b c : R) :
    rc a (b * c) = rc a b * c + b * rc a c := by
      unfold rc;
      grobner

/-
**Left Leibniz Rule**: The commutator distributes over left multiplication.
-/
theorem rc_mul_left (a b c : R) :
    rc (a * b) c = a * rc b c + rc a c * b := by
      unfold rc;
      simpa only [ mul_sub, sub_mul, ← mul_assoc ] using by abel1;

/-! ### The Jacobi Identity -/

/-
**The Jacobi Identity** for ring commutators.
This is the fundamental identity that makes every associative ring into
a Lie ring under the commutator bracket.
-/
theorem rc_jacobi (a b c : R) :
    rc a (rc b c) + rc b (rc c a) + rc c (rc a b) = 0 := by
      unfold rc;
      grind

/-! ### Commutativity Characterization -/

/-
Two elements commute if and only if their commutator vanishes.
-/
theorem comm_iff_rc_eq_zero (a b : R) :
    a * b = b * a ↔ rc a b = 0 := by
      rw [ show rc a b = a * b - b * a by rfl, sub_eq_zero ]

/-
The set of elements commuting with `a` is closed under multiplication.
-/
theorem rc_mul_of_comm (a b c : R)
    (hab : rc a b = 0) (hac : rc a c = 0) : rc a (b * c) = 0 := by
      rw [ rc_mul_right, hab, hac, MulZeroClass.zero_mul, MulZeroClass.mul_zero, add_zero ]

/-
The set of elements commuting with `a` is closed under addition.
-/
theorem rc_add_of_comm (a b c : R)
    (hab : rc a b = 0) (hac : rc a c = 0) : rc a (b + c) = 0 := by
      grind +suggestions

/-! ### Power Commutator Formula -/

/-
When `rc a b` commutes with `b`, the commutator with a power simplifies:
`rc a (b ^ n) = n • (rc a b * b ^ (n - 1))`.

This is the ring-theoretic analog of the differentiation rule `d/dx(x^n) = n·x^{n-1}`.
The hypothesis that `rc a b` commutes with `b` is essential.
-/
theorem rc_pow_of_comm_right (a b : R) (n : ℕ)
    (h : rc a b * b = b * rc a b) :
    rc a (b ^ n) = n • (rc a b * b ^ (n - 1)) := by
      rcases n with ( _ | n );
      · simp +decide [ rc, rc_one_right ];
      · induction' n with n ih <;> simp_all +decide [ pow_succ, Nat.succ_eq_add_one, mul_assoc, add_mul, mul_add ];
        simp_all +decide [ ← mul_assoc, ← add_mul, rc_mul_right ];
        simp +decide [ add_mul, mul_assoc ];
        simp +decide only [← h, ← mul_assoc];
        refine' Nat.recOn n _ _ <;> simp_all +decide [ pow_succ, mul_assoc ]

/-! ### The Trace Identity -/

/-
`rc a b + rc b a = 0` — the commutator is alternating.
-/
theorem rc_add_swap (a b : R) : rc a b + rc b a = 0 := by
  unfold rc;
  abel1

/-! ### Commutative Rings -/

/-
In a commutative ring, all commutators vanish.
-/
theorem rc_eq_zero_of_commRing {S : Type*} [CommRing S] (a b : S) :
    rc a b = 0 := by
      exact sub_eq_zero_of_eq ( mul_comm a b )

/-! ### Double Commutator Expansion -/

/-
**Double commutator**: `rc a (rc a b) = a² * b - 2 • (a * b * a) + b * a²`.
This appears in the Baker-Campbell-Hausdorff formula.
-/
theorem rc_rc_left (a b : R) :
    rc a (rc a b) = a ^ 2 * b - 2 • (a * b * a) + b * a ^ 2 := by
      unfold rc;
      grind +revert

end