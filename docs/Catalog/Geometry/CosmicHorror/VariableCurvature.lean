import Mathlib
import Geometry.CosmicHorror.HyperbolicIdealArea

/-!
# Comparison estimates for ideal triangles under variable curvature

The previous files work at *constant* curvature `-κ`, where the area element is
`dx dy / (κ y²)`.  Here we allow the curvature to vary — the area element
becomes `dx dy / (K(x) y²)` for a positive function `K` — and prove the
expected comparison inequalities:

`κ₁ ≤ K ≤ κ₂  ⟹  π / κ₂ ≤ area ≤ π / κ₁`.

In words: *pinching the curvature between `-κ₂` and `-κ₁` pinches the area of an
ideal triangle between `π/κ₂` and `π/κ₁`*, and more negative curvature means a
smaller ideal triangle.  At `K` constant both bounds collapse to the exact value
`π / κ` of `idealTriangleArea_eq`, so the comparison theorem is sharp.

## Main results

* `variableSlicedArea_eq`:  slicing formula in the variable-curvature setting
  (no hypothesis on `K` is needed).
* `variableSlicedArea_le_of_le` / `le_variableSlicedArea_of_le`:  the two
  comparison inequalities.
* `variableSlicedArea_pinched`:  the two-sided pinching statement.
* `variableSlicedArea_const`:  sharpness — for constant curvature the bounds are
  attained.
-/

namespace CosmicHorrorGeometry

open Real Set MeasureTheory Filter Topology

/-- The hyperbolic area of a vertically sliced region for the *variable*
curvature profile `-K(x)`, whose area element is `dx dy / (K(x) y²)`. -/
noncomputable def variableSlicedArea (K low : ℝ → ℝ) (a b : ℝ) : ℝ :=
  ∫ x in a..b, ∫ y in Ioi (low x), (K x * y ^ 2)⁻¹

/-- Slicing in the variable-curvature setting.  Note that no positivity or
measurability assumption on `K` is needed: the identity
`∫_{c}^{∞} dy/(K y²) = 1/(K c)` holds for `K = 0` as well, both sides being
zero under Lean's junk-value convention for `0⁻¹`. -/
theorem variableSlicedArea_eq {a b : ℝ} (hab : a < b) (K low : ℝ → ℝ)
    (hlow : ∀ x ∈ Ioo a b, 0 < low x) :
    variableSlicedArea K low a b = ∫ x in a..b, (K x * low x)⁻¹ := by
  have hae : ∀ᵐ x : ℝ, x ∈ Set.uIoc a b →
      (∫ y in Ioi (low x), (K x * y ^ 2)⁻¹) = (K x * low x)⁻¹ := by
    have hne : ∀ᵐ x : ℝ, x ≠ b := by
      have hb : volume {b} = 0 := by simp
      filter_upwards [MeasureTheory.compl_mem_ae_iff.2 hb] with x hx
      simpa using hx
    filter_upwards [hne] with x hx hmem
    rw [Set.uIoc_of_le hab.le] at hmem
    have hpos := hlow x ⟨hmem.1, lt_of_le_of_ne hmem.2 hx⟩
    have hsplit : ∀ y : ℝ, (K x * y ^ 2)⁻¹ = (K x)⁻¹ * (y ^ 2)⁻¹ := fun y => mul_inv _ _
    simp_rw [hsplit]
    rw [MeasureTheory.integral_const_mul, integral_Ioi_inv_sq hpos, mul_inv]
  rw [variableSlicedArea, intervalIntegral.integral_congr_ae hae]

/-- Integrability of the variable-curvature density of an ideal triangle. -/
theorem intervalIntegrable_variable_density {a b : ℝ} {K : ℝ → ℝ}
    (hK : ContinuousOn K (uIcc a b)) (hKne : ∀ x ∈ uIcc a b, K x ≠ 0) :
    IntervalIntegrable (fun x => (K x)⁻¹ * (chordHeight a b x)⁻¹) volume a b :=
  (intervalIntegrable_invSqrtChord a b).continuousOn_mul (hK.inv₀ hKne)

/-- The reference integral at constant curvature. -/
theorem integral_const_curvature {a b κ : ℝ} (hab : a < b) :
    ∫ x in a..b, (κ⁻¹ * (chordHeight a b x)⁻¹) = Real.pi / κ := by
  rw [intervalIntegral.integral_const_mul, integral_invSqrtChord hab, div_eq_inv_mul]

