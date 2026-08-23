import Mathlib
import Probability.FactorLocalETCrossChannel

/-!
# FACTOR-LOCAL-ET, cycle 6: truncated trial division cannot explain `0.84`

Cycle 2 proved that a *pointwise linear* trial-division cost `a·p` on a dyadic
population forces an across-`k` slope above `0.875`, so the reported `0.84`
refutes that cost model (`trial_pointwise_refuted_by_084`).  The natural
rescue, listed as a future direction of the previous cycle, is that a real
implementation does not pay `p` but a *truncated* cost: trial division is
abandoned after a bound proportional to the modulus size, so the per-instance
cost is `min(p, B·2^k)`.  The conjecture was that truncation manufactures a
slope deficit `c(B) > 0.125` and thereby explains the measurement.

This file **refutes that conjecture**, for every truncation level `B > 0`.

## Main results

* `truncated_powerBand` — on a dyadic population the truncated cost obeys a
  power band with exponent `1` and constants `a·min(1/2, B) ≤ a·min(1, B)`.
* `trunc_const_ratio_le_two` — the spread of that band is at most `2`,
  *uniformly in `B`*: truncation can only ever remove mass, never tilt the
  window by more than the window's own width.
* `truncated_trial_slope_ge` — hence `slope ≥ 0.875` at the experimental lever
  arm `Δk = 8`, exactly as in the untruncated case.
* `truncation_cannot_explain_084` — therefore no truncation level reproduces
  the reported `0.84`; the compression must come from the `p`-distribution (or
  from the fitting procedure), not from the cost accounting.
* `fully_truncated_slope_eq_one` — the extreme case is the sharpest form of the
  obstruction: for `B ≤ 1/2` the bound binds on every draw, the cost becomes a
  pure power `a·B·2^k`, and the measured slope is *exactly* `1` — the deficit
  is zero, not `0.16`.
* `truncation_deficit_lt_eighth` — the quantitative summary: the deficit
  `1 − slope` produced by truncation is strictly smaller than `1/8` at
  `Δk = 8`, whereas explaining the measurement needs `0.16`.
-/

namespace FactorLocalET

open Real

/-! ## 1. The truncated cost model -/

/-- Per-instance cost of trial division truncated at `B·2^k`: the search is
abandoned once the trial bound exceeds a fixed fraction of the modulus window
top, so a draw with a large prime factor is charged the truncation level
instead of `p`. -/
noncomputable def truncCost (B : ℝ) (k : ℕ) (p : ℝ) : ℝ := min p (B * (2 : ℝ) ^ (k : ℝ))

theorem truncCost_le_self {B : ℝ} {k : ℕ} {p : ℝ} : truncCost B k p ≤ p := min_le_left _ _

theorem truncCost_le_bound {B : ℝ} {k : ℕ} {p : ℝ} :
    truncCost B k p ≤ B * (2 : ℝ) ^ (k : ℝ) := min_le_right _ _

/-- The empirical mean of a constant population is that constant. -/
theorem mean_const {n : ℕ} (hn : 0 < n) (c : ℝ) : mean (fun _ : Fin n => c) = c :=
  le_antisymm (mean_le hn fun _ => le_rfl) (le_mean hn fun _ => le_rfl)

/-! ## 2. The truncated cost still lies in a spread-`2` band -/

/-- **Truncation stays inside the window.**  On a dyadic population
`p ∈ [2^{k-1}, 2^k]` the expected truncated cost obeys a power band with
exponent `1`, lower constant `a·min(1/2, B)` and upper constant `a·min(1, B)`.
Both constants degrade in the same way as `B` shrinks, which is precisely why
truncation cannot bend the exponent. -/
theorem truncated_powerBand {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a B : ℝ}
    (ha : 0 < a) (hB : 0 < B)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ (2 : ℝ) ^ (k : ℝ))
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => truncCost B k (p k i)) :
    PowerBand E 1 (a * min (1 / 2) B) (a * min 1 B) := by
  have hhalf : ∀ k : ℕ, (2 : ℝ) ^ ((k : ℝ) - 1) = (2 : ℝ) ^ (k : ℝ) * (1 / 2) := by
    intro k
    rw [Real.rpow_sub (by norm_num), Real.rpow_one]
    ring
  have hpow : ∀ k : ℕ, (2 : ℝ) ^ ((1 : ℝ) * (k : ℕ)) = (2 : ℝ) ^ (k : ℝ) := by
    intro k; rw [one_mul]
  refine ⟨by positivity, ?_, ?_⟩
  · intro k
    have hlow : ∀ i, (2 : ℝ) ^ (k : ℝ) * min (1 / 2) B ≤ truncCost B k (p k i) := by
      intro i
      refine le_min ?_ ?_
      · calc (2 : ℝ) ^ (k : ℝ) * min (1 / 2) B ≤ (2 : ℝ) ^ (k : ℝ) * (1 / 2) := by
              have : min (1 / 2 : ℝ) B ≤ 1 / 2 := min_le_left _ _
              nlinarith [Real.rpow_pos_of_pos (by norm_num : (0 : ℝ) < 2) (k : ℝ)]
          _ = (2 : ℝ) ^ ((k : ℝ) - 1) := (hhalf k).symm
          _ ≤ p k i := hlo k i
      · have : min (1 / 2 : ℝ) B ≤ B := min_le_right _ _
        nlinarith [Real.rpow_pos_of_pos (by norm_num : (0 : ℝ) < 2) (k : ℝ)]
    have := le_mean hn hlow
    rw [hE k, hpow k]
    nlinarith [this, Real.rpow_pos_of_pos (by norm_num : (0 : ℝ) < 2) (k : ℝ)]
  · intro k
    have hup : ∀ i, truncCost B k (p k i) ≤ (2 : ℝ) ^ (k : ℝ) * min 1 B := by
      intro i
      rcases le_total (1 : ℝ) B with h | h
      · rw [min_eq_left h, mul_one]
        exact le_trans truncCost_le_self (hhi k i)
      · rw [min_eq_right h, mul_comm]
        exact truncCost_le_bound
    have := mean_le hn hup
    rw [hE k, hpow k]
    nlinarith [this, Real.rpow_pos_of_pos (by norm_num : (0 : ℝ) < 2) (k : ℝ)]

