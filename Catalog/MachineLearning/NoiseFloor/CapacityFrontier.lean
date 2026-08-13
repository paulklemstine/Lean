/-
# The Noise-Floor Principle, Part V: the capacity frontier

Round-6 hypothesis closure, Phase A, cycle 2.

The trace bound `d_eff ≤ tr A / b` of Part I is lossy: it ignores the saturation
of every individual mode.  The correct intermediate quantity is the **Gaussian
channel capacity** (equivalently, the log-determinant of the regularised
covariance, equivalently the log-evidence of the Bayesian linear model)

  `logDet a b = ∑ i, log (1 + a i / b) = log det (1 + b⁻¹ • A)`.

We prove the *capacity frontier*

  `effDim a b ≤ logDet a b ≤ tr a / b`,

a strict sharpening of Part I that inserts an information-theoretic quantity
between a purely spectral one and a purely linear one, and its matrix form

  `noiseFloor ≤ b · log det (1 + b⁻¹ • A) ≤ tr A`.

Thus *the irreducible risk of spectral learning is bounded by the channel
capacity of the data covariance* — a bridge between estimation theory
(Parts I–IV) and information theory.

## Main results

* `mode_log_sandwich`      — `x/(x+b) ≤ log (1 + x/b) ≤ x/b`, the scalar engine
* `effDim_le_logDet`, `logDet_le_trace_div` — the capacity frontier
* `logDet_eq_log_det_matrix` — `∑ log (1 + μ i / b) = log det (1 + b⁻¹ • A)`
* `noiseFloor_le_capacity`, `capacity_le_trace` — matrix form of the frontier
* `capacity_frontier_strict` — the frontier is strictly finer than Part I:
  at `a = b` the three quantities are `1/2 < log 2 < 1`.
-/
import Mathlib
import MachineLearning.NoiseFloor.EffectiveDimension
import MachineLearning.NoiseFloor.NoiseFloorPrinciple
import MachineLearning.NoiseFloor.TraceLemma

namespace Catalog.MachineLearning.NoiseFloor

open Finset Matrix

variable {ι : Type*} [Fintype ι]

/-- Gaussian channel capacity (in nats, up to the factor `1/2`) of the spectrum
`a` at noise level `b`. -/
noncomputable def logDet (a : ι → ℝ) (b : ℝ) : ℝ := ∑ i, Real.log (1 + a i / b)

section Mode

variable {x b : ℝ}

/-- **Scalar capacity sandwich.**  `x/(x+b) ≤ log (1 + x/b) ≤ x/b`.  The left
inequality is the saturation bound, the right one the linear bound. -/
lemma mode_log_sandwich (hx : 0 ≤ x) (hb : 0 < b) :
    x / (x + b) ≤ Real.log (1 + x / b) ∧ Real.log (1 + x / b) ≤ x / b := by
  have hd : 0 < x + b := by linarith
  have hu : 0 < 1 + x / b := by positivity
  constructor
  · -- from `log y ≤ y - 1` applied to `y = 1/(1 + x/b)`
    have h := Real.log_le_sub_one_of_pos (x := (1 + x / b)⁻¹) (by positivity)
    rw [Real.log_inv] at h
    have hval : (1 + x / b)⁻¹ - 1 = - (x / (x + b)) := by
      field_simp
      ring
    rw [hval] at h
    linarith
  · have h := Real.log_le_sub_one_of_pos hu
    simpa using h

end Mode

section Frontier

variable {a : ι → ℝ} {b : ℝ}

