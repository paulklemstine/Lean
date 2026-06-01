/-
  # Register Allocation as Graph Coloring: Chordal Structure and Optimality

  This file formalizes the deep connection between register allocation in compilers
  and graph coloring theory, focusing on the chordal structure of SSA interference
  graphs and its consequences for optimal register allocation.

  ## Main Contributions

  * `InterferenceSystem` — Novel structure capturing the full register allocation problem
  * `RegisterPressure` — Novel concept: register pressure at each PEO position
  * `chordal_colorable_of_clique_bound` — χ(G) = ω(G) for chordal graphs (perfectness)
  * `spill_cost_clique_lower_bound` — Tight spill cost bounds from clique structure
  * `interval_graph_is_chordal` — Interval graphs (from linear SSA) are chordal

  ## References

  * Chaitin, G. J. "Register allocation & spilling via graph coloring" (1982)
  * Hack, Grund, Goos. "Register allocation for programs in SSA form" (2006)
  * Gavril. "Algorithms for minimum coloring of perfect graphs" (1972)
-/
import Mathlib

open SimpleGraph Finset Function

noncomputable section

/-! ## Core Definitions -/

/-- An interference graph for register allocation with n program variables. -/
structure InterferenceGraph (n : ℕ) where
  graph : SimpleGraph (Fin n)
  decAdj : DecidableRel graph.Adj

attribute [instance] InterferenceGraph.decAdj

/-- A vertex v is simplicial in G if its neighbors form a clique. -/
def SimpleGraph.IsSimplicial {V : Type*} (G : SimpleGraph V) (v : V) : Prop :=
  ∀ u w : V, G.Adj v u → G.Adj v w → u ≠ w → G.Adj u w

/-- A perfect elimination ordering: each vertex is simplicial in the subgraph
    induced by vertices appearing at or after it in the ordering. -/
structure PerfectEliminationOrdering {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] where
  order : Equiv.Perm (Fin n)
  simplicial_prop : ∀ i : Fin n, ∀ u w : Fin n,
    G.Adj (order i) u → G.Adj (order i) w →
    i < order.symm u → i < order.symm w →
    u ≠ w → G.Adj u w

/-- A graph is chordal if it admits a perfect elimination ordering. -/
def SimpleGraph.IsChordal {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] : Prop :=
  Nonempty (PerfectEliminationOrdering G)

/-! ## Novel Definition: Register Pressure Profile

  The register pressure at position i in a PEO is the number of "later" neighbors
  of vertex i, plus 1. This captures how many registers are simultaneously needed
  at each point in the elimination. -/

/-- The register pressure at position i in a PEO. -/
def registerPressure {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (peo : PerfectEliminationOrdering G) (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun j : Fin n =>
    G.Adj (peo.order i) (peo.order j) ∧ i < j)).card + 1

