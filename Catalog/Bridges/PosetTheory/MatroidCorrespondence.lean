import Mathlib
import Bridges.MatroidMinorFiniteBasis
/-!
# Matroid correspondences as order-theoretic functors

A correspondence between quotient-ordered structures is encoded by a relation whose
fibres extend along the source order.  Universal inverse image then transports lower
classes contravariantly.  This isolates the categorical mechanism behind matroid
correspondences from any particular construction such as deletion or contraction.

The main results prove closure under composition, functoriality on lower classes,
preservation of arbitrary intersections, and an obstruction theorem for matroids.
-/

open Set

namespace MatroidCorrespondence

/-- An order correspondence from `α` to `β`.  The extension law says that a target
witness over a smaller source can be extended above it over every larger source. -/
structure OrderCorrespondence (α β : Type*) [Preorder α] [Preorder β] where
  rel : α → β → Prop
  extend : ∀ {a₀ a₁ b₀}, a₀ ≤ a₁ → rel a₀ b₀ → ∃ b₁, b₀ ≤ b₁ ∧ rel a₁ b₁

namespace OrderCorrespondence

variable {α β γ δ : Type*}
variable [Preorder α] [Preorder β] [Preorder γ] [Preorder δ]

/-- The identity correspondence. -/
def id (α : Type*) [Preorder α] : OrderCorrespondence α α where
  rel := (· = ·)
  extend h hab := ⟨_, hab ▸ h, rfl⟩

/-- Relational composition of order correspondences. -/
def comp (F : OrderCorrespondence α β) (G : OrderCorrespondence β γ) :
    OrderCorrespondence α γ where
  rel a c := ∃ b, F.rel a b ∧ G.rel b c
  extend ha h := by
    rcases h with ⟨b₀, hab₀, hbc₀⟩
    rcases F.extend ha hab₀ with ⟨b₁, hb, hab₁⟩
    rcases G.extend hb hbc₀ with ⟨c₁, hc, hbc₁⟩
    exact ⟨c₁, hc, b₁, hab₁, hbc₁⟩

/-- Universal inverse image of a class along a correspondence. -/
def pull (F : OrderCorrespondence α β) (C : Set β) : Set α :=
  {a | ∀ b, F.rel a b → b ∈ C}

/-- Universal inverse image transports lower classes to lower classes. -/
theorem pull_isLowerSet (F : OrderCorrespondence α β) {C : Set β}
    (hC : IsLowerSet C) : IsLowerSet (F.pull C) := by
  intro a₁ a₀ ha ha₁ b₀ hab₀
  rcases F.extend ha hab₀ with ⟨b₁, hb, hab₁⟩
  exact hC hb (ha₁ b₁ hab₁)

/-- Pullback along a composite is iterated pullback. -/
theorem pull_comp (F : OrderCorrespondence α β) (G : OrderCorrespondence β γ)
    (C : Set γ) : (F.comp G).pull C = F.pull (G.pull C) := by
  ext a
  constructor
  · intro ha b hab c hbc
    exact ha c ⟨b, hab, hbc⟩
  · intro ha c hac
    rcases hac with ⟨b, hab, hbc⟩
    exact ha b hab c hbc

/-- Pullback along the identity correspondence fixes every class. -/
theorem pull_id (C : Set α) : (id α).pull C = C := by
  ext a
  constructor
  · intro ha
    exact ha a rfl
  · intro ha b hab
    rwa [← hab]

/-- Universal inverse image preserves arbitrary intersections. -/
theorem pull_iInter (F : OrderCorrespondence α β) (C : ι → Set β) :
    F.pull (⋂ i, C i) = ⋂ i, F.pull (C i) := by
  ext a
  constructor
  · intro ha
    refine Set.mem_iInter.mpr fun i b hab => ?_
    exact Set.mem_iInter.mp (ha b hab) i
  · intro ha b hab
    refine Set.mem_iInter.mpr fun i => ?_
    exact Set.mem_iInter.mp ha i b hab

