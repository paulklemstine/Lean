/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Closure Barron Duality: Atomic Decomposition for Finite Distributive Lattices

This file formalizes a Barron-style atomic representation theorem for monotone
sup-preserving functionals on finite distributive lattices, connecting
lattice theory, idempotent mathematics, and interpretable machine learning.

## Main Results

* `birkhoff_sup_irred` — Birkhoff decomposition for finite distributive lattices.
* `sup_hom_eq_iSup_atoms` — Main representation theorem.
* `sup_hom_determined_by_sup_irred` — Determination by join-irreducibles.
* `reconstruct_canonical` — Round-trip reconstruction theorem.
* `closure_barron_duality_forward` — Forward direction of the duality.

## Mathematical Overview

In a finite distributive lattice L, Birkhoff's theorem says every element a
equals ⊔{j ∈ JI(L) | j ≤ a}. For f : L → ℝ≥0∞ monotone and sup-preserving
(f(a ⊔ b) = max(f(a), f(b))), we prove f(a) = ⨆ {f(j) | j join-irreducible, j ≤ a}.
This is the lattice-theoretic analogue of Barron's atomic decomposition.
-/

noncomputable section

open Classical Finset ENNReal

variable {L : Type*} [DistribLattice L] [OrderBot L] [Fintype L] [DecidableEq L]

/-- The finset of join-irreducible elements in a finite lattice. -/
def supIrredFinset (L : Type*) [SemilatticeSup L] [Fintype L] [DecidableEq L] : Finset L :=
  Finset.univ.filter (fun a => SupIrred a)

/-- The finset of join-irreducible elements below a given element. -/
def supIrredBelow (a : L) : Finset L :=
  Finset.univ.filter (fun j => SupIrred j ∧ j ≤ a)

/-- **Birkhoff Decomposition**: In a finite distributive lattice, every element
    equals the sup of the join-irreducible elements below it. -/
theorem birkhoff_sup_irred (a : L) :
    (supIrredBelow a).sup id = a := by
  refine' le_antisymm (Finset.sup_le fun x hx => Finset.mem_filter.mp hx |>.2.2) _
  induction' a using WellFoundedLT.induction with a ih
  by_cases ha : a = ⊥ ∨ SupIrred a
  · cases ha <;> simp +decide [*, supIrredBelow]
    exact Finset.le_sup (f := id) (by aesop)
  · obtain ⟨b, c, hb, hc, habc⟩ : ∃ b c : L, b < a ∧ c < a ∧ a = b ⊔ c := by
      simp_all +decide [SupIrred]
      rcases ha.2 ha.1 with ⟨b, c, rfl, hb, hc⟩
      exact ⟨b, lt_of_le_of_ne le_sup_left hb, c, lt_of_le_of_ne le_sup_right hc, rfl⟩
    refine' habc ▸ sup_le _ _
    · exact le_trans (ih b hb) (Finset.sup_mono fun x hx =>
        Finset.mem_filter.mpr ⟨Finset.mem_univ _,
          Finset.mem_filter.mp hx |>.2.1,
          le_trans (Finset.mem_filter.mp hx |>.2.2) le_sup_left⟩)
    · exact le_trans (ih c hc) (Finset.sup_mono fun x hx =>
        Finset.mem_filter.mpr ⟨Finset.mem_univ _,
          Finset.mem_filter.mp hx |>.2.1,
          le_trans (Finset.mem_filter.mp hx |>.2.2) le_sup_right⟩)

/-- A functional is sup-preserving if it commutes with binary sups (max). -/
def IsSupPreserving (f : L → ENNReal) : Prop :=
  ∀ a b : L, f (a ⊔ b) = f a ⊔ f b

/-- The canonical weight assignment: restriction of f to join-irreducibles. -/
def canonicalWeights (f : L → ENNReal) : L → ENNReal :=
  fun j => if SupIrred j then f j else 0

/-- The reconstructed functional from weights via sup-combination of atoms. -/
def reconstruct (w : L → ENNReal) : L → ENNReal :=
  fun K => ⨆ j ∈ supIrredFinset L, if j ≤ K then w j else 0

