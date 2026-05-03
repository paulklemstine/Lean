/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL₃ Tropical Satake Classification — Main Theorems

## Overview

This file proves the **GL₃ tropical Satake classification theorem on bounded
support**: a bounded-support tropical datum on the dominant chamber is realized
by a tropical Hecke element if and only if it satisfies the Satake admissibility
conditions. The realization is moreover unique, yielding a complete
classification of bounded-support tropical Hecke data.

## Main Results

* `facet_implies_levi12` — Adjacent facet ⟹ Levi₁₂ compatibility
* `facet_implies_levi23` — Adjacent facet ⟹ Levi₂₃ compatibility
* `levi12_implies_facet` — Levi₁₂ ⟹ adjacent facet compatibility
* `levi23_implies_facet` — Levi₂₃ ⟹ adjacent facet compatibility
* `levi12_iff_facet` — Levi₁₂ ↔ adjacent facet
* `levi12_iff_levi23` — Levi₁₂ ↔ Levi₂₃
* `levi12_implies_separability` — Levi₁₂ ⟹ additive separability
* `admissible_iff_separated` — Admissibility ↔ separated form
* `tropSatake_injective` — Injectivity of the tropical Satake transform
* `tropSatake_admissible` — Image elements are admissible
* `tropSatake_candidate_eq` — Candidate Hecke element reconstructs the datum
* `candidate_bounded_support` — Candidate has bounded support
* `gl3_tropSatake_surjective_on_bounded_support` — **Surjectivity**
* `gl3_tropSatake_bounded_support_classification` — **Unique existence**
* `gl3_tropSatake_mem_range_iff_admissible_bounded` — **Image ↔ admissible**

## Proof Strategy

The key mathematical insight is that the four admissibility conditions
(edge valuation, Levi₁₂, Levi₂₃, adjacent facet) are mutually equivalent
modulo the origin normalization, and each implies additive separability:

  `D(a, b) = D(a, 0) + D(0, b)`

This is proved by induction on the first coordinate using the Levi₁₂ condition
as a telescoping device. The inverse construction then reads off edge data
from the boundary values `D(a, 0)` and `D(0, b)`.
-/
import Mathlib
import Tropical.Satake.GL3.Defs

namespace TropSatakeGL3

/-! ## Equivalences Between Admissibility Conditions -/

/-- The adjacent facet condition implies Levi₁₂ compatibility.
    Proof: the facet condition says `D(a+1,b+1) - D(a,b+1) = D(a+1,b) - D(a,b)`,
    so by induction on `b` the first-direction increment is constant in `b`. -/
theorem facet_implies_levi12 (D : TropDatum) (hf : AdjacentFacetCompatible D) :
    Levi12Compatible D := by
  intro a b
  induction b with
  | zero => ring
  | succ n ih =>
    have hfn := hf a n
    linarith

/-- The adjacent facet condition implies Levi₂₃ compatibility. -/
theorem facet_implies_levi23 (D : TropDatum) (hf : AdjacentFacetCompatible D) :
    Levi23Compatible D := by
  intro a b
  induction a with
  | zero => ring
  | succ n ih =>
    have hfn := hf n b
    linarith

/-- Levi₁₂ compatibility implies the adjacent facet condition. -/
theorem levi12_implies_facet (D : TropDatum) (h12 : Levi12Compatible D) :
    AdjacentFacetCompatible D := by
  intro a b
  have h1 := h12 a (b + 1)
  have h2 := h12 a b
  linarith

/-- Levi₂₃ compatibility implies the adjacent facet condition. -/
theorem levi23_implies_facet (D : TropDatum) (h23 : Levi23Compatible D) :
    AdjacentFacetCompatible D := by
  intro a b
  have h1 := h23 (a + 1) b
  have h2 := h23 a b
  linarith

/-- Levi₁₂ and adjacent facet compatibility are equivalent. -/
theorem levi12_iff_facet (D : TropDatum) :
    Levi12Compatible D ↔ AdjacentFacetCompatible D :=
  ⟨levi12_implies_facet D, facet_implies_levi12 D⟩

/-- Levi₂₃ and adjacent facet compatibility are equivalent. -/
theorem levi23_iff_facet (D : TropDatum) :
    Levi23Compatible D ↔ AdjacentFacetCompatible D :=
  ⟨levi23_implies_facet D, facet_implies_levi23 D⟩

