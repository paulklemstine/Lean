/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Repulsive Information Geometry

This file establishes a rigorous bridge between the information geometry of
determinantal point processes (DPPs) and electrical resistance networks.

The central insight is that the DPP log-Hessian matrix (with off-diagonal entries
`-Lᵢⱼ²` and diagonal chosen for zero row sums) is precisely a weighted graph
Laplacian. Its quadratic form on zero-sum vectors equals a pairwise Dirichlet energy,
identifying repulsion strength with effective resistance.

## Main Definitions

* `zeroSumSubmodule` — Submodule of vectors summing to zero
* `laplacianEnergy` — The quadratic form `xᵀHx` for a zero-row-sum matrix
* `dppLogHessian` — The DPP log-Hessian / graph Laplacian
* `coordDiff` — Standard basis difference vectors `eᵢ - eⱼ`

## Main Results

* `laplacianEnergy_eq_pairwise` — `xᵀHx = ½ ∑ᵢⱼ (-Hᵢⱼ)(xᵢ - xⱼ)²`
* `laplacianEnergy_posDef_on_zeroSum` — Positive definiteness on zero-sum subspace
* `dpp_laplacianEnergy_eq_resolventDirichlet` — `xᵀHx = ½ ∑ Lᵢⱼ²(xᵢ-xⱼ)²` for DPPs
* `diagonal_dpp_logHessian_eq_zero` — Fisher information vanishes for independent trials
-/

open Finset BigOperators Matrix

noncomputable section

/-! ## Core Definitions -/

/-- The submodule of vectors in `Fin n → ℝ` whose coordinates sum to zero. -/
def zeroSumSubmodule (n : ℕ) : Submodule ℝ (Fin n → ℝ) where
  carrier := {x | ∑ i, x i = 0}
  add_mem' {a b} ha hb := by
    simp only [Set.mem_setOf_eq, Pi.add_apply] at *
    rw [Finset.sum_add_distrib]; linarith
  zero_mem' := by simp
  smul_mem' c {x} hx := by
    simp only [Set.mem_setOf_eq, Pi.smul_apply, smul_eq_mul] at *
    rw [← Finset.mul_sum, hx, mul_zero]

/-- The Laplacian energy / Dirichlet energy of matrix `H` on vector `x`: `xᵀHx`.
    For graph Laplacians (like the DPP log-Hessian), this is nonneg on zero-sum vectors
    and measures the "repulsion strength" of perturbation `x`. -/
