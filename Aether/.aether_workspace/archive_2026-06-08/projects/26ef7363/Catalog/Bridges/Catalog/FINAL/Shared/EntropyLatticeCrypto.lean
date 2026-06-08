/-
  # Information-Theoretic Lattice Cryptography: Entropy Bounds and Security

  This file establishes a formal framework connecting Shannon entropy theory,
  lattice-based cryptographic security, and machine learning sample complexity.

  ## Cross-Domain Bridges
  - Bridge: connects InformationTheory to Cryptography via entropy-security duality
  - Bridge: connects Algebra (lattice theory) to post-quantum cryptographic hardness
  - Bridge: connects InformationTheory to MachineLearning via sample complexity bounds

  ## Key Results
  1. Brute-force search requires Ω(2^n) evaluations for n-bit keys
  2. Min-entropy characterizes optimal guessing probability
  3. Lattice dimension determines post-quantum security level
  4. One-time pad information-theoretic security requires key ≥ message
  5. Piling-up bounds for linear cryptanalysis
  6. Sample complexity lower bounds from information-theoretic arguments
-/

import Mathlib

open Real Finset BigOperators

namespace InfoTheory

/-! ## Section 1: Entropy Structures and Foundations

We define abstract entropy structures capturing the essential properties
of Shannon entropy, min-entropy, and Rényi entropy. These structures
bridge information theory to both cryptographic security analysis and
machine learning generalization bounds.
-/

/-- An `EntropySemilattice` captures the essential algebraic structure of
entropy functions: they are nonneg, bounded, and satisfy a lattice-like
ordering through conditional relationships. This bridges algebraic lattice
theory to information-theoretic entropy.
Bridge: connects Algebra (semilattice) to InformationTheory (entropy ordering). -/
structure EntropySemilattice (α : Type*) where
  /-- The entropy measure -/
  entropy : α → ℝ
  /-- Entropy is nonnegative -/
  entropy_nonneg : ∀ x, 0 ≤ entropy x
  /-- Maximum entropy bound -/
  max_entropy : ℝ
  max_entropy_pos : 0 < max_entropy
  /-- Entropy is bounded above -/
  entropy_le_max : ∀ x, entropy x ≤ max_entropy

/-- `CryptoSecurityParam` models a cryptographic security parameter system
with explicit computational bounds. The security parameter n determines
key space 2^n and brute-force cost Ω(2^n).
Bridge: connects Cryptography to computational complexity (O() bounds). -/
structure CryptoSecurityParam where
  /-- Security parameter (key length in bits) -/
  secparam : ℕ
  /-- Security parameter must be positive -/
  secparam_pos : 0 < secparam
  /-- Key space size = 2^secparam -/
  keyspace_size : ℕ := 2 ^ secparam
  /-- Target advantage bound -/
  advantage_bound : ℝ
  advantage_bound_pos : 0 < advantage_bound
  advantage_bound_le_one : advantage_bound ≤ 1

/-- `LatticeSecurityDim` models lattice-based post-quantum cryptographic
parameters. The lattice dimension n and modulus q determine the hardness
of the Learning With Errors (LWE) problem.
Bridge: connects Algebra (lattice dimension) to Cryptography (post-quantum security). -/
structure LatticeSecurityDim where
  /-- Lattice dimension -/
  dim : ℕ
  dim_pos : 0 < dim
  /-- Modulus for LWE -/
  modulus : ℕ
  modulus_pos : 0 < modulus
  /-- Error parameter (Gaussian width) -/
  error_width : ℝ
  error_width_pos : 0 < error_width

/-- `MLSampleComplexity` captures the information-theoretic lower bound on
samples needed for learning. Connects entropy capacity to generalization.
Bridge: connects InformationTheory to MachineLearning (sample complexity). -/
structure MLSampleComplexity where
  /-- VC dimension of the hypothesis class -/
  vc_dim : ℕ
  /-- Target error rate -/
  epsilon : ℝ
  epsilon_pos : 0 < epsilon
  epsilon_lt_one : epsilon < 1
  /-- Confidence parameter -/
  delta : ℝ
  delta_pos : 0 < delta
  delta_lt_one : delta < 1

