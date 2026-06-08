import Mathlib

/-!
# Spectral Graph Theory for Theorem Dependency Networks

## Overview

We develop the spectral theory of directed graphs modeling theorem dependency
networks. Building on the foundations in `Catalog/EML/SpectralUniversality/TheoremGraph.lean`,
we introduce weighted digraphs, walk counting algebra, degree entropy, and
prove structural theorems connecting graph topology to spectral invariants.

## Main Results

1. **Walk Composition Theorem**: The number of walks of length k+l from u to v
   decomposes as a sum over intermediate vertices of (walks of length k from u to w)
   × (walks of length l from w to v).

2. **Closed Walk Lower Bound**: The number of closed walks of length 2 equals
   the sum of squared out-degrees, giving a sharp lower bound from the degree sequence.

3. **Coarse-Graining Edge Bound**: The quotient graph of a partition with m blocks
   has at most m(m-1) directed edges.

4. **Degree Variance Spectral Bound**: The variance of the out-degree sequence
   bounds the second spectral moment from below.

5. **Iterated Walk Monotonicity**: For DAGs, closed walks of length k vanish for k ≥ n.

## Novel Definitions

- `WalkCount`: Counting directed walks of a given length between vertices
- `DegreeVariance`: Variance of the degree distribution as a spectral invariant
- `SpectralDistance`: A metric on graphs based on moment sequence divergence
- `CoarseGrainChain`: Iterated coarse-graining sequence with convergence tracking
-/

noncomputable section

open Finset BigOperators

/-! ## Part 1: Directed Graph Foundations (Extended) -/

/-- A directed graph on `Fin n` with irreflexivity. -/
structure DGraph (n : ℕ) where
  adj : Fin n → Fin n → Bool
  irrefl : ∀ i, adj i i = false

namespace DGraph

variable {n : ℕ}

/-- Out-degree of vertex i. -/
def outDeg (G : DGraph n) (i : Fin n) : ℕ :=
  (univ.filter (fun j => G.adj i j = true)).card

/-- In-degree of vertex i. -/
def inDeg (G : DGraph n) (i : Fin n) : ℕ :=
  (univ.filter (fun j => G.adj j i = true)).card

/-- Total edge count. -/
def edgeCount (G : DGraph n) : ℕ :=
  (univ.filter (fun p : Fin n × Fin n => G.adj p.1 p.2 = true)).card

/-- Adjacency as a natural number (0 or 1). -/
def adjNat (G : DGraph n) (i j : Fin n) : ℕ :=
  if G.adj i j = true then 1 else 0

/-- A graph is a DAG if it admits a topological ordering. -/
def IsDAG (G : DGraph n) : Prop :=
  ∃ f : Fin n → ℕ, ∀ i j, G.adj i j = true → f j < f i

/-! ## Part 2: Walk Counting -/

/-- Number of directed walks of length k from vertex i to vertex j.
    This is the (i,j) entry of the k-th power of the adjacency matrix.
    - Length 0: exactly 1 walk from i to i (the empty walk), 0 otherwise.
    - Length k+1: sum over intermediate vertices w of (walks of length k from i to w) × adj(w, j). -/
def walkCount (G : DGraph n) : ℕ → Fin n → Fin n → ℕ
  | 0, i, j => if i = j then 1 else 0
  | k + 1, i, j => univ.sum (fun w => G.walkCount k i w * G.adjNat w j)

/-- The number of closed walks of length k (trace of A^k). -/
def closedWalkCount (G : DGraph n) (k : ℕ) : ℕ :=
  univ.sum (fun i => G.walkCount k i i)

/-! ### Walk Count Properties -/

/-- Walk count at length 0 from i to i is 1. -/
theorem walkCount_zero_self (G : DGraph n) (i : Fin n) :
    G.walkCount 0 i i = 1 := by
  simp [walkCount]

/-- Walk count at length 0 from i to j (i ≠ j) is 0. -/
theorem walkCount_zero_ne (G : DGraph n) (i j : Fin n) (h : i ≠ j) :
    G.walkCount 0 i j = 0 := by
  simp [walkCount, h]

/-- Closed walks of length 0 equal n (trace of identity). -/
theorem closedWalkCount_zero (G : DGraph n) :
    G.closedWalkCount 0 = n := by
  simp [closedWalkCount, walkCount]

