/-! # CatalogBuild.SPBBridge.CayleyTransform

Auto-generated from theorem catalog database.
Domain: SPBBridge
Declarations: 3
-/

import Mathlib
import SPBBridge.Core

noncomputable section

theorem cayley_injective : Function.Injective cayley := by
  intro x y hxy;
  unfold cayley at hxy;
  rw [ div_eq_div_iff ] at hxy;
  · norm_num [ Complex.ext_iff ] at hxy ; linarith;
  · norm_num [ Complex.ext_iff ];
  · norm_num [ Complex.ext_iff ]

/-
Cayley homomorphism: cayley(spb(x,y)) = cayley(x) * cayley(y).
-/

theorem one_minus_ix_normSq (x : ℝ) :
    Complex.normSq (1 - ↑x * Complex.I) = 1 + x ^ 2 := by
  norm_num [ Complex.normSq, sq ]

/-
1 - ix ≠ 0 for all x ∈ ℝ.
-/

theorem one_minus_ix_ne_zero (x : ℝ) :
    (1 : ℂ) - ↑x * Complex.I ≠ 0 := by
  norm_num [ Complex.ext_iff ]


end