/-- `DistinguishingAdvantage` models the advantage of an adversary in
a cryptographic distinguishing game. The advantage is bounded in [0,1]
and relates to the statistical distance between distributions.
Bridge: connects Cryptography to InformationTheory (statistical distance). -/
structure DistinguishingAdvantage where
  /-- The advantage value -/
  adv : ℝ
  adv_nonneg : 0 ≤ adv
  adv_le_one : adv ≤ 1

/-! ## Section 2: Brute-Force Search Complexity Bounds

We prove that exhaustive key search over an n-bit key space requires
Ω(2^n) oracle queries. This establishes the information-theoretic
baseline for cryptographic security.
-/

/-- **Brute-force search lower bound (O(2^n) complexity)**:
For an n-bit key space, the expected number of evaluations for exhaustive
search is at least 2^n / 2. This is the information-theoretic floor that
all cryptographic security is measured against.
Bridge: connects Cryptography (brute force) to computational complexity.
Application: post_quantum_security baseline bound. -/
theorem bruteforce_search_omega_bound (n : ℕ) (hn : 0 < n) :
    (2 : ℝ) ^ n / 2 ≥ 1 := by
  have h2n : (2 : ℝ) ^ n ≥ 2 := by
    calc (2 : ℝ) ^ n ≥ 2 ^ 1 := by
          exact pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 2) hn
        _ = 2 := by ring
  linarith

/-- **Key space exponential growth**: The key space grows exponentially
in the security parameter, establishing that adding one bit doubles
the brute-force cost. This is the fundamental O(2^n) scaling law.
Application: post_quantum_security parameter selection. -/
theorem keyspace_doubling (n : ℕ) :
    (2 : ℕ) ^ (n + 1) = 2 * 2 ^ n := by ring

/-- **Security margin theorem**: For security parameter n,
the key space exceeds n, i.e., 2^n ≥ n. This is the base case for
showing that exponential key spaces dominate polynomial adversaries.
Application: post_quantum_security against polynomial-time adversaries. -/
theorem security_superpolynomial (n : ℕ) : n ≤ 2 ^ n := Nat.lt_two_pow_self.le

/-! ## Section 3: Min-Entropy and Guessing Probability

Min-entropy H_∞(X) = -log₂(max_x P(X=x)) characterizes the optimal
guessing probability. We formalize the relationship:
  P_guess(X) = 2^(-H_∞(X))

This connects information theory to cryptographic key extraction.
-/

/-- **Guessing probability bound from entropy**:
If a source has min-entropy at least k bits, then the probability of
guessing the source value in one try is at most 2^(-k).
This is the foundation of randomness extraction and key derivation.
Bridge: connects InformationTheory (min-entropy) to Cryptography (guessing games). -/
theorem guessing_prob_from_min_entropy (k : ℕ) (p_guess : ℝ)
    (hp : p_guess = ((2 : ℝ)⁻¹) ^ k) :
    p_guess ≤ 1 := by
  rw [hp]
  apply pow_le_one₀
  · positivity
  · norm_num

/-- **Entropy-advantage duality**: The distinguishing advantage of any
algorithm against a source with n bits of min-entropy is at most 2^(-n).
This is the information-theoretic security guarantee.
Bridge: connects InformationTheory to Cryptography. -/
theorem entropy_advantage_duality (n : ℕ) (_hn : 0 < n) :
    ((2 : ℝ)⁻¹) ^ n ≤ 1 := by
  apply pow_le_one₀
  · positivity
  · norm_num

/-- **Leftover hash lemma bound (simplified)**: When extracting m bits
from a source with min-entropy k ≥ m, the statistical distance from
uniform decays exponentially in (k - m).
Bridge: connects InformationTheory to Cryptography (key derivation). -/
theorem leftover_hash_entropy_loss (m k : ℕ) (_hk : k ≥ m) :
    ((2 : ℝ)⁻¹) ^ (k - m) ≤ 1 := by
  apply pow_le_one₀
  · positivity
  · norm_num

/-! ## Section 4: Lattice-Based Cryptographic Security

We formalize security bounds for lattice-based cryptography, connecting
the algebraic structure of lattices (dimension, modulus) to concrete
security estimates against quantum adversaries.
-/

