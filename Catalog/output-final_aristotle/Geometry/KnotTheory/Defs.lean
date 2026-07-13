/-
  # Foundations for the Kauffman bracket

  This file provides the combinatorial data underlying the Kauffman bracket state
  sum: smoothings of crossings, smoothing states of a diagram, the loop-count of a
  smoothed diagram, and the three Reidemeister moves recorded through their effect
  on the loop-count.

  A crossing may be resolved in one of two ways, an `A`-smoothing or a
  `B`-smoothing.  A *state* of an `n`-crossing diagram is a choice of smoothing at
  each crossing, i.e. a function `Fin n → Smoothing`.  A link diagram additionally
  records, for each state, the number of disjoint loops in the fully smoothed
  picture (always at least one).  Oriented diagrams carry a writhe.

  The Reidemeister moves are encoded structurally through the way the loop-count of
  the larger diagram relates to that of the smaller one under the two possible
  smoothings of the crossing that the move creates or removes.
-/
import Mathlib

namespace Knot

open Finset

/-- A crossing is resolved by one of two smoothings. -/
inductive Smoothing
  | A
  | B
deriving DecidableEq, Fintype

/-- A smoothing state of an `n`-crossing diagram: a choice of smoothing at each
crossing. -/
abbrev KState (n : ℕ) := Fin n → Smoothing

/-- The number of `A`-smoothings in a state. -/
def numA {n : ℕ} (s : KState n) : ℕ :=
  (Finset.univ.filter (fun i => s i = Smoothing.A)).card

/-- The number of `B`-smoothings in a state. -/
def numB {n : ℕ} (s : KState n) : ℕ :=
  (Finset.univ.filter (fun i => s i = Smoothing.B)).card

/-- Every crossing is either an `A`- or a `B`-smoothing, so the two counts add up
to the number of crossings. -/
theorem numA_add_numB {n : ℕ} (s : KState n) : numA s + numB s = n := by
  simp only [numA, numB, Finset.card_filter]
  rw [← Finset.sum_add_distrib,
    Finset.sum_congr rfl (fun i _ => by rcases s i with _ | _ <;> rfl),
    Finset.sum_const, Finset.card_fin]
  simp

/-- A link diagram on `n` crossings, recorded through the loop-count of each of its
smoothing states.  A fully smoothed diagram always has at least one loop. -/
structure LinkDiagram (n : ℕ) where
  /-- The number of loops in the diagram smoothed according to a given state. -/
  loops : KState n → ℕ
  /-- A smoothed diagram has at least one loop. -/
  loops_pos : ∀ s, 0 < loops s

/-- An oriented link diagram additionally records a writhe. -/
structure OrientedLinkDiagram (n : ℕ) extends LinkDiagram n where
  /-- The writhe (signed crossing count) of the oriented diagram. -/
  writhe : ℤ

/-- The unknot, drawn with no crossings: a single loop. -/
def unknotDiagram : LinkDiagram 0 where
  loops := fun _ => 1
  loops_pos := fun _ => Nat.one_pos

/-- **Positive Reidemeister I.**  `D₁` has one more crossing (a positive kink) than
`D₂`.  Smoothing the kink one way splits off an extra loop; smoothing it the other
way leaves the loop-count unchanged. -/
structure ReidemeisterI {n : ℕ} (D₁ : OrientedLinkDiagram (n + 1))
    (D₂ : OrientedLinkDiagram n) : Prop where
  /-- The positive kink increases the writhe by one. -/
  writhe_rel : D₁.writhe = D₂.writhe + 1
  /-- The `A`-smoothing of the kink splits off an extra loop. -/
  loops_A : ∀ s : KState n, D₁.loops (Fin.snoc s Smoothing.A) = D₂.loops s + 1
  /-- The `B`-smoothing of the kink preserves the loop-count. -/
  loops_B : ∀ s : KState n, D₁.loops (Fin.snoc s Smoothing.B) = D₂.loops s

/-- **Negative Reidemeister I.**  As above but for a negative kink, with the roles
of the two smoothings exchanged. -/
structure ReidemeisterI_neg {n : ℕ} (D₁ : OrientedLinkDiagram (n + 1))
    (D₂ : OrientedLinkDiagram n) : Prop where
  /-- The negative kink decreases the writhe by one. -/
  writhe_rel : D₁.writhe = D₂.writhe - 1
  /-- The `A`-smoothing of the kink preserves the loop-count. -/
  loops_A : ∀ s : KState n, D₁.loops (Fin.snoc s Smoothing.A) = D₂.loops s
  /-- The `B`-smoothing of the kink splits off an extra loop. -/
  loops_B : ∀ s : KState n, D₁.loops (Fin.snoc s Smoothing.B) = D₂.loops s + 1

/-- **Reidemeister III.**  The two diagrams have the same crossings up to a
loop- and `A`-count preserving relabelling of their states. -/
def ReidemeisterIII {n : ℕ} (D₁ D₂ : LinkDiagram n) : Prop :=
  ∃ f : KState n → KState n, Function.Bijective f ∧
    (∀ s, numA s = numA (f s)) ∧ (∀ s, D₁.loops s = D₂.loops (f s))

end Knot