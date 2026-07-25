import Mathlib

/-!
# Sunflower Pruning for Pythagorean Hypergraphs

This file develops the theory of sunflower-based search-tree pruning for
transversal (hitting set) computation on the 3-uniform Pythagorean triple
hypergraph.

## Main Definitions

* `vertexDegree` — Degree of a vertex in a hypergraph
* `IsHittingSet` — Transversal / hitting set for a hypergraph
* `IsSunflowerOn` — Sunflower (Δ-system) with specified kernel
* `OverlapRich` — Vertex with high degree in hypergraph
* `pythagoreanEdges` — The 3-uniform Pythagorean hypergraph on {1,…,n}
* `recursiveCallsNaive` / `recursiveCallsSunflower` — Search tree size models

## Main Results

* `incidence_double_counting` — ∑ deg(v) = ∑ |e| (fundamental double-counting)
* `incidence_sum_eq_uniformity_mul_edges` — For r-uniform: ∑ deg(v) = r·|E|
* `exists_vertex_large_degree` — Averaging: some vertex has degree ≥ r·|E|/|V|
* `hitting_set_must_hit_sunflower_core` — Soundness of sunflower branching
* `bounded_hitting_set_forces_heavy_vertex` — Heavy vertices forced into small
  hitting sets
* `sunflower_branching_le_naive` — Pruned search ≤ naive search (monotonic domination)
* `sunflower_reduction_preserves_hitting_set` — FPT kernelization correctness

## Strategy

We follow Strategy A (incidence double-counting + sunflower forcing) combined with
Strategy C (kernelization-first algorithm proof). The arithmetic structure of
Pythagorean triples creates overlap-rich vertices that sunflower extraction exploits.

## References

* Erdős, R.; Rado, R. "Intersection theorems for systems of sets" (1960)
* Cygan et al. "Parameterized Algorithms" §7
-/

open Finset

/-! ## Core Hypergraph Definitions -/

/-- The degree of vertex `v` in hypergraph `H`: number of edges containing `v`. -/
def vertexDegree (H : Finset (Finset ℕ)) (v : ℕ) : ℕ :=
  (H.filter fun e => v ∈ e).card

/-- A set `T` is a hitting set (transversal) of hypergraph `H` if `T`
    intersects every edge. -/
def IsHittingSet (T : Finset ℕ) (H : Finset (Finset ℕ)) : Prop :=
  ∀ e ∈ H, (e ∩ T).Nonempty

/-- A family `S` of sets is a sunflower with kernel `c` if `c ⊆ e` for all
    `e ∈ S` and distinct members intersect exactly in `c`. -/
def IsSunflowerOn (S : Finset (Finset ℕ)) (c : Finset ℕ) : Prop :=
  (∀ e ∈ S, c ⊆ e) ∧
  (∀ e₁ ∈ S, ∀ e₂ ∈ S, e₁ ≠ e₂ → e₁ ∩ e₂ = c)

/-- A vertex `v` is overlap-rich at threshold `t` if at least `t` edges
    contain it. -/
def OverlapRich (H : Finset (Finset ℕ)) (v : ℕ) (t : ℕ) : Prop :=
  t ≤ vertexDegree H v

/-- `HasPetalFamilyWithCore H c m` holds when `H` contains a sunflower with
    kernel `c` having exactly `m` petals. This is a sunflower-oriented
    refinement of overlap-richness. -/
def HasPetalFamilyWithCore (H : Finset (Finset ℕ)) (c : Finset ℕ) (m : ℕ) : Prop :=
  ∃ S ⊆ H, S.card = m ∧ IsSunflowerOn S c

/-- The Pythagorean edge predicate: a < b < c, all in {1,…,n}, and a² + b² = c². -/
def IsPythagoreanEdge (n a b c : ℕ) : Prop :=
  1 ≤ a ∧ a < b ∧ b < c ∧ c ≤ n ∧ a ^ 2 + b ^ 2 = c ^ 2

instance (n a b c : ℕ) : Decidable (IsPythagoreanEdge n a b c) := by
  unfold IsPythagoreanEdge; infer_instance

/-- The Pythagorean hypergraph on {1,…,n}: all triples {a,b,c} with
    a < b < c ≤ n and a² + b² = c². Each edge is the Finset {a, b, c}. -/
