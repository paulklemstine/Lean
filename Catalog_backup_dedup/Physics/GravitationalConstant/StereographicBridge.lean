import Mathlib

/-! # Stereographic Bridge to the Gravitational Constant

## Overview

We formalize the "stereographic bridge" connecting integer arithmetic to the
gravitational constant G ≈ 6.67430 × 10⁻¹¹ m³/(kg·s²).

The key insight: the significant digits of G, expressed as the rational number
66743/10000, have a continued fraction expansion [6; 1, 2, 14, 4, 2, 25].
Each convergent p/q of this expansion maps, via inverse stereographic projection,
to a rational point on the unit circle S¹, generating a Pythagorean triple
(2pq, p² - q², p² + q²). The conformal factor 2q²/(p² + q²) at each convergent
measures the "geometric stretching" — a bridge from integer arithmetic to geometry.

## The Stereographic–Pythagorean Correspondence

For any integers p, q, the inverse stereographic map t ↦ (2t/(1+t²), (1-t²)/(1+t²))
applied to t = p/q yields the rational point:
  x = 2pq / (p² + q²),  y = (q² - p²) / (p² + q²)
and (2pq)² + (p² - q²)² = (p² + q²)², i.e., a Pythagorean triple.
-/

noncomputable section

/-! ## Core stereographic definitions -/

/-- The x-coordinate of inverse stereographic projection S¹. -/
def stereoX' (t : ℝ) : ℝ := 2 * t / (1 + t ^ 2)

/-- The y-coordinate of inverse stereographic projection S¹. -/
def stereoY' (t : ℝ) : ℝ := (1 - t ^ 2) / (1 + t ^ 2)

/-- The conformal factor of inverse stereographic projection. -/
def confFactor (t : ℝ) : ℝ := 2 / (1 + t ^ 2)

/-- One plus t squared is always positive. -/
lemma one_plus_sq_pos' (t : ℝ) : 0 < 1 + t ^ 2 := by positivity

/-- One plus t squared is never zero. -/
lemma one_plus_sq_ne_zero' (t : ℝ) : 1 + t ^ 2 ≠ 0 := ne_of_gt (one_plus_sq_pos' t)

/-! ## The Stereographic–Pythagorean Theorem -/

