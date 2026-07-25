import Mathlib

/-!
# Vietoris–Rips completion threshold

This file formalizes the *completion threshold* for the Vietoris–Rips complex of a
(pseudo)metric space.

We use a lightweight, custom notion of a downward-closed family of finite subsets
(`SimpleComplex`) rather than Mathlib's abstract simplicial complexes, in order to keep
the development self-contained and the proofs robust.

## Main definitions

* `SimpleComplex α` : a set of finite subsets ("faces") closed under taking subsets.
* `fullComplex α`   : the complex whose faces are *all* finite subsets of `α`.
* `vietorisRips ε`  : the Vietoris–Rips complex at scale `ε`; a finite subset is a face
  iff all pairwise distances of its vertices are `≤ ε`.

## Main results

* `mem_fullComplex` / `mem_vietorisRips_iff` : membership characterizations.
* `vietorisRips_eq_fullComplex_iff` :
  `vietorisRips ε = fullComplex α ↔ ∀ x y, dist x y ≤ ε`.
* `vietorisRips_eq_fullComplex_iff_sup'_le` : the finite "maximum pairwise distance"
  packaging of the above when `α` is a finite, nonempty type.
-/

namespace VietorisRipsThreshold

/-- A lightweight simplicial-complex–like structure: a family of finite subsets
("faces") of `α` that is closed under taking subsets. -/
@[ext]
structure SimpleComplex (α : Type*) where
  /-- The faces of the complex. -/
  faces : Set (Finset α)
  /-- The face set is downward closed: a subset of a face is a face. -/
  downward_closed : ∀ ⦃s t : Finset α⦄, s ∈ faces → t ⊆ s → t ∈ faces

variable {α : Type*}

/-- The full complex: every finite subset of `α` is a face. -/
def fullComplex (α : Type*) : SimpleComplex α where
  faces := Set.univ
  downward_closed := by intro s t _ _; trivial

@[simp]
theorem mem_fullComplex (s : Finset α) : s ∈ (fullComplex α).faces := Set.mem_univ s

variable [PseudoMetricSpace α]

/-- The Vietoris–Rips complex at scale `ε`: a finite subset is a face iff every pair of
its vertices is at distance `≤ ε`. -/
def vietorisRips (ε : ℝ) : SimpleComplex α where
  faces := {s : Finset α | ∀ x ∈ s, ∀ y ∈ s, dist x y ≤ ε}
  downward_closed := by
    intro s t hs hts x hx y hy
    exact hs x (hts hx) y (hts hy)

@[simp]
theorem mem_vietorisRips_iff {ε : ℝ} (s : Finset α) :
    s ∈ (vietorisRips ε).faces ↔ ∀ x ∈ s, ∀ y ∈ s, dist x y ≤ ε := Iff.rfl

/-- **Vietoris–Rips completion threshold.** The Vietoris–Rips complex at scale `ε`
equals the full complex iff every pair of points of `α` is at distance `≤ ε`. -/
theorem vietorisRips_eq_fullComplex_iff (ε : ℝ) :
    (vietorisRips ε : SimpleComplex α) = fullComplex α ↔ ∀ x y : α, dist x y ≤ ε := by
  classical
  constructor
  · intro h x y
    have hmem : ({x, y} : Finset α) ∈ (vietorisRips ε).faces := by
      rw [h]; exact mem_fullComplex _
    exact (mem_vietorisRips_iff _).1 hmem x (by simp) y (by simp)
  · intro h
    ext s
    simp only [mem_vietorisRips_iff, mem_fullComplex, iff_true]
    intro x _ y _
    exact h x y

/-- Finite "maximum pairwise distance" packaging of the completion threshold:
for a finite nonempty type, the Vietoris–Rips complex at scale `ε` equals the full
complex iff the maximum pairwise distance over `α × α` is `≤ ε`. -/
theorem vietorisRips_eq_fullComplex_iff_sup'_le [Fintype α] (ε : ℝ)
    (hne : (Finset.univ : Finset (α × α)).Nonempty) :
    (vietorisRips ε : SimpleComplex α) = fullComplex α ↔
      Finset.univ.sup' hne (fun p : α × α => dist p.1 p.2) ≤ ε := by
  rw [vietorisRips_eq_fullComplex_iff, Finset.sup'_le_iff]
  constructor
  · intro h p _; exact h p.1 p.2
  · intro h x y; exact h (x, y) (Finset.mem_univ _)

end VietorisRipsThreshold