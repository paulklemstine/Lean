/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical (Min-Plus) Matrix Algebra

This file develops the theory of min-plus matrix multiplication over ℝ,
where the "tropical product" of matrices A and B is defined by
  (A ⊗ B)ᵢⱼ = ⨅ k, (Aᵢₖ + Bₖⱼ).

The main results are:
- `tropMul_diag_le`: The diagonal of a tropical product satisfies
    (A ⊗ B)ᵢᵢ ≤ Aᵢᵢ + Bᵢᵢ
- `tropMul_assoc`: Tropical multiplication is associative
- `tropPow_add`: Power-splitting: A^⊗(m+k+1) = A^⊗m ⊗ A^⊗k
    (using 0-indexed powers where tropPow A m = A^(m+1))
- `tropPow_diag_subadditive`: Diagonal entries of tropical powers are subadditive

These are foundational results for tropical spectral theory, connecting to
cycle-mean theory and shortest-path algorithms.
-/
import Mathlib

open BigOperators

variable {n : ℕ}

/-- Min-plus (tropical) matrix multiplication:
    `(tropMul A B) i j = ⨅ k, (A i k + B k j)`. -/
noncomputable def tropMul (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => ⨅ k : Fin n, (A i k + B k j)

/-- Tropical matrix power (0-indexed): `tropPow A m` represents the (m+1)-fold
    tropical product A ⊗ A ⊗ ⋯ ⊗ A. We avoid the tropical identity matrix
    (which requires +∞ off-diagonal) by starting from A itself. -/
noncomputable def tropPow (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => A
  | m + 1 => tropMul (tropPow A m) A

/-! ## Basic properties of tropical infimum -/

/-
The tropical product at (i,j) is at most A i k + B k j for any k.
-/
theorem tropMul_le_of_witness [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) (k : Fin n) :
    tropMul A B i j ≤ A i k + B k j := by
  exact ciInf_le ( Finite.bddBelow_range fun x => A i x + B x j ) k

/-! ## Diagonal bound -/

/-- Key lemma: the diagonal of a tropical product is bounded by the sum of diagonals.
    This follows because k = i is one possible witness in the infimum. -/
theorem tropMul_diag_le [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    tropMul A B i i ≤ A i i + B i i :=
  tropMul_le_of_witness A B i i i

/-! ## Associativity -/

/-
Tropical multiplication is associative:
    `tropMul (tropMul A B) C = tropMul A (tropMul B C)`.
    Both sides equal `⨅ k, ⨅ l, (A i k + B k l + C l j)`.
-/
theorem tropMul_assoc [Nonempty (Fin n)]
    (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMul (tropMul A B) C = tropMul A (tropMul B C) := by
  by_contra h_neq;
  -- By definition of tropical multiplication, we have:
  have h_def : ∀ i j, tropMul (tropMul A B) C i j = ⨅ k, ⨅ l, (A i l + B l k + C k j) ∧ tropMul A (tropMul B C) i j = ⨅ l, ⨅ k, (A i l + B l k + C k j) := by
    intro i j; constructor <;> simp +decide [ add_assoc, tropMul ] ; simp +decide [ add_assoc, ciInf_add ];
    congr! 1;
    ext l; rw [ ← add_comm, @ciInf_add ] ;
    · ac_rfl;
    · exact Set.finite_range _ |> Set.Finite.bddBelow;
  refine' h_neq ( funext fun i => funext fun j => _ );
  rw [ h_def i j |>.1, h_def i j |>.2 ];
  -- Apply the commutativity of infimum over finite types.
  apply le_antisymm;
  · refine' le_csInf _ _;
    · exact ⟨ _, ⟨ i, rfl ⟩ ⟩;
    · simp +zetaDelta at *;
      intro a;
      refine' ciInf_mono _ _;
      · exact Set.finite_range _ |> Set.Finite.bddBelow;
      · exact fun x => ciInf_le ( Finite.bddBelow_range fun l => A i l + B l x + C x j ) a;
  · refine' le_ciInf fun k => _;
    refine' ciInf_mono _ _;
    · exact Set.finite_range _ |> Set.Finite.bddBelow;
    · exact fun x => ciInf_le ( Finite.bddBelow_range fun k => A i x + B x k + C k j ) k

/-! ## Power splitting -/

/-
Tropical powers split: `tropPow A (m + k + 1) = tropMul (tropPow A m) (tropPow A k)`.
    Since `tropPow A m` = A^⊗(m+1), this says A^⊗(m+k+2) = A^⊗(m+1) ⊗ A^⊗(k+1).
-/
theorem tropPow_add [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (m k : ℕ) :
    tropPow A (m + k + 1) = tropMul (tropPow A m) (tropPow A k) := by
  induction' k with k ih generalizing m;
  · rfl;
  · convert tropMul_assoc ( tropPow A m ) ( tropPow A k ) A using 1;
    grind +locals

/-! ## Subadditivity of diagonal entries -/

/-- **Subadditivity of tropical power diagonals**: For all m, k,
    `(A^⊗(m+k+2))ᵢᵢ ≤ (A^⊗(m+1))ᵢᵢ + (A^⊗(k+1))ᵢᵢ`,
    equivalently `tropPow A (m + k + 1) i i ≤ tropPow A m i i + tropPow A k i i`.

    This is the foundational inequality for tropical spectral theory.
    By Fekete's lemma, it implies the existence of the asymptotic cycle mean
    `lim_{n→∞} (A^⊗n)ᵢᵢ / n`, which is the tropical eigenvalue. -/
theorem tropPow_diag_subadditive [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) (m k : ℕ) :
    tropPow A (m + k + 1) i i ≤ tropPow A m i i + tropPow A k i i := by
  rw [tropPow_add]
  exact tropMul_diag_le _ _ _