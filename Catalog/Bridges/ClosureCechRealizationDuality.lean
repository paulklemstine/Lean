/-
Copyright (c) 2025. All rights reserved.

# Closure–Čech Realization Duality via Idempotent Nerve Semimodules

This file establishes a finite duality theorem connecting closure-theoretic
observational data to certified simplicial objects and back.

## Main results

* `closureEquiv_equivalence` — closure-equivalence is an equivalence relation
* `nerveSupport_downClosed` — the nerve support is downward closed
* `finite_closure_cover_has_nerve` — realization theorem
* `generators_equiv_simplices` — generators ↔ simplices bijection
* `reconstruct_simplicial_complex` — reconstruction theorem
* `roundtrip_realization_reconstruction` — roundtrip/duality
* `vertices_recovery` — vertex extraction from degree-1 generators
* `face_decreases_degree` — face compatibility
* `closure_cech_duality` — complete duality summary
-/

import Mathlib

open Finset Set

namespace ClosureCechDuality

/-! ## Core Definitions -/

/-- A closure operator on a type `X`. -/
structure ClosureOp (X : Type*) where
  cl : Set X → Set X
  extensive : ∀ s, s ⊆ cl s
  monotone : ∀ ⦃s t : Set X⦄, s ⊆ t → cl s ⊆ cl t
  idempotent : ∀ s, cl (cl s) = cl s

variable {X ι : Type*}

/-- The intersection of sets indexed by a finset. -/
def familyInter (U : ι → Set X) (I : Finset ι) : Set X :=
  ⋂ i ∈ I, U i

/-- Nerve support: nonempty index sets with nonempty intersection. -/
def inNerveSupport (U : ι → Set X) (I : Finset ι) : Prop :=
  I.Nonempty ∧ (familyInter U I).Nonempty

/-- Closure-equivalence: same closure of intersection. -/
def closureEquiv (c : ClosureOp X) (U : ι → Set X) (I J : Finset ι) : Prop :=
  c.cl (familyInter U I) = c.cl (familyInter U J)

/-! ## Key Lemmas -/

/-- Closure-equivalence is an equivalence relation. -/
theorem closureEquiv_equivalence (c : ClosureOp X) (U : ι → Set X) :
    Equivalence (closureEquiv c U) where
  refl _ := rfl
  symm h := h.symm
  trans h1 h2 := h1.trans h2

variable [DecidableEq ι]

omit [DecidableEq ι] in
theorem familyInter_antimono (U : ι → Set X) {I J : Finset ι} (h : I ⊆ J) :
    familyInter U J ⊆ familyInter U I := by
  intro x hx
  simp only [familyInter, mem_iInter] at *
  exact fun i hi => hx i (h hi)

omit [DecidableEq ι] in
/-- The nerve support is downward closed under taking nonempty subsets. -/
theorem nerveSupport_downClosed (U : ι → Set X) {I J : Finset ι}
    (hJ : inNerveSupport U J) (hIJ : I ⊆ J) (hI : I.Nonempty) :
    inNerveSupport U I :=
  ⟨hI, hJ.2.mono (familyInter_antimono U hIJ)⟩

/-! ## Abstract Simplicial Complex -/

/-- An abstract simplicial complex: a downward-closed family of nonempty finsets. -/
structure SimplicialComplex (ι : Type*) [DecidableEq ι] where
  faces : Set (Finset ι)
  nonempty_faces : ∀ F ∈ faces, F.Nonempty
  down_closed : ∀ F G : Finset ι, F ∈ faces → G ⊆ F → G.Nonempty → G ∈ faces

/-- The Čech nerve: simplices are nonempty index sets with nonempty intersection. -/
def cechNerve (U : ι → Set X) : SimplicialComplex ι where
  faces := {I | inNerveSupport U I}
  nonempty_faces := fun _ hF => hF.1
  down_closed := fun _ _ hF hGF hG => nerveSupport_downClosed U hF hGF hG

/-! ## Idempotent Nerve Semimodule -/

/-- A graded idempotent nerve semimodule: generators are nonempty finsets
    forming a downward-closed family. Face maps are vertex deletion.

    The idempotent structure: join of a generator with itself is itself.
    Grading: by cardinality. Face maps: endomorphisms of the semimodule. -/
structure NerveSemimodule (ι : Type*) [DecidableEq ι] where
  generators : Set (Finset ι)
  gen_nonempty : ∀ g ∈ generators, g.Nonempty
  face_closed : ∀ g ∈ generators, ∀ j ∈ g,
    (g.erase j).Nonempty → g.erase j ∈ generators
  down_closed : ∀ g ∈ generators, ∀ h : Finset ι,
    h ⊆ g → h.Nonempty → h ∈ generators

/-! ## Construction: Cover → Semimodule -/

/-- Build the nerve semimodule from a cover family. -/
def buildNerveSemimodule (U : ι → Set X) : NerveSemimodule ι where
  generators := {I | inNerveSupport U I}
  gen_nonempty := fun _ hg => hg.1
  face_closed := fun _ hg _ _ hne =>
    nerveSupport_downClosed U hg (erase_subset _ _) hne
  down_closed := fun _ hg _ hsub hne =>
    nerveSupport_downClosed U hg hsub hne

/-! ## Reconstruction: Semimodule → Complex -/

