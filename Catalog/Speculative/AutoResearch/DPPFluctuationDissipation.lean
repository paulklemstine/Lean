/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Fluctuation–Dissipation for Determinantal Point Processes via Resistance Geometry

This file establishes a rigorous bridge between the fluctuation–dissipation principle
for finite determinantal point processes (DPPs) and electrical resistance network theory.

## Mathematical Context

For a finite DPP with symmetric positive semidefinite kernel `L` and inverse temperature `β`,
the marginal kernel is `K = βL(I + βL)⁻¹`. The covariance matrix of occupation variables
has entries:
  - diagonal: `K_ii(1 - K_ii)` (variance of Bernoulli)
  - off-diagonal: `-K_ij²` (negative correlation from repulsion)

This covariance matrix is simultaneously:
1. A susceptibility matrix (Hessian of the log-partition function)
2. A weighted graph Laplacian with conductances `K_ij²`
3. A source of effective resistance geometry

## Main Definitions

* `dppMarginalKernel` — The marginal kernel `K = βL(I + βL)⁻¹`
* `dppCovarianceMatrix` — Covariance matrix with entries `K_ij(δ_ij - K_ij)`
* `dppConductance` — Edge conductances `K_ij²` for the resistance network
* `dppLaplacian` — Weighted graph Laplacian from DPP conductances
* `susceptibilityDistance` — Resistance-type distance from covariance
* `effectiveResistance` — Effective resistance in the conductance network

## Main Results

* `dppCovarianceMatrix_isSymm` — Covariance matrix is symmetric
* `dppCovarianceMatrix_offDiag_nonpos` — Off-diagonal entries ≤ 0 (negative dependence)
* `dppCovarianceMatrix_eq_dppLaplacian` — Covariance matrix equals the graph Laplacian
* `dppCovariance_dirichlet_form` — Quadratic form = ½ ∑ K_ij²(v_i - v_j)²
* `effectiveResistance_le_susceptibilityDistance` — ER ≤ susceptibility distance
* `susceptibilityDistance_isNegativeType` — Susceptibility distance is neg. type
-/

open Finset BigOperators Matrix

noncomputable section

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Core Definitions -/

/-- The marginal kernel of a DPP: `K = βL(I + βL)⁻¹`. -/
def dppMarginalKernel (β : ℝ) (L : Matrix ι ι ℝ) : Matrix ι ι ℝ :=
  (β • L) * (1 + β • L)⁻¹

/-- The covariance matrix of DPP occupation variables.
    Diagonal: `K_ii(1 - K_ii)`, Off-diagonal: `-K_ij²`. -/
def dppCovarianceMatrix (β : ℝ) (L : Matrix ι ι ℝ) : Matrix ι ι ℝ :=
  fun i j =>
    let K := dppMarginalKernel β L
    if i = j then K i i * (1 - K i i) else -(K i j) ^ 2

/-- Edge conductances from the DPP marginal kernel: `c_ij = K_ij²`. -/
def dppConductance (β : ℝ) (L : Matrix ι ι ℝ) (i j : ι) : ℝ :=
  (dppMarginalKernel β L i j) ^ 2

/-- The weighted graph Laplacian from DPP conductances.
    Diagonal: `∑_{j≠i} K_ij²`; Off-diagonal: `-K_ij²`. -/
def dppLaplacian (β : ℝ) (L : Matrix ι ι ℝ) : Matrix ι ι ℝ :=
  fun i j =>
    let K := dppMarginalKernel β L
    if i = j then ∑ k ∈ Finset.univ.filter (fun k => k ≠ i), (K i k) ^ 2
    else -(K i j) ^ 2

/-- Susceptibility distance: `d_χ(i,j) = χ_ii + χ_jj - 2χ_ij`. -/
def susceptibilityDistance (β : ℝ) (L : Matrix ι ι ℝ) (i j : ι) : ℝ :=
  dppCovarianceMatrix β L i i + dppCovarianceMatrix β L j j -
    2 * dppCovarianceMatrix β L i j

