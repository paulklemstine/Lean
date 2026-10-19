import Mathlib

/-!
# NFS closure, channel 1: constant factors are invisible to the `L[α, c]` ladder

Round 44's single "positive" NFS-measure result was ruled out (`refuteB`) because it is a
**constant-factor** effect, not an `L[1/3]` effect.  This file makes that verdict a theorem.

We work with the subexponential complexity function of the catalog,
`Lfun α c x = exp (c · x^α · (log x)^(1-α))` in the bit-size variable `x = log N`
(this is verbatim `FactoringBarriers.Lfun` from
`Catalog/Cryptography/FactoringBarriers/AsymptoticLadder.lean`; it is restated here only
so that this file is self-contained under the `Physics` library).

## The `L`-exponent

A cost function `f` *has `L`-exponent `(α, c)`* when
`log (f x) / (x^α (log x)^(1-α)) → c`.  This is the invariant the NFS literature reports
(`c = (64/9)^{1/3}` for the general NFS at `α = 1/3`).

## Main results

* `LExponent.Lfun`            : `Lfun α c` has `L`-exponent `(α, c)`;
* `LExponent.unique`          : the `L`-exponent constant is unique;
* `LExponent.const_mul`       : multiplying by any constant `K > 0` leaves it unchanged —
  **a constant-factor effect is invisible to the `L`-ladder** (the refuters' category);
* `LExponent.mul_of_bounded`  : more generally any factor bounded above and below by positive
  constants is invisible;
* `Lfun_ratio_superpoly`      : a *genuine* constant improvement `c' < c` produces a ratio
  `Lfun α c / Lfun α c'` which is superpolynomial;
* `const_factor_cannot_emulate_L_gain` : therefore no constant factor `K` can ever reproduce an
  `L`-constant improvement — the two categories are strictly separated.
-/

namespace Physics.NFSClosure

open Filter Real
open scoped Topology

/-- The catalog's subexponential complexity function `L_N[α, c]`, in `x = log N`. -/
noncomputable def Lfun (α c x : ℝ) : ℝ :=
  Real.exp (c * x ^ α * (Real.log x) ^ (1 - α))

/-- The `L`-scale `x^α (log x)^(1-α)`: the quantity whose coefficient is the `L`-constant. -/
noncomputable def Lscale (α x : ℝ) : ℝ := x ^ α * (Real.log x) ^ (1 - α)

/-- `f` has `L`-exponent `(α, c)`. -/
def LExponent (f : ℝ → ℝ) (α c : ℝ) : Prop :=
  Tendsto (fun x => Real.log (f x) / Lscale α x) atTop (𝓝 c)

/-- For `0 < α ≤ 1` the `L`-scale tends to infinity. -/
theorem Lscale_tendsto_atTop {α : ℝ} (hα : 0 < α) (hα1 : α ≤ 1) :
    Tendsto (Lscale α) atTop atTop := by
  refine tendsto_atTop_mono' atTop ?_ (tendsto_rpow_atTop hα)
  filter_upwards [eventually_ge_atTop (Real.exp 1)] with x hx
  have hx0 : (0:ℝ) < x := lt_of_lt_of_le (Real.exp_pos 1) hx
  have hlog : (1:ℝ) ≤ Real.log x := by
    have := Real.log_le_log (Real.exp_pos 1) hx
    simpa using this
  have hpow : (1:ℝ) ≤ (Real.log x) ^ (1 - α) := Real.one_le_rpow hlog (by linarith)
  have hxa : (0:ℝ) ≤ x ^ α := (Real.rpow_pos_of_pos hx0 α).le
  unfold Lscale
  nlinarith

theorem log_Lfun (α c x : ℝ) : Real.log (Lfun α c x) = c * Lscale α x := by
  unfold Lfun Lscale
  rw [Real.log_exp]
  ring

/-- `Lfun α c` has `L`-exponent exactly `(α, c)`. -/
theorem LExponent.Lfun {α c : ℝ} (hα : 0 < α) (hα1 : α ≤ 1) :
    LExponent (Lfun α c) α c := by
  unfold LExponent
  refine tendsto_const_nhds.congr' ?_
  filter_upwards [(Lscale_tendsto_atTop hα hα1).eventually_gt_atTop 0] with x hx
  rw [log_Lfun, mul_div_assoc, div_self hx.ne', mul_one]

/-- The `L`-constant is uniquely determined by the cost function. -/
theorem LExponent.unique {f : ℝ → ℝ} {α c c' : ℝ} (h : LExponent f α c)
    (h' : LExponent f α c') : c = c' :=
  tendsto_nhds_unique h h'

/-- **Constant factors are invisible.**  If `f` has `L`-exponent `(α, c)` and `K > 0`, then
`K • f` has the *same* `L`-exponent, provided `f` is eventually positive. -/
theorem LExponent.const_mul {f : ℝ → ℝ} {α c K : ℝ} (hα : 0 < α) (hα1 : α ≤ 1)
    (hK : 0 < K) (hpos : ∀ᶠ x in atTop, 0 < f x) (h : LExponent f α c) :
    LExponent (fun x => K * f x) α c := by
  unfold LExponent at *
  have hS := Lscale_tendsto_atTop hα hα1
  have hsmall : Tendsto (fun x => Real.log K / Lscale α x) atTop (𝓝 0) :=
    hS.const_div_atTop _
  have hsum := hsmall.add h
  rw [zero_add] at hsum
  refine hsum.congr' ?_
  filter_upwards [hpos, hS.eventually_gt_atTop 0] with x hx hSx
  rw [Real.log_mul hK.ne' hx.ne', add_div]

/-- **Bounded factors are invisible.**  Any multiplicative perturbation `g` with
`a ≤ g x ≤ b` for positive constants `a, b` leaves the `L`-exponent unchanged.  This covers
measured "speedups" with error bars, e.g. a ratio `0.9932 ± 0.0122`. -/
theorem LExponent.mul_of_bounded {f g : ℝ → ℝ} {α c a b : ℝ} (hα : 0 < α) (hα1 : α ≤ 1)
    (ha : 0 < a) (hpos : ∀ᶠ x in atTop, 0 < f x)
    (hg : ∀ᶠ x in atTop, a ≤ g x ∧ g x ≤ b) (h : LExponent f α c) :
    LExponent (fun x => g x * f x) α c := by
  unfold LExponent at *
  have hS := Lscale_tendsto_atTop hα hα1
  have hlo : Tendsto (fun x => Real.log a / Lscale α x) atTop (𝓝 0) := hS.const_div_atTop _
  have hhi : Tendsto (fun x => Real.log b / Lscale α x) atTop (𝓝 0) := hS.const_div_atTop _
  have hmid : Tendsto (fun x => Real.log (g x) / Lscale α x) atTop (𝓝 0) := by
    refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlo hhi ?_ ?_
    · filter_upwards [hg, hS.eventually_gt_atTop 0] with x hx hSx
      exact div_le_div_of_nonneg_right (Real.log_le_log ha hx.1) hSx.le
    · filter_upwards [hg, hS.eventually_gt_atTop 0] with x hx hSx
      exact div_le_div_of_nonneg_right (Real.log_le_log (lt_of_lt_of_le ha hx.1) hx.2) hSx.le
  have hsum := hmid.add h
  rw [zero_add] at hsum
  refine hsum.congr' ?_
  filter_upwards [hpos, hg, hS.eventually_gt_atTop 0] with x hx hgx hSx
  rw [Real.log_mul (lt_of_lt_of_le ha hgx.1).ne' hx.ne', add_div]

/-- The ratio of two `L`-functions with the same `α` is again an `L`-function. -/
theorem Lfun_div_Lfun (α c c' x : ℝ) : Lfun α c x / Lfun α c' x = Lfun α (c - c') x := by
  unfold Lfun
  rw [← Real.exp_sub]
  ring_nf

/-- **A genuine `L`-gain is superpolynomial.**  If `c' < c` and `0 < α ≤ 1`, the ratio
`Lfun α c / Lfun α c'` eventually exceeds every power `x ^ d` of the bit-size. -/
theorem Lfun_ratio_superpoly {α c c' : ℝ} (hα : 0 < α) (hα1 : α ≤ 1) (hcc : c' < c)
    (d : ℝ) : Tendsto (fun x => (Lfun α c x / Lfun α c' x) / x ^ d) atTop atTop := by
  have hδ : 0 < c - c' := by linarith
  have hcomp : Tendsto (fun x : ℝ => Real.exp ((c - c') * x) / x ^ (d / α)) atTop atTop :=
    tendsto_exp_mul_div_rpow_atTop (d / α) (c - c') hδ
  have hrp : Tendsto (fun x : ℝ => x ^ α) atTop atTop := tendsto_rpow_atTop hα
  refine tendsto_atTop_mono' atTop ?_ (hcomp.comp hrp)
  filter_upwards [eventually_ge_atTop (Real.exp 1)] with x hx
  have hx0 : (0:ℝ) < x := lt_of_lt_of_le (Real.exp_pos 1) hx
  have hlog : (1:ℝ) ≤ Real.log x := by
    have := Real.log_le_log (Real.exp_pos 1) hx
    simpa using this
  have hpow : (1:ℝ) ≤ (Real.log x) ^ (1 - α) := Real.one_le_rpow hlog (by linarith)
  have hxa : (0:ℝ) ≤ x ^ α := (Real.rpow_pos_of_pos hx0 α).le
  have hxd : (x ^ α) ^ (d / α) = x ^ d := by
    rw [← Real.rpow_mul hx0.le, mul_div_cancel₀ d hα.ne']
  simp only [Function.comp, hxd, Lfun_div_Lfun]
  have hpd : (0:ℝ) < x ^ d := Real.rpow_pos_of_pos hx0 d
  gcongr
  unfold Lfun
  apply Real.exp_le_exp.mpr
  nlinarith [mul_nonneg hδ.le hxa]

/-- **Separation of categories.**  For `c' < c` no constant factor `K` turns the cheaper
cost `Lfun α c'` into something that dominates `Lfun α c`: a constant-factor effect can never
emulate (or be mistaken for) an `L`-constant improvement. -/
theorem const_factor_cannot_emulate_L_gain {α c c' : ℝ} (hα : 0 < α) (hα1 : α ≤ 1)
    (hcc : c' < c) (K : ℝ) :
    ¬ ∀ᶠ x in atTop, Lfun α c x ≤ K * Lfun α c' x := by
  intro hK
  have h0 := Lfun_ratio_superpoly hα hα1 hcc 0
  have hbig := h0.eventually_gt_atTop K
  obtain ⟨x, h1, h2⟩ := (hK.and hbig).exists
  have hL : 0 < Lfun α c' x := Real.exp_pos _
  rw [Real.rpow_zero, div_one, lt_div_iff₀ hL] at h2
  linarith

/-- **Refuter B, as a theorem.**  Suppose an "improved" NFS cost is `K * Lfun α c` for a
constant `K > 0` (a constant-factor effect).  Then its `L`-exponent is still exactly `c`; in
particular it is *not* the `L`-exponent of any genuinely improved constant `c' ≠ c`. -/
theorem constant_factor_effect_has_no_L_gain {α c c' K : ℝ} (hα : 0 < α) (hα1 : α ≤ 1)
    (hK : 0 < K) (hcc : c' ≠ c) :
    LExponent (fun x => K * Lfun α c x) α c ∧
      ¬ LExponent (fun x => K * Lfun α c x) α c' := by
  have h := (LExponent.Lfun (c := c) hα hα1).const_mul hα hα1 hK
    (Eventually.of_forall fun x => Real.exp_pos _)
  exact ⟨h, fun h' => hcc (h.unique h').symm⟩

end Physics.NFSClosure