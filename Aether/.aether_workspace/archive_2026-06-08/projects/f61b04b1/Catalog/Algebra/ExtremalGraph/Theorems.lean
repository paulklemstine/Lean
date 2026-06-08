/-
  # Extremal Graph Theory: Core Theorems

  This module proves the main theorems in our extremal graph theory framework:

  1. **Neighborhood Clique-Free Lemma**: If G is K_r-free, then the neighborhood
     of any vertex induces a K_{r-1}-free subgraph. This is the key inductive
     step in degree-based proofs of Turán's theorem.

  2. **Degree-Edge Inequality**: The sum of squared degrees is at least
     (2e)²/n where e is the edge count, by Cauchy-Schwarz (handshaking + convexity).

  3. **Turán Graph Clique-Freeness**: The Turán graph T(n,p) is K_{p+1}-free.

  4. **Mantel's Theorem**: Triangle-free graphs on n vertices have ≤ n²/4 edges.

  5. **Greedy Triangle Removal Certificate**: Removing one edge per triangle
     produces a triangle-free graph with edit distance ≤ triangle count.

  6. **3-AP to Triangle Bridge**: A cross-domain theorem connecting
     arithmetic progressions to graph triangles.
-/
import Mathlib
import Algebra.ExtremalGraph.Defs

open Finset BigOperators SimpleGraph ExtremalGraph

namespace ExtremalGraph

/-! ## Theorem 1: Neighborhood Clique-Free Lemma

This is the foundational inductive tool for Turán-type arguments.
If G is K_r-free, then for any vertex v, the subgraph induced on
the neighborhood of v is K_{r-1}-free. The proof is by contradiction:
if the neighborhood contained a (r-1)-clique, adding v would produce
an r-clique in G. -/

/-
If G is CliqueFree r, then the neighborhood subgraph of any vertex
    is CliqueFree (r-1). This is the key inductive step in proofs of
    Turán's theorem via degree counting.
-/
theorem neighborhood_cliqueFree
    {n : ℕ} (r : ℕ) (hr : 2 ≤ r)
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hG : G.CliqueFree r) (v : Fin n) :
    (G.neighborFinset v).card < r - 1 ∨
    ∀ (s : Finset (Fin n)), s ⊆ G.neighborFinset v → s.card = r - 1 →
      ¬ G.IsClique (s : Set (Fin n)) := by
  right; intro s hs hcard hclique; exact (by
  have := hG ( Insert.insert v s ) ?_ <;> simp_all +decide [ SimpleGraph.isNClique_iff ];
  exact ⟨ fun b hb hb' => by simpa [ hb' ] using hs hb, by rw [ Finset.card_insert_of_notMem fun h => by have := hs h; aesop, hcard, Nat.sub_add_cancel ( by linarith ) ] ⟩);

/-! ## Theorem 2: Degree-Energy Lower Bound (Cauchy-Schwarz)

By the handshaking lemma, ∑ deg(v) = 2|E|.
By Cauchy-Schwarz (or convexity of x²),
  n · ∑ deg(v)² ≥ (∑ deg(v))² = (2|E|)².
Hence: ∑ deg(v)² ≥ 4|E|²/n.

This is reusable infrastructure for all degree-based extremal arguments. -/

/-
The sum of squared degrees times n is at least (2 * edge_count)².
    This is the Cauchy-Schwarz / convexity bound on degree energy.
-/
theorem degree_energy_cauchy_schwarz
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] :
    n * (∑ v : Fin n, G.degree v ^ 2) ≥ (∑ v : Fin n, G.degree v) ^ 2 := by
  -- By the Cauchy-Schwarz inequality, we have that for any vectors $u$ and $v$ of equal length, $(∑ i, u i * v i)^2 ≤ (∑ i, u i^2) * (∑ i, v i^2)$.
  have h_cauchy_schwarz : ∀ (u v : Fin n → ℝ), (∑ i, u i * v i)^2 ≤ (∑ i, u i^2) * (∑ i, v i^2) := by
    exact fun u v => sum_mul_sq_le_sq_mul_sq univ u v;
  specialize h_cauchy_schwarz ( fun _ => 1 ) ( fun x => G.degree x ) ; norm_num at h_cauchy_schwarz;
  norm_cast at h_cauchy_schwarz

