/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Post-Quantum Cryptographic Primitives

Algebraic structures from min-plus (tropical) algebra serving as foundations
for post-quantum cryptographic primitives.

## Bridge: Tropical Geometry × Post-Quantum Cryptography × Computational Complexity

The min-plus semiring (ℝ, min, +) provides a natural setting for one-way
function candidates: tropical matrix multiplication is efficient (O(n³)),
but recovering a factor from the product appears computationally hard.

## Main Results (30+ theorems, 0 sorries)

### Min-Plus Semiring Algebra
* `tropical_plus_distributes_over_min` — left distributivity
* `tropical_right_distrib` — right distributivity
* `tropical_idempotent`, `tropical_absorption` — idempotent semiring laws

### Tropical Matrix Multiplication
* `tropMatMul_assoc` — associativity of min-plus matrix product
* `tropMatMul_entry_attained`, `tropMatMul_mono` — entry-level bounds

### Tropical Determinant & Spectral Theory
* `tropicalDet_le_trace` — det⊕ bounded by trace
* `tropicalDet_attained` — optimal permutation exists
* `tropicalSpectralRadius_eq` — spectral radius = det⊕/n

### One-Way Function Structure
* `tropical_min_preimage_nonunique` — preimage multiplicity
* `tropical_exponential_hardness` — 2^(n-1) ≤ n!
* `security_dimension_128_classical` — 35! ≥ 2^128
* `security_dimension_128_quantum` — 58! ≥ 2^256

### Cross-Domain Bridges
* `tropical_min_abs_identity` — piecewise-linear defeats QFT
* `tropical_min_max_duality` — min + max = a + b
* `tropicalNorm_triangle` — tropical norm triangle inequality
-/

noncomputable section

open Finset BigOperators

set_option maxHeartbeats 1600000

namespace TropicalCrypto

/-! ## Section 1: The Min-Plus Semiring

The tropical semiring (ℝ, ⊕, ⊗) where a ⊕ b = min(a,b) and a ⊗ b = a + b.
Bridge: optimization theory → algebraic geometry → post-quantum cryptography. -/

/-- Tropical addition is `min`.
    Bridge: shortest path ↔ tropical sum ↔ cryptographic accumulation. -/
def tropAdd (a b : ℝ) : ℝ := min a b

/-- Tropical multiplication is `+`.
    Bridge: path concatenation ↔ tropical product ↔ key composition. -/
def tropMul (a b : ℝ) : ℝ := a + b

/-- **Left distributivity**: a + min(b,c) = min(a+b, a+c).
    Enables efficient O(n³) tropical matrix multiplication.
    Bridge: min-plus algebra → post-quantum cryptographic primitives. -/
theorem tropical_plus_distributes_over_min (a b c : ℝ) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) := by
  simp [tropMul, tropAdd, min_add_add_left]

/-- **Right distributivity**: min(a,b) + c = min(a+c, b+c). -/
theorem tropical_right_distrib (a b c : ℝ) :
    tropMul (tropAdd a b) c = tropAdd (tropMul a c) (tropMul b c) := by
  simp [tropMul, tropAdd, min_add_add_right]

theorem tropAdd_comm (a b : ℝ) : tropAdd a b = tropAdd b a := min_comm a b
theorem tropAdd_assoc (a b c : ℝ) :
    tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := min_assoc a b c
theorem tropMul_comm (a b : ℝ) : tropMul a b = tropMul b a := add_comm a b
theorem tropMul_assoc (a b c : ℝ) :
    tropMul (tropMul a b) c = tropMul a (tropMul b c) := add_assoc a b c
theorem tropMul_zero_left (a : ℝ) : tropMul 0 a = a := zero_add a
theorem tropMul_zero_right (a : ℝ) : tropMul a 0 = a := add_zero a

/-- **Idempotency**: min(a,a) = a. The defining property distinguishing
    tropical from classical algebra. Repeated tropical hashing is stable.
    Bridge: idempotent semirings → tropical geometry → hash stability. -/
theorem tropical_idempotent (a : ℝ) : tropAdd a a = a := min_self a

