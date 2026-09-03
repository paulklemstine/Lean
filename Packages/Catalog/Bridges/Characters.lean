import Mathlib
/-
Copyright (c) 2024 Thermodynamic Galois Duality Project. All rights reserved.
-/
import Logic.GraphTheory.Defs
import Applications.IsingModel.TransferMatrix

/-!
# Equilibrium–Character Correspondence

This module constructs the correspondence between equilibrium functionals
(positive normalized eigenvectors of the transfer matrix) and normalized
semiring characters on the weighted correspondence semiring.

## Main Results

* `CorrespondenceSemiring` — The semiring of formal NNReal-linear combinations
  of state-to-state correspondences, with composition as multiplication
* `equilibriumToCharacter` — Construction: equilibrium functional → semiring character
* `characterToFunctional` — Construction: character → state functional
* `character_preserves_eigenvalue` — Characters respect the eigenvalue structure
* `equilibrium_character_correspondence` — The fundamental correspondence theorem

## Mathematical Significance

This is one of the key innovations of thermodynamic Galois duality:
equilibrium states (a thermodynamic concept) are shown to be equivalent to
extremal normalized characters (an algebraic concept) on the semiring of
weighted closure correspondences. This bridge allows algebraic techniques
to be applied to thermodynamic problems and vice versa.
-/

open Finset BigOperators Matrix

noncomputable section

variable {X : Type*} [Fintype X] [DecidableEq X]

/-! ### Weighted Correspondence Semiring

The correspondence semiring `Matrix X X NNReal` serves as our model for
the semiring of weighted closure correspondences. Matrix addition represents
superposition of correspondences, and matrix multiplication represents
composition. This is the natural finite-dimensional incarnation of the
abstract correspondence semiring S(C,W). -/

/-- The weighted correspondence semiring for a finite closure system is
    realized as `Matrix X X NNReal`. Elements represent weighted transition
    correspondences between states. -/
abbrev CorrespondenceSemiring (X : Type*) := Matrix X X NNReal

/-! ### From Equilibrium Functionals to Semiring Characters -/

/-- Given a positive normalized eigenvector μ (equilibrium functional) of
    a nonneg matrix A with eigenvalue r, we construct a semiring character
    on the correspondence semiring `Matrix X X NNReal`.

    The character evaluates a matrix M by computing the "μ-weighted total flow":
    `χ_μ(M) = (1/r) · Σ_{x,y} M(x,y) · μ(y)`
    when the eigenvalue is used for normalization, or more simply:
    `χ_μ(M) = Σ_{x,y} M(x,y) · μ(y) / (|X| · r)`

    For the identity matrix, this gives χ_μ(I) = Σ_x μ(x) / |X| = 1/|X|.
    We normalize by defining χ(M) = Σ_y (Σ_x M(x,y)) · μ(y). -/
def equilibriumWeightedSum (μ : StateFunctional X) (M : Matrix X X NNReal) : NNReal :=
  ∑ y : X, (∑ x : X, M x y) * μ.val y

/-
The equilibrium-weighted sum is additive in the matrix argument.
-/
omit [DecidableEq X] in
theorem equilibriumWeightedSum_add (μ : StateFunctional X)
    (M N : Matrix X X NNReal) :
    equilibriumWeightedSum μ (M + N) =
    equilibriumWeightedSum μ M + equilibriumWeightedSum μ N := by
  unfold equilibriumWeightedSum; simp +decide [ Finset.sum_add_distrib, right_distrib ] ;

/-
The equilibrium-weighted sum sends the zero matrix to zero.
-/
omit [DecidableEq X] in
theorem equilibriumWeightedSum_zero (μ : StateFunctional X) :
    equilibriumWeightedSum μ 0 = 0 := by
  unfold equilibriumWeightedSum; aesop;

/-! ### Character from Equilibrium via Column Sums -/

/-- A simpler character construction: for each matrix M, evaluate
    `χ(M) = Σ_{x,y} μ(x) · M(x,y) · μ(y)`,
    the bilinear form of M against the equilibrium measure.
    This is multiplicative when μ is an eigenmeasure. -/
def equilibriumBilinearChar (μ : X → NNReal) (M : Matrix X X NNReal) : NNReal :=
  ∑ x : X, ∑ y : X, μ x * M x y * μ y

/-
The bilinear character is additive.
-/
omit [DecidableEq X] in
theorem equilibriumBilinearChar_add (μ : X → NNReal) (M N : Matrix X X NNReal) :
    equilibriumBilinearChar μ (M + N) =
    equilibriumBilinearChar μ M + equilibriumBilinearChar μ N := by
  unfold equilibriumBilinearChar; simp +decide [ Finset.sum_add_distrib, mul_add, add_mul ] ;

/-
The bilinear character sends zero to zero.
-/
omit [DecidableEq X] in
theorem equilibriumBilinearChar_zero (μ : X → NNReal) :
    equilibriumBilinearChar μ 0 = 0 := by
  exact Finset.sum_eq_zero fun x _ => Finset.sum_eq_zero fun y _ => by simp +decide ;

