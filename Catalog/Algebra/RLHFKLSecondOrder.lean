import Algebra.RLHFMeanAbsoluteDeviation

/-!
# The exact second-order KL drift constant is `Var/2`

Domain: Algebra (convex analysis × information theory × alignment theory).

The catalogue's `RLHF.kl_gibbs_le_variance` bounds the alignment KL drift by
`e^{range r/β} Var_p(r)/β²`, i.e. by `Var_p(r)/β²` with an absolute constant `1` in the
large-`β` limit.  The cumulant heuristic predicts that the true constant is `1/2` — the
second cumulant of the tilted family — and this file proves it, quantitatively.

* `RLHF.klDiv_gibbs_eq_centred` — the exact identity
  `KL(π_β‖p) = A_β/W_β − log W_β` with `W_β = 𝔼_p e^{(r−𝔼r)/β}` the centred partition
  function and `A_β = 𝔼_p[e^{(r−𝔼r)/β}·(r−𝔼r)/β]`;
* `RLHF.abs_kl_sub_half_variance` — `|KL(π_β‖p) − Var_p(r)/(2β²)| ≤
  2·range(r)·Var_p(r)/β³ + 3·Var_p(r)²/β⁴` whenever `β ≥ range r`;
* `RLHF.kl_tendsto_half_variance` — hence `β²·KL(π_β‖p) → Var_p(r)/2`.

So the KL drift law is exactly `Var_p(r)/(2β²)`: the variance functional of C1 is
correct for KL (unlike the `ℓ¹` law, whose sharp functional is the mean absolute
deviation, see `Algebra.RLHFMeanAbsoluteDeviation`), and the absolute constant is `1/2`,
half of what the catalogue bound gives.

Combining with Pinsker, `‖π_β − p‖₁ ≤ √(2 KL) ≈ σ_p(r)/β`, which is exactly the
standard-deviation law of C1 — and `RLHF.mad_le_sqrt_variance` shows the true `ℓ¹`
constant `MAD_p(r)` is never larger.  The Pinsker step is therefore the *only* source of
looseness in the σ-law, and its defect is precisely the deviation defect
`σ_p(r) − MAD_p(r)`.

All error terms are third-order Taylor remainders, handled by `Real.exp_bound`.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. Centred moment sums -/

omit [Nonempty Ω] in
theorem sum_ctr_div {β : ℝ} {r p : Ω → ℝ} (hp : IsDist p) :
    ∑ y, p y * ((r y - mean p r) / β) = 0 := by
  have h : ∀ y, p y * ((r y - mean p r) / β) = (1 / β) * (p y * (r y - mean p r)) :=
    fun y => by ring
  rw [Finset.sum_congr rfl fun y _ => h y, ← Finset.mul_sum, sum_centered hp r, mul_zero]

omit [Nonempty Ω] in
theorem sum_ctr_sq_div {β : ℝ} {r p : Ω → ℝ} :
    ∑ y, p y * ((r y - mean p r) / β) ^ 2 = variance p r / β ^ 2 := by
  have h : ∀ y, p y * ((r y - mean p r) / β) ^ 2
      = (1 / β ^ 2) * (p y * (r y - mean p r) ^ 2) := fun y => by ring
  rw [Finset.sum_congr rfl fun y _ => h y, ← Finset.mul_sum]
  simp only [variance]
  ring

