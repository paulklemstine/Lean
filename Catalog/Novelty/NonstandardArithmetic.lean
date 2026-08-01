/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A concrete ultrapower of the natural numbers

This file specializes Mathlib's filter germs (the existing ultraproduct
construction) to the cofinite ultrafilter on `ℕ`.  It records transfer for
predicates and relations, constructs the nonstandard element represented by
the identity sequence, and proves arithmetic facts that survive in this
non-Archimedean model.
-/

import Mathlib.ModelTheory.Ultraproducts
import Mathlib.Order.Filter.FilterProduct
import Mathlib.Order.Filter.Ultrafilter.Basic

open Filter Set

namespace NonstandardArithmetic

/-- The ultrapower of `ℕ` by Mathlib's cofinite-extending ultrafilter. -/
abbrev HyperNat := Filter.Germ (Filter.hyperfilter ℕ : Filter ℕ) ℕ

/-- The canonical embedding of ordinary naturals as constant sequences. -/
def standard (n : ℕ) : HyperNat := (n : HyperNat)

/-- The nonstandard natural represented by the identity sequence. -/
def omega : HyperNat := (fun n : ℕ => n : HyperNat)

/-- Unary predicates hold of a represented hypernatural exactly when they hold
on an ultrafilter-large set of indices. -/
theorem transfer_predicate (P : ℕ → Prop) (f : ℕ → ℕ) :
    Filter.Germ.LiftPred P (f : HyperNat) ↔ ∀ᶠ i in Filter.hyperfilter ℕ, P (f i) := by
  exact Filter.Germ.liftPred_coe

/-- Binary relations transfer pointwise to the ultrapower. -/
theorem transfer_relation (R : ℕ → ℕ → Prop) (f g : ℕ → ℕ) :
    Filter.Germ.LiftRel R (f : HyperNat) (g : HyperNat) ↔
      ∀ᶠ i in Filter.hyperfilter ℕ, R (f i) (g i) := by
  exact Filter.Germ.liftRel_coe

/-- Equality in the ultrapower is equality on an ultrafilter-large set. -/
theorem transfer_equality (f g : ℕ → ℕ) :
    (f : HyperNat) = (g : HyperNat) ↔ ∀ᶠ i in Filter.hyperfilter ℕ, f i = g i := by
  exact Filter.Germ.coe_eq

/-- The standard embedding is injective. -/
theorem standard_injective : Function.Injective standard := by
  intro m n h
  change (m : HyperNat) = (n : HyperNat) at h
  exact Filter.Germ.const_inj.mp h

/-- Addition of represented hypernaturals is computed pointwise. -/
theorem transfer_add (f g : ℕ → ℕ) :
    (f : HyperNat) + (g : HyperNat) = (fun i => f i + g i : HyperNat) := by
  exact (Filter.Germ.coe_add f g).symm

/-- Multiplication of represented hypernaturals is computed pointwise. -/
theorem transfer_mul (f g : ℕ → ℕ) :
    (f : HyperNat) * (g : HyperNat) = (fun i => f i * g i : HyperNat) := by
  exact (Filter.Germ.coe_mul f g).symm

/-- Every standard natural is strictly below `omega`. -/
theorem standard_lt_omega (n : ℕ) : standard n < omega := by
  change (fun _ : ℕ => n : HyperNat) < (fun i : ℕ => i : HyperNat)
  rw [Filter.Germ.coe_lt]
  apply Nat.hyperfilter_le_atTop
  filter_upwards [Filter.eventually_ge_atTop (n + 1)] with i hi
  exact Nat.lt_of_lt_of_le (Nat.lt_succ_self n) hi

/-- The identity hypernatural is not in the image of the standard embedding. -/
theorem omega_not_standard (n : ℕ) : omega ≠ standard n := by
  intro h
  exact (standard_lt_omega n).ne h.symm

/-- The ultrapower order is genuinely non-Archimedean: one element dominates
all embedded ordinary naturals. -/
theorem nonArchimedean_witness : ∃ H : HyperNat, ∀ n : ℕ, standard n < H := by
  exact ⟨omega, standard_lt_omega⟩

/-- Successor commutes with passage to the ultrapower. -/
theorem transfer_successor (f : ℕ → ℕ) :
    (fun i => f i + 1 : HyperNat) = (f : HyperNat) + 1 := by
  exact (Filter.Germ.coe_add f (fun _ => 1)).trans (congrArg ((f : HyperNat) + ·)
    Filter.Germ.coe_one)

/-- Every hypernatural has a strictly larger successor. -/
theorem lt_successor (H : HyperNat) : H < H + 1 := by
  refine Filter.Germ.inductionOn H ?_
  intro f
  change (f : HyperNat) < (fun i => f i + 1 : HyperNat)
  rw [Filter.Germ.coe_lt]
  exact Filter.Eventually.of_forall (fun i => Nat.lt_succ_self (f i))

/-- Consequently the nonstandard model has no greatest element. -/
theorem no_greatest_hypernatural (H : HyperNat) : ∃ K : HyperNat, H < K := by
  exact ⟨H + 1, lt_successor H⟩

/-- Divisibility of represented naturals transfers pointwise. -/
theorem transfer_dvd (f g : ℕ → ℕ) :
    Filter.Germ.LiftRel (· ∣ ·) (f : HyperNat) (g : HyperNat) ↔
      ∀ᶠ i in Filter.hyperfilter ℕ, f i ∣ g i := by
  exact Filter.Germ.liftRel_coe

/-- Every hypernatural is, on an ultrafilter-large set, either even or odd.
This is the transferred parity dichotomy. -/
theorem transferred_parity_dichotomy (H : HyperNat) :
    Filter.Germ.LiftPred (fun n => 2 ∣ n) H ∨
      Filter.Germ.LiftPred (fun n => 2 ∣ n + 1) H := by
  refine Filter.Germ.inductionOn H ?_
  intro f
  rw [Filter.Germ.liftPred_coe, Filter.Germ.liftPred_coe]
  apply (Filter.hyperfilter ℕ).eventually_or.mp
  exact Filter.Eventually.of_forall (fun i => by
    rcases Nat.even_or_odd' (f i) with ⟨k, hk | hk⟩
    · left
      exact ⟨k, hk⟩
    · right
      refine ⟨k + 1, ?_⟩
      simp [hk, Nat.mul_add, Nat.add_assoc])

/-- Euclidean division by two survives pointwise in the ultrapower. -/
theorem transferred_division_algorithm_two (f : ℕ → ℕ) :
    (f : HyperNat) = (fun i => 2 * (f i / 2) + f i % 2 : HyperNat) := by
  rw [Filter.Germ.coe_eq]
  exact Filter.Eventually.of_forall (fun i => by
    simpa [Nat.add_comm, Nat.mul_comm] using (Nat.mod_add_div (f i) 2).symm)

/-- Generic Łoś transfer for sentences, specialized only in name: an
ultraproduct satisfies a first-order sentence exactly when almost every factor
does.  This exposes Mathlib's existing ultraproduct construction for reuse by
arithmetic languages. -/
theorem los_transfer_sentence
    {I : Type*} (M : I → Type*) (U : Ultrafilter I)
    {L : FirstOrder.Language} [∀ i, L.Structure (M i)]
    [∀ i, Nonempty (M i)] (φ : L.Sentence) :
    (U : Filter I).Product M ⊨ φ ↔ ∀ᶠ i in U, M i ⊨ φ := by
  exact FirstOrder.Language.Ultraproduct.sentence_realize (M := M) (u := U) φ

end NonstandardArithmetic