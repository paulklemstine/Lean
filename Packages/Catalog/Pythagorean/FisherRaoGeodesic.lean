/-
# The Fisher–Rao geodesic between two positive probability vectors

`Pythagorean.BhattacharyyaRiemannConvergence` shows that the Fisher–Rao length
dominates twice the Bhattacharyya angle of the endpoints.  This file shows that
the bound is *attained*: the great-circle arc of the square-root sphere,

  `x(t) = (sin((1−t)θ) √p + sin(tθ) √q) / sin θ`,  `θ = arccos BC(p,q)`,

pulls back to a `C¹` curve `t ↦ x(t)²` of probability vectors joining `p` to `q`
whose Fisher–Rao length is exactly `2 θ`.  Hence

  `inf {Fisher–Rao length of curves from p to q} = 2 arccos BC(p,q)`,

so the Fisher–Rao length functional is *calibrated*: it is the length structure
of the round metric of radius `2` on the positive orthant of the sphere.

## Main results

* `FisherRao.Geodesic.curve_zero`, `curve_one` — the arc joins `p` to `q`
* `FisherRao.Geodesic.curve_sum` — it stays in the simplex (for all times)
* `FisherRao.Geodesic.curve_pos` — it stays strictly positive on `[0,1]`
* `FisherRao.Geodesic.speed_eq` — it has constant Fisher–Rao speed `2 θ`
* `FisherRao.Geodesic.fisherRaoLength_eq` — its Fisher–Rao length is `2 θ`
* `FisherRao.fisherRao_geodesic_realization` — the resulting sharpness statement
-/
import Pythagorean.BhattacharyyaRiemannConvergence

open Finset Real

namespace FisherRao

namespace Geodesic

variable {ι : Type*} [Fintype ι]

/-! ## Two trigonometric identities -/

/-- `sin²u + 2 sin u sin w cos(u+w) + sin²w = sin²(u+w)`. -/
theorem sin_sq_add_sin_sq_add (u w : ℝ) :
    sin u ^ 2 + 2 * sin u * sin w * cos (u + w) + sin w ^ 2 = sin (u + w) ^ 2 := by
  rw [Real.sin_add, Real.cos_add]
  linear_combination (-(sin u ^ 2)) * Real.sin_sq_add_cos_sq w
    + (-(sin w ^ 2)) * Real.sin_sq_add_cos_sq u

/-- `cos²u − 2 cos u cos w cos(u+w) + cos²w = sin²(u+w)`. -/
theorem cos_sq_sub_cos_sq_add (u w : ℝ) :
    cos u ^ 2 - 2 * cos u * cos w * cos (u + w) + cos w ^ 2 = sin (u + w) ^ 2 := by
  rw [Real.sin_add, Real.cos_add]
  linear_combination (-(cos u ^ 2)) * Real.sin_sq_add_cos_sq w
    + (-(cos w ^ 2)) * Real.sin_sq_add_cos_sq u

/-! ## The arc -/

/-- The great-circle arc of the square-root sphere from `√p` to `√q`, in
coordinates. -/
noncomputable def curveVec (p q : ι → ℝ) (t : ℝ) (i : ι) : ℝ :=
  (sin ((1 - t) * arccos (bhattacharyya p q)) * √(p i)
      + sin (t * arccos (bhattacharyya p q)) * √(q i)) / sin (arccos (bhattacharyya p q))

/-- The velocity of the great-circle arc, in coordinates. -/
noncomputable def curveVecDeriv (p q : ι → ℝ) (t : ℝ) (i : ι) : ℝ :=
  arccos (bhattacharyya p q) *
      (-(cos ((1 - t) * arccos (bhattacharyya p q)) * √(p i))
        + cos (t * arccos (bhattacharyya p q)) * √(q i)) / sin (arccos (bhattacharyya p q))

/-- The Fisher–Rao geodesic: the square of the great-circle arc. -/
noncomputable def curve (p q : ι → ℝ) (t : ℝ) (i : ι) : ℝ := (curveVec p q t i) ^ 2

/-- The velocity field of the Fisher–Rao geodesic. -/
noncomputable def vel (p q : ι → ℝ) (t : ℝ) (i : ι) : ℝ :=
  2 * curveVec p q t i * curveVecDeriv p q t i

