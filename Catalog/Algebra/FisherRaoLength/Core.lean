/-
# The `L¹` bound integrates to a Fisher–Rao length bound

This file proves the main theorem `l1_le_fisherRao_length`: along any smooth
curve of (strictly positive) probability vectors, the `L¹` distance between the
endpoints is bounded by the Fisher–Rao length of the curve.

The infinitesimal statement is a Cauchy–Schwarz inequality on the simplex,

  `∑ᵢ |vᵢ| = ∑ᵢ (|vᵢ| / √pᵢ) · √pᵢ ≤ √(∑ᵢ vᵢ²/pᵢ) · √(∑ᵢ pᵢ) = √(∑ᵢ vᵢ²/pᵢ)`,

i.e. the `L¹` speed of a curve of probability vectors never exceeds its
Fisher–Rao speed.  Integrating this pointwise bound with the fundamental theorem
of calculus turns it into the global length bound.

## Main definitions

* `l1Dist`            — the `L¹` distance `∑ᵢ |pᵢ - qᵢ|` (twice total variation)
* `fisherRaoSpeed`    — `√(∑ᵢ vᵢ² / pᵢ)`, the Fisher–Rao norm of a tangent vector
* `fisherRaoLength`   — the integral of the Fisher–Rao speed along a curve

## Main results

* `l1_speed_le_fisherRaoSpeed` — the infinitesimal (Cauchy–Schwarz) bound
* `l1_le_fisherRao_length`     — the integrated length bound (main theorem)
* `l1_le_fisherRao_length_uIcc`— localized version, hypotheses only on `[a,b]`
* `tv_le_half_fisherRao_length`— total variation form of the main theorem
* `fisherRaoSpeed_eq_two_mul_sqrtSpeed` — Fisher–Rao speed is twice the
  Euclidean speed of the square-root (sphere) embedding
* `TwoPoint.fisherRaoLength_eq_arcsin`, `TwoPoint.l1_lt_fisherRaoLength`,
  `TwoPoint.sharp` — an exactly solvable family showing the inequality is
  strict but that the constant `1` is optimal
* `fisherRao_sq_tensor`, `fisherRaoSpeed_tensor` — Pythagorean tensorization
* `abs_sub_event_le_half_fisherRao_length` — no event's probability moves by
  more than half the length
* `sqrt_chord_le_half_fisherRao_length` — the sharper spherical chord bound
* `one_sub_bhattacharyya_le_sq_fisherRao_length` — Hellinger/Bhattacharyya form
* `l1Dist_le_two_mul_sqrt_one_sub_bhattacharyya_sq`,
  `l1Dist_le_sum_arccos_bhattacharyya` — the smoothness-free discrete analogue
-/
import Mathlib

open Finset BigOperators Real MeasureTheory intervalIntegral

namespace FisherRao

variable {ι : Type*} [Fintype ι]

/-! ## Definitions -/

/-- The `L¹` (total-variation-type) distance between two finite vectors. -/
noncomputable def l1Dist (p q : ι → ℝ) : ℝ := ∑ i, |p i - q i|

/-- The Fisher–Rao (information-metric) norm of a tangent vector `v` at the
point `p` of the open simplex: `√(∑ᵢ vᵢ² / pᵢ)`. -/
noncomputable def fisherRaoSpeed (p v : ι → ℝ) : ℝ := Real.sqrt (∑ i, (v i) ^ 2 / p i)

/-- The Fisher–Rao length of the curve `t ↦ p t` with velocity field `t ↦ v t`,
computed over the interval `[a, b]`. -/
noncomputable def fisherRaoLength (p v : ℝ → ι → ℝ) (a b : ℝ) : ℝ :=
  ∫ t in a..b, fisherRaoSpeed (p t) (v t)

/-! ## Elementary properties -/

theorem l1Dist_nonneg (p q : ι → ℝ) : 0 ≤ l1Dist p q :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

theorem l1Dist_comm (p q : ι → ℝ) : l1Dist p q = l1Dist q p :=
  Finset.sum_congr rfl fun i _ => abs_sub_comm (p i) (q i)

theorem l1Dist_triangle (p q r : ι → ℝ) : l1Dist p r ≤ l1Dist p q + l1Dist q r := by
  unfold l1Dist
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_le_sum fun i _ => ?_
  calc |p i - r i| = |(p i - q i) + (q i - r i)| := by ring_nf
    _ ≤ |p i - q i| + |q i - r i| := abs_add_le _ _

theorem fisherRaoSpeed_nonneg (p v : ι → ℝ) : 0 ≤ fisherRaoSpeed p v := Real.sqrt_nonneg _

/-! ## The infinitesimal bound: Cauchy–Schwarz on the simplex -/

/-- **Infinitesimal `L¹` ≤ Fisher–Rao bound.**  For a strictly positive
probability vector `p` and an arbitrary tangent vector `v`, the `L¹` norm of `v`
is at most its Fisher–Rao norm.  This is Cauchy–Schwarz applied to the splitting
`|vᵢ| = (|vᵢ|/√pᵢ) · √pᵢ`. -/
theorem l1_speed_le_fisherRaoSpeed (p v : ι → ℝ) (hp : ∀ i, 0 < p i)
    (hp1 : ∑ i, p i = 1) : ∑ i, |v i| ≤ fisherRaoSpeed p v := by
  have hkey : (∑ i, |v i|) ^ 2 ≤ ∑ i, (v i) ^ 2 / p i := by
    have hCS := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
      (fun i => |v i| / Real.sqrt (p i)) (fun i => Real.sqrt (p i))
    have hrw : ∀ i : ι, |v i| / Real.sqrt (p i) * Real.sqrt (p i) = |v i| := by
      intro i
      have : Real.sqrt (p i) ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr (hp i))
      field_simp
    have hrw2 : ∀ i : ι, (|v i| / Real.sqrt (p i)) ^ 2 = (v i) ^ 2 / p i := by
      intro i
      rw [div_pow, Real.sq_sqrt (hp i).le, sq_abs]
    have hrw3 : ∀ i : ι, (Real.sqrt (p i)) ^ 2 = p i := fun i => Real.sq_sqrt (hp i).le
    simp only [hrw, hrw2, hrw3] at hCS
    rwa [hp1, mul_one] at hCS
  have hnn : 0 ≤ ∑ i, |v i| := Finset.sum_nonneg fun _ _ => abs_nonneg _
  rw [fisherRaoSpeed, show (∑ i, |v i|) = Real.sqrt ((∑ i, |v i|) ^ 2) from
    (Real.sqrt_sq hnn).symm]
  exact Real.sqrt_le_sqrt hkey

/-! ## Continuity and integrability infrastructure -/

section Curve

variable {p v : ℝ → ι → ℝ}

omit [Fintype ι] in
theorem continuous_coord (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t) (i : ι) :
    Continuous fun t => p t i :=
  continuous_iff_continuousAt.mpr fun t => (hderiv t i).continuousAt

