/-
# The quota threshold: which rungs an extra pair of seeds actually helps

Conjecture **D5** of the previous cycle's `FUTURE_DIRECTIONS.md` asked whether the median
identity `SeedSharpRate.miss_le_gap_div_sq` — *the next ladder step controls the entire
remaining distance to certainty, up to the factor `(2p-1)^(-2)`* — survives off the centre, at
a general quota fraction `α`, with a constant `c(α,p)` that "degenerates exactly at the
calibration line `α = 1 - p`".

This file settles the question in a sharper form than the conjecture stated, by working with
the quota itself rather than an asymptotic fraction.

Main results.

* `SeedThreshold.rung_two_step_gap` — the **general two-step gap**, for every ensemble size and
  every quota: `rungProb (n+2) (m+2) p - rungProb n (m+1) p
  = p^{m+1}(1-p)^{n-m}·(C(n,m)p - C(n,m+1)(1-p))`.  `SeedCondorcet.median_rung_gap` and
  `SeedOffsetLadder.offset_rung_gap` are the cases `m = r` and `m = r+k` of it.
* **The quota threshold law.**  `SeedThreshold.ladder_ascends_iff` : for `0 < p < 1` and
  `m + 1 ≤ n`, two extra seeds with the quota raised by one *help* — `rungProb n (m+1) p ≤
  rungProb (n+2) (m+2) p` — **iff `(1-p)(n+1) ≤ m+1`**, i.e. iff the quota is at least the
  expected number of failures in the enlarged ensemble.  D5's calibration line `α = 1-p` is
  therefore not merely where a constant degenerates: it is the exact sign change of the ladder
  step, in finite `n`, with no asymptotics.
* `SeedThreshold.median_ascends_iff_majority` — the median case collapses to the Condorcet
  condition `1/2 ≤ p`, recovering `SeedCondorcet.condorcet_step` and showing it is *sharp*: for
  `p < 1/2` the median ladder strictly descends.
* `SeedThreshold.offset_ascends_iff` — an offset-`k` rung ascends iff
  `(1-p)(2r+2) ≤ r+1+k`, so a quota above the median keeps buying amplification *below* the
  coin flip: at `(n,m) = (3,3)` — NET-48's own `3/3` guarantee rung — the threshold is `p ≥ 1/4`
  (`SeedThreshold.net48_unanimity_threshold`).
* `SeedThreshold.rate_sharp_general` — the sharpened rate at **every** quota:
  `1 - rungProb n m p ≤ C(n, n/2)·p^m(1-p)^{n-m+1}/(2p-1)`, with the matching single-term lower
  bound `SeedThreshold.rate_general_lower`.  Only the middle-binomial domination step was
  quota-specific in the median proof, and `Nat.choose_le_middle` supplies it in general — D5's
  "why now" was right about the mechanism.
* **D5, corrected and closed.**  `SeedThreshold.miss_le_gap_div_constant` : whenever the step
  is upward,
  `1 - rungProb n (m+1) p ≤ (step)·C(n,n/2)/((2p-1)(C(n,m)p - C(n,m+1)(1-p)))`.
  The constant is explicit, it is *not* a function of the quota fraction and `p` alone (it
  carries a ratio of binomial coefficients), and it degenerates exactly on the calibration line
  where the bracket vanishes.  `SeedThreshold.median_case_constant` checks that at the median it
  is precisely `(2p-1)^{-2}`, recovering `SeedSharpRate.miss_le_gap_div_sq`.
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Probability.SeedCondorcetLadder
import Probability.SeedCondorcetConvergence
import Probability.SeedSharpRate

namespace SeedThreshold

open Finset SeedQuota SeedCondorcet SeedCondorcetRate

/-! ## 1.  The general two-step gap -/

