/-
  An Abstract Order Framework for Minor-Closed Classes
  ====================================================

  This file provides the abstract order-theoretic scaffolding used by
  `ForestDensity.lean` and `MinorModel.lean`: a *minor-closed class* is nothing
  but a downward-closed set in a preorder, and the classes obtained by
  *excluding* a family of graphs are exactly the basic examples.

  Main results:

  * `MinorTheory.MinorClosed`          : downward closure in a preorder.
  * `MinorTheory.excl_minorClosed`     : excluding any family gives a
                                         minor-closed class.
  * `MinorTheory.minorClosed_iff_isLowerSet` : the framework coincides with
                                         Mathlib's `IsLowerSet`.
  * closure of minor-closed classes under arbitrary unions and intersections.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): all the combinatorics of "minor-closed class" that
    is used downstream is order-theoretic, hence should be stated for an
    arbitrary preorder `α` and specialised later to `SimpleGraph V` with either
    the subgraph order or the genuine minor order.
  Experiment (Experimenter): defined `MinorClosed` as downward closure and
    verified that `excl S`, arbitrary unions, arbitrary intersections and
    complements-of-upper-sets all fit.
  Analysis (Analyst): `MinorClosed C ↔ IsLowerSet C` on the nose, so the whole
    Mathlib lower-set API becomes available to the graph-minor development.
  Critique (Critic): the framework is deliberately *order-theoretic only*; it
    says nothing about the graph-minor relation being a preorder — that is the
    content of `HadwigerCore.isMinor_trans`.
  Synthesis (PI): a small, reusable base layer.
  -- !-- Lab Notes -- !--
-/
import Mathlib

namespace MinorTheory

variable {α : Type*} [Preorder α]

/-- A class of objects is **minor-closed** when it is downward closed for the
ambient order (which downstream is either the subgraph order or the graph-minor
order). -/
def MinorClosed (C : Set α) : Prop := ∀ ⦃G H : α⦄, G ≤ H → H ∈ C → G ∈ C

/-- The class of objects **excluding** every member of `S`. -/
def excl (S : Set α) : Set α := {G | ∀ H ∈ S, ¬ H ≤ G}

/-- Excluding an arbitrary family of obstructions produces a minor-closed
class. -/
theorem excl_minorClosed (S : Set α) : MinorClosed (excl S) := by
  intro G H hGH hH K hK hKG
  exact hH K hK (hKG.trans hGH)

/-- `MinorClosed` is exactly Mathlib's `IsLowerSet`. -/
theorem minorClosed_iff_isLowerSet (C : Set α) : MinorClosed C ↔ IsLowerSet C :=
  ⟨fun h _ _ hle hm => h hle hm, fun h _ _ hle hm => h hle hm⟩

theorem minorClosed_univ : MinorClosed (Set.univ : Set α) := fun _ _ _ _ => trivial

theorem minorClosed_empty : MinorClosed (∅ : Set α) := fun _ _ _ h => h

theorem MinorClosed.inter {C D : Set α} (hC : MinorClosed C) (hD : MinorClosed D) :
    MinorClosed (C ∩ D) := fun _ _ hle h => ⟨hC hle h.1, hD hle h.2⟩

theorem MinorClosed.union {C D : Set α} (hC : MinorClosed C) (hD : MinorClosed D) :
    MinorClosed (C ∪ D) := by
  rintro G H hle (h | h)
  · exact Or.inl (hC hle h)
  · exact Or.inr (hD hle h)

theorem MinorClosed.sInter {S : Set (Set α)} (hS : ∀ C ∈ S, MinorClosed C) :
    MinorClosed (⋂₀ S) := by
  intro G H hle h C hC
  exact hS C hC hle (h C hC)

theorem MinorClosed.iUnion {ι : Sort*} {C : ι → Set α} (hC : ∀ i, MinorClosed (C i)) :
    MinorClosed (⋃ i, C i) := by
  rintro G H hle h
  obtain ⟨i, hHi⟩ := Set.mem_iUnion.mp h
  exact Set.mem_iUnion.mpr ⟨i, hC i hle hHi⟩

/-- A minor-closed class contains every object below one of its members. -/
theorem MinorClosed.mem_of_le {C : Set α} (hC : MinorClosed C) {G H : α}
    (hle : G ≤ H) (hH : H ∈ C) : G ∈ C := hC hle hH

/-- The complement of a minor-closed class is upward closed. -/
theorem MinorClosed.isUpperSet_compl {C : Set α} (hC : MinorClosed C) :
    IsUpperSet Cᶜ := (minorClosed_iff_isLowerSet C).mp hC |>.compl

end MinorTheory