/-- Composition of correspondences is associative at the level of relations. -/
theorem comp_assoc (F : OrderCorrespondence α β) (G : OrderCorrespondence β γ)
    (H : OrderCorrespondence γ δ) :
    ((F.comp G).comp H).rel = (F.comp (G.comp H)).rel := by
  funext a d
  apply propext
  constructor
  · rintro ⟨c, ⟨b, hab, hbc⟩, hcd⟩
    exact ⟨b, hab, c, hbc, hcd⟩
  · rintro ⟨b, hab, c, hbc, hcd⟩
    exact ⟨c, ⟨b, hab, hbc⟩, hcd⟩

end OrderCorrespondence

section MatroidObstructions

open Matroid MatroidMinorFiniteBasis

variable {α β : Type*}

/-- A matroid correspondence is an order correspondence for the minor orders. -/
abbrev MatroidCorr := OrderCorrespondence (Matroid α) (Matroid β)

/-- The minor correspondence relates a matroid to each of its minors. -/
def minorCorr (α : Type*) : MatroidCorr (α := α) (β := α) where
  rel M N := N ≤m M
  extend hMN hKN := ⟨_, hKN.trans hMN, Matroid.IsMinor.refl⟩

/-- Universal pullback along the minor correspondence is the operation sending a
class to the matroids all of whose minors lie in that class.  It fixes every
minor-closed class. -/
theorem minorCorr_pull_eq (C : Set (Matroid α)) (hC : IsMatroidMinorClosed C) :
    (minorCorr α).pull C = C := by
  ext M
  constructor
  · intro hM
    exact hM M Matroid.IsMinor.refl
  · intro hM N hNM
    exact hC hM hNM

/-- Every correspondence pulls a minor-closed target class back to a minor-closed
source class.  Under a well-quasi-order hypothesis, that source class has a finite,
canonical excluded-minor basis. -/
theorem pullback_has_finite_excluded_minors
    (F : MatroidCorr (α := α) (β := β))
    (C : Set (Matroid β)) (hC : IsMatroidMinorClosed C)
    (hwqo : WellQuasiOrdered ((· ≤m ·) : Matroid α → Matroid α → Prop)) :
    {M | IsExcludedMinor (F.pull C) M}.Finite ∧
      ∀ M, M ∈ F.pull C ↔
        ∀ N, IsExcludedMinor (F.pull C) N → ¬ N ≤m M := by
  have hC' : IsLowerSet C :=
    isLowerSet_iff_Iic_subset.mpr fun _ hM _ hNM => hC hM hNM
  have hpull : IsLowerSet (F.pull C) := F.pull_isLowerSet hC'
  have hpull' : IsMatroidMinorClosed (F.pull C) :=
    fun {_ _} hM hNM => (isLowerSet_iff_Iic_subset.mp hpull) hM hNM
  exact matroid_wqo_gives_finite_excluded_minors hwqo (F.pull C) hpull'

/-- Excluded minors of a correspondence pullback are pairwise incomparable. -/
theorem pullback_excludedMinors_isAntichain
    (F : MatroidCorr (α := α) (β := β)) (C : Set (Matroid β)) :
    IsAntichain (· ≤m ·) {M | IsExcludedMinor (F.pull C) M} := by
  exact excludedMinors_isAntichain (F.pull C)

end MatroidObstructions

end MatroidCorrespondence

-- !-- Lab Notes -- !--
-- Hypothesis: the functorial core of matroid correspondence is an extension law
-- for a relation between quotient orders, rather than functionality of that relation.
-- Experiment: universal inverse image was tested against identity, relational
-- composition, arbitrary intersections, and excluded-minor extraction.
-- Analysis: existential direct image has the wrong variance for minor-closed classes;
-- universal inverse image is lower precisely because witnesses extend upward.
-- Critique: representability and Lorentzian support require additional algebraic data
-- and are not asserted here.  The results concern the quotient-order mechanism only.
-- Synthesis: correspondences form an associative relational calculus whose pullbacks
-- act contravariantly on lower classes and inherit finite obstruction bases under WQO.
-- !-- End Lab Notes -- !--