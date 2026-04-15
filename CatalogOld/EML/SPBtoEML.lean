import Mathlib

/-!
# SPB to EML Conversion: The Arithmetic–Geometry Bridge

Key identity: `1 + spb(x,y)² = (1+x²)(1+y²) / (1-xy)²`
Conversion: `spb(x,y) = eml(eml(0, 1-xy) - eml(0, x+y), 1)`
-/

noncomputable section

open Real

namespace SPBtoEML

def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)
def eml (x y : ℝ) : ℝ := exp x - log y
def spbH (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-! ## The Fundamental Norm Identity -/

theorem spb_norm_identity (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + (spb x y) ^ 2) * (1 - x * y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring

theorem spb_norm_ratio (x y : ℝ) (h : 1 - x * y ≠ 0) :
    1 + (spb x y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) / (1 - x * y) ^ 2 := by
  have h2 : (1 - x * y) ^ 2 ≠ 0 := pow_ne_zero 2 h
  field_simp
  have := spb_norm_identity x y h
  linarith

/-! ## The Logarithmic Bridge Identity -/

theorem log_spb_norm (x y : ℝ) (h : 1 - x * y ≠ 0) :
    log (1 + (spb x y) ^ 2) =
    log (1 + x ^ 2) + log (1 + y ^ 2) - 2 * log |1 - x * y| := by
  convert congr_arg Real.log ( spb_norm_ratio x y h ) using 1;
  rw [ Real.log_div, Real.log_mul ] <;> first | positivity | aesop;

/-! ## EML Properties -/

theorem eml_is_exp (x : ℝ) : eml x 1 = exp x := by simp [eml, Real.log_one]
theorem eml_is_neg_log (y : ℝ) : eml 0 y = 1 - log y := by simp [eml]
theorem eml_identity_val : eml 0 1 = 1 := by simp [eml, Real.log_one]
theorem eml_generates_e : eml 1 1 = exp 1 := by simp [eml, Real.log_one]

/-! ## SPB via EML -/

theorem spb_eml_decomposition (x y : ℝ) (hden : 0 < 1 - x * y) :
    spb x y = (x + y) * exp (-log (1 - x * y)) := by
  unfold spb
  rw [Real.exp_neg, Real.exp_log hden]
  simp [spb, div_eq_mul_inv]

/-! ## arctan Homomorphism -/

theorem arctan_spb_add (x y : ℝ) (h : 0 < 1 - x * y) :
    arctan (spb x y) = arctan x + arctan y := by
  unfold spb
  exact (Real.arctan_add (by linarith : x * y < 1)).symm

theorem exp_arctan_spb_mul (x y : ℝ) (h : 0 < 1 - x * y) :
    exp (arctan (spb x y)) = exp (arctan x) * exp (arctan y) := by
  rw [arctan_spb_add x y h, Real.exp_add]

/-! ## SPB Group Properties -/

theorem spb_comm (x y : ℝ) : spb x y = spb y x := by
  simp [spb, add_comm, mul_comm]
theorem spb_zero (x : ℝ) : spb x 0 = x := by simp [spb]
theorem spb_neg (x : ℝ) : spb x (-x) = 0 := by simp [spb]

theorem spb_assoc (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (_h3 : 1 - spb x y * z ≠ 0) (_h4 : 1 - x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  simp only [spb]; field_simp; ring

theorem spb_self (x : ℝ) : spb x x = 2 * x / (1 - x * x) := by
  unfold spb; ring

theorem wick_rotation (x y : ℝ) :
    spb x (-y) = (x - y) / (1 + x * y) := by
  unfold spb; ring_nf

/-! ## Cauchy Entropy -/

def cauchyEntropy (x : ℝ) : ℝ := log (1 + x ^ 2)

theorem cauchyEntropy_nonneg (x : ℝ) : 0 ≤ cauchyEntropy x := by
  unfold cauchyEntropy; apply Real.log_nonneg; linarith [sq_nonneg x]

theorem cauchyEntropy_eq_zero_iff (x : ℝ) : cauchyEntropy x = 0 ↔ x = 0 := by
  constructor;
  · intro hx;
    contrapose! hx;
    exact ne_of_gt ( Real.log_pos <| by nlinarith [ mul_self_pos.2 hx ] );
  · unfold cauchyEntropy; aesop;

theorem cauchyEntropy_spb (x y : ℝ) (h : 1 - x * y ≠ 0) :
    cauchyEntropy (spb x y) =
    cauchyEntropy x + cauchyEntropy y - 2 * log |1 - x * y| :=
  log_spb_norm x y h

/-! ## SPB Derivative -/

theorem spb_hasDerivAt_fst (x y : ℝ) (h : 1 - x * y ≠ 0) :
    HasDerivAt (fun x' => spb x' y) ((1 + y ^ 2) / (1 - x * y) ^ 2) x := by
  convert HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_id x ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_id x ) ( hasDerivAt_const _ _ ) ) ) h using 1 ; ring;
  norm_num ; ring

theorem spb_deriv_pos (y d : ℝ) (hd : d ≠ 0) :
    (1 + y ^ 2) / d ^ 2 > 0 := by
  apply div_pos <;> [linarith [sq_nonneg y]; positivity]

end SPBtoEML