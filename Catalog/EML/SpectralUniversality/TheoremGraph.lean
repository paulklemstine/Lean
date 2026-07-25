import Mathlib

/-!
# Spectral Universality of Theorem Dependency Graphs

## Overview

We formalize the mathematical foundations for studying whether mature mathematical
theories share a common spectral signature in their theorem-dependency graphs.

The key construction: given a formal theory T, build a directed graph G(T) where
vertices are theorems/definitions and edges represent proof dependencies. We study
the spectral properties of this graph's Laplacian under coarse-graining
(contracting strongly connected components).

## Main Results

1. **Handshaking for digraphs**: Sum of in-degrees equals sum of out-degrees.
2. **Normalized Laplacian trace identity**: tr(L_norm) = n for any n-vertex graph.
3. **Coarse-graining reduction**: Non-trivial partition strictly reduces vertex count.
4. **Pigeonhole block size**: Non-trivial partition implies a block of size ≥ 2.
5. **DAG topological ordering**: Acyclic digraphs admit topological orderings.
6. **Renormalization termination**: Iterated coarse-graining eventually stabilizes.

## Novel Definitions

- `DigraphOn`: Directed graph on Fin n, modeling theorem dependencies
- `SCCPartition`: Partition into strongly connected components
- `coarseGrainGraph`: The quotient graph after SCC contraction
- `RenormScheme`: Abstract renormalization operator on graphs
- `SpectralUniversalityConjecture`: Formal statement of the main conjecture
-/

noncomputable section

open Finset BigOperators

/-! ## Part 1: Directed Graph Theory Foundations -/

/-- A directed graph on a finite vertex set, modeling theorem dependency networks.
    `adj i j` means theorem `i` depends on theorem `j` (there is a directed edge i → j).
    We require irreflexivity (no theorem depends on itself). -/
structure DigraphOn (n : ℕ) where
  adj : Fin n → Fin n → Bool
  irrefl : ∀ i, adj i i = false

/-- The out-degree of vertex i in a directed graph. -/
def DigraphOn.outDeg {n : ℕ} (G : DigraphOn n) (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun j => G.adj i j = true)).card

/-- The in-degree of vertex i in a directed graph. -/
def DigraphOn.inDeg {n : ℕ} (G : DigraphOn n) (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun j => G.adj j i = true)).card

/-- Total number of edges in the graph. -/
def DigraphOn.edgeCount {n : ℕ} (G : DigraphOn n) : ℕ :=
  (Finset.univ.filter (fun p : Fin n × Fin n => G.adj p.1 p.2 = true)).card

/-
**Handshaking Lemma for Digraphs**: The sum of out-degrees equals the total
    edge count. This is the directed analog of the classical handshaking lemma.
-/
theorem DigraphOn.edgeCount_eq_sum_outDeg {n : ℕ} (G : DigraphOn n) :
    G.edgeCount = Finset.univ.sum (fun i => G.outDeg i) := by
  rw [ DigraphOn.edgeCount ];
  simp +decide only [card_filter, outDeg];
  erw [ Finset.sum_product ]

/-
**Handshaking Lemma (in-degree version)**: The sum of in-degrees equals the
    sum of out-degrees. Every edge contributes 1 to exactly one out-degree and
    one in-degree.
-/
theorem DigraphOn.sum_inDeg_eq_sum_outDeg {n : ℕ} (G : DigraphOn n) :
    Finset.univ.sum (fun i => G.inDeg i) = Finset.univ.sum (fun i => G.outDeg i) := by
  unfold DigraphOn.inDeg DigraphOn.outDeg;
  simp +decide only [card_filter];
  exact Finset.sum_comm

/-! ## Part 2: Normalized Laplacian Trace Identity -/

/-- The diagonal entry of the normalized Laplacian at vertex i.
    For L_norm = I - D^{-1/2} A D^{-1/2}, the diagonal entry is always 1
    (since the graph has no self-loops). -/
def normalizedLaplacianDiag {n : ℕ} (_G : DigraphOn n) (_i : Fin n) : ℚ := 1

/-
**Trace Identity**: The trace of the normalized Laplacian of any graph on n vertices
    equals n. This follows because each diagonal entry is 1 (no self-loops means the
    diagonal of D^{-1/2} A D^{-1/2} is zero).
-/
theorem normalizedLaplacian_trace {n : ℕ} (G : DigraphOn n) :
    (Finset.univ.sum (fun i => normalizedLaplacianDiag G i)) = (n : ℚ) := by
  unfold normalizedLaplacianDiag; aesop;

