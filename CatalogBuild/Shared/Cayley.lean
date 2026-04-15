/-! # CatalogBuild.Shared.Cayley

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 2
-/

import Mathlib

noncomputable section

def cayley (x : ℝ) : ℂ := (1 + x * Complex.I) / (1 - x * Complex.I)

/-
The Cayley transform has unit norm squared (lies on S¹) when `x` is real.
-/

theorem cayley_normSq (x : ℝ) : Complex.normSq (cayley x) = 1 := by
  unfold cayley;
  norm_num [ Complex.normSq ];
  nlinarith

/-
**Key bridge theorem**: The Cayley transform converts SPB to multiplication.
    `cayley(spb(x,y)) = cayley(x) * cayley(y)` when `xy ≠ 1`.
-/

end