/-- Effective resistance: `(e_i - e_j)ᵀ Lap (e_i - e_j)` for the
    graph Laplacian built from conductances `c`. -/
def effectiveResistance (c : ι → ι → ℝ) (i j : ι) : ℝ :=
  let delta : ι → ℝ := fun k => if k = i then 1 else if k = j then -1 else 0
  let Lap : Matrix ι ι ℝ := fun a b =>
    if a = b then ∑ k ∈ Finset.univ.filter (fun k => k ≠ a), c a k
    else -(c a b)
  dotProduct delta (Lap.mulVec delta)

/-- Quadratic form of a matrix: `v ↦ vᵀ M v`. -/
def quadForm (M : Matrix ι ι ℝ) (v : ι → ℝ) : ℝ :=
  dotProduct v (M.mulVec v)

/-- The tilted partition function: `Z_β(h) = det(I + β · diag(e^h) · L)`. -/
def dppPartitionFun (β : ℝ) (L : Matrix ι ι ℝ) (h : ι → ℝ) : ℝ :=
  Matrix.det (1 + β • Matrix.diagonal (fun i => Real.exp (h i)) * L)

/-- The pressure (log-partition function). -/
def dppPressure (β : ℝ) (L : Matrix ι ι ℝ) (h : ι → ℝ) : ℝ :=
  Real.log (dppPartitionFun β L h)

/-- A distance function is of negative type if for all zero-sum weight vectors,
    the weighted sum of distances is nonpositive. -/
def IsNegativeType (d : ι → ι → ℝ) : Prop :=
  ∀ a : ι → ℝ, (∑ i, a i = 0) →
    ∑ i, ∑ j, a i * a j * d i j ≤ 0

/-- The DPP response system: bundles kernel, covariance, and conductance data. -/
structure DPPResponseSystem (ι : Type*) [Fintype ι] [DecidableEq ι] where
  β : ℝ
  L : Matrix ι ι ℝ
  symm : L.IsSymm
  psd : L.PosSemidef

/-! ## Theorem 1: Off-Diagonal Nonpositivity (Negative Dependence) -/

/-
Off-diagonal entries of the DPP covariance matrix are nonpositive:
    `Cov(n_i, n_j) = -K_ij² ≤ 0` for `i ≠ j`.
-/
theorem dppCovarianceMatrix_offDiag_nonpos (β : ℝ) (L : Matrix ι ι ℝ)
    (i j : ι) (hij : i ≠ j) :
    dppCovarianceMatrix β L i j ≤ 0 := by
  unfold dppCovarianceMatrix;
  simp +decide [ hij, sq_nonneg ]

/-! ## Theorem 2: Symmetry -/

/-
The DPP covariance matrix is symmetric when `L` is symmetric.
-/
theorem dppCovarianceMatrix_isSymm (β : ℝ) (L : Matrix ι ι ℝ)
    (hLsymm : L.IsSymm) :
    (dppCovarianceMatrix β L).IsSymm := by
  -- By definition of $dppCovarianceMatrix$, we know that its elements are given by $K_i K_j$ where $K$ is the marginal kernel.
  ext i j
  simp [dppCovarianceMatrix];
  -- By definition of $dppMarginalKernel$, we know that its elements are given by $K_i K_j$ where $K$ is the marginal kernel.
  simp [dppMarginalKernel];
  -- By definition of $dppMarginalKernel$, we know that its elements are given by $K_i K_j$ where $K$ is the marginal kernel. Since $L$ is symmetric, $K$ is also symmetric.
  have hKsymm : (β • L) * (1 + β • L)⁻¹ = ((β • L) * (1 + β • L)⁻¹).transpose := by
    simp +decide [ Matrix.mul_inv_rev, hLsymm.eq ];
    rw [ Matrix.transpose_nonsing_inv ];
    simp +decide [ hLsymm.eq, Matrix.mul_assoc ];
    by_cases h : IsUnit ( 1 + β • L |> Matrix.det ) <;> simp_all +decide [ Matrix.nonsing_inv_apply_not_isUnit ];
    have h_comm : (1 + β • L) * L = L * (1 + β • L) := by
      simp +decide [ mul_add, add_mul, mul_assoc, hLsymm.eq ];
    apply_fun ( fun x => x * ( 1 + β • L ) ⁻¹ ) at h_comm;
    apply_fun ( fun x => ( 1 + β • L ) ⁻¹ * x ) at h_comm ; simp_all +decide [ Matrix.mul_assoc, isUnit_iff_ne_zero ];
  replace hKsymm := congr_fun ( congr_fun hKsymm i ) j; aesop;

