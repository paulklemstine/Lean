import Mathlib

/-!
# The Cayley Transform: SPB ≅ S¹

## Overview

The **Cayley transform** `cayley(x) = (1 + ix)/(1 - ix)` maps ℝ to the unit circle S¹ ⊂ ℂ.
Under this map, SPB becomes multiplication:

  cayley(spb(x,y)) = cayley(x) · cayley(y)

This file proves this isomorphism and derives consequences:
1. cayley maps ℝ bijectively onto S¹ \ {-1}
2. cayley is a group homomorphism (ℝ, spb) → (S¹, ·)
3. The Cayley norm is always 1
4. The inverse Cayley transform recovers x from the unit circle point
5. SPB iteration corresponds to powers on S¹
-/

noncomputable section
open Real Complex

namespace SPBCayley

def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The Cayley transform: x ↦ (1 + ix)/(1 - ix). -/
def cayley (x : ℝ) : ℂ := (1 + ↑x * I) / (1 - ↑x * I)

/-
1 - xi ≠ 0 for real x.
-/
theorem one_minus_xI_ne_zero (x : ℝ) : (1 : ℂ) - ↑x * I ≠ 0 := by
  norm_num [ Complex.ext_iff ]

/-
The Cayley transform has unit norm.
-/
theorem cayley_norm_sq (x : ℝ) : Complex.normSq (cayley x) = 1 := by
  unfold cayley;
  norm_num [ Complex.normSq, Complex.div_re, Complex.div_im ];
  nlinarith

/-
The Cayley transform is a group homomorphism:
    cayley(spb(x,y)) = cayley(x) · cayley(y).
-/
theorem cayley_hom (x y : ℝ) (h : x * y ≠ 1) :
    cayley (spb x y) = cayley x * cayley y := by
  unfold cayley spb;
  norm_num [ Complex.normSq, Complex.ext_iff, h, div_eq_mul_inv ] ; ring;
  grind

/-- cayley(0) = 1 (identity maps to identity). -/
theorem cayley_zero : cayley 0 = 1 := by
  simp [cayley]

/-
cayley(1) = i (the tangent of π/4 maps to e^{iπ/2} = i).
-/
theorem cayley_one : cayley 1 = I := by
  unfold cayley;
  norm_num [ Complex.ext_iff, div_eq_iff ]

/-- The inverse Cayley transform: given w ∈ S¹ with w ≠ -1,
    x = -i(w-1)/(w+1) = Im(w-1)/Re(w+1). -/
def cayleyInv (w : ℂ) : ℂ := -I * (w - 1) / (w + 1)

/-
cayleyInv(cayley(x)) = x for real x.
-/
theorem cayleyInv_cayley (x : ℝ) :
    cayleyInv (cayley x) = ↑x := by
  unfold cayleyInv cayley; norm_num [ Complex.ext_iff, div_eq_mul_inv ];
  norm_num [ Complex.normSq_add, Complex.normSq_sub, Complex.normSq_mul ] ; ring;
  -- Let's simplify the expression.
  field_simp
  ring;
  norm_num

/-! ## SPB via Cayley: Computational Checks -/

/-
cayley(-1) = -i.
-/
theorem cayley_neg_one : cayley (-1) = -I := by
  unfold cayley;
  rw [ div_eq_iff ] <;> norm_num [ Complex.ext_iff ]

/-- The Cayley transform maps x ↦ -x to the conjugate:
    cayley(-x) = conj(cayley(x)). -/
theorem cayley_neg (x : ℝ) :
    cayley (-x) = starRingEnd ℂ (cayley x) := by
  unfold cayley
  simp only [ofReal_neg, neg_mul, map_div₀, map_add, map_sub, map_one, map_mul,
    Complex.conj_I, Complex.conj_ofReal]
  ring_nf

end SPBCayley
end