/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Néron Component Groups via Tropical Jacobians — Theorems

This file contains the main theorems connecting tropical Jacobians (reduced
Laplacian cokernels) to Néron component groups:

1. Symmetry, kernel, and basic properties of graph Laplacians
2. Positive semidefiniteness and nonneg determinant of reduced Laplacians
3. The arithmetic comparison principle (from axiomatized bridge)
4. Concrete computational examples (K₃, K₄, banana graphs)
5. Independence of the deleted vertex
6. Cardinality = |det| and SNF classification

## References

* Baker, M. "Specialization of linear systems from curves to graphs" (2008)
* Raynaud, M. "Spécialisation du foncteur de Picard" (1970)
-/

import Mathlib
import Pythagorean.TropicalBridge.NeronComponent.Defs

open Finset BigOperators Matrix

/-! ## Section 1: Basic Laplacian properties -/

/-- The reduced Laplacian of a symmetric matrix is symmetric. -/
theorem reducedLaplacian_symmetric {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (v0 : V) (hsym : Lᵀ = L) :
    (reducedLaplacian L v0)ᵀ = reducedLaplacian L v0 := by
  unfold reducedLaplacian; aesop

/-- Each column of a symmetric matrix with zero row sums also has zero column sums. -/
lemma colSumZero_of_symmetric_rowSumZero {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (hsym : Lᵀ = L) (hrow : ∀ v, ∑ w, L v w = 0)
    (w : V) : ∑ v, L v w = 0 := by
  rw [← hrow w]
  conv_rhs => rw [← hsym]
  rfl

/-- For a matrix with zero row sums, the constant vector is in the kernel. -/
lemma laplacian_ker_contains_constants {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (hrow : ∀ v, ∑ w, L v w = 0) (c : ℤ) :
    L.mulVec (Function.const V c) = 0 := by
  ext v; simp +decide [Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, hrow]
  rw [← Finset.sum_mul, hrow, MulZeroClass.zero_mul]

/-! ## Section 2: Positive semidefiniteness and nonneg determinant -/

/-
The determinant of the reduced Laplacian of a graph Laplacian is nonneg.
    This follows from PSD structure: x^T L x = ∑_{edges} w_{ij}(x_i - x_j)² ≥ 0.
    The proof lifts to ℝ, establishes PSD of the quadratic form,
    then uses that eigenvalues of PSD matrices are nonneg.
-/
lemma reducedLaplacian_det_nonneg
    (G : SemistableDualGraphData) (v0 : G.V) :
    0 ≤ Matrix.det (reducedLaplacian G.laplacian v0) := by
  -- Since $L_{\text{red}}$ is a principal submatrix of $L$, and $L$ is positive semidefinite, $L_{\text{red}}$ is also positive semidefinite.
  have h_pos_semidef : Matrix.PosSemidef (Matrix.map (reducedLaplacian G.laplacian v0) (algebraMap ℤ ℝ)) := by
    have h_pos_semidef : Matrix.PosSemidef (Matrix.map G.laplacian (algebraMap ℤ ℝ)) := by
      have h_pos_semidef : ∀ x : G.V → ℝ, (∑ i, ∑ j, (G.laplacian i j : ℝ) * x i * x j) ≥ 0 := by
        intro x
        have h_quad_form : ∑ i, ∑ j, (G.laplacian i j : ℝ) * x i * x j = -∑ i, ∑ j ∈ Finset.univ \ {i}, (G.laplacian i j : ℝ) * (x i - x j) ^ 2 / 2 := by
          have h_quad_form : ∑ i, ∑ j, (G.laplacian i j : ℝ) * x i * x j = ∑ i, ∑ j, (G.laplacian i j : ℝ) * x i * x j - ∑ i, ∑ j, (G.laplacian i j : ℝ) * x i ^ 2 / 2 - ∑ i, ∑ j, (G.laplacian i j : ℝ) * x j ^ 2 / 2 := by
            have h_quad_form : ∑ i, ∑ j, (G.laplacian i j : ℝ) * x i ^ 2 = 0 ∧ ∑ i, ∑ j, (G.laplacian i j : ℝ) * x j ^ 2 = 0 := by
              have h_quad_form : ∑ i, ∑ j, (G.laplacian i j : ℝ) * x i ^ 2 = ∑ i, (x i ^ 2 * ∑ j, (G.laplacian i j : ℝ)) := by
                simp +decide only [mul_comm, Finset.mul_sum _ _ _];
              have h_quad_form : ∑ i, ∑ j, (G.laplacian i j : ℝ) * x j ^ 2 = ∑ j, (x j ^ 2 * ∑ i, (G.laplacian i j : ℝ)) := by
                simpa only [ mul_comm, Finset.mul_sum _ _ _ ] using Finset.sum_comm;
              have h_quad_form : ∀ i, ∑ j, (G.laplacian i j : ℝ) = 0 := by
                exact fun i => mod_cast G.rowSumZero i;
              have h_quad_form : ∀ j, ∑ i, (G.laplacian i j : ℝ) = 0 := by
                intro j; specialize h_quad_form; have := G.symmetric; simp_all +decide [ ← Matrix.ext_iff ] ;
              aesop;
            simp_all +decide [ ← Finset.sum_div _ _ _ ];
          have h_quad_form : ∑ i, ∑ j, (G.laplacian i j : ℝ) * x i * x j - ∑ i, ∑ j, (G.laplacian i j : ℝ) * x i ^ 2 / 2 - ∑ i, ∑ j, (G.laplacian i j : ℝ) * x j ^ 2 / 2 = -∑ i, ∑ j, (G.laplacian i j : ℝ) * (x i - x j) ^ 2 / 2 := by
            norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_div, mul_sub, sub_mul, mul_assoc, mul_comm, mul_left_comm, sq ] ; ring;
            norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, mul_assoc, mul_comm, mul_left_comm ] ; ring;
          convert h_quad_form using 1;
          simp +decide [ Finset.sum_sub_distrib, sub_sq ];
          ring ; norm_num;
        -- Since $L_{ij} \leq 0$ for $i \neq j$, each term in the sum is nonnegative.
        have h_nonneg : ∀ i j, i ≠ j → (G.laplacian i j : ℝ) * (x i - x j) ^ 2 / 2 ≤ 0 := by
          exact fun i j hij => div_nonpos_of_nonpos_of_nonneg ( mul_nonpos_of_nonpos_of_nonneg ( mod_cast G.offDiag_nonpos i j hij ) ( sq_nonneg _ ) ) zero_le_two;
        exact h_quad_form.symm ▸ neg_nonneg_of_nonpos ( Finset.sum_nonpos fun i hi => Finset.sum_nonpos fun j hj => h_nonneg i j <| by aesop );
      constructor;
      · ext i j; simp +decide [ G.symmetric ] ;
        exact congr_fun ( congr_fun G.symmetric i ) j;
      · intro x; specialize h_pos_semidef x; simp_all +decide [ Finsupp.sum_fintype, mul_assoc, mul_comm, mul_left_comm ] ;
    convert h_pos_semidef.submatrix _ using 1;
  convert h_pos_semidef.det_nonneg using 1;
  norm_num [ Matrix.det_apply' ];
  norm_cast

/-! ## Section 3: Arithmetic Comparison Principle -/

/-- **Theorem 4: Arithmetic comparison principle.**
    Given a specialization component bridge (axiomatizing Raynaud's theorem),
    the Néron component group is isomorphic to the tropical Jacobian.
    This is the formal interface into which Raynaud/Baker theory can plug. -/
theorem componentGroup_equiv_tropicalJacobian
    (G : SemistableDualGraphData) (v0 : G.V)
    (B : SpecializationComponentBridge G v0) :
    Nonempty (B.Phi ≃+ reducedLaplacianCokernel G.laplacian v0) :=
  ⟨AddEquiv.ofBijective B.toTrop ⟨B.injective_toTrop, B.surjective_toTrop⟩⟩

/-! ## Section 4: Concrete computational examples -/

/-- The Laplacian of the cycle graph K₃ (triangle). -/
def cycleGraph3Laplacian : Matrix (Fin 3) (Fin 3) ℤ :=
  !![2, -1, -1; -1, 2, -1; -1, -1, 2]

/-- K₃ has zero row sums. -/
lemma cycleGraph3_rowSumZero : ∀ v : Fin 3, ∑ w, cycleGraph3Laplacian v w = 0 := by
  native_decide

/-- K₃ has symmetric Laplacian. -/
lemma cycleGraph3_symmetric : cycleGraph3Laplacianᵀ = cycleGraph3Laplacian := by
  native_decide +revert

/-- K₃ off-diagonal entries are nonpositive. -/
lemma cycleGraph3_offDiag_nonpos :
    ∀ v w : Fin 3, v ≠ w → cycleGraph3Laplacian v w ≤ 0 := by
  native_decide +revert

/-
The reduced Laplacian of the triangle (deleting vertex 0) has determinant 3,
    which equals the number of spanning trees of K₃.
-/
theorem cycleGraph3_det_reduced :
    Matrix.det (reducedLaplacian cycleGraph3Laplacian (0 : Fin 3)) = 3 := by
  decide +revert

/-- The Laplacian of the complete graph K₄. -/
def completeGraph4Laplacian : Matrix (Fin 4) (Fin 4) ℤ :=
  !![3, -1, -1, -1; -1, 3, -1, -1; -1, -1, 3, -1; -1, -1, -1, 3]

/-- K₄ has 16 spanning trees: det of reduced Laplacian = 16. -/
theorem completeGraph4_det_reduced :
    Matrix.det (reducedLaplacian completeGraph4Laplacian (0 : Fin 4)) = 16 := by
  decide +revert

/-- The Laplacian of a banana graph (two vertices, n parallel edges). -/
def bananaGraphLaplacian (n : ℤ) : Matrix (Fin 2) (Fin 2) ℤ :=
  !![n, -n; -n, n]

/-
The reduced Laplacian of the banana graph has determinant n.
-/
theorem bananaGraph_det_reduced (n : ℤ) :
    Matrix.det (reducedLaplacian (bananaGraphLaplacian n) (0 : Fin 2)) = n := by
  convert Matrix.det_unique ?_GraphLaplacian;
  swap;
  exact ⟨ ⟨ 1, by decide ⟩, by rintro ⟨ v, hv ⟩ ; fin_cases v <;> trivial ⟩;
  rfl

/-- K₃ as a `SemistableDualGraphData` instance. -/
def cycleGraph3Data : SemistableDualGraphData where
  V := Fin 3
  laplacian := cycleGraph3Laplacian
  connected := True
  symmetric := cycleGraph3_symmetric
  rowSumZero := cycleGraph3_rowSumZero
  offDiag_nonpos := cycleGraph3_offDiag_nonpos

/-! ## Section 5: Genus-2 examples -/

/-- The theta graph: 2 vertices connected by 3 edges.
    This is a standard genus-2 semistable reduction dual graph.
    The tropical Jacobian is ℤ/3ℤ. -/
def thetaGraphLaplacian : Matrix (Fin 2) (Fin 2) ℤ :=
  !![3, -3; -3, 3]

/-
The theta graph reduced Laplacian determinant is 3.
-/
theorem thetaGraph_det_reduced :
    Matrix.det (reducedLaplacian thetaGraphLaplacian (0 : Fin 2)) = 3 := by
  convert bananaGraph_det_reduced 3

/-- A genus-2 chain graph: 3 vertices with edge weights 2 and 1.
    Laplacian: [[2, -2, 0], [-2, 3, -1], [0, -1, 1]]. -/
def genus2ChainLaplacian : Matrix (Fin 3) (Fin 3) ℤ :=
  !![2, -2, 0; -2, 3, -1; 0, -1, 1]

/-- Genus-2 chain graph has zero row sums. -/
lemma genus2Chain_rowSumZero :
    ∀ v : Fin 3, ∑ w, genus2ChainLaplacian v w = 0 := by
  native_decide

/-
Genus-2 chain graph reduced Laplacian determinant is 2.
-/
theorem genus2Chain_det_reduced :
    Matrix.det (reducedLaplacian genus2ChainLaplacian (0 : Fin 3)) = 2 := by
  exact?

/-! ## Section 6: Deep structural theorems -/

/-- The cokernel of an integer matrix. -/
noncomputable def intMatrixCokernel {n : Type} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℤ) : Type :=
  (n → ℤ) ⧸ (LinearMap.range (Matrix.mulVecLin A)).toAddSubgroup

noncomputable instance intMatrixCokernel.instAddCommGroup
    {n : Type} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℤ) : AddCommGroup (intMatrixCokernel A) :=
  QuotientAddGroup.Quotient.addCommGroup _

/-- The reduced Laplacian cokernel is definitionally equal to the
    integer matrix cokernel of the reduced Laplacian. -/
noncomputable def reducedLaplacianCokernel_eq_intMatrixCokernel
    {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (v0 : V) :
    reducedLaplacianCokernel L v0 ≃+ intMatrixCokernel (reducedLaplacian L v0) :=
  AddEquiv.refl _

/-- **Theorem 1: Reduced Laplacian cokernel is independent of the deleted vertex.**
    For a matrix with zero row sums, the cokernel of the reduced Laplacian
    does not depend on which vertex is deleted.

    Proof strategy: Both cokernels are isomorphic to Div⁰(Γ)/Prin(Γ), the quotient
    of degree-zero divisors by principal divisors. -/
theorem reducedLaplacianCokernel_nonempty_iso
    {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (hrow : ∀ v, ∑ w, L v w = 0)
    (v₁ v₂ : V) :
    Nonempty (reducedLaplacianCokernel L v₁ ≃+ reducedLaplacianCokernel L v₂) := by
  sorry

/-- **Theorem 2: Cardinality of the cokernel equals |det| of the reduced Laplacian.**
    This is the algebraic heart of |Φ_J| = det(L_red). -/
theorem componentGroup_order_eq_det_reducedLaplacian
    {V : Type} [Fintype V] [DecidableEq V]
    (G : SemistableDualGraphData)
    (v0 : G.V)
    [Fintype (reducedLaplacianCokernel G.laplacian v0)] :
    Fintype.card (reducedLaplacianCokernel G.laplacian v0) =
      Int.natAbs (Matrix.det (reducedLaplacian G.laplacian v0)) := by
  sorry

/-- **Theorem 3: Smith normal form classification of the cokernel.** -/
theorem intMatrixCokernel_isomorphic_to_cyclic_product
    {n : Type} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℤ) :
    ∃ (k : ℕ) (d : Fin k → ℤ),
      (∀ i, d i ≠ 0) ∧
      Nonempty (intMatrixCokernel A ≃+
        DirectSum (Fin k) (fun i => ZMod (Int.natAbs (d i)))) := by
  sorry

/-- **Product formula:** invariant factors product = |det(A)| when det ≠ 0. -/
theorem invariant_factors_product_eq_det
    {n : Type} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℤ) (hdet : A.det ≠ 0)
    (k : ℕ) (d : Fin k → ℤ)
    (hne : ∀ i, d i ≠ 0)
    (hiso : Nonempty (intMatrixCokernel A ≃+
      DirectSum (Fin k) (fun i => ZMod (Int.natAbs (d i))))) :
    ∏ i : Fin k, Int.natAbs (d i) = Int.natAbs A.det := by
  sorry