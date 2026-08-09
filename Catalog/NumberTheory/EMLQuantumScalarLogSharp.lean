import Mathlib

/-!
# Sharpening the scalar unitary logarithmic factor

This file continues the study of the *scalar-log unit-circle* problem for
quantum EML activations begun in `Catalog/NumberTheory/EMLQuantumScalarLog.lean`,
where the existence of a parameter `t ≠ 0` with `‖log (1 + t i)‖ = 1` was
established with the crude certified interval `[1/2, 3]`.  (The catalog files
are compiled independently of one another, so the two basic definitions
`scalarLogNorm` and the auxiliary lemmas are restated here verbatim; everything
past that point is new.)

The results proved here answer the first three of the "future directions"
attached to that file, and add a fourth.

## Main results

* `QuantumEML.scalarLogNorm_sq` : the closed form
  `‖log (1 + t i)‖ ^ 2 = (log (1 + t ^ 2) / 2) ^ 2 + arctan t ^ 2`.
* `QuantumEML.strictMonoOn_scalarLogNorm` : `t ↦ ‖log (1 + t i)‖` is *strictly
  increasing* on `[0, ∞)`.  This upgrades the previous existence statement to a
  uniqueness statement.
* `QuantumEML.existsUnique_pos_scalarLogNorm_eq_one` : there is exactly one
  positive solution of `‖log (1 + t i)‖ = 1`.
* `QuantumEML.scalarLogNorm_six_fifths_lt_one`,
  `QuantumEML.one_lt_scalarLogNorm_five_fourths`,
  `QuantumEML.root_mem_Icc_six_fifths_five_fourths` : the certified interval is
  tightened from `[1/2, 3]` to `[6/5, 5/4]`, a factor `30` improvement in
  width.  The proof uses the exact `arctan` addition identities
  `arctan (6/5) = π/4 + arctan (1/11)` and `arctan (5/4) = π/4 + arctan (1/9)`
  together with the elementary two-sided bound
  `y / (1 + y ^ 2) ≤ arctan y ≤ y` and the rational bounds
  `1 - x⁻¹ ≤ log x ≤ x - 1` applied after splitting off `log 2`.
* `smul_one_mem_unitary` : a scalar of modulus one times the identity of any
  complex star algebra is unitary; hence the scalar logarithmic factor lifts to
  matrix C⋆-algebras (`QuantumEML.exists_scalar_log_smul_one_mem_unitary`).
* `QuantumEML.polarUnit_smul_one_mem_unitary` : the *polar-normalized*
  logarithmic factor `log (1 + t i) / ‖log (1 + t i)‖` is unitary for **every**
  `t ≠ 0`, not merely for the certified root.
-/

noncomputable section

open Complex Real Set

/-! ### A scalar of modulus one is a unitary in any complex star algebra -/

