/-
# The sharpened Condorcet rate: the miss is its own next ladder step, divided by `(2p-1)²`

`Probability.SeedCondorcetConvergence` proved the elementary rate
`1 - rungProb (2r+1) (r+1) p ≤ 2(1-p)(4p(1-p))^r`, whose only input about Pascal's row is the
crude count `∑_{j ≤ r} C(2r+1,j) ≤ 2^(2r+1)`.  Conjecture **C3** of the previous cycle's
`FUTURE_DIRECTIONS.md` asserted that this loses a factor `Θ(√r)`, because the low tail is
dominated by its single largest term, and predicted that repairing it would cut the certified
seed count at the measured frequency `p = 2/3` from `73` to about `49`.

This file closes C3 in the strong (upper-bound) direction, without any Stirling asymptotics:
replacing the crude row count by the *middle binomial* bound `C(2r+1,j) ≤ C(2r+1,r)`
(`Nat.choose_le_middle`) and summing the resulting geometric series exactly gives

  `1 - rungProb (2r+1) (r+1) p ≤ C(2r+1,r)·(p(1-p))^(r+1)/(2p-1)`.

Main results.

* `SeedSharpRate.condorcet_rate_sharp` — the bound above, for every `1/2 < p ≤ 1`.
* `SeedSharpRate.sharp_bound_eq_gap_div_sq` — **the structural reading.**  The right-hand side
  is exactly `gap p r / (2p-1)²`, where `gap p r` is the next step of the Condorcet ladder
  (`SeedLadderGF.gap`, a single monomial by `SeedCondorcet.median_rung_gap`).  So an ensemble's
  distance from certainty is controlled by the *increment* it is about to make: the ladder
  measures its own remaining distance, up to the fixed factor `(2p-1)^{-2}`.
* `SeedSharpRate.condorcet_rate_lower` and `sharp_bound_tight` — a matching lower bound: the
  miss is at least the single largest tail term, and the sharpened bound is exactly
  `p/(2p-1)` times that term.  So the bound is tight up to a fixed factor (`2` at the measured
  `p = 2/3`), and any further gain must come from a sharper estimate of `C(2r+1,r)`, not from
  the summation.
* `SeedSharpRate.sharp_le_crude` — the sharpened bound beats the old one whenever
  `p ≥ 2/3`, via the elementary row bound `C(2r+1,r) ≤ 4^r` (`choose_odd_le_four_pow`); at
  `p = 2/3` and `r = 0` the two agree exactly (`net48_sharp_vs_crude_zero`), and they separate
  from the first ladder step on.  Near the coin flip the sharpened bound blows up like
  `(2p-1)^{-1}`, so the two are complementary.
* `SeedSharpRate.net48_sharp_49_seeds` — at the measured `p = 2/3` the sharpened bound
  certifies `1 %` already at `r = 24`, i.e. **49 seeds** instead of the `73` the crude bound
  needed: `24` seeds — roughly four days of training at the round's `~4 h` per seed — saved.
* `SeedSharpRate.net48_sharp_47_insufficient` — and it does not reach `1 %` at `47` seeds, so
  `49` is the honest reading of this argument.  The true crossing is at `47`
  (`Probability.SeedExactCrossing`, where the exact low tails are computed): the sharpened
  bound is within one ladder step of the truth, where the crude one was `13` steps away.
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Probability.SeedCondorcetLadder
import Probability.SeedCondorcetConvergence
import Probability.SeedLadderGeneratingFunction

namespace SeedSharpRate

open Finset SeedQuota SeedCondorcet SeedCondorcetRate

/-! ## 1.  The sharpened rate -/