/-- The third absolute moment of the centred, scaled reward is at most
`range(r)·Var_p(r)/β³`. -/
theorem sum_ctr_cube_le {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsDist p) :
    ∑ y, p y * |(r y - mean p r) / β| ^ 3 ≤ rewardRange r * variance p r / β ^ 3 := by
  have hle : ∀ y ∈ (univ : Finset Ω), p y * |(r y - mean p r) / β| ^ 3
      ≤ (rewardRange r / β) * (p y * ((r y - mean p r) / β) ^ 2) := by
    intro y _
    have habs : |(r y - mean p r) / β| ≤ rewardRange r / β := by
      rw [abs_div, abs_of_pos hβ]
      exact (div_le_div_iff_of_pos_right hβ).mpr (abs_sub_mean_le_range hp y)
    have hcube : |(r y - mean p r) / β| ^ 3
        = |(r y - mean p r) / β| * ((r y - mean p r) / β) ^ 2 := by
      rw [show (3 : ℕ) = 1 + 2 by norm_num, pow_add, pow_one, sq_abs]
    rw [hcube]
    have h2 : |(r y - mean p r) / β| * ((r y - mean p r) / β) ^ 2
        ≤ (rewardRange r / β) * ((r y - mean p r) / β) ^ 2 :=
      mul_le_mul_of_nonneg_right habs (sq_nonneg _)
    calc p y * (|(r y - mean p r) / β| * ((r y - mean p r) / β) ^ 2)
        ≤ p y * ((rewardRange r / β) * ((r y - mean p r) / β) ^ 2) :=
          mul_le_mul_of_nonneg_left h2 (hp.nonneg y)
      _ = (rewardRange r / β) * (p y * ((r y - mean p r) / β) ^ 2) := by ring
  refine le_trans (Finset.sum_le_sum hle) ?_
  rw [← Finset.mul_sum, sum_ctr_sq_div, div_mul_div_comm, ← pow_succ']

/-! ## 2. The centred first moment of the tilt -/

/-- `A_β = 𝔼_p[e^{(r−𝔼r)/β} · (r−𝔼r)/β]`, the centred first moment of the tilted
reward.  It is the numerator of the exact KL identity. -/
noncomputable def tiltMoment (β : ℝ) (r p : Ω → ℝ) : ℝ :=
  ∑ y, p y * (Real.exp ((r y - mean p r) / β) * ((r y - mean p r) / β))

omit [Nonempty Ω] in
/-- `A_β ≥ 0`: the tilt is positively correlated with the reward.  (Termwise this is
false; the proof uses the vanishing of the centred first moment.) -/
theorem tiltMoment_nonneg {β : ℝ} {r p : Ω → ℝ} (hp : IsDist p) : 0 ≤ tiltMoment β r p := by
  have heq : tiltMoment β r p
      = ∑ y, p y * ((Real.exp ((r y - mean p r) / β) - 1) * ((r y - mean p r) / β)) := by
    have h : ∀ y, p y * ((Real.exp ((r y - mean p r) / β) - 1) * ((r y - mean p r) / β))
        = p y * (Real.exp ((r y - mean p r) / β) * ((r y - mean p r) / β))
          - p y * ((r y - mean p r) / β) := fun y => by ring
    rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_sub_distrib, sum_ctr_div hp]
    simp only [tiltMoment]
    ring
  rw [heq]
  refine Finset.sum_nonneg fun y _ => mul_nonneg (hp.nonneg y) ?_
  set s := (r y - mean p r) / β with hs
  rcases le_total 0 s with hpos | hneg
  · have h1 : 1 ≤ Real.exp s := Real.one_le_exp hpos
    nlinarith
  · have h1 : Real.exp s ≤ 1 := Real.exp_le_one_iff.2 hneg
    nlinarith

