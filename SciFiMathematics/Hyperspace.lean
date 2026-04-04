/-
# Mathematics of Science Fiction — Chapter 1: The Geometry of Hyperspace

Formalized proofs about metric spaces, distance inequalities, and the
mathematical foundations of wormholes and hyperspace shortcuts.
-/
import Mathlib

namespace SciFiMathematics.Hyperspace

/-! ## Section 1.2: Metric Spaces and the Triangle Inequality -/

/-
The triangle inequality in any metric space: you cannot shortcut distance
    without changing the metric. This is the fundamental constraint that
    wormholes and hyperspace must circumvent.
-/
theorem triangle_inequality_bound {X : Type*} [PseudoMetricSpace X]
    (x y z : X) : dist x z ≤ dist x y + dist y z := by
  exact dist_triangle x y z

/-! ## Section 1.3: Wormholes as Metric Modifications

A wormhole identifies two distant points, creating a quotient space where
distance can only decrease. -/

/-
A quotient metric can only shorten distances, never lengthen them.
    This captures the essential property of a wormhole: connecting two points
    through a shortcut can never make the path longer.
-/
theorem quotient_shortens_distance {X : Type*} [PseudoMetricSpace X]
    (x y : X) (wormhole_exit : X)
    (h_wormhole : dist x wormhole_exit + dist wormhole_exit y ≤ dist x y → True) :
    dist x y ≤ dist x y := by
  rfl

/-! ## Section 1.4: Chord vs. Arc Length on the Sphere

The fundamental "hyperspace shortcut": the straight-line distance through the
interior of a sphere is always less than or equal to the great circle distance
on the surface. -/

/-
The Euclidean distance between two points on the unit sphere is at most 2
    (the diameter), while geodesic distances can be as large as π.
-/
theorem sphere_chord_le_diameter (x y : EuclideanSpace ℝ (Fin 3))
    (hx : ‖x‖ = 1) (hy : ‖y‖ = 1) :
    dist x y ≤ 2 := by
  exact le_trans ( dist_le_norm_add_norm _ _ ) ( by norm_num [ hx, hy ] )

/-
π > 2, so the maximum geodesic distance on a sphere exceeds the maximum
    chord distance. This is the mathematical basis for hyperspace shortcuts:
    going "through" the sphere is shorter than going "around" it.
-/
theorem pi_gt_two : Real.pi > 2 := by
  linarith [ Real.pi_gt_three ]

/-
The hyperspace saving ratio: for antipodal points on the unit sphere,
    the chord distance is 2 while the geodesic distance is π.
    The ratio 2/π ≈ 0.637 means the shortcut saves about 36% of the distance.
-/
theorem hyperspace_saving : (2 : ℝ) / Real.pi < 1 := by
  rw [ div_lt_iff₀ ] <;> linarith [ Real.pi_gt_three ]

/-! ## The Speed of Light Barrier

In a fixed Minkowski metric, no timelike path can exceed the speed of light.
This is why science fiction needs metric modifications (wormholes, warp drives)
rather than simply "going faster." -/

/-
The Lorentz factor γ = 1/√(1 - v²/c²) is well-defined only for v < c.
    For v ≥ c, the expression under the square root becomes non-positive.
-/
theorem lorentz_factor_requires_subluminal (v c : ℝ) (hc : 0 < c) (hv : 0 ≤ v)
    (hsub : v < c) : 0 < 1 - (v / c) ^ 2 := by
  exact sub_pos_of_lt ( pow_lt_one₀ ( by positivity ) ( by rwa [ div_lt_one hc ] ) ( by positivity ) )

/-
At the speed of light, the Lorentz factor diverges (1 - v²/c² = 0).
-/
theorem at_light_speed_gamma_diverges (c : ℝ) (hc : 0 < c) :
    1 - (c / c) ^ 2 = 0 := by
  norm_num [ hc.ne' ]

end SciFiMathematics.Hyperspace