import Mathlib

/-!
# The filter cap law: `4/3` for exchangeable dials, `1/θ` for structural ones

This file formalises the *filter accounting* underlying the ORBIT-DIAL-CAP-TEST
(FACT round-74 #2, exp 564).

## The cost model

We normalise the cost of an unfiltered `sqrt`-descending trial-division sweep to `1`.
A *dial* is a rule that retains a fraction `θ ∈ (0,1]` of the candidate divisors and
retains the *true* factor with probability `s ∈ [0,1]` (`s` is the dial's *soundness*).

Running the dial costs `θ` (the filtered sweep).  With probability `s` the factor is
inside the retained set and the search stops there; with probability `1 - s` the dial
missed and the remaining `1 - θ` candidates must still be swept, for total cost `1`.
Hence the expected cost is

`dialCost s θ = s * θ + (1 - s) * 1 = 1 - s + s * θ`

and the speedup over the unfiltered sweep is `dialSpeedup s θ = (dialCost s θ)⁻¹`.

## Main results

* `OrbitDialCap.exchangeable_cap` — an **exchangeable** dial (`s = θ`: the true factor
  is no more likely to be retained than any other candidate) has speedup `≤ 4/3`.
  This is *barrier 4*.
* `OrbitDialCap.exchangeable_cap_eq_iff` — the cap is attained exactly at `θ = 1/2`,
  matching the measured RAND-MATCH read `1.3387 ≈ 4/3`.
* `OrbitDialCap.speedup_gt_four_thirds_iff` — the cap is broken **iff** `s * (1-θ) > 1/4`,
  a clean threshold that separates the two regimes.
* `OrbitDialCap.soundness_excess_of_gt_cap` — quantitative escape cost: breaking the cap
  forces a strictly super-exchangeable soundness, `s - θ > (1 - 2θ)^2 / (4 (1-θ))`.
* `OrbitDialCap.deterministic_escape` and `OrbitDialCap.parity_skip_speedup` — a
  *deterministic* exclusion (`s = 1`) has speedup `1/θ`, equal to `2` at `θ = 1/2`:
  the ORBIT arm's `2.0000` read is exactly this, a constant shave, not a barrier event.
-/

namespace OrbitDialCap

open Real

/-- Expected cost of a filtered `sqrt`-descending sweep, normalised so that the
unfiltered sweep costs `1`.  `θ` is the retained fraction of candidates, `s` the
probability that the true factor survives the filter. -/
noncomputable def dialCost (s θ : ℝ) : ℝ := 1 - s + s * θ

/-- Speedup of a dial with soundness `s` and retention `θ` over the unfiltered sweep. -/
noncomputable def dialSpeedup (s θ : ℝ) : ℝ := (dialCost s θ)⁻¹

@[simp] lemma dialCost_one (θ : ℝ) : dialCost 1 θ = θ := by
  simp [dialCost]

@[simp] lemma dialCost_zero (θ : ℝ) : dialCost 0 θ = 1 := by
  simp [dialCost]

lemma dialCost_exch (θ : ℝ) : dialCost θ θ = 1 - θ + θ ^ 2 := by
  simp [dialCost, sq]

/-- The expected cost is positive as soon as some candidates are retained. -/
lemma dialCost_pos {s θ : ℝ} (hs1 : s ≤ 1) (hs0 : 0 ≤ s) (hθ : 0 < θ) :
    0 < dialCost s θ := by
  rcases eq_or_lt_of_le hs1 with h | h
  · rw [dialCost, h]; linarith
  · have h1 : 0 < 1 - s := by linarith
    have h2 : 0 ≤ s * θ := mul_nonneg hs0 hθ.le
    simp only [dialCost]
    linarith

/-- **Exchangeable cost floor.**  An exchangeable dial can never cost less than `3/4`
of the unfiltered sweep, the minimum being the completed square `(θ - 1/2)^2`. -/
lemma exch_cost_ge (θ : ℝ) : 3 / 4 ≤ dialCost θ θ := by
  have h : dialCost θ θ - 3 / 4 = (θ - 1 / 2) ^ 2 := by
    simp only [dialCost]; ring
  nlinarith [sq_nonneg (θ - 1 / 2)]

/-- **Barrier 4 (the cap law).**  Any exchangeable dial — one that keeps the true factor
with exactly the same probability `θ` with which it keeps an arbitrary candidate — is
worth at most a `4/3` speedup, whatever the retention `θ`. -/
theorem exchangeable_cap {θ : ℝ} (hθ : 0 < θ) (hθ1 : θ ≤ 1) :
    dialSpeedup θ θ ≤ 4 / 3 := by
  have hpos : 0 < dialCost θ θ := dialCost_pos hθ1 hθ.le hθ
  have hge : 3 / 4 ≤ dialCost θ θ := exch_cost_ge θ
  have hinv : (dialCost θ θ)⁻¹ ≤ (3 / 4 : ℝ)⁻¹ := inv_anti₀ (by norm_num) hge
  have : ((3 : ℝ) / 4)⁻¹ = 4 / 3 := by norm_num
  rw [dialSpeedup]
  linarith [hinv, this.le, this.ge]

/-- No exchangeable dial breaks the cap: the barrier has no counterexample. -/
theorem no_exchangeable_barrier :
    ¬ ∃ θ : ℝ, 0 < θ ∧ θ ≤ 1 ∧ 4 / 3 < dialSpeedup θ θ := by
  rintro ⟨θ, hθ, hθ1, hlt⟩
  exact absurd (exchangeable_cap hθ hθ1) (not_le.mpr hlt)

/-- The exchangeable cap is attained exactly at retention `θ = 1/2`, the value used in
the experiment (`RAND-MATCH 1.3387`, predicted `4/3 = 1.3333`). -/
theorem exchangeable_cap_eq_iff {θ : ℝ} (hθ : 0 < θ) (hθ1 : θ ≤ 1) :
    dialSpeedup θ θ = 4 / 3 ↔ θ = 1 / 2 := by
  have hpos : 0 < dialCost θ θ := dialCost_pos hθ1 hθ.le hθ
  constructor
  · intro h
    have hcost : dialCost θ θ = 3 / 4 := by
      have := congrArg (fun x : ℝ => x⁻¹) h
      simpa [dialSpeedup, inv_inv, hpos.ne'] using this
    have hsq : (θ - 1 / 2) ^ 2 = 0 := by
      have : dialCost θ θ - 3 / 4 = (θ - 1 / 2) ^ 2 := by simp only [dialCost]; ring
      linarith [this, hcost]
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hsq
    linarith
  · rintro rfl
    norm_num [dialSpeedup, dialCost]

@[simp] lemma exchangeable_half : dialSpeedup (1 / 2) (1 / 2) = 4 / 3 := by
  norm_num [dialSpeedup, dialCost]

/-- A **deterministic** dial (`s = 1`, the true factor is *never* excluded) shaves the
cost to exactly the retained fraction. -/
@[simp] theorem deterministic_speedup (θ : ℝ) :
    dialSpeedup 1 θ = θ⁻¹ := by
  simp [dialSpeedup, dialCost]

/-- The ORBIT arm: the parity skip retains half the candidates and never excludes an
odd factor, giving a clean `2.0000` — the value measured with failure rate `0.000`. -/
theorem parity_skip_speedup : dialSpeedup 1 (1 / 2) = 2 := by
  norm_num [dialSpeedup, dialCost]

/-- The measured ORBIT/RAND-MATCH ratio at `θ = 1/2` is exactly `3/2`. -/
theorem orbit_over_randmatch :
    dialSpeedup 1 (1 / 2) / dialSpeedup (1 / 2) (1 / 2) = 3 / 2 := by
  rw [parity_skip_speedup, exchangeable_half]; norm_num

/-- **Sharp cap-breaking criterion.**  A dial beats the `4/3` cap precisely when its
soundness–retention product `s * (1 - θ)` exceeds `1/4`. -/
theorem speedup_gt_four_thirds_iff {s θ : ℝ} (hs1 : s ≤ 1) (hs0 : 0 ≤ s) (hθ : 0 < θ) :
    4 / 3 < dialSpeedup s θ ↔ 1 / 4 < s * (1 - θ) := by
  have hpos : 0 < dialCost s θ := dialCost_pos hs1 hs0 hθ
  rw [dialSpeedup, lt_inv_comm₀ (by norm_num) hpos,
    show ((4 : ℝ) / 3)⁻¹ = 3 / 4 by norm_num, dialCost]
  constructor <;> intro h <;> nlinarith

/-- Restating the cap law through the sharp criterion: exchangeability `s = θ` forces
`θ (1 - θ) ≤ 1/4` by AM–GM, so the criterion can never fire. -/
theorem exchangeable_never_fires (θ : ℝ) : θ * (1 - θ) ≤ 1 / 4 := by
  nlinarith [sq_nonneg (θ - 1 / 2)]

/-- **Quantitative escape cost.**  Any dial that beats the cap must be strictly
*super-exchangeable*: its soundness exceeds its retention by at least the completed
square `(1 - 2θ)^2 / (4(1-θ))`.  At `θ = 1/2` this is vacuous (any `s > 1/2` bias
already helps), which is why `θ = 1/2` is the extremal test point. -/
theorem soundness_excess_of_gt_cap {s θ : ℝ} (hs1 : s ≤ 1) (hs0 : 0 ≤ s)
    (hθ : 0 < θ) (hθ1 : θ < 1) (hbeat : 4 / 3 < dialSpeedup s θ) :
    (1 - 2 * θ) ^ 2 / (4 * (1 - θ)) < s - θ := by
  have hcrit : 1 / 4 < s * (1 - θ) := (speedup_gt_four_thirds_iff hs1 hs0 hθ).mp hbeat
  have h1 : 0 < 1 - θ := by linarith
  rw [div_lt_iff₀ (by linarith)]
  nlinarith [hcrit, sq_nonneg (1 - 2 * θ)]

/-- A dial that beats the cap is strictly more likely to keep the true factor than a
random candidate — it is *biased towards the factor*.  Either that bias comes from
per-`N` information, or (the ORBIT case) from a deterministic structural exclusion. -/
theorem soundness_gt_retention_of_gt_cap {s θ : ℝ} (hs1 : s ≤ 1) (hs0 : 0 ≤ s)
    (hθ : 0 < θ) (hθ1 : θ < 1) (hbeat : 4 / 3 < dialSpeedup s θ) : θ < s := by
  have := soundness_excess_of_gt_cap hs1 hs0 hθ hθ1 hbeat
  have hnn : 0 ≤ (1 - 2 * θ) ^ 2 / (4 * (1 - θ)) :=
    div_nonneg (sq_nonneg _) (by linarith)
  linarith

/-- Monotonicity of the speedup in the soundness: a filter is worth more the more
reliably it keeps the answer. -/
theorem dialSpeedup_mono_soundness {s s' θ : ℝ} (hs0 : 0 ≤ s) (hs' : s ≤ s')
    (hs'1 : s' ≤ 1) (hθ : 0 < θ) (hθ1 : θ ≤ 1) :
    dialSpeedup s θ ≤ dialSpeedup s' θ := by
  have hpos : 0 < dialCost s θ := dialCost_pos (hs'.trans hs'1) hs0 hθ
  have hpos' : 0 < dialCost s' θ := dialCost_pos hs'1 (hs0.trans hs') hθ
  have hle : dialCost s' θ ≤ dialCost s θ := by
    simp only [dialCost]; nlinarith
  exact inv_anti₀ hpos' hle

/-- **The scope note on barrier 4, in one statement.**  At the experimental operating
point `θ = 1/2` the exchangeable dial sits exactly at the cap `4/3`, while the
deterministic dial with the *same* retention reads `2 > 4/3`.  The cap therefore bounds
information-bearing dials only; a blind structural exclusion escapes it by soundness,
not by information. -/
theorem cap_scope_note :
    dialSpeedup (1 / 2) (1 / 2) = 4 / 3 ∧
    dialSpeedup 1 (1 / 2) = 2 ∧
    dialSpeedup (1 / 2) (1 / 2) < dialSpeedup 1 (1 / 2) := by
  refine ⟨exchangeable_half, parity_skip_speedup, ?_⟩
  rw [exchangeable_half, parity_skip_speedup]; norm_num

end OrbitDialCap