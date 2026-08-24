/-
# E3 — the margin does not shrink with depth

Cycle four of the attention-cost thread.  `Probability/AttentionMarginLaw.lean`
closed the *pinning* step: if the budget selected by the margin channel equals
the measured depth-linear knee `d·ctx/32`, then the held-out logit margin is
forced to `m = 128·L·B·A`, a value in which the depth `d` does not appear
(`AttentionMarginLaw.margin_forced_by_depth_linear_knee`).  That statement is
exact: it assumes the knee is measured *without error*.  A real sweep reports a
knee on a discrete grid at two seeds, so the exact hypothesis is never available
and the exact conclusion is never testable.

This file turns the pinning step into an experiment that can actually be run and
actually be failed.

* **§1 Pinning with a general calibration constant.**  `margin_pinned_of_knee`
  replaces the fitted `1/32` by an arbitrary `c > 0` and gives `m = 4·c·L·B·A`;
  `margin_pinned_of_knee_32` recovers the catalog value `128·L·B·A`.

* **§2 The band theorem (the E3 statement).**  `marginOfKnee` is the margin a
  measured knee `K` implies.  `margin_ratio_within_band` shows that if the knee
  at two depths is measured within a *relative* tolerance `η < 1` of `d·ctx/c`,
  then the ratio of the implied margins lies in `[(1-η)/(1+η), (1+η)/(1-η)]` —
  with the depths, the context, the amplitude `A` and the read-out constant
  `L·B` all cancelling.  `margin_depth_independent_ten_percent` is the headline:
  a knee measured to `±1/21 ≈ ±4.8 %` certifies the margin flat to `±10 %`, at
  *every* pair of depths (`margin_flat_across_depths`).
  `ten_percent_window_sharp` shows the window is attained, so the constant
  `1/21` cannot be improved by the same argument.

* **§3 Refutation.**  `naive_quarter_scaling_refuted` : the naive prediction
  `m(16) = m(4)/4` is *inconsistent* with knees measured inside the `±1/21`
  band — the mechanism and the naive expectation are not merely different
  fits, they exclude each other.  `threshold_test_correct` gives the decision
  rule with an explicit noise budget: a threshold at `0.45` on the measured
  ratio separates the two hypotheses even under `±50 %` multiplicative error.

* **§4 Power-law rigidity.**  Fitting `m(d) = m₁·d^(-α)` to a margin that is
  flat to `±10 %` forces `|α| ≤ log(10/9)/log 4` (`margin_exponent_small`),
  hence `α ≠ 1` (`naive_exponent_excluded`) and `α = 0` in the exact case
  (`margin_exponent_zero`).  This is the depth leg stated as a statement about
  an exponent, with no truncation sweep anywhere in it.

* **§5 Seeds and medians.**  The protocol reports a *median* over seeds.  Reusing
  the order-statistic machinery of `Computation/MedianBreakdown.lean`,
  `median_ratio_in_band` shows the reported median inherits the band even when
  strictly fewer than half of the runs are corrupted, and
  `median_quarter_refutes` restates the refutation for the reported statistic.

* **§6 The equivalence.**  `knee_linear_of_pinned_margin` is the converse leg: a
  depth-free margin `128·L·B·A` *reproduces* the measured law `k* = d·ctx/32`
  exactly, through `AttentionCostLaw.attention_cost_law`.  Together with §1 this
  is `margin_flat_iff_knee_linear`: depth-linear knee ⇔ depth-free margin.  The
  linear growth of `k*` is therefore carried entirely by the depth leg (error
  accumulation over layers), not by a shrinking margin.
-/

import Mathlib
import Probability.AttentionMarginLaw
import Computation.MedianBreakdown

namespace MarginDepthInvariance

open AttentionCostLaw AttentionMarginLaw

/-!
## 1.  Pinning the margin from a measured knee
-/

