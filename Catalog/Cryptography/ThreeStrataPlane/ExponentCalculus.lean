import Cryptography.FactoringBarriers.AsymptoticLadder

/-!
# The measured-exponent calculus

A *measured exponent* of a cost profile `f`, expressed in the bit-size variable
`x = log N`, is the limit

  `α(f) = lim_{x → ∞} log (f x) / x`.

This is exactly the quantity that an empirical log–log fit estimates, and it is
the coordinate on which the three strata of the factoring plane are compared.
This file develops the calculus of that exponent:

* `HasExponent.unique` — the exponent is well defined;
* `hasExponent_of_log_sub_bounded` — an additive `O(1)` correction to `log f`
  does not move the exponent (so `exp(ax + c)` has exponent `a`);
* `hasExponent_exp_linear`, `hasExponent_rpow` — the two calibration points:
  `exp (a x)` has exponent `a`, and every polynomial has exponent `0`;
* `HasExponent.comp_div` — **the units lemma**.  If a cost is fitted in the
  variable `b = log p` (prime bit-size) with slope `s`, then on `x = log N = c·b`
  its exponent is `s / c`.  Reading the per-prime-bit slope as an exponent on `N`
  is precisely the units error this lemma quantifies;
* `HasExponent.tendsto_atTop`, `HasExponent.not_polyBounded` — a positive
  exponent forces superpolynomial growth;
* `exponent_gap_ratio`, `exponent_gap_price` — **the price theorem**: two
  profiles with different exponents are separated by a ratio which itself has
  the difference as its exponent, and therefore diverges.

All statements are unconditional theorems about limits; the empirical numbers
they are used to interpret live in `ComputationalEvidence.md`.
-/

namespace ThreeStrata

open Filter Real FactoringBarriers
open scoped Topology

/-- `f` has *measured exponent* `a` on `N`: `log (f x) / x → a`, where
`x = log N`. -/
def HasExponent (f : ℝ → ℝ) (a : ℝ) : Prop :=
  Tendsto (fun x => Real.log (f x) / x) atTop (𝓝 a)

/-- The measured exponent is unique. -/
theorem HasExponent.unique {f : ℝ → ℝ} {a b : ℝ} (ha : HasExponent f a)
    (hb : HasExponent f b) : a = b :=
  tendsto_nhds_unique ha hb

/-- An `O(1)` additive correction to `log f` does not change the exponent. -/
theorem hasExponent_of_log_sub_bounded {f : ℝ → ℝ} {a C : ℝ}
    (h : ∀ᶠ x in atTop, |Real.log (f x) - a * x| ≤ C) : HasExponent f a := by
  have hC : Tendsto (fun x : ℝ => C / x) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop tendsto_id
  have hkey : Tendsto (fun x => (Real.log (f x) - a * x) / x) atTop (𝓝 0) := by
    refine squeeze_zero_norm' ?_ hC
    filter_upwards [h, eventually_gt_atTop (0 : ℝ)] with x hx hx0
    rw [Real.norm_eq_abs, abs_div, abs_of_pos hx0]
    gcongr
  have := hkey.const_add a
  rw [add_zero] at this
  refine this.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx0
  field_simp
  ring

/-- Calibration point 1: `exp (a x)` has exponent `a`. -/
theorem hasExponent_exp_linear (a : ℝ) : HasExponent (fun x => Real.exp (a * x)) a := by
  refine hasExponent_of_log_sub_bounded (C := 0) ?_
  filter_upwards with x
  simp [Real.log_exp]

/-- `exp (a x + c)` also has exponent `a`: additive constants in the exponent are
invisible to the measurement. -/
theorem hasExponent_exp_affine (a c : ℝ) :
    HasExponent (fun x => Real.exp (a * x + c)) a := by
  refine hasExponent_of_log_sub_bounded (C := |c|) ?_
  filter_upwards with x
  simp [Real.log_exp]

