import Mathlib
import Bridges.GraphTheory.K2UnionIndependentFree
import Combinatorics.K2UnionK1FreeInvariants

/-!
# Necessary conditions for Hamilton-connectedness

`Combinatorics.K2UnionK1FreeInvariants` introduced `IsHamiltonConnected G`: every pair of
distinct vertices is joined by a Hamiltonian path. That file proved that a
Hamilton-connected graph is connected. Here we prove the sharper local necessary
condition on degrees, which is the invariant side of the Hamilton-connectedness milestone.

* `two_le_degree_of_mem_support_of_ne`: a vertex lying strictly inside a path (i.e. in its
  support but distinct from both endpoints) has at least two neighbours, namely the
  predecessor and the successor along the path; these are distinct because the support of
  a path has no repetitions.
* `two_le_degree_of_isHamiltonConnected` and `two_le_minDegree_of_isHamiltonConnected`:
  a Hamilton-connected graph on at least three vertices has minimum degree at least `2`.
* `three_le_degree_of_isHamiltonConnected` and
  `three_le_minDegree_of_isHamiltonConnected`: on at least four vertices the minimum
  degree is in fact at least `3`, because a degree-two vertex `v` with neighbours `a`, `b`
  would force the Hamiltonian `a`-`b` path to be the three-vertex path `a, v, b`.
* `not_isHamiltonConnected_of_degree_lt_two` and
  `not_isHamiltonConnected_of_degree_lt_three`: contrapositive forms, usable obstructions;
  `cycleGraph_five_not_isHamiltonConnected` applies the second one to `C₅`.
* `isHamiltonConnected_bot_iff`: the edgeless graph is Hamilton-connected only in the
  degenerate case of at most one vertex, a consistency check on the definition.
-/

open Finset SimpleGraph K2UnionIndependentFree K2UnionK1FreeInvariants

namespace HamiltonConnectedDegree

variable {V : Type*}

/-- **Internal vertices of a path have two neighbours.** If `v` lies on the path `p` from
`x` to `y` and differs from both endpoints, then `v` has at least two distinct
neighbours. -/
theorem two_le_degree_of_mem_support_of_ne [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] {x y v : V} (p : G.Walk x y) (hp : p.IsPath) (hv : v ∈ p.support)
    (hvx : v ≠ x) (hvy : v ≠ y) : 2 ≤ G.degree v := by
  classical
  set q := p.takeUntil v hv with hq
  set r := p.dropUntil v hv with hr
  have hqnil : ¬ q.Nil := SimpleGraph.Walk.not_nil_of_ne (Ne.symm hvx)
  have hrnil : ¬ r.Nil := SimpleGraph.Walk.not_nil_of_ne hvy
  set a := q.penultimate with ha
  set b := r.snd with hb
  have hav : G.Adj v a := (SimpleGraph.Walk.adj_penultimate hqnil).symm
  have hbv : G.Adj v b := SimpleGraph.Walk.adj_snd hrnil
  -- the two neighbours are distinct because the support of a path is duplicate-free
  have hspec : q.append r = p := p.take_spec hv
  have hnodup : (q.support ++ r.support.tail).Nodup := by
    rw [← SimpleGraph.Walk.support_append, hspec]
    exact hp.support_nodup
  have hamem : a ∈ q.support :=
    List.dropLast_subset _ (SimpleGraph.Walk.penultimate_mem_dropLast_support hqnil)
  have hbmem : b ∈ r.support.tail := SimpleGraph.Walk.snd_mem_tail_support hrnil
  have hab : a ≠ b := by
    intro hEq
    exact List.disjoint_of_nodup_append hnodup hamem (hEq ▸ hbmem)
  have hcard : 1 < (G.neighborFinset v).card := by
    refine Finset.one_lt_card.mpr ⟨a, ?_, b, ?_, hab⟩
    · simpa [SimpleGraph.mem_neighborFinset] using hav
    · simpa [SimpleGraph.mem_neighborFinset] using hbv
  rwa [SimpleGraph.card_neighborFinset_eq_degree] at hcard

/-- **Hamilton-connectedness forces minimum degree two.** Every vertex of a
Hamilton-connected graph on at least three vertices has at least two neighbours. -/
theorem two_le_degree_of_isHamiltonConnected [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] (h : IsHamiltonConnected G) (hcard : 3 ≤ Fintype.card V) (v : V) :
    2 ≤ G.degree v := by
  classical
  have hcard2 : 1 < (Finset.univ.erase v).card := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ v), Finset.card_univ]
    omega
  obtain ⟨x, hx, y, hy, hxy⟩ := Finset.one_lt_card.mp hcard2
  have hvx : v ≠ x := (Finset.mem_erase.mp hx).1.symm
  have hvy : v ≠ y := (Finset.mem_erase.mp hy).1.symm
  obtain ⟨p, hp, hsupp⟩ := h x y hxy
  exact two_le_degree_of_mem_support_of_ne p hp (hsupp v) hvx hvy