/-- **The margin is pinned by the knee, for any calibration constant.**  If the
budget the margin channel asks for at depth `d`, namely `4·L·B·A·d·ctx/m`,
equals the measured knee `d·ctx/c`, then `m = 4·c·L·B·A`: the depth cancels
identically, whatever the fitted constant `c` is.  This generalises
`AttentionMarginLaw.margin_forced_by_depth_linear_knee` (the case `c = 32`). -/
theorem margin_pinned_of_knee {A ctx L B m c : ℝ} {d : ℕ} (hd : 0 < d)
    (hctx : 0 < ctx) (hm : 0 < m) (hc : 0 < c)
    (hlaw : 4 * L * B * A * d * ctx / m = d * ctx / c) :
    m = 4 * c * L * B * A := by
  have hdR : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
  have h1 : 4 * L * B * A * d * ctx = ((d : ℝ) * ctx / c) * m :=
    (div_eq_iff hm.ne').mp hlaw
  have hne : ((d : ℝ) * ctx) ≠ 0 := by positivity
  have hcancel : (4 * c * L * B * A) * ((d : ℝ) * ctx) = m * ((d : ℝ) * ctx) := by
    field_simp at h1 ⊢
    linarith [h1]
  exact (mul_right_cancel₀ hne hcancel).symm

/-- The catalog calibration `c = 32` gives the value quoted in the conjecture:
`m = 128·L·B·A`. -/
theorem margin_pinned_of_knee_32 {A ctx L B m : ℝ} {d : ℕ} (hd : 0 < d)
    (hctx : 0 < ctx) (hm : 0 < m)
    (hlaw : 4 * L * B * A * d * ctx / m = d * ctx / 32) :
    m = 128 * L * B * A := by
  have h := margin_pinned_of_knee (c := 32) hd hctx hm (by norm_num) hlaw
  linarith [h]

/-!
## 2.  The band theorem: what a knee measured to `±η` says about the margin
-/

/-- The margin implied by a *measured* knee `K` at depth `d`: the unique `m`
solving the margin-channel equation `4·L·B·A·d·ctx/m = K`. -/
noncomputable def marginOfKnee (L B A ctx : ℝ) (d : ℕ) (K : ℝ) : ℝ :=
  4 * L * B * A * d * ctx / K

/-- `marginOfKnee` does solve the margin-channel equation: feeding it back gives
the measured knee. -/
theorem marginOfKnee_solves {L B A ctx K : ℝ} {d : ℕ} (hL : 0 < L) (hB : 0 < B)
    (hA : 0 < A) (hctx : 0 < ctx) (hd : 0 < d) (hK : 0 < K) :
    4 * L * B * A * d * ctx / marginOfKnee L B A ctx d K = K := by
  have hdR : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
  have hnum : (0 : ℝ) < 4 * L * B * A * d * ctx := by positivity
  unfold marginOfKnee
  field_simp

theorem marginOfKnee_pos {L B A ctx K : ℝ} {d : ℕ} (hL : 0 < L) (hB : 0 < B)
    (hA : 0 < A) (hctx : 0 < ctx) (hd : 0 < d) (hK : 0 < K) :
    0 < marginOfKnee L B A ctx d K := by
  have hdR : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
  unfold marginOfKnee
  positivity

/-- `x` is within relative tolerance `η` of the reference value `y`. -/
def WithinRel (η x y : ℝ) : Prop := |x - y| ≤ η * y

theorem WithinRel.lower {η x y : ℝ} (h : WithinRel η x y) : (1 - η) * y ≤ x := by
  have := (abs_le.mp h).1
  nlinarith [this]

theorem WithinRel.upper {η x y : ℝ} (h : WithinRel η x y) : x ≤ (1 + η) * y := by
  have := (abs_le.mp h).2
  nlinarith [this]

/-- A knee measured inside a relative band around `d·ctx/c` is positive. -/
theorem knee_pos_of_band {η ctx c K : ℝ} {d : ℕ} (hd : 0 < d) (hctx : 0 < ctx)
    (hc : 0 < c) (hη : η < 1) (h : WithinRel η K ((d : ℝ) * ctx / c)) : 0 < K := by
  have hdR : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
  have href : (0 : ℝ) < (d : ℝ) * ctx / c := by positivity
  have := h.lower
  nlinarith [this]

/-- **The band theorem (E3).**  Suppose the knee is measured at two depths, each
within a relative tolerance `η < 1` of the depth-linear law `d·ctx/c`.  Then the
*ratio* of the two implied margins is confined to `[(1-η)/(1+η), (1+η)/(1-η)]`:
the depths, the context, the tail amplitude `A` and the read-out constant `L·B`
cancel completely, so the prediction has no free parameter left to fit. -/
theorem margin_ratio_within_band {L B A ctx c η K₁ K₂ : ℝ} {d₁ d₂ : ℕ}
    (hL : 0 < L) (hB : 0 < B) (hA : 0 < A) (hctx : 0 < ctx) (hc : 0 < c)
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂) (hη : 0 ≤ η) (hη1 : η < 1)
    (h₁ : WithinRel η K₁ ((d₁ : ℝ) * ctx / c))
    (h₂ : WithinRel η K₂ ((d₂ : ℝ) * ctx / c)) :
    (1 - η) / (1 + η) ≤
        marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂ ∧
      marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂
        ≤ (1 + η) / (1 - η) := by
  have hd₁R : (0 : ℝ) < (d₁ : ℝ) := by exact_mod_cast hd₁
  have hd₂R : (0 : ℝ) < (d₂ : ℝ) := by exact_mod_cast hd₂
  have hK₁ : 0 < K₁ := knee_pos_of_band hd₁ hctx hc hη1 h₁
  have hK₂ : 0 < K₂ := knee_pos_of_band hd₂ hctx hc hη1 h₂
  have hP : (0 : ℝ) < 4 * L * B * A := by positivity
  -- the ratio of implied margins, in closed form
  have hratio : marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂
      = ((d₁ : ℝ) * K₂) / ((d₂ : ℝ) * K₁) := by
    unfold marginOfKnee
    field_simp
  have hden : (0 : ℝ) < (d₂ : ℝ) * K₁ := by positivity
  have hpos1 : (0 : ℝ) < 1 + η := by linarith
  have hpos2 : (0 : ℝ) < 1 - η := by linarith
  -- band facts, with the context/calibration factor `ctx/c` isolated
  have hu₁ : K₁ ≤ (1 + η) * ((d₁ : ℝ) * (ctx / c)) := by
    have h := h₁.upper; rw [mul_div_assoc] at h; exact h
  have hl₁ : (1 - η) * ((d₁ : ℝ) * (ctx / c)) ≤ K₁ := by
    have h := h₁.lower; rw [mul_div_assoc] at h; exact h
  have hu₂ : K₂ ≤ (1 + η) * ((d₂ : ℝ) * (ctx / c)) := by
    have h := h₂.upper; rw [mul_div_assoc] at h; exact h
  have hl₂ : (1 - η) * ((d₂ : ℝ) * (ctx / c)) ≤ K₂ := by
    have h := h₂.lower; rw [mul_div_assoc] at h; exact h
  constructor
  · rw [hratio, div_le_div_iff₀ hpos1 hden]
    have s1 : (1 - η) * ((d₂ : ℝ) * K₁)
        ≤ (1 - η) * ((d₂ : ℝ) * ((1 + η) * ((d₁ : ℝ) * (ctx / c)))) :=
      mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left hu₁ hd₂R.le) hpos2.le
    have s2 : (1 + η) * ((d₁ : ℝ) * ((1 - η) * ((d₂ : ℝ) * (ctx / c))))
        ≤ (1 + η) * ((d₁ : ℝ) * K₂) :=
      mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left hl₂ hd₁R.le) hpos1.le
    have sring : (1 - η) * ((d₂ : ℝ) * ((1 + η) * ((d₁ : ℝ) * (ctx / c))))
        = (1 + η) * ((d₁ : ℝ) * ((1 - η) * ((d₂ : ℝ) * (ctx / c)))) := by ring
    linarith [s1, s2, sring.le, sring.ge]
  · rw [hratio, div_le_div_iff₀ hden hpos2]
    have s1 : (1 - η) * ((d₁ : ℝ) * K₂)
        ≤ (1 - η) * ((d₁ : ℝ) * ((1 + η) * ((d₂ : ℝ) * (ctx / c)))) :=
      mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left hu₂ hd₁R.le) hpos2.le
    have s2 : (1 + η) * ((d₂ : ℝ) * ((1 - η) * ((d₁ : ℝ) * (ctx / c))))
        ≤ (1 + η) * ((d₂ : ℝ) * K₁) :=
      mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left hl₁ hd₂R.le) hpos1.le
    have sring : (1 - η) * ((d₁ : ℝ) * ((1 + η) * ((d₂ : ℝ) * (ctx / c))))
        = (1 + η) * ((d₂ : ℝ) * ((1 - η) * ((d₁ : ℝ) * (ctx / c)))) := by ring
    linarith [s1, s2, sring.le, sring.ge]

