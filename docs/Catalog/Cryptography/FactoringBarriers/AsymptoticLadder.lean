import Mathlib

/-!
# The Asymptotic Ladder for Classical Factoring Barriers

This file develops the *quantitative* backbone of the conditional-impossibility
framework for classical integer factoring.  Every known classical factoring
resource comes with a running-time barrier, and each barrier is expressed in
terms of the bit-size parameter `x = log N`.

The three shapes that occur are

* `x ↦ exp (b * x)` (exponential; e.g. `N^{1/4}` for Pollard rho, `b = 1/4`);
* `Lfun α c x = exp (c * x^α * (log x)^(1-α))` (subexponential `L_N[α, c]`;
  e.g. `L_N[1/3,c]` for the number field sieve, `L_p[1/2,√2]` for ECM);
* `x ↦ C * x^d` (polynomial — the target of a hypothetical fast algorithm).

Main results:

* `Superpoly_exp_rpow`  : `exp (c * x^α)` is superpolynomial for `c, α > 0`;
* `Lfun_superpoly`      : `L[α,c]` is superpolynomial for `0 < α ≤ 1`, `c > 0`;
* `Lfun_subexp`         : `L[α,c]` is *sub*exponential for `0 < α < 1`;
* `not_polyBounded_of_superpoly` : a superpolynomial lower bound rules out
  polynomially bounded running time.

Together these say that the `L`-functions occupy a genuine intermediate rung of
the ladder: strictly above every polynomial and strictly below every exponential.
-/

namespace FactoringBarriers

open Filter Real
open scoped Topology

/-! ## Growth classes -/

/-- `f` is *superpolynomial*: for every real exponent `d`, `f x / x ^ d → ∞`. -/
def Superpoly (f : ℝ → ℝ) : Prop :=
  ∀ d : ℝ, Tendsto (fun x => f x / x ^ d) atTop atTop

/-- `f` is *subexponential*: for every `ε > 0`, `f x / exp (ε * x) → 0`. -/
def Subexp (f : ℝ → ℝ) : Prop :=
  ∀ ε : ℝ, 0 < ε → Tendsto (fun x => f x / Real.exp (ε * x)) atTop (𝓝 0)

/-- `f` is *polynomially bounded*: `f x ≤ C * x ^ d` for all large `x`. -/
def PolyBounded (f : ℝ → ℝ) : Prop :=
  ∃ C d : ℝ, ∀ᶠ x in atTop, f x ≤ C * x ^ d

/-- The subexponential complexity function `L_N[α, c] = exp (c (log N)^α (log log N)^{1-α})`,
written in the bit-size variable `x = log N`. -/
noncomputable def Lfun (α c x : ℝ) : ℝ :=
  Real.exp (c * x ^ α * (Real.log x) ^ (1 - α))

/-! ## Superpolynomiality is inherited by domination -/

/-- Eventual domination transfers superpolynomiality upward. -/
theorem Superpoly.of_eventually_le {f g : ℝ → ℝ} (hg : Superpoly g)
    (h : ∀ᶠ x in atTop, g x ≤ f x) : Superpoly f := by
  intro d
  refine tendsto_atTop_mono' atTop ?_ (hg d)
  filter_upwards [h, eventually_gt_atTop (0 : ℝ)] with x hx hx0
  have hpos : (0:ℝ) < x ^ d := Real.rpow_pos_of_pos hx0 d
  gcongr

/-! ## The basic exponential rung -/

