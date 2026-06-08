/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Determinantal Point Processes, Lorentzian Polynomials, and Negative Dependence

This file formalizes the connection between determinantal point processes (DPPs),
Lorentzian polynomial theory, and negative dependence inequalities in probability.

## Mathematical Context

A determinantal point process (DPP) on `Fin n` with kernel `K` has generating polynomial
  `Z_K(x₁,…,xₙ) := det(I + diag(x) · K)`
whose degree-`d` homogeneous component is
  `Z_{K,d}(x) = ∑_{|S|=d} det(K_S) · ∏_{i∈S} xᵢ`
where `K_S` is the principal submatrix indexed by `S`.

For positive semidefinite `K`, these coefficients are nonneg principal minors, and the
homogeneous components satisfy Lorentzian polynomial inequalities that imply negative
dependence for the associated probability measure.

## Main Definitions

* `DPPKernel` — Bundled symmetric positive semidefinite kernel matrix
* `dppPartitionFunction` — The multivariate generating polynomial `det(I + diag(x)K)`
* `dppHomogeneousComponent` — Degree-`d` homogeneous component of the partition function
* `pairInclusionWeight` — The 2×2 principal minor `det K_{i,j} = K_ii K_jj - K_ij K_ji`
* `singleInclusionWeight` — The diagonal entry `K_ii`

## Main Results

* `dpp_uniformSpecialization` — `Z_K(t,…,t) = det(I + tK)`: spectral bridge
* `dpp_partitionFunction_eval_ones` — `Z_K(1,…,1) = det(I + K)`
* `dpp_partitionFunction_eval_zero` — `Z_K(0,…,0) = 1`
* `psd_principal_minor_nonneg` — Principal minors of PSD matrices are nonneg
* `psd_pairInclusion_nonneg` — 2×2 principal minor nonneg for PSD
* `dpp_pairwise_negative_dependence` — `det K_{ij} ≤ K_ii · K_jj`: negative dependence
* `dpp_diagonal_factored` — Diagonal DPP factors as `∏(1 + wᵢxᵢ)`
* `dpp_diagonal_uniformSpec` — Diagonal DPP uniform specialization = `∏(1 + twᵢ)`

## Cross-Domain Connections

* **Statistical physics ↔ Spectral theory**: The uniform specialization theorem connects
  the DPP partition function (a statistical-mechanical object) to spectral invariants of K.
* **Algebraic combinatorics ↔ Probability**: Lorentzian structure of generating polynomials
  implies negative dependence, linking Hodge-theoretic geometry to repulsive random models.
* **Linear algebra ↔ Machine learning**: PSD kernel structure yields certified diversity
  guarantees for DPP-based subset selection algorithms.

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Macchi, "The coincidence approach to stochastic point processes", 1975
* Kulesza–Taskar, "Determinantal Point Processes for Machine Learning", 2012
-/

open Finset BigOperators Matrix MvPolynomial

noncomputable section

/-! ## Core Definitions -/

/-- A DPP kernel: a symmetric positive semidefinite real matrix.
    This bundles the linear-algebraic data needed for a determinantal point process. -/
structure DPPKernel (n : ℕ) where
  /-- The kernel matrix -/
  K : Matrix (Fin n) (Fin n) ℝ
  /-- The kernel is symmetric -/
  symm : K.IsSymm
  /-- The kernel is positive semidefinite -/
  psd : K.PosSemidef

/-- The multivariate generating polynomial (partition function) of a DPP:
    `Z_K(x₁,…,xₙ) = det(I + diag(x₁,…,xₙ) · K)`.
    This is an element of `MvPolynomial (Fin n) ℝ`. -/
