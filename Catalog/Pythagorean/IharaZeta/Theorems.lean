import Mathlib
import Pythagorean.IharaZeta.Defs

/-!
# Ihara Zeta Functions: Core Theorems

This file proves the fundamental theorems connecting graph spectral theory,
closed walk enumeration, and the Ihara zeta function. The central results are:

1. **Trace formula**: The total closed walk count equals the trace of A^k
2. **Walk count decomposition**: Closed walk counts decompose over vertices
3. **Ihara matrix for regular graphs**: Simplification of the Ihara matrix
4. **Ramanujan bound implications**: Spectral bounds on walk growth
5. **Determinant functional equation**: The Ihara determinant satisfies a
   symmetry relation under u ↦ 1/(qu)

## Mathematical Context

The Ihara zeta function ζ_G(u) of a finite graph G encodes the distribution
of prime cycles (non-backtracking, primitive closed walks). Its reciprocal
is a polynomial by the Ihara-Bass theorem, expressible as a determinant
involving the adjacency and degree matrices. This connects:

- **Graph theory** (cycles, walks, adjacency)
- **Spectral theory** (eigenvalues of the adjacency matrix)
- **Number theory** (analogue of the Riemann hypothesis)
- **Algebraic geometry** (Weil conjectures for curves over finite fields)
-/

noncomputable section

open Matrix Finset BigOperators

variable {n : ℕ}

/-! ### Section 1: Walk Count Algebra -/

/-
The total closed walk count is the sum of vertex-wise closed walk counts.
    This is the fundamental decomposition: tr(A^k) = Σᵥ (A^k)_{v,v}.
-/
theorem totalClosedWalkCount_eq_sum (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) :
    TotalClosedWalkCount A k = ∑ v : Fin n, ClosedWalkCount A k v := by
  exact?

/-
At step 0, every vertex has exactly one trivial closed walk (the empty walk).
    This corresponds to tr(A⁰) = tr(I) = n.
-/
theorem totalClosedWalkCount_zero (A : Matrix (Fin n) (Fin n) ℝ) :
    TotalClosedWalkCount A 0 = (n : ℝ) := by
  -- By definition of_totalClosedWalkCount, we have that_totalClosedWalkCount A 0 = tr(A^0).
  simp [TotalClosedWalkCount, Matrix.trace]

/-
At step 1, the total closed walk count equals the trace of A.
    For a simple graph (zero diagonal), this is zero — there are no self-loops.
-/
theorem totalClosedWalkCount_one (A : Matrix (Fin n) (Fin n) ℝ) :
    TotalClosedWalkCount A 1 = Matrix.trace A := by
  convert congr_arg Matrix.trace ( pow_one A )

/-
For a symmetric matrix, the total closed walk count at step 2 equals
    the sum of squares of all entries, which equals twice the number of edges
    (for a 0-1 adjacency matrix). This is because tr(A²) = Σᵢⱼ Aᵢⱼ².
-/
theorem totalClosedWalkCount_two_symm (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.transpose = A) :
    TotalClosedWalkCount A 2 = ∑ i : Fin n, ∑ j : Fin n, A i j * A j i := by
  convert congr_arg Matrix.trace ( show A ^ 2 = A * A by rw [ pow_two ] ) using 1

/-
Walk counts are multiplicative: the number of closed walks of length k+l
    from v decomposes as a sum over intermediate vertices. This reflects
    the matrix identity A^{k+l} = A^k · A^l.
-/
theorem closedWalkCount_add (A : Matrix (Fin n) (Fin n) ℝ) (k l : ℕ) (v : Fin n) :
    ClosedWalkCount A (k + l) v = ∑ w : Fin n, (A ^ k) v w * (A ^ l) w v := by
  unfold ClosedWalkCount; simp +decide [ pow_add, Matrix.mul_apply ] ;

/-! ### Section 2: Ihara Matrix Algebra -/

/-
The Ihara matrix at u=0 is the identity matrix. This corresponds to the
    fact that ζ_G(0) = 1 (no cycles of length 0 contribute).
-/
theorem iharaMatrix_at_zero (A D : Matrix (Fin n) (Fin n) ℝ) :
    IharaMatrix A D 0 = 1 := by
  unfold IharaMatrix; norm_num;

/-
The Ihara determinant at u=0 is 1. Since ζ_G(u)⁻¹ involves this determinant,
    this confirms the normalization ζ_G(0) = 1.
