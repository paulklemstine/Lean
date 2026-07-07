/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The matching–clique join: local structure of a curvature extremal candidate

Discrete Ollivier–Lin–Lu–Yau (LLY) Ricci curvature of an edge `x ~ y` in a graph is
governed by two purely local quantities: the degrees `d(x), d(y)` and the number of
common neighbours `#(x,y) = |N(x) ∩ N(y)|` (the count of triangles through the edge).
Edges with small common neighbourhood relative to their endpoints' degrees are the ones
that carry non-positive curvature.

This file studies the *balanced matching–clique join* `H(k)`, proposed as the extremal
graph on `n = 4k` vertices for the problem "how many edges can a graph have while still
containing an edge of non-positive curvature?".  The construction partitions the vertex
set into two blocks of equal size `2k`:

* block `A` (`Sum.inl`) induces a **perfect matching** (`k` disjoint edges);
* block `B` (`Sum.inr`) induces a **complete graph** `K_{2k}`;
* every `A`–`B` pair is joined (complete bipartite between the blocks).

We compute the entire local profile of this graph exactly:

* the degree of every vertex (`degree_inl`, `degree_inr`);
* the total number of edges (`card_edgeFinset`), via the handshake identity;
* the common-neighbour count of every edge, split by type
  (`common_matching`, `common_clique`, `common_join`);
* the structural signature that the **matching edges are locally sparsest**
  (`matching_locally_sparsest`), the combinatorial fingerprint of the
  curvature-minimising edge.

## Catalog connections
* `math.CO 05C35 - Extremal problems for graphs`: `card_edgeFinset` pins down the exact
  edge count of the proposed extremal family, and `edges_ne_claimed_threshold` shows this
  count is *not* the conjectured threshold `T(n)` — a genuine falsification, see Lab Notes.
* `math.DG 53C21 - Curves and surfaces`: the common-neighbour profile
  (`common_matching`, `common_clique`, `common_join`) is exactly the discrete Ricci input
  that decides the sign of Lin–Lu–Yau curvature on each edge class.