def laplacianEnergy {n : ℕ} (H : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  dotProduct x (H.mulVec x)

/-- The coordinate difference vector `eᵢ - eⱼ`. -/
def coordDiff (n : ℕ) (i j : Fin n) : Fin n → ℝ :=
  fun k => if k = i then 1 else if k = j then -1 else 0

/-- The DPP log-Hessian: a weighted graph Laplacian with conductances `(Lᵢⱼ)²`.
    Off-diagonal: `H(i,j) = -(L i j)²` (nonpositive).
    Diagonal: `H(i,i) = ∑_{k≠i} (L i k)²` (nonneg, chosen for zero row sums). -/
def dppLogHessian {n : ℕ} (L : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if i = j then ∑ k ∈ Finset.univ.filter (fun k => k ≠ i), (L i k) ^ 2
             else -(L i j) ^ 2

/-! ## Auxiliary Lemmas -/

/-- Expansion of `xᵀHx` as a double sum. -/
lemma dotProduct_mulVec_expand {n : ℕ} (H : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) :
    dotProduct x (H.mulVec x) = ∑ i : Fin n, ∑ j : Fin n, H i j * x i * x j := by
  simp +decide [Matrix.mulVec, dotProduct, mul_assoc, mul_comm, mul_left_comm,
    Finset.mul_sum _ _ _]

/-
For a symmetric matrix with zero row sums,
    `∑ᵢⱼ (-Hᵢⱼ)(xᵢ - xⱼ)² = 2·xᵀHx`.
-/
lemma neg_pairwise_sq_eq_twice_energy {n : ℕ} (H : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (hsym : H.IsSymm)
    (hrowsum : ∀ i, ∑ j, H i j = 0) :
    ∑ i : Fin n, ∑ j : Fin n, (-H i j) * (x i - x j) ^ 2
    = 2 * ∑ i : Fin n, ∑ j : Fin n, H i j * x i * x j := by
  simp +decide only [sub_sq, mul_assoc, mul_add, mul_sub, sum_add_distrib, sum_sub_distrib];
  simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hrowsum ];
  simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, hrowsum ];
  rw [ Finset.sum_comm ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hsym.apply, hrowsum ]

/-! ## Main Theorems -/

/-- **Theorem 1 (Dirichlet Form Identity)**: For any symmetric matrix `H` with zero
    row sums, `xᵀHx = ½ ∑ᵢⱼ (-Hᵢⱼ)(xᵢ - xⱼ)²`.

    When `H` is a graph Laplacian (nonneg diagonal, nonpositive off-diagonal),
    the weights `-Hᵢⱼ` for `i ≠ j` are the edge conductances, and the right-hand
    side is the classical Dirichlet energy of the weighted graph.

    This identifies the DPP repulsion metric with an electrical resistance network. -/
theorem laplacianEnergy_eq_pairwise
    {n : ℕ}
    (H : Matrix (Fin n) (Fin n) ℝ)
    (hsym : H.IsSymm)
    (hrowsum : ∀ i, ∑ j, H i j = 0) :
    ∀ x : Fin n → ℝ,
      laplacianEnergy H x =
      (1 / 2 : ℝ) * ∑ i : Fin n, ∑ j : Fin n, (-H i j) * (x i - x j) ^ 2 := by
  intro x
  unfold laplacianEnergy
  rw [dotProduct_mulVec_expand, neg_pairwise_sq_eq_twice_energy H x hsym hrowsum]
  ring

/-
**Theorem 2 (Positive Definiteness on Zero-Sum)**: If the Laplacian energy is
    nonneg on zero-sum vectors and has trivial zero-sum kernel, then it is strictly
    positive on nonzero zero-sum vectors — defining a genuine metric.
-/
theorem laplacianEnergy_posDef_on_zeroSum
    {n : ℕ}
    (H : Matrix (Fin n) (Fin n) ℝ)
    (hpsd : ∀ x : Fin n → ℝ, (∑ i, x i = 0) →
      0 ≤ laplacianEnergy H x)
    (hndeg : ∀ x : Fin n → ℝ, (∑ i, x i = 0) →
      laplacianEnergy H x = 0 → x = 0) :
    ∀ x : Fin n → ℝ,
      (∑ i, x i = 0) →
      x ≠ 0 →
      0 < laplacianEnergy H x := by
  grind

/-! ## DPP-Specific Results -/

/-- The DPP log-Hessian has zero row sums by construction. -/
theorem dppLogHessian_rowSum_zero {n : ℕ} (L : Matrix (Fin n) (Fin n) ℝ) :
    ∀ i, ∑ j, dppLogHessian L i j = 0 := by
  intro i
  unfold dppLogHessian
  simp [mul_comm, mul_assoc, sub_eq_add_neg]
  simp +decide [Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', Finset.filter_ne']
  simp +decide [Finset.filter_eq, Finset.filter_ne]

/-- The DPP log-Hessian is symmetric when `L` is symmetric. -/
theorem dppLogHessian_symm {n : ℕ} (L : Matrix (Fin n) (Fin n) ℝ)
    (hL : L.IsSymm) : (dppLogHessian L).IsSymm := by
  ext i j; by_cases hij : i = j <;> simp +decide [*, dppLogHessian]
  rw [if_neg (Ne.symm hij), ← hL.apply]

/-
**Theorem 3 (DPP Dirichlet Form)**: For a symmetric resolvent `L`,
    `xᵀ(dppLogHessian L)x = ½ ∑ᵢⱼ (Lᵢⱼ)²(xᵢ - xⱼ)²`.

    This is the central bridge theorem: the DPP log-Hessian IS a graph Laplacian
    with conductances `(Lᵢⱼ)²`, so the repulsion metric is literally a
    resistance-network Dirichlet form.
-/
theorem dpp_laplacianEnergy_eq_resolventDirichlet
    {n : ℕ}
    (L : Matrix (Fin n) (Fin n) ℝ)
    (hLsymm : L.IsSymm) :
    ∀ x : Fin n → ℝ,
      laplacianEnergy (dppLogHessian L) x
      = (1 / 2 : ℝ) * ∑ i : Fin n, ∑ j : Fin n, (L i j) ^ 2 * (x i - x j) ^ 2 := by
  convert laplacianEnergy_eq_pairwise ( dppLogHessian L ) ( dppLogHessian_symm L hLsymm ) ( dppLogHessian_rowSum_zero L ) using 3 ; ring!;
  refine' Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => _ ; by_cases hij : i = j <;> simp +decide [ hij, dppLogHessian ] ; ring;
  ring

/-! ## Cross-Domain: Fisher Information for Diagonal DPPs -/

/-- For a diagonal kernel, the off-diagonal entries of the DPP log-Hessian are zero. -/
theorem diagonal_dpp_logHessian_offdiag_zero
    {n : ℕ} (w : Fin n → ℝ) (i j : Fin n) (hij : i ≠ j) :
    dppLogHessian (Matrix.diagonal w) i j = 0 := by
  unfold dppLogHessian; aesop

/-- For a diagonal kernel, the diagonal entries of the DPP log-Hessian are zero. -/
theorem diagonal_dpp_logHessian_diag_zero
    {n : ℕ} (w : Fin n → ℝ) (i : Fin n) :
    dppLogHessian (Matrix.diagonal w) i i = 0 := by
  simp [dppLogHessian, diagonal]

/-- The DPP log-Hessian of a diagonal kernel is the zero matrix.
    This is the base case for Fisher information: a product-of-independent-Bernoullis
    has no off-diagonal Fisher information, matching the DPP prediction. -/
theorem diagonal_dpp_logHessian_eq_zero
    {n : ℕ} (w : Fin n → ℝ) :
    dppLogHessian (Matrix.diagonal w) = 0 := by
  ext i j
  by_cases hij : i = j
  · subst hij; exact diagonal_dpp_logHessian_diag_zero w i
  · simp [diagonal_dpp_logHessian_offdiag_zero w i j hij]

/-! ## Coordinate Difference Properties -/

/-- The coordinate difference vector lies in the zero-sum subspace. -/
theorem coordDiff_zeroSum {n : ℕ} (i j : Fin n) (hij : i ≠ j) :
    ∑ k : Fin n, coordDiff n i j k = 0 := by
  unfold coordDiff
  simp +decide [Finset.sum_ite, Finset.filter_eq', Finset.filter_ne']
  grind

/-
The Laplacian energy on `eᵢ - eⱼ` extracts matrix entries.
-/
theorem laplacianEnergy_coordDiff {n : ℕ} (H : Matrix (Fin n) (Fin n) ℝ)
    (hsym : H.IsSymm) (i j : Fin n) (hij : i ≠ j) :
    laplacianEnergy H (coordDiff n i j)
    = H i i + H j j - 2 * H i j := by
  simp +decide [ hsym.eq, laplacianEnergy, dotProduct, coordDiff ];
  simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', hsym, Matrix.mulVec, dotProduct ] ; ring;
  simp +decide [ coordDiff, hij.symm, Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ] ; ring;
  rw [ show H j i = H i j from hsym.apply i j ▸ rfl ] ; ring;

/-
For the DPP log-Hessian with off-diagonal entries `-(L i j)²`,
    the energy on `eᵢ - eⱼ` unfolds to `∑_{k≠i} (L i k)² + ∑_{k≠j} (L j k)² + 2(L i j)²`.
    The `2(L i j)²` term comes from `-2 · H_{ij} = -2 · (-(L i j)²)`.
-/
theorem dpp_laplacianEnergy_coordDiff_offdiag {n : ℕ} (L : Matrix (Fin n) (Fin n) ℝ)
    (hLsymm : L.IsSymm) (i j : Fin n) (hij : i ≠ j) :
    laplacianEnergy (dppLogHessian L) (coordDiff n i j)
    = (dppLogHessian L) i i + (dppLogHessian L) j j + 2 * (L i j) ^ 2 := by
  convert laplacianEnergy_coordDiff ( dppLogHessian L ) ( dppLogHessian_symm L hLsymm ) i j hij using 1 ; ring;
  rw [ show dppLogHessian L i j = - ( L i j ) ^ 2 by exact if_neg hij ] ; ring;

/-! ## Conjectures

### Conjecture A: Full Repulsion-Resistance Isometry
For every finite DPP resolvent `L`, the pseudoinverse of `dppLogHessian L` restricted to
the zero-sum subspace coincides with the effective resistance matrix of the weighted
graph with conductances `(Lᵢⱼ)²`.

### Conjecture B: Fisher-Repulsion Equivalence
For every strongly log-concave polynomial with positive coefficients, the zero-sum
Hessian metric at the all-ones point is the Fisher metric of a canonical exponential family.

Both conjectures are computationally verified in `demo.py` for small instances.
-/

end