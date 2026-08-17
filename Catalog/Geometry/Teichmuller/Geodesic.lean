/-
# Teichmüller geodesics: the stretch line of the torus

A *Teichmüller geodesic* is a family of marked surfaces obtained by stretching a fixed flat
structure in one direction at exponential rate.  For the torus the stretch line based at the
square torus is `t ↦ i e^{2t}`, i.e. the imaginary axis of the Teichmüller space `ℍ`
traversed at exponential speed.

This file shows that this line is a **unit-speed geodesic of the Teichmüller metric**:

* `Teichmuller.teichDist_stretchLine` : `d_T (σ_s, σ_t) = |t - s|`;
* `Teichmuller.teichDist_stretchLine_add` : additivity along the line for `r ≤ s ≤ t`, i.e.
  the triangle inequality of `Teichmuller.teichDist_triangle` is an equality — the line is a
  geodesic, not merely a rectifiable path;
* `Teichmuller.dil_stretchLine` : the extremal quasiconformal dilatation between two points of
  the line is `e^{2|t-s|}`, so the *dilatation* grows exponentially in the Teichmüller distance;
* `Teichmuller.teichDist_unbounded` : the Teichmüller space of the torus has infinite diameter.

-- !-- Lab Notes -- !--
Hypothesizer: the exponential parametrization `i e^{2t}` (not `i e^{t}`) should be the unit-speed
one, because the Teichmüller metric is *half* the hyperbolic metric.
Experimenter: `dist_of_re_eq` gives `d_ℍ (i e^{2s}, i e^{2t}) = |2t - 2s|`, and halving gives
`|t - s|`; the exponent `2` is exactly the factor `1/2` of `teichDist_eq_half_dist` in disguise.
Analyst: the extremal map between `σ_s` and `σ_t` is the diagonal stretch with dilatation
`e^{2|t-s|}` — dilatation is exponential in Teichmüller distance, the quantitative reason
Teichmüller distance is a *logarithm* of a dilatation.
-/
import Mathlib
import Geometry.Teichmuller.TorusSpace

namespace Teichmuller

open Complex UpperHalfPlane

/-- The Teichmüller stretch line through the square torus: the torus `ℂ / ⟨1, i e^{2t}⟩`. -/
noncomputable def stretchLine (t : ℝ) : ℍ :=
  ⟨⟨0, Real.exp (2 * t)⟩, Real.exp_pos _⟩

@[simp] theorem stretchLine_re (t : ℝ) : (stretchLine t).re = 0 := rfl

@[simp] theorem stretchLine_im (t : ℝ) : (stretchLine t).im = Real.exp (2 * t) := rfl

/-- **The stretch line is a unit-speed geodesic for the Teichmüller metric.** -/
theorem teichDist_stretchLine (s t : ℝ) : teichDist (stretchLine s) (stretchLine t) = |t - s| := by
  rw [teichDist_eq_half_dist, UpperHalfPlane.dist_of_re_eq (by simp), stretchLine_im,
    stretchLine_im, Real.log_exp, Real.log_exp, Real.dist_eq]
  rw [show (2 * s - 2 * t) = -(2 * (t - s)) by ring, abs_neg, abs_mul,
    abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2)]
  ring

/-- Additivity of the Teichmüller distance along the stretch line: the triangle inequality is an
equality, so the stretch line really is a geodesic. -/
theorem teichDist_stretchLine_add {r s t : ℝ} (hrs : r ≤ s) (hst : s ≤ t) :
    teichDist (stretchLine r) (stretchLine t)
      = teichDist (stretchLine r) (stretchLine s) + teichDist (stretchLine s) (stretchLine t) := by
  rw [teichDist_stretchLine, teichDist_stretchLine, teichDist_stretchLine,
    abs_of_nonneg (by linarith : (0:ℝ) ≤ t - r), abs_of_nonneg (by linarith : (0:ℝ) ≤ s - r),
    abs_of_nonneg (by linarith : (0:ℝ) ≤ t - s)]
  ring

/-- The extremal dilatation along the stretch line grows exponentially in the Teichmüller
distance. -/
theorem dil_stretchLine (s t : ℝ) :
    (affine (stretchLine s) (stretchLine t)).dil = Real.exp (2 * |t - s|) := by
  rw [dil_affine_eq_exp_dist]
  congr 1
  have h := teichDist_stretchLine s t
  rw [teichDist_eq_half_dist] at h
  linarith

/-- The Teichmüller space of the torus has infinite diameter. -/
theorem teichDist_unbounded (M : ℝ) : ∃ σ σ' : ℍ, M < teichDist σ σ' := by
  refine ⟨stretchLine 0, stretchLine (|M| + 1), ?_⟩
  rw [teichDist_stretchLine, sub_zero, abs_of_nonneg (by positivity : (0:ℝ) ≤ |M| + 1)]
  have := le_abs_self M
  linarith

end Teichmuller