/-- Second-order expansion of `A_β`: it is `Var/β²` up to a third-order remainder. -/
theorem abs_tiltMoment_sub {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsDist p)
    (hr : rewardRange r ≤ β) :
    |tiltMoment β r p - variance p r / β ^ 2| ≤ rewardRange r * variance p r / β ^ 3 := by
  have hsmall : ∀ y, |(r y - mean p r) / β| ≤ 1 := by
    intro y
    rw [abs_div, abs_of_pos hβ, div_le_one hβ]
    exact le_trans (abs_sub_mean_le_range hp y) hr
  have hsplit : tiltMoment β r p - variance p r / β ^ 2
      = ∑ y, p y * (Real.exp ((r y - mean p r) / β) * ((r y - mean p r) / β)
          - ((r y - mean p r) / β) - ((r y - mean p r) / β) ^ 2) := by
    have h : ∀ y, p y * (Real.exp ((r y - mean p r) / β) * ((r y - mean p r) / β)
          - ((r y - mean p r) / β) - ((r y - mean p r) / β) ^ 2)
        = p y * (Real.exp ((r y - mean p r) / β) * ((r y - mean p r) / β))
          - p y * ((r y - mean p r) / β) - p y * ((r y - mean p r) / β) ^ 2 :=
      fun y => by ring
    rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_sub_distrib, Finset.sum_sub_distrib,
      sum_ctr_div hp, sum_ctr_sq_div]
    simp only [tiltMoment]
    ring
  rw [hsplit]
  refine le_trans (Finset.abs_sum_le_sum_abs _ _) ?_
  have hterm : ∀ y ∈ (univ : Finset Ω),
      |p y * (Real.exp ((r y - mean p r) / β) * ((r y - mean p r) / β)
        - ((r y - mean p r) / β) - ((r y - mean p r) / β) ^ 2)|
      ≤ p y * |(r y - mean p r) / β| ^ 3 := by
    intro y _
    set s := (r y - mean p r) / β with hs
    have htaylor : |Real.exp s - 1 - s| ≤ s ^ 2 := Real.abs_exp_sub_one_sub_id_le (hsmall y)
    have hfact : Real.exp s * s - s - s ^ 2 = (Real.exp s - 1 - s) * s := by ring
    have hb : |Real.exp s * s - s - s ^ 2| ≤ |s| ^ 3 := by
      rw [hfact, abs_mul]
      calc |Real.exp s - 1 - s| * |s| ≤ s ^ 2 * |s| :=
            mul_le_mul_of_nonneg_right htaylor (abs_nonneg s)
        _ = |s| ^ 3 := by rw [← sq_abs s]; ring
    rw [abs_mul, abs_of_nonneg (hp.nonneg y)]
    exact mul_le_mul_of_nonneg_left hb (hp.nonneg y)
  exact le_trans (Finset.sum_le_sum hterm) (sum_ctr_cube_le hβ hp)

/-- Second-order expansion of the centred partition function:
`W_β = 1 + Var/(2β²)` up to a third-order remainder. -/
theorem abs_tiltNorm_sub_quad {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsDist p)
    (hr : rewardRange r ≤ β) :
    |tiltNorm β r p - 1 - variance p r / β ^ 2 / 2|
      ≤ rewardRange r * variance p r / β ^ 3 := by
  have hsmall : ∀ y, |(r y - mean p r) / β| ≤ 1 := by
    intro y
    rw [abs_div, abs_of_pos hβ, div_le_one hβ]
    exact le_trans (abs_sub_mean_le_range hp y) hr
  have hsplit : tiltNorm β r p - 1 - variance p r / β ^ 2 / 2
      = ∑ y, p y * (Real.exp ((r y - mean p r) / β) - 1 - ((r y - mean p r) / β)
          - ((r y - mean p r) / β) ^ 2 / 2) := by
    have h : ∀ y, p y * (Real.exp ((r y - mean p r) / β) - 1 - ((r y - mean p r) / β)
          - ((r y - mean p r) / β) ^ 2 / 2)
        = p y * Real.exp ((r y - mean p r) / β) - p y - p y * ((r y - mean p r) / β)
          - (1 / 2) * (p y * ((r y - mean p r) / β) ^ 2) := fun y => by ring
    rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_sub_distrib, Finset.sum_sub_distrib,
      Finset.sum_sub_distrib, ← Finset.mul_sum, sum_ctr_div hp, sum_ctr_sq_div, hp.total]
    simp only [tiltNorm]
    ring
  rw [hsplit]
  refine le_trans (Finset.abs_sum_le_sum_abs _ _) ?_
  have hterm : ∀ y ∈ (univ : Finset Ω),
      |p y * (Real.exp ((r y - mean p r) / β) - 1 - ((r y - mean p r) / β)
        - ((r y - mean p r) / β) ^ 2 / 2)|
      ≤ p y * |(r y - mean p r) / β| ^ 3 := by
    intro y _
    set s := (r y - mean p r) / β with hs
    have hb0 := Real.exp_bound (x := s) (hsmall y) (n := 3) (by norm_num)
    have hsum3 : ∑ m ∈ Finset.range 3, s ^ m / (Nat.factorial m : ℝ)
        = 1 + s + s ^ 2 / 2 := by
      simp [Finset.sum_range_succ, Nat.factorial]
    rw [hsum3] at hb0
    have hb : |Real.exp s - 1 - s - s ^ 2 / 2| ≤ |s| ^ 3 := by
      have hrew : Real.exp s - (1 + s + s ^ 2 / 2) = Real.exp s - 1 - s - s ^ 2 / 2 := by ring
      rw [hrew] at hb0
      refine le_trans hb0 ?_
      have h1 : (0:ℝ) ≤ |s| ^ 3 := by positivity
      have h2 : ((Nat.succ 3 : ℕ) : ℝ) / ((Nat.factorial 3 : ℝ) * ((3 : ℕ) : ℝ)) ≤ 1 := by
        norm_num [Nat.factorial]
      nlinarith [h1, h2]
    rw [abs_mul, abs_of_nonneg (hp.nonneg y)]
    exact mul_le_mul_of_nonneg_left hb (hp.nonneg y)
  exact le_trans (Finset.sum_le_sum hterm) (sum_ctr_cube_le hβ hp)

