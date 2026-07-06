import Mathlib
import EML.FixedPointConvergence

/-!
# EML Fixed-Point Theorem: The Sharp Asymptotic Convergence Rate

`EML.FixedPointConvergence` proves that the EML single operator
`f(x) = exp(a) · log(b·x + c)` is a contraction on an invariant interval and that
its Picard iteration `xₙ₊₁ = f(xₙ)` converges to a unique fixed point `x*`.
`EML.FixedPointRate` upgrades this to the *a priori* geometric error bound
`|xₙ − x*| ≤ |x₁ − x₀| · ρⁿ / (1 − ρ)`, where `ρ` is the **interval-wide**
contraction constant `D.rho` bounding `|f'|` on the whole interval.

The literal statement of the EML fixed-point conjecture, however, is that the
iteration converges *at rate `O(ρⁿ)` where `ρ = |f'(x*)|`* — the contraction
constant evaluated **exactly at the fixed point**, which is generically strictly
smaller than the interval-wide bound `D.rho`. This file proves that sharp,
local statement: the iteration is **Q-linearly convergent with asymptotic ratio
exactly `|f'(x*)|`**:

  `|xₙ₊₁ − x*| / |xₙ − x*|  →  |f'(x*)| = |exp(a) · b / (b·x* + c)|`.

This is the precise dynamical meaning of "rate `ρ = |f'(x*)|`": the per-step
error contraction ratio does not merely stay below `D.rho`, it converges to the
local derivative magnitude at the fixed point.

## Main results

* `EMLIterOp.strictMonoOn_of_b_pos` — for `b > 0` the operator is strictly
  monotone on the invariant interval (so it is injective there).
* `EMLIterOp.iterSeq_ne_fixedPoint` — a non-degenerate start `x₀ ≠ x*` never
  hits the fixed point: every iterate stays distinct from `x*`.
* `EMLIterOp.iterSeq_sharp_rate` — **the sharp asymptotic rate**: the ratio of
  consecutive errors tends to `|f'(x*)|`.
* `EMLIterOp.sharp_rate_le_interval_rate` / `EMLIterOp.sharp_rate_lt_one` — the
  asymptotic ratio is bounded by the interval constant `D.rho`, hence `< 1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The catalog's rate theorem certifies convergence with
the *interval* constant `D.rho`, but the conjecture insists the true rate is the
*local* derivative magnitude `|f'(x*)|`. Bold claim: the consecutive-error ratio
converges to exactly `|f'(x*)|`, so `D.rho` is only an upper proxy.

Experiment (Experimenter): The decisive tool is `hasDerivAt_iff_tendsto_slope`:
`HasDerivAt f L x*` is *equivalent* to `slope f x* → L` along `𝓝[≠] x*`. The
Picard sequence already tends to `x*` (catalog), and `slope f x* xₙ` is literally
`(xₙ₊₁ − x*)/(xₙ − x*)`. Feeding the sequence into the punctured-neighbourhood
limit and taking absolute values yields the ratio limit. The only non-soft input
is that the iterates stay `≠ x*`, which needs injectivity of `f`.

Analysis (Analyst): Injectivity is where `b > 0` finally earns its keep: it makes
`f' = exp(a)·b/(b·x+c) > 0`, hence `f` strictly increasing, hence injective; and
a strictly monotone map sends `x₀ ≠ x*` forward to `xₙ ≠ x*` forever. So the
sharp rate is a clean composition of (i) the soft metric convergence, (ii) the
analytic derivative at `x*`, and (iii) injectivity. None of the three alone is
new, but their composition gives the conjecture's literal rate, absent from the
catalog.

Critique (Critic): Is `x₀ ≠ x*` a cheat hypothesis? No — if `x₀ = x*` the
sequence is constant and the ratio is the degenerate `0/0 = 0`, which need not
equal `|f'(x*)|`; the non-degeneracy is genuinely required and is the natural
condition. Is the limit vacuous (e.g. `0`)? Not in general: it equals
`|f'(x*)|`, which is positive whenever `b > 0`. The bound
`|f'(x*)| ≤ D.rho < 1` certifies it is a genuine contraction ratio.

