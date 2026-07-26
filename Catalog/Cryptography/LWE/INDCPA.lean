import Mathlib

/-!
# A Game-Hopping Security Theorem for LWE Encryption

This file formalizes the quantitative core of the IND-CPA proof for Regev-style
LWE encryption.  Ciphertext ensembles are represented by their probability mass
functions on a finite transcript space.  Their `ℓ¹` gap is twice statistical
distance.  The main theorem says that if encryption of either challenge bit can
be replaced by the same message-independent ideal ensemble with respective
losses `ε₀` and `ε₁`, then the IND-CPA gap is at most `ε₀ + ε₁`.

This isolates the exact final game hop used after an LWE assumption has replaced
public-key samples and ciphertext inner products by uniform values.  A second
result proves the general hybrid lemma and its linear-loss corollary.
-/

open Finset BigOperators

noncomputable section

namespace LWE

/-- A probability mass function on a finite transcript space. -/
structure FinitePMF (Ω : Type*) [Fintype Ω] where
  mass : Ω → ℝ
  nonneg : ∀ x, 0 ≤ mass x
  sum_mass : ∑ x, mass x = 1

/-- The `ℓ¹` gap between finite ensembles (twice their statistical distance). -/
def l1Gap {Ω : Type*} [Fintype Ω] (P Q : FinitePMF Ω) : ℝ :=
  ∑ x, |P.mass x - Q.mass x|

/-- The `ℓ¹` gap is nonnegative. -/
theorem l1Gap_nonneg {Ω : Type*} [Fintype Ω] (P Q : FinitePMF Ω) :
    0 ≤ l1Gap P Q := by
  simp only [l1Gap]
  apply Finset.sum_nonneg
  intro x _
  exact abs_nonneg _

/-- The `ℓ¹` gap is symmetric. -/
theorem l1Gap_symm {Ω : Type*} [Fintype Ω] (P Q : FinitePMF Ω) :
    l1Gap P Q = l1Gap Q P := by
  simp [l1Gap, abs_sub_comm]

/-- Triangle inequality for finite statistical experiments. -/
theorem l1Gap_triangle {Ω : Type*} [Fintype Ω] (P Q R : FinitePMF Ω) :
    l1Gap P R ≤ l1Gap P Q + l1Gap Q R := by
  simp only [l1Gap]
  rw [← sum_add_distrib]
  exact Finset.sum_le_sum fun x _ => abs_sub_le _ _ _

/-- The two challenge ciphertext ensembles of an encryption experiment. -/
structure EncryptionExperiment (Ω : Type*) [Fintype Ω] where
  challenge : Bool → FinitePMF Ω

/-- IND-CPA distinguishing gap, in the `ℓ¹` normalization. -/
def indCPAGap {Ω : Type*} [Fintype Ω] (E : EncryptionExperiment Ω) : ℝ :=
  l1Gap (E.challenge false) (E.challenge true)

/-- **LWE replacement implies IND-CPA security.**

If both challenge-bit games are close to one common, message-independent ideal
game, then the challenge distributions are close to each other.  In a concrete
Regev proof, the two hypotheses are supplied by the decisional-LWE game hop;
the ideal distribution does not contain the challenge bit. -/
theorem indCPA_of_common_ideal {Ω : Type*} [Fintype Ω]
    (E : EncryptionExperiment Ω) (ideal : FinitePMF Ω) (ε₀ ε₁ : ℝ)
    (hzero : l1Gap (E.challenge false) ideal ≤ ε₀)
    (hone : l1Gap (E.challenge true) ideal ≤ ε₁) :
    indCPAGap E ≤ ε₀ + ε₁ := by
  have h := l1Gap_triangle (E.challenge false) ideal (E.challenge true)
  simp only [l1Gap_symm ideal (E.challenge true)] at h
  exact le_trans h (add_le_add hzero hone)

/-- A chain of game hops accumulates at most the sum of its adjacent gaps. -/
theorem hybrid_l1Gap {Ω : Type*} [Fintype Ω] (G : ℕ → FinitePMF Ω) :
    ∀ k : ℕ, l1Gap (G 0) (G k) ≤ ∑ i ∈ range k, l1Gap (G i) (G (i + 1)) := by
  intro k
  induction k with
  | zero =>
    simp [l1Gap]
  | succ k ih =>
    calc l1Gap (G 0) (G (k + 1))
        ≤ l1Gap (G 0) (G k) + l1Gap (G k) (G (k + 1)) := l1Gap_triangle _ _ _
      _ ≤ ∑ i ∈ range k, l1Gap (G i) (G (i + 1)) + l1Gap (G k) (G (k + 1)) := by exact add_le_add_left ih _
      _ = ∑ i ∈ range (k + 1), l1Gap (G i) (G (i + 1)) := by simp [Finset.sum_range_succ]

