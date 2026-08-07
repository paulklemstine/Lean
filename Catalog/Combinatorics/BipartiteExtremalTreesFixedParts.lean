/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Combinatorics.BipartiteExtremalTrees

/-! # The fixed-part bipartite extremal number of `P₄`

This file continues `Catalog/Combinatorics/BipartiteExtremalTrees.lean`, where the order-only
value `exBip n P₄ = n - 1` (`exBip_pathGraph_four`) was determined.  Here we settle the
**fixed-part** problem for `P₄` completely:

* `pathGraph_four_free_iff_forall_degree_one`: a graph is `P₄`-free **iff** every edge has an
  endpoint of degree one.  (The `→` direction of the bipartite version was
  `exists_degree_one_endpoint`; the `←` direction, proved here, needs no bipartiteness and is
  what turns the criterion into a tool for building extremal graphs.)
* `twoStars`: the disjoint union of a star centred in the left part and a star centred in the
  right part, the extremal construction.
* `exBipParts_pathGraph_four`: `exBipParts m n P₄ = m + n - 2` whenever `2 ≤ m` and `2 ≤ n`.
* `exBipParts_pathGraph_four_formula`: the complete answer for all `m, n`, namely
  `exBipParts m n P₄ = if min m n ≤ 1 then m * n else m + n - 2`.
* `exBip_pathGraph_four_eq_sup`: consistency with the decomposition theorem — maximising
  `m + (n - m) - 2` over the splittings of `n` returns exactly `n - 1`, the order-only value,
  the maximum being attained at the *unbalanced* splitting `m = 1`.

The last point is a genuinely informative phenomenon: for `P₄` the fixed-part optimum
`m + n - 2` is *smaller* than the order-only optimum for every balanced splitting, and the
order-only extremal graph is forced to be maximally unbalanced (a single star).
-/

namespace Catalog.Combinatorics.BipartiteExtremalTrees

open Finset Fintype SimpleGraph

/-! ### A degree characterisation of `P₄`-freeness -/

/-- **If every edge has an endpoint of degree one, the graph is `P₄`-free.**  This is the
converse of `exists_degree_one_endpoint`, and unlike it needs no bipartiteness hypothesis. -/
theorem pathGraph_four_free_of_forall_degree_one {V : Type*} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} [DecidableRel G.Adj]
    (h : ∀ {u v : V}, G.Adj u v → G.degree u = 1 ∨ G.degree v = 1) :
    (pathGraph 4).Free G := by
  rintro ⟨f⟩
  have hadj : ∀ {a b : Fin 4}, (pathGraph 4).Adj a b → G.Adj (f a) (f b) := fun hab =>
    f.toHom.map_adj hab
  have h01 : (pathGraph 4).Adj 0 1 := by simp [pathGraph_adj]
  have h12 : (pathGraph 4).Adj 1 2 := by simp [pathGraph_adj]
  have h23 : (pathGraph 4).Adj 2 3 := by simp [pathGraph_adj]
  -- the two middle vertices of the path both have degree at least two in `G`
  have key : ∀ {a b c : Fin 4}, (pathGraph 4).Adj a b → (pathGraph 4).Adj b c → a ≠ c →
      2 ≤ G.degree (f b) := by
    intro a b c hab hbc hac
    rw [← card_neighborFinset_eq_degree]
    refine Finset.one_lt_card.mpr ⟨f a, ?_, f c, ?_, ?_⟩
    · exact (mem_neighborFinset ..).mpr (hadj hab).symm
    · exact (mem_neighborFinset ..).mpr (hadj hbc)
    · exact fun hcon => hac (f.injective hcon)
  have hd1 : 2 ≤ G.degree (f 1) := key h01 h12 (by decide)
  have hd2 : 2 ≤ G.degree (f 2) := key h12 h23 (by decide)
  rcases h (hadj h12) with hc | hc <;> omega

/-- **`P₄`-freeness is exactly the statement that every edge has an endpoint of degree one**, for
bipartite graphs.  (Only the forward implication needs bipartiteness.) -/
theorem pathGraph_four_free_iff_forall_degree_one {V : Type*} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} [DecidableRel G.Adj] (hbip : G.IsBipartite) :
    (pathGraph 4).Free G ↔ ∀ {u v : V}, G.Adj u v → G.degree u = 1 ∨ G.degree v = 1 :=
  ⟨fun hfree _ _ huv => exists_degree_one_endpoint hbip hfree huv,
    pathGraph_four_free_of_forall_degree_one⟩