/-- **Curvature comparison, upper bound.**  If the curvature magnitude is at
least `κ₁ > 0` throughout, the ideal triangle has area at most `π / κ₁`. -/
theorem variableSlicedArea_le_of_le {a b κ₁ : ℝ} {K : ℝ → ℝ} (hab : a < b) (hκ : 0 < κ₁)
    (hK : ContinuousOn K (uIcc a b)) (hle : ∀ x ∈ uIcc a b, κ₁ ≤ K x) :
    variableSlicedArea K (chordHeight a b) a b ≤ Real.pi / κ₁ := by
  have hKpos : ∀ x ∈ uIcc a b, 0 < K x := fun x hx => lt_of_lt_of_le hκ (hle x hx)
  have hKne : ∀ x ∈ uIcc a b, K x ≠ 0 := fun x hx => (hKpos x hx).ne'
  rw [variableSlicedArea_eq hab _ _ (fun x hx => chordHeight_pos hx)]
  have hrw : ∀ x : ℝ, (K x * chordHeight a b x)⁻¹ = (K x)⁻¹ * (chordHeight a b x)⁻¹ :=
    fun x => mul_inv _ _
  simp_rw [hrw]
  rw [← integral_const_curvature (κ := κ₁) hab]
  refine intervalIntegral.integral_mono_on hab.le
    (intervalIntegrable_variable_density hK hKne)
    (intervalIntegrable_variable_density continuousOn_const (fun x _ => hκ.ne')) ?_
  intro x hx
  have hxu : x ∈ uIcc a b := by rwa [Set.uIcc_of_le hab.le]
  have hc : 0 ≤ (chordHeight a b x)⁻¹ := by
    unfold chordHeight; positivity
  have hinv : (K x)⁻¹ ≤ κ₁⁻¹ := inv_anti₀ hκ (hle x hxu)
  exact mul_le_mul_of_nonneg_right hinv hc

/-- **Curvature comparison, lower bound.**  If the curvature magnitude is at
most `κ₂` throughout (and positive), the ideal triangle has area at least
`π / κ₂`. -/
theorem le_variableSlicedArea_of_le {a b κ₂ : ℝ} {K : ℝ → ℝ} (hab : a < b) (hκ : 0 < κ₂)
    (hK : ContinuousOn K (uIcc a b)) (hpos : ∀ x ∈ uIcc a b, 0 < K x)
    (hle : ∀ x ∈ uIcc a b, K x ≤ κ₂) :
    Real.pi / κ₂ ≤ variableSlicedArea K (chordHeight a b) a b := by
  have hKne : ∀ x ∈ uIcc a b, K x ≠ 0 := fun x hx => (hpos x hx).ne'
  rw [variableSlicedArea_eq hab _ _ (fun x hx => chordHeight_pos hx)]
  have hrw : ∀ x : ℝ, (K x * chordHeight a b x)⁻¹ = (K x)⁻¹ * (chordHeight a b x)⁻¹ :=
    fun x => mul_inv _ _
  simp_rw [hrw]
  rw [← integral_const_curvature (κ := κ₂) hab]
  refine intervalIntegral.integral_mono_on hab.le
    (intervalIntegrable_variable_density continuousOn_const (fun x _ => hκ.ne'))
    (intervalIntegrable_variable_density hK hKne) ?_
  intro x hx
  have hxu : x ∈ uIcc a b := by rwa [Set.uIcc_of_le hab.le]
  have hc : 0 ≤ (chordHeight a b x)⁻¹ := by
    unfold chordHeight; positivity
  have hinv : κ₂⁻¹ ≤ (K x)⁻¹ := inv_anti₀ (hpos x hxu) (hle x hxu)
  exact mul_le_mul_of_nonneg_right hinv hc

/-- **Pinching.**  Curvature pinched between `-κ₂` and `-κ₁` pinches the ideal
triangle area between `π/κ₂` and `π/κ₁`. -/
theorem variableSlicedArea_pinched {a b κ₁ κ₂ : ℝ} {K : ℝ → ℝ} (hab : a < b) (hκ : 0 < κ₁)
    (hK : ContinuousOn K (uIcc a b)) (hlo : ∀ x ∈ uIcc a b, κ₁ ≤ K x)
    (hhi : ∀ x ∈ uIcc a b, K x ≤ κ₂) :
    Real.pi / κ₂ ≤ variableSlicedArea K (chordHeight a b) a b ∧
      variableSlicedArea K (chordHeight a b) a b ≤ Real.pi / κ₁ := by
  have hκ₂ : 0 < κ₂ := by
    have h1 : a ∈ uIcc a b := left_mem_uIcc
    exact lt_of_lt_of_le (lt_of_lt_of_le hκ (hlo a h1)) (hhi a h1)
  refine ⟨le_variableSlicedArea_of_le hab hκ₂ hK
    (fun x hx => lt_of_lt_of_le hκ (hlo x hx)) hhi,
    variableSlicedArea_le_of_le hab hκ hK hlo⟩

/-- **Sharpness.**  At constant curvature the comparison bounds are attained:
the variable-curvature area functional specialises to the exact value `π / κ`.
Hence neither inequality of `variableSlicedArea_pinched` can be improved. -/
theorem variableSlicedArea_const {a b κ : ℝ} (hab : a < b) :
    variableSlicedArea (fun _ => κ) (chordHeight a b) a b = Real.pi / κ := by
  rw [variableSlicedArea_eq hab _ _ (fun x hx => chordHeight_pos hx)]
  have hrw : ∀ x : ℝ, (κ * chordHeight a b x)⁻¹ = κ⁻¹ * (chordHeight a b x)⁻¹ :=
    fun x => mul_inv _ _
  simp_rw [hrw]
  exact integral_const_curvature hab

/-- The variable-curvature area functional agrees with the constant-curvature
one of `HyperbolicIdealArea.lean`. -/
theorem variableSlicedArea_eq_slicedArea {a b κ : ℝ} (hab : a < b) :
    variableSlicedArea (fun _ => κ) (chordHeight a b) a b
      = slicedArea κ a b (chordHeight a b) := by
  rw [variableSlicedArea_const hab, idealTriangleArea_eq hab]

end CosmicHorrorGeometry