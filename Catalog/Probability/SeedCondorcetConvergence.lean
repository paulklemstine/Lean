/-
# Condorcet convergence with an explicit rate: how many seeds certify the centre?

`Probability.SeedCondorcetLadder` proved the *monotone* half of the Condorcet phenomenon for
seed ensembles: for a per-seed majority `p ≥ 1/2` the median rung of an odd ensemble is
nondecreasing in the ensemble size and at least `p`.  That leaves the quantitative question
the NET-48 round actually faces — *how many seeds are needed before the centre is certain?*
— open.  This file closes it, with an elementary exponential rate.

Main results.

* `SeedCondorcetRate.one_sub_rungProb` — the complementary (low) tail of a rung.
* `SeedCondorcetRate.condorcet_rate` — **the rate**:
  `1 - rungProb (2r+1) (r+1) p ≤ 2(1-p)·(4p(1-p))^r` for `1/2 ≤ p ≤ 1`.
  The proof is termwise domination of the low tail by its largest term
  (`p^j (1-p)^(2r+1-j) ≤ p^r (1-p)^(r+1)` for `j ≤ r`) followed by the crude count
  `∑_{j ≤ r} C(2r+1,j) ≤ 2^(2r+1)`.  The base `4p(1-p) = 1 - (2p-1)^2` is exactly the
  quantity that is `< 1` precisely off the calibrated point, so the rate degrades
  continuously as the per-seed tendency weakens — no discontinuity at `p = 1/2`.
* `SeedCondorcetRate.condorcet_convergence` — **the Condorcet jury theorem**: for `p > 1/2`
  the median rung tends to `1`.  Combined with `SeedCondorcet.condorcet_ladder` this makes
  the ensemble centre a *consistent* estimator of the majority side, at geometric speed.
* `SeedCondorcetRate.net48_seeds_for_one_percent` — the deployment reading for the round: at
  the measured six-seed frequency `p = 2/3` of landing at or below the `7/8` budget, the
  bound certifies the three-seed median law to within `1 %` at `r = 36`, i.e. **73 seeds**,
  and `net48_thirty_five_insufficient` shows the same bound does *not* reach `1 %` at
  `r = 35`.  Certifying a distributional centre is expensive: at `~4 h` per seed this is a
  concrete, falsifiable cost statement about the round's own methodology.
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Probability.SeedCondorcetLadder

namespace SeedCondorcetRate

open Finset SeedQuota

/-! ## 1.  The low tail -/

/-- The complement of a rung is the low tail of the binomial. -/
theorem one_sub_rungProb (n m : ℕ) (p : ℝ) (h : m ≤ n + 1) :
    1 - rungProb n m p = ∑ j ∈ range m, (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j) := by
  have hsum := Finset.sum_range_add_sum_Ico
    (fun j => (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)) h
  have h0 := rungProb_zero n p
  rw [rungProb, Nat.Ico_zero_eq_range] at h0
  rw [rungProb]
  simp only at hsum h0 ⊢
  linarith

/-- Rungs are probabilities. -/
theorem rungProb_le_one {n m : ℕ} {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) : rungProb n m p ≤ 1 := by
  rcases le_or_gt m (n + 1) with hm | hm
  · have hlow := one_sub_rungProb n m p hm
    have hnn : 0 ≤ ∑ j ∈ range m, (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j) := by
      refine Finset.sum_nonneg fun j _ => ?_
      have : (0:ℝ) ≤ 1 - p := by linarith
      positivity
    linarith
  · rw [rungProb_of_gt (by omega)]
    norm_num

/-! ## 2.  The exponential rate -/

