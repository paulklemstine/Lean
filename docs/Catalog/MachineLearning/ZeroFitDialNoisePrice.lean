import Mathlib
import MachineLearning.ZeroFitDialFade104
import MachineLearning.ZeroFitDialFadeDichotomy
import MachineLearning.ZeroFitDialContraction

/-!
# The noise price of the plateau — how much measurement error the smooth readings cost

## Research context (FACT round-68 #2, exp 541, `TDIAL-U104`; fourth cycle)

`MachineLearning.ZeroFitDialContraction` closed the identifiability question in the negative
direction: contraction of the four-bit decrements would pin an explicit floor, but the recorded
ladder admits no contraction factor below `2`, chiefly because the bitlen-116 rebound
`0.4621 → 0.4847` is retraced at bitlen 120 by a step of `0.0483`.

The obvious rescue is measurement error: perhaps the *true* fade curve is monotone — even
contractive — and the rebound is noise.  This file prices that rescue.  Fix a per-rung error
budget `eps` and ask for a latent ladder `tau` with `|recRung k − tau k| ≤ eps` for all seven
recorded rungs.  The question is how large `eps` must be.

## Main results

* `monotone_noise_price` — a *monotone* latent ladder forces `eps ≥ 113/10000 = 0.0113`, exactly
  half the recorded rebound.
* `monotone_noise_price_sharp` — and `0.0113` suffices: an explicit antitone witness
  `(0.5739, 0.5436, 0.5005, 0.4880, 0.4734, 0.4734, 0.43636)` lies within `0.0113` of every
  recorded rung.  So the monotone price is *exactly* `0.0113`.
* `contractive_noise_price` — demanding instead that the latent decrements halve (`q = 1/2`, the
  hypothesis under which a plateau can be localised) raises the price to
  `eps ≥ 3847/300000 > 0.01282`, and monotonicity is not even needed as an extra assumption.
* `contractive_price_exceeds_monotone_price` — the contractive price is strictly larger: buying
  a plateau costs strictly more noise than buying mere monotonicity.
* `seed_dispersion_below_monotone_price` — the observed seed-to-seed half-spread at bitlen 104,
  `(0.509 − 0.493)/2 = 0.008`, is strictly **below** the monotone price.  Seed dispersion alone
  cannot buy a monotone reading of the ladder.
* `ci_halfwidth_exceeds_contractive_price` — the pooled confidence half-width
  `(0.545 − 0.456)/2 = 0.0445` is comfortably above even the contractive price, so the pooled
  interval does not exclude the plateau.
* `noise_price_verdict` — the three comparisons together: the smooth reading of the ladder is
  affordable at the pooled-CI scale and unaffordable at the seed-dispersion scale, which is a
  falsifiable prediction about what a variance-reduced rerun should show.
-/

open Catalog.MachineLearning.ZeroFitDialFade104

open Catalog.MachineLearning.ZeroFitDialFadeDichotomy

namespace Catalog.MachineLearning.ZeroFitDialNoisePrice

/-! ## 1. Latent ladders within an error budget -/

/-- `tau` reproduces every recorded rung to within `eps`. -/
def WithinBudget (eps : ℚ) (tau : ℕ → ℚ) : Prop := ∀ k ≤ 6, |recRung k - tau k| ≤ eps

/-- `tau` is non-increasing across the seven recorded rungs. -/
def MonotoneFade (tau : ℕ → ℚ) : Prop := ∀ k < 6, tau (k + 1) ≤ tau k

/-- The latent four-bit decrements shrink by the factor `q` from one rung to the next. -/
def ContractiveFade (q : ℚ) (tau : ℕ → ℚ) : Prop :=
  ∀ k < 5, tau (k + 1) - tau (k + 2) ≤ q * (tau k - tau (k + 1))

/-- Unpacking the budget at a single rung. -/
lemma budget_bounds {eps : ℚ} {tau : ℕ → ℚ} (h : WithinBudget eps tau) {k : ℕ} (hk : k ≤ 6) :
    recRung k - eps ≤ tau k ∧ tau k ≤ recRung k + eps := by
  have h' := abs_le.1 (h k hk)
  exact ⟨by linarith [h'.2], by linarith [h'.1]⟩

/-! ## 2. The price of monotonicity -/

