import Mathlib

/-!
# Cayley Transform: Real Spectrum → Unit Circle

We prove that the Cayley transform `z = (w − i)/(w + i)` maps real numbers
to the unit circle. Combined with the fact that Hermitian matrices have real
eigenvalues, this gives: Hermitian spectra yield unit-circle zero sets after
Cayley transport.

## Main Results

- `cayley_of_real_on_unit_circle`: real `w` maps to `‖z‖ = 1` under Cayley transform
- `cayley_denom_ne_zero`: the denominator `w + i` is nonzero when `w` is real
-/

open Complex

noncomputable section

/-- The Cayley transform sending `ℝ` to the unit circle. -/
def cayleyTransform (w : ℂ) : ℂ :=
  (w - I) / (w + I)

/-
The denominator `w + i` is nonzero when `w` is real.
-/
theorem cayley_denom_ne_zero {w : ℂ} (hw : w.im = 0) :
    w + I ≠ 0 := by
  exact ne_of_apply_ne Complex.im ( by norm_num [ hw ] )

/-
**Cayley transform of reals lands on the unit circle.**
    If `w` is real (i.e., `w.im = 0`), then `‖(w − i)/(w + i)‖ = 1`.
-/
theorem cayley_of_real_on_unit_circle
    {w : ℂ} (hw : w.im = 0) :
    ‖cayleyTransform w‖ = 1 := by
  unfold cayleyTransform; norm_num [ Complex.norm_def ];
  rw [ div_eq_iff ] <;> norm_num [ Complex.normSq, hw ];
  exact ne_of_gt <| Real.sqrt_pos.mpr <| by nlinarith

end