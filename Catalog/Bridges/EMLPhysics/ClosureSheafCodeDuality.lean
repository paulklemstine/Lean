/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Closure-Sheaf Code Duality via Cellular Decoder Reconstruction

## Overview

We establish a finite duality between constraint-closure systems on finite cell complexes
and cellular decoder presentations. The main results are:

1. **Reconstruction (Theorem A)**: Every constraint system yields a canonical decoder
   whose codewords are exactly the valid (zero-defect) assignments.
2. **Inverse Reconstruction (Theorem B)**: Every decoder yields a canonical constraint
   system whose valid set contains the original codewords.
3. **Minimality (Theorem C)**: The canonical constraint system induced by a set of
   assignments has the smallest domains among all systems accepting those assignments.
   This is the cellular Myhill–Nerode theorem.
4. **Round-Trip Duality (Theorem D)**: Under a finite gluing axiom, the round-trip
   closure → decoder → closure recovers the original valid set exactly.
5. **Certified Decoder (Theorem E)**: The canonical decoder construction is sound,
   complete, and produces minimal domains via refinement.

## Mathematical Context

This formalizes the "closure-decoder duality": constraint propagation systems (modeling
local physics, CSP, or coding constraints) are equivalent to local decoder presentations.
The defect functional measures failure of local consistency, and minimization via a kernel
congruence gives a cellular Myhill–Nerode theorem. The finite gluing axiom bridges
pairwise local consistency to global codeword reconstruction.
-/

open Set Function Finset Classical

noncomputable section

namespace ClosureSheafCodeDuality

/-! ## Section 1: Finite Cell Complexes -/

/-- A finite cell complex: a finite type with a decidable, reflexive incidence relation. -/
structure CellComplex where
  Cell : Type*
  [cellFintype : Fintype Cell]
  [cellDecEq : DecidableEq Cell]
  Inc : Cell → Cell → Prop
  [incDecRel : DecidableRel Inc]
  inc_refl : ∀ σ, Inc σ σ

attribute [instance] CellComplex.cellFintype CellComplex.cellDecEq CellComplex.incDecRel

namespace CellComplex

variable (K : CellComplex)

/-- The star of a cell: all cells incident to it (including itself). -/
def star (σ : K.Cell) : Finset K.Cell :=
  Finset.univ.filter (K.Inc σ)

@[simp]
theorem mem_star_iff {σ τ : K.Cell} :
    τ ∈ K.star σ ↔ K.Inc σ τ := by
  simp [star]

theorem self_mem_star (σ : K.Cell) :
    σ ∈ K.star σ := by
  simp [K.inc_refl σ]

end CellComplex

/-! ## Section 2: Constraint Systems -/

variable {K : CellComplex} {Obs : Type*} [Fintype Obs] [DecidableEq Obs]

/-- An assignment of observables to cells. -/
abbrev Assignment (K : CellComplex) (Obs : Type*) := K.Cell → Obs

/-- A constraint system on a cell complex with observables.
    Assigns to each cell a finite domain of admissible values and to each pair
    of incident cells a pairwise compatibility constraint. -/
structure ConstraintSystem (K : CellComplex) (Obs : Type*) [Fintype Obs] [DecidableEq Obs] where
  /-- Local domain: admissible values at each cell -/
  domain : K.Cell → Finset Obs
  /-- Pairwise compatibility constraint on incident cells -/
  compat : K.Cell → K.Cell → Obs → Obs → Prop
  /-- Every domain is nonempty -/
  domainNonempty : ∀ σ, (domain σ).Nonempty

/-- An assignment is valid (zero-defect) if all values are in domains and
    all incident pairs satisfy compatibility. -/
def ConstraintSystem.IsValid (S : ConstraintSystem K Obs) (f : Assignment K Obs) : Prop :=
  (∀ σ, f σ ∈ S.domain σ) ∧
  (∀ σ τ, K.Inc σ τ → S.compat σ τ (f σ) (f τ))

