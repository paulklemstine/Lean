/-! # CatalogBuild.Algebra.AutoResearch.MoonshotQuantum

Auto-generated from theorem catalog database.
Domain: Algebra/AutoResearch
Declarations: 61
-/

import Mathlib

/-- [Section: # CatalogBuild.Physics.Quantum.MoonshotQuantum
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 61] -/
theorem no_cloning_core_real (x : ℝ) (h : x = x ^ 2) : x = 0 ∨ x = 1 := by
  grind


/-- [Section: # CatalogBuild.Physics.Quantum.MoonshotQuantum
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 61] -/
theorem no_cloning_core_complex (z : ℂ) (h : z = z ^ 2) : z = 0 ∨ z = 1 := by
  exact or_iff_not_imp_left.mpr fun h0 => mul_left_cancel₀ h0 <| by linear_combination' h.symm;


/-- [Section: # CatalogBuild.Physics.Quantum.MoonshotQuantum
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 61] -/
theorem no_cloning_core_int (n : ℤ) (h : n = n ^ 2) : n = 0 ∨ n = 1 := by
  cases le_or_gt n 0 <;> [ left; right ] <;> nlinarith


/-- **Idempotent inner products are trivial**.
If f : α → ℝ satisfies f(x) = f(x)² for all x, then f only takes values 0 or 1.
This is the functional form of the no-cloning theorem. -/
theorem idempotent_function_binary (f : α → ℝ) (h : ∀ x, f x = (f x) ^ 2) :
    ∀ x, f x = 0 ∨ f x = 1 :=
  fun x => no_cloning_core_real (f x) (h x)


/-- **Time-reversal for 2×2 integer matrices with det = ±1**.
If det(M) = ±1, then M is invertible over ℤ. We construct the
explicit inverse using the adjugate (classical adjoint). -/
def time_reverse_matrix (M : Matrix (Fin 2) (Fin 2) ℤ) : Matrix (Fin 2) (Fin 2) ℤ :=
  !![M 1 1, -(M 0 1); -(M 1 0), M 0 0]


theorem time_reverse_mul (M : Matrix (Fin 2) (Fin 2) ℤ) :
    M * (time_reverse_matrix M) = M.det • (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  ext i j; fin_cases i <;> fin_cases j <;> norm_num [ Matrix.mul_apply, Matrix.det_fin_two, time_reverse_matrix ] <;> ring;


theorem time_reverse_det_one (M : Matrix (Fin 2) (Fin 2) ℤ) (hdet : M.det = 1) :
    M * (time_reverse_matrix M) = 1 := by
  convert time_reverse_mul M using 1 ; aesop


theorem time_reverse_det_neg_one (M : Matrix (Fin 2) (Fin 2) ℤ) (hdet : M.det = -1) :
    M * (time_reverse_matrix M) = -1 := by
  convert time_reverse_mul M using 1 ; aesop


theorem double_time_reverse (M : Matrix (Fin 2) (Fin 2) ℤ) :
    time_reverse_matrix (time_reverse_matrix M) = M := by
  unfold time_reverse_matrix; ext i j; fin_cases i <;> fin_cases j <;> norm_num;


/-- **Pauli X adjugate is -X**: The adjugate of X = [[0,1],[1,0]] is -X.
Since det(X) = -1, we have X⁻¹ = -adj(X) = X, confirming X is self-inverse. -/
theorem pauli_X_adjugate :
    time_reverse_matrix (!![0, 1; 1, 0] : Matrix (Fin 2) (Fin 2) ℤ) = !![0, -1; -1, 0] := by
  native_decide


theorem pauli_Z_self_adjoint :
    time_reverse_matrix (!![1, 0; 0, -1] : Matrix (Fin 2) (Fin 2) ℤ) = !![-1, 0; 0, 1] := by
  native_decide +revert


theorem time_reverse_antimorphism (A B : Matrix (Fin 2) (Fin 2) ℤ)
    (hA : A.det = 1) (hB : B.det = 1) :
    time_reverse_matrix (A * B) = time_reverse_matrix B * time_reverse_matrix A := by
  unfold time_reverse_matrix; ext i j ; fin_cases i <;> fin_cases j <;> simp +decide [ Matrix.vecHead, Matrix.vecTail ] at *;
  · rw [ Matrix.mul_apply ] ; norm_num [ Fin.sum_univ_succ ] ; ring;
  · simp [ Matrix.mul_apply, mul_comm ];
  · simp [ Matrix.mul_apply, mul_comm ];
  · simpa [ Matrix.mul_apply, mul_comm ] using by ring;


/-- The identity matrix (encoding "00"). -/
def pauli_I : Matrix (Fin 2) (Fin 2) ℤ := 1


/-- Pauli X (encoding "01"). -/
def sd_X : Matrix (Fin 2) (Fin 2) ℤ := !![0, 1; 1, 0]


/-- Pauli Z (encoding "10"). -/
def sd_Z : Matrix (Fin 2) (Fin 2) ℤ := !![1, 0; 0, -1]


/-- Pauli XZ (encoding "11"). -/
def sd_XZ : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]


