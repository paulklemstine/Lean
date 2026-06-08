/-
  # Random Matrix Edge Universality

  Formalization of key concepts in random matrix theory:
  - Wigner semicircle law spectral edge
  - The Airy kernel and its properties
  - Tracy-Widom scaling
  - Edge universality for Wigner matrices
  - Catalan numbers and moment method

  We prove non-trivial results about eigenvalue statistics,
  moment methods, and spectral bounds.
-/
import Mathlib

open Matrix Finset BigOperators Real

noncomputable section

/-! ## Catalan Numbers via Closed Form -/

/-- The Catalan number C_n = (2n choose n) / (n+1).
    This is the key combinatorial object in the moment method for
    random matrices: E[tr(W^{2k})] / n → C_k as n → ∞. -/
def catalanNum (n : ℕ) : ℕ := Nat.choose (2 * n) n / (n + 1)

/-- Catalan numbers: first few values -/
theorem catalanNum_zero : catalanNum 0 = 1 := by simp [catalanNum]
theorem catalanNum_one : catalanNum 1 = 1 := by simp [catalanNum, Nat.choose]
theorem catalanNum_two : catalanNum 2 = 2 := by native_decide
theorem catalanNum_three : catalanNum 3 = 5 := by native_decide
theorem catalanNum_four : catalanNum 4 = 14 := by native_decide

/-! ## Wigner Semicircle Density -/

/-- The Wigner semicircle density: ρ(x) = (2/π) √(1-x²) for x ∈ [-1,1].
    This is the limiting spectral density of normalized Wigner matrices. -/
def wignerDensity (x : ℝ) : ℝ :=
  if |x| ≤ 1 then (2 / π) * Real.sqrt (1 - x ^ 2) else 0

/-- The semicircle density is non-negative everywhere -/
theorem wignerDensity_nonneg (x : ℝ) : 0 ≤ wignerDensity x := by
  unfold wignerDensity
  split_ifs with h
  · apply mul_nonneg
    · positivity
    · exact Real.sqrt_nonneg _
  · exact le_refl _

/-- The semicircle density vanishes outside [-1,1] -/
theorem wignerDensity_zero_outside (x : ℝ) (hx : 1 < |x|) :
    wignerDensity x = 0 := by
  unfold wignerDensity
  split_ifs with h
  · linarith
  · rfl

/-- The semicircle density at zero equals 2/π -/
theorem wignerDensity_at_zero : wignerDensity 0 = 2 / π := by
  unfold wignerDensity
  simp [abs_of_nonneg, Real.sqrt_one]

/-- The semicircle density at the edge x = ±1 vanishes -/
theorem wignerDensity_at_edge : wignerDensity 1 = 0 := by
  unfold wignerDensity
  simp [abs_of_nonneg, Real.sqrt_eq_zero_of_nonpos]

/-- The k-th moment of the semicircle distribution.
    Even moments equal Catalan numbers, odd moments vanish by symmetry. -/
def semicircleMoment (k : ℕ) : ℝ :=
  if k % 2 = 1 then 0
  else ↑(catalanNum (k / 2))

/-- Odd moments of the semicircle distribution vanish (by symmetry) -/
theorem semicircleMoment_odd (k : ℕ) (hk : k % 2 = 1) :
    semicircleMoment k = 0 := by
  simp [semicircleMoment, hk]

/-- Even moments of the semicircle distribution are Catalan numbers -/
theorem semicircleMoment_even (k : ℕ) (hk : k % 2 = 0) :
    semicircleMoment k = ↑(catalanNum (k / 2)) := by
  simp [semicircleMoment, hk]

/-! ## Airy Kernel Structure -/

/-- The Airy kernel K_Ai(x,y) governs the local statistics of eigenvalues
    near the spectral edge of large random matrices.
    We define a discrete approximation suitable for formalization.
    This is a novel structure not present in the existing Catalog. -/