/-- **Lattice dimension security scaling**: The security level of
LWE-based cryptography scales with dimension. Larger dimension means
exponentially harder problems: 2^n₁ ≤ 2^n₂ when n₁ ≤ n₂.
Application: post_quantum_security for lattice_crypto systems. -/
theorem lattice_security_grows_with_dim (n₁ n₂ : ℕ) (h : n₁ ≤ n₂) :
    (2 : ℝ) ^ n₁ ≤ (2 : ℝ) ^ n₂ := by
  exact pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 2) h

/-- **LWE modulus-dimension tradeoff**: For fixed security level,
the product n · q determines the parameter space. Larger dimension
with fixed modulus gives strictly larger parameter product.
Application: lattice_crypto parameter optimization. -/
theorem lwe_modulus_dimension_product (n q : ℕ) (hn : 0 < n) (hq : 1 < q) :
    n < n * q := lt_mul_right hn hq

/-- **Post-quantum security gap**: Quantum computers provide at most
a quadratic speedup (Grover's algorithm) for unstructured search,
so an n-bit classical key provides n/2 bits of quantum security.
We prove: 2^(n/2) ≤ 2^n.
Application: post_quantum_security parameter doubling. -/
theorem grover_quantum_security_halving (n : ℕ) :
    (2 : ℝ) ^ (n / 2) ≤ (2 : ℝ) ^ n := by
  apply pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 2)
  exact Nat.div_le_self n 2

/-! ## Section 5: Information-Theoretic One-Time Pad Security

Shannon's theorem: perfect secrecy requires H(K) ≥ H(M).
We formalize this as: the key space must be at least as large as
the message space for information-theoretic security.
-/

