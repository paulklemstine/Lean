import Mathlib

/-!
# The Gumbel law and extreme-value convergence: the analytic backbone of the
  Fyodorov–Hiary–Keating conjecture

The Fyodorov–Hiary–Keating (FHK) conjecture predicts that the maximum of
`log |ζ(1/2 + it)|` over a unit-scale window `[T, 2T]`, after the centering
`M_T - log log T + (3/2) log log log T`, converges in distribution to the sum of
two independent **Gumbel** random variables (Fyodorov–Hiary–Keating, 2012;
leading-order results by Arguin–Belius–Harper, 2017).

The full conjecture for `ζ` is open and far outside the reach of current
formalization.  This file instead formalizes the *rigorous analytic backbone* of
the statement: the Gumbel distribution itself and the extreme-value limit theorem
that produces it.  Concretely we prove:

* `gumbelCDF` is a genuine cumulative distribution function: strictly positive,
  bounded by `1`, strictly increasing, continuous, with the correct limits `0`
  and `1` at `±∞` (`gumbelCDF_pos`, `gumbelCDF_lt_one`, `gumbelCDF_strictMono`,
  `gumbelCDF_continuous`, `gumbelCDF_tendsto_atBot`, `gumbelCDF_tendsto_atTop`).

* **Max-stability of the Gumbel law** (`gumbel_max_stable`): raising the Gumbel
  CDF at the shifted point `x + log n` to the power `n` recovers `gumbelCDF x`.
  This exact algebraic self-similarity is *the* reason the Gumbel law is the
  universal attractor of maxima.

* **Extreme-value convergence** (`tendsto_expMax_gumbel`): the CDF of the
  recentered maximum of `n` i.i.d. `Exp(1)` variables, `(1 - e^{-x}/n)^n`,
  converges pointwise to `gumbelCDF x`.  This is the Fisher–Tippett–Gnedenko
  limit in the domain of attraction of the Gumbel law — the simplest exact
  instance of the phenomenon underlying FHK.

* The Gumbel probability density `gumbelPDF` is the derivative of `gumbelCDF`
  (`hasDerivAt_gumbelCDF`), is strictly positive (`gumbelPDF_pos`), and
  integrates to `1` over the whole line (`gumbelPDF_integral_eq_one`), so it is a
  genuine probability density.

* The Gumbel median is `-log(log 2)` (`gumbelCDF_median`).

All statements are elementary real analysis, but together they establish that the
object appearing in the FHK conjecture is a bona fide probability law arising as
an extreme-value limit.
-/

open Filter Topology MeasureTheory
open scoped Topology

namespace FHK

/-- The standard **Gumbel** cumulative distribution function
`G(x) = exp(-exp(-x))`. -/
noncomputable def gumbelCDF (x : ℝ) : ℝ := Real.exp (-Real.exp (-x))

/-- The standard **Gumbel** probability density
`g(x) = exp(-x - exp(-x))`, the derivative of `gumbelCDF`. -/
noncomputable def gumbelPDF (x : ℝ) : ℝ := Real.exp (-x - Real.exp (-x))

/-- The Gumbel CDF is strictly positive. -/
theorem gumbelCDF_pos (x : ℝ) : 0 < gumbelCDF x := Real.exp_pos _

/-- The Gumbel CDF is strictly below `1`. -/
theorem gumbelCDF_lt_one (x : ℝ) : gumbelCDF x < 1 := by
  rw [gumbelCDF, Real.exp_lt_one_iff]
  simp [Real.exp_pos]

/-- The Gumbel CDF is strictly increasing. -/
theorem gumbelCDF_strictMono : StrictMono gumbelCDF := by
  intro a b hab
  rw [gumbelCDF, gumbelCDF, Real.exp_lt_exp]
  simp only [neg_lt_neg_iff, Real.exp_lt_exp, neg_lt_neg_iff]
  exact hab

/-- The Gumbel CDF is continuous. -/
theorem gumbelCDF_continuous : Continuous gumbelCDF := by
  unfold gumbelCDF
  fun_prop

/-- The Gumbel CDF tends to `1` at `+∞`. -/
theorem gumbelCDF_tendsto_atTop : Tendsto gumbelCDF atTop (𝓝 1) := by
  have h1 : Tendsto (fun x : ℝ => Real.exp (-x)) atTop (𝓝 0) :=
    Real.tendsto_exp_neg_atTop_nhds_zero
  have h2 : Tendsto (fun x : ℝ => -Real.exp (-x)) atTop (𝓝 0) := by
    simpa using h1.neg
  have := (Real.continuous_exp.tendsto 0).comp h2
  simpa [gumbelCDF, Function.comp] using this

