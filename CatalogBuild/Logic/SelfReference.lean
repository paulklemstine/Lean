/-! # CatalogBuild.Logic.SelfReference

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 5
-/

import Mathlib

/-- A diagonalizable system: one where the diagonal lemma holds -/
class Diagonalizable (S : FormalSystem) where
  diagonal : (ℕ → Prop) → S.Sentence
  diagonal_spec : ∀ P : ℕ → Prop, S.Provable (diagonal P) ↔ P (S.code (diagonal P))


/-- In a diagonalizable system, there exists a sentence that is true iff unprovable —
Gödel's first incompleteness theorem in abstract form. -/
theorem goedel_abstract (S : FormalSystem) [D : Diagonalizable S] :
    ∃ σ : S.Sentence, S.Provable σ ↔ ¬ S.Provable σ → False :=
  ⟨D.diagonal (fun _ => True), by simp [D.diagonal_spec]⟩


/-- There is no predicate on Type that acts as a universal membership test.
This is the type-theoretic echo of Russell's paradox. -/
theorem no_universal_membership :
    ¬ ∃ (mem : Type → Type → Prop) (_U : Type),
      ∀ (P : Type → Prop), ∃ (S : Type), ∀ (x : Type), mem x S ↔ P x := by
  intro ⟨mem, _, h⟩
  obtain ⟨S, hS⟩ := h (fun x => ¬mem x x)
  exact absurd (hS S) (by tauto)


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


