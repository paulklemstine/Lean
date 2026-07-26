/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Cycle-containing families of vectors: the general alphabet bound

## Setup

Fix an alphabet size `b` and a length `k`.  To each ordered pair of vectors
`u v : Fin k → Fin b` we associate a **bipartite graph** `pairGraph u v` on the
vertex set `Fin b ⊕ Fin b`:  the left copy and the right copy of the alphabet.
For every coordinate `i` we put an edge between `Sum.inl (u i)` (the `u`-symbol
at position `i`) and `Sum.inr (v i)` (the `v`-symbol at position `i`).  This is
exactly the bipartite graph appearing in the research conjecture: a pair of
vectors is "good" when this graph *contains a cycle*.

`ContainsCycle u v` is defined as `¬ (pairGraph u v).IsAcyclic`, i.e. the graph
genuinely contains a cycle in the sense of Mathlib's `SimpleGraph` library.

## Main results

* `pairGraph_colorable` : the graph is properly `2`-colorable (it is bipartite),
  the colour being which side of the `Sum` a vertex lives on.
* `containsCycle_k_ge_four` : **the girth obstruction.**  If the pair `(u, v)`
  yields a graph containing a cycle then `4 ≤ k`.  This is sharp: a bipartite
  graph has no cycle of length `< 4`, and a cycle of length `≥ 4` needs `≥ 4`
  distinct edges, each coming from a distinct coordinate.
* `cyclicFamily_card_le_one_of_small` : consequently, for `k ≤ 3` *every*
  cycle-containing family contains at most one vector — the extremal function is
  forced to be `1` below the threshold, for **every** alphabet size `b`.

These are the unconditional, alphabet-uniform pieces of the conjecture; the exact
extremal value `N_b(k)` for large `k` is recorded as an open problem in
`FUTURE_DIRECTIONS.md`.

-- !-- Lab Notes -- !--
Hypothesis  : A pair of vectors whose bipartite graph contains a cycle cannot be
              "too short": a cycle costs edges, and edges cost coordinates.
Experiment  : Defined `pairGraph` via `fromEdgeSet`; computed that every edge runs
              between an `inl` and an `inr` vertex, hence the graph is 2-colorable.
              Combined `two_colorable_iff_forall_loop_even` (closed walks are even)
              with `IsCycle.three_le_length` (cycles have length ≥ 3) to upgrade
              the cycle length to `≥ 4`.  The cycle's `≥ 4` distinct edges inject
              into the `k` coordinates, giving `k ≥ 4`.
Analysis    : The bound `4` is *sharp* and *alphabet-independent*: the only place
              `b` enters is the codomain of the vectors, which is irrelevant to the
              girth count.  A naive attempt using only `three_le_length` gives the
              weaker `k ≥ 3`; the bipartite parity argument is what makes it sharp.
Critique    : `ContainsCycle` is the genuine graph-theoretic predicate (negation of
              `IsAcyclic`), not a hand-rolled stand-in, so the bound is faithful.
              The small-`k` corollary is non-vacuous: cyclic families do exist for
              `k ≥ 4` (see `CycleFamilies.Binary`).
Synthesis   : `containsCycle_k_ge_four` + `cyclicFamily_card_le_one_of_small`
              pin down the extremal function completely on `k ≤ 3`.
-/
import Mathlib

open SimpleGraph Finset

namespace Catalog.Novelty.CycleFamilies

variable {b k : ℕ}

/-- The bipartite graph attached to an ordered pair of vectors `u v : Fin k → Fin b`:
vertices are two copies of the alphabet, and coordinate `i` contributes the edge
`s(inl (u i), inr (v i))`. -/
noncomputable def pairGraph (u v : Fin k → Fin b) : SimpleGraph (Fin b ⊕ Fin b) :=
  SimpleGraph.fromEdgeSet (Set.range (fun i => s(Sum.inl (u i), Sum.inr (v i))))

/-- A pair of vectors is *cycle-containing* when its bipartite graph is not acyclic. -/
def ContainsCycle (u v : Fin k → Fin b) : Prop := ¬ (pairGraph u v).IsAcyclic

/-- A family of vectors is *cyclic* when every pair of distinct members is
cycle-containing. -/
def CyclicFamily (C : Finset (Fin k → Fin b)) : Prop :=
  ∀ u ∈ C, ∀ v ∈ C, u ≠ v → ContainsCycle u v

/-- The bipartite graph of a pair is `2`-colorable: colour a vertex by which copy
of the alphabet it belongs to. -/
theorem pairGraph_colorable (u v : Fin k → Fin b) : (pairGraph u v).Colorable 2 := by
  refine ⟨⟨Sum.elim (fun _ => 0) (fun _ => 1), ?_⟩⟩
  intro x y hadj
  rw [pairGraph, SimpleGraph.fromEdgeSet_adj] at hadj
  obtain ⟨⟨i, hi⟩, hne⟩ := hadj
  rw [Sym2.eq_iff] at hi
  rcases hi with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> subst h1 <;> subst h2 <;> simp

/-- **Girth obstruction.**  If the pair `(u, v)` yields a graph containing a cycle,
then the length `k` is at least `4`.  The proof: the graph is bipartite, so any
cycle has even length `≥ 4`; its `≥ 4` distinct edges inject into the `k`
coordinates. -/
theorem containsCycle_k_ge_four (u v : Fin k → Fin b) (h : ContainsCycle u v) : 4 ≤ k := by
  rw [ContainsCycle, SimpleGraph.IsAcyclic] at h
  push_neg at h
  obtain ⟨x, c, hc⟩ := h
  have heven : Even c.length :=
    (SimpleGraph.two_colorable_iff_forall_loop_even.mp (pairGraph_colorable u v)) x c
  have h3 := hc.three_le_length
  have h4 : 4 ≤ c.length := by obtain ⟨m, hm⟩ := heven; omega
  have hsub : c.edges.toFinset ⊆
      Finset.image (fun i => s(Sum.inl (u i), Sum.inr (v i))) Finset.univ := by
    intro e he
    rw [List.mem_toFinset] at he
    have hmem : e ∈ (pairGraph u v).edgeSet := c.edges_subset_edgeSet he
    rw [pairGraph, SimpleGraph.edgeSet_fromEdgeSet] at hmem
    obtain ⟨i, hi⟩ := hmem.1
    exact Finset.mem_image.mpr ⟨i, Finset.mem_univ i, hi⟩
  have hcard : c.edges.toFinset.card = c.length := by
    rw [List.toFinset_card_of_nodup hc.edges_nodup, c.length_edges]
  calc 4 ≤ c.length := h4
    _ = c.edges.toFinset.card := hcard.symm
    _ ≤ (Finset.image (fun i => s(Sum.inl (u i), Sum.inr (v i))) Finset.univ).card :=
        Finset.card_le_card hsub
    _ ≤ Finset.univ.card := Finset.card_image_le
    _ = k := by simp

/-- **Sub-threshold collapse.**  For `k ≤ 3` no pair can be cycle-containing, so
every cyclic family has at most one element, for every alphabet size `b`. -/
theorem cyclicFamily_card_le_one_of_small (hk : k ≤ 3) (C : Finset (Fin k → Fin b))
    (h : CyclicFamily C) : C.card ≤ 1 := by
  by_contra hc
  push_neg at hc
  obtain ⟨u, hu, v, hv, huv⟩ := Finset.one_lt_card.mp hc
  have := containsCycle_k_ge_four u v (h u hu v hv huv)
  omega

end Catalog.Novelty.CycleFamilies