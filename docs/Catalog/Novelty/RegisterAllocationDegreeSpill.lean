/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Degree-based spilling is not optimal, even for chordal interference graphs

The exact positive theorem for SSA register allocation is that chordal interference graphs
are perfect, so the register requirement is the clique number, not in general `Δ + 1`.
This file isolates a complementary obstruction to a commonly used heuristic: deleting a
maximum-degree vertex need not be the best one-vertex spill.

The counterexample is itself chordal.  It is the disjoint union of a triangle on vertices
`0,1,2` and a four-leaf star with centre `3`.  The centre has the unique maximum degree four,
but spilling it leaves the uncolourable triangle.  Spilling vertex `0`, whose degree is only
two, leaves an edge and a star, and two registers suffice.

Unlike a bare numerical check, the main result below packages separately proved structural,
degree, positive-colouring, and impossibility lemmas.
-/

open Finset SimpleGraph

namespace DegreeSpillCounterexample

/-- The eight-vertex chordal counterexample: `K₃ ⊔ K₁,₄`. -/
def spillGraph : SimpleGraph (Fin 8) where
  Adj i j :=
    (i.val < 3 ∧ j.val < 3 ∧ i ≠ j) ∨
    (i.val = 3 ∧ 4 ≤ j.val) ∨
    (j.val = 3 ∧ 4 ≤ i.val)
  symm := by
    intro i j h
    rcases h with h | h | h
    · exact Or.inl ⟨h.2.1, h.1, h.2.2.symm⟩
    · exact Or.inr (Or.inr h)
    · exact Or.inr (Or.inl h)
  loopless := ⟨by
    intro i h
    rcases h with h | h | h
    · exact h.2.2 rfl
    · omega
    · omega⟩

instance : DecidableRel spillGraph.Adj := by
  intro i j
  unfold spillGraph
  infer_instance

/-- Colourability after vertices in `spilled` have been removed.  Colours assigned to removed
vertices are ignored. -/
def ColorableExcept (G : SimpleGraph (Fin 8)) (spilled : Finset (Fin 8)) (k : ℕ) : Prop :=
  ∃ c : Fin 8 → Fin k, ∀ u v, u ∉ spilled → v ∉ spilled → G.Adj u v → c u ≠ c v

/-- Earlier neighbours for the natural elimination order on `Fin 8`. -/
def earlierNeighbours (G : SimpleGraph (Fin 8)) [DecidableRel G.Adj] (v : Fin 8) :
    Finset (Fin 8) := univ.filter (fun w => w < v ∧ G.Adj v w)

/-- The concrete form of a perfect elimination ordering used here. -/
def HasPerfectEliminationOrder (G : SimpleGraph (Fin 8)) [DecidableRel G.Adj] : Prop :=
  ∀ v, G.IsClique (earlierNeighbours G v : Set (Fin 8))

@[simp] theorem spillGraph_adj (i j : Fin 8) :
    spillGraph.Adj i j ↔
      (i.val < 3 ∧ j.val < 3 ∧ i ≠ j) ∨
      (i.val = 3 ∧ 4 ≤ j.val) ∨
      (j.val = 3 ∧ 4 ≤ i.val) := Iff.rfl

/-- The natural vertex order is a perfect elimination order.  Thus the example lies in the
chordal/SSA graph class, rather than exploiting an induced long cycle. -/
theorem spillGraph_hasPEO : HasPerfectEliminationOrder spillGraph := by
  intro v x hx y hy hxy
  simp [earlierNeighbours] at hx hy
  rcases hx.2 with hxadj | hxadj | hxadj
  · rcases hy.2 with hyadj | hyadj | hyadj
    · exact Or.inl ⟨hxadj.2.1, hyadj.2.1, hxy⟩
    · omega
    · omega
  · omega
  · rcases hy.2 with hyadj | hyadj | hyadj
    · omega
    · omega
    · exact (hxy (Fin.ext (by omega))).elim

