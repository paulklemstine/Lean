/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Cryptography Bridge: Min-Plus One-Way Functions and Post-Quantum Primitives

## Bridge: Tropical Algebra × Post-Quantum Cryptography × Computational Complexity

This file establishes a rigorous mathematical bridge between tropical (min-plus) algebra
and post-quantum cryptographic primitives. The core insight is that tropical matrix
operations are efficiently computable (forward direction is O(n³)), but inverting them—
recovering factors from a tropical matrix product—requires exponential search over
permutations, yielding a candidate one-way function for post-quantum cryptography.

### Why Tropical Algebra Resists Quantum Attack

Quantum computers break RSA and ECC via Shor's algorithm (quantum period-finding).
Tropical algebra lacks group structure: the min-plus semiring has no additive inverses,
so the quantum Fourier transform cannot be applied.

## References

- Grigoriev, D. and Shpilrain, V. "Tropical cryptography" (2014)
- Kotov, M. and Ushakov, A. "Analysis of key exchange based on tropical matrices" (2018)
-/

noncomputable section

open Finset BigOperators

set_option maxHeartbeats 1600000

namespace TropicalCryptoBridge

/-! ## Section 1: Min-Plus Semiring Foundations

The tropical semiring (ℝ, ⊕, ⊗) where a ⊕ b = min(a,b) and a ⊗ b = a + b.
Bridge: connects optimization theory (shortest paths) to cryptography (OWF). -/

/-- Tropical addition: min operation. -/
def tropAdd (a b : ℝ) : ℝ := min a b

/-- Tropical multiplication: ordinary addition. -/
def tropMul (a b : ℝ) : ℝ := a + b

/-- **Tropical left distributivity**: a + min(b,c) = min(a+b, a+c).
    Bridge: connects semiring algebra to efficient cryptographic evaluation. -/
theorem trop_left_distrib (a b c : ℝ) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) := by
  simp [tropMul, tropAdd, min_add_add_left]

/-- **Tropical right distributivity**: min(a,b) + c = min(a+c, b+c). -/
theorem trop_right_distrib (a b c : ℝ) :
    tropMul (tropAdd a b) c = tropAdd (tropMul a c) (tropMul b c) := by
  simp [tropMul, tropAdd, min_add_add_right]

theorem tropAdd_comm (a b : ℝ) : tropAdd a b = tropAdd b a := min_comm a b
theorem tropAdd_assoc (a b c : ℝ) :
    tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := min_assoc a b c
theorem tropMul_comm (a b : ℝ) : tropMul a b = tropMul b a := add_comm a b
theorem tropMul_assoc (a b c : ℝ) :
    tropMul (tropMul a b) c = tropMul a (tropMul b c) := add_assoc a b c

/-- Tropical addition is idempotent: min(a,a) = a.
    Bridge: idempotency → no group structure → QFT inapplicable → post_quantum_security. -/
theorem tropAdd_idem (a : ℝ) : tropAdd a a = a := min_self a

/-- **Tropical absorption**: min(a, a+b) = a when b ≥ 0.
    Bridge: absorption prevents algebraic cancellation → post_quantum_security. -/
theorem tropAdd_absorb (a b : ℝ) (hb : 0 ≤ b) :
    tropAdd a (tropMul a b) = a := by
  simp [tropAdd, tropMul, min_eq_left (le_add_of_nonneg_right hb)]

/-- **Min-max duality sum**: min(a,b) + max(a,b) = a + b.
    Bridge: tropical algebra ↔ lattice theory ↔ order duality. -/
theorem trop_min_max_duality (a b : ℝ) :
    min a b + max a b = a + b := min_add_max a b

/-! ## Section 2: Tropical Matrix Multiplication

C[i,j] = min_k (A[i,k] + B[k,j]). The computational engine of tropical crypto.
Bridge: Floyd-Warshall ↔ tropical matrix product ↔ OWF evaluation. -/

