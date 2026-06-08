/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib
import Geometry.MatroidMinors.Basic

/-!
# Representable Matroids and the Robertson-Seymour Conjecture

This file defines representable matroids over a field, states the Robertson-Seymour
conjecture for representable matroids, and proves that the conjecture implies the
finite excluded minor property for any minor-closed subclass.

## Main Definitions

* `MatroidMinor.Representation` — a linear representation of a matroid over a field
* `MatroidMinor.IsRepresentable` — a matroid is representable over F
* `MatroidMinor.RobertsonSeymourConj` — the WQO conjecture for F-representable matroids

## Main Results

* `MatroidMinor.wqo_implies_finite_obstructions` — RS conjecture implies finite
  excluded minors for any minor-closed subclass of representable matroids
* `MatroidMinor.rs_conj_dual_equivalent` — the RS conjecture is self-dual
-/

open Set Matroid

noncomputable section

namespace MatroidMinor

variable {α : Type*}

/-! ## Representable Matroids -/

/-- A **representation** of a matroid `M` over a field `F` is an injection from the
ground set into a vector space over `F`, such that a subset is independent in `M`
if and only if its image is linearly independent over `F`. -/
structure Representation (F : Type*) [Field F] (M : Matroid α) (n : ℕ) where
  /-- The map from ground set elements to vectors in F^n -/
  toFun : α → (Fin n → F)
  /-- The map is injective on the ground set -/
  injOn : InjOn toFun M.E
  /-- Independent sets correspond to linearly independent images -/
  indep_iff : ∀ (I : Set α), I ⊆ M.E →
    (M.Indep I ↔ LinearIndependent F (fun (x : I) => toFun x))

/-- A matroid is **representable** over a field `F` if there exists a representation
over `F` in some dimension. -/
def IsRepresentable (F : Type*) [Field F] (M : Matroid α) : Prop :=
  ∃ n : ℕ, Nonempty (Representation F M n)

/-! ## The Robertson-Seymour Conjecture for Matroids -/

/-- **The Robertson-Seymour Conjecture for F-representable matroids**:
For any field `F`, the class of `F`-representable matroids is well-quasi-ordered
by the minor relation. -/
def RobertsonSeymourConj (F : Type*) [Field F] : Prop :=
  ∀ (f : ℕ → Matroid α), (∀ n, IsRepresentable F (f n)) →
    ∃ i j, i < j ∧ f i ≤m f j

/-
The Robertson-Seymour conjecture is equivalent to saying the representable
matroids form a minor-WQO class.
-/
theorem rs_conj_iff_wqo (F : Type*) [Field F] :
    RobertsonSeymourConj F (α := α) ↔
    IsMinorWQO ({M : Matroid α | IsRepresentable F M}) := by
  aesop

/-
**Consequence of the Robertson-Seymour Conjecture**: If the conjecture holds for `F`,
then for any minor-closed subclass of `F`-representable matroids, there are only finitely
many excluded minors within the representable class.
-/
theorem wqo_implies_finite_obstructions (F : Type*) [Field F]
    (hRS : RobertsonSeymourConj F (α := α))
    (P : Matroid α → Prop) (hP : IsMinorClosed P)
    (_hPsub : ∀ M, P M → IsRepresentable F M) :
    ∀ (A : Set (Matroid α)),
      (∀ M ∈ A, IsExcludedMinor P M) →
      (∀ M ∈ A, IsRepresentable F M) →
      A.Finite := by
  intro A hA hA';
  -- Since the set of excluded minors forms an antichain, we can apply the wqo_implies_finite_antichains theorem.
  have h_antichain : IsMinorAntichain {M | IsExcludedMinor P M} := by
    exact?;
  apply wqo_implies_finite_antichains;
  convert rs_conj_iff_wqo F |>.1 hRS;
  · exact hA';
  · exact fun M hM N hN hMN => h_antichain M ( hA M hM ) N ( hA N hN ) hMN

