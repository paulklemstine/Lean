import Mathlib

/-! # Phase 2a: Sub-Quadratic Attention — Asymptotic Complexity Reduction

We formalize a block-sparse attention approximation and prove:
1. Its computational complexity is strictly sub-quadratic: O(N · B) where B = ⌈√N⌉.
2. The spectral error between the exact and approximate attention matrices
   is bounded in Frobenius norm.
-/

noncomputable section

open Matrix BigOperators Real Finset

/-! ## Section 1: Block-Sparse Attention Pattern -/

/-- The block size for sub-quadratic attention: B = max(⌈√N⌉, 1). -/
def blockSize (N : ℕ) : ℕ := max (Nat.sqrt N + 1) 1

/-- Block size is always positive. -/
theorem blockSize_pos (N : ℕ) : 0 < blockSize N := by simp [blockSize]

/-- Block size is at most √N + 1. -/
theorem blockSize_le (N : ℕ) : blockSize N ≤ Nat.sqrt N + 1 := by
  simp [blockSize]

/-- The block index of token i. -/
def blockIndex (N : ℕ) (i : ℕ) : ℕ := i / blockSize N

/-- The sparse attention mask: token i attends to token j iff they are
in the same block, or j is in block 0 (the global anchor block). -/
def sparseAttentionMask (N : ℕ) (i j : ℕ) : Bool :=
  (blockIndex N i = blockIndex N j) || (blockIndex N j = 0)

/-! ## Section 2: Complexity Bounds

The key complexity result: total sparse attention pairs ≤ N · 2B
where B = blockSize N ≈ √N, giving O(N^{3/2}) complexity. -/

/-- Number of tokens that token i attends to under block-sparse attention. -/
def sparseAttendCount (N : ℕ) (i : ℕ) : ℕ :=
  ((Finset.range N).filter (fun j => sparseAttentionMask N i j = true)).card

/-- The total number of attention pairs in full quadratic attention. -/
def fullAttentionPairs (N : ℕ) : ℕ := N * N

/-- The total number of attention pairs in block-sparse attention. -/
def sparseAttentionPairs (N : ℕ) : ℕ :=
  ∑ i ∈ Finset.range N, sparseAttendCount N i

/-
Each token attends to at most 2 · blockSize(N) tokens
(its own block + anchor block).
-/
theorem sparseAttendCount_le_2B (N : ℕ) (i : ℕ) :
    sparseAttendCount N i ≤ 2 * blockSize N := by
  -- The set of tokens that token i attends to in the sparse attention is a subset of those that are in the same block or in block 0.
  have h_subset : (Finset.range N).filter (fun j => (sparseAttentionMask N i j)) ⊆ ((Finset.range N).filter (fun j => blockIndex N i = blockIndex N j)) ∪ ((Finset.range N).filter (fun j => blockIndex N j = 0)) := by
    intro j hj; unfold sparseAttentionMask at hj; aesop;
  -- The set of tokens that are in the same block or in block 0 has cardinality at most 2 * blockSize N.
  have h_card : ((Finset.range N).filter (fun j => blockIndex N i = blockIndex N j)).card ≤ blockSize N ∧ ((Finset.range N).filter (fun j => blockIndex N j = 0)).card ≤ blockSize N := by
    constructor;
    · -- The set of tokens in the same block as i is a subset of the range N and has cardinality at most blockSize N.
      have h_same_block : ((Finset.range N).filter (fun j => blockIndex N i = blockIndex N j)).card ≤ Finset.card (Finset.Ico (blockIndex N i * blockSize N) ((blockIndex N i + 1) * blockSize N)) := by
        refine Finset.card_le_card ?_;
        intro j hj; simp_all +decide [ blockIndex ];
        exact ⟨ Nat.div_mul_le_self _ _, by linarith [ Nat.div_add_mod j ( blockSize N ), Nat.mod_lt j ( blockSize_pos N ) ] ⟩;
      simp_all +decide [ add_mul ];
    · -- The set of tokens that are in block 0 has cardinality at most blockSize N.
      have h_card_block0 : ((Finset.range N).filter (fun j => blockIndex N j = 0)).card ≤ Finset.card (Finset.range (blockSize N)) := by
        refine Finset.card_le_card ?_;
        exact fun x hx => Finset.mem_range.mpr <| Nat.lt_of_not_ge fun h => absurd ( Finset.mem_filter.mp hx |>.2 ) ( Nat.ne_of_gt <| Nat.div_pos h <| Nat.pos_of_ne_zero <| by rw [ blockSize ] ; positivity );
      aesop;
  exact le_trans ( Finset.card_le_card h_subset ) ( le_trans ( Finset.card_union_le _ _ ) ( by linarith ) )