/-- The set of all valid assignments (zero-defect global sections). -/
def ConstraintSystem.ValidSet (S : ConstraintSystem K Obs) : Set (Assignment K Obs) :=
  {f | S.IsValid f}

/-! ## Section 3: Cellular Decoders -/

/-- A cellular decoder: a local check predicate at each cell. -/
structure CellularDecoder (K : CellComplex) (Obs : Type*) where
  /-- Check predicate: whether assignment passes the check at cell σ -/
  check : K.Cell → (K.Cell → Obs) → Prop

/-- Codewords: assignments passing all checks. -/
def CellularDecoder.Codewords (D : CellularDecoder K Obs) : Set (K.Cell → Obs) :=
  {f | ∀ σ, D.check σ f}

/-- Soundness: codewords ⊆ target set. -/
def CellularDecoder.IsSoundFor (D : CellularDecoder K Obs) (W : Set (K.Cell → Obs)) : Prop :=
  D.Codewords ⊆ W

/-- Completeness: target set ⊆ codewords. -/
def CellularDecoder.IsCompleteFor (D : CellularDecoder K Obs) (W : Set (K.Cell → Obs)) : Prop :=
  W ⊆ D.Codewords

/-! ## Section 4: Defect Functional -/

/-- Domain defect at a cell: the value is not in the admissible domain. -/
def domainDefect (S : ConstraintSystem K Obs) (f : Assignment K Obs) (σ : K.Cell) : Prop :=
  f σ ∉ S.domain σ

/-- Compatibility defect at a pair of cells. -/
def compatDefect (S : ConstraintSystem K Obs) (f : Assignment K Obs)
    (σ τ : K.Cell) : Prop :=
  K.Inc σ τ ∧ ¬S.compat σ τ (f σ) (f τ)

/-- An assignment is zero-defect iff it is valid. -/
theorem zero_defect_iff_valid (S : ConstraintSystem K Obs) (f : Assignment K Obs) :
    (∀ σ, ¬domainDefect S f σ) ∧ (∀ σ τ, ¬compatDefect S f σ τ) ↔ S.IsValid f := by
  unfold domainDefect compatDefect ConstraintSystem.IsValid
  constructor
  · intro ⟨hd, hc⟩
    simp only [not_not] at hd
    refine ⟨hd, fun σ τ hinc => ?_⟩
    have := hc σ τ
    push_neg at this
    exact this hinc
  · intro ⟨hd, hc⟩
    exact ⟨fun σ h => h (hd σ), fun σ τ ⟨hinc, hnc⟩ => hnc (hc σ τ hinc)⟩

/-- The number of domain defects. -/
def domainDefectCount (S : ConstraintSystem K Obs) (f : Assignment K Obs) : ℕ :=
  (Finset.univ.filter (fun σ => f σ ∉ S.domain σ)).card

/-- Zero domain defects means all values are in their domains. -/
theorem domainDefectCount_eq_zero_iff (S : ConstraintSystem K Obs) (f : Assignment K Obs) :
    domainDefectCount S f = 0 ↔ ∀ σ, f σ ∈ S.domain σ := by
  simp [domainDefectCount, Finset.filter_eq_empty_iff]

/-! ## Section 5: Closure Operators -/

/-- A finite closure operator on sets of a type. -/
structure FinClosureOp (α : Type*) where
  cl : Set α → Set α
  extensive : ∀ S, S ⊆ cl S
  monotone : ∀ S T, S ⊆ T → cl S ⊆ cl T
  idempotent : ∀ S, cl (cl S) = cl S

/-- The identity closure operator. -/
def FinClosureOp.identity (α : Type*) : FinClosureOp α where
  cl := id
  extensive _ := Subset.rfl
  monotone _ _ h := h
  idempotent _ := rfl

/-- A set is closed iff it is a fixed point of the closure operator. -/
def FinClosureOp.IsClosed (C : FinClosureOp α) (S : Set α) : Prop :=
  C.cl S = S

/-- The closure of any set is closed. -/
theorem FinClosureOp.cl_isClosed (C : FinClosureOp α) (S : Set α) :
    C.IsClosed (C.cl S) :=
  C.idempotent S

