/-! # CatalogBuild.Algebra.SPBCayleyCircleGroup

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 9
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.SPBCayleyCircleGroup
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9] -/
theorem one_minus_xI_ne_zero (x : ℝ) : (1 : ℂ) - ↑x * I ≠ 0 := by
  norm_num [ Complex.ext_iff ]


/-- [Section: # CatalogBuild.Speculative.SPBCayleyCircleGroup
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9] -/
theorem cayley_norm_sq (x : ℝ) : Complex.normSq (cayley x) = 1 := by
  unfold cayley;
  norm_num [ Complex.normSq, Complex.div_re, Complex.div_im ];
  nlinarith


/-- [Section: # CatalogBuild.Speculative.SPBCayleyCircleGroup
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9] -/
theorem cayley_hom (x y : ℝ) (h : x * y ≠ 1) :
    cayley (spb x y) = cayley x * cayley y := by
  unfold cayley spb;
  norm_num [ Complex.normSq, Complex.ext_iff, h, div_eq_mul_inv ] ; ring;
  grind


/-- cayley(0) = 1 (identity maps to identity). -/
theorem cayley_zero : cayley 0 = 1 := by
  simp [cayley]


theorem cayley_one : cayley 1 = I := by
  unfold cayley;
  norm_num [ Complex.ext_iff, div_eq_iff ]


/-- The inverse Cayley transform: given w ∈ S¹ with w ≠ -1,
x = -i(w-1)/(w+1) = Im(w-1)/Re(w+1). -/
def cayleyInv (w : ℂ) : ℂ := -I * (w - 1) / (w + 1)


theorem cayleyInv_cayley (x : ℝ) :
    cayleyInv (cayley x) = ↑x := by
  unfold cayleyInv cayley; norm_num [ Complex.ext_iff, div_eq_mul_inv ];
  norm_num [ Complex.normSq_add, Complex.normSq_sub, Complex.normSq_mul ] ; ring;
  -- Let's simplify the expression.
  field_simp
  ring;
  norm_num


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


end
