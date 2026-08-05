/-
  Packing-Isolating Sets — basic definitions

  This file supplies the definitions used by `Probability.Constructions`
  (packing-isolating sets in block graphs).

  For a finite simple graph `G` and a vertex `v`, `closedNbhd G v` is the closed
  neighbourhood `{v} ∪ N(v)`, and `nbhdSet G S = ⋃_{v ∈ S} closedNbhd G v`.

  * `IsTwoPacking G S` : the closed neighbourhoods of distinct members of `S` are
    pairwise disjoint (equivalently, distinct members of `S` are at distance `≥ 3`).
  * `IsIsolating G S` : every edge of `G` has an endpoint in `nbhdSet G S`, i.e.
    deleting `nbhdSet G S` leaves no edges.
  * `IsPackingIsolating G S` : both conditions hold.
-/
import Mathlib

open Finset SimpleGraph
open scoped Classical

namespace PackingIsolation

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The closed neighbourhood `{v} ∪ N(v)` of a vertex. -/
noncomputable def closedNbhd (G : SimpleGraph V) (v : V) : Finset V :=
  insert v (G.neighborFinset v)

/-- The union of the closed neighbourhoods of the members of `S`. -/
noncomputable def nbhdSet (G : SimpleGraph V) (S : Finset V) : Finset V :=
  S.biUnion (fun v => closedNbhd G v)

@[simp] theorem mem_closedNbhd {G : SimpleGraph V} {v x : V} :
    x ∈ closedNbhd G v ↔ x = v ∨ G.Adj v x := by
  simp [closedNbhd]

theorem mem_nbhdSet {G : SimpleGraph V} {S : Finset V} {x : V} :
    x ∈ nbhdSet G S ↔ ∃ v ∈ S, (x = v ∨ G.Adj v x) := by
  simp [nbhdSet, mem_closedNbhd]

/-- `S` is a *2-packing*: the closed neighbourhoods of distinct members are disjoint. -/
def IsTwoPacking (G : SimpleGraph V) (S : Finset V) : Prop :=
  ∀ u ∈ S, ∀ v ∈ S, u ≠ v → Disjoint (closedNbhd G u) (closedNbhd G v)

/-- `S` is *isolating*: every edge of `G` meets the closed neighbourhood of `S`. -/
def IsIsolating (G : SimpleGraph V) (S : Finset V) : Prop :=
  ∀ u v : V, G.Adj u v → u ∈ nbhdSet G S ∨ v ∈ nbhdSet G S

/-- `S` is *packing-isolating*: it is simultaneously a 2-packing and isolating. -/
def IsPackingIsolating (G : SimpleGraph V) (S : Finset V) : Prop :=
  IsTwoPacking G S ∧ IsIsolating G S

/-- A singleton is always a 2-packing (there are no distinct pairs to separate). -/
theorem isTwoPacking_singleton {G : SimpleGraph V} (v : V) :
    IsTwoPacking G ({v} : Finset V) := by
  intro a ha b hb hab
  rw [Finset.mem_singleton] at ha hb
  exact absurd (ha.trans hb.symm) hab

/-- A dominating set (one whose closed neighbourhood is everything) is isolating. -/
theorem isIsolating_of_dominating {G : SimpleGraph V} {S : Finset V}
    (h : ∀ x : V, x ∈ nbhdSet G S) : IsIsolating G S :=
  fun u _ _ => Or.inl (h u)

end PackingIsolation