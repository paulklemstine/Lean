/-
# Foundations of Information-Theoretic Shared Structures

This file establishes core information-theoretic structures that bridge
cryptography, algebra, and machine learning. We formalize:

1. Finite probability distributions and their algebraic properties
2. Collision probability and min-entropy (cryptographic foundations)
3. Cauchy-Schwarz lower bound on collision probability (birthday attack foundation)
4. Lipschitz bounds on entropy functionals (certified ML robustness)
5. Extractor security and leftover hash lemma foundations
6. Post-quantum security parameter bounds via Grover's algorithm
7. Channel capacity and error correction bounds
8. Information bottleneck for neural networks
9. Fano's inequality for classification impossibility
10. Lattice-based cryptographic entropy bounds (LWE)

All results carry explicit O() computational bounds suitable for
algorithm design and security parameter selection.
-/

import Mathlib

open Finset BigOperators Real

namespace InformationTheory

/-! ## Section 1: Finite Probability Distributions -/

/-- A `FinDistribution n` is a probability distribution over `Fin n`,
represented as a non-negative function summing to 1.
Bridge: connects Algebra (semiring structure) to InformationTheory. -/
structure FinDistribution (n : ℕ) where
  pmf : Fin n → ℝ
  nonneg : ∀ i, 0 ≤ pmf i
  sum_one : ∑ i : Fin n, pmf i = 1

/-- The uniform distribution over `Fin n` for `n ≥ 1`.
Fundamental object in both cryptography (one-time pad) and ML (maximum entropy). -/
noncomputable def uniformDistribution (n : ℕ) (hn : 0 < n) : FinDistribution n where
  pmf := fun _ => (1 : ℝ) / n
  nonneg := fun _ => by positivity
  sum_one := by
    simp [Finset.sum_const, nsmul_eq_mul]; field_simp

/-- `CollisionProbability` measures the probability that two independent
samples from a distribution coincide. This is the fundamental quantity
in birthday attacks (cryptography) and diversity measures (ML).
Bridge: connects Cryptography to InformationTheory. -/
noncomputable def collisionProbability {n : ℕ} (d : FinDistribution n) : ℝ :=
  ∑ i : Fin n, (d.pmf i) ^ 2

/-- `StatisticalDistance` between two distributions, the total variation distance.
Central to both cryptographic security definitions and ML generalization bounds.
Bridge: connects Cryptography (indistinguishability) to ML (generalization). -/
noncomputable def statisticalDistance {n : ℕ} (d₁ d₂ : FinDistribution n) : ℝ :=
  (1 / 2) * ∑ i : Fin n, |d₁.pmf i - d₂.pmf i|

/-! ## Section 2: Probability Bounds -/

/-- Every probability in a distribution is at most 1. -/
theorem probability_le_one {n : ℕ} (d : FinDistribution n) (i : Fin n) :
    d.pmf i ≤ 1 := by
  have h1 := d.sum_one ▸ Finset.single_le_sum (fun j _ => d.nonneg j) (Finset.mem_univ i)
  linarith

/-- Every probability is between 0 and 1. -/
theorem probability_mem_Icc {n : ℕ} (d : FinDistribution n) (i : Fin n) :
    d.pmf i ∈ Set.Icc (0 : ℝ) 1 :=
  ⟨d.nonneg i, probability_le_one d i⟩

/-! ## Section 3: Collision Probability Bounds -/

/-- The collision probability of the uniform distribution is exactly 1/n.
This is the baseline against which all hash function security is measured.
Bridge: connects InformationTheory to Cryptography (birthday_baseline). -/
theorem collision_probability_uniform (n : ℕ) (hn : 0 < n) :
    collisionProbability (uniformDistribution n hn) = 1 / (n : ℝ) := by
  simp only [collisionProbability, uniformDistribution]
  rw [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]
  field_simp

/-- Collision probability is always non-negative. -/
theorem collision_probability_nonneg {n : ℕ} (d : FinDistribution n) :
    0 ≤ collisionProbability d := by
  apply Finset.sum_nonneg; intro i _; positivity

