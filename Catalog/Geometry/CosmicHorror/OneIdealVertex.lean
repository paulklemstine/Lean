import Mathlib
import Geometry.CosmicHorror.HyperbolicIdealArea

/-!
# Gauss–Bonnet with one ideal vertex, derived from the metric

This file carries the programme of `HyperbolicIdealArea.lean` one step further.
There we computed the area of a *fully* ideal triangle (all three angles `0`).
Here we compute the area of a hyperbolic triangle with **one** ideal vertex and
two genuine finite vertices, and we do not postulate the interior angles: we
*define* them as angles between the tangent vectors of the two geodesic sides
and prove the Gauss–Bonnet identity

`area = (π - (α + β + 0)) / κ = hyperbolicArea κ α β 0`.

Because the half-plane metric `(dx² + dy²)/(κ y²)` is a pointwise positive
multiple of the Euclidean one, hyperbolic angles coincide with Euclidean
angles; this is recorded formally by `angleBetween_smul_left` and
`angleBetween_smul_right`, which say the angle functional is invariant under
positive rescaling of either tangent vector, hence under conformal change of
metric.

## The configuration

Fix `0 < φ < θ < π`.  The triangle has

* geodesic sides the two vertical rays `x = cos θ` and `x = cos φ` (these are
  half-plane geodesics), and the unit semicircle `|z| = 1` (also a geodesic);
* vertices `(cos θ, sin θ)`, `(cos φ, sin φ)` and the ideal point `∞`.

## Main results

* `angleBetween_vertical_circleRight`, `angleBetween_vertical_circleLeft`:  the
  interior angles are `π - θ` and `φ`.
* `oneIdealVertex_area`:  the hyperbolic area equals `(θ - φ)/κ`.  The result is
  proved for `0 ≤ φ < θ ≤ π`, so it covers one, two (`twoIdealVertices_area`)
  and three (`threeIdealVertices_area`) ideal vertices in one statement.
* `oneIdealVertex_gauss_bonnet`:  the area equals `hyperbolicArea κ α β 0`,
  the algebraic Gauss–Bonnet invariant evaluated at the two computed angles.
* `oneIdealVertex_angles_pos`:  both finite angles are *strictly* positive, so
  a triangle with a finite vertex is never ideal — angle sum `0` really does
  require adjoining the boundary.
* `oneIdealVertex_area_lt_ideal`:  consequently its area is strictly below the
  ideal maximum `π / κ`.
-/

namespace CosmicHorrorGeometry

open Real Set MeasureTheory Filter Topology

/-! ### Euclidean = hyperbolic angles -/

/-- The angle between two nonzero plane vectors.  Since the half-plane metric is
conformal to the Euclidean metric, this is also the hyperbolic angle. -/
noncomputable def angleBetween (u v : ℝ × ℝ) : ℝ :=
  Real.arccos ((u.1 * v.1 + u.2 * v.2) /
    (Real.sqrt (u.1 ^ 2 + u.2 ^ 2) * Real.sqrt (v.1 ^ 2 + v.2 ^ 2)))

/-- Rescaling a tangent vector by a positive factor does not change the angle.
This is the formal content of "the conformal factor `1/(κ y²)` is invisible to
angles". -/
theorem angleBetween_smul_left (c : ℝ) (hc : 0 < c) (u v : ℝ × ℝ) :
    angleBetween (c * u.1, c * u.2) v = angleBetween u v := by
  unfold angleBetween
  have h : Real.sqrt ((c * u.1) ^ 2 + (c * u.2) ^ 2)
      = c * Real.sqrt (u.1 ^ 2 + u.2 ^ 2) := by
    rw [show (c * u.1) ^ 2 + (c * u.2) ^ 2 = c ^ 2 * (u.1 ^ 2 + u.2 ^ 2) by ring,
      Real.sqrt_mul (by positivity), Real.sqrt_sq hc.le]
  rw [h]
  congr 1
  rw [show c * u.1 * v.1 + c * u.2 * v.2 = c * (u.1 * v.1 + u.2 * v.2) by ring]
  rw [mul_assoc]
  exact mul_div_mul_left _ _ hc.ne'

