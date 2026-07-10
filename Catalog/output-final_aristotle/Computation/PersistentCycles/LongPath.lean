/-
# The deterministic backbone: long paths forced by minimum degree

The persistence theorem for cycles in `G_p` ultimately rests on a *deterministic*
fact: a graph in which every vertex has large degree must contain a long path
(and, with more work, a long cycle).  This file proves the long-path half — the
Erdős–Gallai / Dirac degree bound — from scratch, via the maximal-path argument.

## Main results

* `PersistentCycles.exists_long_path` — if every vertex of a finite simple graph
  has degree at least `k`, then the graph contains a path of length at least `k`.
* `PersistentCycles.exists_long_path_of_minDegree` — the same phrased with the
  minimum degree: there is a path of length at least `G.minDegree`.

The proof: take a path `p` of maximal length (it exists by finiteness).  Every
neighbour of an endpoint `v` must already lie on `p` — otherwise we could append
the edge and get a strictly longer path.  Since the endpoint has at least `k`
neighbours, all distinct and lying among the `p.length + 1` vertices of `p` but
different from `v`, the path has at least `k + 1` vertices, i.e. length `≥ k`.
-/
import Mathlib

open scoped BigOperators
open SimpleGraph

namespace PersistentCycles

variable {V : Type*} [Fintype V] [DecidableEq V]

/-
**Long path from large minimum degree (Erdős–Gallai / Dirac backbone).**
If every vertex of a finite simple graph has degree at least `k`, then the graph
contains a path of length at least `k`.
-/
theorem exists_long_path (G : SimpleGraph V) [DecidableRel G.Adj] [Nonempty V]
    {k : ℕ} (hk : ∀ v, k ≤ G.degree v) :
    ∃ (u v : V) (p : G.Walk u v), p.IsPath ∧ k ≤ p.length := by
  by_contra h_contra;
  obtain ⟨u, v, p, hp, hmax⟩ : ∃ u v : V, ∃ p : G.Walk u v, p.IsPath ∧ ∀ u' v' : V, ∀ p' : G.Walk u' v', p'.IsPath → p'.length ≤ p.length := by
    have h_max_path : ∃ p ∈ {l : ℕ | ∃ u v : V, ∃ p : G.Walk u v, p.IsPath ∧ p.length = l}, ∀ l ∈ {l : ℕ | ∃ u v : V, ∃ p : G.Walk u v, p.IsPath ∧ p.length = l}, p ≥ l := by
      apply_rules [ Set.exists_max_image ];
      · refine' Set.finite_iff_bddAbove.mpr ⟨ Fintype.card V, fun l hl => _ ⟩;
        obtain ⟨ u, v, p, hp, rfl ⟩ := hl;
        have := hp.support_nodup;
        have := List.toFinset_card_of_nodup this;
        exact le_trans ( by simp +decide [ SimpleGraph.Walk.length_support ] ) ( this ▸ Finset.card_le_univ _ );
      · exact ⟨ _, ⟨ Classical.arbitrary V, Classical.arbitrary V, SimpleGraph.Walk.nil, SimpleGraph.Walk.IsPath.nil, rfl ⟩ ⟩;
    obtain ⟨ p, ⟨ u, v, p, hp, rfl ⟩, hp' ⟩ := h_max_path; exact ⟨ u, v, p, hp, fun u' v' p' hp'' => hp' _ ⟨ u', v', p', hp'', rfl ⟩ ⟩ ;
  -- Since $p$ is a maximal path, for any vertex $w$ adjacent to $v$, $w$ must be in the support of $p$.
  have h_adj_support : ∀ w : V, G.Adj v w → w ∈ p.support := by
    intro w hw; specialize hmax u w ( p.append ( SimpleGraph.Walk.cons hw SimpleGraph.Walk.nil ) ) ; simp_all +decide [ SimpleGraph.Walk.isPath_def ] ;
    simp_all +decide [ SimpleGraph.Walk.support_append ];
    grind;
  -- Since $p$ is a maximal path, the set of vertices adjacent to $v$ is a subset of the support of $p$.
  have h_adj_subset_support : G.neighborFinset v ⊆ p.support.toFinset.erase v := by
    intro w hw; aesop;
  have := Finset.card_mono h_adj_subset_support; simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ] ;
  exact absurd ( hk v ) ( by rw [ List.toFinset_card_of_nodup hp.support_nodup ] at this; have := h_contra u v p hp; have := p.length_support; omega )

/-
The minimum-degree form: a finite simple graph contains a path of length at
least its minimum degree.
-/
theorem exists_long_path_of_minDegree (G : SimpleGraph V) [DecidableRel G.Adj]
    [Nonempty V] :
    ∃ (u v : V) (p : G.Walk u v), p.IsPath ∧ G.minDegree ≤ p.length := by
  exact exists_long_path G fun v => G.minDegree_le_degree v

end PersistentCycles