/-- **The two-step gap at an arbitrary quota.**  Adding two seeds and raising the quota by one
changes the rung by `p^{m+1}(1-p)^{n-m}·(C(n,m)p - C(n,m+1)(1-p))`. -/
theorem rung_two_step_gap {n m : ℕ} (hm : m + 1 ≤ n) (p : ℝ) :
    rungProb (n + 2) (m + 2) p - rungProb n (m + 1) p
      = p ^ (m + 1) * (1 - p) ^ (n - m)
        * ((n.choose m : ℝ) * p - (n.choose (m + 1) : ℝ) * (1 - p)) := by
  have hstep := rungProb_two_step n m p
  have hg1 : rungProb n m p - rungProb n (m + 1) p
      = (n.choose m : ℝ) * p ^ m * (1 - p) ^ (n - m) := rungProb_sub_succ (by omega) p
  have hg2 : rungProb n (m + 1) p - rungProb n (m + 2) p
      = (n.choose (m + 1) : ℝ) * p ^ (m + 1) * (1 - p) ^ (n - (m + 1)) :=
    rungProb_sub_succ (by omega) p
  have hexp : (1 - p) ^ (n - m) = (1 - p) ^ (n - (m + 1)) * (1 - p) := by
    rw [show n - m = (n - (m + 1)) + 1 by omega, pow_succ]
  have hA : rungProb n m p
      = rungProb n (m + 1) p + (n.choose m : ℝ) * p ^ m * (1 - p) ^ (n - m) := by linarith
  have hC : rungProb n (m + 2) p
      = rungProb n (m + 1) p
        - (n.choose (m + 1) : ℝ) * p ^ (m + 1) * (1 - p) ^ (n - (m + 1)) := by linarith
  have hp : p ^ (m + 1) = p ^ m * p := by rw [pow_succ]
  rw [hstep, hA, hC, hexp, hp]
  ring

/-! ## 2.  The quota threshold law -/

/-- The sign of the two-step gap is the sign of `(m+1) - (1-p)(n+1)`. -/
theorem bracket_mul (n m : ℕ) (hm : m + 1 ≤ n) (p : ℝ) :
    ((m : ℝ) + 1) * ((n.choose m : ℝ) * p - (n.choose (m + 1) : ℝ) * (1 - p))
      = (n.choose m : ℝ) * (((m : ℝ) + 1) - (1 - p) * ((n : ℝ) + 1)) := by
  have hrec : n.choose (m + 1) * (m + 1) = n.choose m * (n - m) := Nat.choose_succ_right_eq n m
  have hcast : ((n.choose (m + 1) : ℝ)) * ((m : ℝ) + 1)
      = (n.choose m : ℝ) * ((n : ℝ) - (m : ℝ)) := by
    have hc := congrArg (fun t : ℕ => (t : ℝ)) hrec
    push_cast [Nat.cast_sub (show m ≤ n by omega)] at hc
    linarith [hc]
  calc ((m : ℝ) + 1) * ((n.choose m : ℝ) * p - (n.choose (m + 1) : ℝ) * (1 - p))
      = (n.choose m : ℝ) * p * ((m : ℝ) + 1)
        - ((n.choose (m + 1) : ℝ) * ((m : ℝ) + 1)) * (1 - p) := by ring
    _ = (n.choose m : ℝ) * p * ((m : ℝ) + 1)
        - ((n.choose m : ℝ) * ((n : ℝ) - (m : ℝ))) * (1 - p) := by rw [hcast]
    _ = (n.choose m : ℝ) * (((m : ℝ) + 1) - (1 - p) * ((n : ℝ) + 1)) := by ring

/-- **The quota threshold law.**  For `0 < p < 1`, two extra seeds with the quota raised by one
increase the rung **iff the quota is at least the expected number of failures**,
`(1-p)(n+1) ≤ m+1`.  Below that threshold the same move strictly *decreases* the rung. -/
theorem ladder_ascends_iff {n m : ℕ} (hm : m + 1 ≤ n) {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) :
    rungProb n (m + 1) p ≤ rungProb (n + 2) (m + 2) p ↔ (1 - p) * ((n : ℝ) + 1) ≤ (m : ℝ) + 1 := by
  have hq0 : (0:ℝ) < 1 - p := by linarith
  have hpow : (0:ℝ) < p ^ (m + 1) * (1 - p) ^ (n - m) := by positivity
  have hchoose : (0:ℝ) < (n.choose m : ℝ) := by
    have : 0 < n.choose m := Nat.choose_pos (by omega)
    exact_mod_cast this
  have hm1 : (0:ℝ) < (m : ℝ) + 1 := by positivity
  have hgap := rung_two_step_gap hm p
  constructor
  · intro hle
    have hgn : 0 ≤ p ^ (m + 1) * (1 - p) ^ (n - m)
        * ((n.choose m : ℝ) * p - (n.choose (m + 1) : ℝ) * (1 - p)) := by
      rw [← hgap]; linarith
    have hbr : 0 ≤ (n.choose m : ℝ) * p - (n.choose (m + 1) : ℝ) * (1 - p) :=
      nonneg_of_mul_nonneg_right hgn hpow
    have := bracket_mul n m hm p
    nlinarith [hbr, hchoose, hm1, this]
  · intro hth
    have hbr : 0 ≤ (n.choose m : ℝ) * p - (n.choose (m + 1) : ℝ) * (1 - p) := by
      have hmul := bracket_mul n m hm p
      nlinarith [hchoose, hm1, hmul, hth]
    nlinarith [hgap, mul_nonneg hpow.le hbr]