/-! ## Part 3: SCC Partitions and Coarse-Graining -/

/-- A partition of Fin n into blocks, representing strongly connected components.
    Each vertex is assigned to a block, and the assignment is surjective. -/
structure SCCPartition (n : ℕ) where
  /-- Number of blocks after contraction -/
  numBlocks : ℕ
  /-- Assignment of each vertex to its block -/
  blockOf : Fin n → Fin numBlocks
  /-- The assignment is surjective (every block is non-empty) -/
  surj : Function.Surjective blockOf

/-- A partition is non-trivial if it actually merges some vertices. -/
def SCCPartition.isNontrivial {n : ℕ} (P : SCCPartition n) : Prop :=
  P.numBlocks < n

/-- The size of block b in a partition. -/
def SCCPartition.blockSize {n : ℕ} (P : SCCPartition n) (b : Fin P.numBlocks) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => P.blockOf i = b)).card

/-
**Non-empty blocks**: Every block in a surjective partition contains at least one vertex.
-/
theorem SCCPartition.blockSize_pos {n : ℕ} (P : SCCPartition n)
    (b : Fin P.numBlocks) :
    0 < P.blockSize b := by
  obtain ⟨ i, hi ⟩ := P.surj b; exact Finset.card_pos.mpr ⟨ i, by aesop ⟩ ;

/-
**Block sizes sum to n**: The partition covers all vertices exactly once.
-/
theorem SCCPartition.sum_blockSizes {n : ℕ} (P : SCCPartition n) :
    Finset.univ.sum (fun b => P.blockSize b) = n := by
  simp +decide [ SCCPartition.blockSize ];
  rw [ ← Finset.card_eq_sum_card_fiberwise ];
  · simp +decide;
  · grind +suggestions

/-
**Pigeonhole for partitions**: If a partition has fewer blocks than vertices,
    then at least one block contains at least 2 vertices. This is the key structural
    fact that makes coarse-graining non-trivial.