/-- **The headline prediction.**  A knee measured to `±1/21 ≈ ±4.8 %` of
`d·ctx/32` at two depths certifies that the implied held-out margins agree to
`±10 %`: `0.9 ≤ m(d₁)/m(d₂) ≤ 1.1`. -/
theorem margin_depth_independent_ten_percent {L B A ctx K₁ K₂ : ℝ} {d₁ d₂ : ℕ}
    (hL : 0 < L) (hB : 0 < B) (hA : 0 < A) (hctx : 0 < ctx)
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂)
    (h₁ : WithinRel (1 / 21) K₁ ((d₁ : ℝ) * ctx / 32))
    (h₂ : WithinRel (1 / 21) K₂ ((d₂ : ℝ) * ctx / 32)) :
    (0.9 : ℝ) ≤ marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂ ∧
      marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂ ≤ 1.1 := by
  obtain ⟨hlo, hhi⟩ := margin_ratio_within_band (c := 32) (η := 1 / 21)
    hL hB hA hctx (by norm_num) hd₁ hd₂ (by norm_num) (by norm_num) h₁ h₂
  constructor
  · have : (1 - 1 / 21 : ℝ) / (1 + 1 / 21) = 10 / 11 := by norm_num
    rw [this] at hlo
    linarith [hlo]
  · have : (1 + 1 / 21 : ℝ) / (1 - 1 / 21) = 11 / 10 := by norm_num
    rw [this] at hhi
    linarith [hhi]