/-! ## Section 6: Closure-Cosheaf Systems -/

/-- A closure-cosheaf system: a constraint system enriched with a closure operator
    whose domains are closed sets. This connects constraint propagation to closure
    semantics: the domains are exactly the fixed points of closure at each cell. -/
structure ClosureCosheafSystem (K : CellComplex) (Obs : Type*) [Fintype Obs] [DecidableEq Obs]
    extends ConstraintSystem K Obs where
  /-- Closure operator on observables -/
  closure : FinClosureOp Obs
  /-- Domains are closed under the closure operator -/
  domainsClosed : ∀ σ, closure.cl (↑(domain σ) : Set Obs) = ↑(domain σ)

/-! ## Section 7: Canonical Constructions

The canonical decoder from a constraint system checks domain membership and compatibility.
The canonical constraint system from a set of assignments uses projections as domains
and co-occurrence as compatibility. These are the two directions of the duality. -/

/-- The canonical decoder from a constraint system:
    checks domain membership and pairwise compatibility at each cell. -/
def canonicalDecoder (S : ConstraintSystem K Obs) : CellularDecoder K Obs where
  check σ f := f σ ∈ S.domain σ ∧ ∀ τ, K.Inc σ τ → S.compat σ τ (f σ) (f τ)

/-- The canonical constraint system from a nonempty set of assignments:
    domains are projections, compatibility is co-occurrence in W. -/
def canonicalConstraint (W : Set (Assignment K Obs))
    (hne : W.Nonempty) : ConstraintSystem K Obs where
  domain σ := Finset.univ.filter (fun a => ∃ f ∈ W, f σ = a)
  compat σ τ a b := ∃ f ∈ W, f σ = a ∧ f τ = b
  domainNonempty σ := by
    obtain ⟨f, hf⟩ := hne
    exact ⟨f σ, Finset.mem_filter.mpr ⟨Finset.mem_univ _, f, hf, rfl⟩⟩

/-! ## Section 8: Core Duality Theorems -/

/-- **Theorem A (Closure-to-Decoder Reconstruction):**
    The canonical decoder's codewords are exactly the valid assignments of the
    constraint system. This is a sound and complete reconstruction. -/
theorem canonical_decoder_codewords_eq (S : ConstraintSystem K Obs) :
    (canonicalDecoder S).Codewords = S.ValidSet := by
  ext f
  simp only [CellularDecoder.Codewords, canonicalDecoder, ConstraintSystem.ValidSet,
    ConstraintSystem.IsValid, Set.mem_setOf_eq]
  constructor
  · intro h; exact ⟨fun σ => (h σ).1, fun σ τ hinc => (h σ).2 τ hinc⟩
  · intro ⟨hdom, hcompat⟩ σ; exact ⟨hdom σ, fun τ hinc => hcompat σ τ hinc⟩

/-- The canonical decoder is sound for the valid set. -/
theorem canonical_decoder_sound (S : ConstraintSystem K Obs) :
    (canonicalDecoder S).IsSoundFor S.ValidSet :=
  (canonical_decoder_codewords_eq S).symm ▸ Subset.rfl

/-- The canonical decoder is complete for the valid set. -/
theorem canonical_decoder_complete (S : ConstraintSystem K Obs) :
    (canonicalDecoder S).IsCompleteFor S.ValidSet :=
  (canonical_decoder_codewords_eq S).symm ▸ Subset.rfl

/-- **Theorem B (Decoder-to-Closure Canonicalization):**
    The canonical constraint system induced by a set of assignments W
    has valid set containing W. -/
theorem canonical_constraint_contains (W : Set (Assignment K Obs))
    (hne : W.Nonempty) :
    W ⊆ (canonicalConstraint W hne).ValidSet := by
  intro f hf
  refine ⟨fun σ => ?_, fun σ τ _ => ?_⟩
  · simp only [canonicalConstraint, Finset.mem_filter, Finset.mem_univ, true_and]
    exact ⟨f, hf, rfl⟩
  · exact ⟨f, hf, rfl, rfl⟩