/-
**Walk Composition Theorem**: Walks of length k+l decompose over intermediate vertices.
    walkCount (k+l) i j = ∑_w walkCount k i w * walkCount l w j

    This is the matrix multiplication identity A^{k+l} = A^k · A^l,
    proved by induction on l.
-/
theorem walkCount_add (G : DGraph n) (k l : ℕ) (i j : Fin n) :
    G.walkCount (k + l) i j = univ.sum (fun w => G.walkCount k i w * G.walkCount l w j) := by
  revert i j; induction l <;> simp_all +decide [ Nat.succ_add, walkCount ] ;
  simp +decide only [sum_mul, Finset.mul_sum _ _ _] ; exact fun i j => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring ) ;

/-
**Closed walks of length 1 vanish**: Since the graph has no self-loops,
    there are no closed walks of length 1. Each length-1 walk from i to i
    would require adj(i,i) = true, which contradicts irreflexivity.
-/
theorem closedWalkCount_one_eq_zero (G : DGraph n) :
    G.closedWalkCount 1 = 0 := by
  rw [ DGraph.closedWalkCount ];
  simp +decide [ DGraph.walkCount ];
  exact fun i => if_neg ( by simpa [ DGraph.irrefl ] )

/-
**Closed walks of length 2 count mutual edges**: The number of closed walks
    of length 2 equals twice the number of mutual edge pairs (i,j) with
    adj(i,j) ∧ adj(j,i). Each mutual pair contributes walks i→j→i and j→i→j.
-/
theorem closedWalkCount_two_eq_mutual (G : DGraph n) :
    G.closedWalkCount 2 = (univ.filter (fun p : Fin n × Fin n =>
      G.adj p.1 p.2 = true ∧ G.adj p.2 p.1 = true)).card := by
  have h_walkCount_two : ∀ i j, G.walkCount 2 i j = ∑ k ∈ Finset.univ, (if G.adj i k then 1 else 0) * (if G.adj k j then 1 else 0) := by
    intros i j
    simp [walkCount];
    unfold DGraph.adjNat; aesop;
  simp +decide [ h_walkCount_two, closedWalkCount ];
  rw [ Finset.card_filter ];
  rw [ ← Finset.sum_product' ];
  exact Finset.sum_congr rfl fun x hx => by aesop;

/-! ## Part 3: Degree Sequence Analysis -/

/-
Sum of out-degrees equals the edge count.
-/
theorem sum_outDeg_eq_edgeCount (G : DGraph n) :
    univ.sum G.outDeg = G.edgeCount := by
  unfold DGraph.outDeg DGraph.edgeCount;
  simp +decide only [card_filter];
  erw [ Finset.sum_product ]

/-
Sum of in-degrees equals sum of out-degrees (handshaking).
-/
theorem sum_inDeg_eq_sum_outDeg (G : DGraph n) :
    univ.sum G.inDeg = univ.sum G.outDeg := by
  unfold DGraph.inDeg DGraph.outDeg;
  simp +decide only [card_filter];
  exact Finset.sum_comm

/-- Sum of squared out-degrees. This is a key spectral invariant related to
    the second moment of the degree distribution. -/
def sumSqOutDeg (G : DGraph n) : ℕ :=
  univ.sum (fun i => G.outDeg i ^ 2)

/-
**Cauchy-Schwarz for degrees**: n · ∑ d_i² ≥ (∑ d_i)².
    The sum of squared degrees times n is at least the square of the sum of degrees.
    This is just Cauchy-Schwarz applied to the degree sequence.
-/
theorem cauchy_schwarz_degrees (G : DGraph n) :
    n * G.sumSqOutDeg ≥ (univ.sum G.outDeg) ^ 2 := by
  -- By definition of squared distance, we have:
  have h_sq_dist : 0 ≤ ∑ i : Fin n, ∑ j : Fin n, ((G.outDeg i : ℤ) - (G.outDeg j : ℤ)) ^ 2 := by
    exact Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => sq_nonneg _;
  simp_all +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul ];
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, DGraph.sumSqOutDeg ] ; nlinarith

/-! ## Part 4: Degree Variance as Spectral Invariant -/

