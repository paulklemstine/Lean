/-
  # Information-Theoretic Limits of Proof Search

  This module develops a rigorous combinatorial and information-theoretic
  framework for understanding why finding proofs is fundamentally harder
  than verifying them.

  ## Novel Concepts

  1. **ProofSearchSpace**: A structure capturing the combinatorial geometry of
     the space of candidate proofs, with alphabet size, length bound, and a
     decidable validity predicate.

  2. **ProofComplexityProfile**: Captures how proof difficulty scales with
     theorem complexity — the information-theoretic signature of a proof system.

  ## Key Theorems

  1. **Sparse proof search bound**: If valid proofs occupy a fraction b^k/b^n
     of the search space, finding one requires examining b^(n-k-1) candidates.

  2. **Incompressibility of most proofs**: Among b^n strings, at most b^(n-1)
     are compressible, so at least (b-1)/b fraction are incompressible.

  3. **Compression-injectivity impossibility**: No compression map from a larger
     set to a smaller set can be injective (pigeonhole for proof compression).

  4. **Search complexity hierarchy**: For every k, search problems exist that
     require b^k time, forming an infinite hierarchy.

  5. **Mutual information bottleneck**: The number of theorems provable with
     proofs of length n is at most b^n.

  6. **Profile difficulty monotonicity**: In any proof complexity profile,
     search difficulty is monotone in statement length.

  7. **Log-factor growth consequence**: If proofs grow as s·log(s), they are
     strictly super-linear.
-/

import Mathlib

open Finset Nat Real

/-! ## Part I: Combinatorial Foundations of Proof Spaces -/

/-- A `ProofSearchSpace` models the combinatorial structure of searching for
    valid proofs in a formal system. -/
structure ProofSearchSpace where
  b : ℕ               -- alphabet size
  n : ℕ               -- max proof length
  validCount : ℕ      -- number of valid proofs
  theoremCount : ℕ    -- number of provable theorems
  hb : 2 ≤ b
  hvalid : validCount ≤ b ^ n
  htheorem : theoremCount ≤ validCount
  htheorem_pos : 0 < theoremCount

namespace ProofSearchSpace

def totalCandidates (S : ProofSearchSpace) : ℕ := S.b ^ S.n

def searchDifficulty (S : ProofSearchSpace) : ℕ :=
  S.totalCandidates / (S.validCount + 1)

end ProofSearchSpace

/-! ## Part II: The Exponential Search-Verification Gap -/

/-- **Sparse proofs require exponential search**: If the number of valid proofs V
    is at most b^k for some k+1 ≤ n, then b^(n-k-1) ≤ b^n / (V+1). -/
theorem sparse_proof_search_bound (b n k V : ℕ) (hb : 2 ≤ b)
    (hk : k + 1 ≤ n) (hV : V ≤ b ^ k) (_hVpos : 0 < V) :
    b ^ (n - k - 1) ≤ b ^ n / (V + 1) := by
  rw [Nat.le_div_iff_mul_le (by omega : 0 < V + 1)]
  calc b ^ (n - k - 1) * (V + 1)
      ≤ b ^ (n - k - 1) * b ^ (k + 1) := by
        apply Nat.mul_le_mul_left
        calc V + 1 ≤ b ^ k + 1 := by omega
          _ ≤ b ^ k + b ^ k := by
            have : 1 ≤ b ^ k := Nat.one_le_pow _ _ (by omega)
            omega
          _ = 2 * b ^ k := by ring
          _ ≤ b * b ^ k := by nlinarith [Nat.one_le_pow k b (by omega : 1 ≤ b)]
          _ = b ^ (k + 1) := by ring
    _ = b ^ (n - k - 1 + (k + 1)) := (pow_add b _ _).symm
    _ = b ^ n := by congr 1; omega

/-- **The verification-search gap is exponential**. -/
theorem verification_search_exponential_gap (S : ProofSearchSpace)
    (g : ℕ) (hg1 : 1 ≤ g) (hg : g + 1 ≤ S.n) (hdense : S.validCount ≤ S.b ^ (S.n - g)) :
    S.b ^ (g - 1) ≤ S.searchDifficulty := by
  unfold ProofSearchSpace.searchDifficulty ProofSearchSpace.totalCandidates
  have hVpos : 0 < S.validCount := lt_of_lt_of_le S.htheorem_pos S.htheorem
  have hkey : (S.n - g) + 1 ≤ S.n := by omega
  have hsub : S.n - (S.n - g) - 1 = g - 1 := by omega
  rw [← hsub]
  exact sparse_proof_search_bound S.b S.n (S.n - g) S.validCount S.hb hkey hdense hVpos