/-- **Theorem C (Minimality — Cellular Myhill–Nerode):**
    The canonical constraint system has the smallest domains among all constraint
    systems whose valid set contains W. This is the finite analogue of the
    Myhill–Nerode theorem: the canonical system uses only *reachable* states. -/
theorem canonical_constraint_minimal_domain (W : Set (Assignment K Obs))
    (hne : W.Nonempty) (S : ConstraintSystem K Obs) (h : W ⊆ S.ValidSet) :
    ∀ σ, (canonicalConstraint W hne).domain σ ⊆ S.domain σ := by
  intro σ a
  simp only [canonicalConstraint, Finset.mem_filter, Finset.mem_univ, true_and]
  intro ⟨f, hf, hfa⟩
  rw [← hfa]; exact (h hf).1 σ

/-- Minimality also holds for compatibility constraints. -/
theorem canonical_constraint_minimal_compat (W : Set (Assignment K Obs))
    (hne : W.Nonempty) (S : ConstraintSystem K Obs) (h : W ⊆ S.ValidSet) :
    ∀ σ τ a b, (canonicalConstraint W hne).compat σ τ a b →
    K.Inc σ τ → S.compat σ τ a b := by
  intro σ τ a b ⟨f, hf, hfa, hfb⟩ hinc
  rw [← hfa, ← hfb]; exact (h hf).2 σ τ hinc

/-! ## Section 9: Pairwise Consistency and the Finite Gluing Property

The finite gluing property is the cellular analogue of the sheaf gluing condition.
It states that pairwise consistency (each pair of incident values co-occurs in some
valid assignment) implies global validity. Under this axiom, the round-trip
reconstruction is exact. -/

/-- An assignment is pairwise consistent if each value and each incident pair
    co-occurs with some valid assignment. -/
def PairwiseConsistent (S : ConstraintSystem K Obs) (f : Assignment K Obs) : Prop :=
  (∀ σ, ∃ g ∈ S.ValidSet, g σ = f σ) ∧
  (∀ σ τ, K.Inc σ τ → ∃ g ∈ S.ValidSet, g σ = f σ ∧ g τ = f τ)

/-- The finite gluing property: pairwise consistency implies global validity. -/
def ConstraintSystem.FiniteGluing (S : ConstraintSystem K Obs) : Prop :=
  ∀ f, PairwiseConsistent S f → S.IsValid f

/-- Every valid assignment is pairwise consistent. -/
theorem valid_implies_pairwise (S : ConstraintSystem K Obs) (f : Assignment K Obs)
    (hf : f ∈ S.ValidSet) : PairwiseConsistent S f :=
  ⟨fun _ => ⟨f, hf, rfl⟩, fun _ _ _ => ⟨f, hf, rfl, rfl⟩⟩

/-- **Theorem D (Round-Trip Duality under Gluing):**
    Under the finite gluing property, the canonical constraint system of the valid set
    has the same valid set as the original system. This is the core of the
    closure-decoder duality: constraint systems with gluing can be fully
    reconstructed from their valid assignments. -/
theorem round_trip_exact_with_gluing (S : ConstraintSystem K Obs)
    (hne : S.ValidSet.Nonempty) (hglue : S.FiniteGluing) :
    (canonicalConstraint S.ValidSet hne).ValidSet = S.ValidSet := by
  ext f
  constructor
  · intro hf
    apply hglue
    constructor
    · intro σ
      have hdom := hf.1 σ
      simp only [canonicalConstraint, Finset.mem_filter, Finset.mem_univ, true_and] at hdom
      exact hdom
    · intro σ τ hinc
      exact hf.2 σ τ hinc
  · intro hf; exact canonical_constraint_contains S.ValidSet hne hf

/-! ## Section 10: Extensibility and Domain Recovery -/

/-- A constraint system is extensible if every domain value extends to a valid assignment.
    This means every local state is *reachable* — it participates in some global solution. -/
