/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bridge: the probabilistic Caro–Wei bound ↔ a greedy (constructive) independent set

The Caro–Wei inequality
`α(G) ≥ ∑_v 1 / (deg v + 1)`
is the textbook example of the *probabilistic method with alterations*: order the vertices
uniformly at random and keep the vertices that precede all of their neighbours; the expected
number of kept vertices is `∑_v 1/(deg v + 1)`.

This file proves the inequality **without any probability space at all**: the whole content is a
strong induction that repeatedly deletes the closed neighbourhood of a vertex of *minimum*
degree, i.e. the greedy algorithm.  This is the constructive shadow of the expectation argument,
in the exact spirit of the mission ("Erdős's existence proofs are algorithms in disguise").

Main results:

* `GreedyIndependentSet.caro_wei_finset` — the induction engine, relativised to an arbitrary
  vertex subset `t`: there is an independent `s ⊆ t` with `∑_{v ∈ t} 1/(deg_t v + 1) ≤ #s`.
* `GreedyIndependentSet.caro_wei` — `∑_v 1/(deg v + 1) ≤ α(G)`.
* `GreedyIndependentSet.card_div_maxDegree_succ_le_indepNum` — the Turán-type corollary
  `n / (Δ + 1) ≤ α(G)`.
* `GreedyIndependentSet.turan_bound_of_cliqueFree` — Turán's theorem
  `#edges ≤ (1 - 1/r) n² / 2` for `K_{r+1}`-free graphs, on an *arbitrary* finite vertex type
  and with **no divisibility hypothesis**, obtained by applying Caro–Wei to the complement and
  Sedrakyan's (Cauchy–Schwarz) inequality.

## Catalog connections
* `Bridges/TuranExplicitCount.lean` : the explicit Turán graph attains this bound.
* `Bridges/ErdosProbabilisticRamsey.lean`, `Bridges/LovaszLocalLemmaFinite.lean` : the other
  members of the probabilistic-method trio.
-/
import Mathlib

open Finset SimpleGraph

namespace GreedyIndependentSet