/-- A monotone sup-preserving functional distributes over finite sups. -/
theorem sup_preserving_finset_sup (f : L → ENNReal) (hf : Monotone f)
    (hsup : IsSupPreserving f) (hbot : f ⊥ = 0) (s : Finset L) :
    f (s.sup id) = s.sup f := by
  induction s using Finset.induction <;> simp_all +decide
  rw [hsup, ← ‹f (Finset.sup _ id) = Finset.sup _ f›]

/-- **Main Representation Theorem**: Every monotone sup-preserving functional
    on a finite distributive lattice equals the sup-combination of its values
    on join-irreducible atoms. f(K) = ⨆ {f(j) | j join-irreducible, j ≤ K}. -/
theorem sup_hom_eq_iSup_atoms (f : L → ENNReal) (hf : Monotone f)
    (hsup : IsSupPreserving f) (hbot : f ⊥ = 0) (K : L) :
    f K = ⨆ j ∈ supIrredBelow K, f j := by
  conv_lhs => rw [← birkhoff_sup_irred K]
  rw [sup_preserving_finset_sup f hf hsup hbot, Finset.sup_eq_iSup]

/-- Two monotone sup-preserving functionals agreeing on join-irreducibles
    are equal everywhere. -/
theorem sup_hom_determined_by_sup_irred
    (f g : L → ENNReal) (hf : Monotone f) (hg : Monotone g)
    (hfsup : IsSupPreserving f) (hgsup : IsSupPreserving g)
    (hfbot : f ⊥ = 0) (hgbot : g ⊥ = 0)
    (hJI : ∀ j : L, SupIrred j → f j = g j) :
    f = g := by
  funext K
  rw [sup_hom_eq_iSup_atoms f hf hfsup hfbot K, sup_hom_eq_iSup_atoms g hg hgsup hgbot K]
  exact iSup_congr fun j => iSup_congr fun hj => hJI j <| Finset.mem_filter.mp hj |>.2.1

/-
The reconstruct map is monotone.
-/
theorem reconstruct_monotone (w : L → ENNReal) :
    Monotone (reconstruct w) := by
  refine' fun a b hab => iSup_mono fun j => _;
  split_ifs <;> simp_all +decide [ le_trans ];
  exact False.elim ( ‹¬j ≤ b› ( le_trans ‹_› hab ) )

omit [OrderBot L] in
/-- The reconstruct map is sup-preserving. -/
theorem reconstruct_sup_preserving (w : L → ENNReal) :
    IsSupPreserving (reconstruct (L := L) w) := by
  intro a b; simp +decide [ reconstruct, Finset.sup_eq_iSup ] ;
  rw [ ← iSup_sup_eq ];
  congr with j ; by_cases hj : j ∈ supIrredFinset L <;> simp +decide [ hj ];
  split_ifs <;> simp_all +decide [ supIrredFinset ];
  · have := hj.2;
    contrapose! this;
    use j ⊓ a, j ⊓ b;
    simp_all +decide [ ← inf_sup_left ];
  · exact False.elim ( ‹¬j ≤ a ⊔ b› ( le_sup_of_le_left ‹_› ) );
  · exact False.elim ( ‹¬j ≤ a ⊔ b› ( le_sup_of_le_left ‹_› ) );
  · exact False.elim ( ‹¬j ≤ a ⊔ b› ( le_sup_of_le_right ‹_› ) )

/-
The reconstruct map sends ⊥ to 0.
-/
theorem reconstruct_bot (w : L → ENNReal) :
    reconstruct w (⊥ : L) = 0 := by
  -- No SupIrred j has j ≤ ⊥, so reconstructed f = 0.
  simp [reconstruct, Finset.sup_eq_bot_iff];
  intro i hi hi'; have := Finset.mem_filter.mp hi; simp_all +decide [ supIrredFinset ] ;

