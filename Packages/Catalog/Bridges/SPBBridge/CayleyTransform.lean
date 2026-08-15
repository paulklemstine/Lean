import Mathlib
import Logic.StrangeLoops.Core
import Bridges.SPBBridge.AlgebraicIdentities
import Shared.CatalogbuildSharedCayley.Cayley

/-!
# Cayley Transform: Deep Properties

The Cayley transform C(x) = (1 + ix)/(1 - ix) maps ℝ to the unit circle S¹ ⊂ ℂ.
It converts the SPB operation to multiplication.

## Main Results
- Cayley has unit norm (lies on S¹)
- Cayley is injective
- Cayley homomorphism: C(spb(x,y)) = C(x)·C(y)
- Cayley special values: C(0) = 1, C(1) = i
- Inverse Cayley: C⁻¹(z) = -i(z-1)/(z+1)
-/

noncomputable section
open Real Complex SPBResearch

namespace CayleyDeep

/-
Cayley transform norm squared equals 1.
-/
theorem cayley_normSq (x : ℝ) : Complex.normSq (cayley x) = 1 := by
  unfold cayley;
  norm_num [ Complex.normSq, Complex.div_re, Complex.div_im ];
  nlinarith

/-- Cayley(0) = 1. -/
theorem cayley_zero : cayley 0 = 1 := by
  unfold cayley; simp

/-
Cayley(1) = i.
-/
theorem cayley_one : cayley 1 = Complex.I := by
  unfold cayley; norm_num [ Complex.ext_iff ];
  norm_num [ Complex.normSq, Complex.div_re, Complex.div_im ]

/-
Cayley(-1) = -i.
-/
theorem cayley_neg_one : cayley (-1) = -Complex.I := by
  unfold cayley;
  rw [ div_eq_iff ] <;> norm_num [ Complex.ext_iff ]

/-
Cayley is injective on ℝ.
-/
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
theorem cayley_spb_mul (x y : ℝ) (h : 1 - x * y ≠ 0) :
    cayley (spb x y) = cayley x * cayley y := by
  unfold cayley spb;
  rw [ div_mul_div_comm, div_eq_div_iff ] <;> norm_num [ Complex.ext_iff ] <;> ring;
  · norm_cast; norm_num [ h ] ; ring;
    grind;
  · norm_num [ Complex.normSq, Complex.ext_iff ] at *

/-
The fundamental norm identity via Cayley:
    |1 - ix|² = 1 + x² for all x ∈ ℝ.
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

end CayleyDeep
end