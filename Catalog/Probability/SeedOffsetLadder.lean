/-
# The off-centre Condorcet ladder: every offset rung has its own exact sum

Conjecture **D3** of the previous cycle's `FUTURE_DIRECTIONS.md`: the ladder of
`Probability.SeedLadderGeneratingFunction` was built at the *median* rung, where the two-step
Pascal recursion collapses to a single monomial.  Deployment, however, reads *off-centre*
rungs — NET-48's `3/3` guarantee is the top rung of a three-seed ensemble, not its median.
D3 conjectured that for each fixed offset `k` the shifted ladder still sums to a rational
function of `p`, of the form `(1-p)·R_k(p)` with `R_0 = 1`.

This file proves it, with `R_k(p) = 1 + p + ⋯ + p^{2k}`:

* `SeedOffsetLadder.offset_rung_gap` — the off-centre gap is a **difference of two monomials**,
  `p^{r+k+1}(1-p)^{r-k+1}·(C(2r+1,r+k)·p − C(2r+1,r+k+1)·(1−p))`; at `k = 0` the two binomial
  coefficients coincide and it collapses to `SeedCondorcet.median_rung_gap`.
* `SeedOffsetLadder.offset_condorcet_step` — the gap is nonnegative for `p ≥ 1/2`: **every**
  rung at or above the median amplifies a per-seed majority, not just the median one.  The two
  ingredients are the antitonicity of the binomial row above its centre
  (`SeedOffsetLadder.choose_antitone_above_centre`) and `p ≥ 1 − p`.
* `SeedOffsetLadder.hasSum_offsetGap_from` — **the exact remaining-distance identity**: for
  `k ≤ r`, `1 − rungProb (2r+1) (r+1+k) p = ∑_{s ≥ 0} offsetGap k p (r+s)`.  The distance an
  off-centre rung still has to travel is exactly the sum of the steps it will take.
* `SeedOffsetLadder.hasSum_offsetGap` — **D3, closed.**  Started at its first legal ensemble
  `2k+1`, the offset-`k` ladder sums to `1 − p^{2k+1} = (1−p)(1 + p + ⋯ + p^{2k})`; the case
  `k = 0` is the previous cycle's `1 − p`.  So `R_k` is not merely rational but *polynomial*,
  and it is the geometric sum of length `2k+1` — the size of the smallest ensemble that has an
  offset-`k` rung at all.
* `SeedOffsetLadder.offset_tail_bound` / `offset_convergence` — the quantitative input: an
  off-centre rung misses certainty by at most the median rung's Condorcet rate plus `k` crude
  terms of size `2·4^k·p(1−p)·(4p(1−p))^t`, so off-centre rungs converge to certainty as well,
  geometrically, at the same base `4p(1−p)`.

Lab notes at the measured per-seed frequency `p = 2/3` are in section 5.
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Probability.SeedCondorcetLadder
import Probability.SeedCondorcetConvergence
import Probability.SeedLadderGeneratingFunction

namespace SeedOffsetLadder

open Finset SeedQuota SeedCondorcet SeedCondorcetRate Filter

/-! ## 1.  The off-centre gap -/

/-- One step of the offset-`k` ladder: two more seeds, quota raised by one, the quota sitting
`k` rungs above the median throughout. -/
noncomputable def offsetGap (k : ℕ) (p : ℝ) (r : ℕ) : ℝ :=
  rungProb (2 * r + 3) (r + 2 + k) p - rungProb (2 * r + 1) (r + 1 + k) p