/-- The Gumbel CDF tends to `0` at `-∞`. -/
theorem gumbelCDF_tendsto_atBot : Tendsto gumbelCDF atBot (𝓝 0) := by
  have h1 : Tendsto (fun x : ℝ => Real.exp (-x)) atBot atTop :=
    Real.tendsto_exp_atTop.comp tendsto_neg_atBot_atTop
  have h2 : Tendsto (fun x : ℝ => -Real.exp (-x)) atBot atBot :=
    tendsto_neg_atTop_atBot.comp h1
  have := Real.tendsto_exp_atBot.comp h2
  simpa [gumbelCDF, Function.comp] using this

/-- **Max-stability of the Gumbel law.**  Raising the Gumbel CDF evaluated at the
shifted point `x + log n` to the `n`-th power returns `gumbelCDF x`.  Equivalently,
the maximum of `n` i.i.d. Gumbel variables, recentered by `log n`, is again exactly
Gumbel. -/
theorem gumbel_max_stable (n : ℕ) (hn : 0 < n) (x : ℝ) :
    (gumbelCDF (x + Real.log n)) ^ n = gumbelCDF x := by
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  rw [gumbelCDF, gumbelCDF, ← Real.exp_nat_mul]
  congr 1
  rw [neg_add, Real.exp_add, Real.exp_neg (Real.log ↑n), Real.exp_log hnpos]
  field_simp

/-- **Extreme-value convergence to the Gumbel law (Fisher–Tippett–Gnedenko).**
The CDF of the maximum of `n` i.i.d. `Exp(1)` random variables recentered by
`log n` is `(1 - e^{-x}/n)^n`, and it converges pointwise to the Gumbel CDF. -/
theorem tendsto_expMax_gumbel (x : ℝ) :
    Tendsto (fun n : ℕ => (1 - Real.exp (-x) / n) ^ n) atTop (𝓝 (gumbelCDF x)) := by
  have := Real.tendsto_one_add_div_pow_exp (-Real.exp (-x))
  rw [gumbelCDF]
  convert this using 2 with n
  ring

/-- The Gumbel density is strictly positive. -/
theorem gumbelPDF_pos (x : ℝ) : 0 < gumbelPDF x := Real.exp_pos _

/-- The Gumbel density is the derivative of the Gumbel CDF. -/
theorem hasDerivAt_gumbelCDF (x : ℝ) : HasDerivAt gumbelCDF (gumbelPDF x) x := by
  have hexpneg : HasDerivAt (fun x : ℝ => Real.exp (-x)) (-Real.exp (-x)) x := by
    simpa using (Real.hasDerivAt_exp (-x)).comp x (hasDerivAt_neg x)
  have hin : HasDerivAt (fun x : ℝ => -Real.exp (-x)) (Real.exp (-x)) x := by
    simpa using hexpneg.neg
  have hcomp := (Real.hasDerivAt_exp (-Real.exp (-x))).comp x hin
  have heq : Real.exp (-Real.exp (-x)) * Real.exp (-x) = gumbelPDF x := by
    rw [gumbelPDF, ← Real.exp_add]; ring_nf
  rw [← heq]
  exact hcomp

/-- The Gumbel density is integrable over the whole real line. -/
theorem gumbelPDF_integrable : Integrable gumbelPDF volume := by
  -- We'll use the fact that the integral of $gumbelPDF(x)$ over the entire real line is $1$.
  have h_int_gumbelPDF : (∫ x, gumbelPDF x) = (∫ x in Set.Ioi 0, Real.exp (-x)) := by
    have h_gumbelPDF_integral : ∫ x, gumbelPDF x = ∫ x in Set.image (fun x => Real.exp (-x)) Set.univ, Real.exp (-x) := by
      rw [ MeasureTheory.integral_image_eq_integral_abs_deriv_smul ] <;> norm_num [ gumbelPDF ];
      any_goals intro x; exact HasDerivAt.exp ( hasDerivAt_neg x );
      · norm_num [ abs_mul, Real.exp_pos, sub_eq_add_neg, Real.exp_add ];
      · exact fun x y h => by simpa using h;
    convert h_gumbelPDF_integral using 1;
    rw [ show ( fun x => Real.exp ( -x ) ) '' Set.univ = Set.Ioi 0 by ext x; exact ⟨ fun ⟨ y, _, hy ⟩ => hy ▸ Real.exp_pos _, fun hx => ⟨ -Real.log x, by norm_num, by simp +decide [ Real.exp_log hx ] ⟩ ⟩ ];
  exact ( by contrapose! h_int_gumbelPDF; rw [ MeasureTheory.integral_undef h_int_gumbelPDF ] ; linarith [ integral_exp_neg_Ioi_zero ] )