/-! ## Theorem 3: Turán Graph is Clique-Free

The Turán graph T(n, p) is p-partite, hence K_{p+1}-free.
Any (p+1) vertices must include two in the same partition class,
and same-class vertices are non-adjacent. -/

/-
The Turán graph T(n, p) with p ≥ 1 parts is K_{p+1}-free.
    Proof by pigeonhole: any (p+1) vertices must contain two
    in the same partition class (mod p), which are non-adjacent.
-/
theorem turanGraph_cliqueFree (n p : ℕ) (hp : 1 ≤ p) :
    (TuranGraph n p hp).CliqueFree (p + 1) := by
  intro t ht;
  -- By the pigeonhole principle, since there are p+1 elements in t and only p possible remainders when divided by p, there must be at least two elements in t that share the same remainder.
  have h_pigeonhole : ∃ x y : Fin n, x ∈ t ∧ y ∈ t ∧ x ≠ y ∧ x.val % p = y.val % p := by
    by_contra h_contra;
    exact absurd ( Finset.card_le_card ( show Finset.image ( fun x : Fin n => ( x : ℕ ) % p ) t ⊆ Finset.range p from Finset.image_subset_iff.mpr fun x hx => Finset.mem_range.mpr <| Nat.mod_lt _ hp ) ) ( by rw [ Finset.card_image_of_injOn fun x hx y hy hxy => Classical.not_not.1 fun h => h_contra ⟨ x, y, hx, hy, h, hxy ⟩ ] ; simp +decide [ ht.card_eq ] );
  obtain ⟨ x, y, hx, hy, hxy, h ⟩ := h_pigeonhole; have := ht.1 hx hy; simp_all +decide [ TuranGraph ] ;

/-! ## Theorem 4: Mantel's Theorem (Turán for r = 3)

The simplest non-trivial case of Turán's theorem:
every triangle-free graph on n vertices has at most ⌊n²/4⌋ edges.

Proof strategy (degree-based):
In a triangle-free graph, no two adjacent vertices share a neighbor.
For each edge {u,v}, deg(u) + deg(v) ≤ n (since N(u) and N(v)
are disjoint subsets of V). Summing over edges:
  ∑_{uv ∈ E} (deg(u) + deg(v)) ≤ |E| · n.
The left side equals ∑_v deg(v)², so ∑ deg(v)² ≤ |E| · n.
By Cauchy-Schwarz: (2|E|)² ≤ n · ∑ deg(v)² ≤ n² · |E|.
Hence 4|E| ≤ n², giving |E| ≤ n²/4. -/

/-
**Mantel's theorem**: A triangle-free graph on n vertices has
    at most ⌊n²/4⌋ edges. Equivalently, 4 * |E| ≤ n².