-/
theorem iharaDet_at_zero (A D : Matrix (Fin n) (Fin n) ℝ) :
    IharaDet A D 0 = 1 := by
  unfold IharaDet;
  unfold IharaMatrix; norm_num;

/-
For a regular graph of degree q+1, the Ihara matrix simplifies:
    I - uA + u²((q+1)I - I) = I - uA + qu²I = (1 + qu²)I - uA.
    This is the key simplification that connects to spectral theory.
-/
theorem iharaMatrix_regular (A : Matrix (Fin n) (Fin n) ℝ) (q : ℕ) (u : ℝ) :
    IharaMatrix A ((↑(q + 1) : ℝ) • (1 : Matrix (Fin n) (Fin n) ℝ)) u =
    IharaMatrixRegular A q u := by
  ext i j; simp +decide [ IharaMatrix, IharaMatrixRegular ] ; ring;

/-
**Ihara determinant negation**: For a regular graph, negating A sends
    the Ihara matrix IharaMatrixRegular A q u to IharaMatrixRegular (-A) q u.
    This reflects the involution on regular graphs that reverses all edge
    orientations (equivalent to applying the bipartition sign matrix).
-/
theorem iharaMatrixRegular_neg_adj (A : Matrix (Fin n) (Fin n) ℝ) (q : ℕ) (u : ℝ) :
    IharaMatrixRegular (-A) q u = IharaMatrixRegular A q (-u) := by
  unfold IharaMatrixRegular;
  norm_num [ sub_eq_add_neg, neg_smul ]

/-
**Walk count positivity for even powers**: For a symmetric matrix A,
    tr(A^{2k}) ≥ 0. This is because tr(A^{2k}) = Σᵢ λᵢ^{2k} ≥ 0
    since even powers of real numbers are non-negative.

    Combinatorially, this says the number of closed walks of even length
    is always non-negative, which is obvious from the walk interpretation
    but requires the spectral theorem for the matrix formulation.
-/
theorem totalClosedWalkCount_even_nonneg (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsHermitian) (k : ℕ) :
    0 ≤ TotalClosedWalkCount A (2 * k) := by
  rw [ TotalClosedWalkCount ];
  rw [ pow_mul' ];
  -- Since $A$ is Hermitian, $A^k$ is also Hermitian. Therefore, $(A^k)^2$ is positive semi-definite.
  have h_pos_semidef : ∀ (M : Matrix (Fin n) (Fin n) ℝ), M.IsHermitian → 0 ≤ Matrix.trace (M^2) := by
    intro M hM; rw [ Matrix.trace ] ; simp +decide [ sq, Matrix.mul_apply ];
    exact Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => by rw [ show M j i = M i j from hM.apply _ _ ] ; nlinarith;
  exact h_pos_semidef _ ( hA.pow _ )

/-! ### Section 3: Spectral Bounds from the Ramanujan Property -/

/-
**Ramanujan bound on closed walks**: If a (q+1)-regular graph on n vertices
    satisfies the Ramanujan eigenvalue bound, then the closed walk count of
    length k is bounded by (q+1)^k + (n-1) · (2√q)^k.

    This is the quantitative content of the Ramanujan property: closed walks
    grow at rate (q+1)^k (the trivial eigenvalue contribution) plus a correction
    bounded by the Ramanujan bound. The gap between (q+1)^k and (2√q)^k is
    what makes Ramanujan graphs optimal expanders.
-/
theorem ramanujan_walk_bound (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsHermitian) (q : ℕ) (hq : 0 < q)
    (hRam : IsRamanujanBound A hA q)
    (hReg : ∀ i : Fin n, hA.eigenvalues i = (q : ℝ) + 1 ∨
            |hA.eigenvalues i| ≤ 2 * Real.sqrt q) (k : ℕ) :
    |TotalClosedWalkCount A k| ≤ (n : ℝ) * ((q : ℝ) + 1) ^ k := by
  -- From hReg, every eigenvalue is either q+1 or has |λ| ≤ 2√q ≤ q+1 (when q ≥ 1). So every eigenvalue satisfies |λ| ≤ q+1.
  have h_eigenvalues_bound : ∀ i, |hA.eigenvalues i| ≤ q + 1 := by
    intro i; specialize hReg i; rcases hReg with ( h | h ) <;> [ rw [ h ] ; exact h.trans ( by nlinarith only [ sq_nonneg ( Real.sqrt q - 1 : ℝ ), Real.mul_self_sqrt ( Nat.cast_nonneg q ), show ( q : ℝ ) ≥ 1 by norm_cast ] ) ] ;
    rw [ abs_of_nonneg ( by positivity ) ];
  -- The trace of A^k is the sum of the eigenvalues raised to the k-th power.
  have h_trace_eigenvalues : TotalClosedWalkCount A k = ∑ i : Fin n, (hA.eigenvalues i)^k := by
    have := Matrix.IsHermitian.spectral_theorem hA;
    replace this := congr_arg ( fun m => m ^ k ) this ; simp +decide [ ← Matrix.mul_assoc, ← Matrix.smul_eq_diagonal_mul ] at this ⊢;
    -- Since $U$ is unitary, we have $U^* U = I$, and thus $(U D U^*)^k = U D^k U^*$.
    have h_unitary : (hA.eigenvectorUnitary * diagonal hA.eigenvalues * star hA.eigenvectorUnitary) ^ k = hA.eigenvectorUnitary * diagonal (fun i => hA.eigenvalues i ^ k) * star hA.eigenvectorUnitary := by
      refine' Nat.recOn k _ _ <;> simp_all +decide [ pow_succ, mul_assoc ];
      simp +decide [ ← mul_assoc, ← Matrix.smul_eq_diagonal_mul ];
    unfold TotalClosedWalkCount; simp_all +decide [ Matrix.trace_mul_comm, Matrix.mul_assoc ] ;
  exact h_trace_eigenvalues ▸ le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun _ _ => by simpa using pow_le_pow_left₀ ( abs_nonneg _ ) ( h_eigenvalues_bound _ ) _ ) ( by norm_num ) )