/-- A Hamilton-connected graph on at least three vertices has minimum degree at least
`2`. -/
theorem two_le_minDegree_of_isHamiltonConnected [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] (h : IsHamiltonConnected G) (hcard : 3 ≤ Fintype.card V) :
    2 ≤ G.minDegree := by
  have : Nonempty V := Fintype.card_pos_iff.mp (by omega)
  obtain ⟨v, hv⟩ := G.exists_minimal_degree_vertex
  rw [hv]
  exact two_le_degree_of_isHamiltonConnected h hcard v

/-- **Hamilton-connectedness forces minimum degree three.** If `G` is Hamilton-connected
and has at least four vertices, then every vertex has at least three neighbours: a vertex
`v` of degree exactly two with neighbours `a`, `b` would force the Hamiltonian path from
`a` to `b` to be the three-vertex path `a, v, b`. -/
theorem three_le_degree_of_isHamiltonConnected [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] (h : IsHamiltonConnected G) (hcard : 4 ≤ Fintype.card V) (v : V) :
    3 ≤ G.degree v := by
  classical
  by_contra hlt
  push_neg at hlt
  have h2 := two_le_degree_of_isHamiltonConnected h (by omega) v
  have hdeg : (G.neighborFinset v).card = 2 := by
    rw [SimpleGraph.card_neighborFinset_eq_degree]
    omega
  obtain ⟨a, b, hab, hset⟩ := Finset.card_eq_two.mp hdeg
  have hva : G.Adj v a := by
    have : a ∈ G.neighborFinset v := by rw [hset]; simp
    simpa [SimpleGraph.mem_neighborFinset] using this
  have hvb : G.Adj v b := by
    have : b ∈ G.neighborFinset v := by rw [hset]; simp
    simpa [SimpleGraph.mem_neighborFinset] using this
  obtain ⟨p, hp, hsupp⟩ := h a b hab
  have hv : v ∈ p.support := hsupp v
  set q := p.takeUntil v hv with hq
  set r := p.dropUntil v hv with hr
  have hqnil : ¬ q.Nil := SimpleGraph.Walk.not_nil_of_ne hva.ne'
  have hrnil : ¬ r.Nil := SimpleGraph.Walk.not_nil_of_ne hvb.ne
  have hqp : q.IsPath := hp.takeUntil hv
  have hrp : r.IsPath := hp.dropUntil hv
  have hspec : q.append r = p := p.take_spec hv
  have hnodup : (q.support ++ r.support.tail).Nodup := by
    rw [← SimpleGraph.Walk.support_append, hspec]
    exact hp.support_nodup
  -- the predecessor of `v` along `p` is `a` and its successor is `b`
  have hpen : G.Adj v q.penultimate := (SimpleGraph.Walk.adj_penultimate hqnil).symm
  have hsnd : G.Adj v r.snd := SimpleGraph.Walk.adj_snd hrnil
  have hpenmem : q.penultimate ∈ ({a, b} : Finset V) := by
    rw [← hset]
    simpa [SimpleGraph.mem_neighborFinset] using hpen
  have hsndmem : r.snd ∈ ({a, b} : Finset V) := by
    rw [← hset]
    simpa [SimpleGraph.mem_neighborFinset] using hsnd
  have hbnot : b ∉ q.support :=
    SimpleGraph.Walk.endpoint_notMem_support_takeUntil hp hv hvb.ne'
  have hpena : q.penultimate = a := by
    have hmemq : q.penultimate ∈ q.support :=
      List.dropLast_subset _ (SimpleGraph.Walk.penultimate_mem_dropLast_support hqnil)
    rcases Finset.mem_insert.mp hpenmem with hEq | hEq
    · exact hEq
    · rw [Finset.mem_singleton] at hEq
      exact absurd (hEq ▸ hmemq) hbnot
  have hsndb : r.snd = b := by
    have hmemr : r.snd ∈ r.support.tail := SimpleGraph.Walk.snd_mem_tail_support hrnil
    rcases Finset.mem_insert.mp hsndmem with hEq | hEq
    · exact absurd (hEq ▸ hmemr)
        (fun hmem => List.disjoint_of_nodup_append hnodup (SimpleGraph.Walk.start_mem_support q)
          hmem)
    · exact Finset.mem_singleton.mp hEq
  -- hence both halves have length one
  have hqlen : q.length = 1 := by
    have h0 : q.getVert 0 = a := by simp
    have hpg : q.getVert (q.length - 1) = q.getVert 0 := by
      rw [h0]
      exact hpena
    have hq1 : 1 ≤ q.length := SimpleGraph.Walk.not_nil_iff_lt_length.mp hqnil
    have := hqp.getVert_injOn (Set.mem_setOf.mpr (by omega)) (Set.mem_setOf.mpr (by omega)) hpg
    omega
  have hrlen : r.length = 1 := by
    have hlast : r.getVert r.length = b := by simp
    have hpg : r.getVert 1 = r.getVert r.length := by
      rw [hlast]
      exact hsndb
    have hr1 : 1 ≤ r.length := SimpleGraph.Walk.not_nil_iff_lt_length.mp hrnil
    have := hrp.getVert_injOn (Set.mem_setOf.mpr (by omega)) (Set.mem_setOf.mpr (by omega)) hpg
    omega
  have hplen : p.length = 2 := by
    rw [← hspec, SimpleGraph.Walk.length_append, hqlen, hrlen]
  -- but a Hamiltonian path must visit all four vertices
  have hle : Fintype.card V ≤ p.support.length := by
    have hsub : (Finset.univ : Finset V) ⊆ p.support.toFinset := by
      intro x _
      simpa using hsupp x
    have := Finset.card_le_card hsub
    rw [Finset.card_univ] at this
    exact this.trans (List.toFinset_card_le _)
  rw [SimpleGraph.Walk.length_support, hplen] at hle
  omega

