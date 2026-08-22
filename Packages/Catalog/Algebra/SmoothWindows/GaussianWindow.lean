import Algebra.SmoothWindows.GaborOperators

/-!
# Smooth windows II: the Gaussian window and its Fourier duality

Building on the Heisenberg/Weyl algebra of `Algebra.SmoothWindows.GaborOperators`, this file
introduces the **Gaussian window**

  `g_s(t) = exp(-π t² / s²)`,  `s > 0`,

and establishes the structural facts that make it the canonical smooth replacement for the
rectangular window of `Algebra.ReciprocalZeroHarmonics.WindowDichotomy`.

## Main results

* `gaussWin_translate_mul` — **the Gaussian window algebra is closed under products of
  translates**: `g_s(t-a) · g_s(t-b) = exp(-π(a-b)²/(2s²)) · g_{s/√2}(t - (a+b)/2)`.  Two Gaussian
  probes at different positions multiply to a *single* Gaussian probe at the midpoint, with an
  exponentially small overlap constant.  Nothing of this kind holds for rectangular windows.
* `fourier_transOp`, `fourier_modOp` — the Fourier transform **intertwines** translation and
  modulation: `𝓕 T_a = χ(-a·) 𝓕` and `𝓕 M_b = T_b 𝓕`.  Together with the Weyl relation this is
  the modulation/translation identity on the frequency side.
* `fourier_gaussC` — **Fourier self-duality with width inversion**: `𝓕 g_s = s · g_{1/s}`.  The
  Gaussian family is a fixed family of the Fourier transform; the width parameter is inverted,
  which is the exact form of the time–frequency uncertainty trade-off for this family.
* `fourier_gaborAtom` — the transform of a Gabor atom `T_a M_b g_s` is a modulated Gaussian
  centred at the frequency `b`; `norm_fourier_gaborAtom` shows its modulus is *exactly* a
  Gaussian bump, hence **strictly unimodal and sidelobe-free** (`norm_fourier_gaborAtom_lt` and
  `norm_fourier_gaborAtom_strictAnti`).
* `gaussWin_tendsto_zero_pow` — the Gaussian window has rapid (super-polynomial) decay, the
  Schwartz property that makes it usable as a smooth analysing window.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** Replacing the sharp cutoff by `g_s` should trade a discontinuous
  transfer function with slowly decaying sidelobes for a strictly unimodal, exponentially
  decaying one, *without* losing any of the exact algebraic identities.
* **Experiment (Experimenter).** The product identity is the polarisation identity
  `(t-a)² + (t-b)² = 2(t-m)² + (a-b)²/2` fed through `Real.exp_add`.  Self-duality is obtained by
  specialising Mathlib's `fourier_gaussian_pi` at `b = 1/s²`, the delicate part being the complex
  power `b^{1/2}` which must be identified with the real square root.
* **Analysis (Analyst).** The three phenomena — closure under products, self-duality, unimodality
  of the transform — are all consequences of a single fact: the Gaussian is the unique (up to the
  Heisenberg action) minimiser of the uncertainty product, hence a *fixed vector* for the
  metaplectic action.  The rectangular window has none of these properties.
* **Critique (Critic).** Every statement carries `0 < s`; at `s = 0` the definition degenerates
  (`x/0 = 0` in Lean gives the constant window `1`), which is why the hypothesis is kept
  explicit rather than derived.
-/

namespace SmoothWindows

open Complex Real MeasureTheory FourierTransform

/-! ## The Gaussian window -/

/-- The **Gaussian window** of width `s`: `g_s(t) = exp(-π t²/s²)`. -/
noncomputable def gaussWin (s t : ℝ) : ℝ := Real.exp (-π * t ^ 2 / s ^ 2)

/-- The complex-valued Gaussian window, as an element of the representation space `ℝ → ℂ`. -/
noncomputable def gaussC (s : ℝ) : ℝ → ℂ := fun t => (gaussWin s t : ℂ)

theorem gaussWin_pos (s t : ℝ) : 0 < gaussWin s t := Real.exp_pos _

@[simp] theorem gaussWin_zero (s : ℝ) : gaussWin s 0 = 1 := by simp [gaussWin]

theorem gaussWin_even (s t : ℝ) : gaussWin s (-t) = gaussWin s t := by
  simp [gaussWin]

