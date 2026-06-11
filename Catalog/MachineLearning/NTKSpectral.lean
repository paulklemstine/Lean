/-
# Neural Tangent Kernel: Spectral Convergence Theory

This file extends `MachineLearning.NTKCore` along Research Direction #1 of the
NTK programme: making the geometric convergence theorem
(`gdResidual_geometric_decay`) *explicit* in terms of the spectrum of the
kernel matrix K.

In `NTKCore`, convergence is driven by an opaque contractivity constant `c < 1`
(`IsContractive`).  Here we open that black box on the eigen-decomposition:

* For an eigenvector `v` of `K` with eigenvalue `λ`, the gradient-descent update
  operator `I - ηK` acts as the *scalar* `1 - ηλ`, so the residual along `v`
  decays exactly like `|1 - ηλ|^t`.

* Stability along that mode is the scalar condition `0 < ηλ < 2`.

* Optimising the worst-case contraction over a spectrum `[μ, L]` (with
  `0 < μ ≤ L`) yields the classical optimal learning rate `η* = 2/(μ+L)` with
  contraction constant `(L-μ)/(L+μ)` — the inverse condition number bound.

* The NTK Gram matrix is positive semidefinite (`ntkGramMatrix_posSemidef`), so
  its eigenvalues are nonnegative; combined with the stability range this gives a
  concrete convergence theorem for genuine NTK modes.

## Catalog synthesis

We build directly on `MachineLearning.NTKCore`:
`gdUpdateOp`, `gdStep`, `gdResidual`, `IsContractive`, `gdResidual_geometric_decay`,
`ntkGramMatrix`, and `ntkGramMatrix_posSemidef`.  We connect them to Mathlib's
`Matrix.PosSemidef.eigenvalues_nonneg` (Hermitian eigenvalue API), realising the
"connect to Mathlib's eigenvalue API" goal stated in the future-directions notes.
-/

import Mathlib
import MachineLearning.NTKCore

open Matrix Finset BigOperators

noncomputable section

namespace NTKSpectral

variable {n p : ℕ}

/-! ## Part 1: The update operator acts diagonally on eigenvectors -/

/-
!-- If `K v = λ v` then `(I - ηK) v = (1 - ηλ) v`: expand `gdUpdateOp` and use
linearity of `mulVec` together with the eigenvalue equation. -- !--
-/
theorem gdUpdateOp_mulVec_eigenvector (K : Matrix (Fin n) (Fin n) ℝ) (η lam : ℝ)
    (v : Fin n → ℝ) (hv : K.mulVec v = lam • v) :
    (gdUpdateOp K η).mulVec v = (1 - η * lam) • v := by
  ext i;
  simp +decide [ gdUpdateOp, Matrix.sub_mulVec, Matrix.one_mulVec, Matrix.smul_mulVec, hv ];
  ring

/-
!-- Iterating the previous lemma: the residual after `t` steps along an
eigenvector is `(1 - ηλ)^t v`. Induction on `t`. -- !--
-/
theorem gdResidual_eigenvector (K : Matrix (Fin n) (Fin n) ℝ) (η lam : ℝ)
    (v : Fin n → ℝ) (hv : K.mulVec v = lam • v) (t : ℕ) :
    gdResidual K η v t = (1 - η * lam) ^ t • v := by
  induction' t with t ih
  · simp [gdResidual]
  · have h_step : gdResidual K η v (t + 1)
        = (gdUpdateOp K η).mulVec (gdResidual K η v t) := rfl
    rw [h_step, ih, Matrix.mulVec_smul, gdUpdateOp_mulVec_eigenvector K η lam v hv,
      smul_smul, ← pow_succ]

/-! ## Part 2: Exact norm decay and the spectral contraction bound -/

/-
!-- Taking norms of the eigenvector residual gives an *exact* geometric law
`‖u_t‖ = |1 - ηλ|^t ‖v‖`, using `norm_smul` and `Real.norm_eq_abs`. -- !--
-/
theorem gdResidual_eigenvector_norm (K : Matrix (Fin n) (Fin n) ℝ) (η lam : ℝ)
    (v : Fin n → ℝ) (hv : K.mulVec v = lam • v) (t : ℕ) :
    ‖gdResidual K η v t‖ = |1 - η * lam| ^ t * ‖v‖ := by
  convert congr_arg Norm.norm ( gdResidual_eigenvector K η lam v hv t ) using 1;
  norm_num [ norm_smul, abs_pow ]