/-- **The margin is flat across the whole depth ladder.**  If the sweep reports
a knee within `±1/21` of `d·ctx/32` at *every* depth, then the implied margins
at any two depths agree to `±10 %` — in particular at `d = 4, 8, 16`. -/
theorem margin_flat_across_depths {L B A ctx : ℝ} (K : ℕ → ℝ)
    (hL : 0 < L) (hB : 0 < B) (hA : 0 < A) (hctx : 0 < ctx)
    (hband : ∀ d : ℕ, 0 < d → WithinRel (1 / 21) (K d) ((d : ℝ) * ctx / 32)) :
    ∀ d₁ d₂ : ℕ, 0 < d₁ → 0 < d₂ →
      (0.9 : ℝ) ≤ marginOfKnee L B A ctx d₁ (K d₁) / marginOfKnee L B A ctx d₂ (K d₂) ∧
        marginOfKnee L B A ctx d₁ (K d₁) / marginOfKnee L B A ctx d₂ (K d₂) ≤ 1.1 :=
  fun d₁ d₂ h₁ h₂ =>
    margin_depth_independent_ten_percent hL hB hA hctx h₁ h₂ (hband d₁ h₁) (hband d₂ h₂)

/-- **The `±10 %` window is sharp for the `±1/21` knee band.**  There are knee
measurements inside the band whose implied margin ratio is exactly `1.1`, so no
argument from the same hypotheses can give a tighter window. -/
theorem ten_percent_window_sharp {L B A ctx : ℝ} (hL : 0 < L) (hB : 0 < B)
    (hA : 0 < A) (hctx : 0 < ctx) {d₁ d₂ : ℕ} (hd₁ : 0 < d₁) (hd₂ : 0 < d₂) :
    ∃ K₁ K₂ : ℝ, WithinRel (1 / 21) K₁ ((d₁ : ℝ) * ctx / 32) ∧
      WithinRel (1 / 21) K₂ ((d₂ : ℝ) * ctx / 32) ∧
      marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂ = 1.1 := by
  have hd₁R : (0 : ℝ) < (d₁ : ℝ) := by exact_mod_cast hd₁
  have hd₂R : (0 : ℝ) < (d₂ : ℝ) := by exact_mod_cast hd₂
  refine ⟨(1 - 1 / 21) * ((d₁ : ℝ) * ctx / 32), (1 + 1 / 21) * ((d₂ : ℝ) * ctx / 32),
    ?_, ?_, ?_⟩
  · unfold WithinRel
    have href : (0 : ℝ) < (d₁ : ℝ) * ctx / 32 := by positivity
    rw [abs_le]
    constructor <;> nlinarith [href]
  · unfold WithinRel
    have href : (0 : ℝ) < (d₂ : ℝ) * ctx / 32 := by positivity
    rw [abs_le]
    constructor <;> nlinarith [href]
  · unfold marginOfKnee
    have hP : (0 : ℝ) < 4 * L * B * A := by positivity
    field_simp
    ring

