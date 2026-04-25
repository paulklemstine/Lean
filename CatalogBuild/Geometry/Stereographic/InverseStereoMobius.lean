/-! # CatalogBuild.Geometry.Stereographic.InverseStereoMobius

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 42
-/

import Mathlib

noncomputable section

/-- The change-of-pole Möbius transformation.
M_a(t) = (at + 1)/(t - a) maps the standard south-pole coordinates to
the stereographic projection from the pole at parameter a. -/
def poleMap (a t : ℝ) : ℝ := (a * t + 1) / (t - a)





/-- **Theorem Α.2**: M_0(t) = 1/t, the classical north-south swap. -/
theorem pole_map_at_zero (t : ℝ) (ht : t ≠ 0) :
    poleMap 0 t = 1 / t := by
  simp [poleMap]





/-- [Section: # CatalogBuild.Geometry.Stereographic.InverseStereoMobius
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 42] -/
theorem pole_map_involution (a t : ℝ) (ht : t ≠ a)
    (hmt : (a * t + 1) / (t - a) ≠ a) :
    poleMap a (poleMap a t) = t := by
  -- Substitute poleMap a t into the expression for poleMap a (poleMap a t).
  have h_sub : poleMap a (poleMap a t) = (a * ((a * t + 1) / (t - a)) + 1) / (((a * t + 1) / (t - a)) - a) := by
    rfl;
  grind





/-- [Section: # CatalogBuild.Geometry.Stereographic.InverseStereoMobius
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 42] -/
theorem pole_map_antipodal (a : ℝ) (ha : a ≠ 0) :
    poleMap a (-1/a) = 0 := by
  unfold poleMap; ring_nf; aesop;





/-- The two-pole Möbius transformation.
F_{a,b}(t) = ((ab+1)t + (b-a)) / ((a-b)t + (ab+1)) -/
def twoPoleMap (a b t : ℝ) : ℝ :=
  ((a * b + 1) * t + (b - a)) / ((a - b) * t + (a * b + 1))





/-- [Section: # CatalogBuild.Geometry.Stereographic.InverseStereoMobius
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 42] -/
theorem two_pole_same_is_id (a t : ℝ) :
    twoPoleMap a a t = t := by
  exact div_eq_iff ( by nlinarith [ sq_nonneg a ] ) |>.2 ( by ring )





/-- **Theorem Β.2**: The key algebraic identity.
(b-a)·Num + (ab+1)·Den = (1+a²)(1+b²). -/
theorem two_pole_det_identity (a b t : ℝ) :
    (b - a) * ((a * b + 1) * t + (b - a)) +
    (a * b + 1) * ((a - b) * t + (a * b + 1)) =
    (1 + a ^ 2) * (1 + b ^ 2) := by ring





/-- **Theorem Β.3**: The determinant factors as (1+a²)(1+b²). -/
theorem two_pole_det_factored (a b : ℝ) :
    (a * b + 1) ^ 2 + (b - a) ^ 2 = (1 + a ^ 2) * (1 + b ^ 2) := by ring





theorem two_pole_reverse_inverse (a b t : ℝ)
    (h1 : (a - b) * t + (a * b + 1) ≠ 0)
    (h2 : (b - a) * twoPoleMap a b t + (b * a + 1) ≠ 0) :
    twoPoleMap b a (twoPoleMap a b t) = t := by
  unfold twoPoleMap at *;
  grind +ring





/-- **Theorem Β.5**: F_{0,1}(t) = (t+1)/(1-t). South-to-east-point map. -/
theorem two_pole_south_east (t : ℝ) (ht : (1:ℝ) - t ≠ 0) :
    twoPoleMap 0 1 t = (t + 1) / (1 - t) := by
  unfold twoPoleMap; congr 1 <;> ring





/-- **Theorem Β.6**: F_{0,1}(0) = 1. -/
theorem two_pole_01_at_zero :
    twoPoleMap 0 1 0 = 1 := by
  unfold twoPoleMap; norm_num





/-- **Theorem Β.7**: F_{0,1}(-1) = 0. -/
theorem two_pole_01_at_neg_one :
    twoPoleMap 0 1 (-1) = 0 := by
  unfold twoPoleMap; norm_num





