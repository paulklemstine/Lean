import Mathlib
import Geometry.CosmicHorror.IdealTriangle

/-!
# From angle data to a Riemannian area integral: ideal triangles in the half-plane

The companion file `Geometry/CosmicHorror/IdealTriangle.lean` studies the
*algebraic* Gauss–Bonnet invariant

`hyperbolicArea κ α β γ = (π - (α + β + γ)) / κ`

as a function of angle data only.  The present file replaces the angle data by
an honest Riemannian computation in the **upper half-plane model** of the
hyperbolic plane of constant curvature `-κ`, whose area element is

`dA = dx dy / (κ y²)`.

## Main results

* `hasDerivAt_arcsinChord` / `intervalIntegrable_invSqrtChord`:  the analytic
  core, an explicit antiderivative for the chordal density
  `x ↦ (√((x - a)(b - x)))⁻¹` together with its (improper) integrability.
* `integral_invSqrtChord`:  `∫ x in a..b, (√((x - a)(b - x)))⁻¹ = π`.
  This is the whole geometry of an ideal triangle compressed into one identity.
* `integral_Ioi_inv_sq`:  the vertical fibre integral `∫_{c}^{∞} y⁻² dy = c⁻¹`,
  i.e. the hyperbolic length of the fibre measure above a point.
* `idealTriangleArea_eq`:  **the area of the ideal triangle with vertices
  `a < b` on the real line and `∞` equals `π / κ`**, computed from the area
  element by Fubini-style slicing.  Together with
  `idealTriangleArea_eq_hyperbolicArea` this *derives* the value that
  `IdealTriangle.lean` obtained from Gauss–Bonnet with all angles `0`.
* `idealPolygonArea_eq`:  the ideal `(m+2)`-gon with finite vertices
  `v 0 < ⋯ < v m` and last vertex `∞` has area `m · π / κ = ((n - 2) π)/κ`.
* `truncatedIdealTriangleArea_lt` and `tendsto_truncatedIdealTriangleArea`:
  the degeneration statement — the compact exhaustion of an ideal triangle by
  truncated regions has strictly smaller area, converging to `π / κ`.
* `angles_tendsto_zero_of_area_tendsto_max`:  conversely, on the angle side, a
  sequence of admissible triangles whose Gauss–Bonnet area tends to the maximum
  `π / κ` must have *all three* angles tending to `0`; the ideal triangle is the
  unique limiting shape.
-/

namespace CosmicHorrorGeometry

open Real Set MeasureTheory intervalIntegral Filter Topology

/-! ### The analytic core: the chordal density and its antiderivative -/

/-- The antiderivative of the chordal density on the interval `[a, b]`:
`x ↦ arcsin ((2x - a - b)/(b - a))`, normalised so that it runs from `-π/2` to
`π/2`. -/
noncomputable def arcsinChord (a b x : ℝ) : ℝ := Real.arcsin ((2 * x - a - b) / (b - a))

/-- The hyperbolic lower boundary of the ideal triangle with real vertices
`a < b`: the euclidean semicircle with diameter `[a, b]`, which is the geodesic
of the half-plane model joining the two boundary points. -/
noncomputable def chordHeight (a b x : ℝ) : ℝ := Real.sqrt ((x - a) * (b - x))

lemma chordHeight_pos {a b x : ℝ} (hx : x ∈ Ioo a b) : 0 < chordHeight a b x := by
  obtain ⟨hxa, hxb⟩ := hx
  exact Real.sqrt_pos.2 (by nlinarith)