/-- Symmetric version of `angleBetween_smul_left`. -/
theorem angleBetween_smul_right (c : ℝ) (hc : 0 < c) (u v : ℝ × ℝ) :
    angleBetween u (c * v.1, c * v.2) = angleBetween u v := by
  unfold angleBetween
  have h : Real.sqrt ((c * v.1) ^ 2 + (c * v.2) ^ 2)
      = c * Real.sqrt (v.1 ^ 2 + v.2 ^ 2) := by
    rw [show (c * v.1) ^ 2 + (c * v.2) ^ 2 = c ^ 2 * (v.1 ^ 2 + v.2 ^ 2) by ring,
      Real.sqrt_mul (by positivity), Real.sqrt_sq hc.le]
  rw [h]
  congr 1
  rw [show u.1 * (c * v.1) + u.2 * (c * v.2) = c * (u.1 * v.1 + u.2 * v.2) by ring,
    show Real.sqrt (u.1 ^ 2 + u.2 ^ 2) * (c * Real.sqrt (v.1 ^ 2 + v.2 ^ 2))
      = c * (Real.sqrt (u.1 ^ 2 + u.2 ^ 2) * Real.sqrt (v.1 ^ 2 + v.2 ^ 2)) by ring]
  exact mul_div_mul_left _ _ hc.ne'

/-- The upward tangent vector of a vertical geodesic. -/
def verticalTangent : ℝ × ℝ := (0, 1)

/-- The tangent vector, pointing in the direction of increasing `x`, of the unit
semicircle geodesic at the point `(cos θ, sin θ)`. -/
noncomputable def circleTangentRight (θ : ℝ) : ℝ × ℝ := (Real.sin θ, -Real.cos θ)

/-- The tangent vector, pointing in the direction of decreasing `x`, of the unit
semicircle geodesic at the point `(cos φ, sin φ)`. -/
noncomputable def circleTangentLeft (φ : ℝ) : ℝ × ℝ := (-Real.sin φ, Real.cos φ)

/-- **Interior angle at the left finite vertex** is `π - θ`. -/
theorem angleBetween_vertical_circleRight {θ : ℝ} (h0 : 0 ≤ θ) (hpi : θ ≤ π) :
    angleBetween verticalTangent (circleTangentRight θ) = π - θ := by
  unfold angleBetween verticalTangent circleTangentRight
  have hs : Real.sqrt ((Real.sin θ) ^ 2 + (-Real.cos θ) ^ 2) = 1 := by
    rw [show (Real.sin θ) ^ 2 + (-Real.cos θ) ^ 2 = 1 by
      rw [neg_pow]; simp [Real.sin_sq_add_cos_sq]]
    exact Real.sqrt_one
  simp only [hs]
  rw [show ((0 : ℝ) ^ 2 + (1 : ℝ) ^ 2) = 1 by ring, Real.sqrt_one]
  rw [show (0 : ℝ) * Real.sin θ + 1 * -Real.cos θ = -Real.cos θ by ring]
  rw [mul_one, div_one, Real.arccos_neg, Real.arccos_cos h0 hpi]

/-- **Interior angle at the right finite vertex** is `φ`. -/
theorem angleBetween_vertical_circleLeft {φ : ℝ} (h0 : 0 ≤ φ) (hpi : φ ≤ π) :
    angleBetween verticalTangent (circleTangentLeft φ) = φ := by
  unfold angleBetween verticalTangent circleTangentLeft
  have hs : Real.sqrt ((-Real.sin φ) ^ 2 + (Real.cos φ) ^ 2) = 1 := by
    rw [show (-Real.sin φ) ^ 2 + (Real.cos φ) ^ 2 = 1 by
      rw [neg_pow]; simp [Real.sin_sq_add_cos_sq]]
    exact Real.sqrt_one
  simp only [hs]
  rw [show ((0 : ℝ) ^ 2 + (1 : ℝ) ^ 2) = 1 by ring, Real.sqrt_one]
  rw [show (0 : ℝ) * -Real.sin φ + 1 * Real.cos φ = Real.cos φ by ring]
  rw [mul_one, div_one, Real.arccos_cos h0 hpi]

/-! ### The unit semicircle as the lower boundary -/

lemma chordHeight_neg_one_one (x : ℝ) : chordHeight (-1) 1 x = Real.sqrt (1 - x ^ 2) := by
  unfold chordHeight
  congr 1
  ring

