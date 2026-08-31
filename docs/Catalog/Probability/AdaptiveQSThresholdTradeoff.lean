/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The threshold trade-off: throughput rises, total yield falls

Fourth cycle on experiment 559.  The previous cycles establish that skipping by a
concordant dial never lowers the throughput.  A referee's objection follows at once:
if skipping always helps, why did the deployment stop at `θ = q20` (`28.3%` of the work
skipped) instead of skipping everything but the single best target?

This file proves the exact boundary, and it is a genuine two-sided trade-off.

* `throughput_mono_threshold` — raising the threshold **never lowers** throughput.  The
  throughput objective is monotone in `θ`, so on throughput alone the optimum is
  degenerate: keep only the best target.
* `keptYield_antitone_threshold` — raising the threshold **never raises** the total
  yield, and `keptYield_lt_of_skips_live_target` makes the loss strict as soon as the
  threshold defers a target of positive rate.

So the flip is correct exactly when *work*, not relations, is the binding constraint;
when a relation quota must be met, `θ` is bounded by the quota
(`threshold_admissible_of_quota`).  This is the honest form of the "`+28.9%`
throughput at `89.5%` retention" claim: the two numbers move in opposite directions
by theorem, and the operating point is the choice of which constraint binds.

Two sharpness statements complete the allocation picture of the first cycle:

* `concentrator_attains_oracle_bound` — the oracle bound `B · max r` is attained, so it
  is the exact supremum of the achievable yield and the measured `+74.8%` headroom is
  not an artefact of a loose bound.
* `oracle_ratio_le_card` — that headroom is at most a factor `|s|` above the uniform
  baseline: the unclaimed gain is bounded by the number of targets, whatever the rate
  spread.
-/
import Mathlib
import Probability.AdaptiveQSAllocation
import Probability.AdaptiveQSSkipFlip

namespace Probability.AdaptiveQS

open Finset

variable {ι : Type*} [DecidableEq ι]

/-! ## Threshold monotonicity -/

omit [DecidableEq ι] in
/-- Concordance is inherited by subsets of targets. -/
theorem Concordant.subset {s t : Finset ι} {d r : ι → ℝ} (hts : t ⊆ s)
    (hc : Concordant s d r) : Concordant t d r :=
  fun i hi j hj hlt => hc i (hts hi) j (hts hj) hlt

omit [DecidableEq ι] in
/-- A higher threshold keeps fewer targets. -/
theorem keepSet_subset_keepSet {s : Finset ι} {d : ι → ℝ} {θ₁ θ₂ : ℝ} (h : θ₁ ≤ θ₂) :
    keepSet s d θ₂ ⊆ keepSet s d θ₁ := by
  intro i hi
  rw [keepSet, Finset.mem_filter] at hi ⊢
  exact ⟨hi.1, le_trans h hi.2⟩

omit [DecidableEq ι] in
/-- Thresholding twice is thresholding once, at the larger threshold. -/
theorem keepSet_keepSet {s : Finset ι} {d : ι → ℝ} {θ₁ θ₂ : ℝ} (h : θ₁ ≤ θ₂) :
    keepSet (keepSet s d θ₁) d θ₂ = keepSet s d θ₂ := by
  ext i
  rw [keepSet, keepSet, keepSet, Finset.mem_filter, Finset.mem_filter, Finset.mem_filter]
  constructor
  · rintro ⟨⟨hi, _⟩, h2⟩; exact ⟨hi, h2⟩
  · rintro ⟨hi, h2⟩; exact ⟨⟨hi, le_trans h h2⟩, h2⟩

/-- **Throughput is monotone in the threshold.**  For a concordant dial, deferring more
work never lowers the yield per unit of work — so throughput alone has a degenerate
optimum and cannot be the whole objective. -/
theorem throughput_mono_threshold {s : Finset ι} {d r : ι → ℝ} (hc : Concordant s d r)
    {θ₁ θ₂ : ℝ} (h : θ₁ ≤ θ₂) (hK : (keepSet s d θ₂).Nonempty) :
    throughput (keepSet s d θ₁) r ≤ throughput (keepSet s d θ₂) r := by
  have hsub : keepSet s d θ₁ ⊆ s := Finset.filter_subset _ _
  have hc1 : Concordant (keepSet s d θ₁) d r := hc.subset hsub
  have hK' : (keepSet (keepSet s d θ₁) d θ₂).Nonempty := by
    rwa [keepSet_keepSet h]
  have := skip_throughput_ge hc1 θ₂ hK'
  rwa [keepSet_keepSet h] at this