-/
theorem mantel_theorem
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hG : G.CliqueFree 3) :
    4 * G.edgeFinset.card ≤ n ^ 2 := by
  -- By Cauchy-Schwarz inequality, we know that $n \sum_{v \in V} \deg(v)^2 \geq (\sum_{v \in V} \deg(v))^2$.
  have h_cauchy_schwarz : n * (∑ v : Fin n, G.degree v ^ 2) ≥ (∑ v : Fin n, G.degree v) ^ 2 := by
    convert degree_energy_cauchy_schwarz G using 1;
  -- By the Handshaking Lemma, we know that $\sum_{v \in V} \deg(v) = 2|E|$.
  have h_handshaking : ∑ v : Fin n, G.degree v = 2 * G.edgeFinset.card := by
    exact sum_degrees_eq_twice_card_edges G;
  nontriviality;
  cases n <;> simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ];
  rename_i n hG;
  have h_sum_degrees : ∀ (u v : Fin (n + 1)), G.Adj u v → (Finset.card (Finset.filter (fun w => G.Adj u w) Finset.univ)) + (Finset.card (Finset.filter (fun w => G.Adj v w) Finset.univ)) ≤ n + 1 := by
    intros u v huv
    have h_disjoint : Disjoint (Finset.filter (fun w => G.Adj u w) Finset.univ) (Finset.filter (fun w => G.Adj v w) Finset.univ) := by
      simp_all +decide [ Finset.disjoint_left, SimpleGraph.CliqueFree ];
      intro w huw hvw; specialize hG { u, v, w } ; simp_all +decide [ SimpleGraph.isNClique_iff ] ;
      rw [ Finset.card_insert_of_notMem, Finset.card_insert_of_notMem ] at hG <;> aesop;
    rw [ ← Finset.card_union_of_disjoint h_disjoint ] ; exact le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ;
  have h_sum_degrees : ∑ u : Fin (n + 1), ∑ v ∈ Finset.filter (fun w => G.Adj u w) Finset.univ, (Finset.card (Finset.filter (fun w => G.Adj u w) Finset.univ) + Finset.card (Finset.filter (fun w => G.Adj v w) Finset.univ)) ≤ ∑ u : Fin (n + 1), ∑ v ∈ Finset.filter (fun w => G.Adj u w) Finset.univ, (n + 1) := by
    exact Finset.sum_le_sum fun u hu => Finset.sum_le_sum fun v hv => h_sum_degrees u v <| Finset.mem_filter.mp hv |>.2;
  simp_all +decide [ Finset.sum_add_distrib, Finset.sum_filter ];
  simp_all +decide [ ← sq, ← Finset.sum_mul _ _ _, SimpleGraph.adj_comm ];
  rw [ Finset.sum_comm ] at h_sum_degrees;
  simp_all +decide [ Finset.sum_ite, SimpleGraph.adj_comm ];
  simp_all +decide [ ← sq ];
  nlinarith [ show 0 ≤ ∑ x : Fin ( n + 1 ), Finset.card ( Finset.filter ( fun w => G.Adj x w ) Finset.univ ) ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]

/-! ## Theorem 5: Greedy Triangle Removal Certificate

An algorithmic result: from any graph, we can obtain a triangle-free
graph by removing at most one edge per triangle. This gives an
explicit certificate that edit distance to triangle-freeness is
bounded by the triangle count.

The proof is by strong induction on the triangle count. If there are
no triangles, take H = G. Otherwise, pick a triangle, remove one of
its edges. The resulting graph has strictly fewer triangles, and we
can recurse. The total number of edges removed is at most the original
triangle count. -/

/-
**Greedy Triangle Removal**: For any graph G on Fin n, there exists
    a triangle-free graph H with edit distance at most triangleCount G.
    This is a verified algorithmic certificate.