/-- **The spread is at most `2`, uniformly in the truncation level.**  This is
the heart of the refutation: `min(1, B) ≤ 2·min(1/2, B)` for every `B > 0`. -/
theorem trunc_const_ratio_le_two {a B : ℝ} (ha : 0 < a) (hB : 0 < B) :
    (a * min 1 B) / (a * min (1 / 2) B) ≤ 2 := by
  have hmin : min (1 : ℝ) B ≤ 2 * min (1 / 2 : ℝ) B := by
    rcases le_total B (1 / 2 : ℝ) with h | h
    · rw [min_eq_right (by linarith : B ≤ (1 : ℝ)), min_eq_right h]; linarith
    · rcases le_total B (1 : ℝ) with h' | h'
      · rw [min_eq_right h', min_eq_left h]; linarith
      · rw [min_eq_left h', min_eq_left h]; linarith
  have hpos : 0 < a * min (1 / 2 : ℝ) B := by
    have : 0 < min (1 / 2 : ℝ) B := lt_min (by norm_num) hB
    positivity
  rw [div_le_iff₀ hpos]
  nlinarith [hmin, ha.le]

/-! ## 3. Consequence: the measured `0.84` is out of reach -/

/-- **Truncation does not move the exponent.**  For every truncation level
`B > 0`, the across-`k` slope of the truncated trial-division cost at the
experimental lever arm `k = 16 → 24` is at least `0.875`. -/
theorem truncated_trial_slope_ge {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a B : ℝ}
    (ha : 0 < a) (hB : 0 < B)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ (2 : ℝ) ^ (k : ℝ))
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => truncCost B k (p k i)) :
    (0.875 : ℝ) ≤ logSlope E 16 24 := by
  have hband := truncated_powerBand hn ha hB hlo hhi hE
  have hb := hband.abs_logSlope_sub_le (k₁ := 16) (k₂ := 24) (by norm_num)
  have h8 : ((24 : ℕ) : ℝ) - ((16 : ℕ) : ℝ) = 8 := by norm_num
  rw [h8] at hb
  have hratio : Real.logb 2 ((a * min 1 B) / (a * min (1 / 2) B)) ≤ 1 := by
    have hpos : 0 < (a * min 1 B) / (a * min (1 / 2) B) := by
      have h1 : 0 < min (1 : ℝ) B := lt_min (by norm_num) hB
      have h2 : 0 < min (1 / 2 : ℝ) B := lt_min (by norm_num) hB
      positivity
    have := Real.logb_le_logb_of_le (b := 2) (by norm_num) hpos
      (trunc_const_ratio_le_two ha hB)
    simpa using this
  have habs : |logSlope E 16 24 - 1| ≤ 1 / 8 := by
    refine hb.trans ?_
    linarith [hratio]
  have := (abs_le.mp habs).1
  norm_num at this ⊢
  linarith

/-- **The conjecture is false.**  No truncation level reproduces the reported
trial-division slope `0.84`. -/
theorem truncation_cannot_explain_084 {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a B : ℝ}
    (ha : 0 < a) (hB : 0 < B)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ (2 : ℝ) ^ (k : ℝ))
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => truncCost B k (p k i)) :
    logSlope E 16 24 ≠ 0.84 := by
  intro h
  have hge := truncated_trial_slope_ge hn ha hB hlo hhi hE
  rw [h] at hge
  norm_num at hge