/-! ## 3. The exact KL identity and its second-order expansion -/

/-- **Exact centred form of the alignment KL drift**:
`KL(π_β ‖ p) = A_β / W_β − log W_β`. -/
theorem klDiv_gibbs_eq_centred {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) :
    klDiv (gibbsPolicy β r p) p
      = tiltMoment β r p / tiltNorm β r p - Real.log (tiltNorm β r p) := by
  have hW := tiltNorm_pos (β := β) (r := r) hp
  have hWne : tiltNorm β r p ≠ 0 := ne_of_gt hW
  have key : ∀ y, gibbsPolicy β r p y * Real.log (gibbsPolicy β r p y / p y)
      = (1 / tiltNorm β r p)
          * (p y * (Real.exp ((r y - mean p r) / β) * ((r y - mean p r) / β)))
        - (Real.log (tiltNorm β r p) / tiltNorm β r p)
          * (p y * Real.exp ((r y - mean p r) / β)) := by
    intro y
    have hq : gibbsPolicy β r p y
        = p y * Real.exp ((r y - mean p r) / β) / tiltNorm β r p := gibbsPolicy_eq_centred y
    have hpy : p y ≠ 0 := ne_of_gt (hp.pos y)
    have hratio : gibbsPolicy β r p y / p y
        = Real.exp ((r y - mean p r) / β) / tiltNorm β r p := by
      rw [hq]; field_simp
    rw [hratio, hq, Real.log_div (ne_of_gt (Real.exp_pos _)) hWne, Real.log_exp]
    field_simp
  rw [klDiv, Finset.sum_congr rfl fun y _ => key y, Finset.sum_sub_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum]
  show (1 / tiltNorm β r p) * tiltMoment β r p
      - (Real.log (tiltNorm β r p) / tiltNorm β r p) * tiltNorm β r p
      = tiltMoment β r p / tiltNorm β r p - Real.log (tiltNorm β r p)
  field_simp

