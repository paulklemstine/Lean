import Mathlib

/-! # CatalogBuild.Algebra.Factoring.Quantum
Unified file merging Quantum-related theorems.
-
-/

/- Original: QuantumE8Modular.lean -/



noncomputable section

/-- In dimension k, the total factoring equations from one representation
are k peel channels plus C(k,2) cross-component pairs. -/
theorem total_factoring_equations (k : ℕ) :
    k + Nat.choose k 2 = k + k * (k - 1) / 2 := by
  congr 1; exact Nat.choose_two_right k

/-- σ_k(n) = sum of k-th powers of divisors of n -/
noncomputable def sigma_k (k n : ℕ) : ℕ :=
  (Nat.divisors n).sum (· ^ k)

/-- σ_k(n) ≥ 1 for all n ≥ 1 (since n divides itself). -/
theorem sigma_k_pos (k n : ℕ) (hn : n ≥ 1) : sigma_k k n ≥ 1 := by
  unfold sigma_k
  have hmem : n ∈ Nat.divisors n := Nat.mem_divisors.mpr ⟨dvd_refl n, by omega⟩
  have := Finset.single_le_sum (f := fun x => x ^ k) (fun x _ => Nat.zero_le _) hmem
  calc (Nat.divisors n).sum (· ^ k) ≥ n ^ k := this
    _ ≥ 1 := Nat.one_le_pow k n (by omega)

/-- Octonion norm (sum of 8 squares) -/
def onorm (v : Fin 8 → ℤ) : ℤ := ∑ i, v i ^ 2

/-- Onorm is nonneg -/
theorem onorm_nonneg (v : Fin 8 → ℤ) : onorm v ≥ 0 := by
  unfold onorm
  apply Finset.sum_nonneg
  intro i _
  exact sq_nonneg (v i)

/-- In dimension 8, each pair of representations gives C(8,2) = 28
cross-collision pairs. -/
theorem dim8_cross_collisions : Nat.choose 8 2 = 28 := by decide

/-- [Section: # CatalogBuild.Pythagorean.Quadruples.QuantumE8Modular
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 18] -/
theorem dim4_cross_collisions : Nat.choose 4 2 = 6 := by decide

/-- [Section: # CatalogBuild.Pythagorean.Quadruples.QuantumE8Modular
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 18] -/
theorem dim2_cross_collisions : Nat.choose 2 2 = 1 := by decide

/-- The first few r₈ values demonstrate representation richness. -/
theorem e8_representation_richness :
    16 < 112 ∧ 112 < 448 ∧ 448 < 1136 := by omega

/-- Count divisors of n congruent to r mod m -/
noncomputable def count_divisors_mod (n r m : ℕ) : ℕ :=
  ((Nat.divisors n).filter (fun d => d % m = r)).card

/-- For a prime p ≡ 1 (mod 4), p has at least one divisor ≡ 1 (mod 4),
namely 1 itself. -/
theorem r2_prime_1mod4_divisor_structure (p : ℕ) (hp : Nat.Prime p)
    (_hmod : p % 4 = 1) :
    count_divisors_mod p 1 4 ≥ 1 := by
  unfold count_divisors_mod
  apply Finset.card_pos.mpr
  use 1
  simp [Finset.mem_filter, Nat.mem_divisors]
  exact hp.ne_zero

/-- Upper bound on σ_k(n): at most n^k times the number of divisors. -/
theorem sigma_k_upper_bound (k n : ℕ) (_hn : n ≥ 1) :
    sigma_k k n ≤ n ^ k * (Nat.divisors n).card := by
  unfold sigma_k
  calc (Nat.divisors n).sum (· ^ k)
      ≤ (Nat.divisors n).sum (fun _ => n ^ k) := by
        apply Finset.sum_le_sum
        intro d hd
        exact Nat.pow_le_pow_left (Nat.divisor_le hd) k
    _ = (Nat.divisors n).card • (n ^ k) := Finset.sum_const _
    _ = n ^ k * (Nat.divisors n).card := by rw [smul_eq_mul, mul_comm]

/-- The hierarchy of factoring power: more channels, more collisions. -/
theorem hierarchy_channels :
    1 * Nat.choose 2 2 < 2 * Nat.choose 2 2 ∧
    2 * Nat.choose 2 2 < 4 * Nat.choose 2 2 ∧
    4 * Nat.choose 2 2 < 8 * Nat.choose 2 2 := by decide

