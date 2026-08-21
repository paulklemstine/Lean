/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bridge: the max-cut half-of-the-edges bound, as a finite count and as a terminating search

The classical probabilistic proof that every graph has a cut containing at least half of its
edges puts every vertex on one of the two sides independently: each edge is then cut with
probability `1/2`, so the expected size of the cut is `m/2` and some cut is at least that large.

As everywhere else in this thread, the probability is replaced here by a *cardinality*: the sum
of the cut sizes over **all** `2 ^ n` subsets `S ⊆ V` is computed exactly
(`sum_cut_eq_card_adjPairs_mul`), and the existence statement is then pure pigeonhole on natural
numbers.  Finally the existence is upgraded to an explicit object: `maxCut G` is the supremum of
the cut function over the (finite, decidable) powerset — a terminating exhaustive search — and it
provably meets the bound and is attained by a concrete subset.  This is the "existence proof is an
algorithm in disguise" slogan of the mission in its smallest complete instance.

## Main results

* `card_filter_mem_notMem` : exactly `2 ^ (n - 2)` of the subsets of `V` contain `u` but not `v`.
* `sum_cut_eq_card_adjPairs_mul` : `∑_{S ⊆ V} cut S = (2 · #edges) · 2 ^ (n - 2)`, an exact
  identity — the finite form of "the expected cut is `m/2`".
* `exists_cut_ge_half_edges` : some `S` satisfies `#edges ≤ 2 · cut S`.
* `maxCut_ge_half_edges` : the exhaustive search `maxCut G` already satisfies the bound, and
  `exists_cut_eq_maxCut` shows it is attained by an explicit subset.
* `exists_bool_colouring_cut` : the same statement phrased as a `2`-colouring `f : V → Bool`.
* `maxCut_triangle`, `maxCut_completeGraph_four` : the search evaluated on `K₃` and `K₄`, showing
  the bound is tight for `K₃` (`3 ≤ 2 · 2`) and strict for `K₄` (`6 ≤ 2 · 4`).

## Catalog connections
* `Bridges/ErdosProbabilisticRamsey.lean` : the counting lemma `card_filter_superset` is reused
  verbatim to count the subsets containing a given pair.
* `Bridges/PropertyBUnionBound.lean` : the same "colourings are subsets" encoding.
-/
import Mathlib
import Bridges.ErdosProbabilisticRamsey
import Bridges.TuranSharpNonDivisible

open Finset

namespace MaxCutDerandomized

open ErdosProbabilisticRamsey (card_filter_superset)

variable {V : Type*} [Fintype V] [DecidableEq V]

section Counting

/-- Exactly `2 ^ (n - 2)` subsets of `V` contain `u` but avoid `v` (for `u ≠ v`). -/
lemma card_filter_mem_notMem (u v : V) (huv : u ≠ v) :
    #((univ : Finset V).powerset.filter (fun S => u ∈ S ∧ v ∉ S)) =
      2 ^ (Fintype.card V - 2) := by
  classical
  have hbij : #((univ : Finset V).powerset.filter (fun S => u ∈ S ∧ v ∉ S)) =
      #((univ : Finset V).powerset.filter (fun S => ({u, v} : Finset V) ⊆ S)) := by
    refine Finset.card_bij' (fun S _ => insert v S) (fun T _ => T.erase v) ?_ ?_ ?_ ?_
    · intro S hS
      simp only [mem_filter, mem_powerset] at hS ⊢
      refine ⟨subset_univ _, ?_⟩
      intro x hx
      simp only [mem_insert, mem_singleton] at hx
      rcases hx with rfl | rfl
      · exact mem_insert_of_mem hS.2.1
      · exact mem_insert_self _ _
    · intro T hT
      simp only [mem_filter, mem_powerset] at hT ⊢
      refine ⟨subset_univ _, ?_, ?_⟩
      · exact mem_erase.2 ⟨huv, hT.2 (by simp)⟩
      · simp
    · intro S hS
      simp only [mem_filter, mem_powerset] at hS
      exact Finset.erase_insert hS.2.2
    · intro T hT
      simp only [mem_filter, mem_powerset] at hT
      exact Finset.insert_erase (hT.2 (by simp))
  rw [hbij, card_filter_superset _ _ (subset_univ _), card_univ,
    Finset.card_insert_of_notMem (by simp [huv]), card_singleton]