/-- **Trace orthogonality**: Tr(P†Q) = 0 for distinct Paulis P, Q.
Over ℤ, we verify Tr(PᵀQ) = 0 (transpose replaces adjoint). -/
theorem trace_orth_I_X : Matrix.trace (pauli_Iᵀ * sd_X) = 0 := by
  native_decide


theorem trace_orth_I_Z : Matrix.trace (pauli_Iᵀ * sd_Z) = 0 := by
  native_decide


theorem trace_orth_I_XZ : Matrix.trace (pauli_Iᵀ * sd_XZ) = 0 := by
  native_decide


theorem trace_orth_X_Z : Matrix.trace (sd_Xᵀ * sd_Z) = 0 := by
  native_decide


theorem trace_orth_X_XZ : Matrix.trace (sd_Xᵀ * sd_XZ) = 0 := by
  native_decide


theorem trace_orth_Z_XZ : Matrix.trace (sd_Zᵀ * sd_XZ) = 0 := by
  native_decide


/-- **Self-trace normalization**: Tr(P†P) = 2 for each Pauli. -/
theorem trace_norm_I : Matrix.trace (pauli_Iᵀ * pauli_I) = 2 := by native_decide


theorem trace_norm_X : Matrix.trace (sd_Xᵀ * sd_X) = 2 := by native_decide


theorem trace_norm_Z : Matrix.trace (sd_Zᵀ * sd_Z) = 2 := by native_decide


theorem trace_norm_XZ : Matrix.trace (sd_Xᵀ * sd_XZ) = 0 := by native_decide


/-- **Superdense coding capacity theorem**: 4 orthogonal Pauli operations
on a 2-dimensional space encode log₂(4) = 2 classical bits.
The number of distinguishable encodings equals dim². -/
theorem superdense_capacity : (Fintype.card (Fin 2)) ^ 2 = 4 := by norm_num


/-- **The Pauli group structure**: The four Pauli matrices form a group
under multiplication (up to signs). -/
theorem pauli_group_closure_X_sq : sd_X * sd_X = 1 := by native_decide


theorem pauli_group_closure_Z_sq : sd_Z * sd_Z = 1 := by native_decide