/-- **The off-centre gap is a difference of two monomials.**  For `k ≤ r`,
`offsetGap k p r = p^{r+k+1}(1-p)^{r-k+1}·(C(2r+1,r+k)p - C(2r+1,r+k+1)(1-p))`. -/
theorem offset_rung_gap {k r : ℕ} (hk : k ≤ r) (p : ℝ) :
    offsetGap k p r
      = p ^ (r + k + 1) * (1 - p) ^ (r - k + 1)
        * (((2 * r + 1).choose (r + k) : ℝ) * p
            - ((2 * r + 1).choose (r + k + 1) : ℝ) * (1 - p)) := by
  have hstep := rungProb_two_step (2 * r + 1) (r + k) p
  rw [show 2 * r + 1 + 2 = 2 * r + 3 by ring] at hstep
  have hg1 : rungProb (2 * r + 1) (r + k) p - rungProb (2 * r + 1) (r + k + 1) p
      = ((2 * r + 1).choose (r + k) : ℝ) * p ^ (r + k) * (1 - p) ^ (2 * r + 1 - (r + k)) :=
    rungProb_sub_succ (by omega) p
  have hg2 : rungProb (2 * r + 1) (r + k + 1) p - rungProb (2 * r + 1) (r + k + 2) p
      = ((2 * r + 1).choose (r + k + 1) : ℝ) * p ^ (r + k + 1)
          * (1 - p) ^ (2 * r + 1 - (r + k + 1)) :=
    rungProb_sub_succ (by omega) p
  rw [show 2 * r + 1 - (r + k) = (r - k) + 1 by omega] at hg1
  rw [show 2 * r + 1 - (r + k + 1) = r - k by omega] at hg2
  have hA : rungProb (2 * r + 1) (r + k) p
      = rungProb (2 * r + 1) (r + k + 1) p
        + ((2 * r + 1).choose (r + k) : ℝ) * p ^ (r + k) * (1 - p) ^ ((r - k) + 1) := by
    linarith
  have hC : rungProb (2 * r + 1) (r + k + 2) p
      = rungProb (2 * r + 1) (r + k + 1) p
        - ((2 * r + 1).choose (r + k + 1) : ℝ) * p ^ (r + k + 1) * (1 - p) ^ (r - k) := by
    linarith
  have hidx : r + 2 + k = r + k + 2 := by ring
  have hidx2 : (1 - p) ^ ((r - k) + 1) = (1 - p) ^ (r - k) * (1 - p) := by rw [pow_succ]
  have hidx3 : p ^ (r + k + 1) = p ^ (r + k) * p := by rw [pow_succ]
  rw [offsetGap, hidx, hstep, hA, hC, hidx2, hidx3]
  ring_nf

/-! ## 2.  Off-centre amplification -/

/-- **The binomial row is antitone above its centre.**  For `k ≤ r`,
`C(2r+1, r+k+1) ≤ C(2r+1, r+k)`. -/
theorem choose_antitone_above_centre {k r : ℕ} (hk : k ≤ r) :
    (2 * r + 1).choose (r + k + 1) ≤ (2 * r + 1).choose (r + k) := by
  rcases Nat.eq_zero_or_pos k with rfl | hk1
  · -- at the centre the two coefficients are equal
    have h := Nat.choose_symm (show r ≤ 2 * r + 1 by omega)
    rw [show 2 * r + 1 - r = r + 1 by omega] at h
    simpa using h.le
  · have hs1 : (2 * r + 1).choose (r - k) = (2 * r + 1).choose (r + k + 1) := by
      have h := Nat.choose_symm (show r + k + 1 ≤ 2 * r + 1 by omega)
      rwa [show 2 * r + 1 - (r + k + 1) = r - k by omega] at h
    have hs2 : (2 * r + 1).choose (r + 1 - k) = (2 * r + 1).choose (r + k) := by
      have h := Nat.choose_symm (show r + k ≤ 2 * r + 1 by omega)
      rwa [show 2 * r + 1 - (r + k) = r + 1 - k by omega] at h
    have hstep : (2 * r + 1).choose (r - k) ≤ (2 * r + 1).choose ((r - k) + 1) := by
      refine Nat.choose_le_succ_of_lt_half_left ?_
      have : (2 * r + 1) / 2 = r := by omega
      omega
    rw [← hs1, ← hs2, show r + 1 - k = (r - k) + 1 by omega]
    exact hstep

/-- **Off-centre rungs amplify too.**  For a per-seed majority and any offset `k ≤ r`, adding
two seeds and raising the quota by one increases the rung.  The Condorcet ladder is therefore
not a phenomenon of the median: it holds along every fixed offset above it. -/
theorem offset_condorcet_step {k r : ℕ} (hk : k ≤ r) {p : ℝ} (h : 1/2 ≤ p) (h1 : p ≤ 1) :
    rungProb (2 * r + 1) (r + 1 + k) p ≤ rungProb (2 * r + 3) (r + 2 + k) p := by
  have hp0 : (0:ℝ) ≤ p := by linarith
  have hq0 : (0:ℝ) ≤ 1 - p := by linarith
  have hchoose : ((2 * r + 1).choose (r + k + 1) : ℝ) ≤ ((2 * r + 1).choose (r + k) : ℝ) := by
    exact_mod_cast choose_antitone_above_centre hk
  have hbr : (0:ℝ) ≤ ((2 * r + 1).choose (r + k) : ℝ) * p
      - ((2 * r + 1).choose (r + k + 1) : ℝ) * (1 - p) := by
    have hc2 : (0:ℝ) ≤ ((2 * r + 1).choose (r + k + 1) : ℝ) := Nat.cast_nonneg _
    nlinarith [hchoose, hc2, hp0, hq0]
  have hgap : 0 ≤ offsetGap k p r := by
    rw [offset_rung_gap hk]
    have hpow : (0:ℝ) ≤ p ^ (r + k + 1) * (1 - p) ^ (r - k + 1) := by positivity
    exact mul_nonneg hpow hbr
  rw [offsetGap] at hgap
  linarith