theorem continuous_fisherRaoSpeed (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i) :
    Continuous fun t => fisherRaoSpeed (p t) (v t) := by
  refine Continuous.sqrt (continuous_finset_sum _ fun i _ => ?_)
  exact ((hv i).pow 2).div (continuous_coord hderiv i) fun t => ne_of_gt (hpos t i)

theorem continuous_l1Speed (hv : ∀ i, Continuous fun t => v t i) :
    Continuous fun t => ∑ i, |v t i| :=
  continuous_finset_sum _ fun i _ => (hv i).abs

end Curve

/-! ## The main theorem -/

/-- **The `L¹` bound integrates to a Fisher–Rao length bound.**

Let `t ↦ p t` be a curve in the open probability simplex of a finite type `ι`, with
continuous velocity field `v` (so `v t i` is the derivative of `t ↦ p t i`).
Then the `L¹` distance between the endpoints `p a` and `p b` is at most the
Fisher–Rao length of the curve on `[a, b]`. -/
theorem l1_le_fisherRao_length {p v : ℝ → ι → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i)
    (hpos : ∀ t i, 0 < p t i) (hp1 : ∀ t, ∑ i, p t i = 1) :
    l1Dist (p b) (p a) ≤ fisherRaoLength p v a b := by
  -- Step 1: each coordinate satisfies the fundamental theorem of calculus.
  have hFTC : ∀ i : ι, p b i - p a i = ∫ t in a..b, v t i := fun i =>
    (integral_eq_sub_of_hasDerivAt (fun t _ => hderiv t i)
      ((hv i).intervalIntegrable a b)).symm
  -- Step 2: coordinatewise, `|p b i - p a i| ≤ ∫ |v t i|`.
  have hcoord : ∀ i : ι, |p b i - p a i| ≤ ∫ t in a..b, |v t i| := by
    intro i
    rw [hFTC i]
    exact abs_integral_le_integral_abs hab
  -- Step 3: sum the coordinate bounds and exchange sum and integral.
  have hsum : l1Dist (p b) (p a) ≤ ∫ t in a..b, ∑ i, |v t i| := by
    have hswap : (∫ t in a..b, ∑ i, |v t i|) = ∑ i, ∫ t in a..b, |v t i| :=
      intervalIntegral.integral_finset_sum fun i _ => ((hv i).abs).intervalIntegrable a b
    rw [hswap]
    exact Finset.sum_le_sum fun i _ => hcoord i
  -- Step 4: the pointwise Cauchy–Schwarz bound, integrated.
  refine hsum.trans (intervalIntegral.integral_mono_on hab
    ((continuous_l1Speed hv).intervalIntegrable a b)
    ((continuous_fisherRaoSpeed hderiv hv hpos).intervalIntegrable a b) ?_)
  intro t _
  exact l1_speed_le_fisherRaoSpeed (p t) (v t) (hpos t) (hp1 t)

/-- Total-variation form of the main theorem: since total variation distance is
half the `L¹` distance, `dTV(p a, p b) ≤ ½ · length`. -/
theorem tv_le_half_fisherRao_length {p v : ℝ → ι → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i)
    (hpos : ∀ t i, 0 < p t i) (hp1 : ∀ t, ∑ i, p t i = 1) :
    (1 / 2) * l1Dist (p b) (p a) ≤ (1 / 2) * fisherRaoLength p v a b := by
  have := l1_le_fisherRao_length hab hderiv hv hpos hp1
  linarith

/-! ## Structural properties of the length functional -/

theorem fisherRaoLength_nonneg (p v : ℝ → ι → ℝ) {a b : ℝ} (hab : a ≤ b) :
    0 ≤ fisherRaoLength p v a b :=
  intervalIntegral.integral_nonneg hab fun t _ => fisherRaoSpeed_nonneg (p t) (v t)

/-- The Fisher–Rao length is additive along concatenation of subintervals. -/
theorem fisherRaoLength_add {p v : ℝ → ι → ℝ} {a b c : ℝ}
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i) :
    fisherRaoLength p v a b + fisherRaoLength p v b c = fisherRaoLength p v a c := by
  have hc := continuous_fisherRaoSpeed hderiv hv hpos
  exact intervalIntegral.integral_add_adjacent_intervals
    (hc.intervalIntegrable a b) (hc.intervalIntegrable b c)

/-! ## The square-root (sphere) embedding

The Fisher–Rao metric is, up to the factor `4`, the Euclidean metric pulled back
along `p ↦ √p`.  Concretely, if `pᵢ` moves with velocity `vᵢ`, then `√pᵢ` moves
with velocity `vᵢ / (2√pᵢ)`, and hence `∑ᵢ (d/dt √pᵢ)² = ¼ ∑ᵢ vᵢ²/pᵢ`. -/

/-- The velocity of the square-root embedding. -/
noncomputable def sqrtVelocity (p v : ι → ℝ) : ι → ℝ := fun i => v i / (2 * Real.sqrt (p i))

theorem hasDerivAt_sqrt_coord {f : ℝ → ℝ} {x c : ℝ} (hf : HasDerivAt f c x) (hpos : 0 < f x) :
    HasDerivAt (fun t => Real.sqrt (f t)) (c / (2 * Real.sqrt (f x))) x := by
  simpa using (hf.sqrt (ne_of_gt hpos))

/-- The Fisher–Rao speed is exactly twice the Euclidean speed of the
square-root embedding into the sphere. -/
theorem fisherRaoSpeed_eq_two_mul_sqrtSpeed (p v : ι → ℝ) (hp : ∀ i, 0 < p i) :
    fisherRaoSpeed p v = 2 * Real.sqrt (∑ i, (sqrtVelocity p v i) ^ 2) := by
  have hterm : ∀ i : ι, (sqrtVelocity p v i) ^ 2 = ((v i) ^ 2 / p i) / 4 := by
    intro i
    have hs : Real.sqrt (p i) ^ 2 = p i := Real.sq_sqrt (hp i).le
    unfold sqrtVelocity
    rw [div_pow, mul_pow, hs]
    ring
  have : (∑ i, (sqrtVelocity p v i) ^ 2) = (∑ i, (v i) ^ 2 / p i) / 4 := by
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun i _ => hterm i
  rw [fisherRaoSpeed, this, show (∑ i, (v i) ^ 2 / p i) / 4 = (1/4) * (∑ i, (v i) ^ 2 / p i) by ring,
    Real.sqrt_mul (by norm_num), show Real.sqrt (1/4) = 1/2 by
      rw [show (1/4:ℝ) = (1/2)^2 by norm_num, Real.sqrt_sq (by norm_num)]]
  ring

/-- The square-root embedding lands on the unit sphere for probability vectors. -/
theorem sqrt_embedding_sphere (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hp1 : ∑ i, p i = 1) :
    ∑ i, (Real.sqrt (p i)) ^ 2 = 1 := by
  rw [← hp1]
  exact Finset.sum_congr rfl fun i _ => Real.sq_sqrt (hp i)

/-! ## Sharpness: an explicit two-point family

To show that the constant `1` in `l1_le_fisherRao_length` cannot be improved we
compute both sides exactly for the curve

  `t ↦ ((1 + r·sin t)/2, (1 - r·sin t)/2)`,  `t ∈ [0, π/2]`,  `0 ≤ r < 1`,