theorem gaussWin_le_one (s t : ℝ) : gaussWin s t ≤ 1 := by
  rw [gaussWin, Real.exp_le_one_iff, neg_mul, neg_div, neg_nonpos]
  positivity

/-- The Gaussian window has a *strict* maximum at the origin: it is a genuine probe of a single
location, unlike the rectangular window which is constant on its support. -/
theorem gaussWin_lt_one {s t : ℝ} (hs : s ≠ 0) (ht : t ≠ 0) : gaussWin s t < 1 := by
  rw [gaussWin, Real.exp_lt_one_iff, neg_mul, neg_div, neg_lt_zero]
  have h1 : 0 < t ^ 2 := by positivity
  have h2 : 0 < s ^ 2 := by positivity
  exact div_pos (mul_pos Real.pi_pos h1) h2

theorem gaussC_ne_zero (s t : ℝ) : gaussC s t ≠ 0 := by
  simp only [gaussC, ne_eq, Complex.ofReal_eq_zero]
  exact (gaussWin_pos s t).ne'

@[simp] theorem norm_gaussC (s t : ℝ) : ‖gaussC s t‖ = gaussWin s t := by
  rw [gaussC, Complex.norm_real, Real.norm_eq_abs, abs_of_pos (gaussWin_pos s t)]

/-- **Closure of the Gaussian window algebra under products of translates.**  The product of two
Gaussian probes centred at `a` and `b` is an exponentially small multiple of a single narrower
Gaussian probe centred at the midpoint. -/
theorem gaussWin_translate_mul {s : ℝ} (hs : s ≠ 0) (a b t : ℝ) :
    gaussWin s (t - a) * gaussWin s (t - b)
      = Real.exp (-π * (a - b) ^ 2 / (2 * s ^ 2))
        * gaussWin (s / Real.sqrt 2) (t - (a + b) / 2) := by
  have hs2 : s ^ 2 ≠ 0 := pow_ne_zero _ hs
  have hsqrt : (Real.sqrt 2) ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  rw [gaussWin, gaussWin, gaussWin, ← Real.exp_add, ← Real.exp_add]
  congr 1
  rw [div_pow, hsqrt]
  field_simp
  ring

/-- Rapid decay of the Gaussian window: `t^n g_s(t) → 0` for every `n`.  This is the Schwartz
property that guarantees the smooth window has no algebraic tails. -/
theorem gaussWin_tendsto_zero_pow {s : ℝ} (hs : 0 < s) (n : ℕ) :
    Filter.Tendsto (fun t : ℝ => t ^ n * gaussWin s t) Filter.atTop (nhds 0) := by
  have hc : 0 < π / s ^ 2 := by positivity
  -- compare with `u^n e^{-u}` after the substitution `u = π t²/s²`
  have hbase := Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero n
  have harg : Filter.Tendsto (fun t : ℝ => π / s ^ 2 * t ^ 2) Filter.atTop Filter.atTop :=
    Filter.Tendsto.const_mul_atTop hc (Filter.tendsto_pow_atTop (by norm_num))
  have hcomp : Filter.Tendsto (fun t : ℝ => (π / s ^ 2 * t ^ 2) ^ n *
      Real.exp (-(π / s ^ 2 * t ^ 2))) Filter.atTop (nhds 0) := by
    simpa [Function.comp] using hbase.comp harg
  refine squeeze_zero' ?_ ?_ hcomp
  · filter_upwards [Filter.eventually_ge_atTop (0 : ℝ)] with t ht
    have := gaussWin_pos s t
    positivity
  · filter_upwards [Filter.eventually_ge_atTop (max 1 (s ^ 2 / π))] with t ht
    have ht1 : (1 : ℝ) ≤ t := le_trans (le_max_left _ _) ht
    have ht2 : s ^ 2 / π ≤ t := le_trans (le_max_right _ _) ht
    have hs2 : (0 : ℝ) < s ^ 2 := by positivity
    have hpi := Real.pi_pos
    have hst : s ^ 2 ≤ t * π := by rwa [div_le_iff₀ hpi] at ht2
    have hkey : t ≤ π / s ^ 2 * t ^ 2 := by
      rw [div_mul_eq_mul_div, le_div_iff₀ hs2]
      nlinarith
    have hpow : t ^ n ≤ (π / s ^ 2 * t ^ 2) ^ n := pow_le_pow_left₀ (by linarith) hkey n
    have hexp : gaussWin s t = Real.exp (-(π / s ^ 2 * t ^ 2)) := by
      rw [gaussWin]; congr 1; field_simp
    rw [hexp]
    exact mul_le_mul_of_nonneg_right hpow (Real.exp_pos _).le

