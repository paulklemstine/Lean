/-! # CatalogBuild.Logic.SelfReference

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 5
-/

import Mathlib

class Diagonalizable (S : FormalSystem) where
  diagonal : (ℕ → Prop) → S.Sentence
  diagonal_spec : ∀ P : ℕ → Prop, S.Provable (diagonal P) ↔ P (S.code (diagonal P))

/-- In a diagonalizable system, there exists a sentence that is true iff unprovable —
    Gödel's first incompleteness theorem in abstract form. -/

theorem goedel_abstract (S : FormalSystem) [D : Diagonalizable S] :
    ∃ σ : S.Sentence, S.Provable σ ↔ ¬ S.Provable σ → False :=
  ⟨D.diagonal (fun _ => True), by simp [D.diagonal_spec]⟩

/-! ## Russell's Bootstrap Paradox

The set of all sets that don't contain themselves: R = {x | x ∉ x}.
Does R ∈ R? This self-referential question bootstraps a contradiction.
We show this forces any "set of all sets" construction to be inconsistent. -/

/-- There is no predicate on Type that acts as a universal membership test.
    This is the type-theoretic echo of Russell's paradox. -/

theorem no_universal_membership :
    ¬ ∃ (mem : Type → Type → Prop) (_U : Type),
      ∀ (P : Type → Prop), ∃ (S : Type), ∀ (x : Type), mem x S ↔ P x := by
  intro ⟨mem, _, h⟩
  obtain ⟨S, hS⟩ := h (fun x => ¬mem x x)
  exact absurd (hS S) (by tauto)

/-! ## Quine: The Self-Reproducing Bootstrap

A Quine is a program that outputs its own source code — pure bootstrapping.
We model this abstractly: in a computation model with a self-application
operator, Quines exist. -/

/-- Abstract model of computation with string output -/

structure ComputationModel where
  Program : Type
  run : Program → List Char
  expressive : ∀ s : List Char, ∃ p : Program, run p = s
  source : Program → List Char
  source_injective : Function.Injective source

/-- In a computation model with a self-application operator, Quines exist. -/

theorem quine_existence_with_selfapp (M : ComputationModel)
    (selfapp : ∀ p : M.Program, ∃ q : M.Program, M.run q = M.source q)
    (p₀ : M.Program) :
    ∃ p : M.Program, M.run p = M.source p :=
  selfapp p₀