in the interior of the 1-dimensional simplex.  Its `L¹` displacement is `r`
while its Fisher–Rao length is `arcsin r`; the ratio tends to `1` as `r → 0`,
and is `> 1` for every `r ∈ (0,1)` (so the inequality is always strict for
non-constant curves in this family). -/

namespace TwoPoint

/-- The two-point curve `t ↦ ((1 + r sin t)/2, (1 - r sin t)/2)`. -/
noncomputable def curve (r : ℝ) : ℝ → Fin 2 → ℝ :=
  fun t => ![(1 + r * Real.sin t) / 2, (1 - r * Real.sin t) / 2]

/-- Its velocity field. -/
noncomputable def vel (r : ℝ) : ℝ → Fin 2 → ℝ :=
  fun t => ![r * Real.cos t / 2, -(r * Real.cos t) / 2]

theorem hasDerivAt_curve (r : ℝ) (t : ℝ) (i : Fin 2) :
    HasDerivAt (fun s => curve r s i) (vel r t i) t := by
  have hs : HasDerivAt (fun s : ℝ => r * Real.sin s) (r * Real.cos t) t :=
    (Real.hasDerivAt_sin t).const_mul r
  fin_cases i
  · simpa [curve, vel] using (hs.const_add 1).div_const 2
  · simpa [curve, vel, sub_eq_add_neg] using ((hs.neg).const_add 1).div_const 2

theorem continuous_vel (r : ℝ) (i : Fin 2) : Continuous fun t => vel r t i := by
  fin_cases i <;> simp [vel] <;> fun_prop

theorem curve_sum (r : ℝ) (t : ℝ) : ∑ i, curve r t i = 1 := by
  simp [curve, Fin.sum_univ_two]; ring

theorem abs_r_sin_lt (r t : ℝ) (hr : |r| < 1) : |r * Real.sin t| < 1 := by
  have h1 : |r * Real.sin t| = |r| * |Real.sin t| := abs_mul _ _
  have h2 : |Real.sin t| ≤ 1 := Real.abs_sin_le_one t
  nlinarith [abs_nonneg r, abs_nonneg (Real.sin t)]

theorem curve_pos (r : ℝ) (hr : |r| < 1) (t : ℝ) (i : Fin 2) : 0 < curve r t i := by
  have h := abs_r_sin_lt r t hr
  rw [abs_lt] at h
  fin_cases i <;> simp [curve] <;> linarith [h.1, h.2]

/-- The Fisher–Rao speed of the two-point curve is `r cos t / √(1 - r² sin² t)`. -/
theorem speed_eq (r : ℝ) (hr : |r| < 1) (t : ℝ) (hcos : 0 ≤ r * Real.cos t) :
    fisherRaoSpeed (curve r t) (vel r t) =
      r * Real.cos t / Real.sqrt (1 - (r * Real.sin t) ^ 2) := by
  set u := r * Real.sin t with hu
  have hu1 : |u| < 1 := abs_r_sin_lt r t hr
  have hu1' : u ^ 2 < 1 := by
    exact (sq_lt_one_iff_abs_lt_one u).mpr hu1
  have hden : 0 < 1 - u ^ 2 := by linarith
  have hsq : Real.sqrt (1 - u ^ 2) ^ 2 = 1 - u ^ 2 := Real.sq_sqrt hden.le
  have hspos : 0 < Real.sqrt (1 - u ^ 2) := Real.sqrt_pos.mpr hden
  have hsum : ∑ i, (vel r t i) ^ 2 / curve r t i
      = (r * Real.cos t / Real.sqrt (1 - u ^ 2)) ^ 2 := by
    have h0 : (0:ℝ) < (1 + u) / 2 := by
      rw [abs_lt] at hu1; linarith [hu1.1]
    have h1 : (0:ℝ) < (1 - u) / 2 := by
      rw [abs_lt] at hu1; linarith [hu1.2]
    have h0' : (1 + u) ≠ 0 := by linarith
    have h1' : (1 - u) ≠ 0 := by intro h; linarith [h1, h]
    have hrhs : (r * Real.cos t / Real.sqrt (1 - u ^ 2)) ^ 2
        = (r * Real.cos t) ^ 2 / (1 - u ^ 2) := by
      rw [div_pow, hsq]
    rw [Fin.sum_univ_two, hrhs]
    simp only [curve, vel, Matrix.cons_val_zero, Matrix.cons_val_one, ← hu]
    field_simp
    ring
  rw [fisherRaoSpeed, hsum, Real.sqrt_sq (by positivity)]

/-- The `arcsin` antiderivative of the Fisher–Rao speed. -/
theorem hasDerivAt_arcsin_comp (r : ℝ) (hr : |r| < 1) (t : ℝ) :
    HasDerivAt (fun s => Real.arcsin (r * Real.sin s))
      (r * Real.cos t / Real.sqrt (1 - (r * Real.sin t) ^ 2)) t := by
  have hu1 : |r * Real.sin t| < 1 := abs_r_sin_lt r t hr
  rw [abs_lt] at hu1
  have hin : HasDerivAt (fun s : ℝ => r * Real.sin s) (r * Real.cos t) t :=
    (Real.hasDerivAt_sin t).const_mul r
  have hout : HasDerivAt Real.arcsin (1 / Real.sqrt (1 - (r * Real.sin t) ^ 2))
      (r * Real.sin t) :=
    Real.hasDerivAt_arcsin (by linarith [hu1.1]) (by linarith [hu1.2])
  have := hout.comp t hin
  simpa [Function.comp, div_eq_mul_inv, mul_comm, mul_assoc, mul_left_comm] using this

/-- **Exact Fisher–Rao length of the two-point family.** -/
theorem fisherRaoLength_eq_arcsin (r : ℝ) (hr0 : 0 ≤ r) (hr : r < 1) :
    fisherRaoLength (curve r) (vel r) 0 (Real.pi / 2) = Real.arcsin r := by
  have hrabs : |r| < 1 := by rw [abs_lt]; constructor <;> linarith
  have hcont : Continuous fun t : ℝ => r * Real.cos t / Real.sqrt (1 - (r * Real.sin t) ^ 2) := by
    have hden : ∀ t : ℝ, Real.sqrt (1 - (r * Real.sin t) ^ 2) ≠ 0 := by
      intro t
      have hu1 : |r * Real.sin t| < 1 := abs_r_sin_lt r t hrabs
      have : (r * Real.sin t) ^ 2 < 1 := (sq_lt_one_iff_abs_lt_one _).mpr hu1
      exact ne_of_gt (Real.sqrt_pos.mpr (by linarith))
    exact (continuous_const.mul Real.continuous_cos).div
      ((continuous_const.sub ((continuous_const.mul Real.continuous_sin).pow 2)).sqrt) hden
  have hEq : fisherRaoLength (curve r) (vel r) 0 (Real.pi / 2)
      = ∫ t in (0:ℝ)..(Real.pi / 2), r * Real.cos t / Real.sqrt (1 - (r * Real.sin t) ^ 2) := by
    refine intervalIntegral.integral_congr ?_
    intro t ht
    rw [Set.uIcc_of_le (by positivity)] at ht
    have hcos : 0 ≤ Real.cos t :=
      Real.cos_nonneg_of_mem_Icc ⟨by linarith [ht.1, Real.pi_pos], ht.2⟩
    exact speed_eq r hrabs t (by positivity)
  rw [hEq, intervalIntegral.integral_eq_sub_of_hasDerivAt
    (fun t _ => hasDerivAt_arcsin_comp r hrabs t) (hcont.intervalIntegrable _ _)]
  simp

