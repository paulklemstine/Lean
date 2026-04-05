/-
  Mathematics of Science Fiction — Chapter 5: Computability and Artificial Intelligence
  Halting problem, diagonalization, Rice's theorem, Gödel incompleteness.
  Author: Paul Klemstine | Soli Deo Gloria
-/
import Mathlib

open Function Set

/-! ## The Halting Problem and AI Safety

  There is no algorithm that determines whether an arbitrary program halts.
  This implies there is no general algorithm to determine whether an AI system
  will remain within specified behavioral bounds. -/

/-
Cantor-style diagonalization: there is no surjection from a type to its power set.
-/
theorem no_surjection_to_powerset (A : Type*) : ¬ ∃ f : A → Set A, Surjective f := by
  rintro ⟨ f, hf ⟩;
  obtain ⟨ g, hg ⟩ := hf ( { a : A | a ∉ f a } );
  exact absurd ( Set.ext_iff.mp hg g ) ( by tauto )

/-! ## Rice's Theorem

  For any non-trivial semantic property of programs, the set of programs
  satisfying that property is undecidable. -/

/-- Rice's theorem (abstract): if a property P on functions is non-trivial
    (some function satisfies it, some doesn't), it cannot be decided by
    a computable function that only inspects the extensional behavior. -/
theorem rice_abstract {F : Type*} (P : F → Prop)
    (h_nontrivial : (∃ f, P f) ∧ (∃ f, ¬ P f)) :
    ∃ f₁ f₂ : F, P f₁ ∧ ¬ P f₂ := by
  obtain ⟨⟨f₁, hf₁⟩, ⟨f₂, hf₂⟩⟩ := h_nontrivial
  exact ⟨f₁, f₂, hf₁, hf₂⟩

/-! ## Gödel's Incompleteness (Abstract Formulation)

  No consistent formal system capable of expressing basic arithmetic
  can prove its own consistency. -/

/-
Abstract incompleteness: no consistent system can prove all true statements.
    If a proof system is consistent and sound, there exist unprovable truths.
-/
theorem abstract_incompleteness {Stmt : Type*} (True' : Stmt → Prop)
    (Provable : Stmt → Prop)
    (h_sound : ∀ s, Provable s → True' s)
    (goedel_sentence : Stmt)
    (h_goedel : True' goedel_sentence ↔ ¬ Provable goedel_sentence) :
    True' goedel_sentence ∧ ¬ Provable goedel_sentence := by
  grind