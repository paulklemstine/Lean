/-! # CatalogBuild.EML.CayleyTransform

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 19
-/

import Mathlib

noncomputable section

/-- The SPB-adapted Cayley transform: C'(x) = (1 + ix)/(1 - ix).
This maps ℝ → S¹ as a group homomorphism from (ℝ, spb) to (S¹, ·).
It IS stereographic projection from -1 ∈ S¹. -/
def spbCayley (x : ℝ) : ℂ := (1 + x * I) / (1 - x * I)

/-- Complex version of the SPB-adapted Cayley transform. -/

def spbCayleyC (z : ℂ) : ℂ := (1 + z * I) / (1 - z * I)

/-- The standard Cayley transform C(x) = (x - i)/(x + i). -/

def stdCayley (x : ℝ) : ℂ := (↑x - I) / (↑x + I)

/-- Inverse SPB-Cayley: C'⁻¹(w) = -i(w - 1)/(w + 1) = (1 - w)/(i(1 + w)). -/

def spbCayleyInv (w : ℂ) : ℂ := (w - 1) / (I * (w + 1))

/-! ## Unitarity: |C'(x)| = 1 for real x -/

/-- The SPB-Cayley transform numerator and denominator have equal normSq. -/

theorem spbCayley_normSq_eq (x : ℝ) :
    Complex.normSq (1 + x * I) = Complex.normSq (1 - x * I) := by
  simp [Complex.normSq_apply]

/-
The SPB-Cayley transform of a real number lies on S¹: ‖C'(x)‖ = 1.
-/

theorem spbCayley_norm_eq_one (x : ℝ) : ‖spbCayley x‖ = 1 := by
  unfold spbCayley; norm_num [ Complex.norm_def, Complex.normSq ] ;
  exact ne_of_gt <| Real.sqrt_pos.mpr <| by nlinarith

/-
normSq version.
-/

theorem spbCayley_normSq_eq_one (x : ℝ) : Complex.normSq (spbCayley x) = 1 := by
  convert congr_arg ( · ^ 2 ) ( spbCayley_norm_eq_one x ) using 1;
  · exact?;
  · norm_num

/-! ## Special Values -/

/-- C'(0) = 1 (identity maps to identity — correct!). -/

theorem spbCayley_zero : spbCayley 0 = 1 := by
  simp [spbCayley]

/-- The standard Cayley maps 0 to -1. -/

theorem stdCayley_zero : stdCayley 0 = -1 := by
  simp [stdCayley]

/-- The standard Cayley normSq equals that of num and denom. -/

theorem stdCayley_normSq_num_eq_denom (x : ℝ) :
    Complex.normSq (↑x - I) = Complex.normSq (↑x + I) := by
  simp [Complex.normSq_apply]

/-
‖stdCayley x‖ = 1.
-/

theorem stdCayley_norm_eq_one (x : ℝ) : ‖stdCayley x‖ = 1 := by
  norm_num [ stdCayley, Complex.norm_def, Complex.normSq ];
  exact ne_of_gt <| Real.sqrt_pos.mpr <| by nlinarith;

/-! ## The SPB definition for intertwining -/

/-- The stereographic sum. -/

def spbR (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-! ## The Intertwining Property (Main Theorem) -/

/-
**Key theorem**: The SPB-Cayley transform intertwines SPB with multiplication.
    C'(spb(x,y)) = C'(x) · C'(y)
    This says C' is a group homomorphism from (ℝ, spb) to (S¹, ·).
-/

theorem spbCayley_intertwines (x y : ℝ)
    (hx : 1 - x * I ≠ (0 : ℂ)) (hy : 1 - y * I ≠ (0 : ℂ))
    (hs : 1 - ↑(spbR x y) * I ≠ (0 : ℂ))
    (hd : (1 : ℝ) - x * y ≠ 0) :
    spbCayley (spbR x y) = spbCayley x * spbCayley y := by
  unfold spbR spbCayley; simp +decide [ *, Complex.ext_iff, div_eq_mul_inv ] ; ring;
  simp +decide [ Complex.normSq, sq ];
  grind

/-! ## Real and Imaginary Parts of the Standard Cayley -/

/-- Re(stdCayley(x)) = (x²-1)/(x²+1). -/

theorem stdCayley_re (x : ℝ) : (stdCayley x).re = (x ^ 2 - 1) / (x ^ 2 + 1) := by
  unfold stdCayley
  norm_num [Complex.normSq, Complex.div_re]; ring

/-- Im(stdCayley(x)) = -2x/(x²+1). -/

theorem stdCayley_im (x : ℝ) : (stdCayley x).im = -2 * x / (x ^ 2 + 1) := by
  unfold stdCayley
  norm_num [Complex.normSq, Complex.div_im]; ring

/-! ## Real and Imaginary Parts of the SPB-Cayley -/

/-
Re(spbCayley(x)) = (1-x²)/(1+x²).
-/

theorem spbCayley_re (x : ℝ) : (spbCayley x).re = (1 - x ^ 2) / (1 + x ^ 2) := by
  unfold spbCayley; norm_num [ Complex.normSq, Complex.div_re ] ; ring;

/-
Im(spbCayley(x)) = 2x/(1+x²).
-/

theorem spbCayley_im (x : ℝ) : (spbCayley x).im = 2 * x / (1 + x ^ 2) := by
  unfold spbCayley; norm_num [ Complex.normSq, Complex.div_im ] ; ring;

/-! ## Relationship between the two conventions -/

/-
C'(x) = -C(x): the two conventions differ by negation.
-/

theorem spbCayley_eq_neg_stdCayley (x : ℝ)
    (hx : (↑x : ℂ) + I ≠ 0) :
    spbCayley x = -stdCayley x := by
  unfold spbCayley stdCayley;
  rw [ ← neg_div, div_eq_div_iff ] <;> norm_num [ Complex.ext_iff ];
  ring

/-! ## Differentiability -/

/-- The complex SPB-Cayley is differentiable. -/

theorem spbCayleyC_differentiableAt (z : ℂ) (hz : 1 - z * I ≠ 0) :
    DifferentiableAt ℂ spbCayleyC z := by
  unfold spbCayleyC
  apply DifferentiableAt.div
  · exact (differentiableAt_const 1).add (differentiableAt_id.mul (differentiableAt_const I))
  · exact (differentiableAt_const 1).sub (differentiableAt_id.mul (differentiableAt_const I))
  · exact hz


end