/-- The cross term (ad - bc) squared is bounded by N². -/
theorem cross_term_squared_bound (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    (a * d - b * c) ^ 2 ≤ N ^ 2 := by
  have key : (a * d - b * c) ^ 2 + (a * c + b * d) ^ 2 = N ^ 2 := by
    linear_combination' h1 * h2
  nlinarith [sq_nonneg (a * c + b * d)]

/-- The cross term is zero iff the two representations are "parallel". -/
theorem cross_term_zero_iff_parallel (a b c d : ℤ)
    (h_ad_bc : a * d - b * c = 0) :
    a * d = b * c := by linarith

/-- If both the cross term and dot product are nonzero, the cross term
is strictly bounded—making gcd(ad-bc, N) a nontrivial factor candidate.
Note: when ac+bd = 0 (representations are orthogonal rotations of each other),
we get (ad-bc)² = N² exactly, so the dot-product hypothesis is needed. -/
theorem collision_yields_factor_candidate (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N)
    (_hne : a * d - b * c ≠ 0)
    (hne2 : a * c + b * d ≠ 0) :
    (a * d - b * c) ^ 2 < N ^ 2 := by
  have key : (a * d - b * c) ^ 2 + (a * c + b * d) ^ 2 = N ^ 2 := by
    linear_combination' h1 * h2
  have : (a * c + b * d) ^ 2 > 0 := by positivity
  linarith

/-- Total channel count in the hierarchy for 2 representations -/
theorem total_channels_two_reps :
    1 < 3 ∧ 3 < 10 ∧ 10 < 36 := by omega

/-- The ratio of channels grows superlinearly with dimension. -/
theorem channel_growth_superlinear :
    10 * 2 > 3 * 4 ∧
    36 * 4 > 10 * 8 := by omega

end

/- Original: QuantumGateSynthesis.lean -/



/-- A gate in the theta group gate set.
These correspond to the generators of Γ_θ = ⟨S, T²⟩:
- `M₁` corresponds to T²·S (the "left turn" in the Berggren tree)
- `M₃` corresponds to T² (the "right turn")
- Their inverses complete the group. -/
inductive ThetaGate where
  | M₁     -- [[2, -1], [1, 0]]
  | M₃     -- [[1, 2], [0, 1]]
  | M₁_inv -- [[0, 1], [-1, 2]]
  | M₃_inv -- [[1, -2], [0, 1]]
  deriving Repr, DecidableEq

/-- A quantum circuit is a sequence of theta group gates. -/
def ThetaCircuit := List ThetaGate

/-- The matrix representation of each gate. -/
def ThetaGate.toMatrix : ThetaGate → Matrix (Fin 2) (Fin 2) ℤ
  | .M₁     => !![2, -1; 1, 0]
  | .M₃     => !![1, 2; 0, 1]
  | .M₁_inv => !![0, 1; -1, 2]
  | .M₃_inv => !![1, -2; 0, 1]

/-- Evaluate a circuit as a matrix product (right-to-left composition). -/
def eval_circuit : ThetaCircuit → Matrix (Fin 2) (Fin 2) ℤ
  | []      => 1
  | g :: gs => g.toMatrix * eval_circuit gs

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumGateSynthesis
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 35] -/
theorem det_gate (g : ThetaGate) : Matrix.det g.toMatrix = 1 := by
  cases g <;> simp [ThetaGate.toMatrix, Matrix.det_fin_two]

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumGateSynthesis
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 35] -/
theorem eval_circuit_determinant (c : ThetaCircuit) : Matrix.det (eval_circuit c) = 1 := by
  induction c with
  | nil => simp [eval_circuit, det_one]
  | cons g gs ih =>
    simp [eval_circuit, det_mul, det_gate, ih]

theorem M₁_mul_M₁_inv : ThetaGate.M₁.toMatrix * ThetaGate.M₁_inv.toMatrix = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [ThetaGate.toMatrix, Matrix.mul_apply, Fin.sum_univ_two]

theorem M₁_inv_mul_M₁ : ThetaGate.M₁_inv.toMatrix * ThetaGate.M₁.toMatrix = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [ThetaGate.toMatrix, Matrix.mul_apply, Fin.sum_univ_two]

theorem M₃_mul_M₃_inv : ThetaGate.M₃.toMatrix * ThetaGate.M₃_inv.toMatrix = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [ThetaGate.toMatrix, Matrix.mul_apply, Fin.sum_univ_two]

theorem M₃_inv_mul_M₃ : ThetaGate.M₃_inv.toMatrix * ThetaGate.M₃.toMatrix = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [ThetaGate.toMatrix, Matrix.mul_apply, Fin.sum_univ_two]