/-- All three Levi/facet conditions are mutually equivalent. -/
theorem levi12_iff_levi23 (D : TropDatum) :
    Levi12Compatible D ↔ Levi23Compatible D := by
  rw [levi12_iff_facet, levi23_iff_facet]

/-! ## Separability -/

/-- Levi₁₂ compatibility implies additive separability modulo the origin.
    This is proved by induction on `a`, telescoping the first-direction increments. -/
theorem levi12_implies_separability (D : TropDatum) (h12 : Levi12Compatible D) :
    ∀ a b : ℕ, D (a, b) = D (a, 0) + D (0, b) - D (0, 0) := by
  intro a b
  induction a with
  | zero => ring
  | succ n ih =>
    have h := h12 n b
    linarith

/-- The adjacent facet condition implies additive separability modulo the origin. -/
theorem facet_implies_separability (D : TropDatum) (hf : AdjacentFacetCompatible D) :
    ∀ a b : ℕ, D (a, b) = D (a, 0) + D (0, b) - D (0, 0) :=
  levi12_implies_separability D (facet_implies_levi12 D hf)

/-- Full admissibility is equivalent to the separated form with vanishing origin. -/
theorem admissible_iff_separated (D : TropDatum) :
    SatakeAdmissible D ↔
      (D (0, 0) = 0 ∧ ∀ a b : ℕ, D (a, b) = D (a, 0) + D (0, b)) := by
  constructor
  · intro ⟨hedge, h12, _, _⟩
    have h0 : D (0, 0) = 0 := hedge
    exact ⟨hedge, fun a b => by
      have := levi12_implies_separability D h12 a b; linarith⟩
  · intro ⟨h0, hsep⟩
    refine ⟨h0, ?_, ?_, ?_⟩
    · -- Levi12Compatible
      intro a b
      have h1 := hsep (a + 1) b
      have h2 := hsep a b
      have h3 := hsep (a + 1) 0
      have h4 := hsep a 0
      linarith
    · -- Levi23Compatible
      intro a b
      have h1 := hsep a (b + 1)
      have h2 := hsep a b
      have h3 := hsep 0 (b + 1)
      have h4 := hsep 0 b
      linarith
    · -- AdjacentFacetCompatible
      intro a b
      have h1 := hsep (a + 1) (b + 1)
      have h2 := hsep a b
      have h3 := hsep (a + 1) b
      have h4 := hsep a (b + 1)
      linarith

/-- Helper: admissible data satisfy the separability identity. -/
theorem admissible_sep (D : TropDatum) (hadm : SatakeAdmissible D) (a b : ℕ) :
    D (a, b) = D (a, 0) + D (0, b) := by
  have ⟨_, hsep⟩ := (admissible_iff_separated D).mp hadm
  exact hsep a b

/-! ## The Candidate Hecke Element -/

/-- Construct the candidate Hecke element from an admissible datum.
    The edge data are read directly from the boundary values of `D`. -/
noncomputable def candidateHecke (D : TropDatum) (hadm : SatakeAdmissible D) :
    TropHecke where
  edge1 := fun a => D (a, 0)
  edge2 := fun b => D (0, b)
  edge1_zero := hadm.1
  edge2_zero := hadm.1

/-! ## Injectivity -/

/-- The tropical Satake transform is injective: distinct Hecke elements
    produce distinct tropical data. -/
theorem tropSatake_injective : Function.Injective tropSatake := by
  intro h₁ h₂ heq
  have heqf : ∀ p : DomWt, tropSatake h₁ p = tropSatake h₂ p := fun p => by rw [heq]
  ext a
  · -- edge1
    have := heqf (a, 0)
    simp [tropSatake, h₁.edge2_zero, h₂.edge2_zero] at this
    exact this
  · -- edge2
    have := heqf (0, a)
    simp [tropSatake, h₁.edge1_zero, h₂.edge1_zero] at this
    exact this

/-! ## Forward Direction: Image Elements Are Admissible -/