noncomputable def pythagoreanEdges (n : ℕ) : Finset (Finset ℕ) :=
  ((Finset.Icc 1 n ×ˢ Finset.Icc 1 n ×ˢ Finset.Icc 1 n).filter
    fun t => IsPythagoreanEdge n t.1 t.2.1 t.2.2).image
    fun t => ({t.1, t.2.1, t.2.2} : Finset ℕ)

/-- Naive branching call count: branching factor `r` with budget `k` gives r^k nodes. -/
def recursiveCallsNaive (r k : ℕ) : ℕ := r ^ k

/-- Sunflower-pruned branching: core of size `s` gives s^k nodes. -/
def recursiveCallsSunflower (s k : ℕ) : ℕ := s ^ k

/-! ## Theorem 1: Incidence Double-Counting (Cross-Domain: Incidence Geometry) -/

/-
**Incidence identity**: ∑_{v ∈ V} deg_H(v) = ∑_{e ∈ H} |e|.
    This is the fundamental double-counting identity connecting
    incidence geometry to hypergraph theory.
-/
theorem incidence_double_counting
    (H : Finset (Finset ℕ)) (V : Finset ℕ)
    (hV : ∀ e ∈ H, e ⊆ V) :
    ∑ v ∈ V, vertexDegree H v = ∑ e ∈ H, e.card := by
  -- By definition of vertex degree, we can rewrite the left-hand side as the sum over all edges of the number of vertices in each edge.
  have h_deg : ∑ v ∈ V, vertexDegree H v = ∑ v ∈ V, ∑ e ∈ H, if v ∈ e then 1 else 0 := by
    simp +decide [ vertexDegree ];
  rw [ h_deg, Finset.sum_comm ];
  simp +decide [ Finset.sum_boole, Finset.filter_mem_eq_inter, Finset.inter_eq_right.mpr ( hV _ _ ) ];
  exact Finset.sum_congr rfl fun x hx => by rw [ Finset.inter_eq_right.mpr ( hV x hx ) ] ;

/-
**Corollary**: For `r`-uniform hypergraphs, ∑ deg(v) = r · |E|.
-/
theorem incidence_sum_eq_uniformity_mul_edges
    (H : Finset (Finset ℕ)) (V : Finset ℕ) (r : ℕ)
    (hV : ∀ e ∈ H, e ⊆ V)
    (hUnif : ∀ e ∈ H, e.card = r) :
    ∑ v ∈ V, vertexDegree H v = r * H.card := by
  rw [ incidence_double_counting ];
  · rw [ Finset.sum_congr rfl hUnif, Finset.sum_const, smul_eq_mul, mul_comm ];
  · assumption

/-
**Averaging principle**: some vertex has degree ≥ `d` when the total
    incidence count is at least `d * |V|`.
-/
theorem exists_vertex_large_degree
    (H : Finset (Finset ℕ)) (V : Finset ℕ) (d : ℕ)
    (hV : V.Nonempty)
    (hsum : d * V.card ≤ ∑ v ∈ V, vertexDegree H v) :
    ∃ v ∈ V, d ≤ vertexDegree H v := by
  contrapose! hsum;
  simpa [ mul_comm ] using Finset.sum_lt_sum_of_nonempty hV hsum

/-! ## Theorem 2: Sunflower Core Hitting (Algorithmic Correctness) -/

/-
**Sunflower core hitting theorem**: if `S ⊆ H` is a sunflower with core `c`,
    `T` is a hitting set of `H` with `|T| ≤ k`, and `|S| > k`, then `T` must
    intersect the core `c`.

    *Proof sketch*: If `T ∩ c = ∅`, then for each `e ∈ S`, `T` must hit `e`
    in `e \ c` (the petal). Since petals are pairwise disjoint by the sunflower
    property, `T` contains ≥ |S| > k elements, contradicting `|T| ≤ k`.
