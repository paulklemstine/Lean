/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The trace–eigenvalue bridge for empirical spectral distributions

The moment method for the Wigner semicircle law rests on the identity

  (1/N) Σᵢ λᵢᵏ = (1/N) tr(Aᵏ),

which converts a statement about the *empirical spectral distribution* (ESD) of a
Hermitian matrix into a statement about traces of powers, i.e. into a sum over
closed walks in the complete graph.  This file proves that bridge for arbitrary
Hermitian matrices over an `RCLike` field, specialises it to the real symmetric
case, and sets up the `√N`-normalised spectral moments used in the semicircle law.
-/
import Mathlib

open Matrix BigOperators

namespace WignerBridge

variable {𝕜 : Type*} [RCLike 𝕜] {n : Type*} [Fintype n] [DecidableEq n]

/-- **Trace–eigenvalue bridge.**  For a Hermitian matrix, the trace of the `k`-th
power is the `k`-th power sum of the eigenvalues. -/
theorem trace_pow_eq_sum_eigenvalues {A : Matrix n n 𝕜} (hA : A.IsHermitian) (k : ℕ) :
    (A ^ k).trace = ∑ i, ((hA.eigenvalues i : 𝕜)) ^ k := by
  conv_lhs => rw [hA.spectral_theorem]
  rw [← map_pow, Unitary.conjStarAlgAut_apply, Matrix.trace_mul_cycle]
  have h1 : (star hA.eigenvectorUnitary : Matrix n n 𝕜) *
      (hA.eigenvectorUnitary : Matrix n n 𝕜) = 1 := by
    simp
  rw [h1, Matrix.one_mul, diagonal_pow, Matrix.trace_diagonal]
  simp

/-- Real symmetric version of the trace–eigenvalue bridge. -/
theorem trace_pow_eq_sum_eigenvalues_real {A : Matrix n n ℝ} (hA : A.IsHermitian) (k : ℕ) :
    (A ^ k).trace = ∑ i, (hA.eigenvalues i) ^ k := by
  simpa using trace_pow_eq_sum_eigenvalues (𝕜 := ℝ) hA k

/-- The `k`-th moment of the empirical spectral distribution of a Hermitian matrix:
the average of the `k`-th powers of its eigenvalues. -/
noncomputable def esdMoment {A : Matrix n n ℝ} (hA : A.IsHermitian) (k : ℕ) : ℝ :=
  (1 / (Fintype.card n : ℝ)) * ∑ i, (hA.eigenvalues i) ^ k

theorem esdMoment_eq_trace {A : Matrix n n ℝ} (hA : A.IsHermitian) (k : ℕ) :
    esdMoment hA k = (1 / (Fintype.card n : ℝ)) * (A ^ k).trace := by
  rw [esdMoment, trace_pow_eq_sum_eigenvalues_real hA k]

/-- The `√N`-normalised spectral moment used in the semicircle law: the `k`-th ESD
moment of `A / √N`. -/
noncomputable def normalizedMoment (A : Matrix n n ℝ) (k : ℕ) : ℝ :=
  (1 / (Fintype.card n : ℝ)) *
    (((Real.sqrt (Fintype.card n))⁻¹ • A) ^ k).trace

theorem normalizedMoment_eq (A : Matrix n n ℝ) (k : ℕ) :
    normalizedMoment A k =
      (1 / (Fintype.card n : ℝ)) * (Real.sqrt (Fintype.card n))⁻¹ ^ k * (A ^ k).trace := by
  rw [normalizedMoment, smul_pow, Matrix.trace_smul, smul_eq_mul]
  ring

/-- The normalised spectral moment is the average of the `k`-th powers of the
rescaled eigenvalues `λᵢ / √N`; this is exactly the `k`-th moment of the empirical
spectral distribution of `A / √N`. -/
theorem normalizedMoment_eq_sum_eigenvalues {A : Matrix n n ℝ} (hA : A.IsHermitian) (k : ℕ) :
    normalizedMoment A k =
      (1 / (Fintype.card n : ℝ)) *
        ∑ i, (hA.eigenvalues i / Real.sqrt (Fintype.card n)) ^ k := by
  rw [normalizedMoment_eq, trace_pow_eq_sum_eigenvalues_real hA k, Finset.mul_sum,
    Finset.mul_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [div_pow]
  field_simp
  rw [div_pow, one_pow]
  ring

end WignerBridge