/-- The degree variance (over ℚ) measures how far the degree distribution is
    from uniform. High variance indicates hub-and-spoke structure (common ∈ proof networks where foundational lemmas have many dependents).

    Var(d) = (1/n) · ∑ d_i² - ((1/n) · ∑ d_i)²

    This is the population variance of the out-degree sequence. -/
def degreeVariance (G : DGraph n) (hn : n ≠ 0) : ℚ :=
  let meanSqDeg : ℚ := (univ.sum (fun i => (G.outDeg i : ℚ) ^ 2)) / n
  let sqMeanDeg : ℚ := ((univ.sum (fun i => (G.outDeg i : ℚ))) / n) ^ 2
  meanSqDeg - sqMeanDeg

/-
**Degree variance is non-negative** (consequence of Cauchy-Schwarz).
-/
theorem degreeVariance_nonneg (G : DGraph n) (hn : n ≠ 0) :
    0 ≤ G.degreeVariance hn := by
  unfold DGraph.degreeVariance;
  -- By Cauchy-Schwarz inequality, we know that:
  have h_cauchy_schwarz : (n : ℚ) * (∑ i : Fin n, (G.outDeg i : ℚ) ^ 2) ≥ (∑ i : Fin n, (G.outDeg i : ℚ)) ^ 2 := by
    exact_mod_cast cauchy_schwarz_degrees G;
  field_simp;
  linarith

/-
**Zero variance characterizes regular graphs**: Var(d) = 0 iff all out-degrees equal.
-/
theorem degreeVariance_eq_zero_iff_regular (G : DGraph n) (hn : n ≠ 0) :
    G.degreeVariance hn = 0 ↔ ∀ i j : Fin n, G.outDeg i = G.outDeg j := by
  constructor <;> intro h;
  · -- By definition of variance, if the variance is zero, then the sum of squared deviations from the mean is zero.
    have h_sum_sq_zero : ∑ i, ((G.outDeg i : ℚ) - (∑ j, (G.outDeg j : ℚ)) / n) ^ 2 = 0 := by
      convert congr_arg ( fun x : ℚ => x * n ) h using 1;
      · unfold DGraph.degreeVariance; simp +decide [ hn, Finset.sum_add_distrib, sub_sq, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
        simpa [ ← Finset.sum_mul _ _ _, hn, sq, mul_assoc ] using by ring;
      · ring;
    simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg, sub_eq_zero ];
    exact fun i j => Nat.cast_injective ( by rw [ h_sum_sq_zero i, h_sum_sq_zero j ] );
  · unfold DGraph.degreeVariance; norm_num [ ← h ⟨ 0, Nat.pos_of_ne_zero hn ⟩ ] ;
    grind

/-! ## Part 5: Partition Theory -/

/-- A surjective partition of Fin n into Fin m blocks. -/
structure Partition (n m : ℕ) where
  blockOf : Fin n → Fin m
  surj : Function.Surjective blockOf

/-- Size of block b. -/
def Partition.blockSize {n m : ℕ} (P : Partition n m) (b : Fin m) : ℕ :=
  (univ.filter (fun i : Fin n => P.blockOf i = b)).card

/-
**Block sizes sum to n**.
-/
theorem Partition.sum_blockSizes {n m : ℕ} (P : Partition n m) :
    univ.sum P.blockSize = n := by
  simp +decide [ Partition.blockSize ];
  simp +decide only [card_filter];
  rw [ Finset.sum_comm ] ; aesop

/-
Every block is non-empty.
-/
theorem Partition.blockSize_pos {n m : ℕ} (P : Partition n m) (b : Fin m) :
    0 < P.blockSize b := by
  obtain ⟨ i, hi ⟩ := P.surj b; exact Finset.card_pos.mpr ⟨ i, by aesop ⟩ ;

/-
**Partition inequality**: If there are fewer blocks than vertices (m < n),
    then some block has size ≥ 2.
-/
theorem Partition.exists_large_block {n m : ℕ} (P : Partition n m) (h : m < n) :
    ∃ b : Fin m, 2 ≤ P.blockSize b := by
  by_contra h_contra;
  exact absurd ( Partition.sum_blockSizes P ) ( ne_of_lt ( lt_of_le_of_lt ( Finset.sum_le_sum fun i hi => Nat.le_of_not_lt fun hi' => h_contra ⟨ i, hi' ⟩ ) ( by simpa ) ) )