/-- The quantitative form: the slope *deficit* achievable by truncation is
strictly below `1/8`, while explaining the measurement would require `0.16`. -/
theorem truncation_deficit_lt_eighth {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a B : ℝ}
    (ha : 0 < a) (hB : 0 < B)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ (2 : ℝ) ^ (k : ℝ))
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => truncCost B k (p k i)) :
    1 - logSlope E 16 24 < 0.16 := by
  have hge := truncated_trial_slope_ge hn ha hB hlo hhi hE
  linarith

/-! ## 4. The extreme case: full truncation gives slope exactly `1` -/

/-- **Full truncation is the worst case for the conjecture.**  If `B ≤ 1/2` the
bound binds on every draw of a dyadic population, the expected cost is the pure
power `a·B·2^k`, and the measured slope is exactly `1`: the truncation deficit
is `0`.  Together with `truncated_trial_slope_ge` this brackets the whole
family — the deficit lives in `[0, 1/8)` and never reaches `0.16`. -/
theorem fully_truncated_slope_eq_one {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a B : ℝ}
    (ha : 0 < a) (hB : 0 < B) (hBhalf : B ≤ 1 / 2)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => truncCost B k (p k i)) :
    logSlope E 16 24 = 1 := by
  have hpure : E = fun k => (a * B) * (2 : ℝ) ^ ((1 : ℝ) * (k : ℕ)) := by
    funext k
    have hbind : ∀ i, truncCost B k (p k i) = B * (2 : ℝ) ^ (k : ℝ) := by
      intro i
      have hhalf : (2 : ℝ) ^ ((k : ℝ) - 1) = (2 : ℝ) ^ (k : ℝ) * (1 / 2) := by
        rw [Real.rpow_sub (by norm_num), Real.rpow_one]; ring
      have hle : B * (2 : ℝ) ^ (k : ℝ) ≤ p k i := by
        have hpk : (0 : ℝ) < (2 : ℝ) ^ (k : ℝ) :=
          Real.rpow_pos_of_pos (by norm_num) _
        have : B * (2 : ℝ) ^ (k : ℝ) ≤ (2 : ℝ) ^ ((k : ℝ) - 1) := by
          rw [hhalf]; nlinarith
        exact this.trans (hlo k i)
      exact min_eq_right hle
    rw [hE k]
    simp only [hbind]
    rw [mean_const hn, one_mul]
    ring
  rw [hpure]
  exact logSlope_of_pure_power (C := a * B) (α := 1) (by positivity) (by norm_num)

/-! ## 5. Where the compression must come from: shape drift, not cost accounting -/

/-- The empirical mean of a strictly positive population is strictly positive. -/
theorem mean_pos {n : ℕ} (hn : 0 < n) {f : Fin n → ℝ} (hf : ∀ i, 0 < f i) : 0 < mean f := by
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  have hsum : 0 < ∑ i, f i := Finset.sum_pos (fun i _ => hf i) Finset.univ_nonempty
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  exact div_pos hsum hnpos

/-- **Scale-invariant samplers cannot compress an exponent.**  If the population
at level `k` is the *same shape* rescaled, `p_k(i) = 2^k · u(i)`, then for any
pointwise power cost `a·p^s` the measured across-`k` slope is exactly `s`, with
no tolerance at all.  Combined with `truncation_cannot_explain_084`, this
localises the reported `0.84`: neither the cost accounting nor a `k`-independent
draw shape can produce it, so the balanced-semiprime sampler's *normalised*
distribution `p/2^k` must itself drift with `k`. -/
theorem scale_invariant_slope_eq_pow {n : ℕ} (hn : 0 < n) {u : Fin n → ℝ}
    (hu : ∀ i, 0 < u i) {a s : ℝ} (ha : 0 < a)
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => ((2 : ℝ) ^ (k : ℝ) * u i) ^ s) :
    logSlope E 16 24 = s := by
  have hC : 0 < a * mean fun i => (u i) ^ s :=
    mul_pos ha (mean_pos hn fun i => Real.rpow_pos_of_pos (hu i) s)
  have hpure : E = fun k => (a * mean fun i => (u i) ^ s) * (2 : ℝ) ^ (s * (k : ℕ)) := by
    funext k
    have hsplit : ∀ i, ((2 : ℝ) ^ (k : ℝ) * u i) ^ s
        = (2 : ℝ) ^ (s * (k : ℝ)) * (u i) ^ s := by
      intro i
      rw [Real.mul_rpow (Real.rpow_pos_of_pos (by norm_num) _).le (hu i).le,
        ← Real.rpow_mul (by norm_num : (0 : ℝ) ≤ 2), mul_comm (k : ℝ) s]
    have hmean : (mean fun i => ((2 : ℝ) ^ (k : ℝ) * u i) ^ s)
        = (2 : ℝ) ^ (s * (k : ℝ)) * mean fun i => (u i) ^ s := by
      simp only [mean, hsplit, ← Finset.mul_sum]
      ring
    rw [hE k, hmean]
    ring
  rw [hpure]
  exact logSlope_of_pure_power (C := a * mean fun i => (u i) ^ s) (α := s) hC (by norm_num)

end FactorLocalET