lemma arcsinChord_neg_one_one (x : ℝ) : arcsinChord (-1) 1 x = Real.arcsin x := by
  unfold arcsinChord
  norm_num

lemma arcsin_cos_of_mem {t : ℝ} (h0 : 0 ≤ t) (hpi : t ≤ π) :
    Real.arcsin (Real.cos t) = π / 2 - t := by
  rw [← Real.sin_pi_div_two_sub t]
  exact Real.arcsin_sin (by linarith [Real.pi_pos]) (by linarith)

/-! ### The area of a triangle with one ideal vertex -/

/-- The hyperbolic area, at curvature `-κ`, of the triangle with vertices
`(cos θ, sin θ)`, `(cos φ, sin φ)` and `∞`, bounded by the two vertical
geodesics and the unit semicircle. -/
noncomputable def oneIdealVertexArea (κ θ φ : ℝ) : ℝ :=
  slicedArea κ (Real.cos θ) (Real.cos φ) (chordHeight (-1) 1)

lemma cos_lt_cos_of {φ θ : ℝ} (h0 : 0 ≤ φ) (hlt : φ < θ) (hpi : θ ≤ π) :
    Real.cos θ < Real.cos φ :=
  Real.cos_lt_cos_of_nonneg_of_le_pi h0 hpi hlt

/-- **The area computation.**  The triangle with at least one ideal vertex has
area `(θ - φ)/κ`.  The hypotheses `0 ≤ φ < θ ≤ π` allow the two "finite"
vertices to sit *on* the boundary as well (`φ = 0` or `θ = π`), so this single
statement covers triangles with one, two or three ideal vertices. -/
theorem oneIdealVertex_area {κ θ φ : ℝ} (hφ : 0 ≤ φ) (hφθ : φ < θ) (hθ : θ ≤ π) :
    oneIdealVertexArea κ θ φ = (θ - φ) / κ := by
  have hcc : Real.cos θ < Real.cos φ := cos_lt_cos_of hφ hφθ hθ
  have hlb : -1 ≤ Real.cos θ := Real.neg_one_le_cos θ
  have hub : Real.cos φ ≤ 1 := Real.cos_le_one φ
  have hsub : Ioo (Real.cos θ) (Real.cos φ) ⊆ Ioo (-1 : ℝ) 1 := fun x hx =>
    ⟨lt_of_le_of_lt hlb hx.1, lt_of_lt_of_le hx.2 hub⟩
  rw [oneIdealVertexArea, slicedArea_eq hcc _ (fun x hx => chordHeight_pos (hsub hx))]
  congr 1
  rw [integral_invSqrtChord_subinterval (by norm_num : (-1 : ℝ) < 1) hlb hcc hub,
    arcsinChord_neg_one_one, arcsinChord_neg_one_one,
    arcsin_cos_of_mem hφ (by linarith), arcsin_cos_of_mem (by linarith) hθ]
  ring

/-- **Gauss–Bonnet with one ideal vertex, derived from the Riemannian area
element.**  The area of the triangle equals the algebraic invariant
`hyperbolicArea κ α β 0` evaluated at the two interior angles that were
*computed*, not assumed. -/
theorem oneIdealVertex_gauss_bonnet {κ θ φ : ℝ} (hφ : 0 ≤ φ) (hφθ : φ < θ) (hθ : θ ≤ π) :
    oneIdealVertexArea κ θ φ
      = hyperbolicArea κ (angleBetween verticalTangent (circleTangentRight θ))
          (angleBetween verticalTangent (circleTangentLeft φ)) 0 := by
  rw [oneIdealVertex_area hφ hφθ hθ,
    angleBetween_vertical_circleRight (by linarith) hθ,
    angleBetween_vertical_circleLeft hφ (by linarith),
    hyperbolicArea]
  congr 1
  ring

/-- **Finite vertices carry strictly positive angles.**  Both interior angles of
the triangle with one ideal vertex are `> 0`; the ideal (all-angles-zero)
configuration is therefore never realised by a triangle with a finite vertex. -/
theorem oneIdealVertex_angles_pos {θ φ : ℝ} (hφ : 0 < φ) (hφθ : φ < θ) (hθ : θ < π) :
    0 < angleBetween verticalTangent (circleTangentRight θ) ∧
      0 < angleBetween verticalTangent (circleTangentLeft φ) := by
  rw [angleBetween_vertical_circleRight (by linarith) hθ.le,
    angleBetween_vertical_circleLeft hφ.le (by linarith)]
  exact ⟨by linarith, hφ⟩

