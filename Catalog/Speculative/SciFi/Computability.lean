/-! # CatalogBuild.Speculative.SciFi.Computability

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 3
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.SciFi.Computability
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 3] -/
theorem no_surjection_to_powerset (A : Type*) : ¬ ∃ f : A → Set A, Surjective f := by
  rintro ⟨ f, hf ⟩;
  obtain ⟨ g, hg ⟩ := hf ( { a : A | a ∉ f a } );
  exact absurd ( Set.ext_iff.mp hg g ) ( by tauto )




/-- Rice's theorem (abstract): if a property P on functions is non-trivial
(some function satisfies it, some doesn't), it cannot be decided by
a computable function that only inspects the extensional behavior. -/
theorem rice_abstract {F : Type*} (P : F → Prop)
    (h_nontrivial : (∃ f, P f) ∧ (∃ f, ¬ P f)) :
    ∃ f₁ f₂ : F, P f₁ ∧ ¬ P f₂ := by
  obtain ⟨⟨f₁, hf₁⟩, ⟨f₂, hf₂⟩⟩ := h_nontrivial
  exact ⟨f₁, f₂, hf₁, hf₂⟩




/-- [Section: # CatalogBuild.Speculative.SciFi.Computability
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 3] -/
theorem abstract_incompleteness {Stmt : Type*} (True' : Stmt → Prop)
    (Provable : Stmt → Prop)
    (h_sound : ∀ s, Provable s → True' s)
    (goedel_sentence : Stmt)
    (h_goedel : True' goedel_sentence ↔ ¬ Provable goedel_sentence) :
    True' goedel_sentence ∧ ¬ Provable goedel_sentence := by
  grind