/-! ### The extremal construction: two disjoint stars -/

/-- The disjoint union of the star centred at the first left vertex (joined to all right
vertices but the first) and the star centred at the first right vertex (joined to all left
vertices but the first). -/
def twoStars (m n : ℕ) : SimpleGraph (Fin m ⊕ Fin n) where
  Adj x y := match x, y with
    | Sum.inl i, Sum.inr j => (i.val = 0 ∧ j.val ≠ 0) ∨ (i.val ≠ 0 ∧ j.val = 0)
    | Sum.inr j, Sum.inl i => (i.val = 0 ∧ j.val ≠ 0) ∨ (i.val ≠ 0 ∧ j.val = 0)
    | _, _ => False
  symm := by rintro (a | a) (b | b) h <;> exact h
  loopless := ⟨by rintro (a | a) h <;> exact h⟩

instance instDecidableAdjTwoStars (m n : ℕ) : DecidableRel (twoStars m n).Adj := by
  intro x y
  cases x <;> cases y <;> dsimp [twoStars] <;> infer_instance

theorem twoStars_le_completeBipartiteGraph (m n : ℕ) :
    twoStars m n ≤ completeBipartiteGraph (Fin m) (Fin n) := by
  rintro (a | a) (b | b) h <;> simp_all [twoStars, completeBipartiteGraph]

theorem twoStars_degree_left {m n : ℕ} (hn : 0 < n) (i : Fin m) :
    (twoStars m n).degree (Sum.inl i) = if i.val = 0 then n - 1 else 1 := by
  rw [← card_neighborFinset_eq_degree]
  by_cases hi : i.val = 0
  · rw [if_pos hi,
      show (twoStars m n).neighborFinset (Sum.inl i)
        = (univ.erase (⟨0, hn⟩ : Fin n)).map ⟨Sum.inr, Sum.inr_injective⟩ by
          ext x; cases x <;> simp [twoStars, hi, Fin.ext_iff]]
    rw [Finset.card_map, Finset.card_erase_of_mem (mem_univ _)]
    simp
  · rw [if_neg hi,
      show (twoStars m n).neighborFinset (Sum.inl i)
        = {Sum.inr (⟨0, hn⟩ : Fin n)} by
          ext x; cases x <;> simp [twoStars, hi, Fin.ext_iff]]
    simp

theorem twoStars_degree_right {m n : ℕ} (hm : 0 < m) (j : Fin n) :
    (twoStars m n).degree (Sum.inr j) = if j.val = 0 then m - 1 else 1 := by
  rw [← card_neighborFinset_eq_degree]
  by_cases hj : j.val = 0
  · rw [if_pos hj,
      show (twoStars m n).neighborFinset (Sum.inr j)
        = (univ.erase (⟨0, hm⟩ : Fin m)).map ⟨Sum.inl, Sum.inl_injective⟩ by
          ext x; cases x <;> simp [twoStars, hj, Fin.ext_iff]]
    rw [Finset.card_map, Finset.card_erase_of_mem (mem_univ _)]
    simp
  · rw [if_neg hj,
      show (twoStars m n).neighborFinset (Sum.inr j)
        = {Sum.inl (⟨0, hm⟩ : Fin m)} by
          ext x; cases x <;> simp [twoStars, hj, Fin.ext_iff]]
    simp

