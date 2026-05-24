/-
Copyright (c) 2025. All rights reserved.

# Clause Interaction Pathwidth: Definitions

Core mathematical objects for studying SAT solving memory through
the lens of graph pathwidth.

## Main Definitions

* `confGraph` — clause interaction graph of a CNF formula
* `PathDecomp` — path decomposition of a simple graph
* `activeFrontier` — clauses spanning a given cut
* `retainAtCut` — path-respecting retention policy
* `clauseEval` — clause evaluation under partial assignments
-/
import Mathlib

open Finset List

/-! ## SAT Primitives -/

variable {α : Type*} [DecidableEq α]

/-- A literal is a variable paired with a polarity. -/
abbrev Literal (α : Type*) := α × Bool

/-- A clause is a finite set of literals (representing a disjunction). -/
abbrev Clause (α : Type*) := Finset (Literal α)

/-- A CNF formula is a finite set of clauses (representing a conjunction). -/
abbrev CNF (α : Type*) := Finset (Clause α)

/-- The set of propositional variables appearing in a clause. -/
def clauseVars (C : Clause α) : Finset α :=
  C.image Prod.fst

/-- Two clauses are **adjacent** (interact) if they share at least one variable. -/
def clausesAdjacent (C D : Clause α) : Prop :=
  ∃ x : α, x ∈ clauseVars C ∧ x ∈ clauseVars D

/-! ## Clause Interaction Graph -/

/-- The **clause interaction graph** of a CNF formula `F`. Vertices are clauses in `F`,
and two distinct clauses are adjacent iff they share a propositional variable. -/
def confGraph (F : CNF α) : SimpleGraph (Clause α) where
  Adj C D := C ∈ F ∧ D ∈ F ∧ C ≠ D ∧ clausesAdjacent C D
  symm := by
    intro C D ⟨hC, hD, hne, x, hxC, hxD⟩
    exact ⟨hD, hC, Ne.symm hne, x, hxD, hxC⟩
  loopless := ⟨fun C ⟨_, _, hne, _⟩ => hne rfl⟩

/-! ## Path Decomposition -/

/-- A **path decomposition** of a simple graph `G`. -/
structure PathDecomp {V : Type*} [DecidableEq V] (G : SimpleGraph V) where
  bags : List (Finset V)
  bags_nonempty : bags ≠ []
  vertex_covered : ∀ v, (∃ w, G.Adj v w) →
    ∃ i, ∃ (hi : i < bags.length), v ∈ bags.get ⟨i, hi⟩
  edge_covered : ∀ ⦃u v⦄, G.Adj u v →
    ∃ i, ∃ (hi : i < bags.length),
      u ∈ bags.get ⟨i, hi⟩ ∧ v ∈ bags.get ⟨i, hi⟩
  running_intersection :
    ∀ v (i k : ℕ),
      i ≤ k →
      (hi : i < bags.length) →
      (hk : k < bags.length) →
      v ∈ bags.get ⟨i, hi⟩ →
      v ∈ bags.get ⟨k, hk⟩ →
      ∀ j, i ≤ j → j ≤ k → (hj : j < bags.length) →
        v ∈ bags.get ⟨j, hj⟩

namespace PathDecomp

variable {V : Type*} [DecidableEq V] {G : SimpleGraph V}

/-- The **width** of a path decomposition: max bag size minus one. -/
noncomputable def width (P : PathDecomp G) : ℕ :=
  (P.bags.map Finset.card).foldr max 0 - 1

/-- Maximum bag cardinality. -/
noncomputable def maxBagSize (P : PathDecomp G) : ℕ :=
  (P.bags.map Finset.card).foldr max 0

theorem width_eq (P : PathDecomp G) : P.width = P.maxBagSize - 1 := rfl

/-- Each element of a list is ≤ the foldr max. -/
private theorem list_get_le_foldr_max (l : List ℕ) (i : ℕ) (hi : i < l.length) :
    l.get ⟨i, hi⟩ ≤ l.foldr max 0 := by
  induction l generalizing i with
  | nil => simp at hi
  | cons hd tl ih =>
    cases i with
    | zero =>
      simp only [List.foldr_cons]
      exact le_max_left _ _
    | succ n =>
      simp only [List.get_cons_succ, List.foldr_cons]
      exact le_trans (ih n (by simpa using hi)) (le_max_right _ _)

/-- Each bag's cardinality is at most `maxBagSize`. -/
theorem card_bag_le_maxBagSize (P : PathDecomp G)
    (i : ℕ) (hi : i < P.bags.length) :
    (P.bags.get ⟨i, hi⟩).card ≤ P.maxBagSize := by
  simp only [maxBagSize]
  have hlen : i < (P.bags.map Finset.card).length := by simp; exact hi
  have : (P.bags.map Finset.card).get ⟨i, hlen⟩ =
    (P.bags.get ⟨i, hi⟩).card := by simp
  rw [← this]
  exact list_get_le_foldr_max _ _ hlen

theorem maxBagSize_le_width_add_one (P : PathDecomp G)
    (h : 0 < P.maxBagSize) :
    P.maxBagSize ≤ P.width + 1 := by
  simp [width_eq]; omega

end PathDecomp

/-! ## Active Frontier and Retention Policy -/

/-- The **active frontier** at cut index `i`: clauses whose bag-support spans `i`. -/
def activeFrontier
    (F : CNF α)
    (P : PathDecomp (confGraph F))
    (i : ℕ) : Finset (Clause α) :=
  F.filter (fun C =>
    (∃ j, ∃ (_ : j < P.bags.length), j ≤ i ∧ C ∈ P.bags.get ⟨j, ‹_›⟩) ∧
    (∃ k, ∃ (_ : k < P.bags.length), i ≤ k ∧ C ∈ P.bags.get ⟨k, ‹_›⟩))

/-- The set of variables appearing in a set of clauses. -/
def bagVars (B : Finset (Clause α)) : Finset α :=
  B.biUnion clauseVars

/-- The **retained subformula** at cut `i`. -/
def retainAtCut
    (F : CNF α)
    (P : PathDecomp (confGraph F))
    (i : ℕ)
    (hi : i < P.bags.length) : Finset (Clause α) :=
  (P.bags.get ⟨i, hi⟩ ∩ F) ∪ activeFrontier F P i

/-! ## Clause Evaluation -/

/-- A partial assignment maps variables to optional Boolean values. -/
def LocalAssignment (α : Type*) := α → Option Bool

/-- Two partial assignments agree on a set of variables. -/
def agreesOn (σ τ : LocalAssignment α) (S : Finset α) : Prop :=
  ∀ x ∈ S, σ x = τ x

/-- Evaluate a single literal under a partial assignment. -/
def litEval (σ : LocalAssignment α) (l : Literal α) : Option Bool :=
  match σ l.1 with
  | some b => some (b == l.2)
  | none => none

/-- Evaluate a clause under a partial assignment. -/
noncomputable def clauseEval (σ : LocalAssignment α) (C : Clause α) : Option Bool :=
  if ∃ l ∈ C, litEval σ l = some true then some true
  else if ∀ l ∈ C, litEval σ l = some false then some false
  else none

/-! ## Maximum Frontier Size -/

/-- The **maximum frontier size** across all valid cut positions. -/
noncomputable def maxFrontierSize
    (F : CNF α)
    (P : PathDecomp (confGraph F)) : ℕ :=
  (List.range P.bags.length |>.map (fun i =>
    if _hi : i < P.bags.length then (activeFrontier F P i).card else 0)).foldr max 0