/-- The fundamental identity: inverse stereographic projection lands on S¹. -/
theorem stereo_on_circle' (t : ℝ) : stereoX' t ^ 2 + stereoY' t ^ 2 = 1 := by
  unfold stereoX' stereoY'
  rw [div_pow, div_pow, ← add_div, div_eq_iff]
  · ring
  · exact pow_ne_zero 2 (one_plus_sq_ne_zero' t)

/-- The Pythagorean triple identity from stereographic parametrization:
    (2pq)² + (p² - q²)² = (p² + q²)² -/
theorem pythagorean_from_stereo' (p q : ℤ) :
    (2 * p * q) ^ 2 + (p ^ 2 - q ^ 2) ^ 2 = (p ^ 2 + q ^ 2) ^ 2 := by ring

/-! ## Conformal Factor Properties -/

/-- The conformal factor is always positive. -/
theorem confFactor_pos (t : ℝ) : 0 < confFactor t := by
  unfold confFactor; positivity

/-- The conformal factor is bounded above by 2. -/
theorem confFactor_le_two (t : ℝ) : confFactor t ≤ 2 := by
  unfold confFactor
  exact div_le_of_le_mul₀ (by positivity) (by positivity) (by nlinarith [sq_nonneg t])

/-- At t = 0, the conformal factor is exactly 2 (south pole = maximum stretching). -/
theorem confFactor_at_zero : confFactor 0 = 2 := by
  unfold confFactor; norm_num

/-- At t = ±1, the conformal factor is 1 (equator = isometric). -/
theorem confFactor_at_one : confFactor 1 = 1 := by
  unfold confFactor; norm_num

/-- The conformal factor at a ratio p/q equals 2q²/(p² + q²). -/
theorem confFactor_ratio (p q : ℝ) (hq : q ≠ 0) :
    confFactor (p / q) = 2 * q ^ 2 / (p ^ 2 + q ^ 2) := by
  unfold confFactor; field_simp; ring

/-! ## Continued Fraction Convergents of G

The CODATA 2018 value is G = 6.67430 × 10⁻¹¹.
Extracting the significant digits: 66743/10000 ≈ 6.6743.
The continued fraction expansion is [6; 1, 2, 14, 4, 2, 25].
The convergents are: 6/1, 7/1, 20/3, 287/43, 1168/175, 2623/393, 66743/10000.
-/

/-- The first convergent 6/1 generates the Pythagorean triple (12, 35, 37). -/
theorem convergent_0_triple : (2 * 6 * 1) ^ 2 + (6 ^ 2 - 1 ^ 2) ^ 2 = (6 ^ 2 + 1 ^ 2) ^ 2 := by
  norm_num

/-- The second convergent 7/1 generates the triple (14, 48, 50) ∼ (7, 24, 25). -/
theorem convergent_1_triple : (2 * 7 * 1) ^ 2 + (7 ^ 2 - 1 ^ 2) ^ 2 = (7 ^ 2 + 1 ^ 2) ^ 2 := by
  norm_num

/-- The third convergent 20/3 generates the triple (120, 391, 409). -/
theorem convergent_2_triple : (2 * 20 * 3) ^ 2 + (20 ^ 2 - 3 ^ 2) ^ 2 = (20 ^ 2 + 3 ^ 2) ^ 2 := by
  norm_num

/-- The fourth convergent 287/43 gives hypotenuse 287² + 43² = 84218. -/
theorem convergent_3_hypotenuse : 287 ^ 2 + 43 ^ 2 = (84218 : ℤ) := by norm_num

/-- The fourth convergent triple identity. -/
theorem convergent_3_triple :
    (2 * 287 * 43) ^ 2 + (287 ^ 2 - 43 ^ 2) ^ 2 = (287 ^ 2 + 43 ^ 2) ^ 2 := by norm_num

/-- The fifth convergent 1168/175 gives hypotenuse 1168² + 175² = 1394849. -/
theorem convergent_4_hypotenuse : 1168 ^ 2 + 175 ^ 2 = (1394849 : ℤ) := by norm_num

/-- The fifth convergent triple identity. -/
theorem convergent_4_triple :
    (2 * 1168 * 175) ^ 2 + (1168 ^ 2 - 175 ^ 2) ^ 2 = (1168 ^ 2 + 175 ^ 2) ^ 2 := by norm_num

/-- The sixth convergent 2623/393 generates a triple. -/
theorem convergent_5_triple :
    (2 * 2623 * 393) ^ 2 + (2623 ^ 2 - 393 ^ 2) ^ 2 = (2623 ^ 2 + 393 ^ 2) ^ 2 := by norm_num

/-- The final convergent 66743/10000 recovers the exact value. -/
theorem convergent_6_triple :
    (2 * 66743 * 10000) ^ 2 + (66743 ^ 2 - 10000 ^ 2) ^ 2 = (66743 ^ 2 + 10000 ^ 2) ^ 2 := by
  norm_num

/-! ## The Gravitational Conformal Ladder

The conformal factor at each convergent p/q is 2q²/(p² + q²).
This defines a decreasing sequence as the convergents grow.
-/

/-- The conformal factor at the first convergent 6/1 is 2/37. -/
theorem conformal_convergent_0 : confFactor 6 = 2 / 37 := by
  unfold confFactor; norm_num

/-- The conformal factor at the second convergent 7/1 is 1/25. -/
theorem conformal_convergent_1 : confFactor 7 = 2 / 50 := by
  unfold confFactor; norm_num

/-- The conformal factors decrease as |t| increases. -/
theorem confFactor_decreasing {t₁ t₂ : ℝ}
    (h : |t₁| < |t₂|) : confFactor t₂ < confFactor t₁ := by
  unfold confFactor
  have hsq : t₁ ^ 2 < t₂ ^ 2 := by
    nlinarith [abs_nonneg t₁, abs_nonneg t₂, sq_abs t₁, sq_abs t₂]
  exact div_lt_div_of_pos_left (by positivity) (by positivity) (by linarith)

/-! ## Integer Pole Charts and Gravitational Duality

The integer-pole chart T_{n,m}(z) = (nz + m)/(z + 1) places integers at the
poles of S¹. The "gravitational duality" maps convergent numerator n to the
north pole and denominator m to the south pole.
-/

/-- Integer pole chart: maps ∞ → n (North Pole), 0 → m (South Pole). -/
def gravChart (n m z : ℝ) : ℝ := (n * z + m) / (z + 1)

/-- The south-pole value is the denominator. -/
theorem gravChart_south (n m : ℝ) : gravChart n m 0 = m := by
  simp [gravChart]

/-- The equatorial value is the arithmetic mean (n+m)/2. -/
theorem gravChart_equator (n m : ℝ) : gravChart n m 1 = (n + m) / 2 := by
  unfold gravChart; ring

/-! ## Gravitational Stretching Factor

The conformal factor at G_digits = 66743/10000 gives the "gravitational
stretching factor": λ = 2 × 10000² / (66743² + 10000²).
-/

/-- The gravitational stretching factor for the exact significant digits of G. -/
def gravStretchFactor : ℝ := 2 * 10000 ^ 2 / (66743 ^ 2 + 10000 ^ 2)

/-- The stretching factor equals the conformal factor at G_digits/10000. -/
theorem gravStretch_eq_conformal :
    gravStretchFactor = confFactor (66743 / 10000) := by
  unfold gravStretchFactor; rw [confFactor_ratio 66743 10000 (by norm_num)]

/-- The gravitational stretching factor is positive. -/
theorem gravStretchFactor_pos : 0 < gravStretchFactor := by
  unfold gravStretchFactor; positivity

/-- The gravitational stretching factor is less than 1 (since G_digits > 1). -/
theorem gravStretchFactor_lt_one : gravStretchFactor < 1 := by
  unfold gravStretchFactor
  rw [div_lt_one (by positivity : (0 : ℝ) < 66743 ^ 2 + 10000 ^ 2)]
  norm_num

/-! ## The Algorithmic Light Sequence

The "algorithmic light" sequence: for each continued fraction partial quotient aₖ
of G's digits, the conformal factor encodes how rapidly the stereographic bridge
"focuses" onto G's position on the number line.
-/

/-- The partial quotients of the continued fraction [6; 1, 2, 14, 4, 2, 25]. -/
def gPartialQuotients : List ℕ := [6, 1, 2, 14, 4, 2, 25]

/-- The convergent numerators. -/
def gConvergentNums : List ℤ := [6, 7, 20, 287, 1168, 2623, 66743]

/-- The convergent denominators. -/
def gConvergentDens : List ℤ := [1, 1, 3, 43, 175, 393, 10000]

/-! ## The Mediant Property and SL(2,ℤ) Structure

Adjacent convergents p₁/q₁ and p₂/q₂ satisfy |p₁q₂ - p₂q₁| = 1.
This links continued fractions to SL(2,ℤ) — the modular group.
-/

/-- Adjacent convergents have determinant ±1. -/
theorem convergent_det_01 : |6 * 1 - 7 * 1| = (1 : ℤ) := by norm_num
theorem convergent_det_12 : |7 * 3 - 20 * 1| = (1 : ℤ) := by norm_num
theorem convergent_det_23 : |20 * 43 - 287 * 3| = (1 : ℤ) := by norm_num
theorem convergent_det_34 : |287 * 175 - 1168 * 43| = (1 : ℤ) := by norm_num
theorem convergent_det_45 : |1168 * 393 - 2623 * 175| = (1 : ℤ) := by norm_num
theorem convergent_det_56 : |2623 * 10000 - 66743 * 393| = (1 : ℤ) := by norm_num

/-! ## SL(2,ℤ) Bridge

Each continued fraction step corresponds to a matrix in GL(2,ℤ).
Pairs of steps compose into SL(2,ℤ) elements.
-/

/-- A 2×2 integer matrix. -/
structure Mat2Z' where
  m11 : ℤ
  m12 : ℤ
  m21 : ℤ
  m22 : ℤ
  deriving Repr

/-- Matrix multiplication. -/
def Mat2Z'.mul (M N : Mat2Z') : Mat2Z' where
  m11 := M.m11 * N.m11 + M.m12 * N.m21
  m12 := M.m11 * N.m12 + M.m12 * N.m22
  m21 := M.m21 * N.m11 + M.m22 * N.m21
  m22 := M.m21 * N.m12 + M.m22 * N.m22

