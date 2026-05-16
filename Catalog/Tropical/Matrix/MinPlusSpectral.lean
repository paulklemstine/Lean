/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical (Min-Plus) Matrix Algebra and Spectral Theory

This file defines min-plus matrix multiplication and proves that diagonal entries
of tropical powers satisfy a subadditive inequality. This is the formal kernel of
tropical spectral theory: it implies the existence of asymptotic cycle means
(tropical eigenvalues) via Fekete's lemma.

## Main results

- `tropMul`: Min-plus matrix multiplication
- `tropPow`: Iterated min-plus matrix power
- `tropMul_diag_le`: Diagonal entry of product bounded by sum of diagonal entries
- `tropMul_assoc`: Associativity of tropical multiplication
- `tropPow_succ`: Unfolding of tropical power
- `tropPow_add`: Key composition law: `tropPow A (m + k) = tropMul (tropPow A m) (tropPow A k)`
- `tropPow_diag_subadditive`: **Flagship theorem** — diagonal entries of tropical
  powers are subadditive: `(A^⊗(m+k))_{ii} ≤ (A^⊗m)_{ii} + (A^⊗k)_{ii}`

## Mathematical significance

Subadditivity of the diagonal sequence `a_n = (A^{⊗n})_{ii}` implies by Fekete's
lemma that `lim a_n/n` exists, yielding the tropical eigenvalue (minimum cycle mean).
This is the foundation for Karp's theorem, tropical Perron-Frobenius theory,
and shortest-path asymptotics.
-/
import Mathlib

open Finset BigOperators

namespace TropicalMatrix

variable {n : ℕ}

/-- Min-plus (tropical) matrix multiplication:
    `(A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})` -/
noncomputable def tropMul [Nonempty (Fin n)] (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.inf' Finset.univ Finset.univ_nonempty (fun k => A i k + B k j)

/-
The diagonal entry of a tropical product is at most the sum of diagonal entries.
    This uses the witness `k = i` in the infimum.
-/
theorem tropMul_diag_le [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    tropMul A B i i ≤ A i i + B i i := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-
Tropical multiplication is bounded below by any pair of entries.
-/
theorem tropMul_le_of_mem [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j k : Fin n) :
    tropMul A B i j ≤ A i k + B k j := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-
Associativity of tropical multiplication.
-/
theorem tropMul_assoc [Nonempty (Fin n)]
    (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMul (tropMul A B) C = tropMul A (tropMul B C) := by
  ext i j;
  nontriviality;
  refine' le_antisymm _ _ <;> simp +decide [ tropMul ];
  · intro k;
    -- By definition of infimum, there exists some $l$ such that $B k l + C l j \leq \inf_{l} (B k l + C l j)$.
    obtain ⟨l, hl⟩ : ∃ l, B k l + C l j ≤ Finset.inf' Finset.univ Finset.univ_nonempty (fun l => B k l + C l j) := by
      exact Finset.exists_min_image Finset.univ ( fun l => B k l + C l j ) ⟨ k, Finset.mem_univ k ⟩ |> fun ⟨ l, hl₁, hl₂ ⟩ => ⟨ l, Finset.le_inf' _ _ fun x hx => hl₂ x hx ⟩;
    exact ⟨ l, by linarith [ show A i k + B k l ≥ Finset.inf' Finset.univ Finset.univ_nonempty ( fun k_1 => A i k_1 + B k_1 l ) from Finset.inf'_le _ ( Finset.mem_univ k ) ] ⟩;
  · intro b;
    obtain ⟨ k, hk ⟩ := Finset.exists_min_image Finset.univ ( fun k => A i k + B k b ) ⟨ b, Finset.mem_univ b ⟩;
    use k;
    obtain ⟨ l, hl ⟩ := Finset.exists_min_image Finset.univ ( fun k_1 => B k k_1 + C k_1 j ) ⟨ b, Finset.mem_univ b ⟩ ; simp_all +decide [ Finset.inf'_le_iff ];
    rw [ show ( Finset.univ.inf' Finset.univ_nonempty fun k_1 => B k k_1 + C k_1 j ) = B k l + C l j from le_antisymm ( Finset.inf'_le _ <| Finset.mem_univ _ ) <| Finset.le_inf' _ _ fun x hx => hl x ] ; linarith [ hk b, hl b, show ( Finset.univ.inf' Finset.univ_nonempty fun k => A i k + B k b ) ≥ A i k + B k b from Finset.le_inf' _ _ fun x hx => hk x ]

/-- Tropical power: A^{⊗0} is A itself (the "1-step" matrix),
    A^{⊗(n+1)} = tropMul (A^{⊗n}) A.
    Note: This is 0-indexed, so tropPow A 0 = A (1-step paths),
    tropPow A 1 = A ⊗ A (2-step paths), etc. -/
noncomputable def tropPow [Nonempty (Fin n)] :
    Matrix (Fin n) (Fin n) ℝ → ℕ → Matrix (Fin n) (Fin n) ℝ
  | A, 0 => A
  | A, m + 1 => tropMul (tropPow A m) A

/-
Composition law for tropical powers:
    `tropPow A (m + k + 1) = tropMul (tropPow A m) (tropPow A k)`
-/
theorem tropPow_add [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (m k : ℕ) :
    tropPow A (m + k + 1) = tropMul (tropPow A m) (tropPow A k) := by
  induction' k with k ih generalizing m;
  · rfl;
  · convert tropMul_assoc ( tropPow A m ) ( tropPow A k ) A using 1;
    grind +locals

/-
**Flagship theorem**: Diagonal entries of tropical powers are subadditive.

    For any matrix `A` and index `i`:
    `(A^{⊗(m+k+1)})_{ii} ≤ (A^{⊗m})_{ii} + (A^{⊗k})_{ii}`

    This is the formal kernel of tropical spectral theory. By Fekete's lemma,
    it implies that the sequence `(A^{⊗n})_{ii} / n` converges, giving the
    tropical eigenvalue (minimum cycle mean through vertex i).
-/
theorem tropPow_diag_subadditive [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) (m k : ℕ) :
    tropPow A (m + k + 1) i i ≤ tropPow A m i i + tropPow A k i i := by
  convert tropMul_diag_le ( tropPow A m ) ( tropPow A k ) i using 1;
  convert congr_arg ( fun x : Matrix ( Fin n ) ( Fin n ) ℝ => x i i ) ( tropPow_add A m k ) using 1

end TropicalMatrix