/-- **The exact second-order KL drift law.**  For any temperature above the reward
range,
`|KL(π_β‖p) − Var_p(r)/(2β²)| ≤ 2·range(r)·Var_p(r)/β³ + 3·Var_p(r)²/β⁴`.
In particular the absolute constant of the KL drift law is `1/2`, not `1`. -/
theorem abs_kl_sub_half_variance {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hr : rewardRange r ≤ β) :
    |klDiv (gibbsPolicy β r p) p - variance p r / β ^ 2 / 2|
      ≤ 2 * (rewardRange r * variance p r / β ^ 3) + 3 * (variance p r ^ 2 / β ^ 4) := by
  have hd := hp.isDist
  have hW := tiltNorm_pos (β := β) (r := r) hp
  have hW1 := one_le_tiltNorm (β := β) (r := r) hd
  have hW2 := tiltNorm_le (β := β) (r := r) hβ hd hr
  have hV : 0 ≤ variance p r := variance_nonneg hd r
  have hU : 0 ≤ rewardRange r := rewardRange_nonneg r
  have hVb : 0 ≤ variance p r / β ^ 2 := by positivity
  have hUV : 0 ≤ rewardRange r * variance p r / β ^ 3 := by positivity
  have hA0 : 0 ≤ tiltMoment β r p := tiltMoment_nonneg hd
  have hA := abs_le.1 (abs_tiltMoment_sub hβ hd hr)
  have hWq := abs_le.1 (abs_tiltNorm_sub_quad hβ hd hr)
  have hw0 : 0 ≤ tiltNorm β r p - 1 := by linarith
  -- the logarithm is within `(W-1)²` of `W-1`
  have hlogu : Real.log (tiltNorm β r p) ≤ tiltNorm β r p - 1 :=
    Real.log_le_sub_one_of_pos hW
  have hlogl : tiltNorm β r p - 1 - (tiltNorm β r p - 1) ^ 2 ≤ Real.log (tiltNorm β r p) := by
    have h1 : Real.log (1 / tiltNorm β r p) ≤ 1 / tiltNorm β r p - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    have h2 : Real.log (1 / tiltNorm β r p) = -Real.log (tiltNorm β r p) := by
      rw [one_div, Real.log_inv]
    rw [h2] at h1
    have h3 : 1 - 1 / tiltNorm β r p ≤ Real.log (tiltNorm β r p) := by linarith
    have hid : (1 - 1 / tiltNorm β r p) - (tiltNorm β r p - 1 - (tiltNorm β r p - 1) ^ 2)
        = (tiltNorm β r p - 1) ^ 3 / tiltNorm β r p := by
      field_simp
      ring
    have hnn : 0 ≤ (tiltNorm β r p - 1) ^ 3 / tiltNorm β r p :=
      div_nonneg (pow_nonneg hw0 3) hW.le
    linarith
  -- the quotient `A/W` is within `A (W-1)` of `A`
  have hquot : |tiltMoment β r p / tiltNorm β r p - tiltMoment β r p|
      ≤ tiltMoment β r p * (tiltNorm β r p - 1) := by
    have heq : tiltMoment β r p / tiltNorm β r p - tiltMoment β r p
        = -(tiltMoment β r p * (tiltNorm β r p - 1) / tiltNorm β r p) := by
      field_simp
      ring
    have hnn : (0:ℝ) ≤ tiltMoment β r p * (tiltNorm β r p - 1) / tiltNorm β r p :=
      div_nonneg (mul_nonneg hA0 hw0) hW.le
    rw [heq, abs_neg, abs_of_nonneg hnn, div_le_iff₀ hW]
    nlinarith [mul_nonneg hA0 hw0]
  have hAle : tiltMoment β r p ≤ 2 * (variance p r / β ^ 2) := by
    have hUVle : rewardRange r * variance p r / β ^ 3 ≤ variance p r / β ^ 2 := by
      rw [div_le_div_iff₀ (by positivity) (by positivity)]
      nlinarith [mul_nonneg hV (pow_nonneg hβ.le 2), pow_pos hβ 2, pow_pos hβ 3]
    linarith [hA.2]
  have hquot2 : |tiltMoment β r p / tiltNorm β r p - tiltMoment β r p|
      ≤ 2 * (variance p r ^ 2 / β ^ 4) := by
    refine le_trans hquot ?_
    have h1 : tiltNorm β r p - 1 ≤ variance p r / β ^ 2 := by linarith
    have h2 : tiltMoment β r p * (tiltNorm β r p - 1)
        ≤ (2 * (variance p r / β ^ 2)) * (variance p r / β ^ 2) :=
      mul_le_mul hAle h1 hw0 (by positivity)
    refine le_trans h2 (le_of_eq ?_)
    field_simp
  have hlogsq : (tiltNorm β r p - 1) ^ 2 ≤ variance p r ^ 2 / β ^ 4 := by
    have h1 : tiltNorm β r p - 1 ≤ variance p r / β ^ 2 := by linarith
    calc (tiltNorm β r p - 1) ^ 2 ≤ (variance p r / β ^ 2) ^ 2 := by nlinarith
      _ = variance p r ^ 2 / β ^ 4 := by
          rw [div_pow]
          ring
  rw [klDiv_gibbs_eq_centred hp, abs_le]
  have habs := abs_le.1 hquot2
  constructor
  · linarith [hA.1, hWq.2, habs.1]
  · linarith [hA.2, hWq.1, habs.2]