/-- If every one of `k` game hops costs at most `ε`, the total cost is at most
`kε`.  This is the standard quantitative hybrid lemma used when replacing LWE
samples one at a time. -/
theorem hybrid_l1Gap_linear {Ω : Type*} [Fintype Ω]
    (G : ℕ → FinitePMF Ω) (k : ℕ) (ε : ℝ)
    (hhop : ∀ i < k, l1Gap (G i) (G (i + 1)) ≤ ε) :
    l1Gap (G 0) (G k) ≤ k * ε := by
  exact le_trans (hybrid_l1Gap G k) (by simpa [Finset.card_range] using Finset.sum_le_card_nsmul (Finset.range k) _ _ fun i hi => hhop i (Finset.mem_range.mp hi))

/-- Combining a `k`-hop LWE replacement on each challenge branch gives a
`2kε` IND-CPA bound. -/
theorem indCPA_of_symmetric_lwe_hybrids {Ω : Type*} [Fintype Ω]
    (E : EncryptionExperiment Ω) (ideal : FinitePMF Ω)
    (G₀ G₁ : ℕ → FinitePMF Ω) (k : ℕ) (ε : ℝ)
    (h₀start : G₀ 0 = E.challenge false) (h₀end : G₀ k = ideal)
    (h₁start : G₁ 0 = E.challenge true) (h₁end : G₁ k = ideal)
    (h₀hop : ∀ i < k, l1Gap (G₀ i) (G₀ (i + 1)) ≤ ε)
    (h₁hop : ∀ i < k, l1Gap (G₁ i) (G₁ (i + 1)) ≤ ε) :
    indCPAGap E ≤ 2 * (k * ε) := by
  have hbound₀ : l1Gap (G₀ 0) ideal ≤ k * ε := by
    have step1 : l1Gap (G₀ 0) ideal = l1Gap (G₀ 0) (G₀ k) := by rw [h₀end]
    rw [step1]
    exact le_trans (hybrid_l1Gap G₀ k)
      (by simpa [Finset.card_range] using Finset.sum_le_card_nsmul (Finset.range k) _ _ fun i hi => h₀hop i (Finset.mem_range.mp hi))
  have hbound₁ : l1Gap (G₁ 0) ideal ≤ k * ε := by
    have step1 : l1Gap (G₁ 0) ideal = l1Gap (G₁ 0) (G₁ k) := by rw [h₁end]
    rw [step1]
    exact le_trans (hybrid_l1Gap G₁ k)
      (by simpa [Finset.card_range] using Finset.sum_le_card_nsmul (Finset.range k) _ _ fun i hi => h₁hop i (Finset.mem_range.mp hi))
  calc indCPAGap E = l1Gap (E.challenge false) (E.challenge true) := rfl
    _ = l1Gap (G₀ 0) (G₁ 0) := by rw [h₀start, h₁start]
    _ ≤ l1Gap (G₀ 0) ideal + l1Gap (G₁ 0) ideal := by
        have := l1Gap_triangle (G₀ 0) ideal (G₁ 0); simpa [l1Gap_symm ideal (G₁ 0)] using this
    _ ≤ k * ε + k * ε := add_le_add hbound₀ hbound₁
    _ = 2 * (k * ε) := by ring

/-! ## Kernel-checked small-case evidence

For the deterministic distributions on `Bool`, the opposite point masses have
`ℓ¹` gap `2`, while identical point masses have gap `0`.  These examples check
the normalization and edge cases used by the general theorem.
-/

def boolPoint (b : Bool) : FinitePMF Bool where
  mass x := if x = b then 1 else 0
  nonneg x := by split_ifs <;> norm_num
  sum_mass := by cases b <;> norm_num [Fintype.sum_bool]

example : l1Gap (boolPoint false) (boolPoint true) = 2 := by
  norm_num [l1Gap, boolPoint, Fintype.sum_bool]

example (b : Bool) : l1Gap (boolPoint b) (boolPoint b) = 0 := by
  simp [l1Gap]

end LWE

end

#print axioms LWE.indCPA_of_common_ideal
#print axioms LWE.hybrid_l1Gap
#print axioms LWE.hybrid_l1Gap_linear
#print axioms LWE.indCPA_of_symmetric_lwe_hybrids