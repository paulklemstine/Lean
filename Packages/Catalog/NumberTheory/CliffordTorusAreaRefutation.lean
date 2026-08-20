import Mathlib
import Catalog.Shared.FourthDimensionPlayground

/-!
# Hopf-invariant tori in `S³`: the Clifford torus maximizes, and does not minimize, area

`FourthDimensionPlayground.clifford_torus_equator` identifies the Clifford torus
`|z| = |w|` inside the unit three-sphere as the Hopf preimage of the equator of
`S²`.  A Phase-A conjecture proposed that, among embedded tori of `S³` invariant
under the diagonal circle action and separating the two coordinate circles, the
Clifford torus *uniquely minimizes area*.

This file refutes that conjecture inside the most natural test family — the
Hopf-invariant flat tori
`T r = { (z, w) : ‖z‖ = r, ‖w‖ = √(1 - r²) }`, `0 < r < 1` — and proves the
corrected statement: the Clifford torus is the unique **maximizer** of area in
this family, while the area infimum over the family is `0`, so no minimizer
exists at all.

The area is not postulated: it is computed from the first fundamental form of the
explicit parametrization `(s, t) ↦ (r e^{is}, √(1-r²) e^{it})`, whose tangent
vectors are verified to be genuine derivatives (`hasDerivAt_param_fst`,
`hasDerivAt_param_snd`), and then integrated over the fundamental square.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):
Diagonal-circle-invariant tori separating the two coordinate circles form a
one-parameter family `T r`; the conjecture predicts the Clifford torus `r = √2/2`
to be the unique area minimizer.

Experiment (Experimenter):
The induced metric of the parametrization is `E = r²`, `F = 0`, `G = 1 - r²`,
hence `area (T r) = 4π² r √(1 - r²)`.  Numerically: `r = 0.7071 → 19.739`,
`r = 0.5 → 17.093`, `r = 0.1 → 3.929`, `r = 0.01 → 0.395`.  The value at the
Clifford parameter is the *largest*, not the smallest, and the family's areas
tend to `0`.

Analysis (Analyst):
By AM–GM, `r √(1 - r²) ≤ 1/2` with equality exactly at `r² = 1/2`, so the
Clifford torus is the unique maximizer, of area `2π²`.  The conjecture is
therefore false as stated; what is true (Marques–Neves) is minimality among
*minimal* tori, i.e. a constrained problem, and the correct unconstrained
extremal property of the Clifford torus in this symmetry class is maximality.
The failure is of type "false as stated / needs a different variational class",
not "true but hard".

Critique (Critic):
The refutation is not vacuous: every `T r` with `0 < r < 1` is a genuine embedded
torus in `S³` (`param_mem_sphere`), is invariant under the diagonal circle action
(`param_diagonal_invariant`), and separates the two coordinate circles in the
concrete sense that the first coordinate circle has `‖z‖ = 1 > r` while the
second has `‖z‖ = 0 < r` (`torus_separates_coordinate_circles`).  The degenerate
parameters `r = 0, 1` are excluded, and the area is derived rather than assumed.

Synthesis (Principal Investigator):
Within the Hopf-symmetric class, area is the single function `4π² r √(1-r²)`;
its unique interior critical point is the Clifford torus, and it is a maximum.
Any correct extremality statement for the Clifford torus must therefore be
constrained (minimal surfaces, Willmore energy) rather than a plain area
minimization.
-- !-- Lab Notes -- !--
-/

open Complex Real ComplexConjugate intervalIntegral

namespace CliffordTorusArea

noncomputable section

/-- The circle of radius `a` in `ℂ`, parametrized by angle. -/
def circleMap' (a s : ℝ) : ℂ := (a : ℂ) * Complex.exp (s * Complex.I)

/-- The Hopf-invariant flat torus `T r ⊂ S³`. -/
def IsTorusPoint (r : ℝ) (z w : ℂ) : Prop := ‖z‖ = r ∧ ‖w‖ = Real.sqrt (1 - r ^ 2)

/-- Explicit parametrization of `T r` by the square `(s, t)`. -/
def param (r s t : ℝ) : ℂ × ℂ := (circleMap' r s, circleMap' (Real.sqrt (1 - r ^ 2)) t)

/-- Candidate tangent vector in the `s`-direction. -/
def tangentS (r s : ℝ) : ℂ × ℂ := ((r : ℂ) * Complex.I * Complex.exp (s * Complex.I), 0)

/-- Candidate tangent vector in the `t`-direction. -/
def tangentT (r t : ℝ) : ℂ × ℂ :=
  (0, ((Real.sqrt (1 - r ^ 2) : ℝ) : ℂ) * Complex.I * Complex.exp (t * Complex.I))

