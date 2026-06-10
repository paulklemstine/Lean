/-
  Model Theory and Algebra Bridge
  ================================
  
  Formalizes fundamental results connecting model theory and algebra:
  
  1. Isomorphic structures are elementarily equivalent
  2. Models of a complete theory are elementarily equivalent  
  3. Complete theories are characterized by their models (T ⊨ φ ↔ M ⊨ φ)
  4. Elementary equivalence preserves the model relation
  5. κ-categoricity implies elementary equivalence of same-size models
  6. A theory is complete iff all models are elementarily equivalent
  
  These results form the algebraic foundation for deeper theorems like 
  Ax-Kochen-Ershov and Morley's categoricity theorem.
-/

import Mathlib

open FirstOrder Cardinal

universe u v

namespace ModelTheoryBridge

variable {L : FirstOrder.Language.{u, v}}

/-! ## Section 1: Isomorphic Structures and Elementary Equivalence -/

-- !-- An L-isomorphism factors through an elementary embedding, giving elem. equivalence. -- !--
/-- Isomorphic L-structures are elementarily equivalent. -/
theorem equiv_elementarilyEquivalent {M : Type*} {N : Type*}
    [L.Structure M] [L.Structure N]
    (f : M ≃[L] N) : L.ElementarilyEquivalent M N :=
  f.toElementaryEmbedding.elementarilyEquivalent

/-! ## Section 2: Complete Theories and Elementary Equivalence -/

-- !-- For each sentence φ, completeness of T gives T ⊨ φ or T ⊨ ¬φ.
--     Since both M and N are models of T, they agree on φ in both cases. -- !--
/-- Any two models of a complete theory are elementarily equivalent. -/
theorem complete_theory_models_elementarilyEquivalent
    {T : L.Theory} (hT : T.IsComplete)
    {M : Type*} {N : Type*} [L.Structure M] [L.Structure N]
    [M ⊨ T] [N ⊨ T] [Nonempty M] [Nonempty N] :
    L.ElementarilyEquivalent M N := by
  change L.completeTheory M = L.completeTheory N
  ext φ
  simp only [Language.completeTheory, Set.mem_setOf_eq]
  obtain ⟨_, h⟩ := hT
  rcases h φ with hφ | hφ
  · exact ⟨fun _ => hφ.realize_sentence N, fun _ => hφ.realize_sentence M⟩
  · constructor
    · intro hMφ
      have := hφ.realize_sentence M
      simp [Language.Sentence.Realize, Language.Formula.realize_not] at this
      exact absurd hMφ this
    · intro hNφ
      have := hφ.realize_sentence N
      simp [Language.Sentence.Realize, Language.Formula.realize_not] at this
      exact absurd hNφ this

/-! ## Section 3: Complete Theory Characterization -/

-- !-- For the forward direction, T ⊨ φ implies M ⊨ φ since M is a model.
--     For the reverse, if M ⊨ φ but T ⊨ ¬φ, then M ⊨ ¬φ, contradiction. -- !--
/-- For a complete theory T, the semantic consequence relation T ⊨ φ is equivalent
    to φ holding in any single model. -/
theorem complete_theory_models_iff_realizes
    {T : L.Theory} (hT : T.IsComplete)
    {M : Type*} [L.Structure M] [M ⊨ T] [Nonempty M]
    (φ : L.Sentence) : T ⊨ᵇ φ ↔ M ⊨ φ := by
  constructor
  · intro h; exact h.realize_sentence M
  · intro h
    obtain ⟨_, hc⟩ := hT
    rcases hc φ with hφ | hφ
    · exact hφ
    · exfalso
      have := hφ.realize_sentence M
      simp [Language.Sentence.Realize, Language.Formula.realize_not] at this
      exact this h

/-! ## Section 4: Elementary Equivalence Preserves Model Relation -/