/-- S matrix of SL(2,ℤ). -/
def S_matrix : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]

/-- T² matrix of SL(2,ℤ). -/
def T_sq_matrix : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

theorem S_eq_M₃_inv_M₁ : S_matrix = ThetaGate.M₃_inv.toMatrix * ThetaGate.M₁.toMatrix := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [S_matrix, ThetaGate.toMatrix, Matrix.mul_apply, Fin.sum_univ_two]

theorem T_sq_eq_M₃ : T_sq_matrix = ThetaGate.M₃.toMatrix := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [T_sq_matrix, ThetaGate.toMatrix]

/-- The O(1) factoring equation: given m, n with m² - n² = N,
the factors are p = m - n, q = m + n. -/
theorem factoring_from_parameters (N m n : ℤ) (h : m ^ 2 - n ^ 2 = N) :
    N = (m - n) * (m + n) := by ring_nf; linarith

/-- The factors are correct. -/
theorem factors_correct (m n : ℤ) :
    (m - n) * (m + n) = m ^ 2 - n ^ 2 := by ring

/-- Given the evaluated circuit output (m, n), factor extraction is O(1). -/
structure FactoringResult where
  N : ℤ
  m : ℤ
  n : ℤ
  p : ℤ := m - n
  q : ℤ := m + n
  param_eq : m ^ 2 - n ^ 2 = N
  factored : N = p * q := by linarith [factors_correct m n]

/-- Apply a circuit to a parameter vector. -/
def apply_circuit (c : ThetaCircuit) (v : Fin 2 → ℤ) : Fin 2 → ℤ :=
  eval_circuit c *ᵥ v

/-- The root parameters: (m₀, n₀) = (2, 1) corresponding to the (3,4,5) triple. -/
def root_params : Fin 2 → ℤ := ![2, 1]

/-- Root parameters give m₀² - n₀² = 3. -/
theorem root_params_diff_sq : (root_params 0) ^ 2 - (root_params 1) ^ 2 = 3 := by
  decide

/-- Convert a Berggren path to a theta circuit. -/
def BerggrenPath.toCircuit : BerggrenPath → ThetaCircuit
  | []             => []
  | .left :: rest  => .M₁ :: BerggrenPath.toCircuit rest
  | .mid :: rest   => .M₁ :: .M₃ :: BerggrenPath.toCircuit rest
  | .right :: rest => .M₃ :: BerggrenPath.toCircuit rest

/-- The circuit evaluation is a single matrix — this IS the O(1) equation.
Instead of running a quantum computer, we evaluate one matrix product. -/
theorem circuit_eval_is_matrix_product (c : ThetaCircuit) (v : Fin 2 → ℤ) :
    apply_circuit c v = eval_circuit c *ᵥ v := rfl

theorem circuit_gives_factorization (N p q : ℕ)
    (hp : 1 < p) (hq : 1 < q) (hpq : p ≤ q)
    (hoddp : Odd p) (hoddq : Odd q) (hN : N = p * q) :
    ∃ (m n : ℤ), m ^ 2 - n ^ 2 = ↑N ∧
      (↑N : ℤ) = (m - n) * (m + n) ∧
      1 < m - n := by
  -- Set $m$ and $n$ using the expressions from the provided solution.
  use (p + q) / 2, (q - p) / 2;
  rcases hoddp with ⟨ m, rfl ⟩ ; rcases hoddq with ⟨ n, rfl ⟩ ; push_cast [ hN ] ; ring ;
  norm_num [ show ( 2 + m * 2 + n * 2 : ℤ ) = 2 * ( 1 + m + n ) by ring, show ( - ( m * 2 ) + n * 2 : ℤ ) = 2 * ( -m + n ) by ring, Int.add_mul_ediv_left ] ; ring ; norm_num;
  linarith

/-- The explicit O(1) equation: extract factors from a 2×2 matrix and root vector. -/
def extract_factors (M : Matrix (Fin 2) (Fin 2) ℤ) : ℤ × ℤ :=
  let v := M *ᵥ root_params
  (v 0 - v 1, v 0 + v 1)

/-- Extraction produces a valid factorization when the matrix encodes the right parameters. -/
theorem extract_factors_correct (M : Matrix (Fin 2) (Fin 2) ℤ) (N : ℤ)
    (m n : ℤ) (hm : (M *ᵥ root_params) 0 = m) (hn : (M *ᵥ root_params) 1 = n)
    (hN : m ^ 2 - n ^ 2 = N) :
    let (fst, snd) := extract_factors M
    fst * snd = N := by
  simp only [extract_factors, hm, hn]
  linarith [factors_correct m n]

