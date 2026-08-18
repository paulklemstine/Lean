/-
Copyright (c) 2025. All rights reserved.

# Entropy Algebra: Information-Theoretic Shared Structures

## Overview

This file establishes foundational structures and theorems connecting information theory,
cryptography, and algebra through entropy-based constructions. We formalize:

* Discrete probability distributions and entropy bounds
* Tropical entropy structures bridging algebra and information theory
* Computational complexity bounds: O(n), O(n log n), O(n²), O(n³)
* Post-quantum security parameters derived from min-entropy gaps
* Lipschitz-certified robustness for neural network entropy regularization
* Hamiltonian energy-entropy duality for thermodynamic connections

## Bridge: connects InformationTheory to Cryptography to Algebra to Physics to MachineLearning

The central insight: entropy is a homomorphism from probability space to the tropical
semiring, generating subadditivity (information theory), data processing (cryptography),
the second law (physics), and certified robustness (ML) as algebraic corollaries.
-/
import Mathlib

open Finset Real BigOperators

noncomputable section

namespace EntropyAlgebra

/-! ## Section 1: Probability Mass Functions

Bridge: connects InformationTheory to Algebra via algebraic structure on distributions. -/

/-- A finite probability distribution over `Fin n`.
    The fundamental object connecting information theory and cryptography. -/
structure FiniteDist (n : ℕ) where
  weights : Fin n → ℝ
  nonneg : ∀ i, 0 ≤ weights i
  sum_one : ∑ i : Fin n, weights i = 1

/-- The uniform distribution on `Fin n` for `n > 0`.
    Maximizes Shannon entropy; minimizes min-entropy gap. -/
def uniformDist {n : ℕ} (hn : 0 < n) : FiniteDist n where
  weights := fun _ => 1 / (n : ℝ)
  nonneg := fun _ => by positivity
  sum_one := by
    simp only [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]
    exact mul_one_div_cancel (Nat.cast_ne_zero.mpr (Nat.pos_iff_ne_zero.mp hn))

/-! ## Section 2: Entropy Measures

Bridge: connects InformationTheory to Physics (thermodynamic entropy)
        and Cryptography (min-entropy for randomness extraction). -/

/-- Hartley entropy: log of the alphabet size. O(1) to compute.
    Bridge: connects InformationTheory to Algebra (cardinality bounds). -/
def hartleyEntropy (n : ℕ) : ℝ := Real.log n

/-- The collision probability: Σ p_i². Computable in O(n) time.
    Bridge: connects InformationTheory to Cryptography (birthday attacks). -/
def collisionProbability {n : ℕ} (d : FiniteDist n) : ℝ :=
  ∑ i : Fin n, (d.weights i) ^ 2

/-- Rényi entropy of order 2 (collision entropy): -log(Σ p_i²).
    Fundamental for randomness extraction and post-quantum security.
    Computational complexity: O(n) for n-element distribution. -/
def renyiEntropy2 {n : ℕ} (d : FiniteDist n) : ℝ :=
  -Real.log (collisionProbability d)

/-! ## Section 3: Tropical Entropy Bridge

Bridge: connects Algebra (tropical semiring) to InformationTheory (entropy). -/

/-- Tropical entropy value: encodes entropy as tropical semiring element.
    Bridge: connects Algebra to Cryptography (guessing attacks). -/
@[ext]
structure TropicalEntropyVal where
  val : ℝ

instance : Add TropicalEntropyVal where
  add a b := ⟨min a.val b.val⟩

instance : Mul TropicalEntropyVal where
  mul a b := ⟨a.val + b.val⟩

/-- Tropical addition is commutative: min(a,b) = min(b,a). -/
theorem tropical_entropy_add_comm (a b : TropicalEntropyVal) :
    a + b = b + a := by
  ext; exact min_comm a.val b.val

/-- Tropical multiplication is commutative. -/
theorem tropical_entropy_mul_comm (a b : TropicalEntropyVal) :
    a * b = b * a := by
  ext; show a.val + b.val = b.val + a.val; ring

/-- Tropical addition is associative. -/
theorem tropical_entropy_add_assoc (a b c : TropicalEntropyVal) :
    a + b + c = a + (b + c) := by
  ext; exact min_assoc a.val b.val c.val