/-- **Exact `L¹` displacement of the two-point family.** -/
theorem l1Dist_eq (r : ℝ) (hr0 : 0 ≤ r) :
    l1Dist (curve r (Real.pi / 2)) (curve r 0) = r := by
  simp only [l1Dist, curve, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
    Real.sin_pi_div_two, Real.sin_zero, mul_one, mul_zero]
  rw [show (1 + r) / 2 - (1 + 0) / 2 = r / 2 by ring,
    show (1 - r) / 2 - (1 - 0) / 2 = -(r / 2) by ring, abs_neg,
    abs_of_nonneg (by linarith : (0:ℝ) ≤ r / 2)]
  ring

/-- Consistency check: the main theorem applied to the two-point family
reproves the classical inequality `r ≤ arcsin r` on `[0,1)`. -/
theorem le_arcsin_of_two_point (r : ℝ) (hr0 : 0 ≤ r) (hr : r < 1) : r ≤ Real.arcsin r := by
  have hrabs : |r| < 1 := by rw [abs_lt]; constructor <;> linarith
  have := l1_le_fisherRao_length (p := curve r) (v := vel r)
    (a := 0) (b := Real.pi / 2) (by positivity)
    (hasDerivAt_curve r) (continuous_vel r) (fun t i => curve_pos r hrabs t i)
    (curve_sum r)
  rwa [l1Dist_eq r hr0, fisherRaoLength_eq_arcsin r hr0 hr] at this

/-- **Strictness.** For every non-degenerate member of the family the Fisher–Rao
length is *strictly* larger than the `L¹` displacement. -/
theorem l1_lt_fisherRaoLength (r : ℝ) (hr0 : 0 < r) (hr : r < 1) :
    l1Dist (curve r (Real.pi / 2)) (curve r 0) < fisherRaoLength (curve r) (vel r) 0 (Real.pi / 2) := by
  rw [l1Dist_eq r hr0.le, fisherRaoLength_eq_arcsin r hr0.le hr]
  have hpos : 0 < Real.arcsin r := Real.arcsin_pos.mpr hr0
  have hs : Real.sin (Real.arcsin r) < Real.arcsin r := Real.sin_lt hpos
  rwa [Real.sin_arcsin (by linarith) (by linarith)] at hs

/-- **Asymptotic sharpness.** For every `ε > 0` there is a member of the family
whose Fisher–Rao length is within a factor `1 + ε` of its `L¹` displacement.
Hence the constant `1` in `l1_le_fisherRao_length` is optimal. -/
theorem sharp (ε : ℝ) (hε : 0 < ε) :
    ∃ r : ℝ, 0 < r ∧ r < 1 ∧
      fisherRaoLength (curve r) (vel r) 0 (Real.pi / 2)
        ≤ (1 + ε) * l1Dist (curve r (Real.pi / 2)) (curve r 0) := by
  set d : ℝ := min 1 (Real.sqrt ε) with hd
  have hd1 : d ≤ 1 := min_le_left _ _
  have hdpos : 0 < d := lt_min one_pos (Real.sqrt_pos.mpr hε)
  have hdsq : d ^ 2 ≤ ε := by
    rcases le_total (Real.sqrt ε) 1 with h | h
    · have : d = Real.sqrt ε := by rw [hd, min_eq_right h]
      rw [this, Real.sq_sqrt hε.le]
    · have : d = 1 := by rw [hd, min_eq_left h]
      have : (1:ℝ) ≤ ε := by
        nlinarith [Real.sq_sqrt hε.le, Real.sqrt_nonneg ε]
      simpa [‹d = 1›] using this
  refine ⟨Real.sin d, Real.sin_pos_of_pos_of_lt_pi hdpos (by linarith [Real.pi_gt_three]), ?_, ?_⟩
  · calc Real.sin d < d := Real.sin_lt hdpos
      _ ≤ 1 := hd1
  · have hsin_pos : 0 < Real.sin d :=
      Real.sin_pos_of_pos_of_lt_pi hdpos (by linarith [Real.pi_gt_three])
    have hsin_lt1 : Real.sin d < 1 := lt_of_lt_of_le (Real.sin_lt hdpos) hd1
    rw [l1Dist_eq _ hsin_pos.le, fisherRaoLength_eq_arcsin _ hsin_pos.le hsin_lt1,
      Real.arcsin_sin (by linarith [Real.pi_gt_three]) (by linarith [Real.pi_gt_three])]
    have hcube : d - d ^ 3 / 4 < Real.sin d := Real.sin_gt_sub_cube hdpos hd1
    have hd2 : d ^ 2 ≤ 1 := by nlinarith
    have key : (1 + ε) * d ^ 2 / 4 ≤ ε := by nlinarith
    have step1 : d ≤ (1 + ε) * (d - d ^ 3 / 4) := by
      nlinarith [mul_nonneg hdpos.le (sub_nonneg.mpr key)]
    have step2 : (1 + ε) * (d - d ^ 3 / 4) ≤ (1 + ε) * Real.sin d := by nlinarith
    linarith

end TwoPoint

/-! ## Tensorization: the Fisher–Rao metric is Pythagorean under products

If two independent systems move simultaneously, the product distribution
`p ⊗ q` has velocity `v ⊗ q + p ⊗ w`, and its squared Fisher–Rao speed is the
sum of the squared speeds of the factors.  The cross term vanishes precisely
because a curve of probability vectors has velocity of total mass `0`. -/

section Tensor

variable {κ : Type*} [Fintype κ]

/-- Velocity vectors of curves in the simplex have total mass zero. -/
theorem sum_velocity_eq_zero {p v : ℝ → ι → ℝ} (t : ℝ)
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hp1 : ∀ t, ∑ i, p t i = 1) : ∑ i, v t i = 0 := by
  have hsum : HasDerivAt (fun s => ∑ i, p s i) (∑ i, v t i) t :=
    HasDerivAt.fun_sum fun i _ => hderiv t i
  have hconst : HasDerivAt (fun s : ℝ => ∑ i, p s i) 0 t := by
    have : (fun s : ℝ => ∑ i, p s i) = fun _ : ℝ => (1:ℝ) := funext hp1
    rw [this]
    exact hasDerivAt_const t 1
  exact hsum.unique hconst