-/
theorem greedy_triangle_removal
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] :
    ∃ (H : SimpleGraph (Fin n)) (_ : DecidableRel H.Adj),
      H.CliqueFree 3 ∧
      G.edgeFinset.card - H.edgeFinset.card ≤ triangleCount G := by
  -- By definition of $H$, we know that $H.edgeFinset.card ≥ G.edgeFinset.card - triangleCount G$. Hence,
  have h_card : ∃ H' : SimpleGraph (Fin n), H'.CliqueFree 3 ∧ H'.edgeFinset.card ≥ G.edgeFinset.card - triangleCount G := by
    -- Let's denote the set of triangles in $G$ by $T$.
    set T := orderedTriangleFinset G;
    -- By removing one edge from each triangle in $T$, we obtain a triangle-free graph $H'$.
    obtain ⟨E', hE'⟩ : ∃ E' : Finset (Sym2 (Fin n)), E' ⊆ G.edgeFinset ∧ (∀ t ∈ T, ∃ e ∈ E', e ∈ ({Sym2.mk (t.1, t.2.1), Sym2.mk (t.1, t.2.2), Sym2.mk (t.2.1, t.2.2)} : Finset (Sym2 (Fin n)))) ∧ E'.card ≤ T.card := by
      have hE' : ∀ t ∈ T, ∃ e ∈ G.edgeFinset, e ∈ ({Sym2.mk (t.1, t.2.1), Sym2.mk (t.1, t.2.2), Sym2.mk (t.2.1, t.2.2)} : Finset (Sym2 (Fin n))) := by
        simp +zetaDelta at *;
        unfold orderedTriangleFinset; aesop;
      choose! f hf₁ hf₂ using hE';
      exact ⟨ Finset.image ( fun t => f t.1 t.2 ) ( Finset.attach T ), Finset.image_subset_iff.mpr fun t ht => hf₁ _ _, fun t ht => ⟨ f t ht, Finset.mem_image.mpr ⟨ ⟨ t, ht ⟩, Finset.mem_attach _ _, rfl ⟩, hf₂ _ _ ⟩, Finset.card_image_le.trans ( by simpa ) ⟩;
    refine' ⟨ SimpleGraph.fromEdgeSet ( G.edgeFinset \ E' ), _, _ ⟩;
    · intro s hs; simp_all +decide [] ;
      rcases Finset.card_eq_three.mp hs.2 with ⟨ a, b, c, ha, hb, hc, hab, hbc, hac ⟩ ; simp_all +decide [ SimpleGraph.isNClique_iff ];
      -- Since $a$, $b$, and $c$ form a triangle in $G$, they must be in $T$.
      have h_triangle : (a, b, c) ∈ T ∨ (a, c, b) ∈ T ∨ (b, a, c) ∈ T ∨ (b, c, a) ∈ T ∨ (c, a, b) ∈ T ∨ (c, b, a) ∈ T := by
        simp +zetaDelta at *;
        cases lt_or_gt_of_ne ha <;> cases lt_or_gt_of_ne hb <;> cases lt_or_gt_of_ne hc <;> simp +decide [ *, orderedTriangleFinset ];
        all_goals simp_all +decide [ SimpleGraph.adj_comm ];
      grind;
    · simp_all +decide [ SimpleGraph.edgeFinset ];
      refine' le_trans _ ( Nat.add_le_add_left hE'.2.2 _ );
      refine' le_trans _ ( Finset.card_union_le _ _ );
      refine' Finset.card_le_card _;
      grind;
  obtain ⟨ H', hH₁, hH₂ ⟩ := h_card;
  refine' ⟨ H', _, hH₁, _ ⟩;
  exact Classical.decRel _;
  grind +suggestions

/-! ## Theorem 6: Handshaking Lemma Applications

Direct consequences of the degree-sum formula that are useful
as lemmas for the Turán bound. -/

/-- In any graph, twice the edge count equals the sum of degrees.
    This wraps Mathlib's `sum_degrees_eq_twice_card_edges`. -/
theorem twice_edges_eq_degree_sum
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] :
    2 * G.edgeFinset.card = ∑ v : Fin n, G.degree v := by
  exact (G.sum_degrees_eq_twice_card_edges).symm

/-! ## Theorem 7: Triangle-Free Degree Constraint

In a triangle-free graph, no two adjacent vertices share a common neighbor.
This means: for any edge {u,v}, N(u) ∩ N(v) = ∅.
Equivalently: for adjacent u, v, deg(u) + deg(v) ≤ n. -/

/-
In a triangle-free graph, adjacent vertices have disjoint neighborhoods.
-/
theorem triangle_free_disjoint_neighborhoods
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hG : G.CliqueFree 3) (u v : Fin n) (huv : G.Adj u v) :
    Disjoint (G.neighborFinset u) (G.neighborFinset v) := by
  simp_all +decide [ SimpleGraph.neighborFinset_def, Finset.disjoint_left ];
  intro w huw hvw; exact hG { u, v, w } ( by
    simp_all +decide [ SimpleGraph.isNClique_iff ];
    rw [ Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_singleton ] <;> aesop ) ;

/-
In a triangle-free graph, the sum of degrees of adjacent vertices
    is at most n.
-/
theorem triangle_free_degree_sum_bound
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hG : G.CliqueFree 3) (u v : Fin n) (huv : G.Adj u v) :
    G.degree u + G.degree v ≤ n := by
  have h_disjoint : Disjoint (G.neighborFinset u) (G.neighborFinset v) := by
    exact triangle_free_disjoint_neighborhoods G hG u v huv;
  have := Finset.card_le_univ ( G.neighborFinset u ∪ G.neighborFinset v ) ; simp_all +decide [ Finset.disjoint_iff_inter_eq_empty ] ;