/-- **Capacity frontier, lower half.**  The effective dimension never exceeds the
channel capacity. -/
theorem effDim_le_logDet (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    effDim a b ≤ logDet a b :=
  Finset.sum_le_sum fun i _ => (mode_log_sandwich (ha i) hb).1

/-- **Capacity frontier, upper half.**  The channel capacity never exceeds the
normalised trace — recovering, and strengthening, `effDim_le_trace_div`. -/
theorem logDet_le_trace_div (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    logDet a b ≤ (∑ i, a i) / b := by
  rw [Finset.sum_div]
  exact Finset.sum_le_sum fun i _ => (mode_log_sandwich (ha i) hb).2

/-- The noise floor is dominated by `b` times the capacity. -/
theorem noiseFloor_le_b_mul_logDet (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    noiseFloor a b ≤ b * logDet a b :=
  mul_le_mul_of_nonneg_left (effDim_le_logDet ha hb) hb.le

/-- At a mode exactly at the noise level, the three frontier quantities are
strictly ordered: `1/2 < log 2 < 1`.  Hence the capacity frontier is a genuine
refinement of the trace bound of Part I, not a restatement of it. -/
theorem capacity_frontier_strict :
    effDim (fun _ : Fin 1 => (1 : ℝ)) 1 < logDet (fun _ : Fin 1 => (1 : ℝ)) 1 ∧
      logDet (fun _ : Fin 1 => (1 : ℝ)) 1 < (∑ _i : Fin 1, (1 : ℝ)) / 1 := by
  have hlog2 : Real.log 2 < 1 := by
    have h : Real.log 2 < Real.log (Real.exp 1) := by
      apply Real.log_lt_log (by norm_num)
      linarith [Real.exp_one_gt_d9]
    rwa [Real.log_exp] at h
  have hhalf : (1 : ℝ) / 2 < Real.log 2 := by
    -- `log 2 > 1/2` because `e < 4`, i.e. `exp (1/2) < 2`
    have hexp : Real.exp 1 < 4 := by
      have := Real.exp_one_lt_d9
      linarith
    have h1 : Real.exp (1 / 2) < 2 := by
      have h2 : Real.exp (1 / 2) ^ 2 = Real.exp 1 := by
        rw [← Real.exp_nat_mul]
        norm_num
      nlinarith [Real.exp_pos (1 / 2), h2, hexp]
    by_contra hcon
    push_neg at hcon
    have hle : Real.exp (Real.log 2) ≤ Real.exp (1 / 2) := Real.exp_le_exp.mpr hcon
    rw [Real.exp_log (by norm_num : (0:ℝ) < 2)] at hle
    linarith
  have heff : effDim (fun _ : Fin 1 => (1 : ℝ)) 1 = 1 / 2 := by
    rw [effDim]; norm_num
  have hcap : logDet (fun _ : Fin 1 => (1 : ℝ)) 1 = Real.log 2 := by
    rw [logDet]; norm_num
  refine ⟨?_, ?_⟩
  · rw [heff, hcap]; exact hhalf
  · rw [hcap]; norm_num; linarith

end Frontier

section MatrixCapacity

variable {n : Type*} [Fintype n] [DecidableEq n] {A : Matrix n n ℝ} {b : ℝ}

/-- The capacity of the eigenvalue spectrum is the log-determinant of the
regularised covariance. -/
theorem logDet_eq_log_det_matrix (hA : A.IsHermitian) (hpsd : A.PosSemidef) (hb : 0 < b) :
    logDet hA.eigenvalues b = Real.log (1 + b⁻¹ • A).det := by
  have h2 : (hA.eigenvectorUnitary : Matrix n n ℝ) *
      star (hA.eigenvectorUnitary : Matrix n n ℝ) = 1 :=
    Unitary.mul_star_self_of_mem hA.eigenvectorUnitary.2
  have hdiag : (1 : Matrix n n ℝ) + b⁻¹ • A
      = (hA.eigenvectorUnitary : Matrix n n ℝ) *
        diagonal (fun i => 1 + b⁻¹ * hA.eigenvalues i) *
        star (hA.eigenvectorUnitary : Matrix n n ℝ) := by
    have hd : (1 : Matrix n n ℝ) + b⁻¹ • diagonal hA.eigenvalues
        = diagonal (fun i => 1 + b⁻¹ * hA.eigenvalues i) := by
      ext i j
      by_cases h : i = j <;> simp [h]
    rw [← hd, Matrix.mul_add, Matrix.add_mul, Matrix.mul_one, h2, Matrix.mul_smul,
      Matrix.smul_mul, ← spectral_conj hA]
  have hdet : (1 + b⁻¹ • A).det = ∏ i, (1 + b⁻¹ * hA.eigenvalues i) := by
    rw [hdiag, Matrix.det_mul, Matrix.det_mul, Matrix.det_diagonal]
    have hunit : (hA.eigenvectorUnitary : Matrix n n ℝ).det *
        (star (hA.eigenvectorUnitary : Matrix n n ℝ)).det = 1 := by
      rw [← Matrix.det_mul, h2, Matrix.det_one]
    calc (hA.eigenvectorUnitary : Matrix n n ℝ).det * (∏ i, (1 + b⁻¹ * hA.eigenvalues i)) *
        (star (hA.eigenvectorUnitary : Matrix n n ℝ)).det
        = ((hA.eigenvectorUnitary : Matrix n n ℝ).det *
          (star (hA.eigenvectorUnitary : Matrix n n ℝ)).det) *
          ∏ i, (1 + b⁻¹ * hA.eigenvalues i) := by ring
      _ = ∏ i, (1 + b⁻¹ * hA.eigenvalues i) := by rw [hunit, one_mul]
  rw [hdet, logDet, Real.log_prod]
  · refine Finset.sum_congr rfl fun i _ => ?_
    rw [div_eq_inv_mul]
  · intro i _
    have h0 : (0:ℝ) ≤ hA.eigenvalues i := hpsd.eigenvalues_nonneg i
    have : 0 < 1 + b⁻¹ * hA.eigenvalues i := by positivity
    exact this.ne'

/-- **Matrix capacity frontier.**  The irreducible risk of spectral learning is
at most `b` times the log-determinant capacity of the regularised covariance. -/
theorem noiseFloor_le_capacity (hA : A.IsHermitian) (hpsd : A.PosSemidef) (hb : 0 < b) :
    noiseFloor hA.eigenvalues b ≤ b * Real.log (1 + b⁻¹ • A).det := by
  rw [← logDet_eq_log_det_matrix hA hpsd hb]
  exact noiseFloor_le_b_mul_logDet (fun i => hpsd.eigenvalues_nonneg i) hb

/-- And the capacity itself is at most the total signal power. -/
theorem capacity_le_trace (hA : A.IsHermitian) (hpsd : A.PosSemidef) (hb : 0 < b) :
    b * Real.log (1 + b⁻¹ • A).det ≤ A.trace := by
  rw [← logDet_eq_log_det_matrix hA hpsd hb]
  have h := logDet_le_trace_div (fun i => hpsd.eigenvalues_nonneg i) hb
  have := mul_le_mul_of_nonneg_left h hb.le
  rw [mul_div_cancel₀ _ hb.ne'] at this
  rwa [trace_eq_sum_eig hA]

end MatrixCapacity

end Catalog.MachineLearning.NoiseFloor