end Counting

variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The ordered pairs of adjacent vertices; there are `2 · #edges` of them. -/
def adjPairs : Finset (V × V) := univ.filter (fun p : V × V => G.Adj p.1 p.2)

/-- The ordered adjacent pairs crossing the cut `S` from inside to outside.  Each edge with
exactly one endpoint in `S` contributes exactly one such pair, so this counts the cut edges. -/
def crossPairs (S : Finset V) : Finset (V × V) :=
  (adjPairs G).filter (fun p => p.1 ∈ S ∧ p.2 ∉ S)

/-- The size of the cut determined by the side `S`. -/
def cut (S : Finset V) : ℕ := #(crossPairs G S)

omit [DecidableEq V] in
lemma card_adjPairs : #(adjPairs G) = 2 * #G.edgeFinset := by
  rw [SimpleGraph.two_mul_card_edgeFinset]
  congr 1

/-- **The exact finite averaging identity.**  Summing the cut size over *all* `2 ^ n` subsets of
`V` gives `(2 · #edges) · 2 ^ (n - 2)`; dividing by `2 ^ n` this is the statement that the
expected size of a uniformly random cut is `#edges / 2`. -/
theorem sum_cut_eq_card_adjPairs_mul :
    ∑ S ∈ (univ : Finset V).powerset, cut G S =
      #(adjPairs G) * 2 ^ (Fintype.card V - 2) := by
  classical
  have hstep : ∀ S ∈ (univ : Finset V).powerset,
      cut G S = ∑ p ∈ adjPairs G, if p.1 ∈ S ∧ p.2 ∉ S then 1 else 0 := by
    intro S _
    rw [cut, crossPairs, Finset.card_filter]
  rw [Finset.sum_congr rfl hstep, Finset.sum_comm]
  have hinner : ∀ p ∈ adjPairs G,
      (∑ S ∈ (univ : Finset V).powerset, if p.1 ∈ S ∧ p.2 ∉ S then 1 else 0) =
        2 ^ (Fintype.card V - 2) := by
    intro p hp
    simp only [adjPairs, mem_filter] at hp
    have hne : p.1 ≠ p.2 := G.ne_of_adj hp.2
    rw [← Finset.card_filter (fun S : Finset V => p.1 ∈ S ∧ p.2 ∉ S)]
    exact card_filter_mem_notMem p.1 p.2 hne
  rw [Finset.sum_congr rfl hinner, Finset.sum_const, smul_eq_mul]

