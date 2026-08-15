import Mathlib
import Bridges.ToposTheoreticML.Foundations
import Bridges.VCCompactness
/-! # Topos-Theoretic Machine Learning: Hypothesis Topos Structure

This file establishes topos-theoretic properties of presheaf categories
and connects them to learning theory via sieves and the subobject classifier.

## Bridge: Category Theory (presheaf toposes, subobject classifiers) →
   Logic (Heyting algebras, geometric formulas) →
   ML (concept hierarchies, hypothesis spaces) →
   Lattice Theory (frames, distributive lattices)
-/

noncomputable section

open Finset CategoryTheory CategoryTheory.Limits

/-! ## I. Presheaf Category Structure -/

/-- Presheaf categories have finite limits.
    Bridge: category theory → topos theory (topos axiom 1). -/
instance presheaf_has_finite_limits (C : Type*) [SmallCategory C] :
    HasFiniteLimits (Cᵒᵖ ⥤ Type*) :=
  inferInstance

/-- Presheaf categories have finite colimits.
    Bridge: category theory → topos theory (topos axiom 2). -/
instance presheaf_has_finite_colimits (C : Type*) [SmallCategory C] :
    HasFiniteColimits (Cᵒᵖ ⥤ Type*) :=
  inferInstance

/-! ## II. Frame Structure of Sieves

The sieve lattice forms a frame (complete Heyting algebra), the
algebraic structure of the subobject classifier Ω in a topos. -/

/-- Meet distributes over join in the sieve lattice.
    Bridge: logic (Heyting algebra) → topos theory (internal logic). -/
theorem sieve_meet_distributes_over_join {α : Type*} [Preorder α] {d : α}
    (s₁ s₂ s₃ : SieveOn α d) :
    sieveIntersection s₁ (sieveUnion s₂ s₃) ≤
      sieveUnion (sieveIntersection s₁ s₂) (sieveIntersection s₁ s₃) :=
  fun _ ⟨h1, h23⟩ => h23.elim (fun h2 => Or.inl ⟨h1, h2⟩) (fun h3 => Or.inr ⟨h1, h3⟩)

/-- Join distributes over meet. -/
theorem sieve_join_distributes_over_meet {α : Type*} [Preorder α] {d : α}
    (s₁ s₂ s₃ : SieveOn α d) :
    sieveUnion (sieveIntersection s₁ s₂) (sieveIntersection s₁ s₃) ≤
      sieveIntersection s₁ (sieveUnion s₂ s₃) :=
  fun _ hx => hx.elim (fun ⟨h1, h2⟩ => ⟨h1, Or.inl h2⟩) (fun ⟨h1, h3⟩ => ⟨h1, Or.inr h3⟩)

/-- Full distributivity: sieve lattice is a frame.
    Bridge: logic (frame = Heyting algebra) → topos theory (Ω is a frame). -/
theorem sieve_frame_distributivity {α : Type*} [Preorder α] {d : α}
    (s₁ s₂ s₃ : SieveOn α d) :
    sieveIntersection s₁ (sieveUnion s₂ s₃) =
      sieveUnion (sieveIntersection s₁ s₂) (sieveIntersection s₁ s₃) :=
  le_antisymm (sieve_meet_distributes_over_join s₁ s₂ s₃)
    (sieve_join_distributes_over_meet s₁ s₂ s₃)

/-! ## III. Sieve Pullback Functoriality -/

/-- Pull back a sieve along a morphism in a preorder.
    Bridge: category theory (pullback) → topos theory (Ω functoriality). -/
def sievePullback {α : Type*} [Preorder α] {c d : α} (_f : c ≤ d)
    (s : SieveOn α d) : SieveOn α c where
  carrier := {x | x ∈ s.carrier ∧ x ≤ c}
  downward_closed := fun x y ⟨hxs, hxc⟩ hyx =>
    ⟨s.downward_closed x y hxs hyx, le_trans hyx hxc⟩
  below_target := fun _ ⟨_, hxc⟩ => hxc

/-- Id pullback = id.
    Bridge: category theory (functor laws) → topos theory. -/
theorem sievePullback_id {α : Type*} [PartialOrder α] {d : α} (s : SieveOn α d) :
    sievePullback (le_refl d) s = s := by
  apply le_antisymm
  · exact fun _ ⟨hxs, _⟩ => hxs
  · exact fun _ hxs => ⟨hxs, s.below_target _ hxs⟩

/-- Pullback preserves intersection. -/
theorem sievePullback_preserves_meet {α : Type*} [Preorder α] {c d : α}
    (f : c ≤ d) (s₁ s₂ : SieveOn α d) :
    sievePullback f (sieveIntersection s₁ s₂) =
      sieveIntersection (sievePullback f s₁) (sievePullback f s₂) := by
  apply le_antisymm
  · exact fun _ ⟨⟨h1, h2⟩, hxc⟩ => ⟨⟨h1, hxc⟩, ⟨h2, hxc⟩⟩
  · exact fun _ ⟨⟨h1, hxc⟩, ⟨h2, _⟩⟩ => ⟨⟨h1, h2⟩, hxc⟩

