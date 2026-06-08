/-
  # Register Allocation as Graph Coloring

  This file formalizes the connection between register allocation in compilers
  and graph coloring theory. We define interference graphs, chordal graphs,
  perfect elimination orderings, and prove key theorems about chromatic number
  bounds, clique-coloring duality, and spill cost optimization.

  ## Main Results

  * `clique_colors_injective` : coloring is injective on cliques
  * `clique_requires_colors` : ω(G) ≤ χ(G) for any graph
  * `spill_clique_lower_bound` : if k < |clique|, at least |clique| - k must be spilled
  * `clique_size_le_maxDegree_succ` : any clique has size ≤ Δ(G) + 1
  * `simplicial_neighborhood_clique` : simplicial vertex neighborhoods form cliques
  * `register_sufficiency_colorable` : n registers always suffice for n-vertex graphs

  ## References

  * Chaitin, G. J. "Register allocation & spilling via graph coloring" (1982)
  * Hack, S. et al. "Register allocation for programs in SSA form" (2006)
-/
import Mathlib

open SimpleGraph Finset

noncomputable section

/-! ## Interference Graphs and Register Allocation -/

/-- An interference graph for register allocation. Variables are vertices (Fin n),
    and edges connect variables that are simultaneously live. -/
structure InterferenceGraph (n : ℕ) where
  /-- The underlying simple graph on n vertices -/
  graph : SimpleGraph (Fin n)
  /-- Adjacency is decidable -/
  decAdj : DecidableRel graph.Adj

attribute [instance] InterferenceGraph.decAdj

/-- A register assignment maps variables to one of k registers -/
def RegisterAssignment (n k : ℕ) := Fin n → Fin k

/-- A valid register assignment is a proper coloring of the interference graph -/
def ValidAssignment {n : ℕ} (IG : InterferenceGraph n) (k : ℕ)
    (f : RegisterAssignment n k) : Prop :=
  ∀ u v : Fin n, IG.graph.Adj u v → f u ≠ f v

/-
A register assignment exists iff the graph is k-colorable
-/
theorem register_assignment_iff_colorable {n : ℕ} (IG : InterferenceGraph n) (k : ℕ) :
    (∃ f : RegisterAssignment n k, ValidAssignment IG k f) ↔ IG.graph.Colorable k := by
  constructor;
  · rintro ⟨ f, hf ⟩;
    use fun v => f v;
    aesop;
  · rintro ⟨ f, hf ⟩;
    exact ⟨ f, fun u v huv => by simpa using hf huv ⟩

/-! ## Chordal Graphs and Perfect Elimination Orderings -/

/-- A simplicial vertex has all its neighbors pairwise adjacent (forming a clique).
    This is the key local property that drives chordal graph algorithms. -/
def SimpleGraph.IsSimplicial {V : Type*} (G : SimpleGraph V) (v : V) : Prop :=
  ∀ u w : V, G.Adj v u → G.Adj v w → u ≠ w → G.Adj u w

/-- A perfect elimination ordering is a sequence where each vertex is simplicial
    in the subgraph induced by vertices appearing later in the ordering.
    This is the characterization of chordal graphs that enables optimal coloring. -/
structure PerfectEliminationOrdering {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] where
  /-- The ordering as a permutation -/
  order : Equiv.Perm (Fin n)
  /-- Each vertex is simplicial among later vertices -/
  simplicial : ∀ i : Fin n, ∀ u w : Fin n,
    G.Adj (order i) u → G.Adj (order i) w →
    i < order.symm u → i < order.symm w →
    u ≠ w → G.Adj u w

/-- A chordal graph admits a perfect elimination ordering.
    SSA-form interference graphs are chordal — this is the key structural insight
    connecting register allocation to optimal graph coloring. -/
def SimpleGraph.IsChordal {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] : Prop :=
  Nonempty (PerfectEliminationOrdering G)

/-! ## Clique-Coloring Duality -/

/-
Any clique in a properly colored graph must receive all distinct colors.
    This is proved by contradiction: if two clique vertices shared a color,
    they would be adjacent (by the clique property) yet same-colored (contradiction).
-/
theorem clique_colors_injective {V : Type*} {G : SimpleGraph V} {α : Type*}
    (c : G.Coloring α) {s : Finset V} (hs : G.IsClique (s : Set V)) :
    Set.InjOn c (s : Set V) := by
  intro x hx y hy hxy;
  exact Classical.not_not.1 fun h => c.valid ( hs hx hy h ) hxy

/-
A clique of size k requires at least k colors.
    Proof: the coloring is injective on the clique, so the image has k elements,
    hence the color type has at least k elements.
