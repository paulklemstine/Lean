/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A Turán-type lower bound on the independence number

For a finite simple graph `G` with `n` vertices and `m` edges, there is an
independent set of size at least `n² / (2m + n)`.

This is the classical **Turán / Caro–Wei** bound.  We prove the sharper
vertex-degree form (Caro–Wei): there is an independent set `S` with
`∑_{v} 1/(deg v + 1) ≤ |S|`, and then deduce the global bound by the
arithmetic–harmonic mean (Cauchy–Schwarz) inequality together with the
handshake identity `∑_v deg v = 2m`.

## A remark on the stated bound `n²/(4m)`

The research prompt proposed the bound `⌈n²/(4m)⌉`.  That bound is **false**
in general: e.g. for `n = 100`, `m = 1` it claims an independent set of size
`⌈10000/4⌉ = 2500`, which exceeds the number of vertices.  The probabilistic
deletion argument it comes from only yields `n²/(4m)` when `n ≤ 2m` (the
optimal sampling probability `p = n/(2m)` must satisfy `p ≤ 1`).  The correct,
always-valid Turán bound is `n²/(2m + n)`, which is what we prove here
(note `n²/(2m+n) ≤ n` always).  Since `n²/(2m+n) ≥ n²/(4m)` exactly when
`n ≤ 2m`, the result below is the genuinely correct strengthening.
-/
import Mathlib

open Finset

set_option maxHeartbeats 1000000

namespace Catalog.Combinatorics.ProbabilisticMethod

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- Number of neighbours of `v` lying inside the vertex subset `W`. -/
def degIn (W : Finset V) (v : V) : ℕ := (W.filter (fun u => G.Adj v u)).card

/-
Relating the within-`W` degree to the within-`W.erase v0` degree.
-/
lemma degIn_erase (W : Finset V) (v0 u : V) (hv0 : v0 ∈ W) :
    degIn G W u = degIn G (W.erase v0) u + (if G.Adj u v0 then 1 else 0) := by
  simp +decide [ degIn ];
  split_ifs <;> simp_all +decide [ Finset.filter_erase ];
  rw [ Nat.sub_add_cancel ( Finset.card_pos.mpr ⟨ v0, by aesop ⟩ ) ]