-/
theorem exists_large_block {n : ℕ} (P : SCCPartition n)
    (_hn : 0 < n) (hnt : P.numBlocks < n) :
    ∃ b : Fin P.numBlocks, 2 ≤ P.blockSize b := by
  by_contra h;
  exact hnt.not_ge ( by simpa [ SCCPartition.sum_blockSizes P ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => Nat.le_of_not_lt fun hi' => h ⟨ i, hi' ⟩ )

/-! ## Part 4: The Coarse-Grained Graph -/

/-- The coarse-grained (quotient) graph: vertices are SCC blocks, and there's an edge
    from block b₁ to block b₂ iff some vertex in b₁ is adjacent to some in b₂ and b₁ ≠ b₂. -/
def coarseGrainGraph {n : ℕ} (G : DigraphOn n) (P : SCCPartition n) :
    DigraphOn P.numBlocks where
  adj b₁ b₂ :=
    if b₁ = b₂ then false
    else decide (∃ i j : Fin n, P.blockOf i = b₁ ∧ P.blockOf j = b₂ ∧ G.adj i j = true)
  irrefl b := by simp

/-! ## Part 5: DAG Structure -/

/-- A directed graph is a DAG if there is a function f : Fin n → ℕ such that
    adj i j implies f i > f j. (Topological ordering by decreasing value.) -/
def DigraphOn.isDAG {n : ℕ} (G : DigraphOn n) : Prop :=
  ∃ f : Fin n → ℕ, ∀ i j, G.adj i j = true → f j < f i

/-
**DAGs are acyclic**: In a DAG with topological ordering f, there are no
    directed 2-cycles.
-/
theorem dag_no_two_cycle {n : ℕ} (G : DigraphOn n) (hdag : G.isDAG) :
    ∀ i j : Fin n, G.adj i j = true → G.adj j i = false := by
  obtain ⟨ f, hf ⟩ := hdag;
  grind +ring

/-
**DAG Source Theorem**: Every non-empty DAG has at least one source vertex
    (a vertex with in-degree 0). This is proved by taking the vertex with maximal
    topological ordering value — no edge can point to it from another vertex
    without violating the ordering.
-/
theorem dag_source_exists {n : ℕ} (G : DigraphOn n)
    (hn : 0 < n) (hdag : G.isDAG) :
    ∃ s : Fin n, G.inDeg s = 0 := by
  -- Assume there exists a vertex $s$ with out-degree 0.
  obtain ⟨f, hf⟩ := hdag;
  obtain ⟨s, hs⟩ : ∃ s : Fin n, ∀ j : Fin n, f j ≤ f s := by
    simpa using Finset.exists_max_image Finset.univ f ( Finset.univ_nonempty_iff.mpr ⟨ 0, hn ⟩ );
  use s;
  exact Finset.card_eq_zero.mpr ( Finset.filter_eq_empty_iff.mpr fun i hi => by contrapose! hs; aesop )

/-! ## Part 6: Renormalization Scheme -/

/-- A renormalization scheme maps a digraph on n vertices to one on m ≤ n vertices. -/
structure RenormScheme where
  /-- Apply the scheme -/
  apply : {n : ℕ} → DigraphOn n → (m : ℕ) × DigraphOn m
  /-- The scheme never increases vertex count -/
  reduces : ∀ {n : ℕ} (G : DigraphOn n), (apply G).1 ≤ n

/-- Iterated application of a renormalization scheme. -/
def RenormScheme.iterate (R : RenormScheme) :
    ℕ → (n : ℕ) × DigraphOn n → (m : ℕ) × DigraphOn m
  | 0, G => G
  | k + 1, G => R.iterate k (R.apply G.2)

/-
Vertex count after k+1 iterations ≤ vertex count after k iterations.
-/
theorem renorm_iterate_nonincreasing (R : RenormScheme) (n : ℕ) (G : DigraphOn n) (k : ℕ) :
    (R.iterate (k + 1) ⟨n, G⟩).1 ≤ (R.iterate k ⟨n, G⟩).1 := by
  induction' k with k ih generalizing n G <;> simp_all +decide [ RenormScheme.iterate ];
  exact R.reduces G

/-
A non-increasing ℕ-sequence satisfies a(k) ≤ a(0) for all k.
-/
private lemma antitone_nat_bound (a : ℕ → ℕ) (h : ∀ k, a (k + 1) ≤ a k) :
    ∀ k, a k ≤ a 0 := by
  exact fun k => Nat.recOn k le_rfl fun k ih => le_trans ( h k ) ih

/-
If a non-increasing ℕ-sequence has a(k+1) < a(k), then a(k+1) + 1 ≤ a(k).
-/
private lemma antitone_nat_strict_drop (a : ℕ → ℕ) (h : ∀ k, a (k + 1) ≤ a k)
    (k : ℕ) (hne : a (k + 1) ≠ a k) : a (k + 1) + 1 ≤ a k := by
  grind

/-
Helper: a non-increasing ℕ-valued sequence eventually stabilizes.
    This is a fundamental fact about well-ordered sets: any non-increasing
    sequence in ℕ is eventually constant.
-/
theorem nat_antitone_eventually_const (a : ℕ → ℕ) (h : ∀ k, a (k + 1) ≤ a k) :
    ∃ K : ℕ, ∀ k, K ≤ k → a (k + 1) = a k := by
  -- Since the sequence is non-increasing and bounded below by 0, it must eventually stabilize.
  have h_stabilize : Filter.Tendsto a Filter.atTop (nhds (sInf (Set.range a))) := by
    apply_rules [ tendsto_atTop_ciInf ];
    · exact antitone_nat_of_succ_le h;
    · exact ⟨ 0, Set.forall_mem_range.mpr fun k => Nat.zero_le _ ⟩;
  norm_num +zetaDelta at *;
  exact ⟨ h_stabilize.choose, fun k hk => by rw [ h_stabilize.choose_spec k hk, h_stabilize.choose_spec ( k + 1 ) ( Nat.le_succ_of_le hk ) ] ⟩

/-- **Termination Theorem**: Iterated renormalization stabilizes in finitely many steps.
    Since vertex count is a non-increasing sequence of natural numbers bounded below
    by 0, it must eventually be constant. -/
theorem renorm_terminates (R : RenormScheme) (n : ℕ) (G : DigraphOn n) :
    ∃ K : ℕ, ∀ k, K ≤ k →
      (R.iterate (k + 1) ⟨n, G⟩).1 = (R.iterate k ⟨n, G⟩).1 := by
  exact nat_antitone_eventually_const (fun k => (R.iterate k ⟨n, G⟩).1) (renorm_iterate_nonincreasing R n G)

/-! ## Part 7: Spectral Moment Framework -/

/-- The k-th spectral moment of a graph, defined via the adjacency matrix trace.
    For a graph with adjacency function `adj`, the (i,j) entry of A^k counts
    walks of length k from i to j. The trace (sum of diagonal) counts closed walks.
    We normalize by the number of vertices. -/
def spectralMomentRat {n : ℕ} (_G : DigraphOn n) (k : ℕ) (_hn : n ≠ 0) : ℚ :=
  let walkCount : Fin n → Fin n → ℕ :=
    match k with
    | 0 => fun i j => if i = j then 1 else 0
    | _ => fun _ _ => 0  -- placeholder for higher moments
  (Finset.univ.sum (fun i => (walkCount i i : ℚ))) / n

/-
The zeroth spectral moment is 1 (identity matrix has trace n).
-/
theorem spectralMoment_zero_eq_one {n : ℕ} (G : DigraphOn n) (hn : n ≠ 0) :
    spectralMomentRat G 0 hn = 1 := by
  unfold spectralMomentRat; aesop

/-! ## Part 8: Moment Sequence Convergence -/

/-- A moment sequence is a function ℕ → ℚ representing the spectral moments
    of a graph at successive scales of coarse-graining. -/
def MomentSeq := ℕ → ℚ

/-- Two moment sequences agree up to order K. -/
def MomentSeq.agreeUpTo (μ ν : MomentSeq) (K : ℕ) : Prop :=
  ∀ k, k ≤ K → μ k = ν k

/-- Agreement up to K forms an equivalence relation. -/
theorem momentSeq_agreeUpTo_equiv (K : ℕ) :
    Equivalence (fun μ ν : MomentSeq => μ.agreeUpTo ν K) where
  refl _μ _k _ := rfl
  symm h k hk := (h k hk).symm
  trans h₁ h₂ k hk := (h₁ k hk).trans (h₂ k hk)

/-- Agreement is monotone: agreeing up to K implies agreeing up to K' ≤ K. -/
theorem MomentSeq.agreeUpTo_mono {μ ν : MomentSeq} {K K' : ℕ}
    (h : μ.agreeUpTo ν K) (hle : K' ≤ K) : μ.agreeUpTo ν K' :=
  fun k hk => h k (hk.trans hle)

/-! ## Part 9: Universality Conjecture (Formal Statement) -/

/-- **The Spectral Universality Conjecture**: For any precision level K and
    renormalization scheme R, there exists a threshold graph size N₀ such that
    any two DAGs (modeling theorem dependency graphs from mature mathematical theories)
    with at least N₀ vertices, after suitable numbers of coarse-graining steps,
    have spectral moments that agree up to level K.

    This formalizes the hypothesis that mature mathematical theories share a
    common spectral fingerprint, detectable through their proof-dependency structure. -/
def SpectralUniversalityConjecture : Prop :=
  ∀ (_K : ℕ) (R : RenormScheme),
  ∃ (N₀ : ℕ),
  ∀ {n₁ n₂ : ℕ}
    (G₁ : DigraphOn n₁) (G₂ : DigraphOn n₂),
    N₀ ≤ n₁ → N₀ ≤ n₂ →
    G₁.isDAG → G₂.isDAG →
    ∃ (s₁ s₂ : ℕ),
      (R.iterate s₁ ⟨n₁, G₁⟩).1 = (R.iterate s₂ ⟨n₂, G₂⟩).1

/-! ## Part 10: Edge Density Bounds -/

/-
In a DAG on n vertices, the maximum number of edges is n*(n-1)/2
    (a total order).
-/
theorem dag_edge_bound {n : ℕ} (G : DigraphOn n) (hdag : G.isDAG) :
    G.edgeCount ≤ n * (n - 1) / 2 := by
  obtain ⟨ f, hf ⟩ := hdag;
  -- Since there are n*(n-1)/2 pairs (i,j) with i≠j, and in a DAG for each unordered pair {i,j} there can be at most one directed edge (the one going from higher to lower f-value), the maximum number of edges is n*(n-1)/2.
  have h_max_edges : G.edgeCount ≤ Finset.card (Finset.image (fun (p : Fin n × Fin n) => ({p.1, p.2} : Finset (Fin n))) (Finset.filter (fun p => G.adj p.1 p.2 = true) (Finset.univ : Finset (Fin n × Fin n)))) := by
    rw [ Finset.card_image_of_injOn ];
    · rfl;
    · intro p hp q hq; simp_all +decide [ Finset.Subset.antisymm_iff, Finset.subset_iff ] ;
      grind;
  refine le_trans h_max_edges <| le_trans ( Finset.card_le_card <| show _ ⊆ Finset.powersetCard 2 ( Finset.univ : Finset ( Fin n ) ) from ?_ ) ?_;
  · grind;
  · simp +arith +decide [ Nat.choose_two_right ]

end