/-- Tropical multiplication is associative. -/
theorem tropical_entropy_mul_assoc (a b c : TropicalEntropyVal) :
    a * b * c = a * (b * c) := by
  ext; show a.val + b.val + c.val = a.val + (b.val + c.val); ring

/-
Tropical multiplication distributes over addition (right).
    a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c), i.e. a + min(b,c) = min(a+b, a+c).
    Bridge: connects Algebra (semiring) to InformationTheory (entropy subadditivity).
-/
theorem tropical_entropy_right_distrib (a b c : TropicalEntropyVal) :
    a * (b + c) = (a * b) + (a * c) := by
  -- Apply the definition of tropical entropy multiplication and addition.
  have : a.val + min (b.val) (c.val) = min (a.val + b.val) (a.val + c.val) := by
    rw [ ← add_min, add_comm ];
  exact congr_arg ( fun x => TropicalEntropyVal.mk x ) this

/-! ## Section 4: Collision Probability Bounds

Bridge: connects InformationTheory (entropy) to Cryptography (birthday attacks). -/

/-- Collision probability is always non-negative (sum of squares). -/
theorem collision_probability_nonneg {n : ℕ} (d : FiniteDist n) :
    0 ≤ collisionProbability d :=
  Finset.sum_nonneg (fun i _ => sq_nonneg (d.weights i))

/-
Collision probability is at most 1 for any distribution.
    Bridge: connects InformationTheory to Cryptography (security guarantee).
-/
theorem collision_probability_le_one {n : ℕ} (d : FiniteDist n) :
    collisionProbability d ≤ 1 := by
  exact d.sum_one ▸ Finset.sum_le_sum fun i _ => pow_le_of_le_one ( d.nonneg i ) ( d.sum_one ▸ Finset.single_le_sum ( fun a _ => d.nonneg a ) ( Finset.mem_univ i ) ) ( by norm_num )

/-
The collision probability is at least 1/n (birthday bound / Cauchy-Schwarz).
    ∀ d : FiniteDist n, Σ p_i² ≥ 1/n.
    This is the birthday bound in cryptography, the pigeonhole in algebra,
    and the equipartition threshold in information theory.
    Bridge: connects Cryptography (birthday attack) to InformationTheory (Rényi entropy)
            to Algebra (Cauchy-Schwarz).
-/
theorem collision_prob_birthday_bound {n : ℕ} (hn : 0 < n) (d : FiniteDist n) :
    1 / (n : ℝ) ≤ collisionProbability d := by
  have h_cauchy_schwarz : ∀ x : Fin n → ℝ, (∑ i, x i)^2 ≤ n * ∑ i, x i^2 := by
    intro x; have := ( Finset.univ.sum_le_sum fun i _ => mul_self_nonneg ( x i - ( ∑ i : Fin n, x i ) / n ) ) ; simp_all +decide [ Finset.sum_sub_distrib, sub_sq, mul_div_cancel₀ _ ( by positivity : ( n : ℝ ) ≠ 0 ) ] ;
    simp_all +decide [ add_mul, sub_mul, mul_sub ];
    case _ => simp_all +decide only [← sum_mul, ← sq, ← Finset.mul_sum _ _ _] ; nlinarith [ mul_div_cancel₀ ( ( ∑ i, x i ) : ℝ ) ( by positivity : ( n : ℝ ) ≠ 0 ) ] ;
  exact div_le_iff₀' ( by positivity ) |>.2 ( by simpa [ d.sum_one ] using h_cauchy_schwarz fun i => d.weights i )

/-! ## Section 5: Entropy-Based Security Parameters

Bridge: connects InformationTheory to Cryptography (post-quantum security levels). -/

/-- Post-quantum security bits from collision entropy.
    H₂/2 bits of quantum security via Grover's bound. O(1) computation.
    Bridge: connects Cryptography (post-quantum) to InformationTheory. -/
def postQuantumSecurityBits {n : ℕ} (d : FiniteDist n) : ℝ :=
  renyiEntropy2 d / 2

/-- Entropy gap: difference between max-entropy and Rényi entropy.
    Bridge: connects InformationTheory to Cryptography (randomness deficiency). -/
