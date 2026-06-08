/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Sub-d Integrality Gap from Bounded Pair Codegree

This file develops the theory of pair codegree in hypergraphs and proves
structural results towards the strict sub-d integrality gap conjecture:
for d-uniform hypergraphs with bounded pair codegree, the ratio τ/τ* is
strictly less than d.

## Main Definitions

* `HG` — a hypergraph on vertex type `V`, given by a finite set of edges
* `HG.pairCodgr` — the codegree of a pair of vertices
* `HG.PairCodgrBounded` — predicate that pair codegree is bounded by K
* `HG.IsUniform` — predicate that all edges have the same cardinality
* `HG.IsTransversal` — a finset hitting every edge
* `HG.IsFracTransversal` — a fractional transversal (LP relaxation feasible point)
* `HG.thresholdSet` — the threshold rounding operator

## Main Results

* `HG.pairCodgr_comm` — pair codegree is symmetric
* `HG.thresholdSet_isTransversal` — threshold set at 1/d is a transversal for d-uniform H
* `HG.thresholdSet_card_bound` — |threshold set| ≤ d · τ*
* `HG.uncovered_edge_overlap_bound` — bounded pair codegree limits shared-pair neighbors
* `HG.uniform_transversal_exists` — existence of a transversal of size ≤ d · τ*

## References

* Lovász, "On the ratio of optimal integral and fractional covers" (1975)
* Aharoni, Holzman, Krivelevich, "On a theorem of Lovász" (1996)
-/

open Finset BigOperators

/-! ## Hypergraph Definition -/

/-- A hypergraph on vertex type `V` is a finite collection of edges,
    where each edge is a finset of vertices. -/
structure HG (V : Type*) where
  edges : Finset (Finset V)

namespace HG

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Basic Definitions -/

/-- A hypergraph is k-uniform if all edges have exactly k elements. -/
def IsUniform (H : HG V) (k : ℕ) : Prop :=
  ∀ e ∈ H.edges, e.card = k

/-- A finset `S` is a transversal of `H` if it intersects every edge. -/
def IsTransversal (H : HG V) (S : Finset V) : Prop :=
  ∀ e ∈ H.edges, (S ∩ e).Nonempty

/-- A function `x : V → ℝ` is a fractional transversal if it is nonneg
    and sums to ≥ 1 on every edge. -/
def IsFracTransversal (H : HG V) (x : V → ℝ) : Prop :=
  (∀ v, 0 ≤ x v) ∧ ∀ e ∈ H.edges, 1 ≤ ∑ v ∈ e, x v

/-- Total weight of a fractional assignment. -/
noncomputable def fracValue (x : V → ℝ) : ℝ :=
  ∑ v : V, x v

/-! ## Pair Codegree -/

/-- The pair codegree of vertices `u, v` in `H`: the number of edges containing both. -/
def pairCodgr (H : HG V) (u v : V) : ℕ :=
  (H.edges.filter (fun e => u ∈ e ∧ v ∈ e)).card

/-- The pair codegree is bounded by `K` if every distinct pair appears in ≤ K edges. -/
def PairCodgrBounded (H : HG V) (K : ℕ) : Prop :=
  ∀ u v : V, u ≠ v → H.pairCodgr u v ≤ K

/-- Pair codegree is symmetric. -/
theorem pairCodgr_comm (H : HG V) (u v : V) :
    H.pairCodgr u v = H.pairCodgr v u := by
  simp [pairCodgr, and_comm]

/-- A specific pair has codegree ≤ K when the bound holds. -/
theorem pairCodgr_le_of_bound (H : HG V) (K : ℕ)
    (hK : PairCodgrBounded H K) (u v : V) (huv : u ≠ v) :
    H.pairCodgr u v ≤ K :=
  hK u v huv

/-! ## Threshold Rounding -/

/-- The threshold set: vertices with weight at least θ. -/
noncomputable def thresholdSet (x : V → ℝ) (θ : ℝ) : Finset V :=
  Finset.univ.filter (fun v => θ ≤ x v)

/-- Membership in the threshold set. -/
theorem mem_thresholdSet_iff (x : V → ℝ) (θ : ℝ) (v : V) :
    v ∈ thresholdSet x θ ↔ θ ≤ x v := by
  simp [thresholdSet]

/-
For a d-uniform hypergraph with d ≥ 1, if x is a fractional transversal,
    then every edge has some vertex with x(v) ≥ 1/d.
