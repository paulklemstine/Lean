/-
# The which-factor wall as a cross-population invariant: how much does it really pin down?

This file continues `Speculative.AutoResearch.TraceBatteryWall`
(`TraceBattery.binary_wall_inversion`), which shows that a *binary* capacity
("wall") value determines the class imbalance of a two-valued statistic
**uniquely** on the balanced side `[0, 1/2]`.  Uniqueness, however, is a
qualitative statement.  The research question of this cycle is quantitative:

> if two independent populations report walls that agree to within `ε`,
> how close are their class imbalances?

The mission proposal was:

  `|binEntropy p - binEntropy q| ≥ c(δ) |p - q|` on `[δ, 1/2]`,
  with `c(δ) = log ((1-δ)/δ)`.

**This is false**, and `binEntropy_conjectured_lower_bound_false` refutes it with
an exact counterexample (`δ = q = 1/4`, `p = 1/2`), where the failure reduces to
`log 16 ≤ log 27`.  The reason is structural: `c(δ)` is the *supremum* of
`|binEntropy'|` on `[δ, 1/2]`, not its infimum, so it controls the Lipschitz
(upper) bound, while the true inverse bound must be governed by the derivative
at the endpoint *closest to* `1/2`.

What survives, and is proved here with zero sorries:

* `binEntropy_sub_ge` — the sharp mean-value lower bound
  `(q - p) * (log (1-q) - log q) ≤ binEntropy q - binEntropy p` for
  `0 ≤ p ≤ q ≤ 1/2` (including the boundary case `p = 0`).
* `binEntropy_lipschitz` — the true version of the proposed inequality, with the
  inequality reversed: `|binEntropy p - binEntropy q| ≤ c(δ) |p - q|` on
  `[δ, 1-δ]`.
* `imbalance_dist_le` / `imbalance_dist_le_div` — the corrected **cross-population
  stability theorem**: imbalances in `[0, 1/2 - η]` whose walls agree within `ε`
  agree within `ε / log ((1/2+η)/(1/2-η))`.
* `binary_wall_stability` — the same statement at the level of two binary
  statistics on two different finite populations, via the empirical entropy `H`.
* `log_two_sub_binEntropy_le_sq` — `log 2 - binEntropy (1/2 - t) ≤ 4 t²`, and
  `no_uniform_inversion_constant`: **no** constant inverts the wall near `1/2`.
  So the guard `η > 0` is not an artefact: the wall genuinely loses all
  resolution at balance, at a quadratic rate.
* `wall_imbalance_bracket` — the reported wall `0.4677` bits is a falsifiable
  claim about the split: the unique minority fraction in `[0, 1/2]` realising it
  lies strictly between `1/12` and `1/9` (i.e. between 8.34% and 11.11%),
  consistent with the reported 9.96% and inconsistent with, say, a 5% or a 15%
  split.

Because the catalog module `Combinatorics.TraceBatteryEntropy` carrying the
empirical-entropy definitions is not present in this snapshot, the small
population layer (`img`, `cnt`, `H`, `H_two_values`) is restated here in the
namespace `WhichFactorWall`, with the same definitions, so that the file is
self-contained and compiles on its own.
-/
import Mathlib

namespace WhichFactorWall

open Real Set

/-! ## 1.  Mean-value machinery for `Real.binEntropy`