/-- **Pythagoras for the Fisher–Rao metric.**  The squared Fisher–Rao norm of
the product tangent vector is the sum of the squared norms of the factors. -/
theorem fisherRao_sq_tensor (p v : ι → ℝ) (q w : κ → ℝ)
    (hp : ∀ i, 0 < p i) (hq : ∀ j, 0 < q j) (hw : ∑ j, w j = 0)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ j, q j = 1) :
    ∑ x : ι × κ, (v x.1 * q x.2 + p x.1 * w x.2) ^ 2 / (p x.1 * q x.2)
      = (∑ i, (v i) ^ 2 / p i) + (∑ j, (w j) ^ 2 / q j) := by
  have hinner : ∀ i : ι, ∑ j : κ, (v i * q j + p i * w j) ^ 2 / (p i * q j)
      = (v i) ^ 2 / p i + p i * (∑ j, (w j) ^ 2 / q j) := by
    intro i
    have hexp : ∀ j : κ, (v i * q j + p i * w j) ^ 2 / (p i * q j)
        = (v i) ^ 2 / p i * q j + 2 * v i * w j + p i * ((w j) ^ 2 / q j) := by
      intro j
      have h1 : p i ≠ 0 := ne_of_gt (hp i)
      have h2 : q j ≠ 0 := ne_of_gt (hq j)
      field_simp
      ring
    rw [Finset.sum_congr rfl fun j _ => hexp j, Finset.sum_add_distrib, Finset.sum_add_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum, hq1, hw, mul_one, mul_zero, add_zero]
  rw [Fintype.sum_prod_type, Finset.sum_congr rfl fun i _ => hinner i, Finset.sum_add_distrib,
    ← Finset.sum_mul, hp1, one_mul]

/-- The Fisher–Rao *speed* of a product curve is the Euclidean combination of
the two speeds: `‖(v,w)‖ = √(‖v‖² + ‖w‖²)`. -/
theorem fisherRaoSpeed_tensor (p v : ι → ℝ) (q w : κ → ℝ)
    (hp : ∀ i, 0 < p i) (hq : ∀ j, 0 < q j) (hw : ∑ j, w j = 0)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ j, q j = 1) :
    fisherRaoSpeed (fun x : ι × κ => p x.1 * q x.2)
        (fun x : ι × κ => v x.1 * q x.2 + p x.1 * w x.2)
      = Real.sqrt ((fisherRaoSpeed p v) ^ 2 + (fisherRaoSpeed q w) ^ 2) := by
  have h1 : (fisherRaoSpeed p v) ^ 2 = ∑ i, (v i) ^ 2 / p i :=
    Real.sq_sqrt (Finset.sum_nonneg fun i _ => div_nonneg (sq_nonneg _) (hp i).le)
  have h2 : (fisherRaoSpeed q w) ^ 2 = ∑ j, (w j) ^ 2 / q j :=
    Real.sq_sqrt (Finset.sum_nonneg fun j _ => div_nonneg (sq_nonneg _) (hq j).le)
  rw [h1, h2, fisherRaoSpeed, fisherRao_sq_tensor p v q w hp hq hw hp1 hq1]

end Tensor

/-! ## Statistical consequence: distinguishability of events

The `L¹` bound controls how much the probability of *any* event can change
along a curve: total variation distance is half the `L¹` distance. -/

/-- Total variation bound: the probability of any event differs by at most half
the `L¹` distance. -/
theorem abs_sub_event_le_half_l1Dist [DecidableEq ι] (p q : ι → ℝ) (S : Finset ι)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) :
    |(∑ i ∈ S, p i) - ∑ i ∈ S, q i| ≤ (1 / 2) * l1Dist p q := by
  have hS : (∑ i ∈ S, p i) - ∑ i ∈ S, q i = ∑ i ∈ S, (p i - q i) := by
    rw [Finset.sum_sub_distrib]
  have hzero : ∑ i ∈ S, (p i - q i) + ∑ i ∈ Sᶜ, (p i - q i) = 0 := by
    rw [Finset.sum_add_sum_compl, Finset.sum_sub_distrib, hp1, hq1, sub_self]
  have h1 : |∑ i ∈ S, (p i - q i)| ≤ ∑ i ∈ S, |p i - q i| :=
    Finset.abs_sum_le_sum_abs _ _
  have h2 : |∑ i ∈ Sᶜ, (p i - q i)| ≤ ∑ i ∈ Sᶜ, |p i - q i| :=
    Finset.abs_sum_le_sum_abs _ _
  have h3 : (∑ i ∈ S, |p i - q i|) + ∑ i ∈ Sᶜ, |p i - q i| = l1Dist p q :=
    Finset.sum_add_sum_compl _ _
  have h4 : ∑ i ∈ Sᶜ, (p i - q i) = -∑ i ∈ S, (p i - q i) := by linarith
  rw [h4, abs_neg] at h2
  rw [hS]
  linarith

/-- **Statistical form of the main theorem.**  Along a smooth curve of positive
probability vectors, the probability of any event `S` changes by at most half
the Fisher–Rao length of the curve. -/
theorem abs_sub_event_le_half_fisherRao_length [DecidableEq ι] {p v : ℝ → ι → ℝ} {a b : ℝ}
    (S : Finset ι) (hab : a ≤ b)
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i)
    (hpos : ∀ t i, 0 < p t i) (hp1 : ∀ t, ∑ i, p t i = 1) :
    |(∑ i ∈ S, p b i) - ∑ i ∈ S, p a i| ≤ (1 / 2) * fisherRaoLength p v a b := by
  have h1 := abs_sub_event_le_half_l1Dist (p b) (p a) S (hp1 b) (hp1 a)
  have h2 := l1_le_fisherRao_length hab hderiv hv hpos hp1
  linarith



/-! ## A localized strengthening

The hypotheses of `l1_le_fisherRao_length` ask for a globally defined positive
probability curve.  In fact only the behaviour on `[a,b]` matters; this is the
version one applies to curves (such as straight segments in the simplex) that
leave the simplex outside the interval of interest. -/

theorem l1_le_fisherRao_length_uIcc {p v : ℝ → ι → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hderiv : ∀ t ∈ Set.uIcc a b, ∀ i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, ContinuousOn (fun t => v t i) (Set.uIcc a b))
    (hpos : ∀ t ∈ Set.uIcc a b, ∀ i, 0 < p t i)
    (hp1 : ∀ t ∈ Set.uIcc a b, ∑ i, p t i = 1) :
    l1Dist (p b) (p a) ≤ fisherRaoLength p v a b := by
  have hcontP : ∀ i : ι, ContinuousOn (fun t => p t i) (Set.uIcc a b) := fun i t ht =>
    ((hderiv t ht i).continuousAt).continuousWithinAt
  have hcontS : ContinuousOn (fun t => fisherRaoSpeed (p t) (v t)) (Set.uIcc a b) := by
    refine ContinuousOn.sqrt (continuousOn_finset_sum _ fun i _ => ?_)
    exact ((hv i).pow 2).div (hcontP i) fun t ht => ne_of_gt (hpos t ht i)
  have hFTC : ∀ i : ι, p b i - p a i = ∫ t in a..b, v t i := fun i =>
    (integral_eq_sub_of_hasDerivAt (fun t ht => hderiv t ht i)
      ((hv i).intervalIntegrable)).symm
  have hsum : l1Dist (p b) (p a) ≤ ∫ t in a..b, ∑ i, |v t i| := by
    have hswap : (∫ t in a..b, ∑ i, |v t i|) = ∑ i, ∫ t in a..b, |v t i| :=
      intervalIntegral.integral_finset_sum fun i _ => ((hv i).abs).intervalIntegrable
    rw [hswap]
    refine Finset.sum_le_sum fun i _ => ?_
    rw [hFTC i]
    exact abs_integral_le_integral_abs hab
  refine hsum.trans (intervalIntegral.integral_mono_on hab
    ((continuousOn_finset_sum _ fun i _ => (hv i).abs).intervalIntegrable)
    hcontS.intervalIntegrable ?_)
  intro t ht
  have ht' : t ∈ Set.uIcc a b := by rw [Set.uIcc_of_le hab]; exact ht
  exact l1_speed_le_fisherRaoSpeed (p t) (v t) (hpos t ht') (hp1 t ht')