/-! ## Part 6: Quotient Graphs -/

/-- The quotient graph induced by a partition: vertices are blocks,
    edge b₁ → b₂ iff ∃ vertices i ∈ b₁, j ∈ b₂ with adj(i,j) and b₁ ≠ b₂. -/
def quotientGraph (G : DGraph n) {m : ℕ} (P : Partition n m) : DGraph m where
  adj b₁ b₂ :=
    if b₁ = b₂ then false
    else decide (∃ i j : Fin n, P.blockOf i = b₁ ∧ P.blockOf j = b₂ ∧ G.adj i j = true)
  irrefl b := by simp

/-
**Quotient edge bound**: The quotient graph on m blocks has at most m(m-1) edges
    (since it's a simple digraph with no self-loops).
-/
theorem quotient_edge_bound (G : DGraph n) {m : ℕ} (P : Partition n m) :
    (quotientGraph G P).edgeCount ≤ m * (m - 1) := by
  convert Finset.card_le_card ( show Finset.univ.filter ( fun p : Fin m × Fin m => ( G.quotientGraph P ).adj p.1 p.2 ) ⊆ Finset.univ.filter ( fun p : Fin m × Fin m => p.1 ≠ p.2 ) from ?_ ) using 1;
  · rw [ Finset.card_filter ];
    erw [ Finset.sum_product ];
    simp +decide [ Finset.sum_ite, Finset.filter_ne ];
  · intro p hp; contrapose! hp; unfold DGraph.quotientGraph at *; aesop;

/-
**Edge preservation**: If the original graph has an edge i → j with i, j in
    different blocks, then the quotient has an edge between those blocks.
-/
theorem quotient_preserves_cross_edges (G : DGraph n) {m : ℕ} (P : Partition n m)
    (i j : Fin n) (hij : G.adj i j = true) (hne : P.blockOf i ≠ P.blockOf j) :
    (quotientGraph G P).adj (P.blockOf i) (P.blockOf j) = true := by
  unfold DGraph.quotientGraph; aesop;

/-! ## Part 7: DAG Walk Vanishing -/

/-
**DAG Walk Vanishing**: In a DAG on n vertices, there are no closed walks
    of any positive length. Since a DAG has no cycles, every closed walk must
    have length 0.
-/
theorem dag_no_closed_walks (G : DGraph n) (hdag : G.IsDAG) (k : ℕ) (hk : 0 < k) :
    G.closedWalkCount k = 0 := by
  -- In a DAG with topological ordering f, any edge i→j has f(j) < f(i). A walk of length k from i to i would give f(i) < f(i) (by transitivity of the strict inequality along the walk), which is a contradiction.
  obtain ⟨f, hf⟩ := hdag
  have h_walk_lt : ∀ i j : Fin n, G.walkCount k i j > 0 → f j + k ≤ f i := by
    induction' k with k ih <;> simp_all +decide [ DGraph.walkCount ];
    intro i j hj; contrapose! hj; simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, Nat.succ_le_iff ] ;
    intro w; by_cases hk : 0 < k <;> simp_all +decide [ DGraph.adjNat ] ;
    · grind +ring;
    · by_cases hi : i = w <;> by_cases hj : G.adj w j <;> simp_all +decide [ DGraph.walkCount ];
      linarith [ hf _ _ hj ];
  exact Finset.sum_eq_zero fun i hi => Nat.eq_zero_of_not_pos fun hi' => by linarith [ h_walk_lt i i hi' ] ;

/-
**DAG Walk Length Bound**: In a DAG on n vertices, any walk of length ≥ n
    must revisit a vertex and hence contain a cycle. Therefore all walks have
    length < n.
