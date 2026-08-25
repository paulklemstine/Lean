import Mathlib
import Algebra.ZeroFitDialU120Rigidity

/-!
# Quantitative stability: how far a near-extremal seed profile can be from the extremiser

## Research context (FACT round-72 #4, exp 554, sixth cycle)

Cycle 5 (`Algebra.ZeroFitDialU120Rigidity`) proved that the Kantorovich extremiser is
unique.  Rigidity alone, however, is a statement about *exact* equality, and no measured
seed profile ever attains a bound exactly: exp 554's profiles sit strictly above it.  The
question this cycle answers is therefore the quantitative one:

> **Q (stability).**  If a seed profile misses the sharp pooling bound by at most `ε`, how
> far can it be from the unique extremal profile?

The answer is that the cycle-5 remainder identity is not merely a *detector* of equality
but a *metric*: its two summands are exactly the two ways a profile can fail to be
extremal, and each is separately controlled by the slack.

## Main results

* `endpoint_defect_le` — the pointwise convexity estimate on the window: for `λ ∈ [α, β]`,
  `((β-α)/2)·min(λ-α, β-λ) ≤ (λ-α)(β-λ)`.  The `(λ-α)(β-λ)` appearing in the remainder
  identity therefore dominates a genuine distance-to-the-endpoints.
* `kantorovich_stability` — **the stability theorem**.  A profile whose Kantorovich slack
  is at most `ε` satisfies both
  * `∑ wₖ · dist(λₖ, {α, β}) ≤ ε / (2αβ(β-α))` — the profile is `O(ε)`-close, in weighted
    `L¹`, to being supported on the window endpoints, and
  * `((α+β)M - 2αβ)² ≤ ε` — its mean is within `√ε/(α+β)` of the harmonic mean.
* `kantorovich_stability_recovers_rigidity` — the estimate is consistent and sharp at
  `ε = 0`: it reproves the endpoint-support half of `kantorovich_equality_rigidity`
  verbatim, so no information is lost in passing to the quantitative form.
* `kantorovich_stability_mean` — the clean mean-defect form
  `|M - 2αβ/(α+β)| ≤ √ε/(α+β)`.
* `u120_window_stability` — the recorded-window instance: on `λₖ ∈ [1, 1.21]` a slack of
  `0.001` forces the profile within weighted `L¹` distance `0.002` of the window
  endpoints.  The random search of `ComputationalEvidence.md` §8 bottomed out at slack
  `0.0013` with ratios `(1.0013, 1.2087)`, i.e. `L¹` distance `≈ 0.0013` — inside the
  proved envelope, as it must be.

## Lab notes (exp 554)

The three windows searched in §8 of `ComputationalEvidence.md` give proved envelopes
`ε/(2αβ(β-α))` of `ε/48`, `ε/0.5082` and `ε/24` respectively; in every case the best
random profile found sat well inside its envelope, and the envelope collapses to the exact
extremiser as `ε → 0`.
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU120Stability

open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialU120Floor
open Catalog.Algebra.ZeroFitDialU120Kantorovich
open Catalog.Algebra.ZeroFitDialU120Rigidity

/-- The pointwise convexity estimate on a window: the endpoint product `(λ-α)(β-λ)`
dominates `((β-α)/2)` times the distance from `λ` to the nearer endpoint. -/
theorem endpoint_defect_le {alpha beta lam : ℝ} (h1 : alpha ≤ lam) (h2 : lam ≤ beta) :
    (beta - alpha) / 2 * min (lam - alpha) (beta - lam) ≤ (lam - alpha) * (beta - lam) := by
  rcases le_total (lam - alpha) (beta - lam) with h | h
  · rw [min_eq_left h]
    nlinarith [sub_nonneg.mpr h1, sub_nonneg.mpr h2]
  · rw [min_eq_right h]
    nlinarith [sub_nonneg.mpr h1, sub_nonneg.mpr h2]