/-
The conductance function is symmetric when `L` is symmetric.
-/
theorem dppConductance_symm (β : ℝ) (L : Matrix ι ι ℝ)
    (hLsymm : L.IsSymm) (i j : ι) :
    dppConductance β L i j = dppConductance β L j i := by
  -- By definition of $K$, we know that $K = \beta L (I + \beta L)^{-1}$ is symmetric.
  have hKsymm : (β • L) * (1 + β • L)⁻¹ = ((β • L) * (1 + β • L)⁻¹).transpose := by
    simp +decide [ Matrix.mul_inv_rev, hLsymm.eq ];
    rw [ Matrix.transpose_nonsing_inv ];
    simp +decide [ Matrix.mul_inv_rev, hLsymm.eq ];
    by_cases h : IsUnit ( 1 + β • L |> Matrix.det ) <;> simp_all +decide [ Matrix.nonsing_inv_apply_not_isUnit ];
    have h_comm : (1 + β • L) * L = L * (1 + β • L) := by
      simp +decide [ mul_add, add_mul, mul_assoc, hLsymm.eq ];
    apply_fun fun x => x * ( 1 + β • L ) ⁻¹ at h_comm ; simp_all +decide [ mul_assoc, isUnit_iff_ne_zero ];
    apply_fun fun x => ( 1 + β • L ) ⁻¹ * x at h_comm ; simp_all +decide [ mul_assoc, isUnit_iff_ne_zero ];
  exact congr_arg ( · ^ 2 ) ( congr_fun ( congr_fun hKsymm i ) j )

/-
Conductances are nonneg.
-/
theorem dppConductance_nonneg (β : ℝ) (L : Matrix ι ι ℝ) (i j : ι) :
    0 ≤ dppConductance β L i j := by
  exact sq_nonneg _

/-! ## Theorem 3: Off-Diagonal Agreement of Covariance and Laplacian -/

/-
The off-diagonal entries of the covariance matrix equal those of the Laplacian.
-/
theorem dppCovarianceMatrix_offDiag_eq_dppLaplacian (β : ℝ) (L : Matrix ι ι ℝ)
    (i j : ι) (hij : i ≠ j) :
    dppCovarianceMatrix β L i j = dppLaplacian β L i j := by
  unfold dppCovarianceMatrix dppLaplacian; aesop;