/-- If `‖z‖ = 1` then `z • 1` is a unitary element of any complex star algebra.
Specialising `A` to `Matrix (Fin n) (Fin n) ℂ` lifts scalar unitaries to matrix
C⋆-algebras. -/
theorem smul_one_mem_unitary {A : Type*} [Ring A] [StarRing A] [Algebra ℂ A] [StarModule ℂ A]
    {z : ℂ} (hz : ‖z‖ = 1) : z • (1 : A) ∈ unitary A := by
  have hzz : star z * z = 1 := by
    rw [Complex.star_def, Complex.conj_mul', hz]; norm_num
  have hzz' : z * star z = 1 := by
    rw [Complex.star_def, Complex.mul_conj', hz]; norm_num
  constructor
  · rw [star_smul, star_one, smul_mul_smul_comm, one_mul, hzz, one_smul]
  · rw [star_smul, star_one, smul_mul_smul_comm, one_mul, hzz', one_smul]

/-- The polar normalisation `w ↦ w / ‖w‖` of a nonzero complex number. -/
def polarUnit (w : ℂ) : ℂ := ((‖w‖ : ℝ) : ℂ)⁻¹ * w

theorem norm_polarUnit {w : ℂ} (hw : w ≠ 0) : ‖polarUnit w‖ = 1 := by
  have h : ‖w‖ ≠ 0 := norm_ne_zero_iff.mpr hw
  rw [polarUnit, norm_mul, norm_inv, Complex.norm_real, Real.norm_eq_abs,
    abs_of_nonneg (norm_nonneg w)]
  field_simp

/-! ### Elementary two-sided bounds for `arctan` -/

namespace QuantumEML

/-- `arctan y ≤ y` for `y ≥ 0`, from the tangent inequality `x ≤ tan x`. -/
theorem arctan_le_self {y : ℝ} (hy : 0 ≤ y) : Real.arctan y ≤ y := by
  have h := Real.le_tan (Real.arctan_nonneg.2 hy) (Real.arctan_lt_pi_div_two y)
  rwa [Real.tan_arctan] at h

/-- `y / (1 + y ^ 2) ≤ arctan y` for `y ≥ 0`.  Writing `x = arctan y`, the
left-hand side is `sin x * cos x = sin (2 x) / 2 ≤ x`. -/
theorem self_div_le_arctan {y : ℝ} (hy : 0 ≤ y) : y / (1 + y ^ 2) ≤ Real.arctan y := by
  have hnn : 0 ≤ 2 * Real.arctan y := by
    have := Real.arctan_nonneg.2 hy; linarith
  have h2 : Real.sin (2 * Real.arctan y) ≤ 2 * Real.arctan y := Real.sin_le hnn
  rw [Real.sin_two_mul, Real.sin_arctan, Real.cos_arctan] at h2
  have hs : Real.sqrt (1 + y ^ 2) ^ 2 = 1 + y ^ 2 := Real.sq_sqrt (by positivity)
  have hrw : 2 * (y / Real.sqrt (1 + y ^ 2)) * (1 / Real.sqrt (1 + y ^ 2))
      = 2 * (y / (1 + y ^ 2)) := by
    field_simp
    nlinarith [hs]
  rw [hrw] at h2
  linarith

/-- Exact addition identity `arctan (6/5) = π/4 + arctan (1/11)`. -/
theorem arctan_six_fifths_eq : Real.arctan (6 / 5) = π / 4 + Real.arctan (1 / 11) := by
  have h := Real.arctan_add (x := 1) (y := 1 / 11) (by norm_num)
  rw [Real.arctan_one] at h
  rw [h]; norm_num

/-- Exact addition identity `arctan (5/4) = π/4 + arctan (1/9)`. -/
theorem arctan_five_fourths_eq : Real.arctan (5 / 4) = π / 4 + Real.arctan (1 / 9) := by
  have h := Real.arctan_add (x := 1) (y := 1 / 9) (by norm_num)
  rw [Real.arctan_one] at h
  rw [h]; norm_num

/-! ### The scalar logarithmic norm and its closed form -/

/-- The scalar logarithmic norm along the vertical line through `1`. -/
def scalarLogNorm (t : ℝ) : ℝ := ‖Complex.log (1 + (t : ℂ) * I)‖

/-- The closed form of the square of `scalarLogNorm`. -/
def scalarLogNormSq (t : ℝ) : ℝ := (Real.log (1 + t ^ 2) / 2) ^ 2 + (Real.arctan t) ^ 2

theorem arg_one_add_mul_I (t : ℝ) : (1 + (t : ℂ) * I).arg = Real.arctan t := by
  rw [Complex.arg, if_pos (by simp), Real.arctan_eq_arcsin]
  congr 1
  rw [Complex.norm_def]
  simp [Complex.normSq]
  ring_nf

theorem norm_one_add_mul_I (t : ℝ) : ‖1 + (t : ℂ) * I‖ = Real.sqrt (1 + t ^ 2) := by
  rw [Complex.norm_def]
  congr 1
  simp [Complex.normSq]
  ring

/-- **Closed form.** `‖log (1 + t i)‖ ^ 2 = (log (1 + t ^ 2) / 2) ^ 2 + arctan t ^ 2`. -/
theorem scalarLogNorm_sq (t : ℝ) : scalarLogNorm t ^ 2 = scalarLogNormSq t := by
  have hre : (Complex.log (1 + (t : ℂ) * I)).re = Real.log (1 + t ^ 2) / 2 := by
    rw [Complex.log_re, norm_one_add_mul_I, Real.log_sqrt (by positivity)]
  have him : (Complex.log (1 + (t : ℂ) * I)).im = Real.arctan t := by
    rw [Complex.log_im, arg_one_add_mul_I]
  rw [scalarLogNorm, scalarLogNormSq, ← Complex.normSq_eq_norm_sq, Complex.normSq_apply, hre, him]
  ring

theorem scalarLogNorm_nonneg (t : ℝ) : 0 ≤ scalarLogNorm t := norm_nonneg _

theorem scalarLogNormSq_nonneg (t : ℝ) : 0 ≤ scalarLogNormSq t := by
  rw [← scalarLogNorm_sq]; positivity

theorem scalarLogNorm_eq_sqrt (t : ℝ) : scalarLogNorm t = Real.sqrt (scalarLogNormSq t) := by
  rw [← scalarLogNorm_sq, Real.sqrt_sq (scalarLogNorm_nonneg t)]

/-! ### Strict monotonicity and uniqueness -/

theorem log_one_add_sq_nonneg (t : ℝ) : 0 ≤ Real.log (1 + t ^ 2) :=
  Real.log_nonneg (by nlinarith [sq_nonneg t])

/-- The square of the scalar logarithmic norm is strictly increasing on `[0, ∞)`. -/
theorem strictMonoOn_scalarLogNormSq : StrictMonoOn scalarLogNormSq (Ici (0 : ℝ)) := by
  intro a ha b hb hab
  simp only [mem_Ici] at ha hb
  have h1 : Real.log (1 + a ^ 2) < Real.log (1 + b ^ 2) := by
    apply Real.log_lt_log (by positivity)
    nlinarith
  have h2 : Real.arctan a < Real.arctan b := Real.arctan_strictMono hab
  have ha1 := log_one_add_sq_nonneg a
  have ha2 : 0 ≤ Real.arctan a := Real.arctan_nonneg.2 ha
  unfold scalarLogNormSq
  nlinarith

/-- **Strict monotonicity.**  `t ↦ ‖log (1 + t i)‖` is strictly increasing on
`[0, ∞)`. -/
theorem strictMonoOn_scalarLogNorm : StrictMonoOn scalarLogNorm (Ici (0 : ℝ)) := by
  intro a ha b hb hab
  have h := strictMonoOn_scalarLogNormSq ha hb hab
  rw [scalarLogNorm_eq_sqrt, scalarLogNorm_eq_sqrt]
  exact Real.sqrt_lt_sqrt (scalarLogNormSq_nonneg a) h

theorem injOn_scalarLogNorm : InjOn scalarLogNorm (Ici (0 : ℝ)) :=
  strictMonoOn_scalarLogNorm.injOn

/-! ### The tightened certified interval `[6/5, 5/4]` -/

theorem scalarLogNormSq_six_fifths_lt_one : scalarLogNormSq (6 / 5) < 1 := by
  have hL : Real.log (1 + (6 / 5 : ℝ) ^ 2) ≤ 0.9131472 := by
    have h : 1 + (6 / 5 : ℝ) ^ 2 = 2 * (61 / 50) := by norm_num
    rw [h, Real.log_mul (by norm_num) (by norm_num)]
    have h1 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
    have h2 : Real.log (61 / 50) ≤ 61 / 50 - 1 := Real.log_le_sub_one_of_pos (by norm_num)
    linarith
  have hL0 : 0 ≤ Real.log (1 + (6 / 5 : ℝ) ^ 2) := Real.log_nonneg (by norm_num)
  have hA : Real.arctan (6 / 5) ≤ 0.8785 := by
    rw [arctan_six_fifths_eq]
    have := arctan_le_self (y := (1 / 11 : ℝ)) (by norm_num)
    have hpi : π < 3.15 := Real.pi_lt_d2
    linarith
  have hA0 : 0 ≤ Real.arctan (6 / 5) := Real.arctan_nonneg.2 (by norm_num)
  unfold scalarLogNormSq
  nlinarith

theorem one_lt_scalarLogNormSq_five_fourths : 1 < scalarLogNormSq (5 / 4) := by
  have hL : (0.9126593 : ℝ) ≤ Real.log (1 + (5 / 4 : ℝ) ^ 2) := by
    have h : 1 + (5 / 4 : ℝ) ^ 2 = 2 * (41 / 32) := by norm_num
    rw [h, Real.log_mul (by norm_num) (by norm_num)]
    have h1 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
    have h2 : 1 - (41 / 32 : ℝ)⁻¹ ≤ Real.log (41 / 32) := Real.one_sub_inv_le_log_of_pos (by norm_num)
    norm_num at h2 ⊢
    linarith
  have hA : (0.8951 : ℝ) ≤ Real.arctan (5 / 4) := by
    rw [arctan_five_fourths_eq]
    have h := self_div_le_arctan (y := (1 / 9 : ℝ)) (by norm_num)
    norm_num at h
    have hpi : (3.141592 : ℝ) < π := Real.pi_gt_d6
    linarith
  unfold scalarLogNormSq
  nlinarith

/-- At `t = 6/5` the logarithm is still strictly inside the unit circle. -/
theorem scalarLogNorm_six_fifths_lt_one : scalarLogNorm (6 / 5) < 1 := by
  have h := scalarLogNormSq_six_fifths_lt_one
  nlinarith [scalarLogNorm_sq (6 / 5), scalarLogNorm_nonneg (6 / 5)]

/-- At `t = 5/4` the logarithm is already strictly outside the unit circle. -/
theorem one_lt_scalarLogNorm_five_fourths : 1 < scalarLogNorm (5 / 4) := by
  have h := one_lt_scalarLogNormSq_five_fourths
  nlinarith [scalarLogNorm_sq (5 / 4), scalarLogNorm_nonneg (5 / 4)]

theorem continuous_scalarLogNorm : Continuous scalarLogNorm := by
  unfold scalarLogNorm
  apply Continuous.norm
  apply Continuous.clog
  · fun_prop
  · intro t
    rw [Complex.mem_slitPlane_iff]
    left
    simp

/-- **Tightened certified interval.**  There is a solution of
`‖log (1 + t i)‖ = 1` inside `[6/5, 5/4]`. -/
theorem exists_scalarLogNorm_eq_one_mem_Icc :
    ∃ t ∈ Icc (6 / 5 : ℝ) (5 / 4), scalarLogNorm t = 1 := by
  have hab : (6 / 5 : ℝ) ≤ 5 / 4 := by norm_num
  have hone : (1 : ℝ) ∈ Icc (scalarLogNorm (6 / 5)) (scalarLogNorm (5 / 4)) :=
    ⟨scalarLogNorm_six_fifths_lt_one.le, one_lt_scalarLogNorm_five_fourths.le⟩
  obtain ⟨t, ht, heq⟩ :=
    intermediate_value_Icc hab continuous_scalarLogNorm.continuousOn hone
  exact ⟨t, ht, heq⟩

/-- **Uniqueness.**  There is exactly one positive parameter whose principal
logarithm lies on the unit circle. -/
theorem existsUnique_pos_scalarLogNorm_eq_one :
    ∃! t : ℝ, 0 < t ∧ scalarLogNorm t = 1 := by
  obtain ⟨t, ht, hteq⟩ := exists_scalarLogNorm_eq_one_mem_Icc
  have ht0 : 0 < t := lt_of_lt_of_le (by norm_num) ht.1
  refine ⟨t, ⟨ht0, hteq⟩, ?_⟩
  rintro s ⟨hs0, hseq⟩
  exact injOn_scalarLogNorm (mem_Ici.2 hs0.le) (mem_Ici.2 ht0.le) (hseq.trans hteq.symm)

/-- Every positive solution lies in the tightened interval `[6/5, 5/4]`. -/
theorem root_mem_Icc_six_fifths_five_fourths {t : ℝ} (ht : 0 < t) (h : scalarLogNorm t = 1) :
    t ∈ Icc (6 / 5 : ℝ) (5 / 4) := by
  constructor
  · by_contra hlt
    push_neg at hlt
    have := strictMonoOn_scalarLogNorm (mem_Ici.2 ht.le) (mem_Ici.2 (by norm_num)) hlt
    rw [h] at this
    exact absurd this (not_lt.2 scalarLogNorm_six_fifths_lt_one.le)
  · by_contra hgt
    push_neg at hgt
    have := strictMonoOn_scalarLogNorm (mem_Ici.2 (by norm_num : (0:ℝ) ≤ 5 / 4))
      (mem_Ici.2 ht.le) hgt
    rw [h] at this
    exact absurd this (not_lt.2 one_lt_scalarLogNorm_five_fourths.le)

/-! ### The radius map is a bijection of `[0, ∞)` -/

theorem scalarLogNorm_zero : scalarLogNorm 0 = 0 := by simp [scalarLogNorm]

/-- A crude but explicit growth bound: `‖log (1 + e^r i)‖ ≥ r`. -/
theorem le_scalarLogNorm_exp (r : ℝ) : r ≤ scalarLogNorm (Real.exp r) := by
  have hlog : r ≤ Real.log (1 + Real.exp r ^ 2) / 2 := by
    have h1 : Real.exp r ^ 2 = Real.exp (2 * r) := by rw [← Real.exp_nat_mul]; ring_nf
    have h2 : Real.exp (2 * r) ≤ 1 + Real.exp r ^ 2 := by rw [h1]; linarith
    have h3 := Real.log_le_log (Real.exp_pos (2 * r)) h2
    rw [Real.log_exp] at h3
    linarith
  have hL0 : 0 ≤ Real.log (1 + Real.exp r ^ 2) := log_one_add_sq_nonneg _
  have hsq : (Real.log (1 + Real.exp r ^ 2) / 2) ^ 2 ≤ scalarLogNormSq (Real.exp r) := by
    unfold scalarLogNormSq; nlinarith [sq_nonneg (Real.arctan (Real.exp r))]
  rw [scalarLogNorm_eq_sqrt]
  calc r ≤ Real.log (1 + Real.exp r ^ 2) / 2 := hlog
    _ = Real.sqrt ((Real.log (1 + Real.exp r ^ 2) / 2) ^ 2) := by
        rw [Real.sqrt_sq (by linarith)]
    _ ≤ Real.sqrt (scalarLogNormSq (Real.exp r)) := Real.sqrt_le_sqrt hsq

/-- **The radius map is a bijection.**  For every radius `r ≥ 0` there is a
unique nonnegative parameter `t` with `‖log (1 + t i)‖ = r`.  The unit-circle
theorem is the case `r = 1`. -/
theorem existsUnique_nonneg_scalarLogNorm_eq {r : ℝ} (hr : 0 ≤ r) :
    ∃! t : ℝ, 0 ≤ t ∧ scalarLogNorm t = r := by
  have hT : (0 : ℝ) ≤ Real.exp r := (Real.exp_pos r).le
  have hmem : r ∈ Icc (scalarLogNorm 0) (scalarLogNorm (Real.exp r)) := by
    rw [scalarLogNorm_zero]
    exact ⟨hr, le_scalarLogNorm_exp r⟩
  obtain ⟨t, ht, hteq⟩ :=
    intermediate_value_Icc hT continuous_scalarLogNorm.continuousOn hmem
  refine ⟨t, ⟨ht.1, hteq⟩, ?_⟩
  rintro s ⟨hs0, hseq⟩
  exact injOn_scalarLogNorm (mem_Ici.2 hs0) (mem_Ici.2 ht.1) (hseq.trans hteq.symm)

/-! ### Lifting the scalar factor to matrix C⋆-algebras -/

/-- The unique positive scalar logarithmic factor lifts to a unitary scalar
matrix in every matrix C⋆-algebra. -/
theorem exists_scalar_log_smul_one_mem_unitary (n : ℕ) :
    ∃ t : ℝ, t ∈ Icc (6 / 5 : ℝ) (5 / 4) ∧
      Complex.log (1 + (t : ℂ) * I) • (1 : Matrix (Fin n) (Fin n) ℂ) ∈
        unitary (Matrix (Fin n) (Fin n) ℂ) := by
  obtain ⟨t, ht, hteq⟩ := exists_scalarLogNorm_eq_one_mem_Icc
  exact ⟨t, ht, smul_one_mem_unitary hteq⟩

/-! ### The polar-normalized logarithmic factor -/

theorem log_one_add_mul_I_ne_zero {t : ℝ} (ht : t ≠ 0) : Complex.log (1 + (t : ℂ) * I) ≠ 0 := by
  intro h
  have hre : (Complex.log (1 + (t : ℂ) * I)).re = Real.log (1 + t ^ 2) / 2 := by
    rw [Complex.log_re, norm_one_add_mul_I, Real.log_sqrt (by positivity)]
  have hpos : 0 < Real.log (1 + t ^ 2) := Real.log_pos (by nlinarith [sq_nonneg t, sq_abs t,
    (abs_pos.2 ht)])
  rw [h] at hre
  simp at hre
  linarith

/-- **Polar-normalized logarithmic factor.**  For *every* nonzero real
parameter, the normalized logarithm `log (1 + t i) / ‖log (1 + t i)‖` is a
unitary scalar, hence gives a unitary element of any complex star algebra (in
particular of every matrix C⋆-algebra). -/
theorem polarUnit_smul_one_mem_unitary {A : Type*} [Ring A] [StarRing A] [Algebra ℂ A]
    [StarModule ℂ A] {t : ℝ} (ht : t ≠ 0) :
    polarUnit (Complex.log (1 + (t : ℂ) * I)) • (1 : A) ∈ unitary A :=
  smul_one_mem_unitary (norm_polarUnit (log_one_add_mul_I_ne_zero ht))

/-- At the certified root the polar normalisation is the identity: the
normalized factor coincides with the logarithm itself. -/
theorem polarUnit_eq_self_of_scalarLogNorm_eq_one {t : ℝ} (h : scalarLogNorm t = 1) :
    polarUnit (Complex.log (1 + (t : ℂ) * I)) = Complex.log (1 + (t : ℂ) * I) := by
  rw [polarUnit]
  rw [show ‖Complex.log (1 + (t : ℂ) * I)‖ = 1 from h]
  norm_num

end QuantumEML