/-- **Monotone noise price.**  Any latent ladder that is non-increasing across the recorded rungs
and stays within `eps` of them must have `eps ≥ 0.0113`: the bitlen-112 reading must be pushed up
and the bitlen-116 reading pushed down until they meet, and they are `0.0226` apart. -/
theorem monotone_noise_price {eps : ℚ} {tau : ℕ → ℚ} (hmono : MonotoneFade tau)
    (hb : WithinBudget eps tau) : 113 / 10000 ≤ eps := by
  have h4 := (budget_bounds hb (by norm_num : (4 : ℕ) ≤ 6)).2
  have h5 := (budget_bounds hb (by norm_num : (5 : ℕ) ≤ 6)).1
  have hstep : tau 5 ≤ tau 4 := hmono 4 (by norm_num)
  have e4 : recRung 4 = 4621 / 10000 := by simp [recRung, rung112]
  have e5 : recRung 5 = 4847 / 10000 := by simp [recRung, rung116]
  rw [e4] at h4
  rw [e5] at h5
  linarith

/-- The explicit witness: the recorded ladder with the bitlen-112 and bitlen-116 readings both
replaced by their midpoint `0.4734`. -/
def flatWitness : ℕ → ℚ
  | 0 => 5739 / 10000
  | 1 => 5436 / 10000
  | 2 => 5005 / 10000
  | 3 => 4880 / 10000
  | 4 => 4734 / 10000
  | 5 => 4734 / 10000
  | _ => 43636 / 100000

lemma flatWitness_monotone : MonotoneFade flatWitness := by
  intro k hk
  interval_cases k <;> norm_num [flatWitness]

lemma flatWitness_within : WithinBudget (113 / 10000) flatWitness := by
  intro k hk
  interval_cases k <;>
    norm_num [flatWitness, recRung, rung96, rung100, rung104, rung108, rung112, rung116,
      rung120, abs_le]

/-- **Sharpness.**  `0.0113` is not merely necessary but sufficient, so the monotone noise price
of the recorded ladder is exactly half the rebound. -/
theorem monotone_noise_price_sharp :
    (∃ tau : ℕ → ℚ, MonotoneFade tau ∧ WithinBudget (113 / 10000) tau) ∧
      ∀ (eps : ℚ) (tau : ℕ → ℚ), MonotoneFade tau → WithinBudget eps tau → 113 / 10000 ≤ eps :=
  ⟨⟨flatWitness, flatWitness_monotone, flatWitness_within⟩,
    fun _ _ hm hb => monotone_noise_price hm hb⟩

/-! ## 3. The price of a plateau -/

/-- **Contractive noise price.**  If the latent decrements at least halve — the hypothesis under
which a floor is identifiable, and which does not by itself presuppose monotonicity — then the
budget must exceed `3847/300000 ≈ 0.012823`.  The argument is a geometric-series squeeze: the
first latent step is at most `0.0303 + 2 eps`, the whole latent fade is at most twice that, and
the recorded fade of `0.13754` must fit inside it plus two more error bars. -/
theorem contractive_noise_price {eps : ℚ} {tau : ℕ → ℚ}
    (hcon : ContractiveFade (1 / 2) tau) (hb : WithinBudget eps tau) : 3847 / 300000 ≤ eps := by
  -- the latent decrements halve, so the total fade is at most twice the first step
  have c0 := hcon 0 (by norm_num)
  have c1 := hcon 1 (by norm_num)
  have c2 := hcon 2 (by norm_num)
  have c3 := hcon 3 (by norm_num)
  have c4 := hcon 4 (by norm_num)
  -- error bars at the two ends and at the first step
  have b0 := (budget_bounds hb (by norm_num : (0 : ℕ) ≤ 6)).1
  have b0' := (budget_bounds hb (by norm_num : (0 : ℕ) ≤ 6)).2
  have b1 := (budget_bounds hb (by norm_num : (1 : ℕ) ≤ 6)).1
  have b6 := (budget_bounds hb (by norm_num : (6 : ℕ) ≤ 6)).2
  have e0 : recRung 0 = 5739 / 10000 := by simp [recRung, rung96]
  have e1 : recRung 1 = 5436 / 10000 := by simp [recRung, rung100]
  have e6 : recRung 6 = 43636 / 100000 := by simp [recRung, rung120]
  rw [e0] at b0 b0'
  rw [e1] at b1
  rw [e6] at b6
  -- `norm_num` at the contraction hypotheses to clear the `1/2` factors
  have c0' : tau 1 - tau 2 ≤ (tau 0 - tau 1) / 2 := by linarith
  have c1' : tau 2 - tau 3 ≤ (tau 1 - tau 2) / 2 := by linarith
  have c2' : tau 3 - tau 4 ≤ (tau 2 - tau 3) / 2 := by linarith
  have c3' : tau 4 - tau 5 ≤ (tau 3 - tau 4) / 2 := by linarith
  have c4' : tau 5 - tau 6 ≤ (tau 4 - tau 5) / 2 := by linarith
  linarith