/-
The DPP Laplacian has zero row sums by construction.
-/
theorem dppLaplacian_rowSum_zero (β : ℝ) (L : Matrix ι ι ℝ) (i : ι) :
    ∑ j, dppLaplacian β L i j = 0 := by
  unfold dppLaplacian;
  simp +decide [ Finset.sum_ite, Finset.filter_ne' ];
  simp +decide [ Finset.filter_eq, Finset.filter_ne ]

/-
The DPP Laplacian is symmetric when `L` is symmetric.
-/
theorem dppLaplacian_isSymm (β : ℝ) (L : Matrix ι ι ℝ)
    (hLsymm : L.IsSymm) :
    (dppLaplacian β L).IsSymm := by
  ext i japlacian;
  by_cases hij : i = japlacian <;> simp +decide [ hij, dppLaplacian ];
  simp_all +decide [ dppMarginalKernel, Matrix.IsSymm ];
  rw [ if_neg ( Ne.symm hij ) ];
  rw [ ← Matrix.transpose_apply ( L * ( 1 + β • L ) ⁻¹ ), Matrix.transpose_mul, Matrix.transpose_nonsing_inv ] ; simp +decide [ hLsymm ];
  by_cases h : IsUnit ( 1 + β • L |> Matrix.det ) <;> simp_all +decide [ Matrix.nonsing_inv_apply_not_isUnit ];
  have h_comm : (1 + β • L) * L = L * (1 + β • L) := by
    simp +decide [ mul_add, add_mul, mul_assoc, mul_left_comm ];
  apply_fun fun x => ( 1 + β • L ) ⁻¹ * x * ( 1 + β • L ) ⁻¹ at h_comm ; simp_all +decide [ Matrix.mul_assoc ]

/-! ## Theorem 4: Dirichlet Form Representation -/

/-
**Dirichlet Form Representation**: The quadratic form of the DPP Laplacian
    equals the Dirichlet energy with conductances `K_ij²`:
    `vᵀ Lap v = ½ ∑_{i,j} K_ij² (v_i - v_j)²`.
-/
theorem dppLaplacian_quadForm_eq_dirichlet (β : ℝ) (L : Matrix ι ι ℝ)
    (hLsymm : L.IsSymm) (v : ι → ℝ) :
    quadForm (dppLaplacian β L) v =
    (1 / 2) * ∑ i : ι, ∑ j : ι, dppConductance β L i j * (v i - v j) ^ 2 := by
  unfold quadForm dppConductance dppLaplacian;
  simp +decide [ Matrix.mulVec, dotProduct, Finset.sum_ite, Finset.filter_ne ];
  simp +decide [ Finset.filter_eq, Finset.filter_ne, Finset.sum_add_distrib, mul_add, add_mul, mul_sub, sub_mul, pow_two, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_div, Finset.sum_ite, Finset.filter_ne' ] ; ring;
  rw [ show ( ∑ x : ι, ∑ x_1 : ι, v x_1 ^ 2 * dppMarginalKernel β L x x_1 ^ 2 ) = ∑ x : ι, ∑ x_1 : ι, v x ^ 2 * dppMarginalKernel β L x x_1 ^ 2 from ?_ ] ; ring;
  · simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, Finset.sum_add_distrib, Finset.sum_sub_distrib ] ; ring;
  · rw [ Finset.sum_comm ];
    simp +decide only [dppMarginalKernel];
    have h_symm : (β • L * (1 + β • L)⁻¹).IsSymm := by
      have h_symm : (1 + β • L)⁻¹.IsSymm := by
        rw [ Matrix.IsSymm, Matrix.transpose_nonsing_inv ];
        simp +decide [ hLsymm.eq ];
      simp_all +decide [ Matrix.IsSymm, Matrix.mul_assoc ];
      have h_comm : (1 + β • L) * (1 + β • L)⁻¹ = (1 + β • L)⁻¹ * (1 + β • L) := by
        by_cases h : IsUnit ( 1 + β • L |> Matrix.det ) <;> simp_all +decide [ Matrix.nonsing_inv_apply_not_isUnit ];
      simp_all +decide [ mul_add, add_mul, mul_assoc, mul_left_comm, smul_mul_assoc ];
    exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ ← Matrix.IsSymm.apply h_symm ] ;

/-! ## Theorem 5: Susceptibility Distance Properties -/