/-- **Theorem Β.8**: F_{0,1}(2) = -3. An integer maps to a different integer! -/
theorem two_pole_01_at_two :
    twoPoleMap 0 1 2 = -3 := by
  unfold twoPoleMap; norm_num





/-- **Theorem Β.9**: F_{0,1}(3) = -2. -/
theorem two_pole_01_at_three :
    twoPoleMap 0 1 3 = -2 := by
  unfold twoPoleMap; norm_num





theorem two_pole_composition_formula (a b c t : ℝ)
    (h1 : (a - b) * t + (a * b + 1) ≠ 0)
    (h2 : (b - c) * twoPoleMap a b t + (b * c + 1) ≠ 0) :
    twoPoleMap b c (twoPoleMap a b t) = twoPoleMap a c t := by
  unfold twoPoleMap at *;
  grind





theorem integer_map_necessary (a b n : ℤ) :
    (a - b) * n + (a * b + 1) ∣ (a * b + 1) * n + (b - a) →
    (a - b) * n + (a * b + 1) ∣ (1 + a ^ 2) * (1 + b ^ 2) := by
  exact fun h => by convert dvd_add ( h.mul_left ( b - a ) ) ( dvd_mul_right ( ( a - b ) * n + ( a * b + 1 ) ) ( a * b + 1 ) ) using 1; ring;





theorem integer_map_weak_criterion (a b n : ℤ) :
    (a - b) * n + (a * b + 1) ∣ (1 + a ^ 2) * (1 + b ^ 2) →
    (a - b) * n + (a * b + 1) ∣ (b - a) * ((a * b + 1) * n + (b - a)) := by
  intro h
  have h_det : (a - b) * n + (a * b + 1) ∣ (1 + a ^ 2) * (1 + b ^ 2) := h
  have h_sub : (a - b) * n + (a * b + 1) ∣ (1 + a ^ 2) * (1 + b ^ 2) - (a * b + 1) * ((a - b) * n + (a * b + 1)) := by
    exact dvd_sub h_det ( dvd_mul_left _ _ )
  convert h_sub using 1 ; ring





/-- **Theorem Γ.2**: The key algebraic identity in ℤ. -/
theorem two_pole_det_identity_int (a b n : ℤ) :
    (b - a) * ((a * b + 1) * n + (b - a)) +
    (a * b + 1) * ((a - b) * n + (a * b + 1)) =
    (1 + a ^ 2) * (1 + b ^ 2) := by ring





/-- **Theorem Γ.3**: The determinant factorization in ℤ. -/
theorem two_pole_det_factored_int (a b : ℤ) :
    (a * b + 1) ^ 2 + (b - a) ^ 2 = (1 + a ^ 2) * (1 + b ^ 2) := by ring





/-- **Theorem Γ.4**: det for (0,1) is 4. -/
theorem det_south_east : (1 + (0:ℤ)^2) * (1 + (1:ℤ)^2) = 2 := by norm_num





/-- **Theorem Γ.5**: det for (1,2) is 10. -/
theorem det_one_two : (1 + (1:ℤ)^2) * (1 + (2:ℤ)^2) = 10 := by norm_num





/-- **Theorem Γ.6**: det for (2,3) is 50. -/
theorem det_two_three : (1 + (2:ℤ)^2) * (1 + (3:ℤ)^2) = 50 := by norm_num





/-- **Theorem Γ.7**: 1+n² is always positive for integers. -/
theorem one_plus_sq_pos_int (n : ℤ) : 0 < 1 + n ^ 2 := by positivity





/-- F_{0,1}: numerator at n=2 is 3, denominator is -1, quotient is -3. -/
theorem chain_01_2_num : (0 * 1 + 1) * 2 + (1 - 0) = (3 : ℤ) := by norm_num




theorem chain_01_2_den : (0 - 1) * 2 + (0 * 1 + 1) = (-1 : ℤ) := by norm_num




theorem chain_01_2 : (3 : ℤ) / (-1) = -3 := by norm_num





/-- F_{0,1}: at n=3, numerator is 4, denominator is -2, quotient is -2. -/
theorem chain_01_3_num : (0 * 1 + 1) * 3 + (1 - 0) = (4 : ℤ) := by norm_num




theorem chain_01_3_den : (0 - 1) * 3 + (0 * 1 + 1) = (-2 : ℤ) := by norm_num