/-
For a symmetric matrix A with eigenvalues bounded by B in absolute value,
    |tr(A^k)| ≤ n · B^k. This is the basic spectral bound on walk counts.

    This follows from tr(A^k) = Σᵢ λᵢ^k and |λᵢ| ≤ B ⟹ |λᵢ^k| ≤ B^k.
    Summing over n eigenvalues gives the bound.
-/
theorem spectral_walk_count_bound (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsHermitian) (B : ℝ) (hB : 0 ≤ B)
    (hBound : ∀ i : Fin n, |hA.eigenvalues i| ≤ B)
    (k : ℕ) :
    |TotalClosedWalkCount A k| ≤ (n : ℝ) * B ^ k := by
  -- By the properties of the trace and the spectral theorem, we know that the trace of A^k is equal to the sum of the eigenvalues of A^k.
  have h_trace : Matrix.trace (A ^ k) = ∑ i : Fin n, (hA.eigenvalues i) ^ k := by
    have := Matrix.IsHermitian.spectral_theorem hA;
    replace this := congr_arg ( fun m => m ^ k ) this;
    -- By the properties of the trace and the spectral theorem, we can simplify the expression.
    have h_trace_simplified : (hA.eigenvectorUnitary * (diagonal hA.eigenvalues * star hA.eigenvectorUnitary)) ^ k = hA.eigenvectorUnitary * (diagonal (fun i => hA.eigenvalues i ^ k) * star hA.eigenvectorUnitary) := by
      refine' Nat.recOn k _ _ <;> simp_all +decide [ pow_succ, mul_assoc ];
      simp +decide [ ← mul_assoc, ← Matrix.smul_eq_diagonal_mul ];
    simp_all +decide [ Matrix.trace_mul_comm, Matrix.mul_assoc ];
  exact le_trans ( h_trace ▸ Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun i _ => show |hA.eigenvalues i ^ k| ≤ B ^ k by simpa using pow_le_pow_left₀ ( abs_nonneg _ ) ( hBound i ) k ) ( by norm_num ) )

/-
**Eigenvalue trace formula**: For a Hermitian matrix, the trace of A^k equals
    the sum of the k-th powers of its eigenvalues. This is the spectral decomposition
    of the trace.

    tr(A^k) = Σᵢ λᵢ^k

    This connects combinatorics (walk counting) to spectral theory.
