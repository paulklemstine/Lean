import MachineLearning.QRResidual.Capstone

/-!
# The exact size of a one-feature `R²` lift, and its ceiling

`ResidualLift` proved that augmenting a fit by one feature can only help, and that it
strictly helps exactly when the baseline residual is non-orthogonal to the feature.  This
file computes the lift *exactly* and bounds it:

* `rsq_line_eq` — **the exact lift**: `R²(after) = R²(before) + ⟨r,v⟩² / (‖v‖²·TSS)`.
* `lift_eq_corr_sq_mul` — equivalently, the lift is `ρ² · (1 − R²(before))` where `ρ` is
  the sample correlation between the baseline residual and the feature.  A reported lift
  therefore *measures* a correlation, and cannot exceed the unexplained variance.
* `lift_le_one_sub_rsqOf`, `rsq_line_le_one` — the ceiling: no single feature can push
  `R²` above `1`, and the lift is at most the unexplained fraction `1 − R²(before)`.
* `footprint_lift_exact` — the same identities for the QR footprint feature of
  experiment 477.

The `LabNotes` section instantiates the correlation formula on the reported numbers.
-/

namespace QRResidual

open Finset

variable {ι : Type*} [Fintype ι]

/-! ## Cauchy–Schwarz for the sample inner product -/

/-- Cauchy–Schwarz: `⟨u,v⟩² ≤ ‖u‖²·‖v‖²` for the sample inner product. -/
theorem dot_sq_le_sqNorm_mul (u v : ι → ℝ) : dot u v ^ 2 ≤ sqNorm u * sqNorm v := by
  simpa [dot, sqNorm] using Finset.sum_mul_sq_le_sq_mul_sq (univ : Finset ι) u v

/-! ## The exact lift -/

/-- **The exact one-feature lift.**  Augmenting the fit `g` by the feature `v` raises the
coefficient of determination by exactly `⟨y−g, v⟩² / (‖v‖²·TSS)`. -/
theorem rsq_line_eq {y g v : ι → ℝ} (htss : 0 < tss y) (hv : sqNorm v ≠ 0) :
    rsq y {h : ι → ℝ | ∃ t : ℝ, h = g + t • v}
      = rsqOf y g + dot (y - g) v ^ 2 / (sqNorm v * tss y) := by
  rw [rsq, rss_line_eq hv, rsqOf]
  have hv' : sqNorm v ≠ 0 := hv
  field_simp
  ring

/-- The lift is at most the unexplained variance fraction `1 − R²(before)`: a single
feature can never explain more than what is left. -/
theorem lift_le_one_sub_rsqOf {y g v : ι → ℝ} (htss : 0 < tss y) (hv : sqNorm v ≠ 0) :
    dot (y - g) v ^ 2 / (sqNorm v * tss y) ≤ 1 - rsqOf y g := by
  have hcs := dot_sq_le_sqNorm_mul (y - g) v
  have hvpos : 0 < sqNorm v := lt_of_le_of_ne (sqNorm_nonneg v) (Ne.symm hv)
  rw [rsqOf]
  have hgoal : 1 - (1 - sqNorm (y - g) / tss y) = sqNorm (y - g) / tss y := by ring
  rw [hgoal, div_le_div_iff₀ (by positivity) htss]
  nlinarith [sqNorm_nonneg (y - g)]

/-- **Ceiling.**  The coefficient of determination after augmenting by one feature never
exceeds `1`. -/
theorem rsq_line_le_one {y g v : ι → ℝ} (htss : 0 < tss y) (hv : sqNorm v ≠ 0) :
    rsq y {h : ι → ℝ | ∃ t : ℝ, h = g + t • v} ≤ 1 := by
  rw [rsq_line_eq htss hv]
  have := lift_le_one_sub_rsqOf (y := y) (g := g) (v := v) htss hv
  linarith

/-! ## The lift as a squared correlation -/

/-- The sample correlation between the baseline residual `y − g` and the feature `v`. -/
noncomputable def residualCorr (y g v : ι → ℝ) : ℝ :=
  dot (y - g) v / Real.sqrt (sqNorm (y - g) * sqNorm v)

