/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Conditional Negative Semidefiniteness and Log-Hessian Spectral Theory

This file develops the theory of conditionally negative semidefinite (CondNSD) matrices
and their role as spectral certificates for Lorentzian generating polynomials.

## Mathematical Context

For a positive polynomial `p` with `p(1) > 0`, the **log-Hessian at the all-ones point** is
  `L_p := (∇² log p)(1) = H_p(1)/p(1) - g_p g_pᵀ / p(1)²`
where `H_p(1) = ∇²p(1)` and `g_p = ∇p(1)`.

A symmetric matrix `A` is **conditionally negative semidefinite** (CondNSD) if
  `∀ v, (∑ᵢ vᵢ = 0) → vᵀ A v ≤ 0`.

The **Lorentzian CondNSD Conjecture** states: if `p` is Lorentzian (Brändén–Huh),
then `L_p` is CondNSD. This would provide an O(n³) spectral certificate for
negative dependence, bridging Lorentzian/Hodge theory to spectral graph theory.

## Main Results

### Algebraic foundations
* `condNegSemidef_add` — CondNSD is closed under addition
* `condNegSemidef_smul_nonneg` — CondNSD is closed under nonneg scaling
* `condNegSemidef_neg_outerProduct` — negative outer products are NSD (hence CondNSD)
* `condNegSemidef_fin2_iff` — complete characterization in dimension 2

### Log-Hessian theory
* `logHessianMatrix_quadForm` — quadratic form identity for log-Hessians
* `condNegSemidef_of_product` — product stability for CondNSD log-Hessians
* `logHessian_condNegSemidef_of_hessian_condNegSemidef` — CondNSD Hessian ⟹ CondNSD log-Hessian
* `linearLogHessian_condNegSemidef` — linear factors have CondNSD log-Hessians

### Spectral criteria
* `condNegSemidef_of_neg_laplacian` — negative-of-Laplacian criterion
* `condNegSemidef_neg_hadamard_sq` — negative Hadamard squares are NSD

### Cross-domain bridges
* `condNegSemidef_dissipation` — zero-sum energy dissipation (→ graph theory)
* `dppCov_offdiag_nonpos` — DPP covariance off-diagonal negativity

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators Matrix

noncomputable section

/-! ## Core Definitions -/

/-- The quadratic form `vᵀ A v = ∑ᵢ ∑ⱼ Aᵢⱼ vᵢ vⱼ` for a matrix `A` and vector `v`. -/
def quadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * v i * v j

/-- A vector `v : Fin n → ℝ` is **zero-sum** if `∑ᵢ vᵢ = 0`. -/
def IsZeroSum {n : ℕ} (v : Fin n → ℝ) : Prop :=
  ∑ i : Fin n, v i = 0

/-- A matrix `A` is **conditionally negative semidefinite** (CondNSD) if
    the quadratic form `vᵀ A v ≤ 0` for all zero-sum vectors `v`. -/
