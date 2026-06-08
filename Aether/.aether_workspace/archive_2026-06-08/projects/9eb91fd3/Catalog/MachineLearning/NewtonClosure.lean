/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Speculative.SymmetricPowerEuler.Defs
import Speculative.SymmetricPowerEuler.Recurrence
import Speculative.SymmetricPowerEuler.Invariance

/-!
# Newton Closure for Symmetric-Power Weights

This file proves that every symmetric function of the weight multiset
W_n(a,b) = {a^{n-k} b^k | 0 ≤ k ≤ n} depends only on the trace t = a+b
and determinant d = a*b. This upgrades the invariance theorem from a
whole-product statement to a **coefficientwise universal algebra**.

## Builds on

- `symmTraceRec_eq_e1SymmPower` from Recurrence.lean
- `powerSumTwo_eq` from Recurrence.lean
- `symmPowerEulerDen_eq_eulerPhiRec` from Invariance.lean
-/

open Finset BigOperators Polynomial

/-! ## Power sums of the weight multiset -/

/-- Power sums of the symmetric-power weight multiset:
p_m(n; a,b) = ∑_{k=0}^{n} (a^{n-k} b^k)^m. -/
def powerSumWeights {R : Type*} [CommRing R] (n m : ℕ) (a b : R) : R :=
  ∑ k ∈ Finset.range (n + 1), (a ^ (n - k) * b ^ k) ^ m

/-- Power sums of weights equal e1SymmPower evaluated at (a^m, b^m). -/
theorem powerSumWeights_eq_e1SymmPower {R : Type*} [CommRing R]
    (n m : ℕ) (a b : R) :
    powerSumWeights n m a b = e1SymmPower n (a ^ m) (b ^ m) := by
  simp only [powerSumWeights, e1SymmPower]
  congr 1; ext k
  rw [mul_pow, pow_right_comm, pow_right_comm b]

/-- Power sums of weights equal the Chebyshev recurrence at
(powerSumTwo(t,d,m), d^m). -/
theorem powerSumWeights_eq_symmTraceRec {R : Type*} [CommRing R]
    (n m : ℕ) (a b : R) :
    powerSumWeights n m a b =
      symmTraceRec (powerSumTwo (a + b) (a * b) m) ((a * b) ^ m) n := by
  rw [powerSumWeights_eq_e1SymmPower, ← symmTraceRec_eq_e1SymmPower]
  congr 1
  · exact (powerSumTwo_eq m a b).symm
  · ring

/-- **Power sum closure**: p_m(n; a,b) depends only on (t,d). -/
theorem powerSumWeights_depends_on_trace_det {R : Type*} [CommRing R]
    (n m : ℕ) (a b a' b' : R)
    (ht : a + b = a' + b')
    (hd : a * b = a' * b') :
    powerSumWeights n m a b = powerSumWeights n m a' b' := by
  rw [powerSumWeights_eq_symmTraceRec, powerSumWeights_eq_symmTraceRec, ht, hd]

/-! ## Specific power sum formulas -/

/-- p_0(n; a, b) = n + 1. -/
theorem powerSumWeights_zero {R : Type*} [CommRing R] (n : ℕ) (a b : R) :
    powerSumWeights n 0 a b = (n + 1 : ℕ) := by
  simp [powerSumWeights, Finset.card_range]

/-- p_1(n; a, b) = e1SymmPower n a b. -/
theorem powerSumWeights_one {R : Type*} [CommRing R] (n : ℕ) (a b : R) :
    powerSumWeights n 1 a b = e1SymmPower n a b := by
  simp [powerSumWeights, e1SymmPower, pow_one]

/-- p_2(n; a, b) = symmTraceRec(t² − 2d, d², n). -/
theorem powerSumWeights_two_formula {R : Type*} [CommRing R]
    (n : ℕ) (a b : R) :
    powerSumWeights n 2 a b =
      symmTraceRec ((a + b) ^ 2 - 2 * (a * b)) ((a * b) ^ 2) n := by
  rw [powerSumWeights_eq_symmTraceRec]
  congr 1
  simp [powerSumTwo]; ring

