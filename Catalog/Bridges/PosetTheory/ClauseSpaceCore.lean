import Mathlib

/-!
# Core syntax for the tropical clause space

`Bridges/PosetTheory/TropicalClauseSpace.lean` develops a bridge between proof
complexity and tropical geometry, but the elementary CNF vocabulary it is written
against (literals, clauses, formulas, assignments and clause configurations) was not
present anywhere in this repository, so the file did not compile.  This module supplies
that vocabulary, in the form forced by the way `TropicalClauseSpace` uses it:

* `Literal n`, `Assignment n`, `Literal.satisfiedBy`;
* `Clause n` (a finite set of literals) and `emptyClause`;
* `CNFFormula n` (a finite set of clauses) with `satisfiedBy` and `IsUnsat`;
* `Config n s` — a clause configuration carrying at most `s` clauses — and the empty
  configuration.
-/

/-- A literal over `n` propositional variables: a variable or its negation. -/
inductive Literal (n : ℕ) where
  | pos (i : Fin n) : Literal n
  | neg (i : Fin n) : Literal n
  deriving DecidableEq, Repr

instance (n : ℕ) : Fintype (Literal n) where
  elems := (Finset.univ.image Literal.pos) ∪ (Finset.univ.image Literal.neg)
  complete := by
    intro l
    cases l with
    | pos i => exact Finset.mem_union_left _ (Finset.mem_image_of_mem _ (Finset.mem_univ i))
    | neg i => exact Finset.mem_union_right _ (Finset.mem_image_of_mem _ (Finset.mem_univ i))

/-- A truth assignment to the `n` variables. -/
def Assignment (n : ℕ) : Type := Fin n → Bool

/-- When a literal is satisfied by an assignment. -/
def Literal.satisfiedBy {n : ℕ} : Literal n → Assignment n → Prop
  | .pos i, σ => σ i = true
  | .neg i, σ => σ i = false

instance {n : ℕ} (l : Literal n) (σ : Assignment n) : Decidable (l.satisfiedBy σ) := by
  cases l <;> unfold Literal.satisfiedBy <;> infer_instance

/-- A clause is a finite set of literals, read disjunctively. -/
abbrev Clause (n : ℕ) : Type := Finset (Literal n)

/-- The empty clause, the unsatisfiable one. -/
def emptyClause (n : ℕ) : Clause n := ∅

/-- A CNF formula is a finite set of clauses, read conjunctively. -/
abbrev CNFFormula (n : ℕ) : Type := Finset (Clause n)

/-- A formula is satisfied when every clause has a satisfied literal. -/
def CNFFormula.satisfiedBy {n : ℕ} (F : CNFFormula n) (σ : Assignment n) : Prop :=
  ∀ C ∈ F, ∃ l ∈ C, Literal.satisfiedBy l σ

/-- A formula is unsatisfiable when no assignment satisfies it. -/
def CNFFormula.IsUnsat {n : ℕ} (F : CNFFormula n) : Prop :=
  ∀ σ : Assignment n, ¬ F.satisfiedBy σ

/-- A **clause configuration**: the finite set of clauses currently held in memory by a
proof state, subject to a space bound `s`. -/
structure Config (n s : ℕ) where
  /-- The clauses currently active. -/
  clauses : Finset (Clause n)
  /-- The space bound. -/
  hsize : clauses.card ≤ s

@[ext]
theorem Config.ext {n s : ℕ} {C D : Config n s} (h : C.clauses = D.clauses) : C = D := by
  cases C; cases D; simpa using h

instance {n s : ℕ} : DecidableEq (Config n s) := fun C D =>
  decidable_of_iff (C.clauses = D.clauses) ⟨fun h => Config.ext h, fun h => by rw [h]⟩

/-- The configuration holding no clauses. -/
def emptyConfig (n s : ℕ) : Config n s := ⟨∅, by simp⟩