/-- **Key derivative computation.**  On the open interval `(a, b)` the function
`arcsinChord a b` is an antiderivative of the reciprocal semicircle height. -/
theorem hasDerivAt_arcsinChord {a b x : ℝ} (hx : x ∈ Ioo a b) :
    HasDerivAt (arcsinChord a b) (chordHeight a b x)⁻¹ x := by
  obtain ⟨hxa, hxb⟩ := hx
  have hba : 0 < b - a := by linarith
  set u : ℝ := (2 * x - a - b) / (b - a) with hu
  have hu1 : u ≠ 1 := by
    intro h
    rw [hu, div_eq_one_iff_eq hba.ne'] at h
    linarith
  have hu2 : u ≠ -1 := by
    intro h
    rw [hu, div_eq_iff hba.ne'] at h
    linarith
  have hinner : HasDerivAt (fun t : ℝ => (2 * t - a - b) / (b - a)) (2 / (b - a)) x := by
    have h2 : HasDerivAt (fun t : ℝ => 2 * t - a - b) 2 x := by
      simpa using ((hasDerivAt_id x).const_mul (2 : ℝ)).sub_const a |>.sub_const b
    simpa [div_eq_mul_inv] using h2.div_const (b - a)
  have hcomp := (Real.hasDerivAt_arcsin hu2 hu1).comp x hinner
  convert hcomp using 1
  have hq : 1 - u ^ 2 = 4 * ((x - a) * (b - x)) / (b - a) ^ 2 := by
    rw [hu]; field_simp; ring
  have hpos : 0 < (x - a) * (b - x) := by nlinarith
  have hs : Real.sqrt (1 - u ^ 2) = 2 * Real.sqrt ((x - a) * (b - x)) / (b - a) := by
    rw [hq, show (4 : ℝ) * ((x - a) * (b - x)) / (b - a) ^ 2
        = (2 * Real.sqrt ((x - a) * (b - x)) / (b - a)) ^ 2 by
      rw [div_pow, mul_pow, Real.sq_sqrt hpos.le]; ring]
    exact Real.sqrt_sq (by positivity)
  have hsp : 0 < Real.sqrt ((x - a) * (b - x)) := Real.sqrt_pos.2 hpos
  simp only [chordHeight, hs]
  field_simp

lemma continuous_arcsinChord (a b : ℝ) : Continuous (arcsinChord a b) :=
  Real.continuous_arcsin.comp (by fun_prop)

/-- The chordal density is (improperly) integrable across the closed interval,
even though it blows up at both endpoints. -/
theorem intervalIntegrable_invSqrtChord (a b : ℝ) :
    IntervalIntegrable (fun x => (chordHeight a b x)⁻¹) volume a b := by
  rcases le_total a b with hab | hab
  · refine intervalIntegral.intervalIntegrable_deriv_of_nonneg
      (continuous_arcsinChord a b).continuousOn (fun x hx => ?_)
      (fun x _ => by unfold chordHeight; positivity)
    exact hasDerivAt_arcsinChord (by simpa [min_eq_left hab, max_eq_right hab] using hx)
  · refine intervalIntegral.intervalIntegrable_deriv_of_nonneg
      (continuous_arcsinChord b a).continuousOn (fun x hx => ?_)
      (fun x _ => by unfold chordHeight; positivity)
    have hx' : x ∈ Ioo b a := by simpa [min_eq_right hab, max_eq_left hab] using hx
    have := hasDerivAt_arcsinChord hx'
    have hchord : chordHeight b a x = chordHeight a b x := by
      unfold chordHeight; ring_nf
    rw [hchord] at this
    exact this

/-- Value of the antiderivative at the left ideal endpoint. -/
lemma arcsinChord_left {a b : ℝ} (hab : a < b) : arcsinChord a b a = -(π / 2) := by
  have hba : 0 < b - a := by linarith
  simp only [arcsinChord]
  rw [show (2 * a - a - b) / (b - a) = -1 by rw [div_eq_iff hba.ne']; ring]
  simp

/-- Value of the antiderivative at the right ideal endpoint. -/
lemma arcsinChord_right {a b : ℝ} (hab : a < b) : arcsinChord a b b = π / 2 := by
  have hba : 0 < b - a := by linarith
  simp only [arcsinChord]
  rw [show (2 * b - a - b) / (b - a) = 1 by rw [div_eq_one_iff_eq hba.ne']; ring]
  simp

/-- **Fundamental theorem of calculus for the chordal density.**  On any
subinterval `[u, v]` of the chord `[a, b]` — *including* the singular endpoints
themselves — the integral of the chordal density is the increment of
`arcsinChord a b`. -/
theorem integral_invSqrtChord_subinterval {a b u v : ℝ} (hab : a < b) (hau : a ≤ u)
    (huv : u < v) (hvb : v ≤ b) :
    ∫ x in u..v, (chordHeight a b x)⁻¹ = arcsinChord a b v - arcsinChord a b u := by
  have hderiv : ∀ x ∈ Ioo u v, HasDerivAt (arcsinChord a b) (chordHeight a b x)⁻¹ x :=
    fun x hx => hasDerivAt_arcsinChord ⟨lt_of_le_of_lt hau hx.1, lt_of_lt_of_le hx.2 hvb⟩
  have hint : IntervalIntegrable (fun x => (chordHeight a b x)⁻¹) volume u v := by
    refine (intervalIntegrable_invSqrtChord a b).mono_set ?_
    rw [Set.uIcc_of_le huv.le, Set.uIcc_of_le hab.le]
    exact fun x hx => ⟨le_trans hau hx.1, le_trans hx.2 hvb⟩
  have hu : Tendsto (arcsinChord a b) (𝓝[>] u) (𝓝 (arcsinChord a b u)) :=
    ((continuous_arcsinChord a b).tendsto u).mono_left nhdsWithin_le_nhds
  have hv : Tendsto (arcsinChord a b) (𝓝[<] v) (𝓝 (arcsinChord a b v)) :=
    ((continuous_arcsinChord a b).tendsto v).mono_left nhdsWithin_le_nhds
  exact intervalIntegral.integral_eq_sub_of_hasDerivAt_of_tendsto huv hderiv hint hu hv

/-- **The ideal-triangle integral.**  The total mass of the chordal density
across the chord `[a, b]` is exactly `π`, independently of `a` and `b`.  This
is the analytic incarnation of the fact that all ideal triangles are congruent
and have area `π`. -/
theorem integral_invSqrtChord {a b : ℝ} (hab : a < b) :
    ∫ x in a..b, (chordHeight a b x)⁻¹ = Real.pi := by
  rw [integral_invSqrtChord_subinterval hab le_rfl hab le_rfl, arcsinChord_left hab,
    arcsinChord_right hab]
  ring

/-! ### The vertical fibre of the hyperbolic area element -/

/-- The hyperbolic area of the vertical ray above height `c > 0` is `c⁻¹`. -/
theorem integral_Ioi_inv_sq {c : ℝ} (hc : 0 < c) :
    ∫ y in Ioi c, (y ^ 2)⁻¹ = c⁻¹ := by
  have hcongr : ∫ y in Ioi c, (y ^ 2)⁻¹ = ∫ y in Ioi c, y ^ (-2 : ℝ) := by
    refine setIntegral_congr_fun measurableSet_Ioi (fun y hy => ?_)
    have hy0 : (0 : ℝ) < y := hc.trans hy
    rw [show (-2 : ℝ) = -(2 : ℕ) by norm_num, Real.rpow_neg hy0.le, Real.rpow_natCast]
  rw [hcongr, integral_Ioi_rpow_of_lt (by norm_num) hc]
  rw [show (-2 : ℝ) + 1 = -1 by norm_num, Real.rpow_neg_one]
  ring

/-! ### The hyperbolic area of a vertically sliced region -/

/-- The hyperbolic area, at curvature `-κ`, of the region of the upper
half-plane lying over the interval `(a, b)` and above the graph of `low`,
computed by slicing:  `∫_a^b ∫_{low x}^∞ dy dx / (κ y²)`. -/
noncomputable def slicedArea (κ a b : ℝ) (low : ℝ → ℝ) : ℝ :=
  ∫ x in a..b, ∫ y in Ioi (low x), (κ * y ^ 2)⁻¹

/-- Slicing reduces a two-dimensional hyperbolic area to a one-dimensional
integral of the reciprocal height of the lower boundary. -/
theorem slicedArea_eq {κ a b : ℝ} (hab : a < b) (low : ℝ → ℝ)
    (hlow : ∀ x ∈ Ioo a b, 0 < low x) :
    slicedArea κ a b low = (∫ x in a..b, (low x)⁻¹) / κ := by
  have hae : ∀ᵐ x : ℝ, x ∈ Set.uIoc a b → (∫ y in Ioi (low x), (κ * y ^ 2)⁻¹)
      = (low x)⁻¹ / κ := by
    have hne : ∀ᵐ x : ℝ, x ≠ b := by
      have : volume {b} = 0 := by simp
      filter_upwards [MeasureTheory.compl_mem_ae_iff.2 this] with x hx
      simpa using hx
    filter_upwards [hne] with x hx hmem
    rw [Set.uIoc_of_le hab.le] at hmem
    have hx' : x ∈ Ioo a b := ⟨hmem.1, lt_of_le_of_ne hmem.2 hx⟩
    have hpos := hlow x hx'
    have : ∀ y : ℝ, (κ * y ^ 2)⁻¹ = κ⁻¹ * (y ^ 2)⁻¹ := by
      intro y; rw [mul_inv]
    simp_rw [this]
    rw [MeasureTheory.integral_const_mul, integral_Ioi_inv_sq hpos, div_eq_inv_mul]
  rw [slicedArea, intervalIntegral.integral_congr_ae hae, intervalIntegral.integral_div]

/-! ### The ideal triangle -/

/-- The ideal triangle of the half-plane model with vertices `a < b` on the
boundary line and third vertex at `∞`: the region above the geodesic semicircle
with diameter `[a, b]` and between the two vertical geodesics `x = a`, `x = b`. -/
def idealTriangleRegion (a b : ℝ) : Set (ℝ × ℝ) :=
  {p | p.1 ∈ Ioo a b ∧ chordHeight a b p.1 < p.2}

lemma mem_idealTriangleRegion_iff {a b : ℝ} (p : ℝ × ℝ) :
    p ∈ idealTriangleRegion a b ↔ p.1 ∈ Ioo a b ∧ chordHeight a b p.1 < p.2 := Iff.rfl

/-- Points of an ideal triangle really do lie in the open upper half-plane. -/
lemma idealTriangleRegion_snd_pos {a b : ℝ} {p : ℝ × ℝ}
    (hp : p ∈ idealTriangleRegion a b) : 0 < p.2 :=
  lt_trans (chordHeight_pos hp.1) hp.2

/-- **Gauss–Bonnet, derived.**  At curvature `-κ` (`κ > 0`) the ideal triangle
with vertices `a < b` and `∞` has hyperbolic area exactly `π / κ`. -/
theorem idealTriangleArea_eq {κ a b : ℝ} (hab : a < b) :
    slicedArea κ a b (chordHeight a b) = Real.pi / κ := by
  rw [slicedArea_eq hab _ (fun x hx => chordHeight_pos hx), integral_invSqrtChord hab]

/-- The geometric area of the ideal triangle agrees with the value predicted by
the algebraic Gauss–Bonnet invariant of `IdealTriangle.lean` at all three angles
zero.  This closes the loop between the angle-data model and the Riemannian
model. -/
theorem idealTriangleArea_eq_hyperbolicArea {κ a b : ℝ} (hab : a < b) :
    slicedArea κ a b (chordHeight a b) = hyperbolicArea κ 0 0 0 := by
  rw [idealTriangleArea_eq hab, hyperbolicArea]
  norm_num

/-- All ideal triangles with a vertex at `∞` have the same area: the invariant
does not see the position of the two finite ideal vertices. -/
theorem idealTriangleArea_congr {κ a b a' b' : ℝ} (hab : a < b) (hab' : a' < b') :
    slicedArea κ a b (chordHeight a b) = slicedArea κ a' b' (chordHeight a' b') := by
  rw [idealTriangleArea_eq hab, idealTriangleArea_eq hab']

/-! ### Ideal polygons -/

/-- The ideal `(m+2)`-gon with finite boundary vertices `v 0 < v 1 < ⋯ < v m`
and last vertex `∞`.  Its region is the union of the vertical strips over the
consecutive intervals, so its area is the corresponding sum. -/
noncomputable def idealPolygonArea (κ : ℝ) (m : ℕ) (v : ℕ → ℝ) : ℝ :=
  ∑ i ∈ Finset.range m, slicedArea κ (v i) (v (i + 1)) (chordHeight (v i) (v (i + 1)))

/-- **Area of an ideal polygon.**  An ideal polygon with `n = m + 2` vertices has
area `(n - 2) π / κ = m π / κ`.  The proof is a genuine triangulation: the
region is cut by the vertical geodesics through the finite vertices into `m`
pieces, each of which is an ideal triangle of area `π / κ`. -/
theorem idealPolygonArea_eq {κ : ℝ} {m : ℕ} {v : ℕ → ℝ}
    (hv : ∀ i < m, v i < v (i + 1)) :
    idealPolygonArea κ m v = m * (Real.pi / κ) := by
  unfold idealPolygonArea
  rw [Finset.sum_congr rfl (fun i hi => idealTriangleArea_eq (hv i (Finset.mem_range.1 hi)))]
  simp [mul_comm]

/-- Triangulation invariance:  gluing an ideal `(m+2)`-gon and an ideal
`(k+2)`-gon along a common edge produces an ideal `(m+k+2)`-gon, and the areas
add. -/
theorem idealPolygonArea_add {κ : ℝ} {m k : ℕ} {v w u : ℕ → ℝ}
    (hv : ∀ i < m, v i < v (i + 1)) (hw : ∀ i < k, w i < w (i + 1))
    (hu : ∀ i < m + k, u i < u (i + 1)) :
    idealPolygonArea κ (m + k) u = idealPolygonArea κ m v + idealPolygonArea κ k w := by
  rw [idealPolygonArea_eq hv, idealPolygonArea_eq hw, idealPolygonArea_eq hu]
  push_cast
  ring

/-! ### Degeneration: exhausting the ideal triangle by truncated regions -/

/-- The truncated ideal triangle: the part of the ideal triangle over
`[a + t, b - t]`.  For `t > 0` this is a compact-in-the-model piece with finite
"vertices". -/
noncomputable def truncatedIdealTriangleArea (κ a b t : ℝ) : ℝ :=
  slicedArea κ (a + t) (b - t) (chordHeight a b)

lemma truncatedIdealTriangleArea_eq {κ a b t : ℝ} (ht : 0 < t) (htb : a + t < b - t) :
    truncatedIdealTriangleArea κ a b t
      = (arcsinChord a b (b - t) - arcsinChord a b (a + t)) / κ := by
  have hab : a < b := by linarith
  have hsub : Ioo (a + t) (b - t) ⊆ Ioo a b := by
    intro x hx
    exact ⟨by linarith [hx.1], by linarith [hx.2]⟩
  rw [truncatedIdealTriangleArea,
    slicedArea_eq htb _ (fun x hx => chordHeight_pos (hsub hx))]
  congr 1
  refine intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x hx => ?_)
    ((intervalIntegrable_invSqrtChord a b).mono_set ?_)
  · refine hasDerivAt_arcsinChord ?_
    rw [Set.uIcc_of_le htb.le] at hx
    exact ⟨by linarith [hx.1], by linarith [hx.2]⟩
  · rw [Set.uIcc_of_le htb.le, Set.uIcc_of_le hab.le]
    intro x hx
    exact ⟨by linarith [hx.1], by linarith [hx.2]⟩

/-- Every truncated (finite) piece has area strictly smaller than the ideal
maximum `π / κ`: the maximum is attained only in the ideal limit. -/
theorem truncatedIdealTriangleArea_lt {κ a b t : ℝ} (hκ : 0 < κ) (ht : 0 < t)
    (htb : a + t < b - t) :
    truncatedIdealTriangleArea κ a b t < Real.pi / κ := by
  have hab : a < b := by linarith
  have hba : 0 < b - a := by linarith
  rw [truncatedIdealTriangleArea_eq ht htb]
  refine (div_lt_div_iff_of_pos_right hκ).2 ?_
  have h1 : arcsinChord a b (b - t) ≤ π / 2 := Real.arcsin_le_pi_div_two _
  have h2 : -(π / 2) < arcsinChord a b (a + t) := by
    have harg : -1 < (2 * (a + t) - a - b) / (b - a) := by
      rw [lt_div_iff₀ hba]; linarith
    simpa [arcsinChord] using Real.neg_pi_div_two_lt_arcsin.2 harg
  linarith

/-- **Degeneration.**  As the truncation parameter tends to `0`, the areas of
the finite truncated pieces increase to the ideal area `π / κ`. -/
theorem tendsto_truncatedIdealTriangleArea {κ a b : ℝ} (hab : a < b) :
    Tendsto (fun t => truncatedIdealTriangleArea κ a b t) (𝓝[>] 0) (𝓝 (Real.pi / κ)) := by
  have hba : 0 < b - a := by linarith
  have key : Tendsto (fun t : ℝ =>
      (arcsinChord a b (b - t) - arcsinChord a b (a + t)) / κ) (𝓝 0)
      (𝓝 (Real.pi / κ)) := by
    have hc : Continuous (fun t : ℝ =>
        (arcsinChord a b (b - t) - arcsinChord a b (a + t)) / κ) := by
      exact (((continuous_arcsinChord a b).comp (by fun_prop)).sub
        ((continuous_arcsinChord a b).comp (by fun_prop))).div_const κ
    have hval : (arcsinChord a b b - arcsinChord a b a) / κ = Real.pi / κ := by
      have h1 : arcsinChord a b b = π / 2 := by
        simp only [arcsinChord]
        rw [show (2 * b - a - b) / (b - a) = 1 by rw [div_eq_one_iff_eq hba.ne']; ring]
        simp
      have h2 : arcsinChord a b a = -(π / 2) := by
        simp only [arcsinChord]
        rw [show (2 * a - a - b) / (b - a) = -1 by rw [div_eq_iff hba.ne']; ring]
        simp
      rw [h1, h2]; ring_nf
    have h := hc.tendsto 0
    simp only [sub_zero, add_zero] at h
    rwa [hval] at h
  refine Tendsto.congr' ?_ (key.mono_left nhdsWithin_le_nhds)
  have hev : ∀ᶠ t : ℝ in 𝓝[>] 0, 0 < t ∧ a + t < b - t := by
    filter_upwards [self_mem_nhdsWithin, Ioo_mem_nhdsGT (show (0:ℝ) < (b - a)/2 by linarith)]
      with t ht ht2
    exact ⟨ht, by simp only [Set.mem_Ioo] at ht2; linarith [ht2.2]⟩
  filter_upwards [hev] with t ht
  exact (truncatedIdealTriangleArea_eq ht.1 ht.2).symm

/-! ### The angle side of the degeneration -/

/-- **Uniqueness of the limiting shape.**  If a sequence of admissible
hyperbolic triangles has Gauss–Bonnet area tending to the universal maximum
`π / κ`, then each of the three angles tends to `0`; that is, the triangles
degenerate to an ideal triangle. -/
theorem angles_tendsto_zero_of_area_tendsto_max {κ : ℝ} (hκ : 0 < κ)
    (α β γ : ℕ → ℝ) (hadm : ∀ n, AdmissibleAngles (α n) (β n) (γ n))
    (hA : Tendsto (fun n => hyperbolicArea κ (α n) (β n) (γ n)) atTop (𝓝 (Real.pi / κ))) :
    Tendsto α atTop (𝓝 0) ∧ Tendsto β atTop (𝓝 0) ∧ Tendsto γ atTop (𝓝 0) := by
  have hsum : Tendsto (fun n => α n + β n + γ n) atTop (𝓝 0) := by
    have h1 : Tendsto (fun n => Real.pi - κ * hyperbolicArea κ (α n) (β n) (γ n))
        atTop (𝓝 (Real.pi - κ * (Real.pi / κ))) :=
      (tendsto_const_nhds.sub (hA.const_mul κ))
    have h2 : Real.pi - κ * (Real.pi / κ) = 0 := by
      field_simp
      ring
    rw [h2] at h1
    refine h1.congr (fun n => ?_)
    simp only [hyperbolicArea]
    field_simp
    ring
  refine ⟨?_, ?_, ?_⟩
  · refine squeeze_zero (fun n => (hadm n).1) (fun n => ?_) hsum
    have := hadm n
    linarith [this.2.1, this.2.2.1]
  · refine squeeze_zero (fun n => (hadm n).2.1) (fun n => ?_) hsum
    have := hadm n
    linarith [this.1, this.2.2.1]
  · refine squeeze_zero (fun n => (hadm n).2.2.1) (fun n => ?_) hsum
    have := hadm n
    linarith [this.1, this.2.1]

end CosmicHorrorGeometry