/-! ## e1SymmPower closure -/

/-- e1SymmPower depends only on (t, d). -/
theorem e1SymmPower_depends_on_trace_det {R : Type*} [CommRing R]
    (n : ℕ) (a b a' b' : R)
    (ht : a + b = a' + b')
    (hd : a * b = a' * b') :
    e1SymmPower n a b = e1SymmPower n a' b' := by
  rw [← symmTraceRec_eq_e1SymmPower, ← symmTraceRec_eq_e1SymmPower, ht, hd]

/-! ## Polynomial-level Euler factor -/

/-- The symmetric-power Euler factor as a polynomial in R[X]. -/
noncomputable def symmPowerEulerPoly {R : Type*} [CommRing R]
    (n : ℕ) (a b : R) : R[X] :=
  ∏ k ∈ Finset.range (n + 1),
    (1 - Polynomial.C (a ^ (n - k) * b ^ k) * Polynomial.X)

/-- Evaluating the polynomial Euler factor recovers the ring-level one. -/
theorem symmPowerEulerPoly_eval {R : Type*} [CommRing R]
    (n : ℕ) (a b X : R) :
    Polynomial.eval X (symmPowerEulerPoly n a b) = symmPowerEulerDen n a b X := by
  simp only [symmPowerEulerPoly, symmPowerEulerDen]
  rw [Polynomial.eval_prod]
  congr 1; ext k
  simp [mul_assoc]

/-! ## Polynomial Euler product recursion -/