/-! ## Fourier intertwining of translation and modulation -/

/-- **Translation becomes modulation.**  `𝓕 (T_a f)(w) = χ(-aw) 𝓕 f (w)`. -/
theorem fourier_transOp (a : ℝ) (f : ℝ → ℂ) (w : ℝ) :
    𝓕 (transOp a f) w = chi (-(a * w)) * 𝓕 f w := by
  simp only [Real.fourier_real_eq_integral_exp_smul, transOp, smul_eq_mul]
  rw [← MeasureTheory.integral_add_right_eq_self
    (fun v : ℝ => Complex.exp ((↑(-2 * π * v * w) : ℂ) * Complex.I) * f (v - a)) a]
  simp only [add_sub_cancel_right]
  rw [← MeasureTheory.integral_const_mul]
  refine MeasureTheory.integral_congr_ae (Filter.Eventually.of_forall fun v => ?_)
  simp only [chi]
  rw [← mul_assoc, ← Complex.exp_add]
  congr 2
  push_cast
  ring

/-- **Modulation becomes translation.**  `𝓕 (M_b f) = T_b (𝓕 f)`. -/
theorem fourier_modOp (b : ℝ) (f : ℝ → ℂ) (w : ℝ) :
    𝓕 (modOp b f) w = transOp b (𝓕 f) w := by
  simp only [Real.fourier_real_eq_integral_exp_smul, modOp, transOp, smul_eq_mul]
  refine MeasureTheory.integral_congr_ae (Filter.Eventually.of_forall fun v => ?_)
  simp only [chi]
  rw [← mul_assoc, ← Complex.exp_add]
  congr 2
  push_cast
  ring

/-! ## Fourier self-duality of the Gaussian window -/

/-- **The Gaussian family is Fourier self-dual with inverted width**: `𝓕 g_s = s · g_{1/s}`. -/
theorem fourier_gaussC {s : ℝ} (hs : 0 < s) :
    𝓕 (gaussC s) = fun ξ : ℝ => (s : ℂ) * gaussC (1 / s) ξ := by
  have hb : (0 : ℝ) < 1 / s ^ 2 := by positivity
  have hbc : (0 : ℝ) < (((1 / s ^ 2 : ℝ) : ℂ)).re := by rw [Complex.ofReal_re]; exact hb
  have hrw : gaussC s = fun x : ℝ => Complex.exp (-(π : ℂ) * ((1 / s ^ 2 : ℝ) : ℂ) * (x : ℂ) ^ 2) :=
    by
    funext x
    rw [gaussC, gaussWin, Complex.ofReal_exp]
    congr 1
    push_cast
    field_simp
  rw [hrw, fourier_gaussian_pi hbc]
  funext ξ
  have hsqrt : (((1 / s ^ 2 : ℝ) : ℂ)) ^ (1 / 2 : ℂ) = ((1 / s : ℝ) : ℂ) := by
    rw [show (1 / 2 : ℂ) = ((1 / 2 : ℝ) : ℂ) by norm_num,
      ← Complex.ofReal_cpow (by positivity)]
    congr 1
    rw [← Real.sqrt_eq_rpow, one_div, Real.sqrt_inv, Real.sqrt_sq hs.le, one_div]
  rw [hsqrt, gaussC, gaussWin, Complex.ofReal_exp]
  have hs' : (s : ℂ) ≠ 0 := by exact_mod_cast hs.ne'
  rw [show ((1 / s : ℝ) : ℂ) = 1 / (s : ℂ) by push_cast; ring]
  rw [one_div_one_div]
  congr 1
  push_cast
  field_simp

/-! ## Gabor atoms: a sidelobe-free transfer function -/

/-- The **Gabor atom** with Gaussian window: `T_a M_b g_s`, a smooth probe of the point `(a, b)`
of phase space. -/
noncomputable def gaborAtom (s a b : ℝ) : ℝ → ℂ := transOp a (modOp b (gaussC s))

theorem gaborAtom_apply (s a b t : ℝ) :
    gaborAtom s a b t = chi (b * (t - a)) * gaussC s (t - a) := rfl

