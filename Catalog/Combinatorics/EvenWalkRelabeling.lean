/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Evenness of a closed walk is a relabeling invariant

The predicate `EvenWalks.IsEvenClosedWalk` is defined through the edge multiplicities
`RademacherWigner.edgeMult`, which are attached to *labelled* vertices.  This file
shows that the predicate only depends on the walk up to renaming of the vertices:
composing a walk with an injective map of vertex sets changes neither loop-freeness
nor the multiset of edge multiplicities.

This is the technical engine behind the polynomiality of the moment counts
(`Combinatorics.EvenWalkPolynomial`): the number of even closed walks with a
prescribed vertex set depends on that set only through its cardinality.
-/
import Combinatorics.EvenClosedWalks

open Finset RademacherWigner

namespace EvenWalks

variable {M N L : ℕ}

/-- An injective relabeling of the vertices identifies edges exactly as before. -/
theorem edgeOf_comp_eq_iff {f : Fin M → Fin N} (hf : Function.Injective f)
    {a b c d : Fin M} (hab : a ≠ b) (hcd : c ≠ d) :
    edgeOf (f a) (f b) = edgeOf (f c) (f d) ↔ edgeOf a b = edgeOf c d := by
  rw [edgeOf_eq_iff (fun h => hab (hf h)) (fun h => hcd (hf h)), edgeOf_eq_iff hab hcd]
  constructor
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · exact Or.inl ⟨hf h1, hf h2⟩
    · exact Or.inr ⟨hf h1, hf h2⟩
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · exact Or.inl ⟨by rw [h1], by rw [h2]⟩
    · exact Or.inr ⟨by rw [h1], by rw [h2]⟩

/-- A multiplicity is nonzero only at an edge that is actually traversed. -/
theorem edgeMult_ne_zero_iff {ι : Type*} [Fintype ι] (a b : ι → Fin N)
    (p : Fin N × Fin N) :
    edgeMult a b p ≠ 0 ↔ ∃ t, edgeOf (a t) (b t) = p := by
  simp [edgeMult]

/-- Relabeling injectively preserves the multiplicity of a traversed edge. -/
theorem edgeMult_comp {ι : Type*} [Fintype ι] {f : Fin M → Fin N}
    (hf : Function.Injective f) (a b : ι → Fin M) (hne : ∀ t, a t ≠ b t) (t₀ : ι) :
    edgeMult (fun t => f (a t)) (fun t => f (b t)) (edgeOf (f (a t₀)) (f (b t₀)))
      = edgeMult a b (edgeOf (a t₀) (b t₀)) := by
  unfold edgeMult
  refine congrArg Finset.card (Finset.filter_congr fun t _ => ?_)
  simpa using edgeOf_comp_eq_iff hf (hne t) (hne t₀)

/-- **Evenness is a relabeling invariant.**  Composing a closed walk with an injective
map of vertex sets preserves (and reflects) the property of being an even closed
walk. -/
theorem isEvenClosedWalk_comp_iff [NeZero L] {f : Fin M → Fin N}
    (hf : Function.Injective f) (w : Fin L → Fin M) :
    IsEvenClosedWalk (fun t => f (w t)) ↔ IsEvenClosedWalk w := by
  have hloopiff : (∀ t : Fin L, f (w t) ≠ f (w (t + 1))) ↔ ∀ t : Fin L, w t ≠ w (t + 1) :=
    ⟨fun h t ht => h t (by rw [ht]), fun h t ht => h t (hf ht)⟩
  constructor
  · rintro ⟨hloop, heven⟩
    have hne : ∀ t : Fin L, w t ≠ w (t + 1) := hloopiff.1 hloop
    refine ⟨hne, fun q => ?_⟩
    by_cases hq : edgeMult w (fun t => w (t + 1)) q = 0
    · rw [hq]
      exact ⟨0, rfl⟩
    · obtain ⟨t₀, ht₀⟩ := (edgeMult_ne_zero_iff w (fun t => w (t + 1)) q).1 hq
      rw [← ht₀, ← edgeMult_comp hf w (fun t => w (t + 1)) hne t₀]
      exact heven _
  · rintro ⟨hloop, heven⟩
    refine ⟨fun t => hloopiff.2 hloop t, fun p => ?_⟩
    by_cases hp : edgeMult (fun t => f (w t)) (fun t => f (w (t + 1))) p = 0
    · rw [hp]
      exact ⟨0, rfl⟩
    · obtain ⟨t₀, ht₀⟩ :=
        (edgeMult_ne_zero_iff (fun t => f (w t)) (fun t => f (w (t + 1))) p).1 hp
      rw [← ht₀, edgeMult_comp hf w (fun t => w (t + 1)) hloop t₀]
      exact heven _

/-- Version of `isEvenClosedWalk_comp_iff` phrased with function composition. -/
theorem isEvenClosedWalk_comp_iff' [NeZero L] {f : Fin M → Fin N}
    (hf : Function.Injective f) (w : Fin L → Fin M) :
    IsEvenClosedWalk (f ∘ w) ↔ IsEvenClosedWalk w :=
  isEvenClosedWalk_comp_iff hf w

end EvenWalks