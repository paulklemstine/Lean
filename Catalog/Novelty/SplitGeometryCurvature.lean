import Mathlib

/-!
# The actual curvature phase portrait of split geometry

For the metric

`ds² = dx² / cosh² y + cosh² x · dy²`,

`SplitGeometry.KGauss_eq` computes the Gaussian curvature as

`-cosh² y - sech² x + 2 sech² x sech² y`.

The main result here is that this curvature is never positive.  It vanishes only
at the origin and is strictly negative everywhere else.  Thus the proposed
sign-changing field `sech² x - sech² y` is not the Gaussian curvature phase
portrait of this metric: the actual metric has no positive-curvature region and
its two diagonal lines are not flat (apart from their common origin).
-/

namespace SplitGeometryCurvature

open Real

/-- Squared hyperbolic secant. -/
noncomputable def sechSq (t : ℝ) : ℝ := 1 / Real.cosh t ^ 2

/-- The Gaussian curvature obtained from the orthogonal-metric curvature formula
for `ds² = dx²/cosh² y + cosh² x · dy²`. -/
noncomputable def gaussianCurvature (x y : ℝ) : ℝ :=
  -(Real.cosh y) ^ 2 - sechSq x + 2 * sechSq x * sechSq y

lemma sechSq_pos (t : ℝ) : 0 < sechSq t := by
  unfold sechSq
  positivity

lemma sechSq_le_one (t : ℝ) : sechSq t ≤ 1 := by
  unfold sechSq
  have h1 : (1 : ℝ) ≤ (Real.cosh t) ^ 2 := by
    nlinarith [Real.one_le_cosh t]
  have h2 : 0 < (Real.cosh t) ^ 2 := by positivity
  rw [div_le_one h2]
  linarith

lemma sechSq_zero : sechSq 0 = 1 := by
  simp [sechSq]

/-- The elementary inequality controlling the curvature expression.  It is
stated on the exact range `(0,1]` of squared hyperbolic secants. -/
lemma curvature_parameter_nonpos {a b : ℝ}
    (ha0 : 0 < a) (ha1 : a ≤ 1) (hb0 : 0 < b) (hb1 : b ≤ 1) :
    -(1 / b) - a + 2 * a * b ≤ 0 := by
  have hbpoly : 2 * b ^ 2 - b ≤ 1 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hb1) (add_nonneg hb0.le (by norm_num : (0 : ℝ) ≤ 1 / 2))]
  have hscale : a * (2 * b ^ 2 - b) ≤ 1 := by
    by_cases h : 2 * b ^ 2 - b ≤ 0
    · nlinarith [mul_nonpos_of_nonneg_of_nonpos ha0.le h]
    · have hnonneg : 0 ≤ 2 * b ^ 2 - b := le_of_not_ge h
      calc
        a * (2 * b ^ 2 - b) ≤ 1 * (2 * b ^ 2 - b) :=
          mul_le_mul_of_nonneg_right ha1 hnonneg
        _ ≤ 1 := by simpa using hbpoly
  have hbne : b ≠ 0 := ne_of_gt hb0
  field_simp [hbne]
  nlinarith

/-- Equality in the curvature-controlling inequality is possible only at
`a = b = 1`. -/
lemma curvature_parameter_eq_zero_iff {a b : ℝ}
    (ha0 : 0 < a) (ha1 : a ≤ 1) (hb0 : 0 < b) (hb1 : b ≤ 1) :
    -(1 / b) - a + 2 * a * b = 0 ↔ a = 1 ∧ b = 1 := by
  constructor
  · intro h
    have hmul : -1 - a * b + 2 * a * b ^ 2 = 0 := by
      field_simp at h
      nlinarith
    have hfactor : a * b * (2 * b - 1) = 1 := by nlinarith
    have htwo : 2 * b - 1 ≤ 1 := by linarith
    have hab : a * b ≤ 1 := by
      have := mul_le_mul ha1 hb1 hb0.le (by norm_num : (0 : ℝ) ≤ 1)
      simpa using this
    have hfac_nonneg : 0 ≤ 2 * b - 1 := by
      by_contra hn
      have : a * b * (2 * b - 1) < 0 :=
        mul_neg_of_pos_of_neg (mul_pos ha0 hb0) (lt_of_not_ge hn)
      linarith
    have hprodle : a * b * (2 * b - 1) ≤ 1 := by
      calc
        a * b * (2 * b - 1) ≤ 1 * (2 * b - 1) :=
          mul_le_mul_of_nonneg_right hab hfac_nonneg
        _ ≤ 1 := by simpa using htwo
    have hb : b = 1 := by
      by_contra hne
      have hblt : b < 1 := lt_of_le_of_ne hb1 hne
      have hstrict : 2 * b - 1 < 1 := by linarith
      have : a * b * (2 * b - 1) < 1 :=
        lt_of_le_of_lt
          (mul_le_mul_of_nonneg_right hab hfac_nonneg) (by simpa using hstrict)
      linarith
    subst b
    have ha : a = 1 := by
      norm_num at h
      linarith
    exact ⟨ha, rfl⟩
  · rintro ⟨rfl, rfl⟩
    norm_num

