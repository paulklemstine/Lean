import EML.QuadraticApproxRate

/-!
# EML depth--width tradeoff for the quadratic test function

This file builds on `emlQuadApprox`.  The scale is chosen as `h = w⁻²`, so the
single-activation, depth-two realization has uniform error `O(w⁻²)` on `[0,1]`.
The realization theorem displays the mission's activation
`exp(a*x+b) - log(a'*x+b')` explicitly (with `a'=0`, `b'=1`) followed by an
affine readout and linear skip connection.

The final two theorems compare the certified inverse-square bound with the
inverse-linear benchmark: the former is no larger for every positive width and
is strictly smaller once the width exceeds one.
-/

noncomputable section

open Real Set

namespace EMLDepthWidth

/-- The existing EML quadratic approximant at the inverse-square scale associated
with a width budget `w`. -/
def quadraticApproxAtWidth (w : ℕ) (x : ℝ) : ℝ :=
  emlQuadApprox (1 / (w : ℝ) ^ 2) x

/-- The approximant is a depth-two computation: one neuron with activation
`exp(a*x+b) - log(a'*x+b')`, followed by an affine readout (with a linear skip).
Only the already-catalogued function `emlQuadApprox` is being represented here. -/
theorem emlQuadApprox_depth_two_realization (h x : ℝ) :
    emlQuadApprox h x =
      (2 / h ^ 2) *
          (Real.exp (h * x + 0) - Real.log (0 * x + 1)) -
        (2 / h ^ 2) - (2 / h) * x := by
  unfold emlQuadApprox
  simp
  field_simp

/-- The displayed depth-two realization is smooth; this is its exact derivative. -/
theorem emlQuadApprox_hasDerivAt (h x : ℝ) :
    HasDerivAt (emlQuadApprox h)
      ((2 / h ^ 2) * (h * Real.exp (h * x) - h)) x := by
  unfold emlQuadApprox
  have hlin : HasDerivAt (fun y : ℝ => h * y) h x := by
    simpa using (hasDerivAt_id x).const_mul h
  have hexp : HasDerivAt (fun y : ℝ => Real.exp (h * y))
      (h * Real.exp (h * x)) x := by
    simpa [mul_comm] using (Real.hasDerivAt_exp (h * x)).comp x hlin
  simpa using ((hexp.sub_const 1).sub hlin).const_mul (2 / h ^ 2)

/-- **Certified inverse-square width rate.**  For every positive width budget,
the depth-two EML realization uniformly approximates `x²` on `[0,1]` with error
at most `4/(9w²)`. -/
theorem quadraticApproxAtWidth_error (w : ℕ) (hw : 1 ≤ w)
    (x : ℝ) (hx : x ∈ Icc (0 : ℝ) 1) :
    |quadraticApproxAtWidth w x - x ^ 2| ≤ 4 / (9 * (w : ℝ) ^ 2) := by
  unfold quadraticApproxAtWidth
  have hwR : (1 : ℝ) ≤ (w : ℝ) := by exact_mod_cast hw
  have hwpos : (0 : ℝ) < (w : ℝ) := lt_of_lt_of_le zero_lt_one hwR
  have hspos : 0 < (1 / (w : ℝ) ^ 2) := by positivity
  have hsle : 1 / (w : ℝ) ^ 2 ≤ 1 := by
    rw [div_le_one (by positivity)]
    nlinarith
  calc
    |emlQuadApprox (1 / (w : ℝ) ^ 2) x - x ^ 2| ≤
        (4 / 9) * (1 / (w : ℝ) ^ 2) :=
      emlQuadApprox_error (1 / (w : ℝ) ^ 2) hspos hsle x hx
    _ = 4 / (9 * (w : ℝ) ^ 2) := by field_simp

/-- The inverse-square certificate is at least as strong as the inverse-linear
benchmark at every positive integral width. -/
theorem inverse_square_le_inverse_linear (w : ℕ) (hw : 1 ≤ w) :
    4 / (9 * (w : ℝ) ^ 2) ≤ 4 / (9 * (w : ℝ)) := by
  have hwR : (1 : ℝ) ≤ (w : ℝ) := by exact_mod_cast hw
  have hwpos : (0 : ℝ) < (w : ℝ) := lt_of_lt_of_le zero_lt_one hwR
  rw [div_le_div_iff₀ (by positivity) (by positivity)]
  nlinarith

/-- Beyond width one, the certified inverse-square rate is strictly smaller than
the inverse-linear benchmark. -/
theorem inverse_square_lt_inverse_linear (w : ℕ) (hw : 2 ≤ w) :
    4 / (9 * (w : ℝ) ^ 2) < 4 / (9 * (w : ℝ)) := by
  have hwR : (2 : ℝ) ≤ (w : ℝ) := by exact_mod_cast hw
  have hwpos : (0 : ℝ) < (w : ℝ) := by linarith
  rw [div_lt_div_iff₀ (by positivity) (by positivity)]
  nlinarith

end EMLDepthWidth