/-! ## 3.  The telescoping identity and the exact sum -/

/-- The top rung of an ensemble asks all its seeds to pass. -/
theorem rungProb_self (n : ℕ) (p : ℝ) : rungProb n n p = p ^ n := by
  rw [rungProb, Nat.Ico_succ_singleton, Finset.sum_singleton]
  simp

/-- **Telescoping the offset ladder** from any starting ensemble. -/
theorem sum_range_offsetGap_from (k r : ℕ) (p : ℝ) (R : ℕ) :
    ∑ s ∈ range R, offsetGap k p (r + s)
      = rungProb (2 * (r + R) + 1) ((r + R) + 1 + k) p - rungProb (2 * r + 1) (r + 1 + k) p := by
  have hstep : ∀ s ∈ range R,
      offsetGap k p (r + s) = (fun i : ℕ => rungProb (2 * (r + i) + 1) ((r + i) + 1 + k) p) (s + 1)
        - (fun i : ℕ => rungProb (2 * (r + i) + 1) ((r + i) + 1 + k) p) s := by
    intro s _
    simp only [offsetGap]
    rw [show 2 * (r + (s + 1)) + 1 = 2 * (r + s) + 3 by ring,
      show r + (s + 1) + 1 + k = (r + s) + 2 + k by ring]
  rw [Finset.sum_congr rfl hstep,
    Finset.sum_range_sub (fun i : ℕ => rungProb (2 * (r + i) + 1) ((r + i) + 1 + k) p) R]
  simp

/-! ## 4.  Off-centre rungs converge to certainty -/

/-- The difference of two rungs of the same ensemble is the corresponding block of the
binomial row. -/
theorem rungProb_sub_of_le {n m m' : ℕ} (hm : m ≤ m') (hm' : m' ≤ n + 1) (p : ℝ) :
    rungProb n m p - rungProb n m' p
      = ∑ j ∈ Finset.Ico m m', (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j) := by
  have h := Finset.sum_Ico_consecutive
    (fun j => (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)) hm hm'
  rw [rungProb, rungProb]
  linarith [h]

