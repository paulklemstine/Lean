/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# A Moore-type lower bound for the diameter of a bounded degree graph

One of the applications of covering radius estimates for the Laplacian lattice
of a graph is a lower bound for the diameter of graphs arising from certain
dynamical systems.  This file proves the elementary, purely combinatorial
counterpart of such statements: a *ball growth* (Moore) bound.

If every vertex of a connected graph has degree at most `k`, then the ball of
radius `r` around any vertex contains at most `(k + 1) ^ r` vertices.
Consequently a connected graph on `n` vertices with maximum degree `k` has
diameter at least `log_{k+1} n`; in particular graphs of bounded degree cannot
have small diameter.

## Main results

* `BrillNoetherDiameter.card_ball_le_pow` — `|B(v, r)| ≤ (k + 1) ^ r`.
* `BrillNoetherDiameter.card_le_pow_diam` — `n ≤ (k + 1) ^ diam G`.
* `BrillNoetherDiameter.log_card_le_diam` — `log_{k+1} n ≤ diam G`.
-/

open Finset

namespace BrillNoetherDiameter

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The ball of radius `r` around a vertex `v`. -/
noncomputable def ball (v : V) (r : ℕ) : Finset V :=
  Finset.univ.filter (fun u => G.dist v u ≤ r)

omit [DecidableEq V] [DecidableRel G.Adj] in
theorem mem_ball {v u : V} {r : ℕ} : u ∈ ball G v r ↔ G.dist v u ≤ r := by simp [ball]

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Every vertex at positive distance from `v` has a neighbour strictly closer to `v`. -/
theorem exists_adj_dist_lt {v u : V} (h : G.dist v u ≠ 0) :
    ∃ w, G.Adj w u ∧ G.dist v w < G.dist v u := by
  rw [SimpleGraph.dist_comm] at h
  obtain ⟨p, hp⟩ := SimpleGraph.exists_walk_of_dist_ne_zero h
  cases p with
  | nil => simp at h
  | @cons _ w _ hadj q =>
      refine ⟨w, hadj.symm, ?_⟩
      have h1 : G.dist w v ≤ q.length := SimpleGraph.dist_le q
      simp only [SimpleGraph.Walk.length_cons] at hp
      have e1 : G.dist v w = G.dist w v := SimpleGraph.dist_comm
      have e2 : G.dist v u = G.dist u v := SimpleGraph.dist_comm
      omega

/-- The ball of radius `r + 1` is contained in the ball of radius `r` together with
the neighbourhoods of its points. -/
theorem ball_succ_subset (v : V) (r : ℕ) :
    ball G v (r + 1) ⊆ ball G v r ∪ (ball G v r).biUnion (fun w => G.neighborFinset w) := by
  intro u hu
  rw [mem_ball] at hu
  by_cases h : G.dist v u ≤ r
  · exact Finset.mem_union_left _ (by rwa [mem_ball])
  · have hne : G.dist v u ≠ 0 := by omega
    obtain ⟨w, hadj, hlt⟩ := exists_adj_dist_lt G hne
    refine Finset.mem_union_right _ (Finset.mem_biUnion.mpr ⟨w, ?_, ?_⟩)
    · rw [mem_ball]; omega
    · simpa [SimpleGraph.mem_neighborFinset] using hadj

/-- **Ball growth (Moore) bound.**  In a connected graph of maximum degree at most
`k`, a ball of radius `r` contains at most `(k + 1) ^ r` vertices. -/
theorem card_ball_le_pow (hG : G.Connected) (k : ℕ) (hk : ∀ w, G.degree w ≤ k) (v : V) (r : ℕ) :
    (ball G v r).card ≤ (k + 1) ^ r := by
  induction r with
  | zero =>
      have hb : ball G v 0 = {v} := by
        ext u
        simp only [mem_ball, Finset.mem_singleton, Nat.le_zero]
        constructor
        · intro h
          rcases (SimpleGraph.dist_eq_zero_iff_eq_or_not_reachable).mp h with h1 | h2
          · exact h1.symm
          · exact absurd (hG.preconnected v u) h2
        · rintro rfl; exact SimpleGraph.dist_self
      rw [hb]; simp
  | succ n ih =>
      have h1 := Finset.card_le_card (ball_succ_subset G v n)
      have h2 : (ball G v n ∪ (ball G v n).biUnion (fun w => G.neighborFinset w)).card
          ≤ (ball G v n).card + ((ball G v n).biUnion (fun w => G.neighborFinset w)).card :=
        Finset.card_union_le _ _
      have h3 : ((ball G v n).biUnion (fun w => G.neighborFinset w)).card
          ≤ ∑ w ∈ ball G v n, (G.neighborFinset w).card := Finset.card_biUnion_le
      have h4 : ∑ w ∈ ball G v n, (G.neighborFinset w).card ≤ ∑ w ∈ ball G v n, k :=
        Finset.sum_le_sum fun w _ => by
          simpa [SimpleGraph.card_neighborFinset_eq_degree] using hk w
      have h5 : ∑ w ∈ ball G v n, k = (ball G v n).card * k := by
        simp [Finset.sum_const, mul_comm]
      calc (ball G v (n + 1)).card ≤ (ball G v n).card + (ball G v n).card * k := by omega
        _ ≤ (k + 1) ^ n + (k + 1) ^ n * k :=
            Nat.add_le_add ih (Nat.mul_le_mul_right k ih)
        _ = (k + 1) ^ (n + 1) := by ring

/-- **A connected graph of maximum degree `k` has at most `(k + 1) ^ diam` vertices.** -/
theorem card_le_pow_diam [Nonempty V] (hG : G.Connected) (k : ℕ) (hk : ∀ w, G.degree w ≤ k) :
    Fintype.card V ≤ (k + 1) ^ G.diam := by
  obtain ⟨v⟩ := ‹Nonempty V›
  have hediam : G.ediam ≠ ⊤ := (SimpleGraph.connected_iff_ediam_ne_top).mp hG
  have hsub : (Finset.univ : Finset V) ⊆ ball G v G.diam := by
    intro u _
    rw [mem_ball]
    exact SimpleGraph.dist_le_diam hediam
  calc Fintype.card V = (Finset.univ : Finset V).card := (Finset.card_univ).symm
    _ ≤ (ball G v G.diam).card := Finset.card_le_card hsub
    _ ≤ (k + 1) ^ G.diam := card_ball_le_pow G hG k hk v G.diam

/-- **Logarithmic lower bound for the diameter.**  A connected graph on `n` vertices
whose degrees are bounded by `k ≥ 1` has diameter at least `log_{k+1} n`. -/
theorem log_card_le_diam [Nonempty V] (hG : G.Connected) (k : ℕ) (hk1 : 1 ≤ k)
    (hk : ∀ w, G.degree w ≤ k) :
    Nat.log (k + 1) (Fintype.card V) ≤ G.diam := by
  have hb : 1 < k + 1 := by omega
  have h := card_le_pow_diam G hG k hk
  calc Nat.log (k + 1) (Fintype.card V) ≤ Nat.log (k + 1) ((k + 1) ^ G.diam) :=
        Nat.log_mono_right h
    _ = G.diam := Nat.log_pow hb _

end BrillNoetherDiameter