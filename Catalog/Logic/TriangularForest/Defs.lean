import Mathlib

/-!
# Triangular forests

A *triangular forest* is a graph in which every 2-connected block is a single edge or a
triangle.  Equivalently (and this is the definition we use, since it is the most convenient
one to reason with) a graph is a triangular forest exactly when **every cycle has length 3**.

The two descriptions agree: a 2-connected graph on at least four vertices always contains a
cycle of length at least four, and two triangles sharing an edge span a 4-cycle, so "every
cycle is a triangle" forces every block to be an edge or a triangle, and conversely.

This file sets up the basic theory:

* `TriangularForest.IsTriangularForest` — the definition;
* closure under subgraphs (`IsTriangularForest.mono`) and induced subgraphs
  (`IsTriangularForest.induce`);
* forests are triangular forests;
* every vertex on a cycle has degree at least two, hence a cycle is no longer than the number
  of vertices of degree at least two (`IsCycle.length_le_card_two_le_degree`);
* consequently any graph with at most three vertices of degree ≥ 2 is a triangular forest
  (`isTriangularForest_of_card_two_le_degree_le_three`), which is the workhorse for verifying
  concrete examples.
-/

namespace TriangularForest

open SimpleGraph Finset

variable {V : Type*} {G H : SimpleGraph V}

/-- A graph is a **triangular forest** when every one of its cycles is a triangle. -/
def IsTriangularForest (G : SimpleGraph V) : Prop :=
  ∀ ⦃v : V⦄ (c : G.Walk v v), c.IsCycle → c.length = 3

/-- Acyclic graphs (forests) are triangular forests. -/
theorem isTriangularForest_of_isAcyclic (h : G.IsAcyclic) : IsTriangularForest G :=
  fun _ c hc => absurd hc (h c)

/-- The empty graph is a triangular forest. -/
theorem isTriangularForest_bot : IsTriangularForest (⊥ : SimpleGraph V) :=
  isTriangularForest_of_isAcyclic isAcyclic_bot

/-- Triangular forests are closed under taking subgraphs. -/
theorem IsTriangularForest.mono (hle : H ≤ G) (hG : IsTriangularForest G) :
    IsTriangularForest H := by
  intro v c hc
  have := hG (c.mapLe hle) (hc.mapLe hle)
  simpa using this

/-- Triangular forests are closed under taking induced subgraphs. -/
theorem IsTriangularForest.induce (s : Set V) (hG : IsTriangularForest G) :
    IsTriangularForest (G.induce s) := by
  intro v c hc
  have hinj : Function.Injective (SimpleGraph.Embedding.induce (G := G) s).toHom :=
    (SimpleGraph.Embedding.induce (G := G) s).injective
  have := hG (c.map (SimpleGraph.Embedding.induce (G := G) s).toHom) (hc.map hinj)
  simpa using this

section Degrees

variable [Fintype V] [DecidableRel G.Adj]

/-- Every vertex lying on a cycle has at least two neighbours. -/
theorem two_le_degree_of_mem_support {v : V} {c : G.Walk v v} (hc : c.IsCycle) {x : V}
    (hx : x ∈ c.support) : 2 ≤ G.degree x := by
  classical
  have hcx : (c.rotate hx).IsCycle := hc.rotate hx
  have hnil : ¬ (c.rotate hx).Nil := hcx.not_nil
  have h1 : G.Adj x (c.rotate hx).snd := (c.rotate hx).adj_snd hnil
  have h2 : G.Adj x (c.rotate hx).penultimate :=
    ((c.rotate hx).adj_penultimate hnil).symm
  have hne : (c.rotate hx).snd ≠ (c.rotate hx).penultimate := hcx.snd_ne_penultimate
  have hsub : ({(c.rotate hx).snd, (c.rotate hx).penultimate} : Finset V) ⊆
      G.neighborFinset x := by
    intro y hy
    simp only [Finset.mem_insert, Finset.mem_singleton] at hy
    rcases hy with rfl | rfl <;> simpa using ‹_›
  have := Finset.card_le_card hsub
  rwa [Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton,
    card_neighborFinset_eq_degree] at this

variable [DecidableEq V]

/-- A cycle cannot be longer than the number of vertices of degree at least two. -/
theorem length_le_card_two_le_degree_of_isCycle {v : V} {c : G.Walk v v} (hc : c.IsCycle) :
    c.length ≤ #{x ∈ (univ : Finset V) | 2 ≤ G.degree x} := by
  classical
  have hnodup : c.support.tail.Nodup := hc.support_nodup
  have hlen : c.support.tail.length = c.length := by
    have := c.length_support
    simp [List.length_tail, this]
  have hsub : c.support.tail.toFinset ⊆ {x ∈ (univ : Finset V) | 2 ≤ G.degree x} := by
    intro x hx
    simp only [List.mem_toFinset] at hx
    have : x ∈ c.support := List.mem_of_mem_tail hx
    simp [two_le_degree_of_mem_support hc this]
  calc c.length = c.support.tail.toFinset.card := by
        rw [List.toFinset_card_of_nodup hnodup, hlen]
    _ ≤ _ := Finset.card_le_card hsub

/-- A graph with at most three vertices of degree at least two is a triangular forest.
This is the practical criterion used to certify concrete examples. -/
theorem isTriangularForest_of_card_two_le_degree_le_three
    (h : #{x ∈ (univ : Finset V) | 2 ≤ G.degree x} ≤ 3) : IsTriangularForest G := by
  intro v c hc
  exact le_antisymm (le_trans (length_le_card_two_le_degree_of_isCycle hc) h) hc.three_le_length

end Degrees

end TriangularForest