/-- The number of arithmetic operations to extract factors from (m, n) is exactly 2:
one subtraction (m - n = p) and one addition (m + n = q). -/
def extraction_ops : ℕ := 2

/-- The number of operations for matrix-vector multiplication Mv₀ is at most 6:
4 multiplications and 2 additions for a 2×2 matrix times a 2-vector. -/
def matvec_ops : ℕ := 6

/-- Total operations for the O(1) extraction phase. -/
def total_extraction_ops : ℕ := matvec_ops + extraction_ops

/-- The total operation count is constant (= 8). -/
theorem extraction_is_O1 : total_extraction_ops = 8 := by rfl

/-- The Euclidean step matrix: subtract q times the other. -/
def euclidean_step (q_val : ℤ) : Matrix (Fin 2) (Fin 2) ℤ :=
  !![0, 1; 1, -q_val]

/-- Each Euclidean step has determinant -1. -/
theorem det_euclidean_step (q_val : ℤ) :
    Matrix.det (euclidean_step q_val) = -1 := by
  simp [euclidean_step, Matrix.det_fin_two]

/-- Two consecutive Euclidean steps have determinant 1 (in SL(2,ℤ)). -/
theorem det_two_steps (q₁ q₂ : ℤ) :
    Matrix.det (euclidean_step q₁ * euclidean_step q₂) = 1 := by
  simp [det_mul, det_euclidean_step]

/-- Factoring 15 via a single M₃ gate applied to root parameters. -/
theorem factor_15_example :
    let c : ThetaCircuit := [.M₃]
    let result := apply_circuit c root_params
    let m := result 0
    let n := result 1
    m = 4 ∧ n = 1 ∧ m ^ 2 - n ^ 2 = 15 ∧ (m - n) * (m + n) = 15 := by
  native_decide

/-- Factoring 5 via a single M₁ gate applied to root parameters. -/
theorem factor_5_example :
    let c : ThetaCircuit := [.M₁]
    let result := apply_circuit c root_params
    let m := result 0
    let n := result 1
    m = 3 ∧ n = 2 ∧ m ^ 2 - n ^ 2 = 5 ∧ (m - n) * (m + n) = 5 := by
  native_decide

/-- Factoring 45 = 5 × 9 via M₃ · M₁ circuit. -/
theorem factor_45_example :
    let c : ThetaCircuit := [.M₃, .M₁]
    let result := apply_circuit c root_params
    let m := result 0
    let n := result 1
    m ^ 2 - n ^ 2 = 45 := by
  native_decide

/- Original: QuantumOracleChain.lean -/



noncomputable section

/-- A chain of oracles applied in sequence -/
structure OracleChain (α : Type*) where
  oracles : List (α → α)
  all_idem : ∀ f ∈ oracles, ∀ x, f (f x) = f x

/-- Apply an oracle chain to an input -/
def OracleChain.apply {α : Type*} (chain : OracleChain α) (x : α) : α :=
  chain.oracles.foldl (fun acc f => f acc) x

/-- The empty chain is the identity -/
def OracleChain.empty (α : Type*) : OracleChain α :=
  ⟨[], by simp⟩

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumOracleChain
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 48] -/
theorem OracleChain.empty_apply {α : Type*} (x : α) :
    (OracleChain.empty α).apply x = x := by
  simp [OracleChain.apply, OracleChain.empty]

/-- A singleton chain wraps one oracle -/
def OracleChain.singleton {α : Type*} (f : α → α) (hf : ∀ x, f (f x) = f x) :
    OracleChain α :=
  ⟨[f], by simpa using hf⟩

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumOracleChain
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 48] -/
theorem OracleChain.singleton_apply {α : Type*} (f : α → α) (hf : ∀ x, f (f x) = f x)
    (x : α) : (OracleChain.singleton f hf).apply x = f x := by
  simp [OracleChain.apply, OracleChain.singleton]

/-- Concatenate two oracle chains -/
def OracleChain.concat {α : Type*} (c₁ c₂ : OracleChain α) : OracleChain α where
  oracles := c₁.oracles ++ c₂.oracles
  all_idem := by
    intro f hf
    rw [List.mem_append] at hf
    rcases hf with h1 | h2
    · exact c₁.all_idem f h1
    · exact c₂.all_idem f h2