/-- **A crude bound on an off-centre block.**  Each of the `k` extra terms between the median
rung and the offset-`k` rung of a `2(k+t)+1`-seed ensemble is at most
`2^{2(k+t)+1}·(p(1-p))^{t+1}`. -/
theorem offset_block_bound (k t : ℕ) {p : ℝ} (h : 1/2 ≤ p) (h1 : p ≤ 1) :
    rungProb (2 * (k + t) + 1) ((k + t) + 1) p - rungProb (2 * (k + t) + 1) ((k + t) + 1 + k) p
      ≤ k * (2 * 4 ^ k * (p * (1 - p)) * (4 * p * (1 - p)) ^ t) := by
  have hp0 : (0:ℝ) ≤ p := by linarith
  have hq0 : (0:ℝ) ≤ 1 - p := by linarith
  set n : ℕ := 2 * (k + t) + 1 with hn
  rw [rungProb_sub_of_le (by omega) (by omega) p]
  have hterm : ∀ j ∈ Finset.Ico ((k + t) + 1) ((k + t) + 1 + k),
      (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)
        ≤ 2 * 4 ^ k * (p * (1 - p)) * (4 * p * (1 - p)) ^ t := by
    intro j hj
    simp only [Finset.mem_Ico] at hj
    have hjlow : t + 1 ≤ j := by omega
    have hjhigh : t + 1 ≤ n - j := by omega
    have hpj : p ^ j ≤ p ^ (t + 1) := pow_le_pow_of_le_one hp0 h1 hjlow
    have hqj : (1 - p) ^ (n - j) ≤ (1 - p) ^ (t + 1) :=
      pow_le_pow_of_le_one hq0 (by linarith) hjhigh
    have hchoose : (n.choose j : ℝ) ≤ (2:ℝ) ^ n := by
      have := Nat.choose_le_two_pow n j
      exact_mod_cast this
    have hnn : (0:ℝ) ≤ p ^ j * (1 - p) ^ (n - j) := by positivity
    have hstep1 : (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)
        ≤ (2:ℝ) ^ n * (p ^ (t + 1) * (1 - p) ^ (t + 1)) := by
      have h1' : (n.choose j : ℝ) * (p ^ j * (1 - p) ^ (n - j))
          ≤ (2:ℝ) ^ n * (p ^ j * (1 - p) ^ (n - j)) := mul_le_mul_of_nonneg_right hchoose hnn
      have h2' : p ^ j * (1 - p) ^ (n - j) ≤ p ^ (t + 1) * (1 - p) ^ (t + 1) := by
        have hp1 : (0:ℝ) ≤ p ^ j := by positivity
        have hq1 : (0:ℝ) ≤ (1 - p) ^ (n - j) := by positivity
        have hq2 : (0:ℝ) ≤ (1 - p) ^ (t + 1) := by positivity
        calc p ^ j * (1 - p) ^ (n - j) ≤ p ^ (t + 1) * (1 - p) ^ (n - j) :=
              mul_le_mul_of_nonneg_right hpj hq1
          _ ≤ p ^ (t + 1) * (1 - p) ^ (t + 1) :=
              mul_le_mul_of_nonneg_left hqj (by positivity)
      have h3' : (0:ℝ) ≤ (2:ℝ) ^ n := by positivity
      calc (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)
          = (n.choose j : ℝ) * (p ^ j * (1 - p) ^ (n - j)) := by ring
        _ ≤ (2:ℝ) ^ n * (p ^ j * (1 - p) ^ (n - j)) := h1'
        _ ≤ (2:ℝ) ^ n * (p ^ (t + 1) * (1 - p) ^ (t + 1)) :=
            mul_le_mul_of_nonneg_left h2' h3'
    have hval : (2:ℝ) ^ n * (p ^ (t + 1) * (1 - p) ^ (t + 1))
        = 2 * 4 ^ k * (p * (1 - p)) * (4 * p * (1 - p)) ^ t := by
      have h4 : (4:ℝ) = 2 ^ 2 := by norm_num
      have hpow2 : (2:ℝ) ^ n = 2 * 4 ^ k * 4 ^ t := by
        rw [hn, show 2 * (k + t) + 1 = 2 * k + 2 * t + 1 by ring, pow_succ, pow_add, pow_mul,
          pow_mul, h4]
        ring
      have e1 : (4 * p * (1 - p)) ^ t = 4 ^ t * (p * (1 - p)) ^ t := by
        rw [show (4:ℝ) * p * (1 - p) = 4 * (p * (1 - p)) by ring, mul_pow]
      have e2 : p ^ (t + 1) * (1 - p) ^ (t + 1) = (p * (1 - p)) ^ t * (p * (1 - p)) := by
        rw [pow_succ, pow_succ, mul_pow]
        ring
      rw [hpow2, e1, e2]
      ring
    rw [← hval]
    exact hstep1
  have hcard : (Finset.Ico ((k + t) + 1) ((k + t) + 1 + k)).card = k := by
    rw [Nat.card_Ico]
    omega
  calc ∑ j ∈ Finset.Ico ((k + t) + 1) ((k + t) + 1 + k), (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)
      ≤ ∑ _j ∈ Finset.Ico ((k + t) + 1) ((k + t) + 1 + k),
          2 * 4 ^ k * (p * (1 - p)) * (4 * p * (1 - p)) ^ t := Finset.sum_le_sum hterm
    _ = k * (2 * 4 ^ k * (p * (1 - p)) * (4 * p * (1 - p)) ^ t) := by
        rw [Finset.sum_const, hcard, nsmul_eq_mul]

/-- **The off-centre miss bound.**  The median rate plus `k` crude terms, both geometric in the
same base `4p(1-p)`. -/
theorem offset_tail_bound (k t : ℕ) {p : ℝ} (h : 1/2 ≤ p) (h1 : p ≤ 1) :
    1 - rungProb (2 * (k + t) + 1) ((k + t) + 1 + k) p
      ≤ 2 * (1 - p) * (4 * p * (1 - p)) ^ (k + t)
        + k * (2 * 4 ^ k * (p * (1 - p)) * (4 * p * (1 - p)) ^ t) := by
  have hmed := condorcet_rate (k + t) h h1
  have hblock := offset_block_bound k t h h1
  linarith