/-- **The Condorcet rate.**  For a per-seed majority the median rung of a `2r+1`-seed
ensemble misses certainty by at most `2(1-p)·(4p(1-p))^r`.  The base `4p(1-p)` equals
`1 - (2p-1)^2`, so it is `< 1` exactly when the per-seed tendency is off the coin flip. -/
theorem condorcet_rate (r : ℕ) {p : ℝ} (h : 1/2 ≤ p) (h1 : p ≤ 1) :
    1 - rungProb (2 * r + 1) (r + 1) p ≤ 2 * (1 - p) * (4 * p * (1 - p)) ^ r := by
  have hq0 : (0:ℝ) ≤ 1 - p := by linarith
  have hp0 : (0:ℝ) ≤ p := by linarith
  have hqp : (1 : ℝ) - p ≤ p := by linarith
  rw [one_sub_rungProb (2 * r + 1) (r + 1) p (by omega)]
  -- termwise domination by the largest term
  have hterm : ∀ j ∈ range (r + 1),
      ((2 * r + 1).choose j : ℝ) * p ^ j * (1 - p) ^ (2 * r + 1 - j)
        ≤ ((2 * r + 1).choose j : ℝ) * (p ^ r * (1 - p) ^ (r + 1)) := by
    intro j hj
    simp only [Finset.mem_range] at hj
    have hjr : j ≤ r := by omega
    have hexp : 2 * r + 1 - j = (r - j) + (r + 1) := by omega
    have hsplit : p ^ j * (1 - p) ^ (2 * r + 1 - j)
        = (p ^ j * (1 - p) ^ (r - j)) * (1 - p) ^ (r + 1) := by
      rw [hexp, pow_add]
      ring
    have hdom : p ^ j * (1 - p) ^ (r - j) ≤ p ^ r := by
      have hpow : (1 - p) ^ (r - j) ≤ p ^ (r - j) := pow_le_pow_left₀ hq0 hqp _
      have hj' : p ^ j * p ^ (r - j) = p ^ r := by
        rw [← pow_add]
        congr 1
        omega
      calc p ^ j * (1 - p) ^ (r - j) ≤ p ^ j * p ^ (r - j) := by
            exact mul_le_mul_of_nonneg_left hpow (pow_nonneg hp0 j)
        _ = p ^ r := hj'
    have hcnn : (0:ℝ) ≤ ((2 * r + 1).choose j : ℝ) := Nat.cast_nonneg _
    calc ((2 * r + 1).choose j : ℝ) * p ^ j * (1 - p) ^ (2 * r + 1 - j)
        = ((2 * r + 1).choose j : ℝ) * ((p ^ j * (1 - p) ^ (r - j)) * (1 - p) ^ (r + 1)) := by
          rw [← hsplit]; ring
      _ ≤ ((2 * r + 1).choose j : ℝ) * (p ^ r * (1 - p) ^ (r + 1)) := by
          have := mul_le_mul_of_nonneg_right hdom (pow_nonneg hq0 (r + 1))
          exact mul_le_mul_of_nonneg_left this hcnn
  have hsum1 : ∑ j ∈ range (r + 1), ((2 * r + 1).choose j : ℝ) * p ^ j * (1 - p) ^ (2 * r + 1 - j)
      ≤ ∑ j ∈ range (r + 1), ((2 * r + 1).choose j : ℝ) * (p ^ r * (1 - p) ^ (r + 1)) :=
    Finset.sum_le_sum hterm
  -- crude count of the low half of Pascal's row
  have hcount : ∑ j ∈ range (r + 1), ((2 * r + 1).choose j : ℝ) ≤ 2 ^ (2 * r + 1) := by
    have hsub : range (r + 1) ⊆ range (2 * r + 2) := by
      intro x hx
      simp only [Finset.mem_range] at hx ⊢
      omega
    have hnat : ∑ j ∈ range (r + 1), (2 * r + 1).choose j
        ≤ ∑ j ∈ range (2 * r + 2), (2 * r + 1).choose j :=
      Finset.sum_le_sum_of_subset hsub
    have htot : ∑ j ∈ range (2 * r + 2), (2 * r + 1).choose j = 2 ^ (2 * r + 1) :=
      Nat.sum_range_choose (2 * r + 1)
    have hfin : ∑ j ∈ range (r + 1), (2 * r + 1).choose j ≤ 2 ^ (2 * r + 1) := by omega
    exact_mod_cast hfin
  have hfact : ∑ j ∈ range (r + 1), ((2 * r + 1).choose j : ℝ) * (p ^ r * (1 - p) ^ (r + 1))
      = (∑ j ∈ range (r + 1), ((2 * r + 1).choose j : ℝ)) * (p ^ r * (1 - p) ^ (r + 1)) := by
    rw [Finset.sum_mul]
  have hpos : (0:ℝ) ≤ p ^ r * (1 - p) ^ (r + 1) := by positivity
  have hchain : ∑ j ∈ range (r + 1), ((2 * r + 1).choose j : ℝ) * (p ^ r * (1 - p) ^ (r + 1))
      ≤ 2 ^ (2 * r + 1) * (p ^ r * (1 - p) ^ (r + 1)) := by
    rw [hfact]
    exact mul_le_mul_of_nonneg_right hcount hpos
  have hclose : (2:ℝ) ^ (2 * r + 1) * (p ^ r * (1 - p) ^ (r + 1))
      = 2 * (1 - p) * (4 * p * (1 - p)) ^ r := by
    have h4 : (2:ℝ) ^ (2 * r + 1) = 2 * 4 ^ r := by
      rw [pow_succ, pow_mul]
      norm_num
      ring
    rw [h4, mul_pow, mul_pow, pow_succ]
    ring
  linarith [hsum1, hchain, hclose.le, hclose.ge]