-/
theorem clique_requires_colors {n : ℕ} {G : SimpleGraph (Fin n)}
    {k m : ℕ} (hcol : G.Colorable m)
    (s : Finset (Fin n)) (hs : s.card = k) (hclique : G.IsClique (s : Set (Fin n))) :
    k ≤ m := by
  convert clique_colors_injective hcol.some hclique |> fun h => Finset.card_image_of_injOn h |> fun h' => h'.ge.trans ( Finset.card_le_univ _ ) using 1;
  · exact hs.symm;
  · norm_num

/-! ## Spill Cost Theory -/

/-
The spill-clique theorem: if a graph contains a clique of size m and we have
    k < m registers, then at least m - k vertices from the clique must be spilled.

    Proof by contradiction: if fewer than m - k clique vertices are spilled,
    then more than k unspilled clique vertices remain. The coloring is injective
    on these (since they form a clique), but injecting > k elements into Fin k
    is impossible.
-/
theorem spill_clique_lower_bound {n : ℕ} {G : SimpleGraph (Fin n)} [DecidableRel G.Adj]
    {k m : ℕ} (s : Finset (Fin n)) (hs : s.card = m)
    (hclique : G.IsClique (s : Set (Fin n)))
    (spilled : Finset (Fin n))
    (hk : k < m)
    (hvalid : ∃ c : Fin n → Fin k,
      ∀ u v : Fin n, u ∉ spilled → v ∉ spilled → G.Adj u v → c u ≠ c v) :
    m - k ≤ (s ∩ spilled).card := by
  obtain ⟨ c, hc ⟩ := hvalid;
  -- By contradiction, assume that $(s \cap spilled).card < m - k$.
  by_contra h_contra
  have h_card : (s \ spilled).card > k := by
    grind;
  have h_inj : Set.InjOn c (s \ spilled : Set (Fin n)) := by
    exact fun u hu v hv huv => Classical.not_not.1 fun h => hc u v hu.2 hv.2 ( hclique hu.1 hv.1 <| by aesop ) huv;
  have := Finset.card_le_univ ( Finset.image c ( s \ spilled ) ) ; simp_all +decide [ Finset.card_image_of_injOn ] ;
  linarith

/-! ## Degree Bounds -/

/-
Any clique of size k in a graph satisfies k ≤ Δ(G) + 1.
    Proof: pick any vertex v in the clique. The other k-1 clique members
    are all neighbors of v, so degree(v) ≥ k-1, hence Δ ≥ k-1.
-/
theorem clique_size_le_maxDegree_succ {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (s : Finset (Fin n))
    (hclique : G.IsClique (s : Set (Fin n))) (hne : s.Nonempty) :
    s.card ≤ G.maxDegree + 1 := by
  -- Pick v from s (using � h�ne). Then s.erase v ⊆ G.neighborFinset v because all other clique members are adjacent to v.
  obtain ⟨v, hv⟩ : ∃ v ∈ s, True := by
    grind
  have h_subset : s.erase v ⊆ G.neighborFinset v := by
    intro u hu; have := hclique hv.1 ( Finset.mem_of_mem_erase hu ) ; aesop;
  have := Finset.card_mono h_subset; simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ] ;
  exact this.trans ( Nat.succ_le_succ ( G.degree_le_maxDegree v |> le_trans ( by simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ] ) ) )

/-
Register sufficiency: n registers always suffice for an n-vertex graph
-/
theorem register_sufficiency_colorable {n : ℕ} (G : SimpleGraph (Fin n)) :
    G.Colorable n := by
  exact ⟨ fun v => v, by aesop ⟩

/-! ## Simplicial Vertex Properties -/

/-
The neighborhood of a simplicial vertex forms a clique.
    This is the defining property restated in terms of the neighbor set.
-/
theorem simplicial_neighborhood_clique {V : Type*} {G : SimpleGraph V}
    {v : V} (hsimpl : G.IsSimplicial v) :
    G.IsClique (G.neighborSet v) := by
  exact fun u hu w hw hne => hsimpl u w hu hw hne

/-
In a chordal graph, there exists a simplicial vertex.
    This is the first vertex in the PEO.
