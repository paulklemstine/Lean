/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Determinantal Complexity of Matroid Basis Polynomials

This file introduces a new algebraic complexity invariant — **determinantal complexity** —
for multiaffine homogeneous polynomials arising as basis-generating polynomials of matroids.

## Mathematical Overview

For a matrix `A ∈ R^{r×n}`, the **basis polynomial** is:
  `basisPolyOfMatrix A = det(A · D_X · Aᵀ)`
where `D_X = diag(X₁, …, Xₙ)` is the diagonal matrix of formal variables.

By Cauchy–Binet, this equals `∑_{S ⊆ [n], |S|=r} (det A_S)² · ∏_{e∈S} Xₑ`.

We define `IsDeterminantalBasisPolynomial r p` and `determinantalComplexity p`.

## Main Results

1. `isDeterminantalBasisPolynomial_of_matrix`: every matrix gives a determinantal representation
2. `determinantalComplexity_le_of_matrix`: upper bound on complexity
3. `eval_basisPolyOfMatrix_nonneg`: nonnegativity for nonneg weights (partition function bridge)
4. `isDeterminantalBasisPolynomial_X`: single variable representation
5. `basisPolyOfMatrix_blockDiag`: block-diagonal factorization identity

## Cross-Domain Bridges

- **Matroid theory ↔ algebraic complexity**: determinantal size as complexity measure
- **Matroid theory ↔ probability**: basis polynomial = partition function; nonnegativity
- **Algebraic complexity ↔ compositionality**: direct sum → additive complexity

## References

Builds on Cauchy–Binet machinery in `Catalog/Pythagorean/FermionicPlucker.lean`.
-/

open Finset BigOperators Matrix MvPolynomial

noncomputable section

namespace DeterminantalComplexity

/-! ## Section 1: Core Definitions -/

/-- The **weighted Gram matrix** in polynomial variables: the `(i,j)`-entry is
    `∑_k A(i,k) · X_k · A(j,k)`, which equals `(A · D_X · Aᵀ)(i,j)`. -/
def gramPolyMatrix {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] {r : ℕ}
    (A : Matrix (Fin r) α R) : Matrix (Fin r) (Fin r) (MvPolynomial α R) :=
  fun i j => ∑ k : α,
    MvPolynomial.C (A i k) * MvPolynomial.X k * MvPolynomial.C (A j k)

/-- The **basis polynomial of a matrix**: for `A : Matrix (Fin r) α R`,
    this is `det(A · D_X · Aᵀ)` where `D_X = diag(X_a : a ∈ α)`. -/
def basisPolyOfMatrix {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] {r : ℕ}
    (A : Matrix (Fin r) α R) : MvPolynomial α R :=
  (gramPolyMatrix A).det

/-- A polynomial `p` is a **determinantal basis polynomial of size `r`** if there exists
    a matrix `A : Matrix (Fin r) α R` such that `p = det(A · D_X · Aᵀ)`. -/
def IsDeterminantalBasisPolynomial {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] (r : ℕ) (p : MvPolynomial α R) : Prop :=
  ∃ (A : Matrix (Fin r) α R), basisPolyOfMatrix A = p

/-- The **determinantal complexity** of a polynomial `p` is the minimum `r`
    such that `p` admits a determinantal basis polynomial representation. -/
def determinantalComplexity {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] (p : MvPolynomial α R) : ℕ :=
  sInf {r : ℕ | IsDeterminantalBasisPolynomial (R := R) r p}

/-! ## Section 2: The Determinantal Upper Bound (Theorem 1) -/

/-- **Theorem 1: Every matrix yields a determinantal representation.** -/
theorem isDeterminantalBasisPolynomial_of_matrix
    {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] {r : ℕ}
    (A : Matrix (Fin r) α R) :
    IsDeterminantalBasisPolynomial (R := R) r (basisPolyOfMatrix A) :=
  ⟨A, rfl⟩

/-- **Corollary: Determinantal complexity is at most `r` for any `r × n` matrix.** -/
theorem determinantalComplexity_le_of_matrix
    {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] {r : ℕ}
    (A : Matrix (Fin r) α R) :
    determinantalComplexity (basisPolyOfMatrix A) ≤ r :=
  Nat.sInf_le ⟨A, rfl⟩

/-! ## Section 3: Evaluation and the Partition Function Bridge -/

