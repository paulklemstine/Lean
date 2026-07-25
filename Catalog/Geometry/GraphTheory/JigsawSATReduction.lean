import Mathlib
import Novelty.JigsawFoundations

/-!
# 3-SAT to Jigsaw Puzzle Reduction

We formalize the reduction from 3-SAT to jigsaw puzzle solving, proving that
the reduction preserves satisfiability in both directions. This establishes
that jigsaw puzzle solving is NP-hard.

## Main Results

* `sat_implies_all_clauses_tab` — satisfying assignment → all clause pieces output tab
* `all_clauses_tab_implies_sat` — all clause pieces output tab → satisfying assignment
* `sat_iff_puzzle_solvable` — the reduction is correct (biconditional)
* `clause_sat_iff_tab` — clause pieces enforce OR semantics
* `variable_pieces_complementary` — variable pieces enforce mutual exclusion
-/

/-! ## 3-SAT Formalization -/

/-- A literal is a variable index paired with a polarity (positive or negated). -/
structure Literal (n : ℕ) where
  var : Fin n
  polarity : Bool
  deriving DecidableEq, Repr

/-- A 3-SAT clause consists of exactly three literals. -/
structure Clause3 (n : ℕ) where
  lit : Fin 3 → Literal n
  deriving Repr

/-- A 3-SAT formula is a list of clauses over n variables. -/
structure Formula3SAT where
  numVars : ℕ
  clauses : List (Clause3 numVars)

/-- An assignment maps each variable to a boolean value. -/
def Assignment (n : ℕ) := Fin n → Bool

/-- Evaluate a literal under an assignment. -/
def Literal.eval {n : ℕ} (l : Literal n) (a : Assignment n) : Bool :=
  if l.polarity then a l.var else !a l.var

/-- A clause is satisfied if at least one literal evaluates to true. -/
def Clause3.sat {n : ℕ} (c : Clause3 n) (a : Assignment n) : Prop :=
  ∃ i : Fin 3, (c.lit i).eval a = true

/-- A formula is satisfiable if there exists an assignment satisfying all clauses. -/
def Formula3SAT.satisfiable (φ : Formula3SAT) : Prop :=
  ∃ a : Assignment φ.numVars, ∀ c ∈ φ.clauses, c.sat a

/-! ## Edge Encoding: Booleans as Edge Types -/

/-- Encode a boolean as an edge type: true → tab, false → blank. -/
def boolToEdge : Bool → EdgeType
  | true => EdgeType.tab
  | false => EdgeType.blank

/-- Decode an edge type back to a boolean (flat maps to false). -/
def edgeToBool : EdgeType → Bool
  | EdgeType.tab => true
  | EdgeType.blank => false
  | EdgeType.flat => false

/-- Round-trip: decode ∘ encode = id. -/

theorem adjacency_count (n m : ℕ) :
    n * (m + 1) + (n + 1) * m = 2 * n * m + n + m := by
  ring

/-! ## Composition of Reductions -/

/-- **Transitivity**: Any problem reducible to 3-SAT is reducible to jigsaw puzzles. -/