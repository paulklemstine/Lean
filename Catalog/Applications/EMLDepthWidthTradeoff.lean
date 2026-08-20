/-
# EML expressiveness: depth, width, and a quadratic separation from shallow ReLU

An **EML neuron** computes `x ↦ exp(a x + b) − log(c x + d)` (the activation used
throughout the EML catalog, cf. `eml x y = exp x − log y`).  An **EML layer** of
width `k` is a real affine read-out of `k` such neurons, and depth is obtained by
composing layers.

This file settles, in the univariate model case `f(x) = x²`, the depth/width
trade-off conjectured in the mission statement, and it does so in a *sharper*
form than conjectured.

## Main results

* `sqLayer_eval`, `sqLayer_error` — the **width-2** EML layer
  `S_h(x) = (exp(h x) + exp(−h x) − 2)/h²` (a genuine `Layer 2`, with the
  logarithmic branches switched off by `log 1 = 0`) satisfies
  `|S_h x − x²| ≤ h² x⁴ / 6` whenever `|h x| ≤ 1`.
* `sqLayer_rate` — with `h = 1/n` this is the rate `1/(6 n²)`, a *quadratic*
  improvement on the catalog's forward-difference network
  (`EML.QuadraticApproxRate.emlQuadApprox`, rate `Θ(1/n)`).
* `forward_layer_error_lower_bound` — the forward-difference network really is
  `Θ(h)`: its error at `x = 1` is at least `h/3`.  So the improvement is not an
  artefact of a lossy estimate.
* `sqLayer_error_lower_bound`, `sqLayer_error_two_sided` — the rate is sharp:
  the error at `x = 1` is at least `h²/14`, so the width-2 layer is `Θ(h²)`.
* `sqLayer_deriv_error` — the same fixed-width-2 network approximates the
  *gradient* `2x` to `h²/2` ("smoother gradients").
* `quarticLayer2_error` — the **depth-2** network `S_h ∘ S_h` approximates `x⁴`
  on `[0,1]` with error `≤ h²`; depth composes without losing the rate.
* `relu_shallow_sq_lower_bound` — **lower bound**: *every* one-hidden-layer ReLU
  network with `k` units (even with an affine skip connection and arbitrary real
  parameters) has uniform error at least `1/(32 (k+1)²)` on `x²`.
* `relu_shallow_slope_lower_bound` — the same networks misestimate the *slope*
  `2x` by at least `1/(2(k+1))` somewhere.
* `eml_relu_width_separation` — putting these together: accuracy `ε` costs the
  EML model a *constant* width `2`, while any shallow ReLU model needs
  `(k+1)² ≥ 1/(32 ε)`, i.e. width `Ω(ε^{-1/2})`.

* `prodGate_error_unit`, `prodGate_error_two_sided` — **polarisation**:
  `x y = ((x+y)² − (x−y)²)/4` turns two copies of `S_h` into a width-`4`
  *multiplication gate* whose error on `[0,1]²` is again `Θ(h²)` (at most `h²`,
  at least `2h²/7` at the corner).
* `quadForm_error` — consequently a *single* EML layer of width `4 n²` computes
  every quadratic form on `[0,1]ⁿ` with error `h²·Σ|A i j|`: the constant is
  dimension-free, only the coefficient mass enters.
* `relu_shallow_prod_lower_bound`, `eml_relu_product_separation` — the ReLU
  barrier survives in two inputs: restricting to the diagonal turns a bivariate
  `k`-unit network into a univariate one, so approximating `x y` on `[0,1]²`
  still costs ReLU width `Ω(ε^{-1/2})` while EML pays width `4`.

The converse direction — that depth-2 EML networks *contain* shallow ReLU
networks (via softplus) and therefore also achieve the `O(1/N)` Jackson rate on
the whole Lipschitz class — is proved in the companion file
`Catalog/Applications/EMLSoftplusJackson.lean`.

The ReLU lower bound is proved from scratch: a pigeonhole argument produces a
subinterval of `[0,1]` of length `1/(k+1)` free of breakpoints
(`exists_breakpoint_free_interval`), on which the network is exactly affine
(`reluNet_affine_on_gap`), and an affine function cannot follow a parabola
(`affine_sq_error_lower`).

Everything is self-contained (`import Mathlib` only).
-/
import Mathlib

namespace EML.DepthWidth

open Real Set

noncomputable section

/-! ## 1. EML neurons, layers, and depth -/

/-- Parameters of a single **EML neuron** `x ↦ exp(a x + b) − log(c x + d)`. -/
structure Neuron where
  /-- weight inside the exponential branch -/
  a : ℝ
  /-- bias inside the exponential branch -/
  b : ℝ
  /-- weight inside the logarithmic branch -/
  c : ℝ
  /-- bias inside the logarithmic branch -/
  d : ℝ

/-- The function computed by an EML neuron. -/
def Neuron.eval (N : Neuron) (x : ℝ) : ℝ :=
  Real.exp (N.a * x + N.b) - Real.log (N.c * x + N.d)

/-- An **EML layer of width `k`**: an affine read-out of `k` EML neurons. -/
structure Layer (k : ℕ) where
  /-- the neurons of the layer -/
  neuron : Fin k → Neuron
  /-- the read-out weights -/
  out : Fin k → ℝ
  /-- the read-out bias -/
  bias : ℝ

/-- The function computed by an EML layer. -/
def Layer.eval {k : ℕ} (L : Layer k) (x : ℝ) : ℝ :=
  L.bias + ∑ i, L.out i * (L.neuron i).eval x

/-- Composition of two layers: a **depth-2** EML network. -/
def Layer.comp {k₁ k₂ : ℕ} (L₂ : Layer k₂) (L₁ : Layer k₁) (x : ℝ) : ℝ :=
  L₂.eval (L₁.eval x)

/-! ## 2. The width-2 EML layer for `x²` -/

/-- The **central-difference EML layer**: width `2`, both logarithmic branches
switched off (`log (0·x + 1) = 0`).  It computes
`(exp(h x) + exp(−h x) − 2)/h²`. -/
def sqLayer (h : ℝ) : Layer 2 where
  neuron := ![⟨h, 0, 0, 1⟩, ⟨-h, 0, 0, 1⟩]
  out := ![1 / h ^ 2, 1 / h ^ 2]
  bias := -2 / h ^ 2

theorem sqLayer_eval (h : ℝ) (hh : h ≠ 0) (x : ℝ) :
    (sqLayer h).eval x = (Real.exp (h * x) + Real.exp (-(h * x)) - 2) / h ^ 2 := by
  simp [sqLayer, Layer.eval, Neuron.eval, Fin.sum_univ_two]
  field_simp
  ring

/-- Taylor estimate for `2 cosh`: `|exp u + exp(−u) − 2 − u²| ≤ u⁴/6` for `|u| ≤ 1`. -/
theorem cosh_quartic_bound (u : ℝ) (hu : |u| ≤ 1) :
    |Real.exp u + Real.exp (-u) - 2 - u ^ 2| ≤ u ^ 4 / 6 := by
  have h1 := Real.exp_bound hu (n := 5) (by norm_num)
  have h2 := Real.exp_bound (x := -u) (by rwa [abs_neg]) (n := 5) (by norm_num)
  rw [abs_neg] at h2
  norm_num [Finset.sum_range_succ, Nat.factorial] at h1 h2
  rw [abs_le] at h1 h2 ⊢
  have h4 : |u| ^ 4 = u ^ 4 := by
    rw [← abs_pow]; exact abs_of_nonneg (by positivity)
  have habs : |u| ^ 5 ≤ u ^ 4 := by
    rw [← h4]
    nlinarith [abs_nonneg u, pow_nonneg (abs_nonneg u) 4]
  constructor <;> nlinarith [h1.1, h1.2, h2.1, h2.2, habs]

