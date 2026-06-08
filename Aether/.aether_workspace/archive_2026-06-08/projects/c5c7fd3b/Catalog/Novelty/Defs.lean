/-
# Fiber Graphs in Hamming Spaces

This file develops the theory of fiber graphs induced by additive scoring
functions on Hamming spaces. The central result is the Bridge Duality Theorem:
for two equal-score configurations differing at exactly two positions,
bridge existence through one position is equivalent to bridge existence
through the other.
-/
import Mathlib

open Finset BigOperators

namespace FiberGraph

variable {n q : ℕ} {G : Type*} [AddCommGroup G] [DecidableEq G]

/-! ## Core Definitions -/

/-- A configuration in the Hamming space: assignment of symbols to positions. -/
abbrev Config (n q : ℕ) := Fin n → Fin q

/-- An additive weight system: each position has a weight function from symbols to scores. -/
abbrev WeightSystem (n q : ℕ) (G : Type*) := Fin n → Fin q → G

/-- The additive score of a configuration under a weight system. -/
noncomputable def additiveScore (w : WeightSystem n q G) (x : Config n q) : G :=
  ∑ i : Fin n, w i (x i)

/-- The fiber of a value v: all configurations with score v. -/
def fiber (w : WeightSystem n q G) (v : G) : Set (Config n q) :=
  {x | additiveScore w x = v}

/-- Two configurations are Hamming-adjacent if they differ at exactly one position. -/
def hammingAdj (x y : Config n q) : Prop :=
  ∃! i : Fin n, x i ≠ y i

/-- The set of positions where two configurations differ. -/
def diffPositions [DecidableEq (Fin q)] (x y : Config n q) : Finset (Fin n) :=
  Finset.univ.filter (fun i => x i ≠ y i)

/-- A bridge through position i from x to y: an intermediate configuration z that
    agrees with x everywhere except at position i, has the same score as x, and
    makes z adjacent to both x and y in the fiber graph. -/
def bridgeThrough [DecidableEq (Fin q)] (w : WeightSystem n q G)
    (x y : Config n q) (i : Fin n) : Prop :=
  ∃ z : Config n q,
    (∀ k : Fin n, k ≠ i → z k = x k) ∧
    additiveScore w z = additiveScore w x ∧
    z i = y i

/-- The score difference when changing position i from symbol a to symbol b. -/
def scoreDelta (w : WeightSystem n q G) (i : Fin n) (a b : Fin q) : G :=
  w i b - w i a

/-- A fiber graph edge: two configurations are fiber-adjacent if they are
    Hamming-adjacent and have the same score. -/
def fiberAdj (w : WeightSystem n q G) (x y : Config n q) : Prop :=
  hammingAdj x y ∧ additiveScore w x = additiveScore w y

/-- The weight class of a position i: the set of score values achievable. -/
def weightClass (w : WeightSystem n q G) (i : Fin n) : Set G :=
  Set.range (w i)

/-- Configuration obtained by modifying x at position i to value a. -/
def modify (x : Config n q) (i : Fin n) (a : Fin q) : Config n q :=
  Function.update x i a

end FiberGraph