/-
  # Kronecker Product Closure for Hadamard Matrices

  Proves that the Kronecker (tensor) product of two Hadamard matrices is Hadamard,
  establishing closure under tensor products. This is the key mechanism for constructing
  large-order Hadamard matrices from smaller ones.
-/
import Algebra.Hadamard.Defs

open Matrix Finset BigOperators

/-! ## Generalized Hadamard on arbitrary Fintype index -/

/-- Generalized Hadamard predicate for matrices indexed by arbitrary finite types. -/
def IsHadamardGen {ι : Type*} [Fintype ι] [DecidableEq ι]
    (H : Matrix ι ι ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (Fintype.card ι : ℤ) • (1 : Matrix ι ι ℤ)

/-- IsHadamard is the special case of IsHadamardGen for Fin n. -/
theorem isHadamard_iff_isHadamardGen {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) :
    IsHadamard H ↔ IsHadamardGen H := by
  simp [IsHadamard, IsHadamardGen, Fintype.card_fin]

/-! ## Kronecker product preserves Hadamard property -/

/-
Kronecker product of two Hadamard matrices (on general Fintype indices) is Hadamard.
-/
theorem IsHadamardGen.kronecker
    {ι₁ : Type*} [Fintype ι₁] [DecidableEq ι₁]
    {ι₂ : Type*} [Fintype ι₂] [DecidableEq ι₂]
    {H₁ : Matrix ι₁ ι₁ ℤ} {H₂ : Matrix ι₂ ι₂ ℤ}
    (h₁ : IsHadamardGen H₁) (h₂ : IsHadamardGen H₂) :
    IsHadamardGen (Matrix.kroneckerMap (· * ·) H₁ H₂) := by
  constructor
  · intro ⟨i₁, i₂⟩ ⟨j₁, j₂⟩
    simp only [Matrix.kroneckerMap_apply]
    rcases h₁.1 i₁ j₁ with h | h <;> rcases h₂.1 i₂ j₂ with h' | h' <;> simp [h, h']
  ·
    have h_kronecker : Matrix.kroneckerMap (fun x y => x * y) H₁ H₂ * Matrix.transpose (Matrix.kroneckerMap (fun x y => x * y) H₁ H₂) = Matrix.kroneckerMap (fun x y => x * y) (H₁ * Matrix.transpose H₁) (H₂ * Matrix.transpose H₂) := by
      ext ⟨ i₁, i₂ ⟩ ⟨ j₁, j₂ ⟩ ; simp +decide [ Matrix.mul_apply ] ; ring;
      simp +decide only [mul_comm, mul_left_comm, Finset.mul_sum _ _ _]
      exact Fintype.sum_prod_type_right fun x => H₁ i₁ x.1 * (H₁ j₁ x.1 * (H₂ i₂ x.2 * H₂ j₂ x.2))
    simp_all +decide [ IsHadamardGen ]

/-
Reindexing a generalized Hadamard matrix preserves the Hadamard property.
-/
theorem IsHadamardGen.reindex
    {ι₁ : Type*} [Fintype ι₁] [DecidableEq ι₁]
    {ι₂ : Type*} [Fintype ι₂] [DecidableEq ι₂]
    (e : ι₁ ≃ ι₂) {H : Matrix ι₁ ι₁ ℤ}
    (hH : IsHadamardGen H) :
    IsHadamardGen ((Matrix.reindex e e) H) := by
  unfold IsHadamardGen at *;
  simp_all +decide [ Fintype.card_congr e, Matrix.smul_eq_diagonal_mul ]

/-! ## HadamardOrder is multiplicative -/

/-- If orders m and n are Hadamard orders, then so is m * n. -/
theorem hadamardOrder_mul {m n : ℕ}
    (hm : HadamardOrder m) (hn : HadamardOrder n) :
    HadamardOrder (m * n) := by
  obtain ⟨H₁, hH₁⟩ := hm
  obtain ⟨H₂, hH₂⟩ := hn
  rw [isHadamard_iff_isHadamardGen] at hH₁ hH₂
  have hK := IsHadamardGen.kronecker hH₁ hH₂
  -- Reindex from Fin m × Fin n to Fin (m * n)
  have e : Fin m × Fin n ≃ Fin (m * n) := (finProdFinEquiv).symm.symm
  have hK' := IsHadamardGen.reindex e hK
  rw [← isHadamard_iff_isHadamardGen] at hK'
  exact ⟨_, hK'⟩