/-- The real (Euclidean) inner product of `ℂ² ≅ ℝ⁴`. -/
def innerR (a b : ℂ × ℂ) : ℝ := (a.1 * conj b.1).re + (a.2 * conj b.2).re

/-! ### The parametrization and its derivatives -/

theorem circleMap'_norm (a s : ℝ) (ha : 0 ≤ a) : ‖circleMap' a s‖ = a := by
  simp [circleMap', Complex.norm_exp, abs_of_nonneg ha]

theorem hasDerivAt_circleMap' (a s : ℝ) :
    HasDerivAt (circleMap' a) ((a : ℂ) * Complex.I * Complex.exp (s * Complex.I)) s := by
  have h1 : HasDerivAt (fun s : ℝ => (s : ℂ) * Complex.I) Complex.I s := by
    simpa using (Complex.ofRealCLM.hasDerivAt (x := s)).mul_const Complex.I
  have h2 := (h1.cexp).const_mul (a : ℂ)
  unfold circleMap'
  convert h2 using 1
  ring

/-- `tangentS` really is the partial derivative of the parametrization in `s`. -/
theorem hasDerivAt_param_fst (r t : ℝ) (s : ℝ) :
    HasDerivAt (fun s : ℝ => (param r s t).1) (tangentS r s).1 s :=
  hasDerivAt_circleMap' r s

/-- `tangentT` really is the partial derivative of the parametrization in `t`. -/
theorem hasDerivAt_param_snd (r s : ℝ) (t : ℝ) :
    HasDerivAt (fun t : ℝ => (param r s t).2) (tangentT r t).2 t :=
  hasDerivAt_circleMap' _ t

/-- The parametrized torus lies on the unit three-sphere. -/
theorem param_mem_sphere (r s t : ℝ) (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    ‖(param r s t).1‖ ^ 2 + ‖(param r s t).2‖ ^ 2 = 1 := by
  have hnn : (0:ℝ) ≤ 1 - r ^ 2 := by nlinarith
  rw [param]
  simp only [circleMap'_norm r s hr0, circleMap'_norm _ t (Real.sqrt_nonneg _)]
  rw [Real.sq_sqrt hnn]
  ring

/-- Every point of `T r` is realized by the parametrization, and conversely. -/
theorem param_isTorusPoint (r s t : ℝ) (hr0 : 0 ≤ r) :
    IsTorusPoint r (param r s t).1 (param r s t).2 :=
  ⟨circleMap'_norm r s hr0, circleMap'_norm _ t (Real.sqrt_nonneg _)⟩

/-- **Diagonal circle invariance.**  Multiplying both coordinates by the phase
`e^{iθ}` moves the parametrized point to another point of the same torus. -/
theorem param_diagonal_invariant (r s t θ : ℝ) :
    (Complex.exp (θ * Complex.I) * (param r s t).1,
      Complex.exp (θ * Complex.I) * (param r s t).2) = param r (s + θ) (t + θ) := by
  have hs : ((s + θ : ℝ) : ℂ) * Complex.I = (s : ℂ) * Complex.I + (θ : ℂ) * Complex.I := by
    push_cast; ring
  have ht : ((t + θ : ℝ) : ℂ) * Complex.I = (t : ℂ) * Complex.I + (θ : ℂ) * Complex.I := by
    push_cast; ring
  simp only [param, circleMap', Prod.mk.injEq, hs, ht, Complex.exp_add]
  constructor <;> ring

/-- **Separation of the coordinate circles.**  For `0 < r < 1` the torus `T r` sits
strictly between the circle `{(z,0) : ‖z‖ = 1}` and the circle `{(0,w) : ‖w‖ = 1}`,
measured by the modulus of the first coordinate. -/
theorem torus_separates_coordinate_circles (r : ℝ) (hr0 : 0 < r) (hr1 : r < 1)
    (z w : ℂ) (h : IsTorusPoint r z w) (z₁ : ℂ) (hz₁ : ‖z₁‖ = 1) :
    ‖z‖ < ‖z₁‖ ∧ ‖(0 : ℂ)‖ < ‖z‖ := by
  refine ⟨?_, ?_⟩ <;> rw [h.1] <;> simp [hz₁, hr1, hr0]

/-! ### The first fundamental form -/

theorem innerR_self_fst (a : ℂ) : innerR (a, 0) (a, 0) = ‖a‖ ^ 2 := by
  simp [innerR, Complex.mul_conj, Complex.sq_norm]

theorem coeff_E (r s : ℝ) (hr : 0 ≤ r) : innerR (tangentS r s) (tangentS r s) = r ^ 2 := by
  have hnorm : ‖(r : ℂ) * Complex.I * Complex.exp (s * Complex.I)‖ = r := by
    simp [Complex.norm_exp, abs_of_nonneg hr]
  simp only [innerR, tangentS, Complex.mul_conj, Complex.ofReal_re, ← Complex.sq_norm, hnorm]
  norm_num

theorem coeff_G (r t : ℝ) (hr1 : r ≤ 1) (hr0 : -1 ≤ r) :
    innerR (tangentT r t) (tangentT r t) = 1 - r ^ 2 := by
  have hnn : (0:ℝ) ≤ 1 - r ^ 2 := by nlinarith
  have hnorm : ‖((Real.sqrt (1 - r ^ 2) : ℝ) : ℂ) * Complex.I * Complex.exp (t * Complex.I)‖
      = Real.sqrt (1 - r ^ 2) := by
    simp [Complex.norm_exp, abs_of_nonneg (Real.sqrt_nonneg (1 - r ^ 2))]
  simp only [innerR, tangentT, Complex.mul_conj, Complex.ofReal_re, ← Complex.sq_norm, hnorm]
  norm_num [Real.sq_sqrt hnn]

/-- The parametrization is conformal-orthogonal: the two tangent directions are
perpendicular. -/
theorem coeff_F (r s t : ℝ) : innerR (tangentS r s) (tangentT r t) = 0 := by
  simp [innerR, tangentS, tangentT]

/-! ### Area of the Hopf-invariant tori -/

/-- Area of the torus `T r`, as the integral of `√(EG - F²)` over the fundamental
square of the parametrization. -/
def area (r : ℝ) : ℝ :=
  ∫ s in (0:ℝ)..(2 * π), ∫ t in (0:ℝ)..(2 * π),
    Real.sqrt (innerR (tangentS r s) (tangentS r s) * innerR (tangentT r t) (tangentT r t)
      - innerR (tangentS r s) (tangentT r t) ^ 2)

/-- **Area formula** for the Hopf-invariant flat tori. -/
theorem area_eq (r : ℝ) (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    area r = 4 * π ^ 2 * (r * Real.sqrt (1 - r ^ 2)) := by
  have hnn : (0:ℝ) ≤ 1 - r ^ 2 := by nlinarith
  have hval : ∀ s t : ℝ,
      Real.sqrt (innerR (tangentS r s) (tangentS r s) * innerR (tangentT r t) (tangentT r t)
        - innerR (tangentS r s) (tangentT r t) ^ 2) = r * Real.sqrt (1 - r ^ 2) := by
    intro s t
    rw [coeff_E r s hr0, coeff_G r t hr1 (by linarith), coeff_F r s t]
    have hsq : r ^ 2 * (1 - r ^ 2) - (0:ℝ) ^ 2 = (r * Real.sqrt (1 - r ^ 2)) ^ 2 := by
      rw [mul_pow, Real.sq_sqrt hnn]; ring
    rw [hsq, Real.sqrt_sq (by positivity)]
  simp only [area, hval, intervalIntegral.integral_const, smul_eq_mul, sub_zero]
  ring

/-- The Clifford torus is the member `r = √2/2` of the family, with area `2π²`. -/
theorem clifford_area : area (Real.sqrt 2 / 2) = 2 * π ^ 2 := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hs0 : (0:ℝ) < Real.sqrt 2 := by positivity
  have hr0 : 0 ≤ Real.sqrt 2 / 2 := by positivity
  have hr1 : Real.sqrt 2 / 2 ≤ 1 := by nlinarith
  have hsq : 1 - (Real.sqrt 2 / 2) ^ 2 = (Real.sqrt 2 / 2) ^ 2 := by nlinarith
  rw [area_eq _ hr0 hr1, hsq, Real.sqrt_sq hr0]
  nlinarith

/-- **The Clifford torus uniquely maximizes area** in the Hopf-invariant family. -/
theorem area_le_clifford (r : ℝ) (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    area r ≤ 2 * π ^ 2 := by
  have hnn : (0:ℝ) ≤ 1 - r ^ 2 := by nlinarith
  have hs := Real.sq_sqrt hnn
  have hsnn := Real.sqrt_nonneg (1 - r ^ 2)
  have hkey : r * Real.sqrt (1 - r ^ 2) ≤ 1 / 2 := by
    nlinarith [sq_nonneg (r - Real.sqrt (1 - r ^ 2))]
  have hp2 : (0:ℝ) < π ^ 2 := by positivity
  rw [area_eq r hr0 hr1]
  nlinarith [mul_nonneg hp2.le (show (0:ℝ) ≤ 1 / 2 - r * Real.sqrt (1 - r ^ 2) by linarith)]

/-- Uniqueness of the maximizer: any other parameter has strictly smaller area. -/
theorem area_lt_clifford_of_ne (r : ℝ) (hr0 : 0 ≤ r) (hr1 : r ≤ 1)
    (hne : r ≠ Real.sqrt 2 / 2) : area r < 2 * π ^ 2 := by
  have hnn : (0:ℝ) ≤ 1 - r ^ 2 := by nlinarith
  have hs := Real.sq_sqrt hnn
  have hsnn := Real.sqrt_nonneg (1 - r ^ 2)
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hdiff : r - Real.sqrt (1 - r ^ 2) ≠ 0 := by
    intro hzero
    have h1 : r = Real.sqrt (1 - r ^ 2) := by linarith
    have hr2 : r ^ 2 = 1 / 2 := by nlinarith
    apply hne
    have hhalf : (1:ℝ) / 2 = (Real.sqrt 2 / 2) ^ 2 := by nlinarith
    rw [← Real.sqrt_sq hr0, hr2, hhalf, Real.sqrt_sq (by positivity)]
  have hpos : 0 < (r - Real.sqrt (1 - r ^ 2)) ^ 2 :=
    lt_of_le_of_ne (sq_nonneg _) (Ne.symm (pow_ne_zero 2 hdiff))
  have hkey : r * Real.sqrt (1 - r ^ 2) < 1 / 2 := by nlinarith
  have hp2 : (0:ℝ) < π ^ 2 := by positivity
  rw [area_eq r hr0 hr1]
  nlinarith [mul_pos hp2 (show (0:ℝ) < 1 / 2 - r * Real.sqrt (1 - r ^ 2) by linarith)]

/-! ### Refutation of the minimality conjecture -/

/-- Formal statement of the conjecture: the Clifford torus minimizes area among the
Hopf-invariant tori separating the two coordinate circles. -/
def CliffordMinimizesArea : Prop :=
  ∀ r : ℝ, 0 < r → r < 1 → area (Real.sqrt 2 / 2) ≤ area r

/-- The areas of the family have infimum `0`: thin tori are arbitrarily short. -/
theorem area_small (δ : ℝ) (hδ : 0 < δ) :
    ∃ r : ℝ, 0 < r ∧ r < 1 ∧ 0 < area r ∧ area r < δ := by
  have hpi : (0:ℝ) < π := Real.pi_pos
  refine ⟨min (1/2) (δ / (8 * π ^ 2)), lt_min (by norm_num) (by positivity),
    lt_of_le_of_lt (min_le_left _ _) (by norm_num), ?_, ?_⟩
  · set r := min (1/2) (δ / (8 * π ^ 2)) with hr
    have hr0 : 0 < r := lt_min (by norm_num) (by positivity)
    have hr1 : r ≤ 1/2 := min_le_left _ _
    have hnn : (0:ℝ) ≤ 1 - r ^ 2 := by nlinarith
    have hspos : 0 < Real.sqrt (1 - r ^ 2) :=
      Real.sqrt_pos.mpr (by nlinarith)
    rw [area_eq r hr0.le (by linarith)]
    positivity
  · set r := min (1/2) (δ / (8 * π ^ 2)) with hr
    have hr0 : 0 < r := lt_min (by norm_num) (by positivity)
    have hr1 : r ≤ 1/2 := min_le_left _ _
    have hrδ : r ≤ δ / (8 * π ^ 2) := min_le_right _ _
    have hnn : (0:ℝ) ≤ 1 - r ^ 2 := by nlinarith
    have hs1 : Real.sqrt (1 - r ^ 2) ≤ 1 := by
      have h := Real.sqrt_le_sqrt (show 1 - r ^ 2 ≤ 1 by nlinarith)
      simpa using h
    have hsnn := Real.sqrt_nonneg (1 - r ^ 2)
    rw [area_eq r hr0.le (by linarith)]
    have hle : 4 * π ^ 2 * (r * Real.sqrt (1 - r ^ 2)) ≤ 4 * π ^ 2 * r := by
      have : r * Real.sqrt (1 - r ^ 2) ≤ r * 1 := by
        exact mul_le_mul_of_nonneg_left hs1 hr0.le
      nlinarith
    have h8 : (0:ℝ) < 8 * π ^ 2 := by positivity
    have hmul : r * (8 * π ^ 2) ≤ δ := by
      calc r * (8 * π ^ 2) ≤ (δ / (8 * π ^ 2)) * (8 * π ^ 2) :=
            mul_le_mul_of_nonneg_right hrδ h8.le
        _ = δ := by field_simp
    nlinarith

/-- **The Clifford-torus minimality conjecture is false.** -/
theorem not_cliffordMinimizesArea : ¬ CliffordMinimizesArea := by
  intro h
  obtain ⟨r, hr0, hr1, _, hlt⟩ := area_small (π ^ 2) (by positivity)
  have := h r hr0 hr1
  rw [clifford_area] at this
  have hpi : (0:ℝ) < π := Real.pi_pos
  nlinarith


/-! ### Criticality: what the Clifford parameter really satisfies -/

/-- The reduced area functional is differentiable on `(0,1)`, with derivative
`4π² (1 - 2r²)/√(1 - r²)`. -/
theorem hasDerivAt_area (r : ℝ) (h0 : 0 < r) (h1 : r < 1) :
    HasDerivAt area (4 * π ^ 2 * ((1 - 2 * r ^ 2) / Real.sqrt (1 - r ^ 2))) r := by
  have hpos : 0 < 1 - r ^ 2 := by nlinarith
  have hne : (1 - r ^ 2) ≠ 0 := ne_of_gt hpos
  have hs : 0 < Real.sqrt (1 - r ^ 2) := Real.sqrt_pos.mpr hpos
  have hinner : HasDerivAt (fun x : ℝ => 1 - x ^ 2) (-(2 * r)) r := by
    simpa using ((hasDerivAt_pow 2 r).const_sub 1)
  have hsqrt : HasDerivAt (fun x : ℝ => Real.sqrt (1 - x ^ 2))
      (-((Real.sqrt (1 - r ^ 2))⁻¹ * 2⁻¹ * (2 * r))) r := by
    simpa using (Real.hasDerivAt_sqrt hne).comp r hinner
  have h := ((hasDerivAt_id r).mul hsqrt).const_mul (4 * π ^ 2)
  have hform : HasDerivAt (fun x : ℝ => 4 * π ^ 2 * (x * Real.sqrt (1 - x ^ 2)))
      (4 * π ^ 2 * ((1 - 2 * r ^ 2) / Real.sqrt (1 - r ^ 2))) r := by
    convert h using 1
    simp only [id_eq]
    field_simp
    nlinarith [Real.sq_sqrt hpos.le, hs]
  refine hform.congr_of_eventuallyEq ?_
  filter_upwards [Ioo_mem_nhds h0 h1] with x hx
  exact area_eq x hx.1.le hx.2.le

/-- **The Clifford torus is the unique critical point** of the area functional in the
Hopf-invariant family — criticality, not minimality, is its variational property. -/
theorem clifford_unique_critical_point (r : ℝ) (h0 : 0 < r) (h1 : r < 1) :
    deriv area r = 0 ↔ r = Real.sqrt 2 / 2 := by
  have hpos : 0 < 1 - r ^ 2 := by nlinarith
  have hs : 0 < Real.sqrt (1 - r ^ 2) := Real.sqrt_pos.mpr hpos
  have hp2 : (0:ℝ) < π ^ 2 := by positivity
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  rw [(hasDerivAt_area r h0 h1).deriv]
  constructor
  · intro h
    have h4 : (4:ℝ) * π ^ 2 ≠ 0 := by positivity
    have hnum : 1 - 2 * r ^ 2 = 0 := by
      rcases mul_eq_zero.mp h with h' | h'
      · exact absurd h' h4
      · exact (div_eq_zero_iff.mp h').resolve_right (ne_of_gt hs)
    have hr2 : r ^ 2 = (Real.sqrt 2 / 2) ^ 2 := by nlinarith
    rw [← Real.sqrt_sq h0.le, hr2, Real.sqrt_sq (by positivity)]
  · intro h
    subst h
    have : 1 - 2 * (Real.sqrt 2 / 2) ^ 2 = 0 := by nlinarith
    rw [this]
    simp

/-- The corrected extremality statement: the Clifford torus is the unique area
*maximizer* in the Hopf-invariant family. -/
theorem clifford_unique_maximizer :
    area (Real.sqrt 2 / 2) = 2 * π ^ 2 ∧
      ∀ r : ℝ, 0 ≤ r → r ≤ 1 → r ≠ Real.sqrt 2 / 2 → area r < area (Real.sqrt 2 / 2) := by
  refine ⟨clifford_area, fun r hr0 hr1 hne => ?_⟩
  rw [clifford_area]
  exact area_lt_clifford_of_ne r hr0 hr1 hne

end

end CliffordTorusArea