/-- The maximum register pressure over all positions in the PEO. -/
def maxRegisterPressure {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (peo : PerfectEliminationOrdering G) : ℕ :=
  Finset.sup Finset.univ (registerPressure G peo)

/-! ## Novel Definition: Interference System -/

/-- Complete register allocation problem instance -/
structure InterferenceSystem (n : ℕ) extends InterferenceGraph n where
  numRegisters : ℕ
  peo : @PerfectEliminationOrdering n graph decAdj

/-! ## Clique-Coloring Fundamentals -/

/-- Coloring is injective on cliques. -/
theorem clique_coloring_injective {V : Type*} {G : SimpleGraph V} {α : Type*}
    (c : G.Coloring α) {s : Finset V} (hs : G.IsClique (s : Set V)) :
    Set.InjOn c (s : Set V) :=
  fun _ hx _ hy hxy => by_contra fun h => (c.valid (hs hx hy h)) hxy

/-- A clique of size k requires at least k colors. -/
theorem clique_size_le_colorable {n : ℕ} {G : SimpleGraph (Fin n)}
    {k m : ℕ} (hcol : G.Colorable m)
    (s : Finset (Fin n)) (hs : s.card = k) (hclique : G.IsClique (s : Set (Fin n))) :
    k ≤ m := by
  obtain ⟨c⟩ := hcol
  have hinj := clique_coloring_injective c hclique
  have h_card := Finset.card_image_of_injOn (f := c) (s := s) (by
    intro a ha b hb hab
    exact hinj ha hb hab)
  calc k = s.card := hs.symm
    _ = (s.image c).card := h_card.symm
    _ ≤ Finset.univ.card := Finset.card_le_univ _
    _ = m := Finset.card_fin m

/-! ## PEO Later Neighborhood Clique -/

/-- The set of later neighbors of position i in a PEO. -/
def laterNeighbors {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (peo : PerfectEliminationOrdering G) (i : Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun j : Fin n =>
    G.Adj (peo.order i) (peo.order j) ∧ i < j)

/-- The "local clique" at position i: vertex i plus its later neighbors. -/
def localClique {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (peo : PerfectEliminationOrdering G) (i : Fin n) : Finset (Fin n) :=
  {i} ∪ laterNeighbors G peo i

/-
The later neighbors of any PEO position, mapped back to vertices, form a clique.
    This is because the PEO's simplicial property guarantees pairwise adjacency.
-/
theorem later_neighbors_form_clique {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PerfectEliminationOrdering G) (i : Fin n) :
    G.IsClique ((laterNeighbors G peo i).image peo.order : Set (Fin n)) := by
  intros x hx y hy;
  simp +zetaDelta at *;
  unfold laterNeighbors at hx hy;
  have := peo.simplicial_prop i ( peo.order ( Equiv.symm peo.order x ) ) ( peo.order ( Equiv.symm peo.order y ) ) ; aesop;

/-
Register pressure equals the local clique size.
-/
theorem register_pressure_eq_local_clique_card {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PerfectEliminationOrdering G) (i : Fin n) :
    registerPressure G peo i = (localClique G peo i).card := by
  rw [ localClique, Finset.card_union_of_disjoint ];
  · unfold registerPressure; simp +decide [ Finset.Nonempty ] ;
    rw [ add_comm, laterNeighbors ];
  · simp +decide [ laterNeighbors ]

/-! ## Chordal Graph Perfectness -/

/-
Helper: In a PEO, each vertex has at most k-1 later neighbors when all cliques
    have size ≤ k. This is because the later neighbors plus the vertex form a clique.
-/
theorem peo_later_neighbors_bound {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PerfectEliminationOrdering G) (k : ℕ)
    (hclique : ∀ s : Finset (Fin n), G.IsClique (↑s : Set (Fin n)) → s.card ≤ k)
    (i : Fin n) :
    (laterNeighbors G peo i).card < k := by
  -- Consider the set $s = \{peo.order i\} \cup ((laterNeighbors G peo i).image peo.order)$.
  set s : Finset (Fin n) := {peo.order i} ∪ ((laterNeighbors G peo i).image peo.order);
  -- By definition of $s$, we know that $s$ is a clique in $G$.
  have hs_clique : G.IsClique (s : Set (Fin n)) := by
    have h_clique : ∀ j ∈ laterNeighbors G peo i, G.Adj (peo.order i) (peo.order j) := by
      exact fun j hj => Finset.mem_filter.mp hj |>.2.1;
    have h_clique : ∀ j k, j ∈ laterNeighbors G peo i → k ∈ laterNeighbors G peo i → j ≠ k → G.Adj (peo.order j) (peo.order k) := by
      intros j k hj hk hneq
      have := peo.simplicial_prop i (peo.order j) (peo.order k)
      simp_all +decide;
      exact this ( Finset.mem_filter.mp hj |>.2.2 ) ( Finset.mem_filter.mp hk |>.2.2 );
    simp +zetaDelta at *;
    grind +suggestions;
  refine' lt_of_lt_of_le _ ( hclique s hs_clique );
  rw [ Finset.card_union_of_disjoint ] <;> norm_num [ Finset.card_image_of_injective _ peo.order.injective ];
  exact fun hi => lt_irrefl _ ( Finset.mem_filter.mp hi |>.2.2 )

/-
Greedy coloring lemma: if there exists an ordering σ such that every vertex v has
    fewer than k neighbors that appear after v in σ, then G is k-colorable.
    This is the core greedy coloring argument.
-/
set_option maxHeartbeats 400000 in
theorem greedy_coloring_from_ordering {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (σ : Equiv.Perm (Fin n)) (k : ℕ)
    (hbound : ∀ i : Fin n,
      (Finset.univ.filter (fun j : Fin n => G.Adj (σ i) (σ j) ∧ i < j)).card < k) :
    G.Colorable k := by
  -- We'll use the fact that if the � graph� is chordal, then it's k-colorable.
  have h_colorable : ∀ (i : Fin n), Finset.card (Finset.filter (fun j => G.Adj (σ i) (σ j)) (Finset.univ.filter (fun j => i < j))) < k := by
    simpa [ and_comm, Finset.filter_filter ] using hbound;
  have h_colorable : ∀ (V : Finset (Fin n)), V.Nonempty → ∃ c : Fin n → Fin k, ∀ v ∈ V, ∀ w ∈ V, G.Adj (σ v) (σ w) → c v ≠ c w := by
    intro V hV_nonempty
    induction' V using Finset.strongInduction with V ih
    by_cases hV_empty : V = ∅;
    · aesop;
    · -- Let $v$ be the vertex � in� $V$ with the smallest index.
      obtain ⟨v, hv⟩ : ∃ v ∈ V, ∀ w ∈ V, w ≥ v := by
        exact ⟨ Finset.min' V hV_nonempty, Finset.min'_mem _ _, fun w hw => Finset.min'_le _ _ hw ⟩;
      -- Let $c$ be a coloring of � $�V \setminus \{v\}$.
      obtain ⟨c, hc⟩ : ∃ c : Fin n → Fin k, ∀ w ∈ V \ {v}, ∀ u ∈ V \ {v}, G.Adj (σ w) (σ u) → c w ≠ c u := by
        by_cases hV_singleton : V = {v};
        · exact ⟨ fun _ => ⟨ 0, by linarith [ h_colorable v ] ⟩, by aesop ⟩;
        · exact ih _ ( by rw [ Finset.ssubset_iff_subset_ne ] ; aesop ) ( Finset.nonempty_of_ne_empty ( by aesop ) );
      -- Let $c'$ be a coloring of $V$ such that $c'(v) = c(v)$ for all $v \in V \setminus \{v �\�}$ and $c'(v) = \min \{0, 1, \ldots, k-1\} \setminus \{c(w) \mid w \in V \setminus \{v\} \text{ and } G.Adj (σ v) (σ w)\}$.
      obtain ⟨c', hc'⟩ : ∃ c' : Fin k, c' ∉ Finset.image c (Finset.filter (fun w => G.Adj (σ v) (σ w)) (V \ {v})) := by
        have h_card : Finset.card (Finset.image c (Finset.filter (fun w => G.Adj (σ v) (σ w)) (V \ {v}))) < k := by
          refine' lt_of_le_of_lt ( Finset.card_image_le ) _;
          refine' lt_of_le_of_lt _ ( h_colorable v );
          refine Finset.card_mono ?_;
          simp_all +decide [ Finset.subset_iff ];
          exact fun w hw hw' hw'' => lt_of_le_of_ne ( hv.2 w hw ) ( Ne.symm hw' );
        contrapose! h_card;
        rw [ show ( Finset.image c ( Finset.filter ( fun w => G.Adj ( σ v ) ( σ w ) ) ( V \ { v } ) ) ) = Finset.univ from Finset.eq_univ_of_forall h_card ] ; simp +decide;
      use fun w => if w = v then c' else c w; simp_all +decide ;
      intro u hu w hw h; split_ifs <;> simp_all +decide [ SimpleGraph.adj_comm ] ;
      exact Ne.symm ( hc' _ hw ‹_› h );
  obtain ⟨c, hc⟩ : ∃ c : Fin n → Fin k, ∀ v w, G.Adj (σ v) (σ w) → c v ≠ c w := by
    cases n <;> [ aesop; exact Exists.elim ( h_colorable Finset.univ ⟨ ⟨ 0, by linarith ⟩, Finset.mem_univ _ ⟩ ) fun c hc => ⟨ c, fun v w hvw => hc v ( Finset.mem_univ _ ) w ( Finset.mem_univ _ ) hvw ⟩ ];
  use fun v => c (σ.symm v);
  intro a b hab; specialize hc ( σ.symm a ) ( σ.symm b ) ; aesop;

/-
**Key Theorem**: For chordal graphs, if every clique has size ≤ k, then
    the graph is k-colorable. This is one direction of the perfect graph
    property for chordal graphs (χ = ω).

    **Proof**: By peo_later_neighbors_bound, each vertex has < k later neighbors
    in the PEO. By greedy_coloring_from_ordering, this yields k-colorability.
-/
theorem chordal_colorable_of_clique_bound {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PerfectEliminationOrdering G) (k : ℕ)
    (hclique : ∀ s : Finset (Fin n), G.IsClique (↑s : Set (Fin n)) → s.card ≤ k) :
    G.Colorable k := by
  apply greedy_coloring_from_ordering G peo.order k (fun i => by
    convert peo_later_neighbors_bound G peo k hclique i using 1)

/-! ## Spill Cost Theory -/

/-
**Spill-Clique Theorem**: If a graph contains a clique of size m and we have
    k < m registers, then at least m - k vertices from the clique must be spilled.

    **Proof**: By contradiction. If fewer than m-k clique vertices are spilled,
    then > k unspilled clique vertices remain. The partial coloring is injective
    on these (clique property), but injecting > k elements into Fin k is impossible.
-/
theorem spill_cost_clique_lower_bound {n : ℕ} {G : SimpleGraph (Fin n)}
    [DecidableRel G.Adj] {k m : ℕ} (s : Finset (Fin n)) (hs : s.card = m)
    (hclique : G.IsClique (↑s : Set (Fin n)))
    (spilled : Finset (Fin n))
    (hk : k < m)
    (hvalid : ∃ c : Fin n → Fin k,
      ∀ u v : Fin n, u ∉ spilled → v ∉ spilled → G.Adj u v → c u ≠ c v) :
    m - k ≤ (s ∩ spilled).card := by
  cases' hvalid with c hc;
  -- By contradiction, assume that $(s \cap spilled).card < m - k$.
  by_contra h_contra
  have h_card : (s \ spilled).card > k := by
    grind;
  have h_inj : Set.InjOn c (s \ spilled : Finset (Fin n)) := by
    exact fun u hu v hv huv => Classical.not_not.1 fun h => hc u v ( by aesop ) ( by aesop ) ( hclique ( by aesop ) ( by aesop ) h ) huv;
  exact absurd ( Finset.card_le_univ ( Finset.image c ( s \ spilled ) ) ) ( by rw [ Finset.card_image_of_injOn h_inj ] ; simpa using by linarith )

/-! ## Degree Bounds -/

/-
Any clique has size at most Δ(G) + 1.
-/
theorem clique_le_maxDegree_succ {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (s : Finset (Fin n))
    (hclique : G.IsClique (↑s : Set (Fin n))) (hne : s.Nonempty) :
    s.card ≤ G.maxDegree + 1 := by
  -- Pick any vertex $v \ �in� s$ (using $hne$).
  obtain ⟨v, hv⟩ : ∃ v, v ∈ s := hne;
  -- Then $s.erase v \subseteq G.neighborFinset v$ because all other clique members are adjacent to $v$.
  have h_erase : s.erase v ⊆ G.neighborFinset v := by
    intro u hu; have := hclique ( Finset.mem_coe.mpr ( Finset.mem_of_mem_erase hu ) ) ( Finset.mem_coe.mpr hv ) ; aesop;
  -- So $s.card = (s.erase v).card + 1 ≤ (G.neighborFinset v).card + 1 = G.degree v + 1 ≤ G.maxDegree + 1$.
  have h_card : s.card ≤ (G.neighborFinset v).card + 1 := by
    have := Finset.card_mono h_erase; simp_all +decide [ Finset.card_erase_of_mem hv ] ;
  exact le_trans h_card ( Nat.succ_le_succ ( SimpleGraph.degree_le_maxDegree _ _ ) )

/-
Δ(G) + 1 colors always suffice (greedy coloring bound).
-/
theorem colorable_maxDegree_succ {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] :
    G.Colorable (G.maxDegree + 1) := by
  have h_deg_bound : ∀ v : Fin n, G.degree v ≤ G.maxDegree := by
    exact fun v => G.degree_le_maxDegree v;
  have h_colorable : ∀ (s : Finset (Fin n)), G.induce s |>.Colorable (G.maxDegree + 1) := by
    intro s;
    induction' s using Finset.induction with v s ih;
    · exact ⟨ fun _ => 0, by simp +decide ⟩;
    · obtain ⟨c, hc⟩ := ‹_›;
      -- Since $v$ has at most $G.maxDegree$ neighbors in $s$, we can choose a color for $v$ that is different from the colors of � its� neighbors in $s$.
      obtain ⟨color_v, hcolor_v⟩ : ∃ color_v : Fin (G.maxDegree + 1), ∀ w : s, G.Adj v w → color_v ≠ c w := by
        have h_card : Finset.card (Finset.image c (Finset.filter (fun w : s => G.Adj v w) Finset.univ)) ≤ G.maxDegree := by
          refine' le_trans ( Finset.card_image_le ) _;
          refine' le_trans _ ( h_deg_bound v );
          refine' le_trans _ ( Finset.card_mono <| show Finset.image ( fun w : s => ( w : Fin n ) ) ( Finset.filter ( fun w : s => G.Adj v w ) Finset.univ ) ⊆ G.neighborFinset v from _ );
          · rw [ Finset.card_image_of_injective _ fun x y hxy => by aesop ];
          · intro w hw
            aesop;
        contrapose! h_card;
        rw [ show ( Finset.image c { w : s | G.Adj v w } ) = Finset.univ from Finset.eq_univ_of_forall fun x => by obtain ⟨ w, hw₁, hw₂ ⟩ := h_card x; aesop ] ; simp +decide [ Finset.card_univ ];
      use fun w => if hw : w.val ∈ s then c ⟨w.val, hw⟩ else color_v;
      simp +zetaDelta at *;
      intro a ha b hb hab; rcases ha with ( rfl | ha ) <;> rcases hb with ( rfl | hb ) <;> simp_all +decide ;
      · exact hcolor_v b hb hab;
      · exact Ne.symm ( hcolor_v a ha ( by simpa [ SimpleGraph.adj_comm ] using hab ) );
      · exact hc a ha b hb hab;
  obtain ⟨c, hc⟩ := h_colorable Finset.univ;
  use fun v => c ⟨v, by simp⟩;
  aesop

/-- The chromatic number is at most Δ(G) + 1. -/
theorem chromatic_le_maxDegree_succ {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] :
    G.chromaticNumber ≤ ↑(G.maxDegree + 1) :=
  (colorable_maxDegree_succ G).chromaticNumber_le

/-- When k > Δ(G), the graph is k-colorable (no spilling needed). -/
theorem no_spill_sufficient_registers {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (k : ℕ) (hk : G.maxDegree < k) :
    G.Colorable k :=
  (colorable_maxDegree_succ G).mono (by omega)

/-! ## Simplicial Vertex Theory -/

/-- The neighborhood of a simplicial vertex forms a clique. -/
theorem simplicial_nbhd_clique {V : Type*} {G : SimpleGraph V}
    {v : V} (h : G.IsSimplicial v) :
    G.IsClique (G.neighborSet v) :=
  fun _ hu _ hw hne => h _ _ hu hw hne

/-
A chordal graph on a nonempty vertex set has a simplicial vertex.
-/
theorem chordal_has_simplicial {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (hchordal : G.IsChordal) (hn : 0 < n) :
    ∃ v : Fin n, G.IsSimplicial v := by
  -- Since G is chordal, there exists a PEO. Let's obtain such a PEO.
  obtain ⟨peo⟩ : ∃ peo : PerfectEliminationOrdering G, True := by
    exact ⟨ hchordal.some, trivial ⟩;
  use peo.order ⟨0, hn⟩;
  intro u w hu hw hne; have := peo.simplicial_prop ⟨ 0, hn ⟩ u w; simp_all +decide [ SimpleGraph.adj_comm ] ;
  exact this ( lt_of_le_of_ne ( Nat.zero_le _ ) ( Ne.symm <| by intro h; have := peo.order.symm.injective ( by aesop : peo.order.symm u = peo.order.symm ( peo.order ⟨ 0, hn ⟩ ) ) ; aesop ) ) ( lt_of_le_of_ne ( Nat.zero_le _ ) ( Ne.symm <| by intro h; have := peo.order.symm.injective ( by aesop : peo.order.symm w = peo.order.symm ( peo.order ⟨ 0, hn ⟩ ) ) ; aesop ) )

/-! ## Interval Graphs -/

/-- An interval representation assigns each vertex a closed interval [a, b] on ℕ. -/
structure IntervalRepr (n : ℕ) where
  left : Fin n → ℕ
  right : Fin n → ℕ
  valid : ∀ i : Fin n, left i ≤ right i

/-- The interval graph: two distinct vertices are adjacent iff their intervals overlap. -/
def IntervalRepr.toGraph {n : ℕ} (repr : IntervalRepr n) : SimpleGraph (Fin n) where
  Adj u v := u ≠ v ∧ repr.left u ≤ repr.right v ∧ repr.left v ≤ repr.right u
  symm u v := by intro ⟨hne, h1, h2⟩; exact ⟨hne.symm, h2, h1⟩
  loopless := ⟨fun v ⟨h, _, _⟩ => h rfl⟩

instance IntervalRepr.decAdj {n : ℕ} (repr : IntervalRepr n) :
    DecidableRel repr.toGraph.Adj := by
  intro u v
  simp only [IntervalRepr.toGraph]
  exact instDecidableAnd

/-
**Bridge Theorem**: Interval graphs are chordal.

    **Proof idea**: Order vertices by left endpoint (breaking ties by right endpoint).
    This gives a PEO because if vertex i is adjacent to later vertices j and k,
    then j and k's intervals both extend left past the left endpoint of i, and
    both start after i in the ordering, so they must overlap.
-/
theorem interval_graph_is_chordal {n : ℕ} (repr : IntervalRepr n) :
    @SimpleGraph.IsChordal n repr.toGraph repr.decAdj := by
  -- We will � construct� the PEO by repeatedly removing the vertex with the smallest right endpoint.
  have h_peo : ∃ (peo : Equiv.Perm (Fin n)), ∀ i j : Fin n, i < j → repr.right (peo i) ≤ repr.right (peo j) := by
    -- We can construct such a permutation by sorting the vertices according to their right endpoints.
    have h_sort : ∃ (peo : Fin n → Fin n), (∀ i j, i < j → repr.right (peo i) ≤ repr.right (peo j)) ∧ Function.Injective peo := by
      have h_sort : ∀ (s : Finset (Fin n)), s.Nonempty → ∃ (v : Fin n), v ∈ s ∧ ∀ u ∈ s, repr.right u ≥ repr.right v := by
        exact fun s hs => Finset.exists_min_image _ _ hs;
      have h_sort : ∀ (k : ℕ) (hk : k ≤ n), ∀ (s : Finset (Fin n)), s.card = k → ∃ (peo : Fin k → Fin n), (∀ i j, i < j → repr.right (peo i) ≤ repr.right (peo j)) ∧ Function.Injective peo ∧ ∀ i, peo i ∈ s := by
        intro k hk s hs_card
        induction' k with k ih generalizing s;
        · simp +decide [ Function.Injective ];
        · obtain ⟨ v, hv₁, hv₂ ⟩ := h_sort s ( Finset.card_pos.mp ( by linarith ) );
          obtain ⟨ peo, hpeo₁, hpeo₂, hpeo ⟩ := ih ( Nat.le_of_succ_le hk ) ( s.erase v ) ( by rw [ Finset.card_erase_of_mem hv₁, hs_card ] ; simp +decide );
          use Fin.cons v peo;
          simp_all +decide [ Fin.forall_fin_succ, Function.Injective, Fin.cons ];
          grind +extAll;
      specialize h_sort n le_rfl Finset.univ ; aesop;
    cases' h_sort with peo hpeo; use Equiv.ofBijective peo (by
    exact ⟨ hpeo.2, Finite.injective_iff_surjective.mp hpeo.2 ⟩); aesop;
  refine' ⟨ ⟨ h_peo.choose, _ ⟩ ⟩;
  intro i u w hu hw hi hj hne; have := h_peo.choose_spec i ( h_peo.choose.symm u ) ; have := h_peo.choose_spec i ( h_peo.choose.symm w ) ; simp_all +decide [ IntervalRepr.toGraph ] ;
  grobner

/-! ## The SSA Register Allocation Theorem -/

/-
**Main Theorem**: For interval graphs (SSA interference graphs),
    if k colors suffice, then every clique has size ≤ k.
    Combined with chordal_colorable_of_clique_bound, this gives χ = ω.
-/
theorem interval_clique_le_colors {n : ℕ} (repr : IntervalRepr n)
    (k : ℕ) (hcol : @SimpleGraph.Colorable (Fin n) repr.toGraph k) :
    ∀ s : Finset (Fin n), @SimpleGraph.IsClique (Fin n) repr.toGraph (↑s) → s.card ≤ k := by
  exact fun s hs => clique_size_le_colorable hcol s rfl hs

/-
Register assignment equivalence: assignments exist iff the graph is colorable.
-/
theorem register_iff_colorable {n : ℕ} (IG : InterferenceGraph n) (k : ℕ) :
    (∃ f : Fin n → Fin k, ∀ u v, IG.graph.Adj u v → f u ≠ f v) ↔
    IG.graph.Colorable k := by
  constructor;
  · rintro ⟨ f, hf ⟩;
    exact ⟨ ⟨ f, by tauto ⟩ ⟩;
  · rintro ⟨ f ⟩;
    exact ⟨ f, fun u v huv => f.valid huv ⟩

/-! ## Falsifiable Conjecture -/

/-- **Conjecture**: For every chordal graph, χ(G) = ω(G): the graph is k-colorable
    iff every clique has size ≤ k.

    **Testable prediction**: Generate 1000 random chordal graphs with n ∈ [10,100].
    For each, compute the greedy coloring on a random PEO and verify
    colors_used = max_clique_size. A single violation disproves this. -/
def ChordalGreedyOptimality {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] : Prop :=
  G.IsChordal →
    ∀ k : ℕ, G.Colorable k ↔
      ∀ s : Finset (Fin n), G.IsClique (↑s : Set (Fin n)) → s.card ≤ k

end