/-
**Polynomial-level Euler product recursion.**
The key structural identity that splits the degree-(n+3) product into a
quadratic factor times a shifted degree-(n+1) product.
-/
theorem euler_product_recursion_poly {R : Type*} [CommRing R]
    (n : ℕ) (a b : R) :
    symmPowerEulerPoly (n + 2) a b =
      (1 - Polynomial.C (a ^ (n + 2) + b ^ (n + 2)) * Polynomial.X +
        Polynomial.C ((a * b) ^ (n + 2)) * Polynomial.X ^ 2) *
      (symmPowerEulerPoly n a b).comp (Polynomial.C (a * b) * Polynomial.X) := by
  unfold symmPowerEulerPoly;
  rw [ Finset.prod_range_succ, Finset.prod_range_succ' ];
  simp +decide [ mul_assoc, mul_comm, mul_left_comm, pow_succ, ← mul_pow ];
  rw [ show ( ∏ x ∈ range ( n + 1 ), ( 1 - X * ( C b * ( C a ^ ( n + 1 - x ) * C b ^ x ) ) ) ) = ( ∏ x ∈ range ( n + 1 ), ( 1 - X * ( C a ^ ( n - x ) * C b ^ x ) ) |> Polynomial.comp <| Polynomial.X * ( C a * C b ) ) from ?_ ];
  · ring;
  · rw [ Polynomial.prod_comp ];
    refine' Finset.prod_congr rfl fun x hx => _;
    rw [ show n + 1 - x = n - x + 1 by rw [ tsub_add_eq_add_tsub ( Finset.mem_range_succ_iff.mp hx ) ] ] ; norm_num ; ring

/-! ## Coefficientwise invariance (direct inductive proof) -/

/-
**Coefficientwise invariance**: the polynomial Euler factor depends
only on (t, d), hence each coefficient does too.

Proved by strong induction on n using `euler_product_recursion_poly`.
-/
theorem symmPowerEulerPoly_eq_of_trace_det {R : Type*} [CommRing R]
    (n : ℕ) (a b a' b' : R)
    (ht : a + b = a' + b')
    (hd : a * b = a' * b') :
    symmPowerEulerPoly n a b = symmPowerEulerPoly n a' b' := by
  induction' n using Nat.strong_induction_on with n ih generalizing a b a' b';
  rcases n with ( _ | _ | n );
  · unfold symmPowerEulerPoly; simp +decide [ Finset.prod_range_succ' ] ;
  · simp +decide [ symmPowerEulerPoly, Finset.prod_range_succ ];
    ext i; simp +decide [ Polynomial.coeff_one, Polynomial.coeff_X, mul_assoc, sub_mul, mul_sub ] ; ring;
    rcases i with ( _ | _ | _ | i ) <;> simp +decide [ Polynomial.coeff_eq_zero_of_natDegree_lt ];
    · linear_combination -ht;
    · exact hd;
  · rw [ euler_product_recursion_poly, euler_product_recursion_poly ];
    rw [ ih n ( by linarith ) a b a' b' ht hd, hd ];
    rw [ ← powerSumTwo_eq, ← powerSumTwo_eq ];
    rw [ ht, hd ]

/-- Coefficientwise invariance: each coefficient of the polynomial
Euler factor depends only on trace and determinant. -/
theorem symmPowerEulerPoly_coeff_depends_on_trace_det {R : Type*} [CommRing R]
    (n j : ℕ) (a b a' b' : R)
    (ht : a + b = a' + b')
    (hd : a * b = a' * b') :
    (symmPowerEulerPoly n a b).coeff j = (symmPowerEulerPoly n a' b').coeff j := by
  rw [symmPowerEulerPoly_eq_of_trace_det n a b a' b' ht hd]

/-! ## Polynomial-level recursive Euler factor -/

/-- The recursive Euler factor as a polynomial in R[X], depending only on (t,d). -/
noncomputable def eulerPhiRecPoly {R : Type*} [CommRing R]
    (t d : R) : ℕ → R[X]
  | 0 => 1 - Polynomial.X
  | 1 => 1 - Polynomial.C t * Polynomial.X + Polynomial.C d * Polynomial.X ^ 2
  | n + 2 => (1 - Polynomial.C (powerSumTwo t d (n + 2)) * Polynomial.X +
              Polynomial.C (d ^ (n + 2)) * Polynomial.X ^ 2) *
              (eulerPhiRecPoly t d n).comp (Polynomial.C d * Polynomial.X)

/-- Evaluating eulerPhiRecPoly at X recovers the ring-level eulerPhiRec. -/
theorem eulerPhiRecPoly_eval {R : Type*} [CommRing R]
    (t d X : R) (n : ℕ) :
    Polynomial.eval X (eulerPhiRecPoly t d n) = eulerPhiRec t d X n := by
  induction' n using Nat.strong_induction_on with n ih generalizing X
  rcases n with ( _ | _ | n ) <;> simp_all +decide [eulerPhiRecPoly, eulerPhiRec]

/-! ## Recurrence identities -/

/-- The eulerPhiRec function satisfies a two-step recursion. -/
theorem eulerPhiRec_step {R : Type*} [CommRing R]
    (t d X : R) (n : ℕ) :
    eulerPhiRec t d X (n + 2) =
      (1 - powerSumTwo t d (n + 2) * X + d ^ (n + 2) * X ^ 2) *
        eulerPhiRec t d (d * X) n := by
  rfl

/-- The powerSumTwo oracle satisfies its own recurrence. -/
theorem powerSumTwo_recurrence {R : Type*} [CommRing R]
    (t d : R) (n : ℕ) :
    powerSumTwo t d (n + 2) = t * powerSumTwo t d (n + 1) - d * powerSumTwo t d n := by
  rfl

/-- The symmTraceRec oracle satisfies its own recurrence. -/
theorem symmTraceRec_recurrence {R : Type*} [CommRing R]
    (t d : R) (n : ℕ) :
    symmTraceRec t d (n + 2) = t * symmTraceRec t d (n + 1) - d * symmTraceRec t d n := by
  rfl