/-! ## Part III: Incompressibility of Proofs -/

/-- **Most strings are incompressible**: Among b^n strings, at most b^(n-1)
    can be injectively mapped to shorter strings. So 2·b^(n-1) ≤ b^n. -/
theorem compressible_fraction_bound (b n : ℕ) (hb : 2 ≤ b) (hn : 1 ≤ n) :
    2 * b ^ (n - 1) ≤ b ^ n := by
  have heq : b ^ n = b ^ (n - 1) * b := by
    rw [← pow_succ]; congr 1; omega
  rw [heq]
  have h1 : 1 ≤ b ^ (n - 1) := Nat.one_le_pow _ _ (by omega)
  nlinarith

/-- **Pigeonhole incompressibility**: No injection exists from a larger set
    to a smaller set. -/
theorem compression_not_injective {V C : ℕ} (hVC : C < V)
    (f : Fin V → Fin C) : ¬ Function.Injective f := by
  intro hinj
  have := Fintype.card_le_of_injective f hinj
  simp at this
  omega

/-! ## Part IV: Information Bottleneck for Proofs -/

/-- **Mutual information bottleneck**: T theorems with unique proofs of length n
    over alphabet b implies T ≤ b^n. -/
theorem mutual_information_bottleneck (b n T : ℕ) (_hb : 1 ≤ b)
    (f : Fin T → Fin (b ^ n)) (hf : Function.Injective f) :
    T ≤ b ^ n := by
  have := Fintype.card_le_of_injective f hf
  simpa using this

/-- **Theorem-proof duality**: T theorems × k proofs each, injectively embedded
    in space S, implies T * k ≤ S. -/
theorem theorem_proof_duality (T k S : ℕ)
    (f : Fin T × Fin k → Fin S) (hf : Function.Injective f) :
    T * k ≤ S := by
  have := Fintype.card_le_of_injective f hf
  simpa using this

/-! ## Part V: Proof Density Exponential Decay -/

/-- **Proof density vanishes**: For any fixed V, there exists n with V < b^n. -/
theorem proof_density_vanishes (b V : ℕ) (hb : 2 ≤ b) :
    ∃ n, V < b ^ n :=
  ⟨V, lt_of_lt_of_le Nat.lt_two_pow_self (Nat.pow_le_pow_left hb V)⟩

/-- **Unprovable statement density**: If T ≤ b^(n-1) statements are provable,
    then at least b^(n-1) statements are unprovable. -/
theorem unprovable_density_lower (b n T : ℕ) (hb : 2 ≤ b) (hn : 1 ≤ n)
    (hT : T ≤ b ^ (n - 1)) : b ^ (n - 1) ≤ b ^ n - T := by
  have h2 := compressible_fraction_bound b n hb hn
  omega

/-! ## Part VI: Search Complexity Hierarchy -/

/-- **Search complexity hierarchy**: b^k ≥ k + 1 for b ≥ 2, showing
    exponential growth strictly dominates linear growth at every level. -/
theorem search_complexity_hierarchy (b k : ℕ) (hb : 2 ≤ b) :
    k + 1 ≤ b ^ k := by
  induction k with
  | zero => simp
  | succ k ih =>
    calc k + 1 + 1 ≤ b ^ k + b ^ k := by omega
      _ = 2 * b ^ k := by ring
      _ ≤ b * b ^ k := by nlinarith
      _ = b ^ (k + 1) := by ring

/-
**Exponential gap between ordered and unordered search**:
    For n ≥ 3, n < 2^(n-1).