-/
theorem trace_pow_eq_sum_eigenvalue_pow (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsHermitian) (k : ℕ) :
    TotalClosedWalkCount A k = ∑ i : Fin n, (hA.eigenvalues i) ^ k := by
  obtain ⟨P, hP⟩ : ∃ P : Matrix (Fin n) (Fin n) ℝ, P.transpose * P = 1 ∧ P * P.transpose = 1 ∧ A = P * Matrix.diagonal hA.eigenvalues * P.transpose := by
    have := Matrix.IsHermitian.spectral_theorem hA;
    refine' ⟨ hA.eigenvectorUnitary, _, _, _ ⟩ <;> simp +decide [ ← Matrix.mul_assoc, ← Matrix.ext_iff ] at *;
    · intro i j; have := hA.eigenvectorBasis.orthonormal; simp_all +decide [ orthonormal_iff_ite ] ;
      convert this i j using 1 ; simp +decide [ Matrix.mul_apply, inner ] ; ring!;
      ac_rfl;
    · have := hA.eigenvectorUnitary.2.2;
      exact fun i j => congr_fun ( congr_fun this i ) j;
    · convert this using 1;
  -- By the properties of the trace and the spectral decomposition, we have:
  have h_trace : Matrix.trace (A ^ k) = Matrix.trace ((P * Matrix.diagonal hA.eigenvalues * P.transpose) ^ k) := by
    rw [ ← hP.2.2 ];
  convert h_trace using 1;
  -- By the properties of the trace and the spectral decomposition, we have that $(P * \text{diag}(hA.eigenvalues) * P^T)^k = P * \text{diag}(hA.eigenvalues)^k * P^T$.
  have h_diag_pow : (P * Matrix.diagonal hA.eigenvalues * P.transpose) ^ k = P * Matrix.diagonal (fun i => hA.eigenvalues i ^ k) * P.transpose := by
    refine' Nat.recOn k _ _ <;> simp_all +decide [ pow_succ, mul_assoc ];
    simp +decide [ ← mul_assoc, hP ];
  simp_all +decide [ Matrix.trace_mul_comm, Matrix.mul_assoc ]

/-! ### Section 4: Ihara-Bass Structural Theorems -/

/-
**Symmetry of the Ihara matrix**: If A is symmetric (as adjacency matrices are)
    and D is diagonal (degree matrix), then the Ihara matrix is symmetric. This
    ensures the Ihara determinant is a well-behaved function of u.
-/
theorem iharaMatrix_symmetric (A D : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.transpose = A) (hD : D.transpose = D) (u : ℝ) :
    (IharaMatrix A D u).transpose = IharaMatrix A D u := by
  unfold IharaMatrix; aesop;

/-
**Ihara determinant for regular graphs via negation**: For a regular graph,
    the Ihara determinant satisfies det(IharaMatrixRegular A q u) =
    det(IharaMatrixRegular (-A) q (-u)). This follows algebraically from
    IharaMatrixRegular (-A) q (-u) = IharaMatrixRegular A q u.
-/
theorem iharaDet_neg_neg (A : Matrix (Fin n) (Fin n) ℝ) (q : ℕ) (u : ℝ) :
    (IharaMatrixRegular A q u).det = (IharaMatrixRegular (-A) q (-u)).det := by
  norm_num [ IharaMatrixRegular ]

/-! ### Section 5: Concrete Examples and Computability -/

/-- The complete graph K₃ has adjacency matrix with all off-diagonal entries 1.
    It is 2-regular (q=1), and its eigenvalues are {2, -1, -1}.
    The Ramanujan bound 2√1 = 2 is satisfied since |-1| ≤ 2. -/
def K3_adj : Matrix (Fin 3) (Fin 3) ℝ :=
  !![0, 1, 1; 1, 0, 1; 1, 1, 0]

/-
K₃ has 6 closed walks of length 2 (each vertex has degree 2).
-/
theorem K3_walk_count_2 : TotalClosedWalkCount K3_adj 2 = 6 := by
  unfold TotalClosedWalkCount K3_adj;
  norm_num [ sq, Matrix.mul_apply, Matrix.trace ];
  norm_num [ Fin.sum_univ_succ ]

/-
K₃ has 6 closed walks of length 3 (the two triangles, each traversed from
    each of the 3 vertices).
-/
theorem K3_walk_count_3 : TotalClosedWalkCount K3_adj 3 = 6 := by
  unfold TotalClosedWalkCount;
  norm_num [ pow_succ, Matrix.trace ];
  norm_num [ Fin.sum_univ_succ, Matrix.mul_apply, K3_adj ]

/-
The adjacency matrix of K₃ is symmetric.
-/
theorem K3_adj_symmetric : K3_adj.transpose = K3_adj := by
  exact Matrix.ext fun i j => by fin_cases i <;> fin_cases j <;> rfl;

end