/-- If the graph has an edge then it has at least two vertices. -/
lemma two_le_card_of_edge (hm : 0 < #G.edgeFinset) : 2 ≤ Fintype.card V := by
  classical
  obtain ⟨e, he⟩ := Finset.card_pos.1 hm
  induction e with
  | _ u v =>
    have huv : G.Adj u v := by simpa using (SimpleGraph.mem_edgeFinset).1 he
    have : ({u, v} : Finset V) ⊆ univ := subset_univ _
    have hcard : #({u, v} : Finset V) = 2 := by
      rw [Finset.card_insert_of_notMem (by simp [G.ne_of_adj huv]), card_singleton]
    calc 2 = #({u, v} : Finset V) := hcard.symm
      _ ≤ #(univ : Finset V) := Finset.card_le_card this
      _ = Fintype.card V := card_univ

/-- **Half of the edges can always be cut.**  Some side `S` satisfies `#edges ≤ 2 · cut S`. -/
theorem exists_cut_ge_half_edges : ∃ S : Finset V, #G.edgeFinset ≤ 2 * cut G S := by
  classical
  rcases Nat.eq_zero_or_pos #G.edgeFinset with hm | hm
  · exact ⟨∅, by simp [hm]⟩
  -- with `n ≥ 2` the total over all `2 ^ n` sides is exactly `#edges · 2 ^ n`
  have hn : 2 ≤ Fintype.card V := two_le_card_of_edge G hm
  obtain ⟨t, ht⟩ : ∃ t, Fintype.card V = t + 2 := ⟨Fintype.card V - 2, by omega⟩
  have hsum : ∑ _S ∈ (univ : Finset V).powerset, #G.edgeFinset ≤
      ∑ S ∈ (univ : Finset V).powerset, 2 * cut G S := by
    rw [Finset.sum_const, smul_eq_mul, Finset.card_powerset, card_univ, ← Finset.mul_sum,
      sum_cut_eq_card_adjPairs_mul, card_adjPairs, ht, Nat.add_sub_cancel]
    have hpow : (2 : ℕ) ^ (t + 2) = 4 * 2 ^ t := by ring
    rw [hpow]
    exact le_of_eq (by ring)
  obtain ⟨S, -, hS⟩ := Finset.exists_le_of_sum_le ⟨∅, by simp⟩ hsum
  exact ⟨S, hS⟩

/-- The exhaustive search: the largest cut over all `2 ^ n` subsets of `V`.  This is a genuine
finite computation, not a choice: `Finset.sup` over the powerset. -/
def maxCut : ℕ := (univ : Finset V).powerset.sup (cut G)

lemma cut_le_maxCut (S : Finset V) : cut G S ≤ maxCut G :=
  Finset.le_sup (f := cut G) (by simp)

/-- The search value is attained by an explicit subset. -/
theorem exists_cut_eq_maxCut : ∃ S : Finset V, cut G S = maxCut G := by
  classical
  obtain ⟨S, hS, hmax⟩ :=
    Finset.exists_mem_eq_sup ((univ : Finset V).powerset) ⟨∅, by simp⟩ (cut G)
  exact ⟨S, hmax.symm⟩

/-- **The derandomised statement.**  The terminating exhaustive search `maxCut` already cuts at
least half of the edges. -/
theorem maxCut_ge_half_edges : #G.edgeFinset ≤ 2 * maxCut G := by
  obtain ⟨S, hS⟩ := exists_cut_ge_half_edges G
  exact hS.trans (Nat.mul_le_mul_left 2 (cut_le_maxCut G S))

/-- The same conclusion phrased as a `2`-colouring: some `f : V → Bool` cuts at least half of the
edges, where a cut edge is an ordered adjacent pair coloured `true`/`false`. -/
theorem exists_bool_colouring_cut :
    ∃ f : V → Bool,
      #G.edgeFinset ≤ 2 * #((adjPairs G).filter (fun p => f p.1 = true ∧ f p.2 = false)) := by
  classical
  obtain ⟨S, hS⟩ := exists_cut_ge_half_edges G
  refine ⟨fun v => decide (v ∈ S), ?_⟩
  have : ((adjPairs G).filter (fun p => decide (p.1 ∈ S) = true ∧ decide (p.2 ∈ S) = false)) =
      crossPairs G S := by
    apply Finset.filter_congr
    intro p _
    simp
  rw [this]
  exact hS

/-! ## The complete graph: the search value is exactly the Turán number `ex(n, K₃)` -/

section CompleteGraph

/-- In the complete graph the cut of `S` consists of all ordered pairs from `S` to its
complement, so it has `#S · (n − #S)` elements. -/
lemma cut_top (S : Finset V) :
    cut (⊤ : SimpleGraph V) S = #S * (Fintype.card V - #S) := by
  classical
  have hset : crossPairs (⊤ : SimpleGraph V) S = S ×ˢ Sᶜ := by
    ext p
    simp only [crossPairs, adjPairs, mem_filter, mem_univ, true_and, Finset.mem_product,
      Finset.mem_compl, SimpleGraph.top_adj]
    constructor
    · rintro ⟨-, h1, h2⟩
      exact ⟨h1, h2⟩
    · rintro ⟨h1, h2⟩
      refine ⟨?_, h1, h2⟩
      intro he
      exact h2 (he ▸ h1)
  rw [cut, hset, Finset.card_product, Finset.card_compl]

/-- The balanced split beats every other split, sharply over the integers:
`4 · #S · (n − #S) ≤ n²`. -/
lemma four_mul_cut_top_le (S : Finset V) :
    4 * cut (⊤ : SimpleGraph V) S ≤ (Fintype.card V) ^ 2 := by
  rw [cut_top]
  obtain ⟨j, hj⟩ : ∃ j, Fintype.card V = #S + j :=
    ⟨Fintype.card V - #S, by have := Finset.card_le_univ S; omega⟩
  have hsub : Fintype.card V - #S = j := by omega
  rw [hsub, hj]
  zify
  nlinarith [sq_nonneg ((#S : ℤ) - (j : ℤ))]

/-- The balanced split, with the exact defect: `4 · (n/2) · (n − n/2) + n % 2 = n²`. -/
lemma four_mul_balanced_add_mod (n : ℕ) : 4 * ((n / 2) * (n - n / 2)) + n % 2 = n ^ 2 := by
  obtain ⟨m, s, hs, hn⟩ : ∃ m s, s < 2 ∧ n = 2 * m + s :=
    ⟨n / 2, n % 2, Nat.mod_lt _ (by norm_num), by omega⟩
  have hq : n / 2 = m := by omega
  have hr : n % 2 = s := by omega
  have hd : n - n / 2 = m + s := by omega
  rw [hd, hq, hr, hn]
  interval_cases s <;> ring

/-- **The maximum cut of the complete graph.**  The exhaustive search returns the balanced
bipartition value `(n/2) · (n − n/2)`. -/
theorem maxCut_top : maxCut (⊤ : SimpleGraph V) =
    (Fintype.card V / 2) * (Fintype.card V - Fintype.card V / 2) := by
  classical
  set n := Fintype.card V with hn
  refine le_antisymm (Finset.sup_le ?_) ?_
  · intro S _
    by_contra hcon
    push_neg at hcon
    have h1 : 4 * cut (⊤ : SimpleGraph V) S ≤ n ^ 2 := four_mul_cut_top_le S
    have h2 : 4 * ((n / 2) * (n - n / 2)) + n % 2 = n ^ 2 := four_mul_balanced_add_mod n
    have h3 : n % 2 < 2 := Nat.mod_lt _ (by norm_num)
    omega
  · -- an explicit balanced side attains the value
    obtain ⟨S, -, hcard⟩ :=
      Finset.exists_subset_card_eq (s := (univ : Finset V)) (n := n / 2)
        (by simp only [card_univ, ← hn]; omega)
    have := cut_le_maxCut (⊤ : SimpleGraph V) S
    rwa [cut_top, hcard] at this

end CompleteGraph

/-- **Bridge to Turán.**  The maximum cut of `Kₙ` is exactly the number of edges of the Turán
graph `T(n, 2)`, i.e. the extremal number `ex(n, K₃)`: the largest bipartite subgraph of the
complete graph *is* the extremal triangle-free graph. -/
theorem maxCut_top_eq_card_edgeFinset_turanGraph (n : ℕ) :
    maxCut (⊤ : SimpleGraph (Fin n)) = #(SimpleGraph.turanGraph n 2).edgeFinset := by
  have hbal : 4 * ((n / 2) * (n - n / 2)) + n % 2 = n ^ 2 := four_mul_balanced_add_mod n
  have hturan := TuranSharpNonDivisible.turan_edge_identity (n := n) (r := 2) (by norm_num)
  have hcard : Fintype.card (Fin n) = n := Fintype.card_fin n
  have hmax : maxCut (⊤ : SimpleGraph (Fin n)) = (n / 2) * (n - n / 2) := by
    rw [maxCut_top, hcard]
  have hsq : (2 - 1) * n ^ 2 = n ^ 2 := by ring
  rw [hsq] at hturan
  have hcases : n % 2 = 0 ∨ n % 2 = 1 := by omega
  rcases hcases with h | h <;> rw [h] at hturan <;> omega

end MaxCutDerandomized

namespace MaxCutDerandomized

/-- The search on the triangle `K₃`: the largest cut has two edges, and the bound `m ≤ 2 · cut`
is tight there (`3 ≤ 4`, while `3 ≤ 2 · 1` would be false). -/
theorem maxCut_triangle : maxCut (⊤ : SimpleGraph (Fin 3)) = 2 := by decide

/-- The search on `K₄`: the largest cut has four edges (the balanced bipartition `2 + 2`). -/
theorem maxCut_completeGraph_four : maxCut (⊤ : SimpleGraph (Fin 4)) = 4 := by decide

end MaxCutDerandomized