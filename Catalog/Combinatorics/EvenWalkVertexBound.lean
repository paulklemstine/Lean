/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Even closed walks are short-sighted: at most `L/2` edges and `L/2 + 1` vertices

`Combinatorics.EvenClosedWalks` turns every trace moment of the symmetric Rademacher
ensemble into the number of *even* closed walks — walks that never stand still and
traverse every edge an even number of times.  This file proves the structural
constraint that makes those counts small:

* `two_mul_card_walkEdges_le`: an even closed walk of length `L` traverses at most
  `L / 2` distinct edges, because each traversed edge is used an even, hence at least
  twice, number of times;
* `card_walkVertices_le_card_walkEdges_succ`: a closed walk visits at most one more
  vertex than it has edges — the "spanning tree" inequality, proved by injecting each
  newly discovered vertex into the edge on which it was discovered;
* `two_mul_card_walkVertices_le`: consequently an even closed walk of length `L`
  visits at most `L / 2 + 1` distinct vertices.

The vertex bound is exactly the mechanism behind the `N^{k+1}` size of the `2k`-th
moment of an `N × N` Wigner matrix.
-/
import Combinatorics.EvenWalkRelabeling

open Finset RademacherWigner

namespace EvenWalks

variable {N L : ℕ}

/-- The set of edges traversed by a closed walk. -/
def walkEdges [NeZero L] (w : Fin L → Fin N) : Finset (Fin N × Fin N) :=
  Finset.image (fun t : Fin L => edgeOf (w t) (w (t + 1))) Finset.univ

/-- The set of vertices visited by a walk. -/
def walkVertices (w : Fin L → Fin N) : Finset (Fin N) :=
  Finset.image w Finset.univ

@[simp] theorem mem_walkVertices {w : Fin L → Fin N} {u : Fin N} :
    u ∈ walkVertices w ↔ ∃ t, w t = u := by
  simp [walkVertices]

/-- Every traversed edge of an even closed walk is traversed at least twice. -/
theorem two_le_edgeMult_of_mem_walkEdges [NeZero L] {w : Fin L → Fin N}
    (hw : IsEvenClosedWalk w) {p : Fin N × Fin N} (hp : p ∈ walkEdges w) :
    2 ≤ edgeMult w (fun t => w (t + 1)) p := by
  obtain ⟨t, -, ht⟩ := Finset.mem_image.1 hp
  have hne : edgeMult w (fun t => w (t + 1)) p ≠ 0 :=
    (edgeMult_ne_zero_iff w (fun t => w (t + 1)) p).2 ⟨t, ht⟩
  obtain ⟨c, hc⟩ := hw.2 p
  omega

/-- **An even closed walk of length `L` traverses at most `L / 2` distinct edges.** -/
theorem two_mul_card_walkEdges_le [NeZero L] {w : Fin L → Fin N}
    (hw : IsEvenClosedWalk w) : 2 * (walkEdges w).card ≤ L := by
  have hsum : (∑ p : Fin N × Fin N, edgeMult w (fun t => w (t + 1)) p) = L := by
    rw [← card_eq_sum_edgeMult w (fun t => w (t + 1)), Fintype.card_fin]
  calc 2 * (walkEdges w).card = ∑ _p ∈ walkEdges w, 2 := by
        rw [Finset.sum_const, smul_eq_mul, mul_comm]
    _ ≤ ∑ p ∈ walkEdges w, edgeMult w (fun t => w (t + 1)) p :=
        Finset.sum_le_sum fun p hp => two_le_edgeMult_of_mem_walkEdges hw hp
    _ ≤ ∑ p : Fin N × Fin N, edgeMult w (fun t => w (t + 1)) p :=
        Finset.sum_le_sum_of_subset (Finset.subset_univ _)
    _ = L := hsum