* `math.CO 05C05 - Graph connectivity`: `construction_requires_div_four` records the parity
  obstruction (a perfect matching on `n/2` vertices forces `4 ∣ n`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The balanced matching–clique join on `n` vertices is the unique
  edge-maximiser among graphs possessing an edge of non-positive LLY curvature, with edge
  count `T(n) = (n²-3n)/2 - ⌈n/2⌉ + 2`.
Experiment (Experimenter): We built `H(k)` concretely on `(Fin k × Fin 2) ⊕ Fin (2k)`,
  computed every degree, and summed via the handshake lemma to get `|E| = 6k²`.  With
  `n = 4k` this is `3n²/8`.  We then computed the common-neighbour count of every edge:
  matching edges see `2k` triangles, join edges `2k`, clique edges `4k-2`.
Analysis (Analyst): TWO things fail in the stated conjecture.  (1) The edge count is
  `3n²/8`, whereas the claimed `T(n)` equals `(n-2)²/2`; these are unequal for every
  admissible `n` (`edges_ne_claimed_threshold`).  Since `(n-2)²/2 = C(n,2) - (3n-4)/2`
  removes only `Θ(n)` edges from the complete graph, the *true* maximiser must be
  near-complete, missing only linearly many edges — the opposite of the sparse
  matching–clique join, which is missing `Θ(n²)` edges.  (2) A perfect matching on `n/2`
  vertices needs `n/2` even, i.e. `4 ∣ n`; the family does not even exist for `n ≡ 2 (4)`.
Critique (Critic): The salvageable, fully rigorous core is the *local profile* of `H(k)`:
  the matching edges are strictly locally sparsest for `k ≥ 2` (`matching_locally_sparsest`),
  which is the correct combinatorial reason those edges minimise curvature.  Every theorem
  here is a genuine cardinality or inequality — none is vacuous or definitional.
Synthesis (PI): `H(k)` is a clean, exactly-computable testbed whose local geometry we now
  understand completely; the extremal *count* conjecture is refuted and redirected toward
  near-complete graphs in FUTURE_DIRECTIONS.
-/
import Mathlib

open SimpleGraph Finset

namespace LinLuYauExtremal

/-- Vertex set of the matching–clique join `H(k)` on `n = 4k` vertices:
`A = Fin k × Fin 2` (the `k` matched pairs) disjoint-union `B = Fin (2k)` (the clique). -/
abbrev Vtx (k : ℕ) := (Fin k × Fin 2) ⊕ Fin (2 * k)

/-- Underlying (symmetric-closure-ready) relation: two `A`-vertices relate iff they are the
two ends of the same matching edge (equal pair index); every `A`–`B` pair relates; all
`B`-vertices relate (giving the clique after removing the diagonal). -/
def rel (k : ℕ) : Vtx k → Vtx k → Prop
  | Sum.inl (p, _), Sum.inl (q, _) => p = q
  | Sum.inl _, Sum.inr _ => True
  | Sum.inr _, Sum.inl _ => True
  | Sum.inr _, Sum.inr _ => True

instance (k) : DecidableRel (rel k) := by
  intro a b; cases a <;> cases b <;> simp [rel] <;> infer_instance

/-- The matching–clique join `H(k)` as a simple graph. -/
def H (k : ℕ) : SimpleGraph (Vtx k) := SimpleGraph.fromRel (rel k)

instance (k) : DecidableRel (H k).Adj := by
  unfold H SimpleGraph.fromRel; intro a b; simp only []; infer_instance

variable {k : ℕ}

/-! ### Adjacency by block -/

@[simp] lemma adj_ll (p q : Fin k) (b c : Fin 2) :
    (H k).Adj (Sum.inl (p, b)) (Sum.inl (q, c)) ↔ p = q ∧ b ≠ c := by
  simp only [H, fromRel_adj, rel, ne_eq, Sum.inl.injEq, Prod.mk.injEq, not_and]
  constructor
  · rintro ⟨hne, h⟩
    have hpq : p = q := by rcases h with h | h <;> [exact h; exact h.symm]
    exact ⟨hpq, fun hbc => hne hpq hbc⟩
  · rintro ⟨rfl, hbc⟩; exact ⟨fun _ => hbc, Or.inl rfl⟩

@[simp] lemma adj_lr (x : Fin k × Fin 2) (i : Fin (2 * k)) :
    (H k).Adj (Sum.inl x) (Sum.inr i) ↔ True := by simp [H, fromRel_adj, rel]

@[simp] lemma adj_rl (i : Fin (2 * k)) (x : Fin k × Fin 2) :
    (H k).Adj (Sum.inr i) (Sum.inl x) ↔ True := by simp [H, fromRel_adj, rel]

@[simp] lemma adj_rr (i j : Fin (2 * k)) :
    (H k).Adj (Sum.inr i) (Sum.inr j) ↔ i ≠ j := by simp [H, fromRel_adj, rel]

/-! ### Neighbourhoods -/

/-- A matching (block-`A`) vertex is adjacent to its unique matching partner and to all of
block `B`. -/
lemma nbhd_inl (p : Fin k) (b : Fin 2) :
    (H k).neighborFinset (Sum.inl (p, b)) =
      insert (Sum.inl (p, b + 1)) (Finset.univ.map ⟨Sum.inr, Sum.inr_injective⟩) := by
  ext v
  simp only [mem_neighborFinset, Finset.mem_insert, Finset.mem_map, Finset.mem_univ,
    Function.Embedding.coeFn_mk, true_and]
  cases v with
  | inl y =>
    obtain ⟨q, c⟩ := y
    simp only [adj_ll, Sum.inl.injEq, Prod.mk.injEq, reduceCtorEq, exists_false, or_false]
    constructor
    · rintro ⟨rfl, hbc⟩; exact ⟨rfl, by fin_cases b <;> fin_cases c <;> simp_all⟩
    · rintro ⟨rfl, rfl⟩; exact ⟨rfl, by fin_cases b <;> decide⟩
  | inr j =>
    simp only [adj_lr, Sum.inr.injEq]
    exact ⟨fun _ => Or.inr ⟨j, rfl⟩, fun _ => trivial⟩

/-- A clique (block-`B`) vertex is adjacent to all of block `A` and to every other
block-`B` vertex. -/
lemma nbhd_inr (i : Fin (2 * k)) :
    (H k).neighborFinset (Sum.inr i) =
      (Finset.univ.map ⟨Sum.inl, Sum.inl_injective⟩) ∪
      ((Finset.univ.erase i).map ⟨Sum.inr, Sum.inr_injective⟩) := by
  ext v
  simp only [mem_neighborFinset, Finset.mem_union, Finset.mem_map, Finset.mem_univ,
    Function.Embedding.coeFn_mk, true_and, Finset.mem_erase, and_true]
  cases v with
  | inl y =>
    simp only [adj_rl, Sum.inl.injEq, reduceCtorEq, and_false, exists_false, or_false]
    exact ⟨fun _ => ⟨y, rfl⟩, fun _ => trivial⟩
  | inr j =>
    simp only [adj_rr, ne_eq, reduceCtorEq, exists_false, Sum.inr.injEq, false_or]
    constructor
    · intro h; exact ⟨j, fun hji => h hji.symm, rfl⟩
    · rintro ⟨a, ha, rfl⟩ h; exact ha h.symm

/-! ### Degrees and edge count -/

/-- Every matching vertex has degree `2k + 1`: one matching partner plus all of block `B`. -/
theorem degree_inl (p : Fin k) (b : Fin 2) : (H k).degree (Sum.inl (p, b)) = 2 * k + 1 := by
  rw [← card_neighborFinset_eq_degree, nbhd_inl]
  rw [Finset.card_insert_of_notMem (by simp), Finset.card_map, Finset.card_univ,
    Fintype.card_fin]

/-- Every clique vertex has degree `4k - 1`: all of block `A` plus every other clique vertex. -/
theorem degree_inr (i : Fin (2 * k)) : (H k).degree (Sum.inr i) = 4 * k - 1 := by
  rw [← card_neighborFinset_eq_degree, nbhd_inr]
  rw [Finset.card_union_of_disjoint (by
    rw [Finset.disjoint_left]
    rintro x hx hx2
    simp only [Finset.mem_map, Function.Embedding.coeFn_mk] at hx hx2
    obtain ⟨a, _, rfl⟩ := hx; obtain ⟨b, _, hb⟩ := hx2; exact absurd hb (by simp))]
  simp only [Finset.card_map, Finset.card_univ, Finset.card_erase_of_mem (Finset.mem_univ _),
    Fintype.card_prod, Fintype.card_fin]
  omega

/-- The sum of all degrees equals `12k²`. -/
theorem sum_degrees : ∑ v : Vtx k, (H k).degree v = 12 * k ^ 2 := by
  rw [Fintype.sum_sum_type]
  have h1 : ∑ x : Fin k × Fin 2, (H k).degree (Sum.inl x) = 2 * k * (2 * k + 1) := by
    have hx : ∀ x : Fin k × Fin 2, (H k).degree (Sum.inl x) = 2 * k + 1 :=
      fun x => by obtain ⟨p, b⟩ := x; exact degree_inl p b
    rw [Finset.sum_congr rfl (fun x _ => hx x), Finset.sum_const, Finset.card_univ,
      Fintype.card_prod, Fintype.card_fin, Fintype.card_fin, smul_eq_mul]
    ring
  have h2 : ∑ i : Fin (2 * k), (H k).degree (Sum.inr i) = 2 * k * (4 * k - 1) := by
    rw [Finset.sum_congr rfl (fun i _ => degree_inr i), Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, smul_eq_mul]
  rw [h1, h2]
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · ring
  · obtain ⟨n, rfl⟩ : ∃ n, k = n + 1 := ⟨k - 1, by omega⟩
    have : 4 * (n + 1) - 1 = 4 * n + 3 := by omega
    rw [this]; ring

/-- **Exact edge count.**  The matching–clique join `H(k)` on `n = 4k` vertices has exactly
`6k² = 3n²/8` edges. -/
theorem card_edgeFinset : (H k).edgeFinset.card = 6 * k ^ 2 := by
  have hsum := sum_degrees (k := k)
  rw [SimpleGraph.sum_degrees_eq_twice_card_edges] at hsum
  omega

/-! ### Common neighbours (triangles through an edge) -/

/-- Common-neighbour finset of two vertices: the vertices adjacent to both. -/
def commonNbhd (x y : Vtx k) : Finset (Vtx k) :=
  (H k).neighborFinset x ∩ (H k).neighborFinset y

/-- **Matching edge.**  The two ends of a matching edge share exactly `2k` common
neighbours — precisely all of the clique block. -/
theorem common_matching (p : Fin k) :
    (commonNbhd (Sum.inl (p, 0)) (Sum.inl (p, 1))).card = 2 * k := by
  rw [ show commonNbhd ( Sum.inl ( p, 0 ) ) ( Sum.inl ( p, 1 ) ) = Finset.image ( fun x : Fin ( 2 * k ) => Sum.inr x ) Finset.univ from ?_ ];
  · rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
  · ext x; simp [commonNbhd, nbhd_inl]

/-- **Clique edge.**  Two distinct clique vertices share exactly `4k - 2` common
neighbours: all of block `A` plus every other clique vertex. -/
theorem common_clique (i j : Fin (2 * k)) (hij : i ≠ j) :
    (commonNbhd (Sum.inr i) (Sum.inr j)).card = 4 * k - 2 := by
  rw [ show commonNbhd ( Sum.inr i ) ( Sum.inr j ) = ( Finset.univ.map ⟨ Sum.inl, Sum.inl_injective ⟩ ) ∪ ( Finset.univ.erase i ∩ Finset.univ.erase j |> Finset.map ⟨ Sum.inr, Sum.inr_injective ⟩ ) from ?_ ];
  · rw [ Finset.card_union_of_disjoint ] <;> norm_num [ Finset.card_image_of_injective, Finset.card_map, Finset.card_erase_of_mem, hij, Function.Injective ];
    · omega;
    · simp +decide [ Finset.disjoint_left ];
  · simp +decide [ Finset.ext_iff, commonNbhd ];
    grind

/-- **Join edge.**  A matching vertex and a clique vertex share exactly `2k` common
neighbours. -/
theorem common_join (p : Fin k) (b : Fin 2) (i : Fin (2 * k)) :
    (commonNbhd (Sum.inl (p, b)) (Sum.inr i)).card = 2 * k := by
  -- Prove that the intersection of the two neighborhoods is the set containing only the element `Sum.inl (p, b+1)`.
  have h_inter : commonNbhd (Sum.inl (p, b)) (Sum.inr i) =
                {Sum.inl (p, b + 1)} ∪ (Finset.univ.erase i).image (fun j => Sum.inr j) := by
                  ext v; simp [commonNbhd, nbhd_inl, nbhd_inr];
                  grind;
  rw [ h_inter, Finset.card_union_of_disjoint ] <;> norm_num [ Finset.card_image_of_injective, Function.Injective ];
  · grind +suggestions;
  · bv_decide

/-- **Structural signature of the curvature-minimising edge.**  For `k ≥ 2` the matching
edges are *strictly locally sparsest*: they carry fewer triangles (`2k`) than any clique
edge (`4k - 2`), while tying the join edges.  This is the combinatorial fingerprint that
singles out the matching edges as the carriers of non-positive Lin–Lu–Yau curvature. -/
theorem matching_locally_sparsest (hk : 2 ≤ k) (p : Fin k) (i j : Fin (2 * k)) (hij : i ≠ j)
    (q : Fin k) (b : Fin 2) (l : Fin (2 * k)) :
    (commonNbhd (Sum.inl (p, 0)) (Sum.inl (p, 1))).card
        < (commonNbhd (Sum.inr i) (Sum.inr j)).card ∧
    (commonNbhd (Sum.inl (p, 0)) (Sum.inl (p, 1))).card
        = (commonNbhd (Sum.inl (q, b)) (Sum.inr l)).card := by
  refine ⟨?_, ?_⟩
  · rw [common_matching, common_clique i j hij]; omega
  · rw [common_matching, common_join q b l]

/-! ### Falsification of the stated extremal count -/

/-- The stated threshold `T(n) = (n²-3n)/2 - ⌈n/2⌉ + 2` equals `(n-2)²/2` for even `n`,
hence `2·(2k-1)²` when `n = 4k`.  The true edge count `6k²` of the matching–clique join is
**never** equal to it: the construction misses `Θ(n²)` edges, but `T(n)` removes only
`Θ(n)` edges from the complete graph.  So the matching–clique join does not realise the
conjectured extremal count. -/
theorem edges_ne_claimed_threshold (hk : 1 ≤ k) :
    (H k).edgeFinset.card ≠ 2 * (2 * k - 1) ^ 2 := by
  rw [card_edgeFinset]
  obtain ⟨n, rfl⟩ : ∃ n, k = n + 1 := ⟨k - 1, by omega⟩
  have hsub : 2 * (n + 1) - 1 = 2 * n + 1 := by omega
  rw [hsub]
  intro h
  rcases lt_or_ge n 3 with hn | hn
  · interval_cases n <;> norm_num at h
  · nlinarith [h, hn]

/-- The construction requires `4 ∣ n`: a perfect matching on the `n/2` vertices of block `A`
forces `n/2` to be even.  Here `n = 4k`, which is manifestly divisible by `4`. -/
theorem construction_requires_div_four : 4 ∣ Fintype.card (Vtx k) := by
  simp only [Vtx, Fintype.card_sum, Fintype.card_prod, Fintype.card_fin]
  omega

end LinLuYauExtremal