section

variable {p q : ι → ℝ} (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
  (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1)

include hp hq hp1 hq1

/-- The cosine of the Bhattacharyya angle is the Bhattacharyya coefficient. -/
theorem cos_arccos_bhattacharyya :
    cos (arccos (bhattacharyya p q)) = bhattacharyya p q :=
  Real.cos_arccos (by linarith [bhattacharyya_nonneg p q])
    (bhattacharyya_le_one p q hp hq hp1 hq1)

/-- Expansion of the squared norm of a combination of the two square-root
vectors. -/
theorem sum_comb_sq (α β : ℝ) :
    ∑ i, (α * √(p i) + β * √(q i)) ^ 2
      = α ^ 2 + 2 * α * β * bhattacharyya p q + β ^ 2 := by
  have hterm : ∀ i ∈ (Finset.univ : Finset ι),
      (α * √(p i) + β * √(q i)) ^ 2
        = α ^ 2 * p i + 2 * α * β * √(p i * q i) + β ^ 2 * q i := by
    intro i _
    rw [Real.sqrt_mul (hp i)]
    nlinarith [Real.sq_sqrt (hp i), Real.sq_sqrt (hq i)]
  rw [Finset.sum_congr rfl hterm]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
    ← Finset.mul_sum, hp1, hq1]
  simp [bhattacharyya]

omit hp hq hp1 hq1 in
theorem arccos_pos_of_ne (hne : bhattacharyya p q < 1) : 0 < arccos (bhattacharyya p q) :=
  Real.arccos_pos.mpr hne

omit hp hq hp1 hq1 in
theorem sin_arccos_pos (hne : bhattacharyya p q < 1) :
    0 < sin (arccos (bhattacharyya p q)) := by
  refine Real.sin_pos_of_pos_of_lt_pi (arccos_pos_of_ne hne) ?_
  have h := Real.arccos_le_pi_div_two.mpr (bhattacharyya_nonneg p q)
  linarith [Real.pi_pos]

variable (hne : bhattacharyya p q < 1)

include hne

omit hq hp1 hq1 in
/-- The arc starts at `p`. -/
theorem curve_zero (i : ι) : curve p q 0 i = p i := by
  have hs : 0 < sin (arccos (bhattacharyya p q)) := sin_arccos_pos hne
  have h : curveVec p q 0 i = √(p i) := by
    unfold curveVec
    simp only [sub_zero, one_mul, zero_mul, Real.sin_zero, add_zero]
    field_simp
  rw [curve, h, Real.sq_sqrt (hp i)]

omit hp hp1 hq1 in
/-- The arc ends at `q`. -/
theorem curve_one (i : ι) : curve p q 1 i = q i := by
  have hs : 0 < sin (arccos (bhattacharyya p q)) := sin_arccos_pos hne
  have h : curveVec p q 1 i = √(q i) := by
    unfold curveVec
    simp only [sub_self, zero_mul, Real.sin_zero, one_mul, zero_add]
    field_simp
  rw [curve, h, Real.sq_sqrt (hq i)]

/-- The arc stays in the simplex. -/
theorem curve_sum (t : ℝ) : ∑ i, curve p q t i = 1 := by
  set θ : ℝ := arccos (bhattacharyya p q) with hθ
  have hs : 0 < sin θ := sin_arccos_pos hne
  have hcos : cos θ = bhattacharyya p q := cos_arccos_bhattacharyya hp hq hp1 hq1
  have hexp : ∀ i ∈ (Finset.univ : Finset ι), curve p q t i
      = (sin ((1 - t) * θ) * √(p i) + sin (t * θ) * √(q i)) ^ 2 / (sin θ) ^ 2 := by
    intro i _
    rw [curve, curveVec, div_pow]
  rw [Finset.sum_congr rfl hexp, ← Finset.sum_div,
    sum_comb_sq hp hq hp1 hq1 (sin ((1 - t) * θ)) (sin (t * θ)), ← hcos]
  have hid := sin_sq_add_sin_sq_add ((1 - t) * θ) (t * θ)
  rw [show (1 - t) * θ + t * θ = θ by ring] at hid
  rw [show sin ((1 - t) * θ) ^ 2 + 2 * sin ((1 - t) * θ) * sin (t * θ) * cos θ + sin (t * θ) ^ 2
      = sin θ ^ 2 from hid]
  exact div_self (by positivity)