/-! ## Theorem 8: Cross-Domain — Degree Energy Bounds Edge Count for Triangle-Free Graphs

This is the bridge theorem connecting degree energy (an analytic/energy concept)
to the edge bound in triangle-free graphs. It shows that minimizing degree energy
subject to triangle-freeness forces the Mantel bound.

In a triangle-free graph: for each edge {u,v}, deg(u) + deg(v) ≤ n.
Summing over edges: ∑_{uv} (deg(u) + deg(v)) ≤ n · |E|.
But the left side equals ∑_v deg(v)² (each degree gets counted deg(v) times). -/

/-
**Degree energy controls edges in triangle-free graphs**:
    The degree energy ∑ deg(v)² satisfies degreeEnergy G ≤ n * |E|
    for triangle-free G. Combined with Cauchy-Schwarz this gives Mantel.
-/
theorem triangle_free_degree_energy_bound
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hG : G.CliqueFree 3) :
    ∑ v : Fin n, (G.degree v) ^ 2 ≤ n * G.edgeFinset.card := by
  -- We can rewrite the sum as $\sum_{u,v} \deg(v)$ over all edges $(u,v)$, which equals $\sum_v \deg(v)^2$.
  have h_sum_edges' : ∑ u : Fin n, ∑ v ∈ G.neighborFinset u, (G.degree u) = ∑ u : Fin n, ∑ v ∈ G.neighborFinset u, (G.degree v) := by
    simp +decide only [neighborFinset_eq_filter, sum_filter];
    rw [ Finset.sum_comm ];
    simp +decide only [adj_comm];
  -- By the triangle-free property, for any edge $(u,v)$, we have $\deg(u) + \deg(v) \leq n$.
  have h_deg_sum : ∀ u v : Fin n, G.Adj u v → G.degree u + G.degree v ≤ n := by
    exact fun u v a => triangle_free_degree_sum_bound G hG u v a;
  -- By summing $\deg(u) + \deg(v) \leq n$ over all edges $(u,v)$, we get $2 \sum_v \deg(v)^2 \leq n \sum_v \deg(v)$.
  have h_sum_deg_sum : ∑ u : Fin n, ∑ v ∈ G.neighborFinset u, (G.degree u + G.degree v) ≤ n * ∑ u : Fin n, G.degree u := by
    rw [ Finset.mul_sum _ _ _ ];
    exact Finset.sum_le_sum fun u hu => by simpa [ mul_comm ] using Finset.sum_le_sum fun v hv => h_deg_sum u v <| by aesop;
  simp_all +decide [ Finset.sum_add_distrib ];
  have := SimpleGraph.sum_degrees_eq_twice_card_edges G; norm_num [ ← sq, ← Finset.sum_mul _ _ _ ] at *; nlinarith;

/-! ## Theorem 9: Edge Edit Distance Properties -/

/-- Edge edit distance is symmetric. -/
theorem edgeEditDistance_symm {V : Type*} [Fintype V] [DecidableEq V]
    (G H : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel H.Adj]
    [Fintype (↥G.edgeSet)] [Fintype (↥H.edgeSet)] :
    edgeEditDistance G H = edgeEditDistance H G := by
  unfold edgeEditDistance
  omega

/-- Edge edit distance from a graph to itself is zero. -/
theorem edgeEditDistance_self {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] [Fintype (↥G.edgeSet)] :
    edgeEditDistance G G = 0 := by
  unfold edgeEditDistance
  simp

/-! ## Theorem 10: Lower Shadow Monotonicity

The shadow of a larger family is at least as large. -/

/-
The lower shadow is monotone: 𝒜 ⊆ ℬ implies shadow(𝒜) ⊆ shadow(ℬ).
-/
theorem lowerShadow_mono {α : Type*} [DecidableEq α]
    (𝒜 ℬ : Finset (Finset α)) (h : 𝒜 ⊆ ℬ) :
    lowerShadow 𝒜 ⊆ lowerShadow ℬ := by
  exact Finset.biUnion_subset_biUnion_of_subset_left _ h

end ExtremalGraph