/-- **The Condorcet jury theorem for seed ensembles.**  For any strict per-seed majority the
median rung tends to certainty as the (odd) ensemble grows, geometrically fast. -/
theorem condorcet_convergence {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    Filter.Tendsto (fun r : ℕ => rungProb (2 * r + 1) (r + 1) p) Filter.atTop (nhds 1) := by
  have hp0 : (0:ℝ) ≤ p := by linarith
  have hq0 : (0:ℝ) ≤ 1 - p := by linarith
  have hbase0 : (0:ℝ) ≤ 4 * p * (1 - p) := by positivity
  have hbase1 : 4 * p * (1 - p) < 1 := by nlinarith [sq_nonneg (2 * p - 1)]
  have hgeom : Filter.Tendsto (fun r : ℕ => 2 * (1 - p) * (4 * p * (1 - p)) ^ r)
      Filter.atTop (nhds 0) := by
    have := tendsto_pow_atTop_nhds_zero_of_lt_one hbase0 hbase1
    simpa using this.const_mul (2 * (1 - p))
  have hsq : Filter.Tendsto (fun r : ℕ => 1 - rungProb (2 * r + 1) (r + 1) p)
      Filter.atTop (nhds 0) := by
    refine squeeze_zero (fun r => ?_) (fun r => condorcet_rate r h.le h1) hgeom
    have := rungProb_le_one (n := 2 * r + 1) (m := r + 1) hp0 h1
    linarith
  have := hsq.const_sub (1 : ℝ)
  simpa using this

/-! ## 3.  Lab notes: the cost of certifying the NET-48 centre -/

/-- **73 seeds.**  At the measured per-seed frequency `p = 2/3` the rate bound certifies the
median rung to within `1 %` of certainty at `r = 36`, i.e. an ensemble of `2·36+1 = 73`
seeds. -/
theorem net48_seeds_for_one_percent :
    1 - rungProb (2 * 36 + 1) (36 + 1) (2/3 : ℝ) ≤ 1/100 := by
  have hrate := condorcet_rate 36 (p := (2/3 : ℝ)) (by norm_num) (by norm_num)
  have hnum : 2 * (1 - (2/3 : ℝ)) * (4 * (2/3) * (1 - (2/3 : ℝ))) ^ 36 ≤ 1/100 := by
    norm_num
  linarith

/-- …and the same bound does *not* reach `1 %` at `r = 35`: the rate is not slack by a whole
step, so `73` is the honest reading of this argument. -/
theorem net48_thirty_five_insufficient :
    (1/100 : ℝ) < 2 * (1 - (2/3 : ℝ)) * (4 * (2/3) * (1 - (2/3 : ℝ))) ^ 35 := by
  norm_num

/-- The three-seed ensemble actually run is far from that: its median rung at the measured
frequency is `20/27 ≈ 0.74`, so NET-48's centre is a *point estimate with a `26 %` miss
probability under its own frequency model — not a certified centre.  This is the sharpest
honest limit the probability model puts on the round. -/
theorem net48_three_seed_miss_probability :
    1 - rungProb 3 2 (2/3 : ℝ) = 7/27 ∧ (1/4 : ℝ) < 1 - rungProb 3 2 (2/3 : ℝ) := by
  have h3 : rungProb 3 2 (2/3 : ℝ) = 20/27 := by
    rw [SeedCondorcet.rungProb_three_two]; norm_num
  rw [h3]
  norm_num

end SeedCondorcetRate