/-- **The spanning-tree inequality for closed walks.**  A loop-free closed walk visits
at most one more vertex than the number of distinct edges it traverses: map every
visited vertex other than `w 0` to the edge on which it is first discovered. -/
theorem card_walkVertices_le_card_walkEdges_succ [NeZero L] {w : Fin L → Fin N}
    (hw : ∀ t, w t ≠ w (t + 1)) :
    (walkVertices w).card ≤ (walkEdges w).card + 1 := by
  obtain ⟨M, rfl⟩ : ∃ M, L = M + 1 := ⟨L - 1, by have := NeZero.ne L; omega⟩
  classical
  -- the first time the walk visits a vertex
  set arrive : Fin N → Fin (M + 1) := fun u =>
    if h : (Finset.univ.filter fun t : Fin (M + 1) => w t = u).Nonempty then
      (Finset.univ.filter fun t : Fin (M + 1) => w t = u).min' h else 0 with harrive
  have harrive_spec : ∀ u ∈ walkVertices w, w (arrive u) = u := by
    intro u hu
    obtain ⟨t, ht⟩ := mem_walkVertices.1 hu
    have hne : (Finset.univ.filter fun t : Fin (M + 1) => w t = u).Nonempty :=
      ⟨t, Finset.mem_filter.2 ⟨Finset.mem_univ t, ht⟩⟩
    rw [harrive]
    simp only [dif_pos hne]
    exact (Finset.mem_filter.1 (Finset.min'_mem _ hne)).2
  have harrive_min : ∀ u ∈ walkVertices w, ∀ s : Fin (M + 1), w s = u → arrive u ≤ s := by
    intro u hu s hs
    obtain ⟨t, ht⟩ := mem_walkVertices.1 hu
    have hne : (Finset.univ.filter fun t : Fin (M + 1) => w t = u).Nonempty :=
      ⟨t, Finset.mem_filter.2 ⟨Finset.mem_univ t, ht⟩⟩
    rw [harrive]
    simp only [dif_pos hne]
    exact Finset.min'_le _ s (Finset.mem_filter.2 ⟨Finset.mem_univ s, hs⟩)
  -- the edge on which a vertex is first discovered
  set disc : Fin N → Fin N × Fin N := fun u => edgeOf (w (arrive u - 1)) (w (arrive u))
    with hdisc
  have hmaps : ∀ u ∈ (walkVertices w).erase (w 0), disc u ∈ walkEdges w := by
    intro u _
    refine Finset.mem_image.2 ⟨arrive u - 1, Finset.mem_univ _, ?_⟩
    rw [hdisc, sub_add_cancel]
  have hne_zero : ∀ u ∈ (walkVertices w).erase (w 0), arrive u ≠ 0 := by
    intro u hu h0
    have hu' := Finset.mem_of_mem_erase hu
    have : w 0 = u := by rw [← h0]; exact harrive_spec u hu'
    exact (Finset.ne_of_mem_erase hu) this.symm
  have hinj : ∀ u ∈ (walkVertices w).erase (w 0), ∀ u' ∈ (walkVertices w).erase (w 0),
      disc u = disc u' → u = u' := by
    intro u hu u' hu' heq
    have hu0 := Finset.mem_of_mem_erase hu
    have hu'0 := Finset.mem_of_mem_erase hu'
    have hwu : w (arrive u) = u := harrive_spec u hu0
    have hwu' : w (arrive u') = u' := harrive_spec u' hu'0
    have hstep : ∀ t : Fin (M + 1), w (t - 1) ≠ w t := by
      intro t ht
      exact hw (t - 1) (by rw [sub_add_cancel]; exact ht)
    rcases (edgeOf_eq_iff (hstep (arrive u)) (hstep (arrive u'))).1 heq with
      ⟨-, h2⟩ | ⟨h1, h2⟩
    · rw [← hwu, ← hwu', h2]
    · -- the two vertices would each be discovered strictly before the other
      exfalso
      have hlt1 : arrive u ≤ arrive u' - 1 := by
        refine harrive_min u hu0 _ ?_
        rw [← h2, hwu]
      have hlt2 : arrive u' ≤ arrive u - 1 := by
        refine harrive_min u' hu'0 _ ?_
        rw [h1, hwu']
      have hz : arrive u ≠ 0 := hne_zero u hu
      have hz' : arrive u' ≠ 0 := hne_zero u' hu'
      have e1 : ((arrive u - 1 : Fin (M + 1)) : ℕ) = (arrive u : ℕ) - 1 := by
        rw [Fin.coe_sub_one, if_neg hz]
      have e2 : ((arrive u' - 1 : Fin (M + 1)) : ℕ) = (arrive u' : ℕ) - 1 := by
        rw [Fin.coe_sub_one, if_neg hz']
      have p1 : (arrive u : ℕ) ≤ (arrive u' : ℕ) - 1 := by
        have := hlt1
        rw [Fin.le_def, e2] at this
        exact this
      have p2 : (arrive u' : ℕ) ≤ (arrive u : ℕ) - 1 := by
        have := hlt2
        rw [Fin.le_def, e1] at this
        exact this
      have q1 : (arrive u : ℕ) ≠ 0 := fun h => hz (Fin.ext h)
      have q2 : (arrive u' : ℕ) ≠ 0 := fun h => hz' (Fin.ext h)
      omega
  have hcard : ((walkVertices w).erase (w 0)).card ≤ (walkEdges w).card :=
    Finset.card_le_card_of_injOn disc hmaps hinj
  have hmem : w 0 ∈ walkVertices w := mem_walkVertices.2 ⟨0, rfl⟩
  have := Finset.card_erase_of_mem hmem
  have hpos : 1 ≤ (walkVertices w).card := Finset.card_pos.2 ⟨w 0, hmem⟩
  omega

/-- **An even closed walk of length `L` visits at most `L / 2 + 1` vertices.** -/
theorem two_mul_card_walkVertices_le [NeZero L] {w : Fin L → Fin N}
    (hw : IsEvenClosedWalk w) : 2 * (walkVertices w).card ≤ L + 2 := by
  have h1 := two_mul_card_walkEdges_le hw
  have h2 := card_walkVertices_le_card_walkEdges_succ hw.1
  omega

end EvenWalks