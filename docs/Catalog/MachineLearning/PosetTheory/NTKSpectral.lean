/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# NTK Spectral Convergence

This file develops, from a cold start, the spectral theory of the **Neural Tangent
Kernel (NTK)** that governs the convergence of gradient-based training in the
infinite-width / linearized regime.

The NTK of a model with feature/Jacobian matrix `J` is the Gram matrix
`Θ = Jᵀ J`. In the lazy-training regime, the training residual `r` evolves under
gradient descent as `r_{k+1} = (I - η Θ) r_k`. Decomposing the residual in the
eigenbasis of `Θ` turns this matrix recurrence into independent scalar modes
`c_{k+1} = (1 - η λ) c_k`, one per eigenvalue `λ`. Hence the *entire* convergence
behaviour of training is controlled by the **spectrum** of `Θ`.

## Main results

* `ntkGram_posSemidef` — the NTK Gram matrix `Jᵀ J` is positive semidefinite.
* `ntk_quadratic_form` — the NTK quadratic form equals the squared feature-space
  norm: `xᵀ (Jᵀ J) x = ‖J x‖²`.
* `ntk_quadratic_form_nonneg` — consequently the NTK quadratic form is `≥ 0`.
* `ntk_mode_decay` — closed form of a single spectral mode: `c k = (1 - η λ)ᵏ c₀`.
* `optimal_lr_contraction` — with the optimal learning rate `η* = 2/(λ_min+λ_max)`,
  every mode contracts by the condition-number factor
  `(λ_max - λ_min)/(λ_max + λ_min) = (κ-1)/(κ+1)`.
* `geometric_convergence` — a per-step contraction by `ρ` yields `|c k| ≤ ρᵏ |c₀|`.
* `contraction_tendsto_zero` — if `ρ < 1` the residual converges to `0`.
* `ntk_optimal_tendsto_zero` — capstone: a positive-definite NTK spectrum
  (`0 < λ_min ≤ λ_max`) trained at the optimal rate drives every mode to `0`.

## References

The neural tangent kernel was introduced by Jacot, Gabriel and Hongler (2018);
the link between the smallest NTK eigenvalue and the gradient-descent convergence
rate is standard in the lazy-training literature. The condition-number contraction
`(κ-1)/(κ+1)` is the classical optimal rate for gradient descent on quadratics.
-/

namespace NTKSpectral

open Matrix Filter

-- !-- Lab Notebook -- !--
-- Hypothesis: The convergence of gradient descent in the NTK (lazy) regime is
--   entirely governed by the spectrum of the Gram matrix Θ = Jᵀ J: positive
--   semidefiniteness guarantees non-amplifying modes, and the condition number
--   κ = λ_max/λ_min controls the optimal contraction rate.
-- Result: Formalized the full chain — (1) Θ is PSD with quadratic form equal to
--   the squared feature norm; (2) each eigen-mode follows c_{k+1}=(1-ηλ)c_k with
--   closed form (1-ηλ)ᵏc₀; (3) at η*=2/(λmin+λmax) every mode contracts by
--   (λmax-λmin)/(λmax+λmin); (4) this yields geometric convergence to 0.
-- Insight: The spectral diagonalization turns the matrix recurrence into scalar
--   modes, so the global convergence theorem reduces to a one-dimensional
--   contraction lemma plus a clean condition-number inequality. The PSD result
--   and the contraction result are genuinely cross-domain: linear algebra meets
--   optimization dynamics.
-- Failure analysis: A direct ODE / matrix-exponential treatment of the
--   continuous-time flow ṙ = -Θ r was abandoned — Mathlib's ODE API makes the
--   matrix-exponential energy estimate heavy. The discrete spectral-mode route
--   captures the same mathematics (rate = condition number) with clean, fully
--   verified proofs, and is closer to what actual optimizers run.

/-! ## Section 1: The NTK Gram matrix and its spectrum -/

/-- The Neural Tangent Kernel Gram matrix associated to a Jacobian / feature
matrix `J`: `Θ = Jᵀ J`. Rows/columns are indexed by data points. -/
def ntkGram {m n : Type*} [Fintype m] [Fintype n] (J : Matrix m n ℝ) :
    Matrix n n ℝ := Jᵀ * J

