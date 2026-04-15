import Mathlib

/-!
# Wick Rotation: The SPB Sign-Flip Bridge Between Circular and Hyperbolic Geometry
-/

noncomputable section

open Real

def spbW (x y : ℝ) : ℝ := (x + y) / (1 - x * y)
def spbHW (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

theorem spb_sum_identity (x y : ℝ) (hc : 1 - x * y ≠ 0) (hh : 1 + x * y ≠ 0) :
    spbW x y + spbHW x y = 2 * (x + y) / ((1 - x * y) * (1 + x * y)) := by
  unfold spbW spbHW; field_simp; ring

theorem spb_diff_identity (x y : ℝ) (hc : 1 - x * y ≠ 0) (hh : 1 + x * y ≠ 0) :
    spbW x y - spbHW x y = 2 * x * y * (x + y) / ((1 - x * y) * (1 + x * y)) := by
  unfold spbW spbHW; field_simp [hc, hh]; ring

theorem spb_product_identity (x y : ℝ) (hc : 1 - x * y ≠ 0) (hh : 1 + x * y ≠ 0) :
    spbW x y * spbHW x y = (x + y) ^ 2 / ((1 - x * y) * (1 + x * y)) := by
  unfold spbW spbHW; field_simp [hc, hh]

theorem denom_product (x y : ℝ) :
    (1 - x * y) * (1 + x * y) = 1 - (x * y) ^ 2 := by ring

theorem circular_norm (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 - x * y) ^ 2 * (1 + spbW x y ^ 2) = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spbW; field_simp; ring

theorem hyperbolic_norm (x y : ℝ) (h : 1 + x * y ≠ 0) :
    (1 + x * y) ^ 2 * (1 - spbHW x y ^ 2) = (1 - x ^ 2) * (1 - y ^ 2) := by
  unfold spbHW; field_simp; ring

theorem wick_norm_exchange (x : ℝ) : (1 + x ^ 2) + (1 - x ^ 2) = 2 := by ring

/-
Cross-ratio key: spb(a,t) - spb(b,t).
-/
theorem spb_difference (a b t : ℝ) (ha : 1 - a * t ≠ 0) (hb : 1 - b * t ≠ 0) :
    spbW a t - spbW b t = (a - b) * (1 + t ^ 2) / ((1 - a * t) * (1 - b * t)) := by
  unfold spbW; rw [ div_sub_div ] <;> ring <;> aesop;

end