Synthesis (PI): This pins the EML iteration's asymptotic rate to the local
derivative, sharpening the catalog's interval-constant bound to the exact value
predicted by the conjecture.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set Filter Topology

namespace EMLIterOp

/-
For `b > 0`, the EML operator is strictly monotone on the invariant interval,
because its derivative `exp(a)·b/(b·x+c)` is positive there.
-/
theorem strictMonoOn_of_b_pos (a b c lo hi : ℝ) (hb : 0 < b)
    (harg : ∀ x ∈ Icc lo hi, 0 < b * x + c) :
    StrictMonoOn (EMLIterOp a b c) (Icc lo hi) := by
  intros x hx y hy hxy;
  exact mul_lt_mul_of_pos_left ( Real.log_lt_log ( harg x hx ) ( by nlinarith [ harg x hx, harg y hy ] ) ) ( Real.exp_pos _ )

/-- For `b > 0`, the EML operator is injective on the invariant interval. -/
theorem injOn_of_b_pos (a b c lo hi : ℝ) (hb : 0 < b)
    (harg : ∀ x ∈ Icc lo hi, 0 < b * x + c) :
    Set.InjOn (EMLIterOp a b c) (Icc lo hi) :=
  (strictMonoOn_of_b_pos a b c lo hi hb harg).injOn

/-
A non-degenerate start never reaches the fixed point: if `x₀ ≠ x*` then every
iterate `xₙ` is distinct from the fixed point `x*`. This uses injectivity of the
operator on the invariant interval (hence `b > 0`).
-/
theorem iterSeq_ne_fixedPoint (D : EMLContractionData) (hb : 0 < D.b)
    (x₀ : ℝ) (hx₀ : x₀ ∈ Icc D.lo D.hi)
    (xstar : ℝ) (hfix : EMLIterOp D.a D.b D.c xstar = xstar)
    (hxstar : xstar ∈ Icc D.lo D.hi) (hx0_ne : x₀ ≠ xstar) :
    ∀ n, EMLIterOp.iterSeq D.a D.b D.c x₀ n ≠ xstar := by
  intro n hn;
  induction' n with n ih;
  · exact hx0_ne hn;
  · exact ih ( by have := injOn_of_b_pos D.a D.b D.c D.lo D.hi hb D.arg_pos ( EMLIterOp.iterSeq_mem_Icc D.a D.b D.c x₀ D.lo D.hi hx₀ D.maps_to n ) hxstar ( by aesop ) ; aesop )

/-
**The sharp asymptotic convergence rate of the EML iteration.**
For `b > 0` and a non-degenerate start `x₀ ≠ x*`, the ratio of consecutive errors
converges to the magnitude of the derivative at the fixed point,
`|f'(x*)| = |exp(a)·b/(b·x*+c)|`. This is the literal `ρ = |f'(x*)|` rate of the
EML fixed-point conjecture, sharper than the interval-wide constant `D.rho`.
-/
theorem iterSeq_sharp_rate (D : EMLContractionData) (hb : 0 < D.b)
    (x₀ : ℝ) (hx₀ : x₀ ∈ Icc D.lo D.hi)
    (xstar : ℝ) (hfix : EMLIterOp D.a D.b D.c xstar = xstar)
    (hxstar : xstar ∈ Icc D.lo D.hi)
    (htend : Tendsto (EMLIterOp.iterSeq D.a D.b D.c x₀) atTop (𝓝 xstar))
    (hx0_ne : x₀ ≠ xstar) :
    Tendsto
      (fun n => |EMLIterOp.iterSeq D.a D.b D.c x₀ (n + 1) - xstar| /
                 |EMLIterOp.iterSeq D.a D.b D.c x₀ n - xstar|)
      atTop (𝓝 |exp D.a * D.b / (D.b * xstar + D.c)|) := by
  have hderiv : HasDerivAt (EMLIterOp D.a D.b D.c) (Real.exp D.a * D.b / (D.b * xstar + D.c)) xstar := by
    exact EMLIterOp.hasDerivAt _ _ _ _ ( D.arg_pos _ hxstar );
  convert hderiv.tendsto_slope_zero.comp ( show Filter.Tendsto ( fun n => iterSeq D.a D.b D.c x₀ n - xstar ) atTop ( nhdsWithin 0 { 0 } ᶜ ) from ?_ ) |> Filter.Tendsto.abs using 2;
  · simp +decide [ abs_inv, hfix, iterSeq_succ ];
    ring;
  · rw [ tendsto_nhdsWithin_iff ];
    exact ⟨ by simpa using htend.sub_const xstar, Filter.Eventually.of_forall fun n => sub_ne_zero_of_ne <| iterSeq_ne_fixedPoint D hb x₀ hx₀ xstar hfix hxstar hx0_ne n ⟩

