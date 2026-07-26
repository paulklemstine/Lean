/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Register allocation for SSA programs: chordal interference graphs are perfect

Register allocation assigns program variables to a fixed bank of CPU registers.  Two
variables *interfere* when they are simultaneously live; a legal assignment gives interfering
variables distinct registers, i.e. a proper colouring of the **interference graph** `G`, using
`χ(G)` colours in the optimum.

For programs in **Static Single Assignment (SSA)** form the interference graph is *chordal*:
every cycle of length `≥ 4` has a chord.  Equivalently, `G` admits a **perfect elimination
ordering (PEO)** — an enumeration `v₁, …, vₙ` of the vertices such that, for each `vᵢ`, the
neighbours of `vᵢ` occurring *earlier* in the order form a clique.  This file proves the
central structural fact behind optimal SSA register allocation:

> **Chordal graphs are perfect.**  If `G` has a perfect elimination ordering then
> `χ(G) = ω(G)`: greedy colouring along the order uses exactly `ω(G) = ` (the maximum number
> of simultaneously live variables) registers, and no colouring can do better.

We work with the concrete elimination order given by the linear order on `Fin n`, so a PEO is
the hypothesis `IsPerfectElimOrder G : ∀ v, G.IsClique (earlierNeighbours G v)`.

## Main results

* `colorable_of_earlierDegree_lt` — the **greedy colouring lemma**: if every vertex has fewer
  than `k` earlier neighbours, then `G` is `k`-colourable (no chordality needed).
* `earlier_insert_isClique`, `earlierDegree_succ_le_cliqueNum` — under a PEO each vertex with
  its earlier neighbours is a clique, so `earlierDegree v + 1 ≤ ω(G)`.
* `colorable_cliqueNum_of_peo` — a PEO graph is `ω(G)`-colourable (linear-scan optimality).
* `chromaticNumber_eq_cliqueNum_of_peo` — **perfectness of chordal graphs**: `χ(G) = ω(G)`.

## Interval graphs as a special case

Interval / linear-scan interference graphs (variables with contiguous live ranges) are a
strict subclass of chordal graphs.  We recover them:

* `interferenceGraph_isPEO` — when live ranges are sorted by start point (`Monotone lo`), the
  interval interference graph has a perfect elimination ordering;
* `interval_chromaticNumber_eq_cliqueNum` — hence `χ = ω` for interval graphs, obtained here
  purely as a corollary of the general chordal theorem.

This strictly generalises the interval-graph analysis of register allocation to the full SSA
(chordal) setting: interval ⊊ chordal, and the optimal register count is the clique number in
both.
-/

open Finset SimpleGraph

namespace ChordalRegAlloc

variable {n : ℕ}