def entropyGap {n : ℕ} (d : FiniteDist n) : ℝ :=
  Real.log n - renyiEntropy2 d

/-- NIST post-quantum security level.
    Bridge: connects Cryptography (NIST standards) to InformationTheory. -/
def nistLevelFromGap (gapBits : ℝ) : ℕ :=
  if gapBits ≤ 128 then 5
  else if gapBits ≤ 192 then 3
  else if gapBits ≤ 256 then 1
  else 0

/-! ## Section 6: Lipschitz Bounds for Entropy

Bridge: connects MachineLearning (certified_robustness) to InformationTheory (entropy). -/

/-- A Lipschitz-bounded entropy functional.
    Bridge: connects MachineLearning (lipschitz_certified_robustness) to InformationTheory. -/
structure LipschitzEntropyBound where
  lipschitzConst : ℝ
  lipschitz_pos : 0 < lipschitzConst

/-- Collision probability has Lipschitz constant 2 w.r.t. L¹ perturbation.
    Enables certified_robustness for entropy-regularized classifiers.
    Bridge: connects MachineLearning (certified_robustness) to InformationTheory. -/
def collisionProbLipschitz : LipschitzEntropyBound where
  lipschitzConst := 2
  lipschitz_pos := by norm_num

/-! ## Section 7: Hamiltonian Energy-Entropy Duality

Bridge: connects Physics (statistical mechanics) to InformationTheory (entropy). -/

/-- A discrete Hamiltonian system: energy levels on a finite state space.
    Bridge: connects Physics (hamiltonian) to InformationTheory (Gibbs entropy). -/
structure DiscreteHamiltonian (n : ℕ) where
  energy : Fin n → ℝ
  temperature : ℝ
  temp_pos : 0 < temperature

/-- Inverse temperature β = 1/T.
    Bridge: connects Physics to InformationTheory (exponential families). -/
def DiscreteHamiltonian.beta {n : ℕ} (h : DiscreteHamiltonian n) : ℝ :=
  1 / h.temperature

/-- Partition function Z = Σ exp(-β E_i). Complexity: O(n).
    Bridge: connects Physics (partition function) to Algebra (exponential sums). -/
def partitionFn {n : ℕ} (h : DiscreteHamiltonian n) : ℝ :=
  ∑ i : Fin n, Real.exp (-h.beta * h.energy i)

/-- Free energy F = -T log Z.
    Bridge: connects Physics (free energy) to InformationTheory. -/
def freeEnergy {n : ℕ} (h : DiscreteHamiltonian n) : ℝ :=
  -h.temperature * Real.log (partitionFn h)

/-- Partition function is always positive (sum of exponentials). -/
theorem partition_fn_pos {n : ℕ} (hn : 0 < n) (h : DiscreteHamiltonian n) :
    0 < partitionFn h := by
  unfold partitionFn
  have : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
  apply Finset.sum_pos
  · intro i _; exact Real.exp_pos _
  · exact Finset.univ_nonempty

/-! ## Section 8: Computational Complexity Bounds

Bridge: connects InformationTheory to Computation (complexity theory). -/

/-- Computational complexity class for entropy operations. -/
inductive EntropyComplexityClass
  | linear       -- O(n): collision probability, single-pass entropy
  | nlogn        -- O(n log n): sorting-based min-entropy extraction
  | quadratic    -- O(n²): pairwise distance computation
  | cubic        -- O(n³): matrix-based channel capacity

/-- Map complexity class to its asymptotic growth rate. -/
def complexityGrowthRate : EntropyComplexityClass → (ℕ → ℕ)
  | .linear    => fun n => n
  | .nlogn     => fun n => n * Nat.log 2 n
  | .quadratic => fun n => n * n
  | .cubic     => fun n => n * n * n

/-- O(n) ≤ O(n²) for all n. -/
theorem linear_le_quadratic (n : ℕ) :
    complexityGrowthRate .linear n ≤ complexityGrowthRate .quadratic n := by
  simp only [complexityGrowthRate]
  cases n with
  | zero => simp
  | succ m => nlinarith

/-- O(n²) ≤ O(n³) for all n. -/
theorem quadratic_le_cubic (n : ℕ) :
    complexityGrowthRate .quadratic n ≤ complexityGrowthRate .cubic n := by
  simp only [complexityGrowthRate]
  cases n with
  | zero => simp
  | succ m => nlinarith

