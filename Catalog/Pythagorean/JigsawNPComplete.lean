import Mathlib

/-!
# A jigsaw-assembly encoding of CNF satisfiability

This file supplies the reduction infrastructure used by
`Shared.JigsawSolutionSpace`.

A CNF formula is turned into a *puzzle*: one **variable piece** per declared
variable, one **literal piece** per literal occurrence, and one **clause piece**
per clause.  Edges carry an integer shape, `+1` for a tab and `-1` for a blank.
A literal piece with polarity `b` carries the tab shape `tabShape b`; a variable
piece carries the blank shape determined by the current truth assignment.  A
literal piece can be locked into the assembly exactly when its tab matches the
blank offered by its variable, and a clause piece is assembled when at least one
of its literal pieces locks in.

The main correctness statement is `puzzle_solvable_iff_satisfiable`, and the
sharper local statement `clausePieceFits_iff` is what makes the reduction
*parsimonious*: it preserves the witness itself, not merely its existence.

-- !-- Lab Notes -- !--

* Hypothesis: geometric interlocking constraints are expressive enough to encode
  Boolean clause satisfaction *witness for witness*, not just yes/no.
* Experiment: shapes were modelled by the two-element set `{+1, -1} ⊆ ℤ`, the
  tab/blank involution being negation.  `clausePieceFits_iff` was proved by
  unfolding the shape equation to a Boolean equation.
* Analysis: the equivalence is pointwise in the assignment, so it lifts to a
  bijection of solution spaces (carried out in `Shared.JigsawSolutionSpace`).
* Critique: this is an abstract combinatorial model of interlocking, not a
  Euclidean-geometry model; it establishes witness-preserving equivalence with
  CNF-SAT, not a full NP-completeness theorem for geometric jigsaw puzzles.
-/

namespace Jigsaw

/-- A literal: a variable index together with a polarity. -/
abbrev Literal : Type := ℕ × Bool

/-- A clause is a disjunction of literals. -/
abbrev Clause : Type := List Literal

/-- A formula in conjunctive normal form. -/
abbrev Formula : Type := List Clause

/-- A truth assignment for all variable indices. -/
abbrev Assignment : Type := ℕ → Bool

/-! ## Boolean semantics -/

/-- A literal is satisfied when the assignment matches its polarity. -/
def litSat (a : Assignment) (l : Literal) : Prop := a l.1 = l.2

instance (a : Assignment) (l : Literal) : Decidable (litSat a l) := by
  unfold litSat; infer_instance

/-- A clause is satisfied when one of its literals is. -/
def clauseSat (a : Assignment) (c : Clause) : Prop := ∃ l ∈ c, litSat a l

/-- A formula is satisfied when all of its clauses are. -/
def Formula.Sat (F : Formula) (a : Assignment) : Prop := ∀ c ∈ F, clauseSat a c

/-- A formula is satisfiable when some assignment satisfies it. -/
def Formula.Satisfiable (F : Formula) : Prop := ∃ a : Assignment, F.Sat a

/-! ## Puzzle pieces and interlocking shapes -/

/-- The pieces of the puzzle built from a formula. -/
inductive Piece where
  /-- The piece carrying the truth value of variable `i`. -/
  | var (i : ℕ) : Piece
  /-- The piece for the `k`-th clause's occurrence of literal `l`. -/
  | lit (k : ℕ) (l : Literal) : Piece
  /-- The piece that must be locked in for clause `k`. -/
  | clause (k : ℕ) : Piece
  deriving DecidableEq, Repr

/-- The full piece list: one variable piece for each of the `n` declared
variables, one literal piece per literal occurrence, one clause piece per
clause. -/
def allPieces (n : ℕ) (F : Formula) : List Piece :=
  (List.range n).map Piece.var ++
    (F.zipIdx.flatMap fun p => p.1.map fun l => Piece.lit p.2 l) ++
    (List.range F.length).map Piece.clause

private theorem length_litPieces (F : Formula) (k : ℕ) :
    ((F.zipIdx k).flatMap fun p => p.1.map fun l => Piece.lit p.2 l).length
      = (F.map List.length).sum := by
  induction F generalizing k with
  | nil => simp
  | cons c F ih => simp [List.zipIdx_cons, ih]