/-
!-- A per-mode version of `gdResidual_geometric_decay`: any bound
`|1 - ηλ| ≤ c` upgrades to `‖u_t‖ ≤ c^t ‖v‖`. Monotonicity of `x ↦ x^t`. -- !--
-/
theorem gdResidual_eigenvector_decay (K : Matrix (Fin n) (Fin n) ℝ) (η lam c : ℝ)
    (v : Fin n → ℝ) (hv : K.mulVec v = lam • v) (hc : |1 - η * lam| ≤ c) (t : ℕ) :
    ‖gdResidual K η v t‖ ≤ c ^ t * ‖v‖ := by
  rw [ gdResidual_eigenvector_norm K η lam v hv t ];
  gcongr

/-! ## Part 3: Stability range of a single eigenvalue -/

/-
!-- The mode `λ` is (strictly) contractive iff the step size lands in the
classical stability window `0 < ηλ < 2`. Direct from `abs_lt`. -- !--
-/
theorem eigenvalue_stable_iff (η lam : ℝ) :
    |1 - η * lam| < 1 ↔ 0 < η * lam ∧ η * lam < 2 := by
  exact abs_lt.trans ⟨ fun h => ⟨ by linarith, by linarith ⟩, fun h => ⟨ by linarith, by linarith ⟩ ⟩

/-! ## Part 4: Optimal learning rate over a spectrum `[μ, L]` -/

/-
!-- At the optimal rate `η* = 2/(μ+L)` both extreme modes contract by exactly
the inverse-condition-number factor `(L-μ)/(L+μ)`. Field arithmetic plus
`abs_of_nonneg` / `abs_of_nonpos`. -- !--
-/
theorem optimalRate_contraction (mu L : ℝ) (hmu : 0 < mu) (hL : mu ≤ L) :
    |1 - (2 / (mu + L)) * mu| = (L - mu) / (L + mu) ∧
    |1 - (2 / (mu + L)) * L| = (L - mu) / (L + mu) := by
  constructor <;> rw [ abs_eq ];
  · grind;
  · exact div_nonneg ( by linarith ) ( by linarith );
  · grind;
  · exact div_nonneg ( by linarith ) ( by linarith )

/-
!-- The optimal contraction constant is `< 1` exactly because `μ > 0`. -- !--
-/
theorem optimalRate_lt_one (mu L : ℝ) (hmu : 0 < mu) (hL : mu ≤ L) :
    (L - mu) / (L + mu) < 1 := by
  rw [ div_lt_iff₀ ] <;> linarith

/-
!-- Optimality (lower bound): NO step size beats `(L-μ)/(L+μ)` on the worst of
the two extreme modes. Key trick: the η-free combination
`L(1-ημ) - μ(1-ηL) = L-μ`, so the triangle inequality gives
`(L+μ)·max ≥ L|1-ημ| + μ|1-ηL| ≥ |L-μ| = L-μ`. -- !--
-/
theorem optimalRate_minimizes (mu L η : ℝ) (hmu : 0 < mu) (hL : mu ≤ L) :
    (L - mu) / (L + mu) ≤ max |1 - η * mu| |1 - η * L| := by
  rw [ div_le_iff₀ ];
  · cases abs_cases ( 1 - η * mu ) <;> cases abs_cases ( 1 - η * L ) <;> nlinarith [ le_max_left |1 - η * mu| |1 - η * L|, le_max_right |1 - η * mu| |1 - η * L| ];
  · linarith

/-! ## Part 5: Nonnegativity of NTK eigenvalues (Mathlib bridge) -/

/-
!-- The NTK Gram matrix is PSD (`ntkGramMatrix_posSemidef`), so each Hermitian
eigenvalue is `≥ 0` via `Matrix.PosSemidef.eigenvalues_nonneg`. -- !--
-/
theorem ntkGram_eigenvalues_nonneg (Φ : Fin n → Fin p → ℝ) (i : Fin n) :
    0 ≤ (ntkGramMatrix_posSemidef Φ).1.eigenvalues i := by
  convert Matrix.PosSemidef.eigenvalues_nonneg ( ntkGramMatrix_posSemidef Φ ) i

/-! ## Part 6: Capstone — explicit convergence for a genuine NTK mode -/

/-
!-- Combining the eigenvector norm law with the stability window: for a true
NTK eigenvector with positive eigenvalue and `η` in the stable range, the
residual decays geometrically with an *explicit, < 1* rate. -- !--
-/
theorem ntk_eigen_convergence (Φ : Fin n → Fin p → ℝ) (η lam : ℝ) (v : Fin n → ℝ)
    (hv : (ntkGramMatrix Φ).mulVec v = lam • v)
    (hη : 0 < η) (hlam : 0 < lam) (hη2 : η * lam < 2) (t : ℕ) :
    ‖gdResidual (ntkGramMatrix Φ) η v t‖ = |1 - η * lam| ^ t * ‖v‖ ∧
      |1 - η * lam| < 1 := by
  exact ⟨ gdResidual_eigenvector_norm _ _ _ _ hv _, abs_lt.mpr ⟨ by nlinarith, by nlinarith ⟩ ⟩

end NTKSpectral