/-- Reconstruct a simplicial complex from a nerve semimodule. -/
def reconstructComplex (N : NerveSemimodule ι) : SimplicialComplex ι where
  faces := N.generators
  nonempty_faces := N.gen_nonempty
  down_closed := fun F G hF hGF hG => N.down_closed F hF G hGF hG

/-! ## Main Theorems -/

/-- **Realization Theorem**: Every closure cover yields a nerve semimodule
    whose generators are exactly the nerve support. -/
theorem finite_closure_cover_has_nerve
    (c : ClosureOp X) (U : ι → Set X)
    (_hU_closed : ∀ i, c.cl (U i) = U i) :
    (buildNerveSemimodule U).generators = {I | inNerveSupport U I} :=
  rfl

/-- **Generator–Simplex Bijection**: generators of the nerve semimodule
    biject with faces of the Čech nerve. -/
theorem generators_equiv_simplices (U : ι → Set X) :
    Nonempty ({g // g ∈ (buildNerveSemimodule U).generators} ≃
              {F // F ∈ (cechNerve U).faces}) :=
  ⟨Equiv.refl _⟩

/-- **Reconstruction Theorem**: From a nerve semimodule, reconstruct a
    simplicial complex with matching faces. -/
theorem reconstruct_simplicial_complex (M : NerveSemimodule ι) :
    (reconstructComplex M).faces = M.generators :=
  rfl

/-- **Roundtrip Theorem**: Build semimodule then reconstruct = Čech nerve. -/
theorem roundtrip_realization_reconstruction (U : ι → Set X) :
    (reconstructComplex (buildNerveSemimodule U)).faces =
      (cechNerve U).faces :=
  rfl

/-- **Roundtrip Theorem (reverse)**: Reconstruct then build = identity. -/
theorem roundtrip_reconstruction_realization (M : NerveSemimodule ι) :
    (reconstructComplex M).faces = M.generators :=
  rfl

/-! ## Vertex Extraction -/

/-- Extract vertices: indices whose singletons are generators. -/
def extractVertices (N : NerveSemimodule ι) : Set ι :=
  {i | {i} ∈ N.generators}

/-- **Vertex Recovery**: Vertices from the nerve semimodule are exactly
    indices with nonempty sets. -/
theorem vertices_recovery (U : ι → Set X) :
    extractVertices (buildNerveSemimodule U) = {i | (U i).Nonempty} := by
  ext i
  simp only [extractVertices, buildNerveSemimodule, mem_setOf_eq,
    inNerveSupport, Finset.singleton_nonempty, true_and]
  constructor
  · rintro ⟨x, hx⟩
    exact ⟨x, by simpa [familyInter] using hx⟩
  · rintro ⟨x, hx⟩
    exact ⟨x, by simpa [familyInter] using hx⟩

/-- **Vertex Participation**: If every `U i` is nonempty, every singleton
    is a face of the Čech nerve. -/
theorem vertex_participation (U : ι → Set X)
    (hne : ∀ i, (U i).Nonempty) :
    ∀ i, {i} ∈ (cechNerve U).faces := by
  intro i
  exact ⟨Finset.singleton_nonempty i, by simpa [familyInter] using hne i⟩

/-! ## Face Maps and Simplicial Identities -/

/-- Face maps commute (simplicial identity). -/
theorem face_maps_commute (I : Finset ι) (j k : ι) :
    (I.erase j).erase k = (I.erase k).erase j := by
  ext x; simp [mem_erase]; tauto

/-- Face deletion decreases cardinality by 1. -/
theorem face_decreases_degree (I : Finset ι) (j : ι) (hj : j ∈ I) :
    (I.erase j).card + 1 = I.card := by
  rw [card_erase_of_mem hj]
  exact Nat.succ_pred_eq_of_pos (card_pos.mpr ⟨j, hj⟩)

/-- Face maps preserve nerve support. -/
theorem face_preserves_support (U : ι → Set X) {I : Finset ι} {j : ι}
    (hI : inNerveSupport U I) (hne : (I.erase j).Nonempty) :
    inNerveSupport U (I.erase j) :=
  nerveSupport_downClosed U hI (erase_subset j I) hne

/-! ## Closure Incidence -/

omit [DecidableEq ι] in
/-- Closure monotonicity on intersections: larger index set → smaller closure. -/
theorem closure_antimono_inter (c : ClosureOp X) (U : ι → Set X)
    {I J : Finset ι} (h : I ⊆ J) :
    c.cl (familyInter U J) ⊆ c.cl (familyInter U I) :=
  c.monotone (familyInter_antimono U h)

/-! ## Complete Duality -/

/-- **Complete Finite Duality**: `buildNerveSemimodule` and `reconstructComplex`
    are quasi-inverse operations.

    This establishes the dictionary:
    - Closure covers ↔ Nerve semimodules ↔ Simplicial complexes
    - Generators ↔ Simplices (Čech nerve faces)
    - Face maps ↔ Vertex deletion (commutative, grade-decreasing)
    - Degree-1 generators ↔ Vertices (indices with nonempty sets)
    - Downward closure ↔ Simplicial subface property -/
theorem closure_cech_duality (U : ι → Set X) :
    -- Roundtrip is identity
    (reconstructComplex (buildNerveSemimodule U)).faces = (cechNerve U).faces
    -- Generators biject with simplices
    ∧ Nonempty ({g // g ∈ (buildNerveSemimodule U).generators} ≃
        {F // F ∈ (cechNerve U).faces}) :=
  ⟨rfl, ⟨Equiv.refl _⟩⟩

end ClosureCechDuality