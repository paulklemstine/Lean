import Logic.TriangularForest.SharpBound

/-!
# The class of triangular forests as a graph class

Lee, Liu and Tsai study edge-decomposition into `k` members of a graph class `F` which is closed
under topological minors and 1-sums, has decidable membership, contains a triangle, and is not
the class of all graphs.  Triangular forests are the smallest interesting such class.  This file
verifies the elementary side of those requirements for triangular forests and records the local
structure they force:

* `TriangularForest.instDecidableIsCycle`, `TriangularForest.instDecidableIsTriangularForest` —
  membership in the class is decidable for finite graphs (cycles are bounded in length by the
  number of vertices, so a finite search suffices);
* `TriangularForest.triangle_isTriangularForest` — the class contains a triangle;
* `TriangularForest.not_isTriangularForest_completeGraph_four` — `K₄` is not a triangular forest,
  so the class is not the class of all graphs;
* `IsTriangularForest.mono` (in `Defs`) — closure under subgraphs;
* `TriangularForest.no_four_cycle` — triangular forests are `C₄`-free, and hence
  `TriangularForest.neighborhood_matching`: the neighbourhood of any vertex induces a matching,
  so every edge lies in at most one triangle;
* `TriangularForest.triangle_tight` — the sparsity bound `2e ≤ 3(n-1)` is attained (by a
  triangle), so it cannot be improved.
-/

namespace TriangularForest

open SimpleGraph Finset

variable {V : Type*} {G : SimpleGraph V}

section Decidability

/-- Being a cycle is a decidable property of a closed walk. -/
instance instDecidableIsCycle [DecidableEq V] {v : V} (c : G.Walk v v) : Decidable c.IsCycle :=
  decidable_of_iff (c.edges.Nodup ∧ ¬ c.Nil ∧ c.support.tail.Nodup) (by
    rw [Walk.isCycle_def, Walk.isTrail_def]
    simp [Walk.nil_iff_eq_nil])

/-- Cycles are shorter than `|V| + 1`, so being a triangular forest is a finite search. -/
theorem isTriangularForest_iff_forall_short [Fintype V] [DecidableEq V] [DecidableRel G.Adj] :
    IsTriangularForest G ↔
      ∀ v : V, ∀ c ∈ G.finsetWalkLengthLT (Fintype.card V + 1) v v, c.IsCycle → c.length = 3 := by
  constructor
  · intro h v c _ hc
    exact h c hc
  · intro h v c hc
    refine h v c ?_ hc
    rw [SimpleGraph.mem_finsetWalkLengthLT_iff]
    have h1 := length_le_card_two_le_degree_of_isCycle hc
    have h2 : #{x ∈ (univ : Finset V) | 2 ≤ G.degree x} ≤ Fintype.card V :=
      le_trans (Finset.card_filter_le _ _) (le_of_eq (Finset.card_univ))
    omega

/-- **Membership in the class of triangular forests is decidable.** -/
instance instDecidableIsTriangularForest [Fintype V] [DecidableEq V] [DecidableRel G.Adj] :
    Decidable (IsTriangularForest G) :=
  decidable_of_iff _ isTriangularForest_iff_forall_short.symm

end Decidability

section Examples

/-- The class of triangular forests contains a triangle. -/
theorem triangle_isTriangularForest : IsTriangularForest (⊤ : SimpleGraph (Fin 3)) :=
  isTriangularForest_of_card_two_le_degree_le_three (by decide)

/-- `K₄` is not a triangular forest: its four vertices carry a 4-cycle.  Hence the class of
triangular forests is a proper subclass of all graphs. -/
theorem not_isTriangularForest_completeGraph_four :
    ¬ IsTriangularForest (⊤ : SimpleGraph (Fin 4)) := by
  intro h
  have hc : (Walk.cons (by decide : (⊤ : SimpleGraph (Fin 4)).Adj 0 1)
      (Walk.cons (by decide : (⊤ : SimpleGraph (Fin 4)).Adj 1 2)
      (Walk.cons (by decide : (⊤ : SimpleGraph (Fin 4)).Adj 2 3)
      (Walk.cons (by decide : (⊤ : SimpleGraph (Fin 4)).Adj 3 0) Walk.nil)))).IsCycle := by
    decide
  have := h _ hc
  simp at this

/-- The sparsity bound `2e ≤ 3(n-1)` is attained by a triangle, so it is sharp. -/
theorem triangle_tight :
    2 * #(⊤ : SimpleGraph (Fin 3)).edgeFinset = 3 * (Fintype.card (Fin 3) - 1) := by
  rw [SimpleGraph.card_edgeFinset_top_eq_card_choose_two]
  simp

end Examples

section LocalStructure

/-- **Triangular forests are `C₄`-free.**  There is no closed walk `a → b → c → d → a` on four
distinct vertices. -/
theorem no_four_cycle (hG : IsTriangularForest G) {a b c d : V} (hab : G.Adj a b)
    (hbc : G.Adj b c) (hcd : G.Adj c d) (hda : G.Adj d a) (hac : a ≠ c) (hbd : b ≠ d) : False := by
  have hcyc : (Walk.cons hab (Walk.cons hbc (Walk.cons hcd (Walk.cons hda Walk.nil)))).IsCycle := by
    rw [Walk.cons_isCycle_iff]
    refine ⟨?_, ?_⟩
    · simp [Walk.isPath_def, hbc.ne, hbd, hab.ne', hcd.ne, hac.symm, hda.ne]
    · simp [hab.ne, hbd, hda.ne', hac]
  have := hG _ hcyc
  simp only [Walk.length_cons, Walk.length_nil] at this
  omega

/-- **Neighbourhoods induce matchings.**  In a triangular forest a vertex `u` cannot be adjacent
to two distinct neighbours `w`, `x` of a common neighbour `v`; equivalently every edge lies in at
most one triangle. -/
theorem neighborhood_matching (hG : IsTriangularForest G) {v u w x : V} (hvu : G.Adj v u)
    (hvw : G.Adj v w) (hvx : G.Adj v x) (huw : G.Adj u w) (hux : G.Adj u x) : w = x := by
  by_contra hne
  exact no_four_cycle hG hvw huw.symm hux hvx.symm hvu.ne hne

/-- Two distinct triangles cannot share an edge. -/
theorem triangle_edge_unique (hG : IsTriangularForest G) {u v w x : V} (huv : G.Adj u v)
    (huw : G.Adj u w) (hvw : G.Adj v w) (hux : G.Adj u x) (hvx : G.Adj v x) : w = x :=
  neighborhood_matching hG huv huw hux hvw hvx

end LocalStructure

end TriangularForest