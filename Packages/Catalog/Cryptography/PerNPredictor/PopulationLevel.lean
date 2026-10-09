import Cryptography.PerNPredictor.SieveDial

/-!
# Level tracks the population: the mean dial value on a complete period

`population_feature_sum` (in `SieveDial.lean`) counts the QR feature over a
common period.  Here it is turned into the population *mean* and into explicit
bounds for the adopted dial.

* `population_feature_mean` — on the uniform population `N < M`, `M` a common
  multiple of the odd primes in `S`, the mean feature is exactly
  `Σ_{p ∈ S} ((p−1)/2)/p`.
* `population_feature_mean_bounds` — hence `|S|/3 ≤ mean < |S|/2`.
* `population_dial_mean_bounds` — for the 24 odd primes `≤ 100` and any common
  period, the population-mean feature lies in `[8, 12)` and the mean adopted
  dial value in `[0.08898, 0.13522)`.  The level is a property of the
  population, the per-`N` deviation from it a property of `N`.
-/

namespace PerNPredictor

open Finset

/-- The population-mean feature on a common period. -/
theorem population_feature_mean (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2) (M : ℕ)
    (hM0 : 0 < M) (hM : ∀ p ∈ S, p ∣ M) :
    ((∑ N ∈ range M, qrFeature S N : ℕ) : ℚ) / M = ∑ p ∈ S, ((p / 2 : ℕ) : ℚ) / p := by
  rw [population_feature_sum S hS M hM]
  have hMq : (M : ℚ) ≠ 0 := by exact_mod_cast hM0.ne'
  push_cast
  rw [sum_div]
  apply sum_congr rfl
  intro p hp
  have hp0 : (p : ℚ) ≠ 0 := by exact_mod_cast (hS p hp).1.pos.ne'
  rw [Nat.cast_div (hM p hp) hp0]
  field_simp

/-- Each odd prime contributes between `1/3` and `1/2` to the mean feature. -/
theorem half_ratio_bounds (p : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    (1 : ℚ) / 3 ≤ ((p / 2 : ℕ) : ℚ) / p ∧ ((p / 2 : ℕ) : ℚ) / p < 1 / 2 := by
  have hodd : p % 2 = 1 := by
    rcases hp.eq_two_or_odd with h | h
    · exact absurd h hp2
    · exact h
  have h3 : 3 ≤ p := by have := hp.two_le; omega
  obtain ⟨k, rfl⟩ : ∃ k, p = 2 * k + 1 := ⟨p / 2, by omega⟩
  have hk : (2 * k + 1) / 2 = k := by omega
  rw [hk]
  have hk1 : (1 : ℚ) ≤ k := by exact_mod_cast (show 1 ≤ k by omega)
  have hpos : (0 : ℚ) < ((2 * k + 1 : ℕ) : ℚ) := by positivity
  push_cast at hpos ⊢
  constructor
  · rw [div_le_div_iff₀ (by norm_num) hpos]; linarith
  · rw [div_lt_div_iff₀ hpos (by norm_num)]; linarith

/-- The population-mean feature is pinned to `[|S|/3, |S|/2)` (for nonempty `S`). -/
theorem population_feature_mean_bounds (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2)
    (hSne : S.Nonempty) (M : ℕ) (hM0 : 0 < M) (hM : ∀ p ∈ S, p ∣ M) :
    (S.card : ℚ) / 3 ≤ ((∑ N ∈ range M, qrFeature S N : ℕ) : ℚ) / M ∧
      ((∑ N ∈ range M, qrFeature S N : ℕ) : ℚ) / M < (S.card : ℚ) / 2 := by
  rw [population_feature_mean S hS M hM0 hM]
  constructor
  · have := sum_le_sum fun p hp => (half_ratio_bounds p (hS p hp).1 (hS p hp).2).1
    simpa [div_eq_mul_inv, mul_comm] using this
  · have := sum_lt_sum_of_nonempty hSne fun p hp => (half_ratio_bounds p (hS p hp).1 (hS p hp).2).2
    simpa [div_eq_mul_inv, mul_comm] using this

/-- The dial is affine, so its population mean is the dial of the mean feature. -/
theorem dial_mean (S : Finset ℕ) (M : ℕ) (hM0 : 0 < M) :
    (∑ N ∈ range M, dial (qrFeature S N)) / M
      = -7 / 2000 + 289 / 25000 * (((∑ N ∈ range M, qrFeature S N : ℕ) : ℚ) / M) := by
  have hMq : (M : ℚ) ≠ 0 := by exact_mod_cast hM0.ne'
  unfold dial
  rw [sum_add_distrib, sum_const, card_range, nsmul_eq_mul, ← mul_sum]
  push_cast
  field_simp

/-- **Population level of the adopted dial** on the 24 odd primes `≤ 100`: for any
common period `M` of these primes, the mean feature is in `[8, 12)` and the mean
predicted rate in `[0.08898, 0.13522)`. -/
theorem population_dial_mean_bounds (M : ℕ) (hM0 : 0 < M) (hM : ∀ p ∈ oddPrimesLe100, p ∣ M) :
    (8 : ℚ) ≤ ((∑ N ∈ range M, qrFeature oddPrimesLe100 N : ℕ) : ℚ) / M ∧
    ((∑ N ∈ range M, qrFeature oddPrimesLe100 N : ℕ) : ℚ) / M < 12 ∧
    (4449 : ℚ) / 50000 ≤ (∑ N ∈ range M, dial (qrFeature oddPrimesLe100 N)) / M ∧
    (∑ N ∈ range M, dial (qrFeature oddPrimesLe100 N)) / M < 6761 / 50000 := by
  have hne : oddPrimesLe100.Nonempty := ⟨3, by decide⟩
  obtain ⟨h1, h2⟩ := population_feature_mean_bounds _ oddPrimesLe100_spec hne M hM0 hM
  rw [oddPrimesLe100_card] at h1 h2
  rw [show ((24 : ℕ) : ℚ) / 3 = 8 by norm_num] at h1
  rw [show ((24 : ℕ) : ℚ) / 2 = 12 by norm_num] at h2
  rw [dial_mean _ M hM0]
  refine ⟨h1, h2, ?_, ?_⟩ <;> linarith

end PerNPredictor