def dppPartitionFunction {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    MvPolynomial (Fin n) ℝ :=
  Matrix.det (1 + Matrix.diagonal (fun i => (MvPolynomial.X i : MvPolynomial (Fin n) ℝ)) *
    K.map MvPolynomial.C)

/-- The degree-`d` homogeneous component of the DPP generating polynomial.
    For PSD kernels, this equals the generating function of d-subset principal minors. -/
def dppHomogeneousComponent {n d : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    MvPolynomial (Fin n) ℝ :=
  MvPolynomial.homogeneousComponent d (dppPartitionFunction K)

/-- The pairwise inclusion weight: the 2×2 principal minor `det K_{i,j}`.
    In the DPP probability model, this equals `Pr[i ∈ S ∧ j ∈ S]`. -/
def pairInclusionWeight {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : ℝ :=
  K i i * K j j - K i j * K j i

/-- The single inclusion weight: the diagonal entry `K_ii`.
    In the DPP probability model, this equals `Pr[i ∈ S]`. -/
def singleInclusionWeight {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) : ℝ :=
  K i i

/-- Embedding of a pair `(i, j)` into `Fin n` for 2×2 submatrix extraction. -/
def pairEmbed {n : ℕ} (i j : Fin n) : Fin 2 → Fin n := ![i, j]

/-! ## Theorem 1: Uniform Specialization — Spectral Bridge -/

/-- **Uniform specialization theorem**: evaluating the DPP partition function at
    `x₁ = ⋯ = xₙ = t` yields `det(I + tK)`.

    This is the key bridge between the multivariate generating polynomial
    (a combinatorial/algebraic object) and spectral theory. When `K` is
    diagonalizable with eigenvalues `λ₁,…,λₙ`, the right-hand side equals
    `∏ᵢ (1 + tλᵢ)`, connecting DPP partition functions to elementary symmetric
    functions of eigenvalues.

    **Cross-domain significance**: This theorem bridges statistical physics
    (partition function) with random matrix theory (spectral determinant). -/
theorem dpp_uniformSpecialization
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (t : ℝ) :
    MvPolynomial.aeval (fun _ : Fin n => t) (dppPartitionFunction K)
      = Matrix.det (1 + t • K) := by
  unfold dppPartitionFunction
  rw [AlgHom.map_det]
  congr 1
  ext i j
  simp [AlgHom.mapMatrix, Matrix.map, Matrix.diagonal, Matrix.mul_apply,
    Matrix.one_apply, Matrix.smul_apply]

/-- Evaluating the partition function at all ones gives `det(I + K)`,
    the total mass of the DPP probability measure. -/
theorem dpp_partitionFunction_eval_ones
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    MvPolynomial.aeval (fun _ : Fin n => (1 : ℝ)) (dppPartitionFunction K)
      = Matrix.det (1 + K) := by
  rw [dpp_uniformSpecialization]
  simp [one_smul]

/-- Evaluating the partition function at all zeros gives 1
    (the determinant of the identity matrix). -/
theorem dpp_partitionFunction_eval_zero
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    MvPolynomial.aeval (fun _ : Fin n => (0 : ℝ)) (dppPartitionFunction K) = 1 := by
  rw [dpp_uniformSpecialization]
  simp

/-! ## Theorem 2: Principal Minor Nonnegativity from PSD -/

/-- All principal minors of a positive semidefinite matrix are nonneg.
    This is the algebraic foundation of the probabilistic interpretation:
    the coefficients of the DPP generating polynomial are nonneg weights. -/
theorem psd_principal_minor_nonneg {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.PosSemidef) (S : Finset (Fin n)) :
    0 ≤ (K.submatrix (Subtype.val : S → Fin n) (Subtype.val : S → Fin n)).det :=
  (hK.submatrix _).det_nonneg

/-- The pairwise inclusion weight (2×2 principal minor determinant) is
    nonneg for PSD kernels. This ensures `Pr[i,j ∈ S] ≥ 0`. -/
theorem psd_pairInclusion_nonneg {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKpsd : K.PosSemidef) (i j : Fin n) :
    0 ≤ pairInclusionWeight K i j := by
  unfold pairInclusionWeight
  have hSub := hKpsd.submatrix (pairEmbed i j)
  have hDet := hSub.det_nonneg
  rw [Matrix.det_fin_two] at hDet
  simp only [Matrix.submatrix, pairEmbed] at hDet
  convert hDet using 1

/-
Diagonal entries of PSD matrices are nonneg.
    This ensures `Pr[i ∈ S] ≥ 0`.
-/
theorem psd_singleInclusion_nonneg {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKpsd : K.PosSemidef) (i : Fin n) :
    0 ≤ singleInclusionWeight K i := by
  have := hKpsd.2;
  convert this ( Finsupp.single i 1 ) using 1 ; norm_num [ Finsupp.sum_single_index ];
  rfl

/-! ## Theorem 3: Pairwise Negative Dependence -/

/-- **Pairwise negative dependence for DPPs**: For any symmetric PSD kernel,
    the joint inclusion probability of two items is at most the product of
    their marginal inclusion probabilities:
      `det K_{ij} ≤ K_ii · K_jj`
    equivalently:
      `Pr[i ∈ S ∧ j ∈ S] ≤ Pr[i ∈ S] · Pr[j ∈ S]`

    This is the fundamental repulsion inequality of DPPs. Items selected by a
    DPP are negatively correlated: including one item makes the other less likely.

    **Proof**: By symmetry of K, `K_ij = K_ji`, so
    `K_ii · K_jj - det K_{ij} = K_ij · K_ji = K_ij² ≥ 0`. -/
theorem dpp_pairwise_negative_dependence
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) (_hKpsd : K.PosSemidef)
    (i j : Fin n) (_hij : i ≠ j) :
    pairInclusionWeight K i j ≤ singleInclusionWeight K i * singleInclusionWeight K j := by
  unfold pairInclusionWeight singleInclusionWeight
  have hsym : K j i = K i j := by
    have h := hKsymm; rw [Matrix.IsSymm] at h
    exact congrFun (congrFun h i) j
  have : 0 ≤ K i j * K j i := by rw [hsym]; exact mul_self_nonneg _
  linarith

/-- **Bundled negative dependence for DPPKernel**: convenient wrapper using
    the bundled DPPKernel structure. -/
theorem DPPKernel.pairwise_neg_dep {n : ℕ} (D : DPPKernel n)
    (i j : Fin n) (hij : i ≠ j) :
    pairInclusionWeight D.K i j ≤ singleInclusionWeight D.K i * singleInclusionWeight D.K j :=
  dpp_pairwise_negative_dependence D.K D.symm D.psd i j hij

/-- The negative dependence inequality implies that the covariance
    `Cov(1_i, 1_j) = Pr[i,j ∈ S] - Pr[i ∈ S]·Pr[j ∈ S]` is nonpositive.
    This is the probabilistic reformulation of the negative dependence. -/
theorem dpp_covariance_nonpos
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) (hKpsd : K.PosSemidef)
    (i j : Fin n) (hij : i ≠ j) :
    pairInclusionWeight K i j - singleInclusionWeight K i * singleInclusionWeight K j ≤ 0 := by
  linarith [dpp_pairwise_negative_dependence K hKsymm hKpsd i j hij]

/-- The covariance equals negative `K_ij²` for symmetric PSD kernels.
    This gives the exact covariance formula. -/
theorem dpp_covariance_eq_neg_sq
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (_hKsymm : K.IsSymm)
    (i j : Fin n) :
    pairInclusionWeight K i j - singleInclusionWeight K i * singleInclusionWeight K j
    = -(K i j * K j i) := by
  unfold pairInclusionWeight singleInclusionWeight
  ring

/-! ## Theorem 4: Diagonal DPP Factorization -/

/-
For a diagonal kernel `K = diag(w)`, the DPP partition function factors as
    `∏ᵢ (1 + wᵢxᵢ)`. This is the product-of-linear-forms representation,
    which is the defining case for Lorentzian polynomials.
-/
theorem dpp_diagonal_factored {n : ℕ} (w : Fin n → ℝ) :
    dppPartitionFunction (Matrix.diagonal w) =
    ∏ i : Fin n, (1 + MvPolynomial.C (w i) * MvPolynomial.X i) := by
  convert Matrix.det_diagonal using 3 ; ring;
  unfold dppPartitionFunction;
  congr ; ext i j ; by_cases hij : i = j <;> simp +decide [ hij, mul_comm ];
  infer_instance

/-
Uniform specialization of the diagonal DPP gives the product `∏(1 + twᵢ)`.
-/
theorem dpp_diagonal_uniformSpec {n : ℕ} (w : Fin n → ℝ) (t : ℝ) :
    MvPolynomial.aeval (fun _ : Fin n => t) (dppPartitionFunction (Matrix.diagonal w))
    = ∏ i : Fin n, (1 + t * w i) := by
  rw [dpp_uniformSpecialization]
  rw [ show ( 1 + t • diagonal w : Matrix ( Fin n ) ( Fin n ) ℝ ) = Matrix.diagonal ( fun i => 1 + t * w i ) by ext i j; by_cases hi : i = j <;> aesop ] ; rw [ Matrix.det_diagonal ]

/-! ## Theorem 5: Partition Function of Special Kernels -/

/-
The partition function of the zero kernel is 1 (empty process).
-/
theorem dpp_partitionFunction_zero (n : ℕ) :
    dppPartitionFunction (0 : Matrix (Fin n) (Fin n) ℝ) = 1 := by
  unfold dppPartitionFunction;
  norm_num [ Matrix.det_fin_two ]

/-
The partition function of the identity kernel is `∏(1 + xᵢ)`.
-/
theorem dpp_partitionFunction_identity (n : ℕ) :
    dppPartitionFunction (1 : Matrix (Fin n) (Fin n) ℝ) =
    ∏ i : Fin n, (1 + MvPolynomial.X i) := by
  convert dpp_diagonal_factored ( fun _ => 1 ) using 1;
  norm_num [ MvPolynomial.C_1 ]

/-! ## Conjecture: Lorentzianity of DPP Homogeneous Components

The following theorem is the flagship open formalization target connecting
DPP theory to Lorentzian polynomial geometry. It states that for any symmetric
PSD kernel K, every homogeneous component of the DPP partition function is
Lorentzian in the sense of Brändén–Huh.

**Status**: Stated as a conjecture. The proof requires:
1. Showing `det(I + diag(x)K)` is real stable for PSD K
2. Using the Brändén–Huh theorem: stable + nonneg coefficients ⟹ Lorentzian
3. Showing homogeneous components inherit Lorentzianity

The diagonal case (product of linear forms) is the base case. -/

/-- A polynomial is Lorentzian (Brändén–Huh) if it is homogeneous with nonneg coefficients
    and all degree-2 iterated derivative leaves have Hessian with at most one positive
    eigenvalue. This is the theorem-ready characterization equivalent to the original
    Brändén–Huh definition. -/
def IsDPPLorentzian {n : ℕ} (d : ℕ) (p : MvPolynomial (Fin n) ℝ) : Prop :=
  p.IsHomogeneous d ∧
  (∀ m, 0 ≤ MvPolynomial.coeff m p) ∧
  (d ≥ 2 → ∀ α : Fin n → ℕ, ∑ i, α i = d - 2 →
    ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
      (∑ i, w i * v i = 0) →
        ∑ i, ∑ j, (MvPolynomial.coeff 0
          (MvPolynomial.pderiv i (MvPolynomial.pderiv j
            (Fin.foldl n (fun g k => (MvPolynomial.pderiv k)^[α k] g) p)))) *
          v i * v j ≤ 0)

/-- **Conjecture (Lorentzianity of DPP layers)**: For any symmetric PSD kernel K,
    every homogeneous component of the DPP partition function is Lorentzian.

    This is the flagship open formalization target connecting DPP theory to
    Lorentzian polynomial geometry. The proof requires:
    1. Showing `det(I + diag(x)K)` is real stable for PSD K
    2. Using the Brändén–Huh theorem: stable + nonneg coefficients ⟹ Lorentzian
    3. Showing homogeneous components inherit Lorentzianity

    The diagonal case (product of linear forms) is the base case. -/
theorem dpp_partition_function_lorentzian
    {n d : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) (hKpsd : K.PosSemidef) :
    IsDPPLorentzian d (dppHomogeneousComponent (d := d) K) := by
  sorry

end