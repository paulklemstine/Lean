import Mathlib
import SPBBridge.Core

/-!
# SPB and Gaussian Integers / Sum of Squares

The Brahmagupta-Fibonacci identity (a²+b²)(c²+d²) = (ac-bd)²+(ad+bc)²
is intimately connected to SPB via the norm identity.

## Main Results
- `brahmagupta_fibonacci`: The sum-of-two-squares identity
- `spb_norm_mult`: (1+spb(x,y)²)(1-xy)² = (1+x²)(1+y²)
- `gaussian_norm_sq`: |1+xi|² = 1+x²
-/

noncomputable section
open Real SPBResearch

namespace SPBGaussian

/-- Brahmagupta-Fibonacci identity: (a²+b²)(c²+d²) = (ac-bd)²+(ad+bc)². -/
theorem brahmagupta_fibonacci (a b c d : ℝ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by
  ring

/-- Alternative form: (a²+b²)(c²+d²) = (ac+bd)²+(ad-bc)². -/
theorem brahmagupta_fibonacci_alt (a b c d : ℝ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c + b*d)^2 + (a*d - b*c)^2 := by
  ring

/-- The SPB norm identity: (1+spb(x,y)²)(1-xy)² = (1+x²)(1+y²). -/
theorem spb_norm_mult (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + spb x y ^ 2) * (1 - x * y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring

/-- Connecting SPB to Gaussian norm: |1+xi|² = 1+x². -/
theorem gaussian_norm_sq (x : ℝ) :
    Complex.normSq (1 + ↑x * Complex.I) = 1 + x ^ 2 := by
  simp [Complex.normSq_apply, Complex.add_re, Complex.add_im,
        Complex.ofReal_re, Complex.ofReal_im, Complex.mul_re, Complex.mul_im,
        Complex.I_re, Complex.I_im]; ring

/-- The norm of the product: |1+xi|²·|1+yi|² = (1+x²)(1+y²). -/
theorem gaussian_product_norm (x y : ℝ) :
    Complex.normSq (1 + ↑x * Complex.I) * Complex.normSq (1 + ↑y * Complex.I) =
    (1 + x ^ 2) * (1 + y ^ 2) := by
  rw [gaussian_norm_sq, gaussian_norm_sq]

/-- SPB norm identity as a consequence of Gaussian integer multiplication:
    (1+xi)(1+yi) has norm (1+x²)(1+y²) and real part (1-xy), imaginary part (x+y).
    So (1-xy)² + (x+y)² = (1+x²)(1+y²). -/
theorem spb_norm_gaussian (x y : ℝ) :
    (1 - x * y) ^ 2 + (x + y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by ring

end SPBGaussian
end