/-
The Caro–Wei bound for the subgraph induced on a vertex subset `W`:
there is an independent set `S ⊆ W` with `∑_{v ∈ W} 1/(degIn W v + 1) ≤ |S|`.
-/
lemma caro_wei_aux (W : Finset V) :
    ∃ S ⊆ W, (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ G.Adj v u) ∧
      (∑ v ∈ W, (1 : ℝ) / (degIn G W v + 1)) ≤ (S.card : ℝ) := by
  induction' W using Finset.strongInduction with W ih;
  by_cases hW : W.Nonempty;
  · obtain ⟨ v0, hv0 ⟩ := Finset.exists_max_image W ( fun v => degIn G W v ) hW;
    by_cases hd0 : degIn G W v0 = 0;
    · refine' ⟨ W, Finset.Subset.refl _, _, _ ⟩ <;> simp_all +decide [ Finset.ext_iff ];
      intro v hv u hu hne; specialize hv0; have := hv0.2 v hv; have := hv0.2 u hu; simp_all +decide [ degIn ] ;
    · obtain ⟨ S', hS'₁, hS'₂, hS'₃ ⟩ := ih ( W.erase v0 ) ( Finset.erase_ssubset hv0.1 );
      refine' ⟨ S', _, _, _ ⟩;
      · exact Finset.Subset.trans hS'₁ ( Finset.erase_subset _ _ );
      · exact hS'₂;
      · -- For each $u \in W'$, we have $\frac{1}{\deg_{W'}(u) + 1} - \frac{1}{\deg_W(u) + 1} \geq \frac{1}{d_0(d_0 + 1)}$ if $u$ is adjacent to $v_0$, and $0$ otherwise.
        have h_diff : ∀ u ∈ W.erase v0, (1 / ((degIn G (W.erase v0) u) + 1 : ℝ) - 1 / ((degIn G W u) + 1 : ℝ)) ≥ (if G.Adj u v0 then 1 / ((degIn G W v0) * ((degIn G W v0) + 1) : ℝ) else 0) := by
          intro u hu
          by_cases h_adj : G.Adj u v0;
          · have h_deg : degIn G W u = degIn G (W.erase v0) u + 1 := by
              rw [ degIn_erase ] ; aesop;
              exact hv0.1;
            simp_all +decide [ Nat.succ_div ];
            field_simp;
            nlinarith only [ show ( degIn G W v0 : ℝ ) ≥ degIn G ( W.erase v0 ) u + 1 by exact_mod_cast h_deg ▸ hv0.2 u hu.2 ];
          · simp_all +decide [ degIn_erase ];
            rw [ degIn_erase ] ; aesop;
            exact hv0.1;
        -- Summing the differences over all $u \in W'$, we get $\sum_{u \in W'} \left( \frac{1}{\deg_{W'}(u) + 1} - \frac{1}{\deg_W(u) + 1} \right) \geq \frac{d_0}{d_0(d_0 + 1)} = \frac{1}{d_0 + 1}$.
        have h_sum_diff : ∑ u ∈ W.erase v0, (1 / ((degIn G (W.erase v0) u) + 1 : ℝ) - 1 / ((degIn G W u) + 1 : ℝ)) ≥ 1 / ((degIn G W v0) + 1 : ℝ) := by
          refine' le_trans _ ( Finset.sum_le_sum h_diff );
          simp +decide [ Finset.sum_ite, Finset.filter_congr, Finset.filter_ne', Finset.filter_eq', * ];
          rw [ show ( Finset.filter ( fun x => G.Adj x v0 ) ( W.erase v0 ) ) = Finset.filter ( fun x => G.Adj v0 x ) W from ?_ ];
          · field_simp;
            exact_mod_cast le_of_eq ( by unfold degIn; simp +decide [ SimpleGraph.adj_comm ] );
          · ext; simp +decide [ SimpleGraph.adj_comm ] ; aesop;
        simp_all +decide [ Finset.sum_add_distrib ];
        linarith;
  · aesop

/-
The within-`univ` degree is the usual graph degree.
-/
lemma degIn_univ (v : V) : degIn G univ v = G.degree v := by
  exact congr_arg Finset.card ( by ext; simp +decide [ SimpleGraph.adj_comm ] )

/-
Handshake-type identity: `∑_v (deg v + 1) = 2m + n`.
-/
lemma sum_degIn_univ_add_one :
    (∑ v, ((degIn G univ v : ℝ) + 1)) = 2 * (G.edgeFinset.card : ℝ) + Fintype.card V := by
  simp [degIn] ; ring;
  convert congr_arg ( fun x : ℕ => x + Fintype.card V ) ( G.sum_degrees_eq_twice_card_edges ) using 1 ; norm_cast ; simp +decide [ add_comm, Finset.sum_add_distrib, SimpleGraph.degree, SimpleGraph.neighborFinset_def ] ; ring;

/-
Arithmetic–harmonic mean inequality (a Cauchy–Schwarz corollary):
`n² / (∑ f) ≤ ∑ 1/f` for positive `f`.
-/
lemma sq_card_div_le_sum_inv (f : V → ℝ) (hf : ∀ v, 0 < f v) :
    (Fintype.card V : ℝ) ^ 2 / (∑ v, f v) ≤ ∑ v, 1 / f v := by
  by_contra! h_contra;
  rw [ lt_div_iff₀ ( Finset.sum_pos ( fun _ _ ↦ hf _ ) <| Finset.univ_nonempty_iff.mpr ⟨ Classical.choose <| show ∃ v, True from by
                                                                                                              by_cases h : Nonempty V <;> simp_all +decide [ Fintype.card_eq_zero_iff ] ⟩ ) ] at h_contra;
  -- Applying the Cauchy-Schwarz inequality in its generalized form for sequences in Euclidean space.
  have h_cauchy_schwarz : ∀ (u v : V → ℝ), (∑ i, u i * v i) ^ 2 ≤ (∑ i, u i ^ 2) * (∑ i, v i ^ 2) :=
    fun u v => Finset.sum_mul_sq_le_sq_mul_sq univ u v
  specialize h_cauchy_schwarz ( fun v => 1 / Real.sqrt ( f v ) ) ( fun v => Real.sqrt ( f v ) ) ; simp_all +decide [ ne_of_gt, Real.sq_sqrt ( le_of_lt ( hf _ ) ) ];
  linarith

/-
`2m ≤ n(n-1)`, hence `n² ≥ 2m + n`: there are at most `C(n,2)` edges.
-/
lemma two_mul_card_edges_add_card_le :
    2 * G.edgeFinset.card + Fintype.card V ≤ (Fintype.card V) ^ 2 := by
  have h_card_edges : G.edgeFinset.card ≤ Nat.choose (Fintype.card V) 2 :=
    SimpleGraph.card_edgeFinset_le_card_choose_two
  rw [ Nat.choose_two_right ] at h_card_edges;
  cases n : Fintype.card V <;> simp_all +decide [ Nat.mul_succ, sq ] ; linarith [ Nat.div_mul_le_self ( Nat.succ ‹_› * ‹_› ) 2 ]

/-
**Turán / Caro–Wei independent set bound.**
Any finite simple graph with at least one edge has an independent set whose
size is at least `n² / (2m + n)` (natural-number division), and in particular
this set is nonempty.
-/
theorem exists_large_independent_set
    (hm : 0 < G.edgeFinset.card) :
    ∃ S : Finset V, S.Nonempty ∧
      (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ G.Adj v u) ∧
      S.card ≥ (Fintype.card V) ^ 2 / (2 * G.edgeFinset.card + Fintype.card V) := by
  obtain ⟨S, hS⟩ : ∃ S : Finset V, S ⊆ Finset.univ ∧ (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ G.Adj v u) ∧ (∑ v ∈ Finset.univ, (1 : ℝ) / (G.degree v + 1)) ≤ S.card := by
    obtain ⟨ S, hS₁, hS₂, hS₃ ⟩ := caro_wei_aux G Finset.univ;
    exact ⟨ S, hS₁, hS₂, by simpa only [ degIn_univ ] using hS₃ ⟩;
  refine' ⟨ S, Finset.nonempty_of_ne_empty _, hS.2.1, Nat.le_of_lt_succ ( Nat.div_lt_of_lt_mul _ ) ⟩;
  · rintro rfl; norm_num at *;
    exact not_le_of_gt ( Finset.sum_pos ( fun _ _ => by positivity ) ( Finset.univ_nonempty_iff.mpr ⟨ Classical.choose ( show ∃ v, G.degree v > 0 from not_forall_not.mp fun h => hm <| by ext v w; simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ] ) ⟩ ) ) hS;
  · -- By `sq_card_div_le_sum_inv`, we have `(card V : ℝ)^2 / (∑ v, (G.degree v + 1)) ≤ ∑ v, 1/(G.degree v + 1)`.
    have h_sq_card_div_le_sum_inv : ((Fintype.card V : ℝ) ^ 2) / (∑ v, (G.degree v + 1 : ℝ)) ≤ (∑ v, (1 : ℝ) / (G.degree v + 1)) := by
      convert sq_card_div_le_sum_inv _ _;
      · infer_instance;
      · exact fun v => Nat.cast_add_one_pos _;
    -- By `sum_degIn_univ_add_one`, we have `∑ v, (G.degree v + 1 : ℝ) = 2 * G.edgeFinset.card + Fintype.card V`.
    have h_sum_degIn_univ_add_one : (∑ v, (G.degree v + 1 : ℝ)) = 2 * G.edgeFinset.card + Fintype.card V := by
      simp +decide [ Finset.sum_add_distrib, SimpleGraph.sum_degrees_eq_twice_card_edges ];
      exact mod_cast G.sum_degrees_eq_twice_card_edges;
    rw [ ← @Nat.cast_lt ℝ ] ; push_cast ; rw [ div_le_iff₀ ] at h_sq_card_div_le_sum_inv <;> nlinarith [ show ( 0 : ℝ ) < #G.edgeFinset by positivity ]

end Catalog.Combinatorics.ProbabilisticMethod