/-- `exp (c * x ^ α)` is superpolynomial for every `c > 0` and `α > 0`.
This is the engine behind every barrier bound in the framework. -/
theorem Superpoly_exp_rpow {c α : ℝ} (hc : 0 < c) (hα : 0 < α) :
    Superpoly (fun x => Real.exp (c * x ^ α)) := by
  intro d
  have hcomp :
      Tendsto (fun x : ℝ => Real.exp (c * x) / x ^ (d / α)) atTop atTop :=
    tendsto_exp_mul_div_rpow_atTop (d / α) c hc
  have hrp : Tendsto (fun x : ℝ => x ^ α) atTop atTop := tendsto_rpow_atTop hα
  refine (hcomp.comp hrp).congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
  have hxd : (x ^ α) ^ (d / α) = x ^ d := by
    rw [← Real.rpow_mul hx.le, mul_div_cancel₀ d hα.ne']
  simp [hxd]

/-- Pure exponentials `exp (b * x)` with `b > 0` are superpolynomial. -/
theorem Superpoly_exp_linear {b : ℝ} (hb : 0 < b) :
    Superpoly (fun x => Real.exp (b * x)) := by
  have h := Superpoly_exp_rpow hb (by norm_num : (0:ℝ) < 1)
  refine h.of_eventually_le ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
  simp [Real.rpow_one]

/-! ## The `L`-functions are superpolynomial -/

/-- For `x ≥ e` and `α ≤ 1` we have `L[α,c] x ≥ exp (c x^α)`. -/
theorem exp_rpow_le_Lfun {α c x : ℝ} (hc : 0 ≤ c) (hα : α ≤ 1) (hx : Real.exp 1 ≤ x) :
    Real.exp (c * x ^ α) ≤ Lfun α c x := by
  have hx0 : (0:ℝ) < x := lt_of_lt_of_le (Real.exp_pos 1) hx
  have hlog : (1:ℝ) ≤ Real.log x := by
    have := Real.log_le_log (Real.exp_pos 1) hx
    simpa using this
  have hpow : (1:ℝ) ≤ (Real.log x) ^ (1 - α) :=
    Real.one_le_rpow hlog (by linarith)
  have hxa : (0:ℝ) ≤ x ^ α := (Real.rpow_pos_of_pos hx0 α).le
  have : c * x ^ α ≤ c * x ^ α * (Real.log x) ^ (1 - α) := by
    nlinarith [mul_nonneg hc hxa]
  exact Real.exp_le_exp.mpr this

/-- **Barrier growth theorem.** For `0 < α ≤ 1` and `c > 0` the subexponential
complexity function `L[α,c]` is superpolynomial: it eventually dominates every
polynomial in the bit-size. -/
theorem Lfun_superpoly {α c : ℝ} (hc : 0 < c) (hα : 0 < α) (hα1 : α ≤ 1) :
    Superpoly (Lfun α c) := by
  refine (Superpoly_exp_rpow hc hα).of_eventually_le ?_
  filter_upwards [eventually_ge_atTop (Real.exp 1)] with x hx
  exact exp_rpow_le_Lfun hc.le hα1 hx

/-! ## The `L`-functions are subexponential -/

/-- Key growth comparison: `x^α (log x)^{1-α} = o(x)` when `α < 1`. -/
theorem tendsto_rpow_mul_log_rpow_div_atTop {α : ℝ} (hα1 : α < 1) :
    Tendsto (fun x : ℝ => x ^ α * (Real.log x) ^ (1 - α) / x) atTop (𝓝 0) := by
  have hlog : Tendsto (fun x : ℝ => Real.log x / x) atTop (𝓝 0) := by
    have := Real.tendsto_pow_log_div_mul_add_atTop 1 0 1 (one_ne_zero)
    simpa using this
  have hcont : ContinuousAt (fun t : ℝ => t ^ (1 - α)) 0 :=
    Real.continuousAt_rpow_const 0 (1 - α) (Or.inr (by linarith))
  have hz : ((0:ℝ) ^ (1 - α)) = 0 := Real.zero_rpow (by linarith)
  have hcomp : Tendsto (fun x : ℝ => (Real.log x / x) ^ (1 - α)) atTop (𝓝 0) := by
    have := (hcont.tendsto.comp hlog)
    rw [hz] at this
    exact this
  refine hcomp.congr' ?_
  filter_upwards [eventually_gt_atTop (1 : ℝ)] with x hx
  have hx0 : (0:ℝ) < x := lt_trans one_pos hx
  have hlx : (0:ℝ) < Real.log x := Real.log_pos hx
  have hxa : (0:ℝ) < x ^ (1 - α) := Real.rpow_pos_of_pos hx0 _
  have hsum : x ^ α * x ^ (1 - α) = x := by
    rw [← Real.rpow_add hx0]; norm_num
  rw [Real.div_rpow hlx.le hx0.le, div_eq_div_iff hxa.ne' hx0.ne']
  calc Real.log x ^ (1 - α) * x
      = Real.log x ^ (1 - α) * (x ^ α * x ^ (1 - α)) := by rw [hsum]
    _ = x ^ α * Real.log x ^ (1 - α) * x ^ (1 - α) := by ring

/-- **Subexponentiality.** For `0 < α < 1` and any `c`, the function `L[α,c]`
grows more slowly than every genuine exponential `exp (ε x)`, `ε > 0`. -/
theorem Lfun_subexp {α c : ℝ} (hc : 0 < c) (hα1 : α < 1) :
    Subexp (Lfun α c) := by
  intro ε hε
  have key : ∀ᶠ x : ℝ in atTop,
      Lfun α c x / Real.exp (ε * x) ≤ Real.exp (-(ε / 2) * x) := by
    have hsmall : ∀ᶠ x : ℝ in atTop,
        x ^ α * (Real.log x) ^ (1 - α) / x < ε / (2 * c) := by
      have h0 : (0:ℝ) < ε / (2 * c) := by positivity
      exact ((tendsto_rpow_mul_log_rpow_div_atTop hα1).eventually
        (eventually_lt_nhds h0)) |>.mono (fun x hx => hx)
    filter_upwards [hsmall, eventually_gt_atTop (1 : ℝ)] with x hx hx1
    have hx0 : (0:ℝ) < x := lt_trans one_pos hx1
    have hlt := (div_lt_iff₀ hx0).mp hx
    have hkey : c * x ^ α * (Real.log x) ^ (1 - α) < (ε / 2) * x := by
      have h2 : c * (x ^ α * (Real.log x) ^ (1 - α)) < c * (ε / (2 * c) * x) :=
        mul_lt_mul_of_pos_left hlt hc
      have h3 : c * (ε / (2 * c) * x) = ε / 2 * x := by
        field_simp
      calc c * x ^ α * (Real.log x) ^ (1 - α)
          = c * (x ^ α * (Real.log x) ^ (1 - α)) := by ring
        _ < c * (ε / (2 * c) * x) := h2
        _ = ε / 2 * x := h3
    rw [Lfun, ← Real.exp_sub]
    apply Real.exp_le_exp.mpr
    linarith
  have hlim : Tendsto (fun x : ℝ => Real.exp (-(ε / 2) * x)) atTop (𝓝 0) := by
    have hpos : Tendsto (fun x : ℝ => Real.exp ((ε / 2) * x)) atTop atTop :=
      Real.tendsto_exp_atTop.comp
        (Filter.Tendsto.const_mul_atTop (by linarith : (0:ℝ) < ε / 2) tendsto_id)
    refine hpos.inv_tendsto_atTop.congr (fun x => ?_)
    simp only [Pi.inv_apply, ← Real.exp_neg]
    ring_nf
  refine squeeze_zero' ?_ key hlim
  filter_upwards with x
  simp only [Lfun]
  positivity

/-! ## Superpolynomial lower bounds exclude polynomial time -/

/-- A superpolynomial function is not polynomially bounded. -/
theorem not_polyBounded_of_superpoly {f : ℝ → ℝ} (hf : Superpoly f) :
    ¬ PolyBounded f := by
  rintro ⟨C, d, hCd⟩
  have hdiv : Tendsto (fun x => f x / x ^ d) atTop atTop := hf d
  have hbdd : ∀ᶠ x : ℝ in atTop, f x / x ^ d ≤ C := by
    filter_upwards [hCd, eventually_gt_atTop (0 : ℝ)] with x hx hx0
    rw [div_le_iff₀ (Real.rpow_pos_of_pos hx0 d)]
    linarith [hx]
  have := (hdiv.eventually (eventually_gt_atTop C)).and hbdd
  rcases this.exists with ⟨x, h1, h2⟩
  linarith

/-- If `f` eventually dominates a superpolynomial function then `f` is not
polynomially bounded. -/
theorem not_polyBounded_of_dominates {f g : ℝ → ℝ} (hg : Superpoly g)
    (h : ∀ᶠ x in atTop, g x ≤ f x) : ¬ PolyBounded f :=
  not_polyBounded_of_superpoly (hg.of_eventually_le h)

/-! ## Separation of the rungs -/

/-- Genuine exponentials are *not* subexponential: `exp (b x)` with `b > 0`
fails the subexponentiality test at `ε = b / 2`. -/
theorem exp_linear_not_subexp {b : ℝ} (hb : 0 < b) :
    ¬ Subexp (fun x => Real.exp (b * x)) := by
  intro h
  have h2 := h (b / 2) (by linarith)
  have hgrow : Tendsto (fun x : ℝ => Real.exp (b * x) / Real.exp (b / 2 * x)) atTop atTop := by
    have : ∀ x : ℝ, Real.exp (b * x) / Real.exp (b / 2 * x) = Real.exp ((b / 2) * x) := by
      intro x; rw [← Real.exp_sub]; ring_nf
    simp only [this]
    exact Real.tendsto_exp_atTop.comp
      (Filter.Tendsto.const_mul_atTop (by linarith : (0:ℝ) < b / 2) tendsto_id)
  have := (hgrow.eventually (eventually_gt_atTop (1:ℝ))).and
    (h2.eventually (eventually_lt_nhds (by norm_num : (0:ℝ) < 1)))
  rcases this.exists with ⟨x, hx1, hx2⟩
  linarith

/-- **The ladder is strict**: for `0 < α < 1` and `c > 0`, `L[α,c]` is
superpolynomial and subexponential, hence lies strictly between the polynomial
and exponential rungs. -/
theorem Lfun_strictly_intermediate {α c : ℝ} (hc : 0 < c) (hα : 0 < α) (hα1 : α < 1) :
    Superpoly (Lfun α c) ∧ Subexp (Lfun α c) ∧ ¬ PolyBounded (Lfun α c) :=
  ⟨Lfun_superpoly hc hα hα1.le, Lfun_subexp hc hα1,
    not_polyBounded_of_superpoly (Lfun_superpoly hc hα hα1.le)⟩

end FactoringBarriers