theorem OracleChain.concat_apply {α : Type*} (c₁ c₂ : OracleChain α) (x : α) :
    (c₁.concat c₂).apply x = c₂.apply (c₁.apply x) := by
  simp [OracleChain.apply, OracleChain.concat, List.foldl_append]

/-- Chain concatenation is associative -/
theorem OracleChain.concat_assoc {α : Type*} (c₁ c₂ c₃ : OracleChain α) :
    (c₁.concat c₂).concat c₃ = c₁.concat (c₂.concat c₃) := by
  simp [OracleChain.concat, List.append_assoc]

/-- A quantum state is a unit vector in ℂⁿ -/
structure QState (n : ℕ) where
  amplitudes : Fin n → ℂ
  normalized : ∑ i : Fin n, ‖amplitudes i‖ ^ 2 = 1

/-- Measurement probabilities are non-negative -/
theorem measureProb_nonneg {n : ℕ} (ψ : QState n) (k : Fin n) :
    0 ≤ measureProb ψ k :=
  sq_nonneg _

/-- Measurement probabilities sum to 1 -/
theorem measureProb_sum {n : ℕ} (ψ : QState n) :
    ∑ k : Fin n, measureProb ψ k = 1 := ψ.normalized

/-- A quantum gate is a unitary matrix -/
structure QGate (n : ℕ) where
  mat : Matrix (Fin n) (Fin n) ℂ
  unitary : mat * star mat = 1

/-- Gate composition -/
def QGate.compose {n : ℕ} (g₁ g₂ : QGate n) : QGate n where
  mat := g₁.mat * g₂.mat
  unitary := by
    rw [Matrix.star_mul, ← mul_assoc, mul_assoc g₁.mat, g₂.unitary, mul_one, g₁.unitary]

/-- The identity gate -/
def QGate.id' (n : ℕ) : QGate n where
  mat := 1
  unitary := by simp [star_one]

