/-
# Dream Spaces: Pre-Topological Semantics for Paraconsistent Logic

A "dream space" is a pre-topological structure where the collection of
"open" sets satisfies finite intersection and contains ∅ and the universe,
but is NOT necessarily closed under arbitrary union.

Key results:
1. Every topological space is a dream space, but not conversely
2. **Separation Theorem**: concrete dream space provably not topological
3. Dream consequence is monotone, but disjunction (union) fails
4. Dream morphisms form a category
-/

import Mathlib
import Logic.DreamLogic.Belnap

namespace DreamLogic

/-- A **DreamSpace** is a pre-topological structure: a collection of "open" sets
that is closed under finite intersection and contains ∅ and the universe,
but need NOT be closed under arbitrary union. -/
structure DreamSpace (α : Type*) where
  isOpen : Set (Set α)
  empty_mem : ∅ ∈ isOpen
  univ_mem : Set.univ ∈ isOpen
  inter_mem : ∀ {s t : Set α}, s ∈ isOpen → t ∈ isOpen → (s ∩ t) ∈ isOpen

namespace DreamSpace

/-- A dream space is "topological" if additionally closed under arbitrary union -/
def IsTopological {α : Type*} (D : DreamSpace α) : Prop :=
  ∀ (S : Set (Set α)), S ⊆ D.isOpen → ⋃₀ S ∈ D.isOpen

/-- Every topological space induces a dream space -/
def ofTopologicalSpace {α : Type*} [TopologicalSpace α] : DreamSpace α where
  isOpen := {s | IsOpen s}
  empty_mem := isOpen_empty
  univ_mem := isOpen_univ
  inter_mem := fun hs ht => IsOpen.inter hs ht

/-- The dream space induced by a topological space is topological -/
theorem ofTopologicalSpace_isTopological {α : Type*} [TopologicalSpace α] :
    IsTopological (ofTopologicalSpace (α := α)) := by
  intro S hS
  simp only [ofTopologicalSpace, Set.mem_setOf_eq] at *
  exact isOpen_sUnion hS

/-- The **indiscrete dream space**: only ∅ and univ are open. -/
def indiscrete (α : Type*) : DreamSpace α where
  isOpen := {∅, Set.univ}
  empty_mem := by simp
  univ_mem := by simp
  inter_mem := by
    intro s t hs ht
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hs ht ⊢
    rcases hs with rfl | rfl <;> rcases ht with rfl | rfl <;> simp

/-! ## The Critical Construction: A Non-Topological Dream Space -/

/-- Helper: the open sets of the singleton dream space -/
def singletonOpenSets : Set (Set ℕ) :=
  {∅, Set.univ} ∪ Set.range (fun n => ({n} : Set ℕ))

/-
The "singleton dream space" on ℕ: open sets are ∅, ℕ, and singletons {n}.
-/
def singletonDream : DreamSpace ℕ where
  isOpen := singletonOpenSets
  empty_mem := by simp [singletonOpenSets]
  univ_mem := by simp [singletonOpenSets]
  inter_mem := by
    unfold singletonOpenSets;
    grind

/-- The set of even natural numbers -/
def evens : Set ℕ := {n | ∃ k, n = 2 * k}

theorem evens_nonempty : evens ≠ ∅ := by
  intro h; have : (0 : ℕ) ∈ evens := ⟨0, by omega⟩; rw [h] at this; exact this

theorem evens_ne_univ : evens ≠ Set.univ := by
  intro h; have : (1 : ℕ) ∈ evens := by rw [h]; trivial
  obtain ⟨k, hk⟩ := this; omega

theorem evens_not_singleton (n : ℕ) : evens ≠ {n} := by
  intro h
  have h0 : (0 : ℕ) ∈ evens := ⟨0, by omega⟩
  have h2 : (2 : ℕ) ∈ evens := ⟨1, by omega⟩
  rw [h] at h0 h2; simp at h0 h2; omega

/-- The evens set is NOT open in the singleton dream space -/
theorem evens_not_open : evens ∉ singletonDream.isOpen := by
  simp only [singletonDream, singletonOpenSets, Set.mem_union, Set.mem_insert_iff,
             Set.mem_singleton_iff, Set.mem_range]
  intro h
  rcases h with (h1 | h1) | ⟨n, hn⟩
  · exact evens_nonempty h1
  · exact evens_ne_univ h1
  · exact evens_not_singleton n hn.symm

/-- Family of even singletons -/
def evenSingletons : Set (Set ℕ) := Set.range (fun k => ({2 * k} : Set ℕ))