-- !-- The NTK Gram matrix is `Aᴴ A` with `A = J`; over ℝ conjugate-transpose is
--     transpose, so `Matrix.posSemidef_conjTranspose_mul_self` applies directly. -- !--
/-- The NTK Gram matrix is positive semidefinite. This is the spectral backbone:
all NTK eigenvalues are `≥ 0`, so no training mode is ever *amplified*. -/
theorem ntkGram_posSemidef {m n : Type*} [Fintype m] [Fintype n] [DecidableEq n]
    (J : Matrix m n ℝ) : (ntkGram J).PosSemidef := by
  have := Matrix.posSemidef_conjTranspose_mul_self J
  simpa [ntkGram] using this

-- !-- Expand `(Jᵀ J) *ᵥ x = Jᵀ *ᵥ (J *ᵥ x)`, push the `x` through `dotProduct_mulVec`
--     and `vecMul_transpose` to land on `(J x) ⬝ᵥ (J x)`. -- !--
/-- The NTK quadratic form is the squared norm of the residual in feature space:
`xᵀ (Jᵀ J) x = (J x) · (J x) = ‖J x‖²`. This identity is *why* the NTK measures
alignment of gradients: it is an honest inner product of feature vectors. -/
theorem ntk_quadratic_form {m n : Type*} [Fintype m] [Fintype n]
    (J : Matrix m n ℝ) (x : n → ℝ) :
    x ⬝ᵥ (ntkGram J) *ᵥ x = (J *ᵥ x) ⬝ᵥ (J *ᵥ x) := by
  rw [ntkGram, ← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec]
  simp [Matrix.vecMul_transpose]

/-- The NTK quadratic form is nonnegative: a direct corollary of the
feature-norm identity (a sum of squares). -/
theorem ntk_quadratic_form_nonneg {m n : Type*} [Fintype m] [Fintype n]
    (J : Matrix m n ℝ) (x : n → ℝ) :
    0 ≤ x ⬝ᵥ (ntkGram J) *ᵥ x := by
  rw [ntk_quadratic_form]
  unfold dotProduct
  exact Finset.sum_nonneg (fun i _ => mul_self_nonneg _)

/-! ## Section 2: Spectral modes of gradient descent -/

-- !-- Induction on `k`: the base case is `h0`, and the step rewrites with the
--     recurrence and `pow_succ`. -- !--
/-- **Spectral mode decay.** In the eigenbasis of the NTK, the gradient-descent
residual decouples into scalar modes obeying `c_{k+1} = (1 - η λ) c_k`. This lemma
gives the closed form `c k = (1 - η λ)ᵏ c₀`, exposing that each eigenvalue `λ`
contributes an independent geometric factor `(1 - η λ)`. -/
theorem ntk_mode_decay (lr lam c0 : ℝ) (c : ℕ → ℝ)
    (h0 : c 0 = c0) (hrec : ∀ k, c (k + 1) = (1 - lr * lam) * c k) :
    ∀ k, c k = (1 - lr * lam) ^ k * c0 := by
  intro k
  induction k with
  | zero => simpa using h0
  | succ k ih => rw [hrec, ih, pow_succ]; ring

-- !-- Write `1 - η λ` over the common denominator `λmin+λmax`; the bound reduces
--     to `|λmin+λmax-2λ| ≤ λmax-λmin`, which is exactly `λmin ≤ λ ≤ λmax`. -- !--
/-- **Optimal-learning-rate contraction.** Choosing the classical optimal step
size `η* = 2/(λ_min+λ_max)`, *every* eigen-mode with eigenvalue
`λ ∈ [λ_min, λ_max]` contracts by at most the condition-number factor
`(λ_max - λ_min)/(λ_max + λ_min) = (κ-1)/(κ+1)` where `κ = λ_max/λ_min`. This is
the central spectral statement: the worst-case convergence rate of NTK training
is determined by the condition number of the kernel. -/
theorem optimal_lr_contraction (lmin lmax lam : ℝ)
    (hmin : 0 < lmin) (h1 : lmin ≤ lam) (h2 : lam ≤ lmax) :
    |1 - (2 / (lmin + lmax)) * lam| ≤ (lmax - lmin) / (lmax + lmin) := by
  have hs : 0 < lmin + lmax := by linarith
  have key : 1 - (2 / (lmin + lmax)) * lam = (lmin + lmax - 2 * lam) / (lmin + lmax) := by
    field_simp
  rw [key, abs_div, abs_of_pos hs, add_comm lmax lmin, div_le_div_iff_of_pos_right hs]
  rw [abs_le]; constructor <;> linarith