-- !-- If φ ∈ T and M ⊨ T then M ⊨ φ. Since M ≡ N, also N ⊨ φ. -- !--
/-- Elementary equivalence preserves the model relation. -/
theorem model_of_elementarilyEquivalent
    {T : L.Theory} {M N : Type*}
    [L.Structure M] [L.Structure N]
    (h : L.ElementarilyEquivalent M N) [M ⊨ T] : N ⊨ T := by
  constructor
  intro φ hφ
  have hMφ : M ⊨ φ := Language.Theory.Model.realize_of_mem φ hφ
  change L.completeTheory M = L.completeTheory N at h
  have : φ ∈ L.completeTheory M := hMφ
  rw [h] at this
  exact this

/-! ## Section 5: Elementary Equivalence as an Equivalence Relation -/

/-- Elementary equivalence is reflexive. -/
theorem elementarilyEquivalent_refl (M : Type*) [L.Structure M] :
    L.ElementarilyEquivalent M M := rfl

/-- Elementary equivalence is symmetric. -/
theorem elementarilyEquivalent_symm {M N : Type*} [L.Structure M] [L.Structure N]
    (h : L.ElementarilyEquivalent M N) : L.ElementarilyEquivalent N M := h.symm

/-- Elementary equivalence is transitive. -/
theorem elementarilyEquivalent_trans {M N P : Type*}
    [L.Structure M] [L.Structure N] [L.Structure P]
    (h₁ : L.ElementarilyEquivalent M N) (h₂ : L.ElementarilyEquivalent N P) :
    L.ElementarilyEquivalent M P := h₁.trans h₂

/-! ## Section 6: κ-Categoricity -/

/-- A theory T is κ-categorical if any two models of T of cardinality κ are isomorphic. -/
def IsCategoricalAt (T : L.Theory) (κ : Cardinal) : Prop :=
  ∀ (M N : T.ModelType), #M = κ → #N = κ → Nonempty (M ≃[L] N)

/-! ## Section 7: Categorical Theories and Elementary Equivalence -/

-- !-- If T is κ-categorical and M, N are models of size κ, then M ≅ N by categoricity,
--     so M ≡ N since isomorphism → elementary embedding → elementary equivalence. -- !--
/-- In a κ-categorical theory, any two models of cardinality κ are elementarily equivalent. -/
theorem categorical_models_elementarilyEquivalent
    {T : L.Theory} {κ : Cardinal}
    (hcat : IsCategoricalAt T κ)
    (M N : T.ModelType) (hM : #M = κ) (hN : #N = κ) :
    L.ElementarilyEquivalent M N := by
  obtain ⟨f⟩ := hcat M N hM hN
  exact f.toElementaryEmbedding.elementarilyEquivalent

/-! ## Section 8: Complete Theory of a Structure is Complete -/

-- !-- Th(M) is complete: satisfiable (M witnesses) and decides every sentence. -- !--
/-- The complete theory of any nonempty structure is complete. -/
theorem completeTheory_isComplete' (M : Type*) [L.Structure M] [Nonempty M] :
    (L.completeTheory M).IsComplete :=
  Language.completeTheory.isComplete L M

/-! ## Section 9: Completeness Characterization via Elementary Equivalence -/

-- !-- Use the hypothesis to show all models have the same complete theory as
--     the witness model M. Since Th(M) is always complete, T is complete. -- !--
/-- A satisfiable theory is complete if all its models are elementarily equivalent.
    This fundamental characterization reduces completeness to a purely model-theoretic condition. -/
theorem isComplete_of_allModels_ee
    {T : L.Theory}
    (hsat : T.IsSatisfiable)
    (h : ∀ (M N : Language.Theory.ModelType.{u, v, max u v} T),
      L.ElementarilyEquivalent M N) :
    T.IsComplete := by
  obtain ⟨M, _⟩ := hsat
  have h_complete : (L.completeTheory M).IsComplete := Language.completeTheory.isComplete L M
  obtain ⟨hT_sat, hT_decide⟩ := h_complete
  grind +suggestions

end ModelTheoryBridge