/-- **The median case is exactly the Condorcet condition.**  The median rung of a `2r+1`-seed
ensemble improves when two seeds are added iff the per-seed probability is at least `1/2`;
`SeedCondorcet.condorcet_step` is therefore sharp. -/
theorem median_ascends_iff_majority (r : ℕ) {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) :
    rungProb (2 * r + 1) (r + 1) p ≤ rungProb (2 * r + 3) (r + 2) p ↔ 1/2 ≤ p := by
  have hm : r + 1 ≤ 2 * r + 1 := by omega
  have hiff := ladder_ascends_iff (n := 2 * r + 1) (m := r) hm hp0 hp1
  rw [show 2 * r + 1 + 2 = 2 * r + 3 by ring, show r + 2 = r + 2 from rfl] at hiff
  rw [hiff]
  constructor
  · intro hth
    push_cast at hth
    nlinarith [hth]
  · intro hth
    push_cast
    nlinarith [hth, Nat.cast_nonneg (α := ℝ) r]

/-- **Off-centre rungs ascend below the coin flip.**  An offset-`k` rung of a `2r+1`-seed
ensemble improves iff `(1-p)(2r+2) ≤ r+1+k`; for `k ≥ 1` this admits `p < 1/2`. -/
theorem offset_ascends_iff {k r : ℕ} (hk : k ≤ r) {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) :
    rungProb (2 * r + 1) (r + 1 + k) p ≤ rungProb (2 * r + 3) (r + 2 + k) p
      ↔ (1 - p) * (2 * (r : ℝ) + 2) ≤ (r : ℝ) + 1 + k := by
  have hm : (r + k) + 1 ≤ 2 * r + 1 := by omega
  have hiff := ladder_ascends_iff (n := 2 * r + 1) (m := r + k) hm hp0 hp1
  rw [show 2 * r + 1 + 2 = 2 * r + 3 by ring, show r + k + 2 = r + 2 + k by ring,
    show r + k + 1 = r + 1 + k by ring] at hiff
  rw [hiff]
  push_cast
  constructor <;> intro hth <;> nlinarith [hth]

/-- **NET-48's guarantee rung.**  The `3/3` rung of the three-seed ensemble actually run keeps
improving under extra seed pairs as long as `p ≥ 1/4`: the deployment guarantee is far more
robust to a weak per-seed frequency than the median reading, which needs `p ≥ 1/2`. -/
theorem net48_unanimity_threshold {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) :
    rungProb 3 3 p ≤ rungProb 5 4 p ↔ 1/4 ≤ p := by
  have hiff := ladder_ascends_iff (n := 3) (m := 2) (by omega) hp0 hp1
  norm_num at hiff
  rw [hiff]
  constructor <;> intro h <;> linarith

/-! ## 3.  The sharpened rate at every quota -/