/-- **The lift is a squared correlation.**  The `R²` gain from a feature equals the squared
sample correlation between the baseline residual and the feature, times the unexplained
variance fraction.  A reported lift is therefore a direct measurement of that correlation.
-/
theorem lift_eq_corr_sq_mul {y g v : ι → ℝ} (htss : 0 < tss y) (hv : sqNorm v ≠ 0)
    (hr : sqNorm (y - g) ≠ 0) :
    dot (y - g) v ^ 2 / (sqNorm v * tss y)
      = residualCorr y g v ^ 2 * (1 - rsqOf y g) := by
  have hvpos : 0 < sqNorm v := lt_of_le_of_ne (sqNorm_nonneg v) (Ne.symm hv)
  have hrpos : 0 < sqNorm (y - g) := lt_of_le_of_ne (sqNorm_nonneg (y - g)) (Ne.symm hr)
  have hsq : Real.sqrt (sqNorm (y - g) * sqNorm v) ^ 2 = sqNorm (y - g) * sqNorm v :=
    Real.sq_sqrt (by positivity)
  rw [residualCorr, div_pow, hsq, rsqOf]
  have hgoal : 1 - (1 - sqNorm (y - g) / tss y) = sqNorm (y - g) / tss y := by ring
  rw [hgoal]
  field_simp

/-! ## Specialisation to the QR footprint feature -/

/-- **The exact `R²` lift of the QR footprint dial.**  For any sample of moduli and any
baseline fit, the footprint feature `Σ_{QR p ≤ B} 2/p` raises `R²` by exactly the squared
residual correlation times the unexplained variance. -/
theorem footprint_lift_exact (B : ℕ) (Nsam : ι → ℤ) (y g : ι → ℝ) (htss : 0 < tss y)
    (hv : sqNorm (footprintFeature B Nsam) ≠ 0) (hr : sqNorm (y - g) ≠ 0) :
    rsq y {h : ι → ℝ | ∃ t : ℝ, h = g + t • footprintFeature B Nsam}
      = rsqOf y g + residualCorr y g (footprintFeature B Nsam) ^ 2 * (1 - rsqOf y g) := by
  rw [rsq_line_eq htss hv, lift_eq_corr_sq_mul htss hv hr]

/-- The footprint dial can never take `R²` above `1`, whatever the baseline. -/
theorem footprint_rsq_le_one (B : ℕ) (Nsam : ι → ℤ) (y g : ι → ℝ) (htss : 0 < tss y)
    (hv : sqNorm (footprintFeature B Nsam) ≠ 0) :
    rsq y {h : ι → ℝ | ∃ t : ℝ, h = g + t • footprintFeature B Nsam} ≤ 1 :=
  rsq_line_le_one htss hv

section LabNotes

/-! The reported out-of-sample scores of experiment 477 at `u = 2.5` are
`R²(before) = 0.3927` and `R²(after) = 0.5691`, a lift of `0.1764`.  By
`lift_eq_corr_sq_mul` this pins the squared residual–feature correlation to
`0.1764 / (1 − 0.3927) = 1764/6073 ≈ 0.29046`, i.e. `|ρ| ≈ 0.5389`; at `u = 3.5`
(`0.2063 → 0.3078`) it is `1015/7937 ≈ 0.12788`, i.e. `|ρ| ≈ 0.3576`.  Both are kernel
checked below as exact rational identities. -/

example : (5691 - 3927 : ℚ) / 10000 = 1764 / 10000 := by norm_num

example : ((5691 - 3927 : ℚ) / 10000) / (1 - 3927 / 10000) = 1764 / 6073 := by norm_num

example : ((3078 - 2063 : ℚ) / 10000) / (1 - 2063 / 10000) = 1015 / 7937 := by norm_num

/-- The implied correlations are strictly between `0` and `1`, so the lift is consistent
with the ceiling `lift_le_one_sub_rsqOf` — the reported numbers are not impossible. -/
example : (0 : ℚ) < 1764 / 6073 ∧ (1764 : ℚ) / 6073 < 1 := by norm_num

end LabNotes

end QRResidual