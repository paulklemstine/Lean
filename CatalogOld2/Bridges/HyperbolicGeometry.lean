import Mathlib
import SPBBridge.Core
import SPBBridge.AlgebraicIdentities

/-!
# SPB and Hyperbolic Geometry

## Main Results
- Rapidity is additive under spbH composition  
- Hyperbolic half-angle formula
- Weierstrass parametrization identity
- Boost composition boundedness
-/

noncomputable section
open Real SPBResearch

namespace HyperbolicGeometry

/-- Rapidity: ρ(v) = (1/2)·ln((1+v)/(1-v)). -/
def rapidity (v : ℝ) : ℝ := Real.log ((1 + v) / (1 - v)) / 2

/-- Rapidity of 0 is 0. -/
theorem rapidity_zero : rapidity 0 = 0 := by unfold rapidity; simp

/-- Rapidity ratio multiplicativity (algebraic core). -/
theorem rapidity_ratio_mul (u v : ℝ) (hu : u ≠ 1) (hv : v ≠ 1)
    (huv : 1 + u * v ≠ 0) (hs : spbH u v ≠ 1) :
    (1 + spbH u v) / (1 - spbH u v) =
    ((1 + u) / (1 - u)) * ((1 + v) / (1 - v)) := by
  unfold spbH; field_simp; ring

/-- Distance from 0 to v equals |ρ(v)|. -/
theorem hypDist_from_origin (v : ℝ) :
    |rapidity (spbH 0 v)| = |rapidity v| := by
  rw [spbH_comm]; simp [SPBResearch.spbH]

/-- Boost composition is bounded. -/
theorem boost_bounded (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbH u v| < 1 := SPBAlgebra.spbH_bounded u v hu hv

/-- Rapidity additivity when all ratios are positive. -/
theorem rapidity_additive (u v : ℝ) (hu : u ≠ 1) (hv : v ≠ 1)
    (huv : 1 + u * v ≠ 0) (hs : spbH u v ≠ 1)
    (hpu : 0 < (1 + u) / (1 - u)) (hpv : 0 < (1 + v) / (1 - v)) :
    rapidity (spbH u v) = rapidity u + rapidity v := by
  unfold rapidity
  rw [rapidity_ratio_mul u v hu hv huv hs, Real.log_mul (by positivity) (by positivity)]
  ring

/-- Hyperbolic half-angle: spbH(t,t) = 2t/(1+t²). -/
theorem hyperbolic_half_angle (t : ℝ) :
    spbH t t = 2 * t / (1 + t ^ 2) := by unfold spbH; ring

/-- Weierstrass: ((1+t²)/(1-t²))² - (2t/(1-t²))² = 1. -/
theorem weierstrass_identity (t : ℝ) (h : 1 - t ^ 2 ≠ 0) :
    ((1 + t ^ 2) / (1 - t ^ 2)) ^ 2 - (2 * t / (1 - t ^ 2)) ^ 2 = 1 := by
  field_simp; ring

/-- Lorentz factor identity. -/
theorem lorentz_composition (u v : ℝ) (h : 1 + u * v ≠ 0) :
    (1 - spbH u v ^ 2) * (1 + u * v) ^ 2 = (1 - u ^ 2) * (1 - v ^ 2) := by
  unfold spbH; field_simp; ring

/-- Gamma factor squared is positive when |v| < 1. -/
theorem gamma_sq_pos (v : ℝ) (hv : |v| < 1) : 0 < 1 - v ^ 2 := by
  have := abs_lt.mp hv; nlinarith

end HyperbolicGeometry
end