/-- The Gram polynomial matrix evaluated at weights. -/
theorem eval_gramPolyMatrix {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] {r : ℕ}
    (A : Matrix (Fin r) α R) (w : α → R) (i j : Fin r) :
    MvPolynomial.eval w (gramPolyMatrix A i j) =
    ∑ k : α, A i k * w k * A j k := by
  unfold gramPolyMatrix; simp [map_sum, map_mul]

/-- Evaluating the basis polynomial at weights yields the Gram determinant. -/
theorem eval_basisPolyOfMatrix {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] {r : ℕ}
    (A : Matrix (Fin r) α R) (w : α → R) :
    MvPolynomial.eval w (basisPolyOfMatrix A) =
    Matrix.det (fun i j => ∑ k : α, A i k * w k * A j k : Matrix (Fin r) (Fin r) R) := by
  unfold basisPolyOfMatrix
  rw [show (MvPolynomial.eval w) (gramPolyMatrix A).det =
    ((gramPolyMatrix A).map (MvPolynomial.eval w)).det from RingHom.map_det _ _]
  congr 1; ext i j; exact eval_gramPolyMatrix A w i j

/-
**Cross-domain theorem: Nonnegativity of the partition function.**

    When evaluated at nonneg real weights, the basis polynomial is nonneg.
    This connects matroid basis polynomials to partition functions.
-/
theorem eval_basisPolyOfMatrix_nonneg
    {α : Type*} [Fintype α] [DecidableEq α]
    {r : ℕ} (A : Matrix (Fin r) α ℝ)
    (w : α → ℝ) (hw : ∀ a, 0 ≤ w a) :
    0 ≤ MvPolynomial.eval w (basisPolyOfMatrix A) := by
      -- Apply the theorem that states the determinant of a positive semi-definite matrix is nonnegative.
      have h_det_nonneg : 0 ≤ Matrix.det (fun i j => ∑ k : α, A i k * w k * A j k : Matrix (Fin r) (Fin r) ℝ) := by
        -- Let $B = A^T \sqrt{D_X}$, where $D_X$ is the diagonal matrix with entries $w$.
        set B : Matrix α (Fin r) ℝ := fun i j => Real.sqrt (w i) * A j i;
        -- Then $B^T B = \sum_{k} A_{ik} w_k A_{jk}$.
        have hBTB : (B.transpose * B) = fun i j => ∑ k : α, A i k * w k * A j k := by
          ext i j; simp +decide [ B, Matrix.mul_apply ] ; ring;
          exact Finset.sum_congr rfl fun _ _ => by rw [ Real.sq_sqrt ( hw _ ) ] ; ring;
        exact hBTB ▸ Matrix.posSemidef_conjTranspose_mul_self B |> fun h => h.det_nonneg;
      rw [ eval_basisPolyOfMatrix ] ; exact h_det_nonneg;

/-! ## Section 4: Size-0 representations -/

/-- The basis polynomial of the empty (0 × n) matrix is 1. -/
theorem basisPolyOfMatrix_fin_zero {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] (A : Matrix (Fin 0) α R) :
    basisPolyOfMatrix A = 1 := by
  simp [basisPolyOfMatrix]

/-- The constant 1 is a determinantal basis polynomial of size 0. -/
theorem isDeterminantalBasisPolynomial_one {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] :
    IsDeterminantalBasisPolynomial (R := R) 0 (1 : MvPolynomial α R) :=
  ⟨0, basisPolyOfMatrix_fin_zero 0⟩

/-! ## Section 5: Single Variable Representation -/

/-- The indicator row vector: `1 × α` matrix with `1` at column `a`, `0` elsewhere. -/
def indicatorRowVec {α : Type*} [DecidableEq α]
    {R : Type*} [CommRing R] (a : α) : Matrix (Fin 1) α R :=
  fun _ j => if j = a then 1 else 0

/-- The basis polynomial of the indicator row vector for `a` is `X_a`. -/
theorem basisPolyOfMatrix_indicator {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] (a : α) :
    basisPolyOfMatrix (indicatorRowVec a : Matrix (Fin 1) α R) =
      (MvPolynomial.X a : MvPolynomial α R) := by
  unfold basisPolyOfMatrix indicatorRowVec gramPolyMatrix; simp