omit hp hq hp1 hq1 in
/-- The arc stays strictly positive on `[0,1]`. -/
theorem curve_pos (hppos : ∀ i, 0 < p i) (hqpos : ∀ i, 0 < q i) {t : ℝ}
    (ht : t ∈ Set.Icc (0:ℝ) 1) (i : ι) : 0 < curve p q t i := by
  set θ : ℝ := arccos (bhattacharyya p q) with hθ
  have hθpos : 0 < θ := arccos_pos_of_ne hne
  have hθle : θ ≤ π / 2 := Real.arccos_le_pi_div_two.mpr (bhattacharyya_nonneg p q)
  have hs : 0 < sin θ := sin_arccos_pos hne
  have hA : 0 < √(p i) := Real.sqrt_pos.mpr (hppos i)
  have hB : 0 < √(q i) := Real.sqrt_pos.mpr (hqpos i)
  have h1 : 0 ≤ sin ((1 - t) * θ) := by
    refine Real.sin_nonneg_of_nonneg_of_le_pi (by nlinarith [ht.1, ht.2]) ?_
    nlinarith [ht.1, ht.2, Real.pi_pos]
  have h2 : 0 ≤ sin (t * θ) := by
    refine Real.sin_nonneg_of_nonneg_of_le_pi (by nlinarith [ht.1, ht.2]) ?_
    nlinarith [ht.1, ht.2, Real.pi_pos]
  have hne0 : 0 < sin ((1 - t) * θ) + sin (t * θ) := by
    rcases le_total t (1 / 2) with hcase | hcase
    · have : 0 < sin ((1 - t) * θ) := by
        refine Real.sin_pos_of_pos_of_lt_pi (by nlinarith [ht.2]) ?_
        nlinarith [ht.1, Real.pi_pos]
      linarith
    · have : 0 < sin (t * θ) := by
        refine Real.sin_pos_of_pos_of_lt_pi (by nlinarith) ?_
        nlinarith [ht.2, Real.pi_pos]
      linarith
  have hnum : 0 < sin ((1 - t) * θ) * √(p i) + sin (t * θ) * √(q i) := by
    rcases eq_or_lt_of_le h1 with hc | hc
    · have h4 : 0 < sin (t * θ) := by linarith [hne0, hc]
      nlinarith
    · nlinarith
  have : 0 < curveVec p q t i := div_pos hnum hs
  exact pow_pos this 2

/-! ## Derivatives -/

omit hp hq hp1 hq1 hne in
theorem hasDerivAt_curveVec (t : ℝ) (i : ι) :
    HasDerivAt (fun s => curveVec p q s i) (curveVecDeriv p q t i) t := by
  set θ : ℝ := arccos (bhattacharyya p q) with hθ
  have h1 : HasDerivAt (fun s : ℝ => (1 - s) * θ) (-θ) t := by
    have := ((hasDerivAt_id t).const_sub 1).mul_const θ
    simpa using this
  have h2 : HasDerivAt (fun s : ℝ => s * θ) θ t := by
    simpa using (hasDerivAt_id t).mul_const θ
  have h3 : HasDerivAt (fun s : ℝ => sin ((1 - s) * θ)) (cos ((1 - t) * θ) * (-θ)) t := h1.sin
  have h4 : HasDerivAt (fun s : ℝ => sin (s * θ)) (cos (t * θ) * θ) t := h2.sin
  have h5 := ((h3.mul_const (√(p i))).add (h4.mul_const (√(q i)))).div_const (sin θ)
  convert h5 using 1
  rw [curveVecDeriv, ← hθ]
  field_simp

omit hp hq hp1 hq1 hne in
theorem hasDerivAt_curve (t : ℝ) (i : ι) :
    HasDerivAt (fun s => curve p q s i) (vel p q t i) t := by
  have h := (hasDerivAt_curveVec (p := p) (q := q) t i).pow 2
  simpa [curve, vel, pow_one, mul_comm, mul_assoc, mul_left_comm] using h