variable {V : Type*} [DecidableEq V] [Fintype V] (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The degree of `v` measured inside the vertex subset `t`. -/
def degIn (t : Finset V) (v : V) : ℕ := #(t.filter fun w => G.Adj v w)

omit [DecidableEq V] [Fintype V] in
lemma degIn_mono {t t' : Finset V} (h : t' ⊆ t) (v : V) : degIn G t' v ≤ degIn G t v :=
  card_le_card (filter_subset_filter _ h)

omit [DecidableEq V] in
lemma degIn_univ (v : V) : degIn G univ v = G.degree v := by
  rw [degIn, ← card_neighborFinset_eq_degree, neighborFinset_eq_filter]

/-- The closed neighbourhood of `v` inside `t`. -/
private def closedNbhd (t : Finset V) (v : V) : Finset V := insert v (t.filter fun w => G.Adj v w)

omit [Fintype V] in
private lemma card_closedNbhd (t : Finset V) (v : V) :
    #(closedNbhd G t v) = degIn G t v + 1 := by
  rw [closedNbhd, card_insert_of_notMem, degIn]
  simp [SimpleGraph.irrefl]

omit [Fintype V] in
private lemma closedNbhd_subset {t : Finset V} {v : V} (hv : v ∈ t) :
    closedNbhd G t v ⊆ t := by
  intro u hu
  rcases mem_insert.mp hu with h | h
  · exact h ▸ hv
  · exact (mem_filter.mp h).1

omit [Fintype V] in
/-- **Caro–Wei, relative form.**  For every vertex subset `t` there is an independent set
`s ⊆ t` whose size is at least `∑_{v ∈ t} 1/(deg_t v + 1)`, where `deg_t` counts only
neighbours inside `t`.  The proof is the greedy algorithm: repeatedly pick a vertex of minimum
relative degree and delete its closed neighbourhood. -/
theorem caro_wei_finset (t : Finset V) :
    ∃ s ⊆ t, G.IsIndepSet (s : Set V) ∧
      ∑ v ∈ t, (1 : ℝ) / (degIn G t v + 1) ≤ #s := by
  induction t using Finset.strongInduction with
  | _ t ih =>
    rcases t.eq_empty_or_nonempty with rfl | hne
    · exact ⟨∅, by simp, by simp [SimpleGraph.IsIndepSet], by simp⟩
    obtain ⟨v, hv, hmin⟩ := t.exists_min_image (degIn G t) hne
    set B := closedNbhd G t v with hB
    have hBt : B ⊆ t := closedNbhd_subset G hv
    have hvB : v ∈ B := mem_insert_self _ _
    have hsub : t \ B ⊂ t := by
      refine ⟨sdiff_subset, fun hcon => ?_⟩
      have := hcon hv
      simp [mem_sdiff, hvB] at this
    obtain ⟨s', hs't', hind', hsum'⟩ := ih (t \ B) hsub
    have hvs' : v ∉ s' := fun h => by
      have := hs't' h
      rw [mem_sdiff] at this
      exact this.2 hvB
    refine ⟨insert v s', ?_, ?_, ?_⟩
    · intro u hu
      rcases mem_insert.mp hu with rfl | h
      · exact hv
      · exact (mem_sdiff.mp (hs't' h)).1
    · -- independence
      have key : ∀ u ∈ s', u ≠ v ∧ ¬ G.Adj v u := by
        intro u hu
        have hu' := hs't' hu
        rw [mem_sdiff] at hu'
        refine ⟨fun h => hu'.2 (h ▸ hvB), fun hadj => hu'.2 ?_⟩
        exact mem_insert_of_mem (mem_filter.mpr ⟨hu'.1, hadj⟩)
      have hsymm : Symmetric (fun v w : V => ¬ G.Adj v w) := fun a b hab hba => hab hba.symm
      rw [SimpleGraph.isIndepSet_iff, coe_insert,
        Set.pairwise_insert_of_symmetric hsymm]
      refine ⟨hind', fun u hu _ => (key u hu).2⟩
    · -- the counting step
      have hsplit : ∑ u ∈ t \ B, (1 : ℝ) / (degIn G t u + 1)
          + ∑ u ∈ B, (1 : ℝ) / (degIn G t u + 1)
          = ∑ u ∈ t, (1 : ℝ) / (degIn G t u + 1) := sum_sdiff hBt
      have hB_le : ∑ u ∈ B, (1 : ℝ) / (degIn G t u + 1) ≤ 1 := by
        have hbound : ∀ u ∈ B, (1 : ℝ) / (degIn G t u + 1) ≤ 1 / (degIn G t v + 1) := by
          intro u hu
          have hut : u ∈ t := hBt hu
          have := hmin u hut
          apply one_div_le_one_div_of_le
          · positivity
          · exact_mod_cast Nat.add_le_add_right this 1
        calc ∑ u ∈ B, (1 : ℝ) / (degIn G t u + 1)
            ≤ ∑ _u ∈ B, (1 : ℝ) / (degIn G t v + 1) := sum_le_sum hbound
          _ = (#B : ℝ) * (1 / (degIn G t v + 1)) := by rw [sum_const, nsmul_eq_mul]
          _ = 1 := by
              rw [card_closedNbhd]
              push_cast
              field_simp
      have hrest : ∑ u ∈ t \ B, (1 : ℝ) / (degIn G t u + 1) ≤ (#s' : ℝ) := by
        refine le_trans (sum_le_sum ?_) hsum'
        intro u _
        apply one_div_le_one_div_of_le
        · positivity
        · have := degIn_mono G (sdiff_subset (s := t) (t := B)) u
          exact_mod_cast Nat.add_le_add_right this 1
      have hcard : (#(insert v s') : ℝ) = (#s' : ℝ) + 1 := by
        rw [card_insert_of_notMem hvs']
        push_cast
        ring
      rw [hcard, ← hsplit]
      linarith

/-- **Caro–Wei inequality**: the independence number of a finite graph is at least
`∑_v 1/(deg v + 1)`.  Proved constructively, by the greedy algorithm. -/
theorem caro_wei : ∑ v, (1 : ℝ) / (G.degree v + 1) ≤ G.indepNum := by
  obtain ⟨s, _, hind, hsum⟩ := caro_wei_finset G univ
  refine le_trans (le_of_eq ?_) (le_trans hsum ?_)
  · exact sum_congr rfl fun v _ => by rw [degIn_univ]
  · exact_mod_cast hind.card_le_indepNum

/-- The classical corollary of Caro–Wei: every finite graph has an independent set of size at
least `n / (Δ + 1)`. -/
theorem card_div_maxDegree_succ_le_indepNum :
    (Fintype.card V : ℝ) / (G.maxDegree + 1) ≤ G.indepNum := by
  have h1 : (Fintype.card V : ℝ) / (G.maxDegree + 1)
      = ∑ _v : V, (1 : ℝ) / (G.maxDegree + 1) := by
    rw [sum_const, Finset.card_univ, nsmul_eq_mul, mul_one_div]
  have h2 : ∑ _v : V, (1 : ℝ) / (G.maxDegree + 1) ≤ ∑ v : V, (1 : ℝ) / (G.degree v + 1) := by
    refine sum_le_sum fun v _ => ?_
    apply one_div_le_one_div_of_le
    · positivity
    · exact_mod_cast Nat.add_le_add_right (G.degree_le_maxDegree v) 1
  rw [h1]
  exact le_trans h2 (caro_wei G)

/-- **Turán's bound on the independence number**: `α(G) ≥ n²/(2m + n)`, where `m` is the number of
edges.  This is Caro–Wei combined with Sedrakyan's (Cauchy–Schwarz) inequality, i.e. the
convexity step that turns the degree sum into the average degree. -/
theorem card_sq_div_le_indepNum :
    (Fintype.card V : ℝ) ^ 2 / (2 * #G.edgeFinset + Fintype.card V) ≤ G.indepNum := by
  have hpos : ∀ v ∈ (univ : Finset V), (0 : ℝ) < (G.degree v : ℝ) + 1 := fun v _ => by positivity
  have hsum : ∑ v : V, ((G.degree v : ℝ) + 1) = 2 * #G.edgeFinset + Fintype.card V := by
    have hGsum : ∑ v : V, (G.degree v : ℝ) = 2 * #G.edgeFinset := by
      exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) G.sum_degrees_eq_twice_card_edges
    rw [sum_add_distrib, hGsum, sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
  have hcs := Finset.sq_sum_div_le_sum_sq_div (univ : Finset V) (fun _ => (1 : ℝ)) hpos
  rw [hsum] at hcs
  refine le_trans (le_of_eq ?_) (le_trans (le_trans hcs (le_of_eq ?_)) (caro_wei G))
  · simp [Finset.card_univ]
  · simp

omit [DecidableEq V] [Fintype V] [DecidableRel G.Adj] in
/-- A `K_{r+1}`-free graph has clique number at most `r`. -/
lemma cliqueNum_le_of_cliqueFree {r : ℕ} (h : G.CliqueFree (r + 1)) : G.cliqueNum ≤ r := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨s, hs⟩ := G.exists_isNClique_cliqueNum
  obtain ⟨u, hu, hcard⟩ := Finset.exists_subset_card_eq (s := s) (n := r + 1)
    (by rw [hs.card_eq]; omega)
  exact h u ⟨hs.isClique.subset hu, hcard⟩

/-- **Turán's theorem via Caro–Wei.**  A `K_{r+1}`-free graph on an arbitrary finite vertex type
has at most `(1 - 1/r)·n²/2` edges.  No divisibility hypothesis is needed: the bound comes from
applying the greedy Caro–Wei bound to the complement graph and then Sedrakyan's form of the
Cauchy–Schwarz inequality. -/
theorem turan_bound_of_cliqueFree {r : ℕ} (hr : 1 ≤ r) (h : G.CliqueFree (r + 1)) :
    (#G.edgeFinset : ℝ) ≤ (1 - 1 / r) * (Fintype.card V) ^ 2 / 2 := by
  classical
  set n : ℕ := Fintype.card V with hn
  rcases Nat.eq_zero_or_pos n with hn0 | hnpos
  · have : IsEmpty V := Fintype.card_eq_zero_iff.mp hn0
    have : G.edgeFinset = ∅ := by
      apply Finset.eq_empty_of_forall_notMem
      intro e he
      induction e with
      | _ a b => exact this.elim a
    simp [this, hn0]
  -- the complement graph
  have hdeg : ∀ v : V, ((Gᶜ.degree v : ℝ)) = (n : ℝ) - 1 - G.degree v := by
    intro v
    have hlt : G.degree v < n := G.degree_lt_card_verts v
    have hnat : Gᶜ.degree v + G.degree v + 1 = n := by
      rw [SimpleGraph.degree_compl]; omega
    have hcast := congrArg (fun m : ℕ => (m : ℝ)) hnat
    push_cast at hcast
    linarith
  have hsumdeg : ∑ v : V, ((Gᶜ.degree v : ℝ) + 1) = (n : ℝ) ^ 2 - 2 * #G.edgeFinset := by
    have hGsum : ∑ v : V, (G.degree v : ℝ) = 2 * #G.edgeFinset := by
      exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) (G.sum_degrees_eq_twice_card_edges)
    calc ∑ v : V, ((Gᶜ.degree v : ℝ) + 1)
        = ∑ v : V, ((n : ℝ) - G.degree v) := by
          refine sum_congr rfl fun v _ => by rw [hdeg v]; ring
      _ = (n : ℝ) * n - ∑ v : V, (G.degree v : ℝ) := by
          rw [sum_sub_distrib, sum_const, Finset.card_univ, ← hn, nsmul_eq_mul]
      _ = (n : ℝ) ^ 2 - 2 * #G.edgeFinset := by rw [hGsum]; ring
  have hpos : ∀ v ∈ (univ : Finset V), (0 : ℝ) < (Gᶜ.degree v : ℝ) + 1 := by
    intro v _; positivity
  have hcs : ((n : ℝ)) ^ 2 / ((n : ℝ) ^ 2 - 2 * #G.edgeFinset)
      ≤ ∑ v : V, (1 : ℝ) / ((Gᶜ.degree v : ℝ) + 1) := by
    have := Finset.sq_sum_div_le_sum_sq_div (univ : Finset V) (fun _ => (1 : ℝ)) hpos
    rw [hsumdeg] at this
    simpa [Finset.card_univ, ← hn, one_pow] using this
  have hcw : ∑ v : V, (1 : ℝ) / ((Gᶜ.degree v : ℝ) + 1) ≤ (r : ℝ) := by
    refine le_trans (caro_wei Gᶜ) ?_
    have : Gᶜ.indepNum ≤ r := by
      rw [SimpleGraph.indepNum_compl]
      exact cliqueNum_le_of_cliqueFree G h
    exact_mod_cast this
  have hSpos : (0 : ℝ) < (n : ℝ) ^ 2 - 2 * #G.edgeFinset := by
    rw [← hsumdeg]
    exact sum_pos (fun v hv => hpos v hv) (by
      simpa [Finset.univ_nonempty_iff, ← Fintype.card_pos_iff] using hnpos)
  have hrpos : (0 : ℝ) < r := by exact_mod_cast hr
  have hnpos' : (0 : ℝ) < n := by exact_mod_cast hnpos
  have key : ((n : ℝ)) ^ 2 ≤ (r : ℝ) * ((n : ℝ) ^ 2 - 2 * #G.edgeFinset) := by
    rw [div_le_iff₀ hSpos] at hcs
    nlinarith [le_trans hcs (mul_le_mul_of_nonneg_right hcw hSpos.le)]
  have hfin : 2 * (r : ℝ) * #G.edgeFinset ≤ ((r : ℝ) - 1) * (n : ℝ) ^ 2 := by nlinarith [key]
  have hrw : (1 - 1 / (r : ℝ)) * (n : ℝ) ^ 2 / 2 = ((r : ℝ) - 1) * (n : ℝ) ^ 2 / (2 * r) := by
    field_simp
  rw [hrw, le_div_iff₀ (by positivity)]
  nlinarith [hfin]

/-! ## From greedy independence to the off-diagonal Ramsey bound `R(3, k+1) > k²`

A triangle-free graph has independent neighbourhoods, so `Δ ≤ α`; combined with the greedy bound
`n ≤ α(Δ+1)` this gives `n ≤ α(α+1)`.  Contrapositively, a graph on more than `k(k+1)` vertices
contains a triangle or an independent set of size `k+1` — a verified lower bound for the
off-diagonal Ramsey number `R(3, k+1)`, obtained with no probability at all. -/

/-- Natural-number form of the greedy bound: `n ≤ α·(Δ+1)`. -/
theorem card_le_indepNum_mul_maxDegree_succ :
    Fintype.card V ≤ G.indepNum * (G.maxDegree + 1) := by
  have h := card_div_maxDegree_succ_le_indepNum G
  rw [div_le_iff₀ (by positivity)] at h
  exact_mod_cast h

omit [DecidableEq V] in
/-- In a triangle-free graph the maximum degree is at most the independence number, because the
neighbourhood of any vertex is independent. -/
theorem maxDegree_le_indepNum_of_triangleFree (h : G.CliqueFree 3) :
    G.maxDegree ≤ G.indepNum := by
  refine G.maxDegree_le_of_forall_degree_le _ fun v => ?_
  have hind : G.IsIndepSet ((G.neighborFinset v : Finset V) : Set V) := by
    rw [coe_neighborFinset]
    exact G.isIndepSet_neighborSet_of_triangleFree h v
  simpa using hind.card_le_indepNum

/-- **Triangle-free graphs have large independent sets**: `n ≤ α·(α+1)`, i.e. `α ≥ √n − 1`. -/
theorem card_le_indepNum_mul_succ_of_triangleFree (h : G.CliqueFree 3) :
    Fintype.card V ≤ G.indepNum * (G.indepNum + 1) :=
  le_trans (card_le_indepNum_mul_maxDegree_succ G)
    (Nat.mul_le_mul_left _ (Nat.add_le_add_right (maxDegree_le_indepNum_of_triangleFree G h) 1))

/-- **Off-diagonal Ramsey lower bound `R(3, k+1) > k²`.**  Every graph on more than `k(k+1)`
vertices contains a triangle or an independent set of size `k + 1`. -/
theorem exists_triangle_or_large_indepSet {k : ℕ} (hn : k * (k + 1) < Fintype.card V) :
    ¬ G.CliqueFree 3 ∨ k + 1 ≤ G.indepNum := by
  by_cases h : G.CliqueFree 3
  · refine Or.inr ?_
    by_contra hcon
    push_neg at hcon
    have hle := card_le_indepNum_mul_succ_of_triangleFree G h
    have hk : G.indepNum ≤ k := by omega
    have : G.indepNum * (G.indepNum + 1) ≤ k * (k + 1) :=
      Nat.mul_le_mul hk (Nat.add_le_add_right hk 1)
    omega
  · exact Or.inl h

/-! ## Lab notes: sharpness of the two bounds

Experimental data (all checked by `decide` below, on the four-vertex Turán graph
`turanGraph 4 2`, which is the 4-cycle):

| quantity                       | value | source                            |
|--------------------------------|-------|-----------------------------------|
| `#edges`                       | `4`   | `card_edges_turanGraph_four_two`  |
| Turán bound `(1-1/2)·4²/2`     | `4`   | `turan_bound_sharp_four_two`      |
| `maxDegree`                    | `2`   | `maxDegree_turanGraph_four_two`   |
| greedy bound `n/(Δ+1) = 4/3`   | `1.33`| `card_div_maxDegree_succ_le_indepNum` |
| true independence number       | `2`   | the two colour classes            |

So the Turán inequality proved above is *attained* (it is not merely an upper bound), while the
`n/(Δ+1)` corollary is strict here — the loss is exactly the convexity slack in
Cauchy–Schwarz. -/

/-- The `K_3`-free graph `turanGraph 4 2` (the 4-cycle) has exactly `4` edges. -/
theorem card_edges_turanGraph_four_two :
    #(SimpleGraph.turanGraph 4 2).edgeFinset = 4 := by decide

/-- `turanGraph 4 2` is triangle-free, so `turan_bound_of_cliqueFree` applies to it with `r = 2`. -/
theorem cliqueFree_turanGraph_four_two : (SimpleGraph.turanGraph 4 2).CliqueFree 3 :=
  fun s hs => by revert s hs; decide

theorem maxDegree_turanGraph_four_two : (SimpleGraph.turanGraph 4 2).maxDegree = 2 := by decide

/-- **Sharpness of the Turán bound.**  For `r = 2`, `n = 4` the inequality
`turan_bound_of_cliqueFree` is an equality, so the constant `(1 - 1/r)/2` cannot be improved. -/
theorem turan_bound_sharp_four_two :
    (#(SimpleGraph.turanGraph 4 2).edgeFinset : ℝ)
      = (1 - 1 / (2 : ℝ)) * (Fintype.card (Fin 4)) ^ 2 / 2 := by
  rw [card_edges_turanGraph_four_two]
  norm_num

end GreedyIndependentSet