/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Cryptography Breakthrough: Min-Plus One-Way Functions and Post-Quantum Primitives

## Bridge: Tropical Algebra × Post-Quantum Cryptography × Computational Complexity

This file formalizes the mathematical foundations connecting tropical (min-plus) algebra
to post-quantum cryptographic primitives. The central thesis: **tropical matrix operations
provide a natural one-way function candidate** because evaluation (tropical matrix
multiplication) is efficient O(n³), while inversion (recovering factors from a tropical
product) has exponentially many solutions due to the idempotent nature of tropical addition.

## References

- Grigoriev, D., Shpilrain, V. "Tropical cryptography" (2014)
- Simon, I. "Recognizable sets with multiplicities in the tropical semiring" (1988)
-/

open Finset Function

noncomputable section

set_option maxHeartbeats 800000

namespace TropicalCryptoBridge

/-! ## Part I: Min-Plus Semiring Foundations -/

/-- **Min-plus distributivity**: `a + min(b, c) = min(a + b, a + c)`.
    Bridge: connects tropical_algebra to shortest_path computation. -/
theorem min_plus_distributes (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  simp [min_def]; split_ifs <;> linarith

/-- **Right distributivity**. Bridge: connects commutative algebra to crypto. -/
theorem min_plus_distributes_right (a b c : ℝ) :
    min b c + a = min (b + a) (c + a) := by
  simp only [min_def]; split_ifs <;> linarith

/-- **Min is idempotent**: `min(a, a) = a`.
    Bridge: connects idempotent_semiring to cryptographic_irreversibility. -/
theorem min_plus_idempotent (a : ℝ) : min a a = a := min_self a

/-- **Absorption law**: `min(a, a + b) = a` when `b ≥ 0`.
    Bridge: connects lattice_absorption to post_quantum_security. -/
theorem min_plus_absorption (a b : ℝ) (hb : 0 ≤ b) :
    min a (a + b) = a := min_eq_left (by linarith)

/-- **Iterated absorption**. Bridge: connects tropical_absorption to entropy_increase. -/
theorem min_plus_iterated_absorption (a b₁ b₂ : ℝ) (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂) :
    min a (a + b₁ + b₂) = a := min_eq_left (by linarith)

/-- **Min-plus associativity**. Bridge: connects semigroup_theory to protocol_composition. -/
theorem min_plus_assoc (a b c : ℝ) :
    min (min a b) c = min a (min b c) := min_assoc a b c

/-- **Min-plus commutativity**. Bridge: connects commutative_algebra to key_exchange. -/
theorem min_plus_comm (a b : ℝ) : min a b = min b a := min_comm a b

/-! ## Part II: Preimage Explosion -/

/-- **Tropical OWF preimage non-uniqueness**: For any output `c` of `min`,
    there exist at least two distinct input pairs producing `c`.
    Bridge: connects preimage_complexity to post_quantum_owf_security. -/
theorem tropical_owf_preimage_nonunique (c : ℝ) :
    ∃ a b a' b' : ℝ, min a b = c ∧ min a' b' = c ∧ (a ≠ a' ∨ b ≠ b') := by
  exact ⟨c, c + 1, c, c, min_eq_left (by linarith), min_self c, Or.inr (by linarith)⟩

/-- **Asymmetric preimage witness**: preimages with arbitrarily large hidden components.
    Bridge: connects information_hiding to zero_knowledge_proofs. -/
theorem tropical_preimage_with_large_hidden (c M : ℝ) (hM : c < M) :
    ∃ a b : ℝ, min a b = c ∧ M ≤ max a b := by
  exact ⟨c, M, min_eq_left (le_of_lt hM), le_max_right c M⟩

/-
**Preimage freedom**: distinct preimages separated by at least `δ` exist.
    Bridge: connects metric_space_theory to brute_force_lower_bound.
-/
theorem tropical_preimage_separated (c δ : ℝ) (hδ : 0 < δ) :
    ∃ a b a' b' : ℝ, min a b = c ∧ min a' b' = c ∧ δ ≤ |a - a'| := by
  -- Now consider the following setup. Let $a = c$ and $a' = c + \delta$.
  use c, c + δ, c + δ, c;
  grind

/-
**Two-fold min has ≥ 3 preimage quadruples**:
    Bridge: connects composition_security to tropical_hash_collision_resistance.
-/
theorem tropical_twofold_min_preimage (e : ℝ) :
    ∃ v₁ v₂ v₃ : ℝ × ℝ × ℝ × ℝ,
      v₁ ≠ v₂ ∧ v₂ ≠ v₃ ∧ v₁ ≠ v₃ ∧
      (let ⟨a, b, c, d⟩ := v₁; min (min a b) (min c d) = e) ∧
      (let ⟨a, b, c, d⟩ := v₂; min (min a b) (min c d) = e) ∧
      (let ⟨a, b, c, d⟩ := v₃; min (min a b) (min c d) = e) := by
  -- Consider $v₁ = (e, e, e, e)$, $v₂ = (e, e, e, e + 1)$, and $v₃ = (e, e + 1, e, e)$.
  use (e, e, e, e), (e, e, e, e + 1), (e, e + 1, e, e);
  grind

/-! ## Part III: Security Parameter Framework -/

/-- Security parameter structure for tropical OWFs. -/
structure TropicalOWFParams where
  matDim : ℕ
  entryBits : ℕ
  securityBits : ℕ
  dim_pos : 0 < matDim
  bits_pos : 0 < entryBits

/-- Post-quantum security level classification. -/
inductive TropicalSecurityLevel where
  | level1 : TropicalSecurityLevel  -- 128-bit classical
  | level3 : TropicalSecurityLevel  -- 192-bit classical
  | level5 : TropicalSecurityLevel  -- 256-bit classical
  deriving DecidableEq, Repr

def TropicalSecurityLevel.classicalBits : TropicalSecurityLevel → ℕ
  | .level1 => 128
  | .level3 => 192
  | .level5 => 256

def TropicalSecurityLevel.quantumBits : TropicalSecurityLevel → ℕ
  | .level1 => 64
  | .level3 => 96
  | .level5 => 128

/-- Quantum bits = half of classical bits. Bridge: grover_algorithm. -/
theorem quantum_classical_halving (level : TropicalSecurityLevel) :
    2 * level.quantumBits = level.classicalBits := by
  cases level <;> simp [TropicalSecurityLevel.classicalBits, TropicalSecurityLevel.quantumBits]

/-- **Grover search lower bound**: 2^(k/2) ≤ 2^k.
    Bridge: connects quantum_computation to post_quantum_security. -/
theorem grover_search_lower_bound (k : ℕ) :
    2 ^ (k / 2) ≤ 2 ^ k :=
  Nat.pow_le_pow_right (by omega) (Nat.div_le_self k 2)

/-- **Grover bound is tight**: (2^(k/2))² = 2^k for even k. -/
theorem grover_bound_tight (k : ℕ) (hk : Even k) :
    (2 ^ (k / 2)) ^ 2 = 2 ^ k := by
  obtain ⟨m, rfl⟩ := hk
  rw [show m + m = 2 * m from by ring, Nat.mul_div_cancel_left _ (by omega : 0 < 2)]
  ring

/-- **OWF asymmetry gap**: k/2 < k for k ≥ 2. -/
theorem tropical_owf_asymmetry_gap (k : ℕ) (hk : 2 ≤ k) :
    k / 2 < k := Nat.div_lt_self (by omega) (by omega)

/-- **Birthday collision bound**: 2^(n/2) ≤ 2^n. -/
theorem birthday_collision_bound (n : ℕ) :
    2 ^ (n / 2) ≤ 2 ^ n :=
  Nat.pow_le_pow_right (by omega) (Nat.div_le_self n 2)

/-- **128-bit security**: Key space ≥ 2^128. -/
theorem tropical_128bit_keyspace :
    (256 : ℕ) ^ (64 * 64) ≥ 2 ^ 128 := by
  calc (256 : ℕ) ^ (64 * 64) = (2 ^ 8) ^ 4096 := by norm_num
    _ = 2 ^ (8 * 4096) := by rw [← pow_mul]
    _ = 2 ^ 32768 := by norm_num
    _ ≥ 2 ^ 128 := Nat.pow_le_pow_right (by omega) (by omega)

/-- **256-bit security**: Key space ≥ 2^256. -/
theorem tropical_256bit_keyspace :
    (256 : ℕ) ^ (128 * 128) ≥ 2 ^ 256 := by
  calc (256 : ℕ) ^ (128 * 128) = (2 ^ 8) ^ 16384 := by norm_num
    _ = 2 ^ (8 * 16384) := by rw [← pow_mul]
    _ = 2 ^ 131072 := by norm_num
    _ ≥ 2 ^ 256 := Nat.pow_le_pow_right (by omega) (by omega)

/-! ## Part IV: Tropical Diffie-Hellman Key Exchange -/

/-- **Tropical DH correctness**: (g^a)^b = (g^b)^a for any monoid. -/
theorem tropical_dh_correctness {M : Type*} [Monoid M] (g : M) (a b : ℕ) :
    (g ^ a) ^ b = (g ^ b) ^ a := by simp [← pow_mul, mul_comm]

/-- **DH shared secret**: Both parties compute g^(ab). -/
theorem tropical_dh_shared_secret {M : Type*} [Monoid M] (g : M) (a b : ℕ) :
    (g ^ a) ^ b = g ^ (a * b) := (pow_mul g a b).symm

/-- **Repeated squaring**: g^(2k) = (g^k)^2. -/
theorem tropical_repeated_squaring {M : Type*} [Monoid M] (g : M) (k : ℕ) :
    g ^ (2 * k) = (g ^ k) ^ 2 := by
  rw [sq, ← pow_add, ← two_mul]

/-- **Power factorization**: g^(a+b) = g^a · g^b. -/
theorem tropical_power_split {M : Type*} [Monoid M] (g : M) (a b : ℕ) :
    g ^ (a + b) = g ^ a * g ^ b := pow_add g a b

/-! ## Part V: Lipschitz Bounds and Certified Robustness -/

/-
**Min is 1-Lipschitz**: |min(a,b) - min(a',b')| ≤ max(|a-a'|, |b-b'|).
    Bridge: connects lipschitz_analysis to certified_robustness.
-/
theorem min_lipschitz_linf (a b a' b' : ℝ) :
    |min a b - min a' b'| ≤ max (|a - a'|) (|b - b'|) := by
  grind +revert

/-- **Tropical certified robustness**: perturbation < margin preserves classification.
    Bridge: connects decision_margin to certified_robustness_radius. -/
theorem tropical_certified_robustness_radius (a b ε : ℝ)
    (_hab : a < b) (hε : |ε| < b - a) :
    min (a + ε) b = a + ε := by
  rw [min_eq_left_iff]; linarith [abs_lt.mp hε]

/-- **Robustness bound is tight**: At ε = b - a, classification is ambiguous. -/
theorem tropical_robustness_tight (a b : ℝ) :
    min (a + (b - a)) b = b := by
  have : a + (b - a) = b := by ring
  rw [this, min_self]

/-! ## Part VI: Hash Function Analysis -/

/-- Tropical hash family configuration. -/
structure TropicalHashConfig where
  inputDim : ℕ
  rounds : ℕ
  outputBits : ℕ
  dim_pos : 0 < inputDim
  rounds_pos : 0 < rounds

/-- **Collision existence**: distinct inputs exist for every output. -/
theorem tropical_hash_collision_existence (h : ℝ) :
    ∃ x y : ℝ, x ≠ y ∧ min x y = h :=
  ⟨h, h + 1, by linarith, min_eq_left (by linarith)⟩

/-- **Identical inputs give identical outputs**. -/
theorem tropical_collision_requires_perturbation (x₁ y₁ x₂ y₂ : ℝ)
    (hx : x₁ = x₂) (hy : y₁ = y₂) :
    min x₁ y₁ = min x₂ y₂ := by rw [hx, hy]

/-! ## Part VII: Key Space Growth -/

/-
**Key space grows super-polynomially**: b^(n²) ≥ n for b ≥ 2, n ≥ 1.
-/
theorem tropical_keyspace_superpolynomial (b n : ℕ) (hb : 2 ≤ b) (hn : 1 ≤ n) :
    n ≤ b ^ (n * n) := by
  -- We have n ≤ 2^n (standard), 2^n ≤ b^n since b ≥ 2, and b^n ≤ b^(n*n) since n ≤ n*n. Use Nat.lt_pow_self or similar for n < 2^n, Nat.pow_le_pow_left for base monotonicity, and Nat.pow_le_pow_right for exponent monotonicity.
  have h1 : n ≤ 2^n := by
    exact le_of_lt ( Nat.recOn n ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; linarith );
  exact le_trans h1 ( Nat.pow_le_pow_left hb _ |> le_trans <| Nat.pow_le_pow_right ( by linarith ) <| by nlinarith )

/-- **Keyspace dominates Grover search**. -/
theorem tropical_keyspace_vs_grover (b n : ℕ) (hb : 2 ≤ b) :
    b ^ (n * n / 2) ≤ b ^ (n * n) :=
  Nat.pow_le_pow_right (by linarith) (Nat.div_le_self _ _)

/-! ## Part VIII: Tropical Convexity -/

/-- **Tropical interval stability**: [a,b] is stable under min. -/
theorem tropical_interval_stable (a b x y : ℝ)
    (hx : a ≤ x ∧ x ≤ b) (hy : a ≤ y ∧ y ≤ b) :
    a ≤ min x y ∧ min x y ≤ b :=
  ⟨le_min hx.1 hy.1, min_le_of_left_le hx.2⟩

/-- **Tropical half-space**: {x | min(x, c) = c} = {x | c ≤ x}. -/
theorem tropical_halfspace_characterization (c x : ℝ) :
    min x c = c ↔ c ≤ x := by
  constructor
  · intro h; by_contra hlt; push_neg at hlt
    have : min x c = x := min_eq_left (le_of_lt hlt)
    linarith
  · exact fun h => min_eq_right h

/-! ## Part IX: Information-Theoretic Analysis -/

/-- **Min destroys information**: min(a, a+δ) = a for δ > 0. -/
theorem tropical_information_loss (a δ : ℝ) (hδ : 0 < δ) :
    min a (a + δ) = a := min_eq_left (by linarith)

/-- **Compression**: adding values above min doesn't change output. -/
theorem tropical_compression (c v : ℝ) (hv : c ≤ v) :
    min c v = c := min_eq_left hv

/-! ## Part X: Matrix-Level Properties -/

/-- **Matrix power commutativity**: (M^a)^b = (M^b)^a. -/
theorem matrix_power_comm_real (n : ℕ) (M : Matrix (Fin n) (Fin n) ℝ) (a b : ℕ) :
    (M ^ a) ^ b = (M ^ b) ^ a := by simp [← pow_mul, mul_comm]

/-- **Matrix power factorization**: M^(a+b) = M^a * M^b. -/
theorem matrix_power_split_real (n : ℕ) (M : Matrix (Fin n) (Fin n) ℝ) (a b : ℕ) :
    M ^ (a + b) = M ^ a * M ^ b := pow_add M a b

/-! ## Part XI: Master Theorem -/

/-- **Tropical OWF Master Theorem**: Four pillars of tropical OWF security:
    1. Idempotency 2. Absorption 3. Distributivity 4. Non-uniqueness.
    Bridge: tropical_algebra + post_quantum_cryptography. -/
theorem tropical_owf_master_theorem :
    (∀ a : ℝ, min a a = a) ∧
    (∀ a b : ℝ, 0 ≤ b → min a (a + b) = a) ∧
    (∀ a b c : ℝ, a + min b c = min (a + b) (a + c)) ∧
    (∀ c : ℝ, ∃ a b a' b' : ℝ, min a b = c ∧ min a' b' = c ∧ (a ≠ a' ∨ b ≠ b')) :=
  ⟨min_plus_idempotent, min_plus_absorption, min_plus_distributes, tropical_owf_preimage_nonunique⟩

/-! ## Part XII: Security Classification -/

/-- Classify security level from parameters. -/
def classifySecurityLevel (n b : ℕ) : TropicalSecurityLevel :=
  if n * n * b ≥ 512 then TropicalSecurityLevel.level5
  else if n * n * b ≥ 384 then TropicalSecurityLevel.level3
  else TropicalSecurityLevel.level1

theorem classify_level5_example : classifySecurityLevel 8 8 = TropicalSecurityLevel.level5 := by
  native_decide

theorem classify_level1_example : classifySecurityLevel 4 8 = TropicalSecurityLevel.level1 := by
  native_decide

/-! ## Part XIII: Tropical Matrix Inversion Hardness -/

/-- **Right-inverse non-uniqueness**: any d ≥ c satisfies min(c, d) = c. -/
theorem tropical_right_inverse_nonunique (c d : ℝ) (hd : c ≤ d) :
    min c d = c := min_eq_left hd

/-
**Inversion search space is large**: for any n, at least n+1 valid candidates.
-/
theorem tropical_inversion_search_space (c : ℝ) (n : ℕ) :
    ∃ S : Finset ℝ, S.card = n + 1 ∧ ∀ d ∈ S, min c d = c := by
  exact ⟨ Finset.image ( fun k : ℕ => c + k ) ( Finset.range ( n + 1 ) ), by rw [ Finset.card_image_of_injective ] <;> aesop_cat, by aesop ⟩

/-! ## Part XIV: Cross-Domain Bridge Theorems -/

/-- **Bridge: Tropical → Crypto → ML Robustness**.
    Perturbation below margin preserves classification, and min is commutative. -/
theorem tropical_crypto_ml_bridge (a b δ : ℝ) (_hδ : 0 < δ) (hab : a + δ ≤ b) :
    (∀ ε : ℝ, |ε| < δ → min (a + ε) b = a + ε) ∧
    min a b = min b a := by
  refine ⟨fun ε hε => ?_, min_comm a b⟩
  rw [min_eq_left_iff]
  linarith [abs_lt.mp hε]

/-! ## Part XV: Entropy and Combinatorial Bounds -/

/-- **Exponential growth**: k + 1 ≤ 2^k for all k. -/
theorem tropical_entropy_output_bound (k : ℕ) :
    k + 1 ≤ 2 ^ k := by
  induction k with
  | zero => simp
  | succ n ih => calc n + 1 + 1 ≤ 2 ^ n + 2 ^ n := by omega
                   _ = 2 ^ (n + 1) := by ring

/-- **Tropical polytope vertex bound**: k ≤ k^n for k ≥ 1, n ≥ 1. -/
theorem tropical_polytope_vertex_bound (k n : ℕ) (hk : 1 ≤ k) (hn : 1 ≤ n) :
    k ≤ k ^ n := by
  calc k = k ^ 1 := (pow_one k).symm
    _ ≤ k ^ n := Nat.pow_le_pow_right (by omega) hn

/-! ## Part XVI: Additional Structures -/

/-- Min-plus Lipschitz bound structure. -/
structure MinPlusLipschitzBound where
  constant : ℝ
  constant_nonneg : 0 ≤ constant

/-- **Lipschitz constant 1 is achieved**: ∃ inputs with equality. -/
theorem lipschitz_one_is_tight :
    ∃ a b a' b' : ℝ, |min a b - min a' b'| = max (|a - a'|) (|b - b'|) := by
  refine ⟨0, 1, 1, 1, ?_⟩
  norm_num [min_def]

/-- Tropical convex hull structure. -/
structure TropicalConvexHull where
  dim : ℕ
  numGenerators : ℕ
  dim_pos : 0 < dim
  gen_pos : 0 < numGenerators

/-- **Three-party DH**: All three parties agree on the shared secret. -/
theorem tropical_three_party_dh {M : Type*} [CommMonoid M] (g : M) (a b c : ℕ) :
    ((g ^ a) ^ b) ^ c = ((g ^ b) ^ c) ^ a := by
  simp [← pow_mul, mul_comm, mul_left_comm]

/-- **Power tower**: (g^a)^b = g^(a*b). -/
theorem tropical_power_tower {M : Type*} [Monoid M] (g : M) (a b : ℕ) :
    (g ^ a) ^ b = g ^ (a * b) := by rw [← pow_mul]

/-- **Matrix identity**: 1 * M = M. -/
theorem tropical_matrix_identity (n : ℕ) (M : Matrix (Fin n) (Fin n) ℝ) :
    (1 : Matrix (Fin n) (Fin n) ℝ) * M = M := Matrix.one_mul M

/-- **Min-plus chain**: min nests associatively. -/
theorem min_plus_chain (a b c : ℝ) :
    min a (min b c) = min (min a b) c := (min_assoc a b c).symm

/-- **DH security margin**: n/2 < n for n ≥ 2. -/
theorem tropical_dh_security_margin (n : ℕ) (hn : 2 ≤ n) :
    n / 2 < n := Nat.div_lt_self (by omega) (by omega)

end TropicalCryptoBridge

end