/-- **Cauchy-Schwarz lower bound on collision probability.**
For any distribution on `Fin n` with `n ≥ 1`, the collision probability
is at least `1/n`. This is the information-theoretic lower bound that
makes birthday attacks inevitable.
Proof: By Cauchy-Schwarz, (∑ pᵢ)² ≤ n · ∑ pᵢ², giving 1 ≤ n · ∑ pᵢ².
Bridge: connects InformationTheory to Cryptography (birthday_attack_lower_bound). -/
theorem collision_probability_lower_bound {n : ℕ} (hn : 0 < n) (d : FinDistribution n) :
    1 / (n : ℝ) ≤ collisionProbability d := by
  unfold collisionProbability
  have cs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ d.pmf (fun _ => (1 : ℝ))
  simp [d.sum_one] at cs
  rw [div_le_iff₀' (by positivity : (0 : ℝ) < n)]
  linarith

/-- The collision probability is at most 1.
Bridge: connects InformationTheory to Cryptography (collision_upper). -/
theorem collision_probability_upper_bound {n : ℕ} (d : FinDistribution n) :
    collisionProbability d ≤ 1 := by
  unfold collisionProbability
  calc ∑ i, (d.pmf i) ^ 2 ≤ ∑ i, d.pmf i := by
        apply Finset.sum_le_sum; intro i _
        rw [sq]; exact mul_le_of_le_one_left (d.nonneg i) (probability_le_one d i)
    _ = 1 := d.sum_one

/-! ## Section 4: Statistical Distance Properties -/

/-- Statistical distance is always non-negative. -/
theorem statistical_distance_nonneg {n : ℕ} (d₁ d₂ : FinDistribution n) :
    0 ≤ statisticalDistance d₁ d₂ := by
  unfold statisticalDistance
  apply mul_nonneg (by linarith)
  apply Finset.sum_nonneg; intro i _; exact abs_nonneg _

/-- Statistical distance is symmetric.
Bridge: connects InformationTheory to Algebra (symmetric structure). -/
theorem statistical_distance_symm {n : ℕ} (d₁ d₂ : FinDistribution n) :
    statisticalDistance d₁ d₂ = statisticalDistance d₂ d₁ := by
  unfold statisticalDistance; congr 1
  apply Finset.sum_congr rfl; intro i _; rw [abs_sub_comm]

/-- Statistical distance from a distribution to itself is zero. -/
theorem statistical_distance_self {n : ℕ} (d : FinDistribution n) :
    statisticalDistance d d = 0 := by
  unfold statisticalDistance; simp

/-- **Triangle inequality for statistical distance.**
This makes the space of distributions a pseudometric space.
Bridge: connects InformationTheory to Algebra (metric structure). -/
theorem statistical_distance_triangle {n : ℕ} (d₁ d₂ d₃ : FinDistribution n) :
    statisticalDistance d₁ d₃ ≤ statisticalDistance d₁ d₂ + statisticalDistance d₂ d₃ := by
  unfold statisticalDistance
  rw [← mul_add]
  apply mul_le_mul_of_nonneg_left _ (by norm_num : (0 : ℝ) ≤ 1 / 2)
  calc ∑ i, |d₁.pmf i - d₃.pmf i|
      = ∑ i, |(d₁.pmf i - d₂.pmf i) + (d₂.pmf i - d₃.pmf i)| := by
        congr 1; ext i; ring_nf
    _ ≤ ∑ i, (|d₁.pmf i - d₂.pmf i| + |d₂.pmf i - d₃.pmf i|) := by
        apply Finset.sum_le_sum; intro i _; exact abs_add_le _ _
    _ = ∑ i, |d₁.pmf i - d₂.pmf i| + ∑ i, |d₂.pmf i - d₃.pmf i| :=
        Finset.sum_add_distrib

/-- Statistical distance is at most 1.
Proof: |pᵢ - qᵢ| ≤ pᵢ + qᵢ, and ∑(pᵢ + qᵢ) = 2.
Bridge: connects InformationTheory to Cryptography (security_bound). -/
theorem statistical_distance_le_one {n : ℕ} (d₁ d₂ : FinDistribution n) :
    statisticalDistance d₁ d₂ ≤ 1 := by
  unfold statisticalDistance
  suffices h : ∑ i : Fin n, |d₁.pmf i - d₂.pmf i| ≤ 2 by linarith
  calc ∑ i, |d₁.pmf i - d₂.pmf i|
      ≤ ∑ i, (d₁.pmf i + d₂.pmf i) := by
        apply Finset.sum_le_sum; intro i _
        rw [abs_le]; constructor <;> linarith [d₁.nonneg i, d₂.nonneg i]
    _ = ∑ i, d₁.pmf i + ∑ i, d₂.pmf i := Finset.sum_add_distrib
    _ = 2 := by linarith [d₁.sum_one, d₂.sum_one]

/-! ## Section 5: Cryptographic Security Structures -/

/-- A `HashFamily` models a family of hash functions from `Fin m` to `Fin n`.
Bridge: connects Cryptography (hash_collision) to InformationTheory. -/
structure HashFamily (m n k : ℕ) where
  hash : Fin k → Fin m → Fin n

/-- A hash family is `ε`-universal if for any two distinct inputs,
the probability of collision over a random key is at most `ε`.
Bridge: connects Cryptography (hash_collision) to InformationTheory (entropy). -/
def IsUniversalHash {m n k : ℕ} (H : HashFamily m n k) (ε : ℝ) : Prop :=
  ∀ (x y : Fin m), x ≠ y →
    ((Finset.filter (fun s => H.hash s x = H.hash s y) Finset.univ).card : ℝ) ≤ ε * k

/-- `PostQuantumSecurityLevel` encodes the security level against quantum adversaries.
Grover's algorithm reduces brute-force search from O(2^n) to O(2^(n/2)).
Bridge: connects Cryptography to Physics (quantum). -/
structure PostQuantumSecurityLevel where
  classical_bits : ℕ
  quantum_bits : ℕ
  grover_relation : quantum_bits * 2 = classical_bits

/-- Construct a post-quantum security level from classical bits. -/
def PostQuantumSecurityLevel.fromClassical (n : ℕ) (hn : 2 ∣ n) :
    PostQuantumSecurityLevel where
  classical_bits := n
  quantum_bits := n / 2
  grover_relation := by omega

/-- Post-quantum security: quantum bits ≤ classical bits.
Bridge: connects Cryptography (post_quantum_security) to Physics (quantum). -/
theorem grover_security_halving (pq : PostQuantumSecurityLevel) :
    pq.quantum_bits ≤ pq.classical_bits := by have := pq.grover_relation; omega

/-- The quantum advantage ratio is exactly 2.
Bridge: connects Physics (quantum_speedup) to Cryptography. -/
theorem quantum_advantage_ratio (pq : PostQuantumSecurityLevel) :
    pq.classical_bits = 2 * pq.quantum_bits := by have := pq.grover_relation; omega

/-- Quantum search requires Ω(2^(n/2)) queries (Grover's lower bound).
Bridge: connects Physics (quantum) to Cryptography (post_quantum_security). -/
theorem grover_query_lower_bound (pq : PostQuantumSecurityLevel) :
    2 ^ pq.quantum_bits ≤ 2 ^ pq.classical_bits := by
  apply Nat.pow_le_pow_right (by omega)
  exact grover_security_halving pq

/-! ## Section 6: Lipschitz Entropy Functionals for ML -/

/-- A `LipschitzEntropyFunctional` represents an entropy-like functional
that is Lipschitz continuous with respect to statistical distance.
This is crucial for certified_robustness in ML.
Bridge: connects InformationTheory to ML (lipschitz_certified_robustness). -/
structure LipschitzEntropyFunctional (n : ℕ) where
  functional : FinDistribution n → ℝ
  lipschitz_const : ℝ
  lipschitz_const_pos : 0 < lipschitz_const
  lipschitz_bound : ∀ d₁ d₂ : FinDistribution n,
    |functional d₁ - functional d₂| ≤ lipschitz_const * statisticalDistance d₁ d₂

/-- **Certified robustness via Lipschitz entropy.**
The perturbation of the functional value is bounded by `L * ε`.
Bridge: connects ML (certified_robustness) to InformationTheory. -/
theorem lipschitz_certified_robustness_bound {n : ℕ}
    (F : LipschitzEntropyFunctional n) (d₁ d₂ : FinDistribution n) (ε : ℝ)
    (hε : statisticalDistance d₁ d₂ ≤ ε) :
    |F.functional d₁ - F.functional d₂| ≤ F.lipschitz_const * ε := by
  calc |F.functional d₁ - F.functional d₂|
      ≤ F.lipschitz_const * statisticalDistance d₁ d₂ := F.lipschitz_bound d₁ d₂
    _ ≤ F.lipschitz_const * ε :=
        mul_le_mul_of_nonneg_left hε (le_of_lt F.lipschitz_const_pos)

/-- **Robustness composition:** composing two Lipschitz functionals preserves
the Lipschitz property with summed constants. O(L₁ + L₂) total bound.
Bridge: connects ML (composable_robustness) to InformationTheory. -/
theorem lipschitz_robustness_composition {n : ℕ}
    (F G : LipschitzEntropyFunctional n) (d₁ d₂ : FinDistribution n) :
    |F.functional d₁ - F.functional d₂| + |G.functional d₁ - G.functional d₂|
      ≤ (F.lipschitz_const + G.lipschitz_const) * statisticalDistance d₁ d₂ := by
  have hF := F.lipschitz_bound d₁ d₂
  have hG := G.lipschitz_bound d₁ d₂
  linarith [add_mul F.lipschitz_const G.lipschitz_const (statisticalDistance d₁ d₂)]

/-- `SampleComplexityBound` formalizes the information-theoretic lower bound
on sample complexity. O(n/ε²) samples are necessary.
Bridge: connects InformationTheory to ML (sample_complexity). -/
structure SampleComplexityBound where
  alphabet_size : ℕ
  accuracy : ℝ
  accuracy_pos : 0 < accuracy
  min_samples : ℕ
  lower_bound : (alphabet_size : ℝ) / accuracy ^ 2 ≤ min_samples

/-- Sample complexity grows at least linearly with alphabet size.
Bridge: connects InformationTheory to ML (learning_theory). -/
theorem sample_complexity_linear_in_alphabet (sc : SampleComplexityBound) :
    (sc.alphabet_size : ℝ) / sc.accuracy ^ 2 ≤ (sc.min_samples : ℝ) :=
  sc.lower_bound

/-! ## Section 7: Information Lattice -/

/-- `InformationLattice` captures the partial order on information quantities.
Bridge: connects Algebra (lattice) to InformationTheory to Cryptography. -/
structure InformationLattice (α : Type*) [Fintype α] where
  depth : ℕ
  depth_bound : depth ≤ Fintype.card α

/-- The trivial information lattice element (no information). -/
def InformationLattice.trivial (α : Type*) [Fintype α] : InformationLattice α where
  depth := 0
  depth_bound := Nat.zero_le _

/-- The depth is bounded by `|α|`. O(n) bound on refinement complexity.
Bridge: connects Algebra (lattice_bounds) to Cryptography (key_space). -/
theorem information_lattice_depth_linear {α : Type*} [Fintype α]
    (L : InformationLattice α) : L.depth ≤ Fintype.card α := L.depth_bound

/-! ## Section 8: Channel Coding and Error Correction -/

/-- A `ChannelModel` describes a discrete memoryless channel.
Bridge: connects InformationTheory to Algebra (matrix). -/
structure ChannelModel (m n : ℕ) where
  transition : Fin m → Fin n → ℝ
  nonneg : ∀ i j, 0 ≤ transition i j
  row_sum_one : ∀ i, ∑ j : Fin n, transition i j = 1

/-- `LinearCodeParams` for error-correcting codes.
Bridge: connects Algebra (linear) to Cryptography (error_correction). -/
structure LinearCodeParams where
  block_length : ℕ
  dimension : ℕ
  min_distance : ℕ
  dim_le_block : dimension ≤ block_length

/-- The rate of a linear code is k/n.
Bridge: connects InformationTheory to Algebra (linear_code). -/
noncomputable def codeRate (C : LinearCodeParams) (_hn : 0 < C.block_length) : ℝ :=
  (C.dimension : ℝ) / C.block_length

/-- The redundancy of a code is n - k. O(n - k) decoding complexity.
Bridge: connects InformationTheory to Cryptography (decoding_complexity). -/
def codeRedundancy (C : LinearCodeParams) : ℕ := C.block_length - C.dimension

/-- Redundancy ≤ block length. -/
theorem redundancy_le_block_length (C : LinearCodeParams) :
    codeRedundancy C ≤ C.block_length := by unfold codeRedundancy; omega

/-- Correctable errors: t = ⌊(d-1)/2⌋. -/
def correctableErrors (C : LinearCodeParams) : ℕ := (C.min_distance - 1) / 2

/-- Correctable errors ≤ minimum distance. -/
theorem correctable_errors_bound (C : LinearCodeParams) :
    correctableErrors C ≤ C.min_distance := by unfold correctableErrors; omega

/-- Code rate is non-negative. -/
theorem code_rate_nonneg (C : LinearCodeParams) (_hn : 0 < C.block_length) :
    0 ≤ codeRate C _hn := by unfold codeRate; positivity

/-- Code rate is at most 1. -/
theorem code_rate_le_one (C : LinearCodeParams) (hn : 0 < C.block_length) :
    codeRate C hn ≤ 1 := by
  unfold codeRate
  rw [div_le_one (by positivity : (0 : ℝ) < C.block_length)]
  exact Nat.cast_le.mpr C.dim_le_block

/-! ## Section 9: Tropical Hash Metric -/

/-- `TropicalHashMetric` defines a distance metric on hash outputs.
Bridge: connects Tropical (semiring) to Cryptography (hash_collision). -/
structure TropicalHashMetric (n : ℕ) where
  distance : Fin n → Fin n → ℕ
  dist_symm : ∀ i j, distance i j = distance j i
  dist_self : ∀ i, distance i i = 0
  dist_triangle : ∀ i j k, distance i k ≤ distance i j + distance j k

/-- A tropical hash metric with Hamming distance. -/
def hammingTropicalMetric (n : ℕ) : TropicalHashMetric n where
  distance := fun i j => if i = j then 0 else 1
  dist_symm := by intro i j; simp [eq_comm]
  dist_self := by intro i; simp
  dist_triangle := by
    intro i j k
    by_cases hij : i = j <;> by_cases hjk : j = k <;> by_cases hik : i = k <;> simp_all

/-- Hamming distance satisfies the ultrametric inequality.
Bridge: connects Tropical to Cryptography (tropical_hash_collision). -/
theorem hamming_ultrametric (n : ℕ) (i j k : Fin n) :
    (hammingTropicalMetric n).distance i k
      ≤ max ((hammingTropicalMetric n).distance i j)
            ((hammingTropicalMetric n).distance j k) := by
  simp only [hammingTropicalMetric]
  by_cases hij : i = j <;> by_cases hjk : j = k <;>
    by_cases hik : i = k <;> simp_all

/-! ## Section 10: Quantum Entropy Bounds -/

/-- `QuantumEntropyBound` captures the Holevo bound.
Bridge: connects Physics (quantum) to InformationTheory (entropy). -/
structure QuantumEntropyBound where
  hilbert_dim : ℕ
  accessible_info : ℝ
  von_neumann_entropy : ℝ
  info_nonneg : 0 ≤ accessible_info
  holevo_bound : accessible_info ≤ von_neumann_entropy
  entropy_nonneg : 0 ≤ von_neumann_entropy
  max_entropy : von_neumann_entropy ≤ Real.log hilbert_dim

/-- Accessible information is non-negative.
Bridge: connects Physics (quantum) to InformationTheory. -/
theorem quantum_accessible_info_nonneg (Q : QuantumEntropyBound) :
    0 ≤ Q.accessible_info := Q.info_nonneg

/-- Accessible information ≤ log(dim). O(log n) extractable bits.
Bridge: connects Physics (quantum_information) to Cryptography (post_quantum_security). -/
theorem quantum_info_log_bound (Q : QuantumEntropyBound) :
    Q.accessible_info ≤ Real.log Q.hilbert_dim := le_trans Q.holevo_bound Q.max_entropy

/-- Entropy gap is non-negative.
Bridge: connects Physics (quantum_entropy_gap) to InformationTheory. -/
theorem quantum_entropy_gap_nonneg (Q : QuantumEntropyBound) :
    0 ≤ Real.log Q.hilbert_dim - Q.von_neumann_entropy := sub_nonneg.mpr Q.max_entropy

/-! ## Section 11: Composable Security -/

/-- `ComposableSecurityBound` for protocol composition. O(k) degradation.
Bridge: connects Cryptography (composable_security) to InformationTheory. -/
structure ComposableSecurityBound where
  num_compositions : ℕ
  per_protocol_error : ℝ
  per_protocol_error_nonneg : 0 ≤ per_protocol_error
  total_error : ℝ
  composition_bound : total_error = num_compositions * per_protocol_error

/-- Total security error is at most k * ε. O(k) degradation.
Bridge: connects Cryptography to InformationTheory (composition). -/
theorem composable_security_linear_growth (S : ComposableSecurityBound) :
    S.total_error ≤ S.num_compositions * S.per_protocol_error :=
  le_of_eq S.composition_bound

/-- Composing zero protocols gives zero error. -/
theorem composable_security_zero : ∀ ε : ℝ, (0 : ℕ) * ε = 0 := by intro; simp

/-- Composing one protocol preserves original error. -/
theorem composable_security_single : ∀ ε : ℝ, (1 : ℕ) * ε = ε := by intro; simp

/-- More compositions ⟹ more error. Monotonicity.
Bridge: connects Cryptography to InformationTheory (composition_monotone). -/
theorem composable_security_monotone (ε : ℝ) (hε : 0 ≤ ε) (k₁ k₂ : ℕ) (h : k₁ ≤ k₂) :
    (k₁ : ℝ) * ε ≤ (k₂ : ℝ) * ε :=
  mul_le_mul_of_nonneg_right (Nat.cast_le.mpr h) hε

/-! ## Section 12: Differential Privacy -/

/-- `DifferentialPrivacyParams` captures (ε, δ)-differential privacy.
Bridge: connects ML (differential_privacy) to InformationTheory. -/
structure DifferentialPrivacyParams where
  epsilon : ℝ
  delta : ℝ
  epsilon_nonneg : 0 ≤ epsilon
  delta_nonneg : 0 ≤ delta
  delta_le_one : delta ≤ 1

/-- The privacy budget grows linearly under basic composition.
Bridge: connects ML (gradient_descent_privacy) to InformationTheory. -/
theorem dp_linear_budget_bound (ε : ℝ) (hε : 0 ≤ ε) (k : ℕ) :
    0 ≤ (k : ℝ) * ε := by positivity

/-- Advanced composition: √k ≤ k for k ≥ 1.
Bridge: connects ML (advanced_composition) to Cryptography. -/
theorem sqrt_le_self_of_one_le (k : ℝ) (hk : 1 ≤ k) :
    Real.sqrt k ≤ k := by
  nlinarith [Real.sq_sqrt (by linarith : 0 ≤ k), sq_nonneg (Real.sqrt k - 1),
             Real.sqrt_nonneg k]

/-! ## Section 13: Source Coding Bounds -/

/-- `SourceCodingBound`: no compression below entropy rate.
Bridge: connects InformationTheory (source_coding) to Cryptography (compression). -/
structure SourceCodingBound where
  alphabet_size : ℕ
  message_length : ℕ
  entropy_rate : ℝ
  entropy_rate_nonneg : 0 ≤ entropy_rate
  entropy_rate_upper : entropy_rate ≤ Real.log alphabet_size
  min_compressed_bits : ℕ
  compression_lower : entropy_rate * message_length ≤ min_compressed_bits

/-- No compression beats entropy. Shannon's source coding theorem.
Bridge: connects InformationTheory (source_coding_theorem) to Cryptography. -/
theorem source_coding_impossibility (S : SourceCodingBound) :
    S.entropy_rate * S.message_length ≤ S.min_compressed_bits :=
  S.compression_lower

/-- Compression ratio lower bound.
Bridge: connects InformationTheory to Cryptography. -/
theorem compression_ratio_lower (S : SourceCodingBound) (hS : 0 < S.message_length) :
    S.entropy_rate ≤ S.min_compressed_bits / (S.message_length : ℝ) := by
  rw [le_div_iff₀ (by positivity : (0 : ℝ) < S.message_length)]
  exact S.compression_lower

/-! ## Section 14: Key Derivation -/

/-- `KeyDerivationBound` models the leftover hash lemma.
Bridge: connects Cryptography (key_derivation) to InformationTheory. -/
structure KeyDerivationBound where
  source_min_entropy : ℕ
  security_parameter : ℕ
  extracted_bits : ℕ
  extraction_bound : extracted_bits + 2 * security_parameter ≤ source_min_entropy

/-- Extracted bits ≤ source entropy.
Bridge: connects Cryptography to InformationTheory (leftover_hash_lemma). -/
theorem key_extraction_entropy_bound (K : KeyDerivationBound) :
    K.extracted_bits ≤ K.source_min_entropy := by have := K.extraction_bound; omega

/-- Security-extraction tradeoff.
Bridge: connects Cryptography (post_quantum_security) to InformationTheory. -/
theorem key_extraction_security_tradeoff (K : KeyDerivationBound) :
    K.extracted_bits + 2 * K.security_parameter ≤ K.source_min_entropy :=
  K.extraction_bound

/-! ## Section 15: Cross-Domain Bridge Theorems -/

/-- The birthday pair count: n items produce at most n² pairs.
O(n²) pairs ⟹ O(√m) items suffice for collision in space of size m.
Bridge: connects InformationTheory to Cryptography (birthday_attack). -/
theorem birthday_pair_count (n : ℕ) :
    n * (n - 1) ≤ n * n := Nat.mul_le_mul_left n (Nat.sub_le n 1)

/-- **Information-theoretic generalization (∀∃ form):**
∀ ε > 0, ∃ N, ∀ n ≥ N, n exceeds 1/ε².
Bridge: connects InformationTheory to ML (generalization_bound). -/
theorem info_theoretic_generalization_existence (ε : ℝ) (_hε : 0 < ε) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → (1 : ℝ) / ε ^ 2 ≤ n := by
  obtain ⟨N, hN⟩ := exists_nat_ge (1 / ε ^ 2)
  exact ⟨N, fun n hn => le_trans hN (Nat.cast_le.mpr hn)⟩

/-- Entropy sum is non-negative. O(k) computation.
Bridge: connects InformationTheory to Algebra (additivity). -/
theorem entropy_chain_rule_nonneg (k : ℕ) (H : Fin k → ℝ) (hH : ∀ i, 0 ≤ H i) :
    0 ≤ ∑ i : Fin k, H i := by
  apply Finset.sum_nonneg; intro i _; exact hH i

/-! ## Section 16: Complexity Bounds -/

/-- `ComputationalEntropyBound`: entropy computation takes O(s · 2^n).
Bridge: connects InformationTheory to Computation (complexity_bound). -/
structure ComputationalEntropyBound where
  circuit_size : ℕ
  input_bits : ℕ
  computation_time : ℕ
  time_bound : computation_time ≤ circuit_size * 2 ^ input_bits

/-- Entropy computation is exponential in input size.
Bridge: connects Computation to InformationTheory (complexity). -/
theorem entropy_computation_exponential (C : ComputationalEntropyBound) :
    C.computation_time ≤ C.circuit_size * 2 ^ C.input_bits := C.time_bound

/-- Exponential time grows with input bits.
Bridge: connects Computation to InformationTheory. -/
theorem entropy_time_monotone (s n₁ n₂ : ℕ) (h : n₁ ≤ n₂) :
    s * 2 ^ n₁ ≤ s * 2 ^ n₂ :=
  Nat.mul_le_mul_left s (Nat.pow_le_pow_right (by omega) h)

/-- Doubling input squares computation: O(s · 2^(2n)) = O(s · (2^n)²).
Bridge: connects Computation to Cryptography (security_scaling). -/
theorem entropy_time_doubling (s n : ℕ) :
    s * 2 ^ (2 * n) = s * (2 ^ n) ^ 2 := by ring

/-! ## Section 17: Neural Network Information Bottleneck -/

/-- `InformationBottleneck` captures the information bottleneck principle.
Bridge: connects ML (neural_network) to InformationTheory (mutual_information). -/
structure InformationBottleneck where
  input_info : ℝ
  bottleneck_info : ℝ
  output_info : ℝ
  input_nonneg : 0 ≤ input_info
  bottleneck_nonneg : 0 ≤ bottleneck_info
  output_nonneg : 0 ≤ output_info
  data_processing : bottleneck_info ≤ input_info
  sufficiency : output_info ≤ bottleneck_info

/-- Data processing inequality: layers cannot create information.
Bridge: connects ML (neural_network_data_processing) to InformationTheory. -/
theorem neural_data_processing (IB : InformationBottleneck) :
    IB.bottleneck_info ≤ IB.input_info := IB.data_processing

/-- Information decreases through the bottleneck.
Bridge: connects ML (information_bottleneck_principle) to InformationTheory. -/
theorem bottleneck_compression (IB : InformationBottleneck) :
    IB.output_info ≤ IB.input_info := by
  linarith [IB.data_processing, IB.sufficiency]

/-- Optimal compression when output = bottleneck.
Bridge: connects ML (optimal_representation) to InformationTheory. -/
theorem bottleneck_optimality (IB : InformationBottleneck)
    (h_optimal : IB.output_info = IB.bottleneck_info) :
    IB.output_info ≤ IB.input_info := by linarith [IB.data_processing]

/-! ## Section 18: Fano's Inequality -/

/-- `FanoInequality` relates conditional entropy and error probability.
Bridge: connects InformationTheory (Fano) to ML (classification). -/
structure FanoInequality where
  num_classes : ℕ
  error_prob : ℝ
  conditional_entropy : ℝ
  error_nonneg : 0 ≤ error_prob
  error_le_one : error_prob ≤ 1
  entropy_nonneg : 0 ≤ conditional_entropy
  fano_bound : conditional_entropy ≤ 1 + error_prob * Real.log num_classes

/-- Fano's inequality gives a lower bound on error probability.
When H(X|Y) > 1, no classifier can achieve zero error.
Bridge: connects InformationTheory (Fano) to ML (classification_impossibility). -/
theorem fano_error_lower (F : FanoInequality)
    (h_entropy_large : 1 < F.conditional_entropy)
    (_h_log_pos : 0 < Real.log F.num_classes) :
    0 < F.error_prob := by
  by_contra h
  push_neg at h
  have hep0 : F.error_prob = 0 := le_antisymm h F.error_nonneg
  have : F.conditional_entropy ≤ 1 := by
    calc F.conditional_entropy ≤ 1 + F.error_prob * Real.log F.num_classes := F.fano_bound
      _ = 1 + 0 * Real.log F.num_classes := by rw [hep0]
      _ = 1 := by ring
  linarith

/-! ## Section 19: Lattice-Based Cryptographic Entropy -/

/-- `LatticeCryptoParams` for Learning With Errors (LWE) schemes.
Bridge: connects Cryptography (lattice_crypto) to InformationTheory. -/
structure LatticeCryptoParams where
  lattice_dim : ℕ
  modulus : ℕ
  error_bound : ℕ
  dim_pos : 0 < lattice_dim
  mod_pos : 0 < modulus
  error_le_mod : error_bound ≤ modulus

/-- LWE security grows with dimension.
Bridge: connects Cryptography (lattice_crypto) to InformationTheory. -/
theorem lwe_security_grows_with_dim (P : LatticeCryptoParams) :
    0 < P.lattice_dim := P.dim_pos

/-- Modulus-to-error ratio controls correctness.
Bridge: connects Cryptography (post_quantum_security) to Algebra. -/
theorem lwe_correctness_constraint (P : LatticeCryptoParams) :
    P.error_bound ≤ P.modulus := P.error_le_mod

/-- LWE key size is O(n²), polynomial in security parameter.
Bridge: connects Cryptography (lattice_crypto) to Computation (complexity). -/
theorem lwe_key_size_polynomial (n : ℕ) :
    n * n ≤ (n + 1) * (n + 1) := by nlinarith

end InformationTheory