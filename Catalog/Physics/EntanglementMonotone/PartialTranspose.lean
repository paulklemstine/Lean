import Physics.EntanglementMonotone.TraceNorm

/-!
# Partial transposition on a bipartite system

For a bipartite system with Hilbert space `ℂ^α ⊗ ℂ^β`, operators are matrices indexed by
`α × β`.  The *partial transpose* (with respect to the second factor `B`) is

`(Γ X)_{(i,j),(k,l)} = X_{(i,l),(k,j)}`.

This file records the structural properties of `Γ` used in the theory of the logarithmic
negativity:

* `EntMonotone.ptrans_ptrans` : `Γ` is an involution;
* `EntMonotone.trace_ptrans`  : `Γ` preserves the trace;
* `EntMonotone.ptrans_isHermitian` : `Γ` preserves Hermiticity;
* `EntMonotone.ptrans_kronecker` : `Γ (A ⊗ B) = A ⊗ Bᵀ`, hence product states are PPT;
* `EntMonotone.ptrans_conj_local` : the key covariance identity
  `Γ ((A ⊗ B) X (A ⊗ B)ᴴ) = (A ⊗ B̄) (Γ X) (A ⊗ B̄)ᴴ`,
  which says that conjugation by a *local* operator commutes with partial transposition up
  to complex conjugation of the local operator on `B`.  This is what makes local operations
  PPT operations.
-/

namespace EntMonotone

open Matrix Kronecker ComplexOrder
open scoped MatrixOrder

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-- Partial transposition on the second tensor factor. -/
def ptrans (X : Matrix (α × β) (α × β) ℂ) : Matrix (α × β) (α × β) ℂ :=
  Matrix.of fun p q => X (p.1, q.2) (q.1, p.2)

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
@[simp] theorem ptrans_apply (X : Matrix (α × β) (α × β) ℂ) (i k : α) (j l : β) :
    ptrans X (i, j) (k, l) = X (i, l) (k, j) := rfl

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
/-- Partial transposition is an involution. -/
@[simp] theorem ptrans_ptrans (X : Matrix (α × β) (α × β) ℂ) : ptrans (ptrans X) = X := by
  ext ⟨i, j⟩ ⟨k, l⟩
  rfl

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
theorem ptrans_add (X Y : Matrix (α × β) (α × β) ℂ) :
    ptrans (X + Y) = ptrans X + ptrans Y := by
  ext ⟨i, j⟩ ⟨k, l⟩; rfl

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
theorem ptrans_sub (X Y : Matrix (α × β) (α × β) ℂ) :
    ptrans (X - Y) = ptrans X - ptrans Y := by
  ext ⟨i, j⟩ ⟨k, l⟩; rfl

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
theorem ptrans_smul (c : ℂ) (X : Matrix (α × β) (α × β) ℂ) :
    ptrans (c • X) = c • ptrans X := by
  ext ⟨i, j⟩ ⟨k, l⟩; rfl

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
@[simp] theorem ptrans_zero : ptrans (0 : Matrix (α × β) (α × β) ℂ) = 0 := by
  ext ⟨i, j⟩ ⟨k, l⟩; rfl

omit [DecidableEq α] [DecidableEq β] in
/-- Partial transposition preserves the trace. -/
@[simp] theorem trace_ptrans (X : Matrix (α × β) (α × β) ℂ) : (ptrans X).trace = X.trace := by
  simp only [Matrix.trace, Matrix.diag_apply]
  exact Finset.sum_congr rfl fun p _ => rfl

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
/-- Partial transposition preserves Hermiticity. -/
theorem ptrans_isHermitian {X : Matrix (α × β) (α × β) ℂ} (hX : X.IsHermitian) :
    (ptrans X).IsHermitian := by
  ext ⟨i, j⟩ ⟨k, l⟩
  have := congrFun (congrFun hX (i, l)) (k, j)
  simpa [Matrix.conjTranspose_apply, ptrans] using this

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
/-- Partial transposition of a product operator transposes the second factor. -/
theorem ptrans_kronecker (A : Matrix α α ℂ) (B : Matrix β β ℂ) :
    ptrans (A ⊗ₖ B) = A ⊗ₖ Bᵀ := by
  ext ⟨i, j⟩ ⟨k, l⟩
  simp [ptrans, Matrix.transpose_apply]