/-!
## 3.  Refutation: the naive `1/d` margin is excluded, and the test has power
-/

/-- **The naive expectation is refuted, not merely disfavoured.**  If the knees
at depths `4` and `16` are both measured inside the `±1/21` band, then the
implied margins *cannot* satisfy the naive proportionality `m(16) = m(4)/4`.
A measured quarter is therefore evidence against the mechanism's premises, not
evidence for a deeper stack having a proportionally smaller usable margin. -/
theorem naive_quarter_scaling_refuted {L B A ctx K₄ K₁₆ : ℝ}
    (hL : 0 < L) (hB : 0 < B) (hA : 0 < A) (hctx : 0 < ctx)
    (h₄ : WithinRel (1 / 21) K₄ ((4 : ℕ) * ctx / 32))
    (h₁₆ : WithinRel (1 / 21) K₁₆ ((16 : ℕ) * ctx / 32))
    (hnaive : marginOfKnee L B A ctx 16 K₁₆ = marginOfKnee L B A ctx 4 K₄ / 4) :
    False := by
  have hK₄ : 0 < K₄ :=
    knee_pos_of_band (d := 4) (by norm_num) hctx (by norm_num) (by norm_num) h₄
  have hm₄ : 0 < marginOfKnee L B A ctx 4 K₄ :=
    marginOfKnee_pos hL hB hA hctx (by norm_num) hK₄
  obtain ⟨hlo, -⟩ := margin_depth_independent_ten_percent (d₁ := 16) (d₂ := 4)
    hL hB hA hctx (by norm_num) (by norm_num) h₁₆ h₄
  rw [hnaive] at hlo
  have hne : marginOfKnee L B A ctx 4 K₄ ≠ 0 := hm₄.ne'
  have hcollapse : marginOfKnee L B A ctx 4 K₄ / 4 / marginOfKnee L B A ctx 4 K₄
      = 1 / 4 := by
    field_simp
  rw [hcollapse] at hlo
  norm_num at hlo

/-- **The test has power under realistic measurement noise.**  Let `r` be the
true ratio `m(16)/m(4)` and let the harness report `r̂ = r·(1+e)` with a
multiplicative error of at most `50 %`.  Then the decision rule "accept the
mechanism iff `r̂ > 0.45`" is correct on both sides: it accepts whenever the
mechanism's band `r ∈ [0.9, 1.1]` holds, and rejects whenever the naive band
`r ≤ 0.275` (i.e. `1/4` inflated by `10 %`) holds.  The two hypotheses are
separated with room to spare. -/
theorem threshold_test_correct {r e : ℝ} (he : |e| ≤ 1 / 2) (hr : 0 ≤ r) :
    ((0.9 : ℝ) ≤ r → 0.45 ≤ r * (1 + e)) ∧ (r ≤ 0.275 → r * (1 + e) < 0.45) := by
  obtain ⟨he1, he2⟩ := abs_le.mp he
  constructor
  · intro h
    nlinarith [h, he1]
  · intro h
    nlinarith [h, he2, hr]

/-!
## 4.  Power-law rigidity: the depth exponent of the margin is essentially zero
-/

/-- The `d`-dependence of `m` under a power-law ansatz `m(d) = m₁ · d^(-α)`. -/
noncomputable def marginPow (m₁ α : ℝ) (d : ℝ) : ℝ := m₁ * d ^ (-α)

/-- The ratio predicted by the power law between depths `4` and `16` is
`4^(-α)`, independent of the prefactor. -/
theorem marginPow_ratio {m₁ α : ℝ} (hm₁ : 0 < m₁) :
    marginPow m₁ α 16 / marginPow m₁ α 4 = (4 : ℝ) ^ (-α) := by
  have h16 : (16 : ℝ) = (4 : ℝ) ^ (2 : ℝ) := by
    rw [show (2 : ℝ) = ((2 : ℕ) : ℝ) by norm_num, Real.rpow_natCast]
    norm_num
  have h4 : (0 : ℝ) < (4 : ℝ) ^ (-α) := Real.rpow_pos_of_pos (by norm_num) _
  unfold marginPow
  rw [h16, ← Real.rpow_mul (by norm_num : (0:ℝ) ≤ 4)]
  rw [show (2 : ℝ) * -α = -α + -α by ring, Real.rpow_add (by norm_num : (0:ℝ) < 4)]
  field_simp