def CondNegSemidef {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ v : Fin n → ℝ, IsZeroSum v → quadForm A v ≤ 0

/-- The **outer product** of a vector with itself: `(v vᵀ)ᵢⱼ = vᵢ · vⱼ`. -/
def outerProduct {n : ℕ} (v : Fin n → ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => v i * v j

/-- The **log-Hessian matrix** at the all-ones point:
    `L = H/c - ggᵀ/c²`, where `H` is the Hessian, `g` the gradient, `c` the value. -/
def logHessianMatrix {n : ℕ} (H : Matrix (Fin n) (Fin n) ℝ) (g : Fin n → ℝ) (c : ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  (1 / c) • H - (1 / (c * c)) • outerProduct g

/-! ## Section 1: Basic CondNSD Properties -/

/-- The zero matrix is CondNSD. -/
theorem condNegSemidef_zero {n : ℕ} : CondNegSemidef (0 : Matrix (Fin n) (Fin n) ℝ) := by
  intro v _; simp [quadForm]

/-- The quadratic form distributes over matrix addition. -/
theorem quadForm_add {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    quadForm (A + B) v = quadForm A v + quadForm B v := by
  unfold quadForm
  simp [Matrix.add_apply, mul_add, add_mul, Finset.sum_add_distrib]

/-- **CondNSD is closed under addition.** -/
theorem condNegSemidef_add {n : ℕ} {A B : Matrix (Fin n) (Fin n) ℝ}
    (hA : CondNegSemidef A) (hB : CondNegSemidef B) :
    CondNegSemidef (A + B) := by
  intro v hv
  rw [quadForm_add]
  exact add_nonpos (hA v hv) (hB v hv)

/-
The quadratic form of a scaled matrix.
-/
theorem quadForm_smul {n : ℕ} (c : ℝ) (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    quadForm (c • A) v = c * quadForm A v := by
  unfold quadForm; simp +decide [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ] ;

/-- CondNSD is closed under nonneg scaling. -/
theorem condNegSemidef_smul_nonneg {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    (hA : CondNegSemidef A) {c : ℝ} (hc : 0 ≤ c) :
    CondNegSemidef (c • A) := by
  intro v hv
  rw [quadForm_smul]
  exact mul_nonpos_of_nonneg_of_nonpos hc (hA v hv)

/-! ## Section 2: Outer Products and NSD -/

/-
The quadratic form of an outer product equals the square of the dot product:
    `vᵀ(ggᵀ)v = (gᵀv)²`.
-/
theorem quadForm_outerProduct {n : ℕ} (g v : Fin n → ℝ) :
    quadForm (outerProduct g) v = (∑ i, g i * v i) ^ 2 := by
  unfold quadForm outerProduct; simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq ] ;
  simp +decide only [mul_comm, mul_left_comm, Finset.mul_sum _ _ _]

/-
The quadratic form of a negative outer product is nonpositive:
    `vᵀ(-ggᵀ)v = -(gᵀv)² ≤ 0`.
-/
theorem quadForm_neg_outerProduct_nonpos {n : ℕ} (g v : Fin n → ℝ) :
    quadForm (-(outerProduct g)) v ≤ 0 := by
  -- By quadForm_smul, when c = -1, quadForm (-(outerProduct g)) v = -1 * (∑ i, g i * v i) ^ 2.
  have h_inner : quadForm (-(outerProduct g)) v = -1 * (∑ i, g i * v i) ^ 2 := by
    convert quadForm_smul ( -1 ) ( outerProduct g ) v using 1 ; norm_num [ quadForm_outerProduct ];
    exact congrArg _ ( by rw [ quadForm_outerProduct ] );
  exact h_inner ▸ mul_nonpos_of_nonpos_of_nonneg ( by norm_num ) ( sq_nonneg _ )

/-- **Negative outer products are CondNSD** (in fact, NSD everywhere). -/
theorem condNegSemidef_neg_outerProduct {n : ℕ} (g : Fin n → ℝ) :
    CondNegSemidef (-(outerProduct g)) :=
  fun v _ => quadForm_neg_outerProduct_nonpos g v

/-! ## Section 3: Log-Hessian Quadratic Form Identity -/

/-
**Log-Hessian quadratic form identity**: For `L = H/c - ggᵀ/c²`,
    `vᵀLv = (vᵀHv)/c - (gᵀv)²/c²`.
    This identity is the engine behind all CondNSD propagation results.
-/
theorem logHessianMatrix_quadForm {n : ℕ}
    (H : Matrix (Fin n) (Fin n) ℝ) (g : Fin n → ℝ) (c : ℝ) (v : Fin n → ℝ) :
    quadForm (logHessianMatrix H g c) v =
      (1 / c) * quadForm H v - (1 / (c * c)) * (∑ i, g i * v i) ^ 2 := by
  convert quadForm_add ( ( 1 / c ) • H ) ( - ( 1 / ( c * c ) ) • Matrix.of fun i j => g i * g j ) v using 1 ; norm_num ; ring;
  · unfold logHessianMatrix; norm_num ; ring;
    unfold outerProduct; norm_num [ sub_eq_add_neg ] ;
  · rw [ quadForm_smul, quadForm_smul ] ; ring;
    exact congr rfl ( by rw [ ← quadForm_outerProduct ] ; rfl )

/-! ## Section 4: Product Stability -/

/-- **Product stability for CondNSD log-Hessians**: If the log-Hessians of `p`
    and `q` are both CondNSD, then so is the log-Hessian of `pq`.
    This follows from `∇² log(pq) = ∇² log p + ∇² log q` and closure under addition. -/
theorem condNegSemidef_of_product {n : ℕ}
    {H₁ H₂ : Matrix (Fin n) (Fin n) ℝ} {g₁ g₂ : Fin n → ℝ} {c₁ c₂ : ℝ}
    (h₁ : CondNegSemidef (logHessianMatrix H₁ g₁ c₁))
    (h₂ : CondNegSemidef (logHessianMatrix H₂ g₂ c₂)) :
    CondNegSemidef (logHessianMatrix H₁ g₁ c₁ + logHessianMatrix H₂ g₂ c₂) :=
  condNegSemidef_add h₁ h₂

/-! ## Section 5: The Key Structural Theorem -/

/-
**Outer-product subtraction principle**: If `H` is CondNSD and `c > 0`,
    then the log-Hessian `H/c - ggᵀ/c²` is automatically CondNSD.
    Both terms contribute nonpositive quadratic forms on zero-sum vectors.
-/
theorem logHessian_condNegSemidef_of_hessian_condNegSemidef {n : ℕ}
    {H : Matrix (Fin n) (Fin n) ℝ} {g : Fin n → ℝ} {c : ℝ}
    (hH : CondNegSemidef H) (hc : 0 < c) :
    CondNegSemidef (logHessianMatrix H g c) := by
  -- Apply the logHessianMatrix_quadForm theorem to express the quadratic form of L in terms of H and the outer product.
  have h_quadForm : ∀ v : Fin n → ℝ, quadForm (logHessianMatrix H g c) v = (1 / c) * quadForm H v - (1 / (c * c)) * (∑ i, g i * v i) ^ 2 := by
    grind +suggestions;
  intro v hv; nlinarith [ h_quadForm v, show 0 ≤ 1 / ( c * c ) by positivity, show 1 / c * quadForm H v ≤ 0 by exact mul_nonpos_of_nonneg_of_nonpos ( by positivity ) ( hH v hv ), show ( ∑ i, g i * v i ) ^ 2 ≥ 0 by positivity ] ;

/-! ## Section 6: Zero-Sum Energy Dissipation -/

/-- **Zero-sum energy dissipation**: If `A` is CondNSD, then `-vᵀAv ≥ 0`
    for all zero-sum vectors. This connects to graph Laplacian energy. -/
theorem condNegSemidef_dissipation {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    (hA : CondNegSemidef A) (v : Fin n → ℝ) (hv : IsZeroSum v) :
    0 ≤ -quadForm A v :=
  le_neg.mpr (by linarith [hA v hv])

/-! ## Section 7: Dimension 2 Characterization -/

/-
**Dimension-2 characterization**: A matrix on `Fin 2` is CondNSD iff
    `A₀₀ - A₀₁ - A₁₀ + A₁₁ ≤ 0`. The zero-sum subspace is spanned by `(1,-1)`.
-/
theorem condNegSemidef_fin2_iff (A : Matrix (Fin 2) (Fin 2) ℝ) :
    CondNegSemidef A ↔ A 0 0 - A 0 1 - A 1 0 + A 1 1 ≤ 0 := by
  -- Let's start with the forward direction: assume that A is conditionally negative semidefinite.
  apply Iff.intro
  intro hA
  specialize hA ![1, -1] (by
  exact show ∑ i : Fin 2, ( if i = 0 then 1 else -1 ) = 0 by norm_num;);
  · convert hA using 1 ; unfold quadForm ; norm_num ; ring!;
  · intro h v hv;
    -- Since $v$ is zero-sum, we have $v 0 = -v 1$.
    have hv0 : v 0 = -v 1 := by
      exact eq_neg_of_add_eq_zero_left ( hv ▸ by simp +decide [ Fin.sum_univ_two ] );
    unfold quadForm; norm_num [ Fin.sum_univ_succ, hv0 ] ; nlinarith [ sq_nonneg ( v 1 ) ] ;

/-! ## Section 8: Negative-of-Laplacian Criterion

The naive "row-sum nonpositive implies CondNSD" is false in general
(counterexample: `A = [[1, -2], [-2, 1]]` has row sums -1 but is not CondNSD).
The correct criterion requires **nonneg** off-diagonal entries. -/

/-
**Negative-of-Laplacian criterion**: A symmetric matrix with nonneg off-diagonal
    entries and zero row sums is NSD everywhere (hence CondNSD).

    Such matrices are negatives of graph Laplacians. The key identity:
    `vᵀAv = -∑_{i<j} A_ij (v_i - v_j)²`
    is nonpositive since `A_ij ≥ 0` and `(v_i - v_j)² ≥ 0`.
-/
theorem condNegSemidef_of_neg_laplacian {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hsymm : A.IsSymm)
    (hoffdiag : ∀ i j, i ≠ j → 0 ≤ A i j)
    (hrowsum : ∀ i, ∑ j, A i j = 0) :
    CondNegSemidef A := by
  intro v hv;
  -- Using the row sum condition, we can rewrite the quadratic form as:
  have h_quadForm : quadForm A v = ∑ i, ∑ j, A i j * v i * (v j - v i) := by
    simp +decide [ mul_sub, quadForm ];
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, hrowsum ];
  -- By symmetry of $A$, we can rewrite the quadratic form as:
  have h_quadForm_symm : quadForm A v = (1 / 2) * ∑ i, ∑ j, A i j * (v i * (v j - v i) + v j * (v i - v j)) := by
    have h_quadForm_symm : quadForm A v = (1 / 2) * (∑ i, ∑ j, A i j * v i * (v j - v i) + ∑ i, ∑ j, A j i * v j * (v i - v j)) := by
      rw [ h_quadForm ];
      rw [ ← Finset.sum_comm ] ; ring;
    convert h_quadForm_symm using 2 ; norm_num [ mul_add, mul_sub, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, hsymm.apply ] ; ring;
  -- Since $A_{ij} \geq 0$ for $i \neq j$ and $(v_i - v_j)^2 \geq 0$, each term in the sum is non-positive.
  have h_nonpos : ∀ i j, i ≠ j → A i j * (v i * (v j - v i) + v j * (v i - v j)) ≤ 0 := by
    exact fun i j hij => mul_nonpos_of_nonneg_of_nonpos ( hoffdiag i j hij ) ( by nlinarith only [ sq_nonneg ( v i - v j ) ] );
  exact h_quadForm_symm.symm ▸ mul_nonpos_of_nonneg_of_nonpos ( by norm_num ) ( Finset.sum_nonpos fun i hi => Finset.sum_nonpos fun j hj => if hij : i = j then hij.symm ▸ by norm_num [ hrowsum ] else h_nonpos i j hij )

/-! ## Section 9: Linear Forms and Diagonal Log-Hessians -/

/-- The log-Hessian of a single linear form `(1 + w·xᵢ)` at x=1 is
    diagonal: `-(w/(1+w))²` in position `(i,i)`, zero elsewhere. -/
def linearLogHessian (n : ℕ) (i : Fin n) (w : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun a b => if a = i ∧ b = i then -(w / (1 + w)) ^ 2 else 0

/-
The log-Hessian of a single linear factor is CondNSD.
-/
theorem linearLogHessian_condNegSemidef (n : ℕ) (i : Fin n) (w : ℝ) :
    CondNegSemidef (linearLogHessian n i w) := by
  -- Since the only nonzero entry is -(w/(1+w))² at (i,i), we can simplify the quadratic form.
  intro v hv
  simp [linearLogHessian, quadForm] at *;
  simp +contextual [ Finset.sum_ite, Finset.filter_eq', Finset.filter_and, mul_assoc, sq_nonneg ];
  exact Finset.sum_nonneg fun x hx => mul_nonneg ( Nat.cast_nonneg _ ) ( mul_nonneg ( sq_nonneg _ ) ( mul_self_nonneg _ ) )

/-! ## Section 10: Negative Hadamard Square —  DPP Log-Hessian Mechanism

For the DPP partition function `Z_K(x) = det(I + diag(x)K)`, the log-Hessian
at `x = 1` has entries `(∂²log Z/∂xᵢ∂xⱼ)(1) = -M_ij²` where `M = K(I+K)⁻¹`.
Since `M` is symmetric PSD, the matrix `-(M ∘ M)` (negative entrywise square)
is NSD by the Schur product theorem. We prove this directly. -/

/-- The DPP covariance matrix: `C_ij = -K_ij · K_ji` for `i ≠ j`,
    `C_ii = K_ii(1-K_ii)` on the diagonal. -/
def dppCovarianceMatrix {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => if i = j then K i i * (1 - K i i) else -(K i j * K j i)

/-
For symmetric kernels, off-diagonal covariance entries are nonpositive.
-/
theorem dppCov_offdiag_nonpos {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hKsymm : K.IsSymm) (i j : Fin n) (hij : i ≠ j) :
    (dppCovarianceMatrix K) i j ≤ 0 := by
  -- By definition of dppCovarianceMatrix, we have:
  simp [dppCovarianceMatrix];
  rw [ if_neg hij, show K j i = K i j from hKsymm.apply _ _ ] ; nlinarith

/-
**Negative Hadamard square is NSD**: For any symmetric matrix `M`, the matrix
    `A_ij = -M_ij²` is NSD (hence CondNSD).

    **Proof**: `vᵀAv = -∑ᵢ∑ⱼ M_ij² vᵢvⱼ = -‖M diag(v)‖²_F ≤ 0`
    where the Frobenius norm interpretation uses the column structure.
    More elementarily: `vᵀAv = -(∑ⱼ (∑ᵢ M_ij vᵢ) vⱼ · (∑ₖ M_kj vₖ)... `

    Actually the cleanest argument: by the Schur product theorem,
    `M ∘ M` is PSD when `M` is PSD. But we don't need PSD of M here;
    we only need `vᵀ(-(M∘M))v ≤ 0`, which is `∑ᵢ∑ⱼ M_ij² vᵢvⱼ ≥ 0`.
    This follows from `∑ᵢ∑ⱼ M_ij² vᵢvⱼ = ∑ⱼ (∑ᵢ M_ij vᵢ M_ij)vⱼ`...

    For symmetric M, `∑ᵢ∑ⱼ M_ij² vᵢvⱼ = ∑ⱼ (∑ᵢ M_ij²·vᵢ)·vⱼ`. Hmm.

    Direct argument: define `wⱼ = ∑ᵢ M_ij vᵢ` (this is `(Mv)_j`).
    Then `∑ᵢ∑ⱼ M_ij² vᵢvⱼ` is NOT `∑ⱼ wⱼ²`.

    Instead use: the entrywise square satisfies
    `∑ᵢ∑ⱼ M_ij² vᵢvⱼ = ∑_k e_kᵀ M diag(v) M e_k`... this is complex.

    We prove it via: `-(M ∘ M)` is a sum of negative outer products of rows,
    or by direct matrix manipulation.
-/
theorem condNegSemidef_neg_hadamard_sq {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ)
    (hMpsd : M.PosSemidef) :
    CondNegSemidef (Matrix.of fun i j => -(M i j * M i j)) := by
  -- Since $M$ is positive semidefinite, we can write $M = \sum_k w_k w_k^T$ for some vectors $w_k$.
  obtain ⟨w, hw⟩ : ∃ w : Fin n → Fin n → ℝ, M = Matrix.of (fun i j => ∑ k, w k i * w k j) := by
    have := Matrix.posSemidef_iff_eq_conjTranspose_mul_self.mp hMpsd;
    obtain ⟨ B, rfl ⟩ := this; use fun k i => B k i; ext i j; simp +decide [ Matrix.mul_apply ] ;
  intro v hv
  have h_sum_sq : ∑ i, ∑ j, (∑ k, w k i * w k j) * (∑ k, w k i * w k j) * v i * v j = ∑ k, ∑ l, (∑ i, w k i * w l i * v i)^2 := by
    simp +decide only [Finset.mul_sum _ _ _, mul_comm, mul_left_comm, pow_two];
    simp +decide only [← sum_product'];
    refine' Finset.sum_bij ( fun x _ => ( x.2.2.1, x.2.2.2, x.1, x.2.1 ) ) _ _ _ _ <;> simp +decide;
  simp_all +decide [ quadForm ];
  exact Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _

end