/-- The Gabor atom is the image of the Gaussian under the Heisenberg action. -/
theorem gaborAtom_eq_gaborAct (s a b : ℝ) :
    gaborAtom s a b = gaborAct ⟨a, b, 1⟩ (gaussC s) := by
  funext t
  rw [gaborAct_apply, gaborAtom_apply]
  simp

/-- **Covariance of the Gaussian Gabor atoms.**  The Heisenberg group permutes the atoms: acting
by `g` moves the atom from the phase-space point `(a,b)` to `(g.a + a, g.b + b)`, changing only
the phase.  This is the modulation/translation identity in the form used by time–frequency
analysis. -/
theorem gaborAct_gaborAtom (g : Heis) (s a b : ℝ) :
    gaborAct g (gaborAtom s a b)
      = fun t => ((g.z : ℂ) * chi (g.b * a)) * gaborAtom s (g.a + a) (g.b + b) t := by
  rw [gaborAtom_eq_gaborAct, gaborAtom_eq_gaborAct, ← gaborAct_mul]
  funext t
  rw [gaborAct_apply, gaborAct_apply]
  simp only [Heis.mul_a, Heis.mul_b, Heis.mul_z, Circle.coe_mul, coe_circleExp, one_mul,
    Circle.coe_one, mul_one]
  ring

/-- **The transform of a Gaussian Gabor atom.**  It is a Gaussian bump in frequency, centred at
`b`, times a pure phase. -/
theorem fourier_gaborAtom {s : ℝ} (hs : 0 < s) (a b ξ : ℝ) :
    𝓕 (gaborAtom s a b) ξ = chi (-(a * ξ)) * ((s : ℂ) * gaussC (1 / s) (ξ - b)) := by
  rw [gaborAtom, fourier_transOp]
  congr 1
  rw [fourier_modOp, transOp, fourier_gaussC hs]

/-- **No sidelobes.**  The modulus of the transfer function of a Gaussian Gabor atom is exactly a
Gaussian bump: positive, with a single strict maximum at the analysed frequency `b`. -/
theorem norm_fourier_gaborAtom {s : ℝ} (hs : 0 < s) (a b ξ : ℝ) :
    ‖𝓕 (gaborAtom s a b) ξ‖ = s * gaussWin (1 / s) (ξ - b) := by
  rw [fourier_gaborAtom hs, norm_mul, norm_chi, one_mul, norm_mul, norm_gaussC,
    Complex.norm_real, Real.norm_eq_abs, abs_of_pos hs]

/-- Strict unimodality: away from the analysed frequency the response is strictly below the
peak.  A rectangular window has no such property (see `Algebra.SmoothWindows.Sidelobes`). -/
theorem norm_fourier_gaborAtom_lt {s : ℝ} (hs : 0 < s) (a b ξ : ℝ) (hξ : ξ ≠ b) :
    ‖𝓕 (gaborAtom s a b) ξ‖ < ‖𝓕 (gaborAtom s a b) b‖ := by
  rw [norm_fourier_gaborAtom hs, norm_fourier_gaborAtom hs, sub_self, gaussWin_zero, mul_one]
  have h := gaussWin_lt_one (s := 1 / s) (by positivity) (sub_ne_zero.mpr hξ)
  nlinarith [gaussWin_pos (1 / s) (ξ - b), hs]

/-- The transfer function is strictly decreasing in `|ξ - b|`: the smooth window produces a single
monotone lobe. -/
theorem norm_fourier_gaborAtom_strictAnti {s : ℝ} (hs : 0 < s) (a b ξ η : ℝ)
    (h : |ξ - b| < |η - b|) :
    ‖𝓕 (gaborAtom s a b) η‖ < ‖𝓕 (gaborAtom s a b) ξ‖ := by
  rw [norm_fourier_gaborAtom hs, norm_fourier_gaborAtom hs]
  have hsq : (ξ - b) ^ 2 < (η - b) ^ 2 := by
    have h0 : 0 ≤ |ξ - b| := abs_nonneg _
    nlinarith [sq_abs (ξ - b), sq_abs (η - b)]
  have hlt : gaussWin (1 / s) (η - b) < gaussWin (1 / s) (ξ - b) := by
    rw [gaussWin, gaussWin, Real.exp_lt_exp]
    have hpos : (0 : ℝ) < (1 / s) ^ 2 := by positivity
    rw [div_lt_div_iff_of_pos_right hpos]
    nlinarith [Real.pi_pos]
  nlinarith [gaussWin_pos (1 / s) (η - b)]

end SmoothWindows