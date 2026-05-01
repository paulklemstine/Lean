import Mathlib
import Pythagorean.Core

/-! # CatalogBuild.Bridges.SPBBridge.GaussianIntegers

Auto-generated from theorem catalog database.
Domain: Bridges/SPBBridge
Declarations: 2
-/

noncomputable section

/-- Connecting SPB to Gaussian norm: |1+xi|² = 1+x². -/
theorem gaussian_norm_sq (x : ℝ) :
    Complex.normSq (1 + ↑x * Complex.I) = 1 + x ^ 2 := by
  simp [Complex.normSq_apply, Complex.add_re, Complex.add_im,
        Complex.ofReal_re, Complex.ofReal_im, Complex.mul_re, Complex.mul_im,
        Complex.I_re, Complex.I_im]; ring

/-- SPB norm identity as a consequence of Gaussian integer multiplication:
(1+xi)(1+yi) has norm (1+x²)(1+y²) and real part (1-xy), imaginary part (x+y).
So (1-xy)² + (x+y)² = (1+x²)(1+y²). -/
theorem spb_norm_gaussian (x y : ℝ) :
    (1 - x * y) ^ 2 + (x + y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by ring

end