/-- Every element in the image of the tropical Satake transform is admissible. -/
theorem tropSatake_admissible (h : TropHecke) :
    SatakeAdmissible (tropSatake h) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- EdgeValuationCompatible
    show h.edge1 0 + h.edge2 0 = 0
    rw [h.edge1_zero, h.edge2_zero, add_zero]
  · -- Levi12Compatible
    intro a b
    show h.edge1 (a + 1) + h.edge2 b - (h.edge1 a + h.edge2 b) =
         h.edge1 (a + 1) + h.edge2 0 - (h.edge1 a + h.edge2 0)
    ring
  · -- Levi23Compatible
    intro a b
    show h.edge1 a + h.edge2 (b + 1) - (h.edge1 a + h.edge2 b) =
         h.edge1 0 + h.edge2 (b + 1) - (h.edge1 0 + h.edge2 b)
    ring
  · -- AdjacentFacetCompatible
    intro a b
    show h.edge1 (a + 1) + h.edge2 (b + 1) + (h.edge1 a + h.edge2 b) =
         h.edge1 (a + 1) + h.edge2 b + (h.edge1 a + h.edge2 (b + 1))
    ring

/-! ## Backward Direction: Admissible Data Are Realized -/

/-- The tropical Satake transform of the candidate Hecke element equals
    the original datum. This is the core reconstruction theorem. -/
theorem tropSatake_candidate_eq (D : TropDatum) (hadm : SatakeAdmissible D) :
    tropSatake (candidateHecke D hadm) = D := by
  ext ⟨a, b⟩
  show D (a, 0) + D (0, b) = D (a, b)
  exact (admissible_sep D hadm a b).symm

/-- The candidate Hecke element has bounded support when the datum does. -/
theorem candidate_bounded_support (N : ℕ) (D : TropDatum)
    (hbd : BoundedSupport N D) (hadm : SatakeAdmissible D) :
    HeckeBoundedSupport N (candidateHecke D hadm) := by
  constructor
  · intro a ha
    exact hbd (a, 0) (by omega)
  · intro b hb
    exact hbd (0, b) (by omega)

/-! ## Main Classification Theorems -/

/-- **GL₃ Tropical Satake Surjectivity on Bounded Support.**
    Every bounded-support admissible tropical datum is realized by a
    tropical Hecke element with bounded support. -/
theorem gl3_tropSatake_surjective_on_bounded_support
    (N : ℕ) (D : TropDatum)
    (hbd : BoundedSupport N D)
    (hadm : SatakeAdmissible D) :
    ∃ h : TropHecke, HeckeBoundedSupport N h ∧ tropSatake h = D :=
  ⟨candidateHecke D hadm,
   candidate_bounded_support N D hbd hadm,
   tropSatake_candidate_eq D hadm⟩

/-- **GL₃ Tropical Satake Classification on Bounded Support.**
    The realization of an admissible bounded-support datum by a tropical
    Hecke element is unique. This combines surjectivity with injectivity. -/
theorem gl3_tropSatake_bounded_support_classification
    (N : ℕ) (D : TropDatum)
    (hbd : BoundedSupport N D)
    (hadm : SatakeAdmissible D) :
    ∃! h : TropHecke, HeckeBoundedSupport N h ∧ tropSatake h = D := by
  refine ⟨candidateHecke D hadm,
    ⟨candidate_bounded_support N D hbd hadm, tropSatake_candidate_eq D hadm⟩,
    ?_⟩
  intro h' ⟨_, heq⟩
  exact tropSatake_injective (heq.trans (tropSatake_candidate_eq D hadm).symm)

/-- **Image characterization (bounded support)**: a bounded-support datum
    is in the range of the tropical Satake transform from bounded-support
    Hecke elements if and only if it is Satake-admissible.

    This is the cleanest formal expression of the GL₃ tropical Satake
    classification on bounded support. -/
theorem gl3_tropSatake_mem_range_iff_admissible_bounded
    (N : ℕ) (D : TropDatum)
    (hbd : BoundedSupport N D) :
    (∃ h : TropHecke, HeckeBoundedSupport N h ∧ tropSatake h = D) ↔
    SatakeAdmissible D := by
  constructor
  · rintro ⟨h, _, heq⟩
    rw [← heq]
    exact tropSatake_admissible h
  · exact gl3_tropSatake_surjective_on_bounded_support N D hbd

/-- **Image characterization (general)**: a tropical datum is in the range
    of the tropical Satake transform if and only if it is Satake-admissible.
    No bounded-support assumption is needed for this direction. -/
theorem gl3_tropSatake_mem_range_iff_admissible (D : TropDatum) :
    (∃ h : TropHecke, tropSatake h = D) ↔ SatakeAdmissible D := by
  constructor
  · rintro ⟨h, heq⟩
    rw [← heq]
    exact tropSatake_admissible h
  · intro hadm
    exact ⟨candidateHecke D hadm, tropSatake_candidate_eq D hadm⟩

end TropSatakeGL3