/-- **The sharpened rate, quota-agnostic.**  Dominating every low-tail coefficient by the
middle one of the row and summing the geometric series exactly. -/
theorem rate_sharp_general {n m : ℕ} (hmn : m ≤ n) {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    1 - rungProb n m p
      ≤ (n.choose (n / 2) : ℝ) * p ^ m * (1 - p) ^ (n - m + 1) / (2 * p - 1) := by
  have hp0 : (0:ℝ) < p := by linarith
  have hq0 : (0:ℝ) ≤ 1 - p := by linarith
  have hd : (0:ℝ) < 2 * p - 1 := by linarith
  have hC0 : (0:ℝ) ≤ (n.choose (n / 2) : ℝ) := Nat.cast_nonneg _
  rcases Nat.eq_zero_or_pos m with rfl | hm1
  · -- the bottom rung is certain; the bound is trivially nonnegative
    rw [rungProb_zero]
    have : (0:ℝ) ≤ (n.choose (n / 2) : ℝ) * p ^ 0 * (1 - p) ^ (n - 0 + 1) / (2 * p - 1) := by
      positivity
    linarith
  rw [one_sub_rungProb n m p (by omega)]
  have hterm : ∀ j ∈ range m,
      (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)
        ≤ (n.choose (n / 2) : ℝ) * ((1 - p) ^ (n - m + 1) * (p ^ j * (1 - p) ^ (m - 1 - j))) := by
    intro j hj
    simp only [Finset.mem_range] at hj
    have hchoose : (n.choose j : ℝ) ≤ (n.choose (n / 2) : ℝ) := by
      exact_mod_cast Nat.choose_le_middle j n
    have hexp : n - j = (m - 1 - j) + (n - m + 1) := by omega
    have hnn : (0:ℝ) ≤ p ^ j * ((1 - p) ^ (m - 1 - j) * (1 - p) ^ (n - m + 1)) := by positivity
    calc (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)
        = (n.choose j : ℝ) * (p ^ j * ((1 - p) ^ (m - 1 - j) * (1 - p) ^ (n - m + 1))) := by
          rw [hexp, pow_add]; ring
      _ ≤ (n.choose (n / 2) : ℝ) * (p ^ j * ((1 - p) ^ (m - 1 - j) * (1 - p) ^ (n - m + 1))) :=
          mul_le_mul_of_nonneg_right hchoose hnn
      _ = (n.choose (n / 2) : ℝ) * ((1 - p) ^ (n - m + 1) * (p ^ j * (1 - p) ^ (m - 1 - j))) := by
          ring
  have hsum : ∑ j ∈ range m, (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)
      ≤ ∑ j ∈ range m,
          (n.choose (n / 2) : ℝ) * ((1 - p) ^ (n - m + 1) * (p ^ j * (1 - p) ^ (m - 1 - j))) :=
    Finset.sum_le_sum hterm
  set S : ℝ := ∑ j ∈ range m, p ^ j * (1 - p) ^ (m - 1 - j) with hS
  have hfactor : ∑ j ∈ range m,
      (n.choose (n / 2) : ℝ) * ((1 - p) ^ (n - m + 1) * (p ^ j * (1 - p) ^ (m - 1 - j)))
      = (n.choose (n / 2) : ℝ) * (1 - p) ^ (n - m + 1) * S := by
    rw [hS, Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by ring
  have hgeom : S * (p - (1 - p)) = p ^ m - (1 - p) ^ m := geom_sum₂_mul p (1 - p) m
  have hSle : S * (2 * p - 1) ≤ p ^ m := by
    have hpow : (0:ℝ) ≤ (1 - p) ^ m := by positivity
    have : S * (2 * p - 1) = p ^ m - (1 - p) ^ m := by rw [← hgeom]; ring
    linarith
  rw [le_div_iff₀ hd]
  have hCq : (0:ℝ) ≤ (n.choose (n / 2) : ℝ) * (1 - p) ^ (n - m + 1) := by positivity
  calc (∑ j ∈ range m, (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)) * (2 * p - 1)
      ≤ ((n.choose (n / 2) : ℝ) * (1 - p) ^ (n - m + 1) * S) * (2 * p - 1) :=
        mul_le_mul_of_nonneg_right (hsum.trans_eq hfactor) hd.le
    _ = ((n.choose (n / 2) : ℝ) * (1 - p) ^ (n - m + 1)) * (S * (2 * p - 1)) := by ring
    _ ≤ ((n.choose (n / 2) : ℝ) * (1 - p) ^ (n - m + 1)) * p ^ m :=
        mul_le_mul_of_nonneg_left hSle hCq
    _ = (n.choose (n / 2) : ℝ) * p ^ m * (1 - p) ^ (n - m + 1) := by ring

/-- The matching lower bound: the single largest omitted term. -/
theorem rate_general_lower {n m : ℕ} (hm : m + 1 ≤ n + 1) {p : ℝ} (hp0 : 0 < p) (hp1 : p ≤ 1) :
    (n.choose m : ℝ) * p ^ m * (1 - p) ^ (n - m) ≤ 1 - rungProb n (m + 1) p := by
  have hq0 : (0:ℝ) ≤ 1 - p := by linarith
  rw [one_sub_rungProb n (m + 1) p (by omega)]
  have hmem : m ∈ range (m + 1) := by simp
  exact Finset.single_le_sum
    (f := fun j => (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j))
    (fun j _ => by positivity) hmem

/-! ## 4.  D5, corrected: the step controls the tail, with an explicit constant -/

private theorem div_cancel_helper {P C d b : ℝ} (hd : d ≠ 0) (hb : b ≠ 0) :
    P * b * C / (d * b) = C * P / d := by
  field_simp

/-- **The general step-controls-the-tail bound.**  Whenever the two-step gap is strictly
positive, the whole remaining distance to certainty is at most that single step, multiplied by
the explicit constant `C(n,n/2)/((2p-1)·bracket)`.  The constant blows up exactly as the
bracket approaches `0`, i.e. as the quota approaches the calibration line
`m + 1 = (1-p)(n+1)` — D5's degeneration, made exact. -/
theorem miss_le_gap_div_constant {n m : ℕ} (hm : m + 1 ≤ n) {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1)
    (hbr : 0 < (n.choose m : ℝ) * p - (n.choose (m + 1) : ℝ) * (1 - p)) :
    1 - rungProb n (m + 1) p
      ≤ (rungProb (n + 2) (m + 2) p - rungProb n (m + 1) p) * (n.choose (n / 2) : ℝ)
          / ((2 * p - 1) * ((n.choose m : ℝ) * p - (n.choose (m + 1) : ℝ) * (1 - p))) := by
  have hd : (0:ℝ) < 2 * p - 1 := by linarith
  have hgap := rung_two_step_gap hm p
  have hrate := rate_sharp_general (n := n) (m := m + 1) (by omega) h h1
  rw [show n - (m + 1) + 1 = n - m by omega] at hrate
  have hbrne : ((n.choose m : ℝ) * p - (n.choose (m + 1) : ℝ) * (1 - p)) ≠ 0 := ne_of_gt hbr
  have heq : (rungProb (n + 2) (m + 2) p - rungProb n (m + 1) p) * (n.choose (n / 2) : ℝ)
      / ((2 * p - 1) * ((n.choose m : ℝ) * p - (n.choose (m + 1) : ℝ) * (1 - p)))
      = (n.choose (n / 2) : ℝ) * (p ^ (m + 1) * (1 - p) ^ (n - m)) / (2 * p - 1) := by
    rw [hgap]
    exact div_cancel_helper (ne_of_gt hd) hbrne
  rw [heq]
  calc 1 - rungProb n (m + 1) p
      ≤ (n.choose (n / 2) : ℝ) * p ^ (m + 1) * (1 - p) ^ (n - m) / (2 * p - 1) := hrate
    _ = (n.choose (n / 2) : ℝ) * (p ^ (m + 1) * (1 - p) ^ (n - m)) / (2 * p - 1) := by ring

/-- **Consistency at the median.**  There the constant is exactly `(2p-1)^{-2}`, so the general
bound specialises to `SeedSharpRate.miss_le_gap_div_sq`. -/
theorem median_case_constant (r : ℕ) {p : ℝ} (h : 1/2 < p) :
    ((2 * r + 1).choose ((2 * r + 1) / 2) : ℝ)
        / ((2 * p - 1) * (((2 * r + 1).choose r : ℝ) * p
            - ((2 * r + 1).choose (r + 1) : ℝ) * (1 - p)))
      = 1 / (2 * p - 1) ^ 2 := by
  have hd : (0:ℝ) < 2 * p - 1 := by linarith
  have hhalf : (2 * r + 1) / 2 = r := by omega
  have hsymm : ((2 * r + 1).choose (r + 1) : ℝ) = ((2 * r + 1).choose r : ℝ) := by
    have hnat : (2 * r + 1).choose (r + 1) = (2 * r + 1).choose r := by
      have hs := Nat.choose_symm (show r ≤ 2 * r + 1 by omega)
      rwa [show 2 * r + 1 - r = r + 1 by omega] at hs
    exact_mod_cast hnat
  have hpos : (0:ℝ) < ((2 * r + 1).choose r : ℝ) := by
    have : 0 < (2 * r + 1).choose r := Nat.choose_pos (by omega)
    exact_mod_cast this
  rw [hhalf, hsymm]
  have hbr : ((2 * r + 1).choose r : ℝ) * p - ((2 * r + 1).choose r : ℝ) * (1 - p)
      = ((2 * r + 1).choose r : ℝ) * (2 * p - 1) := by ring
  rw [hbr]
  field_simp

end SeedThreshold