/-! ## Hellinger bridge

The squared Hellinger distance `H²(p,q) = ½‖√p − √q‖²` is dominated by the
total variation distance, hence by half the Fisher–Rao length.  This links the
`L¹` length bound to the square-root (sphere) picture of Fisher–Rao geometry. -/

/-- Coordinatewise Hellinger–`L¹` comparison. -/
theorem sq_sub_sqrt_le_abs_sub {x y : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) :
    (Real.sqrt x - Real.sqrt y) ^ 2 ≤ |x - y| := by
  have hx' : Real.sqrt x ^ 2 = x := Real.sq_sqrt hx
  have hy' : Real.sqrt y ^ 2 = y := Real.sq_sqrt hy
  have hxn : 0 ≤ Real.sqrt x := Real.sqrt_nonneg x
  have hyn : 0 ≤ Real.sqrt y := Real.sqrt_nonneg y
  rcases le_total (Real.sqrt y) (Real.sqrt x) with h | h
  · rw [abs_of_nonneg (by nlinarith)]; nlinarith
  · rw [abs_of_nonpos (by nlinarith)]; nlinarith

/-- `‖√p − √q‖² ≤ ‖p − q‖₁`: twice the squared Hellinger distance is at most the
`L¹` distance. -/
theorem sq_dist_sqrt_le_l1Dist (p q : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i) :
    ∑ i, (Real.sqrt (p i) - Real.sqrt (q i)) ^ 2 ≤ l1Dist p q :=
  Finset.sum_le_sum fun i _ => sq_sub_sqrt_le_abs_sub (hp i) (hq i)

/-- **Hellinger form of the main theorem.**  The squared Hellinger distance
between the endpoints of a smooth curve of positive probability vectors is at
most half its Fisher–Rao length. -/
theorem hellingerSq_le_half_fisherRao_length {p v : ℝ → ι → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i)
    (hpos : ∀ t i, 0 < p t i) (hp1 : ∀ t, ∑ i, p t i = 1) :
    (1 / 2) * ∑ i, (Real.sqrt (p b i) - Real.sqrt (p a i)) ^ 2
      ≤ (1 / 2) * fisherRaoLength p v a b := by
  have h1 := sq_dist_sqrt_le_l1Dist (p b) (p a) (fun i => (hpos b i).le) (fun i => (hpos a i).le)
  have h2 := l1_le_fisherRao_length hab hderiv hv hpos hp1
  linarith

/-! ## The sharper spherical chord bound

The `L¹` bound is one shadow of a stronger geometric fact: the *chord* of the
square-root embedding is at most half the Fisher–Rao length.  The proof is the
same Cauchy–Schwarz/FTC mechanism, but applied to the single scalar function
`t ↦ ⟨Δ, √p t⟩ / ‖Δ‖` where `Δ = √p b − √p a`; this device replaces
vector-valued integration by an ordinary one-dimensional integral.

Note that no simplex constraint is needed here: the statement is purely
metric. -/

/-- Velocity of the square-root embedding along the curve. -/
noncomputable def sqrtVel (p v : ℝ → ι → ℝ) (t : ℝ) (i : ι) : ℝ :=
  v t i / (2 * Real.sqrt (p t i))

omit [Fintype ι] in
theorem continuous_sqrtVel {p v : ℝ → ι → ℝ}
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i) (i : ι) :
    Continuous fun t => sqrtVel p v t i := by
  have hp : Continuous fun t => Real.sqrt (p t i) := (continuous_coord hderiv i).sqrt
  exact (hv i).div (continuous_const.mul hp) fun t =>
    ne_of_gt (mul_pos two_pos (Real.sqrt_pos.mpr (hpos t i)))

/-- Half the Fisher–Rao speed is the Euclidean speed of the square-root curve. -/
theorem sqrtVel_norm_eq {p v : ℝ → ι → ℝ} (hpos : ∀ t i, 0 < p t i) (t : ℝ) :
    Real.sqrt (∑ i, (sqrtVel p v t i) ^ 2) = (1 / 2) * fisherRaoSpeed (p t) (v t) := by
  rw [fisherRaoSpeed_eq_two_mul_sqrtSpeed (p t) (v t) (hpos t)]
  simp only [sqrtVelocity, sqrtVel]
  ring