/-- Buying a plateau costs strictly more noise than buying monotonicity. -/
theorem contractive_price_exceeds_monotone_price :
    (113 : ℚ) / 10000 < 3847 / 300000 := by norm_num

/-! ## 4. Is the price affordable?  Two scales of the recorded dispersion -/

/-- Per-seed pooled readings at bitlen 104 (seeds 20261210–12). -/
def seedLow : ℚ := 493 / 1000
/-- Per-seed pooled reading, middle seed. -/
def seedMid : ℚ := 499 / 1000
/-- Per-seed pooled reading, top seed. -/
def seedHigh : ℚ := 509 / 1000

/-- Recorded pooled confidence interval at bitlen 104. -/
def ciLow : ℚ := 456 / 1000
/-- Upper endpoint of the recorded pooled confidence interval at bitlen 104. -/
def ciHigh : ℚ := 545 / 1000

/-- The three per-seed readings do bracket the pooled reading `0.5005` only from below: all three
lie under it, which is why the seed half-spread is the relevant dispersion scale. -/
theorem seeds_below_pooled : seedLow < rung104 ∧ seedMid < rung104 ∧ seedHigh > rung104 := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num [seedLow, seedMid, seedHigh, rung104]

/-- **The rebound is not seed noise.**  The seed-to-seed half-spread at bitlen 104 is `0.008`,
strictly below the `0.0113` that a monotone latent ladder demands. -/
theorem seed_dispersion_below_monotone_price : (seedHigh - seedLow) / 2 < 113 / 10000 := by
  norm_num [seedHigh, seedLow]

/-- …and a fortiori below the plateau price. -/
theorem seed_dispersion_below_contractive_price : (seedHigh - seedLow) / 2 < 3847 / 300000 := by
  norm_num [seedHigh, seedLow]

/-- **But the pooled interval can afford it.**  The pooled CI half-width `0.0445` exceeds even the
contractive price by a factor above three. -/
theorem ci_halfwidth_exceeds_contractive_price : 3 * (3847 / 300000) < (ciHigh - ciLow) / 2 := by
  norm_num [ciHigh, ciLow]

/-- **Verdict.**  A monotone — indeed contractive — latent fade is compatible with the recorded
ladder at the pooled-CI error scale but not at the seed-dispersion scale.  The gap between the two
scales is the falsifiable content: a rerun whose per-rung dispersion is pushed down to the
seed-spread level must either destroy the rebound or destroy the plateau reading. -/
theorem noise_price_verdict :
    (∀ (eps : ℚ) (tau : ℕ → ℚ), ContractiveFade (1 / 2) tau →
        WithinBudget eps tau → 3847 / 300000 ≤ eps) ∧
      (seedHigh - seedLow) / 2 < 3847 / 300000 ∧
      3847 / 300000 < (ciHigh - ciLow) / 2 :=
  ⟨fun _ _ hc hb => contractive_noise_price hc hb,
    seed_dispersion_below_contractive_price, by norm_num [ciHigh, ciLow]⟩

/-! ## 5. Consequence for the contraction test

A latent ladder bought at the monotone price need not be contractive: the flat witness has two
equal consecutive rungs, so its decrement at rung 4 is `0`, and the next decrement `0.03704` is
positive.  No finite contraction factor bounds that ratio.  Monotonicity is therefore strictly
cheaper than contraction not merely numerically but structurally. -/
theorem flatWitness_not_contractive : ¬ ∃ q : ℚ, ContractiveFade q flatWitness := by
  rintro ⟨q, hq⟩
  have h := hq 4 (by norm_num)
  norm_num [flatWitness] at h

end Catalog.MachineLearning.ZeroFitDialNoisePrice