/-- The angle triple of such a triangle is admissible in the sense of
`IdealTriangle.lean`. -/
theorem oneIdealVertex_admissible {θ φ : ℝ} (hφ : 0 ≤ φ) (hφθ : φ < θ) (hθ : θ ≤ π) :
    AdmissibleAngles (angleBetween verticalTangent (circleTangentRight θ))
      (angleBetween verticalTangent (circleTangentLeft φ)) 0 := by
  rw [angleBetween_vertical_circleRight (by linarith) hθ,
    angleBetween_vertical_circleLeft hφ (by linarith)]
  exact ⟨by linarith, hφ, le_rfl, by linarith⟩

/-- **Two ideal vertices.**  Taking `φ = 0` places the right-hand vertex on the
boundary point `1`, so the triangle has exactly one finite vertex; its area is
`θ/κ`, in agreement with Gauss–Bonnet for the angle triple `(π - θ, 0, 0)`. -/
theorem twoIdealVertices_area {κ θ : ℝ} (hθ0 : 0 < θ) (hθ : θ ≤ π) :
    oneIdealVertexArea κ θ 0
      = hyperbolicArea κ (angleBetween verticalTangent (circleTangentRight θ)) 0 0 := by
  rw [oneIdealVertex_gauss_bonnet le_rfl hθ0 hθ,
    angleBetween_vertical_circleLeft le_rfl (by linarith [Real.pi_pos])]

/-- **Three ideal vertices.**  Taking `φ = 0` and `θ = π` degenerates the two
finite vertices onto the boundary points `1` and `-1`, and the area computation
returns the ideal value `π / κ` of `idealTriangleArea_eq`. -/
theorem threeIdealVertices_area (κ : ℝ) : oneIdealVertexArea κ π 0 = Real.pi / κ := by
  rw [oneIdealVertex_area le_rfl Real.pi_pos le_rfl]
  ring_nf

/-- **Strict subideality.**  A triangle with two finite vertices has area
strictly less than the ideal maximum `π / κ`. -/
theorem oneIdealVertex_area_lt_ideal {κ θ φ : ℝ} (hκ : 0 < κ) (hφ : 0 < φ) (hφθ : φ < θ)
    (hθ : θ ≤ π) : oneIdealVertexArea κ θ φ < Real.pi / κ := by
  rw [oneIdealVertex_area hφ.le hφθ hθ]
  exact (div_lt_div_iff_of_pos_right hκ).2 (by linarith)

/-- **Degeneration to the ideal triangle, geometrically.**  As the two finite
vertices slide out to the boundary points `-1` and `1` (that is, `θ → π` and
`φ → 0`), the area increases to the ideal value `π / κ`. -/
theorem tendsto_oneIdealVertex_area {κ : ℝ} :
    Tendsto (fun p : ℝ × ℝ => oneIdealVertexArea κ p.1 p.2)
      (𝓝[{p : ℝ × ℝ | 0 ≤ p.2 ∧ p.2 < p.1 ∧ p.1 ≤ π}] (π, 0)) (𝓝 (Real.pi / κ)) := by
  have hc : Continuous (fun p : ℝ × ℝ => (p.1 - p.2) / κ) := by fun_prop
  have h1 : Tendsto (fun p : ℝ × ℝ => (p.1 - p.2) / κ)
      (𝓝[{p : ℝ × ℝ | 0 ≤ p.2 ∧ p.2 < p.1 ∧ p.1 ≤ π}] (π, 0)) (𝓝 (Real.pi / κ)) := by
    have := (hc.tendsto (π, 0)).mono_left
      (nhdsWithin_le_nhds (s := {p : ℝ × ℝ | 0 ≤ p.2 ∧ p.2 < p.1 ∧ p.1 ≤ π}))
    simpa using this
  refine h1.congr' ?_
  filter_upwards [self_mem_nhdsWithin] with p hp
  exact (oneIdealVertex_area hp.1 hp.2.1 hp.2.2).symm

end CosmicHorrorGeometry