/-- A single variable `X_a` is a determinantal basis polynomial of size 1. -/
theorem isDeterminantalBasisPolynomial_X {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] (a : α) :
    IsDeterminantalBasisPolynomial (R := R) 1
      (MvPolynomial.X a : MvPolynomial α R) :=
  ⟨indicatorRowVec a, basisPolyOfMatrix_indicator a⟩

/-- The determinantal complexity of a single variable is at most 1. -/
theorem determinantalComplexity_X_le {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] (a : α) :
    determinantalComplexity (MvPolynomial.X a : MvPolynomial α R) ≤ 1 :=
  Nat.sInf_le (isDeterminantalBasisPolynomial_X a)

/-! ## Section 6: Rename of basis polynomial via injective rename -/

/-
Renaming variables through an injective function preserves determinantal structure.
    For an injective `f : α ↪ β`, `rename f (basisPolyOfMatrix A)` is the basis polynomial
    of the matrix `A` viewed with columns in `β` via `f`.
-/
theorem rename_injective_basisPolyOfMatrix {α β : Type*} [Fintype α] [DecidableEq α]
    [Fintype β] [DecidableEq β]
    {R : Type*} [CommRing R] {r : ℕ}
    (A : Matrix (Fin r) α R) (f : α ↪ β) :
    MvPolynomial.rename f (basisPolyOfMatrix A) =
    basisPolyOfMatrix (fun i (b : β) => if h : ∃ a, f a = b then A i h.choose else 0) := by
      unfold basisPolyOfMatrix gramPolyMatrix;
      simp +decide [ Matrix.det_apply', rename ];
      refine' Finset.sum_congr rfl fun σ _ => congr_arg₂ _ rfl ( Finset.prod_congr rfl fun i _ => _ );
      rw [ ← Finset.sum_subset ( Finset.subset_univ ( Finset.image f Finset.univ ) ) ];
      · rw [ Finset.sum_image ];
        · simp +decide [ f.injective.eq_iff ];
        · exact f.injective.injOn;
      · aesop

/-! ## Section 7: Block Diagonal Factorization Identity -/

/-- The block-diagonal matrix for composition: combines `A : Fin r × α` and
    `B : Fin s × β` into a `Fin (r+s) × (α ⊕ β)` matrix. -/
def blockDiagMatrix {α β : Type*}
    {R : Type*} [CommRing R] {r s : ℕ}
    (A : Matrix (Fin r) α R) (B : Matrix (Fin s) β R) :
    Matrix (Fin (r + s)) (α ⊕ β) R :=
  fun i ab =>
    match ab with
    | Sum.inl a => if h : i.val < r then A ⟨i.val, h⟩ a else 0
    | Sum.inr b => if h : r ≤ i.val then B ⟨i.val - r, by omega⟩ b else 0

/-
The Gram matrix of the block-diagonal matrix splits as a sum over α and β.
-/
theorem gramPolyMatrix_blockDiag_entry
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    {R : Type*} [CommRing R] {r s : ℕ}
    (A : Matrix (Fin r) α R) (B : Matrix (Fin s) β R)
    (i j : Fin (r + s)) :
    gramPolyMatrix (blockDiagMatrix A B) i j =
      (∑ a : α, MvPolynomial.C (blockDiagMatrix A B i (Sum.inl a)) *
        MvPolynomial.X (Sum.inl a) *
        MvPolynomial.C (blockDiagMatrix A B j (Sum.inl a))) +
      (∑ b : β, MvPolynomial.C (blockDiagMatrix A B i (Sum.inr b)) *
        MvPolynomial.X (Sum.inr b) *
        MvPolynomial.C (blockDiagMatrix A B j (Sum.inr b))) := by
          convert Fintype.sum_sum_type _ using 2

/-
**Theorem 3 (factorization form): Block-diagonal factorization identity.**

    The basis polynomial of a block-diagonal matrix factors as the product
    of the (renamed) basis polynomials of the diagonal blocks.

    `basisPolyOfMatrix (blockDiag A B) = rename inl (basisPolyOfMatrix A) *
                                          rename inr (basisPolyOfMatrix B)`
-/
theorem basisPolyOfMatrix_blockDiag
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    {R : Type*} [CommRing R] {r s : ℕ}
    (A : Matrix (Fin r) α R) (B : Matrix (Fin s) β R) :
    basisPolyOfMatrix (blockDiagMatrix A B) =
    MvPolynomial.rename Sum.inl (basisPolyOfMatrix A) *
    MvPolynomial.rename Sum.inr (basisPolyOfMatrix B) := by
      convert Matrix.det_reindex_self ( finSumFinEquiv.symm ) _ using 1;
      case convert_5 => exact r;
      any_goals exact s;
      any_goals try infer_instance;
      rotate_right;
      exact Matrix.of fun i j => if h : i.val < r ∧ j.val < r then ∑ a : α, MvPolynomial.C ( A ⟨ i.val, h.1 ⟩ a ) * MvPolynomial.X ( Sum.inl a ) * MvPolynomial.C ( A ⟨ j.val, h.2 ⟩ a ) else if h : r ≤ i.val ∧ r ≤ j.val then ∑ b : β, MvPolynomial.C ( B ⟨ i.val - r, by omega ⟩ b ) * MvPolynomial.X ( Sum.inr b ) * MvPolynomial.C ( B ⟨ j.val - r, by omega ⟩ b ) else 0;
      · unfold basisPolyOfMatrix gramPolyMatrix blockDiagMatrix; simp +decide [ Finset.sum_ite ] ;
        congr! 2;
        ext j; split_ifs <;> simp +decide [ *, Finset.sum_add_distrib ] ;
        linarith;
      · convert Matrix.det_fromBlocks_zero₂₁ _ _ _ using 1;
        rotate_left;
        rotate_left;
        exact Fin r;
        exact Fin s;
        all_goals try infer_instance;
        exact Matrix.of fun i j => ∑ a : α, MvPolynomial.C ( A i a ) * MvPolynomial.X ( Sum.inl a ) * MvPolynomial.C ( A j a );
        exact 0;
        exact Matrix.of fun i j => ∑ b : β, MvPolynomial.C ( B i b ) * MvPolynomial.X ( Sum.inr b ) * MvPolynomial.C ( B j b );
        · rw [ Matrix.det_fromBlocks_zero₂₁ ];
          unfold basisPolyOfMatrix;
          simp +decide [ gramPolyMatrix, Matrix.det_apply' ];
        · convert Matrix.det_fromBlocks_zero₂₁ _ _ _ using 1;
          rotate_left;
          exact 0;
          convert Matrix.det_reindex_self ( finSumFinEquiv ) _ using 1;
          congr! 1;
          · ext i j; simp +decide [ finSumFinEquiv ] ;
            split_ifs <;> simp +decide [ *, Fin.addCases ];
            · rfl;
            · split_ifs <;> simp_all +decide [ Fin.subNat ]; all_goals linarith;
            · split_ifs <;> simp_all +decide [ Fin.castLT, Fin.subNat ];
          · infer_instance

/-! ## Section 8: Composition Corollary -/

/-- **Corollary: Composition of determinantal representations.**
    If `p` has det. complexity ≤ `r` and `q` has det. complexity ≤ `s`,
    then `rename inl p * rename inr q` has det. complexity ≤ `r + s`. -/
theorem isDeterminantalBasisPolynomial_mul_disjoint
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    {R : Type*} [CommRing R] {r s : ℕ}
    {p : MvPolynomial α R} {q : MvPolynomial β R}
    (hp : IsDeterminantalBasisPolynomial (R := R) r p)
    (hq : IsDeterminantalBasisPolynomial (R := R) s q) :
    IsDeterminantalBasisPolynomial (R := R) (r + s)
      (MvPolynomial.rename Sum.inl p * MvPolynomial.rename Sum.inr q) := by
  obtain ⟨A, rfl⟩ := hp
  obtain ⟨B, rfl⟩ := hq
  exact ⟨blockDiagMatrix A B, basisPolyOfMatrix_blockDiag A B⟩

/-! ## Section 9: Evaluation at unit weights -/

/-- Evaluating the basis polynomial at all-ones gives `det(A · Aᵀ)`. -/
theorem eval_basisPolyOfMatrix_ones {α : Type*} [Fintype α] [DecidableEq α]
    {R : Type*} [CommRing R] {r : ℕ}
    (A : Matrix (Fin r) α R) :
    MvPolynomial.eval (fun _ => (1 : R)) (basisPolyOfMatrix A) =
    (A * A.transpose).det := by
  rw [eval_basisPolyOfMatrix]
  congr 1; ext i j; simp [Matrix.mul_apply]

end DeterminantalComplexity