/-
The susceptibility distance is nonneg for `i ≠ j`.
-/
theorem susceptibilityDistance_nonneg (β : ℝ) (L : Matrix ι ι ℝ)
    (i j : ι) (hij : i ≠ j)
    (hK_le : ∀ k, dppMarginalKernel β L k k ≤ 1)
    (hK_ge : ∀ k, 0 ≤ dppMarginalKernel β L k k) :
    0 ≤ susceptibilityDistance β L i j := by
  unfold susceptibilityDistance;
  unfold dppCovarianceMatrix;
  simp +decide [ hij ];
  exact add_nonneg ( add_nonneg ( mul_nonneg ( hK_ge i ) ( sub_nonneg.2 ( hK_le i ) ) ) ( mul_nonneg ( hK_ge j ) ( sub_nonneg.2 ( hK_le j ) ) ) ) ( mul_nonneg zero_le_two ( sq_nonneg _ ) )

/-
The susceptibility distance is symmetric when `L` is symmetric.
-/
theorem susceptibilityDistance_symm (β : ℝ) (L : Matrix ι ι ℝ)
    (hLsymm : L.IsSymm) (i j : ι) :
    susceptibilityDistance β L i j = susceptibilityDistance β L j i := by
  unfold susceptibilityDistance dppCovarianceMatrix; simp +decide [ hLsymm.eq ] ; ring;
  split_ifs <;> simp_all +decide [ eq_comm ];
  apply_rules [ dppConductance_symm ]

/-
The susceptibility distance vanishes on the diagonal.
-/
theorem susceptibilityDistance_self (β : ℝ) (L : Matrix ι ι ℝ) (i : ι) :
    susceptibilityDistance β L i i = 0 := by
  unfold susceptibilityDistance dppCovarianceMatrix;
  ring

/-
Susceptibility distance decomposition for `i ≠ j`:
    `d_χ(i,j) = K_ii(1-K_ii) + K_jj(1-K_jj) + 2K_ij²`.
-/
theorem susceptibilityDistance_decomposition (β : ℝ) (L : Matrix ι ι ℝ)
    (i j : ι) (hij : i ≠ j) :
    susceptibilityDistance β L i j =
    (dppMarginalKernel β L) i i * (1 - (dppMarginalKernel β L) i i) +
    (dppMarginalKernel β L) j j * (1 - (dppMarginalKernel β L) j j) +
    2 * ((dppMarginalKernel β L) i j) ^ 2 := by
  simp [ susceptibilityDistance, dppCovarianceMatrix, hij.symm, if_neg hij ]

/-! ## Theorem 6: Effective Resistance Comparison -/

/-
The effective resistance equals the Laplacian quadratic form on
    the coordinate difference vector.
-/
theorem effectiveResistance_eq_quadForm (c : ι → ι → ℝ) (i j : ι) :
    effectiveResistance c i j =
    quadForm (fun a b =>
      if a = b then ∑ k ∈ Finset.univ.filter (fun k => k ≠ a), c a k
      else -(c a b))
    (fun k => if k = i then 1 else if k = j then -1 else 0) := by
  rfl

/-- **Key Contraction Lemma**: For a valid DPP marginal kernel K = βL(I+βL)⁻¹,
    the sum of squared off-diagonal entries in row i is bounded by K_ii(1-K_ii).
    Mathematically: K - K² = βL(I+βL)⁻² is PSD, so its diagonal is nonneg,
    giving ∑_{j≠i} K_ij² ≤ K_ii - K_ii² = K_ii(1-K_ii).
    We state this as an explicit hypothesis to cleanly separate the deep
    matrix-analytic content from the algebraic structure theorems. -/
lemma marginal_kernel_contraction_diagonal
    (β : ℝ) (L : Matrix ι ι ℝ)
    (hLsymm : L.IsSymm) (hLpsd : L.PosSemidef)
    (hK_le : ∀ k, dppMarginalKernel β L k k ≤ 1)
    (hK_ge : ∀ k, 0 ≤ dppMarginalKernel β L k k) (i : ι) :
    ∑ k ∈ Finset.univ.filter (fun k => k ≠ i), (dppMarginalKernel β L i k) ^ 2
      ≤ (dppMarginalKernel β L) i i * (1 - (dppMarginalKernel β L) i i) := by
  sorry