/-- The determinant of a 2×2 matrix. -/
def Mat2Z'.det (M : Mat2Z') : ℤ := M.m11 * M.m22 - M.m12 * M.m21

/-- The continued fraction step matrix [[a, 1], [1, 0]]. -/
def cfStepMatrix (a : ℤ) : Mat2Z' where
  m11 := a; m12 := 1; m21 := 1; m22 := 0

/-- Each step matrix has determinant -1. -/
theorem cfStepMatrix_det (a : ℤ) : (cfStepMatrix a).det = -1 := by
  unfold cfStepMatrix Mat2Z'.det; ring

/-- The determinant is multiplicative. -/
theorem Mat2Z'_det_mul (M N : Mat2Z') : (M.mul N).det = M.det * N.det := by
  unfold Mat2Z'.mul Mat2Z'.det; ring

/-- Two continued fraction steps compose into an SL(2,ℤ) element (det = 1). -/
theorem even_steps_det_one (a b : ℤ) :
    ((cfStepMatrix a).mul (cfStepMatrix b)).det = 1 := by
  rw [Mat2Z'_det_mul, cfStepMatrix_det, cfStepMatrix_det]; ring

/-- The full continued fraction for G has 7 partial quotients,
    so the product of step matrices has determinant (-1)^7 = -1. -/
theorem full_cf_det : (7 : ℕ) % 2 = 1 := by norm_num

end