/-- **The KL alignment drift is exactly `Var_p(r)/(2β²)`.**
`β²·KL(π_β‖p) → Var_p(r)/2` as the KL temperature `β → ∞`, confirming the cumulant
prediction and halving the constant of `RLHF.kl_gibbs_le_variance`. -/
theorem kl_tendsto_half_variance {r p : Ω → ℝ} (hp : IsPosDist p) :
    Filter.Tendsto (fun β : ℝ => β ^ 2 * klDiv (gibbsPolicy β r p) p) Filter.atTop
      (nhds (variance p r / 2)) := by
  have hinv : Filter.Tendsto (fun β : ℝ => (1 : ℝ) / β) Filter.atTop (nhds 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds Filter.tendsto_id
  have herr : Filter.Tendsto
      (fun β : ℝ => 2 * (rewardRange r * variance p r) * (1 / β)
        + 3 * variance p r ^ 2 * ((1 / β) * (1 / β))) Filter.atTop (nhds 0) := by
    have h1 : Filter.Tendsto (fun β : ℝ => 2 * (rewardRange r * variance p r) * (1 / β))
        Filter.atTop (nhds 0) := by
      simpa using hinv.const_mul (2 * (rewardRange r * variance p r))
    have h2 : Filter.Tendsto (fun β : ℝ => 3 * variance p r ^ 2 * ((1 / β) * (1 / β)))
        Filter.atTop (nhds 0) := by
      simpa using (hinv.mul hinv).const_mul (3 * variance p r ^ 2)
    simpa using h1.add h2
  have hlow : Filter.Tendsto
      (fun β : ℝ => variance p r / 2 - (2 * (rewardRange r * variance p r) * (1 / β)
        + 3 * variance p r ^ 2 * ((1 / β) * (1 / β)))) Filter.atTop
      (nhds (variance p r / 2)) := by
    simpa using tendsto_const_nhds.sub herr
  have hhigh : Filter.Tendsto
      (fun β : ℝ => variance p r / 2 + (2 * (rewardRange r * variance p r) * (1 / β)
        + 3 * variance p r ^ 2 * ((1 / β) * (1 / β)))) Filter.atTop
      (nhds (variance p r / 2)) := by
    simpa using tendsto_const_nhds.add herr
  have hsandwich : ∀ β : ℝ, max (rewardRange r) 1 ≤ β →
      |β ^ 2 * klDiv (gibbsPolicy β r p) p - variance p r / 2|
        ≤ 2 * (rewardRange r * variance p r) * (1 / β)
          + 3 * variance p r ^ 2 * ((1 / β) * (1 / β)) := by
    intro β hβm
    have hβ : 0 < β := lt_of_lt_of_le zero_lt_one (le_trans (le_max_right _ _) hβm)
    have hr : rewardRange r ≤ β := le_trans (le_max_left _ _) hβm
    have hβ2 : (0:ℝ) < β ^ 2 := by positivity
    have hkey := abs_kl_sub_half_variance hβ hp hr
    have heq : β ^ 2 * (klDiv (gibbsPolicy β r p) p - variance p r / β ^ 2 / 2)
        = β ^ 2 * klDiv (gibbsPolicy β r p) p - variance p r / 2 := by
      field_simp
    have habs : |β ^ 2 * (klDiv (gibbsPolicy β r p) p - variance p r / β ^ 2 / 2)|
        = β ^ 2 * |klDiv (gibbsPolicy β r p) p - variance p r / β ^ 2 / 2| := by
      rw [abs_mul, abs_of_pos hβ2]
    rw [← heq, habs]
    refine le_trans (mul_le_mul_of_nonneg_left hkey hβ2.le) (le_of_eq ?_)
    field_simp
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hhigh ?_ ?_
  · filter_upwards [Filter.eventually_ge_atTop (max (rewardRange r) 1)] with β hβm
    linarith [(abs_le.1 (hsandwich β hβm)).1]
  · filter_upwards [Filter.eventually_ge_atTop (max (rewardRange r) 1)] with β hβm
    linarith [(abs_le.1 (hsandwich β hβm)).2]

end RLHF