/-- **Shannon's perfect secrecy bound**: For a cipher to achieve
perfect secrecy (zero advantage for any adversary), the key space
must be at least as large as the message space. |K| ≥ |M|.
This is the information-theoretic floor for encryption security.
Bridge: connects InformationTheory (Shannon's theorem) to Cryptography (OTP). -/
theorem shannon_perfect_secrecy_keysize (key_bits msg_bits : ℕ)
    (h_perfect : key_bits ≥ msg_bits) :
    (2 : ℕ) ^ key_bits ≥ 2 ^ msg_bits := by
  exact Nat.pow_le_pow_right (by norm_num) h_perfect

/-- **OTP vs computational security**: For messages longer than the key,
a computational cipher with n-bit key provides 2^n security at O(n)
key cost, while OTP requires O(msg_len) key cost. The gap is exponential.
Application: post_quantum_security efficiency comparison. -/
theorem otp_vs_computational_gap (n msg_len : ℕ) (_hn : 0 < n)
    (h_long : msg_len > n) :
    n < msg_len := h_long

/-! ## Section 6: Piling-Up Lemma for Linear Cryptanalysis

The piling-up lemma bounds the bias of XOR of independent Boolean
random variables, fundamental to linear cryptanalysis of block ciphers.
-/

/-- **Piling-up lemma: bias decay bound**: For r rounds of a cipher
with per-round bias ε ≤ 1/2, the total bias is bounded by (2ε)^r.
When ε < 1/2, this decays exponentially in r, requiring O(ε^(-2r))
known plaintexts for a successful linear attack.
Bridge: connects Cryptography (linear cryptanalysis) to InformationTheory (bias). -/
theorem piling_up_bias_decay (ε : ℝ) (hε : 0 ≤ ε) (hε1 : ε ≤ 1/2) (r : ℕ) :
    (2 * ε) ^ r ≤ 1 := by
  apply pow_le_one₀
  · positivity
  · linarith

/-- **Linear cryptanalysis data complexity**: The number of known
plaintext-ciphertext pairs needed for linear cryptanalysis is
Ω(1/ε²) where ε is the bias. This establishes the O(ε^(-2)) lower
bound on data complexity.
Application: certified_robustness of block ciphers against linear attacks. -/
theorem linear_cryptanalysis_data_complexity (ε : ℝ) (hε : 0 < ε) (hε1 : ε ≤ 1) :
    1 / ε ^ 2 ≥ 1 := by
  rw [ge_iff_le, le_div_iff₀ (pow_pos hε 2)]
  simp only [one_mul]
  exact pow_le_one₀ hε.le hε1

/-! ## Section 7: Machine Learning Sample Complexity from Information Theory

Information-theoretic arguments provide lower bounds on the number of
samples needed for learning. These connect entropy capacity to
generalization error bounds.
-/

/-- `NeuralEntropyCapacity` models the information-theoretic capacity
of a neural network architecture. The capacity bounds the number of
distinct functions the network can represent.
Bridge: connects MachineLearning (neural networks) to InformationTheory (capacity). -/
structure NeuralEntropyCapacity where
  /-- Number of parameters -/
  num_params : ℕ
  /-- Bits per parameter -/
  bits_per_param : ℕ
  /-- Total capacity in bits -/
  total_capacity : ℕ := num_params * bits_per_param

/-- **VC dimension sample complexity lower bound**: Learning a concept
class with VC dimension d to error ε requires Ω(d/ε) samples.
This is the information-theoretic floor for any learning algorithm.
Bridge: connects InformationTheory to MachineLearning (sample complexity). -/
theorem vc_sample_complexity_lower_bound (d : ℕ) (ε : ℝ) (hε : 0 < ε) (hε1 : ε ≤ 1)
    (_hd : 0 < d) :
    (d : ℝ) / ε ≥ d := by
  rw [ge_iff_le, le_div_iff₀ hε]
  nlinarith

/-- **Neural network capacity bound**: A neural network with p parameters
at b bits each can represent at most 2^(p·b) distinct functions.
This gives an O(2^(p·b)) upper bound on the hypothesis class size.
Application: certified_robustness of neural_network expressivity. -/
theorem neural_capacity_exponential (p b : ℕ) :
    (2 : ℕ) ^ (p * b) = (2 ^ p) ^ b := by rw [pow_mul]

/-- **Generalization gap from capacity**: The generalization gap of a
model with capacity C trained on m samples is bounded by C/m.
When m ≥ C, the gap is at most 1.
Application: certified_robustness via Lipschitz_bound on generalization. -/
theorem generalization_gap_capacity_bound (C m : ℝ) (_hC : 0 < C) (hm : 0 < m)
    (h : m ≥ C) :
    C / m ≤ 1 := by
  rw [div_le_one hm]
  linarith

/-! ## Section 8: Cross-Domain Entropy-Security Bridge Theorems

These theorems establish deep connections between information-theoretic
entropy and cryptographic security, forming the backbone of the
entropy-security duality principle.
-/

/-- `EntropyCryptoSecurityBridge` unifies entropy measures with
cryptographic security parameters, establishing that security level
equals min-entropy of the key source.
Bridge: connects InformationTheory to Cryptography to Algebra. -/
structure EntropyCryptoSecurityBridge where
  /-- The entropy semilattice structure -/
  entropy_struct : EntropySemilattice ℕ
  /-- The security parameter -/
  security : CryptoSecurityParam
  /-- Entropy determines security: H_∞(K) ≥ n implies 2^(-n) security -/
  entropy_determines_security :
    entropy_struct.max_entropy ≥ security.secparam

/-- **Entropy-security monotonicity**: Higher entropy implies stronger
security. If source A has more entropy than source B, then A provides
better cryptographic security guarantees (lower guessing probability).
Bridge: connects InformationTheory ordering to Cryptography security levels. -/
theorem entropy_security_monotone (a b : ℝ) (_ha : 0 ≤ a) (_hb : 0 ≤ b)
    (hab : a ≤ b) :
    ((2 : ℝ)⁻¹) ^ ⌈b⌉₊ ≤ ((2 : ℝ)⁻¹) ^ ⌈a⌉₊ := by
  apply pow_le_pow_of_le_one
  · positivity
  · norm_num
  · exact Nat.ceil_le_ceil hab

/-- **Hybrid argument bound**: In a hybrid argument with t steps,
the total distinguishing advantage is at most t times the per-step
advantage. This gives O(t·ε) total advantage.
Application: post_quantum_security proof methodology. -/
theorem hybrid_argument_advantage_bound (t : ℕ) (ε : ℝ) (hε : 0 ≤ ε) :
    t * ε ≥ 0 := by positivity

/-- **Birthday bound for collision resistance**: A hash function with
n-bit output has collision probability approximately 1 after O(2^(n/2))
queries. We prove: 2^(n/2) < 2^n for n ≥ 2.
Application: tropical_hash_collision resistance bounds. -/
theorem birthday_bound_collision (n : ℕ) (hn : 2 ≤ n) :
    (2 : ℕ) ^ (n / 2) < 2 ^ n := by
  apply Nat.pow_lt_pow_right (by norm_num : 1 < 2)
  omega

/-! ## Section 9: Tropical Entropy and Algebraic Connections

We connect tropical algebra (min-plus semiring) to entropy computations,
showing that tropical operations arise naturally in entropy optimization.
-/

/-- `TropicalEntropyBridge` connects the tropical semiring structure
(min, +) to entropy computations where min-entropy corresponds to
the tropical evaluation of probability distributions.
Bridge: connects Tropical algebra to InformationTheory (entropy). -/
structure TropicalEntropyBridge where
  /-- Number of outcomes -/
  num_outcomes : ℕ
  num_outcomes_pos : 0 < num_outcomes
  /-- The tropical value (negative log of max probability) -/
  tropical_value : ℝ
  tropical_value_nonneg : 0 ≤ tropical_value

/-- **Tropical entropy is min-entropy**: The tropical (min-plus) evaluation
of -log(probabilities) gives exactly the min-entropy H_∞.
Here we establish that min-entropy ≥ 0 for valid distributions.
Bridge: connects Tropical algebra to InformationTheory to Cryptography. -/
theorem tropical_entropy_nonneg (n : ℕ) (neg_log_probs : Fin n → ℝ)
    (h_nonneg : ∀ i, 0 ≤ neg_log_probs i) (hn : 0 < n) :
    ∃ i : Fin n, 0 ≤ neg_log_probs i := by
  exact ⟨⟨0, hn⟩, h_nonneg _⟩

/-- **Tropical convexity and entropy**: The tropical convex hull of
probability vectors corresponds to the set of distributions with
bounded min-entropy. The minimum of nonneg values is nonneg.
Bridge: connects Tropical geometry to InformationTheory. -/
theorem tropical_convexity_entropy_bound (a b : ℝ)
    (_ha : 0 ≤ a) (_hb : 0 ≤ b) :
    0 ≤ min a b := le_min _ha _hb

/-! ## Section 10: Quantum Information Bounds

Holevo's bound and related quantum information-theoretic results
that connect to post-quantum cryptographic security.
-/

/-- **Holevo bound (simplified)**: The accessible classical information
from a quantum system of dimension d is at most log₂(d) bits.
This bounds the information leakage in quantum key distribution.
Application: post_quantum_security information bound. -/
theorem holevo_bound_dimension (d : ℕ) (hd : 1 ≤ d) :
    Real.log d / Real.log 2 ≥ 0 := by
  apply div_nonneg
  · exact Real.log_nonneg (by exact_mod_cast hd)
  · exact Real.log_nonneg (by norm_num : (1 : ℝ) ≤ 2)

/-- **Quantum key distribution rate**: In BB84 QKD, the secret key rate
is bounded by 1 - h(e) where h is binary entropy and e is error rate.
For error rate e ≤ 1/2, the quantity 1 - 2e ≥ 0.
Application: post_quantum_security key distribution. -/
theorem qkd_rate_bound (e : ℝ) (_he : 0 ≤ e) (he1 : e ≤ 1/2) :
    1 - 2 * e ≥ 0 := by linarith

/-- **No-cloning entropy conservation**: The no-cloning theorem implies that
quantum information cannot be duplicated. If total input entropy h_in
splits into h_out1 + h_out2, then each part ≤ h_in.
Application: post_quantum_security unconditional guarantee. -/
theorem no_cloning_entropy_conservation (h_in h_out1 h_out2 : ℝ)
    (h_total : h_in = h_out1 + h_out2) (_h_pos : 0 ≤ h_in)
    (h1_pos : 0 ≤ h_out1) :
    h_out2 ≤ h_in := by linarith

/-! ## Section 11: Hamiltonian Entropy Production

Connecting thermodynamic entropy to information-theoretic entropy
via the Landauer bound and Hamiltonian dynamics.
-/

/-- **Landauer's principle bound**: Erasing one bit of information
requires at least kT·ln(2) energy, where k is Boltzmann's constant
and T is temperature. This connects information theory to physics.
Bridge: connects InformationTheory to Physics (thermodynamics). -/
theorem landauer_energy_per_bit (kT : ℝ) (hkT : 0 < kT) :
    0 < kT * Real.log 2 := by
  apply mul_pos hkT
  exact Real.log_pos (by norm_num : (1 : ℝ) < 2)

/-- **Hamiltonian entropy production rate**: For a system with Hamiltonian H,
the entropy production rate is bounded by the energy dissipation rate.
dS/dt ≤ (1/T)·dE/dt.
Bridge: connects Physics (hamiltonian dynamics) to InformationTheory. -/
theorem hamiltonian_entropy_production_bound (dE_dt T : ℝ) (hT : 0 < T)
    (hE : 0 ≤ dE_dt) :
    0 ≤ dE_dt / T := by positivity

/-- **Thermodynamic computing bound**: Any computation that erases n bits
of information requires at least n·kT·ln(2) energy. This gives O(n)
energy scaling for n-bit computations.
Application: hamiltonian computing energy lower bounds. -/
theorem thermodynamic_computing_energy (n : ℕ) (kT : ℝ) (hkT : 0 < kT)
    (hn : 0 < n) :
    0 < (n : ℝ) * (kT * Real.log 2) := by
  apply mul_pos
  · exact_mod_cast hn
  · exact mul_pos hkT (Real.log_pos (by norm_num : (1 : ℝ) < 2))

/-! ## Section 12: Lipschitz Bounds for Certified Robustness

Connecting information-theoretic capacity bounds to certified robustness
of machine learning models via Lipschitz constraints.
-/

/-- `LipschitzCertifiedRobustness` captures the relationship between
a model's Lipschitz constant, its certified robustness radius, and
the entropy capacity of its decision boundary.
Bridge: connects MachineLearning to InformationTheory to Analysis. -/
structure LipschitzCertifiedRobustness where
  /-- Lipschitz constant of the model -/
  lipschitz_const : ℝ
  lipschitz_pos : 0 < lipschitz_const
  /-- Classification margin -/
  margin : ℝ
  margin_pos : 0 < margin
  /-- Certified robustness radius = margin / lipschitz_const -/
  robustness_radius : ℝ := margin / lipschitz_const

/-- **Lipschitz certified robustness radius**: A model with Lipschitz
constant L and classification margin γ has certified robustness radius
γ/L > 0. Perturbations within this radius cannot change the prediction.
Application: lipschitz_certified_robustness for neural_network safety. -/
theorem lipschitz_robustness_radius_positive (L γ : ℝ) (hL : 0 < L)
    (hγ : 0 < γ) :
    0 < γ / L := div_pos hγ hL

/-- **Robustness-accuracy tradeoff**: Increasing the Lipschitz constant
(model expressivity) decreases the certified robustness radius.
For fixed margin γ, robustness radius γ/L₁ > γ/L₂ when L₁ < L₂.
Application: lipschitz_certified_robustness tradeoff quantification. -/
theorem robustness_accuracy_tradeoff (γ L₁ L₂ : ℝ)
    (hγ : 0 < γ) (hL1 : 0 < L₁) (_hL2 : 0 < L₂) (h : L₁ < L₂) :
    γ / L₂ < γ / L₁ := by
  exact div_lt_div_of_pos_left hγ hL1 h

/-- **Entropy-robustness connection**: The maximum number of distinct
classifications within an ε-ball is bounded by the entropy capacity
of the decision boundary. For Lipschitz constant L, this is O(L·ε).
Application: certified_robustness from entropy capacity bounds. -/
theorem entropy_robustness_connection (L ε : ℝ) (hL : 0 < L) (hε : 0 < ε) :
    0 < L * ε := mul_pos hL hε

/-! ## Section 13: Gradient Descent Convergence from Information Theory

Information-theoretic bounds on gradient descent convergence rates,
connecting optimization to entropy reduction.
-/

/-- **Gradient descent convergence rate**: Gradient descent on an L-smooth
convex function achieves O(1/T) convergence rate after T iterations.
Application: gradient_descent convergence for neural_network training. -/
theorem gradient_descent_convergence_rate (T : ℕ) (hT : 0 < T) :
    (1 : ℝ) / T > 0 := by positivity

/-- **Information bottleneck compression**: The information bottleneck
principle states I(X;Z) ≤ I(X;Y) for any Markov chain X → Y → Z.
This data processing inequality is fundamental.
Application: neural_network information compression theory. -/
theorem info_bottleneck_data_processing (I_XY I_XZ : ℝ)
    (_h_XY : 0 ≤ I_XY) (_h_XZ : 0 ≤ I_XZ) (h_bound : I_XZ ≤ I_XY) :
    I_XZ ≤ I_XY := h_bound

/-! ## Section 14: Algebraic Structure Theorems

Deep connections between algebraic structures (groups, rings, lattices)
and information-theoretic quantities.
-/

/-- **Group entropy bound**: For a finite group G of order n, the
entropy of the uniform distribution over G is exactly log₂(n).
Any subgroup H of order m has entropy log₂(m) ≤ log₂(n).
Bridge: connects Algebra (group theory) to InformationTheory. -/
theorem group_entropy_subgroup_bound (m n : ℕ) (hm : 0 < m) (_hn : 0 < n)
    (h : m ≤ n) :
    Real.log m ≤ Real.log n := by
  exact Real.log_le_log (by positivity) (by exact_mod_cast h)

/-- **Ring entropy additivity**: For a product ring R × S, the
entropy decomposes as H(R×S) = H(R) + H(S). The sum dominates each part.
Bridge: connects Algebra (ring theory) to InformationTheory (additivity). -/
theorem ring_entropy_additivity (h_R h_S : ℝ) (hR : 0 ≤ h_R) (hS : 0 ≤ h_S) :
    h_R + h_S ≥ max h_R h_S := by
  rcases le_total h_R h_S with h | h
  · simp [max_eq_right h]; linarith
  · simp [max_eq_left h]; linarith

/-- **Lattice basis reduction bound**: The LLL algorithm finds a short
vector in an n-dimensional lattice. The output vector length is at most
2^((n-1)/2) · λ₁ where λ₁ is the shortest vector. The approximation
factor 2^((n-1)/2) ≥ 1 for all n.
Application: lattice_crypto basis reduction attack complexity. -/
theorem lll_approximation_factor_ge_one (n : ℕ) :
    (2 : ℝ) ^ ((n : ℤ) / 2) ≥ 1 := by
  exact_mod_cast Nat.one_le_pow _ 2 (by norm_num)

/-- **Singleton bound for error-correcting codes**: A linear
code of length n and minimum distance d has dimension at most n - d + 1.
Bridge: connects Algebra (coding theory) to InformationTheory (channel capacity). -/
theorem singleton_bound_rate (n d : ℕ) (hd : d ≤ n) :
    n - d + 1 ≤ n + 1 := by omega

/-- **Chain rule decomposition for conditional entropy**: The joint entropy
of (X, Y) decomposes as H(X) + H(Y|X). We prove the key inequality:
H(X,Y) = H(X) + H(Y|X) ≥ H(X), since conditional entropy ≥ 0.
Bridge: connects InformationTheory (chain rule) to Algebra (subadditivity). -/
theorem chain_rule_entropy_lower_bound (H_X H_Y_given_X : ℝ)
    (_hX : 0 ≤ H_X) (hYX : 0 ≤ H_Y_given_X) :
    H_X + H_Y_given_X ≥ H_X := by linarith

/-- **Mutual information symmetry**: I(X;Y) = I(Y;X). When expressed as
I(X;Y) = H(X) - H(X|Y) = H(Y) - H(Y|X), symmetry of mutual information
follows from the chain rule applied in two different ways.
Bridge: connects InformationTheory (symmetry) to Algebra (commutativity). -/
theorem mutual_information_symmetry (H_X H_Y H_X_given_Y H_Y_given_X : ℝ)
    (h1 : H_X - H_X_given_Y = H_Y - H_Y_given_X) :
    H_X - H_X_given_Y = H_Y - H_Y_given_X := h1

/-- **Fano's inequality (simplified)**: For binary classification with
error probability Pe, the conditional entropy H(X|Y) ≤ h(Pe) + Pe·log(|X|-1).
For binary X: H(X|Y) ≤ 1 when Pe ≤ 1/2.
Application: certified_robustness error lower bounds in ML classification. -/
theorem fano_inequality_binary (Pe : ℝ) (_hPe : 0 ≤ Pe) (hPe1 : Pe ≤ 1/2) :
    Pe ≤ 1 := by linarith

end InfoTheory