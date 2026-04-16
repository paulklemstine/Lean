/-! # CatalogBuild.Pythagorean.Berggren.BerggrenGPS

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22
-/

import Mathlib

noncomputable section

/-- Zone A inverse: maps (m, n) to (n, 2n - m) when m < 2n. -/
def zoneA_inv (m n : ℤ) : ℤ × ℤ := (n, 2 * n - m)



/-- Zone B inverse: maps (m, n) to (n, m - 2n) when 2n < m < 3n. -/
def zoneB_inv (m n : ℤ) : ℤ × ℤ := (n, m - 2 * n)



/-- Zone C inverse: maps (m, n) to (m - 2n, n) when m > 3n. -/
def zoneC_inv (m n : ℤ) : ℤ × ℤ := (m - 2 * n, n)



/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenGPS
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22] -/
theorem zoneA_valid (m n : ℤ) (hm_gt_n : m > n) (hn_pos : n > 0) (hm_lt : m < 2 * n) :
    let (m', n') := zoneA_inv m n
    m' > n' ∧ n' > 0 := by
  simp [zoneA_inv]; constructor <;> omega



theorem zoneB_valid (m n : ℤ) (hm_gt : m > 2 * n) (hm_lt : m < 3 * n) (hn_pos : n > 0) :
    let (m', n') := zoneB_inv m n
    m' > n' ∧ n' > 0 := by
  simp [zoneB_inv]; constructor <;> omega



theorem zoneC_valid (m n : ℤ) (hm_gt : m > 3 * n) (hn_pos : n > 0) :
    let (m', n') := zoneC_inv m n
    (m - 2 * n) > n ∧ n > 0 := by
  constructor <;> omega



theorem zoneA_hyp_decreases (m n : ℤ) (hm_gt_n : m > n) (hn_pos : n > 0) (hm_lt : m < 2 * n) :
    let (m', n') := zoneA_inv m n
    m' ^ 2 + n' ^ 2 < m ^ 2 + n ^ 2 := by
  simp [zoneA_inv]
  nlinarith [sq_nonneg (m - n), sq_nonneg n, sq_nonneg (2 * n - m)]



theorem zoneB_hyp_decreases (m n : ℤ) (hm_gt : m > 2 * n) (hm_lt : m < 3 * n) (hn_pos : n > 0) :
    let (m', n') := zoneB_inv m n
    m' ^ 2 + n' ^ 2 < m ^ 2 + n ^ 2 := by
  simp [zoneB_inv]
  nlinarith [sq_nonneg (m - 2 * n), sq_nonneg n, sq_nonneg (m - n)]



theorem zoneC_hyp_decreases (m n : ℤ) (hm_gt : m > 3 * n) (hn_pos : n > 0) :
    let (m', n') := zoneC_inv m n
    m' ^ 2 + n' ^ 2 < m ^ 2 + n ^ 2 := by
  simp [zoneC_inv]
  nlinarith [sq_nonneg (m - 2 * n), sq_nonneg n, sq_nonneg (m - 3 * n)]



/-- Zone A preserves the Pythagorean property. -/
theorem zoneA_preserves_pyth (m n : ℤ) :
    let (m', n') := zoneA_inv m n
    (m' ^ 2 - n' ^ 2) ^ 2 + (2 * m' * n') ^ 2 = (m' ^ 2 + n' ^ 2) ^ 2 := by
  simp [zoneA_inv]; ring



/-- The Berggren-Gauss map on ℝ. -/
noncomputable def berggrenGauss (z : ℝ) : ℝ :=
  if z < 2 then 1 / (2 - z)
  else if z < 3 then 1 / (z - 2)
  else z - 2



theorem silver_ratio_fixed_point :
    berggrenGauss (1 + Real.sqrt 2) = 1 + Real.sqrt 2 := by
  unfold berggrenGauss;
  rw [ if_neg, if_pos ] <;> try nlinarith [ Real.sqrt_nonneg 2, Real.sq_sqrt zero_le_two ] ; ; rw [ div_eq_iff ] <;> nlinarith [ Real.sqrt_nonneg 2, Real.sq_sqrt zero_le_two ] ;



theorem golden_ratio_step1 :
    berggrenGauss ((1 + Real.sqrt 5) / 2) = (3 + Real.sqrt 5) / 2 := by
  unfold berggrenGauss;
  rw [ if_pos, div_eq_iff ] <;> nlinarith [ Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ]



theorem golden_ratio_step2 :
    berggrenGauss ((3 + Real.sqrt 5) / 2) = (1 + Real.sqrt 5) / 2 := by
  rw [ berggrenGauss ];
  rw [ if_neg ( by nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ), if_pos ( by nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ) ] ; rw [ div_eq_iff ] <;> nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ]



/-- The golden ratio has a period-2 orbit under the Berggren-Gauss map. -/
theorem golden_ratio_two_cycle :
    berggrenGauss (berggrenGauss ((1 + Real.sqrt 5) / 2)) = (1 + Real.sqrt 5) / 2 := by
  rw [golden_ratio_step1, golden_ratio_step2]



theorem arctan_half_plus_arctan_third :
    Real.arctan (1/2) + Real.arctan (1/3) = Real.pi / 4 := by
  rw [ ← eq_sub_iff_add_eq', Real.arctan_eq_of_tan_eq ];
  · rw [ Real.tan_eq_sin_div_cos, Real.sin_sub, Real.cos_sub, Real.sin_pi_div_four, Real.cos_pi_div_four, Real.sin_arctan, Real.cos_arctan ] ; repeat ring <;> norm_num;
  · constructor <;> linarith [ Real.arctan_pos.2 ( show 0 < 1 / 2 by norm_num ), Real.arctan_lt_pi_div_two ( 1 / 2 ) ]



/-- Berggren 2×2 matrix M_A -/
def M_A : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]



/-- Berggren 2×2 matrix M_B -/
def M_B : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]



/-- Berggren 2×2 matrix M_C -/
def M_C : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]



/-- det(M_A) = 1 (M_A ∈ SL(2,ℤ)) -/
theorem det_MA : Matrix.det M_A = 1 := by native_decide



/-- det(M_B) = -1 -/
theorem det_MB : Matrix.det M_B = -1 := by native_decide



/-- det(M_C) = 1 -/
theorem det_MC : Matrix.det M_C = 1 := by native_decide



end