omit [DecidableEq ι] in
/-- **Total yield is antitone in the threshold.**  Every unit of deferred work is a unit
of yield forgone. -/
theorem keptYield_antitone_threshold {s : Finset ι} {d r : ι → ℝ}
    (hnonneg : ∀ i ∈ s, 0 ≤ r i) {θ₁ θ₂ : ℝ} (h : θ₁ ≤ θ₂) :
    ∑ i ∈ keepSet s d θ₂, r i ≤ ∑ i ∈ keepSet s d θ₁, r i := by
  refine Finset.sum_le_sum_of_subset_of_nonneg (keepSet_subset_keepSet h) ?_
  intro i hi _
  exact hnonneg i (Finset.filter_subset _ _ hi)

omit [DecidableEq ι] in
/-- The yield loss is strict as soon as the higher threshold defers a live target. -/
theorem keptYield_lt_of_skips_live_target {s : Finset ι} {d r : ι → ℝ}
    (hnonneg : ∀ i ∈ s, 0 ≤ r i) {θ₁ θ₂ : ℝ} (h : θ₁ ≤ θ₂)
    {j : ι} (hj1 : j ∈ keepSet s d θ₁) (hj2 : j ∉ keepSet s d θ₂) (hrj : 0 < r j) :
    ∑ i ∈ keepSet s d θ₂, r i < ∑ i ∈ keepSet s d θ₁, r i := by
  classical
  have hsub : keepSet s d θ₂ ⊆ keepSet s d θ₁ := keepSet_subset_keepSet h
  have hins : insert j (keepSet s d θ₂) ⊆ keepSet s d θ₁ :=
    Finset.insert_subset hj1 hsub
  have hstep : ∑ i ∈ keepSet s d θ₂, r i < ∑ i ∈ insert j (keepSet s d θ₂), r i := by
    rw [Finset.sum_insert hj2]
    linarith
  refine lt_of_lt_of_le hstep (Finset.sum_le_sum_of_subset_of_nonneg hins ?_)
  intro i hi _
  exact hnonneg i (Finset.filter_subset _ _ hi)

omit [DecidableEq ι] in
/-- **Where the flip stops.**  If a relation quota `Q` has to be met, the threshold is
admissible only while the kept yield still clears the quota; the throughput gain of
`throughput_mono_threshold` is available exactly up to that point. -/
theorem threshold_admissible_of_quota {s : Finset ι} {d r : ι → ℝ}
    (hnonneg : ∀ i ∈ s, 0 ≤ r i) {θ₁ θ₂ Q : ℝ} (h : θ₁ ≤ θ₂)
    (hquota : Q ≤ ∑ i ∈ keepSet s d θ₂, r i) :
    Q ≤ ∑ i ∈ keepSet s d θ₁, r i :=
  le_trans hquota (keptYield_antitone_threshold hnonneg h)

/-! ## Sharpness of the oracle bound -/

/-- **The oracle bound is attained**, hence exact: the concentrator realises `B · max r`,
so no allocation does better and some allocation does exactly this. -/
theorem concentrator_attains_oracle_bound {s : Finset ι} {r : ι → ℝ} {i₀ : ι}
    (hi₀ : i₀ ∈ s) (hmax : ∀ i ∈ s, r i ≤ r i₀) (B : ℝ) :
    yieldOf s r (concAlloc i₀ B) = r i₀ * B
      ∧ ∀ ℓ : ι → ℝ, (∀ i ∈ s, 0 ≤ ℓ i) → (∑ i ∈ s, ℓ i = B) →
        yieldOf s r ℓ ≤ yieldOf s r (concAlloc i₀ B) := by
  refine ⟨conc_yield_eq hi₀ r B, ?_⟩
  intro ℓ hℓ hsum
  rw [conc_yield_eq hi₀ r B]
  exact yield_le_budget_mul_sup hmax hℓ hsum

omit [DecidableEq ι] in
/-- **The headroom is bounded by the number of targets.**  The oracle yield is at most
`|s|` times the uniform baseline, whatever the rate spread — the unclaimed gain measured
against a uniform schedule cannot exceed a factor `|s|`. -/
theorem oracle_ratio_le_card {s : Finset ι} {r : ι → ℝ} {i₀ : ι} (hi₀ : i₀ ∈ s)
    (hnonneg : ∀ i ∈ s, 0 ≤ r i) {B : ℝ} (hB : 0 ≤ B) :
    r i₀ * B ≤ (s.card : ℝ) * yieldOf s r (uniformAlloc s B) := by
  have hs : s.Nonempty := ⟨i₀, hi₀⟩
  have hn : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  have hsingle : r i₀ ≤ ∑ i ∈ s, r i :=
    Finset.single_le_sum (fun i hi => hnonneg i hi) hi₀
  rw [uniform_yield_eq]
  rw [mul_div_assoc', le_div_iff₀ hn]
  nlinarith [mul_nonneg hB (sub_nonneg.mpr hsingle), hn]

end Probability.AdaptiveQS