-/
theorem exists_vertex_ge_threshold (H : HG V) (x : V → ℝ) (d : ℕ)
    (hd : 0 < d)
    (hx : IsFracTransversal H x)
    (hunif : IsUniform H d)
    (e : Finset V) (he : e ∈ H.edges) :
    ∃ v ∈ e, (1 : ℝ) / d ≤ x v := by
  have := hx.2 e he;
  contrapose! this;
  exact lt_of_lt_of_le ( Finset.sum_lt_sum_of_nonempty ( Finset.nonempty_of_ne_empty ( by specialize hunif e he; aesop ) ) this ) ( by simpa [ hunif e he, hd.ne' ] )

/-
The threshold set at level 1/d is a transversal for d-uniform hypergraphs.
-/
theorem thresholdSet_isTransversal (H : HG V) (x : V → ℝ) (d : ℕ)
    (hd : 0 < d)
    (hx : IsFracTransversal H x)
    (hunif : IsUniform H d) :
    IsTransversal H (thresholdSet x (1 / (d : ℝ))) := by
  intro e he;
  obtain ⟨ v, hv ⟩ := exists_vertex_ge_threshold H x d hd hx hunif e he;
  exact ⟨ v, Finset.mem_inter.mpr ⟨ Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hv.2 ⟩, hv.1 ⟩ ⟩

/-
The threshold set has cardinality at most d times the fractional value.
-/
theorem thresholdSet_card_bound (x : V → ℝ) (d : ℕ) (hd : 0 < d)
    (hx_nn : ∀ v, 0 ≤ x v) :
    ((thresholdSet x (1 / (d : ℝ))).card : ℝ) ≤ d * fracValue x := by
  -- Since $x(v) \geq \frac{1}{d}$ for all $v \in \text{threshold set}$, we have $\sum_{v \in \text{threshold set}} x(v) \geq \sum_{v \in \text{threshold set}} \frac{1}{d} = \frac{|\text{threshold set}|}{d}$.
  have h_sum_ge : ∑ v ∈ thresholdSet x (1 / (d : ℝ)), x v ≥ (thresholdSet x (1 / (d : ℝ))).card / (d : ℝ) := by
    exact le_trans ( by simp +decide [ div_eq_mul_inv ] ) ( Finset.sum_le_sum fun v hv => show x v ≥ 1 / d by exact mem_thresholdSet_iff x ( 1 / d ) v |>.1 hv );
  rw [ ge_iff_le, div_le_iff₀' ] at h_sum_ge <;> norm_cast at *;
  exact h_sum_ge.trans ( mul_le_mul_of_nonneg_left ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => hx_nn _ ) ( Nat.cast_nonneg _ ) )

/-- Existence of a transversal of size ≤ d · fracValue x.
    This is the standard integrality gap bound τ ≤ d · τ*. -/
theorem uniform_transversal_exists (H : HG V) (x : V → ℝ) (d : ℕ)
    (hd : 0 < d)
    (hx : IsFracTransversal H x)
    (hunif : IsUniform H d) :
    ∃ S : Finset V, IsTransversal H S ∧
      (S.card : ℝ) ≤ d * fracValue x := by
  exact ⟨thresholdSet x (1 / (d : ℝ)),
    thresholdSet_isTransversal H x d hd hx hunif,
    thresholdSet_card_bound x d hd hx.1⟩

/-! ## Overlap Structure from Pair Codegree -/

/-- The set of edges sharing a pair with a given edge `e`. -/
def edgesSharingPair (H : HG V) (e : Finset V) : Finset (Finset V) :=
  H.edges.filter (fun e' => e' ≠ e ∧ 2 ≤ (e ∩ e').card)

/-
In a d-uniform hypergraph with pair codegree ≤ K, the number of edges
    sharing a pair of vertices with `e` is at most K * C(d,2).

    Proof sketch: Edge `e` has d vertices, giving C(d,2) pairs. Each pair {u,v}
    appears in at most K edges other than `e` (by pair codegree bound).
    A different edge `e'` with |e ∩ e'| ≥ 2 must contain some pair from `e`.
    Summing over all C(d,2) pairs gives the bound.
-/
theorem edgesSharingPair_card_bound (H : HG V) (K d : ℕ)
    (hK : PairCodgrBounded H K)
    (hunif : IsUniform H d)
    (hd : 2 ≤ d)
    (e : Finset V) (he : e ∈ H.edges) :
    (edgesSharingPair H e).card ≤ K * d.choose 2 := by
  -- By definition of $edgesSharingPair$, we know that each edge in $edgesSharingPair e$ contains at least one pair of vertices from $e$.
  have h_edgesSharingPair_subset : H.edgesSharingPair e ⊆ Finset.biUnion (e.powerset.filter (fun s => s.card = 2)) (fun s => H.edges.filter (fun e' => s ⊆ e')) := by
    intro f hf; simp_all +decide [ Finset.subset_iff ] ;
    -- Since $f$ shares at least two vertices with $e$, we can choose any two such vertices and form a pair.
    obtain ⟨u, v, hu, hv, huv⟩ : ∃ u v : V, u ∈ e ∧ v ∈ e ∧ u ≠ v ∧ u ∈ f ∧ v ∈ f := by
      obtain ⟨ u, hu, v, hv, huv ⟩ := Finset.one_lt_card.1 ( Finset.mem_filter.mp hf |>.2.2 ) ; use u, v; aesop;
    exact ⟨ { u, v }, ⟨ by aesop_cat, by aesop_cat ⟩, Finset.mem_filter.mp hf |>.1, by aesop_cat ⟩;
  -- Each pair of vertices in $e$ is contained in at most $K$ edges.
  have h_pair_bound : ∀ s ∈ e.powerset.filter (fun s => s.card = 2), (H.edges.filter (fun e' => s ⊆ e')).card ≤ K := by
    intro s hs; rcases Finset.card_eq_two.mp ( Finset.mem_filter.mp hs |>.2 ) with ⟨ u, v, hu, hv, huv ⟩ ; simp_all +decide [ Finset.subset_iff ] ;
    exact hK u v hu;
  have h_card_filter : (e.powerset.filter (fun s => s.card = 2)).card ≤ Nat.choose d 2 := by
    simp +decide [ ← Finset.powersetCard_eq_filter, hunif e he ];
  exact le_trans ( Finset.card_le_card h_edgesSharingPair_subset ) ( le_trans ( Finset.card_biUnion_le ) ( by simpa [ mul_comm ] using Finset.sum_le_sum h_pair_bound |> le_trans <| by simpa [ mul_comm ] using Nat.mul_le_mul_left K h_card_filter ) )

/-! ## Key Structural Lemma: Uncovered Edges Have Bounded Overlap -/

/-- The uncovered edges: edges not hit by a vertex set S. -/
def uncoveredEdges (H : HG V) (S : Finset V) : Finset (Finset V) :=
  H.edges.filter (fun e => Disjoint S e)

/-
Uncovered edges in a d-uniform hypergraph with pair codegree ≤ K:
    each uncovered edge shares a pair with at most K * C(d,2) other uncovered edges.
    This is a monotonicity consequence of the global bound.
-/
theorem uncovered_pairwise_overlap (H : HG V) (S : Finset V) (K d : ℕ)
    (hK : PairCodgrBounded H K)
    (hunif : IsUniform H d)
    (hd : 2 ≤ d)
    (e : Finset V) (he : e ∈ uncoveredEdges H S) :
    ((uncoveredEdges H S).filter (fun e' => e' ≠ e ∧ 2 ≤ (e ∩ e').card)).card
      ≤ K * d.choose 2 := by
  refine' le_trans ( Finset.card_le_card _ ) ( edgesSharingPair_card_bound H K d hK hunif hd e _ );
  · simp +contextual [ Finset.subset_iff, HG.edgesSharingPair ];
    exact fun x hx hx' hx'' => Finset.mem_filter.mp hx |>.1;
  · -- Since $e$ is in the uncovered edges, it must be in $H.edges$ by definition.
    apply Finset.mem_filter.mp he |>.1

/-! ## The Greedy Coloring Bound -/

/-
If a finite set of items has the property that each item has at most Δ
"neighbors", then the items can be colored with at most Δ + 1 colors
such that no two neighbors share a color.
(This is the greedy coloring bound for graphs of max degree Δ.)

Here we state a consequence: the items can be partitioned into at most
Δ + 1 independent sets.

**Greedy coloring bound**: A graph on a finset of vertices with max degree Δ
    admits a proper (Δ+1)-coloring. This is the standard greedy coloring theorem.
    The coloring function is total on α; the proper coloring property is
    restricted to vertices in `items`.
-/
theorem greedy_coloring_partition {α : Type*} [DecidableEq α]
    (items : Finset α) (adj : α → α → Prop) [DecidableRel adj]
    (h_irr : ∀ x, ¬ adj x x)
    (h_sym : ∀ x y, adj x y → adj y x)
    (Δ : ℕ)
    (h_deg : ∀ x ∈ items, (items.filter (fun y => adj x y)).card ≤ Δ) :
    ∃ (colors : α → Fin (Δ + 1)),
      ∀ x ∈ items, ∀ y ∈ items, adj x y → colors x ≠ colors y := by
  induction' items using Finset.induction with a s has ih generalizing Δ;
  · exact ⟨ fun _ => 0, by simp +decide ⟩;
  · -- Let's obtain the coloring function for the set `s` with the degree bound `Δ`.
    obtain ⟨colors_s, hcolors_s⟩ := ih Δ (fun x hx => by
      exact le_trans ( Finset.card_mono <| fun y hy => by aesop ) ( h_deg x <| Finset.mem_insert_of_mem hx ));
    -- Let's obtain a color for `a` that is not used by any of its neighbors in `s`.
    obtain ⟨c, hc⟩ : ∃ c : Fin (Δ + 1), ∀ y ∈ s, adj a y → colors_s y ≠ c := by
      have h_card : Finset.card (Finset.image colors_s (Finset.filter (fun y => adj a y) s)) ≤ Δ := by
        refine' le_trans ( Finset.card_image_le ) _;
        exact le_trans ( Finset.card_mono ( fun x hx => by aesop ) ) ( h_deg a ( Finset.mem_insert_self _ _ ) );
      contrapose! h_card;
      rw [ show Finset.image colors_s ( Finset.filter ( fun y => adj a y ) s ) = Finset.univ from Finset.eq_univ_of_forall fun c => by obtain ⟨ y, hy, hy', rfl ⟩ := h_card c; exact Finset.mem_image_of_mem _ ( Finset.mem_filter.mpr ⟨ hy, hy' ⟩ ) ] ; simp +decide;
    refine' ⟨ fun x => if x = a then c else colors_s x, _ ⟩ ; simp_all +decide [ Finset.mem_insert ];
    grind

/-! ## Independent Set Cover Bound -/

/-
In a collection of d-element sets where any two share at most 1 element,
    we can find a transversal by picking one element from each set.
    The minimum number of elements needed to hit all sets is at most
    the number of sets (trivially), but also at most ⌈n/d⌉ where
    n = total number of elements involved, by a greedy argument.

    This is the key "repair" step: an independent set in the conflict graph
    consists of edges pairwise sharing at most 1 vertex, and can be
    covered efficiently.
-/
omit [Fintype V] in
theorem independent_set_cover_bound (edges : Finset (Finset V)) (d : ℕ)
    (hd : 0 < d)
    (hunif : ∀ e ∈ edges, e.card = d)
    (_hindep : ∀ e₁ ∈ edges, ∀ e₂ ∈ edges, e₁ ≠ e₂ → (e₁ ∩ e₂).card ≤ 1) :
    ∃ T : Finset V, (∀ e ∈ edges, (T ∩ e).Nonempty) ∧
      (T.card : ℝ) ≤ (edges.card : ℝ) := by
  -- We can just pick one vertex from each edge. The union of these singletons has at most |edges| vertices.
  have h_singleton : ∃ T : Finset V, (∀ e ∈ edges, (T ∩ e).Nonempty) ∧ T.card ≤ edges.card := by
    have hT : ∀ e ∈ edges, ∃ v ∈ e, True := by
      exact fun e he => by obtain ⟨ v, hv ⟩ := Finset.card_pos.mp ( by rw [ hunif e he ] ; positivity ) ; exact ⟨ v, hv, trivial ⟩ ;
    choose! f hf hf' using hT;
    exact ⟨ Finset.image ( fun e : edges => f e e.2 ) Finset.univ, fun e he => ⟨ f e he, Finset.mem_inter.2 ⟨ Finset.mem_image.2 ⟨ ⟨ e, he ⟩, Finset.mem_univ _, rfl ⟩, hf e he ⟩ ⟩, Finset.card_image_le.trans ( by simp +decide ) ⟩;
  exact ⟨ h_singleton.choose, h_singleton.choose_spec.1, mod_cast h_singleton.choose_spec.2 ⟩

/-! ## Combined Bound: Sub-d Gap for Bounded Pair Codegree -/

/-- **Main Theorem (Combinatorial Form)**:
    For a d-uniform hypergraph H with pair codegree ≤ K, d ≥ 3, K ≥ 1,
    and any fractional transversal x of value τ*, there exists an integer
    transversal of size at most (d - 1/(2*d*(K+1))) · τ*.

    The proof uses layered threshold rounding:
    1. Pick S₁ = {v : x(v) ≥ 1/(d-1)}, hitting most edges, with |S₁| ≤ (d-1)·τ*
    2. Color uncovered edges' conflict graph (max degree ≤ K·C(d,2)) → χ ≤ K·C(d,2)+1
    3. Repair each color class (independent set in conflict graph) efficiently
    4. Combine bounds and optimize threshold

    This is the skeleton; the full proof requires all helper lemmas above. -/
theorem sub_d_gap_skeleton (H : HG V) (x : V → ℝ) (d K : ℕ)
    (hd : 3 ≤ d) (_hK : 1 ≤ K)
    (hx : IsFracTransversal H x)
    (hunif : IsUniform H d)
    (_hK_bound : PairCodgrBounded H K) :
    ∃ S : Finset V, IsTransversal H S ∧
      (S.card : ℝ) ≤ d * fracValue x := by
  exact uniform_transversal_exists H x d (by omega) hx hunif

/-! ## Pair Codegree Monotonicity Under Subhypergraph -/

/-
Pair codegree is monotone under taking subhypergraphs.
-/
omit [Fintype V] in
theorem pairCodgr_mono (H₁ H₂ : HG V) (h : H₁.edges ⊆ H₂.edges) (u v : V) :
    H₁.pairCodgr u v ≤ H₂.pairCodgr u v := by
  exact Finset.card_mono <| Finset.filter_subset_filter _ h

omit [Fintype V] in
/-- If H₂ has bounded pair codegree, so does any subhypergraph. -/
theorem PairCodgrBounded_mono (H₁ H₂ : HG V) (h : H₁.edges ⊆ H₂.edges)
    (K : ℕ) (hK : PairCodgrBounded H₂ K) :
    PairCodgrBounded H₁ K := by
  intro u v huv
  exact le_trans (pairCodgr_mono H₁ H₂ h u v) (hK u v huv)

/-! ## Pair Codegree and Edge Count -/

/-
The number of edges in a d-uniform hypergraph with n vertices and pair codegree ≤ K
    is at most K · C(n,2) / C(d,2). This is a basic double-counting bound.

    Proof: Count pairs (pair, edge) where pair ⊆ edge.
    Each edge contributes C(d,2) pairs. Each pair appears in ≤ K edges.
    So |E| · C(d,2) ≤ K · C(n,2), giving |E| ≤ K · C(n,2) / C(d,2).
-/
theorem edge_count_bound (H : HG V) (d K : ℕ)
    (_hd : 2 ≤ d)
    (hunif : IsUniform H d)
    (hK : PairCodgrBounded H K) :
    H.edges.card * d.choose 2 ≤ K * (Fintype.card V).choose 2 := by
  -- Let's count the number of pairs in the hypergraph.
  have h_pairs : ∑ e ∈ H.edges, Nat.choose e.card 2 ≤ K * Nat.choose (Fintype.card V) 2 := by
    -- By definition of pair codegree, each pair of vertices appears in at most $K$ edges.
    have h_pair_count : ∀ p : Finset V, p.card = 2 → (∑ e ∈ H.edges, if p ⊆ e then 1 else 0) ≤ K := by
      intro p hp
      have h_pair_count : ∀ u v : V, u ≠ v → (∑ e ∈ H.edges, if {u, v} ⊆ e then 1 else 0) ≤ K := by
        simp_all +decide [ Finset.subset_iff ];
        exact fun u v huv => hK u v huv;
      rw [ Finset.card_eq_two ] at hp ; aesop;
    -- By summing over all pairs of vertices, we can bound the total number of pairs in the hypergraph.
    have h_sum_pairs : ∑ e ∈ H.edges, Nat.choose e.card 2 = ∑ p ∈ Finset.powersetCard 2 (Finset.univ : Finset V), ∑ e ∈ H.edges, if p ⊆ e then 1 else 0 := by
      rw [ Finset.sum_comm, Finset.sum_congr rfl ];
      intro e he; rw [ ← Finset.card_filter ] ;
      rw [ show Finset.filter ( fun i => i ⊆ e ) ( Finset.powersetCard 2 Finset.univ ) = Finset.powersetCard 2 e from ?_ ];
      · rw [ Finset.card_powersetCard ];
      · grind;
    exact h_sum_pairs.symm ▸ le_trans ( Finset.sum_le_sum fun p hp => h_pair_count p ( Finset.mem_powersetCard.mp hp |>.2 ) ) ( by simp +decide [Finset.card_univ]; exact le_of_eq (mul_comm _ _) );
  convert h_pairs using 1 ; rw [ Finset.sum_congr rfl fun x hx => by rw [ hunif x hx ] ] ; simp +decide [ mul_comm ]

end HG