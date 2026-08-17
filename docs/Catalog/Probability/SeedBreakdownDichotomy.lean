/-
# Calibration = maximal robustness: the exact breakdown number of a quota rung

`Logic.KneeQuotaScaling` proved that the **median** rung of a `2m+1`-seed ensemble survives
`m` corrupted seeds (`KneeQuota.median_breakdown_half`) and exhibited sharpness at the
three-seed cell.  `Probability.SeedQuotaBinomial` proved, on the probabilistic side, that the
median rung is the *unique calibrated* rung of an odd ensemble and that even ensembles have
none.  Those two facts single out the same index, and this file proves that this is not a
coincidence.

Main results.

* `SeedBreakdown.rung_bracket` — a rung moves by at most `c` rungs of the *clean* ladder
  under `c` corrupted seeds, in **both** directions.  `rung_in_clean_range` : hence for
  `c ≤ min (m-1) (n-m)` the corrupted reading stays inside the clean ensemble's own range.
* `SeedBreakdown.breakdown_up` and `breakdown_down` — sharpness in both directions and for
  every rung: with `n - m + 1` corrupted seeds the rung is pushed above any prescribed value,
  and with `m` corrupted seeds it collapses to `0`.  So the two-sided breakdown number of the
  `m`-th rung of an `n`-seed ensemble is exactly `min (m-1) (n-m)`
  (`SeedBreakdown.breakdownNumber`).
* `SeedBreakdown.calibrated_iff_maximally_robust` — **the dichotomy.**  For an odd ensemble
  `n = 2r+1` and a meaningful quota `1 ≤ m ≤ n`, the rung is calibrated on coin-flip seeds
  **iff** its breakdown number is maximal (`= r`).  Calibration is a parity constraint,
  robustness is a counting constraint, and they pin the same rung.
* `SeedBreakdown.even_no_unique_centre` — for an even ensemble both properties fail together:
  no rung is calibrated, and the maximal breakdown number `r-1` is attained by *two* rungs.
  Parity is the obstruction to a canonical centre, on both sides at once.
* `SeedBreakdown.net48_three_seed_centre` / `net48_four_seed_two_centres` — the readings for
  the round: the three-seed ensemble has a unique calibrated, maximally robust rung
  (the median, breakdown `1`); a fourth seed would leave two competing central rungs, both of
  breakdown `1` and neither calibrated.  A fourth seed buys **no** robustness over the third.
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Logic.KneeQuotaScaling

namespace SeedBreakdown

open Finset KneeMedian KneeQuota

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## 1.  Two-sided robustness of a rung -/

/-- **`c` corrupted seeds move the `m`-th rung by at most `c` rungs, in either direction.**
The upper half is `KneeQuota.quotaBudget_agree_le`; the lower half is its mirror. -/
theorem rung_bracket (K K' : ι → ℕ) (S : Finset ι) (hagree : ∀ i ∉ S, K i = K' i)
    {m c : ℕ} (hc : S.card ≤ c) (hcm : c ≤ m - 1) (hmn : m + c ≤ Fintype.card ι) :
    quotaBudget K (m - c) ≤ quotaBudget K' m ∧ quotaBudget K' m ≤ quotaBudget K (m + c) := by
  constructor
  · have hle := quotaBudget_agree_le K K' S hagree (m - c) (by omega)
    exact hle.trans (quotaBudget_mono (by omega) (by omega))
  · have hagree' : ∀ i ∉ S, K' i = K i := fun i hi => (hagree i hi).symm
    have hle := quotaBudget_agree_le K' K S hagree' m (by omega)
    exact hle.trans (quotaBudget_mono (by omega) (by omega))

/-- The two-sided breakdown number of the `m`-th rung of an `n`-seed ensemble. -/
def breakdownNumber (n m : ℕ) : ℕ := min (m - 1) (n - m)

