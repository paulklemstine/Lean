/-
# The Condorcet ladder sums exactly, and its generating function is the central binomial one

`Probability.SeedCondorcetLadder` proved that the step of the ladder is a single monomial,
`rungProb (2r+3) (r+2) p - rungProb (2r+1) (r+1) p = C(2r+1,r)·p^(r+1)(1-p)^(r+1)(2p-1)`
(`SeedCondorcet.median_rung_gap`), and `Probability.SeedCondorcetConvergence` proved that the
median rung tends to `1` geometrically for `p > 1/2`.  Conjecture **C4** of the previous
cycle's `FUTURE_DIRECTIONS.md` asked whether the ladder therefore *sums exactly*, and whether
that sum is the analytic shadow of the central binomial generating function.  This file
proves both, and in the direction the conjecture did not anticipate: the probabilistic ladder
**implies** the generating function, rather than needing it.

Main results.

* `SeedLadderGF.sum_range_gap` — the ladder telescopes:
  `∑_{r < R} gap p r = rungProb (2R+1) (R+1) p - p`.
* `SeedLadderGF.hasSum_gap` — for `1/2 < p ≤ 1` the ladder is summable with
  `∑' r, gap p r = 1 - p` exactly: the total amplification available to an ensemble is
  precisely the per-seed miss probability, no tail estimate needed.
* `SeedLadderGF.hasSum_centralBinomOdd` — **C4's generating function.**  For `0 < x < 1/4`,
  `∑' r, C(2r+1,r)·x^(r+1) = (1/2)·(1/√(1-4x) - 1)`, obtained by substituting
  `p = (1 + √(1-4x))/2`, for which `p(1-p) = x` and `2p - 1 = √(1-4x)`.  The radius `1/4` is
  exactly the coin-flip point `p = 1/2`, where the ladder stops moving: the parity law's
  analytic shadow, as conjectured.
* `SeedLadderGF.net48_ladder_sum` / `net48_generating_function` — the lab-note readings at the
  measured per-seed frequency `p = 2/3`: the whole ladder above three seeds is worth `1/3`
  of probability, and the associated series `∑' r, C(2r+1,r)(2/9)^(r+1)` equals exactly `1`.
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Probability.SeedCondorcetLadder
import Probability.SeedCondorcetConvergence

namespace SeedLadderGF

open SeedQuota SeedCondorcet SeedCondorcetRate Filter

/-! ## 1.  The ladder telescopes -/

/-- One step of the Condorcet ladder: what a pair of extra seeds buys at the centre. -/
noncomputable def gap (p : ℝ) (r : ℕ) : ℝ :=
  rungProb (2 * r + 3) (r + 2) p - rungProb (2 * r + 1) (r + 1) p

theorem gap_nonneg {p : ℝ} (h : 1/2 ≤ p) (h1 : p ≤ 1) (r : ℕ) : 0 ≤ gap p r :=
  sub_nonneg.2 (condorcet_step r h h1)

/-- **Telescoping.**  The partial ladder sum is the current median rung minus the one-seed
reading `p`. -/
theorem sum_range_gap (p : ℝ) (R : ℕ) :
    ∑ r ∈ Finset.range R, gap p r = rungProb (2 * R + 1) (R + 1) p - p := by
  have hstep : ∀ r ∈ Finset.range R,
      gap p r = (fun i : ℕ => rungProb (2 * i + 1) (i + 1) p) (r + 1)
        - (fun i : ℕ => rungProb (2 * i + 1) (i + 1) p) r := by
    intro r _
    simp only [gap]
    rw [show 2 * (r + 1) + 1 = 2 * r + 3 by ring, show r + 1 + 1 = r + 2 by ring]
  rw [Finset.sum_congr rfl hstep,
    Finset.sum_range_sub (fun i : ℕ => rungProb (2 * i + 1) (i + 1) p) R]
  simp [rungProb_one_one]

/-! ## 2.  The exact ladder sum -/

/-- **The ladder sums to `1 - p`.**  For a strict per-seed majority the total amplification
the ensemble centre can ever gain over a single seed is exactly the per-seed miss
probability. -/
theorem hasSum_gap {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) : HasSum (gap p) (1 - p) := by
  have hp0 : (0:ℝ) ≤ p := by linarith
  have hnn : ∀ r, 0 ≤ gap p r := gap_nonneg h.le h1
  have hbdd : ∀ R, ∑ r ∈ Finset.range R, gap p r ≤ 1 - p := by
    intro R
    rw [sum_range_gap]
    have := rungProb_le_one (n := 2 * R + 1) (m := R + 1) hp0 h1
    linarith
  have hsummable : Summable (gap p) := summable_of_sum_range_le hnn hbdd
  have htend : Tendsto (fun R => ∑ r ∈ Finset.range R, gap p r) atTop (nhds (1 - p)) := by
    have hconv := condorcet_convergence h h1
    have : Tendsto (fun R : ℕ => rungProb (2 * R + 1) (R + 1) p - p) atTop (nhds (1 - p)) :=
      hconv.sub_const p
    exact this.congr (fun R => (sum_range_gap p R).symm)
  have := hsummable.hasSum.tendsto_sum_nat
  have heq : ∑' r, gap p r = 1 - p := tendsto_nhds_unique this htend
  simpa [heq] using hsummable.hasSum