/-- The neighbours of `v` occurring *earlier* than `v` in the elimination order on `Fin n`. -/
def earlierNeighbours (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (v : Fin n) :
    Finset (Fin n) :=
  univ.filter (fun w => w < v ∧ G.Adj v w)

@[simp] lemma mem_earlierNeighbours {G : SimpleGraph (Fin n)} [DecidableRel G.Adj]
    {v w : Fin n} : w ∈ earlierNeighbours G v ↔ w < v ∧ G.Adj v w := by
  simp [earlierNeighbours]

/-- `G` has a **perfect elimination ordering** (relative to the linear order on `Fin n`) when
the earlier neighbours of every vertex form a clique.  This is the order-theoretic
characterisation of chordality. -/
def IsPerfectElimOrder (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] : Prop :=
  ∀ v, G.IsClique (earlierNeighbours G v : Set (Fin n))

/-
**Greedy colouring lemma.**  If every vertex has strictly fewer than `k` earlier
neighbours, then `G` is `k`-colourable.  Processing vertices from largest to smallest, when a
vertex is coloured its already-coloured neighbours are exactly its earlier neighbours, of
which there are `< k`, so a free colour remains.  (No chordality is required for this bound.)
-/
theorem colorable_of_earlierDegree_lt (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (k : ℕ) (hk : ∀ v, (earlierNeighbours G v).card < k) : G.Colorable k := by
  -- Define a coloring function based on the elimination order.
  have hcolor : ∃ c : Fin n → Fin k, ∀ v : Fin n, ∀ w ∈ earlierNeighbours G v, c v ≠ c w := by
    rcases n with ( _ | n ) <;> simp_all +decide;
    -- By induction on $n$, we can color the vertices in such a way that no two adjacent vertices share the same color.
    have h_ind : ∀ (s : Finset (Fin (n + 1))), ∃ c : Fin (n + 1) → Fin k, ∀ v ∈ s, ∀ w ∈ s, w < v → G.Adj v w → ¬c v = c w := by
      intro s
      induction' s using Finset.strongInduction with s ih;
      by_cases hs : s.Nonempty;
      · obtain ⟨m, hm⟩ : ∃ m ∈ s, ∀ v ∈ s, v ≤ m := by
          exact ⟨ Finset.max' s hs, Finset.max'_mem s hs, fun v hv => Finset.le_max' s v hv ⟩;
        obtain ⟨ c, hc ⟩ := ih ( s.erase m ) ( Finset.erase_ssubset hm.1 );
        -- Let $N$ be the set of earlier neighbors of $m$.
        set N := earlierNeighbours G m;
        -- Since $N$ is a subset of $s.erase m$, we can use the induction hypothesis to color $N$.
        obtain ⟨cv, hcv⟩ : ∃ cv : Fin k, cv ∉ N.image c := by
          contrapose! hk;
          exact ⟨ m, by simpa using Finset.card_le_card ( show Finset.univ ⊆ Finset.image c N from fun x _ => hk x ) |> le_trans <| Finset.card_image_le ⟩;
        use fun v => if v = m then cv else c v;
        grind +locals;
      · exact ⟨ fun _ => ⟨ 0, by linarith [ hk 0 ] ⟩, by aesop ⟩;
    exact Exists.elim ( h_ind Finset.univ ) fun c hc => ⟨ c, fun v w hv hw => hc v ( Finset.mem_univ v ) w ( Finset.mem_univ w ) hv hw ⟩;
  obtain ⟨c, hc⟩ := hcolor
  use fun v => c v
  intro v w hvw
  by_cases hvw' : v < w;
  · exact hc _ _ ( by rw [ SimpleGraph.adj_comm ] at hvw; aesop ) |> Ne.symm;
  · exact hc v w ( by rw [ mem_earlierNeighbours ] ; exact ⟨ lt_of_le_of_ne ( le_of_not_gt hvw' ) ( by aesop ), hvw ⟩ )

/-
Under a PEO, a vertex together with its earlier neighbours forms a clique.
-/
theorem earlier_insert_isClique (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hpeo : IsPerfectElimOrder G) (v : Fin n) :
    G.IsClique (insert v (earlierNeighbours G v) : Set (Fin n)) := by
  simp_all +decide [ Set.Pairwise ];
  have := hpeo v;
  exact fun x hx₁ hx₂ y hy₁ hy₂ hxy => this ( by aesop ) ( by aesop ) hxy

/-
Under a PEO, `earlierDegree v + 1 ≤ ω(G)`: the earlier-neighbour count of every vertex is
bounded by the clique number.
-/
theorem earlierDegree_succ_le_cliqueNum (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hpeo : IsPerfectElimOrder G) (v : Fin n) :
    (earlierNeighbours G v).card + 1 ≤ G.cliqueNum := by
  obtain ⟨s, hs⟩ : ∃ s : Finset (Fin n), G.IsNClique ((earlierNeighbours G v).card + 1) s := by
    use insert v (earlierNeighbours G v);
    convert earlier_insert_isClique G hpeo v using 1;
    simp +decide [ SimpleGraph.isNClique_iff ];
  exact le_csSup ⟨ n, by rintro x ⟨ t, ht ⟩ ; exact ht.card_eq ▸ ( Finset.card_le_univ t ).trans ( by simp +decide ) ⟩ ⟨ s, hs ⟩

/-
**Linear-scan optimality for chordal graphs.**  A graph with a perfect elimination
ordering is colourable with `ω(G)` colours.
-/
theorem colorable_cliqueNum_of_peo (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hpeo : IsPerfectElimOrder G) : G.Colorable G.cliqueNum := by
  apply colorable_of_earlierDegree_lt;
  exact fun v => Nat.lt_of_succ_le ( earlierDegree_succ_le_cliqueNum G hpeo v )

/-
**Chordal graphs are perfect.**  If `G` has a perfect elimination ordering then its
chromatic number equals its clique number.  For register allocation this says: the optimal
number of registers for an SSA program equals the maximum number of simultaneously live
variables, and greedy colouring along the elimination order attains it.
-/
theorem chromaticNumber_eq_cliqueNum_of_peo (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hpeo : IsPerfectElimOrder G) :
    G.chromaticNumber = (G.cliqueNum : ℕ∞) := by
  by_cases h : G.Colorable ( G.cliqueNum );
  · exact le_antisymm ( by simpa using h.chromaticNumber_le ) ( by simpa using G.cliqueNum_le_chromaticNumber );
  · exact False.elim <| h <| colorable_cliqueNum_of_peo G hpeo

/-! ## Interval graphs as a special case of chordal graphs -/

/-- Two distinct variables *interfere* when their closed live ranges `[lo, hi]` overlap. -/
def Interfere (lo hi : Fin n → ℕ) (i j : Fin n) : Prop :=
  i ≠ j ∧ lo i ≤ hi j ∧ lo j ≤ hi i

lemma Interfere.symm {lo hi : Fin n → ℕ} {i j : Fin n} (h : Interfere lo hi i j) :
    Interfere lo hi j i := ⟨h.1.symm, h.2.2, h.2.1⟩

/-- The interval interference graph on `Fin n`. -/
def interferenceGraph (lo hi : Fin n → ℕ) : SimpleGraph (Fin n) where
  Adj i j := Interfere lo hi i j
  symm := fun _ _ h => h.symm
  loopless := ⟨fun _ h => h.1 rfl⟩

instance (lo hi : Fin n → ℕ) : DecidableRel (interferenceGraph lo hi).Adj := by
  intro i j; unfold interferenceGraph Interfere; infer_instance

@[simp] lemma interferenceGraph_adj (lo hi : Fin n → ℕ) (i j : Fin n) :
    (interferenceGraph lo hi).Adj i j ↔ Interfere lo hi i j := Iff.rfl

/-
**Interval graphs are chordal.**  When live ranges are enumerated in increasing order of
their start points (`Monotone lo`), the interval interference graph has a perfect elimination
ordering: the earlier neighbours of a variable are all live at its start point, hence pairwise
overlap.  (Well-formedness `lo ≤ hi` of the ranges is not even needed for chordality.)
-/
theorem interferenceGraph_isPEO (lo hi : Fin n → ℕ)
    (hmono : Monotone lo) : IsPerfectElimOrder (interferenceGraph lo hi) := by
  intro v w hw w' hw' hne
  simp_all +decide [ earlierNeighbours, interferenceGraph, Interfere ]
  constructor <;> linarith [ hmono hw.1.le, hmono hw'.1.le ]

/-- **Perfectness of interval interference graphs**, obtained as a corollary of the general
chordal theorem: for register allocation with sorted contiguous live ranges, `χ = ω`. -/
theorem interval_chromaticNumber_eq_cliqueNum (lo hi : Fin n → ℕ)
    (hmono : Monotone lo) :
    (interferenceGraph lo hi).chromaticNumber = ((interferenceGraph lo hi).cliqueNum : ℕ∞) :=
  chromaticNumber_eq_cliqueNum_of_peo _ (interferenceGraph_isPEO lo hi hmono)

/-- Register-allocation reading: `ω` registers suffice for a sorted-live-range program. -/
theorem interval_colorable_cliqueNum (lo hi : Fin n → ℕ)
    (hmono : Monotone lo) :
    (interferenceGraph lo hi).Colorable (interferenceGraph lo hi).cliqueNum :=
  colorable_cliqueNum_of_peo _ (interferenceGraph_isPEO lo hi hmono)

end ChordalRegAlloc