omit [OrderBot L] in
/-- Reconstruct of canonical weights equals biSup of f over join-irreducibles. -/
theorem reconstruct_canonical_eq (f : L → ENNReal) (K : L) :
    reconstruct (canonicalWeights f) K =
      ⨆ j ∈ supIrredFinset L, if j ≤ K then f j else 0 := by
  unfold reconstruct canonicalWeights;
  simp +decide [ supIrredFinset ];
  exact iSup_congr fun _ => iSup_congr fun _ => by aesop;

/-
Reconstruction with canonical weights recovers the original functional.
-/
theorem reconstruct_canonical (f : L → ENNReal) (hf : Monotone f)
    (hsup : IsSupPreserving f) (hbot : f ⊥ = 0) :
    reconstruct (canonicalWeights f) = f := by
  apply funext;
  intro x;
  rw [ reconstruct_canonical_eq, sup_hom_eq_iSup_atoms f hf hsup hbot x ];
  simp +decide [ supIrredFinset, supIrredBelow ];
  congr with j ; aesop

/-- A sparse representation of a functional f. -/
structure SparseAtomicRep (f : L → ENNReal) where
  support : Finset L
  weights : L → ENNReal
  support_supIrred : ∀ j ∈ support, SupIrred j
  weights_zero_outside : ∀ j, j ∉ support → weights j = 0
  represents : ∀ K : L,
    f K = ⨆ j ∈ support, if j ≤ K then weights j else 0

/-
Every monotone sup-preserving functional admits a sparse atomic representation.
-/
theorem sup_hom_sparse_rep (f : L → ENNReal) (hf : Monotone f)
    (hsup : IsSupPreserving f) (hbot : f ⊥ = 0) :
    ∃ rep : SparseAtomicRep f, rep.support ⊆ supIrredFinset L := by
  use ⟨supIrredFinset L, canonicalWeights f, by
    exact fun j hj => Finset.mem_filter.mp hj |>.2, by
    unfold canonicalWeights supIrredFinset; aesop;, by
    intro K;
    convert sup_hom_eq_iSup_atoms f hf hsup hbot K using 1;
    simp +decide [ supIrredBelow, canonicalWeights ];
    simp +decide [ supIrredFinset, iSup_and ];
    exact iSup_congr fun j => iSup_congr fun hj => by aesop;⟩

omit [OrderBot L] in
/-- Support bound: any sparse representation has support size bounded by
    the number of join-irreducible elements. -/
theorem sparse_support_bound (f : L → ENNReal) (rep : SparseAtomicRep f) :
    rep.support.card ≤ (supIrredFinset L).card :=
  Finset.card_le_card fun x hx =>
    Finset.mem_filter.mpr ⟨Finset.mem_univ _, rep.support_supIrred x hx⟩

/-- The closure variation norm: infimum total weight over all atomic decompositions. -/
def closureVariation (f : L → ENNReal) : ENNReal :=
  ⨅ (rep : SparseAtomicRep f), rep.support.sum rep.weights

/-- The type of monotone sup-preserving functionals with f(⊥) = 0. -/
structure SupHomFunctional (L : Type*) [DistribLattice L] [OrderBot L]
    [Fintype L] [DecidableEq L] where
  toFun : L → ENNReal
  monotone' : Monotone toFun
  sup_preserving' : IsSupPreserving toFun
  bot_zero' : toFun ⊥ = 0

/-- Forward map: extract canonical weights. -/
def SupHomFunctional.toWeights (f : SupHomFunctional L) : L → ENNReal :=
  canonicalWeights f.toFun

/-- Inverse map: reconstruct functional from weights. -/
def SupHomFunctional.fromWeights (w : L → ENNReal) : SupHomFunctional L where
  toFun := reconstruct w
  monotone' := reconstruct_monotone w
  sup_preserving' := reconstruct_sup_preserving w
  bot_zero' := reconstruct_bot w

/-- **Closure Barron Duality (Forward)**: reconstructing from canonical weights
    recovers the original functional. -/
theorem closure_barron_duality_forward (f : SupHomFunctional L) :
    (SupHomFunctional.fromWeights (f.toWeights)).toFun = f.toFun :=
  reconstruct_canonical f.toFun f.monotone' f.sup_preserving' f.bot_zero'

end