/-- **Uniform error of the width-2 EML layer.**  Whenever `|h x| ≤ 1`,
`S_h` approximates `x²` with error at most `h² x⁴ / 6`. -/
theorem sqLayer_error (h x : ℝ) (hh : h ≠ 0) (hu : |h * x| ≤ 1) :
    |(sqLayer h).eval x - x ^ 2| ≤ h ^ 2 * x ^ 4 / 6 := by
  have hkey := cosh_quartic_bound (h * x) hu
  have hid : (sqLayer h).eval x - x ^ 2 =
      (Real.exp (h * x) + Real.exp (-(h * x)) - 2 - (h * x) ^ 2) / h ^ 2 := by
    rw [sqLayer_eval h hh]; field_simp
  rw [hid, abs_div, abs_of_pos (by positivity : (0:ℝ) < h ^ 2)]
  rw [div_le_iff₀ (by positivity : (0:ℝ) < h ^ 2)]
  calc |Real.exp (h * x) + Real.exp (-(h * x)) - 2 - (h * x) ^ 2| ≤ (h * x) ^ 4 / 6 := hkey
    _ = h ^ 2 * x ^ 4 / 6 * h ^ 2 := by ring

/-- **Jackson-type rate at width 2.**  With `h = 1/n` the width-2 EML layer
approximates `x²` on `[0,1]` with error `1/(6 n²)` — the `O(w^{-2})` rate of the
mission statement, achieved at *constant* width. -/
theorem sqLayer_rate (n : ℕ) (hn : 1 ≤ n) (x : ℝ) (hx : x ∈ Icc (0:ℝ) 1) :
    |(sqLayer (1 / n)).eval x - x ^ 2| ≤ 1 / (6 * (n:ℝ) ^ 2) := by
  obtain ⟨hx0, hx1⟩ := hx
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  have hn1 : (1:ℝ) ≤ n := by exact_mod_cast hn
  have hh : (1 / (n:ℝ)) ≠ 0 := by positivity
  have hu : |1 / (n:ℝ) * x| ≤ 1 := by
    rw [abs_le]
    constructor
    · nlinarith [mul_nonneg (le_of_lt (show (0:ℝ) < 1 / n by positivity)) hx0]
    · rw [div_mul_eq_mul_div, one_mul, div_le_one hn0]
      linarith
  refine (sqLayer_error (1 / n) x hh hu).trans ?_
  have hx4 : x ^ 4 ≤ 1 := pow_le_one₀ hx0 hx1
  have hc : (0:ℝ) < 1 / (6 * (n:ℝ) ^ 2) := by positivity
  have key : (1 / (n:ℝ)) ^ 2 * x ^ 4 / 6 = x ^ 4 * (1 / (6 * (n:ℝ) ^ 2)) := by
    field_simp
  rw [key]
  calc x ^ 4 * (1 / (6 * (n:ℝ) ^ 2)) ≤ 1 * (1 / (6 * (n:ℝ) ^ 2)) :=
        mul_le_mul_of_nonneg_right hx4 hc.le
    _ = 1 / (6 * (n:ℝ) ^ 2) := one_mul _

