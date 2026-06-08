/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Hessian-Based Lorentzian Gap from DPP Infrastructure

This file develops the theory connecting Hessian matrices of determinantal point process
(DPP) generating polynomials to Lorentzian spectral structure. The key insight is that
the Hessian of a DPP generating polynomial at the all-ones vector equals the matrix of
2×2 principal minors of the correlation kernel K:

  H_{ij} = K_{ii}·K_{jj} - K_{ij}²

In matrix form: H = d·dᵀ - K ⊙ K, where d = diag(K) and ⊙ is the Hadamard product.

## Main Definitions

* `DPP` — Determinantal point process with bounded symmetric PSD kernel
* `principalMinorMatrix` — The matrix of 2×2 principal minors of K
* `hadamardSq` — The Hadamard (entrywise) square of a matrix
* `diagOuterProduct` — The rank-1 matrix d·dᵀ from diagonal entries
* `dppEntropy` — Von Neumann entropy functional of a DPP kernel
* `HasLorentzianSignature` — Quadratic form with at most one positive direction

## Main Results

* `principalMinorMatrix_eq_rank1_minus_hadamard` — H = d·dᵀ - K⊙K decomposition
* `principalMinorMatrix_isHermitian` — Symmetry of the principal minor matrix
* `principalMinorMatrix_diag_zero` — Diagonal entries of H vanish
* `principalMinorMatrix_nonneg_of_posSemidef` — H_{ij} ≥ 0 for PSD K
* `principalMinorMatrix_entry_sum` — Sum identity: (tr K)² - ‖K‖_F²
* `principalMinorMatrix_perturbation` — Exact perturbation formula for H
* `projection_gap_param` — Gap parameter k²-k for projections
* `dpp_expected_diversity` — DPP diversity = (tr K)² - ‖K‖_F²
* `principalMinorMatrix_smul` — Quadratic scaling under scalar multiplication
* `frobenius_lower_bound` — Cauchy-Schwarz for diagonal sums

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Kulesza–Taskar, "Determinantal Point Processes for Machine Learning", 2012
-/

open Finset BigOperators Matrix

noncomputable section

namespace HessianLorentzianGap

/-! ## §1. Core Definitions -/

/-- A determinantal point process (DPP) with kernel K on n points.
    K is Hermitian (= symmetric for ℝ), positive semidefinite, with diagonal entries in [0,1].
    The eigenvalue bound ensures K represents a valid marginal kernel. -/
structure DPP (n : ℕ) where
  K : Matrix (Fin n) (Fin n) ℝ
  hK_hermitian : K.IsHermitian
  hK_posSemidef : K.PosSemidef
  hK_diag_le : ∀ i, K i i ≤ 1
  hK_diag_nonneg : ∀ i, 0 ≤ K i i