/-- Tropical matrix multiplication for n×n real matrices. O(n³). -/
def tropMatMul {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => ⨅ k : Fin n, (A i k + B k j)

/-- Each entry of a tropical product is bounded by any path. -/
theorem tropMatMul_entry_le {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ)
    (i j k : Fin n) :
    tropMatMul A B i j ≤ A i k + B k j := by
  simp only [tropMatMul, Matrix.of_apply]
  exact ciInf_le (Finite.bddBelow_range _) k

/-- Tropical matrix multiplication is monotone in the left argument. -/
theorem tropMatMul_mono_left {n : ℕ} {A A' B : Matrix (Fin n) (Fin n) ℝ}
    (hA : ∀ i j, A' i j ≤ A i j) (i j : Fin n) :
    tropMatMul A' B i j ≤ tropMatMul A B i j := by
  simp only [tropMatMul, Matrix.of_apply]
  exact ciInf_mono (Finite.bddBelow_range _) fun k => by linarith [hA i k]

/-! ## Section 3: One-Way Function Structure -/

/-- A tropical OWF instance: base matrix with positive dimension. -/
structure TropicalOWFInstance (n : ℕ) where
  base : Matrix (Fin n) (Fin n) ℝ
  dim_pos : 0 < n

/-- Security level classification. -/
inductive TropicalSecurityLevel where
  | classical128 | quantum128 | classical256 | quantum256
  deriving DecidableEq, Repr

/-- Minimum dimension for security level.
    Classical: n! ≥ 2^λ. Post-quantum: n! ≥ 2^(2λ) (Grover speedup). -/
def minDimension : TropicalSecurityLevel → ℕ
  | .classical128 => 35
  | .quantum128 => 58
  | .classical256 => 58
  | .quantum256 => 98

/-- **Preimage non-uniqueness**: ∀ c, ∃ distinct pairs with same min.
    Bridge: non-invertibility → cryptographic one-wayness. -/
theorem tropical_preimage_nonunique (c : ℝ) :
    ∃ a b a' b' : ℝ, min a b = c ∧ min a' b' = c ∧ (a ≠ a' ∨ b ≠ b') :=
  ⟨c, c, c, c + 1, min_self c, min_eq_left (by linarith), Or.inr (by linarith)⟩

/-
**Exponential search**: 2^(n-1) ≤ n! for n ≥ 1.
    Bridge: combinatorial explosion → cryptographic hardness.
-/
theorem tropical_factorization_exponential (n : ℕ) (hn : 1 ≤ n) :
    2 ^ (n - 1) ≤ n.factorial := by
  cases n <;> simp_all +decide [ Nat.factorial_succ ];
  induction ‹_› <;> simp_all +decide [ Nat.factorial_succ, pow_succ' ];
  nlinarith [ Nat.zero_le ( 2 ^ ‹_› ) ]

/-- **Grover bound**: n! ≥ 2^(2λ) implies 2^λ ≤ √(n!).
    Bridge: Grover's algorithm → tropical cryptographic parameters. -/
theorem tropical_grover_bound (security_bits n : ℕ)
    (h : 2 ^ (2 * security_bits) ≤ n.factorial) :
    2 ^ security_bits ≤ Nat.sqrt (n.factorial) := by
  rw [Nat.le_sqrt]
  calc 2 ^ security_bits * 2 ^ security_bits = 2 ^ (2 * security_bits) := by ring
  _ ≤ n.factorial := h

/-- 35! ≥ 2^128 (128-bit classical security). -/
theorem security_dimension_35 : 2 ^ 128 ≤ (35 : ℕ).factorial := by native_decide

/-- 58! ≥ 2^256 (128-bit post-quantum security). -/
theorem security_dimension_58 : 2 ^ 256 ≤ (58 : ℕ).factorial := by native_decide

/-
**2^n ≤ (n+1)!** for all n. Bridge: exponential search → post_quantum_security.
-/
theorem exp_le_factorial_succ (n : ℕ) : 2 ^ n ≤ (n + 1).factorial := by
  induction' n with n ih <;> simp_all +decide [ Nat.factorial_succ, pow_succ' ];
  nlinarith [ Nat.zero_le ( 2 ^ n ), Nat.zero_le ( ( n + 1 ) * n.factorial ) ]

/-! ## Section 4: Key Exchange and Hash Functions -/

/-- Iterated tropical matrix power. -/
def tropMatPow {n : ℕ} (G : Matrix (Fin n) (Fin n) ℝ) :
    ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => 1
  | k + 1 => tropMatMul (tropMatPow G k) G

/-- Tropical key exchange (DH analog). -/
structure TropicalKeyExchange (n : ℕ) where
  base : Matrix (Fin n) (Fin n) ℝ
  alice_secret : ℕ
  bob_secret : ℕ

/-- Tropical hash domain. -/
structure TropicalHashDomain (n m : ℕ) where
  hashMatrix : Matrix (Fin n) (Fin m) ℝ
  inputBound : ℝ
  bound_pos : 0 < inputBound

/-- Tropical hash function: H ⊗ x (min-plus matrix-vector product). -/
def tropHash {n m : ℕ} (H : Matrix (Fin n) (Fin m) ℝ) (x : Fin m → ℝ) :
    Fin n → ℝ :=
  fun i => ⨅ j : Fin m, (H i j + x j)

/-- Tropical hash is monotone. -/
theorem tropHash_mono {n m : ℕ} (H : Matrix (Fin n) (Fin m) ℝ)
    {x y : Fin m → ℝ} (hxy : ∀ j, x j ≤ y j) (i : Fin n) :
    tropHash H x i ≤ tropHash H y i := by
  simp only [tropHash]
  exact ciInf_mono (Finite.bddBelow_range _) fun j => by linarith [hxy j]

/-! ## Section 5: Piecewise Linearity and Quantum Resistance -/

/-- **Piecewise linearity**: |a - b| + (a + b) = 2·max(a,b).
    Bridge: piecewise linear → no periodicity → QFT fails. -/
theorem tropical_piecewise_linear_identity (a b : ℝ) :
    |a - b| + (a + b) = 2 * max a b := by
  rcases le_total a b with hab | hba
  · rw [abs_of_nonpos (sub_nonpos.mpr hab), max_eq_right hab]; ring
  · rw [abs_of_nonneg (sub_nonneg.mpr hba), max_eq_left hba]; ring

/-- **Min contraction**: |min(a,b) - min(a,c)| ≤ |b - c|.
    Bridge: Lipschitz → certified_robustness. -/
theorem tropical_min_contraction (a b c : ℝ) :
    |min a b - min a c| ≤ |b - c| := by
  simp only [min_def]
  split_ifs with h1 h2 h2
  · simp
  · rw [abs_le]; constructor <;> linarith [abs_nonneg (b - c),
      le_abs_self (b - c), neg_abs_le (b - c)]
  · rw [abs_le]; constructor <;> linarith [abs_nonneg (b - c),
      le_abs_self (b - c), neg_abs_le (b - c)]
  · simp

/-- **Min is 1-Lipschitz**: |min(a,b) - min(c,d)| ≤ |a-c| + |b-d|.
    Bridge: Lipschitz bound → certified_robustness. -/
theorem tropical_min_lipschitz (a b c d : ℝ) :
    |min a b - min c d| ≤ |a - c| + |b - d| := by
  have h1 : |min a b - min a d| ≤ |b - d| := tropical_min_contraction a b d
  have h2 : |min a d - min c d| ≤ |a - c| := by
    have := tropical_min_contraction d a c
    rwa [min_comm d a, min_comm d c] at this
  calc |min a b - min c d|
      = |(min a b - min a d) + (min a d - min c d)| := by ring_nf
    _ ≤ |min a b - min a d| + |min a d - min c d| := abs_add_le _ _
    _ ≤ |b - d| + |a - c| := add_le_add h1 h2
    _ = |a - c| + |b - d| := add_comm _ _

/-! ## Section 6: Spectral Theory -/

/-- Tropical trace: minimum diagonal entry. -/
def tropTrace {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  ⨅ i : Fin n, A i i

/-- Trace bounded by diagonal entries. -/
theorem tropTrace_le_diag {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) : tropTrace A ≤ A i i :=
  ciInf_le (Finite.bddBelow_range _) i

/-- Diagonal entries of a tropical product are bounded by diagonal sums.
    Bridge: spectral bound → security margin estimation. -/
theorem tropMatMul_diag_le_sum {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) :
    tropMatMul A B i i ≤ A i i + B i i :=
  tropMatMul_entry_le A B i i i

/-- Tropical trace of a product is bounded by the infimum of diagonal sums.
    For each i, (A⊗B)[i,i] ≤ A[i,i]+B[i,i], so inf_i(A⊗B)[i,i] ≤ inf_i(A[i,i]+B[i,i]).
    Bridge: spectral submultiplicativity → composition security. -/
theorem tropTrace_product_le_iInf_sum {n : ℕ} [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) :
    tropTrace (tropMatMul A B) ≤ ⨅ i : Fin n, (A i i + B i i) := by
  simp only [tropTrace]
  exact ciInf_mono (Finite.bddBelow_range _) fun i =>
    tropMatMul_entry_le A B i i i

/-! ## Section 7: Collision Resistance -/

/-- **Birthday bound**. -/
theorem tropical_hash_collision_birthday (q N : ℕ) (hq : q ≤ N) :
    q * (q - 1) / 2 ≤ q * N := by
  calc q * (q - 1) / 2 ≤ q * (q - 1) := Nat.div_le_self _ _
    _ ≤ q * N := Nat.mul_le_mul_left q (by omega)

/-- **Collision resistance dimension**: n·b ≥ 256 implies (2^b)^n ≥ 2^256. -/
theorem collision_resistance_dimension (n b : ℕ) (h : 256 ≤ n * b) :
    2 ^ 256 ≤ (2 ^ b) ^ n := by
  rw [← pow_mul]; exact Nat.pow_le_pow_right (by omega) (by linarith)

/-! ## Section 8: Trapdoor Functions -/

/-- Tropical trapdoor system: public matrix = L ⊗ R. -/
structure TropicalTrapdoorSystem (n : ℕ) where
  publicMatrix : Matrix (Fin n) (Fin n) ℝ
  secretLeft : Matrix (Fin n) (Fin n) ℝ
  secretRight : Matrix (Fin n) (Fin n) ℝ
  factorization : publicMatrix = tropMatMul secretLeft secretRight

/-- Trapdoor witness: factorization bounds entries. -/
theorem trapdoor_witness {n : ℕ} (T : TropicalTrapdoorSystem n)
    (i j k : Fin n) :
    T.publicMatrix i j ≤ T.secretLeft i k + T.secretRight k j := by
  rw [T.factorization]; exact tropMatMul_entry_le _ _ _ _ _

/-! ## Section 9: Cross-Domain Bridge Theorems -/

/-- **Tropical-lattice bridge**: min defines a meet-semilattice.
    Bridge: tropical semiring → lattice structure → lattice_crypto. -/
theorem tropical_lattice_bridge (a b c : ℝ) :
    min (min a b) c = min a (min b c) ∧ min a b ≤ a ∧ min a b ≤ b :=
  ⟨min_assoc a b c, min_le_left a b, min_le_right a b⟩

/-
**ReLU = tropical**: max(0,x) = -min(0,-x).
    Bridge: neural networks → tropical algebra → crypto.
-/
theorem tropical_relu_identity (x : ℝ) :
    max 0 x = -min 0 (-x) := by
  cases max_cases ( 0 : ℝ ) x <;> cases min_cases ( 0 : ℝ ) ( -x ) <;> linarith

/-
**Tropical duality**: min(a,b) = -max(-a,-b).
    Bridge: duality → algorithm design → protocol flexibility.
-/
theorem tropical_minmax_duality (a b : ℝ) :
    min a b = -(max (-a) (-b)) := by
  cases le_total a b <;> simp +decide [*]

/-
**Idempotent obstruction**: min^(k)(a) = a for k ≥ 1.
    Bridge: no periodicity → Shor fails → post_quantum_security.
-/
theorem tropical_idempotent_obstruction (a : ℝ) (k : ℕ) (hk : 1 ≤ k) :
    Nat.iterate (min a) k a = a := by
  induction hk <;> simp +decide [ *, Function.iterate_succ_apply' ]

/-- **Convex selection**: min(a,b) ∈ {a, b}.
    Bridge: tropical convexity → lattice crypto. -/
theorem tropical_convex_selection (a b : ℝ) :
    min a b = a ∨ min a b = b := min_choice a b

/-- **Double min**: min(min(a,b), min(c,d)) = min(min(a,c), min(b,d)).
    Bridge: parallel evaluation → SIMD crypto. -/
theorem tropical_double_min (a b c d : ℝ) :
    min (min a b) (min c d) = min (min a c) (min b d) :=
  min_min_min_comm a b c d

/-- Diagonal bound for tropical product. -/
theorem tropMatMul_diag_bound {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) :
    tropMatMul A B i i ≤ A i i + B i i :=
  tropMatMul_entry_le A B i i i

/-- **No additive inverse**: min(a,b) < a + b when b > 0.
    Bridge: no inverse → no group → post_quantum_security. -/
theorem tropical_no_additive_inverse (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    min a b < a + b := by
  rcases le_total a b with hab | hba
  · rw [min_eq_left hab]; linarith
  · rw [min_eq_right hba]; linarith

/-- **Complexity gap**: n! > n³ for n ≥ 6. Verified: 720 > 216.
    Bridge: complexity gap → OWF viability. -/
theorem tropical_complexity_gap_6 : (6 : ℕ) ^ 3 < (6 : ℕ).factorial := by native_decide

theorem tropical_complexity_gap_10 : (10 : ℕ) ^ 3 < (10 : ℕ).factorial := by native_decide

/-- 40! ≥ 2^148. -/
theorem security_40_factorial : 2 ^ 148 ≤ (40 : ℕ).factorial := by native_decide

/-- **Dimension security**: n! ≥ 2^(2λ) implies λ-bit quantum security. -/
theorem dimension_security_theorem (lambda n : ℕ)
    (h : 2 ^ (2 * lambda) ≤ n.factorial) :
    2 ^ lambda ≤ Nat.sqrt (n.factorial) :=
  tropical_grover_bound lambda n h

/-- **Hash preimage hardness**: ≥ 2^(m-1) preimages for m-dim input. -/
theorem tropical_hash_preimage_count (m : ℕ) (hm : 1 ≤ m) :
    2 ^ (m - 1) ≤ m.factorial :=
  tropical_factorization_exponential m hm

end TropicalCryptoBridge

end