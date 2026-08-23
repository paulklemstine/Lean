/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Known versus unresolved cards — VI. No betting system beats a fair book

The previous files price a *fixed* menu of cards.  This file closes the loop by
letting the gambler be maximally adaptive: after every fair coin toss she may
choose a completely arbitrary new stake — of either sign, of any size, depending
on the whole history — and she may quit at any time (encoded by staking `0`).

`expGain_eq_zero` says that the expected net gain of *any* such system over any
finite horizon is exactly `0`.  This is the finite-horizon optional stopping
theorem, proved here by a two-line induction on the horizon, and it is the
strongest form of "uncertainty supplies no positive edge": not only does a
random card have no value, no adaptive scheme built out of random cards has any
value either.

The second half of the file is the standard adversarial objection — the
**doubling (martingale) system**, which wins with probability `1 - 2^{-n}` — and
its resolution: the rare loss is exactly large enough to cancel the frequent
gain.  `doubling_paradox` states the two facts side by side.

## Main results

* `expGain_eq_zero` — no adaptive betting system has an edge at fair odds.
* `optional_stopping_no_edge` — the same with an explicit stopping rule.
* `doubling_net_after_win` — the geometric-series identity `2^k - (2^k - 1) = 1`
  that makes the doubling system's net gain equal to `1` after any win.
* `E_doublingGain` — the doubling system has zero expected gain, and
* `prob_doubling_wins` — it nevertheless wins with probability `1 - 2^{-n}`.
* `doubling_paradox` — both, together with the fact that the win probability can
  be pushed arbitrarily close to `1`.
-/

import MachineLearning.KnownUnresolvedCards.Basic

namespace KnownUnresolvedCards

open Finset

/-! ## Adaptive betting systems -/

/-- Expected net gain of the adaptive system `stake` over `n` further fair
`±1` tosses, starting from the history `h`.  A stake of `0` encodes "stop", so
this covers optional stopping; the stake may be negative, so it covers switching
sides. -/
def expGain (stake : List Bool → ℚ) : ℕ → List Bool → ℚ
  | 0, _ => 0
  | (n + 1), h =>
      ((stake h + expGain stake n (h ++ [true]))
        + (-(stake h) + expGain stake n (h ++ [false]))) / 2

/-- **No betting system beats a fair book.**  For every adaptive stake function,
every horizon and every history, the expected net gain is exactly zero. -/
theorem expGain_eq_zero (stake : List Bool → ℚ) :
    ∀ (n : ℕ) (h : List Bool), expGain stake n h = 0 := by
  intro n
  induction n with
  | zero => intro h; rfl
  | succ n ih => intro h; rw [expGain, ih, ih]; ring

/-- Betting `bet h` until the stopping rule `stop` fires. -/
def stoppedStake (stop : List Bool → Bool) (bet : List Bool → ℚ) : List Bool → ℚ :=
  fun h => if stop h then 0 else bet h

/-- **Optional stopping.**  No stopping rule creates an edge either. -/
theorem optional_stopping_no_edge (stop : List Bool → Bool) (bet : List Bool → ℚ) (n : ℕ) :
    expGain (stoppedStake stop bet) n [] = 0 :=
  expGain_eq_zero _ n []

/-! ## The doubling system -/

/-- After `k` consecutive losses the gambler has lost `2^k - 1` and stakes `2^k`,
so a win leaves her exactly one unit ahead. -/
theorem doubling_net_after_win (k : ℕ) : (2 : ℚ) ^ k - ∑ j ∈ Finset.range k, (2 : ℚ) ^ j = 1 := by
  have h : ∑ j ∈ Finset.range k, (2 : ℚ) ^ j = 2 ^ k - 1 := by
    rw [geom_sum_eq (by norm_num)]
    ring
  rw [h]
  ring

/-- The all-tails outcome. -/
def allFalse (n : ℕ) : Fin n → Bool := fun _ => false

/-- Net gain of the doubling system over a horizon of `n` fair tosses: by
`doubling_net_after_win` it is `+1` as soon as one toss comes up heads, and
`-(2^n - 1)` on the single all-tails outcome. -/
noncomputable def doublingGain (n : ℕ) (w : Fin n → Bool) : ℚ :=
  if w = allFalse n then -(2 ^ n - 1) else 1

theorem sum_doublingGain (n : ℕ) : ∑ w : Fin n → Bool, doublingGain n w = 0 := by
  classical
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ (allFalse n))]
  have h1 : doublingGain n (allFalse n) = -(2 ^ n - 1) := by simp [doublingGain]
  have h2 : ∀ w ∈ (univ : Finset (Fin n → Bool)).erase (allFalse n), doublingGain n w = 1 := by
    intro w hw
    have hne : w ≠ allFalse n := (Finset.mem_erase.mp hw).1
    simp [doublingGain, hne]
  rw [h1, Finset.sum_congr rfl h2, Finset.sum_const, Finset.card_erase_of_mem (Finset.mem_univ _),
    Finset.card_univ]
  simp

/-- **The doubling system is fair.**  Its expected net gain is exactly zero. -/
theorem E_doublingGain (n : ℕ) : E (doublingGain n) = 0 := by
  rw [E_def, sum_doublingGain, zero_div]

/-- **…yet it wins with probability `1 - 2^{-n}`.** -/
theorem prob_doubling_wins (n : ℕ) :
    E (fun w : Fin n → Bool => if 0 < doublingGain n w then (1 : ℚ) else 0) = 1 - (1 / 2) ^ n := by
  classical
  have hpos : ∀ w : Fin n → Bool, (0 < doublingGain n w) ↔ w ≠ allFalse n := by
    intro w
    by_cases h : w = allFalse n
    · subst h
      simp only [doublingGain, ne_eq, not_true_eq_false, iff_false, not_lt, if_pos]
      have : (1 : ℚ) ≤ 2 ^ n := one_le_pow₀ (by norm_num)
      linarith
    · simp [doublingGain, h]
  have hsum : ∑ w : Fin n → Bool, (if 0 < doublingGain n w then (1 : ℚ) else 0)
      = ((2 : ℚ) ^ n - 1) := by
    rw [Finset.sum_congr rfl (fun w _ => by rw [if_congr (hpos w) rfl rfl])]
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ (allFalse n))]
    rw [if_neg (by simp)]
    rw [Finset.sum_congr rfl (fun w hw => if_pos (Finset.mem_erase.mp hw).1)]
    rw [Finset.sum_const, Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ]
    simp
  rw [E_def, hsum]
  have hc : (Fintype.card (Fin n → Bool) : ℚ) = 2 ^ n := by simp
  rw [hc]
  have h2 : ((2 : ℚ) ^ n) ≠ 0 := by positivity
  have h3 : ((1 : ℚ) / 2) ^ n * 2 ^ n = 1 := by rw [← mul_pow]; norm_num
  field_simp
  linarith

/-- **The doubling paradox, resolved.**  The system wins with a probability that
can be pushed arbitrarily close to certainty, and its expected gain is
nevertheless exactly zero: the improbable loss is exactly as large as the
probable gain is likely.  A high win rate is not an edge. -/
theorem doubling_paradox (eps : ℚ) (heps : 0 < eps) :
    ∃ n : ℕ, E (doublingGain n) = 0
      ∧ 1 - eps < E (fun w : Fin n → Bool => if 0 < doublingGain n w then (1 : ℚ) else 0) := by
  obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one heps (by norm_num : (1 : ℚ) / 2 < 1)
  refine ⟨n, E_doublingGain n, ?_⟩
  rw [prob_doubling_wins n]
  linarith

end KnownUnresolvedCards