/-- The Kronecker product of two positive semidefinite matrices is positive semidefinite. -/
theorem posSemidef_kronecker {A : Matrix α α ℂ} {B : Matrix β β ℂ}
    (hA : A.PosSemidef) (hB : B.PosSemidef) : (A ⊗ₖ B).PosSemidef := by
  have hsA : (CFC.sqrt A).PosSemidef := Matrix.nonneg_iff_posSemidef.mp (CFC.sqrt_nonneg A)
  have hsB : (CFC.sqrt B).PosSemidef := Matrix.nonneg_iff_posSemidef.mp (CFC.sqrt_nonneg B)
  have key : A ⊗ₖ B = (CFC.sqrt A ⊗ₖ CFC.sqrt B)ᴴ * (CFC.sqrt A ⊗ₖ CFC.sqrt B) := by
    rw [Matrix.conjTranspose_kronecker, hsA.isHermitian.eq, hsB.isHermitian.eq,
      ← Matrix.mul_kronecker_mul, CFC.sqrt_mul_sqrt_self A (Matrix.nonneg_iff_posSemidef.mpr hA),
      CFC.sqrt_mul_sqrt_self B (Matrix.nonneg_iff_posSemidef.mpr hB)]
  rw [key]
  exact Matrix.posSemidef_conjTranspose_mul_self _

/-- A bipartite state is *PPT* (positive under partial transposition) when its partial
transpose is again positive semidefinite. -/
def IsPPT (X : Matrix (α × β) (α × β) ℂ) : Prop := (ptrans X).PosSemidef

/-- Product states are PPT. -/
theorem isPPT_kronecker {A : Matrix α α ℂ} {B : Matrix β β ℂ}
    (hA : A.PosSemidef) (hB : B.PosSemidef) : IsPPT (A ⊗ₖ B) := by
  rw [IsPPT, ptrans_kronecker]
  exact posSemidef_kronecker hA hB.transpose

/-- Entrywise complex conjugate of a matrix. -/
def entryConj (B : Matrix β β ℂ) : Matrix β β ℂ := Bᴴᵀ

omit [Fintype β] [DecidableEq β] in
@[simp] theorem entryConj_apply (B : Matrix β β ℂ) (i j : β) :
    entryConj B i j = star (B i j) := rfl

/-- Swapping the second components of a pair of composite indices; the combinatorial heart of
the covariance identity below. -/
def swapSecond : ((α × β) × (α × β)) ≃ ((α × β) × (α × β)) where
  toFun p := ((p.1.1, p.2.2), (p.2.1, p.1.2))
  invFun p := ((p.1.1, p.2.2), (p.2.1, p.1.2))
  left_inv := by rintro ⟨⟨a, b⟩, ⟨c, d⟩⟩; rfl
  right_inv := by rintro ⟨⟨a, b⟩, ⟨c, d⟩⟩; rfl

omit [DecidableEq α] [DecidableEq β] in
theorem sum_swap_second {M : Type*} [AddCommMonoid M] (F : (α × β) → (α × β) → M) :
    (∑ v : α × β, ∑ u : α × β, F u v)
      = ∑ v : α × β, ∑ u : α × β, F (u.1, v.2) (v.1, u.2) := by
  rw [← Finset.sum_product', ← Finset.sum_product', Finset.univ_product_univ]
  exact Fintype.sum_equiv swapSecond _ _ (fun _ => rfl)

omit [DecidableEq α] [DecidableEq β] in
/-- **Covariance of partial transposition under local conjugation.**
Conjugating by a local operator `A ⊗ B` intertwines with partial transposition, the local
operator on the second factor getting complex conjugated. -/
theorem ptrans_conj_local (A : Matrix α α ℂ) (B : Matrix β β ℂ)
    (X : Matrix (α × β) (α × β) ℂ) :
    ptrans ((A ⊗ₖ B) * X * (A ⊗ₖ B)ᴴ)
      = (A ⊗ₖ entryConj B) * ptrans X * (A ⊗ₖ entryConj B)ᴴ := by
  ext ⟨i, j⟩ ⟨k, l⟩
  simp only [ptrans_apply, Matrix.mul_apply, Matrix.conjTranspose_apply, Finset.sum_mul]
  refine Eq.trans (sum_swap_second _) ?_
  refine Finset.sum_congr rfl fun v _ => Finset.sum_congr rfl fun u _ => ?_
  obtain ⟨a, b⟩ := u
  obtain ⟨c, d⟩ := v
  simp only [Matrix.kronecker_apply, entryConj_apply, ptrans_apply, star_mul', star_star]
  ring

end EntMonotone