/-- **Off-centre convergence.**  For a strict per-seed majority every fixed offset rung tends
to certainty as the ensemble grows. -/
theorem offset_convergence (k : ℕ) {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    Tendsto (fun r : ℕ => rungProb (2 * r + 1) (r + 1 + k) p) atTop (nhds 1) := by
  have hp0 : (0:ℝ) ≤ p := by linarith
  have hq0 : (0:ℝ) ≤ 1 - p := by linarith
  have hbase0 : (0:ℝ) ≤ 4 * p * (1 - p) := by positivity
  have hbase1 : 4 * p * (1 - p) < 1 := by nlinarith [sq_nonneg (2 * p - 1)]
  have hgeom : Tendsto (fun t : ℕ => (4 * p * (1 - p)) ^ t) atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one hbase0 hbase1
  -- the shifted sequence
  have hshift : Tendsto (fun t : ℕ => 1 - rungProb (2 * (k + t) + 1) ((k + t) + 1 + k) p)
      atTop (nhds 0) := by
    have hupper : Tendsto (fun t : ℕ => 2 * (1 - p) * (4 * p * (1 - p)) ^ (k + t)
        + k * (2 * 4 ^ k * (p * (1 - p)) * (4 * p * (1 - p)) ^ t)) atTop (nhds 0) := by
      have h1' : Tendsto (fun t : ℕ => 2 * (1 - p) * (4 * p * (1 - p)) ^ (k + t))
          atTop (nhds 0) := by
        have : Tendsto (fun t : ℕ => (2 * (1 - p) * (4 * p * (1 - p)) ^ k)
            * (4 * p * (1 - p)) ^ t) atTop (nhds 0) := by
          simpa using hgeom.const_mul (2 * (1 - p) * (4 * p * (1 - p)) ^ k)
        refine this.congr (fun t => ?_)
        rw [pow_add]; ring
      have h2' : Tendsto (fun t : ℕ =>
          (k : ℝ) * (2 * 4 ^ k * (p * (1 - p)) * (4 * p * (1 - p)) ^ t)) atTop (nhds 0) := by
        have : Tendsto (fun t : ℕ => ((k : ℝ) * (2 * 4 ^ k * (p * (1 - p))))
            * (4 * p * (1 - p)) ^ t) atTop (nhds 0) := by
          simpa using hgeom.const_mul ((k : ℝ) * (2 * 4 ^ k * (p * (1 - p))))
        refine this.congr (fun t => ?_)
        ring
      simpa using h1'.add h2'
    refine squeeze_zero (fun t => ?_) (fun t => offset_tail_bound k t h.le h1) hupper
    have := rungProb_le_one (n := 2 * (k + t) + 1) (m := (k + t) + 1 + k) hp0 h1
    linarith
  have hshift1 : Tendsto (fun t : ℕ => rungProb (2 * (k + t) + 1) ((k + t) + 1 + k) p)
      atTop (nhds 1) := by
    have := hshift.const_sub (1 : ℝ)
    simpa using this
  -- unshift
  rw [← tendsto_add_atTop_iff_nat k]
  refine hshift1.congr (fun t => ?_)
  rw [show t + k = k + t from Nat.add_comm t k]

/-! ## 5.  The exact sums -/

