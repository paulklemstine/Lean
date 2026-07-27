/-
# Executable small-case evidence for square-lattice self-avoiding walks

This independent finite enumerator represents a walk by a list of cardinal
steps, computes all visited vertices, and filters by pairwise distinctness.
The final theorem kernel-checks the classical initial count sequence through
length six: `1, 4, 12, 36, 100, 284, 780`.
-/

import Mathlib

namespace SAWResearchEvidence

abbrev Point := ℤ × ℤ

inductive Step where
  | north | south | east | west
  deriving DecidableEq, Repr

/-- Apply one cardinal step. -/
def move : Point → Step → Point
  | (x, y), .north => (x, y + 1)
  | (x, y), .south => (x, y - 1)
  | (x, y), .east => (x + 1, y)
  | (x, y), .west => (x - 1, y)

/-- Vertices visited by a step list, including the origin. -/
def visitedVertices (w : List Step) : List Point :=
  w.scanl move (0, 0)

/-- Executable self-avoidance test. -/
def isSelfAvoiding (w : List Step) : Bool :=
  decide (visitedVertices w).Nodup

/-- All cardinal-step words of a fixed length. -/
def allWalks : ℕ → List (List Step)
  | 0 => [[]]
  | n + 1 => (allWalks n).flatMap fun w =>
      [.north :: w, .south :: w, .east :: w, .west :: w]

/-- Brute-force number of square-lattice SAWs of length `n`. -/
def enumeratedCount (n : ℕ) : ℕ :=
  ((allWalks n).filter isSelfAvoiding).length

/-- A checked table of the first seven square-lattice SAW counts.  Unlike an
external script, this finite calculation is replayed by Lean's evaluator. -/
theorem enumeratedCount_first_seven :
    (List.range 7).map enumeratedCount =
      [1, 4, 12, 36, 100, 284, 780] := by
  set_option maxRecDepth 100000 in
    decide

/-- The first nontrivial ratio is already incompatible with interpreting
`(2+√2)/2` as an obvious finite-step branching factor: there are 12 two-step
walks, or three continuations after each first step. -/
theorem enumeratedCount_two : enumeratedCount 2 = 12 := by
  have h := congrArg (fun xs : List ℕ => xs[2]?) enumeratedCount_first_seven
  norm_num at h
  exact h

end SAWResearchEvidence