/-- **Below the breakdown number the reading cannot escape the clean ensemble.**  It stays
between the clean best case (rung `1`, the minimum knee) and the clean guarantee (rung `n`,
the maximum knee). -/
theorem rung_in_clean_range (K K' : ι → ℕ) (S : Finset ι) (hagree : ∀ i ∉ S, K i = K' i)
    {m : ℕ} (hm1 : 1 ≤ m) (hmn : m ≤ Fintype.card ι)
    (hS : S.card ≤ breakdownNumber (Fintype.card ι) m) :
    quotaBudget K 1 ≤ quotaBudget K' m ∧ quotaBudget K' m ≤ quotaBudget K (Fintype.card ι) := by
  have hSm : S.card ≤ m - 1 := le_trans hS (min_le_left _ _)
  have hSn : S.card ≤ Fintype.card ι - m := le_trans hS (min_le_right _ _)
  obtain ⟨hlow, hhigh⟩ :=
    rung_bracket K K' S hagree (c := S.card) le_rfl hSm (by omega)
  exact ⟨(quotaBudget_mono (by omega) (by omega)).trans hlow,
    hhigh.trans (quotaBudget_mono (by omega) le_rfl)⟩

/-! ## 2.  Sharpness: the breakdown number is exactly `min (m-1) (n-m)` -/

/-- **Upward breakdown.**  Corrupting `n - m + 1` seeds pushes the `m`-th rung above any
prescribed value: too few clean seeds remain to fill the quota. -/
theorem breakdown_up (K : ι → ℕ) (S : Finset ι) {m : ℕ} (hm : m ≤ Fintype.card ι)
    (hS : Fintype.card ι < m + S.card) (B : ℕ) :
    ∃ K' : ι → ℕ, (∀ i ∉ S, K i = K' i) ∧ B ≤ quotaBudget K' m := by
  classical
  have key : ∀ K' : ι → ℕ, (∀ i ∈ S, B ≤ K' i) → B ≤ quotaBudget K' m := by
    intro K' hK'
    by_contra hcon
    push_neg at hcon
    have hmem : m ≤ (passSet K' (quotaBudget K' m)).card := card_passSet_quotaBudget hm
    have hsub : passSet K' (quotaBudget K' m) ⊆ Sᶜ := by
      intro i hi
      simp only [passSet, mem_filter, mem_univ, true_and] at hi
      simp only [Finset.mem_compl]
      intro hiS
      have hBi := hK' i hiS
      omega
    have hcard := card_le_card hsub
    rw [Finset.card_compl] at hcard
    have hScard : S.card ≤ Fintype.card ι := by
      simpa [Finset.card_univ] using Finset.card_le_univ S
    omega
  exact ⟨fun i => if i ∈ S then B else K i, fun i hi => by simp [hi],
    key _ (fun i hi => by simp [hi])⟩

