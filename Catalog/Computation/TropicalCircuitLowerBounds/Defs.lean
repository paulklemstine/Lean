import Mathlib

/-! Basic definitions for tropical circuit path and assignment costs. -/

namespace TropicalCircuit

/-- A matrix is layered when every positive-weight edge points to a strictly
later layer. -/
def IsLayered {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : Prop :=
  ∀ i j, 0 < M i j → i < j

/-- A list is a path when every consecutive matrix entry has positive weight. -/
def IsPath {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : List (Fin n) → Prop
  | [] => True
  | [_] => True
  | a :: b :: rest => 0 < M a b ∧ IsPath M (b :: rest)

/-- Number of consecutive edges in a vertex list. -/
def pathEdges {α : Type*} : List α → ℕ
  | [] => 0
  | _ :: rest => rest.length

/-- Sum of the weights of consecutive edges along a list. -/
def pathCost {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : List (Fin n) → ℕ
  | [] => 0
  | [_] => 0
  | a :: b :: rest => M a b + pathCost M (b :: rest)

/-- Cost of the assignment represented by a permutation. -/
def permCost {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ)
    (σ : Equiv.Perm (Fin n)) : ℕ :=
  ∑ i, M i (σ i)

/-- The min-plus permanent: the least assignment cost. -/
noncomputable def minPlusPerm {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : ℕ :=
  Finset.univ.inf' Finset.univ_nonempty (permCost M)

end TropicalCircuit