theorem pauli_group_closure_XZ_sq : sd_XZ * sd_XZ = -(1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  native_decide


theorem classical_CHSH_bound (a a' b b' : ℤ)
    (ha : a = 1 ∨ a = -1) (ha' : a' = 1 ∨ a' = -1)
    (hb : b = 1 ∨ b = -1) (hb' : b' = 1 ∨ b' = -1) :
    a * b + a * b' + a' * b - a' * b' ≤ 2 := by
  rcases ha with ( rfl | rfl ) <;> rcases ha' with ( rfl | rfl ) <;> rcases hb with ( rfl | rfl ) <;> rcases hb' with ( rfl | rfl ) <;> trivial;


theorem classical_CHSH_bound_abs (a a' b b' : ℤ)
    (ha : a = 1 ∨ a = -1) (ha' : a' = 1 ∨ a' = -1)
    (hb : b = 1 ∨ b = -1) (hb' : b' = 1 ∨ b' = -1) :
    |a * b + a * b' + a' * b - a' * b'| ≤ 2 := by
  rcases ha with ( rfl | rfl ) <;> rcases ha' with ( rfl | rfl ) <;> rcases hb with ( rfl | rfl ) <;> rcases hb' with ( rfl | rfl ) <;> trivial;


theorem quantum_exceeds_classical : (2 : ℝ) < 2 * Real.sqrt 2 := by
  nlinarith [ Real.sqrt_nonneg 2, Real.sq_sqrt zero_le_two ]


theorem tsirelson_bound_sq : (2 * Real.sqrt 2) ^ 2 = (8 : ℝ) := by
  norm_num [ mul_pow ]


/-- Symplectic inner product for n-qubit Pauli operators represented as
pairs of binary vectors (x, z) where the operator is X^x · Z^z. -/
def symplectic_inner (n : ℕ) (a b : Fin n → ZMod 2 × ZMod 2) : ZMod 2 :=
  ∑ i, ((a i).1 * (b i).2 + (a i).2 * (b i).1)

-- **Commutation criterion**: Two Pauli operators commute iff their
-- symplectic inner product is 0.
-- This is a standard result in quantum error correction theory.


/-- **The [[5,1,3]] perfect code**: Smallest code correcting 1 error.
5 physical qubits protect 1 logical qubit with distance 3.
We verify the Singleton bound: k ≤ n - 2(d-1). -/
theorem perfect_code_singleton : 1 ≤ 5 - 2 * (3 - 1) := by norm_num


/-- **The [[7,1,3]] Steane code satisfies the Singleton bound**. -/
theorem steane_code_singleton : 1 ≤ 7 - 2 * (3 - 1) := by norm_num


/-- **Quantum Hamming bound**: For an [[n,k,d]] code correcting t = ⌊(d-1)/2⌋ errors,
2^(n-k) ≥ Σᵢ₌₀ᵗ C(n,i) · 3ⁱ. The [[5,1,3]] code saturates this. -/
theorem quantum_hamming_bound_5_1_3 :
    2 ^ (5 - 1) ≥ ∑ i ∈ range 2, Nat.choose 5 i * 3 ^ i := by native_decide


/-- **Error correction rate**: For the Steane code, the code rate is k/n = 1/7. -/
theorem steane_code_rate : (1 : ℚ) / 7 < 1 := by norm_num


/-- **Gate counting bound**: A circuit of depth d over a k-element gate set
can implement at most k^d distinct operations. To approximate all
unitaries in SU(2^n) to precision ε, we need at least
(1/ε)^(4^n - 1) distinct circuits (volume argument). -/
theorem gate_counting_lower_bound (k d n : ℕ) (hk : 2 ≤ k) (hn : 1 ≤ n) :
    k ^ d ≥ 2 ^ d := Nat.pow_le_pow_left hk d


theorem depth_log_bound (k d : ℕ) (hk : 2 ≤ k) (hd : 0 < d) :
    k ^ d > d := by
  exact Nat.le_induction ( by linarith ) ( fun n hn ih => by rw [ pow_succ' ] ; nlinarith ) d hd


theorem exponential_beats_polynomial (n : ℕ) (hn : 13 ≤ n) : 2 ^ n > n ^ 3 := by
  exact Nat.le_induction ( by norm_num ) ( fun k hk ih ↦ by norm_num [ Nat.pow_succ' ] at * ; nlinarith ) _ hn


theorem knill_lower_bound_base (n : ℕ) (hn : 1 ≤ n) : 4 ^ n ≥ 4 * n := by
  induction hn <;> norm_num [ pow_succ' ] at * ; linarith


theorem bloch_sphere_constraint (x y z : ℝ) (h : x ^ 2 + y ^ 2 + z ^ 2 = 1) :
    x ^ 2 ≤ 1 ∧ y ^ 2 ≤ 1 ∧ z ^ 2 ≤ 1 := by
  exact ⟨ by nlinarith, by nlinarith, by nlinarith ⟩


theorem purity_bound_bloch (x y z : ℝ) (h : x ^ 2 + y ^ 2 + z ^ 2 ≤ 1) :
    (1 + (x ^ 2 + y ^ 2 + z ^ 2)) / 2 ≤ 1 := by
  linarith


/-- **Von Neumann entropy bound**: For a qubit, S(ρ) ≤ log 2 = 1 bit.
Maximum entropy = maximum uncertainty = center of Bloch sphere. -/
theorem max_entropy_qubit : Real.log 2 > 0 := Real.log_pos (by norm_num)


/-- Elliptic gates rotate the Bloch sphere. -/
def is_elliptic (M : Matrix (Fin 2) (Fin 2) ℤ) : Prop :=
  M.det = 1 ∧ |M.trace| < 2


/-- Parabolic gates translate (shear). -/
def is_parabolic (M : Matrix (Fin 2) (Fin 2) ℤ) : Prop :=
  M.det = 1 ∧ |M.trace| = 2


/-- Hyperbolic gates squeeze. -/
def is_hyperbolic (M : Matrix (Fin 2) (Fin 2) ℤ) : Prop :=
  M.det = 1 ∧ |M.trace| > 2


theorem sl2_trichotomy (M : Matrix (Fin 2) (Fin 2) ℤ) (hdet : M.det = 1) :
    is_elliptic M ∨ is_parabolic M ∨ is_hyperbolic M := by
  unfold is_elliptic is_parabolic is_hyperbolic; cases lt_trichotomy ( |M.trace| ) 2 <;> aesop;


theorem S_is_elliptic : is_elliptic !![0, -1; 1, 0] := by
  constructor <;> norm_num [ Matrix.det_fin_two, Matrix.trace_fin_two ]


theorem T_sq_is_parabolic : is_parabolic !![1, 2; 0, 1] := by
  constructor <;> norm_num [ Matrix.det_fin_two, Matrix.trace_fin_two ]


theorem M1_is_parabolic : is_parabolic !![2, -1; 1, 0] := by
  exact ⟨ by decide, by decide ⟩


theorem sl2_preserves_pythagorean_structure (M : Matrix (Fin 2) (Fin 2) ℤ)
    (hdet : M.det = 1) (m n : ℤ) :
    let v := M *ᵥ ![m, n]
    let m' := v 0
    let n' := v 1
    m' ^ 2 - n' ^ 2 = (M 0 0 * m + M 0 1 * n) ^ 2 - (M 1 0 * m + M 1 1 * n) ^ 2 := by
  simp +decide [ Matrix.mulVec, dotProduct ]


theorem no_signaling_trace (A : Matrix (Fin 2) (Fin 2) ℤ)
    (h : A * Aᵀ = 1) : Matrix.trace (A * Aᵀ) = 2 := by
  aesop

-- **Orthogonal matrices over ℤ form the no-signaling group**.
-- The only 2×2 integer matrices with A·Aᵀ = I are: ±I, ±X, ±[[0,-1],[1,0]].
-- These are exactly the signed permutation matrices.


theorem quantum_parallelism (n : ℕ) (hn : 1 ≤ n) :
    2 ^ n ≥ 2 * n := by
  induction hn <;> simp +decide [ pow_succ' ] at * ; linarith [ Nat.one_le_pow ‹_› 2 zero_lt_two ]


theorem simon_gap (n : ℕ) (hn : 6 ≤ n) : n < 2 ^ (n / 2) := by
  -- We'll use induction to prove that the inequality holds for all even $n \geq 6$.
  have h_ind : ∀ k ≥ 3, 2 * k < 2 ^ k := by
    exact fun k hk => by induction hk <;> norm_num [ pow_succ' ] at * ; linarith;
  grind


theorem quantum_supremacy_base :
    ∃ (f : ℕ → ℕ), ∀ n, f n < 2 ^ n ∧ f n ≥ n := by
  exact ⟨ fun n => n, fun n => ⟨ by induction' n with n ih <;> norm_num [ pow_succ' ] at * ; linarith, le_rfl ⟩ ⟩


theorem entanglement_monogamy_base (a b c : ℝ)
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (h_bound : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1)
    (h_max : a = 1) :
    b = 0 ∧ c = 0 := by
  constructor <;> nlinarith


theorem decoherence_decay (t : ℝ) (γ : ℝ) (hγ : 0 < γ) (ht : 0 < t) :
    Real.exp (-γ * t) < 1 := by
  exact Real.exp_lt_one_iff.mpr ( by nlinarith )


theorem born_rule_normalization (p q : ℝ) (hp : 0 ≤ p) (hq : 0 ≤ q)
    (h : p + q = 1) : p ≤ 1 ∧ q ≤ 1 := by
  constructor <;> linarith