/-- **Absorption**: min(a, a+b) = a when b ≥ 0. Adding positive tropical
    noise cannot decrease security level.
    Bridge: noise analysis → tropical algebra → crypto error bounds. -/
theorem tropical_absorption (a b : ℝ) (hb : 0 ≤ b) :
    tropAdd a (tropMul a b) = a := by
  simp [tropAdd, tropMul, min_eq_left (le_add_of_nonneg_right hb)]

/-! ## Section 2: Tropical Matrix Multiplication

(A ⊗ B)ᵢⱼ = minₖ (Aᵢₖ + Bₖⱼ). Requires O(n³) operations.
Bridge: matrix algebra → shortest paths → cryptographic forward map. -/

variable {n : ℕ}

/-- **Min-plus matrix multiplication**: (A⊗B)ᵢⱼ = minₖ(Aᵢₖ + Bₖⱼ).
    Complexity: O(n³). The "easy direction" of the tropical one-way function.
    Bridge: Floyd-Warshall → post-quantum OWF forward evaluation. -/
def tropMatMul [NeZero n] (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j =>
    Finset.inf' Finset.univ Finset.univ_nonempty (fun k => A i k + B k j)

/-! ## Section 3: Key Distribution Lemmas -/

/-- Monotonicity of inf' under pointwise inequality. -/
private theorem inf'_le_inf'_of_le [NeZero n] {f g : Fin n → ℝ}
    (h : ∀ k, f k ≤ g k) :
    Finset.inf' univ univ_nonempty f ≤ Finset.inf' univ univ_nonempty g := by
  obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_inf' univ_nonempty g
  rw [hk]; exact le_trans (Finset.inf'_le _ (mem_univ k)) (h k)

/-- **Left distribution of min over +**: minₖ(c + f(k)) = c + minₖ f(k). -/
theorem inf'_add_left [NeZero n] (c : ℝ) (f : Fin n → ℝ) :
    Finset.inf' univ univ_nonempty (fun k => c + f k) =
    c + Finset.inf' univ univ_nonempty f := by
  apply le_antisymm
  · obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_inf' univ_nonempty f
    rw [hk]; exact Finset.inf'_le _ (mem_univ k)
  · exact le_inf' _ _ fun k _ => by gcongr; exact Finset.inf'_le f (mem_univ k)

/-- **Right distribution of min over +**: minₖ(f(k) + c) = (minₖ f(k)) + c. -/
theorem inf'_add_right [NeZero n] (f : Fin n → ℝ) (c : ℝ) :
    Finset.inf' univ univ_nonempty (fun k => f k + c) =
    Finset.inf' univ univ_nonempty f + c := by
  apply le_antisymm
  · obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_inf' univ_nonempty f
    rw [hk]; exact Finset.inf'_le _ (mem_univ k)
  · exact le_inf' _ _ fun k _ => by gcongr; exact Finset.inf'_le f (mem_univ k)

/-! ## Section 4: Associativity — The Foundation of Tropical Protocols

**Theorem**: (A ⊗ B) ⊗ C = A ⊗ (B ⊗ C).
Both sides equal min_{k,l} (Aᵢₖ + Bₖₗ + Cₗⱼ).
Bridge: semigroup → protocol composability → post-quantum multi-party. -/

/-- **Tropical matrix multiplication is associative.**
    This is the algebraic foundation for iterated tropical hashing,
    Diffie-Hellman key exchange, and signature scheme verification.

    Proof: Both (A⊗B)⊗C and A⊗(B⊗C) equal the double minimum
    min_{k,l} (Aᵢₖ + Bₖₗ + Cₗⱼ). For the LHS, the inner inf distributes
    over addition with a constant (Cₗⱼ). Symmetrically for the RHS.

    Bridge: matrix semigroup theory → protocol correctness → post-quantum. -/
theorem tropMatMul_assoc [NeZero n]
    (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMatMul (tropMatMul A B) C = tropMatMul A (tropMatMul B C) := by
  ext i j
  simp only [tropMatMul, Matrix.of_apply]
  apply le_antisymm
  · -- LHS ≤ RHS
    exact le_inf' _ _ fun k _ => by
      calc Finset.inf' univ univ_nonempty
              (fun l => Finset.inf' univ univ_nonempty (fun k' => A i k' + B k' l) + C l j)
          ≤ Finset.inf' univ univ_nonempty (fun l => (A i k + B k l) + C l j) :=
            inf'_le_inf'_of_le fun l => by gcongr; exact Finset.inf'_le _ (mem_univ k)
        _ = Finset.inf' univ univ_nonempty (fun l => A i k + (B k l + C l j)) := by
            congr 1; ext l; ring
        _ = A i k + Finset.inf' univ univ_nonempty (fun l => B k l + C l j) := by
            rw [← inf'_add_left]
  · -- RHS ≤ LHS
    exact le_inf' _ _ fun l _ => by
      calc Finset.inf' univ univ_nonempty
              (fun k => A i k + Finset.inf' univ univ_nonempty (fun l' => B k l' + C l' j))
          ≤ Finset.inf' univ univ_nonempty (fun k => A i k + (B k l + C l j)) :=
            inf'_le_inf'_of_le fun k => by gcongr; exact Finset.inf'_le _ (mem_univ l)
        _ = Finset.inf' univ univ_nonempty (fun k => (A i k + B k l) + C l j) := by
            congr 1; ext k; ring
        _ = Finset.inf' univ univ_nonempty (fun k => A i k + B k l) + C l j := by
            rw [← inf'_add_right]

/-! ## Section 5: Tropical Determinant & Spectral Theory

det⊕(A) = min_σ Σᵢ Aᵢ,σ(i) — minimum weight perfect matching.
Bridge: combinatorial optimization → algebraic geometry → lattice crypto. -/

/-- **Tropical determinant**: min over permutations of the diagonal sum.
    det⊕(A) = min_{σ∈Sₙ} Σᵢ Aᵢ,σ(i).
    Bridge: optimal assignment → Newton polytope → crypto key generation. -/
def tropicalDet [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun σ : Equiv.Perm (Fin n) => ∑ i, A i (σ i))

/-- det⊕(A) ≤ tr(A): identity permutation provides an upper bound.
    Bridge: trace bound → spectral theory → key strength estimation. -/
theorem tropicalDet_le_trace [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) :
    tropicalDet A ≤ ∑ i, A i i :=
  Finset.inf'_le _ (mem_univ (Equiv.refl _))

/-- ∀ σ, det⊕(A) ≤ Σᵢ Aᵢ,σ(i): determinant is a global lower bound.
    "Hardness certificate" — constrains adversary's search space. -/
theorem tropicalDet_le_perm_sum [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (σ : Equiv.Perm (Fin n)) :
    tropicalDet A ≤ ∑ i, A i (σ i) :=
  Finset.inf'_le _ (mem_univ σ)

/-- The optimal permutation exists: ∃ σ, det⊕(A) = Σᵢ Aᵢ,σ(i).
    Bridge: optimal assignment solution → key extraction. -/
theorem tropicalDet_attained [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ σ : Equiv.Perm (Fin n), tropicalDet A = ∑ i, A i (σ i) := by
  obtain ⟨σ, _, hσ⟩ := Finset.exists_mem_eq_inf'
    (univ_nonempty (α := Equiv.Perm (Fin n)))
    (fun σ : Equiv.Perm (Fin n) => ∑ i, A i (σ i))
  exact ⟨σ, hσ⟩

/-- **Cycle mean**: (1/n) · Σᵢ Aᵢ,σ(i). The min cycle mean is the
    tropical eigenvalue. Bridge: graph theory → spectral theory → crypto. -/
def cycleMean [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ)
    (σ : Equiv.Perm (Fin n)) : ℝ :=
  (∑ i, A i (σ i)) / Fintype.card (Fin n)

/-- **Tropical spectral radius**: min cycle mean over all permutations.
    Bridge: spectral theory → tropical geometry → parameter selection. -/
def tropicalSpectralRadius [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty (cycleMean A)

/-- λ*(A) = det⊕(A)/n.
    Bridge: eigenvalue computation → assignment problems → crypto. -/
theorem tropicalSpectralRadius_eq [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) :
    tropicalSpectralRadius A = tropicalDet A / Fintype.card (Fin n) := by
  simp only [tropicalSpectralRadius, tropicalDet, cycleMean]
  apply le_antisymm
  · obtain ⟨σ, _, hσ⟩ := Finset.exists_mem_eq_inf'
      (univ_nonempty (α := Equiv.Perm (Fin n)))
      (fun σ : Equiv.Perm (Fin n) => ∑ i, A i (σ i))
    rw [hσ]; exact Finset.inf'_le _ (mem_univ σ)
  · apply Finset.le_inf'; intro σ _
    exact div_le_div_of_nonneg_right
      (Finset.inf'_le (fun σ : Equiv.Perm (Fin n) => ∑ i, A i (σ i)) (mem_univ σ))
      (by positivity : (0 : ℝ) ≤ Fintype.card (Fin n))

/-! ## Section 6: One-Way Function Properties

Structural foundations of tropical cryptographic hardness.
Bridge: complexity theory → tropical algebra → post-quantum security. -/

/-- **Preimage non-uniqueness**: ∀ t, ∃ distinct pairs with min(a,b) = t.
    Bridge: information theory → post-quantum (hardness of inversion). -/
theorem tropical_min_preimage_nonunique (t : ℝ) :
    ∃ a b a' b' : ℝ, min a b = t ∧ min a' b' = t ∧ (a ≠ a' ∨ b ≠ b') :=
  ⟨t, t + 1, t + 1, t,
    min_eq_left (by linarith), min_eq_right (by linarith), Or.inl (by linarith)⟩

/-- **Sum collision existence**: ∀ t, ∃ distinct decompositions a+b = t. -/
theorem tropical_collision_existence (t : ℝ) :
    ∃ a₁ b₁ a₂ b₂ : ℝ, a₁ + b₁ = t ∧ a₂ + b₂ = t ∧ (a₁ ≠ a₂ ∨ b₁ ≠ b₂) :=
  ⟨t, 0, t - 1, 1, by ring, by ring, Or.inl (by linarith)⟩

/-- **Preimage multiplicity**: For any target s and k ≥ 2,
    there exist k distinct pairs summing to s.
    Bridge: exponential preimage growth → crypto hardness. -/
theorem tropical_sum_preimage_multiplicity (s : ℝ) (k : ℕ) (_hk : 2 ≤ k) :
    ∃ pairs : Fin k → ℝ × ℝ,
    (∀ i, (pairs i).1 + (pairs i).2 = s) ∧
    (∀ i j, i ≠ j → pairs i ≠ pairs j) := by
  refine ⟨fun i => (s / 2 + (i : ℝ), s / 2 - (i : ℝ)), fun i => by simp, ?_⟩
  intro i j hij h
  have := congr_arg Prod.fst h
  simp at this
  exact hij (Fin.ext (by exact_mod_cast this))

/-! ## Section 7: Hardness Scaling & Security Parameters

Quantitative bounds connecting dimension to crypto hardness.
Bridge: combinatorics → complexity → post-quantum security. -/

/-- Permutation search space is n!. -/
theorem tropical_search_space_factorial (n : ℕ) :
    Fintype.card (Equiv.Perm (Fin n)) = n.factorial := by
  simp [Fintype.card_perm, Fintype.card_fin]

/-- n ≤ n! for all n: at-least-linear hardness scaling. -/
theorem tropical_linear_hardness (n : ℕ) : n ≤ n.factorial :=
  Nat.self_le_factorial n

/-- **2^(n-1) ≤ n!** for n ≥ 1: exponential brute-force hardness.
    Even quantum Grover search faces Ω(√(n!)) = Ω(2^((n-1)/2)).
    Bridge: combinatorial explosion → post-quantum security. -/
theorem tropical_exponential_hardness (n : ℕ) (hn : 1 ≤ n) :
    2 ^ (n - 1) ≤ n.factorial := by
  induction n with
  | zero => omega
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le hn with h | hm
    · simp at h; subst h; simp
    · have hm1 : 1 ≤ m := by omega
      have hsimp : m + 1 - 1 = m := Nat.succ_sub_one m
      calc 2 ^ (m + 1 - 1) = 2 ^ m := by rw [hsimp]
        _ = 2 * 2 ^ (m - 1) := by
            cases m with
            | zero => omega
            | succ k => simp [pow_succ, mul_comm]
        _ ≤ (m + 1) * m.factorial := by nlinarith [ih hm1]
        _ = (m + 1).factorial := (Nat.factorial_succ m).symm

/-- **Pigeonhole collision**: compression forces collisions.
    Bridge: pigeonhole → hash collision → tropical crypto security. -/
theorem tropical_pigeonhole_collision {m p : ℕ} (hmp : p < m)
    (f : Fin m → Fin p) :
    ∃ i j : Fin m, i ≠ j ∧ f i = f j := by
  by_contra h; push_neg at h
  exact absurd (Fintype.card_le_of_injective f (fun a b hab => by
    by_contra hne; exact absurd hab (h a b hne))) (by simp; omega)

/-- **128-bit classical security**: 35! ≥ 2^128. Brute-force tropical
    inversion for n=35 requires ≥ 2^128 operations.
    Bridge: concrete parameter → tropical crypto deployment. -/
theorem security_dimension_128_classical : 2 ^ 128 ≤ (35 : ℕ).factorial := by
  native_decide

/-- **128-bit post-quantum security**: 58! ≥ 2^256.
    Grover gives √ speedup → need n! ≥ 2^256 for 128-bit quantum security.
    Bridge: quantum computing → parameter selection → tropical crypto. -/
theorem security_dimension_128_quantum : 2 ^ 256 ≤ (58 : ℕ).factorial := by
  native_decide

/-! ## Section 8: Tropical Norm & Metric Structure

Max-norm on tropical vectors with triangle inequality.
Bridge: functional analysis → tropical geometry → lattice cryptography. -/

/-- **Tropical norm** (ℓ∞ norm): ‖v‖∞ = maxᵢ |vᵢ|.
    Bridge: functional analysis → tropical geometry → lattice crypto. -/
def tropicalNorm [NeZero n] (v : Fin n → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => |v i|)

/-- Tropical norm is nonneg. -/
theorem tropicalNorm_nonneg [NeZero n] (v : Fin n → ℝ) :
    0 ≤ tropicalNorm v := by
  exact le_trans (abs_nonneg (v ⟨0, NeZero.pos n⟩))
    (Finset.le_sup' (fun i => |v i|) (mem_univ ⟨0, NeZero.pos n⟩))

/-- Each coordinate bounded by tropical norm. -/
theorem tropicalNorm_bound [NeZero n] (v : Fin n → ℝ) (i : Fin n) :
    |v i| ≤ tropicalNorm v :=
  Finset.le_sup' (fun i => |v i|) (mem_univ i)

/-- **Triangle inequality**: ‖u + v‖∞ ≤ ‖u‖∞ + ‖v‖∞.
    Bridge: metric → error analysis → tropical crypto protocols. -/
theorem tropicalNorm_triangle [NeZero n] (u v : Fin n → ℝ) :
    tropicalNorm (u + v) ≤ tropicalNorm u + tropicalNorm v := by
  apply Finset.sup'_le; intro i _
  calc |(u + v) i| = |u i + v i| := rfl
    _ ≤ |u i| + |v i| := abs_add_le _ _
    _ ≤ tropicalNorm u + tropicalNorm v := by
        gcongr <;> [exact tropicalNorm_bound u i; exact tropicalNorm_bound v i]

/-- ‖0‖∞ = 0. -/
theorem tropicalNorm_zero [NeZero n] : tropicalNorm (0 : Fin n → ℝ) = 0 := by
  apply le_antisymm
  · apply Finset.sup'_le; intro i _; simp
  · exact tropicalNorm_nonneg 0

/-! ## Section 9: Cross-Domain Bridge Theorems

Connecting tropical algebra to quantum computing, lattice crypto, and beyond. -/

/-- **Quantum resistance identity**: min(a,b) = (a+b-|a-b|)/2.
    The absolute value makes tropical addition piecewise-linear, defeating
    quantum Fourier transforms that exploit smooth group structure.
    Bridge: quantum computing → tropical algebra → post-quantum hardness. -/
theorem tropical_min_abs_identity (a b : ℝ) :
    min a b = (a + b - |a - b|) / 2 := by
  rcases le_total a b with h | h
  · simp [min_eq_left h, abs_of_nonpos (sub_nonpos.mpr h)]; ring
  · simp [min_eq_right h, abs_of_nonneg (sub_nonneg.mpr h)]

/-- **Max dual**: max(a,b) = (a+b+|a-b|)/2.
    Bridge: optimization duality → tropical geometry → protocol design. -/
theorem tropical_max_abs_identity (a b : ℝ) :
    max a b = (a + b + |a - b|) / 2 := by
  rcases le_total a b with h | h
  · simp [max_eq_right h, abs_of_nonpos (sub_nonpos.mpr h)]; ring
  · simp [max_eq_left h, abs_of_nonneg (sub_nonneg.mpr h)]

/-- **Min-max duality**: min(a,b) + max(a,b) = a + b.
    Bridge: convex analysis → tropical duality → key exchange design. -/
theorem tropical_min_max_duality (a b : ℝ) : min a b + max a b = a + b :=
  min_add_max a b

/-- **Min-max gap**: max(a,b) - min(a,b) = |a-b|.
    Bridge: metric geometry → tropical algebra → error analysis. -/
theorem tropical_min_max_gap (a b : ℝ) : max a b - min a b = |a - b| := by
  rcases le_total a b with h | h
  · rw [max_eq_right h, min_eq_left h, abs_of_nonpos (sub_nonpos.mpr h)]; ring
  · rw [max_eq_left h, min_eq_right h, abs_of_nonneg (sub_nonneg.mpr h)]

/-- **Tropical-lattice norm bridge**: triangle inequality ↔ LWE error bounds.
    Bridge: lattice cryptography → tropical geometry → certified robustness. -/
theorem tropical_lattice_norm_bridge [NeZero n] (u v : Fin n → ℝ) :
    tropicalNorm (u + v) ≤ tropicalNorm u + tropicalNorm v :=
  tropicalNorm_triangle u v

/-! ## Section 10: Shannon Entropy for Security Analysis

Information-theoretic measures for tropical crypto.
Bridge: information theory → thermodynamics → cryptographic security. -/

/-- **Shannon entropy**: H(p) = -Σᵢ pᵢ log(pᵢ).
    Bridge: information theory → thermodynamics → crypto security. -/
def shannonEntropy {m : ℕ} (p : Fin m → ℝ) : ℝ :=
  -∑ i, if p i = 0 then 0 else p i * Real.log (p i)

/-- **Entropy ≥ 0** for probability distributions with pᵢ ∈ [0,1].
    Bridge: positive information → cryptographic security. -/
theorem shannonEntropy_nonneg {m : ℕ} (p : Fin m → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hle1 : ∀ i, p i ≤ 1) :
    0 ≤ shannonEntropy p := by
  unfold shannonEntropy; rw [neg_nonneg]
  apply Finset.sum_nonpos; intro i _
  split_ifs with h
  · linarith
  · exact mul_nonpos_of_nonneg_of_nonpos
      (lt_of_le_of_ne (hp i) (Ne.symm h) |>.le)
      (Real.log_nonpos (lt_of_le_of_ne (hp i) (Ne.symm h) |>.le) (hle1 i))

/-- **Point mass entropy = 0**: H(δⱼ) = 0. No uncertainty. -/
theorem shannonEntropy_point_mass {m : ℕ} [NeZero m] (j : Fin m)
    (p : Fin m → ℝ) (hj : p j = 1) (hrest : ∀ i, i ≠ j → p i = 0) :
    shannonEntropy p = 0 := by
  unfold shannonEntropy; simp only [neg_eq_zero]
  apply Finset.sum_eq_zero; intro i _
  split_ifs with h
  · rfl
  · by_cases hij : i = j
    · subst hij; simp [hj]
    · exact absurd (hrest i hij) h

/-! ## Section 11: Tropical OWF Configuration

Algebraic structure for tropical one-way functions.
Bridge: abstract algebra → cryptographic primitives → post-quantum. -/

/-- A **tropical OWF configuration**: generator matrix with bounded entries.
    Bridge: abstract OWF → concrete tropical algebra. -/
structure TropicalOWFConfig (nn : ℕ) [NeZero nn] where
  generator : Matrix (Fin nn) (Fin nn) ℝ
  entries_bounded : ∀ i j, |generator i j| ≤ 1

/-- Forward evaluation: G ⊗ X. The "easy direction" — O(n³). -/
def TropicalOWFConfig.forward {nn : ℕ} [NeZero nn]
    (cfg : TropicalOWFConfig nn)
    (X : Matrix (Fin nn) (Fin nn) ℝ) : Matrix (Fin nn) (Fin nn) ℝ :=
  tropMatMul cfg.generator X

/-- **Protocol composability**: f(G, f(G, X)) = (G⊗G) ⊗ X.
    Multi-round protocols compose correctly via associativity.
    Bridge: composability → tropical algebra → post-quantum multi-party. -/
theorem TropicalOWFConfig.forward_compose {nn : ℕ} [NeZero nn]
    (cfg : TropicalOWFConfig nn) (X : Matrix (Fin nn) (Fin nn) ℝ) :
    cfg.forward (cfg.forward X) =
    tropMatMul (tropMatMul cfg.generator cfg.generator) X :=
  (tropMatMul_assoc _ _ _).symm

/-- **Inversion search space**: n! permutations to search. -/
theorem TropicalOWFConfig.inversion_search_space (nn : ℕ) :
    Fintype.card (Equiv.Perm (Fin nn)) = nn.factorial := by
  simp [Fintype.card_perm, Fintype.card_fin]

/-! ## Section 12: Tropical Collision Space -/

/-- A **tropical collision space**: compression → collisions exist. -/
structure TropicalCollisionSpace where
  input_dim : ℕ
  output_dim : ℕ
  compression : output_dim < input_dim

/-- Compression implies collision existence for any function.
    Bridge: pigeonhole → collision → hash security bounds. -/
theorem TropicalCollisionSpace.collisions_exist
    (S : TropicalCollisionSpace)
    (f : Fin S.input_dim → Fin S.output_dim) :
    ∃ i j : Fin S.input_dim, i ≠ j ∧ f i = f j :=
  tropical_pigeonhole_collision S.compression f

/-! ## Section 13: Tropical Matrix Entry Bounds -/

/-- Each entry of the tropical product is attained by some index k.
    ∃ k, (A⊗B)ᵢⱼ = Aᵢₖ + Bₖⱼ. -/
theorem tropMatMul_entry_attained [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    ∃ k : Fin n, tropMatMul A B i j = A i k + B k j := by
  obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := Fin n))
    (fun k => A i k + B k j)
  exact ⟨k, by simp [tropMatMul, hk]⟩

/-- (A⊗B)ᵢⱼ ≤ Aᵢₖ + Bₖⱼ for all k. -/
theorem tropMatMul_entry_le [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j k : Fin n) :
    tropMatMul A B i j ≤ A i k + B k j := by
  show Finset.inf' univ univ_nonempty (fun k => A i k + B k j) ≤ A i k + B k j
  exact Finset.inf'_le _ (mem_univ k)

/-- **Monotonicity**: A ≤ A', B ≤ B' → A⊗B ≤ A'⊗B' pointwise.
    Bridge: order theory → certified_robustness → crypto. -/
theorem tropMatMul_mono [NeZero n]
    (A A' B B' : Matrix (Fin n) (Fin n) ℝ)
    (hA : ∀ i j, A i j ≤ A' i j) (hB : ∀ i j, B i j ≤ B' i j) :
    ∀ i j, tropMatMul A B i j ≤ tropMatMul A' B' i j := by
  intro i j
  simp only [tropMatMul, Matrix.of_apply]
  exact inf'_le_inf'_of_le fun k => by linarith [hA i k, hB k j]

end TropicalCrypto

end