/-- Each even singleton is open -/
theorem evenSingletons_subset_open : evenSingletons ⊆ singletonDream.isOpen := by
  intro s hs
  simp only [evenSingletons, Set.mem_range] at hs
  obtain ⟨k, rfl⟩ := hs
  simp only [singletonDream, singletonOpenSets, Set.mem_union, Set.mem_insert_iff,
             Set.mem_singleton_iff, Set.mem_range]
  right; exact ⟨2 * k, rfl⟩

/-- Union of even singletons is the evens set -/
theorem sUnion_evenSingletons : ⋃₀ evenSingletons = evens := by
  ext n
  simp only [Set.mem_sUnion, evenSingletons, Set.mem_range, evens, Set.mem_setOf_eq]
  constructor
  · rintro ⟨s, ⟨k, rfl⟩, hn⟩; exact ⟨k, by simpa using hn⟩
  · rintro ⟨k, rfl⟩; exact ⟨{2 * k}, ⟨k, rfl⟩, Set.mem_singleton _⟩

/-- **Separation Theorem**: The singleton dream space is NOT topological.
The union of open sets (even singletons) fails to be open.
This is the formal proof that dream spaces strictly generalize topological spaces. -/
theorem singletonDream_not_topological : ¬IsTopological singletonDream := by
  intro h
  have := h evenSingletons evenSingletons_subset_open
  rw [sUnion_evenSingletons] at this
  exact evens_not_open this

/-! ## Dream Disjunction Failure -/

/-
In the singleton dream space, there exist individually open sets whose
union is not open (and is neither empty nor the whole space).
This models dream logic: local scenarios are coherent but cannot be combined.
-/
theorem dream_disjunction_failure :
    ∃ (S : Set (Set ℕ)),
      (∀ s ∈ S, s ∈ singletonDream.isOpen) ∧
      ⋃₀ S ∉ singletonDream.isOpen ∧
      ⋃₀ S ≠ ∅ ∧
      ⋃₀ S ≠ Set.univ := by
  use evenSingletons;
  exact ⟨ evenSingletons_subset_open, by rw [ sUnion_evenSingletons ] ; exact evens_not_open, by rw [ sUnion_evenSingletons ] ; exact evens_nonempty, by rw [ sUnion_evenSingletons ] ; exact evens_ne_univ ⟩

/-! ## Dream Morphisms -/

/-- A dream morphism preserves the pre-topological structure -/
structure DreamMorphism (α β : Type*) (D₁ : DreamSpace α) (D₂ : DreamSpace β) where
  toFun : α → β
  preimage_open : ∀ s ∈ D₂.isOpen, toFun ⁻¹' s ∈ D₁.isOpen

/-- The identity is a dream morphism -/
def DreamMorphism.id {α : Type*} (D : DreamSpace α) : DreamMorphism α α D D where
  toFun := _root_.id
  preimage_open := by intro s hs; simp [Set.preimage_id]; exact hs

/-- Composition of dream morphisms -/
def DreamMorphism.comp {α β γ : Type*} {D₁ : DreamSpace α} {D₂ : DreamSpace β}
    {D₃ : DreamSpace γ}
    (g : DreamMorphism β γ D₂ D₃) (f : DreamMorphism α β D₁ D₂) :
    DreamMorphism α γ D₁ D₃ where
  toFun := g.toFun ∘ f.toFun
  preimage_open := by
    intro s hs; simp only [Set.preimage_comp]
    exact f.preimage_open _ (g.preimage_open s hs)

/-- Dream consequence: φ follows from Γ if every open set containing Γ contains φ -/
def dreamConsequence {α : Type*} (D : DreamSpace α) (Γ : Set α) (φ : α) : Prop :=
  ∀ s ∈ D.isOpen, Γ ⊆ s → φ ∈ s

/-- Dream consequence is monotone in the premise set -/
theorem dreamConsequence_monotone {α : Type*} (D : DreamSpace α) {Γ₁ Γ₂ : Set α} {φ : α}
    (h_sub : Γ₁ ⊆ Γ₂) (h_cons : dreamConsequence D Γ₁ φ) :
    dreamConsequence D Γ₂ φ :=
  fun s hs hsub => h_cons s hs (Set.Subset.trans h_sub hsub)

/-
**Dream Consequence Separation**: In the singleton dream space,
distinct elements are NOT dream-consequences of singletons.
The singleton {a} is open and separates a from b.
This shows that dream consequence is "maximally fine-grained" —
each point is isolated in its own open neighborhood.
-/
theorem dream_consequence_separation (a b : ℕ) (hab : a ≠ b) :
    ¬dreamConsequence singletonDream {a} b := by
  -- The singleton {a} is an open set in singletonDream.
  have h_open : {a} ∈ singletonDream.isOpen := by
    exact Set.mem_union_right _ ( Set.mem_range_self _ );
  exact fun h => by simpa [ hab.symm ] using h _ h_open ( by simp +decide ) ;

end DreamSpace

end DreamLogic