/-- Calibration point 2: a polynomial profile `C x^d` has exponent `0`.
This is the quantum stratum's coordinate. -/
theorem hasExponent_rpow {C d : ℝ} (hC : 0 < C) :
    HasExponent (fun x => C * x ^ d) 0 := by
  have hlog : Tendsto (fun x : ℝ => Real.log x / x) atTop (𝓝 0) := by
    simpa using Real.isLittleO_log_id_atTop.tendsto_div_nhds_zero
  have hCx : Tendsto (fun x : ℝ => Real.log C / x) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop tendsto_id
  have hsum : Tendsto (fun x : ℝ => Real.log C / x + d * (Real.log x / x)) atTop (𝓝 0) := by
    have := hCx.add (hlog.const_mul d)
    simpa using this
  refine hsum.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx0
  rw [Real.log_mul hC.ne' (by positivity), Real.log_rpow hx0]
  ring

/-- **The units lemma.**  If a profile is fitted in a variable `b` and then
re-expressed in `x = c · b`, its exponent is divided by `c`.  With `c = 2`
(`log N = 2 log p` for a balanced semiprime) a per-prime-bit slope `s` becomes
an exponent `s / 2` on `N`. -/
theorem HasExponent.comp_div {f : ℝ → ℝ} {s c : ℝ} (hf : HasExponent f s) (hc : 0 < c) :
    HasExponent (fun x => f (x / c)) (s / c) := by
  have hdiv : Tendsto (fun x : ℝ => x / c) atTop atTop :=
    Filter.Tendsto.atTop_div_const hc tendsto_id
  have h1 : Tendsto (fun x : ℝ => Real.log (f (x / c)) / (x / c)) atTop (𝓝 s) := hf.comp hdiv
  have h2 := h1.div_const c
  refine h2.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx0
  field_simp

/-! ## A positive exponent forces superpolynomial growth -/

/-- A profile with positive exponent eventually dominates `exp ((a/2) x)`. -/
theorem HasExponent.eventually_exp_le {f : ℝ → ℝ} {a : ℝ} (hf : HasExponent f a)
    (ha : 0 < a) (hpos : ∀ᶠ x in atTop, 0 < f x) :
    ∀ᶠ x in atTop, Real.exp (a / 2 * x) ≤ f x := by
  have hgt : ∀ᶠ x in atTop, a / 2 < Real.log (f x) / x :=
    hf.eventually (eventually_gt_nhds (by linarith))
  filter_upwards [hgt, hpos, eventually_gt_atTop (0 : ℝ)] with x hx hfx hx0
  have hlog : a / 2 * x ≤ Real.log (f x) := by
    rw [div_lt_div_iff₀ (by norm_num) hx0] at hx
    nlinarith
  calc Real.exp (a / 2 * x) ≤ Real.exp (Real.log (f x)) := Real.exp_le_exp.2 hlog
    _ = f x := Real.exp_log hfx

/-- A profile with positive exponent is superpolynomial. -/
theorem HasExponent.superpoly {f : ℝ → ℝ} {a : ℝ} (hf : HasExponent f a) (ha : 0 < a)
    (hpos : ∀ᶠ x in atTop, 0 < f x) : Superpoly f :=
  (Superpoly_exp_linear (by linarith : (0:ℝ) < a / 2)).of_eventually_le
    (hf.eventually_exp_le ha hpos)

/-- A profile with positive exponent diverges. -/
theorem HasExponent.tendsto_atTop {f : ℝ → ℝ} {a : ℝ} (hf : HasExponent f a) (ha : 0 < a)
    (hpos : ∀ᶠ x in atTop, 0 < f x) : Tendsto f atTop atTop := by
  refine tendsto_atTop_mono' atTop (hf.eventually_exp_le ha hpos) ?_
  exact Real.tendsto_exp_atTop.comp (tendsto_id.const_mul_atTop (by linarith : (0:ℝ) < a / 2))

/-- A profile with positive exponent is not polynomially bounded: the quantum
stratum (exponent `0`) cannot be reached by anything with a positive exponent. -/
theorem HasExponent.not_polyBounded {f : ℝ → ℝ} {a : ℝ} (hf : HasExponent f a) (ha : 0 < a)
    (hpos : ∀ᶠ x in atTop, 0 < f x) : ¬ PolyBounded f :=
  not_polyBounded_of_superpoly (hf.superpoly ha hpos)

/-! ## The price theorem -/

/-- The ratio of two positive profiles has the difference of their exponents. -/
theorem exponent_gap_ratio {f g : ℝ → ℝ} {a b : ℝ} (hf : HasExponent f a)
    (hg : HasExponent g b) (hfpos : ∀ᶠ x in atTop, 0 < f x)
    (hgpos : ∀ᶠ x in atTop, 0 < g x) : HasExponent (fun x => g x / f x) (b - a) := by
  have h := hg.sub hf
  refine h.congr' ?_
  filter_upwards [hfpos, hgpos] with x hfx hgx
  rw [Real.log_div hgx.ne' hfx.ne']
  ring

/-- **The price theorem.**  If profile `g` has a strictly larger measured
exponent than profile `f`, then the cost ratio `g / f` diverges: the penalty for
using `g` instead of `f` is not a constant factor but an unbounded one, and its
own exponent is exactly the gap `b - a`. -/
theorem exponent_gap_price {f g : ℝ → ℝ} {a b : ℝ} (hf : HasExponent f a)
    (hg : HasExponent g b) (hab : a < b) (hfpos : ∀ᶠ x in atTop, 0 < f x)
    (hgpos : ∀ᶠ x in atTop, 0 < g x) :
    HasExponent (fun x => g x / f x) (b - a) ∧
      Tendsto (fun x => g x / f x) atTop atTop := by
  have hratio := exponent_gap_ratio hf hg hfpos hgpos
  refine ⟨hratio, hratio.tendsto_atTop (by linarith) ?_⟩
  filter_upwards [hfpos, hgpos] with x hfx hgx
  positivity

end ThreeStrata