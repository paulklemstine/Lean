import Mathlib

/-!
# Scalar unitary logarithmic factors for quantum EML activations

We prove the scalar-log unit-circle conjecture from the quantum EML future
questions.  The proof gives the explicit certified interval `[1/2, 3]`: the
norm of `log (1 + t i)` is below one at the left endpoint and above one at the
right endpoint, so continuity supplies an intersection with the unit circle.
-/

noncomputable section

open Complex Set

namespace QuantumEML

/-- The scalar logarithmic norm along the vertical line through `1`. -/
def scalarLogNorm (t : ℝ) : ℝ := ‖Complex.log (1 + (t : ℂ) * I)‖

/-- The line `1 + t i` stays in the slit plane, hence its principal logarithm
and its norm vary continuously. -/
theorem continuous_scalarLogNorm : Continuous scalarLogNorm := by
  unfold scalarLogNorm
  apply Continuous.norm
  apply Continuous.clog
  · fun_prop
  · intro t
    rw [Complex.mem_slitPlane_iff]
    left
    simp

/-- At `t = 1/2`, the logarithmic norm is at most `3/4`, hence below the unit
circle. -/
theorem scalarLogNorm_half_lt_one : scalarLogNorm (1 / 2) < 1 := by
  unfold scalarLogNorm
  have h := Complex.norm_log_one_add_half_le_self
    (z := ((1 / 2 : ℝ) : ℂ) * I) (by norm_num)
  norm_num at h ⊢
  exact h.trans_lt (by norm_num)

/-- At `t = 3`, the real part of the logarithm already exceeds one, so its norm
is outside the unit circle. -/
theorem one_lt_scalarLogNorm_three : 1 < scalarLogNorm 3 := by
  unfold scalarLogNorm
  have hn : ‖(1 : ℂ) + (3 : ℂ) * I‖ = Real.sqrt 10 := by
    rw [Complex.norm_def]
    congr 1
    norm_num [Complex.normSq]
  have h3sqrt : (3 : ℝ) < Real.sqrt 10 := by
    rw [Real.lt_sqrt (by norm_num)]
    norm_num
  have hsqrt : Real.exp 1 < Real.sqrt 10 := Real.exp_one_lt_three.trans h3sqrt
  have hlog : 1 < Real.log (Real.sqrt 10) := by
    rw [← Real.log_exp 1]
    exact Real.strictMonoOn_log (Real.exp_pos 1) (Real.sqrt_pos.2 (by norm_num)) hsqrt
  calc
    1 < |(Complex.log (1 + (3 : ℂ) * I)).re| := by
      rw [Complex.log_re, hn, abs_of_pos]
      · exact hlog
      · exact lt_trans (by norm_num) hlog
    _ ≤ ‖Complex.log (1 + (3 : ℂ) * I)‖ := Complex.abs_re_le_norm _

/-- **Scalar-log unit-circle intersection.**  There is a nonzero real scalar in
the certified interval `[1/2, 3]` for which the principal complex logarithm of
`1 + t i` has norm exactly one. -/
theorem exists_nonzero_scalar_log_norm_eq_one :
    ∃ t : ℝ, t ≠ 0 ∧ t ∈ Icc (1 / 2) 3 ∧ ‖Complex.log (1 + (t : ℂ) * I)‖ = 1 := by
  have hab : (1 / 2 : ℝ) ≤ 3 := by norm_num
  have hone : (1 : ℝ) ∈ Icc (scalarLogNorm (1 / 2)) (scalarLogNorm 3) :=
    ⟨scalarLogNorm_half_lt_one.le, one_lt_scalarLogNorm_three.le⟩
  obtain ⟨t, ht, heq⟩ :=
    intermediate_value_Icc hab continuous_scalarLogNorm.continuousOn hone
  refine ⟨t, ?_, ht, ?_⟩
  · have : 0 < t := lt_of_lt_of_le (by norm_num) ht.1
    exact ne_of_gt this
  · simpa [scalarLogNorm] using heq

/-- Reflection across the real axis shows that the scalar logarithmic norm is
even.  Thus every positive unit-circle intersection has a negative partner. -/
theorem scalarLogNorm_neg (t : ℝ) : scalarLogNorm (-t) = scalarLogNorm t := by
  unfold scalarLogNorm
  have hc : (starRingEnd ℂ) (1 + (t : ℂ) * I) = 1 + ((-t : ℝ) : ℂ) * I := by
    apply Complex.ext <;> simp
  rw [← hc, Complex.log_conj]
  · exact Complex.norm_conj _
  · intro h
    have hp := Complex.arg_eq_pi_iff.mp h
    norm_num at hp

/-- Consequently there are both positive and negative scalar parameters whose
principal logarithms lie on the complex unit circle. -/
theorem exists_pos_and_neg_scalar_log_norm_eq_one :
    ∃ t : ℝ, 0 < t ∧ ‖Complex.log (1 + (t : ℂ) * I)‖ = 1 ∧
      ‖Complex.log (1 + ((-t : ℝ) : ℂ) * I)‖ = 1 := by
  obtain ⟨t, -, htIcc, ht⟩ := exists_nonzero_scalar_log_norm_eq_one
  refine ⟨t, lt_of_lt_of_le (by norm_num) htIcc.1, ht, ?_⟩
  rw [← ht]
  simpa [scalarLogNorm] using scalarLogNorm_neg t

/-- The scalar supplied by the intersection theorem is itself a unitary
logarithmic factor in the C⋆-algebra `ℂ`. -/
theorem exists_scalar_log_mem_unitary :
    ∃ t : ℝ, t ≠ 0 ∧ Complex.log (1 + (t : ℂ) * I) ∈ unitary ℂ := by
  obtain ⟨t, ht0, -, ht⟩ := exists_nonzero_scalar_log_norm_eq_one
  refine ⟨t, ht0, ?_⟩
  let z : ℂ := Complex.log (1 + (t : ℂ) * I)
  have hz : ‖z‖ = 1 := ht
  rw [Unitary.mem_iff]
  have hs : Complex.normSq z = 1 := by
    rw [Complex.normSq_eq_norm_sq, hz]
    norm_num
  constructor <;> apply Complex.ext
  all_goals simp
  all_goals try { rw [← Complex.normSq_apply, hs] }
  all_goals ring

end QuantumEML