omit hp hq hp1 hq1 hne in
theorem continuous_curveVec (i : ι) : Continuous fun t => curveVec p q t i := by
  unfold curveVec
  fun_prop

omit hp hq hp1 hq1 hne in
theorem continuous_curveVecDeriv (i : ι) : Continuous fun t => curveVecDeriv p q t i := by
  unfold curveVecDeriv
  fun_prop

omit hp hq hp1 hq1 hne in
theorem continuous_vel (i : ι) : Continuous fun t => vel p q t i :=
  (continuous_const.mul (continuous_curveVec i)).mul (continuous_curveVecDeriv i)

/-! ## Constant speed and the length -/

/-- The velocity of the arc has constant Euclidean norm `θ`. -/
theorem sum_curveVecDeriv_sq (t : ℝ) :
    ∑ i, (curveVecDeriv p q t i) ^ 2 = (arccos (bhattacharyya p q)) ^ 2 := by
  set θ : ℝ := arccos (bhattacharyya p q) with hθ
  have hs : 0 < sin θ := sin_arccos_pos hne
  have hcos : cos θ = bhattacharyya p q := cos_arccos_bhattacharyya hp hq hp1 hq1
  have hexp : ∀ i ∈ (Finset.univ : Finset ι), (curveVecDeriv p q t i) ^ 2
      = θ ^ 2 * ((-cos ((1 - t) * θ)) * √(p i) + cos (t * θ) * √(q i)) ^ 2 / (sin θ) ^ 2 := by
    intro i _
    rw [curveVecDeriv, ← hθ]
    field_simp
  rw [Finset.sum_congr rfl hexp, ← Finset.sum_div, ← Finset.mul_sum,
    sum_comb_sq hp hq hp1 hq1 (-cos ((1 - t) * θ)) (cos (t * θ)), ← hcos]
  have hid := cos_sq_sub_cos_sq_add ((1 - t) * θ) (t * θ)
  rw [show (1 - t) * θ + t * θ = θ by ring] at hid
  have hrw : (-cos ((1 - t) * θ)) ^ 2
      + 2 * (-cos ((1 - t) * θ)) * cos (t * θ) * cos θ + cos (t * θ) ^ 2 = sin θ ^ 2 := by
    nlinarith [hid]
  rw [hrw]
  field_simp

/-- The arc has constant Fisher–Rao speed `2θ`. -/
theorem speed_eq (hppos : ∀ i, 0 < p i) (hqpos : ∀ i, 0 < q i) {t : ℝ}
    (ht : t ∈ Set.Icc (0:ℝ) 1) :
    fisherRaoSpeed (curve p q t) (vel p q t) = 2 * arccos (bhattacharyya p q) := by
  set θ : ℝ := arccos (bhattacharyya p q) with hθ
  have hθpos : 0 < θ := arccos_pos_of_ne hne
  have hterm : ∀ i ∈ (Finset.univ : Finset ι),
      (vel p q t i) ^ 2 / curve p q t i = 4 * (curveVecDeriv p q t i) ^ 2 := by
    intro i _
    have hcpos : 0 < curve p q t i := curve_pos hne hppos hqpos ht i
    have hcv : curveVec p q t i ≠ 0 := by
      intro h0
      rw [curve, h0] at hcpos
      simp at hcpos
    rw [vel, curve]
    field_simp
    ring
  rw [fisherRaoSpeed, Finset.sum_congr rfl hterm, ← Finset.mul_sum,
    sum_curveVecDeriv_sq hp hq hp1 hq1 hne t,
    show (4:ℝ) * θ ^ 2 = (2 * θ) ^ 2 by ring, Real.sqrt_sq (by positivity)]

/-- **The length of the geodesic arc is `2 arccos BC(p,q)`.** -/
theorem fisherRaoLength_eq (hppos : ∀ i, 0 < p i) (hqpos : ∀ i, 0 < q i) :
    fisherRaoLength (curve p q) (vel p q) 0 1 = 2 * arccos (bhattacharyya p q) := by
  have hcongr : ∀ t ∈ Set.uIcc (0:ℝ) 1,
      fisherRaoSpeed (curve p q t) (vel p q t) = 2 * arccos (bhattacharyya p q) := by
    intro t ht
    rw [Set.uIcc_of_le (by norm_num : (0:ℝ) ≤ 1)] at ht
    exact speed_eq hp hq hp1 hq1 hne hppos hqpos ht
  rw [fisherRaoLength, intervalIntegral.integral_congr hcongr]
  simp