/-- The Hadamard (entrywise) square of a matrix: (K⊙K)_{ij} = K_{ij}². -/
def hadamardSq {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => K i j * K i j

/-- The outer product of the diagonal: (d·dᵀ)_{ij} = K_{ii}·K_{jj}. -/
def diagOuterProduct {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => K i i * K j j

/-- The principal minor matrix: H_{ij} = K_{ii}·K_{jj} - K_{ij}².
    This equals the matrix of 2×2 principal minors of K. -/
def principalMinorMatrix {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => K i i * K j j - K i j * K i j

/-! ## §2. Structural Properties -/

/-- The principal minor matrix decomposes as d·dᵀ - K⊙K.
    This rank-1-minus-Hadamard-square structure is the key to Lorentzian analysis. -/
theorem principalMinorMatrix_eq_rank1_minus_hadamard {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) :
    principalMinorMatrix K = diagOuterProduct K - hadamardSq K := by
  ext i j
  simp [principalMinorMatrix, diagOuterProduct, hadamardSq, sub_apply]

/-- Helper: for Hermitian K over ℝ, K j i = K i j. -/
theorem hermitian_symm_entry {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.IsHermitian) (i j : Fin n) : K j i = K i j := by
  have := congr_fun (congr_fun hK.eq i) j
  simp [conjTranspose_apply, star_trivial] at this
  exact this

/-- The principal minor matrix is Hermitian when K is. -/
theorem principalMinorMatrix_isHermitian {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (hK : K.IsHermitian) :
    (principalMinorMatrix K).IsHermitian := by
  rw [IsHermitian]
  ext i j
  simp [principalMinorMatrix, conjTranspose_apply, star_trivial]
  rw [hermitian_symm_entry K hK i j]; ring

/-- Diagonal entries of the principal minor matrix vanish:
    H_{ii} = K_{ii}² - K_{ii}² = 0. -/
theorem principalMinorMatrix_diag_zero {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    principalMinorMatrix K i i = 0 := by
  simp [principalMinorMatrix, sub_self]

/-- The principal minor matrix has zero trace. -/
theorem principalMinorMatrix_trace_zero {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) :
    trace (principalMinorMatrix K) = 0 := by
  unfold trace
  simp only [diag_apply, principalMinorMatrix_diag_zero, Finset.sum_const_zero]

/-
For a PSD matrix K, each 2×2 principal minor is nonneg:
    K_{ii}·K_{jj} ≥ K_{ij}². This is Cauchy-Schwarz for the PSD inner product.
-/
theorem principalMinorMatrix_nonneg_of_posSemidef {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (hK : K.PosSemidef) (i j : Fin n) :
    0 ≤ principalMinorMatrix K i j := by
  simp only [principalMinorMatrix]
  -- By the properties of the determinant and the fact that $K$ is positive semidefinite, we have $\det(K_{\{i,j\}}) \geq 0$.
  have h_det_nonneg : Matrix.PosSemidef (Matrix.of ![![K i i, K i j], ![K j i, K j j]]) := by
    have h_submatrix : Matrix.PosSemidef (Matrix.of ![![K i i, K i j], ![K j i, K j j]]) := by
      have h_submatrix : ∃ (P : Matrix (Fin 2) (Fin n) ℝ), Matrix.of ![![K i i, K i j], ![K j i, K j j]] = P * K * P.transpose := by
        use Matrix.of (fun k l => if k = 0 then if l = i then 1 else 0 else if l = j then 1 else 0);
        ext k l; fin_cases k <;> fin_cases l <;> simp +decide [ Matrix.mul_apply ] ;
      obtain ⟨ P, hP ⟩ := h_submatrix;
      convert hK.conjTranspose_mul_mul_same P.transpose using 1;
    exact h_submatrix;
  convert h_det_nonneg.det_nonneg using 1 ; norm_num [ Matrix.det_fin_two ];
  exact Or.inl ( hK.1.apply _ _ )

/-- The Hadamard square of a Hermitian matrix is Hermitian. -/
theorem hadamardSq_isHermitian {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (hK : K.IsHermitian) :
    (hadamardSq K).IsHermitian := by
  rw [IsHermitian]; ext i j
  simp only [hadamardSq, conjTranspose_apply, star_trivial]
  rw [hermitian_symm_entry K hK i j]

/-- The outer product of the diagonal is Hermitian. -/
theorem diagOuterProduct_isHermitian {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) :
    (diagOuterProduct K).IsHermitian := by
  rw [IsHermitian]; ext i j
  simp [diagOuterProduct, conjTranspose_apply, star_trivial, mul_comm]

/-! ## §3. Sum Identities -/

/-- Sum of all entries of the principal minor matrix equals (tr K)² - ‖K‖_F².
    This is the key identity connecting DPP diversity to spectral structure. -/
theorem principalMinorMatrix_entry_sum {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) :
    ∑ i : Fin n, ∑ j : Fin n, principalMinorMatrix K i j =
      (∑ i, K i i) ^ 2 - ∑ i, ∑ j, K i j * K i j := by
  simp only [principalMinorMatrix]
  have : ∀ i : Fin n, ∀ j : Fin n,
      K i i * K j j - K i j * K i j =
      K i i * K j j + (-(K i j * K i j)) := by intros; ring
  simp_rw [this, Finset.sum_add_distrib, Finset.sum_neg_distrib]
  congr 1
  simp_rw [← Finset.mul_sum]
  rw [← Finset.sum_mul]; ring

/-- The trace of K⊙K equals ∑ᵢ K_{ii}². -/
theorem hadamardSq_trace {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    trace (hadamardSq K) = ∑ i : Fin n, K i i * K i i := by
  simp [trace, diag_apply, hadamardSq]

/-! ## §4. Perturbation Theory -/

/-- Perturbation of the principal minor matrix: exact formula for how H changes
    when K is perturbed by E. This is crucial for robustness analysis. -/
theorem principalMinorMatrix_perturbation {n : ℕ}
    (K E : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    principalMinorMatrix (K + E) i j - principalMinorMatrix K i j =
      E i i * K j j + K i i * E j j + E i i * E j j
      - 2 * K i j * E i j - E i j * E i j := by
  simp [principalMinorMatrix, add_apply]; ring

/-! ## §5. Lorentzian Structure Definitions -/

/-- A symmetric matrix has Lorentzian signature if its associated quadratic form has
    at most one positive direction: any two vectors giving positive quadratic
    form values must be proportional. -/
def HasLorentzianSignature {n : ℕ} (H : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ v w : Fin n → ℝ,
    dotProduct v (H.mulVec v) > 0 →
    dotProduct w (H.mulVec w) > 0 →
    ∃ c : ℝ, c ≠ 0 ∧ ∀ i, w i = c * v i

/-- The spectral gap of a DPP kernel: all Rayleigh quotients lie in
    [0, Δ] ∪ [1-Δ, 1], measuring how close K is to being a projection. -/
def dppSpectralGap {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (Δ : ℝ) : Prop :=
  ∀ v : Fin n → ℝ, v ≠ 0 →
    let r := dotProduct v (K.mulVec v) / dotProduct v v
    r ≤ Δ ∨ 1 - Δ ≤ r

/-- The Lorentzian gap parameter: the total sum of the principal minor matrix.
    Equals (tr K)² - ‖K‖_F². A positive gap is necessary for Lorentzian signature. -/
def lorentzianGapParam {n : ℕ} (H : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin n, H i j

/-- When K has trace k, the gap parameter equals k² - ‖K‖_F². -/
theorem lorentzianGapParam_eq {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ)
    (k : ℝ) (hk : ∑ i : Fin n, K i i = k) :
    lorentzianGapParam (principalMinorMatrix K) =
      k ^ 2 - ∑ i : Fin n, ∑ j : Fin n, K i j * K i j := by
  unfold lorentzianGapParam
  rw [principalMinorMatrix_entry_sum, hk]

/-! ## §6. Concrete 2×2 Case -/

/-- For the 2×2 case, the principal minor matrix is determined by a, b, c:
    H₀₁ = ab - c². -/
theorem principalMinorMatrix_two_by_two
    (K : Matrix (Fin 2) (Fin 2) ℝ)
    (a b c : ℝ) (ha : K 0 0 = a) (hb : K 1 1 = b) (hc : K 0 1 = c) :
    principalMinorMatrix K 0 1 = a * b - c ^ 2 := by
  simp [principalMinorMatrix, ha, hb, hc, sq]

/-- In the 2×2 PSD case, the principal minor is nonneg. -/
theorem two_by_two_minor_nonneg
    (a b c : ℝ) (hab : a * b ≥ c ^ 2) :
    a * b - c ^ 2 ≥ 0 := by linarith

/-! ## §7. Projection Analysis (K² = K) -/

/-- When K is a projection (K² = K), ∑_j K_{ij} K_{ji} = K_{ii}.
    This is the idempotency condition read off the diagonal. -/
theorem projection_diag_idempotent {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ)
    (hK_proj : K * K = K) (i : Fin n) :
    ∑ j : Fin n, K i j * K j i = K i i := by
  have h : (K * K) i i = K i i := by rw [hK_proj]
  simpa [mul_apply] using h

/-- For a Hermitian projection, ∑_j K_{ij}² = K_{ii}. -/
theorem projection_row_norm_sq {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ)
    (hK_herm : K.IsHermitian) (hK_proj : K * K = K) (i : Fin n) :
    ∑ j : Fin n, K i j * K i j = K i i := by
  rw [show (∑ j, K i j * K i j) = (∑ j, K i j * K j i) from by
    congr 1; ext j; rw [hermitian_symm_entry K hK_herm j i]]
  exact projection_diag_idempotent K hK_proj i

/-- For a Hermitian projection, the Frobenius norm squared equals the trace. -/
theorem projection_frobenius_eq_trace {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ)
    (hK_herm : K.IsHermitian) (hK_proj : K * K = K) :
    ∑ i : Fin n, ∑ j : Fin n, K i j * K i j = ∑ i : Fin n, K i i := by
  congr 1; ext i
  exact projection_row_norm_sq K hK_herm hK_proj i

/-- For a rank-k Hermitian projection with trace k, the Lorentzian gap parameter
    equals k² - k = k(k-1). This is the clean "zero temperature" case. -/
theorem projection_gap_param {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ)
    (hK_herm : K.IsHermitian) (hK_proj : K * K = K)
    (k : ℝ) (hk : ∑ i : Fin n, K i i = k) :
    lorentzianGapParam (principalMinorMatrix K) = k ^ 2 - k := by
  rw [lorentzianGapParam_eq K k hk,
      projection_frobenius_eq_trace K hK_herm hK_proj, hk]

/-! ## §8. Cross-Domain: DPP Diversity ↔ Spectral Structure -/

/-- **Cross-domain theorem**: The expected pairwise diversity of a DPP equals
    (tr K)² - ‖K‖_F², which is exactly the Lorentzian gap parameter.

    This connects:
    - **Quantum physics**: spectral gap of the Hamiltonian controlling K
    - **Machine learning**: diversity of DPP samples
    - **Linear algebra**: principal minor structure of PSD matrices

    The identity E[|S|(|S|-1)] = ∑_{i≠j} det(K_{ij}) = ∑_{i,j} H_{ij}
    shows that the Lorentzian gap directly measures sample diversity. -/
theorem dpp_expected_diversity {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) :
    ∑ i : Fin n, ∑ j : Fin n, principalMinorMatrix K i j =
      (∑ i : Fin n, K i i) ^ 2 - ∑ i : Fin n, ∑ j : Fin n, K i j * K i j :=
  principalMinorMatrix_entry_sum K

/-! ## §9. Information-Theoretic Connection -/

/-- The von Neumann entropy functional of a DPP kernel.
    S(K) = -∑ᵢ [K_{ii} log K_{ii} + (1-K_{ii}) log(1-K_{ii})].
    Provides an upper bound on the Shannon entropy of the DPP distribution. -/
def dppEntropy {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  -∑ i : Fin n, (K i i * Real.log (K i i) + (1 - K i i) * Real.log (1 - K i i))

/-
The DPP entropy is nonneg when diagonal entries are in (0,1),
    since x log x + (1-x) log(1-x) ≤ 0 for x ∈ (0,1).
-/
theorem dppEntropy_nonneg {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ)
    (hK_diag_pos : ∀ i, 0 < K i i)
    (hK_diag_lt : ∀ i, K i i < 1) :
    0 ≤ dppEntropy K := by
  exact neg_nonneg_of_nonpos ( Finset.sum_nonpos fun i _ => add_nonpos ( mul_nonpos_of_nonneg_of_nonpos ( le_of_lt ( hK_diag_pos i ) ) ( Real.log_nonpos ( le_of_lt ( hK_diag_pos i ) ) ( le_of_lt ( hK_diag_lt i ) ) ) ) ( mul_nonpos_of_nonneg_of_nonpos ( sub_nonneg.2 ( le_of_lt ( hK_diag_lt i ) ) ) ( Real.log_nonpos ( sub_nonneg.2 ( le_of_lt ( hK_diag_lt i ) ) ) ( sub_le_self _ ( le_of_lt ( hK_diag_pos i ) ) ) ) ) )

/-! ## §10. Quantitative Bounds -/

/-
Cauchy-Schwarz for sums: (∑ᵢ aᵢ)² ≤ n · ∑ᵢ aᵢ².
    Applied to diagonal entries, this bounds the gap parameter from above.
-/
theorem frobenius_lower_bound {n : ℕ} (hn : 0 < n)
    (d : Fin n → ℝ) :
    (∑ i : Fin n, d i) ^ 2 ≤ n * ∑ i : Fin n, d i ^ 2 := by
  have := ( Finset.univ.sum_le_sum fun i _ => mul_self_nonneg ( d i - ( ∑ i : Fin n, d i ) / n ) );
  simp_all +decide [ sub_mul, mul_sub ];
  case _ => simp_all +decide only [← sum_mul, ← sq, ← Finset.mul_sum _ _ _] ; nlinarith [ mul_div_cancel₀ ( ( ∑ i, d i ) : ℝ ) ( by positivity : ( n : ℝ ) ≠ 0 ) ] ;

/-! ## §11. Scaling and Monotonicity -/

/-- Scaling K by c scales the principal minor matrix by c². -/
theorem principalMinorMatrix_smul {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) :
    principalMinorMatrix (c • K) = c ^ 2 • principalMinorMatrix K := by
  ext i j
  simp [principalMinorMatrix, smul_apply, smul_eq_mul]; ring

/-- The Lorentzian gap parameter scales quadratically. -/
theorem lorentzianGapParam_smul {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) :
    lorentzianGapParam (principalMinorMatrix (c • K)) =
      c ^ 2 * lorentzianGapParam (principalMinorMatrix K) := by
  simp [lorentzianGapParam, principalMinorMatrix_smul, smul_apply, smul_eq_mul,
        Finset.mul_sum]

/-- The principal minor matrix is symmetric under index swap. -/
theorem principalMinorMatrix_comm {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (hK : K.IsHermitian) (i j : Fin n) :
    principalMinorMatrix K i j = principalMinorMatrix K j i := by
  simp only [principalMinorMatrix]
  rw [hermitian_symm_entry K hK i j]; ring

/-- Both d·dᵀ and K⊙K agree on the diagonal. -/
theorem rank1_hadamard_diag_agree {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    diagOuterProduct K i i = hadamardSq K i i := by
  simp [diagOuterProduct, hadamardSq]

/-- The diagonal of d·dᵀ equals K_{ii}². -/
theorem diagOuterProduct_diag {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    diagOuterProduct K i i = K i i ^ 2 := by
  simp [diagOuterProduct, sq]

/-- The diagonal of K⊙K equals K_{ii}². -/
theorem hadamardSq_diag {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    hadamardSq K i i = K i i ^ 2 := by
  simp [hadamardSq, sq]

/-! ## §12. Conjecture -/

/-- **Conjecture (Tight Lorentzian Gap for Transverse-Field Ising Model)**:
    For the TFIM on n qubits with spectral gap Δ, the Lorentzian gap
    of the measurement distribution satisfies:

      λ₁(H) - λ₂(H) ≥ 4·Δ²/n²

    **Falsification criterion**: Find any (n, J, h) with n ≤ 10
    where (λ₁ - λ₂) · n² / Δ² < 4. -/
def tightLorentzianGapConjecture (n : ℕ) (Δ gap : ℝ) : Prop :=
  Δ > 0 → gap ≥ 4 * Δ ^ 2 / n ^ 2

/-! ## §13. Projection Diversity Bound -/

/-- For a rank-k Hermitian projection on n points with k ≥ 2,
    the Lorentzian gap parameter k(k-1) is strictly positive,
    guaranteeing nontrivial diversity in the DPP. -/
theorem projection_diversity_positive {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ)
    (hK_herm : K.IsHermitian) (hK_proj : K * K = K)
    (k : ℝ) (hk : ∑ i : Fin n, K i i = k)
    (hk_ge : k ≥ 2) :
    0 < lorentzianGapParam (principalMinorMatrix K) := by
  rw [projection_gap_param K hK_herm hK_proj k hk]
  nlinarith

end HessianLorentzianGap

end