/-- **Quantitative stability of the sharp seed-imbalance law.**  A normalised seed profile
whose Kantorovich slack is at most `ε` is within weighted `L¹` distance `ε/(2αβ(β-α))` of
being supported on the endpoints of the ratio window, and its mean ratio is within
`√ε/(α+β)` of the harmonic mean of the window. -/
theorem kantorovich_stability {r : ℕ} {w lam : Fin r → ℝ} {alpha beta eps : ℝ}
    (halpha : 0 < alpha) (hab : alpha < beta) (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    (hlo : ∀ k, alpha ≤ lam k) (hhi : ∀ k, lam k ≤ beta)
    (hslack : (alpha + beta) ^ 2 * (∑ k, w k * lam k) ^ 2
      - 4 * (alpha * beta) * ((∑ k, w k) * (∑ k, w k * lam k ^ 2)) ≤ eps) :
    (∑ k, w k * min (lam k - alpha) (beta - lam k))
        ≤ eps / (2 * (alpha * beta) * (beta - alpha))
      ∧ ((alpha + beta) * (∑ k, w k * lam k) - 2 * (alpha * beta)) ^ 2 ≤ eps := by
  have hbeta : 0 < beta := lt_trans halpha hab
  have hab' : 0 < alpha * beta := mul_pos halpha hbeta
  have hwidth : 0 < beta - alpha := sub_pos.mpr hab
  have hid := kantorovich_slack_identity (w := w) (lam := lam)
    (alpha := alpha) (beta := beta) hsum
  have hterm : ∀ k ∈ (Finset.univ : Finset (Fin r)),
      0 ≤ w k * ((lam k - alpha) * (beta - lam k)) := by
    intro k _
    exact mul_nonneg (hw k)
      (mul_nonneg (sub_nonneg.mpr (hlo k)) (sub_nonneg.mpr (hhi k)))
  have hD : 0 ≤ ∑ k, w k * ((lam k - alpha) * (beta - lam k)) :=
    Finset.sum_nonneg hterm
  have hsq : 0 ≤ ((alpha + beta) * (∑ k, w k * lam k) - 2 * (alpha * beta)) ^ 2 :=
    sq_nonneg _
  rw [hid] at hslack
  refine ⟨?_, by linarith [mul_nonneg (by positivity : (0:ℝ) ≤ 4 * (alpha * beta)) hD]⟩
  -- the endpoint defect is controlled by the slack
  have hDle : ∑ k, w k * ((lam k - alpha) * (beta - lam k)) ≤ eps / (4 * (alpha * beta)) := by
    rw [le_div_iff₀ (by positivity)]
    nlinarith [hsq]
  have hpt : (beta - alpha) / 2 * (∑ k, w k * min (lam k - alpha) (beta - lam k))
      ≤ ∑ k, w k * ((lam k - alpha) * (beta - lam k)) := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun k _ => ?_
    have := endpoint_defect_le (hlo k) (hhi k)
    have hmul := mul_le_mul_of_nonneg_left this (hw k)
    calc (beta - alpha) / 2 * (w k * min (lam k - alpha) (beta - lam k))
        = w k * ((beta - alpha) / 2 * min (lam k - alpha) (beta - lam k)) := by ring
      _ ≤ w k * ((lam k - alpha) * (beta - lam k)) := hmul
  have hchain : (beta - alpha) / 2 * (∑ k, w k * min (lam k - alpha) (beta - lam k))
      ≤ eps / (4 * (alpha * beta)) := le_trans hpt hDle
  rw [le_div_iff₀ (by positivity)]
  rw [le_div_iff₀ (by positivity : (0:ℝ) < 4 * (alpha * beta))] at hchain
  nlinarith [hchain]

/-- The stability estimate is sharp at `ε = 0`: it reproves the endpoint-support half of
the rigidity theorem, so nothing is lost in the quantitative form. -/
theorem kantorovich_stability_recovers_rigidity {r : ℕ} {w lam : Fin r → ℝ} {alpha beta : ℝ}
    (halpha : 0 < alpha) (hab : alpha < beta) (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    (hlo : ∀ k, alpha ≤ lam k) (hhi : ∀ k, lam k ≤ beta)
    (heq : 4 * (alpha * beta) * ((∑ k, w k) * (∑ k, w k * lam k ^ 2))
      = (alpha + beta) ^ 2 * (∑ k, w k * lam k) ^ 2) :
    ∀ k, w k * min (lam k - alpha) (beta - lam k) = 0 := by
  have hbeta : 0 < beta := lt_trans halpha hab
  have hslack : (alpha + beta) ^ 2 * (∑ k, w k * lam k) ^ 2
      - 4 * (alpha * beta) * ((∑ k, w k) * (∑ k, w k * lam k ^ 2)) ≤ 0 := by
    linarith [heq]
  obtain ⟨hdist, -⟩ := kantorovich_stability halpha hab hw hsum hlo hhi hslack
  have hzero : ∑ k, w k * min (lam k - alpha) (beta - lam k) ≤ 0 := by
    simpa using hdist
  have hnn : ∀ k ∈ (Finset.univ : Finset (Fin r)),
      0 ≤ w k * min (lam k - alpha) (beta - lam k) := by
    intro k _
    exact mul_nonneg (hw k)
      (le_min (sub_nonneg.mpr (hlo k)) (sub_nonneg.mpr (hhi k)))
  have hsum0 : ∑ k, w k * min (lam k - alpha) (beta - lam k) = 0 :=
    le_antisymm hzero (Finset.sum_nonneg hnn)
  intro k
  exact (Finset.sum_eq_zero_iff_of_nonneg hnn).mp hsum0 k (Finset.mem_univ k)

/-- The mean-defect half of stability in its clean form: the mean ratio of a profile with
slack at most `ε` lies within `√ε/(α+β)` of the harmonic mean `2αβ/(α+β)` of the window. -/
theorem kantorovich_stability_mean {r : ℕ} {w lam : Fin r → ℝ} {alpha beta eps : ℝ}
    (halpha : 0 < alpha) (hab : alpha < beta) (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    (hlo : ∀ k, alpha ≤ lam k) (hhi : ∀ k, lam k ≤ beta)
    (hslack : (alpha + beta) ^ 2 * (∑ k, w k * lam k) ^ 2
      - 4 * (alpha * beta) * ((∑ k, w k) * (∑ k, w k * lam k ^ 2)) ≤ eps) :
    |(∑ k, w k * lam k) - 2 * (alpha * beta) / (alpha + beta)|
      ≤ Real.sqrt eps / (alpha + beta) := by
  have hbeta : 0 < beta := lt_trans halpha hab
  have hpos : 0 < alpha + beta := by linarith
  obtain ⟨-, hmean⟩ := kantorovich_stability halpha hab hw hsum hlo hhi hslack
  have heps : 0 ≤ eps := le_trans (sq_nonneg _) hmean
  have habs : |(alpha + beta) * (∑ k, w k * lam k) - 2 * (alpha * beta)| ≤ Real.sqrt eps := by
    rw [← Real.sqrt_sq_eq_abs]
    exact Real.sqrt_le_sqrt hmean
  have key : (∑ k, w k * lam k) - 2 * (alpha * beta) / (alpha + beta)
      = ((alpha + beta) * (∑ k, w k * lam k) - 2 * (alpha * beta)) / (alpha + beta) := by
    field_simp
  rw [key, abs_div, abs_of_pos hpos]
  gcongr

/-- The recorded-window instance: on the `±10%` seed window `λₖ ∈ [1, 1.21]`, a Kantorovich
slack of `0.001` forces the profile within weighted `L¹` distance `0.002` of the window
endpoints. -/
theorem u120_window_stability {r : ℕ} {w lam : Fin r → ℝ}
    (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    (hlo : ∀ k, (1 : ℝ) ≤ lam k) (hhi : ∀ k, lam k ≤ 121 / 100)
    (hslack : (1 + 121 / 100 : ℝ) ^ 2 * (∑ k, w k * lam k) ^ 2
      - 4 * (1 * (121 / 100)) * ((∑ k, w k) * (∑ k, w k * lam k ^ 2)) ≤ 0.001) :
    (∑ k, w k * min (lam k - 1) (121 / 100 - lam k)) ≤ 0.002 := by
  obtain ⟨hdist, -⟩ := kantorovich_stability (alpha := 1) (beta := 121 / 100)
    (by norm_num) (by norm_num) hw hsum hlo hhi hslack
  refine le_trans hdist ?_
  norm_num

end Catalog.Algebra.ZeroFitDialU120Stability