/-- The star centre has degree four. -/
theorem degree_center : spillGraph.degree (3 : Fin 8) = 4 := by
  decide

/-- The useful triangle vertex has degree two. -/
theorem degree_triangle_vertex : spillGraph.degree (0 : Fin 8) = 2 := by
  decide

/-- Four is the maximum degree of the graph. -/
theorem maxDegree_eq_four : spillGraph.maxDegree = 4 := by
  decide

/-- Consequently the star centre is a maximum-degree spill candidate. -/
theorem center_has_maximum_degree :
    spillGraph.degree (3 : Fin 8) = spillGraph.maxDegree := by
  rw [degree_center, maxDegree_eq_four]

/-- After spilling the lower-degree triangle vertex `0`, two registers suffice. -/
theorem two_colorable_after_spilling_triangle_vertex :
    ColorableExcept spillGraph {(0 : Fin 8)} 2 := by
  let c : Fin 8 → Fin 2 := fun v =>
    if v = 2 ∨ 4 ≤ v.val then 1 else 0
  refine ⟨c, ?_⟩
  intro u v hu hv huv
  fin_cases u <;> fin_cases v <;> simp_all [spillGraph, c]

/-- After spilling the maximum-degree centre, the triangle remains and cannot be coloured
with two registers. -/
theorem not_two_colorable_after_spilling_center :
    ¬ ColorableExcept spillGraph {(3 : Fin 8)} 2 := by
  rintro ⟨c, hc⟩
  have h01 : c 0 ≠ c 1 := hc 0 1 (by decide) (by decide) (by simp [spillGraph])
  have h02 : c 0 ≠ c 2 := hc 0 2 (by decide) (by decide) (by simp [spillGraph])
  have h12 : c 1 ≠ c 2 := hc 1 2 (by decide) (by decide) (by simp [spillGraph])
  have hb0 := (c 0).isLt
  have hb1 := (c 1).isLt
  have hb2 := (c 2).isLt
  apply h12
  exact Fin.ext (by omega)

/-- **Failure of degree-based spilling on a chordal graph.**  There is a perfect-elimination
(therefore chordal) interference graph in which a maximum-degree vertex is a strictly worse
one-vertex spill choice than a vertex of smaller degree: deleting the former does not permit
two-register allocation, while deleting the latter does. -/
theorem maximum_degree_spilling_is_not_optimal :
    HasPerfectEliminationOrder spillGraph ∧
    spillGraph.degree (3 : Fin 8) = spillGraph.maxDegree ∧
    spillGraph.degree (0 : Fin 8) < spillGraph.degree (3 : Fin 8) ∧
    ¬ ColorableExcept spillGraph {(3 : Fin 8)} 2 ∧
    ColorableExcept spillGraph {(0 : Fin 8)} 2 := by
  refine ⟨spillGraph_hasPEO, center_has_maximum_degree, ?_,
    not_two_colorable_after_spilling_center,
    two_colorable_after_spilling_triangle_vertex⟩
  rw [degree_triangle_vertex, degree_center]
  omega

/-- The same example also directly refutes the proposed exact formula
`χ = max (Δ + 1) ω`: the graph is three-colourable although the proposed right side is five.
Here colourability is stated at the finite `Colorable` level to avoid any issue about infinite
cardinal coercions. -/
theorem colorable_three_but_not_formula_bound :
    spillGraph.Colorable 3 ∧ spillGraph.maxDegree + 1 = 5 := by
  constructor
  · let c : Fin 8 → Fin 3 := fun v =>
      if h : v.val < 3 then ⟨v.val, h⟩
      else if v = 3 then 0 else 1
    refine ⟨c, ?_⟩
    intro u v huv
    fin_cases u <;> fin_cases v <;> simp_all [spillGraph, c]
  · rw [maxDegree_eq_four]

end DegreeSpillCounterexample