/-- **Chord bound.**  The Euclidean chord of the square-root embedding between
the endpoints is at most half the Fisher–Rao length of the curve. -/
theorem sqrt_chord_le_half_fisherRao_length {p v : ℝ → ι → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i) (hpos : ∀ t i, 0 < p t i) :
    Real.sqrt (∑ i, (Real.sqrt (p b i) - Real.sqrt (p a i)) ^ 2)
      ≤ (1 / 2) * fisherRaoLength p v a b := by
  set D : ℝ := Real.sqrt (∑ i, (Real.sqrt (p b i) - Real.sqrt (p a i)) ^ 2) with hD
  set Δ : ι → ℝ := fun i => Real.sqrt (p b i) - Real.sqrt (p a i) with hΔ
  have hDnn : 0 ≤ D := Real.sqrt_nonneg _
  have hDsq : D ^ 2 = ∑ i, (Δ i) ^ 2 :=
    Real.sq_sqrt (Finset.sum_nonneg fun i _ => sq_nonneg _)
  have hlen : 0 ≤ fisherRaoLength p v a b := fisherRaoLength_nonneg p v hab
  rcases eq_or_lt_of_le hDnn with hD0 | hDpos
  · rw [← hD0]; linarith
  -- the scalar test function
  have hsqrtDeriv : ∀ t i, HasDerivAt (fun s => Real.sqrt (p s i)) (sqrtVel p v t i) t :=
    fun t i => hasDerivAt_sqrt_coord (hderiv t i) (hpos t i)
  have hg : ∀ t : ℝ, HasDerivAt (fun s => (∑ i, Δ i * Real.sqrt (p s i)) / D)
      ((∑ i, Δ i * sqrtVel p v t i) / D) t := by
    intro t
    exact (HasDerivAt.fun_sum fun i _ => (hsqrtDeriv t i).const_mul (Δ i)).div_const D
  have hgcont : Continuous fun t => (∑ i, Δ i * sqrtVel p v t i) / D :=
    (continuous_finset_sum _ fun i _ =>
      continuous_const.mul (continuous_sqrtVel hderiv hv hpos i)).div_const D
  -- endpoint values
  have hend : (∑ i, Δ i * Real.sqrt (p b i)) / D - (∑ i, Δ i * Real.sqrt (p a i)) / D = D := by
    rw [div_sub_div_same, ← Finset.sum_sub_distrib]
    have : ∑ i, (Δ i * Real.sqrt (p b i) - Δ i * Real.sqrt (p a i)) = D ^ 2 := by
      rw [hDsq]
      exact Finset.sum_congr rfl fun i _ => by rw [hΔ]; ring
    rw [this, sq]
    field_simp
  -- pointwise Cauchy–Schwarz bound on the derivative
  have hbound : ∀ t : ℝ, (∑ i, Δ i * sqrtVel p v t i) / D ≤ (1 / 2) * fisherRaoSpeed (p t) (v t) := by
    intro t
    have hCS := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ Δ (fun i => sqrtVel p v t i)
    have hW : Real.sqrt (∑ i, (sqrtVel p v t i) ^ 2) = (1 / 2) * fisherRaoSpeed (p t) (v t) :=
      sqrtVel_norm_eq hpos t
    have habs : |∑ i, Δ i * sqrtVel p v t i| ≤ D * Real.sqrt (∑ i, (sqrtVel p v t i) ^ 2) := by
      have h1 : |∑ i, Δ i * sqrtVel p v t i| = Real.sqrt ((∑ i, Δ i * sqrtVel p v t i) ^ 2) :=
        (Real.sqrt_sq_eq_abs _).symm
      rw [h1, ← Real.sqrt_mul (by positivity) , ← hDsq]
      refine Real.sqrt_le_sqrt ?_
      calc (∑ i, Δ i * sqrtVel p v t i) ^ 2
          ≤ (∑ i, (Δ i) ^ 2) * (∑ i, (sqrtVel p v t i) ^ 2) := hCS
        _ = D ^ 2 * ∑ i, (sqrtVel p v t i) ^ 2 := by rw [hDsq]
    rw [hW] at habs
    rw [div_le_iff₀ hDpos]
    calc ∑ i, Δ i * sqrtVel p v t i ≤ |∑ i, Δ i * sqrtVel p v t i| := le_abs_self _
      _ ≤ D * ((1 / 2) * fisherRaoSpeed (p t) (v t)) := habs
      _ = (1 / 2) * fisherRaoSpeed (p t) (v t) * D := by ring
  -- integrate
  have hFTC : (∫ t in a..b, (∑ i, Δ i * sqrtVel p v t i) / D) = D := by
    rw [integral_eq_sub_of_hasDerivAt (fun t _ => hg t) (hgcont.intervalIntegrable a b), hend]
  have hmono : (∫ t in a..b, (∑ i, Δ i * sqrtVel p v t i) / D)
      ≤ ∫ t in a..b, (1 / 2) * fisherRaoSpeed (p t) (v t) := by
    refine intervalIntegral.integral_mono_on hab (hgcont.intervalIntegrable a b)
      ((continuous_const.mul (continuous_fisherRaoSpeed hderiv hv hpos)).intervalIntegrable a b)
      fun t _ => hbound t
  rw [hFTC] at hmono
  rwa [intervalIntegral.integral_const_mul] at hmono

/-- **Bhattacharyya / Hellinger form of the chord bound.**  With
`BC(p,q) = ∑ᵢ √(pᵢ qᵢ)` the Bhattacharyya coefficient (the inner product of the
square-root embeddings, cf. the Arrow–Curvature catalog file), the squared
Hellinger distance `1 - BC` between the endpoints is at most `L²/8`, where `L`
is the Fisher–Rao length.  This is strictly stronger than the `L¹` bound for
short curves. -/
theorem one_sub_bhattacharyya_le_sq_fisherRao_length {p v : ℝ → ι → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hderiv : ∀ t i, HasDerivAt (fun s => p s i) (v t i) t)
    (hv : ∀ i, Continuous fun t => v t i)
    (hpos : ∀ t i, 0 < p t i) (hp1 : ∀ t, ∑ i, p t i = 1) :
    1 - ∑ i, Real.sqrt (p b i * p a i) ≤ (1 / 8) * (fisherRaoLength p v a b) ^ 2 := by
  have hchord := sqrt_chord_le_half_fisherRao_length hab hderiv hv hpos
  have hnn : 0 ≤ ∑ i, (Real.sqrt (p b i) - Real.sqrt (p a i)) ^ 2 :=
    Finset.sum_nonneg fun i _ => sq_nonneg _
  have hsq : (Real.sqrt (∑ i, (Real.sqrt (p b i) - Real.sqrt (p a i)) ^ 2)) ^ 2
      = ∑ i, (Real.sqrt (p b i) - Real.sqrt (p a i)) ^ 2 := Real.sq_sqrt hnn
  have hexpand : ∑ i, (Real.sqrt (p b i) - Real.sqrt (p a i)) ^ 2
      = 2 - 2 * ∑ i, Real.sqrt (p b i * p a i) := by
    have hterm : ∀ i : ι, (Real.sqrt (p b i) - Real.sqrt (p a i)) ^ 2
        = p b i + p a i - 2 * Real.sqrt (p b i * p a i) := by
      intro i
      rw [Real.sqrt_mul (hpos b i).le]
      have h1 : Real.sqrt (p b i) ^ 2 = p b i := Real.sq_sqrt (hpos b i).le
      have h2 : Real.sqrt (p a i) ^ 2 = p a i := Real.sq_sqrt (hpos a i).le
      nlinarith [h1, h2]
    rw [Finset.sum_congr rfl fun i _ => hterm i, Finset.sum_sub_distrib,
      Finset.sum_add_distrib, hp1 a, hp1 b, ← Finset.mul_sum]
    norm_num
  have hlen : 0 ≤ fisherRaoLength p v a b := fisherRaoLength_nonneg p v hab
  have hchordnn : 0 ≤ Real.sqrt (∑ i, (Real.sqrt (p b i) - Real.sqrt (p a i)) ^ 2) :=
    Real.sqrt_nonneg _
  nlinarith [hchord, hsq, hexpand, hchordnn, hlen]

/-! ## The discrete (Markov-path) length bound

Dropping smoothness entirely, one can still bound the `L¹` displacement of a
finite path of distributions by a sum of *Bhattacharyya angles*
`arccos BC(pᵏ, pᵏ⁺¹)`, which is the natural discrete Fisher–Rao length:
`arccos BC` is precisely the spherical distance between the square-root
embeddings.  The single-step inequality is Le Cam's `‖p−q‖₁ ≤ 2√(1 − BC²)`,
proved by the same Cauchy–Schwarz mechanism as the infinitesimal bound. -/

