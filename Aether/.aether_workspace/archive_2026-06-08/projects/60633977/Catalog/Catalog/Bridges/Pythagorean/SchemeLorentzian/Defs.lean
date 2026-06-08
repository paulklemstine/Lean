/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Scheme-Symmetric Lorentzian Stability: Core Definitions

This file introduces the foundational structures for the theory of
**Lorentzian stability radii under association scheme symmetry**.

## Mathematical Overview

An association scheme on a finite set partitions the pair-space into symmetric
relations (classes) such that the corresponding adjacency matrices form a
commutative algebra (the Bose–Mesner algebra). These matrices are simultaneously
diagonalizable via primitive idempotents.

When a Lorentzian polynomial family has coefficients constant on scheme classes,
its leaf Hessian operators lie in the Bose–Mesner algebra and decompose along
primitive idempotents. This transforms the Lorentzian stability radius into
a finite spectral optimization problem.

## Main Definitions

* `IdempotentSystem` — A family of orthogonal idempotent projections summing to identity
* `SchemeLorentzianFamily` — A Lorentzian family with scheme-symmetric eigenvalue decomposition
* `AffineEigenvalues` — Affinely parameterized eigenvalue families
* `schemeStabilityRadius` — The spectral stability radius as min vanishing time

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Delsarte, "An Algebraic Approach to the Association Schemes of Coding Theory", 1973
-/

open Finset BigOperators Matrix

noncomputable section

namespace SchemeLorentzian

/-! ## Quadratic Form Infrastructure -/

/-- The quadratic form induced by a matrix A: Q_A(x) = ∑ᵢ ∑ⱼ A(i,j) x(i) x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Squared Euclidean norm. -/
def sqNorm {n : ℕ} (v : Fin n → ℝ) : ℝ := ∑ i, v i ^ 2

/-- A matrix has at most one positive eigenvalue (Lorentzian signature). -/
def HasAtMostOnePositiveEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- Gapped Lorentzian signature with quantitative margin ε. -/
def HasGappedSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ -ε * sqNorm v

/-- Quadratic form bound: |Q_A(v)| ≤ c · ‖v‖² for all v. -/
def QuadFormBound {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) : Prop :=
  ∀ v : Fin n → ℝ, |QuadForm A v| ≤ c * sqNorm v

theorem sqNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