`binEntropy` is differentiable away from `{0,1}` with derivative
`log (1-x) - log x` (Mathlib's `Real.deriv_binEntropy`).  We turn one-sided
bounds on that derivative into slope bounds by monotonicity of an auxiliary
function; this is the mean value theorem in the form we need. -/

private lemma hasDerivAt_binEntropy_sub_lin (c x : ℝ) (hx0 : x ≠ 0) (hx1 : x ≠ 1) :
    HasDerivAt (fun y : ℝ => binEntropy y - c * y) (log (1 - x) - log x - c) x := by
  simpa using (Real.hasDerivAt_binEntropy hx0 hx1).sub ((hasDerivAt_id x).const_mul c)

private lemma hasDerivAt_lin_sub_binEntropy (c x : ℝ) (hx0 : x ≠ 0) (hx1 : x ≠ 1) :
    HasDerivAt (fun y : ℝ => c * y - binEntropy y) (c - (log (1 - x) - log x)) x := by
  simpa using ((hasDerivAt_id x).const_mul c).sub (Real.hasDerivAt_binEntropy hx0 hx1)

private lemma monotoneOn_binEntropy_sub_lin {a b c : ℝ} (h0 : 0 < a) (hb : b < 1)
    (hc : ∀ x ∈ Ioo a b, c ≤ log (1 - x) - log x) :
    MonotoneOn (fun x => binEntropy x - c * x) (Icc a b) := by
  have hcont : ContinuousOn (fun x : ℝ => binEntropy x - c * x) (Icc a b) :=
    Real.binEntropy_continuous.continuousOn.sub (continuousOn_const.mul continuousOn_id)
  apply monotoneOn_of_deriv_nonneg (convex_Icc a b) hcont
  · rw [interior_Icc]
    intro x hx
    exact ((hasDerivAt_binEntropy_sub_lin c x (by nlinarith [hx.1, hx.2])
      (by nlinarith [hx.2])).differentiableAt).differentiableWithinAt
  · rw [interior_Icc]
    intro x hx
    rw [(hasDerivAt_binEntropy_sub_lin c x (by nlinarith [hx.1, hx.2]) (by nlinarith [hx.2])).deriv]
    linarith [hc x hx]

private lemma monotoneOn_lin_sub_binEntropy {a b c : ℝ} (h0 : 0 < a) (hb : b < 1)
    (hc : ∀ x ∈ Ioo a b, log (1 - x) - log x ≤ c) :
    MonotoneOn (fun x => c * x - binEntropy x) (Icc a b) := by
  have hcont : ContinuousOn (fun x : ℝ => c * x - binEntropy x) (Icc a b) :=
    (continuousOn_const.mul continuousOn_id).sub Real.binEntropy_continuous.continuousOn
  apply monotoneOn_of_deriv_nonneg (convex_Icc a b) hcont
  · rw [interior_Icc]
    intro x hx
    exact ((hasDerivAt_lin_sub_binEntropy c x (by nlinarith [hx.1, hx.2])
      (by nlinarith [hx.2])).differentiableAt).differentiableWithinAt
  · rw [interior_Icc]
    intro x hx
    rw [(hasDerivAt_lin_sub_binEntropy c x (by nlinarith [hx.1, hx.2]) (by nlinarith [hx.2])).deriv]
    linarith [hc x hx]

/-- **Sharp inverse (mean-value) bound.**  For `0 ≤ p ≤ q ≤ 1/2` the entropy gain is at
least `(q-p)` times the slope at the *upper* endpoint `q`.  The constant
`log (1-q) - log q` is the correct one: it is the infimum of `binEntropy'` on
`[p, q]`, and it degenerates to `0` as `q → 1/2`. -/
theorem binEntropy_sub_ge {p q : ℝ} (hp : 0 ≤ p) (hpq : p ≤ q) (hq : q ≤ 2⁻¹) :
    (q - p) * (log (1 - q) - log q) ≤ binEntropy q - binEntropy p := by
  rcases eq_or_lt_of_le hp with h0 | h0
  · subst_vars
    rw [Real.binEntropy_zero, Real.binEntropy, Real.log_inv, Real.log_inv]
    have h1 : log (1 - q) ≤ 0 := Real.log_nonpos (by linarith) (by linarith)
    nlinarith [h1]
  · have hmono := monotoneOn_binEntropy_sub_lin (a := p) (b := q) (c := log (1 - q) - log q)
      h0 (by linarith) ?_
    · have h := hmono (left_mem_Icc.2 hpq) (right_mem_Icc.2 hpq) hpq
      simp only at h
      nlinarith [h]
    · intro x hx
      have hlq : log x ≤ log q := Real.log_le_log (lt_trans h0 hx.1) hx.2.le
      have hl1 : log (1 - q) ≤ log (1 - x) :=
        Real.log_le_log (by linarith [hx.2]) (by linarith [hx.2])
      linarith

/-- **The proposed inequality, with the direction that is actually true.**
`c(δ) = log ((1-δ)/δ)` is the supremum of `|binEntropy'|` on `[δ, 1-δ]`, hence a
Lipschitz constant, *not* an inverse-Lipschitz constant. -/
theorem binEntropy_lipschitz {δ p q : ℝ} (hδ : 0 < δ) (hp : p ∈ Icc δ (1 - δ))
    (hq : q ∈ Icc δ (1 - δ)) :
    |binEntropy p - binEntropy q| ≤ (log (1 - δ) - log δ) * |p - q| := by
  have key : ∀ a b : ℝ, a ∈ Icc δ (1 - δ) → b ∈ Icc δ (1 - δ) → a ≤ b →
      |binEntropy a - binEntropy b| ≤ (log (1 - δ) - log δ) * |a - b| := by
    intro a b ha hb hab
    set c := log (1 - δ) - log δ with hc
    have hb1 : b < 1 := by linarith [hb.2]
    have ha0 : 0 < a := lt_of_lt_of_le hδ ha.1
    have hup : binEntropy b - binEntropy a ≤ c * (b - a) := by
      have hmono := monotoneOn_lin_sub_binEntropy (a := a) (b := b) (c := c) ha0 hb1 ?_
      · have h := hmono (left_mem_Icc.2 hab) (right_mem_Icc.2 hab) hab
        simp only at h
        nlinarith [h]
      · intro x hx
        have hxδ : δ ≤ x := le_trans ha.1 hx.1.le
        have hx1 : x ≤ 1 - δ := le_trans hx.2.le hb.2
        have h1 : log (1 - x) ≤ log (1 - δ) := Real.log_le_log (by linarith) (by linarith)
        have h2 : log δ ≤ log x := Real.log_le_log hδ hxδ
        linarith
    have hlow : -(c * (b - a)) ≤ binEntropy b - binEntropy a := by
      have hmono := monotoneOn_binEntropy_sub_lin (a := a) (b := b) (c := -c) ha0 hb1 ?_
      · have h := hmono (left_mem_Icc.2 hab) (right_mem_Icc.2 hab) hab
        simp only at h
        nlinarith [h]
      · intro x hx
        have hxδ : δ ≤ x := le_trans ha.1 hx.1.le
        have hx1 : x ≤ 1 - δ := le_trans hx.2.le hb.2
        have hx0 : 0 < x := lt_of_lt_of_le hδ hxδ
        have h1 : log δ ≤ log (1 - x) := Real.log_le_log hδ (by linarith)
        have h2 : log x ≤ log (1 - δ) := Real.log_le_log hx0 hx1
        linarith
    rw [abs_of_nonpos (by linarith : a - b ≤ 0), abs_sub_comm, abs_le]
    constructor <;> nlinarith [hup, hlow]
  rcases le_total p q with h | h
  · exact key p q hp hq h
  · rw [abs_sub_comm, abs_sub_comm p q]; exact key q p hq hp h

/-! ## 2.  Refutation of the proposed inverse bound -/

/-- **The mission conjecture is false.**  There is no inverse-Lipschitz bound with the
supremum constant `c(δ) = log ((1-δ)/δ)` on `[δ, 1/2]`.  Witness: `δ = q = 1/4`,
`p = 1/2`, where the claim collapses to `log 27 ≤ log 16`. -/
theorem binEntropy_conjectured_lower_bound_false :
    ¬ ∀ δ p q : ℝ, 0 < δ → δ ≤ 2⁻¹ → p ∈ Icc δ 2⁻¹ → q ∈ Icc δ 2⁻¹ →
      log ((1 - δ) / δ) * |p - q| ≤ |binEntropy p - binEntropy q| := by
  intro h
  have hval := h (1/4) (1/2) (1/4) (by norm_num) (by norm_num)
    (by constructor <;> norm_num) (by constructor <;> norm_num)
  have hl4 : log (4 : ℝ) = 2 * log 2 := by
    rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; ring
  have hq : binEntropy (1/4 : ℝ) = 2 * log 2 - (3/4) * log 3 := by
    rw [Real.binEntropy, show ((1 : ℝ)/4)⁻¹ = 4 by norm_num,
      show (1 - (1 : ℝ)/4)⁻¹ = 4/3 by norm_num,
      Real.log_div (by norm_num) (by norm_num), hl4]
    ring
  have hp : binEntropy (1/2 : ℝ) = log 2 := by
    rw [show (1 : ℝ)/2 = 2⁻¹ by norm_num, Real.binEntropy_two_inv]
  have hc : log ((1 - (1/4 : ℝ)) / (1/4)) = log 3 := by norm_num
  have hlog3 : log 3 < 2 * log 2 := by
    have h34 : log (3 : ℝ) < log 4 := Real.log_lt_log (by norm_num) (by norm_num)
    linarith [hl4 ▸ h34]
  have habs : |(1 : ℝ)/2 - 1/4| = 1/4 := by rw [abs_of_nonneg] <;> norm_num
  rw [hc, hp, hq, habs] at hval
  -- `(3/4) log 3 ≥ log 2` because `27 ≥ 16`
  have h16 : log (16 : ℝ) = 4 * log 2 := by
    rw [show (16 : ℝ) = 2 ^ 4 by norm_num, Real.log_pow]; ring
  have h27 : log (27 : ℝ) = 3 * log 3 := by
    rw [show (27 : ℝ) = 3 ^ 3 by norm_num, Real.log_pow]; ring
  have hle : log (16 : ℝ) ≤ log 27 := Real.log_le_log (by norm_num) (by norm_num)
  rw [h16, h27] at hle
  rw [abs_of_nonneg (by linarith)] at hval
  linarith

/-! ## 3.  Corrected cross-population stability -/

/-- **Cross-population wall stability (corrected form).**  Two imbalances in the
*guarded* range `[0, 1/2 - η]` are controlled by the gap of their walls, with the
explicit constant `log ((1/2+η)/(1/2-η))`, which is the slope of `binEntropy` at
the guard point — not at `δ`. -/
theorem imbalance_dist_le {η p q : ℝ} (hη : 0 < η) (hη2 : η < 2⁻¹)
    (hp : p ∈ Icc (0 : ℝ) (2⁻¹ - η)) (hq : q ∈ Icc (0 : ℝ) (2⁻¹ - η)) :
    (log (2⁻¹ + η) - log (2⁻¹ - η)) * |p - q| ≤ |binEntropy p - binEntropy q| := by
  have key : ∀ a b : ℝ, a ∈ Icc (0 : ℝ) (2⁻¹ - η) → b ∈ Icc (0 : ℝ) (2⁻¹ - η) → a ≤ b →
      (log (2⁻¹ + η) - log (2⁻¹ - η)) * |a - b| ≤ |binEntropy a - binEntropy b| := by
    intro a b ha hb hab
    rcases eq_or_lt_of_le hb.1 with hb0 | hb0
    · have : a = b := le_antisymm hab (hb0 ▸ ha.1)
      simp [this]
    · have hb2 : b ≤ 2⁻¹ - η := hb.2
      have hslope : log (2⁻¹ + η) - log (2⁻¹ - η) ≤ log (1 - b) - log b := by
        have h1 : log (2⁻¹ + η) ≤ log (1 - b) := Real.log_le_log (by linarith) (by linarith)
        have h2 : log b ≤ log (2⁻¹ - η) := Real.log_le_log hb0 hb2
        linarith
      have hmvt := binEntropy_sub_ge ha.1 hab (by linarith)
      have hnn : 0 ≤ b - a := by linarith
      have h1 : (log (2⁻¹ + η) - log (2⁻¹ - η)) * (b - a) ≤ binEntropy b - binEntropy a := by
        nlinarith [hmvt, hslope, hnn]
      have h2 : 0 ≤ binEntropy b - binEntropy a := by
        have hc : 0 ≤ log (2⁻¹ + η) - log (2⁻¹ - η) := by
          have := Real.log_le_log (show (0:ℝ) < 2⁻¹ - η by linarith)
            (show (2:ℝ)⁻¹ - η ≤ 2⁻¹ + η by linarith)
          linarith
        nlinarith [h1, hc, hnn]
      rw [abs_of_nonpos (by linarith : a - b ≤ 0), abs_of_nonpos (by linarith :
        binEntropy a - binEntropy b ≤ 0)]
      linarith
  rcases le_total p q with h | h
  · exact key p q hp hq h
  · rw [abs_sub_comm, abs_sub_comm (binEntropy p)]; exact key q p hq hp h

/-- Division form: walls agreeing within `ε` force imbalances agreeing within
`ε / log ((1/2+η)/(1/2-η))`. -/
theorem imbalance_dist_le_div {η ε p q : ℝ} (hη : 0 < η) (hη2 : η < 2⁻¹)
    (hp : p ∈ Icc (0 : ℝ) (2⁻¹ - η)) (hq : q ∈ Icc (0 : ℝ) (2⁻¹ - η))
    (hε : |binEntropy p - binEntropy q| ≤ ε) :
    |p - q| ≤ ε / (log ((2⁻¹ + η) / (2⁻¹ - η))) := by
  have hden : log ((2⁻¹ + η) / (2⁻¹ - η)) = log (2⁻¹ + η) - log (2⁻¹ - η) :=
    Real.log_div (by linarith) (by linarith)
  have hpos : 0 < log (2⁻¹ + η) - log (2⁻¹ - η) := by
    have := Real.log_lt_log (show (0:ℝ) < 2⁻¹ - η by linarith)
      (show (2:ℝ)⁻¹ - η < 2⁻¹ + η by linarith)
    linarith
  rw [hden, le_div_iff₀ hpos, mul_comm]
  exact le_trans (imbalance_dist_le hη hη2 hp hq) hε

/-! ## 4.  Why the guard `η > 0` cannot be dropped: quadratic degeneracy at balance -/

/-- **Quadratic flatness at balance.**  `log 2 - binEntropy (1/2 - t) ≤ 4 t²`. -/
theorem log_two_sub_binEntropy_le_sq {t : ℝ} (ht0 : 0 ≤ t) (ht : t < 2⁻¹) :
    log 2 - binEntropy (2⁻¹ - t) ≤ 4 * t ^ 2 := by
  have h1 : (0 : ℝ) < 1 - 2 * t := by linarith
  have h2 : (0 : ℝ) < 1 + 2 * t := by linarith
  have e1 : log ((2⁻¹ - t : ℝ))⁻¹ = log 2 - log (1 - 2 * t) := by
    rw [Real.log_inv, show (2⁻¹ - t : ℝ) = (1 - 2 * t) / 2 by ring,
      Real.log_div (by linarith) (by norm_num)]
    ring
  have e2 : log ((1 - (2⁻¹ - t) : ℝ))⁻¹ = log 2 - log (1 + 2 * t) := by
    rw [Real.log_inv, show (1 - (2⁻¹ - t) : ℝ) = (1 + 2 * t) / 2 by ring,
      Real.log_div (by linarith) (by norm_num)]
    ring
  have b1 : log (1 - 2 * t) ≤ -(2 * t) := by
    have := Real.log_le_sub_one_of_pos h1; linarith
  have b2 : log (1 + 2 * t) ≤ 2 * t := by
    have := Real.log_le_sub_one_of_pos h2; linarith
  have k1 : (2⁻¹ - t) * (-(2 * t)) ≤ (2⁻¹ - t) * (- log (1 - 2 * t)) := by
    have : (0:ℝ) ≤ 2⁻¹ - t := by linarith
    nlinarith
  have k2 : (2⁻¹ + t) * (-(2 * t)) ≤ (2⁻¹ + t) * (- log (1 + 2 * t)) := by
    nlinarith [b2, ht0]
  rw [Real.binEntropy, e1, e2]
  nlinarith [k1, k2]

/-- **No uniform inversion constant near balance.**  For every candidate constant `C`
and every window width `η > 0` there are two imbalances inside
`[1/2 - η, 1/2]` whose walls are `C`-times closer than the imbalances themselves.
Hence the wall is *not* a robust sufficient statistic for the split near `1/2`:
the guarded theorem `imbalance_dist_le` is optimal in shape. -/
theorem no_uniform_inversion_constant (C η : ℝ) (hη : 0 < η) :
    ∃ p q : ℝ, p ∈ Icc (2⁻¹ - η) (2⁻¹ : ℝ) ∧ q ∈ Icc (2⁻¹ - η) (2⁻¹ : ℝ) ∧ p ≠ q ∧
      C * |binEntropy p - binEntropy q| < |p - q| := by
  set t : ℝ := min (min η 4⁻¹) (1 / (8 * (|C| + 1))) with ht
  have hCpos : (0 : ℝ) < |C| + 1 := by positivity
  have ht0 : 0 < t := by
    rw [ht]
    exact lt_min (lt_min hη (by norm_num)) (by positivity)
  have htη : t ≤ η := le_trans (min_le_left _ _) (min_le_left _ _)
  have ht4 : t ≤ 4⁻¹ := le_trans (min_le_left _ _) (min_le_right _ _)
  have htC : t ≤ 1 / (8 * (|C| + 1)) := min_le_right _ _
  refine ⟨2⁻¹ - t, 2⁻¹, ⟨by linarith, by linarith⟩, ⟨by linarith, le_refl _⟩,
    by intro h; rw [sub_eq_self] at h; linarith, ?_⟩
  have hquad : log 2 - binEntropy (2⁻¹ - t) ≤ 4 * t ^ 2 :=
    log_two_sub_binEntropy_le_sq ht0.le (by linarith)
  have hle : binEntropy (2⁻¹ - t) ≤ log 2 := by
    simpa using (Real.binEntropy_le_log_two (p := 2⁻¹ - t))
  have habs1 : |binEntropy (2⁻¹ - t) - binEntropy 2⁻¹| = log 2 - binEntropy (2⁻¹ - t) := by
    rw [Real.binEntropy_two_inv, abs_of_nonpos (by linarith)]
    ring
  have habs2 : |(2⁻¹ - t : ℝ) - 2⁻¹| = t := by
    rw [show (2⁻¹ - t : ℝ) - 2⁻¹ = -t by ring, abs_neg, abs_of_nonneg ht0.le]
  rw [habs1, habs2]
  have hstep : C * (log 2 - binEntropy (2⁻¹ - t)) ≤ |C| * (4 * t ^ 2) := by
    have h0 : 0 ≤ log 2 - binEntropy (2⁻¹ - t) := by linarith
    nlinarith [hquad, le_abs_self C, abs_nonneg C]
  have hfinal : |C| * (4 * t ^ 2) < t := by
    have h2 : |C| * (4 * t) ≤ |C| * (4 * (1 / (8 * (|C| + 1)))) := by
      nlinarith [abs_nonneg C]
    have h3 : |C| * (4 * (1 / (8 * (|C| + 1)))) < 1 := by
      rw [show |C| * (4 * (1 / (8 * (|C| + 1)))) = |C| / (2 * (|C| + 1)) by field_simp; ring,
        div_lt_one (by positivity)]
      nlinarith [abs_nonneg C]
    nlinarith [ht0, h2, h3]
  linarith

/-! ## 5.  Population layer: empirical entropy of a two-valued statistic

These are the definitions of the catalog's trace-battery entropy module,
restated so that this file is self-contained. -/

section Population

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {α : Type*}

/-- The set of readings actually attained by a statistic. -/
noncomputable def img [DecidableEq α] (f : Ω → α) : Finset α := Finset.image f Finset.univ

/-- The number of population members with a given reading. -/
noncomputable def cnt [DecidableEq α] (f : Ω → α) (a : α) : ℕ :=
  (Finset.univ.filter fun w => f w = a).card

/-- Empirical (Shannon) entropy of a statistic, in nats. -/
noncomputable def H [DecidableEq α] (f : Ω → α) : ℝ :=
  ∑ a ∈ img f, ((cnt f a : ℝ) / (Fintype.card Ω : ℝ)) *
    Real.log ((Fintype.card Ω : ℝ) / (cnt f a : ℝ))

variable [DecidableEq α]

omit [Nonempty Ω] in
lemma sum_cnt (f : Ω → α) : ∑ a ∈ img f, cnt f a = Fintype.card Ω := by
  classical
  simp only [cnt, img]
  rw [← Finset.card_univ (α := Ω)]
  exact (Finset.card_eq_sum_card_fiberwise (f := f) (s := Finset.univ)
    (t := Finset.image f Finset.univ)
    (fun x _ => Finset.mem_image_of_mem f (Finset.mem_univ x))).symm

omit [Nonempty Ω] in
lemma cnt_pos_of_mem_img {f : Ω → α} {a : α} (h : a ∈ img f) : 0 < cnt f a := by
  rw [img] at h
  obtain ⟨w, -, hw⟩ := Finset.mem_image.1 h
  rw [cnt, Finset.card_pos]
  exact ⟨w, by simp [hw]⟩

/-- **Two-valued statistics measure imbalance.**  The empirical entropy of a statistic
attaining exactly two readings is the binary entropy of the fraction in the first
class. -/
theorem H_two_values (f : Ω → α) {a b : α} (hab : a ≠ b) (himg : img f = {a, b}) :
    H f = Real.binEntropy ((cnt f a : ℝ) / (Fintype.card Ω : ℝ)) := by
  classical
  have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  have hamem : a ∈ img f := by rw [himg]; exact Finset.mem_insert_self a {b}
  have hbmem : b ∈ img f := by
    rw [himg]; exact Finset.mem_insert_of_mem (Finset.mem_singleton_self b)
  have hapos : (0 : ℝ) < cnt f a := by exact_mod_cast cnt_pos_of_mem_img hamem
  have hbpos : (0 : ℝ) < cnt f b := by exact_mod_cast cnt_pos_of_mem_img hbmem
  have hsum : (cnt f a : ℝ) + cnt f b = (Fintype.card Ω : ℝ) := by
    have h := sum_cnt f
    rw [himg, Finset.sum_pair hab] at h
    exact_mod_cast h
  have hHf : H f = ((cnt f a : ℝ) / (Fintype.card Ω : ℝ))
        * Real.log ((Fintype.card Ω : ℝ) / cnt f a)
      + ((cnt f b : ℝ) / (Fintype.card Ω : ℝ))
        * Real.log ((Fintype.card Ω : ℝ) / cnt f b) := by
    rw [H, himg, Finset.sum_pair hab]
  set p : ℝ := (cnt f a : ℝ) / (Fintype.card Ω : ℝ) with hp
  have hp0 : 0 < p := by rw [hp]; positivity
  have h1p : 1 - p = (cnt f b : ℝ) / (Fintype.card Ω : ℝ) := by
    rw [hp]; field_simp; linarith [hsum]
  have hinvp : p⁻¹ = (Fintype.card Ω : ℝ) / cnt f a := by rw [hp, inv_div]
  have hinvq : (1 - p)⁻¹ = (Fintype.card Ω : ℝ) / cnt f b := by rw [h1p, inv_div]
  rw [hHf, Real.binEntropy, hinvp, ← h1p, hinvq, h1p]

end Population

/-- **The cross-population invariant, quantitatively.**  Two binary statistics on two
*different* finite populations whose walls agree within `ε`, and whose minority
fractions are guarded away from balance by `η`, have imbalances agreeing within
`ε / log ((1/2+η)/(1/2-η))`.  This is the quantitative strengthening of
`TraceBattery.binary_wall_inversion` (the case `ε = 0`). -/
theorem binary_wall_stability {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Nonempty Ω₁] [Fintype Ω₂]
    [Nonempty Ω₂] {α₁ α₂ : Type*} [DecidableEq α₁] [DecidableEq α₂]
    (f : Ω₁ → α₁) (g : Ω₂ → α₂) {a b : α₁} {c e : α₂} {η ε : ℝ}
    (hab : a ≠ b) (hce : c ≠ e) (hf : img f = {a, b}) (hg : img g = {c, e})
    (hη : 0 < η) (hη2 : η < 2⁻¹)
    (hpf : (cnt f a : ℝ) / (Fintype.card Ω₁ : ℝ) ∈ Icc (0 : ℝ) (2⁻¹ - η))
    (hpg : (cnt g c : ℝ) / (Fintype.card Ω₂ : ℝ) ∈ Icc (0 : ℝ) (2⁻¹ - η))
    (hcap : |H f - H g| ≤ ε) :
    |(cnt f a : ℝ) / (Fintype.card Ω₁ : ℝ) - (cnt g c : ℝ) / (Fintype.card Ω₂ : ℝ)|
      ≤ ε / log ((2⁻¹ + η) / (2⁻¹ - η)) := by
  have h1 := H_two_values f hab hf
  have h2 := H_two_values g hce hg
  exact imbalance_dist_le_div hη hη2 hpf hpg (by rw [← h1, ← h2]; exact hcap)

/-! ## 6.  The reported wall `0.4677` bits as a falsifiable claim about the split -/

/-- Third-order accurate upper bound `log x ≤ (x - x⁻¹)/2` for `x ≥ 1`. -/
private lemma hasDerivAt_half_sub_inv_sub_log {y : ℝ} (hy : y ≠ 0) :
    HasDerivAt (fun z : ℝ => (z - z⁻¹) / 2 - log z) ((1 + (y ^ 2)⁻¹) / 2 - y⁻¹) y := by
  have h1 : HasDerivAt (fun z : ℝ => z - z⁻¹) (1 - -(y ^ 2)⁻¹) y :=
    (hasDerivAt_id y).sub (hasDerivAt_inv hy)
  have h2 := (h1.div_const 2).sub (Real.hasDerivAt_log hy)
  convert h2 using 1
  ring

private lemma log_le_half_sub_inv {x : ℝ} (hx : 1 ≤ x) : log x ≤ (x - x⁻¹) / 2 := by
  have hmono : MonotoneOn (fun z : ℝ => (z - z⁻¹) / 2 - log z) (Ici (1 : ℝ)) := by
    apply monotoneOn_of_deriv_nonneg (convex_Ici 1)
    · intro y hy
      simp only [mem_Ici] at hy
      exact ((hasDerivAt_half_sub_inv_sub_log
        (by linarith : y ≠ 0)).differentiableAt.continuousAt).continuousWithinAt
    · rw [interior_Ici]
      intro y hy
      simp only [mem_Ioi] at hy
      exact (hasDerivAt_half_sub_inv_sub_log
        (by linarith : y ≠ 0)).differentiableAt.differentiableWithinAt
    · rw [interior_Ici]
      intro y hy
      simp only [mem_Ioi] at hy
      have hy0 : y ≠ 0 := by intro h; rw [h] at hy; linarith
      rw [(hasDerivAt_half_sub_inv_sub_log hy0).deriv]
      have hpos : (0 : ℝ) < y := by linarith
      have key : (1 + (y ^ 2)⁻¹) / 2 - y⁻¹ = (y - 1) ^ 2 / (2 * y ^ 2) := by field_simp; ring
      rw [key]; positivity
  have h := hmono Set.self_mem_Ici (mem_Ici.2 hx) hx
  simp only [Real.log_one] at h
  norm_num at h
  linarith

/-- Third-order accurate lower bound `2(x-1)/(x+1) ≤ log x` for `x ≥ 1`. -/
private lemma hasDerivAt_log_sub_pade {y : ℝ} (hy : y ≠ 0) (hy1 : y + 1 ≠ 0) :
    HasDerivAt (fun z : ℝ => log z - 2 * (z - 1) / (z + 1)) (y⁻¹ - 4 / (y + 1) ^ 2) y := by
  have h1 : HasDerivAt (fun z : ℝ => 2 * (z - 1)) 2 y := by
    simpa using ((hasDerivAt_id y).sub_const 1).const_mul 2
  have h2 : HasDerivAt (fun z : ℝ => z + 1) 1 y := (hasDerivAt_id y).add_const 1
  have h3 := (Real.hasDerivAt_log hy).sub (h1.div h2 hy1)
  convert h3 using 1
  field_simp
  ring

private lemma two_mul_sub_div_le_log {x : ℝ} (hx : 1 ≤ x) : 2 * (x - 1) / (x + 1) ≤ log x := by
  have hmono : MonotoneOn (fun z : ℝ => log z - 2 * (z - 1) / (z + 1)) (Ici (1 : ℝ)) := by
    apply monotoneOn_of_deriv_nonneg (convex_Ici 1)
    · intro y hy
      simp only [mem_Ici] at hy
      exact ((hasDerivAt_log_sub_pade (by linarith : y ≠ 0)
        (by linarith)).differentiableAt.continuousAt).continuousWithinAt
    · rw [interior_Ici]
      intro y hy
      simp only [mem_Ioi] at hy
      exact (hasDerivAt_log_sub_pade (by linarith : y ≠ 0)
        (by linarith)).differentiableAt.differentiableWithinAt
    · rw [interior_Ici]
      intro y hy
      simp only [mem_Ioi] at hy
      have hy0 : y ≠ 0 := by intro h; rw [h] at hy; linarith
      rw [(hasDerivAt_log_sub_pade hy0 (by linarith)).deriv]
      have hpos : (0 : ℝ) < y := by linarith
      have key : y⁻¹ - 4 / (y + 1) ^ 2 = (y - 1) ^ 2 / (y * (y + 1) ^ 2) := by field_simp; ring
      rw [key]; positivity
  have h := hmono Set.self_mem_Ici (mem_Ici.2 hx) hx
  simp only [Real.log_one] at h
  norm_num at h
  linarith

private lemma log_four_thirds : log ((4 : ℝ) / 3) = 2 * log 2 - log 3 := by
  rw [Real.log_div (by norm_num) (by norm_num), show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]
  ring

private lemma log_three_gt : (1.0946 : ℝ) < log 3 := by
  have h := log_le_half_sub_inv (show (1 : ℝ) ≤ 4 / 3 by norm_num)
  rw [log_four_thirds] at h
  norm_num at h
  linarith [Real.log_two_gt_d9]

private lemma log_three_lt : log 3 < 1.101 := by
  have h := two_mul_sub_div_le_log (show (1 : ℝ) ≤ 4 / 3 by norm_num)
  rw [log_four_thirds] at h
  norm_num at h
  linarith [Real.log_two_lt_d9]

private lemma log_eleven_gt : (2.3952 : ℝ) < log 11 := by
  have h := two_mul_sub_div_le_log (show (1 : ℝ) ≤ 11 / 8 by norm_num)
  have hd : log ((11 : ℝ) / 8) = log 11 - 3 * log 2 := by
    rw [Real.log_div (by norm_num) (by norm_num), show (8 : ℝ) = 2 ^ 3 by norm_num, Real.log_pow]
    ring
  rw [hd] at h
  norm_num at h
  linarith [Real.log_two_gt_d9]

/-- The binary entropy at `1/9`, in closed form. -/
private lemma binEntropy_ninth : binEntropy (1/9 : ℝ) = 2 * log 3 - (8/3) * log 2 := by
  have hl9 : log (9 : ℝ) = 2 * log 3 := by
    rw [show (9 : ℝ) = 3 ^ 2 by norm_num, Real.log_pow]; ring
  have hl8 : log (8 : ℝ) = 3 * log 2 := by
    rw [show (8 : ℝ) = 2 ^ 3 by norm_num, Real.log_pow]; ring
  rw [Real.binEntropy, show ((1 : ℝ)/9)⁻¹ = 9 by norm_num,
    show (1 - (1 : ℝ)/9)⁻¹ = 9/8 by norm_num,
    Real.log_div (by norm_num) (by norm_num), hl9, hl8]
  ring

/-- The binary entropy at `1/12`, in closed form. -/
private lemma binEntropy_twelfth :
    binEntropy (1/12 : ℝ) = 2 * log 2 + log 3 - (11/12) * log 11 := by
  have hl12 : log (12 : ℝ) = 2 * log 2 + log 3 := by
    rw [show (12 : ℝ) = 2 ^ 2 * 3 by norm_num, Real.log_mul (by positivity) (by norm_num),
      Real.log_pow]
    ring
  rw [Real.binEntropy, show ((1 : ℝ)/12)⁻¹ = 12 by norm_num,
    show (1 - (1 : ℝ)/12)⁻¹ = 12/11 by norm_num,
    Real.log_div (by norm_num) (by norm_num), hl12]
  ring

/-- **The wall value `0.4677` bits is a falsifiable claim about the split.**
There is a unique minority fraction `p ∈ [0, 1/2]` whose binary capacity is
`0.4677` bits, and it satisfies `1/12 < p < 1/9`: the split is between 8.34% and
11.11%.  (The reported figure is 9.96%.) -/
theorem wall_imbalance_bracket :
    ∃ p : ℝ, p ∈ Ioo (1/12 : ℝ) (1/9) ∧ binEntropy p = 0.4677 * log 2 ∧
      ∀ q ∈ Icc (0 : ℝ) 2⁻¹, binEntropy q = 0.4677 * log 2 → q = p := by
  have hlow : binEntropy (1/12 : ℝ) < 0.4677 * log 2 := by
    rw [binEntropy_twelfth]
    linarith [Real.log_two_gt_d9, Real.log_two_lt_d9, log_three_lt, log_eleven_gt]
  have hhigh : 0.4677 * log 2 < binEntropy (1/9 : ℝ) := by
    rw [binEntropy_ninth]
    linarith [Real.log_two_lt_d9, log_three_gt]
  have hcont : ContinuousOn binEntropy (Icc (1/12 : ℝ) (1/9)) :=
    Real.binEntropy_continuous.continuousOn
  obtain ⟨p, hp, hpv⟩ := intermediate_value_Ioo (by norm_num : (1/12 : ℝ) ≤ 1/9) hcont
    (mem_Ioo.2 ⟨hlow, hhigh⟩)
  refine ⟨p, hp, hpv, ?_⟩
  intro q hq hqv
  have hpmem : p ∈ Icc (0 : ℝ) 2⁻¹ := ⟨by linarith [hp.1], by linarith [hp.2]⟩
  exact Real.binEntropy_strictMonoOn.injOn hq hpmem (by rw [hqv, hpv])

end WhichFactorWall