/-- A Hamilton-connected graph on at least four vertices has minimum degree at least
`3`. -/
theorem three_le_minDegree_of_isHamiltonConnected [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] (h : IsHamiltonConnected G) (hcard : 4 ≤ Fintype.card V) :
    3 ≤ G.minDegree := by
  have : Nonempty V := Fintype.card_pos_iff.mp (by omega)
  obtain ⟨v, hv⟩ := G.exists_minimal_degree_vertex
  rw [hv]
  exact three_le_degree_of_isHamiltonConnected h hcard v

/-- Contrapositive form: a graph on at least four vertices with a vertex of degree at most
two is not Hamilton-connected. -/
theorem not_isHamiltonConnected_of_degree_lt_three [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] (hcard : 4 ≤ Fintype.card V) {v : V} (hdeg : G.degree v < 3) :
    ¬ IsHamiltonConnected G := by
  intro h
  exact absurd (three_le_degree_of_isHamiltonConnected h hcard v) (not_le.mpr hdeg)

/-- Contrapositive form: a graph with a vertex of degree at most one and at least three
vertices is not Hamilton-connected. -/
theorem not_isHamiltonConnected_of_degree_lt_two [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] (hcard : 3 ≤ Fintype.card V) {v : V} (hdeg : G.degree v < 2) :
    ¬ IsHamiltonConnected G := by
  intro h
  exact absurd (two_le_degree_of_isHamiltonConnected h hcard v) (not_le.mpr hdeg)

/-- The edgeless graph is Hamilton-connected only when it has at most one vertex. -/
theorem isHamiltonConnected_bot_iff [Fintype V] :
    IsHamiltonConnected (⊥ : SimpleGraph V) ↔ Fintype.card V ≤ 1 := by
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    have hnt : Nontrivial V := Fintype.one_lt_card_iff_nontrivial.mp hc
    obtain ⟨x, y, hxy⟩ := hnt
    obtain ⟨p, -, -⟩ := h x y hxy
    have hreach : (⊥ : SimpleGraph V).Reachable x y := ⟨p⟩
    exact hxy (SimpleGraph.reachable_bot.mp hreach)
  · intro hle u v huv
    exact absurd (Fintype.card_le_one_iff.mp hle u v) huv

/-- The path graph on three vertices is not Hamilton-connected: its endpoints have degree
one. -/
theorem pathGraph_three_not_isHamiltonConnected :
    ¬ IsHamiltonConnected (pathGraph 3) := by
  classical
  refine not_isHamiltonConnected_of_degree_lt_two (v := 0) (by simp) ?_
  have hsub : (pathGraph 3).neighborFinset 0 ⊆ {1} := by
    intro y hy
    rw [SimpleGraph.mem_neighborFinset, SimpleGraph.pathGraph_adj] at hy
    fin_cases y <;> simp_all
  have hcard := Finset.card_le_card hsub
  rw [SimpleGraph.card_neighborFinset_eq_degree] at hcard
  simp only [Finset.card_singleton] at hcard
  omega

/-- The five-cycle is not Hamilton-connected: it is `2`-regular, while a
Hamilton-connected graph on five vertices needs minimum degree at least `3`. -/
theorem cycleGraph_five_not_isHamiltonConnected :
    ¬ IsHamiltonConnected (cycleGraph 5) := by
  refine not_isHamiltonConnected_of_degree_lt_three (v := 0) (by simp) ?_
  decide

end HamiltonConnectedDegree