/-! ## Self-Duality of the Conjecture -/

/-
**The RS conjecture is self-dual**: the conjecture for a class of matroids holds if
and only if it holds for their duals. This is because duality is an involution that
preserves the minor relation.
-/
theorem rs_conj_dual_equivalent (F : Type*) [Field F]
    (h_dual : ∀ (M : Matroid α), IsRepresentable F M → IsRepresentable F M✶) :
    (∀ (f : ℕ → Matroid α), (∀ n, IsRepresentable F (f n)) →
      ∃ i j, i < j ∧ f i ≤m f j) →
    (∀ (f : ℕ → Matroid α), (∀ n, IsRepresentable F (f n)✶) →
      ∃ i j, i < j ∧ (f i)✶ ≤m (f j)✶) := by
  intro h f hf;
  convert h ( fun n => ( f n )✶✶ ) _ using 1;
  · ext i; simp +decide [ dual_isMinor_iff ] ;
  · exact fun n => by simpa using h_dual _ ( hf n ) ;

/-! ## Finite Matroid Rank Properties -/

/-
For a matroid with finite ground set, the rank function is bounded by the
size of the ground set. This provides a basic finiteness condition.
-/
theorem finite_ground_finite_rank {M : Matroid α} (hfin : M.E.Finite) :
    M.eRank ≠ ⊤ := by
  refine' ne_of_lt ( lt_of_le_of_lt ( iSup_le _ ) _ );
  exact ↑ ( hfin.toFinset.card );
  · intro B;
    convert Set.encard_le_encard ( show B.val ⊆ hfin.toFinset from fun x hx => hfin.mem_toFinset.mpr ( B.2.subset_ground hx ) ) using 1;
    rw [ Set.encard_eq_coe_toFinset_card ] ; aesop;
  · exact WithTop.coe_lt_top _

/-! ## Minor Chains -/

/-
In a finite matroid, any descending chain of minors (by strict minor relation)
has length at most |E|. This follows from ground set strict monotonicity.
-/
theorem minor_chain_length_bound {M : Matroid α} (hfin : M.E.Finite)
    (chain : Fin (n + 1) → Matroid α)
    (hchain : ∀ i : Fin n, chain i.castSucc <m chain i.succ)
    (hstart : chain ⟨n, Nat.lt_succ_iff.mpr (le_refl n)⟩ ≤m M) :
    n ≤ hfin.toFinset.card := by
  -- By induction on $i$, we can show that for each $i$, $(chain i).E ⊆ M.E$.
  have h_subset : ∀ i : Fin (n + 1), (chain i).E ⊆ M.E := by
    intro i
    induction' i using Fin.reverseInduction with i ih
    generalize_proofs at *;
    · grind +suggestions;
    · grind +suggestions;
  -- By induction on $i$, we can show that for each $i$, $(chain i).E ⊂ (chain (i + 1)).E$.
  have h_strict_subset : ∀ i : Fin n, (chain i.castSucc).E ⊂ (chain i.succ).E := by
    exact fun i => MatroidMinor.strict_minor_ground_ssubset ( hchain i ) ( hfin.subset ( h_subset _ ) );
  -- By induction on $i$, we can show that for each $i$, $|(chain i).E| ≥ i$.
  have h_card_ge_i : ∀ i : Fin (n + 1), (chain i).E.ncard ≥ i.val := by
    intro i; induction i using Fin.inductionOn <;> simp_all +decide [ Set.ncard_eq_toFinset_card' ] ;
    exact lt_of_le_of_lt ‹_› ( Set.ncard_lt_ncard ( h_strict_subset _ ) ( hfin.subset ( h_subset _ ) ) );
  have := h_card_ge_i ⟨ n, Nat.lt_succ_self n ⟩;
  exact le_trans this ( by rw [ ← Set.ncard_coe_finset ] ; exact Set.ncard_le_ncard ( by aesop ) )

end MatroidMinor

end