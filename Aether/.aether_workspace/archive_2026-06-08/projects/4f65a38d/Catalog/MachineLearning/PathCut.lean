/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# MPS Min-Cut Principle: Path Graph Cut Combinatorics

This file establishes the combinatorial backbone of the MPS min-cut principle:
on a path graph, every nontrivial subset must cross at least one edge, and
consequently the minimum "edge bottleneck" over all bipartitions equals the
minimum single-edge weight.

## Main Results

* `MPSMinCut.cutEdges_nonempty` — Every nontrivial bipartition of a path graph
  has at least one cut edge (discrete intermediate value theorem).
* `MPSMinCut.contiguousMinWeight_le_edgeCutMinWeight` — For any nontrivial
  bipartition, the edge bottleneck is ≥ the global minimum edge weight.
* `MPSMinCut.contiguousMinWeight_le_integratedMinWeight` — The contiguous
  min-cut weight ≤ the integrated information min-weight.
* `MPSMinCut.integratedMinWeight_le_contiguousMinWeight` — The reverse inequality.
* `MPSMinCut.integratedMinWeight_eq_contiguousMinWeight` — **Main theorem**:
  the integrated min weight equals the contiguous min-cut weight.

## Proof Strategy

The key insight is that the path graph has a linear geometry: any nontrivial subset
must have a "transition point" where membership changes between adjacent vertices.
This is a discrete analogue of the intermediate value theorem. The min-cut principle
then follows because:
1. Every bipartition's cut edges include at least one edge, so its bottleneck ≥ min edge wt.
2. A prefix cut uses exactly one edge as cut edge, so its bottleneck = that edge's weight.
3. Taking the minimum over all prefix cuts achieves the minimum edge weight.
-/

import Speculative.MPSMinCut.Defs

namespace MPSMinCut

open Finset

/-! ### Discrete intermediate value theorem on path graphs

Every nontrivial subset of `Fin n` has at least one cut edge.
This is the core combinatorial fact underlying the min-cut principle.
-/

/-
**Discrete IVT for path graphs.**
Every nontrivial bipartition of `Fin n` (n ≥ 2) has at least one cut edge:
there exists an edge `e` such that exactly one of `e.val`, `e.val + 1` is in `S`.
-/
theorem cutEdges_nonempty {n : ℕ} (S : Finset (Fin n))
    (hne : S.Nonempty) (hpr : S ≠ univ) :
    (cutEdges S).Nonempty := by
  by_contra h_contra;
  -- By definition of cut edges, if there are no cut edges, then for every edge $(i, i+1)$, both $i$ and $i+1$ are either in $S$ or not in $S$.
  have h_all_same : ∀ i : Fin (n - 1), (⟨i.val, by omega⟩ ∈ S) = (⟨i.val + 1, by omega⟩ ∈ S) := by
    simp_all +decide [ Finset.ext_iff, cutEdges ];
    unfold isCutEdge at h_contra; aesop;
  -- By induction, we can show that for all $i$, $i \in S$ if and only if $0 \in S$.
  have h_induction : ∀ i : Fin n, (i ∈ S) = (⟨0, by
    exact Fin.pos i⟩ ∈ S) := by
    intro ⟨ i, hi ⟩ ; induction' i with i ih <;> simp_all +decide [ Fin.ext_iff ] ;
    exact h_all_same ⟨ i, Nat.lt_pred_iff.mpr hi ⟩ |>.symm.trans ( ih ( Nat.lt_of_succ_lt hi ) )
  generalize_proofs at *;
  grind +splitImp

/-! ### Bottleneck inequality: every cut has bottleneck ≥ min edge weight -/