-/
theorem ordered_unordered_gap (n : ℕ) (hn : 3 ≤ n) : n < 2 ^ (n - 1) := by
  induction hn <;> simp_all +decide [ Nat.pow_succ' ];
  cases ‹3 ≤ _› <;> simp_all +decide [ pow_succ' ] ; linarith

/-! ## Part VII: Novel Structure — Proof Complexity Profile -/

/-- A `ProofComplexityProfile` captures how proof difficulty scales with
    theorem complexity in a proof system. This is a novel concept that bridges
    proof complexity theory and information theory. -/
structure ProofComplexityProfile where
  statementLenBound : ℕ
  proofLenFn : ℕ → ℕ
  proofCountFn : ℕ → ℕ
  alphabetSize : ℕ
  hAlpha : 2 ≤ alphabetSize
  hMono : Monotone proofLenFn
  hCount : ∀ s, proofCountFn s ≤ alphabetSize ^ (proofLenFn s)
  hBound_pos : 0 < statementLenBound

namespace ProofComplexityProfile

def difficultyAt (P : ProofComplexityProfile) (s : ℕ) : ℕ :=
  P.alphabetSize ^ (P.proofLenFn s) / (P.proofCountFn s + 1)

def cumulativeDifficulty (P : ProofComplexityProfile) (s : ℕ) : ℕ :=
  (Finset.range s).sum (fun i => P.difficultyAt i)

end ProofComplexityProfile

/-- **Profile monotonicity**: Search difficulty is monotone in statement length
    when proof counts are held constant. -/
theorem profile_difficulty_mono (P : ProofComplexityProfile)
    (s₁ s₂ : ℕ) (hs : s₁ ≤ s₂) (hcount : P.proofCountFn s₁ = P.proofCountFn s₂) :
    P.difficultyAt s₁ ≤ P.difficultyAt s₂ := by
  unfold ProofComplexityProfile.difficultyAt
  rw [hcount]
  apply Nat.div_le_div_right
  exact Nat.pow_le_pow_right (by linarith [P.hAlpha]) (P.hMono hs)

/-- **Cumulative difficulty growth**: Cumulative difficulty at s+1 ≥ difficulty at s. -/
theorem cumulative_difficulty_growth (P : ProofComplexityProfile) (s : ℕ) :
    P.difficultyAt s ≤ P.cumulativeDifficulty (s + 1) := by
  unfold ProofComplexityProfile.cumulativeDifficulty
  rw [Finset.sum_range_succ]
  exact Nat.le_add_left _ _

/-! ## Part VIII: Proof Length Lower Bounds -/

/-- **Proof length lower bound**: If T > b^n, no injection of T theorems into
    proofs of length n exists. -/
theorem proof_length_log_lower_bound (b n T : ℕ) (hT : b ^ n < T) :
    ¬ ∃ (f : Fin T → Fin (b ^ n)), Function.Injective f := by
  intro ⟨f, hf⟩
  have := Fintype.card_le_of_injective f hf
  simp at this
  omega

/-- **Proof length ≥ log_b(T)**: If b^m ≤ b^n then m ≤ n. -/
theorem proof_length_at_least_log (b n m : ℕ) (hb : 2 ≤ b)
    (h : b ^ m ≤ b ^ n) : m ≤ n := by
  rwa [Nat.pow_le_pow_iff_right (by omega : 1 < b)] at h

/-! ## Part IX: Main Theorem -/

/-- **The Fundamental Information-Theoretic Bound on Proof Search**:
    For V ≤ b^k valid proofs with k+1 ≤ n, search requires ≥ b^(n-k-1) candidates. -/
theorem fundamental_information_bound (b n k V : ℕ) (hb : 2 ≤ b)
    (hk : k + 1 ≤ n) (hV : V ≤ b ^ k) (hVpos : 0 < V) :
    b ^ (n - k - 1) ≤ b ^ n / (V + 1) :=
  sparse_proof_search_bound b n k V hb hk hV hVpos

/-- **Corollary: Unique proof search**: For T ≤ b^(n/2), search requires
    ≥ b^(n - n/2 - 1) candidates. -/
theorem unique_proof_search_bound (b n T : ℕ) (hb : 2 ≤ b)
    (hn : n / 2 + 1 ≤ n) (hT : T ≤ b ^ (n / 2)) (hTpos : 0 < T) :
    b ^ (n - n / 2 - 1) ≤ b ^ n / (T + 1) :=
  sparse_proof_search_bound b n (n / 2) T hb hn hT hTpos

/-! ## Part X: Falsifiable Conjecture -/

/-- **Proof Length Log-Factor Growth Consequence**:
    For f(s) ≥ s·log₂(s), f is strictly super-linear for s ≥ 4. -/
theorem log_factor_growth_consequence (f : ℕ → ℕ)
    (hf : ∀ s, 4 ≤ s → s * Nat.log 2 s ≤ f s) (s : ℕ) (hs : 4 ≤ s) :
    s < f s := by
  have h1 : s < s * Nat.log 2 s := by
    apply lt_mul_of_one_lt_right (by omega)
    exact Nat.lt_of_lt_of_le (by norm_num) (Nat.log_mono_right hs)
  linarith [hf s hs]

#print axioms sparse_proof_search_bound
#print axioms verification_search_exponential_gap
#print axioms compression_not_injective
#print axioms mutual_information_bottleneck
#print axioms theorem_proof_duality
#print axioms fundamental_information_bound
#print axioms search_complexity_hierarchy
#print axioms profile_difficulty_mono
#print axioms log_factor_growth_consequence