/-- The two-star graph is `P₄`-free: every edge has a leaf endpoint. -/
theorem twoStars_free_pathGraph_four {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    (pathGraph 4).Free (twoStars m n) := by
  refine pathGraph_four_free_of_forall_degree_one ?_
  rintro (i | j) (i' | j') hadj
  · exact absurd hadj (by simp [twoStars])
  · rcases (by simpa [twoStars] using hadj : (i.val = 0 ∧ j'.val ≠ 0) ∨ (i.val ≠ 0 ∧ j'.val = 0))
      with ⟨_, h2⟩ | ⟨h1, _⟩
    · exact Or.inr (by rw [twoStars_degree_right hm, if_neg h2])
    · exact Or.inl (by rw [twoStars_degree_left hn, if_neg h1])
  · rcases (by simpa [twoStars] using hadj : (i'.val = 0 ∧ j.val ≠ 0) ∨ (i'.val ≠ 0 ∧ j.val = 0))
      with ⟨_, h2⟩ | ⟨h1, _⟩
    · exact Or.inl (by rw [twoStars_degree_right hm, if_neg h2])
    · exact Or.inr (by rw [twoStars_degree_left hn, if_neg h1])
  · exact absurd hadj (by simp [twoStars])

theorem card_edgeFinset_twoStars {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    #(twoStars m n).edgeFinset = m + n - 2 := by
  classical
  set L : Finset (Fin m ⊕ Fin n) := Finset.univ.map ⟨Sum.inl, Sum.inl_injective⟩ with hLdef
  set R : Finset (Fin m ⊕ Fin n) := Finset.univ.map ⟨Sum.inr, Sum.inr_injective⟩ with hRdef
  have hbw : (twoStars m n).IsBipartiteWith (L : Set (Fin m ⊕ Fin n))
      (R : Set (Fin m ⊕ Fin n)) := by
    constructor
    · rw [Set.disjoint_left]
      rintro (v | v) <;> simp [hLdef, hRdef]
    · rintro (v | v) (w | w) hadj <;> simp_all [twoStars]
  rw [← isBipartiteWith_sum_degrees_eq_card_edges hbw, hLdef, Finset.sum_map]
  simp only [Function.Embedding.coeFn_mk, twoStars_degree_left hn]
  rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const]
  have h1 : #(univ.filter fun i : Fin m => i.val = 0) = 1 := by
    rw [show (univ.filter fun i : Fin m => i.val = 0) = {(⟨0, hm⟩ : Fin m)} by
      ext i; simp [Fin.ext_iff]]
    simp
  have h2 : #(univ.filter fun i : Fin m => ¬ i.val = 0) = m - 1 := by
    rw [show (univ.filter fun i : Fin m => ¬ i.val = 0) = univ.erase (⟨0, hm⟩ : Fin m) by
      ext i; simp [Fin.ext_iff]]
    rw [Finset.card_erase_of_mem (mem_univ _)]
    simp
  rw [h1, h2]
  simp only [smul_eq_mul, mul_one, one_mul]
  omega

/-! ### The exact fixed-part value -/

/-- In a graph with parts of sizes `m` and `n`, every degree is at most `max m n`. -/
theorem degree_le_of_le_completeBipartiteGraph {m n : ℕ} {G : SimpleGraph (Fin m ⊕ Fin n)}
    [DecidableRel G.Adj] (hsub : G ≤ completeBipartiteGraph (Fin m) (Fin n)) :
    ∀ v, G.degree v ≤ max m n := by
  classical
  rintro (i | j)
  · rw [← card_neighborFinset_eq_degree]
    refine le_trans (Finset.card_le_card (t := Finset.univ.map ⟨Sum.inr, Sum.inr_injective⟩) ?_)
      (by simp)
    rintro (x | x) hx
    · have := hsub ((mem_neighborFinset ..).mp hx)
      simp [completeBipartiteGraph] at this
    · simp
  · rw [← card_neighborFinset_eq_degree]
    refine le_trans (Finset.card_le_card (t := Finset.univ.map ⟨Sum.inl, Sum.inl_injective⟩) ?_)
      (by simp)
    rintro (x | x) hx
    · simp
    · have := hsub ((mem_neighborFinset ..).mp hx)
      simp [completeBipartiteGraph] at this

/-- A graph contained in `K_{m,n}` is bipartite. -/
theorem isBipartite_of_le_completeBipartiteGraph {m n : ℕ} {G : SimpleGraph (Fin m ⊕ Fin n)}
    (hsub : G ≤ completeBipartiteGraph (Fin m) (Fin n)) : G.IsBipartite := by
  refine ⟨⟨Sum.elim (fun _ => (0 : Fin 2)) (fun _ => (1 : Fin 2)), ?_⟩⟩
  rintro (a | a) (b | b) hadj <;> have := hsub hadj <;>
    simp_all [completeBipartiteGraph]

/-- **Upper bound.**  A `P₄`-free graph with parts of sizes `m, n ≥ 2` has at most `m + n - 2`
edges.  The proof is a degree count: `P₄`-freeness forces every edge to have a degree-one
endpoint, so the number of edges is at most the number `d` of degree-one vertices; if `d` were
`m + n` the graph would be a perfect matching (too few edges), and if `d` were `m + n - 1` the
one remaining vertex would need degree `m + n - 1`, exceeding the size `max m n` of the opposite
part. -/
theorem exBipParts_pathGraph_four_le {m n : ℕ} (hm : 2 ≤ m) (hn : 2 ≤ n) :
    exBipParts m n (pathGraph 4) ≤ m + n - 2 := by
  classical
  rw [exBipParts_le_iff]
  intro G hfree hsub
  have hbip := isBipartite_of_le_completeBipartiteGraph hsub
  have hdegbd : ∀ v, G.degree v ≤ m + n - 2 := fun v =>
    le_trans (degree_le_of_le_completeBipartiteGraph hsub v) (by omega)
  have hedge : ∀ {u v}, G.Adj u v → G.degree u = 1 ∨ G.degree v = 1 := fun huv =>
    exists_degree_one_endpoint hbip hfree huv
  have hcard := card_edgeFinset_le_card_degree_one hedge
  set D := univ.filter (fun v : Fin m ⊕ Fin n => G.degree v = 1) with hD
  set Dc := univ.filter (fun v : Fin m ⊕ Fin n => ¬ G.degree v = 1) with hDc
  have hsplit : #D + #Dc = m + n := by
    rw [hD, hDc, Finset.card_filter_add_card_filter_not]
    simp
  have hsum : ∑ v : Fin m ⊕ Fin n, G.degree v = 2 * #G.edgeFinset :=
    SimpleGraph.sum_degrees_eq_twice_card_edges G
  have hsum2 : ∑ v ∈ D, G.degree v + ∑ v ∈ Dc, G.degree v = 2 * #G.edgeFinset := by
    rw [← hsum, hD, hDc]
    exact Finset.sum_filter_add_sum_filter_not _ _ _
  have hsumD : ∑ v ∈ D, G.degree v = #D := by
    rw [Finset.sum_congr rfl (fun v hv => (Finset.mem_filter.mp hv).2), Finset.sum_const,
      smul_eq_mul, mul_one]
  rcases Nat.lt_or_ge (#Dc) 2 with hlt | hge
  · -- few exceptional vertices: use the degree sum
    have hbound : ∑ v ∈ Dc, G.degree v ≤ #Dc * (m + n - 2) := by
      simpa [smul_eq_mul] using Finset.sum_le_card_nsmul Dc _ (m + n - 2) fun v _ => hdegbd v
    interval_cases h : #Dc
    · simp only [Nat.zero_mul, Nat.le_zero] at hbound
      omega
    · rw [Nat.one_mul] at hbound
      omega
  · omega

/-- **The exact fixed-part bipartite extremal number of `P₄` for parts of size at least two.**
Both bounds are sharp: the extremal graph is the disjoint union of two stars. -/
theorem exBipParts_pathGraph_four {m n : ℕ} (hm : 2 ≤ m) (hn : 2 ≤ n) :
    exBipParts m n (pathGraph 4) = m + n - 2 := by
  classical
  refine le_antisymm (exBipParts_pathGraph_four_le hm hn) ?_
  have hle := card_edgeFinset_le_exBipParts
    (twoStars_free_pathGraph_four (m := m) (n := n) (by omega) (by omega))
    (twoStars_le_completeBipartiteGraph m n)
  rwa [card_edgeFinset_twoStars (by omega) (by omega)] at hle

/-- **The complete fixed-part answer for `P₄`.**  For every pair of part sizes,
`exBipParts m n P₄ = m * n` if one part has at most one vertex (the complete bipartite host is
then already `P₄`-free), and `m + n - 2` otherwise. -/
theorem exBipParts_pathGraph_four_formula (m n : ℕ) :
    exBipParts m n (pathGraph 4) = if min m n ≤ 1 then m * n else m + n - 2 := by
  rcases Nat.lt_or_ge m 2 with hm | hm
  · rw [if_pos (by omega)]
    exact exBipParts_pathGraph_eq_mul (p := 4) (by omega)
  rcases Nat.lt_or_ge n 2 with hn | hn
  · rw [if_pos (by omega), exBipParts_comm, exBipParts_pathGraph_eq_mul (p := 4) (by omega),
      Nat.mul_comm]
  rw [if_neg (by omega)]
  exact exBipParts_pathGraph_four hm hn

/-! ### Consistency with the decomposition theorem -/

/-- **The order-only value of `P₄` is recovered from the fixed-part values**, and the maximum
over splittings `n = m + (n - m)` is attained at the extreme splitting `m = 1`: the balanced
splittings only give `n - 2`.  This exhibits the general decomposition theorem
`exBip_eq_sup_exBipParts` in a case where both sides are known exactly. -/
theorem exBip_pathGraph_four_eq_sup {n : ℕ} (hn : 2 ≤ n) :
    ((range (n + 1)).sup fun m => exBipParts m (n - m) (pathGraph 4)) = n - 1 := by
  rw [← exBip_eq_sup_exBipParts]
  exact exBip_pathGraph_four hn

/-- Every splitting of `n` into two parts of size at least two is strictly worse than the
unbalanced splitting: it gives only `n - 2` edges. -/
theorem exBipParts_pathGraph_four_balanced {n m : ℕ} (hm : 2 ≤ m) (hm' : 2 ≤ n - m) :
    exBipParts m (n - m) (pathGraph 4) = m + (n - m) - 2 :=
  exBipParts_pathGraph_four hm hm'

/-! ### Hosts too small to contain the forbidden graph

When the host has fewer vertices than `T`, no copy of `T` can occur, so the extremal number
degenerates to the maximum number of edges of a bipartite graph.  This regime is what makes the
`P₄` answer `n - 1` genuinely special: it fails already for `P₅` at `n = 4`. -/

variable {W : Type*} {T : SimpleGraph W}

/-- A graph on fewer vertices than `T` is automatically `T`-free. -/
theorem free_of_card_lt {V : Type*} [Fintype V] [Fintype W] (G : SimpleGraph V)
    (h : Fintype.card V < Fintype.card W) : T.Free G := by
  rintro ⟨f⟩
  exact absurd (Fintype.card_le_of_injective _ f.injective) (by omega)

/-- The product `m (n - m)` is maximised at the balanced splitting. -/
private lemma mul_sub_le_balanced {n m : ℕ} (hm : m ≤ n) :
    m * (n - m) ≤ (n / 2) * (n - n / 2) := by
  have key : ∀ {a b q c : ℕ}, a + b = q + c → a ≤ q → q ≤ c → a * b ≤ q * c := by
    intro a b q c hsum h1 h2
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le h1
    have hb : b = d + c := by omega
    subst hb
    have hac : a ≤ c := h1.trans h2
    nlinarith
  have hkey : min m (n - m) * max m (n - m) ≤ (n / 2) * (n - n / 2) :=
    key (by omega) (by omega) (by omega)
  rcases le_total m (n - m) with h | h
  · rwa [min_eq_left h, max_eq_right h] at hkey
  · rwa [min_eq_right h, max_eq_left h, Nat.mul_comm] at hkey

/-- **Degenerate fixed-part regime.**  If `T` has more than `m + n` vertices then the complete
bipartite host `K_{m,n}` is itself `T`-free, so `exBipParts m n T = m n`. -/
theorem exBipParts_of_card_lt [Fintype W] (m n : ℕ) (h : m + n < Fintype.card W) :
    exBipParts m n T = m * n :=
  le_antisymm (exBipParts_le_mul m n T)
    (mul_le_exBipParts_of_free (free_of_card_lt _ (by simpa using h)))

/-- **Degenerate order-only regime.**  If `T` has more than `n` vertices then `exBip n T` is the
maximum number of edges of a bipartite graph on `n` vertices, namely `⌊n/2⌋⌈n/2⌉`. -/
theorem exBip_of_card_lt [Fintype W] (n : ℕ) (h : n < Fintype.card W) :
    exBip n T = (n / 2) * (n - n / 2) := by
  rw [exBip_eq_sup_exBipParts]
  refine le_antisymm (Finset.sup_le fun m hm => ?_) ?_
  · have hmn : m ≤ n := by simpa [Nat.lt_succ_iff] using Finset.mem_range.mp hm
    exact le_trans (exBipParts_le_mul _ _ _) (mul_sub_le_balanced hmn)
  · refine le_trans ?_ (Finset.le_sup (f := fun m => exBipParts m (n - m) T)
      (Finset.mem_range.mpr (show n / 2 < n + 1 by omega)))
    exact le_of_eq (exBipParts_of_card_lt (T := T) _ _ (by omega)).symm

/-- **The `P₄` formula does not extend to `P₅`.**  A four-cycle is bipartite and, having only
four vertices, contains no `P₅`; hence `exBip 4 P₅ = 4 > 3 = 4 - 1`.  This is the formal
counterexample behind the entry `P₅` at `n = 4` in the small-case table. -/
theorem exBip_four_pathGraph_five : exBip 4 (pathGraph 5) = 4 := by
  have h := exBip_of_card_lt (T := pathGraph 5) 4 (by simp)
  norm_num at h
  exact h

/-- Consequently the clean answer `exBip n P₄ = n - 1` is genuinely special to `P₄`. -/
theorem exBip_pathGraph_five_ne_sub_one : exBip 4 (pathGraph 5) ≠ 4 - 1 := by
  rw [exBip_four_pathGraph_five]
  norm_num

end Catalog.Combinatorics.BipartiteExtremalTrees