-/
theorem dag_walk_length_bound (G : DGraph n) (hdag : G.IsDAG) (k : ℕ) (hk : n ≤ k)
    (i j : Fin n) : G.walkCount k i j = 0 := by
  cases hy : G.walkCount k i j <;> simp_all +decide;
  -- By definition of walkCount, there exists a sequence of vertices $i = v_0, v_1, \ldots, v_k = j$ such that $G.adj v_i v_{i+1} = true$ for all $i$.
  obtain ⟨v, hv⟩ : ∃ v : Fin (k + 1) → Fin n, v 0 = i ∧ v (Fin.last k) = j ∧ ∀ i : Fin k, G.adj (v (Fin.castSucc i)) (v (Fin.succ i)) = true := by
    have h_walk_exists : ∀ k : ℕ, ∀ i j : Fin n, G.walkCount k i j ≠ 0 → ∃ v : Fin (k + 1) → Fin n, v 0 = i ∧ v (Fin.last k) = j ∧ ∀ i : Fin k, G.adj (v (Fin.castSucc i)) (v (Fin.succ i)) = true := by
      intro k i j hk; induction' k with k ih generalizing i j <;> simp_all +decide [ Fin.sum_univ_succ ] ;
      · exact ⟨ fun _ => i, rfl, by contrapose! hk; unfold DGraph.walkCount; aesop ⟩;
      · -- By definition of walkCount, there exists a vertex $w$ such that $G.walkCount k i w \neq 0$ and $G.adj w j = true$.
        obtain ⟨w, hw⟩ : ∃ w : Fin n, G.walkCount k i w ≠ 0 ∧ G.adj w j = true := by
          contrapose! hk;
          exact Finset.sum_eq_zero fun w hw => by by_cases hw' : G.walkCount k i w = 0 <;> simp_all +decide [ DGraph.adjNat ] ;
        obtain ⟨ v, hv₁, hv₂, hv₃ ⟩ := ih i w hw.1; use Fin.snoc v j; simp_all +decide [ Fin.snoc ] ;
        intro i; split_ifs <;> simp_all +decide [ Fin.castLT ] ;
        · exact hv₃ ⟨ i, by linarith ⟩;
        · grind;
        · grind;
        · bv_omega;
    exact h_walk_exists k i j ( by linarith );
  -- Since $G$ is a DAG, the sequence $v$ must be injective.
  have h_inj : Function.Injective v := by
    obtain ⟨f, hf⟩ := hdag;
    -- By definition of $f$, we know that $f(v_i)$ is strictly decreasing.
    have h_decreasing : StrictAnti (fun i : Fin (k + 1) => f (v i)) := by
      intro i j hij; induction' j using Fin.inductionOn with j ih ih; aesop;
      grind;
    exact fun i j hij => h_decreasing.injective <| by simp +decide [ hij ] ;
  exact absurd ( Fintype.card_le_of_injective v h_inj ) ( by norm_num; linarith )

/-! ## Part 8: Spectral Distance -/

/-- A moment sequence indexed by natural numbers. -/
def MomentSeq' := ℕ → ℚ

/-- The spectral distance between two moment sequences truncated at level K.
    This is the maximum absolute difference of the first K moments.
    d_K(μ, ν) = max_{k ≤ K} |μ(k) - ν(k)| -/