/-- **A margin flat to `±10 %` pins the power-law exponent.**  If the measured
depth ratio `m(16)/m(4)` sits in `[0.9, 1.1]` and the margin follows a power law
`m(d) = m₁·d^(-α)`, then `|α| ≤ log(10/9)/log 4 ≈ 0.076`.  The depth leg is thus
a statement about an exponent, testable from two forward passes. -/
theorem margin_exponent_small {m₁ α : ℝ} (hm₁ : 0 < m₁)
    (hlo : (9 : ℝ) / 10 ≤ marginPow m₁ α 16 / marginPow m₁ α 4)
    (hhi : marginPow m₁ α 16 / marginPow m₁ α 4 ≤ 11 / 10) :
    |α| ≤ Real.log (10 / 9) / Real.log 4 := by
  rw [marginPow_ratio hm₁] at hlo hhi
  have hlog4 : 0 < Real.log 4 := Real.log_pos (by norm_num)
  have hrp : (0 : ℝ) < (4 : ℝ) ^ (-α) := Real.rpow_pos_of_pos (by norm_num) _
  have hlogeq : Real.log ((4 : ℝ) ^ (-α)) = -α * Real.log 4 :=
    Real.log_rpow (by norm_num) _
  have hupper : -α * Real.log 4 ≤ Real.log (11 / 10) := by
    rw [← hlogeq]
    exact Real.log_le_log hrp hhi
  have hlower : Real.log (9 / 10) ≤ -α * Real.log 4 := by
    rw [← hlogeq]
    exact Real.log_le_log (by norm_num) hlo
  have h1110 : Real.log (11 / 10) ≤ Real.log (10 / 9) :=
    Real.log_le_log (by norm_num) (by norm_num)
  have h910 : Real.log (9 / 10) = -Real.log (10 / 9) := by
    rw [show (9 : ℝ) / 10 = ((10 : ℝ) / 9)⁻¹ by norm_num, Real.log_inv]
  rw [h910] at hlower
  have habs : |(-α) * Real.log 4| ≤ Real.log (10 / 9) :=
    abs_le.mpr ⟨by linarith, by linarith⟩
  have heq : |(-α) * Real.log 4| = |α| * Real.log 4 := by
    rw [abs_mul, abs_neg, abs_of_pos hlog4]
  rw [heq] at habs
  rw [le_div_iff₀ hlog4]
  exact habs

/-- **The naive exponent is excluded.**  `α = 1` — the "deeper stack, four times
smaller margin" reading — is incompatible with a margin flat to `±10 %`, because
`log(10/9) < log 4`. -/
theorem naive_exponent_excluded {m₁ α : ℝ} (hm₁ : 0 < m₁)
    (hlo : (9 : ℝ) / 10 ≤ marginPow m₁ α 16 / marginPow m₁ α 4)
    (hhi : marginPow m₁ α 16 / marginPow m₁ α 4 ≤ 11 / 10) :
    α ≠ 1 := by
  intro hα
  have h := margin_exponent_small hm₁ hlo hhi
  rw [hα] at h
  have hlog4 : 0 < Real.log 4 := Real.log_pos (by norm_num)
  have hlt : Real.log (10 / 9) < Real.log 4 := by
    apply Real.log_lt_log (by norm_num) (by norm_num)
  rw [abs_one, le_div_iff₀ hlog4] at h
  linarith

