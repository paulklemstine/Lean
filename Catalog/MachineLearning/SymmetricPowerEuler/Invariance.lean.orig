/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Speculative.SymmetricPowerEuler.Defs
import Speculative.SymmetricPowerEuler.Recurrence

/-!
# Invariance of Symmetric Power Euler Factors

This file proves the central invariance theorem: the symmetric-power
Euler denominator depends only on the trace α+β and determinant αβ.

## Main results

- `euler_product_recursion`: The factored recursion for the Euler product.
- `symmPowerEulerDen_eq_eulerPhiRec`: E_n equals the trace-det recursive form.
- `symmPowerEulerDen_eq_of_trace_det_eq`: The main invariance theorem.
-/

open Finset BigOperators

/-! ## The Euler product recursion -/

theorem euler_product_recursion {R : Type*} [CommRing R]
    (n : ℕ) (α β X : R) :
    symmPowerEulerDen (n + 2) α β X =
      (1 - (α ^ (n + 2) + β ^ (n + 2)) * X + (α * β) ^ (n + 2) * X ^ 2) *
        symmPowerEulerDen n α β (α * β * X) := by
  unfold symmPowerEulerDen
  rw [Finset.prod_range_succ, Finset.prod_range_succ']
  simp +decide [mul_assoc, mul_comm, mul_left_comm, pow_succ, Nat.succ_sub_succ]
  rw [Finset.prod_congr rfl fun x hx => by
    rw [show n + 1 - x = n - x + 1 by
      rw [tsub_add_eq_add_tsub (Finset.mem_range_succ_iff.mp hx)]]]
  ring

/-! ## E_n equals the recursive trace-det form -/

theorem symmPowerEulerDen_eq_eulerPhiRec {R : Type*} [CommRing R]
    (n : ℕ) (α β X : R) :
    symmPowerEulerDen n α β X = eulerPhiRec (α + β) (α * β) X n := by
  induction' n using Nat.strongRecOn with n ih generalizing α β X
  rcases n with ( _ | _ | n )
  · simp +decide [symmPowerEulerDen, eulerPhiRec]
  · simp [symmPowerEulerDen, eulerPhiRec]
    simpa [Finset.prod_range_succ] using by ring
  · rw [euler_product_recursion, ih]
    · exact congr_arg₂ _ (by rw [← powerSumTwo_eq]) rfl
    · grind

/-! ## The main invariance theorem -/

/-- **Symmetric-power Euler denominator depends only on trace and determinant.**

For every n : ℕ, if two pairs (α,β) and (α',β') have the same trace and
determinant, they produce the same symmetric-power Euler denominator.

This is the invariant-theoretic heart of symmetric-power functoriality for GL₂:
the local L-factor is determined by the characteristic polynomial of the
Frobenius conjugacy class. -/
theorem symmPowerEulerDen_eq_of_trace_det_eq
    {R : Type*} [CommRing R]
    (n : ℕ) (α β α' β' X : R)
    (htr : α + β = α' + β')
    (hdet : α * β = α' * β') :
    (∏ k ∈ Finset.range (n + 1), (1 - α ^ (n - k) * β ^ k * X)) =
    (∏ k ∈ Finset.range (n + 1), (1 - α' ^ (n - k) * β' ^ k * X)) := by
  show symmPowerEulerDen n α β X = symmPowerEulerDen n α' β' X
  rw [symmPowerEulerDen_eq_eulerPhiRec, symmPowerEulerDen_eq_eulerPhiRec, htr, hdet]

/-- Corollary: the symmetric-power Euler denominator is symmetric in α and β. -/
theorem symmPowerEulerDen_symm {R : Type*} [CommRing R]
    (n : ℕ) (α β X : R) :
    symmPowerEulerDen n α β X = symmPowerEulerDen n β α X := by
  exact symmPowerEulerDen_eq_of_trace_det_eq n α β β α X (by ring) (by ring)