theorem chain_01_3 : (4 : ℤ) / (-2) = -2 := by norm_num





/-- F_{1,2}(1) = 2. -/
theorem chain_12_1 :
    ((1 * 2 + 1) * 1 + (2 - 1)) / ((1 - 2) * 1 + (1 * 2 + 1)) = (2 : ℤ) := by norm_num





/-- F_{1,2}(2) = 7. -/
theorem chain_12_2 :
    ((1 * 2 + 1) * 2 + (2 - 1)) / ((1 - 2) * 2 + (1 * 2 + 1)) = (7 : ℤ) := by norm_num





/-- F_{1,3}(1) = 3. -/
theorem chain_13_1 :
    ((1 * 3 + 1) * 1 + (3 - 1)) / ((1 - 3) * 1 + (1 * 3 + 1)) = (3 : ℤ) := by norm_num





/-- F_{1,3}(3) = -7. -/
theorem chain_13_3 :
    ((1 * 3 + 1) * 3 + (3 - 1)) / ((1 - 3) * 3 + (1 * 3 + 1)) = (-7 : ℤ) := by norm_num





/-- F_{1,3}(-3) = -1. -/
theorem chain_13_neg3 :
    ((1 * 3 + 1) * (-3) + (3 - 1)) / ((1 - 3) * (-3) + (1 * 3 + 1)) = (-1 : ℤ) := by norm_num





/-- **Grand Synthesis**: The determinant equals (1+a²)(1+b²) = N(1+ai)·N(1+bi)
in Gaussian integer norms. -/
theorem gaussian_norm_connection (a b : ℤ) :
    (a * b + 1) ^ 2 + (b - a) ^ 2 = (1 + a ^ 2) * (1 + b ^ 2) := by ring





/-- **Brahmagupta-Fibonacci from poles**: Both sum-of-squares decompositions. -/
theorem brahmagupta_from_poles (a b : ℤ) :
    (1 + a ^ 2) * (1 + b ^ 2) = (a * b + 1) ^ 2 + (a - b) ^ 2 ∧
    (1 + a ^ 2) * (1 + b ^ 2) = (a * b - 1) ^ 2 + (a + b) ^ 2 := by
  constructor <;> ring





/-- **All integer-pole maps are elliptic**: 4·det - trace² = 4(a-b)² ≥ 0. -/
theorem all_integer_poles_elliptic (a b : ℤ) :
    4 * ((1 + a ^ 2) * (1 + b ^ 2)) - (2 * (a * b + 1)) ^ 2 = 4 * (a - b) ^ 2 := by
  ring





theorem two_pole_01_order_four (t : ℝ) (ht0 : t ≠ 0) (ht1 : t ≠ 1) (htm1 : t ≠ -1) :
    twoPoleMap 0 1 (twoPoleMap 0 1 (twoPoleMap 0 1 (twoPoleMap 0 1 t))) = t := by
  unfold twoPoleMap;
  grind





theorem two_pole_01_squared (t : ℝ) (ht0 : t ≠ 0) (ht1 : t ≠ 1) :
    twoPoleMap 0 1 (twoPoleMap 0 1 t) = -(1/t) := by
  unfold twoPoleMap; norm_num [ ht0, ht1 ] ; ring;
  grind





/-- **Eigenvalue Gaussian factorization**: (1+ai)·conj(1+bi) has real part ab+1
and imaginary part a-b. -/
theorem eigenvalue_gaussian_factorization (a b : ℤ) :
    (1 * 1 + a * b = a * b + 1) ∧ (a * 1 - 1 * b = a - b) := by
  constructor <;> ring





/-- **The Pythagorean triple (3,4,5) from poles (1,2)**: p=3, q=1, 3²+1²=10=2·5. -/
theorem pythagorean_from_poles_1_2 :
    let p := (1:ℤ) * 2 + 1
    let q := (2:ℤ) - 1
    p ^ 2 + q ^ 2 = (1 + 1 ^ 2) * (1 + 2 ^ 2) := by norm_num





/-- **South-east elliptic**: trace² < 4·det for (0,1). -/
theorem south_east_elliptic :
    (2 * ((0:ℤ) * 1 + 1)) ^ 2 < 4 * ((1 + 0 ^ 2) * (1 + 1 ^ 2)) := by norm_num





end
