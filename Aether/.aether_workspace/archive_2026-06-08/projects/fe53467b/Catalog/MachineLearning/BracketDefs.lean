/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tournament Bracket Definitions for Certified Robustness

This file defines the core data structures for tournament-style multiclass
classification: binary elimination brackets, recursive winners, winner paths,
and the recursive margin certification predicate.
-/
import Mathlib

open Classical in
noncomputable section

namespace TournamentRobustness

/-- A full binary tree of labels, representing a tournament bracket.
    Leaves hold class labels; internal nodes represent comparison stages. -/
inductive Bracket (α : Type)
  | leaf : α → Bracket α
  | node : Bracket α → Bracket α → Bracket α
  deriving DecidableEq

variable {α : Type} {X : Type}

/-- The recursive tournament winner: at a leaf, the label itself;
    at an internal node, compare the winners of the two subtrees and
    return the one with the higher score (breaking ties in favor of left). -/
noncomputable def Bracket.winner (score : α → X → ℝ) : Bracket α → X → α
  | .leaf a, _ => a
  | .node l r, x =>
    let wl := l.winner score x
    let wr := r.winner score x
    if score wl x ≥ score wr x then wl else wr

variable {d : ℕ}

/-- Recursive margin certification predicate.
    For a leaf, certification is automatic.
    For a node, we require:
    - Both children are certified (their subtree winners are stable on the ball)
    - The score gap at x0 between the node winner and the opposing child winner
      exceeds the Lipschitz drift bound on the ball of radius r.
    This ensures the tournament winner is unchanged throughout the ball. -/
inductive RecursiveMarginCert [DecidableEq α]
    (score : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ) (rad : ℝ)
    (L : α → α → ℝ) : Bracket α → Prop
  | leaf (a : α) : RecursiveMarginCert score x0 rad L (.leaf a)
  | node_left {l r : Bracket α}
    (hl : RecursiveMarginCert score x0 rad L l)
    (hr : RecursiveMarginCert score x0 rad L r)
    (hge : score (l.winner score x0) x0 ≥ score (r.winner score x0) x0)
    (hgap : L (l.winner score x0) (r.winner score x0) * rad <
             score (l.winner score x0) x0 - score (r.winner score x0) x0) :
    RecursiveMarginCert score x0 rad L (.node l r)
  | node_right {l r : Bracket α}
    (hl : RecursiveMarginCert score x0 rad L l)
    (hr : RecursiveMarginCert score x0 rad L r)
    (hlt : score (l.winner score x0) x0 < score (r.winner score x0) x0)
    (hgap : L (r.winner score x0) (l.winner score x0) * rad <
             score (r.winner score x0) x0 - score (l.winner score x0) x0) :
    RecursiveMarginCert score x0 rad L (.node l r)

/-- A winner-path node records the winning and opposing labels at an internal
    bracket node on the path from the champion leaf to the root. -/
structure WinnerPathNode (α : Type) where
  winLabel : α
  oppLabel : α
  deriving DecidableEq

/-- Extract the list of winner-path nodes from root to the champion leaf.
    Each entry records the winning child's label and the opposing child's label
    at that internal node. -/
noncomputable def Bracket.winnerPath (score : α → X → ℝ) : Bracket α → X → List (WinnerPathNode α)
  | .leaf _, _ => []
  | .node l r, x =>
    let wl := l.winner score x
    let wr := r.winner score x
    if score wl x ≥ score wr x then
      ⟨wl, wr⟩ :: l.winnerPath score x
    else
      ⟨wr, wl⟩ :: r.winnerPath score x

/-- The winner path of a node bracket is nonempty. -/
lemma Bracket.winnerPath_nonempty_of_node (score : α → X → ℝ) (l r : Bracket α) (x : X) :
    (Bracket.node l r).winnerPath score x ≠ [] := by
  simp [Bracket.winnerPath]
  split <;> exact List.cons_ne_nil _ _

end TournamentRobustness

end