/-- Squared hyperbolic secant equals one exactly at zero. -/
theorem sechSq_eq_one_iff (x : ℝ) : sechSq x = 1 ↔ x = 0 := by
  constructor
  · intro h
    unfold sechSq at h
    have hcoshpos : 0 < Real.cosh x := Real.cosh_pos x
    have hsq : Real.cosh x ^ 2 = 1 := by
      field_simp at h
      nlinarith
    have hcosh : Real.cosh x = 1 := by nlinarith
    have habs : |x| ≤ |(0 : ℝ)| := by
      apply Real.cosh_le_cosh.mp
      simpa using hcosh.le
    have hxabs : |x| = 0 := le_antisymm (by simpa using habs) (abs_nonneg x)
    exact abs_eq_zero.mp hxabs
  · rintro rfl
    exact sechSq_zero

/-- **Global curvature theorem.** The Gaussian curvature of the split metric is
nonpositive at every point. -/
theorem gaussianCurvature_nonpos (x y : ℝ) : gaussianCurvature x y ≤ 0 := by
  unfold gaussianCurvature
  have hx0 := sechSq_pos x
  have hx1 := sechSq_le_one x
  have hy0 := sechSq_pos y
  have hy1 := sechSq_le_one y
  have hcoshy : Real.cosh y ^ 2 = 1 / sechSq y := by
    unfold sechSq
    field_simp
  rw [hcoshy]
  exact curvature_parameter_nonpos hx0 hx1 hy0 hy1

/-- The origin is the unique flat point of the split metric. -/
theorem gaussianCurvature_eq_zero_iff (x y : ℝ) :
    gaussianCurvature x y = 0 ↔ x = 0 ∧ y = 0 := by
  unfold gaussianCurvature
  have hx0 := sechSq_pos x
  have hx1 := sechSq_le_one x
  have hy0 := sechSq_pos y
  have hy1 := sechSq_le_one y
  have hcoshy : Real.cosh y ^ 2 = 1 / sechSq y := by
    unfold sechSq
    field_simp
  rw [hcoshy, curvature_parameter_eq_zero_iff hx0 hx1 hy0 hy1,
    sechSq_eq_one_iff, sechSq_eq_one_iff]

/-- Away from the origin the Gaussian curvature is strictly negative. -/
theorem gaussianCurvature_strictly_negative_off_origin {x y : ℝ}
    (h : x ≠ 0 ∨ y ≠ 0) : gaussianCurvature x y < 0 := by
  have hnonpos := gaussianCurvature_nonpos x y
  have hne : gaussianCurvature x y ≠ 0 := by
    intro hz
    have hxy := (gaussianCurvature_eq_zero_iff x y).mp hz
    rcases hxy with ⟨rfl, rfl⟩
    exact h.elim (fun hx => hx rfl) (fun hy => hy rfl)
  exact lt_of_le_of_ne hnonpos hne

/-- On either proposed diagonal phase boundary, every non-origin point actually
has strictly negative Gaussian curvature. -/
theorem gaussianCurvature_negative_on_diagonal {t : ℝ} (ht : t ≠ 0) :
    gaussianCurvature t t < 0 ∧ gaussianCurvature t (-t) < 0 := by
  constructor
  · exact gaussianCurvature_strictly_negative_off_origin (Or.inl ht)
  · exact gaussianCurvature_strictly_negative_off_origin (Or.inl ht)

/-- The proposed phase field, included to compare its zero locus with the true
curvature. -/
noncomputable def phaseField (x y : ℝ) : ℝ := sechSq x - sechSq y

lemma phaseField_origin : phaseField 0 0 = 0 := by
  simp [phaseField, sechSq_zero]

/-- The schematic phase field and the true curvature have sharply different
zero loci: their zero sets intersect only at the origin. -/
theorem phase_and_curvature_both_zero_iff (x y : ℝ) :
    phaseField x y = 0 ∧ gaussianCurvature x y = 0 ↔ x = 0 ∧ y = 0 := by
  constructor
  · rintro ⟨_, hG⟩
    exact (gaussianCurvature_eq_zero_iff x y).mp hG
  · rintro ⟨rfl, rfl⟩
    exact ⟨phaseField_origin, by norm_num [gaussianCurvature, sechSq_zero]⟩

end SplitGeometryCurvature