-/
theorem hitting_set_must_hit_sunflower_core
    (H S : Finset (Finset ℕ)) (c T : Finset ℕ) (k : ℕ)
    (hSsub : S ⊆ H)
    (hSun : IsSunflowerOn S c)
    (hCard : k < S.card)
    (hHit : IsHittingSet T H)
    (hSize : T.card ≤ k) :
    (c ∩ T).Nonempty := by
  by_contra hCard; have := hSun.2; simp_all +decide [ IsHittingSet ] ;
  -- Define a function `f` that maps each edge in `S` to an element in `T` that intersects it.
  obtain ⟨f, hf⟩ : ∃ f : Finset ℕ → ℕ, (∀ e ∈ S, f e ∈ e ∩ T) ∧ (∀ e ∈ S, ∀ e' ∈ S, e ≠ e' → f e ≠ f e') := by
    choose! f hf using fun e he => hHit e ( hSsub he );
    refine' ⟨ f, hf, fun e he e' he' hee' h => _ ⟩ ; have := hf e he; have := hf e' he'; simp_all +decide [ Finset.ext_iff ] ;
    grind +revert;
  -- Since `f` is injective, the image of `S` under `f` has cardinality at least `#S`.
  have h_image_card : (Finset.image f S).card ≥ S.card := by
    rw [ Finset.card_image_of_injOn fun e he e' he' hee' => by contrapose! hee'; exact hf.2 e he e' he' hee' ]
  generalize_proofs at *; (
  exact absurd h_image_card ( by exact not_le_of_gt ( lt_of_le_of_lt ( Finset.card_le_card ( Finset.image_subset_iff.mpr fun e he => Finset.mem_coe.mpr <| Finset.mem_coe.mpr <| Finset.mem_of_mem_inter_right <| hf.1 e he ) ) <| by linarith ) ) ;)

/-
**Bounded hitting set forces heavy vertex**: if vertex `v` has degree > k
    and the incident edges form a sunflower with core {v}, then every hitting
    set of size ≤ k must contain `v`.
-/
theorem bounded_hitting_set_forces_heavy_vertex
    (H : Finset (Finset ℕ)) (v : ℕ) (k : ℕ)
    (hSun : IsSunflowerOn (H.filter fun e => v ∈ e) {v})
    (hDeg : k < vertexDegree H v)
    (T : Finset ℕ)
    (hHit : IsHittingSet T H)
    (hSize : T.card ≤ k) :
    v ∈ T := by
  contrapose! hDeg; ( have := @hitting_set_must_hit_sunflower_core H ( H.filter fun e => v ∈ e ) { v } T k; aesop; )

/-! ## Theorem 3: Search Tree Domination -/

/-
**Sunflower branching dominates naive branching**: when core size s ≤ edge
    size r, pruned search explores ≤ nodes.
-/
theorem sunflower_branching_le_naive
    (s r k : ℕ) (h : s ≤ r) :
    recursiveCallsSunflower s k ≤ recursiveCallsNaive r k := by
  exact Nat.pow_le_pow_left h _

/-
**Strict improvement** when core is strictly smaller than edge size.
-/
theorem sunflower_branching_strict_lt
    (s r k : ℕ) (hs : s < r) (hk : 1 ≤ k) :
    recursiveCallsSunflower s k < recursiveCallsNaive r k := by
  exact Nat.pow_lt_pow_left hs ( by linarith )

/-! ## Cross-Domain: Parameterized Complexity (Kernelization) -/

/-
**Sunflower reduction preserves hitting set**: replacing a large sunflower
    `S ⊆ H` with its core `c` preserves the property that `T` is a hitting
    set. This is the key FPT kernelization step.

    *Proof*: Any edge in `(H \ S) ∪ {c}` is either:
    (a) an edge of `H \ S`, already hit by `T`; or
    (b) the core `c`, which `T` must hit by the sunflower core theorem.
-/
theorem sunflower_reduction_preserves_hitting_set
    (H S : Finset (Finset ℕ)) (c T : Finset ℕ) (k : ℕ)
    (hSsub : S ⊆ H)
    (hSun : IsSunflowerOn S c)
    (hCard : k < S.card)
    (hHit : IsHittingSet T H)
    (hSize : T.card ≤ k) :
    IsHittingSet T (insert c (H \ S)) := by
  -- By definition of IsHittingSet, we need to show that for any edge e in (H \ S) ∪ {c}, T intersects e.
  intro e he
  cases' Finset.mem_insert.mp he with heS heC;
  · convert hitting_set_must_hit_sunflower_core H S c T k hSsub hSun hCard hHit hSize using 1;
    rw [heS];
  · exact hHit _ ( Finset.mem_sdiff.mp heC |>.1 )

/-
**Singleton-core exponential gain**: for 3-uniform hypergraphs with
    singleton sunflower cores, the pruning gain is exponential in budget k.
    This is the quantitative payoff of arithmetic overlap concentration.
-/
theorem singleton_core_exponential_gain (k : ℕ) (hk : 1 ≤ k) :
    recursiveCallsSunflower 1 k < recursiveCallsNaive 3 k := by
  convert sunflower_branching_strict_lt 1 3 k ( by norm_num ) hk using 1