/-! ## A globally admissible reparametrisation

The arc above is only positive on `[0,1]`.  Composing it with the smooth
reparametrisation `σ(t) = (1 − cos(π t))/2`, which maps all of `ℝ` into `[0,1]`
and satisfies `σ(0) = 0`, `σ(1) = 1`, produces a curve satisfying the *global*
hypotheses of the length theory, still of length exactly `2θ`. -/

end

/-- The reparametrisation `σ(t) = (1 − cos(π t))/2` of `ℝ` onto `[0,1]`. -/
noncomputable def reparam (t : ℝ) : ℝ := (1 - cos (π * t)) / 2

/-- The derivative of the reparametrisation. -/
noncomputable def reparamDeriv (t : ℝ) : ℝ := π * sin (π * t) / 2

theorem reparam_mem (t : ℝ) : reparam t ∈ Set.Icc (0:ℝ) 1 :=
  ⟨by have := Real.cos_le_one (π * t); rw [reparam]; linarith,
   by have := Real.neg_one_le_cos (π * t); rw [reparam]; linarith⟩

theorem reparam_zero : reparam 0 = 0 := by simp [reparam]

theorem reparam_one : reparam 1 = 1 := by simp [reparam]

theorem hasDerivAt_reparam (t : ℝ) : HasDerivAt reparam (reparamDeriv t) t := by
  have h1 : HasDerivAt (fun s : ℝ => π * s) π t := by simpa using (hasDerivAt_id t).const_mul π
  have h2 : HasDerivAt (fun s : ℝ => cos (π * s)) (-sin (π * t) * π) t := h1.cos
  have h3 := ((h2.const_sub 1).div_const 2)
  convert h3 using 1
  rw [reparamDeriv]
  ring

/-- The reparametrised geodesic. -/
noncomputable def gcurve (p q : ι → ℝ) (t : ℝ) (i : ι) : ℝ := curve p q (reparam t) i

/-- The velocity of the reparametrised geodesic. -/
noncomputable def gvel (p q : ι → ℝ) (t : ℝ) (i : ι) : ℝ :=
  vel p q (reparam t) i * reparamDeriv t

theorem hasDerivAt_gcurve (p q : ι → ℝ) (t : ℝ) (i : ι) :
    HasDerivAt (fun s => gcurve p q s i) (gvel p q t i) t :=
  (hasDerivAt_curve (p := p) (q := q) (reparam t) i).comp t (hasDerivAt_reparam t)

theorem continuous_gvel (p q : ι → ℝ) (i : ι) : Continuous fun t => gvel p q t i := by
  refine ((continuous_vel (p := p) (q := q) i).comp ?_).mul ?_
  · unfold reparam; fun_prop
  · unfold reparamDeriv; fun_prop

/-- Scaling the velocity scales the Fisher–Rao speed by the absolute value. -/
theorem fisherRaoSpeed_smul (P V : ι → ℝ) (c : ℝ) :
    fisherRaoSpeed P (fun i => V i * c) = |c| * fisherRaoSpeed P V := by
  have hterm : ∀ i ∈ (Finset.univ : Finset ι), (V i * c) ^ 2 / P i = c ^ 2 * ((V i) ^ 2 / P i) := by
    intro i _; ring
  rw [fisherRaoSpeed, Finset.sum_congr rfl hterm, ← Finset.mul_sum,
    Real.sqrt_mul (sq_nonneg c), Real.sqrt_sq_eq_abs, fisherRaoSpeed]

section