/-- The Bhattacharyya coefficient `∑ᵢ √(pᵢ qᵢ)`; it is the inner product of the
square-root embeddings, i.e. the cosine of the spherical angle between them. -/
noncomputable def bhattacharyya (p q : ι → ℝ) : ℝ := ∑ i, Real.sqrt (p i * q i)

theorem bhattacharyya_nonneg (p q : ι → ℝ) : 0 ≤ bhattacharyya p q :=
  Finset.sum_nonneg fun _ _ => Real.sqrt_nonneg _

/-- Sum of the squares of the coordinatewise sums of square roots. -/
theorem sum_add_sqrt_sq (p q : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) :
    ∑ i, (Real.sqrt (p i) + Real.sqrt (q i)) ^ 2 = 2 + 2 * bhattacharyya p q := by
  have hterm : ∀ i : ι, (Real.sqrt (p i) + Real.sqrt (q i)) ^ 2
      = p i + q i + 2 * Real.sqrt (p i * q i) := by
    intro i
    rw [Real.sqrt_mul (hp i)]
    nlinarith [Real.sq_sqrt (hp i), Real.sq_sqrt (hq i)]
  rw [Finset.sum_congr rfl fun i _ => hterm i, Finset.sum_add_distrib, Finset.sum_add_distrib,
    hp1, hq1, ← Finset.mul_sum]
  norm_num [bhattacharyya]

theorem sum_sub_sqrt_sq (p q : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) :
    ∑ i, (Real.sqrt (p i) - Real.sqrt (q i)) ^ 2 = 2 - 2 * bhattacharyya p q := by
  have hterm : ∀ i : ι, (Real.sqrt (p i) - Real.sqrt (q i)) ^ 2
      = p i + q i - 2 * Real.sqrt (p i * q i) := by
    intro i
    rw [Real.sqrt_mul (hp i)]
    nlinarith [Real.sq_sqrt (hp i), Real.sq_sqrt (hq i)]
  rw [Finset.sum_congr rfl fun i _ => hterm i, Finset.sum_sub_distrib, Finset.sum_add_distrib,
    hp1, hq1, ← Finset.mul_sum]
  norm_num [bhattacharyya]

/-- **Le Cam's inequality.**  `‖p − q‖₁ ≤ 2√(1 − BC(p,q)²)`: the `L¹` distance is
at most twice the sine of the Bhattacharyya angle. -/
theorem l1Dist_le_two_mul_sqrt_one_sub_bhattacharyya_sq (p q : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i) (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) :
    l1Dist p q ≤ 2 * Real.sqrt (1 - (bhattacharyya p q) ^ 2) := by
  have hfac : ∀ i : ι, |p i - q i|
      = |Real.sqrt (p i) - Real.sqrt (q i)| * (Real.sqrt (p i) + Real.sqrt (q i)) := by
    intro i
    have h1 : Real.sqrt (p i) ^ 2 = p i := Real.sq_sqrt (hp i)
    have h2 : Real.sqrt (q i) ^ 2 = q i := Real.sq_sqrt (hq i)
    have hnn : 0 ≤ Real.sqrt (p i) + Real.sqrt (q i) := by positivity
    rw [← abs_of_nonneg hnn, ← abs_mul]
    congr 1
    nlinarith [h1, h2]
  have hCS := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun i => |Real.sqrt (p i) - Real.sqrt (q i)|) (fun i => Real.sqrt (p i) + Real.sqrt (q i))
  have habs : ∀ i : ι, |Real.sqrt (p i) - Real.sqrt (q i)| ^ 2
      = (Real.sqrt (p i) - Real.sqrt (q i)) ^ 2 := fun i => sq_abs _
  simp only [habs] at hCS
  rw [sum_sub_sqrt_sq p q hp hq hp1 hq1, sum_add_sqrt_sq p q hp hq hp1 hq1] at hCS
  have hl1 : l1Dist p q = ∑ i, |Real.sqrt (p i) - Real.sqrt (q i)|
      * (Real.sqrt (p i) + Real.sqrt (q i)) :=
    Finset.sum_congr rfl fun i _ => hfac i
  have hsq : (l1Dist p q) ^ 2 ≤ 4 * (1 - (bhattacharyya p q) ^ 2) := by
    rw [hl1]
    nlinarith [hCS]
  have hnn : 0 ≤ l1Dist p q := l1Dist_nonneg p q
  have h4 : (0:ℝ) ≤ 1 - (bhattacharyya p q) ^ 2 := by nlinarith [sq_nonneg (l1Dist p q)]
  nlinarith [Real.sq_sqrt h4, Real.sqrt_nonneg (1 - (bhattacharyya p q) ^ 2)]

/-- **Single-step discrete length bound.**  The `L¹` distance is at most twice
the Bhattacharyya angle `arccos BC(p,q)`, i.e. at most the spherical distance
between the square-root embeddings. -/
theorem l1Dist_le_two_mul_arccos_bhattacharyya (p q : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i) (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) :
    l1Dist p q ≤ 2 * Real.arccos (bhattacharyya p q) := by
  have h1 := l1Dist_le_two_mul_sqrt_one_sub_bhattacharyya_sq p q hp hq hp1 hq1
  have h2 : Real.sqrt (1 - (bhattacharyya p q) ^ 2) = Real.sin (Real.arccos (bhattacharyya p q)) :=
    (Real.sin_arccos _).symm
  have h3 : Real.sin (Real.arccos (bhattacharyya p q)) ≤ Real.arccos (bhattacharyya p q) :=
    Real.sin_le (Real.arccos_nonneg _)
  rw [h2] at h1
  linarith

/-- **Discrete Fisher–Rao length bound.**  For any finite path of probability
vectors, the `L¹` displacement between the endpoints is at most the sum of the
Bhattacharyya angles of the consecutive steps — the discrete counterpart of
`l1_le_fisherRao_length`, requiring no smoothness at all. -/
theorem l1Dist_le_sum_arccos_bhattacharyya (P : ℕ → ι → ℝ)
    (hp : ∀ k i, 0 ≤ P k i) (hp1 : ∀ k, ∑ i, P k i = 1) (N : ℕ) :
    l1Dist (P N) (P 0) ≤ ∑ k ∈ Finset.range N, 2 * Real.arccos (bhattacharyya (P k) (P (k + 1))) := by
  induction N with
  | zero => simp [l1Dist]
  | succ n ih =>
      have hstep : l1Dist (P (n + 1)) (P n)
          ≤ 2 * Real.arccos (bhattacharyya (P n) (P (n + 1))) := by
        rw [l1Dist_comm]
        exact l1Dist_le_two_mul_arccos_bhattacharyya (P n) (P (n + 1)) (hp n) (hp (n + 1))
          (hp1 n) (hp1 (n + 1))
      have htri : l1Dist (P (n + 1)) (P 0) ≤ l1Dist (P (n + 1)) (P n) + l1Dist (P n) (P 0) :=
        l1Dist_triangle _ _ _
      rw [Finset.sum_range_succ]
      linarith

end FisherRao