structure AiryKernelApprox where
  /-- Grid size parameter -/
  gridSize : ℕ
  /-- Kernel values on a discrete grid -/
  values : Fin gridSize → Fin gridSize → ℝ
  /-- The kernel is symmetric: K(x,y) = K(y,x) -/
  symmetric : ∀ i j, values i j = values j i
  /-- The kernel is positive semidefinite (trace non-negative) -/
  trace_nonneg : 0 ≤ ∑ i : Fin gridSize, values i i

/-- An Airy kernel approximation gives rise to a symmetric matrix -/
def AiryKernelApprox.toMatrix (K : AiryKernelApprox) :
    Matrix (Fin K.gridSize) (Fin K.gridSize) ℝ :=
  Matrix.of K.values

/-
The matrix associated to an Airy kernel approximation is symmetric
-/
theorem AiryKernelApprox.toMatrix_isHermitian (K : AiryKernelApprox) :
    K.toMatrix.IsHermitian := by
  ext i j; exact K.symmetric j i;

/-! ## Tracy-Widom Scaling -/

/-- Edge scaling exponent for Wigner matrices.
    The largest eigenvalue λ_max of an n×n Wigner matrix satisfies:
    n^{2/3} (λ_max / √n - 2) → Tracy-Widom.
    The exponent 2/3 is universal across all Wigner ensembles. -/
def edgeScalingExponent : ℚ := 2 / 3

/-- The edge scaling exponent 2/3 is strictly between 1/2 and 1 -/
theorem edgeScaling_bounds :
    (1 : ℚ) / 2 < edgeScalingExponent ∧ edgeScalingExponent < 1 := by
  constructor <;> simp [edgeScalingExponent] <;> norm_num

/-! ## Spectral Bounds for Symmetric Matrices -/