/-- Pullback preserves union. -/
theorem sievePullback_preserves_join {α : Type*} [Preorder α] {c d : α}
    (f : c ≤ d) (s₁ s₂ : SieveOn α d) :
    sievePullback f (sieveUnion s₁ s₂) =
      sieveUnion (sievePullback f s₁) (sievePullback f s₂) := by
  apply le_antisymm
  · exact fun _ ⟨h12, hxc⟩ =>
      h12.elim (fun h1 => Or.inl ⟨h1, hxc⟩) (fun h2 => Or.inr ⟨h2, hxc⟩)
  · exact fun _ hx =>
      hx.elim (fun ⟨h1, hxc⟩ => ⟨Or.inl h1, hxc⟩) (fun ⟨h2, hxc⟩ => ⟨Or.inr h2, hxc⟩)

/-- Pullback preserves empty. -/
theorem sievePullback_empty {α : Type*} [Preorder α] {c d : α} (f : c ≤ d) :
    sievePullback f (SieveOn.empty d) = SieveOn.empty c := by
  apply le_antisymm
  · exact fun _ ⟨hxs, _⟩ => hxs
  · exact SieveOn.empty_le c _

/-- Pullback preserves maximal. -/
theorem sievePullback_maximal {α : Type*} [Preorder α] {c d : α} (f : c ≤ d) :
    sievePullback f (SieveOn.maximal d) = SieveOn.maximal c := by
  apply le_antisymm
  · exact SieveOn.le_maximal c _
  · exact fun _ hxc => ⟨le_trans hxc f, hxc⟩

/-! ## IV. NNO and Sample Complexity -/

/-- Successor iterates count samples.
    Bridge: topos theory (NNO) → ML (sample counting). -/
theorem nno_successor_iterates (n : ℕ) : Nat.succ^[n] 0 = n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [Function.iterate_succ_apply', ih]

/-- Sample complexity is positive for valid parameters.
    Bridge: topos theory → ML (sample complexity). -/
theorem sample_complexity_via_nno (d : ℕ) (ε δ : ℝ)
    (hd : 0 < d) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
    0 < sampleComplexityBound d ε δ :=
  sampleComplexityBound_pos hd hε hδ hδ1

/-! ## V. Concept Ordering via Sieves -/

/-- c₁ ⊆ c₂ ⟹ sieve(c₁) ≤ sieve(c₂).
    Bridge: learning theory → topos theory (subobject order). -/
theorem concept_ordering_via_sieves {α : Type*} [Preorder α] (c₁ c₂ : Set α)
    (h₁ : ∀ x y, x ∈ c₁ → y ≤ x → y ∈ c₁)
    (h₂ : ∀ x y, x ∈ c₂ → y ≤ x → y ∈ c₂)
    (hsub : c₁ ⊆ c₂) :
    ∀ d : α, conceptToSieve c₁ h₁ d ≤ conceptToSieve c₂ h₂ d :=
  fun d => conceptToSieve_mono c₁ c₂ h₁ h₂ d hsub

/-- Mutual inclusion = equality. -/
theorem concept_hierarchy_antisymmetric {α : Type*} (c₁ c₂ : Set α)
    (h₁₂ : c₁ ⊆ c₂) (h₂₁ : c₂ ⊆ c₁) : c₁ = c₂ :=
  Set.Subset.antisymm h₁₂ h₂₁

/-! ## VI. Separation Property -/

/-- Ω separates concepts: distinct downward-closed concepts give distinct sieves.
    Bridge: topos theory (Ω separates subobjects) → ML (concept discrimination). -/
theorem omega_separates_concepts {α : Type*} [PartialOrder α]
    (c₁ c₂ : Set α)
    (h₁ : ∀ x y, x ∈ c₁ → y ≤ x → y ∈ c₁)
    (h₂ : ∀ x y, x ∈ c₂ → y ≤ x → y ∈ c₂)
    (hne : c₁ ≠ c₂) :
    ∃ d : α, conceptToSieve c₁ h₁ d ≠ conceptToSieve c₂ h₂ d := by
  by_contra hall
  push_neg at hall
  apply hne; ext x
  constructor
  · intro hx
    exact ((le_of_eq (hall x) : conceptToSieve c₁ h₁ x ≤ conceptToSieve c₂ h₂ x)
      ⟨le_refl x, hx⟩).2
  · intro hx
    exact ((le_of_eq (hall x).symm : conceptToSieve c₂ h₂ x ≤ conceptToSieve c₁ h₁ x)
      ⟨le_refl x, hx⟩).2

end