/-- **The sharpened Condorcet rate.**  Dominating every low-tail binomial coefficient by the
middle one and summing the remaining geometric series exactly. -/
theorem condorcet_rate_sharp (r : ℕ) {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    1 - rungProb (2 * r + 1) (r + 1) p
      ≤ ((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ (r + 1) / (2 * p - 1) := by
  have hp0 : (0:ℝ) < p := by linarith
  have hq0 : (0:ℝ) ≤ 1 - p := by linarith
  have hd : (0:ℝ) < 2 * p - 1 := by linarith
  have hC0 : (0:ℝ) ≤ ((2 * r + 1).choose r : ℝ) := Nat.cast_nonneg _
  rw [one_sub_rungProb (2 * r + 1) (r + 1) p (by omega)]
  -- Step 1: dominate every coefficient of the low tail by the middle one.
  have hterm : ∀ j ∈ range (r + 1),
      ((2 * r + 1).choose j : ℝ) * p ^ j * (1 - p) ^ (2 * r + 1 - j)
        ≤ ((2 * r + 1).choose r : ℝ) * ((1 - p) ^ (r + 1) * (p ^ j * (1 - p) ^ (r - j))) := by
    intro j hj
    simp only [Finset.mem_range] at hj
    have hchoose : ((2 * r + 1).choose j : ℝ) ≤ ((2 * r + 1).choose r : ℝ) := by
      have hm := Nat.choose_le_middle j (2 * r + 1)
      rw [show (2 * r + 1) / 2 = r by omega] at hm
      exact_mod_cast hm
    have hexp : 2 * r + 1 - j = (r - j) + (r + 1) := by omega
    have hnn : (0:ℝ) ≤ p ^ j * ((1 - p) ^ (r - j) * (1 - p) ^ (r + 1)) := by positivity
    calc ((2 * r + 1).choose j : ℝ) * p ^ j * (1 - p) ^ (2 * r + 1 - j)
        = ((2 * r + 1).choose j : ℝ) * (p ^ j * ((1 - p) ^ (r - j) * (1 - p) ^ (r + 1))) := by
          rw [hexp, pow_add]; ring
      _ ≤ ((2 * r + 1).choose r : ℝ) * (p ^ j * ((1 - p) ^ (r - j) * (1 - p) ^ (r + 1))) :=
          mul_le_mul_of_nonneg_right hchoose hnn
      _ = ((2 * r + 1).choose r : ℝ) * ((1 - p) ^ (r + 1) * (p ^ j * (1 - p) ^ (r - j))) := by
          ring
  have hsum : ∑ j ∈ range (r + 1), ((2 * r + 1).choose j : ℝ) * p ^ j * (1 - p) ^ (2 * r + 1 - j)
      ≤ ∑ j ∈ range (r + 1),
          ((2 * r + 1).choose r : ℝ) * ((1 - p) ^ (r + 1) * (p ^ j * (1 - p) ^ (r - j))) :=
    Finset.sum_le_sum hterm
  -- Step 2: the remaining sum is a geometric series in `p` and `1 - p`.
  set S : ℝ := ∑ j ∈ range (r + 1), p ^ j * (1 - p) ^ (r - j) with hS
  have hfactor : ∑ j ∈ range (r + 1),
      ((2 * r + 1).choose r : ℝ) * ((1 - p) ^ (r + 1) * (p ^ j * (1 - p) ^ (r - j)))
      = ((2 * r + 1).choose r : ℝ) * (1 - p) ^ (r + 1) * S := by
    rw [hS, Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by ring
  have hgeom : S * (p - (1 - p)) = p ^ (r + 1) - (1 - p) ^ (r + 1) := by
    have := geom_sum₂_mul p (1 - p) (r + 1)
    simpa [hS, Nat.add_sub_cancel] using this
  have hSle : S * (2 * p - 1) ≤ p ^ (r + 1) := by
    have hpow : (0:ℝ) ≤ (1 - p) ^ (r + 1) := by positivity
    have : S * (2 * p - 1) = p ^ (r + 1) - (1 - p) ^ (r + 1) := by
      rw [← hgeom]; ring
    linarith
  -- Step 3: assemble.
  rw [le_div_iff₀ hd]
  have hCq : (0:ℝ) ≤ ((2 * r + 1).choose r : ℝ) * (1 - p) ^ (r + 1) := by positivity
  have hmul : (((2 * r + 1).choose r : ℝ) * (1 - p) ^ (r + 1)) * (S * (2 * p - 1))
      ≤ (((2 * r + 1).choose r : ℝ) * (1 - p) ^ (r + 1)) * p ^ (r + 1) :=
    mul_le_mul_of_nonneg_left hSle hCq
  have hprod : ((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ (r + 1)
      = (((2 * r + 1).choose r : ℝ) * (1 - p) ^ (r + 1)) * p ^ (r + 1) := by
    rw [mul_pow]; ring
  calc (∑ j ∈ range (r + 1), ((2 * r + 1).choose j : ℝ) * p ^ j * (1 - p) ^ (2 * r + 1 - j))
        * (2 * p - 1)
      ≤ (((2 * r + 1).choose r : ℝ) * (1 - p) ^ (r + 1) * S) * (2 * p - 1) := by
        have := mul_le_mul_of_nonneg_right (hsum.trans_eq hfactor) hd.le
        exact this
    _ = (((2 * r + 1).choose r : ℝ) * (1 - p) ^ (r + 1)) * (S * (2 * p - 1)) := by ring
    _ ≤ (((2 * r + 1).choose r : ℝ) * (1 - p) ^ (r + 1)) * p ^ (r + 1) := hmul
    _ = ((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ (r + 1) := hprod.symm

/-! ## 2.  The structural reading: the miss is the next ladder step, rescaled -/

/-- **The bound is the next ladder step divided by `(2p-1)²`.**  `SeedLadderGF.gap p r` is the
increment the centre makes when two more seeds are added; the sharpened rate says the centre's
whole remaining distance to certainty is at most that single increment, rescaled by the fixed
factor `(2p-1)^{-2}`.  With `SeedLadderGF.hasSum_gap` (the ladder sums to `1 - p`) this pins
the geometry of the ladder: each step controls the entire tail above it. -/
theorem sharp_bound_eq_gap_div_sq (r : ℕ) {p : ℝ} (h : 1/2 < p) :
    ((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ (r + 1) / (2 * p - 1)
      = SeedLadderGF.gap p r / (2 * p - 1) ^ 2 := by
  have hd : (2 * p - 1) ≠ 0 := by intro hc; linarith [hc]
  rw [SeedLadderGF.gap_eq_monomial]
  field_simp

/-- Consequently the miss probability is at most the next ladder step, rescaled. -/
theorem miss_le_gap_div_sq (r : ℕ) {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    1 - rungProb (2 * r + 1) (r + 1) p ≤ SeedLadderGF.gap p r / (2 * p - 1) ^ 2 := by
  rw [← sharp_bound_eq_gap_div_sq r h]
  exact condorcet_rate_sharp r h h1

/-! ## 3.  A matching lower bound: the sharpened rate is tight up to `p/(2p-1)` -/

/-- **The largest low-tail term is a lower bound.**  The miss probability is at least the
single term `j = r` of the tail. -/
theorem condorcet_rate_lower (r : ℕ) {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    ((2 * r + 1).choose r : ℝ) * p ^ r * (1 - p) ^ (r + 1)
      ≤ 1 - rungProb (2 * r + 1) (r + 1) p := by
  have hp0 : (0:ℝ) < p := by linarith
  have hq0 : (0:ℝ) ≤ 1 - p := by linarith
  rw [one_sub_rungProb (2 * r + 1) (r + 1) p (by omega)]
  have hmem : r ∈ range (r + 1) := by simp
  have hle := Finset.single_le_sum
    (f := fun j => ((2 * r + 1).choose j : ℝ) * p ^ j * (1 - p) ^ (2 * r + 1 - j))
    (fun j hj => by positivity) hmem
  simpa [show 2 * r + 1 - r = r + 1 by omega] using hle

/-- **The sharpened bound is tight up to the factor `p/(2p-1)`.**  Truth and bound differ by
at most that fixed factor, independently of `r`: at the measured `p = 2/3` it is `2`, which is
exactly why the certified count `49` sits one ladder step above the true crossing `47`
(`Probability.SeedExactCrossing`).  In particular no further gain is available from the
geometric summation itself — only from a sharper estimate of `C(2r+1,r)`. -/
theorem sharp_bound_tight (r : ℕ) {p : ℝ} (h : 1/2 < p) :
    ((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ (r + 1) / (2 * p - 1)
      = (p / (2 * p - 1)) * (((2 * r + 1).choose r : ℝ) * p ^ r * (1 - p) ^ (r + 1)) := by
  have hd : (2 * p - 1) ≠ 0 := by intro hc; linarith [hc]
  rw [mul_pow]
  field_simp
  ring

/-! ## 4.  Comparison with the crude bound -/

/-- **Half a Pascal row.**  The odd central binomial coefficient never exceeds `4^r`: it is
half of a pair of equal entries of a row summing to `2^(2r+1)`.  This is the elementary
input that makes the sharpened bound comparable to the crude one. -/
theorem choose_odd_le_four_pow (r : ℕ) : (2 * r + 1).choose r ≤ 4 ^ r := by
  have hpair : ({r, r + 1} : Finset ℕ) ⊆ range (2 * r + 2) := by
    intro j hj
    simp only [Finset.mem_insert, Finset.mem_singleton] at hj
    simp only [Finset.mem_range]
    omega
  have hsum : ∑ j ∈ ({r, r + 1} : Finset ℕ), (2 * r + 1).choose j
      ≤ ∑ j ∈ range (2 * r + 2), (2 * r + 1).choose j :=
    Finset.sum_le_sum_of_subset hpair
  have hpairsum : ∑ j ∈ ({r, r + 1} : Finset ℕ), (2 * r + 1).choose j
      = (2 * r + 1).choose r + (2 * r + 1).choose (r + 1) :=
    Finset.sum_pair (by omega)
  have hsymm : (2 * r + 1).choose (r + 1) = (2 * r + 1).choose r := by
    have hs := Nat.choose_symm (show r ≤ 2 * r + 1 by omega)
    rw [show 2 * r + 1 - r = r + 1 by omega] at hs
    exact hs
  have htot : ∑ j ∈ range (2 * r + 2), (2 * r + 1).choose j = 2 ^ (2 * r + 1) :=
    Nat.sum_range_choose (2 * r + 1)
  have hpow : (2:ℕ) ^ (2 * r + 1) = 2 * 4 ^ r := by
    rw [pow_succ, pow_mul]
    ring
  rw [hpairsum, hsymm, htot, hpow] at hsum
  omega

/-- **The sharpened bound beats the crude one for every `p ≥ 2/3`.**  Two independent gains
combine: the middle binomial coefficient is at most `4^r` (`choose_odd_le_four_pow`), and the
geometric summation replaces the row count by the factor `p/(2p-1) ≤ 2` available once the
per-seed majority is at least `2/3`.  (Near the coin flip the sharpened bound blows up like
`(2p-1)^{-1}`, so the crude bound remains the right one there — the two are genuinely
complementary.) -/
theorem sharp_le_crude (r : ℕ) {p : ℝ} (h : 2/3 ≤ p) (h1 : p ≤ 1) :
    ((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ (r + 1) / (2 * p - 1)
      ≤ 2 * (1 - p) * (4 * p * (1 - p)) ^ r := by
  have hd : (0:ℝ) < 2 * p - 1 := by linarith
  have hp0 : (0:ℝ) < p := by linarith
  have hq0 : (0:ℝ) ≤ 1 - p := by linarith
  have hpq : (0:ℝ) ≤ (p * (1 - p)) ^ r := by positivity
  have hC : ((2 * r + 1).choose r : ℝ) ≤ (4:ℝ) ^ r := by
    have := choose_odd_le_four_pow r
    exact_mod_cast this
  rw [div_le_iff₀ hd, show (4 * p * (1 - p)) ^ r = 4 ^ r * (p * (1 - p)) ^ r by
    rw [show 4 * p * (1 - p) = 4 * (p * (1 - p)) by ring, mul_pow], pow_succ]
  have hstep : ((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ r
      ≤ (4:ℝ) ^ r * (p * (1 - p)) ^ r := mul_le_mul_of_nonneg_right hC hpq
  have hbase : (0:ℝ) ≤ (4:ℝ) ^ r * (p * (1 - p)) ^ r := by positivity
  have hu : (0:ℝ) ≤ p * (1 - p) := by positivity
  calc ((2 * r + 1).choose r : ℝ) * ((p * (1 - p)) ^ r * (p * (1 - p)))
      = (((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ r) * (p * (1 - p)) := by ring
    _ ≤ ((4:ℝ) ^ r * (p * (1 - p)) ^ r) * (p * (1 - p)) :=
        mul_le_mul_of_nonneg_right hstep hu
    _ ≤ 2 * (1 - p) * ((4:ℝ) ^ r * (p * (1 - p)) ^ r) * (2 * p - 1) := by
        nlinarith [mul_nonneg hbase (mul_nonneg hq0 (by linarith : (0:ℝ) ≤ 3 * p - 2))]

/-- At `r = 0` — a single seed — the two bounds agree exactly at `p = 2/3`. -/
theorem net48_sharp_vs_crude_zero :
    ((2 * 0 + 1).choose 0 : ℝ) * ((2/3 : ℝ) * (1 - 2/3)) ^ (0 + 1) / (2 * (2/3 : ℝ) - 1)
      = 2 * (1 - (2/3 : ℝ)) * (4 * (2/3) * (1 - (2/3 : ℝ))) ^ 0 := by
  norm_num

/-! ## 5.  Lab notes: the certified seed count at the measured frequency -/

private theorem choose_49_24 : Nat.choose 49 24 = 63205303218876 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

private theorem choose_47_23 : Nat.choose 47 23 = 16123801841550 := by
  rw [Nat.choose_eq_descFactorial_div_factorial]
  norm_num [Nat.descFactorial, Nat.factorial]

/-- **49 seeds, not 73.**  At the measured per-seed frequency `p = 2/3` the sharpened bound
certifies the median rung to within `1 %` of certainty at `r = 24`, i.e. an ensemble of
`2·24+1 = 49` seeds — `24` fewer than the crude bound's `73`
(`SeedCondorcetRate.net48_seeds_for_one_percent`). -/
theorem net48_sharp_49_seeds :
    1 - rungProb (2 * 24 + 1) (24 + 1) (2/3 : ℝ) ≤ 1/100 := by
  have hb := condorcet_rate_sharp 24 (p := (2/3 : ℝ)) (by norm_num) (by norm_num)
  have hc : ((2 * 24 + 1).choose 24 : ℝ) = 63205303218876 := by
    rw [show 2 * 24 + 1 = 49 from rfl, choose_49_24]; norm_num
  rw [hc] at hb
  refine hb.trans ?_
  norm_num

/-- …and the sharpened bound does *not* reach `1 %` at `47` seeds, so `49` is the honest
reading of this argument — one ladder step above the exact crossing point. -/
theorem net48_sharp_47_insufficient :
    (1/100 : ℝ)
      < ((2 * 23 + 1).choose 23 : ℝ) * ((2/3 : ℝ) * (1 - 2/3)) ^ (23 + 1) / (2 * (2/3 : ℝ) - 1) := by
  have hc : ((2 * 23 + 1).choose 23 : ℝ) = 16123801841550 := by
    rw [show 2 * 23 + 1 = 47 from rfl, choose_47_23]; norm_num
  rw [hc]
  norm_num

end SeedSharpRate