@[simp] theorem length_allPieces (n : ℕ) (F : Formula) :
    (allPieces n F).length = n + (F.map List.length).sum + F.length := by
  simp only [allPieces, List.length_append, List.length_map, List.length_range,
    length_litPieces]

/-- Edge shape of a tab carried by a literal of polarity `b`: `+1` for a tab,
`-1` for a blank. -/
def tabShape (b : Bool) : ℤ := if b then 1 else -1

/-- Edge shape offered by the variable piece for variable `i` under the current
assignment. -/
def blankShape (a : Assignment) (i : ℕ) : ℤ := if a i then 1 else -1

@[simp] theorem tabShape_true : tabShape true = 1 := rfl
@[simp] theorem tabShape_false : tabShape false = -1 := rfl

/-- Two shapes are equal exactly when the underlying Booleans agree; the
tab/blank alphabet is faithful. -/
theorem tabShape_inj {b b' : Bool} (h : tabShape b = tabShape b') : b = b' := by
  cases b <;> cases b' <;> simp [tabShape] at h ⊢

/-- A literal piece locks into its variable piece when the tab shape it carries
matches the blank shape offered by the assignment. -/
def pieceFits (a : Assignment) (l : Literal) : Prop :=
  tabShape l.2 = blankShape a l.1

instance (a : Assignment) (l : Literal) : Decidable (pieceFits a l) := by
  unfold pieceFits; infer_instance

/-- Interlocking is exactly literal satisfaction. -/
theorem pieceFits_iff (a : Assignment) (l : Literal) :
    pieceFits a l ↔ litSat a l := by
  unfold pieceFits litSat blankShape
  cases hl : l.2 <;> cases ha : a l.1 <;> simp [tabShape]

/-- A clause piece is assembled when at least one of its literal pieces locks
into place. -/
def clausePieceFits (a : Assignment) (c : Clause) : Prop :=
  ∃ l ∈ c, pieceFits a l

/-- **Local parsimony.** For a *fixed* assignment, a clause piece assembles iff
the clause is satisfied.  This is what upgrades the reduction from
equisatisfiability to a witness bijection. -/
theorem clausePieceFits_iff (a : Assignment) (c : Clause) :
    clausePieceFits a c ↔ clauseSat a c := by
  unfold clausePieceFits clauseSat
  exact exists_congr fun l => and_congr_right fun _ => pieceFits_iff a l

/-- The puzzle built from `F` is assembled by the recipe `a`. -/
def PuzzleAssembled (F : Formula) (a : Assignment) : Prop :=
  ∀ c ∈ F, clausePieceFits a c

/-- The puzzle built from `F` admits some assembly. -/
def PuzzleSolvable (F : Formula) : Prop := ∃ a : Assignment, PuzzleAssembled F a

/-- **Correctness of the reduction.** The constructed puzzle is solvable exactly
when the formula is satisfiable. -/
theorem puzzle_solvable_iff_satisfiable (F : Formula) :
    PuzzleSolvable F ↔ F.Satisfiable := by
  unfold PuzzleSolvable Formula.Satisfiable
  refine exists_congr fun a => ?_
  unfold PuzzleAssembled Formula.Sat
  exact forall_congr' fun c => imp_congr_right fun _ => clausePieceFits_iff a c

/-- Assembly of a fixed recipe is decidable, and by a check that is linear in
the number of literal occurrences: the puzzle model has an efficient verifier. -/
instance decidablePuzzleAssembled (F : Formula) (a : Assignment) :
    Decidable (PuzzleAssembled F a) := by
  unfold PuzzleAssembled clausePieceFits; infer_instance

/-- The empty formula is trivially assembled. -/
@[simp] theorem puzzleAssembled_nil (a : Assignment) : PuzzleAssembled [] a := by
  intro c hc; cases hc

/-- A formula containing the empty clause is unassemblable: the corresponding
clause piece has no tab to lock into. -/
theorem not_puzzleSolvable_of_nil_mem {F : Formula} (h : ([] : Clause) ∈ F) :
    ¬ PuzzleSolvable F := by
  rintro ⟨a, ha⟩
  obtain ⟨l, hl, -⟩ := ha [] h
  cases hl

end Jigsaw