/-
The contiguous min weight is a lower bound on the edge-cut min weight
for any nontrivial bipartition.
-/
theorem contiguousMinWeight_le_edgeCutMinWeight {n : ℕ}
    (w : Fin (n - 1) → ℕ) (S : Finset (Fin n))
    (hne : S.Nonempty) (hpr : S ≠ univ) :
    contiguousMinWeight w ≤ edgeCutMinWeight w S := by
  unfold contiguousMinWeight edgeCutMinWeight;
  split_ifs <;> simp_all +decide [ Finset.inf'_le ];
  · exact fun b hb => ⟨ b, le_rfl ⟩;
  · exact absurd ‹_› ( Finset.Nonempty.ne_empty ( cutEdges_nonempty S hne hpr ) )

/-! ### Prefix cut achieves the single-edge weight -/

/-
The edge-cut min weight of a prefix cut `{0,…,k-1}` for `0 < k < n`
is at most `w(k-1)`, i.e. the weight of the single crossing edge.
-/
theorem edgeCutMinWeight_prefixCut_le {n : ℕ}
    (w : Fin (n - 1) → ℕ) (k : ℕ) (hk1 : 0 < k) (hk2 : k < n) :
    edgeCutMinWeight w (prefixCut n k) ≤ w ⟨k - 1, by omega⟩ := by
  unfold edgeCutMinWeight;
  split_ifs <;> simp_all +decide [ Finset.inf'_le ];
  exact ⟨ _, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, prefixCut_cutEdge k hk1 hk2 ⟩, le_rfl ⟩

/-! ### Main min-cut principle -/

/-
**Main Theorem A**: Contiguous min-cut weight ≤ integrated information min-weight.
The minimum over all nontrivial bipartitions is at most the minimum over
contiguous (prefix) cuts.
-/
theorem contiguousMinWeight_le_integratedMinWeight {n : ℕ} (hn : 2 ≤ n)
    (w : Fin (n - 1) → ℕ) :
    contiguousMinWeight w ≤ integratedMinWeight w := by
  -- By definition of integratedMinWeight, we know that it is the infimum of edgeCutMinWeight w over all nontrivial bipartitions.
  unfold integratedMinWeight;
  split_ifs <;> simp_all +decide [ Finset.inf'_le ];
  · exact fun S hS => contiguousMinWeight_le_edgeCutMinWeight w S ( Finset.mem_filter.mp hS |>.2.1 ) ( Finset.mem_filter.mp hS |>.2.2 );
  · rename_i h;
    contrapose! h;
    refine' ⟨ { ⟨ 0, by linarith ⟩ }, _ ⟩ ; simp +decide [ nontrivialBipartitions ];
    exact ⟨ by simp +decide, by simpa [ Finset.ext_iff ] using ⟨ ⟨ 1, by linarith ⟩, by simp +decide ⟩ ⟩

/-
**Main Theorem B**: Integrated information min-weight ≤ contiguous min-cut weight.
Since prefix cuts are a special case of nontrivial bipartitions, the minimum over
all bipartitions is at most the minimum over prefix cuts.
-/
theorem integratedMinWeight_le_contiguousMinWeight {n : ℕ} (hn : 2 ≤ n)
    (w : Fin (n - 1) → ℕ) :
    integratedMinWeight w ≤ contiguousMinWeight w := by
  -- By definition of integratedMinWeight, it is the infimum of the edgeCutMinWeight over all nontrivial bipartitions.
  unfold integratedMinWeight;
  split_ifs <;> simp_all +decide [ contiguousMinWeight ];
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ nontrivialBipartitions ];
  obtain ⟨ k, hk ⟩ := Finset.exists_min_image Finset.univ ( fun x => w x ) ⟨ ⟨ 0, Nat.succ_pos _ ⟩, Finset.mem_univ _ ⟩ ; use prefixCut ( n + 2 ) ( k + 1 ) ; simp_all +decide [ IsNontrivialBipartition ] ;
  refine' ⟨ ⟨ _, _ ⟩, _ ⟩;
  · exact ⟨ ⟨ 0, by linarith ⟩, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by linarith [ Fin.is_lt k ] ⟩ ⟩;
  · simp +decide [ Finset.ext_iff, prefixCut ];
    exact ⟨ ⟨ k + 1, by linarith [ Fin.is_lt k, Nat.sub_add_cancel ( by linarith : 1 ≤ n + 1 + 1 ) ] ⟩, Nat.lt_succ_self _ ⟩;
  · intro b; exact le_trans ( edgeCutMinWeight_prefixCut_le _ _ ( Nat.succ_pos _ ) ( Nat.succ_lt_succ ( Fin.is_lt k ) ) ) ( hk _ ) ;

/-- **Main Theorem (MPS Min-Cut Principle).**
On a path graph with `n ≥ 2` vertices and edge weights `w`, the minimum edge-cut
bottleneck over all nontrivial bipartitions equals the minimum single-edge weight.

This is the combinatorial core of the MPS min-cut principle: the globally defined
"integrated information rank" — minimized over exponentially many bipartitions —
collapses to a simple minimum over the `n-1` contiguous (prefix) cuts.

In MPS language: the minimum flattening rank over all bipartitions equals the
minimum bond dimension over all internal bonds.
-/
theorem integratedMinWeight_eq_contiguousMinWeight {n : ℕ} (hn : 2 ≤ n)
    (w : Fin (n - 1) → ℕ) :
    integratedMinWeight w = contiguousMinWeight w := by
  exact le_antisymm
    (integratedMinWeight_le_contiguousMinWeight hn w)
    (contiguousMinWeight_le_integratedMinWeight hn w)

end MPSMinCut