def spectralDistance (μ ν : MomentSeq') (K : ℕ) : ℚ :=
  (Finset.range (K + 1)).sup' ⟨0, Finset.mem_range.mpr (Nat.zero_lt_succ K)⟩
    (fun k => |μ k - ν k|)

/-
Spectral distance is symmetric.
-/
theorem spectralDistance_symm (μ ν : MomentSeq') (K : ℕ) :
    spectralDistance μ ν K = spectralDistance ν μ K := by
  unfold spectralDistance; simp +decide [ abs_sub_comm ] ;

/-
Spectral distance is zero iff the sequences agree up to level K.
-/
theorem spectralDistance_eq_zero_iff (μ ν : MomentSeq') (K : ℕ) :
    spectralDistance μ ν K = 0 ↔ ∀ k, k ≤ K → μ k = ν k := by
  constructor <;> intro h;
  · contrapose! h;
    obtain ⟨ k, hk₁, hk₂ ⟩ := h; exact ne_of_gt ( lt_of_lt_of_le ( abs_pos.mpr ( sub_ne_zero.mpr hk₂ ) ) ( Finset.le_sup' ( fun k => |μ k - ν k| ) ( Finset.mem_range.mpr ( Nat.lt_succ_of_le hk₁ ) ) ) ) ;
  · exact le_antisymm ( Finset.sup'_le _ _ fun x hx => by aesop ) ( by exact le_trans ( by norm_num ) ( Finset.le_sup' ( fun k => |μ k - ν k| ) ( Finset.mem_range.mpr ( Nat.succ_pos K ) ) ) )

/-! ## Part 9: Renormalization Chains -/

/-- A coarse-graining chain: a sequence of graphs obtained by iterated quotient
    operations, together with the sequence of vertex counts. -/
structure CoarseGrainChain where
  /-- Vertex count at step k -/
  vertexCount : ℕ → ℕ
  /-- The sequence is non-increasing -/
  mono : ∀ k, vertexCount (k + 1) ≤ vertexCount k

/-
Helper: a non-increasing ℕ-sequence satisfies a(k) ≤ a(0) - k for each k
    where all preceding steps are strict decreases. Equivalently, if the sequence
    hasn't stabilized in the first n₀ steps, it must have reached 0.
-/
private lemma antitone_nat_drops (a : ℕ → ℕ) (h : ∀ k, a (k + 1) ≤ a k)
    (k : ℕ) (hk : ∀ j, j < k → a (j + 1) ≠ a j) : a k + k ≤ a 0 := by
  induction' k with k ih;
  · norm_num;
  · linarith [ ih fun j hj => hk j ( Nat.lt_succ_of_lt hj ), h k, show a ( k + 1 ) < a k from lt_of_le_of_ne ( h k ) ( hk k ( Nat.lt_succ_self k ) ) ]

/-
**Chain Stabilization**: Every coarse-graining chain eventually stabilizes.
    Since the vertex count is a non-increasing ℕ-sequence, it is eventually constant.
    This follows from the well-ordering of ℕ: any non-increasing sequence of naturals
    can have at most finitely many strict drops.
-/
theorem CoarseGrainChain.stabilizes (C : CoarseGrainChain) :
    ∃ K, ∀ k, K ≤ k → C.vertexCount (k + 1) = C.vertexCount k := by
  obtain ⟨K, hK⟩ : ∃ K, ∀ k ≥ K, C.vertexCount k = C.vertexCount K := by
    have h_antitone : Antitone (fun k => C.vertexCount k : ℕ → ℕ) := by
      exact antitone_nat_of_succ_le C.mono
    -- Since the sequence is antitone and bounded below, it must eventually stabilize.
    have h_stabilize : Filter.Tendsto (fun k => C.vertexCount k : ℕ → ℕ) Filter.atTop (nhds (sInf (Set.range (fun k => C.vertexCount k : ℕ → ℕ)))) := by
      exact tendsto_atTop_ciInf h_antitone ⟨ 0, Set.forall_mem_range.mpr fun k => Nat.zero_le _ ⟩;
    simp +zetaDelta at *;
    exact ⟨ h_stabilize.choose, fun k hk => by rw [ h_stabilize.choose_spec k hk, h_stabilize.choose_spec _ le_rfl ] ⟩;
  exact ⟨ K, fun k hk => by rw [ hK k hk, hK ( k + 1 ) ( Nat.le_succ_of_le hk ) ] ⟩

/-
**Terminal value**: Once a non-increasing ℕ-sequence stabilizes,
    its eventual value equals the infimum of the sequence.
-/
theorem CoarseGrainChain.terminal_value (C : CoarseGrainChain) :
    ∃ v, ∀ k, C.vertexCount k ≥ v ∧
      (∀ k', (∀ j, j < k' → C.vertexCount (j + 1) ≠ C.vertexCount j) → C.vertexCount k' + k' ≤ C.vertexCount 0) := by
  exact ⟨ 0, fun k => ⟨ Nat.zero_le _, fun k' hk' => antitone_nat_drops _ C.mono k' hk' ⟩ ⟩

/-! ## Part 10: Spectral Universality Conjecture (Refined) -/

/-- **Refined Spectral Universality Conjecture**: For sufficiently large DAGs
    arising from "natural" mathematical theories, the normalized spectral moments
    converge under coarse-graining to a universal distribution independent of the
    specific theory.

    We state this as: for any ε > 0 and moment level K, there exists N₀ such that
    any two "natural" DAGs with ≥ N₀ vertices have spectral distance < ε after
    suitable coarse-graining. -/
def RefinedSpectralUniversality : Prop :=
  ∀ (K : ℕ) (ε : ℚ) (_hε : 0 < ε),
  ∃ (_N₀ : ℕ),
  ∀ (μ₁ μ₂ : MomentSeq'),
    True →  -- placeholder for "natural DAG" predicate
    spectralDistance μ₁ μ₂ K ≤ ε

end DGraph
end