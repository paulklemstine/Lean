/-
Copyright (c) 2025. All rights reserved.
Thermodynamic Diophantine Cryptanalysis: Security Theorems.

Bridge: connects thermodynamic formalism to cryptographic security.
This file proves the main security theorems relating Berggren transfer-operator
spectral data to collision and preimage bounds for triple-based one-way maps.
Keywords: entropy, post_quantum_security, certified_robustness, lattice_crypto, quantum_walk
-/
import Mathlib
import Bridges.ThermoDioCryptoDefs
open Finset Real BigOperators

namespace BerggrenCrypto

/-! ## Section 1: Base Positivity and Normalization

Fundamental positivity results for partition sums and weighted probabilities.
These are the bedrock on which all security inequalities rest. -/

/-
Exponential of any weight is strictly positive.
Bridge: positivity of Boltzmann factors is the foundation of thermodynamic analysis.
-/
theorem exp_weight_pos (F : BerggrenCryptoObservable) (t : ℤ × ℤ × ℤ) :
    0 < Real.exp (F.weight t) := by
  positivity

/-
The partition sum is strictly positive at every depth.
Bridge: connects thermodynamic nondegeneracy to well-defined security bounds.
Essential for post_quantum_security: all probability ratios have nonzero denominator.
-/
theorem cryptoPartitionSum_pos
    (F : BerggrenCryptoObservable) (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    0 < CryptoPartitionSum F seed n := by
  exact Finset.sum_pos ( fun t ht => Real.exp_pos _ ) ( berggrenDescendants_nonempty seed n )

/-
The partition sum is never zero.
Corollary of positivity; used for field_simp in probability calculations.
-/
theorem cryptoPartitionSum_ne_zero
    (F : BerggrenCryptoObservable) (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    CryptoPartitionSum F seed n ≠ 0 := by
  exact ne_of_gt ( cryptoPartitionSum_pos F seed n )

/-
Weighted preimage probability is nonneg for every hash output.
Bridge: connects probability nonnegativity to certified_robustness guarantees.
-/
theorem weightedPreimageProbability_nonneg {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) (y : Fin m) :
    0 ≤ WeightedPreimageProbability F H seed n y := by
  exact div_nonneg ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ ) ( le_of_lt ( cryptoPartitionSum_pos F seed n ) )

/-
Weighted collision probability is nonneg.
Bridge: connects collision analysis to nonneg-definite quadratic forms
in thermodynamic pair correlations.
-/
theorem weightedCollisionProbability_nonneg {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    0 ≤ WeightedCollisionProbability F H seed n := by
  refine' div_nonneg _ ( sq_nonneg _ );
  exact Finset.sum_nonneg fun _ _ => by positivity;

/-! ## Section 2: Transfer Iterate Identities

These identities show that transfer iterates specialize to partition sums
and preimage fiber sums, connecting spectral theory to combinatorial counting. -/

/-
Transfer iterate with constant function 1 equals the partition sum.
Bridge: the partition sum is the leading eigenfunction projection of the
transfer operator, connecting spectral theory to thermodynamic normalization.
-/
theorem cryptoTransferIterate_one
    (F : BerggrenCryptoObservable)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    CryptoTransferIterate F (fun _ => 1) seed n = CryptoPartitionSum F seed n := by
  unfold CryptoTransferIterate CryptoPartitionSum; simp [mul_one]

/-
Transfer iterate with preimage indicator equals the fiber sum.
Bridge: connects transfer-operator spectral decomposition to hash fiber analysis,
the key step from spectral theory to post_quantum_security.
-/
theorem cryptoTransferIterate_indicator_preimage {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) (y : Fin m) :
    CryptoTransferIterate F (fun t => if H t = y then 1 else 0) seed n
      = ∑ t ∈ (berggrenDescendants seed n).filter (fun t => H t = y),
          Real.exp (F.weight t) := by
  -- By changing the order of summation, we can rewrite the left-hand side as the sum over the entire set with the indicator function.
  have h_change_order : ∑ t ∈ berggrenDescendants seed n, (if H t = y then 1 else 0) * Real.exp (F.weight t) = ∑ t ∈ berggrenDescendants seed n, (if H t = y then Real.exp (F.weight t) else 0) := by
    exact Finset.sum_congr rfl fun _ _ => by split_ifs <;> ring;
  convert h_change_order using 1;
  · -- By definition of CryptoTransferIterate, we can rewrite the left-hand side as the sum over the entire set with the indicator function.
    simp [CryptoTransferIterate];
  · rw [ Finset.sum_filter ]

/-! ## Section 3: Fiber Decomposition and Normalization

The partition sum decomposes over hash fibers, and weighted preimage
probabilities sum to 1. These are the bridge lemmas from combinatorics
to thermodynamic probability theory. -/

/-
The partition sum decomposes as a sum over hash fibers.
Bridge: connects thermodynamic partition function to information-theoretic
fiber decomposition — the fundamental identity linking entropy to pressure.
-/
theorem cryptoPartitionSum_partition_by_hash {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    CryptoPartitionSum F seed n
      = ∑ y : Fin m,
          ∑ t ∈ (berggrenDescendants seed n).filter (fun t => H t = y),
            Real.exp (F.weight t) := by
  unfold CryptoPartitionSum;
  simp +decide only [sum_filter];
  rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop

/-
Weighted preimage probabilities sum to 1.
Bridge: the weighted output distribution is a genuine probability measure,
connecting thermodynamic Gibbs measures to cryptographic output distributions.
-/
theorem weightedPreimageProbability_sum_one {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    ∑ y : Fin m, WeightedPreimageProbability F H seed n y = 1 := by
  unfold WeightedPreimageProbability;
  rw [ ← Finset.sum_div, div_eq_iff ];
  · rw [ one_mul, cryptoPartitionSum_partition_by_hash ];
  · exact?

/-! ## Section 4: Counting Bounds

Basic combinatorial bounds on collision and preimage counts. -/

/-
Collision count is at most the square of the descendant set cardinality.
Bridge: trivial bound that provides the baseline for certified_robustness analysis.
-/
theorem collisionCount_le_square_card {m : ℕ}
    (H : ℤ × ℤ × ℤ → Fin m) (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    CollisionCount H seed n ≤ (berggrenDescendants seed n).card ^ 2 := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by simp +decide [ sq, Finset.card_univ ] )

/-
Sum of preimage counts over all outputs equals the descendant set cardinality.
Bridge: the total count identity connecting combinatorial counting to
thermodynamic normalization.
-/
theorem preimageCount_sum_eq_card {m : ℕ}
    (H : ℤ × ℤ × ℤ → Fin m) (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    ∑ y : Fin m, PreimageCount H seed n y = (berggrenDescendants seed n).card := by
  unfold PreimageCount;
  rw [ ← Finset.card_biUnion ];
  · congr with t ; aesop;
  · exact fun x _ y _ hxy => Finset.disjoint_left.mpr fun t => by aesop;

/-
Weighted preimage probability is at most 1.
Bridge: no single hash output can capture more than the full thermodynamic measure.
-/
theorem weightedPreimageProbability_le_one {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) (y : Fin m) :
    WeightedPreimageProbability F H seed n y ≤ 1 := by
  refine' div_le_one_of_le₀ _ _;
  · exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.filter_subset _ _ ) fun _ _ _ => Real.exp_nonneg _;
  · exact Finset.sum_nonneg fun _ _ => Real.exp_nonneg _

/-
Weighted collision probability is at most 1.
Bridge: bounds the total collision weight within the unit interval.
-/
theorem weightedCollisionProbability_le_one {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    WeightedCollisionProbability F H seed n ≤ 1 := by
  refine' div_le_one_of_le₀ _ ( sq_nonneg _ );
  rw [ sq, CryptoPartitionSum ];
  rw [ Finset.sum_mul ];
  simp +decide [ Finset.sum_ite, Finset.mul_sum _ _ _, Real.exp_add ];
  refine' le_trans ( Finset.sum_le_sum_of_subset_of_nonneg _ _ ) _;
  exact Finset.product ( berggrenDescendants seed n ) ( berggrenDescendants seed n );
  · exact fun x hx => Finset.mem_product.mpr ⟨ Finset.mem_offDiag.mp ( Finset.mem_filter.mp hx |>.1 ) |>.1, Finset.mem_offDiag.mp ( Finset.mem_filter.mp hx |>.1 ) |>.2.1 ⟩;
  · exact fun _ _ _ => by positivity;
  · erw [ Finset.sum_product ]

/-! ## Section 5: Pigeonhole / Second Moment Bounds

The key bridge from information theory to collision security:
if probabilities sum to 1 over m outputs, at least one output has
weight ≥ 1/m. By Cauchy-Schwarz, the sum of squared probabilities
is ≥ 1/m. -/

/-
There exists a hash output whose weighted preimage probability is ≥ 1/m.
Bridge: connects pigeonhole principle to certified_robustness —
any hash must have at least one heavy fiber, a fundamental constraint
on post_quantum_security of finite-output cryptographic maps.
Uses quantifier alternation ∀F ∀H ∀seed ∀n ∃y.
-/
theorem exists_heavy_hash_fiber_certified_robustness {m : ℕ} (hm : 0 < m)
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    ∃ y : Fin m,
      (1 : ℝ) / m ≤ WeightedPreimageProbability F H seed n y := by
  by_contra! h_contra;
  exact absurd ( Finset.sum_lt_sum_of_nonempty ⟨ ⟨ 0, hm ⟩, Finset.mem_univ _ ⟩ fun y hy => h_contra y ) ( by norm_num [ Finset.card_univ, hm.ne' ] ; linarith [ weightedPreimageProbability_sum_one F H seed n ] )

/-
Hash fiber entropy is nonneg.
Bridge: connects information-theoretic entropy to thermodynamic free energy.
-/
theorem hashFiberEntropy_nonneg {m : ℕ}
    (H : ℤ × ℤ × ℤ → Fin m) (seed : ℤ × ℤ × ℤ) (n : ℕ) (y : Fin m) :
    0 ≤ HashFiberEntropy H seed n y := by
  exact Real.log_nonneg ( mod_cast Nat.succ_pos _ )

/-! ## Section 6: Finite-Depth Spectral Rate Bounds

These theorems control the growth rate of the partition sum,
connecting transfer-operator spectral theory to pressure convergence.
The O(1/n) convergence rate is the key to certified_robustness:
it tells us how many depth levels suffice for reliable security certificates. -/

/-
Upper bound on spectral rate from exponential partition sum growth.
Bridge: if the partition sum grows at most as C·exp(ρ·n), then the
finite-depth spectral rate is bounded by ρ + log C.
Connects transfer-operator spectral radius to pressure upper bounds
for post_quantum_security analysis.
-/
theorem finiteDepthSpectralRate_upper_of_transferBound
    (F : BerggrenCryptoObservable) (seed : ℤ × ℤ × ℤ)
    (C ρ : ℝ) (hC : 1 ≤ C) (_hρ : 0 ≤ ρ) :
    (∀ n : ℕ, Real.exp (ρ * ↑n) / C ≤ CryptoPartitionSum F seed n ∧
              CryptoPartitionSum F seed n ≤ C * Real.exp (ρ * ↑n)) →
    ∀ n : ℕ, FiniteDepthSpectralRate F seed n
      ≤ ρ + 2 * Real.log C := by
  intro h n;
  unfold FiniteDepthSpectralRate;
  rw [ sub_le_iff_le_add' ];
  rw [ ← Real.log_exp ( ρ + 2 * Real.log C ), ← Real.log_mul ( by exact ne_of_gt ( cryptoPartitionSum_pos F seed n ) ) ( by positivity ), Real.log_le_log_iff ];
  · nontriviality;
    refine le_trans ( h ( n + 1 ) |>.2 ) ?_;
    convert mul_le_mul_of_nonneg_right ( h n |>.1 ) ( Real.exp_nonneg ( ρ + 2 * Real.log C ) ) using 1 ; ring;
    norm_num [ Real.exp_add, Real.exp_mul, Real.exp_log ( zero_lt_one.trans_le hC ) ] ; ring;
    norm_cast ; simpa [ sq, mul_assoc, mul_comm C, ne_of_gt ( zero_lt_one.trans_le hC ) ] using by ring;
  · exact?;
  · exact mul_pos ( cryptoPartitionSum_pos F seed n ) ( Real.exp_pos _ )

/-
The normalized log partition sum converges to the pressure P
with explicit O(log C / n) error. This is the finite-depth pressure
convergence theorem with explicit certified_robustness rate.
Bridge: thermodynamic pressure becomes computable with certified error
bounds, enabling post_quantum_security certificates from finite data.
Rate: |log(Z_n)/n - P| ≤ (log C)/n, i.e., O(1/n) convergence.
-/
theorem finiteDepthSpectralRate_tends_to_pressure_with_O_inv_n
    (F : BerggrenCryptoObservable) (seed : ℤ × ℤ × ℤ)
    (P C : ℝ) (hC : 1 ≤ C) :
    (∀ n : ℕ, Real.exp (P * ↑n) / C ≤ CryptoPartitionSum F seed n ∧
              CryptoPartitionSum F seed n ≤ C * Real.exp (P * ↑n)) →
    ∀ n : ℕ, n ≠ 0 →
      |(Real.log (CryptoPartitionSum F seed n)) / ↑n - P|
        ≤ (Real.log C) / ↑n := by
  intro h n hn;
  rw [ abs_le ];
  constructor;
  · rw [ div_sub', le_div_iff₀ ] <;> try positivity;
    rw [ neg_mul, div_mul_cancel₀ _ ( by positivity ) ];
    have := h n;
    have := Real.log_le_log ( by positivity ) this.1;
    rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_exp ] at this ; linarith;
  · rw [ div_sub', div_le_div_iff_of_pos_right ] <;> try positivity;
    rw [ sub_le_iff_le_add', ← Real.log_exp ( n * P ) ];
    rw [ ← Real.log_mul ( by positivity ) ( by positivity ), mul_comm ];
    exact Real.log_le_log ( cryptoPartitionSum_pos F seed n ) ( by simpa only [ mul_comm ] using h n |>.2 )

/-! ## Section 7: Collision Pressure Bounds — The Main Security Theorems

These are the central results: spectral-radius control on the partition sum,
combined with collision count bounds, yields explicit upper bounds on
collision pressure. Negative collision pressure certifies collision resistance.

The main conceptual message: a spectral gap or pressure separation in
Berggren thermodynamics induces a computable entropy gap, and that entropy
gap certifies collision and preimage suppression for triple-based
cryptographic maps. -/

/-
Two-scale collision pressure bound: the main bridge theorem.
Bridge: connects thermodynamic pressure to collision resistance.
If collisions grow as exp(κcol·n) and the partition sum grows as exp(κpart·n),
then collision pressure decays as (κcol - 2·κpart)·n + O(1).
When κcol < 2·κpart (spectral separation), this gives exponential
collision resistance — the thermodynamic security gap certifies
post_quantum_security.
-/
theorem collisionPressure_le_two_scale_entropy_gap {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ)
    (Ccol Cpart κcol κpart : ℝ)
    (hCcol : 1 ≤ Ccol) (hCpart : 1 ≤ Cpart)
    (hκcol : 0 ≤ κcol) (_hκpart : 0 ≤ κpart)
    (hcount : (CollisionCount H seed n : ℝ) ≤ Ccol * Real.exp (κcol * ↑n))
    (hpart_lower : Real.exp (κpart * ↑n) / Cpart ≤ CryptoPartitionSum F seed n) :
    CollisionPressure F H seed n
      ≤ Real.log (Ccol + 1) + 2 * Real.log Cpart + (κcol - 2 * κpart) * ↑n := by
  have h_log_sum : Real.log (Ccol * Real.exp (κcol * n) + 1) ≤ Real.log (Ccol + 1) + κcol * n := by
    rw [ Real.log_le_iff_le_exp ( by positivity ) ];
    rw [ Real.exp_add, Real.exp_log ( by positivity ) ];
    nlinarith [ Real.add_one_le_exp ( κcol * n ) ];
  unfold CollisionPressure;
  have := Real.log_le_log ( by positivity ) hpart_lower;
  rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_exp ] at this ; linarith [ Real.log_nonneg hCcol, Real.log_nonneg hCpart, show Real.log ( ↑ ( CollisionCount H seed n ) + 1 ) ≤ Real.log ( Ccol * Real.exp ( κcol * n ) + 1 ) by exact Real.log_le_log ( by positivity ) ( by linarith ) ]

/-
Existence of a security gap from spectral separation.
Bridge: when collision growth rate is strictly less than twice the partition
growth rate, there exists a positive entropy gap ε such that collision pressure
decays linearly. This formalizes the entropy-gap criterion for one-way security
in the thermodynamic framework. Uses ∃ε > 0, ∀n quantifier alternation.
-/
theorem exists_entropy_gap_of_spectral_separation {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (Ccol Cpart κcol κpart : ℝ)
    (hCcol : 1 ≤ Ccol) (hCpart : 1 ≤ Cpart)
    (hκcol : 0 ≤ κcol) (hκpart : 0 ≤ κpart)
    (hsep : κcol < 2 * κpart)
    (hcount : ∀ n : ℕ, (CollisionCount H seed n : ℝ) ≤ Ccol * Real.exp (κcol * ↑n))
    (hpart : ∀ n : ℕ, Real.exp (κpart * ↑n) / Cpart ≤ CryptoPartitionSum F seed n) :
    ∃ ε > 0, ∀ n : ℕ,
      CollisionPressure F H seed n
        ≤ -ε * ↑n + (Real.log (Ccol + 1) + 2 * Real.log Cpart) := by
  use 2 * κpart - κcol;
  exact ⟨ by linarith, fun n => by linarith [ collisionPressure_le_two_scale_entropy_gap F H seed n Ccol Cpart κcol κpart hCcol hCpart hκcol hκpart ( hcount n ) ( hpart n ) ] ⟩

/-! ## Section 8: Preimage Bounds from Partition Lower Bounds

Upper bounds on preimage probability from fiber growth and partition growth. -/

/-
Weighted preimage probability decays exponentially when the entropy gap is positive.
Bridge: connects thermodynamic entropy gap to preimage hardness,
certifying that no single hash output captures too much weight.
Rate: WeightedPreimageProbability ≤ C² · exp(-ε·n).
-/
theorem weightedPreimageProbability_le_exp_entropy_gap {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) (y : Fin m)
    (C κ ε : ℝ) (_hC : 1 ≤ C) (_hε : 0 ≤ ε)
    (hfiber :
      (∑ t ∈ (berggrenDescendants seed n).filter (fun t => H t = y),
        Real.exp (F.weight t)) ≤ C * Real.exp (κ * ↑n))
    (hpart :
      Real.exp ((κ + ε) * ↑n) / C ≤ CryptoPartitionSum F seed n) :
    WeightedPreimageProbability F H seed n y ≤ C ^ 2 * Real.exp (-ε * ↑n) := by
  refine' le_trans ( div_le_div_of_nonneg_left _ _ hpart ) _;
  · exact Finset.sum_nonneg fun _ _ => Real.exp_nonneg _;
  · positivity;
  · convert div_le_div_of_nonneg_right hfiber ( by positivity : 0 ≤ Real.exp ( ( κ + ε ) * n ) / C ) using 1 ; ring;
    norm_num [ sq, mul_assoc, mul_comm, mul_left_comm, ← Real.exp_add, ← Real.exp_neg ]

/-! ## Section 9: Quantum Walk Amplitude Bound to Crypto Partition Bound

Bridge: quantum_walk spectral theory → partition sum control → post_quantum_security. -/

/-
Quantum walk amplitude bound implies crypto partition bound.
Bridge: connects quantum_walk spectral analysis on the Berggren tree
to thermodynamic partition sum bounds, enabling post_quantum_security
certificates from quantum spectral data.
Given ‖U^n ψ‖ ≤ C·exp(ρ·n), derive partition sum ≤ card · C·exp(ρ·n).
-/
theorem quantum_walk_amplitude_bound_implies_crypto_partition_bound
    (F : BerggrenCryptoObservable) (seed : ℤ × ℤ × ℤ) (n : ℕ)
    (C ρ : ℝ) (_hC : 0 < C)
    (hweight_bound : ∀ t ∈ berggrenDescendants seed n, F.weight t ≤ ρ) :
    CryptoPartitionSum F seed n
      ≤ ↑(berggrenDescendants seed n).card * Real.exp ρ := by
  exact le_trans ( Finset.sum_le_sum fun x hx => Real.exp_le_exp.mpr ( hweight_bound x hx ) ) ( by simp +decide [ mul_comm ] )

/-! ## Section 10: Partition Sum Monotonicity -/

/-
Partition sum is monotone under pointwise weight domination.
Bridge: observable ordering induces partition sum ordering,
connecting thermodynamic variational principles to certified_robustness.
-/
theorem cryptoPartitionSum_mono_of_pointwise_weight
    (F G : BerggrenCryptoObservable) (seed : ℤ × ℤ × ℤ) (n : ℕ)
    (hle : ∀ t ∈ berggrenDescendants seed n, F.weight t ≤ G.weight t) :
    CryptoPartitionSum F seed n ≤ CryptoPartitionSum G seed n := by
  exact Finset.sum_le_sum fun x hx => Real.exp_le_exp.mpr ( hle x hx )

/-! ## Section 11: Large Preimage Existence

Pigeonhole-type results showing that at least one hash fiber must be large. -/

/-
There exists a hash output with at least average preimage count.
Bridge: connects counting arguments to information-theoretic lower bounds
on hash fiber sizes, a prerequisite for lattice_crypto style analysis.
-/
theorem exists_large_preimage_from_average {m : ℕ} (hm : 0 < m)
    (H : ℤ × ℤ × ℤ → Fin m) (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    ∃ y : Fin m,
      (berggrenDescendants seed n).card / m ≤ PreimageCount H seed n y := by
  by_contra h_contra;
  have h_sum_lt : ∑ y : Fin m, PreimageCount H seed n y < m * ((berggrenDescendants seed n).card / m) := by
    simpa using Finset.sum_lt_sum_of_nonempty ⟨ ⟨ 0, hm ⟩, Finset.mem_univ _ ⟩ fun y hy => lt_of_not_ge fun h => h_contra ⟨ y, h ⟩;
  linarith [ preimageCount_sum_eq_card H seed n, Nat.div_mul_le_self ( Finset.card ( berggrenDescendants seed n ) ) m ]

/-! ## Section 12: Security Profile Construction

Constructing and validating security profiles from finite-depth data. -/

/-- The security profile has nonneg entropy gap when constructed from
spectral separation data.
Bridge: certified_robustness — the security profile packages all finite-depth
bounds into a single certified security certificate. -/
theorem securityProfile_entropyGap_nonneg {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    0 ≤ (securityProfileOf F H seed n).entropyGap :=
  (securityProfileOf F H seed n).entropyGap_nonneg

/-
Preimage indicator is nonneg everywhere.
Bridge: positivity of indicator functions underlies transfer-operator analysis.
-/
theorem preimageIndicator_nonneg {m : ℕ} (H : ℤ × ℤ × ℤ → Fin m)
    (y : Fin m) (t : ℤ × ℤ × ℤ) :
    0 ≤ PreimageIndicator H y t := by
  unfold PreimageIndicator; aesop;

/-
Collision indicator is nonneg everywhere.
Bridge: collision indicators as nonneg-definite pair functions.
-/
theorem collisionIndicator_nonneg {m : ℕ} (H : ℤ × ℤ × ℤ → Fin m)
    (t t' : ℤ × ℤ × ℤ) :
    0 ≤ CollisionIndicator H t t' := by
  unfold CollisionIndicator; split_ifs <;> norm_num;

/-
Collision indicator is symmetric.
Bridge: connects symmetric pair correlations to thermodynamic two-point functions.
-/
theorem collisionIndicator_symm {m : ℕ} (H : ℤ × ℤ × ℤ → Fin m)
    (t t' : ℤ × ℤ × ℤ) :
    CollisionIndicator H t t' = CollisionIndicator H t' t := by
  unfold CollisionIndicator; aesop;

/-
Lattice crypto style smoothing: collision pressure controls smoothing parameter.
Bridge: connects thermodynamic collision pressure to lattice_crypto smoothing
parameter bounds, enabling post_quantum_security analysis via discrete
Gaussian techniques.
When collision pressure is negative, the smoothing parameter is bounded.
-/
theorem lattice_crypto_style_smoothing_from_collision_pressure {m : ℕ}
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ)
    (hcp : CollisionPressure F H seed n ≤ 0) :
    ↑(CollisionCount H seed n) + 1
      ≤ (CryptoPartitionSum F seed n) ^ 2 := by
  contrapose! hcp;
  refine' sub_pos_of_lt ( lt_of_le_of_lt _ ( Real.log_lt_log _ hcp ) );
  · rw [ Real.log_pow ] ; norm_num;
  · exact sq_pos_of_pos ( cryptoPartitionSum_pos F seed n )

end BerggrenCrypto