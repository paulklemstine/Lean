/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-! # Bipartite extremal numbers of trees

This file develops the extremal theory of trees restricted to **bipartite host graphs**, in the
two variants studied in the literature:

* `exBip n T`: the maximum number of edges of a `T`-free bipartite graph on `n` vertices;
* `exBipParts m n T`: the same, when the two parts are prescribed to have sizes `m` and `n`.

## Main results

* `exBip_le_extremalNumber`: the bipartite extremal number is at most the ordinary one.
* `extremalNumber_le_two_mul_exBip`: conversely, the ordinary extremal number is at most twice
  the bipartite one (via a max-cut averaging argument), so the two functions agree up to a
  factor of two for every forbidden graph.
* `exBip_eq_sup_exBipParts`: the order-only function is the maximum of the fixed-part functions
  over all splittings `n = m + (n - m)`.
* `two_mul_exBip_starGraph_le`, `exBipParts_starGraph_le`: linear (Erdős–Sós type) upper bounds
  for stars, in both variants.
* `exBipParts_starGraph_eq`, `exBipParts_starGraph_eq_of_le`, `exBip_starGraph_eq`: exact values
  for stars with balanced parts, the extremal graph being the `k`-regular bipartite circulant
  `bipCirculant`.
* `exBipParts_starGraph`: **the complete fixed-part star formula**
  `exBipParts m n K_{1,k+1} = min (k · min m n) (m · n)` for all `m, n, k`, the extremal graph
  for unbalanced parts being the shifted interval graph `bipShift`.
* `exBip_starGraph`: **the complete order-only star formula**
  `exBip n K_{1,k+1} = min (k⌊n/2⌋) (⌊n/2⌋⌈n/2⌉)` for all `n, k`, with the two regimes
  `exBip_starGraph_of_two_mul_le` (`2k ≤ n`) and `exBip_starGraph_of_le_two_mul` (`n ≤ 2k`).
* `exBipParts_starGraph_two`, `exBip_starGraph_two`: the complete answer for `K_{1,2} = P₃`
  (`exBip n P₃ = ⌊n/2⌋` for every `n`), the extremal graph being a maximum matching.
* `free_completeBipartiteGraph_of_forall_coloring`, `mul_le_exBip_of_free`: the general
  colouring criterion producing the natural linear lower-bound construction `K_{a,b}`.
* `coloring_unique_of_connected`, `exBip_ge_of_connected`, `exBipParts_eq_mul_of_connected`:
  for a *connected* forbidden graph `T` the colour classes are an invariant, giving the general
  lower bound `s (n - s) ≤ exBip n T` whenever both classes exceed `s`, and the *exact* value
  `exBipParts m n T = m n` whenever both classes exceed `m`.
* `exBip_pathGraph_lower_bound`: the resulting lower bound `(⌊p/2⌋-1)(n-⌊p/2⌋+1)` for paths.
* `exBip_pathGraph_four`: the exact value `exBip n P₄ = n - 1` for `n ≥ 2`.

## Lab notes (exhaustive search, all labelled graphs on `n ≤ 7` vertices)

```
n        2  3  4  5  6  7
P₄       1  2  3  4  5  6      = n - 1        (proved: exBip_pathGraph_four)
P₅       1  2  4  4  5  6      ≠ n - 1 for n = 4 and, by disjoint C₄'s, for n = 8
K_{1,2}  1  1  2  2  3  3      = ⌊n/2⌋        (proved: exBip_starGraph_two)
K_{1,3}  1  2  4  4  6  6      = 2N at n = 2N (proved: exBip_starGraph_eq, k = 2 ≤ N)
```

The entry `K_{1,3}` at `n = 5` is `4`, strictly below `⌊k·n/2⌋ = 5`: the odd-order star problem
has a genuine parity obstruction.  `exBip_starGraph` explains and resolves it: the true value is
`min (k⌊n/2⌋) (⌊n/2⌋⌈n/2⌉)`, which for `n = 5, k = 2` is `min 4 6 = 4`, and which reproduces the
whole `K_{1,2}` and `K_{1,3}` rows above.  See `ComputationalEvidence.md` for details.
-/

namespace Catalog.Combinatorics.BipartiteExtremalTrees

open Finset Fintype SimpleGraph

section Defs

