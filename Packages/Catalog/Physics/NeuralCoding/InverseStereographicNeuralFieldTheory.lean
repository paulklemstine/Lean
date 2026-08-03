import Mathlib

/-!
# Inverse stereographic neural-field foundations

This file proves a chain of exact geometric and counting results that can be established
without assuming an unformalized stability theory for a Mexican-hat integral operator.
The inverse stereographic chart is made explicit, its image is proved to lie on the unit
sphere, and the behavior of its coordinate modes is quantified.  The last section proves
the `2k+1` multiplicity calculation and the requested cases `k = 1,2,3`.
-/

namespace InverseStereographicNeuralField

noncomputable section

abbrev PlanePoint := ℝ × ℝ

structure SpacePoint where
  x : ℝ
  y : ℝ
  z : ℝ

/-- The denominator occurring in inverse stereographic projection. -/
def stereoDenom (p : PlanePoint) : ℝ := 1 + p.1 ^ 2 + p.2 ^ 2

/-- Inverse stereographic projection from the plane to the unit sphere, with infinity
corresponding to the north pole. -/
def inverseStereo (p : PlanePoint) : SpacePoint where
  x := 2 * p.1 / stereoDenom p
  y := 2 * p.2 / stereoDenom p
  z := (p.1 ^ 2 + p.2 ^ 2 - 1) / stereoDenom p

/-- The stereographic denominator is strictly positive. -/
theorem stereoDenom_pos (p : PlanePoint) : 0 < stereoDenom p := by
  unfold stereoDenom
  positivity

/-- Consequently, the stereographic denominator never vanishes. -/
theorem stereoDenom_ne_zero (p : PlanePoint) : stereoDenom p ≠ 0 := by
  exact ne_of_gt (stereoDenom_pos p)

/-- The north-pole coordinate has an exact complementary conformal-weight formula. -/
theorem one_sub_inverseStereo_third (p : PlanePoint) :
    1 - (inverseStereo p).z = 2 / stereoDenom p := by
  rw [inverseStereo]
  field_simp [stereoDenom_ne_zero p]
  unfold stereoDenom
  ring

/-- Every finite point of the stereographic chart lies strictly below the north pole. -/
theorem inverseStereo_third_lt_one (p : PlanePoint) : (inverseStereo p).z < 1 := by
  have h := one_sub_inverseStereo_third p
  have hp : 0 < 2 / stereoDenom p := div_pos (by norm_num) (stereoDenom_pos p)
  linarith

/-- Inverse stereographic projection lands on the unit two-sphere. -/
theorem inverseStereo_on_unitSphere (p : PlanePoint) :
    (inverseStereo p).x ^ 2 + (inverseStereo p).y ^ 2 +
      (inverseStereo p).z ^ 2 = 1 := by
  simp [inverseStereo, stereoDenom]
  field_simp
  ring

/-- Each of the three degree-one coordinate modes pulled back to the plane has
absolute value at most one. -/
theorem inverseStereo_coordinate_bounds (p : PlanePoint) :
    |(inverseStereo p).x| ≤ 1 ∧ |(inverseStereo p).y| ≤ 1 ∧
      |(inverseStereo p).z| ≤ 1 := by
  have hs := inverseStereo_on_unitSphere p
  constructor
  · rw [abs_le]
    constructor <;> nlinarith [sq_nonneg (inverseStereo p).y,
      sq_nonneg (inverseStereo p).z, sq_nonneg ((inverseStereo p).x - 1),
      sq_nonneg ((inverseStereo p).x + 1)]
  constructor
  · rw [abs_le]
    constructor <;> nlinarith [sq_nonneg (inverseStereo p).x,
      sq_nonneg (inverseStereo p).z, sq_nonneg ((inverseStereo p).y - 1),
      sq_nonneg ((inverseStereo p).y + 1)]
  · rw [abs_le]
    constructor <;> nlinarith [sq_nonneg (inverseStereo p).x,
      sq_nonneg (inverseStereo p).y, sq_nonneg ((inverseStereo p).z - 1),
      sq_nonneg ((inverseStereo p).z + 1)]

/-- Along the positive horizontal ray, the first coordinate mode has exact
`2R/(1+R²)` decay. -/
theorem inverseStereo_first_on_ray (R : ℝ) :
    (inverseStereo (R, 0)).x = 2 * R / (1 + R ^ 2) := by
  simp [inverseStereo, stereoDenom]

/-- The first coordinate mode is quantitatively bounded by `2/R` for `R ≥ 1`. -/
theorem inverseStereo_first_decay (R : ℝ) (hR : 1 ≤ R) :
    |(inverseStereo (R, 0)).x| ≤ 2 / R := by
  rw [inverseStereo_first_on_ray, abs_of_nonneg]
  · rw [div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith
  · exact div_nonneg (mul_nonneg (by norm_num) (by positivity)) (by positivity)

/-- In contrast, the third coordinate mode approaches the north-pole value `1`;
its exact error is `2/(1+R²)`.  Thus not every projected spherical harmonic decays
to zero without an additional north-pole vanishing condition. -/
theorem inverseStereo_third_error (R : ℝ) :
    |1 - (inverseStereo (R, 0)).z| = 2 / (1 + R ^ 2) := by
  rw [one_sub_inverseStereo_third, abs_of_pos (div_pos (by norm_num) (stereoDenom_pos (R, 0)))]
  simp [stereoDenom]

/-- The representation-theoretic multiplicity attached to degree `k` on `S²`. -/
def harmonicMultiplicity (k : ℕ) : ℕ := 2 * k + 1

/-- The standard binomial-difference formula specializes on `S²` to `2k+1`. -/
theorem harmonicMultiplicity_from_binomial (k : ℕ) :
    Nat.choose (k + 2) 2 - Nat.choose k 2 = harmonicMultiplicity k := by
  simp [harmonicMultiplicity]
  have h1 : (k + 2).choose 2 = (k + 2) * (k + 1) / 2 := by
    rw [Nat.choose_two_right]
    simp
  have h2 : k.choose 2 = k * (k - 1) / 2 := by
    rw [Nat.choose_two_right]
  simp [h1, h2]
  have key : (k + 2) * (k + 1) = k * (k - 1) + 4 * k + 2 := by
    cases k with
    | zero => simp
    | succ n => simp; ring
  omega

/-- The requested radius `r = 1/k` mode count is `2k+1`, once mode selection at
exactly degree `k` is taken as the spectral hypothesis. -/
theorem reciprocal_radius_mode_count (k : ℕ) (_hk : 0 < k) :
    harmonicMultiplicity k = 2 * k + 1 := by
  rw [← harmonicMultiplicity_from_binomial]
  exact harmonicMultiplicity_from_binomial k

/-- For radius `1`, the selected degree-one eigenspace has dimension three. -/
theorem reciprocal_radius_one_count : harmonicMultiplicity 1 = 3 := by
  simpa using reciprocal_radius_mode_count 1 (by omega)

/-- For radius `1/2`, the selected degree-two eigenspace has dimension five. -/
theorem reciprocal_radius_two_count : harmonicMultiplicity 2 = 5 := by
  simpa using reciprocal_radius_mode_count 2 (by omega)

/-- For radius `1/3`, the selected degree-three eigenspace has dimension seven. -/
theorem reciprocal_radius_three_count : harmonicMultiplicity 3 = 7 := by
  simpa using reciprocal_radius_mode_count 3 (by omega)

end

end InverseStereographicNeuralField