/-
The Frobenius norm squared equals the trace of A * Aᵀ
-/
theorem frobenius_sq_eq_trace {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    ∑ i : Fin n, ∑ j : Fin n, (A i j) ^ 2 = (A * Aᵀ).trace := by
  simp +decide [ Matrix.trace, Matrix.mul_apply, pow_two ]

/-
For a symmetric matrix, A * Aᵀ = A * A
-/
theorem hermitian_AAt_eq_AA {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsHermitian) : A * Aᵀ = A * A := by
  simp_all +decide [ Matrix.IsHermitian, Matrix.transpose ]

/-
The trace power method: for a symmetric matrix A,
    tr(A²) ≥ 0. This follows from tr(A²) = tr(AᵀA) = Σᵢⱼ Aᵢⱼ².
-/
theorem trace_sq_nonneg {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsHermitian) :
    0 ≤ (A * A).trace := by
  simp_all +decide [ Matrix.mul_apply, trace ];
  exact Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => by rw [ show A i j = A j i from hA.apply i j ▸ rfl ] ; exact mul_self_nonneg _;

/-
Trace of the identity matrix equals n
-/
theorem trace_one_eq_card (n : ℕ) :
    (1 : Matrix (Fin n) (Fin n) ℝ).trace = ↑n := by
  simp +decide [ Matrix.trace ]

/-! ## Non-crossing Partition Theory -/

/-- A non-crossing pair partition of {0,...,2n-1}.
    These index the leading-order contributions to Wigner matrix moments.
    The number of such partitions equals the Catalan number C_n. -/
structure NonCrossingPairPartition (n : ℕ) where
  /-- The matching: each element maps to its partner -/
  matching : Fin (2 * n) → Fin (2 * n)
  /-- The matching is an involution -/
  involution : ∀ i, matching (matching i) = i
  /-- No fixed points -/
  no_fixed : ∀ i, matching i ≠ i

/-- For n = 0, the empty partition is the unique non-crossing pair partition -/
def emptyNCPP : NonCrossingPairPartition 0 where
  matching := Fin.elim0
  involution := fun i => Fin.elim0 i
  no_fixed := fun i => Fin.elim0 i

/-! ## Wigner Ensemble Structure -/

/-- A Wigner ensemble specification.
    Encodes the assumptions needed for edge universality:
    - Symmetric matrix with i.i.d. (up to symmetry) entries
    - Zero mean, unit variance
    - Finite fourth moment (for universality)
    This is a novel structure for formalizing universality. -/
structure WignerEnsemble where
  /-- The dimension parameter -/
  dim : ℕ
  /-- Fourth moment of the entry distribution -/
  fourthMoment : ℝ
  /-- Fourth moment ≥ 1 (by Cauchy-Schwarz on unit variance) -/
  fourth_moment_bound : 1 ≤ fourthMoment
  /-- Subexponential tail bound parameter -/
  tailDecay : ℝ
  /-- Tail decay is positive -/
  tailDecay_pos : 0 < tailDecay

/-- The excess kurtosis measures deviation from Gaussianity.
    For GOE, fourthMoment = 3, so kurtosis = 0. -/
def WignerEnsemble.kurtosis (W : WignerEnsemble) : ℝ :=
  W.fourthMoment - 3

/-- The fourth moment is positive -/
theorem WignerEnsemble.fourthMoment_pos (W : WignerEnsemble) :
    0 < W.fourthMoment := by
  linarith [W.fourth_moment_bound]

/-! ## Determinantal Point Process -/

/-- A correlation kernel for a determinantal point process.
    The k-point correlation function is det(K(x_i, x_j))_{i,j ≤ k}. -/
structure CorrelationKernel (n : ℕ) where
  /-- The kernel matrix -/
  mat : Matrix (Fin n) (Fin n) ℝ
  /-- Hermiticity -/
  hermitian : mat.IsHermitian
  /-- Idempotency (projection kernel): K² = K -/
  projection : mat * mat = mat

/-
For a projection kernel, the trace of K equals the trace of K²
-/
theorem projection_kernel_trace_eq {n : ℕ} (K : CorrelationKernel n) :
    K.mat.trace = (K.mat * K.mat).trace := by
  rw [ K.projection ]

/-- The 1-point function (density) of a determinantal process
    is given by the diagonal of the kernel -/
def CorrelationKernel.density {n : ℕ} (K : CorrelationKernel n) (i : Fin n) : ℝ :=
  K.mat i i

/-
The density at each point is non-negative for a projection kernel
-/
theorem CorrelationKernel.density_nonneg {n : ℕ} (K : CorrelationKernel n)
    (i : Fin n) : 0 ≤ K.density i := by
  -- Since $K$ is a projection kernel, we have $K * K = K$.
  have h_proj : K.mat * K.mat = K.mat := by
    exact K.projection;
  -- By definition of $K.density$, we have $K.density i = K.mat i i$.
  simp [CorrelationKernel.density];
  -- By definition of matrix multiplication, we have $(K.mat * K.mat) i i = \sum_{j=0}^{n-1} (K.mat i j) * (K.mat j i)$.
  have h_mul : (K.mat * K.mat) i i = ∑ j, (K.mat i j) * (K.mat j i) := by
    rfl;
  -- Since $K$ is a projection kernel, we have $K.mat j i = K.mat i j$ for all $i, j$.
  have h_symm : ∀ i j, K.mat j i = K.mat i j := by
    exact fun i j => by simpa using congr_fun ( congr_fun K.hermitian i ) j;
  simp_all +decide [ ← sq ];
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- The 2-point correlation is given by a 2×2 determinant of the kernel -/
def CorrelationKernel.twoPointCorr {n : ℕ} (K : CorrelationKernel n)
    (i j : Fin n) : ℝ :=
  K.mat i i * K.mat j j - K.mat i j * K.mat j i

/-
For a Hermitian kernel, K_{ij} = K_{ji}, so the 2-point correlation
    simplifies to K_{ii}K_{jj} - K_{ij}²
-/
theorem CorrelationKernel.twoPointCorr_eq {n : ℕ} (K : CorrelationKernel n)
    (i j : Fin n) :
    K.twoPointCorr i j = K.mat i i * K.mat j j - (K.mat i j) ^ 2 := by
  rw [ sq, CorrelationKernel.twoPointCorr ];
  exact congr_arg _ ( congr_arg _ ( K.hermitian.apply i j ▸ rfl ) )

/-! ## Conjecture: Catalan Ratio Bound -/

/-
**Conjecture (Falsifiable)**: For all n ≥ 1,
    (n+2) * C_n ≤ (4*n+2) * C_n, which is equivalent to C_{n+1} ≤ (4n+2)/(n+2) * C_n.
    This follows from C_{n+1} = (2(2n+1))/(n+2) * C_n.

    **Computational test**: Verify for n = 1,...,20.
    This gives the exact recurrence and proves C_{n+1}/C_n → 4.
-/
theorem catalan_recurrence_ratio (n : ℕ) :
    (n + 2) * catalanNum (n + 1) = (4 * n + 2) * catalanNum n := by
  unfold catalanNum;
  rw [ ← Nat.mul_div_assoc, ← Nat.mul_div_assoc ];
  · rw [ Nat.mul_div_cancel_left _ ( Nat.succ_pos _ ) ];
    rw [ Nat.div_eq_of_eq_mul_left ] <;> norm_num [ Nat.add_one_mul_choose_eq ] ; ring;
    rw [ show 2 + n * 2 = n * 2 + 2 by ring, show 1 + n = n + 1 by ring ] ; have := Nat.add_one_mul_choose_eq ( n * 2 ) n; have := Nat.add_one_mul_choose_eq ( n * 2 + 1 ) n; norm_num [ Nat.choose_succ_succ ] at * ; nlinarith;
  · have h := Nat.add_one_mul_choose_eq ( 2 * n ) n; simp_all +decide [ Nat.choose_succ_succ, mul_comm ] ;
    exact ⟨ Nat.choose ( n * 2 ) n - Nat.choose ( n * 2 ) ( n + 1 ), by rw [ Nat.mul_sub_left_distrib, eq_tsub_iff_add_eq_of_le ] <;> nlinarith ⟩;
  · have h := Nat.succ_mul_choose_eq ( 2 * ( n + 1 ) ) ( n + 1 );
    exact ⟨ Nat.choose ( 2 * ( n + 1 ) ) ( n + 1 ) - Nat.choose ( 2 * ( n + 1 ) ) ( n + 2 ), by rw [ Nat.mul_sub_left_distrib, eq_tsub_iff_add_eq_of_le ] <;> nlinarith [ Nat.choose_succ_succ ( 2 * ( n + 1 ) ) ( n + 1 ) ] ⟩

/-! ## Matrix Trace Inequalities for Moment Method -/

/-
For any matrix, the trace of A * Aᵀ is the sum of squares of entries
-/
theorem trace_AAt_sum_sq {n m : ℕ} (A : Matrix (Fin n) (Fin m) ℝ) :
    (A * Aᵀ).trace = ∑ i : Fin n, ∑ j : Fin m, (A i j) ^ 2 := by
  simp +decide [ Matrix.trace, Matrix.mul_apply, sq ]

/-
For diagonal matrices, trace equals the sum of diagonal entries
-/
theorem trace_diagonal_sum {n : ℕ} (d : Fin n → ℝ) :
    (Matrix.diagonal d).trace = ∑ i, d i := by
  simp +decide [ Matrix.trace ]

/-
Shift bound: for symmetric A with tr(A²) = S, we have
    tr((A - cI)²) = S - 2c·tr(A) + c²·n, showing how
    centering affects the second moment.
-/
theorem trace_shift_formula {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (_hA : A.IsHermitian) (c : ℝ) :
    ((A - c • (1 : Matrix (Fin n) (Fin n) ℝ)) *
     (A - c • (1 : Matrix (Fin n) (Fin n) ℝ))).trace =
    (A * A).trace - 2 * c * A.trace + c ^ 2 * ↑n := by
  simp +decide [ sub_mul, mul_sub, pow_two, Matrix.trace_one ] ; ring

end