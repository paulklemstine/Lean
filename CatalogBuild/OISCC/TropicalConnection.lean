/-! # CatalogBuild.OISCC.TropicalConnection

Auto-generated from theorem catalog database.
Domain: OISCC
Declarations: 12
-/

import Mathlib

noncomputable section

def EML_trop (a b : ℝ) : ℝ := Real.exp a - Real.log b


theorem EML_trop_legendre (a b : ℝ) :
    EML_trop a (Real.exp b) = Real.exp a - b := by
  simp [EML_trop, Real.log_exp]


def tropVal (x : ℝ) : ℝ := Real.log x


theorem tropVal_EML_one (a : ℝ) :
    tropVal (EML_trop a 1) = a := by
  simp [tropVal, EML_trop, Real.log_one, Real.log_exp]


def logSumExp (a b : ℝ) : ℝ := Real.log (Real.exp a + Real.exp b)


theorem logSumExp_ge_left (a b : ℝ) : logSumExp a b ≥ a := by
  unfold logSumExp
  have h : Real.exp a ≤ Real.exp a + Real.exp b :=
    le_add_of_nonneg_right (Real.exp_nonneg b)
  linarith [Real.log_le_log (Real.exp_pos a) h, Real.log_exp a]


theorem logSumExp_ge_right (a b : ℝ) : logSumExp a b ≥ b := by
  unfold logSumExp
  have h : Real.exp b ≤ Real.exp a + Real.exp b :=
    le_add_of_nonneg_left (Real.exp_nonneg a)
  linarith [Real.log_le_log (Real.exp_pos b) h, Real.log_exp b]


theorem logSumExp_ge_max (a b : ℝ) : logSumExp a b ≥ max a b :=
  max_le (logSumExp_ge_left a b) (logSumExp_ge_right a b)


theorem logSumExp_comm (a b : ℝ) : logSumExp a b = logSumExp b a := by
  simp [logSumExp, add_comm]


def EML_poly1 (a b c x : ℝ) : ℝ := EML_trop (a + b * x) c


theorem EML_poly1_strictMono (a b c : ℝ) (hb : 0 < b) :
    StrictMono (EML_poly1 a b c) := by
  intro x₁ x₂ hx
  simp only [EML_poly1, EML_trop]
  have : a + b * x₁ < a + b * x₂ := by nlinarith
  linarith [Real.exp_lt_exp.mpr this]


theorem EML_superpolynomial_growth (c : ℝ) (n : ℕ) :
    ∀ᶠ x in Filter.atTop, EML_trop x c > x ^ n := by
      -- We know that $\lim_{x \to \infty} \frac{x^n}{\exp x} = 0$.
      have h_lim_zero : Filter.Tendsto (fun x : ℝ => x ^ n / Real.exp x) Filter.atTop (nhds 0) := by
        simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero n;
      -- Since $\exp(x)$ grows faster than any polynomial, we have $\exp(x) - \log(c) > x^n$ for sufficiently large $x$.
      have h_gt : ∀ᶠ x in Filter.atTop, Real.exp x - Real.log c > x ^ n := by
        filter_upwards [ h_lim_zero.eventually ( gt_mem_nhds <| show 0 < 1 / 2 by norm_num ), Filter.eventually_gt_atTop 0, Filter.eventually_ge_atTop <| 2 * |Real.log c| + 1 ] with x hx₁ hx₂ hx₃ using by nlinarith [ abs_le.mp ( show |Real.log c| ≤ |Real.log c| by norm_num ), Real.add_one_le_exp x, Real.exp_pos x, mul_div_cancel₀ ( x ^ n ) ( ne_of_gt <| Real.exp_pos x ) ] ;
      exact h_gt


end