theorem tsum_gap {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) : ∑' r, gap p r = 1 - p :=
  (hasSum_gap h h1).tsum_eq

/-! ## 3.  The central binomial generating function -/

/-- The one-monomial form of the ladder step, restated for the series. -/
theorem gap_eq_monomial (p : ℝ) (r : ℕ) :
    gap p r = ((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ (r + 1) * (2 * p - 1) := by
  rw [gap, median_rung_gap r p, mul_pow]
  ring

/-- **C4, closed.**  For `0 < x < 1/4`,
`∑' r, C(2r+1,r)·x^(r+1) = (1/2)(1/√(1-4x) - 1)`.

The proof is probabilistic: put `p = (1 + √(1-4x))/2`, so that `p(1-p) = x` and
`2p - 1 = √(1-4x)`; the Condorcet ladder for that `p` is the series in question, scaled by
`√(1-4x)`, and it sums to `1 - p` by `hasSum_gap`. -/
theorem hasSum_centralBinomOdd {x : ℝ} (hx0 : 0 < x) (hx : x < 1/4) :
    HasSum (fun r : ℕ => ((2 * r + 1).choose r : ℝ) * x ^ (r + 1))
      (1/2 * (1 / Real.sqrt (1 - 4 * x) - 1)) := by
  set s : ℝ := Real.sqrt (1 - 4 * x) with hs
  have harg : (0:ℝ) < 1 - 4 * x := by linarith
  have hs0 : 0 < s := Real.sqrt_pos.2 harg
  have hssq : s ^ 2 = 1 - 4 * x := Real.sq_sqrt harg.le
  have hs1 : s < 1 := by
    nlinarith [hs0, hssq]
  set p : ℝ := (1 + s) / 2 with hp
  have hphalf : 1/2 < p := by rw [hp]; linarith
  have hp1 : p ≤ 1 := by rw [hp]; linarith
  have hq : 1 - p = (1 - s) / 2 := by rw [hp]; ring
  have hprod : p * (1 - p) = x := by
    rw [hp, hq]
    nlinarith [hssq]
  have hslope : 2 * p - 1 = s := by rw [hp]; ring
  have hmain := (hasSum_gap hphalf hp1).div_const s
  have hfun : (fun r : ℕ => gap p r / s)
      = fun r : ℕ => ((2 * r + 1).choose r : ℝ) * x ^ (r + 1) := by
    funext r
    rw [gap_eq_monomial, hprod, hslope]
    field_simp
  have hval : (1 - p) / s = 1/2 * (1 / s - 1) := by
    rw [hq]
    field_simp
  rw [hfun, hval] at hmain
  exact hmain

theorem tsum_centralBinomOdd {x : ℝ} (hx0 : 0 < x) (hx : x < 1/4) :
    ∑' r : ℕ, ((2 * r + 1).choose r : ℝ) * x ^ (r + 1)
      = 1/2 * (1 / Real.sqrt (1 - 4 * x) - 1) :=
  (hasSum_centralBinomOdd hx0 hx).tsum_eq

/-! ## 4.  Lab notes at the measured per-seed frequency -/

/-- **The whole ladder above one seed is worth `1/3` at `p = 2/3`.**  Every ensemble size
beyond a single seed, taken together, can buy at most the per-seed miss probability. -/
theorem net48_ladder_sum : ∑' r : ℕ, gap (2/3 : ℝ) r = 1/3 := by
  rw [tsum_gap (by norm_num) (by norm_num)]
  norm_num

/-- The same statement read as a combinatorial identity: at the measured frequency the
ladder's generating variable is `x = p(1-p) = 2/9`, and the central binomial series is
exactly `1`. -/
theorem net48_generating_function :
    ∑' r : ℕ, ((2 * r + 1).choose r : ℝ) * (2/9 : ℝ) ^ (r + 1) = 1 := by
  have h := tsum_centralBinomOdd (x := (2/9 : ℝ)) (by norm_num) (by norm_num)
  have hs : Real.sqrt (1 - 4 * (2/9 : ℝ)) = 1/3 := by
    rw [show (1 - 4 * (2/9 : ℝ)) = (1/3 : ℝ) ^ 2 by norm_num]
    exact Real.sqrt_sq (by norm_num)
  rw [h, hs]
  norm_num

/-- **The remaining two seeds of the three-seed ensemble are worth `2/27` of the total.**
The first ladder step at `p = 2/3` is `gap (2/3) 0 = 20/27 - 2/3 = 2/27`, so the three-seed
ensemble has spent only `2/9` of the `1/3` the whole ladder ever offers: the round's centre
is at the very bottom of the ladder. -/
theorem net48_first_step : gap (2/3 : ℝ) 0 = 2/27 := by
  have h : gap (2/3 : ℝ) 0 = rungProb 3 2 (2/3 : ℝ) - rungProb 1 1 (2/3 : ℝ) := by
    norm_num [gap]
  rw [h, rungProb_three_two, rungProb_one_one]
  norm_num

end SeedLadderGF