open Classical in
/-- The **bipartite extremal number**: the maximum number of edges of a `T`-free *bipartite*
graph on `n` vertices. -/
noncomputable def exBip (n : ℕ) {W : Type*} (T : SimpleGraph W) : ℕ :=
  sup {G : SimpleGraph (Fin n) | T.Free G ∧ G.IsBipartite} (#·.edgeFinset)

open Classical in
/-- The **fixed-part bipartite extremal number**: the maximum number of edges of a `T`-free
graph whose vertex set is split into parts of sizes `m` and `n`, all of whose edges join the
two parts. -/
noncomputable def exBipParts (m n : ℕ) {W : Type*} (T : SimpleGraph W) : ℕ :=
  sup {G : SimpleGraph (Fin m ⊕ Fin n) |
        T.Free G ∧ G ≤ completeBipartiteGraph (Fin m) (Fin n)} (#·.edgeFinset)

end Defs

variable {W : Type*} {T : SimpleGraph W}

/-- Counting over `Fin p` is counting over `range p`. -/
private lemma card_fin_filter_eq_range (p : ℕ) (P : ℕ → Prop) [DecidablePred P] :
    #(univ.filter fun i : Fin p => P i.val) = #((range p).filter P) := by
  rw [← Finset.card_map ⟨Fin.val, Fin.val_injective⟩]
  congr 1
  ext x
  simp only [Finset.mem_map, Finset.mem_filter, Finset.mem_univ, true_and,
    Function.Embedding.coeFn_mk, Finset.mem_range]
  constructor
  · rintro ⟨y, hy, rfl⟩; exact ⟨y.isLt, hy⟩
  · rintro ⟨hx, hx2⟩; exact ⟨⟨x, hx⟩, hx2, rfl⟩


open Classical in
/-- Every `T`-free bipartite graph on `Fin n` has at most `exBip n T` edges. -/
theorem card_edgeFinset_le_exBip {n : ℕ} {G : SimpleGraph (Fin n)} [DecidableRel G.Adj]
    (hfree : T.Free G) (hbip : G.IsBipartite) : #G.edgeFinset ≤ exBip n T := by
  convert @Finset.le_sup _ _ _ _ {G : SimpleGraph (Fin n) | T.Free G ∧ G.IsBipartite}
    (#·.edgeFinset) G (Finset.mem_filter.mpr ⟨Finset.mem_univ _, ⟨hfree, hbip⟩⟩)

open Classical in
theorem exBip_le_iff {n : ℕ} (m : ℕ) :
    exBip n T ≤ m ↔ ∀ (G : SimpleGraph (Fin n)), T.Free G → G.IsBipartite →
      #G.edgeFinset ≤ m := by
  simp_rw [exBip, Finset.sup_le_iff, mem_filter_univ]
  exact ⟨fun h G h1 h2 ↦ by convert h G ⟨h1, h2⟩, fun h G hG ↦ by convert h G hG.1 hG.2⟩

/-- Transport: any `T`-free bipartite graph on a vertex type of size `n` witnesses a lower
bound for `exBip n T`. -/
theorem card_edgeFinset_le_exBip' {V : Type*} [Fintype V] {n : ℕ} (hcard : card V = n)
    {G : SimpleGraph V} [DecidableRel G.Adj]
    (hfree : T.Free G) (hbip : G.IsBipartite) : #G.edgeFinset ≤ exBip n T := by
  classical
  let e := Fintype.equivFinOfCardEq hcard
  let iso : G ≃g G.map e.toEmbedding := SimpleGraph.Iso.map e G
  have h1 : #(G.map e.toEmbedding).edgeFinset = #G.edgeFinset := iso.card_edgeFinset_eq.symm
  have h2 : T.Free (G.map e.toEmbedding) := (free_congr (Iso.refl) iso).mp hfree
  have h3 : (G.map e.toEmbedding).IsBipartite := Colorable.of_hom iso.symm.toHom hbip
  exact h1 ▸ card_edgeFinset_le_exBip h2 h3

/-- The bipartite extremal number never exceeds the ordinary extremal number. -/
theorem exBip_le_extremalNumber (n : ℕ) (T : SimpleGraph W) :
    exBip n T ≤ extremalNumber n T := by
  classical
  rw [exBip_le_iff]
  intro G hfree _
  simpa using card_edgeFinset_le_extremalNumber (V := Fin n) hfree

/-! ### Max-cut: the ordinary extremal number is at most twice the bipartite one

Deleting the edges inside the two sides of a maximum cut of a `T`-free graph leaves a *bipartite*
`T`-free graph with at least half of the edges.  Hence the bipartite restriction of the
Erdős–Sós problem loses at most a factor of two:
`exBip n T ≤ extremalNumber n T ≤ 2 * exBip n T`. -/

/-- The bipartite subgraph of `G` cut out by a two-colouring `c`. -/
def cutSubgraph {V : Type*} (G : SimpleGraph V) (c : V → Bool) : SimpleGraph V where
  Adj u v := G.Adj u v ∧ c u ≠ c v
  symm := fun _ _ h => ⟨h.1.symm, h.2.symm⟩
  loopless := ⟨fun _ h => G.irrefl h.1⟩

instance instDecidableAdjCutSubgraph {V : Type*} (G : SimpleGraph V) [DecidableRel G.Adj]
    (c : V → Bool) : DecidableRel (cutSubgraph G c).Adj :=
  fun _ _ => inferInstanceAs (Decidable (_ ∧ _))

theorem cutSubgraph_le {V : Type*} (G : SimpleGraph V) (c : V → Bool) :
    cutSubgraph G c ≤ G := fun _ _ h => h.1

/-- The cut subgraph is bipartite: `c` is a proper two-colouring of it. -/
theorem cutSubgraph_isBipartite {V : Type*} (G : SimpleGraph V) (c : V → Bool) :
    (cutSubgraph G c).IsBipartite := by
  have hcol : (cutSubgraph G c).Coloring Bool := SimpleGraph.Coloring.mk c fun h => h.2
  simpa using hcol.colorable

/-- For distinct `u, v`, exactly half of the two-colourings separate them. -/
private lemma two_mul_card_filter_ne {V : Type*} [Fintype V] [DecidableEq V] {u v : V}
    (huv : u ≠ v) :
    2 * #(univ.filter fun c : V → Bool => c u ≠ c v) = 2 ^ (Fintype.card V) := by
  have hkey : #(univ.filter fun c : V → Bool => c u ≠ c v)
      = #(univ.filter fun c : V → Bool => ¬ (c u ≠ c v)) := by
    refine Finset.card_nbij' (fun c => Function.update c u (!c u))
      (fun c => Function.update c u (!c u)) ?_ ?_ ?_ ?_
    · intro c hc
      simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hc ⊢
      rw [Function.update_self, Function.update_of_ne (Ne.symm huv)]
      revert hc; cases c u <;> cases c v <;> simp
    · intro c hc
      simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hc ⊢
      rw [Function.update_self, Function.update_of_ne (Ne.symm huv)]
      revert hc; cases c u <;> cases c v <;> simp
    · intro c _
      funext x
      by_cases hx : x = u <;> simp [hx, Function.update_apply]
    · intro c _
      funext x
      by_cases hx : x = u <;> simp [hx, Function.update_apply]
  have hsum := Finset.card_filter_add_card_filter_not
    (s := (univ : Finset (V → Bool))) (p := fun c : V → Bool => c u ≠ c v)
  simp only [Finset.card_univ, Fintype.card_fun, Fintype.card_bool] at hsum
  omega

/-- **Max-cut counting identity.**  Summed over all two-colourings, twice the number of cut
edges equals `2^{|V|}` times the number of edges. -/
theorem sum_two_mul_card_edgeFinset_cutSubgraph {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    ∑ c : V → Bool, 2 * #(cutSubgraph G c).edgeFinset
      = 2 ^ (Fintype.card V) * #G.edgeFinset := by
  have hpair : ∀ c : V → Bool, 2 * #(cutSubgraph G c).edgeFinset
      = #(univ.filter fun p : V × V => G.Adj p.1 p.2 ∧ c p.1 ≠ c p.2) := by
    intro c
    rw [SimpleGraph.two_mul_card_edgeFinset]
    rfl
  simp_rw [hpair, Finset.card_filter]
  rw [Finset.sum_comm]
  have hinner : ∀ p : V × V,
      (∑ c : V → Bool, if G.Adj p.1 p.2 ∧ c p.1 ≠ c p.2 then 1 else 0)
        = if G.Adj p.1 p.2 then #(univ.filter fun c : V → Bool => c p.1 ≠ c p.2) else 0 := by
    intro p
    by_cases hp : G.Adj p.1 p.2
    · simp [hp, Finset.card_filter]
    · simp [hp]
  simp_rw [hinner]
  rw [← Finset.sum_filter]
  have hval : ∀ p ∈ univ.filter (fun p : V × V => G.Adj p.1 p.2),
      2 * #(univ.filter fun c : V → Bool => c p.1 ≠ c p.2) = 2 ^ (Fintype.card V) := by
    intro p hp
    rw [Finset.mem_filter] at hp
    exact two_mul_card_filter_ne hp.2.ne
  have h2 : 2 * ∑ p ∈ univ.filter (fun p : V × V => G.Adj p.1 p.2),
      #(univ.filter fun c : V → Bool => c p.1 ≠ c p.2)
      = 2 * (2 ^ (Fintype.card V) * #G.edgeFinset) := by
    rw [Finset.mul_sum, Finset.sum_congr rfl hval, Finset.sum_const, smul_eq_mul,
      ← SimpleGraph.two_mul_card_edgeFinset]
    ring
  omega

/-- **Every graph has a bipartite subgraph with at least half of its edges** (max-cut bound),
obtained by averaging the cut size over all two-colourings. -/
theorem exists_cutSubgraph_card_edgeFinset {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    ∃ c : V → Bool, #G.edgeFinset ≤ 2 * #(cutSubgraph G c).edgeFinset := by
  by_contra hcon
  push_neg at hcon
  have hlt : ∑ c : V → Bool, 2 * #(cutSubgraph G c).edgeFinset
      < ∑ _c : V → Bool, #G.edgeFinset :=
    Finset.sum_lt_sum_of_nonempty ⟨fun _ => true, Finset.mem_univ _⟩ fun c _ => hcon c
  rw [sum_two_mul_card_edgeFinset_cutSubgraph, Finset.sum_const, smul_eq_mul,
    Finset.card_univ, Fintype.card_fun, Fintype.card_bool] at hlt
  omega

/-- **The ordinary extremal number is at most twice the bipartite one.**  Together with
`exBip_le_extremalNumber` this sandwiches the two functions within a factor of two, for *every*
forbidden graph `T`; in particular the bipartite Erdős–Sós problem is linear if and only if the
ordinary one is. -/
theorem extremalNumber_le_two_mul_exBip (n : ℕ) (T : SimpleGraph W) :
    extremalNumber n T ≤ 2 * exBip n T := by
  classical
  have hiff := SimpleGraph.extremalNumber_le_iff (V := Fin n) T (2 * exBip n T)
  simp only [Fintype.card_fin] at hiff
  rw [hiff]
  intro G _ hfree
  obtain ⟨c, hc⟩ := exists_cutSubgraph_card_edgeFinset G
  have hfree' : T.Free (cutSubgraph G c) := fun hcon =>
    hfree (hcon.mono_right (cutSubgraph_le G c))
  exact hc.trans (Nat.mul_le_mul_left 2
    (card_edgeFinset_le_exBip hfree' (cutSubgraph_isBipartite G c)))

/-- **The two extremal functions agree up to a factor of two.** -/
theorem exBip_le_extremalNumber_and_le_two_mul (n : ℕ) (T : SimpleGraph W) :
    exBip n T ≤ extremalNumber n T ∧ extremalNumber n T ≤ 2 * exBip n T :=
  ⟨exBip_le_extremalNumber n T, extremalNumber_le_two_mul_exBip n T⟩

/-! ### The complete bipartite host -/

instance instDecidableAdjCompleteBipartite {α β : Type*} :
    DecidableRel (completeBipartiteGraph α β).Adj :=
  fun _ _ => inferInstanceAs (Decidable (_ ∨ _))

/-- The complete bipartite graph is bipartite. -/
theorem completeBipartiteGraph_isBipartite (α β : Type*) :
    (completeBipartiteGraph α β).IsBipartite := by
  refine IsBipartiteWith.isBipartite (s := {v : α ⊕ β | v.isLeft})
    (t := {v : α ⊕ β | v.isRight}) ?_
  constructor
  · rw [Set.disjoint_left]
    rintro (v | v) <;> simp
  · rintro (v | v) (w | w) h <;> simp_all [completeBipartiteGraph]

/-- The complete bipartite graph with parts of sizes `m` and `n` has `m * n` edges. -/
theorem card_edgeFinset_completeBipartiteGraph (m n : ℕ) :
    #(completeBipartiteGraph (Fin m) (Fin n)).edgeFinset = m * n := by
  have key := SimpleGraph.sum_degrees_eq_twice_card_edges (completeBipartiteGraph (Fin m) (Fin n))
  have hl : ∀ v : Fin m, (completeBipartiteGraph (Fin m) (Fin n)).degree (Sum.inl v) = n := by
    intro v
    rw [← card_neighborFinset_eq_degree,
      show (completeBipartiteGraph (Fin m) (Fin n)).neighborFinset (Sum.inl v)
        = Finset.univ.map ⟨Sum.inr, Sum.inr_injective⟩ by ext w; cases w <;> simp]
    simp
  have hr : ∀ w : Fin n, (completeBipartiteGraph (Fin m) (Fin n)).degree (Sum.inr w) = m := by
    intro w
    rw [← card_neighborFinset_eq_degree,
      show (completeBipartiteGraph (Fin m) (Fin n)).neighborFinset (Sum.inr w)
        = Finset.univ.map ⟨Sum.inl, Sum.inl_injective⟩ by ext v; cases v <;> simp]
    simp
  rw [Fintype.sum_sum_type] at key
  simp [hl, hr, Nat.mul_comm] at key ⊢
  omega

/-! ### Basic API for the fixed-part bipartite extremal number -/

open Classical in
theorem card_edgeFinset_le_exBipParts {m n : ℕ} {G : SimpleGraph (Fin m ⊕ Fin n)}
    [DecidableRel G.Adj] (hfree : T.Free G) (hsub : G ≤ completeBipartiteGraph (Fin m) (Fin n)) :
    #G.edgeFinset ≤ exBipParts m n T := by
  convert @Finset.le_sup _ _ _ _ {G : SimpleGraph (Fin m ⊕ Fin n) |
      T.Free G ∧ G ≤ completeBipartiteGraph (Fin m) (Fin n)} (#·.edgeFinset) G
    (Finset.mem_filter.mpr ⟨Finset.mem_univ _, ⟨hfree, hsub⟩⟩)

open Classical in
theorem exBipParts_le_iff {m n : ℕ} (c : ℕ) :
    exBipParts m n T ≤ c ↔ ∀ (G : SimpleGraph (Fin m ⊕ Fin n)), T.Free G →
      G ≤ completeBipartiteGraph (Fin m) (Fin n) → #G.edgeFinset ≤ c := by
  simp_rw [exBipParts, Finset.sup_le_iff, mem_filter_univ]
  exact ⟨fun h G h1 h2 ↦ by convert h G ⟨h1, h2⟩, fun h G hG ↦ by convert h G hG.1 hG.2⟩

/-- A graph with parts of sizes `m` and `n` has at most `m * n` edges. -/
theorem exBipParts_le_mul (m n : ℕ) (T : SimpleGraph W) : exBipParts m n T ≤ m * n := by
  classical
  rw [exBipParts_le_iff]
  intro G _ hsub
  rw [← card_edgeFinset_completeBipartiteGraph m n]
  exact Finset.card_le_card (edgeFinset_mono hsub)

/-- **Fixed parts refine the order-only problem.** -/
theorem exBipParts_le_exBip (m n : ℕ) (T : SimpleGraph W) :
    exBipParts m n T ≤ exBip (m + n) T := by
  classical
  rw [exBipParts_le_iff]
  intro G hfree hsub
  refine card_edgeFinset_le_exBip' ?_ hfree (Colorable.mono_left hsub
    (completeBipartiteGraph_isBipartite (Fin m) (Fin n)))
  simp

/-- Swapping the two parts does not change the fixed-part bipartite extremal number. -/
theorem exBipParts_comm (m n : ℕ) (T : SimpleGraph W) :
    exBipParts m n T = exBipParts n m T := by
  classical
  have key : ∀ (a b : ℕ), exBipParts a b T ≤ exBipParts b a T := by
    intro a b
    rw [exBipParts_le_iff]
    intro G hfree hsub
    let e : Fin a ⊕ Fin b ≃ Fin b ⊕ Fin a := Equiv.sumComm (Fin a) (Fin b)
    let iso : G ≃g G.map e.toEmbedding := SimpleGraph.Iso.map e G
    have hcard : #(G.map e.toEmbedding).edgeFinset = #G.edgeFinset := iso.card_edgeFinset_eq.symm
    have hfree' : T.Free (G.map e.toEmbedding) := (free_congr (Iso.refl) iso).mp hfree
    have hsub' : G.map e.toEmbedding ≤ completeBipartiteGraph (Fin b) (Fin a) := by
      rintro x y ⟨u, v, huv, hu, hv⟩
      have := hsub huv
      subst hu; subst hv
      cases u <;> cases v <;> simp_all [completeBipartiteGraph, e]
    have hle := card_edgeFinset_le_exBipParts hfree' hsub'
    rwa [hcard] at hle
  exact le_antisymm (key m n) (key n m)

/-! ### Stars

The star `K_{1,k}` is the first family for which the bipartite extremal number can be computed
exactly. -/

/-- The star with `k` leaves, `K_{1,k}`. -/
def starGraph (k : ℕ) : SimpleGraph (Unit ⊕ Fin k) := completeBipartiteGraph Unit (Fin k)

/-- A graph contains a copy of `K_{1,k}` iff it has a vertex of degree at least `k`. -/
theorem starGraph_isContained_iff {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] (k : ℕ) : starGraph k ⊑ G ↔ ∃ v, k ≤ G.degree v := by
  rw [show starGraph k = completeBipartiteGraph Unit (Fin k) from rfl,
    completeBipartiteGraph_isContained_iff]
  constructor
  · rintro ⟨left, right, hl, hr, h⟩
    simp only [Fintype.card_unit, Fintype.card_fin] at hl hr
    obtain ⟨v, rfl⟩ := Finset.card_eq_one.mp hl
    refine ⟨v, ?_⟩
    rw [← hr, ← card_neighborFinset_eq_degree]
    exact Finset.card_le_card fun w hw =>
      (SimpleGraph.mem_neighborFinset ..).mpr (h (by simp) hw)
  · rintro ⟨v, hv⟩
    rw [← card_neighborFinset_eq_degree] at hv
    obtain ⟨right, hsub, hcard⟩ := Finset.exists_subset_card_eq hv
    refine ⟨{v}, right, by simp, by simp [hcard], ?_⟩
    intro x hx y hy
    simp only [Finset.coe_singleton, Set.mem_singleton_iff] at hx
    subst hx
    exact (SimpleGraph.mem_neighborFinset ..).mp (hsub hy)

/-- A graph is `K_{1,k}`-free iff all its degrees are less than `k`. -/
theorem starGraph_free_iff {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] (k : ℕ) : (starGraph k).Free G ↔ ∀ v, G.degree v < k := by
  rw [SimpleGraph.Free, starGraph_isContained_iff]
  push_neg
  rfl

/-- **Bipartite Erdős–Sós bound for stars.** -/
theorem two_mul_exBip_starGraph_le (n k : ℕ) : 2 * exBip n (starGraph (k + 1)) ≤ k * n := by
  classical
  have h : exBip n (starGraph (k + 1)) ≤ k * n / 2 := by
    rw [exBip_le_iff]
    intro G hfree _
    rw [starGraph_free_iff] at hfree
    have hsum := SimpleGraph.sum_degrees_eq_twice_card_edges G
    have hle : ∑ v : Fin n, G.degree v ≤ k * n := by
      calc ∑ v : Fin n, G.degree v ≤ ∑ _v : Fin n, k :=
            Finset.sum_le_sum fun v _ => Nat.lt_succ_iff.mp (hfree v)
        _ = k * n := by simp [Nat.mul_comm]
    omega
  omega

/-- **Fixed-part bound for stars**: a `K_{1,k+1}`-free graph with parts of sizes `m` and `n`
has at most `k * min m n` edges. -/
theorem exBipParts_starGraph_le (m n k : ℕ) :
    exBipParts m n (starGraph (k + 1)) ≤ k * min m n := by
  classical
  rw [exBipParts_le_iff]
  intro G hfree hsub
  rw [starGraph_free_iff] at hfree
  have hdeg : ∀ v, G.degree v ≤ k := fun v => Nat.lt_succ_iff.mp (hfree v)
  set L : Finset (Fin m ⊕ Fin n) := Finset.univ.map ⟨Sum.inl, Sum.inl_injective⟩ with hLdef
  set R : Finset (Fin m ⊕ Fin n) := Finset.univ.map ⟨Sum.inr, Sum.inr_injective⟩ with hRdef
  have hbw : G.IsBipartiteWith (L : Set (Fin m ⊕ Fin n)) (R : Set (Fin m ⊕ Fin n)) := by
    constructor
    · rw [Set.disjoint_left]
      rintro (v | v) <;> simp [hLdef, hRdef]
    · rintro (v | v) (w | w) h <;> have := hsub h <;>
        simp_all [completeBipartiteGraph]
  have hL : #G.edgeFinset ≤ k * m := by
    rw [← isBipartiteWith_sum_degrees_eq_card_edges hbw]
    calc ∑ v ∈ L, G.degree v ≤ ∑ _v ∈ L, k := Finset.sum_le_sum fun v _ => hdeg v
      _ = k * m := by rw [Finset.sum_const, hLdef]; simp [Nat.mul_comm]
  have hR : #G.edgeFinset ≤ k * n := by
    rw [← isBipartiteWith_sum_degrees_eq_card_edges' hbw]
    calc ∑ v ∈ R, G.degree v ≤ ∑ _v ∈ R, k := Finset.sum_le_sum fun v _ => hdeg v
      _ = k * n := by rw [Finset.sum_const, hRdef]; simp [Nat.mul_comm]
  rcases le_total m n with h | h
  · simpa [Nat.min_eq_left h] using hL
  · simpa [Nat.min_eq_right h] using hR

/-! ### The bipartite circulant, and exact star values

`bipCirculant N k` is the `k`-regular bipartite graph on parts `Fin N`, `Fin N` in which
`inl i` is joined to `inr j` exactly when `j - i` is one of the `k` smallest residues.
It is the extremal construction for stars. -/

/-- The `k`-regular bipartite circulant graph with parts `Fin N` and `Fin N`. -/
def bipCirculant (N k : ℕ) : SimpleGraph (Fin N ⊕ Fin N) where
  Adj x y := match x, y with
    | Sum.inl i, Sum.inr j => (j - i).val < k
    | Sum.inr j, Sum.inl i => (j - i).val < k
    | _, _ => False
  symm := by rintro (a | a) (b | b) h <;> exact h
  loopless := ⟨by rintro (a | a) h <;> exact h⟩

instance instDecidableAdjBipCirculant (N k : ℕ) : DecidableRel (bipCirculant N k).Adj := by
  intro x y
  cases x <;> cases y <;> dsimp [bipCirculant] <;> infer_instance

theorem bipCirculant_le_completeBipartiteGraph (N k : ℕ) :
    bipCirculant N k ≤ completeBipartiteGraph (Fin N) (Fin N) := by
  rintro (a | a) (b | b) h <;> simp_all [bipCirculant, completeBipartiteGraph]

/-- There are exactly `k` residues `j` with `j - i` among the `k` smallest residues. -/
private lemma card_filter_sub_right_lt {N k : ℕ} (h : k ≤ N) (i : Fin N) :
    #(univ.filter fun j : Fin N => (j - i).val < k) = k := by
  obtain ⟨M, rfl⟩ : ∃ M, N = M + 1 := by
    cases N with
    | zero => exact absurd i.isLt (by omega)
    | succ M => exact ⟨M, rfl⟩
  rw [show (univ.filter fun j : Fin (M + 1) => (j - i).val < k)
      = (univ.filter fun d : Fin (M + 1) => d.val < k).map (Equiv.addRight i).toEmbedding by
        ext j; simp [Equiv.addRight, sub_eq_add_neg]]
  rw [Finset.card_map,
    show (univ.filter fun d : Fin (M + 1) => d.val < k)
      = (Finset.range k).attachFin fun m hm => lt_of_lt_of_le (Finset.mem_range.mp hm) h by
        ext d; simp [Finset.mem_attachFin]]
  simp

/-- There are exactly `k` residues `i` with `j - i` among the `k` smallest residues. -/
private lemma card_filter_sub_left_lt {N k : ℕ} (h : k ≤ N) (j : Fin N) :
    #(univ.filter fun i : Fin N => (j - i).val < k) = k := by
  obtain ⟨M, rfl⟩ : ∃ M, N = M + 1 := by
    cases N with
    | zero => exact absurd j.isLt (by omega)
    | succ M => exact ⟨M, rfl⟩
  rw [show (univ.filter fun i : Fin (M + 1) => (j - i).val < k)
      = (univ.filter fun d : Fin (M + 1) => d.val < k).map (Equiv.subLeft j).toEmbedding by
        ext i; simp [Equiv.subLeft, sub_eq_neg_add]]
  rw [Finset.card_map,
    show (univ.filter fun d : Fin (M + 1) => d.val < k)
      = (Finset.range k).attachFin fun m hm => lt_of_lt_of_le (Finset.mem_range.mp hm) h by
        ext d; simp [Finset.mem_attachFin]]
  simp

/-- Every left vertex of `bipCirculant N k` has degree `k`, provided `k ≤ N`. -/
theorem bipCirculant_degree_left {N k : ℕ} (h : k ≤ N) (i : Fin N) :
    (bipCirculant N k).degree (Sum.inl i) = k := by
  rw [← card_neighborFinset_eq_degree,
    show (bipCirculant N k).neighborFinset (Sum.inl i)
      = (univ.filter fun j : Fin N => (j - i).val < k).map ⟨Sum.inr, Sum.inr_injective⟩ by
        ext x; cases x <;> simp [bipCirculant]]
  rw [Finset.card_map, card_filter_sub_right_lt h i]

/-- Every right vertex of `bipCirculant N k` has degree `k`, provided `k ≤ N`. -/
theorem bipCirculant_degree_right {N k : ℕ} (h : k ≤ N) (j : Fin N) :
    (bipCirculant N k).degree (Sum.inr j) = k := by
  rw [← card_neighborFinset_eq_degree,
    show (bipCirculant N k).neighborFinset (Sum.inr j)
      = (univ.filter fun i : Fin N => (j - i).val < k).map ⟨Sum.inl, Sum.inl_injective⟩ by
        ext x; cases x <;> simp [bipCirculant]]
  rw [Finset.card_map, card_filter_sub_left_lt h j]

/-- The circulant `bipCirculant N k` has exactly `k * N` edges when `k ≤ N`. -/
theorem card_edgeFinset_bipCirculant {N k : ℕ} (h : k ≤ N) :
    #(bipCirculant N k).edgeFinset = k * N := by
  set L : Finset (Fin N ⊕ Fin N) := Finset.univ.map ⟨Sum.inl, Sum.inl_injective⟩ with hLdef
  set R : Finset (Fin N ⊕ Fin N) := Finset.univ.map ⟨Sum.inr, Sum.inr_injective⟩ with hRdef
  have hbw : (bipCirculant N k).IsBipartiteWith (L : Set (Fin N ⊕ Fin N))
      (R : Set (Fin N ⊕ Fin N)) := by
    constructor
    · rw [Set.disjoint_left]
      rintro (v | v) <;> simp [hLdef, hRdef]
    · rintro (v | v) (w | w) hadj <;> simp_all [bipCirculant]
  rw [← isBipartiteWith_sum_degrees_eq_card_edges hbw]
  rw [hLdef, Finset.sum_map]
  simp [bipCirculant_degree_left h, Nat.mul_comm]

/-- **Exact fixed-part bipartite extremal number of a star.**  For `k ≤ N`, a `K_{1,k+1}`-free
graph with both parts of size `N` has at most `k * N` edges, and the circulant attains it. -/
theorem exBipParts_starGraph_eq {N k : ℕ} (h : k ≤ N) :
    exBipParts N N (starGraph (k + 1)) = k * N := by
  classical
  refine le_antisymm (by simpa using exBipParts_starGraph_le N N k) ?_
  have hfree : (starGraph (k + 1)).Free (bipCirculant N k) := by
    rw [starGraph_free_iff]
    rintro (v | v)
    · rw [bipCirculant_degree_left h]; omega
    · rw [bipCirculant_degree_right h]; omega
  have := card_edgeFinset_le_exBipParts hfree (bipCirculant_le_completeBipartiteGraph N k)
  rwa [card_edgeFinset_bipCirculant h] at this

/-- **Exact bipartite extremal number of a star on an even number of vertices.**
For `k ≤ N`, the maximum number of edges of a `K_{1,k+1}`-free bipartite graph on `2N`
vertices is `k * N`. -/
theorem exBip_starGraph_eq {N k : ℕ} (h : k ≤ N) :
    exBip (2 * N) (starGraph (k + 1)) = k * N := by
  refine le_antisymm ?_ ?_
  · have h2 := two_mul_exBip_starGraph_le (2 * N) k
    rw [show k * (2 * N) = 2 * (k * N) by ring] at h2
    omega
  · have h1 := exBipParts_le_exBip N N (starGraph (k + 1))
    rw [exBipParts_starGraph_eq h] at h1
    rw [two_mul]
    exact h1

/-- If the parts are small (`N ≤ k`) the complete bipartite graph itself is `K_{1,k+1}`-free,
so the fixed-part extremal number is `N ^ 2`. -/
theorem exBipParts_starGraph_eq_of_le {N k : ℕ} (h : N ≤ k) :
    exBipParts N N (starGraph (k + 1)) = N * N := by
  classical
  refine le_antisymm (by simpa using exBipParts_le_mul N N (starGraph (k + 1))) ?_
  have hdeg : ∀ v : Fin N ⊕ Fin N, (completeBipartiteGraph (Fin N) (Fin N)).degree v = N := by
    rintro (v | v)
    · rw [← card_neighborFinset_eq_degree,
        show (completeBipartiteGraph (Fin N) (Fin N)).neighborFinset (Sum.inl v)
          = Finset.univ.map ⟨Sum.inr, Sum.inr_injective⟩ by ext x; cases x <;> simp]
      simp
    · rw [← card_neighborFinset_eq_degree,
        show (completeBipartiteGraph (Fin N) (Fin N)).neighborFinset (Sum.inr v)
          = Finset.univ.map ⟨Sum.inl, Sum.inl_injective⟩ by ext x; cases x <;> simp]
      simp
  have hfree : (starGraph (k + 1)).Free (completeBipartiteGraph (Fin N) (Fin N)) := by
    rw [starGraph_free_iff]
    intro v
    rw [hdeg v]
    omega
  have hle := card_edgeFinset_le_exBipParts hfree (le_refl _)
  rwa [card_edgeFinset_completeBipartiteGraph] at hle

/-! ### The shifted construction and the general fixed-part star formula

For unbalanced parts the circulant is replaced by the *shifted interval* graph `bipShift`:
with `m ≤ n`, the left vertex `i` is joined to the `k` right vertices `i, i+1, …, i+k-1`
(indices modulo `n`).  Its left degrees are exactly `k` and its right degrees are at most `k`,
so it is `K_{1,k+1}`-free with `k * m` edges, matching the upper bound `k * min m n`. -/

/-- The shifted interval bipartite graph with parts `Fin m` and `Fin n`, `m ≤ n`. -/
def bipShift (m n k : ℕ) (h : m ≤ n) : SimpleGraph (Fin m ⊕ Fin n) where
  Adj x y := match x, y with
    | Sum.inl i, Sum.inr j => (j - Fin.castLE h i).val < k
    | Sum.inr j, Sum.inl i => (j - Fin.castLE h i).val < k
    | _, _ => False
  symm := by rintro (a | a) (b | b) hh <;> exact hh
  loopless := ⟨by rintro (a | a) hh <;> exact hh⟩

instance instDecidableAdjBipShift (m n k : ℕ) (h : m ≤ n) :
    DecidableRel (bipShift m n k h).Adj := by
  intro x y
  cases x <;> cases y <;> dsimp [bipShift] <;> infer_instance

theorem bipShift_le_completeBipartiteGraph (m n k : ℕ) (h : m ≤ n) :
    bipShift m n k h ≤ completeBipartiteGraph (Fin m) (Fin n) := by
  rintro (a | a) (b | b) hh <;> simp_all [bipShift, completeBipartiteGraph]

/-- Every left vertex of the shifted graph has degree exactly `k`. -/
theorem bipShift_degree_left {m n k : ℕ} (h : m ≤ n) (hk : k ≤ n) (i : Fin m) :
    (bipShift m n k h).degree (Sum.inl i) = k := by
  rw [← card_neighborFinset_eq_degree,
    show (bipShift m n k h).neighborFinset (Sum.inl i)
      = (univ.filter fun j : Fin n => (j - Fin.castLE h i).val < k).map
          ⟨Sum.inr, Sum.inr_injective⟩ by ext x; cases x <;> simp [bipShift]]
  rw [Finset.card_map, card_filter_sub_right_lt hk]

/-- Every right vertex of the shifted graph has degree at most `k`: its neighbourhood embeds,
via `Fin.castLE`, into the `k`-element set of residues `i` with `j - i < k`. -/
theorem bipShift_degree_right {m n k : ℕ} (h : m ≤ n) (hk : k ≤ n) (j : Fin n) :
    (bipShift m n k h).degree (Sum.inr j) ≤ k := by
  rw [← card_neighborFinset_eq_degree,
    show (bipShift m n k h).neighborFinset (Sum.inr j)
      = (univ.filter fun i : Fin m => (j - Fin.castLE h i).val < k).map
          ⟨Sum.inl, Sum.inl_injective⟩ by ext x; cases x <;> simp [bipShift]]
  rw [Finset.card_map]
  refine le_trans (Finset.card_le_card_of_injOn (fun i => Fin.castLE h i) ?_ ?_)
    (card_filter_sub_left_lt hk j).le
  · intro i hi
    simpa using hi
  · intro a _ b _ hab
    exact Fin.ext (by simpa using congrArg Fin.val hab)

/-- The shifted graph has exactly `k * m` edges. -/
theorem card_edgeFinset_bipShift {m n k : ℕ} (h : m ≤ n) (hk : k ≤ n) :
    #(bipShift m n k h).edgeFinset = k * m := by
  set L : Finset (Fin m ⊕ Fin n) := Finset.univ.map ⟨Sum.inl, Sum.inl_injective⟩ with hLdef
  set R : Finset (Fin m ⊕ Fin n) := Finset.univ.map ⟨Sum.inr, Sum.inr_injective⟩ with hRdef
  have hbw : (bipShift m n k h).IsBipartiteWith (L : Set (Fin m ⊕ Fin n))
      (R : Set (Fin m ⊕ Fin n)) := by
    constructor
    · rw [Set.disjoint_left]
      rintro (v | v) <;> simp [hLdef, hRdef]
    · rintro (v | v) (w | w) hadj <;> simp_all [bipShift]
  rw [← isBipartiteWith_sum_degrees_eq_card_edges hbw, hLdef, Finset.sum_map]
  simp [bipShift_degree_left h hk, Nat.mul_comm]

/-- **Exact fixed-part star number, unbalanced sparse regime.**  If `m ≤ n` and `k ≤ n` then a
`K_{1,k+1}`-free graph with parts of sizes `m` and `n` has at most `k * m` edges, and the
shifted graph attains this. -/
theorem exBipParts_starGraph_eq_mul_left {m n k : ℕ} (h : m ≤ n) (hk : k ≤ n) :
    exBipParts m n (starGraph (k + 1)) = k * m := by
  classical
  refine le_antisymm (by simpa [Nat.min_eq_left h] using exBipParts_starGraph_le m n k) ?_
  have hfree : (starGraph (k + 1)).Free (bipShift m n k h) := by
    rw [starGraph_free_iff]
    rintro (v | v)
    · rw [bipShift_degree_left h hk]; omega
    · have := bipShift_degree_right h hk v; omega
  have hle := card_edgeFinset_le_exBipParts hfree (bipShift_le_completeBipartiteGraph m n k h)
  rwa [card_edgeFinset_bipShift h hk] at hle

/-- **Exact fixed-part star number, dense regime.**  If both parts have size at most `k` then
the complete bipartite graph itself is `K_{1,k+1}`-free. -/
theorem exBipParts_starGraph_eq_mul {m n k : ℕ} (hm : m ≤ k) (hn : n ≤ k) :
    exBipParts m n (starGraph (k + 1)) = m * n := by
  classical
  refine le_antisymm (exBipParts_le_mul m n (starGraph (k + 1))) ?_
  have hdeg : ∀ v : Fin m ⊕ Fin n,
      (completeBipartiteGraph (Fin m) (Fin n)).degree v < k + 1 := by
    rintro (v | v)
    · rw [← card_neighborFinset_eq_degree,
        show (completeBipartiteGraph (Fin m) (Fin n)).neighborFinset (Sum.inl v)
          = Finset.univ.map ⟨Sum.inr, Sum.inr_injective⟩ by ext x; cases x <;> simp]
      simpa using Nat.lt_succ_of_le hn
    · rw [← card_neighborFinset_eq_degree,
        show (completeBipartiteGraph (Fin m) (Fin n)).neighborFinset (Sum.inr v)
          = Finset.univ.map ⟨Sum.inl, Sum.inl_injective⟩ by ext x; cases x <;> simp]
      simpa using Nat.lt_succ_of_le hm
  have hfree : (starGraph (k + 1)).Free (completeBipartiteGraph (Fin m) (Fin n)) :=
    (starGraph_free_iff _ _).mpr hdeg
  have hle := card_edgeFinset_le_exBipParts hfree (le_refl _)
  rwa [card_edgeFinset_completeBipartiteGraph] at hle

/-- **The complete fixed-part bipartite extremal number of every star.**  For all part sizes
`m, n` and all `k`,
`exBipParts m n K_{1,k+1} = min (k * min m n) (m * n)`,
i.e. the maximum number of edges of a bipartite graph with parts of sizes `m` and `n` and
maximum degree at most `k` is `min (k m) (k n) (m n)`.  This is the exact bipartite analogue of
the Zarankiewicz-type answer for stars, and settles the fixed-part star case in full. -/
theorem exBipParts_starGraph (m n k : ℕ) :
    exBipParts m n (starGraph (k + 1)) = min (k * min m n) (m * n) := by
  wlog hmn : m ≤ n generalizing m n
  · rw [exBipParts_comm, this n m (Nat.le_of_not_le hmn), Nat.min_comm n m, Nat.mul_comm n m]
  rcases le_or_gt k n with hk | hk
  · rw [exBipParts_starGraph_eq_mul_left hmn hk, Nat.min_eq_left hmn,
      Nat.min_eq_left (by rw [Nat.mul_comm]; exact Nat.mul_le_mul_left m hk)]
  · rw [exBipParts_starGraph_eq_mul (hmn.trans hk.le) hk.le, Nat.min_eq_left hmn,
      Nat.min_eq_right (by rw [Nat.mul_comm m n]; exact Nat.mul_le_mul_right m hk.le)]

/-! ### Matchings: the complete answer for `P₃ = K_{1,2}`

A `K_{1,2}`-free graph is a matching, and the perfect matching between the two parts is
extremal. -/

/-- The canonical matching between parts `Fin m` and `Fin n`. -/
def matchGraph (m n : ℕ) : SimpleGraph (Fin m ⊕ Fin n) where
  Adj x y := match x, y with
    | Sum.inl i, Sum.inr j => i.val = j.val
    | Sum.inr j, Sum.inl i => i.val = j.val
    | _, _ => False
  symm := by rintro (a | a) (b | b) h <;> exact h
  loopless := ⟨by rintro (a | a) h <;> exact h⟩

instance instDecidableAdjMatchGraph (m n : ℕ) : DecidableRel (matchGraph m n).Adj := by
  intro x y
  cases x <;> cases y <;> dsimp [matchGraph] <;> infer_instance

theorem matchGraph_le_completeBipartiteGraph (m n : ℕ) :
    matchGraph m n ≤ completeBipartiteGraph (Fin m) (Fin n) := by
  rintro (a | a) (b | b) h <;> simp_all [matchGraph, completeBipartiteGraph]

theorem matchGraph_degree_left {m n : ℕ} (i : Fin m) :
    (matchGraph m n).degree (Sum.inl i) = if i.val < n then 1 else 0 := by
  rw [← card_neighborFinset_eq_degree]
  by_cases h : i.val < n
  · rw [if_pos h,
      show (matchGraph m n).neighborFinset (Sum.inl i) = {Sum.inr ⟨i.val, h⟩} by
        ext x; cases x <;> simp [matchGraph, eq_comm, Fin.ext_iff]]
    simp
  · rw [if_neg h,
      show (matchGraph m n).neighborFinset (Sum.inl i) = ∅ by
        ext x; cases x <;> (simp [matchGraph]; try omega)]
    simp

theorem matchGraph_degree_right {m n : ℕ} (j : Fin n) :
    (matchGraph m n).degree (Sum.inr j) = if j.val < m then 1 else 0 := by
  rw [← card_neighborFinset_eq_degree]
  by_cases h : j.val < m
  · rw [if_pos h,
      show (matchGraph m n).neighborFinset (Sum.inr j) = {Sum.inl ⟨j.val, h⟩} by
        ext x; cases x <;> simp [matchGraph, eq_comm, Fin.ext_iff]]
    simp
  · rw [if_neg h,
      show (matchGraph m n).neighborFinset (Sum.inr j) = ∅ by
        ext x; cases x <;> (simp [matchGraph]; try omega)]
    simp

theorem card_edgeFinset_matchGraph (m n : ℕ) :
    #(matchGraph m n).edgeFinset = min m n := by
  set L : Finset (Fin m ⊕ Fin n) := Finset.univ.map ⟨Sum.inl, Sum.inl_injective⟩ with hLdef
  set R : Finset (Fin m ⊕ Fin n) := Finset.univ.map ⟨Sum.inr, Sum.inr_injective⟩ with hRdef
  have hbw : (matchGraph m n).IsBipartiteWith (L : Set (Fin m ⊕ Fin n))
      (R : Set (Fin m ⊕ Fin n)) := by
    constructor
    · rw [Set.disjoint_left]
      rintro (v | v) <;> simp [hLdef, hRdef]
    · rintro (v | v) (w | w) hadj <;> simp_all [matchGraph]
  rw [← isBipartiteWith_sum_degrees_eq_card_edges hbw, hLdef, Finset.sum_map]
  simp only [Function.Embedding.coeFn_mk, matchGraph_degree_left]
  rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const]
  simp only [smul_eq_mul, mul_one, mul_zero, add_zero]
  have := card_fin_filter_eq_range m (fun x => x < n)
  rw [show ((range m).filter fun x => x < n) = range (min m n) by ext x; simp] at this
  simpa using this

/-- **The fixed-part bipartite extremal number of `P₃ = K_{1,2}`** is `min m n`. -/
theorem exBipParts_starGraph_two (m n : ℕ) : exBipParts m n (starGraph 2) = min m n := by
  classical
  refine le_antisymm (by simpa using exBipParts_starGraph_le m n 1) ?_
  have hfree : (starGraph 2).Free (matchGraph m n) := by
    rw [starGraph_free_iff]
    rintro (v | v)
    · rw [matchGraph_degree_left]; split <;> omega
    · rw [matchGraph_degree_right]; split <;> omega
  have hle := card_edgeFinset_le_exBipParts hfree (matchGraph_le_completeBipartiteGraph m n)
  rwa [card_edgeFinset_matchGraph] at hle

/-! ### Lower bounds from the bipartition of `T`

If every proper `2`-colouring of `T` has both colour classes large, then the complete bipartite
graph with a small side is `T`-free, giving the natural linear lower-bound construction. -/

/-- **Colouring criterion for `T`-freeness of a complete bipartite host.**  If every proper
`2`-colouring of `T` has more than `a` vertices of one colour or more than `b` of the other,
then `K_{a,b}` contains no copy of `T`. -/
theorem free_completeBipartiteGraph_of_forall_coloring {W : Type*} [Fintype W] [DecidableEq W]
    {T : SimpleGraph W} {a b : ℕ}
    (h : ∀ c : W → Bool, (∀ v w, T.Adj v w → c v ≠ c w) →
        a < #(univ.filter fun v => c v = true) ∨ b < #(univ.filter fun v => c v = false)) :
    T.Free (completeBipartiteGraph (Fin a) (Fin b)) := by
  rintro ⟨f⟩
  have hproper : ∀ v w, T.Adj v w → (f v).isLeft ≠ (f w).isLeft := by
    intro v w hvw
    have hadj : (completeBipartiteGraph (Fin a) (Fin b)).Adj (f v) (f w) := f.toHom.map_adj hvw
    cases hfv : f v <;> cases hfw : f w <;> rw [hfv, hfw] at hadj <;>
      simp_all [completeBipartiteGraph]
  have hcardL : #(univ.filter fun x : Fin a ⊕ Fin b => x.isLeft = true) = a := by
    rw [show (univ.filter fun x : Fin a ⊕ Fin b => x.isLeft = true)
      = univ.map ⟨Sum.inl, Sum.inl_injective⟩ by ext x; cases x <;> simp]
    simp
  have hcardR : #(univ.filter fun x : Fin a ⊕ Fin b => x.isLeft = false) = b := by
    rw [show (univ.filter fun x : Fin a ⊕ Fin b => x.isLeft = false)
      = univ.map ⟨Sum.inr, Sum.inr_injective⟩ by ext x; cases x <;> simp]
    simp
  have hL0 : #(univ.filter fun v => (f v).isLeft = true)
      ≤ #(univ.filter fun x : Fin a ⊕ Fin b => x.isLeft = true) := by
    refine Finset.card_le_card_of_injOn f (fun v hv => ?_) (Set.injOn_of_injective f.injective)
    simpa using hv
  have hR0 : #(univ.filter fun v => (f v).isLeft = false)
      ≤ #(univ.filter fun x : Fin a ⊕ Fin b => x.isLeft = false) := by
    refine Finset.card_le_card_of_injOn f (fun v hv => ?_) (Set.injOn_of_injective f.injective)
    simpa using hv
  have hL := hL0.trans_eq hcardL
  have hR := hR0.trans_eq hcardR
  rcases h (fun v => (f v).isLeft) hproper with hh | hh <;> omega

/-- If `K_{a,b}` is `T`-free then it witnesses the lower bound `a * b` for the fixed-part
bipartite extremal number. -/
theorem mul_le_exBipParts_of_free {a b : ℕ}
    (h : T.Free (completeBipartiteGraph (Fin a) (Fin b))) : a * b ≤ exBipParts a b T := by
  have hcopy := card_edgeFinset_le_exBipParts (G := completeBipartiteGraph (Fin a) (Fin b)) h le_rfl
  rwa [card_edgeFinset_completeBipartiteGraph] at hcopy

/-- If `K_{a,b}` is `T`-free then it witnesses the lower bound `a * b` for the bipartite
extremal number on `a + b` vertices. -/
theorem mul_le_exBip_of_free {a b : ℕ}
    (h : T.Free (completeBipartiteGraph (Fin a) (Fin b))) : a * b ≤ exBip (a + b) T :=
  (mul_le_exBipParts_of_free h).trans (exBipParts_le_exBip a b T)

/-! ### Paths

The path on `p` vertices has colour classes of sizes `⌈p/2⌉` and `⌊p/2⌋`; consequently
`K_{⌊p/2⌋-1, n-⌊p/2⌋+1}` is `P_p`-free. -/

/-! ### Connected forbidden graphs: the general lower-bound construction

For a connected `T` the proper two-colouring is unique up to swapping the two colours, so the
sizes of the colour classes are an invariant of `T`.  If both classes have more than `s`
vertices then no complete bipartite graph with a part of size `s` can contain `T`; this is the
natural lower-bound construction of the bipartite Erdős–Sós problem, and in the fixed-part
setting it is even *optimal*. -/

/-- Two proper two-colourings of a graph agree along any walk, up to a global flip. -/
private lemma coloring_iff_along_walk {c c' : W → Bool}
    (hc : ∀ v w, T.Adj v w → c v ≠ c w) (hc' : ∀ v w, T.Adj v w → c' v ≠ c' w)
    {u v : W} (p : T.Walk u v) : (c u = c' u) ↔ (c v = c' v) := by
  induction p with
  | nil => exact Iff.rfl
  | @cons x y z hxy q ih =>
      refine Iff.trans ?_ ih
      have h1 : c y = !c x := by have := hc _ _ hxy; revert this; cases c x <;> cases c y <;> simp
      have h2 : c' y = !c' x := by
        have := hc' _ _ hxy; revert this; cases c' x <;> cases c' y <;> simp
      rw [h1, h2]
      cases c x <;> cases c' x <;> simp

/-- **A connected graph has an essentially unique proper two-colouring**: any two proper
two-colourings are equal, or complementary. -/
theorem coloring_unique_of_connected (hconn : T.Connected) {c c' : W → Bool}
    (hc : ∀ v w, T.Adj v w → c v ≠ c w) (hc' : ∀ v w, T.Adj v w → c' v ≠ c' w) :
    (∀ v, c v = c' v) ∨ (∀ v, c v = !c' v) := by
  obtain ⟨r⟩ := hconn.nonempty
  by_cases hr : c r = c' r
  · refine Or.inl fun v => ?_
    obtain ⟨p⟩ := hconn.preconnected r v
    exact (coloring_iff_along_walk hc hc' p).mp hr
  · refine Or.inr fun v => ?_
    obtain ⟨p⟩ := hconn.preconnected r v
    have hne : ¬ (c v = c' v) := fun h => hr ((coloring_iff_along_walk hc hc' p).mpr h)
    revert hne; cases c v <;> cases c' v <;> simp

/-- If `T` is connected and both colour classes of a proper two-colouring of `T` have more than
`s` vertices, then every complete bipartite graph with a part of size `s` is `T`-free. -/
theorem free_completeBipartiteGraph_of_connected [Fintype W] [DecidableEq W]
    (hconn : T.Connected) {c : W → Bool} (hc : ∀ v w, T.Adj v w → c v ≠ c w) {s : ℕ}
    (h1 : s < #(univ.filter fun v => c v = true))
    (h2 : s < #(univ.filter fun v => c v = false)) (b : ℕ) :
    T.Free (completeBipartiteGraph (Fin s) (Fin b)) := by
  refine free_completeBipartiteGraph_of_forall_coloring (fun c' hc' => Or.inl ?_)
  rcases coloring_unique_of_connected hconn hc hc' with hall | hall
  · have heq : (univ.filter fun v => c' v = true) = (univ.filter fun v => c v = true) := by
      ext v; simp [hall v]
    rw [heq]; exact h1
  · have heq : (univ.filter fun v => c' v = true) = (univ.filter fun v => c v = false) := by
      ext v
      simp only [mem_filter, mem_univ, true_and]
      constructor
      · intro h; rw [hall v, h]; rfl
      · intro h; have hv := hall v; rw [h] at hv; revert hv; cases c' v <;> simp
    rw [heq]; exact h2

/-- **General lower-bound construction for connected forbidden graphs.**  If `T` is connected
and some (equivalently, any) proper two-colouring of `T` has both colour classes of size more
than `s`, then `K_{s, n-s}` is `T`-free, so `s (n - s) ≤ exBip n T`. -/
theorem exBip_ge_of_connected [Fintype W] [DecidableEq W] (hconn : T.Connected)
    {c : W → Bool} (hc : ∀ v w, T.Adj v w → c v ≠ c w) {s n : ℕ}
    (h1 : s < #(univ.filter fun v => c v = true))
    (h2 : s < #(univ.filter fun v => c v = false)) (hsn : s ≤ n) :
    s * (n - s) ≤ exBip n T := by
  have hle := mul_le_exBip_of_free (T := T)
    (free_completeBipartiteGraph_of_connected hconn hc h1 h2 (n - s))
  rwa [show s + (n - s) = n by omega] at hle

/-- **Exact fixed-part extremal number in the narrow regime.**  If `T` is connected and both
colour classes of `T` have more than `m` vertices, then no `K_{1,·}`-type obstruction remains:
the complete bipartite host `K_{m,n}` is itself `T`-free, so `exBipParts m n T = m n` for every
`n`.  This is the fixed-part analogue of the lower-bound construction, and it is optimal. -/
theorem exBipParts_eq_mul_of_connected [Fintype W] [DecidableEq W] (hconn : T.Connected)
    {c : W → Bool} (hc : ∀ v w, T.Adj v w → c v ≠ c w) {m n : ℕ}
    (h1 : m < #(univ.filter fun v => c v = true))
    (h2 : m < #(univ.filter fun v => c v = false)) :
    exBipParts m n T = m * n :=
  le_antisymm (exBipParts_le_mul m n T)
    (mul_le_exBipParts_of_free (free_completeBipartiteGraph_of_connected hconn hc h1 h2 n))

private lemma card_range_filter_odd (p : ℕ) : #((range p).filter fun i => i % 2 = 1) = p / 2 := by
  induction p with
  | zero => simp
  | succ n ih =>
    rw [Finset.range_add_one, Finset.filter_insert]
    by_cases h : n % 2 = 1
    · rw [if_pos h, Finset.card_insert_of_notMem (by simp), ih]; omega
    · rw [if_neg h, ih]; omega

private lemma card_range_filter_even (p : ℕ) :
    #((range p).filter fun i => i % 2 = 0) = (p + 1) / 2 := by
  induction p with
  | zero => simp
  | succ n ih =>
    rw [Finset.range_add_one, Finset.filter_insert]
    by_cases h : n % 2 = 0
    · rw [if_pos h, Finset.card_insert_of_notMem (by simp), ih]; omega
    · rw [if_neg h, ih]; omega

/-- A proper `2`-colouring of a path alternates. -/
theorem pathGraph_coloring_val {p : ℕ} (c : Fin p → Bool)
    (hc : ∀ v w, (pathGraph p).Adj v w → c v ≠ c w) (h0 : 0 < p) :
    ∀ (i : ℕ) (hi : i < p), c ⟨i, hi⟩ = xor (c ⟨0, h0⟩) (decide (i % 2 = 1)) := by
  intro i
  induction i with
  | zero => intro hi; simp
  | succ n ih =>
    intro hi
    have hn : n < p := by omega
    have hadj : (pathGraph p).Adj ⟨n, hn⟩ ⟨n + 1, hi⟩ := by rw [pathGraph_adj]; left; rfl
    have hne := hc _ _ hadj
    have hih := ih hn
    have hpar : (n + 1) % 2 = 1 ↔ ¬ (n % 2 = 1) := by omega
    revert hne hih
    cases hc0 : c ⟨0, h0⟩ <;> cases hcn : c ⟨n, hn⟩ <;> cases hcn1 : c ⟨n + 1, hi⟩ <;>
      simp_all

/-- Both colour classes of a proper `2`-colouring of `P_p` have at least `⌊p/2⌋` vertices. -/
theorem pathGraph_class_size {p : ℕ} (c : Fin p → Bool)
    (hc : ∀ v w, (pathGraph p).Adj v w → c v ≠ c w) (h0 : 0 < p) :
    p / 2 ≤ #(univ.filter fun i => c i = true) ∧ p / 2 ≤ #(univ.filter fun i => c i = false) := by
  have key : ∀ i : Fin p, c i = xor (c ⟨0, h0⟩) (decide (i.val % 2 = 1)) := by
    intro i
    simpa using pathGraph_coloring_val c hc h0 i.val i.isLt
  have h1 := card_fin_filter_eq_range p (fun x => x % 2 = 1)
  have h2 := card_fin_filter_eq_range p (fun x => x % 2 = 0)
  rw [card_range_filter_odd] at h1
  rw [card_range_filter_even] at h2
  cases hc0 : c ⟨0, h0⟩
  · have e1 : (univ.filter fun i : Fin p => c i = true)
        = univ.filter fun i : Fin p => i.val % 2 = 1 := by ext i; simp [key i, hc0]
    have e2 : (univ.filter fun i : Fin p => c i = false)
        = univ.filter fun i : Fin p => i.val % 2 = 0 := by ext i; simp [key i, hc0]
    rw [e1, e2]
    omega
  · have e1 : (univ.filter fun i : Fin p => c i = true)
        = univ.filter fun i : Fin p => i.val % 2 = 0 := by ext i; simp [key i, hc0]
    have e2 : (univ.filter fun i : Fin p => c i = false)
        = univ.filter fun i : Fin p => i.val % 2 = 1 := by ext i; simp [key i, hc0]
    rw [e1, e2]
    omega

/-- **The complete bipartite graph `K_{a,b}` with `a < ⌊p/2⌋` contains no path on `p`
vertices.** -/
theorem pathGraph_free_completeBipartiteGraph {p a b : ℕ} (ha : a < p / 2) :
    (pathGraph p).Free (completeBipartiteGraph (Fin a) (Fin b)) := by
  refine free_completeBipartiteGraph_of_forall_coloring fun c hproper => ?_
  have h0 : 0 < p := by omega
  obtain ⟨h1, _⟩ := pathGraph_class_size c hproper h0
  exact Or.inl (by omega)

/-- **Linear lower bound for the bipartite extremal number of a path.**  For `2 ≤ p` and
`n ≥ ⌊p/2⌋ - 1`, the complete bipartite graph `K_{⌊p/2⌋-1, n-⌊p/2⌋+1}` is `P_p`-free. -/
theorem exBip_pathGraph_lower_bound {p n : ℕ} (hp : 2 ≤ p) (hn : p / 2 - 1 ≤ n) :
    (p / 2 - 1) * (n - (p / 2 - 1)) ≤ exBip n (pathGraph p) := by
  have ha : p / 2 - 1 < p / 2 := by omega
  have := mul_le_exBip_of_free (T := pathGraph p)
    (pathGraph_free_completeBipartiteGraph (a := p / 2 - 1) (b := n - (p / 2 - 1)) ha)
  rwa [show p / 2 - 1 + (n - (p / 2 - 1)) = n by omega] at this

/-- **Exact fixed-part bipartite extremal number of a path in the narrow regime.**  If one part
has fewer than `⌊p/2⌋` vertices, the complete bipartite host is itself `P_p`-free, so
`exBipParts m n P_p = m n` for every `n`.  (E.g. `exBipParts 2 n P₆ = 2n`.) -/
theorem exBipParts_pathGraph_eq_mul {p m n : ℕ} (hm : m < p / 2) :
    exBipParts m n (pathGraph p) = m * n :=
  le_antisymm (exBipParts_le_mul m n _)
    (mul_le_exBipParts_of_free (pathGraph_free_completeBipartiteGraph hm))

/-- The bipartite extremal number of the path on four vertices is at least `n - 1`:
the star `K_{1,n-1}` is `P_4`-free. -/
theorem exBip_pathGraph_four_lower_bound (n : ℕ) (hn : 1 ≤ n) :
    n - 1 ≤ exBip n (pathGraph 4) := by
  have := exBip_pathGraph_lower_bound (p := 4) (n := n) (by norm_num) (by omega)
  simpa using this

/-! ### Relating the two extremal functions

The order-only bipartite extremal number is the maximum of the fixed-part ones over all
splittings of `n`. -/

/-- Every bipartite `T`-free graph on `n` vertices arises, after relabelling, as a graph with
parts of sizes `m` and `n - m` for some `m ≤ n`. -/
theorem exBip_le_sup_exBipParts (n : ℕ) (T : SimpleGraph W) :
    exBip n T ≤ (range (n + 1)).sup fun m => exBipParts m (n - m) T := by
  classical
  rw [exBip_le_iff]
  intro G hfree hbip
  obtain ⟨s, t, hst⟩ := hbip.exists_isBipartiteWith
  set S : Set (Fin n) := s with hS
  set m := Fintype.card S with hm
  have hmn : m ≤ n := by
    have h := Fintype.card_le_of_injective (Subtype.val : S → Fin n) Subtype.val_injective
    rwa [Fintype.card_fin] at h
  have hcompl : Fintype.card (Sᶜ : Set (Fin n)) = n - m := by
    rw [Fintype.card_compl_set, Fintype.card_fin]
  let eA := Fintype.equivFinOfCardEq (rfl : Fintype.card S = m)
  let eB := Fintype.equivFinOfCardEq hcompl
  let e : Fin n ≃ Fin m ⊕ Fin (n - m) :=
    (Equiv.Set.sumCompl S).symm.trans (Equiv.sumCongr eA eB)
  have hleft : ∀ x : Fin n, x ∈ S → (e x).isLeft := by
    intro x hx; simp [e, Equiv.Set.sumCompl_symm_apply_of_mem hx]
  have hright : ∀ x : Fin n, x ∉ S → (e x).isRight := by
    intro x hx; simp [e, Equiv.Set.sumCompl_symm_apply_of_notMem hx]
  set G' : SimpleGraph (Fin m ⊕ Fin (n - m)) := G.map e.toEmbedding with hG'
  let iso : G ≃g G' := SimpleGraph.Iso.map e G
  have hcard : #G'.edgeFinset = #G.edgeFinset := iso.card_edgeFinset_eq.symm
  have hfree' : T.Free G' := (free_congr (Iso.refl) iso).mp hfree
  have hsub : G' ≤ completeBipartiteGraph (Fin m) (Fin (n - m)) := by
    rintro x y hxy
    obtain ⟨u, v, huv, hu, hv⟩ := hxy
    have hdisj := hst.disjoint
    rcases hst.mem_of_adj huv with ⟨hus, hvt⟩ | ⟨hut, hvs⟩
    · have hvn : v ∉ S := fun hv' => (Set.disjoint_left.mp hdisj hv') hvt
      subst hu; subst hv
      exact Or.inl ⟨hleft u hus, hright v hvn⟩
    · have hun : u ∉ S := fun hu' => (Set.disjoint_left.mp hdisj hu') hut
      subst hu; subst hv
      exact Or.inr ⟨hright u hun, hleft v hvs⟩
  have hle := card_edgeFinset_le_exBipParts hfree' hsub
  rw [hcard] at hle
  exact hle.trans (Finset.le_sup (f := fun m => exBipParts m (n - m) T)
    (Finset.mem_range.mpr (by omega)))

/-- **The order-only bipartite extremal number is the maximum of the fixed-part ones.** -/
theorem exBip_eq_sup_exBipParts (n : ℕ) (T : SimpleGraph W) :
    exBip n T = (range (n + 1)).sup fun m => exBipParts m (n - m) T := by
  refine le_antisymm (exBip_le_sup_exBipParts n T) (Finset.sup_le fun m hm => ?_)
  have hmn : m ≤ n := by simpa [Nat.lt_succ_iff] using Finset.mem_range.mp hm
  have := exBipParts_le_exBip m (n - m) T
  rwa [show m + (n - m) = n by omega] at this

/-! ### The complete order-only star formula

Combining the fixed-part formula `exBipParts_starGraph` with the decomposition
`exBip_eq_sup_exBipParts` solves the order-only star problem for *all* orders `n` and all `k`,
including the odd orders where the naive bound `⌊k n / 2⌋` is not attained. -/

/-- Elementary rearrangement: if `a + b = q + c` with `a ≤ q ≤ c`, then `a * b ≤ q * c`. -/
private lemma mul_le_mul_of_add_eq {a b q c : ℕ} (hsum : a + b = q + c) (h1 : a ≤ q)
    (h2 : q ≤ c) : a * b ≤ q * c := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le h1
  have hb : b = d + c := by omega
  subst hb
  have hac : a ≤ c := h1.trans h2
  nlinarith

/-- The product `m (n - m)` is maximised at the balanced splitting. -/
private lemma mul_sub_le_half_mul_half {n m : ℕ} (hm : m ≤ n) :
    m * (n - m) ≤ (n / 2) * (n - n / 2) := by
  have key : min m (n - m) * max m (n - m) ≤ (n / 2) * (n - n / 2) :=
    mul_le_mul_of_add_eq (by omega) (by omega) (by omega)
  rcases le_total m (n - m) with h | h
  · rwa [min_eq_left h, max_eq_right h] at key
  · rwa [min_eq_right h, max_eq_left h, Nat.mul_comm] at key

/-- **The complete bipartite extremal number of every star, for every order.**
For all `n` and `k`,
`exBip n K_{1,k+1} = min (k ⌊n/2⌋) (⌊n/2⌋ ⌈n/2⌉)`.
Equivalently: the maximum number of edges of a bipartite graph on `n` vertices with maximum
degree at most `k` is `k⌊n/2⌋` in the sparse regime `2k ≤ n`, and the complete balanced
bipartite value `⌊n/2⌋⌈n/2⌉` otherwise.  In particular the parity obstruction visible for odd
`n` (e.g. `exBip 5 K_{1,3} = 4 < 5 = ⌊k n / 2⌋`) is explained: the true answer is `k⌊n/2⌋`,
not `⌊kn/2⌋`. -/
theorem exBip_starGraph (n k : ℕ) :
    exBip n (starGraph (k + 1)) = min (k * (n / 2)) ((n / 2) * (n - n / 2)) := by
  rw [exBip_eq_sup_exBipParts]
  refine le_antisymm (Finset.sup_le fun m hm => ?_) ?_
  · have hmn : m ≤ n := by simpa [Nat.lt_succ_iff] using Finset.mem_range.mp hm
    rw [exBipParts_starGraph]
    refine le_min ?_ ?_
    · have h1 : min m (n - m) ≤ n / 2 := by omega
      exact le_trans (min_le_left _ _) (Nat.mul_le_mul_left k h1)
    · exact le_trans (min_le_right _ _) (mul_sub_le_half_mul_half hmn)
  · refine le_trans ?_ (Finset.le_sup
      (f := fun m => exBipParts m (n - m) (starGraph (k + 1)))
      (Finset.mem_range.mpr (show n / 2 < n + 1 by omega)))
    show min (k * (n / 2)) ((n / 2) * (n - n / 2))
      ≤ exBipParts (n / 2) (n - n / 2) (starGraph (k + 1))
    rw [exBipParts_starGraph, show min (n / 2) (n - n / 2) = n / 2 by omega]

/-- **Sparse regime.**  If `2k ≤ n` then `exBip n K_{1,k+1} = k ⌊n/2⌋`, for every parity of `n`.
This strictly generalises `exBip_starGraph_eq`, which is the even case `n = 2N`. -/
theorem exBip_starGraph_of_two_mul_le {n k : ℕ} (h : 2 * k ≤ n) :
    exBip n (starGraph (k + 1)) = k * (n / 2) := by
  rw [exBip_starGraph, Nat.min_eq_left]
  rw [Nat.mul_comm]
  exact Nat.mul_le_mul_left (n / 2) (by omega)

/-- **Dense regime.**  If `n ≤ 2k` then the balanced complete bipartite graph is `K_{1,k+1}`-free
and `exBip n K_{1,k+1} = ⌊n/2⌋⌈n/2⌉`. -/
theorem exBip_starGraph_of_le_two_mul {n k : ℕ} (h : n ≤ 2 * k) :
    exBip n (starGraph (k + 1)) = (n / 2) * (n - n / 2) := by
  rw [exBip_starGraph, Nat.min_eq_right]
  rw [Nat.mul_comm k]
  exact Nat.mul_le_mul_left _ (by omega)

/-! ### The exact bipartite extremal number of `P₄`

A bipartite `P₄`-free graph is a disjoint union of stars; we prove the resulting sharp bound
`exBip n P₄ = n - 1` for `n ≥ 2` by a degree argument. -/

/-- Four vertices forming a path give a copy of `P₄`. -/
theorem pathGraph_four_isContained {V : Type*} (G : SimpleGraph V) {x u v y : V}
    (hxu : G.Adj x u) (huv : G.Adj u v) (hvy : G.Adj v y)
    (hxv : x ≠ v) (hxy : x ≠ y) (huy : u ≠ y) :
    pathGraph 4 ⊑ G := by
  have hxu' : x ≠ u := hxu.ne
  have huv' : u ≠ v := huv.ne
  have hvy' : v ≠ y := hvy.ne
  refine ⟨⟨⟨![x, u, v, y], ?_⟩, ?_⟩⟩
  · intro a b hab
    rw [pathGraph_adj] at hab
    fin_cases a <;> fin_cases b <;> simp_all [hxu.symm, huv.symm, hvy.symm]
  · intro a b hab
    fin_cases a <;> fin_cases b <;> simp_all

/-- In a bipartite `P₄`-free graph every edge has an endpoint of degree one. -/
theorem exists_degree_one_endpoint {V : Type*} [Fintype V] [DecidableEq V] {G : SimpleGraph V}
    [DecidableRel G.Adj] (hbip : G.IsBipartite) (hfree : (pathGraph 4).Free G)
    {u v : V} (huv : G.Adj u v) : G.degree u = 1 ∨ G.degree v = 1 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨h1, h2⟩ := hcon
  have hu1 : 1 ≤ G.degree u := by
    rw [← card_neighborFinset_eq_degree]
    exact Finset.card_pos.mpr ⟨v, by simpa using huv⟩
  have hv1 : 1 ≤ G.degree v := by
    rw [← card_neighborFinset_eq_degree]
    exact Finset.card_pos.mpr ⟨u, by simpa using huv.symm⟩
  have hu2 : 1 < #(G.neighborFinset u) := by
    rw [card_neighborFinset_eq_degree]; omega
  have hv2 : 1 < #(G.neighborFinset v) := by
    rw [card_neighborFinset_eq_degree]; omega
  obtain ⟨x, hx, hxv⟩ := Finset.exists_mem_ne hu2 v
  obtain ⟨y, hy, hyu⟩ := Finset.exists_mem_ne hv2 u
  rw [mem_neighborFinset] at hx hy
  have hxy : x ≠ y := by
    rintro rfl
    obtain ⟨c⟩ := hbip
    have e1 := c.valid huv
    have e2 := c.valid hx
    have e3 := c.valid hy
    have b1 := (c u).isLt
    have b2 := (c v).isLt
    have b3 := (c x).isLt
    rw [Fin.ne_iff_vne] at e1 e2 e3
    omega
  exact hfree (pathGraph_four_isContained G hx.symm huv hy hxv hxy hyu.symm)

/-- If every edge has an endpoint of degree one, then the number of edges is at most the number
of vertices of degree one. -/
theorem card_edgeFinset_le_card_degree_one {V : Type*} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} [DecidableRel G.Adj]
    (h : ∀ {u v}, G.Adj u v → G.degree u = 1 ∨ G.degree v = 1) :
    #G.edgeFinset ≤ #(univ.filter fun v => G.degree v = 1) := by
  classical
  set D := univ.filter (fun v => G.degree v = 1) with hD
  have hcover : G.edgeFinset ⊆ D.biUnion (fun v => G.incidenceFinset v) := by
    intro e
    induction e using Sym2.ind with
    | _ u v =>
      intro he
      rw [mem_edgeFinset, mem_edgeSet] at he
      rcases h he with hu | hv
      · exact Finset.mem_biUnion.mpr ⟨u, by simp [hD, hu],
          by simp [SimpleGraph.incidenceFinset, SimpleGraph.incidenceSet, he]⟩
      · exact Finset.mem_biUnion.mpr ⟨v, by simp [hD, hv],
          by simp [SimpleGraph.incidenceFinset, SimpleGraph.incidenceSet, he]⟩
  calc #G.edgeFinset ≤ #(D.biUnion (fun v => G.incidenceFinset v)) := Finset.card_le_card hcover
    _ ≤ ∑ v ∈ D, #(G.incidenceFinset v) := Finset.card_biUnion_le
    _ = ∑ v ∈ D, G.degree v := by simp [card_incidenceFinset_eq_degree]
    _ = #D := by
        rw [Finset.sum_congr rfl (fun v hv => (Finset.mem_filter.mp hv).2)]
        simp [hD]

/-- **Upper bound**: a bipartite `P₄`-free graph on `n ≥ 2` vertices has at most `n - 1`
edges. -/
theorem exBip_pathGraph_four_le {n : ℕ} (hn : 2 ≤ n) : exBip n (pathGraph 4) ≤ n - 1 := by
  classical
  rw [exBip_le_iff]
  intro G hfree hbip
  have hedge : ∀ {u v}, G.Adj u v → G.degree u = 1 ∨ G.degree v = 1 := fun huv =>
    exists_degree_one_endpoint hbip hfree huv
  have hcard := card_edgeFinset_le_card_degree_one hedge
  set D := univ.filter (fun v : Fin n => G.degree v = 1) with hD
  by_cases hall : D = univ
  · have hdeg : ∀ v, G.degree v = 1 := by
      intro v
      have hv : v ∈ D := hall ▸ mem_univ v
      simpa [hD] using hv
    have hsum := SimpleGraph.sum_degrees_eq_twice_card_edges G
    rw [Finset.sum_congr rfl (fun v _ => hdeg v)] at hsum
    simp at hsum
    omega
  · have hlt : #D < n := by
      have hss : D ⊂ univ := (Finset.ssubset_iff_subset_ne).mpr ⟨Finset.subset_univ _, hall⟩
      have := Finset.card_lt_card hss
      simpa using this
    omega

/-- **The exact bipartite extremal number of the path on four vertices.**  For `n ≥ 2` the
maximum number of edges of a bipartite `P₄`-free graph on `n` vertices is `n - 1`, attained by
the star `K_{1,n-1}`. -/
theorem exBip_pathGraph_four {n : ℕ} (hn : 2 ≤ n) : exBip n (pathGraph 4) = n - 1 :=
  le_antisymm (exBip_pathGraph_four_le hn) (exBip_pathGraph_four_lower_bound n (by omega))

/-- **The exact bipartite extremal number of `P₃ = K_{1,2}` for every order**: the extremal
graph is a maximum matching. -/
theorem exBip_starGraph_two (n : ℕ) : exBip n (starGraph 2) = n / 2 := by
  rw [exBip_eq_sup_exBipParts]
  refine le_antisymm (Finset.sup_le fun m hm => ?_) ?_
  · have hmn : m ≤ n := by simpa [Nat.lt_succ_iff] using Finset.mem_range.mp hm
    rw [exBipParts_starGraph_two]
    omega
  · have hmem : n / 2 ∈ range (n + 1) := Finset.mem_range.mpr (by omega)
    refine le_trans ?_ (Finset.le_sup (f := fun m => exBipParts m (n - m) (starGraph 2)) hmem)
    show n / 2 ≤ exBipParts (n / 2) (n - n / 2) (starGraph 2)
    rw [exBipParts_starGraph_two]
    omega

end Catalog.Combinatorics.BipartiteExtremalTrees