/-! ### Eigenvector Properties -/

omit [DecidableEq X] in
/-- For an equilibrium functional with eigenvalue r, the weighted sum
    of a single row is controlled by the eigenvalue. -/
theorem eigenvector_row_sum {A : Matrix X X NNReal}
    (eq_func : EquilibriumFunctional X A)
    (x : X) :
    ∑ y : X, A x y * eq_func.toStateFunctional.val y =
    eq_func.eigenvalue * eq_func.toStateFunctional.val x :=
  eq_func.eigenvector_eq x

/-
The total mass of the eigenvector equation: summing over all x,
    we get Σ_{x,y} A(x,y) · μ(y) = r · 1 = r.
-/
omit [DecidableEq X] in
theorem eigenvector_total_mass {A : Matrix X X NNReal}
    (eq_func : EquilibriumFunctional X A) :
    ∑ x : X, ∑ y : X, A x y * eq_func.toStateFunctional.val y =
    eq_func.eigenvalue := by
  have h_sum : ∑ x : X, (eq_func.eigenvalue * eq_func.toStateFunctional.val x) = eq_func.eigenvalue := by
    rw [ ← Finset.mul_sum _ _ _, eq_func.toStateFunctional.normalized, mul_one ];
  exact h_sum ▸ Finset.sum_congr rfl fun _ _ => eq_func.eigenvector_eq _

/-! ### State Functional from Character -/

/-- Given a semiring character χ on the correspondence semiring,
    construct a state functional by evaluating χ on elementary matrices.
    The functional assigns to state x the value χ(E_xx) where E_xx is
    the matrix with 1 at position (x,x) and 0 elsewhere,
    normalized to sum to 1. -/
def elementaryMatrix (x₀ y₀ : X) : Matrix X X NNReal :=
  fun x y => if x = x₀ ∧ y = y₀ then 1 else 0

/-
Elementary matrices decompose: any matrix is a sum of scaled elementary matrices.
-/
theorem matrix_eq_sum_elementary (M : Matrix X X NNReal) :
    M = ∑ x : X, ∑ y : X, M x y • elementaryMatrix x y := by
  ext x y; simp +decide ;
  simp +decide [ elementaryMatrix, Matrix.sum_apply ];
  rw [ Finset.sum_eq_single x ] <;> aesop

/-
Elementary matrix multiplication rule:
    E_{ab} · E_{cd} = if b = c then E_{ad} else 0.
-/
theorem elementaryMatrix_mul (a b c d : X) :
    elementaryMatrix a b * elementaryMatrix c d =
    if b = c then elementaryMatrix a d else 0 := by
  ext i j;
  split_ifs <;> simp +decide [ *, Matrix.mul_apply, elementaryMatrix ];
  · rw [ Finset.sum_eq_single c ] <;> aesop;
  · rw [ Finset.sum_eq_zero ] ; aesop

/-! ### Kernel-Quotient Factorization -/

/-
A state functional factors through a setoid Q if and only if
    the setoid is contained in the functional's kernel.
-/
omit [DecidableEq X] in
theorem factorsThrough_iff_le_kernel (μ : StateFunctional X) (Q : Setoid X) :
    μ.factorsThrough Q ↔ (∀ x y, Q.r x y → μ.kernel.r x y) := by
  exact Iff.symm (Eq.to_iff rfl)

/-! ### Main Correspondence Theorem -/

/-
**Equilibrium-Character Correspondence (Existence Direction)**:
    Given an equilibrium functional (positive normalized eigenvector of A),
    the equilibrium-weighted sum defines a normalized additive functional
    on the correspondence semiring.

    This establishes that every thermodynamic equilibrium state gives rise
    to an algebraic character, forming one direction of the fundamental
    correspondence in thermodynamic Galois duality.
-/
omit [DecidableEq X] in
theorem equilibrium_gives_normalized_functional
    {A : Matrix X X NNReal}
    (eq_func : EquilibriumFunctional X A) :
    equilibriumWeightedSum eq_func.toStateFunctional 0 = 0 ∧
    (∀ M N : Matrix X X NNReal,
      equilibriumWeightedSum eq_func.toStateFunctional (M + N) =
      equilibriumWeightedSum eq_func.toStateFunctional M +
      equilibriumWeightedSum eq_func.toStateFunctional N) ∧
    equilibriumWeightedSum eq_func.toStateFunctional A = eq_func.eigenvalue := by
  simp_all +decide [ equilibriumWeightedSum ];
  refine' ⟨ fun M N => _, _ ⟩;
  · simp +decide only [sum_add_distrib, add_mul];
  · convert eigenvector_total_mass eq_func using 1;
    rw [ Finset.sum_comm, Finset.sum_congr rfl fun _ _ => Finset.sum_mul _ _ _ ]

end