/-! ## Section 3: From contraction to convergence -/

-- !-- Induction on `k`: combine the one-step bound `|s (k+1)| ≤ ρ |s k|` with the
--     inductive `|s k| ≤ ρᵏ |s 0|`, using `ρ ≥ 0` for monotonicity. -- !--
/-- **Geometric convergence.** Any sequence whose absolute value contracts by a
factor `ρ ≥ 0` at each step satisfies `|c k| ≤ ρᵏ |c₀|`. Applied to an NTK mode
with `ρ = (κ-1)/(κ+1)`, this gives the explicit per-iteration error bound. -/
theorem geometric_convergence (rho : ℝ) (hrho : 0 ≤ rho) (s : ℕ → ℝ)
    (hs : ∀ k, |s (k + 1)| ≤ rho * |s k|) :
    ∀ k, |s k| ≤ rho ^ k * |s 0| := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
    calc |s (k + 1)| ≤ rho * |s k| := hs k
      _ ≤ rho * (rho ^ k * |s 0|) := by
            exact mul_le_mul_of_nonneg_left ih hrho
      _ = rho ^ (k + 1) * |s 0| := by rw [pow_succ]; ring

-- !-- Squeeze `|s k|` between `0` and `ρᵏ |s 0| → 0` (using `ρ < 1`), then conclude
--     `s k → 0` via the norm-squeeze lemma. -- !--
/-- **Convergence to zero.** A contracting mode with `ρ < 1` drives the residual to
`0`. This is the qualitative convergence guarantee for a single NTK eigen-mode. -/
theorem contraction_tendsto_zero (rho : ℝ) (hrho : 0 ≤ rho) (hlt : rho < 1)
    (s : ℕ → ℝ) (hs : ∀ k, |s (k + 1)| ≤ rho * |s k|) :
    Tendsto s atTop (nhds 0) := by
  have hbound := geometric_convergence rho hrho s hs
  have hpow : Tendsto (fun k => rho ^ k * |s 0|) atTop (nhds 0) := by
    have := tendsto_pow_atTop_nhds_zero_of_lt_one hrho hlt
    simpa using this.mul_const (|s 0|)
  refine squeeze_zero_norm (fun k => ?_) hpow
  simpa [Real.norm_eq_abs] using hbound k

/-! ## Section 4: Capstone — spectrum controls convergence -/

-- !-- Assemble: `optimal_lr_contraction` shows each mode contracts by
--     `ρ = (λmax-λmin)/(λmax+λmin) < 1`; feed that into `contraction_tendsto_zero`. -- !--
/-- **NTK spectral convergence theorem.** Suppose the NTK has a strictly positive
spectrum `0 < λ_min ≤ λ ≤ λ_max` and we train with the optimal learning rate
`η* = 2/(λ_min+λ_max)`. Then any residual mode `c` evolving by
`c_{k+1} = (1 - η* λ) c_k` converges to `0`. This packages the spectral picture:
*positive definiteness of the NTK ⇒ global convergence of lazy training.* -/
theorem ntk_optimal_tendsto_zero (lmin lmax lam : ℝ)
    (hmin : 0 < lmin) (h1 : lmin ≤ lam) (h2 : lam ≤ lmax)
    (c : ℕ → ℝ)
    (hrec : ∀ k, c (k + 1) = (1 - (2 / (lmin + lmax)) * lam) * c k) :
    Tendsto c atTop (nhds 0) := by
  set rho := (lmax - lmin) / (lmax + lmin) with hrho_def
  have hmax : 0 < lmax := lt_of_lt_of_le hmin (le_trans h1 h2)
  have hs : 0 < lmax + lmin := by linarith
  have hrho0 : 0 ≤ rho := by
    rw [hrho_def]; apply div_nonneg <;> linarith
  have hrholt : rho < 1 := by
    rw [hrho_def, div_lt_one hs]; linarith
  have hcontr : |1 - (2 / (lmin + lmax)) * lam| ≤ rho :=
    optimal_lr_contraction lmin lmax lam hmin h1 h2
  -- each step contracts by ρ
  have hstep : ∀ k, |c (k + 1)| ≤ rho * |c k| := by
    intro k
    rw [hrec, abs_mul]
    exact mul_le_mul_of_nonneg_right hcontr (abs_nonneg _)
  exact contraction_tendsto_zero rho hrho0 hrholt c hstep

end NTKSpectral