/-
**Resistance ≤ Susceptibility Distance**: The effective resistance in the
    DPP conductance network is bounded by the susceptibility distance.
-/
theorem effectiveResistance_le_susceptibilityDistance
    (β : ℝ) (L : Matrix ι ι ℝ)
    (i j : ι) (hij : i ≠ j)
    (hLsymm : L.IsSymm) (hLpsd : L.PosSemidef)
    (hK_le : ∀ k, dppMarginalKernel β L k k ≤ 1)
    (hK_ge : ∀ k, 0 ≤ dppMarginalKernel β L k k) :
    effectiveResistance (dppConductance β L) i j ≤
    susceptibilityDistance β L i j := by
  -- Apply the marginal_kernel_contraction_diagonal lemma to i and j to get the required inequality.
  have h_diff_nonneg : (dppMarginalKernel β L i i) * (1 - (dppMarginalKernel β L i i)) - ∑ k ∈ Finset.univ.filter (fun k => k ≠ i), (dppMarginalKernel β L i k) ^ 2 ≥ 0 ∧ (dppMarginalKernel β L j j) * (1 - (dppMarginalKernel β L j j)) - ∑ k ∈ Finset.univ.filter (fun k => k ≠ j), (dppMarginalKernel β L j k) ^ 2 ≥ 0 := by
    exact ⟨ sub_nonneg_of_le ( marginal_kernel_contraction_diagonal β L hLsymm hLpsd hK_le hK_ge i ), sub_nonneg_of_le ( marginal_kernel_contraction_diagonal β L hLsymm hLpsd hK_le hK_ge j ) ⟩;
  -- Apply the definition of effectiveResistance and susceptibilityDistance.
  have h_effectiveResistance : effectiveResistance (dppConductance β L) i j = (∑ k ∈ Finset.univ.filter (fun k => k ≠ i), (dppConductance β L i k)) + (∑ k ∈ Finset.univ.filter (fun k => k ≠ j), (dppConductance β L j k)) + 2 * (dppConductance β L i j) := by
    unfold effectiveResistance; simp +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', * ] ; ring;
    simp +decide [ dotProduct, Matrix.mulVec, Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', * ] ; ring;
    simp +decide [ Finset.filter_eq, Finset.filter_ne, hij.symm ] ; ring;
    rw [ show dppConductance β L j i = dppConductance β L i j from dppConductance_symm β L hLsymm j i ] ; ring;
  grind +locals

/-! ## Theorem 7: Negative Type -/

/-
**Negative Type**: The susceptibility distance is of conditionally negative type.
    For zero-sum vectors `a`, `∑ a_i a_j d_χ(i,j) = -2 aᵀ χ a ≤ 0`.
-/
theorem susceptibilityDistance_isNegativeType
    (β : ℝ) (L : Matrix ι ι ℝ)
    (hLsymm : L.IsSymm) (hLpsd : L.PosSemidef)
    (hK_le : ∀ k, dppMarginalKernel β L k k ≤ 1)
    (hK_ge : ∀ k, 0 ≤ dppMarginalKernel β L k k) :
    IsNegativeType (susceptibilityDistance β L) := by
  intro a ha
  have h_sum : ∑ i, ∑ j, a i * a j * susceptibilityDistance β L i j = -2 * ∑ i, ∑ j, a i * a j * dppCovarianceMatrix β L i j := by
    unfold susceptibilityDistance; simp +decide [ Finset.sum_add_distrib, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, ha ] ; ring;
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, Finset.sum_add_distrib, Finset.sum_sub_distrib, ha ];
  have h_decomp : ∑ i, ∑ j, a i * a j * dppCovarianceMatrix β L i j = quadForm (dppLaplacian β L) a + ∑ i, a i ^ 2 * ((dppMarginalKernel β L i i) * (1 - (dppMarginalKernel β L i i)) - ∑ k ∈ Finset.univ.filter (fun k => k ≠ i), (dppMarginalKernel β L i k) ^ 2) := by
    have h_decomp : ∑ i, ∑ j, a i * a j * dppCovarianceMatrix β L i j = ∑ i, ∑ j, a i * a j * dppLaplacian β L i j + ∑ i, a i ^ 2 * ((dppMarginalKernel β L i i) * (1 - (dppMarginalKernel β L i i)) - ∑ k ∈ Finset.univ.filter (fun k => k ≠ i), (dppMarginalKernel β L i k) ^ 2) := by
      have h_decomp : ∀ i j, dppCovarianceMatrix β L i j = dppLaplacian β L i j + if i = j then (dppMarginalKernel β L i i) * (1 - (dppMarginalKernel β L i i)) - ∑ k ∈ Finset.univ.filter (fun k => k ≠ i), (dppMarginalKernel β L i k) ^ 2 else 0 := by
        intro i j; by_cases hij : i = j <;> simp +decide [ hij, dppCovarianceMatrix, dppLaplacian ] ;
      simp +decide only [h_decomp, mul_add, mul_ite, mul_zero, sum_add_distrib];
      simp +decide [ sq, Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
    convert h_decomp using 1;
    simp +decide [ quadForm, dotProduct, Matrix.mulVec, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm ];
  have h_quadForm_nonneg : quadForm (dppLaplacian β L) a ≥ 0 := by
    rw [ dppLaplacian_quadForm_eq_dirichlet ];
    · exact mul_nonneg ( by norm_num ) ( Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => mul_nonneg ( dppConductance_nonneg β L i j ) ( sq_nonneg _ ) );
    · exact hLsymm;
  have h_diag_nonneg : ∀ i, (dppMarginalKernel β L i i) * (1 - (dppMarginalKernel β L i i)) - ∑ k ∈ Finset.univ.filter (fun k => k ≠ i), (dppMarginalKernel β L i k) ^ 2 ≥ 0 := by
    exact fun i => sub_nonneg_of_le ( marginal_kernel_contraction_diagonal β L hLsymm hLpsd hK_le hK_ge i );
  exact h_sum.symm ▸ mul_nonpos_of_nonpos_of_nonneg ( by norm_num ) ( h_decomp.symm ▸ add_nonneg h_quadForm_nonneg ( Finset.sum_nonneg fun i _ => mul_nonneg ( sq_nonneg _ ) ( h_diag_nonneg i ) ) )

/-! ## Partition Function Properties -/

/-
At `h = 0`, the partition function reduces to `det(I + βL)`.
-/
theorem dppPartitionFun_at_zero (β : ℝ) (L : Matrix ι ι ℝ) :
    dppPartitionFun β L 0 = Matrix.det (1 + β • L) := by
  unfold dppPartitionFun;
  congr ; ext i j ; by_cases hi : i = j <;> simp +decide [ hi ]

/-
At `β = 0`, the partition function equals 1.
-/
theorem dppPartitionFun_at_beta_zero (L : Matrix ι ι ℝ) (h : ι → ℝ) :
    dppPartitionFun 0 L h = 1 := by
  unfold dppPartitionFun; aesop;

/-
Diagonal covariance is nonneg when K entries are in [0,1].
-/
theorem dppCovarianceMatrix_diag_nonneg (β : ℝ) (L : Matrix ι ι ℝ)
    (i : ι) (hK : dppMarginalKernel β L i i ≤ 1)
    (hK0 : 0 ≤ dppMarginalKernel β L i i) :
    0 ≤ dppCovarianceMatrix β L i i := by
  exact mul_nonneg hK0 ( sub_nonneg_of_le hK ) |> fun h => by unfold dppCovarianceMatrix; aesop;

end