/-- **Downward breakdown.**  Corrupting `m` seeds collapses the `m`-th rung to `0`, below
every clean knee. -/
theorem breakdown_down (K : ι → ℕ) (S : Finset ι) {m : ℕ} (hSm : m ≤ S.card) :
    ∃ K' : ι → ℕ, (∀ i ∉ S, K i = K' i) ∧ quotaBudget K' m = 0 := by
  classical
  have key : ∀ K' : ι → ℕ, (∀ i ∈ S, K' i = 0) → quotaBudget K' m = 0 := by
    intro K' hK'
    have hsub : S ⊆ passSet K' 0 := by
      intro i hi
      simp only [passSet, mem_filter, mem_univ, true_and, hK' i hi, le_refl]
    have hcard : m ≤ (passSet K' 0).card := hSm.trans (card_le_card hsub)
    exact Nat.le_zero.1 (quotaBudget_le_of_card hcard)
  exact ⟨fun i => if i ∈ S then 0 else K i, fun i hi => by simp [hi],
    key _ (fun i hi => by simp [hi])⟩

/-! ## 3.  The dichotomy: calibrated ⟺ maximally robust -/

/-- In an odd ensemble no rung is more robust than the median rung. -/
theorem breakdownNumber_le_odd {r m : ℕ} (h1 : 1 ≤ m) (h2 : m ≤ 2 * r + 1) :
    breakdownNumber (2 * r + 1) m ≤ r := by
  unfold breakdownNumber
  omega

/-- …and only the median rung attains that bound. -/
theorem breakdownNumber_eq_iff_odd {r m : ℕ} (h1 : 1 ≤ m) (h2 : m ≤ 2 * r + 1) :
    breakdownNumber (2 * r + 1) m = r ↔ m = r + 1 := by
  unfold breakdownNumber
  omega

/-- **The dichotomy.**  For an odd ensemble a rung is calibrated on coin-flip seeds exactly
when it is maximally robust to corrupted seeds.  The probabilistic constraint (a parity
identity on binomial tails) and the combinatorial constraint (a counting bound on
corruptions) select the same rung — which is why "read the median" is a theorem and not a
convention. -/
theorem calibrated_iff_maximally_robust {r m : ℕ} (h1 : 1 ≤ m) (h2 : m ≤ 2 * r + 1) :
    SeedQuota.rungProb (2 * r + 1) m (1/2 : ℝ) = 1/2 ↔ breakdownNumber (2 * r + 1) m = r := by
  rw [SeedQuota.rungProb_half_eq_iff (by omega), breakdownNumber_eq_iff_odd h1 h2]
  omega

/-- **Even ensembles fail on both sides at once.**  No rung is calibrated, and the maximal
breakdown number `r-1` is attained by the two central rungs rather than one.  Parity is a
single obstruction to a canonical centre, visible in both the probability and the
robustness. -/
theorem even_no_unique_centre {r : ℕ} (hr : 1 ≤ r) :
    (∀ m, 1 ≤ m → m ≤ 2 * r → breakdownNumber (2 * r) m ≤ r - 1) ∧
      breakdownNumber (2 * r) r = r - 1 ∧ breakdownNumber (2 * r) (r + 1) = r - 1 ∧
      r ≠ r + 1 ∧ (∀ m, SeedQuota.rungProb (2 * r) m (1/2 : ℝ) ≠ 1/2) := by
  refine ⟨fun m h1 h2 => ?_, ?_, ?_, by omega, fun m => SeedQuota.even_no_calibrated_rung r m⟩
  · unfold breakdownNumber; omega
  · unfold breakdownNumber; omega
  · unfold breakdownNumber; omega

/-! ## 4.  Lab notes: the three-seed centre, and what a fourth seed would do -/

/-- The NET-48 three-seed ensemble has a unique rung that is both calibrated and maximally
robust — the median, with breakdown number `1`. -/
theorem net48_three_seed_centre :
    breakdownNumber 3 2 = 1 ∧ SeedQuota.rungProb 3 2 (1/2 : ℝ) = 1/2 ∧
      (∀ m, 1 ≤ m → m ≤ 3 → breakdownNumber 3 m = 1 → m = 2) := by
  refine ⟨by decide, ?_, fun m h1 h2 h3 => ?_⟩
  · have := SeedQuota.odd_median_rung_calibrated 1
    norm_num at this
    exact this
  · have := (breakdownNumber_eq_iff_odd (r := 1) (m := m) h1 (by omega)).1 (by simpa using h3)
    omega

/-- A fourth seed would leave **two** competing central rungs, of equal breakdown number `1`
— no better than the third seed's — and neither calibrated.  Under this model the fourth
seed buys neither robustness nor calibration; only a fifth does. -/
theorem net48_four_seed_two_centres :
    breakdownNumber 4 2 = 1 ∧ breakdownNumber 4 3 = 1 ∧
      (∀ m, 1 ≤ m → m ≤ 4 → breakdownNumber 4 m ≤ 1) ∧
      (∀ m, SeedQuota.rungProb 4 m (1/2 : ℝ) ≠ 1/2) := by
  refine ⟨by decide, by decide, fun m h1 h2 => ?_, fun m => ?_⟩
  · unfold breakdownNumber; omega
  · have := SeedQuota.even_no_calibrated_rung 2 m
    norm_num at this
    simpa using this

/-- And a fifth seed strictly improves robustness as well as restoring calibration:
breakdown number `2`. -/
theorem net48_five_seed_centre :
    breakdownNumber 5 3 = 2 ∧ SeedQuota.rungProb 5 3 (1/2 : ℝ) = 1/2 := by
  refine ⟨by decide, ?_⟩
  have := SeedQuota.odd_median_rung_calibrated 2
  norm_num at this
  exact this

end SeedBreakdown