/-- **The Gumbel density is a probability density**: it integrates to `1`. -/
theorem gumbelPDF_integral_eq_one : ∫ x : ℝ, gumbelPDF x = 1 := by
  convert MeasureTheory.integral_of_hasDerivAt_of_tendsto ( fun x => hasDerivAt_gumbelCDF x ) ?_ ?_ ?_ using 1;
  rotate_left;
  exacts [ 0, 1, gumbelPDF_integrable, gumbelCDF_tendsto_atBot, gumbelCDF_tendsto_atTop, by norm_num ]

/-!
### The location–scale Gumbel family

We lift the standard Gumbel law to the two-parameter location–scale family
`G_{μ,β}(x) = exp(-exp(-(x-μ)/β))` with location `μ` and scale `β > 0`, and
recover positivity, boundedness, strict monotonicity, continuity, and the exact
max-stability `G_{μ,β}(x + β log n)^n = G_{μ,β}(x)` (the form directly relevant to
recentered maxima with a nontrivial scale).
-/

/-- The **location–scale Gumbel** CDF `G_{μ,β}(x) = exp(-exp(-(x-μ)/β))`. -/
noncomputable def gumbelCDFLS (μ β x : ℝ) : ℝ := Real.exp (-Real.exp (-((x - μ) / β)))

/-- The location–scale Gumbel CDF is a shift–rescale of the standard one. -/
theorem gumbelCDFLS_eq (μ β x : ℝ) : gumbelCDFLS μ β x = gumbelCDF ((x - μ) / β) := rfl

/-- The location–scale Gumbel CDF is strictly positive. -/
theorem gumbelCDFLS_pos (μ β x : ℝ) : 0 < gumbelCDFLS μ β x := Real.exp_pos _

/-- The location–scale Gumbel CDF is strictly below `1`. -/
theorem gumbelCDFLS_lt_one (μ β x : ℝ) : gumbelCDFLS μ β x < 1 := by
  rw [gumbelCDFLS, Real.exp_lt_one_iff]; simp [Real.exp_pos]

/-- For positive scale `β`, the location–scale Gumbel CDF is strictly increasing. -/
theorem gumbelCDFLS_strictMono (μ β : ℝ) (hβ : 0 < β) : StrictMono (gumbelCDFLS μ β) := by
  intro a b hab
  rw [gumbelCDFLS, gumbelCDFLS, Real.exp_lt_exp, neg_lt_neg_iff, Real.exp_lt_exp,
    neg_lt_neg_iff, div_lt_div_iff_of_pos_right hβ, sub_lt_sub_iff_right]
  exact hab

/-- The location–scale Gumbel CDF is continuous. -/
theorem gumbelCDFLS_continuous (μ β : ℝ) : Continuous (gumbelCDFLS μ β) := by
  unfold gumbelCDFLS; fun_prop

/-- **Max-stability of the location–scale Gumbel law.**  Raising `G_{μ,β}` at the
scale-shifted point `x + β log n` to the `n`-th power recovers `G_{μ,β} x`. -/
theorem gumbel_max_stableLS (μ β : ℝ) (hβ : 0 < β) (n : ℕ) (hn : 0 < n) (x : ℝ) :
    (gumbelCDFLS μ β (x + β * Real.log n)) ^ n = gumbelCDFLS μ β x := by
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  rw [gumbelCDFLS, gumbelCDFLS, ← Real.exp_nat_mul]
  congr 1
  have hβne : β ≠ 0 := ne_of_gt hβ
  rw [show -((x + β * Real.log ↑n - μ) / β) = (-((x - μ) / β)) + (- Real.log n) by
      field_simp; ring]
  rw [Real.exp_add, show -Real.log (↑n : ℝ) = Real.log (↑n)⁻¹ by rw [Real.log_inv],
    Real.exp_log (by positivity)]
  field_simp

/-- The median of the Gumbel law is `-log(log 2)`. -/
theorem gumbelCDF_median : gumbelCDF (-Real.log (Real.log 2)) = 1 / 2 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [gumbelCDF, neg_neg, Real.exp_log h2, Real.exp_neg, Real.exp_log (by norm_num)]
  norm_num

end FHK