-/
theorem chordal_has_simplicial {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (hchordal : G.IsChordal) (hn : 0 < n) :
    ∃ v : Fin n, G.IsSimplicial v := by
  -- Since G is chordal �,� there exists a perfect elimination ordering (peo) for G.
  obtain ⟨peo, hpeo⟩ : ∃ peo : PerfectEliminationOrdering G, True := by
    exact ⟨ hchordal.some, trivial ⟩;
  use peo.order ⟨0, hn⟩;
  intro u w hu hw hne; have := peo.simplicial ⟨ 0, hn ⟩ u w hu hw; simp_all +decide [ SimpleGraph.adj_comm ] ;
  grind +suggestions

/-! ## Chromatic Number Bounds -/

/-
Any finite graph is colorable with maxDegree + 1 colors.
    Proof: use the identity coloring composed with a bound reduction.
    Since every vertex has degree ≤ maxDegree, and maxDegree + 1 ≤ n,
    the n-coloring (identity) can be composed with a color reduction.
-/
theorem colorable_maxDegree_succ {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] :
    G.Colorable (G.maxDegree + 1) := by
  have h_max_degree : ∀ v : Fin n, G.degree v ≤ G.maxDegree := by
    exact fun v => SimpleGraph.degree_le_maxDegree G v;
  have h_colorable : ∀ (s : Finset (Fin n)), ∃ f : Fin n → Fin (G.maxDegree + 1), (∀ v ∈ s, ∀ u ∈ s, G.Adj v u → f v ≠ f u) := by
    intro s; induction' s using Finset.induction with v s ih; simp_all +decide ;
    -- Let's choose any color � for� $v �$� that is not used by its neighbors in $s$.
    obtain ⟨f, hf⟩ := ‹∃ f : Fin n → Fin (G.maxDegree + 1), ∀ v ∈ s, ∀ u ∈ s, G.Adj v u → f v ≠ f u›;
    have h_color_v : ∃ c : Fin (G.maxDegree + 1), ∀ u ∈ s, G.Adj v u → f u ≠ c := by
      have h_color_v : Finset.card (Finset.image f (Finset.filter (fun u => G.Adj v u) s)) ≤ G.maxDegree := by
        exact le_trans ( Finset.card_image_le ) ( le_trans ( Finset.card_le_card ( show _ ⊆ G.neighborFinset v from fun x hx => by aesop ) ) ( by simpa using h_max_degree v ) );
      contrapose! h_color_v;
      rw [ show Finset.image f ( Finset.filter ( fun u => G.Adj v u ) s ) = Finset.univ from Finset.eq_univ_of_forall fun x => by obtain ⟨ u, hu₁, hu₂, hu₃ ⟩ := h_color_v x; aesop ] ; simp +decide [ Finset.card_univ ];
    obtain ⟨ c, hc ⟩ := h_color_v; use fun u => if u = v then c else f u; simp_all +decide [ SimpleGraph.adj_comm ] ;
    grind;
  exact Exists.elim ( h_colorable Finset.univ ) fun f hf => ⟨ f, by aesop ⟩

/-- The chromatic number is at most maxDegree + 1. -/
theorem chromatic_le_maxDegree_succ {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] :
    G.chromaticNumber ≤ ↑(G.maxDegree + 1) := by
  exact (colorable_maxDegree_succ G).chromaticNumber_le

/-
If maximum degree Δ < k, then the graph is k-colorable (no spilling needed).
    This gives a sufficient condition for spill-free register allocation.
-/
theorem no_spill_when_enough_registers {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (k : ℕ) (hk : G.maxDegree < k) :
    G.Colorable k := by
  by_contra h_contra;
  have h_colorable : G.chromaticNumber ≤ k := by
    exact le_trans ( chromatic_le_maxDegree_succ G ) ( Nat.cast_le.mpr hk );
  exact h_contra <| by rw [ SimpleGraph.chromaticNumber_le_iff_colorable ] at h_colorable; aesop;

/-! ## SSA Interference Graph Conjecture -/

/-
One direction of the SSA conjecture is always true:
    if G is k-colorable, then every clique has size ≤ k.
-/
theorem ssa_conjecture_forward {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (k : ℕ) (hcol : G.Colorable k) :
    ∀ s : Finset (Fin n), G.IsClique (s : Set (Fin n)) → s.card ≤ k := by
  intro s hsclique;
  convert clique_requires_colors hcol s ( rfl ) hsclique

/-- **Conjecture (SSA Chromatic Number)**: For interference graphs arising from
    SSA-form programs, the chromatic number equals the clique number.
    This is actually a theorem for chordal graphs (they are perfect).

    **Testable prediction**: Extract interference graphs from 100 real SSA programs,
    compute χ(G) and ω(G), and verify equality. A single counterexample with
    χ(G) ≠ ω(G) would disprove this (and would mean the interference graph
    is not chordal, contradicting the SSA structure theorem). -/
def SSA_Chromatic_Conjecture {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] : Prop :=
  G.IsChordal →
    ∀ k : ℕ, G.Colorable k ↔
      ∀ s : Finset (Fin n), G.IsClique (s : Set (Fin n)) → s.card ≤ k

end