variable {p q : ι → ℝ} (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
  (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) (hne : bhattacharyya p q < 1)

include hp hq hp1 hq1 hne

omit hq hp1 hq1 in
theorem gcurve_zero (i : ι) : gcurve p q 0 i = p i := by
  rw [gcurve, reparam_zero]
  exact curve_zero hp hne i

omit hp hp1 hq1 in
theorem gcurve_one (i : ι) : gcurve p q 1 i = q i := by
  rw [gcurve, reparam_one]
  exact curve_one hq hne i

theorem gcurve_sum (t : ℝ) : ∑ i, gcurve p q t i = 1 :=
  curve_sum hp hq hp1 hq1 hne (reparam t)

omit hp hq hp1 hq1 in
theorem gcurve_pos (hppos : ∀ i, 0 < p i) (hqpos : ∀ i, 0 < q i) (t : ℝ) (i : ι) :
    0 < gcurve p q t i :=
  curve_pos hne hppos hqpos (reparam_mem t) i

/-- The Fisher–Rao length of the reparametrised geodesic is still `2θ`. -/
theorem fisherRaoLength_gcurve (hppos : ∀ i, 0 < p i) (hqpos : ∀ i, 0 < q i) :
    fisherRaoLength (gcurve p q) (gvel p q) 0 1 = 2 * arccos (bhattacharyya p q) := by
  set θ : ℝ := arccos (bhattacharyya p q) with hθ
  have hθ0 : 0 ≤ θ := Real.arccos_nonneg _
  have hspeed : ∀ t ∈ Set.uIcc (0:ℝ) 1,
      fisherRaoSpeed (gcurve p q t) (gvel p q t) = 2 * θ * reparamDeriv t := by
    intro t ht
    rw [Set.uIcc_of_le (by norm_num : (0:ℝ) ≤ 1)] at ht
    have hd : 0 ≤ reparamDeriv t := by
      have hs : 0 ≤ sin (π * t) := by
        refine Real.sin_nonneg_of_nonneg_of_le_pi (by nlinarith [Real.pi_pos, ht.1]) ?_
        nlinarith [Real.pi_pos, ht.2]
      rw [reparamDeriv]
      positivity
    have hsp : fisherRaoSpeed (gcurve p q t) (gvel p q t)
        = |reparamDeriv t| * fisherRaoSpeed (curve p q (reparam t)) (vel p q (reparam t)) :=
      fisherRaoSpeed_smul _ _ _
    rw [hsp, speed_eq hp hq hp1 hq1 hne hppos hqpos (reparam_mem t), abs_of_nonneg hd]
    ring
  rw [fisherRaoLength, intervalIntegral.integral_congr hspeed]
  have hF : ∀ t : ℝ, HasDerivAt (fun s => 2 * θ * reparam s) (2 * θ * reparamDeriv t) t :=
    fun t => (hasDerivAt_reparam t).const_mul (2 * θ)
  have hcont : Continuous fun t : ℝ => 2 * θ * reparamDeriv t := by
    unfold reparamDeriv; fun_prop
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun t _ => hF t)
    (hcont.intervalIntegrable 0 1), reparam_zero, reparam_one]
  ring

end

end Geodesic

/-- **Geodesic realization / sharpness.**  Any two distinct strictly positive
probability vectors are joined by a `C¹` curve of probability vectors, positive
on `[0,1]`, whose Fisher–Rao length is exactly twice the Bhattacharyya angle.
Combined with `two_arccos_bhattacharyya_le_fisherRaoLength` this identifies the
Fisher–Rao distance with the spherical distance of the square-root embeddings. -/
theorem fisherRao_geodesic_realization {ι : Type*} [Fintype ι] {p q : ι → ℝ}
    (hppos : ∀ i, 0 < p i) (hqpos : ∀ i, 0 < q i)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) (hne : bhattacharyya p q < 1) :
    ∃ P V : ℝ → ι → ℝ,
      (∀ t i, HasDerivAt (fun s => P s i) (V t i) t) ∧
      (∀ i, Continuous fun t => V t i) ∧
      P 0 = p ∧ P 1 = q ∧
      (∀ t, ∑ i, P t i = 1) ∧
      (∀ t ∈ Set.Icc (0:ℝ) 1, ∀ i, 0 < P t i) ∧
      fisherRaoLength P V 0 1 = 2 * arccos (bhattacharyya p q) := by
  have hp : ∀ i, 0 ≤ p i := fun i => (hppos i).le
  have hq : ∀ i, 0 ≤ q i := fun i => (hqpos i).le
  refine ⟨Geodesic.curve p q, Geodesic.vel p q, fun t i => Geodesic.hasDerivAt_curve t i,
    fun i => Geodesic.continuous_vel i, ?_, ?_, fun t => Geodesic.curve_sum hp hq hp1 hq1 hne t,
    fun t ht i => Geodesic.curve_pos hne hppos hqpos ht i,
    Geodesic.fisherRaoLength_eq hp hq hp1 hq1 hne hppos hqpos⟩
  · funext i; exact Geodesic.curve_zero hp hne i
  · funext i; exact Geodesic.curve_one hq hne i