/-- **Exact version.**  A margin that is exactly equal at `d = 4` and `d = 16`
and follows a power law has exponent `0`: the margin is genuinely constant in
depth, not merely slowly varying. -/
theorem margin_exponent_zero {m₁ α : ℝ} (hm₁ : 0 < m₁)
    (hflat : marginPow m₁ α 16 = marginPow m₁ α 4) : α = 0 := by
  have h4 : (0 : ℝ) < marginPow m₁ α 4 := by
    unfold marginPow
    have : (0 : ℝ) < (4 : ℝ) ^ (-α) := Real.rpow_pos_of_pos (by norm_num) _
    positivity
  have hratio : marginPow m₁ α 16 / marginPow m₁ α 4 = 1 := by
    rw [hflat, div_self h4.ne']
  rw [marginPow_ratio hm₁] at hratio
  have hlog : -α * Real.log 4 = 0 := by
    have := Real.log_rpow (by norm_num : (0:ℝ) < 4) (-α)
    rw [hratio, Real.log_one] at this
    linarith [this]
  have hlog4 : 0 < Real.log 4 := Real.log_pos (by norm_num)
  have : α * Real.log 4 = 0 := by linarith
  rcases mul_eq_zero.mp this with h | h
  · exact h
  · exact absurd h hlog4.ne'

/-!
## 5.  Seeds: the reported statistic is a median, and the band survives it
-/

/-- **The reported median inherits the band.**  The protocol runs two seeds per
depth and reports the *median* held-out margin ratio.  Reusing the breakdown
theory of `Computation/MedianBreakdown.lean`: if the genuine per-run ratios all
lie in `[9/10, 11/10]` and strictly fewer than half of the reported runs are
corrupted, then every median of the reported list still lies in `[9/10, 11/10]`.
The E3 test is therefore robust to a minority of broken runs. -/
theorem median_ratio_in_band {xs ys : List ℚ} {m : ℚ}
    (hlen : xs.length = ys.length)
    (hd : 2 * MedianBreakdown.diffCount xs ys < xs.length)
    (hm : MedianBreakdown.IsMedian ys m)
    (hband : ∀ x ∈ xs, 9 / 10 ≤ x ∧ x ≤ 11 / 10) :
    9 / 10 ≤ m ∧ m ≤ 11 / 10 :=
  MedianBreakdown.median_robust_interval hlen hd hm
    (fun x hx => (hband x hx).1) (fun x hx => (hband x hx).2)

/-- **The reported median refutes the naive prediction too.**  If every genuine
run lies in the mechanism's band and fewer than half of the runs are corrupted,
the reported median cannot be the naive `1/4` — nor anything below `9/10`. -/
theorem median_quarter_refutes {xs ys : List ℚ} {m : ℚ}
    (hlen : xs.length = ys.length)
    (hd : 2 * MedianBreakdown.diffCount xs ys < xs.length)
    (hm : MedianBreakdown.IsMedian ys m)
    (hband : ∀ x ∈ xs, 9 / 10 ≤ x ∧ x ≤ 11 / 10) :
    m ≠ 1 / 4 := by
  intro h
  have := (median_ratio_in_band hlen hd hm hband).1
  rw [h] at this
  norm_num at this

/-- The E3 acceptance predicate on a reported median ratio, decidable on the
rationals the harness actually prints. -/
def PassesE3 (r : ℚ) : Prop := 9 / 10 ≤ r ∧ r ≤ 11 / 10

instance (r : ℚ) : Decidable (PassesE3 r) := by unfold PassesE3; infer_instance

/-- The test is not vacuous on either side: a flat ratio passes and the naive
quarter fails. -/
theorem passesE3_separates : PassesE3 1 ∧ ¬ PassesE3 (1 / 4) := by
  constructor
  · exact ⟨by norm_num, by norm_num⟩
  · rintro ⟨h, -⟩
    norm_num at h

/-- **Worked synthetic example** (not measured data): a six-run log
`d = 4, 8, 16` at two seeds each, with reported margin ratios relative to the
`d = 4` seed-1 run.  All six lie inside the acceptance band, so every median of
the log does too, and the log passes E3 while excluding the naive `1/4`. -/
theorem synthetic_log_passes {m : ℚ}
    (hm : MedianBreakdown.IsMedian [1, 102/100, 98/100, 104/100, 97/100, 101/100] m) :
    PassesE3 m := by
  have h := median_ratio_in_band (xs := [1, 102/100, 98/100, 104/100, 97/100, 101/100])
    (ys := [1, 102/100, 98/100, 104/100, 97/100, 101/100]) rfl
    (by rw [MedianBreakdown.diffCount_self]; simp) hm
    (by intro x hx; fin_cases hx <;> norm_num)
  exact h

/-!
## 6.  The converse leg, and the equivalence
-/

/-- **A depth-free margin reproduces the depth-linear knee.**  If the held-out
margin equals the pinned value `128·L·B·A` at every depth, then the least
sufficient top-`k` budget for the end-to-end criterion is exactly `d·ctx/32` on
every cell with `32 ∣ d·ctx`, through `AttentionCostLaw.attention_cost_law`.
The linear growth of `k*` is thus produced entirely by the depth leg (error
accumulation over layers), with a constant margin. -/
theorem knee_linear_of_pinned_margin {A L B : ℝ} (hA : 0 < A) (hL : 0 < L)
    (hB : 0 < B) {d ctx : ℕ} (hd : 0 < d) (hctx : 0 < ctx) (hdvd : 32 ∣ d * ctx) :
    IsLeast {k : ℕ | 0 < k ∧ (d : ℝ) * zipfTail A ctx k ≤ (128 * L * B * A) / (4 * L * B)}
      (d * ctx / 32) := by
  have hδ : (128 * L * B * A) / (4 * L * B) = 32 * A := by
    field_simp
    ring
  rw [hδ]
  have hδpos : (0 : ℝ) < 32 * A := by positivity
  have hcal : A / (32 * A) = 1 / 32 := by
    field_simp
  exact attention_cost_law hA hδpos hcal hd hctx hdvd

/-- **Depth-linear knee ⇔ depth-free margin.**  Forward: a knee measured at
`d·ctx/32` pins the margin at `128·L·B·A`, with no `d` in it.  Backward: the
pinned margin regenerates the measured knee `d·ctx/32` exactly.  So the depth
leg of the mechanism *is* the statement that the margin is depth-independent —
this is the content of E3, and it needs no truncation sweep to test. -/
theorem margin_flat_iff_knee_linear {A L B : ℝ} (hA : 0 < A) (hL : 0 < L)
    (hB : 0 < B) {d ctx : ℕ} (hd : 0 < d) (hctx : 0 < ctx) (hdvd : 32 ∣ d * ctx) :
    (∀ m : ℝ, 0 < m → 4 * L * B * A * d * (ctx : ℝ) / m = (d : ℝ) * ctx / 32 →
        m = 128 * L * B * A) ∧
      IsLeast {k : ℕ | 0 < k ∧
          (d : ℝ) * zipfTail A ctx k ≤ (128 * L * B * A) / (4 * L * B)} (d * ctx / 32) := by
  have hctxR : (0 : ℝ) < (ctx : ℝ) := by exact_mod_cast hctx
  refine ⟨fun m hm hlaw => margin_pinned_of_knee_32 hd hctxR hm hlaw, ?_⟩
  exact knee_linear_of_pinned_margin hA hL hB hd hctx hdvd

/-- **The deficit at the knee is free of both depth and context.**  With the
margin pinned at `128·L·B·A`, the two-sided margin law of
`AttentionMarginLaw.margin_law_theta` reads `16·A ≤ 1 - ρ(k*) ≤ 32·A`: the
attention deficit at the selected budget depends on the tail amplitude alone.
Every `d`, every `ctx ≥ 32`, the same window. -/
theorem deficit_window_depth_and_context_free {A ctx L B : ℝ} (hA : 0 < A)
    (hL : 0 < L) (hB : 0 < B) (hctx : (32 : ℝ) ≤ ctx) :
    16 * A ≤ zipfTail A ctx (marginKnee A ctx L B (128 * L * B * A)) ∧
      zipfTail A ctx (marginKnee A ctx L B (128 * L * B * A)) ≤ 32 * A := by
  have hctx0 : (0 : ℝ) < ctx := by linarith
  have hm : (0 : ℝ) < 128 * L * B * A := by positivity
  have hbite : 1 ≤ 4 * L * B * A * ctx / (128 * L * B * A) := by
    rw [le_div_iff₀ hm]
    nlinarith [hctx, hA, hL, hB, mul_pos (mul_pos hL hB) hA]
  obtain ⟨hlo, hhi⟩ := margin_law_theta hA hctx0 hL hB hm hbite
  have e1 : (128 * L * B * A) / (8 * L * B) = 16 * A := by field_simp; ring
  have e2 : (128 * L * B * A) / (4 * L * B) = 32 * A := by field_simp; ring
  rw [e1] at hlo
  rw [e2] at hhi
  exact ⟨hlo, hhi⟩

end MarginDepthInvariance