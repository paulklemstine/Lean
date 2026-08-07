/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.RischGaussianObstruction

/-!
# Lab notes: verified worked instances

Polynomials over `ℚ` are not executable in Lean (`Polynomial.C` has no compiled code), so
the experimental data behind the theorems of

* `Catalog/Geometry/RischResidueLiouville.lean`,
* `Catalog/Geometry/RischSplitIntegration.lean`, and
* `Catalog/Geometry/RischGaussianObstruction.lean`

is recorded here as *proved* examples rather than `#eval` output.  Every number below is
therefore kernel-checked.

Data recorded:

| instance | residues | sum |
| --- | --- | --- |
| `1 / (x (x-1) (x-2))` | `1/2, -1, 1/2` | `0` |
| `x² / (x (x-1) (x-2))` | `0, -1, 2` | `1` |

The second row is the interesting one: the residue sum equals the coefficient of
`x^{n-1}` in the numerator (`n` = number of poles), not `0`.  This observation is what
`RischResidue.residue_sum` proves in general.

Risch differential equation solutions (`q' + a q = p`):

| `a` | `p` | `q` |
| --- | --- | --- |
| `1` | `x²` | `x² - 2x + 2` |
| `2` | `x`  | `x/2 - 1/4` |
-/

noncomputable section

open Polynomial

namespace RischExamples

/-! ## Residues of `1 / (x (x-1) (x-2))` -/

private lemma erase_zero : ({0, 1, 2} : Finset ℚ).erase 0 = {1, 2} := by decide
private lemma erase_one : ({0, 1, 2} : Finset ℚ).erase 1 = {0, 2} := by decide
private lemma erase_two : ({0, 1, 2} : Finset ℚ).erase 2 = {0, 1} := by decide

theorem residue_three_poles_zero : RischResidue.residue {0, 1, 2} (C 1) 0 = 1 / 2 := by
  rw [RischResidue.residue]
  norm_num [erase_zero]

theorem residue_three_poles_one : RischResidue.residue {0, 1, 2} (C 1) 1 = -1 := by
  rw [RischResidue.residue]
  norm_num [erase_one]

theorem residue_three_poles_two : RischResidue.residue {0, 1, 2} (C 1) 2 = 1 / 2 := by
  rw [RischResidue.residue]
  norm_num [erase_two]

/-- The residues of `1 / (x (x-1) (x-2))` sum to zero — the numerator degree is two below
the pole count, so there is no `x⁻¹` tail at infinity. -/
theorem residue_sum_three_poles :
    ∑ a ∈ ({0, 1, 2} : Finset ℚ), RischResidue.residue {0, 1, 2} (C 1) a = 0 := by
  norm_num [RischResidue.residue, erase_zero, erase_one, erase_two]

/-! ## Residues of `x² / (x (x-1) (x-2))` -/

theorem residue_sq_three_poles_one :
    RischResidue.residue {0, 1, 2} (X ^ 2) 1 = -1 := by
  rw [RischResidue.residue]
  norm_num [erase_one]

theorem residue_sq_three_poles_two :
    RischResidue.residue {0, 1, 2} (X ^ 2) 2 = 2 := by
  rw [RischResidue.residue]
  norm_num [erase_two]

/-- Here the residues sum to `1`, the leading coefficient of the numerator: the residue
sum is *not* always zero, it detects the `x⁻¹` behaviour at infinity. -/
theorem residue_sum_sq_three_poles :
    ∑ a ∈ ({0, 1, 2} : Finset ℚ), RischResidue.residue {0, 1, 2} (X ^ 2) a = 1 := by
  norm_num [RischResidue.residue, erase_zero, erase_one, erase_two]

/-! ## Solutions of the Risch differential equation -/

/-- `q' + q = x²` is solved by `q = x² - 2x + 2`. -/
theorem risch_de_example_one :
    derivative (X ^ 2 - 2 * X + 2 : ℚ[X]) + C 1 * (X ^ 2 - 2 * X + 2) = X ^ 2 := by
  simp [derivative_sub, derivative_add]
  ring

/-- `q' + 2q = x` is solved by `q = x/2 - 1/4`. -/
theorem risch_de_example_two :
    derivative (C (1 / 2 : ℚ) * X - C (1 / 4)) + C 2 * (C (1 / 2 : ℚ) * X - C (1 / 4)) = X := by
  rw [derivative_sub, derivative_C_mul, derivative_X, derivative_C, mul_one, sub_zero,
    mul_sub, ← mul_assoc, ← C_mul, ← C_mul]
  norm_num

end RischExamples