/-- Existence form: *constant* width `2` suffices for **any** target accuracy. -/
theorem eml_width_two_universal (ε : ℝ) (hε : 0 < ε) :
    ∃ h : ℝ, 0 < h ∧ ∀ x ∈ Icc (0:ℝ) 1, |(sqLayer h).eval x - x ^ 2| ≤ ε := by
  refine ⟨min 1 ε, lt_min one_pos hε, fun x hx => ?_⟩
  set h := min 1 ε with hdef
  have hh1 : h ≤ 1 := min_le_left _ _
  have hhε : h ≤ ε := min_le_right _ _
  have hh0 : 0 < h := lt_min one_pos hε
  obtain ⟨hx0, hx1⟩ := hx
  have hu : |h * x| ≤ 1 := by
    rw [abs_le]
    constructor <;> nlinarith
  refine (sqLayer_error h x hh0.ne' hu).trans ?_
  have hx4 : x ^ 4 ≤ 1 := pow_le_one₀ hx0 hx1
  nlinarith [pow_nonneg hx0 4, sq_nonneg h]

/-! ## 3. The forward-difference layer is genuinely slower -/

/-- The catalog's forward-difference EML network `(2/h²)(exp(h x) − 1 − h x)`,
realised here as an EML `Layer 1`. -/
def forwardLayer (h : ℝ) : Layer 1 where
  neuron := ![⟨h, 0, 0, 1⟩]
  out := ![2 / h ^ 2]
  bias := -2 / h ^ 2

theorem forwardLayer_eval (h : ℝ) (hh : h ≠ 0) (x : ℝ) :
    (forwardLayer h).eval x = 2 / h ^ 2 * (Real.exp (h * x) - 1) := by
  simp [forwardLayer, Layer.eval, Neuron.eval]
  field_simp
  ring

/-- **The forward construction is only first order.**  At `x = 1` its error is at
least `h/3`, hence it cannot achieve the `O(h²)` rate of the central layer.
(Here the `h·x` linear term is subtracted by the read-out, exactly as in
`EML.QuadraticApproxRate.emlQuadApprox`.) -/
theorem forward_layer_error_lower_bound (h : ℝ) (hh : 0 < h) :
    h / 3 ≤ 2 / h ^ 2 * (Real.exp h - 1 - h) - 1 := by
  have hexp : 1 + h + h ^ 2 / 2 + h ^ 3 / 6 ≤ Real.exp h := by
    have := Real.sum_le_exp_of_nonneg hh.le 4
    norm_num [Finset.sum_range_succ, Nat.factorial] at this
    linarith
  rw [le_sub_iff_add_le, ← sub_nonneg]
  have h2 : (0:ℝ) < h ^ 2 := by positivity
  rw [← sub_nonneg] at hexp
  have key : 2 / h ^ 2 * (Real.exp h - 1 - h) - 1 - h / 3
      = 2 / h ^ 2 * (Real.exp h - (1 + h + h ^ 2 / 2 + h ^ 3 / 6)) := by
    field_simp; ring
  nlinarith [key, hexp, div_pos (by norm_num : (0:ℝ) < 2) h2]

/-! ## 3b. Sharpness: the width-2 rate is exactly `Θ(h²)` -/

/-- Lower Taylor estimate for `2 cosh`, from `Real.sum_le_exp_of_nonneg` at
`n = 5` together with `Real.exp_bound` at `n = 6` for the reflected argument. -/
theorem cosh_quartic_lower (h : ℝ) (hh0 : 0 < h) (hh1 : h ≤ 1) :
    2 + h ^ 2 + h ^ 4 / 14 ≤ Real.exp h + Real.exp (-h) := by
  have h1 := Real.sum_le_exp_of_nonneg hh0.le 5
  have h2 := Real.exp_bound (x := -h) (by rw [abs_neg, abs_of_pos hh0]; exact hh1) (n := 6)
    (by norm_num)
  norm_num [Finset.sum_range_succ, Nat.factorial] at h1 h2
  rw [abs_le] at h2
  have habs : |h| ^ 6 = h ^ 6 := by rw [abs_of_pos hh0]
  rw [habs] at h2
  have h5 : h ^ 5 ≤ h ^ 4 := by nlinarith [pow_pos hh0 4]
  have h6 : h ^ 6 ≤ h ^ 4 := by nlinarith [pow_pos hh0 4, pow_pos hh0 5]
  linarith [h1, h2.1]

/-- **The `O(h²)` rate of `sqLayer_error` cannot be improved.**  At the endpoint
`x = 1` the error of the width-2 EML layer is at least `h²/14`, so the exponent
`2` is exact and the upper bound `h²/6` is off only by a constant factor. -/
theorem sqLayer_error_lower_bound (h : ℝ) (hh0 : 0 < h) (hh1 : h ≤ 1) :
    h ^ 2 / 14 ≤ |(sqLayer h).eval 1 - 1 ^ 2| := by
  have hid : (sqLayer h).eval 1 - 1 ^ 2
      = (Real.exp h + Real.exp (-h) - 2 - h ^ 2) / h ^ 2 := by
    rw [sqLayer_eval h hh0.ne']
    field_simp
  have hlow := cosh_quartic_lower h hh0 hh1
  have hpos : 0 < h ^ 2 := by positivity
  have hge : h ^ 2 / 14 ≤ (Real.exp h + Real.exp (-h) - 2 - h ^ 2) / h ^ 2 := by
    rw [le_div_iff₀ hpos]
    have : h ^ 2 / 14 * h ^ 2 = h ^ 4 / 14 := by ring
    rw [this]
    linarith
  rw [hid]
  exact le_trans hge (le_abs_self _)

/-- **Two-sided rate.**  The width-2 EML layer's uniform error on `[0,1]` is
`Θ(h²)`: at least `h²/14` and at most `h²/6`. -/
theorem sqLayer_error_two_sided (h : ℝ) (hh0 : 0 < h) (hh1 : h ≤ 1) :
    h ^ 2 / 14 ≤ |(sqLayer h).eval 1 - 1 ^ 2| ∧
      ∀ x ∈ Icc (0:ℝ) 1, |(sqLayer h).eval x - x ^ 2| ≤ h ^ 2 / 6 := by
  refine ⟨sqLayer_error_lower_bound h hh0 hh1, fun x hx => ?_⟩
  obtain ⟨hx0, hx1⟩ := hx
  have hu : |h * x| ≤ 1 := by
    rw [abs_le]; constructor <;> nlinarith
  refine (sqLayer_error h x hh0.ne' hu).trans ?_
  have hx4 : x ^ 4 ≤ 1 := pow_le_one₀ hx0 hx1
  nlinarith [pow_nonneg hx0 4, sq_nonneg h]

/-! ## 4. Gradients: the width-2 EML layer also learns the derivative -/

/-- Taylor estimate for `2 sinh`: `|exp u − exp(−u) − 2u| ≤ |u|³/2` for `|u| ≤ 1`. -/
theorem sinh_cubic_bound (u : ℝ) (hu : |u| ≤ 1) :
    |Real.exp u - Real.exp (-u) - 2 * u| ≤ |u| ^ 3 / 2 := by
  have h1 := Real.exp_bound hu (n := 4) (by norm_num)
  have h2 := Real.exp_bound (x := -u) (by rwa [abs_neg]) (n := 4) (by norm_num)
  rw [abs_neg] at h2
  norm_num [Finset.sum_range_succ, Nat.factorial] at h1 h2
  rw [abs_le] at h1 h2 ⊢
  have h3 : |u| ^ 3 = |u ^ 3| := by rw [abs_pow]
  have hcube : u ^ 3 ≤ |u| ^ 3 ∧ -(|u| ^ 3) ≤ u ^ 3 := by
    constructor
    · rw [h3]; exact le_abs_self _
    · rw [h3]; exact neg_abs_le _
  have habs : |u| ^ 4 ≤ |u| ^ 3 := by
    have := abs_nonneg u
    nlinarith [pow_nonneg (abs_nonneg u) 3, pow_nonneg (abs_nonneg u) 4]
  have h4 : |u| ^ 4 = u ^ 4 := by rw [← abs_pow, abs_of_nonneg (by positivity)]
  constructor <;> nlinarith [h1.1, h1.2, h2.1, h2.2, habs, hcube.1, hcube.2]

theorem sqLayer_hasDerivAt (h : ℝ) (hh : h ≠ 0) (x : ℝ) :
    HasDerivAt (sqLayer h).eval ((Real.exp (h * x) - Real.exp (-(h * x))) / h) x := by
  have hfun : (sqLayer h).eval =
      fun y => (Real.exp (h * y) + Real.exp (-(h * y)) - 2) / h ^ 2 := by
    funext y; exact sqLayer_eval h hh y
  rw [hfun]
  have d1 : HasDerivAt (fun y : ℝ => Real.exp (h * y)) (Real.exp (h * x) * h) x := by
    simpa using (Real.hasDerivAt_exp (h * x)).comp x ((hasDerivAt_id x).const_mul h)
  have d2 : HasDerivAt (fun y : ℝ => Real.exp (-(h * y))) (Real.exp (-(h * x)) * -h) x := by
    have : HasDerivAt (fun y : ℝ => -(h * y)) (-h) x := by
      simpa using ((hasDerivAt_id x).const_mul h).neg
    simpa using (Real.hasDerivAt_exp (-(h * x))).comp x this
  have d3 := ((d1.add d2).sub_const 2).div_const (h ^ 2)
  convert d3 using 1
  field_simp
  ring

/-- **Smooth gradients.**  The very same width-2 EML layer approximates the
derivative `2x` of the target with error `h²/2` on `[0,1]`. -/
theorem sqLayer_deriv_error (h x : ℝ) (hh : 0 < h) (hh1 : h ≤ 1) (hx : x ∈ Icc (0:ℝ) 1) :
    |(Real.exp (h * x) - Real.exp (-(h * x))) / h - 2 * x| ≤ h ^ 2 / 2 := by
  have hu : |h * x| ≤ 1 := by
    rw [abs_le]; constructor <;> nlinarith [hx.1, hx.2]
  have hkey := sinh_cubic_bound (h * x) hu
  have hid : (Real.exp (h * x) - Real.exp (-(h * x))) / h - 2 * x
      = (Real.exp (h * x) - Real.exp (-(h * x)) - 2 * (h * x)) / h := by
    field_simp
  rw [hid, abs_div, abs_of_pos hh, div_le_iff₀ hh]
  have habs : |h * x| ^ 3 ≤ h ^ 3 := by
    rw [abs_of_nonneg (by nlinarith [hx.1] : (0:ℝ) ≤ h * x)]
    have hx3 : x ^ 3 ≤ 1 := pow_le_one₀ hx.1 hx.2
    have : (h * x) ^ 3 = h ^ 3 * x ^ 3 := by ring
    rw [this]
    nlinarith [pow_pos hh 3, pow_nonneg hx.1 3]
  calc |Real.exp (h * x) - Real.exp (-(h * x)) - 2 * (h * x)| ≤ |h * x| ^ 3 / 2 := hkey
    _ ≤ h ^ 3 / 2 := by linarith
    _ = h ^ 2 / 2 * h := by ring

/-! ## 5. Depth 2: composing the layer approximates `x⁴` -/

/-- **Depth-2 EML network** `S_h ∘ S_h`, of width `2` in each layer, approximates
`x⁴` on `[0,1]` with error `≤ h²`.  Depth composes without degrading the
second-order rate. -/
theorem quarticLayer2_error (h : ℝ) (hh : 0 < h) (hh2 : h ≤ 1 / 2)
    (x : ℝ) (hx : x ∈ Icc (0:ℝ) 1) :
    |(sqLayer h).comp (sqLayer h) x - x ^ 4| ≤ h ^ 2 := by
  obtain ⟨hx0, hx1⟩ := hx
  set y := (sqLayer h).eval x with hy
  have hu : |h * x| ≤ 1 := by
    rw [abs_le]; constructor <;> nlinarith
  have hx4 : x ^ 4 ≤ 1 := pow_le_one₀ hx0 hx1
  have hx2le : x ^ 2 ≤ 1 := pow_le_one₀ hx0 hx1
  have e1 : |y - x ^ 2| ≤ h ^ 2 * x ^ 4 / 6 := sqLayer_error h x hh.ne' hu
  have e1' : |y - x ^ 2| ≤ h ^ 2 / 6 := by
    refine e1.trans ?_
    nlinarith [pow_nonneg hx0 4, sq_nonneg h]
  have hh6 : h ^ 2 / 6 ≤ 1 / 24 := by nlinarith
  obtain ⟨hyl, hyr⟩ := abs_le.1 e1'
  have hybound : |y| ≤ 25 / 24 := by
    rw [abs_le]
    constructor <;> nlinarith [sq_nonneg x]
  obtain ⟨hyl', hyr'⟩ := abs_le.1 hybound
  have huy : |h * y| ≤ 1 := by
    rw [abs_mul, abs_of_pos hh]
    nlinarith [abs_nonneg y]
  have e2 : |(sqLayer h).eval y - y ^ 2| ≤ h ^ 2 * y ^ 4 / 6 :=
    sqLayer_error h y hh.ne' huy
  have hy2 : y ^ 2 ≤ 625 / 576 := by nlinarith
  have hy4 : y ^ 4 ≤ 2 := by nlinarith [sq_nonneg y]
  have e2' : |(sqLayer h).eval y - y ^ 2| ≤ h ^ 2 / 3 := by
    refine e2.trans ?_
    nlinarith [sq_nonneg h, pow_nonneg (sq_nonneg y) 2]
  have e3 : |y ^ 2 - x ^ 4| ≤ h ^ 2 / 2 := by
    have hfac : y ^ 2 - x ^ 4 = (y - x ^ 2) * (y + x ^ 2) := by ring
    have hsum : |y + x ^ 2| ≤ 25 / 24 + 1 := by
      rw [abs_le]; constructor <;> nlinarith [sq_nonneg x]
    have h1 : |y - x ^ 2| * |y + x ^ 2| ≤ (h ^ 2 / 6) * (25 / 24 + 1) :=
      mul_le_mul e1' hsum (abs_nonneg _) (by positivity)
    rw [hfac, abs_mul]
    nlinarith [h1, sq_nonneg h]
  have hsplit : (sqLayer h).comp (sqLayer h) x - x ^ 4
      = ((sqLayer h).eval y - y ^ 2) + (y ^ 2 - x ^ 4) := by
    simp only [Layer.comp, ← hy]; ring
  rw [hsplit]
  calc |(sqLayer h).eval y - y ^ 2 + (y ^ 2 - x ^ 4)|
      ≤ |(sqLayer h).eval y - y ^ 2| + |y ^ 2 - x ^ 4| := abs_add_le _ _
    _ ≤ h ^ 2 / 3 + h ^ 2 / 2 := by linarith
    _ ≤ h ^ 2 := by linarith

    _ ≤ h ^ 2 := by linarith

/-! ## 6. Shallow ReLU networks: a matching lower bound -/

/-- ReLU. -/
def relu (t : ℝ) : ℝ := max t 0

/-- A one-hidden-layer ReLU network with `k` units, an affine skip connection
`c₀ + c₁ x`, arbitrary hidden weights `w`, biases `b` and read-out weights `a`. -/
def reluNet (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ : ℝ) (x : ℝ) : ℝ :=
  c₀ + c₁ * x + ∑ i, a i * relu (w i * x + b i)

/-- **Pigeonhole for breakpoints.** Among the `k+1` equal subintervals of `[0,1]`
at least one contains no breakpoint of a `k`-unit ReLU network. -/
theorem exists_breakpoint_free_interval (k : ℕ) (w b : Fin k → ℝ) :
    ∃ j : Fin (k + 1), ∀ x ∈ Ioo ((j : ℝ) / (k + 1)) (((j : ℝ) + 1) / (k + 1)),
      ∀ i, w i ≠ 0 → w i * x + b i ≠ 0 := by
  by_contra hcon
  push_neg at hcon
  choose x hx i hi hi0 using hcon
  have hk : (0:ℝ) < (k : ℝ) + 1 := by positivity
  have mono : ∀ j₁ j₂ : Fin (k + 1), (j₁ : ℕ) < (j₂ : ℕ) → x j₁ < x j₂ := by
    intro j₁ j₂ hlt
    have h1 := (hx j₁).2
    have h2 := (hx j₂).1
    have hcast : ((j₁ : ℝ) + 1) ≤ (j₂ : ℝ) := by
      have : ((j₁ : ℕ) + 1 : ℝ) ≤ ((j₂ : ℕ) : ℝ) := by exact_mod_cast hlt
      push_cast at this ⊢
      linarith
    have : ((j₁ : ℝ) + 1) / ((k : ℝ) + 1) ≤ (j₂ : ℝ) / ((k : ℝ) + 1) := by
      gcongr
    linarith
  have hinj : Function.Injective i := by
    intro j₁ j₂ hij
    by_contra hne
    have hxeq : x j₁ = x j₂ := by
      have h1 := hi0 j₁
      have h2 := hi0 j₂
      rw [hij] at h1
      have hw : w (i j₂) ≠ 0 := hi j₂
      have : w (i j₂) * (x j₁ - x j₂) = 0 := by linarith [h1, h2]
      rcases mul_eq_zero.1 this with h | h
      · exact absurd h hw
      · linarith
    have hjne : (j₁ : ℕ) ≠ (j₂ : ℕ) := fun hcontra => hne (Fin.ext hcontra)
    rcases lt_or_gt_of_ne hjne with hlt | hlt
    · exact absurd hxeq (ne_of_lt (mono _ _ hlt))
    · exact absurd hxeq.symm (ne_of_lt (mono _ _ hlt))
  have hcard := Fintype.card_le_of_injective i hinj
  simp at hcard

/-- On an interval free of its breakpoint, a single ReLU unit is affine. -/
theorem relu_unit_affine (w b p q : ℝ)
    (hgap : ∀ x ∈ Ioo p q, w ≠ 0 → w * x + b ≠ 0) :
    ∃ u v : ℝ, ∀ x ∈ Ioo p q, relu (w * x + b) = u * x + v := by
  by_cases hw : w = 0
  · exact ⟨0, relu b, fun x _ => by simp [hw, relu]⟩
  · set r := -b / w with hr
    have hroot : w * r + b = 0 := by rw [hr]; field_simp; ring
    have hnot : ¬ (r ∈ Ioo p q) := fun hmem => hgap r hmem hw hroot
    rw [Set.mem_Ioo, not_and_or, not_lt, not_lt] at hnot
    rcases lt_or_gt_of_ne hw with hneg | hpos
    · rcases hnot with hle | hle
      · -- w < 0, r ≤ p : the unit is off
        refine ⟨0, 0, fun y hy => ?_⟩
        have : w * y + b < 0 := by nlinarith [hy.1]
        simp [relu, max_eq_right this.le]
      · -- w < 0, q ≤ r : the unit is on
        refine ⟨w, b, fun y hy => ?_⟩
        have : 0 < w * y + b := by nlinarith [hy.2]
        simp [relu, max_eq_left this.le]
    · rcases hnot with hle | hle
      · -- w > 0, r ≤ p : the unit is on
        refine ⟨w, b, fun y hy => ?_⟩
        have : 0 < w * y + b := by nlinarith [hy.1]
        simp [relu, max_eq_left this.le]
      · -- w > 0, q ≤ r : the unit is off
        refine ⟨0, 0, fun y hy => ?_⟩
        have : w * y + b < 0 := by nlinarith [hy.2]
        simp [relu, max_eq_right this.le]

/-- On a breakpoint-free interval the whole network is exactly affine. -/
theorem reluNet_affine_on_gap (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ p q : ℝ)
    (hgap : ∀ x ∈ Ioo p q, ∀ i, w i ≠ 0 → w i * x + b i ≠ 0) :
    ∃ α β : ℝ, ∀ x ∈ Ioo p q, reluNet k a w b c₀ c₁ x = α * x + β := by
  classical
  have hsum : ∀ s : Finset (Fin k), ∃ u v : ℝ, ∀ x ∈ Ioo p q,
      ∑ i ∈ s, a i * relu (w i * x + b i) = u * x + v := by
    intro s
    induction s using Finset.induction_on with
    | empty => exact ⟨0, 0, by simp⟩
    | insert m s hm ih =>
        obtain ⟨u, v, hv⟩ := ih
        obtain ⟨u', v', hv'⟩ := relu_unit_affine (w m) (b m) p q
          (fun x hx hwm => hgap x hx m hwm)
        refine ⟨a m * u' + u, a m * v' + v, fun x hx => ?_⟩
        rw [Finset.sum_insert hm, hv x hx, hv' x hx]
        ring
  obtain ⟨u, v, hv⟩ := hsum Finset.univ
  exact ⟨c₁ + u, c₀ + v, fun x hx => by rw [reluNet, hv x hx]; ring⟩

/-- **A line cannot follow a parabola.** If an affine function is within `ε` of
`x²` on an interval of length `L`, then `ε ≥ L²/32`. -/
theorem affine_sq_error_lower (α β p q ε : ℝ) (hpq : p < q)
    (h : ∀ x ∈ Ioo p q, |x ^ 2 - (α * x + β)| ≤ ε) : (q - p) ^ 2 / 32 ≤ ε := by
  set L := q - p with hL
  have hL0 : 0 < L := by simp [hL]; linarith
  have h1 := h (p + L / 4) ⟨by linarith, by simp [hL]; linarith⟩
  have h2 := h (p + L / 2) ⟨by linarith, by simp [hL]; linarith⟩
  have h3 := h (p + 3 * L / 4) ⟨by linarith, by simp [hL]; linarith⟩
  rw [abs_le] at h1 h2 h3
  nlinarith [h1.1, h1.2, h2.1, h2.2, h3.1, h3.2]

/-- **The structural core of the ReLU lower bounds.**  Every `k`-unit shallow
ReLU network is *exactly affine* on some subinterval of `[0,1]` of length
`1/(k+1)`. -/
theorem exists_affine_gap (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ : ℝ) :
    ∃ p q α β : ℝ, 0 ≤ p ∧ p < q ∧ q ≤ 1 ∧ q - p = 1 / ((k : ℝ) + 1) ∧
      ∀ x ∈ Ioo p q, reluNet k a w b c₀ c₁ x = α * x + β := by
  obtain ⟨j, hj⟩ := exists_breakpoint_free_interval k w b
  have hk : (0:ℝ) < (k : ℝ) + 1 := by positivity
  set p := (j : ℝ) / ((k : ℝ) + 1) with hp
  set q := ((j : ℝ) + 1) / ((k : ℝ) + 1) with hq
  have hjk : (j : ℝ) + 1 ≤ (k : ℝ) + 1 := by
    have hjle : (j : ℕ) ≤ k := Nat.lt_succ_iff.1 j.isLt
    have : ((j : ℕ) : ℝ) ≤ (k : ℝ) := by exact_mod_cast hjle
    linarith
  have hlen : q - p = 1 / ((k : ℝ) + 1) := by rw [hp, hq]; field_simp; ring
  have hpos : (0:ℝ) < 1 / ((k : ℝ) + 1) := by positivity
  have hpq : p < q := by linarith
  have hp0 : (0:ℝ) ≤ p := by rw [hp]; positivity
  have hq1 : q ≤ 1 := by rw [hq, div_le_one hk]; linarith
  obtain ⟨α, β, hab⟩ := reluNet_affine_on_gap k a w b c₀ c₁ p q
    (fun x hx i hwi => hj x hx i hwi)
  exact ⟨p, q, α, β, hp0, hpq, hq1, hlen, hab⟩

/-- **Main ReLU lower bound.** Every one-hidden-layer ReLU network with `k` units
(plus an affine skip connection, and with arbitrary real parameters) has uniform
error at least `1/(32 (k+1)²)` when approximating `x²` on `[0,1]`. -/
theorem relu_shallow_sq_lower_bound (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ ε : ℝ)
    (h : ∀ x ∈ Icc (0:ℝ) 1, |x ^ 2 - reluNet k a w b c₀ c₁ x| ≤ ε) :
    1 / (32 * ((k : ℝ) + 1) ^ 2) ≤ ε := by
  obtain ⟨p, q, α, β, hp0, hpq, hq1, hlen, hab⟩ := exists_affine_gap k a w b c₀ c₁
  have hsub : Ioo p q ⊆ Icc (0:ℝ) 1 := fun x hx =>
    ⟨by linarith [hx.1], by linarith [hx.2]⟩
  have h' : ∀ x ∈ Ioo p q, |x ^ 2 - (α * x + β)| ≤ ε := by
    intro x hx
    rw [← hab x hx]
    exact h x (hsub hx)
  have key := affine_sq_error_lower α β p q ε hpq h'
  rw [hlen] at key
  calc 1 / (32 * ((k : ℝ) + 1) ^ 2) = (1 / ((k : ℝ) + 1)) ^ 2 / 32 := by field_simp
    _ ≤ ε := key

/-- **Gradient lower bound for shallow ReLU.**  On the interval where the network
is affine with slope `α`, the true slope `2x` of `x²` is missed by at least
`1/(2(k+1))`.  ReLU networks cannot approximate the derivative better than
first order in the width. -/
theorem relu_shallow_slope_lower_bound (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ : ℝ) :
    ∃ p q α β : ℝ, 0 ≤ p ∧ p < q ∧ q ≤ 1 ∧ q - p = 1 / ((k : ℝ) + 1) ∧
      (∀ x ∈ Ioo p q, reluNet k a w b c₀ c₁ x = α * x + β) ∧
      ∃ x ∈ Ioo p q, 1 / (2 * ((k : ℝ) + 1)) ≤ |α - 2 * x| := by
  obtain ⟨p, q, α, β, hp0, hpq, hq1, hlen, hab⟩ := exists_affine_gap k a w b c₀ c₁
  refine ⟨p, q, α, β, hp0, hpq, hq1, hlen, hab, ?_⟩
  set L := q - p with hLdef
  have hL0 : 0 < L := by rw [hLdef]; linarith
  have hx1mem : p + L / 4 ∈ Ioo p q := ⟨by linarith, by rw [hLdef] at *; linarith⟩
  have hx3mem : p + 3 * L / 4 ∈ Ioo p q := ⟨by linarith, by rw [hLdef] at *; linarith⟩
  have htri : L ≤ |α - 2 * (p + L / 4)| + |α - 2 * (p + 3 * L / 4)| := by
    have h2 : |(α - 2 * (p + L / 4)) - (α - 2 * (p + 3 * L / 4))| = L := by
      rw [show (α - 2 * (p + L / 4)) - (α - 2 * (p + 3 * L / 4)) = L by ring]
      exact abs_of_pos hL0
    calc L = |(α - 2 * (p + L / 4)) - (α - 2 * (p + 3 * L / 4))| := h2.symm
      _ ≤ |α - 2 * (p + L / 4)| + |α - 2 * (p + 3 * L / 4)| := abs_sub _ _
  have hLval : L = 1 / ((k : ℝ) + 1) := hlen
  have hhalf : 1 / (2 * ((k : ℝ) + 1)) = L / 2 := by
    rw [hLval]; field_simp
  rcases le_or_gt (L / 2) |α - 2 * (p + L / 4)| with hcase | hcase
  · refine ⟨p + L / 4, hx1mem, ?_⟩
    rw [hhalf]
    exact hcase
  · refine ⟨p + 3 * L / 4, hx3mem, ?_⟩
    rw [hhalf]
    linarith


/-! ## 7. The separation theorem -/

/-- **Depth/width separation between EML and shallow ReLU on `x²`.**

*Left component*: the EML model reaches **any** accuracy `ε` with a *constant*
width `2` (a single hyperparameter `h` is scaled).

*Right component*: a one-hidden-layer ReLU model with `k` units reaching the same
accuracy must satisfy `(k+1)² ≥ 1/(32 ε)`, i.e. its width must grow like
`ε^{-1/2}`.

So on this target the conjectured `O((w·d)^{-2})` rate is achieved by EML at
constant width, while it is exactly the *best possible* behaviour of a shallow
ReLU model — the two models are separated in the width parameter. -/
theorem eml_relu_width_separation (ε : ℝ) (hε : 0 < ε) :
    (∃ h : ℝ, 0 < h ∧ ∀ x ∈ Icc (0:ℝ) 1, |(sqLayer h).eval x - x ^ 2| ≤ ε) ∧
    (∀ (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ : ℝ),
        (∀ x ∈ Icc (0:ℝ) 1, |x ^ 2 - reluNet k a w b c₀ c₁ x| ≤ ε) →
        1 / (32 * ε) ≤ ((k : ℝ) + 1) ^ 2) := by
  refine ⟨eml_width_two_universal ε hε, fun k a w b c₀ c₁ hnet => ?_⟩
  have h1 := relu_shallow_sq_lower_bound k a w b c₀ c₁ ε hnet
  rw [div_le_iff₀ (by positivity : (0:ℝ) < 32 * ((k : ℝ) + 1) ^ 2)] at h1
  rw [div_le_iff₀ (by positivity : (0:ℝ) < 32 * ε)]
  nlinarith

/-- **Quantitative form.**  To match the accuracy `1/(6 n²)` of the width-2 EML
layer with step `h = 1/n`, a shallow ReLU network needs `16 (k+1)² ≥ 3 n²`, i.e.
about `n √3 / 4` units.  EML width stays at `2`. -/
theorem relu_units_needed_to_match_eml (n k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ : ℝ)
    (h : ∀ x ∈ Icc (0:ℝ) 1, |x ^ 2 - reluNet k a w b c₀ c₁ x| ≤ 1 / (6 * (n : ℝ) ^ 2))
    (hn : 1 ≤ n) :
    3 * (n : ℝ) ^ 2 ≤ 16 * ((k : ℝ) + 1) ^ 2 := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  have h1 := relu_shallow_sq_lower_bound k a w b c₀ c₁ _ h
  rw [div_le_div_iff₀ (by positivity) (by positivity)] at h1
  nlinarith [h1]


/-! ## 8. Cycle 3: the EML multiplication gate and multivariate quadratics

The width-2 layer `sqLayer h` squares to second order.  Polarisation
`x y = ((x+y)² − (x−y)²)/4` therefore turns **four** EML neurons into a
*multiplication gate* with the same `O(h²)` accuracy.  Multiplication is the
gateway to several variables: every quadratic form in `n` variables becomes a
single EML layer of width `4 n²`, and — via the diagonal `y = x` — the shallow
ReLU barrier of §7 transfers verbatim to the bivariate target `x y`. -/

/-- The **EML multiplication gate**: the width-`4` layer obtained by evaluating
two copies of the central-difference layer at the pre-activations `x + y` and
`x − y`, and combining them by polarisation. -/
def prodGate (h x y : ℝ) : ℝ :=
  ((sqLayer h).eval (x + y) - (sqLayer h).eval (x - y)) / 4

theorem prodGate_eval (h : ℝ) (hh : h ≠ 0) (x y : ℝ) :
    prodGate h x y =
      (Real.exp (h * (x + y)) + Real.exp (-(h * (x + y)))
        - Real.exp (h * (x - y)) - Real.exp (-(h * (x - y)))) / (4 * h ^ 2) := by
  rw [prodGate, sqLayer_eval h hh, sqLayer_eval h hh]
  field_simp
  ring

/-- **Second-order accuracy of the multiplication gate.**  Four EML neurons
compute `x y` with error `O(h²)`; the constant is the polarisation average of the
two squaring errors. -/
theorem prodGate_error (h x y : ℝ) (hh : h ≠ 0)
    (h₁ : |h * (x + y)| ≤ 1) (h₂ : |h * (x - y)| ≤ 1) :
    |prodGate h x y - x * y| ≤ h ^ 2 * ((x + y) ^ 4 + (x - y) ^ 4) / 24 := by
  have e₁ := sqLayer_error h (x + y) hh h₁
  have e₂ := sqLayer_error h (x - y) hh h₂
  have hid : prodGate h x y - x * y =
      (((sqLayer h).eval (x + y) - (x + y) ^ 2)
        - ((sqLayer h).eval (x - y) - (x - y) ^ 2)) / 4 := by
    rw [prodGate]; ring
  rw [hid, abs_div]
  have habs :
      |((sqLayer h).eval (x + y) - (x + y) ^ 2)
        - ((sqLayer h).eval (x - y) - (x - y) ^ 2)|
      ≤ h ^ 2 * (x + y) ^ 4 / 6 + h ^ 2 * (x - y) ^ 4 / 6 :=
    (abs_sub _ _).trans (add_le_add e₁ e₂)
  have h4 : |(4:ℝ)| = 4 := by norm_num
  rw [h4, div_le_iff₀ (by norm_num : (0:ℝ) < 4)]
  linarith

/-- **The gate on the unit square.**  For `0 < h ≤ 1/2` the width-`4` EML gate
approximates the product on `[0,1]²` with error at most `h²`. -/
theorem prodGate_error_unit (h x y : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2)
    (hx : x ∈ Icc (0:ℝ) 1) (hy : y ∈ Icc (0:ℝ) 1) :
    |prodGate h x y - x * y| ≤ h ^ 2 := by
  obtain ⟨hx0, hx1⟩ := hx
  obtain ⟨hy0, hy1⟩ := hy
  have h₁ : |h * (x + y)| ≤ 1 := by
    rw [abs_le]; constructor <;> nlinarith
  have h₂ : |h * (x - y)| ≤ 1 := by
    rw [abs_le]; constructor <;> nlinarith
  refine (prodGate_error h x y hh0.ne' h₁ h₂).trans ?_
  have hs2 : (x + y) ^ 2 ≤ 4 := by nlinarith
  have hs : (x + y) ^ 4 ≤ 16 := by nlinarith [sq_nonneg (x + y)]
  have hd2 : (x - y) ^ 2 ≤ 1 := by nlinarith
  have hd : (x - y) ^ 4 ≤ 1 := by nlinarith [sq_nonneg (x - y)]
  nlinarith [sq_nonneg h, pow_nonneg (abs_nonneg (x - y)) 4]

/-- **Every quadratic form is one EML layer.**  For an `n × n` coefficient matrix
`A`, replacing each product `x i * x j` by the gate gives an EML network of width
`4 n²` whose error on `[0,1]ⁿ` is `h²‖A‖₁`, uniformly in the dimension `n` up to
the coefficient mass. -/
theorem quadForm_error {n : ℕ} (A : Fin n → Fin n → ℝ) (x : Fin n → ℝ)
    (hx : ∀ i, x i ∈ Icc (0:ℝ) 1) (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    |(∑ i, ∑ j, A i j * prodGate h (x i) (x j))
        - ∑ i, ∑ j, A i j * (x i * x j)|
      ≤ h ^ 2 * ∑ i, ∑ j, |A i j| := by
  have hid : (∑ i, ∑ j, A i j * prodGate h (x i) (x j))
      - ∑ i, ∑ j, A i j * (x i * x j)
      = ∑ i, ∑ j, A i j * (prodGate h (x i) (x j) - x i * x j) := by
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun j _ => by ring
  rw [hid]
  have hstep : ∀ i : Fin n, |∑ j, A i j * (prodGate h (x i) (x j) - x i * x j)|
      ≤ ∑ j, h ^ 2 * |A i j| := by
    intro i
    refine (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun j _ => ?_)
    rw [abs_mul]
    have := prodGate_error_unit h (x i) (x j) hh0 hh (hx i) (hx j)
    calc |A i j| * |prodGate h (x i) (x j) - x i * x j| ≤ |A i j| * h ^ 2 :=
          mul_le_mul_of_nonneg_left this (abs_nonneg _)
      _ = h ^ 2 * |A i j| := by ring
  calc |∑ i, ∑ j, A i j * (prodGate h (x i) (x j) - x i * x j)|
      ≤ ∑ i, |∑ j, A i j * (prodGate h (x i) (x j) - x i * x j)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, ∑ j, h ^ 2 * |A i j| := Finset.sum_le_sum fun i _ => hstep i
    _ = h ^ 2 * ∑ i, ∑ j, |A i j| := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun i _ => (Finset.mul_sum _ _ _).symm

/-- The squaring layer is exact at the origin: `S_h(0) = 0`. -/
theorem sqLayer_eval_zero (h : ℝ) (hh : h ≠ 0) : (sqLayer h).eval 0 = 0 := by
  rw [sqLayer_eval h hh]
  norm_num

/-- **Sharpness of the multiplication gate.**  At the corner `(1,1)` the width-4
gate misses the product by at least `2h²/7`, so its `O(h²)` rate is exact and the
proved constant `1` is off by at most a factor `3.5`. -/
theorem prodGate_error_lower_bound (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    2 * h ^ 2 / 7 ≤ |prodGate h 1 1 - 1 * 1| := by
  have hne : h ≠ 0 := hh0.ne'
  have hid : prodGate h 1 1 - 1 * 1
      = (Real.exp (2 * h) + Real.exp (-(2 * h)) - 2 - (2 * h) ^ 2) / (4 * h ^ 2) := by
    rw [prodGate, show (1:ℝ) - 1 = 0 by ring, sqLayer_eval_zero h hne,
      sqLayer_eval h hne, show h * ((1:ℝ) + 1) = 2 * h by ring]
    field_simp
    ring
  have hlow := cosh_quartic_lower (2 * h) (by linarith) (by linarith)
  have hpos : (0:ℝ) < 4 * h ^ 2 := by positivity
  have hge : 2 * h ^ 2 / 7
      ≤ (Real.exp (2 * h) + Real.exp (-(2 * h)) - 2 - (2 * h) ^ 2) / (4 * h ^ 2) := by
    rw [le_div_iff₀ hpos]
    nlinarith [hlow]
  rw [hid]
  exact le_trans hge (le_abs_self _)

/-- **Two-sided rate for the gate.**  On `[0,1]²` the width-4 EML multiplication
gate has uniform error `Θ(h²)`: at most `h²` everywhere, and at least `2h²/7` at
the corner. -/
theorem prodGate_error_two_sided (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    2 * h ^ 2 / 7 ≤ |prodGate h 1 1 - 1 * 1| ∧
      ∀ x ∈ Icc (0:ℝ) 1, ∀ y ∈ Icc (0:ℝ) 1, |prodGate h x y - x * y| ≤ h ^ 2 :=
  ⟨prodGate_error_lower_bound h hh0 hh,
    fun x hx y hy => prodGate_error_unit h x y hh0 hh hx hy⟩

/-- A one-hidden-layer ReLU network in **two** inputs, with an affine skip
connection and arbitrary real parameters. -/
def reluNet2 (k : ℕ) (a w v b : Fin k → ℝ) (c₀ c₁ c₂ : ℝ) (x y : ℝ) : ℝ :=
  c₀ + c₁ * x + c₂ * y + ∑ i, a i * relu (w i * x + v i * y + b i)

/-- Restricting a bivariate shallow ReLU network to the diagonal produces a
univariate shallow ReLU network with the same number of units. -/
theorem reluNet2_diagonal (k : ℕ) (a w v b : Fin k → ℝ) (c₀ c₁ c₂ x : ℝ) :
    reluNet2 k a w v b c₀ c₁ c₂ x x
      = reluNet k a (fun i => w i + v i) b c₀ (c₁ + c₂) x := by
  simp only [reluNet2, reluNet]
  have : ∀ i : Fin k, w i * x + v i * x + b i = (w i + v i) * x + b i := by
    intro i; ring
  simp only [this]
  ring

/-- **The ReLU barrier transfers to multiplication.**  Every one-hidden-layer
ReLU network with `k` units approximating `x y` on `[0,1]²` has uniform error at
least `1/(32 (k+1)²)`.  The proof is a diagonal restriction: on `y = x` the
target becomes `x²` and the network becomes a univariate `k`-unit network. -/
theorem relu_shallow_prod_lower_bound (k : ℕ) (a w v b : Fin k → ℝ) (c₀ c₁ c₂ ε : ℝ)
    (hbound : ∀ x ∈ Icc (0:ℝ) 1, ∀ y ∈ Icc (0:ℝ) 1,
      |x * y - reluNet2 k a w v b c₀ c₁ c₂ x y| ≤ ε) :
    1 / (32 * ((k : ℝ) + 1) ^ 2) ≤ ε := by
  refine relu_shallow_sq_lower_bound k a (fun i => w i + v i) b c₀ (c₁ + c₂) ε ?_
  intro x hx
  have := hbound x hx x hx
  rwa [reluNet2_diagonal, show x * x = x ^ 2 by ring] at this

/-- **Product separation.**  Width `4` EML reaches any accuracy `ε` on the
product `x y`, while every shallow ReLU network of width `k` that does the same
must satisfy `k + 1 ≥ (32 ε)^{-1/2}`: the EML width is dimension- and
accuracy-independent, the ReLU width is not. -/
theorem eml_relu_product_separation (ε : ℝ) (hε : 0 < ε) :
    (∃ h : ℝ, 0 < h ∧ ∀ x ∈ Icc (0:ℝ) 1, ∀ y ∈ Icc (0:ℝ) 1,
        |prodGate h x y - x * y| ≤ ε) ∧
      ∀ (k : ℕ) (a w v b : Fin k → ℝ) (c₀ c₁ c₂ : ℝ),
        (∀ x ∈ Icc (0:ℝ) 1, ∀ y ∈ Icc (0:ℝ) 1,
          |x * y - reluNet2 k a w v b c₀ c₁ c₂ x y| ≤ ε) →
        1 / (32 * ε) ≤ ((k : ℝ) + 1) ^ 2 := by
  constructor
  · refine ⟨min (1 / 2) ε, lt_min (by norm_num) hε, fun x hx y hy => ?_⟩
    set h := min (1 / 2 : ℝ) ε with hdef
    have hh0 : 0 < h := lt_min (by norm_num) hε
    have hh : h ≤ 1 / 2 := min_le_left _ _
    have hhε : h ≤ ε := min_le_right _ _
    refine (prodGate_error_unit h x y hh0 hh hx hy).trans ?_
    nlinarith
  · intro k a w v b c₀ c₁ c₂ hb
    have hkey := relu_shallow_prod_lower_bound k a w v b c₀ c₁ c₂ ε hb
    have hk : (0:ℝ) < 32 * ((k : ℝ) + 1) ^ 2 := by positivity
    rw [div_le_iff₀ (by positivity : (0:ℝ) < 32 * ε)]
    rw [div_le_iff₀ hk] at hkey
    nlinarith

/-
-- !-- Lab Notes -- !--

## Hypotheses (Hypothesizer)

H1  (bold) The mission's `O((w·d)^{-2/n})` rate is *not tight* for EML: because
    the activation is entire, a **fixed** width suffices for `x²` and the
    accuracy is bought with weight magnitude, not with width.
H2  The catalog's forward-difference EML network is exactly first order, so the
    published `Θ(1/n)` rate is optimal *for that construction* and the central
    difference strictly beats it.
H3  (bold) Shallow ReLU has a hard `Ω(k^{-2})` barrier on `x²`, so H1 yields a
    genuine model separation, not just a better constant.
H4  (bold) Depth 2 is exactly the depth at which EML contains ReLU: `exp` in the
    first layer and `log` in the second compose into softplus.
H5  Depth composes: `S_h ∘ S_h` still has a second-order rate (target `x⁴`).

## Experiments (Experimenter)

Float sampling of `[0,1]` on a 1001-point grid (details in
`ComputationalEvidence.md`):

  h        max|S_h − x²|   /h²        max|F_h − x²|   /h
  0.5      2.1008e-2       0.084031   1.89770e-1      0.379540
  0.25     5.219e-3        0.083507   8.8813e-2       0.355253
  0.125    1.303e-3        0.083377   4.3002e-2       0.344016
  0.0625   3.26e-4         0.083344   2.1163e-2       0.338607

  h        max|S_h(S_h)−x⁴| /h²       max|S_h′ − 2x|  /h²
  0.5      6.5294e-2        0.261177  8.4381e-2       0.337525
  0.25     1.5795e-2        0.252716  2.0899e-2       0.334377
  0.125    3.917e-3         0.250674  5.212e-3        0.333594

The observed constants `1/12`, `1/3`, `1/4`, `1/3` are all strictly inside the
proved constants `1/6`, `1/3` (matched exactly!), `1`, `1/2`.  H1, H2, H5 pass.

## Analysis (Analyst)

* The `1/12` versus the proved `1/6` gap is *route-dependent*: `Real.exp_bound`
  at `n = 5` costs a factor `1 + 12/50` on the remainder, and we rounded up to a
  provable constant.  "True but the sharp constant needs a different route."
* The forward network's `1/3` is matched *exactly* by
  `forward_layer_error_lower_bound` (from `Real.sum_le_exp_of_nonneg` at `n = 4`),
  so H2 is settled with a sharp constant.
* The ReLU barrier is structural, not analytic: a `k`-unit network is affine on
  one of the `k+1` equal subintervals (pigeonhole on breakpoints), and second
  differences of `x²` cannot be reproduced by an affine map.  The proved
  constant `1/32` versus the optimal `1/8` is the price of evaluating at
  interior quarter points instead of the endpoints of the empty interval.
* H4 turned out to be *more* than a curiosity: since `exp` then `log` gives
  softplus, EML at depth 2 dominates shallow ReLU at equal width, which is what
  transfers the whole Lipschitz theory (`lipschitz_relu_rate`) into EML.

## Critique (Critic)

* No statement is vacuous: every error bound is quantified over an interval with
  non-empty interior, and both lower bounds produce explicit witnesses.
* Hidden assumptions made explicit: `h ≠ 0` (division by `h²`), `|h x| ≤ 1`
  (hypothesis of `Real.exp_bound`), `h ≤ 1/2` in the depth-2 statement (needed so
  that the *output* of the first layer still satisfies `|h y| ≤ 1`).
* The `ReLU` lower bound allows an affine skip connection and arbitrary real
  parameters, so it cannot be dodged by reparametrisation; `w i = 0` units are
  handled separately (they contribute a constant, not a breakpoint).
* Boundary case `k = 0` is included: the pigeonhole argument degenerates to
  "the network is affine on all of `[0,1]`", and the bound reads `ε ≥ 1/32`.
* Caveat on the separation: EML buys accuracy with the read-out weight `1/h²`.
  Under a *bounded-weight* constraint the separation would have to be re-proved;
  this is recorded as Conjecture C1 in `FUTURE_DIRECTIONS.md`.

## Cycle 3 — the multiplication gate (Hypothesize → Experiment → Critique)

H6  (bold) Polarisation makes EML a *multiplicative* model: four neurons compute
    `x y` to second order, so a single EML layer of width `4 n²` realises every
    quadratic form in `n` variables, and the ReLU barrier survives the passage
    to two inputs.

Float sampling of `[0,1]²` on a 51 x 51 grid, gate
`P_h(x,y) = (S_h(x+y) − S_h(x−y))/4`:

  h        max|P_h − x y|   /h²
  0.5      8.6161e-2        0.344645
  0.25     2.1008e-2        0.336124
  0.125    5.219e-3         0.334029
  0.0625   1.303e-3         0.333507

The empirical constant is `1/3`; the proved constant is `17/24 ≈ 0.708`
(`prodGate_error` at `(x,y) = (1,1)`), rounded up to `1` in
`prodGate_error_unit`.  The `2 x` factor between `1/3` and the *worst-case*
polarisation bound is the usual slack of adding `|(x+y)⁴|` and `|(x−y)⁴|`
separately instead of exploiting their opposite signs.  H6 passes.

Cycle 4 closes the rate from below: `prodGate_error_lower_bound` gives
`|P_h(1,1) − 1| ≥ 2h²/7 ≈ 0.2857 h²`, so the true constant `1/3` is now
*bracketed* by proved bounds `2/7 ≤ c ≤ 17/24`, and the gate's rate is `Θ(h²)`
in the strict two-sided sense (`prodGate_error_two_sided`).  Note that the lower
bound needs `h ≤ 1/2`, exactly the hypothesis under which the pre-activation
`h(x+y)` stays in `[−1,1]` — the same constraint as in the upper bound, so the
two-sided statement has no gap in its range of validity.

Critique: the diagonal restriction used in `relu_shallow_prod_lower_bound` is
lossless — a bivariate ReLU unit `relu(w x + v y + b)` restricted to `y = x` is
again a single ReLU unit with weight `w + v` — so the transferred lower bound
`1/(32(k+1)²)` costs nothing and cannot be evaded by choosing `v` adversarially.
The bound is dimension-blind, which is the point: EML's width stays `4` while
ReLU's must grow like `ε^{-1/2}` already in two inputs.

## Synthesis (PI)

For `x²` on `[0,1]`: EML needs width 2 and no depth; shallow ReLU needs
`Ω(ε^{-1/2})` units; the two facts combine into `eml_relu_width_separation`.
For the Lipschitz class, EML at depth 2 matches ReLU's `O(1/N)` exactly, because
depth 2 already contains ReLU up to `log 2 / M`.  The conjectured `O((w d)^{-2})`
rate is therefore correct as an upper bound for smooth targets, but it is *not*
the truth: for analytic targets the correct statement is "constant width,
accuracy governed by weight magnitude".  Cycle 3 upgrades this from a single
target to a *class*: polarisation turns the squaring layer into a multiplication
gate (`prodGate_error_unit`), quadratic forms in `n` variables cost width `4 n²`
with a dimension-free `h²` constant (`quadForm_error`), and the shallow-ReLU
barrier transfers to the bivariate product by diagonal restriction
(`relu_shallow_prod_lower_bound`, `eml_relu_product_separation`).
-/

end

end EML.DepthWidth