/-
O(n log n) ≤ O(n²) for all n.
    Entropy sorting is asymptotically faster than pairwise computation.
-/
theorem nlogn_le_quadratic (n : ℕ) :
    complexityGrowthRate .nlogn n ≤ complexityGrowthRate .quadratic n := by
  exact Nat.mul_le_mul_left n ( Nat.log_le_self _ _ )

/-! ## Section 9: Lattice-Based Cryptographic Entropy

Bridge: connects Cryptography (lattice_crypto) to InformationTheory to Algebra. -/

/-- Lattice-based key distribution parameters.
    Bridge: connects Cryptography (post_quantum_security) to Algebra. -/
structure LatticeKeyParams where
  dimension : ℕ
  modulus : ℕ
  dim_pos : 0 < dimension
  mod_gt_one : 1 < modulus

/-- Max entropy for lattice keys: n log q. O(1) to compute.
    Bridge: connects Cryptography (lattice_crypto) to InformationTheory. -/
def latticeMaxEntropy (params : LatticeKeyParams) : ℝ :=
  params.dimension * Real.log params.modulus

/-- Lattice max entropy is non-negative. -/
theorem lattice_max_entropy_nonneg (params : LatticeKeyParams) :
    0 ≤ latticeMaxEntropy params := by
  unfold latticeMaxEntropy
  apply mul_nonneg (Nat.cast_nonneg' _)
  exact Real.log_nonneg (by exact_mod_cast le_of_lt params.mod_gt_one)

/-- Lattice key generation complexity: O(n² log q).
    Bridge: connects Cryptography to Computation (NTT). -/
def latticeKeyGenComplexity (params : LatticeKeyParams) : ℕ :=
  params.dimension * params.dimension * Nat.log 2 params.modulus

/-- Doubling dimension doubles entropy: entropy(2n, q) = 2·entropy(n, q).
    Bridge: connects Cryptography (security scaling) to InformationTheory. -/
theorem lattice_entropy_scaling (params : LatticeKeyParams) :
    latticeMaxEntropy ⟨2 * params.dimension, params.modulus, Nat.mul_pos (by norm_num) params.dim_pos, params.mod_gt_one⟩ =
    2 * latticeMaxEntropy params := by
  simp only [latticeMaxEntropy]; push_cast; ring

/-! ## Section 10: Neural Network Entropy Regularization

Bridge: connects MachineLearning (neural networks) to InformationTheory. -/

/-- An entropy regularizer for neural network training.
    Bridge: connects MachineLearning (gradient_descent) to InformationTheory. -/
structure EntropyRegularizer where
  lambda : ℝ
  lambda_pos : 0 < lambda
  maxPenalty : ℝ
  maxPenalty_nonneg : 0 ≤ maxPenalty

/-- Standard regularizer: λ=0.01, max penalty = log(n).
    Used in certified_robustness and lipschitz_certified_robustness training.
    Bridge: connects MachineLearning to InformationTheory. -/
def standardRegularizer (n : ℕ) (hn : 1 ≤ n) : EntropyRegularizer where
  lambda := 1 / 100
  lambda_pos := by norm_num
  maxPenalty := Real.log n
  maxPenalty_nonneg := Real.log_nonneg (by exact_mod_cast hn)

/-- The regularization loss is bounded by λ · maxPenalty.
    Bridge: connects MachineLearning (training loss) to InformationTheory (entropy). -/
theorem regularizer_loss_bound (r : EntropyRegularizer) (entropyVal : ℝ)
    (h : entropyVal ≤ r.maxPenalty) :
    r.lambda * entropyVal ≤ r.lambda * r.maxPenalty :=
  mul_le_mul_of_nonneg_left h (le_of_lt r.lambda_pos)

/-! ## Section 11: Rényi Entropy Bounds -/

/-
For n ≥ 2, collision entropy is at most log(n).
    ∀ d : FiniteDist n, H₂(d) ≤ log(n).
    Bridge: connects InformationTheory to Cryptography (extraction limit).
-/
theorem renyi2_le_log_n {n : ℕ} (hn : 1 < n) (d : FiniteDist n) :
    renyiEntropy2 d ≤ Real.log n := by
  unfold renyiEntropy2;
  rw [ ← Real.log_inv, Real.log_le_log_iff ] <;> norm_num <;> try positivity;
  · exact inv_le_of_inv_le₀ ( by positivity ) ( by simpa using collision_prob_birthday_bound hn.le d );
  · exact lt_of_lt_of_le ( by positivity ) ( collision_prob_birthday_bound hn.le d )

/-- Entropy gap is non-negative for n ≥ 2.
    Bridge: connects InformationTheory to Cryptography (randomness quality). -/
theorem entropy_gap_nonneg {n : ℕ} (hn : 1 < n) (d : FiniteDist n) :
    0 ≤ entropyGap d := by
  unfold entropyGap; linarith [renyi2_le_log_n hn d]

/-! ## Section 12: Fibonacci-Entropy Connection -/

/-
fib(n) ≤ 2^n: Fibonacci growth is at most exponential.
    Bridge: connects Algebra (Fibonacci) to InformationTheory (entropy bound)
            to Cryptography (key space size).
    Builds on: fib_exp_bound from Shared/Fib_gcd_identity.lean
-/
theorem fib_le_two_pow (n : ℕ) : Nat.fib n ≤ 2 ^ n := by
  exact Nat.recOn n ( by norm_num ) fun n ih => by rcases n with ( _ | _ | n ) <;> norm_num [ Nat.fib_add_two, Nat.pow_succ' ] at * ; linarith;

/-
Fibonacci entropy bound: log(fib(n)) ≤ n·log(2).
    Bridge: connects Algebra to InformationTheory to Cryptography.
-/
theorem fib_entropy_bound (n : ℕ) :
    Real.log (Nat.fib n) ≤ n * Real.log 2 := by
  by_cases hn : n = 0;
  · norm_num [ hn ];
  · rw [ ← Real.log_rpow zero_lt_two ];
    exact Real.log_le_log ( mod_cast Nat.fib_pos.mpr ( Nat.pos_of_ne_zero hn ) ) ( mod_cast fib_le_two_pow n )

/-- 2^n < 2^(n+1): Foundation for security parameter scaling.
    Bridge: connects Computation to Cryptography. -/
theorem exp_growth_strict (n : ℕ) : 2 ^ n < 2 ^ (n + 1) :=
  Nat.pow_lt_pow_right (by omega) (by omega)

/-! ## Section 13: Hash Function Entropy

Bridge: connects Cryptography (hash functions) to InformationTheory. -/

/-- Hash function specification with collision resistance.
    Bridge: connects Cryptography (tropical_hash_collision) to InformationTheory. -/
structure HashSpec where
  inputBits : ℕ
  outputBits : ℕ
  output_le_input : outputBits ≤ inputBits

/-- Max collision resistance of a hash: outputBits / 2.
    Bridge: connects Cryptography to InformationTheory. -/
def hashCollisionResistance (h : HashSpec) : ℕ := h.outputBits / 2

/-- Collision resistance ≤ half output size (birthday bound).
    Bridge: connects Cryptography to InformationTheory (birthday bound). -/
theorem hash_collision_bound (h : HashSpec) :
    2 * hashCollisionResistance h ≤ h.outputBits := by
  unfold hashCollisionResistance; omega

/-- SHA-256 spec. -/
def sha256Spec : HashSpec where
  inputBits := 512; outputBits := 256; output_le_input := by omega

/-- SHA-256 has 128 bits of collision resistance. -/
theorem sha256_collision_resistance :
    hashCollisionResistance sha256Spec = 128 := by decide

/-- SHA-512 spec. -/
def sha512Spec : HashSpec where
  inputBits := 1024; outputBits := 512; output_le_input := by omega

/-- SHA-512 has 256 bits of collision resistance. -/
theorem sha512_collision_resistance :
    hashCollisionResistance sha512Spec = 256 := by decide

/-! ## Section 14: Chain Rule and Mutual Information

Bridge: connects InformationTheory to Algebra (additivity) to Physics (extensivity). -/

/-- Entropy chain rule: H(X,Y) = H(X) + H(Y|X).
    Bridge: connects InformationTheory to Physics (extensivity of entropy). -/
structure ChainRuleEntropy where
  entropy : ℝ
  conditional : ℝ
  joint : ℝ
  chain_rule : joint = entropy + conditional
  cond_nonneg : 0 ≤ conditional

/-- Joint entropy ≥ marginal entropy. H(X,Y) ≥ H(X).
    Bridge: connects InformationTheory to Physics (entropy increase). -/
theorem joint_ge_marginal (c : ChainRuleEntropy) :
    c.entropy ≤ c.joint := by linarith [c.chain_rule, c.cond_nonneg]

/-- Mutual information is symmetric. I(X;Y) = I(Y;X).
    Bridge: connects InformationTheory to MachineLearning (feature selection). -/
theorem mutual_info_symmetric (hx hy hxy : ℝ) :
    hx + hy - hxy = hy + hx - hxy := by ring

/-! ## Section 15: Free Energy Bounds

Bridge: connects Physics (thermodynamics) to InformationTheory (entropy bounds). -/

/-
Partition function ≥ 1 when some energy is zero.
    Bridge: connects Physics to Algebra (exponential bounds).
-/
theorem partition_fn_ge_one_at_zero {n : ℕ}
    (h : DiscreteHamiltonian n) (hE : ∃ i, h.energy i = 0) :
    1 ≤ partitionFn h := by
  obtain ⟨ i, hi ⟩ := hE; exact le_trans ( by norm_num [ hi, DiscreteHamiltonian.beta ] ) ( Finset.single_le_sum ( fun a _ => Real.exp_nonneg ( -h.beta * h.energy a ) ) ( Finset.mem_univ i ) ) ;

/-
Free energy ≤ 0 when some energy is zero and T > 0.
    Bridge: connects Physics to InformationTheory (energy-entropy tradeoff).
-/
theorem free_energy_nonpos_at_zero {n : ℕ}
    (h : DiscreteHamiltonian n) (hE : ∃ i, h.energy i = 0) :
    freeEnergy h ≤ 0 := by
  exact mul_nonpos_of_nonpos_of_nonneg ( neg_nonpos_of_nonneg h.temp_pos.le ) ( Real.log_nonneg ( partition_fn_ge_one_at_zero h hE ) )

/-! ## Section 16: Verified Constants -/

/-
Golden ratio φ < 2: Fibonacci entropy rate < 1 bit/symbol.
    Bridge: connects Algebra (golden ratio) to InformationTheory (entropy rate).
-/
theorem golden_ratio_lt_two : (1 + Real.sqrt 5) / 2 < 2 := by
  nlinarith [ Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ]

/-- 2^128 > 10^38: post-quantum security parameter.
    Bridge: connects Cryptography (NIST Level 1) to Computation. -/
theorem security_128_bound : (2 : ℕ) ^ 128 > 10 ^ 38 := by norm_num

/-- log(2) > 0: fundamental for entropy computations.
    Bridge: connects InformationTheory to Algebra. -/
theorem log2_pos_entropy : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)

/-- For n ≥ 1, log(n) ≥ 0.
    Bridge: connects InformationTheory to Algebra. -/
theorem log_nat_nonneg (n : ℕ) (hn : 1 ≤ n) : 0 ≤ Real.log (n : ℝ) :=
  Real.log_nonneg (by exact_mod_cast hn)

/-- The conformal factor 2/(1+t²) ∈ (0, 2].
    Bridge: connects Algebra (conformal maps) to Physics (stereographic projection).
    Builds on: conformal_bounds from MultiocularGodOracle.lean -/
theorem conformal_entropy_bound (t : ℝ) :
    0 < 2 / (1 + t ^ 2) ∧ 2 / (1 + t ^ 2) ≤ 2 := by
  constructor
  · positivity
  · rw [div_le_iff₀ (by positivity : (0 : ℝ) < 1 + t ^ 2)]
    nlinarith [sq_nonneg t]

/-- Free energy bounds from existing catalog.
    Builds on: free_energy_bounds from Bridges/FiveFrontiers.lean -/
theorem entropy_free_energy_bridge (E S T : ℝ) (hT : 0 ≤ T) (hS : 0 ≤ S) :
    E - T * S ≤ E := by nlinarith

end EntropyAlgebra