/-- The asymptotic ratio `|f'(x*)|` is bounded by the interval-wide contraction
constant `D.rho`: the sharp local rate is never worse than the catalog's bound. -/
theorem sharp_rate_le_interval_rate (D : EMLContractionData)
    (xstar : ℝ) (hxstar : xstar ∈ Icc D.lo D.hi) :
    |exp D.a * D.b / (D.b * xstar + D.c)| ≤ D.rho :=
  D.deriv_bound xstar hxstar

/-- The asymptotic convergence ratio at the fixed point is a genuine contraction
ratio: `|f'(x*)| < 1`. -/
theorem sharp_rate_lt_one (D : EMLContractionData)
    (xstar : ℝ) (hxstar : xstar ∈ Icc D.lo D.hi) :
    |exp D.a * D.b / (D.b * xstar + D.c)| < 1 :=
  lt_of_le_of_lt (sharp_rate_le_interval_rate D xstar hxstar) D.rho_lt_one

/-
**Eventual per-step geometric contraction at the local rate.** For any rate
`r` strictly above the local derivative magnitude `|f'(x*)|`, the EML iteration
eventually contracts the error by a factor `r` at every step. This is the precise
`O(rⁿ)` content of the conjecture for every `r > |f'(x*)|`: since the asymptotic
ratio is exactly `|f'(x*)|`, no rate below it can work, and every rate above it
does.
-/
theorem iterSeq_eventually_step_contraction (D : EMLContractionData) (hb : 0 < D.b)
    (x₀ : ℝ) (hx₀ : x₀ ∈ Icc D.lo D.hi)
    (xstar : ℝ) (hfix : EMLIterOp D.a D.b D.c xstar = xstar)
    (hxstar : xstar ∈ Icc D.lo D.hi)
    (htend : Tendsto (EMLIterOp.iterSeq D.a D.b D.c x₀) atTop (𝓝 xstar))
    (hx0_ne : x₀ ≠ xstar)
    (r : ℝ) (hr : |exp D.a * D.b / (D.b * xstar + D.c)| < r) :
    ∀ᶠ n in atTop,
      |EMLIterOp.iterSeq D.a D.b D.c x₀ (n + 1) - xstar| ≤
        r * |EMLIterOp.iterSeq D.a D.b D.c x₀ n - xstar| := by
  obtain ⟨N, hN⟩ : ∃ N, ∀ n ≥ N, |EMLIterOp.iterSeq D.a D.b D.c x₀ (n + 1) - xstar| / |EMLIterOp.iterSeq D.a D.b D.c x₀ n - xstar| < r := by
    exact Filter.eventually_atTop.mp ( EMLIterOp.iterSeq_sharp_rate D hb x₀ hx₀ xstar hfix hxstar htend hx0_ne |> fun h => h.eventually ( gt_mem_nhds hr ) );
  filter_upwards [ Filter.eventually_ge_atTop N, Filter.eventually_gt_atTop 0 ] with n hn hn' using by have := hN n hn; rw [ div_lt_iff₀ ( abs_pos.mpr <| sub_ne_zero.mpr <| iterSeq_ne_fixedPoint D hb x₀ hx₀ xstar hfix hxstar hx0_ne n ) ] at this; linarith;

end EMLIterOp

end