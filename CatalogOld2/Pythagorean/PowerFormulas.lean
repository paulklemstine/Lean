/-! # CatalogBuild.Pythagorean.PowerFormulas

Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 3
-/

import Mathlib
import Pythagorean.Core

noncomputable section

/-- Note: 5·arctan(1/5) ≠ π/4, so there is no "five-fold SPB of 1/5 = 1" identity.
Machin's formula is 4·arctan(1/5) - arctan(1/239) = π/4, verified elsewhere. -/
theorem spb_four_fifths_value :
    spb (spb (1/5 : ℝ) (1/5)) (spb (1/5) (1/5)) = 120/119 := by
  unfold spb; norm_num


/-- Iterated SPB from 1/2: spb(1/2, 1/2) = 4/3. -/
theorem spb_iter_half : spb (1/2 : ℝ) (1/2) = 4/3 := by
  unfold spb; norm_num


/-- Iterated SPB from 1/3: spb(1/3, 1/3) = 3/4. -/
theorem spb_iter_third : spb (1/3 : ℝ) (1/3) = 3/4 := by
  unfold spb; norm_num


end