/-- The set of Fisher–Rao lengths of `C¹` curves of strictly positive probability
vectors joining `p` to `q` on the parameter interval `[0,1]`. -/
def connectingLengths {ι : Type*} [Fintype ι] (p q : ι → ℝ) : Set ℝ :=
  {L : ℝ | ∃ P V : ℝ → ι → ℝ, (∀ t i, HasDerivAt (fun s => P s i) (V t i) t) ∧
    (∀ i, Continuous fun t => V t i) ∧ (∀ t i, 0 < P t i) ∧ (∀ t, ∑ i, P t i = 1) ∧
    P 0 = p ∧ P 1 = q ∧ L = fisherRaoLength P V 0 1}

/-- **The Fisher–Rao distance is twice the Bhattacharyya angle.**  For strictly
positive probability vectors `p, q`, the infimum of the Fisher–Rao lengths of
`C¹` curves of positive probability vectors joining them is attained and equals
`2 arccos BC(p,q)`, the spherical distance of the square-root embeddings scaled
by the radius `2` of the Fisher–Rao sphere. -/
theorem fisherRao_isGLB_connectingLengths {ι : Type*} [Fintype ι] {p q : ι → ℝ}
    (hppos : ∀ i, 0 < p i) (hqpos : ∀ i, 0 < q i)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) :
    IsGLB (connectingLengths p q) (2 * arccos (bhattacharyya p q)) := by
  have hp : ∀ i, 0 ≤ p i := fun i => (hppos i).le
  have hq : ∀ i, 0 ≤ q i := fun i => (hqpos i).le
  constructor
  · rintro L ⟨P, V, hderiv, hv, hpos, hP1, hP0eq, hP1eq, rfl⟩
    have h := two_arccos_bhattacharyya_le_fisherRaoLength (p := P) (v := V)
      (by norm_num : (0:ℝ) ≤ 1) hderiv hv hpos hP1
    rwa [hP0eq, hP1eq] at h
  · intro c hc
    rcases lt_or_eq_of_le (bhattacharyya_le_one p q hp hq hp1 hq1) with hne | heq
    · -- the geodesic arc realises the value
      have hmem : 2 * arccos (bhattacharyya p q) ∈ connectingLengths p q := by
        refine ⟨Geodesic.gcurve p q, Geodesic.gvel p q,
          fun t i => Geodesic.hasDerivAt_gcurve p q t i, fun i => Geodesic.continuous_gvel p q i,
          fun t i => Geodesic.gcurve_pos hne hppos hqpos t i,
          fun t => Geodesic.gcurve_sum hp hq hp1 hq1 hne t, ?_, ?_, ?_⟩
        · funext i; exact Geodesic.gcurve_zero hp hne i
        · funext i; exact Geodesic.gcurve_one hq hne i
        · exact (Geodesic.fisherRaoLength_gcurve hp hq hp1 hq1 hne hppos hqpos).symm
      exact hc hmem
    · -- `p = q`: the constant curve realises the value `0`
      have hpq : p = q := eq_of_bhattacharyya_eq_one hp hq hp1 hq1 heq
      have hzero : 2 * arccos (bhattacharyya p q) = 0 := by rw [heq]; simp
      have hmem : (0:ℝ) ∈ connectingLengths p q := by
        refine ⟨fun _ => p, fun _ _ => 0, fun t i => hasDerivAt_const t (p i),
          fun i => continuous_const, fun t i => hppos i, fun t => hp1, rfl, hpq, ?_⟩
        simp [fisherRaoLength, fisherRaoSpeed]
      rw [hzero]
      exact hc hmem

end FisherRao