/-- **The remaining distance is the sum of the future steps.**  For `k ≤ r` the offset-`k`
ladder started at the `2r+1`-seed ensemble sums to exactly that ensemble's miss probability. -/
theorem hasSum_offsetGap_from {k r : ℕ} (hkr : k ≤ r) {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    HasSum (fun s : ℕ => offsetGap k p (r + s)) (1 - rungProb (2 * r + 1) (r + 1 + k) p) := by
  have hp0 : (0:ℝ) ≤ p := by linarith
  have hnn : ∀ s : ℕ, 0 ≤ offsetGap k p (r + s) := by
    intro s
    have := offset_condorcet_step (k := k) (r := r + s) (by omega) h.le h1
    rw [offsetGap]
    linarith
  have hbdd : ∀ R, ∑ s ∈ range R, offsetGap k p (r + s)
      ≤ 1 - rungProb (2 * r + 1) (r + 1 + k) p := by
    intro R
    rw [sum_range_offsetGap_from]
    have := rungProb_le_one (n := 2 * (r + R) + 1) (m := (r + R) + 1 + k) hp0 h1
    linarith
  have hsummable : Summable (fun s : ℕ => offsetGap k p (r + s)) :=
    summable_of_sum_range_le hnn hbdd
  have htend : Tendsto (fun R => ∑ s ∈ range R, offsetGap k p (r + s)) atTop
      (nhds (1 - rungProb (2 * r + 1) (r + 1 + k) p)) := by
    have hconv : Tendsto (fun R : ℕ => rungProb (2 * (r + R) + 1) ((r + R) + 1 + k) p)
        atTop (nhds 1) := by
      have hbase := offset_convergence k h h1
      have hmap : Tendsto (fun R : ℕ => r + R) atTop atTop :=
        tendsto_atTop_mono (fun n => Nat.le_add_left n r) tendsto_id
      exact hbase.comp hmap
    have := hconv.sub_const (rungProb (2 * r + 1) (r + 1 + k) p)
    exact this.congr (fun R => (sum_range_offsetGap_from k r p R).symm)
  have heq : ∑' s, offsetGap k p (r + s) = 1 - rungProb (2 * r + 1) (r + 1 + k) p :=
    tendsto_nhds_unique hsummable.hasSum.tendsto_sum_nat htend
  simpa [heq] using hsummable.hasSum

/-- **D3, closed.**  Started at the smallest ensemble that has an offset-`k` rung — namely
`2k+1` seeds, whose offset-`k` rung is unanimity — the offset ladder sums to exactly
`1 - p^{2k+1}`. -/
theorem hasSum_offsetGap (k : ℕ) {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    HasSum (fun s : ℕ => offsetGap k p (k + s)) (1 - p ^ (2 * k + 1)) := by
  have hbase := hasSum_offsetGap_from (k := k) (r := k) le_rfl h h1
  have hfull : rungProb (2 * k + 1) (k + 1 + k) p = p ^ (2 * k + 1) := by
    rw [show k + 1 + k = 2 * k + 1 by ring, rungProb_self]
  rwa [hfull] at hbase

theorem tsum_offsetGap (k : ℕ) {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    ∑' s : ℕ, offsetGap k p (k + s) = 1 - p ^ (2 * k + 1) :=
  (hasSum_offsetGap k h h1).tsum_eq

/-- **The conjectured shape `(1-p)·R_k(p)`, with `R_k` identified.**  `R_k` is the geometric
polynomial of length `2k+1`, and `R_0 = 1` as D3 required. -/
theorem tsum_offsetGap_factored (k : ℕ) {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    ∑' s : ℕ, offsetGap k p (k + s) = (1 - p) * ∑ j ∈ range (2 * k + 1), p ^ j := by
  rw [tsum_offsetGap k h h1]
  have hgeom := geom_sum_mul p (2 * k + 1)
  linarith [hgeom]

/-- The median case `k = 0` is the previous cycle's ladder sum `1 - p`. -/
theorem tsum_offsetGap_zero {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    ∑' s : ℕ, offsetGap 0 p s = 1 - p := by
  have := tsum_offsetGap 0 h h1
  simpa using this

/-! ## 6.  Lab notes at the measured per-seed frequency `p = 2/3` -/

/-- At `p = 2/3` the ladder one rung above the median is worth `19/27` — more than twice the
median ladder's `1/3` (`SeedLadderGF.net48_ladder_sum`).  Off-centre rungs start much further
from certainty, and therefore have much more to gain from extra seeds: the deployment-relevant
guarantee rung is exactly the one that benefits most from a fourth and fifth seed. -/
theorem net48_offset_one_ladder_sum :
    ∑' s : ℕ, offsetGap 1 (2/3 : ℝ) (1 + s) = 19/27 := by
  rw [tsum_offsetGap 1 (by norm_num) (by norm_num)]
  norm_num

/-- The unanimity rung of the three-seed ensemble actually run reads `8/27` at the measured
frequency, and the whole offset-`1` ladder above it is worth the complementary `19/27`. -/
theorem net48_unanimity_rung : rungProb 3 3 (2/3 : ℝ) = 8/27 := by
  rw [show (3:ℕ) = 3 from rfl, rungProb_self]
  norm_num

end SeedOffsetLadder