theorem quadForm_add {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    QuadForm (A + E) v = QuadForm A v + QuadForm E v := by
  unfold QuadForm; simp [Finset.sum_add_distrib, add_mul]

/-! ## Idempotent System

A family of operators `E₀, …, E_d` on ℝⁿ satisfying:
- pairwise orthogonality (E_i · E_j = 0 for i ≠ j),
- idempotency (E_i² = E_i),
- completeness (∑ E_i = Id).

This captures the primitive idempotent structure of any commutative
semisimple algebra, in particular the Bose–Mesner algebra. -/

/-- An **idempotent system** of `d+1` orthogonal projections on ℝⁿ.
    Index 0 is the distinguished "trivial" component. -/
structure IdempotentSystem (d n : ℕ) where
  /-- The projection matrices for each primitive idempotent class. -/
  proj : Fin (d + 1) → Matrix (Fin n) (Fin n) ℝ
  /-- Idempotent: E_i² = E_i. -/
  idempotent : ∀ i, proj i * proj i = proj i
  /-- Orthogonal: E_i · E_j = 0 for i ≠ j. -/
  orthogonal : ∀ i j, i ≠ j → proj i * proj j = 0
  /-- Completeness: ∑ E_i = 1. -/
  complete : ∑ i : Fin (d + 1), proj i = 1

/-! ## Scheme-Symmetric Lorentzian Family -/

/-- A **scheme-symmetric Lorentzian family** captures a one-parameter family
    of quadratic leaf Hessians decomposing along primitive idempotents.

    The Lorentzian condition at base point `t = 0` requires:
    - `θ₀(0) > 0` (positive on trivial component)
    - `θ_j(0) < 0` for `j ≥ 1` (negative on nontrivial components) -/
structure SchemeLorentzianFamily (d n : ℕ) where
  /-- The primitive idempotent decomposition. -/
  decomp : IdempotentSystem d n
  /-- Eigenvalue of the j-th component at parameter t. -/
  eigenvalue : Fin (d + 1) → ℝ → ℝ
  /-- The leaf Hessian at parameter t. -/
  leafHessian : ℝ → Matrix (Fin n) (Fin n) ℝ
  /-- Spectral decomposition: H(t) = ∑_j θ_j(t) · E_j. -/
  spectral_decomp : ∀ t, leafHessian t =
    ∑ j : Fin (d + 1), eigenvalue j t • decomp.proj j
  /-- Trivial component is positive at base point. -/
  pos_trivial : eigenvalue 0 0 > 0
  /-- Nontrivial components are negative at base point. -/
  neg_nontrivial : ∀ j : Fin (d + 1), j ≠ 0 → eigenvalue j 0 < 0

/-! ## Affine Eigenvalue Families -/

/-- Affine eigenvalue specification: θ_j(t) = a_j + t · b_j.
    For Lorentzian families, nontrivial classes have a_j < 0 and b_j > 0,
    so eigenvalues start negative and increase, crossing zero at t = -a_j/b_j. -/
structure AffineEigenvalues (d : ℕ) where
  /-- Base eigenvalue a_j = θ_j(0). -/
  baseVal : Fin (d + 1) → ℝ
  /-- Perturbation rate b_j. -/
  pertRate : Fin (d + 1) → ℝ
  /-- Nontrivial base eigenvalues are negative. -/
  neg_base : ∀ j : Fin (d + 1), j ≠ 0 → baseVal j < 0
  /-- Perturbation rates for nontrivial classes are positive. -/
  pos_rate : ∀ j : Fin (d + 1), j ≠ 0 → 0 < pertRate j

/-- Evaluate an affine eigenvalue at parameter t. -/
def AffineEigenvalues.evalAt {d : ℕ} (A : AffineEigenvalues d) (j : Fin (d + 1)) (t : ℝ) : ℝ :=
  A.baseVal j + t * A.pertRate j

/-- The vanishing time of the j-th nontrivial eigenvalue: t_j = -a_j / b_j.
    This is the parameter value where θ_j(t) = 0. -/
def AffineEigenvalues.vanishingTime {d : ℕ} (A : AffineEigenvalues d) (j : Fin (d + 1)) : ℝ :=
  -A.baseVal j / A.pertRate j

/-- The set of nontrivial class indices. -/
def nontrivialClasses (d : ℕ) : Finset (Fin (d + 1)) :=
  Finset.univ.filter (· ≠ 0)

/-- The nontrivial class set is nonempty when d > 0. -/
theorem nontrivialClasses_nonempty {d : ℕ} (hd : 0 < d) :
    (nontrivialClasses d).Nonempty := by
  refine ⟨⟨1, by omega⟩, Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩⟩
  simp

/-- The **scheme stability radius** for an affine eigenvalue family:
    ρ = min_{j≥1} (-a_j / b_j), the minimum vanishing time across nontrivial classes. -/
def schemeStabilityRadius {d : ℕ} (A : AffineEigenvalues d) (hd : 0 < d) : ℝ :=
  (nontrivialClasses d).inf' (nontrivialClasses_nonempty hd) A.vanishingTime

/-! ## Johnson Scheme Specialization -/

/-- **Johnson scheme J(n,2) eigenvalue data.**
    The leaf Hessian of e₂(x₁,…,xₙ) = J - I decomposes as:
    - θ₀ = n - 1 (trivial, multiplicity 1) with perturbation rate 0
    - θ₁ = -1 (standard, multiplicity n-1) with perturbation rate 1

    Under perturbation H(t) = (J-I) + t·I, the eigenvalues become:
    - θ₀(t) = n - 1 (unchanged)
    - θ₁(t) = -1 + t (crosses zero at t = 1) -/
def johnsonJ2_eigenvalues (n : ℕ) (hn : 2 ≤ n) : AffineEigenvalues 1 where
  baseVal := ![↑n - 1, -1]
  pertRate := ![0, 1]
  neg_base := by
    intro j hj; fin_cases j <;> simp_all [Matrix.cons_val_one]
  pos_rate := by
    intro j hj; fin_cases j <;> simp_all [Matrix.cons_val_one]

/-- The Johnson scheme Lorentzian stability radius for J(n,2). -/
def johnsonLorentzianRadius (n : ℕ) (hn : 2 ≤ n) : ℝ :=
  schemeStabilityRadius (johnsonJ2_eigenvalues n hn) (by omega)

/-! ## Hamming Scheme Data -/

/-- **Hamming scheme perturbation family** for H(n,q).
    Captures the Krawtchouk-spectral data needed for stability bounds. -/
structure HammingLorentzianFamily (n q : ℕ) where
  /-- Number of association scheme classes (= n for H(n,q)). -/
  numClasses : ℕ
  hClasses : 0 < numClasses
  /-- Affine eigenvalue data from Krawtchouk spectrum. -/
  eigenData : AffineEigenvalues numClasses
  /-- Krawtchouk-derived lower bound on stability radius. -/
  krawtchoukLowerBound : ℝ
  /-- The lower bound is positive. -/
  bound_pos : 0 < krawtchoukLowerBound
  /-- The lower bound is valid: it is at most the stability radius. -/
  bound_valid : krawtchoukLowerBound ≤
    schemeStabilityRadius eigenData hClasses

/-- The Hamming stability radius. -/
def hammingStabilityRadius {n q : ℕ} (F : HammingLorentzianFamily n q) : ℝ :=
  schemeStabilityRadius F.eigenData F.hClasses

end SchemeLorentzian