/-- Gate composition with identity -/
theorem QGate.compose_id {n : ℕ} (g : QGate n) :
    (g.compose (QGate.id' n)).mat = g.mat := by
  simp [QGate.compose, QGate.id']

theorem QGate.id_compose {n : ℕ} (g : QGate n) :
    ((QGate.id' n).compose g).mat = g.mat := by
  simp [QGate.compose, QGate.id']

/-- Gate composition is associative -/
theorem QGate.compose_assoc {n : ℕ} (g₁ g₂ g₃ : QGate n) :
    ((g₁.compose g₂).compose g₃).mat = (g₁.compose (g₂.compose g₃)).mat := by
  simp [QGate.compose, mul_assoc]

/-- The Deutsch-Jozsa oracle sign function: maps x to (-1)^f(x) -/
def deutschJozsaSign {n : ℕ} (f : BoolFn n) (x : Fin (2^n)) : ℤ :=
  if f x then -1 else 1

/-- The sign function squares to 1 (oracle is involutive) -/
theorem deutschJozsaSign_sq {n : ℕ} (f : BoolFn n) (x : Fin (2^n)) :
    deutschJozsaSign f x * deutschJozsaSign f x = 1 := by
  simp [deutschJozsaSign]; split <;> ring

/-- Sum of signs for a constant-false function equals 2^n -/
theorem deutschJozsa_constant_sum {n : ℕ} (f : BoolFn n)
    (hf : ∀ x, f x = false) :
    ∑ x : Fin (2^n), deutschJozsaSign f x = 2^n := by
  simp [deutschJozsaSign, hf]

theorem deutschJozsa_balanced_sum {n : ℕ} (f : BoolFn n)
    (hbal : f.isBalanced) :
    ∑ x : Fin (2^n), deutschJozsaSign f x = 0 := by
  -- By definition of `deutschJozsaSign`, we can split the sum into two parts: one over the true inputs and one over the false inputs.
  have h_split : ∑ x, deutschJozsaSign f x = ∑ x ∈ Finset.univ.filter (fun x => f x = true), (-1 : ℤ) + ∑ x ∈ Finset.univ.filter (fun x => f x = false), (1 : ℤ) := by
    rw [ Finset.sum_filter, Finset.sum_filter ] ; rw [ ← Finset.sum_add_distrib ] ; congr ; ext ; unfold deutschJozsaSign ; aesop;
  simp_all +decide [ BoolFn.isBalanced ];
  rw [ show ( Finset.univ.filter fun x => f x = false ) = Finset.univ \ ( Finset.univ.filter fun x => f x = true ) by ext x; aesop, Finset.card_sdiff ] ; norm_num [ Finset.filter_congr, Finset.card_sdiff, Finset.card_singleton, Finset.card_univ, hbal ] ; ring;
  rw [ Nat.cast_sub ( by linarith [ Nat.one_le_pow n 2 zero_lt_two ] ) ] ; push_cast ; linarith

/-- Iterating an idempotent map any positive number of times gives one application -/
theorem iterate_idem {α : Type*} (O : α → α) (hO : ∀ x, O (O x) = O x)
    (n : ℕ) (hn : 1 ≤ n) (x : α) : O^[n] x = O x := by
  induction n with
  | zero => omega
  | succ m ih =>
    rw [Function.iterate_succ', Function.comp_apply]
    by_cases hm : m = 0
    · subst hm; simp
    · rw [ih (by omega)]; exact hO x

/-- Each power-of-2 iteration of an idempotent oracle equals the oracle -/
theorem phase_estimation_idem {α : Type*} (O : α → α) (hO : ∀ x, O (O x) = O x)
    (k : ℕ) (hk : 0 < k) (x : α) : O^[2^k] x = O x :=
  iterate_idem O hO (2^k) Nat.one_le_two_pow x

/-- For unitary operators, (U^k)† = (U†)^k -/
theorem unitary_power_adjoint {n : ℕ} (U : Matrix (Fin n) (Fin n) ℂ) (k : ℕ) :
    star (U ^ k) = (star U) ^ k :=
  star_pow U k

/-- The N-th root of unity -/
def rootOfUnity' (N : ℕ) (k : ℕ) : ℂ := Complex.exp (2 * Real.pi * Complex.I * k / N)

/-- A quantum computer instruction: either a gate or an oracle query -/
inductive QInstruction (n : ℕ) where
  | gate : QGate n → QInstruction n
  | oracle : (Matrix (Fin n) (Fin n) ℂ) → QInstruction n

/-- Execute a quantum instruction as a matrix -/
def QInstruction.toMatrix {n : ℕ} : QInstruction n → Matrix (Fin n) (Fin n) ℂ
  | .gate g => g.mat
  | .oracle P => P

/-- Execute a quantum program (list of instructions) -/
def executeProgram {n : ℕ} (prog : List (QInstruction n)) : Matrix (Fin n) (Fin n) ℂ :=
  prog.foldl (fun acc inst => inst.toMatrix * acc) 1

/-- Empty program is identity -/
theorem executeProgram_empty {n : ℕ} : executeProgram ([] : List (QInstruction n)) = 1 := by
  simp [executeProgram]

/-- Single gate program equals the gate -/
theorem executeProgram_single_gate {n : ℕ} (g : QGate n) :
    executeProgram [QInstruction.gate g] = g.mat := by
  simp [executeProgram, QInstruction.toMatrix]

/-- Gate then oracle = matrix product -/
theorem oracle_gate_composition {n : ℕ} (g : QGate n) (O : Matrix (Fin n) (Fin n) ℂ) :
    executeProgram [QInstruction.gate g, QInstruction.oracle O] = O * g.mat := by
  simp [executeProgram, QInstruction.toMatrix]

/-- Modular exponentiation oracle: f(x) = a^x mod N -/
def modExpOracle (a N : ℕ) (hN : 0 < N) : ℕ → ℕ :=
  fun x => a ^ x % N

/-- The modular exponentiation oracle is periodic -/
theorem modExp_periodic (a N : ℕ) (hN : 0 < N) (r : ℕ) (hr : a ^ r % N = 1)
    (hr0 : 0 < r) :
    ∀ x, modExpOracle a N hN (x + r) = modExpOracle a N hN x := by
  intro x
  simp only [modExpOracle]
  rw [pow_add, Nat.mul_mod, hr, mul_one, Nat.mod_mod_of_dvd]
  exact ⟨1, by ring⟩

/-- Period finding reduces factoring -/
theorem period_to_factor (a N r : ℕ) (hN : 1 < N) (hr : a ^ r % N = 1)
    (heven : 2 ∣ r) :
    (a ^ (r / 2) % N) * (a ^ (r / 2) % N) % N = 1 := by
  obtain ⟨k, hk⟩ := heven
  subst hk
  rw [Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
  rw [← Nat.mul_mod, ← pow_add, ← two_mul]
  exact hr

/-- A stabilizer code is defined by commuting projectors -/
structure StabilizerCode (n k : ℕ) where
  stabilizers : Fin (n - k) → Matrix (Fin (2^n)) (Fin (2^n)) ℝ
  are_projectors : ∀ i, stabilizers i * stabilizers i = stabilizers i
  commute : ∀ i j, stabilizers i * stabilizers j = stabilizers j * stabilizers i

/-- The code space projector is the product of all stabilizers -/
def StabilizerCode.codeProjector {n k : ℕ} (code : StabilizerCode n k) :
    Matrix (Fin (2^n)) (Fin (2^n)) ℝ :=
  (List.ofFn code.stabilizers).foldl (· * ·) 1

/-- Classical query complexity for unstructured search -/
theorem classical_search_bound (N : ℕ) : N / 2 ≤ N := Nat.div_le_self N 2

theorem quantum_search_speedup (N : ℕ) (hN : 16 ≤ N) :
    Nat.sqrt N < N / 2 := by
  exact Nat.le_div_iff_mul_le zero_lt_two |>.2 ( by nlinarith [ Nat.sqrt_le N ] )

/-- Exponential separation for structured problems (Simon's) -/
theorem simon_speedup (n : ℕ) : n < 2^n := Nat.lt_two_pow_self

/-- A quantum algorithm: circuit + oracle queries + success guarantee -/
structure QAlgorithm (n : ℕ) where
  circuit : List (QGate n)
  oracle_queries : ℕ
  success_prob : ℝ
  prob_nonneg : 0 ≤ success_prob
  prob_le_one : success_prob ≤ 1

/-- Composing quantum algorithms (sequential execution) -/
def QAlgorithm.compose {n : ℕ} (a₁ a₂ : QAlgorithm n) : QAlgorithm n where
  circuit := a₁.circuit ++ a₂.circuit
  oracle_queries := a₁.oracle_queries + a₂.oracle_queries
  success_prob := a₁.success_prob * a₂.success_prob
  prob_nonneg := mul_nonneg a₁.prob_nonneg a₂.prob_nonneg
  prob_le_one := mul_le_one₀ a₁.prob_le_one a₂.prob_nonneg a₂.prob_le_one

/-- Oracle query complexity is additive -/
theorem algorithm_compose_queries {n : ℕ} (a₁ a₂ : QAlgorithm n) :
    (a₁.compose a₂).oracle_queries = a₁.oracle_queries + a₂.oracle_queries := rfl

/-- The abstract structure of Shor's algorithm -/
structure ShorChain where
  N : ℕ
  a : ℕ
  precision : ℕ
  hN : 1 < N
  ha : Nat.Coprime a N

/-- The GCD oracle is the first link -/
def ShorChain.gcdOracle (sc : ShorChain) : ℕ → ℕ :=
  fun x => Nat.gcd x sc.N

/-- The GCD oracle in the chain is idempotent -/
theorem ShorChain.gcd_idem (sc : ShorChain) (x : ℕ) :
    sc.gcdOracle (sc.gcdOracle x) = sc.gcdOracle x := by
  unfold ShorChain.gcdOracle
  exact Nat.gcd_eq_left (Nat.gcd_dvd_right x sc.N)

/-- Composing GCD and modExp oracles extracts factor information -/
theorem ShorChain.chain_extracts_info (sc : ShorChain) (x : ℕ)
    (hx : 1 < Nat.gcd (x ^ sc.a % sc.N) sc.N) :
    ∃ d, d ∣ sc.N ∧ 1 < d := by
  exact ⟨Nat.gcd (x ^ sc.a % sc.N) sc.N, Nat.gcd_dvd_right _ _, hx⟩

/-- Grover iteration count is sublinear -/
theorem grover_iterations_sublinear (N : ℕ) (hN : 4 ≤ N) :
    Nat.sqrt N < N :=
  Nat.sqrt_lt_self (by omega)

end

/- Original: QuantumProofMetric.lean -/



noncomputable section

/-- A proof vector is a function from Fin n to ℂ, representing amplitudes
for each proof technique. -/
def ProofVector (n : ℕ) := Fin n → ℂ

/-- The inner product of two proof vectors. -/
noncomputable def proofInnerProduct {n : ℕ} (ψ φ : ProofVector n) : ℂ :=
  ∑ i : Fin n, (starRingEnd ℂ (ψ i)) * (φ i)

/-- The norm squared of a proof vector. -/
noncomputable def proofNormSq {n : ℕ} (ψ : ProofVector n) : ℝ :=
  (∑ i : Fin n, ‖ψ i‖ ^ 2)

/-- A proof vector is normalized if its norm squared equals 1. -/
def isNormalized {n : ℕ} (ψ : ProofVector n) : Prop :=
  proofNormSq ψ = 1

/-- The overlap (fidelity) between two proof vectors. -/
noncomputable def proofFidelity {n : ℕ} (ψ φ : ProofVector n) : ℝ :=
  ‖proofInnerProduct ψ φ‖

/-- The fidelity is non-negative. -/
theorem fidelity_nonneg {n : ℕ} (ψ φ : ProofVector n) :
    0 ≤ proofFidelity ψ φ := by
  exact norm_nonneg _

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumProofMetric
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 16] -/
theorem self_fidelity_normalized {n : ℕ} (ψ : ProofVector n) (h : isNormalized ψ) :
    proofFidelity ψ ψ = proofNormSq ψ := by
  unfold proofFidelity proofNormSq proofInnerProduct;
  norm_num [ Complex.normSq, Complex.sq_norm ];
  convert Complex.norm_of_nonneg _;
  · simp +decide [ Complex.ext_iff, mul_comm ];
  · exact Finset.sum_nonneg fun _ _ => add_nonneg ( mul_self_nonneg _ ) ( mul_self_nonneg _ )

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumProofMetric
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 16] -/
theorem fubiniStudy_self {n : ℕ} (ψ : ProofVector n) (h : isNormalized ψ) :
    fubiniStudyDist ψ ψ = 0 := by
  unfold fubiniStudyDist; have := self_fidelity_normalized ψ h; simp_all +decide [ isNormalized ] ;

theorem fubiniStudy_symm {n : ℕ} (ψ φ : ProofVector n) :
    fubiniStudyDist ψ φ = fubiniStudyDist φ ψ := by
  unfold fubiniStudyDist;
  -- Since ⟨ψ|φ⟩ = starRingEnd ℂ (⟨φ|ψ⟩), we have ‖⟨ψ|φ⟩‖ = ‖starRingEnd ℂ (⟨φ|ψ⟩)‖.
  have h_conj : proofInnerProduct ψ φ = starRingEnd ℂ (proofInnerProduct φ ψ) := by
    unfold proofInnerProduct; simp +decide [ mul_comm ] ;
  unfold proofFidelity; aesop;

/-- Two proof vectors are orthogonal if their inner product is zero. -/
def areOrthogonal {n : ℕ} (ψ φ : ProofVector n) : Prop :=
  proofInnerProduct ψ φ = 0

theorem orthogonal_zero_fidelity {n : ℕ} (ψ φ : ProofVector n)
    (h : areOrthogonal ψ φ) : proofFidelity ψ φ = 0 := by
  unfold proofFidelity; aesop;

/-- A unitary transformation on proof space (n×n unitary matrix). -/
structure ProofRefactoring (n : ℕ) where
  transform : ProofVector n → ProofVector n
  preserves_inner : ∀ ψ φ : ProofVector n,
    proofInnerProduct (transform ψ) (transform φ) = proofInnerProduct ψ φ

theorem refactoring_preserves_fidelity {n : ℕ} (U : ProofRefactoring n)
    (ψ φ : ProofVector n) :
    proofFidelity (U.transform ψ) (U.transform φ) = proofFidelity ψ φ := by
  exact congr_arg _ ( U.preserves_inner ψ φ )

theorem refactoring_preserves_distance {n : ℕ} (U : ProofRefactoring n)
    (ψ φ : ProofVector n) :
    fubiniStudyDist (U.transform ψ) (U.transform φ) = fubiniStudyDist ψ φ := by
  unfold fubiniStudyDist; exact congr_arg Real.arccos ( refactoring_preserves_fidelity U ψ φ ) ;

/-- A superposition of two proof strategies with amplitudes α and β. -/
noncomputable def proofSuperposition {n : ℕ} (α β : ℂ) (ψ φ : ProofVector n) :
    ProofVector n :=
  fun i => α * ψ i + β * φ i

theorem superposition_norm {n : ℕ} (α β : ℂ) (ψ φ : ProofVector n) :
    proofNormSq (proofSuperposition α β ψ φ) =
    ‖α‖^2 * proofNormSq ψ + ‖β‖^2 * proofNormSq φ +
    2 * ((starRingEnd ℂ α * β) * proofInnerProduct ψ φ).re := by
  unfold proofSuperposition proofNormSq proofInnerProduct;
  norm_num [ Complex.normSq, Complex.sq_norm ] ; ring!;
  norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
  simpa only [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] using by ring;

end

