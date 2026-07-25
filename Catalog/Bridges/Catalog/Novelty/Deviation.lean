import Mathlib

/-!
# Geodesic deviation: hyperbolic divergence vs. elliptic convergence

The separation `J(t)` between infinitesimally close geodesics obeys the **Jacobi
equation** `J'' + K · J = 0`, where `K` is the Gaussian curvature along the reference
geodesic.  The sign of `K` dictates the qualitative behaviour, and this is where the
exponential factors `e^{±t}` of the problem statement genuinely live.

This file records the two model behaviours in the constant-curvature normal form.

* **Negative curvature `K = -k < 0` (hyperbolic).**  `J(t) = sinh(√k · t)` solves
  `J'' + K J = J'' - k J = 0` and diverges: `J(t) → ∞`.  Nearby geodesics separate
  exponentially.  This is realised along the **x-axis**, where
  `K(x, 0) = -tanh² x ≤ 0` (see `Curvature.lean`).
* **Positive curvature `K = +k > 0` (elliptic).**  `J(t) = sin(√k · t)` solves
  `J'' + K J = J'' + k J = 0`, stays bounded (`|J| ≤ 1`) and refocuses: it returns to
  `0` at `t = π/√k`.  Nearby geodesics reconverge.

These are the standard Jacobi-field normal forms; combined with the curvature signs of
`Curvature.lean` they give the divergence statement for the x-axis.  (For this
particular metric the curvature is nonpositive everywhere along the axes, so the
elliptic case is not realised by the metric itself; the elliptic lemmas below describe
the generic `K > 0` behaviour.)
-/

namespace SplitGeometry

open Real Filter Topology

/-- Hyperbolic Jacobi field `J(t) = sinh(√k · t)` for curvature `K = -k`. -/
noncomputable def jacobiHyp (k t : ℝ) : ℝ := Real.sinh (Real.sqrt k * t)

/-- Elliptic Jacobi field `J(t) = sin(√k · t)` for curvature `K = +k`. -/
noncomputable def jacobiEll (k t : ℝ) : ℝ := Real.sin (Real.sqrt k * t)

/-
**Hyperbolic case solves the Jacobi equation** `J'' - k J = 0`, i.e.
`J'' + K J = 0` with `K = -k`.
-/
theorem jacobiHyp_solves (k : ℝ) (t : ℝ) :
    deriv (deriv (jacobiHyp k)) t = k * jacobiHyp k t := by
  have hd1 : deriv (jacobiHyp k) = fun u => Real.cosh (Real.sqrt k * u) * Real.sqrt k := by
    funext u
    simpa [jacobiHyp] using (((hasDerivAt_id u).const_mul (Real.sqrt k)).sinh).deriv
  have hd2 : deriv (deriv (jacobiHyp k)) t
      = Real.sinh (Real.sqrt k * t) * Real.sqrt k * Real.sqrt k := by
    rw [hd1]
    simpa using (((hasDerivAt_id t).const_mul (Real.sqrt k)).cosh.mul_const (Real.sqrt k)).deriv
  rw [hd2]
  simp only [jacobiHyp]
  by_cases h : 0 ≤ k
  · rw [mul_assoc, Real.mul_self_sqrt h]; ring
  · rw [Real.sqrt_eq_zero_of_nonpos (not_le.mp h).le]; simp

/-
**Hyperbolic divergence.**  For negative curvature (`k > 0`) the Jacobi field grows
without bound: nearby geodesics separate.
-/
theorem jacobiHyp_diverges (k : ℝ) (hk : 0 < k) :
    Filter.Tendsto (jacobiHyp k) Filter.atTop Filter.atTop := by
  unfold jacobiHyp;
  norm_num [ Real.sinh_eq ];
  exact Filter.Tendsto.atTop_div_const ( by positivity ) ( Filter.Tendsto.atTop_add ( Real.tendsto_exp_atTop.comp <| Filter.tendsto_id.const_mul_atTop <| Real.sqrt_pos.mpr hk ) <| Filter.Tendsto.neg <| Real.tendsto_exp_atBot.comp <| Filter.tendsto_neg_atTop_atBot.comp <| Filter.tendsto_id.const_mul_atTop <| Real.sqrt_pos.mpr hk )

/-
**Elliptic case solves the Jacobi equation** `J'' + k J = 0`, i.e.
`J'' + K J = 0` with `K = +k`.
-/
theorem jacobiEll_solves (k : ℝ) (t : ℝ) :
    deriv (deriv (jacobiEll k)) t = -k * jacobiEll k t := by
  have hd1 : deriv (jacobiEll k) = fun u => Real.cos (Real.sqrt k * u) * Real.sqrt k := by
    funext u
    simpa [jacobiEll] using (((hasDerivAt_id u).const_mul (Real.sqrt k)).sin).deriv
  have hd2 : deriv (deriv (jacobiEll k)) t
      = -Real.sin (Real.sqrt k * t) * Real.sqrt k * Real.sqrt k := by
    rw [hd1]
    simpa using (((hasDerivAt_id t).const_mul (Real.sqrt k)).cos.mul_const (Real.sqrt k)).deriv
  rw [hd2]
  simp only [jacobiEll]
  by_cases h : 0 ≤ k
  · rw [mul_assoc, Real.mul_self_sqrt h]; ring
  · rw [Real.sqrt_eq_zero_of_nonpos (not_le.mp h).le]; simp

/-
**Elliptic boundedness.**  For positive curvature the Jacobi field stays bounded.
-/
theorem jacobiEll_bounded (k t : ℝ) : |jacobiEll k t| ≤ 1 := by
  exact Real.abs_sin_le_one _

/-
**Elliptic refocusing.**  For positive curvature (`k > 0`) the Jacobi field returns
to zero at `t = π/√k`: nearby geodesics reconverge.
-/
theorem jacobiEll_refocus (k : ℝ) (hk : 0 < k) :
    jacobiEll k (Real.pi / Real.sqrt k) = 0 := by
  unfold jacobiEll; rw [ show Real.sqrt k * ( Real.pi / Real.sqrt k ) = Real.pi by rw [ mul_div_cancel₀ _ ( ne_of_gt ( Real.sqrt_pos.mpr hk ) ) ] ] ; exact Real.sin_pi;

end SplitGeometry