/-- Key bound: sparse attention pairs ≤ N * (2 * blockSize N). -/
theorem sparse_pairs_bound (N : ℕ) :
    sparseAttentionPairs N ≤ N * (2 * blockSize N) := by
  unfold sparseAttentionPairs
  calc ∑ i ∈ Finset.range N, sparseAttendCount N i
      ≤ ∑ _i ∈ Finset.range N, (2 * blockSize N) :=
        Finset.sum_le_sum (fun i _ => sparseAttendCount_le_2B N i)
    _ = N * (2 * blockSize N) := by
        simp [Finset.sum_const, Finset.card_range, mul_comm]

/-
For N ≥ 9, 2 * blockSize(N) < N.
-/
theorem sparse_strictly_subquadratic (N : ℕ) (hN : 9 ≤ N) :
    2 * blockSize N < N := by
  rcases N with ( _ | _ | _ | _ | _ | _ | _ | _ | _ | N ) <;> simp +arith +decide [ Nat.sqrt ] at *;
  -- Let's simplify the expression using the definition of `blockSize`.
  simp [blockSize];
  nlinarith [ Nat.sqrt_le ( N + 9 ) ]

/-- Main complexity theorem: for N ≥ 9, sparse attention uses
strictly fewer than N² total pairs. -/
theorem sparse_complexity_lt_quadratic (N : ℕ) (hN : 9 ≤ N) :
    sparseAttentionPairs N < fullAttentionPairs N := by
  have hsub := sparse_strictly_subquadratic N hN
  have hbound := sparse_pairs_bound N
  unfold fullAttentionPairs
  calc sparseAttentionPairs N
      ≤ N * (2 * blockSize N) := hbound
    _ < N * N := Nat.mul_lt_mul_of_pos_left hsub (by omega)

/-! ## Section 3: Spectral Error Bound -/

/-- Frobenius norm squared of a matrix. -/
def frobeniusNormSq (n m : ℕ) (M : Matrix (Fin n) (Fin m) ℝ) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin m, (M i j) ^ 2

/-- Frobenius norm squared is non-negative. -/
theorem frobeniusNormSq_nonneg (n m : ℕ) (M : Matrix (Fin n) (Fin m) ℝ) :
    0 ≤ frobeniusNormSq n m M := by
  apply Finset.sum_nonneg; intro i _
  apply Finset.sum_nonneg; intro j _; exact sq_nonneg _

/-- The residual (error) matrix from masking. -/
def maskResidual (n : ℕ) (mask : Fin n → Fin n → Bool) (M : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of (fun i j => if mask i j then 0 else M i j)

/-
The Frobenius norm of the residual of a [0,1]-valued matrix is bounded
by the number of masked-out entries.
-/
theorem residual_frobenius_bound (n : ℕ) (mask : Fin n → Fin n → Bool)
    (M : Matrix (Fin n) (Fin n) ℝ)
    (hM : ∀ i j, 0 ≤ M i j ∧ M i j ≤ 1) :
    frobeniusNormSq n n (maskResidual n mask M) ≤
    ((Finset.univ ×ˢ Finset.univ).filter
      (fun p : Fin n × Fin n => mask p.1 p.2 = false)).card := by
  simp [frobeniusNormSq, maskResidual];
  convert Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => ?_;
  rotate_left;
  exact inferInstance;
  exact fun i j => if mask i j = true then 0 else 1;
  · split_ifs <;> nlinarith [ hM i j ];
  · infer_instance;
  · simp +decide [ Finset.sum_ite ];
    rw_mod_cast [ Finset.card_filter ];
    erw [ Finset.sum_product ] ; aesop

end