def ConstraintSystem.Extensible (S : ConstraintSystem K Obs) : Prop :=
  ∀ σ, ∀ a ∈ S.domain σ, ∃ f ∈ S.ValidSet, f σ = a

/-- For extensible systems, the canonical constraint of the valid set
    recovers the original domains exactly. -/
theorem round_trip_domain_eq (S : ConstraintSystem K Obs) (hext : S.Extensible)
    (hne : S.ValidSet.Nonempty) :
    ∀ σ, (canonicalConstraint S.ValidSet hne).domain σ = S.domain σ := by
  intro σ; ext a
  simp only [canonicalConstraint, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro ⟨f, hf, hfa⟩; rw [← hfa]; exact hf.1 σ
  · intro ha; exact hext σ a ha

/-! ## Section 11: Kernel Congruence (Cellular Myhill–Nerode)

The zero-defect kernel congruence identifies observables that behave identically
in all valid assignments. The quotient by this congruence gives the minimal
state space — the cellular analogue of the Myhill–Nerode theorem for automata. -/

/-- Two observables are zero-defect equivalent at cell σ if swapping them in any
    valid assignment preserves validity in both directions. -/
def ZeroDefectEquiv (S : ConstraintSystem K Obs) (σ : K.Cell) (a b : Obs) : Prop :=
  a ∈ S.domain σ ∧ b ∈ S.domain σ ∧
  (∀ f, S.IsValid f → f σ = a → S.IsValid (Function.update f σ b)) ∧
  (∀ f, S.IsValid f → f σ = b → S.IsValid (Function.update f σ a))

/-- Zero-defect equivalence is reflexive on domain elements. -/
theorem zeroDefectEquiv_refl (S : ConstraintSystem K Obs) (σ : K.Cell) (a : Obs)
    (ha : a ∈ S.domain σ) : ZeroDefectEquiv S σ a a := by
  refine ⟨ha, ha, fun f hf hfa => ?_, fun f hf hfa => ?_⟩ <;>
  · have : Function.update f σ a = f := by
      ext τ; simp [Function.update_apply]; intro h; rw [h, hfa]
    rwa [this]

/-- Zero-defect equivalence is symmetric. -/
theorem zeroDefectEquiv_symm (S : ConstraintSystem K Obs) (σ : K.Cell) (a b : Obs) :
    ZeroDefectEquiv S σ a b → ZeroDefectEquiv S σ b a := fun ⟨ha, hb, hab, hba⟩ =>
  ⟨hb, ha, hba, hab⟩

/-- The reachable values at cell σ: values appearing in some valid assignment. -/
def reachableValues (S : ConstraintSystem K Obs) (σ : K.Cell) : Set Obs :=
  {a | ∃ f ∈ S.ValidSet, f σ = a}

/-- Reachable values are contained in the domain. -/
theorem reachableValues_subset_domain (S : ConstraintSystem K Obs) (σ : K.Cell) :
    reachableValues S σ ⊆ ↑(S.domain σ) := by
  intro a ⟨f, hf, hfa⟩; rw [← hfa]; exact hf.1 σ

/-- For extensible systems, reachable values equal the full domain. -/
theorem reachableValues_eq_domain (S : ConstraintSystem K Obs) (hext : S.Extensible)
    (σ : K.Cell) :
    reachableValues S σ = ↑(S.domain σ) :=
  Set.Subset.antisymm (reachableValues_subset_domain S σ) (fun _ ha => hext σ _ ha)

/-! ## Section 12: Codeword Equivalence -/

/-- Two constraint systems are codeword-equivalent if they have the same valid set. -/
def ConstraintSystem.CodewordEquiv (S₁ S₂ : ConstraintSystem K Obs) : Prop :=
  S₁.ValidSet = S₂.ValidSet

/-- Codeword equivalence is an equivalence relation. -/
theorem codewordEquiv_equivalence :
    Equivalence (ConstraintSystem.CodewordEquiv (K := K) (Obs := Obs)) where
  refl _ := rfl
  symm h := h.symm
  trans h₁ h₂ := h₁.trans h₂

/-- Under the gluing property, the canonical constraint system is codeword-equivalent
    to the original. -/
theorem canonicalConstraint_codewordEquiv (S : ConstraintSystem K Obs)
    (hne : S.ValidSet.Nonempty) (hglue : S.FiniteGluing) :
    ConstraintSystem.CodewordEquiv (canonicalConstraint S.ValidSet hne) S :=
  round_trip_exact_with_gluing S hne hglue

/-! ## Section 13: Certified Decoder -/

/-- A certified decoder for a constraint system: sound, complete, with
    codewords exactly equal to the valid set. -/
structure CertifiedDecoder (S : ConstraintSystem K Obs) where
  decoder : CellularDecoder K Obs
  sound : decoder.IsSoundFor S.ValidSet
  complete : decoder.IsCompleteFor S.ValidSet
  codeword_eq : decoder.Codewords = S.ValidSet

/-- **Theorem E (Certified Canonical Decoder):**
    Every constraint system admits a certified decoder. The canonical decoder
    is sound, complete, and its codewords equal the valid set. -/
def certifiedCanonicalDecoder (S : ConstraintSystem K Obs) :
    CertifiedDecoder S where
  decoder := canonicalDecoder S
  sound := canonical_decoder_sound S
  complete := canonical_decoder_complete S
  codeword_eq := canonical_decoder_codewords_eq S

/-! ## Section 14: Zero-Defect Sections Equal Codewords -/

/-- Global zero-defect sections: assignments satisfying all local constraints. -/
def GlobalZeroDefectSections (S : ConstraintSystem K Obs) : Set (Assignment K Obs) :=
  {f | ∀ σ, f σ ∈ S.domain σ ∧ ∀ τ, K.Inc σ τ → S.compat σ τ (f σ) (f τ)}

/-- Zero-defect sections equal the valid set. -/
theorem globalZeroDefect_eq_validSet (S : ConstraintSystem K Obs) :
    GlobalZeroDefectSections S = S.ValidSet := by
  ext f
  simp only [GlobalZeroDefectSections, ConstraintSystem.ValidSet, ConstraintSystem.IsValid,
    Set.mem_setOf_eq]
  exact ⟨fun h => ⟨fun σ => (h σ).1, fun σ τ hinc => (h σ).2 τ hinc⟩,
    fun ⟨hd, hc⟩ σ => ⟨hd σ, fun τ hinc => hc σ τ hinc⟩⟩

/-- **Codewords of the canonical decoder equal global zero-defect sections.** -/
theorem codewords_eq_globalZeroDefect (S : ConstraintSystem K Obs) :
    (canonicalDecoder S).Codewords = GlobalZeroDefectSections S := by
  rw [canonical_decoder_codewords_eq, globalZeroDefect_eq_validSet]

/-! ## Section 15: Refinement to Reachable States

The refinement operator projects a constraint system down to its reachable states:
domain values that actually appear in valid assignments. This is the algorithmic
core of the Myhill–Nerode minimization. -/

/-- Refine a constraint system to reachable values only:
    keep only domain elements that appear in some valid assignment. -/
def refineToReachable (S : ConstraintSystem K Obs)
    (hne : S.ValidSet.Nonempty) : ConstraintSystem K Obs where
  domain σ := (S.domain σ).filter (fun a => ∃ f ∈ S.ValidSet, f σ = a)
  compat := S.compat
  domainNonempty σ := by
    obtain ⟨f, hf⟩ := hne
    exact ⟨f σ, Finset.mem_filter.mpr ⟨hf.1 σ, f, hf, rfl⟩⟩

/-- Refined domains are subsets of original domains. -/
theorem refine_domain_subset (S : ConstraintSystem K Obs)
    (hne : S.ValidSet.Nonempty) (σ : K.Cell) :
    (refineToReachable S hne).domain σ ⊆ S.domain σ :=
  Finset.filter_subset _ _

/-- The refined system is extensible: every refined domain value is reachable. -/
theorem refine_extensible (S : ConstraintSystem K Obs)
    (hne : S.ValidSet.Nonempty) :
    (refineToReachable S hne).Extensible := by
  intro σ a ha
  simp only [refineToReachable, Finset.mem_filter] at ha
  obtain ⟨_, f, hf, hfa⟩ := ha
  refine ⟨f, ?_, hfa⟩
  exact ⟨fun τ => Finset.mem_filter.mpr ⟨hf.1 τ, f, hf, rfl⟩, hf.2⟩

/-- The refined system preserves valid assignments exactly. -/
theorem refine_valid_eq (S : ConstraintSystem K Obs)
    (hne : S.ValidSet.Nonempty) :
    (refineToReachable S hne).ValidSet = S.ValidSet := by
  ext f
  simp only [ConstraintSystem.ValidSet, ConstraintSystem.IsValid, Set.mem_setOf_eq]
  constructor
  · intro ⟨hd, hc⟩
    exact ⟨fun σ => refine_domain_subset S hne σ (hd σ), hc⟩
  · intro ⟨hd, hc⟩
    exact ⟨fun σ => Finset.mem_filter.mpr ⟨hd σ, f, ⟨hd, hc⟩, rfl⟩, hc⟩

/-- Refinement domains equal canonical constraint domains: both capture
    exactly the reachable states. -/
theorem refinement_is_canonical (S : ConstraintSystem K Obs)
    (hne : S.ValidSet.Nonempty) :
    ∀ σ, (refineToReachable S hne).domain σ =
      (canonicalConstraint S.ValidSet hne).domain σ := by
  intro σ; ext a
  simp only [refineToReachable, canonicalConstraint, Finset.mem_filter,
    Finset.mem_univ, true_and]
  constructor
  · intro ⟨_, h⟩; exact h
  · intro ⟨f, hf, hfa⟩; exact ⟨by rw [← hfa]; exact hf.1 σ, f, hf, hfa⟩

/-- **Certified Refinement Theorem:** The refinement to reachable states produces
    a system that is sound (same valid set), extensible (all states reachable),
    and minimal (smallest domains among all systems with the same valid set). -/
theorem certified_refinement (S : ConstraintSystem K Obs)
    (hne : S.ValidSet.Nonempty) :
    let R := refineToReachable S hne
    R.ValidSet = S.ValidSet ∧
    R.Extensible ∧
    ∀ (T : ConstraintSystem K Obs), S.ValidSet ⊆ T.ValidSet →
      ∀ σ, R.domain σ ⊆ T.domain σ := by
  refine ⟨refine_valid_eq S hne, refine_extensible S hne, fun T hT σ a ha => ?_⟩
  have ha' := ha
  simp only [refineToReachable, Finset.mem_filter] at ha'
  obtain ⟨_, f, hf, hfa⟩ := ha'
  rw [← hfa]; exact (hT hf).1 σ

/-! ## Section 16: Main Duality Theorem -/

/-- **Main Duality Theorem (Closure-Sheaf-Code Duality):**
    Under the finite gluing property, constraint systems and decoders are dual
    descriptions of the same mathematical object. The round-trip through canonical
    constructions preserves the valid set (= codewords = zero-defect sections). -/
theorem closure_sheaf_code_duality (S : ConstraintSystem K Obs)
    (hne : S.ValidSet.Nonempty) (hglue : S.FiniteGluing) :
    (canonicalDecoder S).Codewords = S.ValidSet ∧
    (canonicalConstraint S.ValidSet hne).ValidSet = S.ValidSet :=
  ⟨canonical_decoder_codewords_eq S, round_trip_exact_with_gluing S hne hglue⟩

/-- **Bidirectional Reconstruction:** For extensible systems, the canonical decoder
    is certified and the round-trip recovers the original domains exactly. -/
theorem bidirectional_reconstruction (S : ConstraintSystem K Obs)
    (hext : S.Extensible) (hne : S.ValidSet.Nonempty) :
    (canonicalDecoder S).Codewords = S.ValidSet ∧
    ∀ σ, (canonicalConstraint S.ValidSet hne).domain σ = S.domain σ :=
  ⟨canonical_decoder_codewords_eq S, round_trip_domain_eq S hext hne⟩

/-! ## Section 17: Defect Preservation -/

/-- For valid assignments, the system has zero domain defect. -/
theorem valid_zero_defect (S : ConstraintSystem K Obs)
    (f : Assignment K Obs) (hf : f ∈ S.ValidSet) :
    domainDefectCount S f = 0 := by
  rw [domainDefectCount_eq_zero_iff]; exact hf.1

/-- For valid assignments, the refined system also has zero defect. -/
theorem refined_valid_zero_defect (S : ConstraintSystem K Obs)
    (hne : S.ValidSet.Nonempty) (f : Assignment K Obs) (hf : f ∈ S.ValidSet) :
    domainDefectCount (refineToReachable S hne) f = 0 := by
  rw [domainDefectCount_eq_zero_iff]
  exact ((refine_valid_eq S hne).symm ▸ hf).1

/-! ## Section 18: Concrete Example — Path Graph Repetition Code -/

/-- A path graph on `Fin n`: cell `i` is incident to cell `j` if `|i - j| ≤ 1`. -/
def pathGraph (n : ℕ) (_hn : 0 < n) : CellComplex where
  Cell := Fin n
  Inc i j := (i : ℕ) = j ∨ (i : ℕ) + 1 = j ∨ (j : ℕ) + 1 = i
  incDecRel := inferInstance
  inc_refl _ := Or.inl rfl

/-- The repetition code on a path graph: all cells must have the same value.
    Compatibility requires equal values at incident cells. -/
def repetitionCode (n : ℕ) (hn : 0 < n) : ConstraintSystem (pathGraph n hn) Bool where
  domain _ := Finset.univ
  compat _ _ a b := a = b
  domainNonempty _ := ⟨true, Finset.mem_univ _⟩

/-- The repetition code is extensible: any value extends to a valid constant assignment. -/
theorem repetitionCode_extensible (n : ℕ) (hn : 0 < n) :
    (repetitionCode n hn).Extensible := by
  intro σ a _
  exact ⟨fun _ => a, ⟨fun _ => Finset.mem_univ _, fun _ _ _ => rfl⟩, rfl⟩

/-- The repetition code has the gluing property: if every pair of incident cells
    has a valid witness with those values, then the assignment is globally valid.
    For the equal-value constraint, this means pairwise equality implies global equality. -/
theorem repetitionCode_gluing (n : ℕ) (hn : 0 < n) :
    (repetitionCode n hn).FiniteGluing := by
  intro f ⟨_, hpair⟩
  refine ⟨fun σ => Finset.mem_univ _, fun σ τ hinc => ?_⟩
  obtain ⟨g, hg, hgσ, hgτ⟩ := hpair σ τ hinc
  have : g σ = g τ := hg.2 σ τ hinc
  rw [← hgσ, ← hgτ]; exact this

/-- The repetition code duality: decoder codewords = valid assignments. -/
theorem repetitionCode_duality (n : ℕ) (hn : 0 < n) :
    (canonicalDecoder (repetitionCode n hn)).Codewords =
    (repetitionCode n hn).ValidSet :=
  canonical_decoder_codewords_eq _

/-- The full duality for the repetition code, using all our machinery. -/
theorem repetitionCode_full_duality (n : ℕ) (hn : 0 < n) :
    let S := repetitionCode n hn
    (canonicalDecoder S).Codewords = S.ValidSet ∧
    ∀ hne : S.ValidSet.Nonempty,
      (canonicalConstraint S.ValidSet hne).ValidSet = S.ValidSet := by
  constructor
  · exact canonical_decoder_codewords_eq _
  · intro hne
    exact round_trip_exact_with_gluing _ hne (repetitionCode_gluing n hn)

end ClosureSheafCodeDuality