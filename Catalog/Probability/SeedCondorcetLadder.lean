/-
# The Condorcet ladder of a seed ensemble, and what a fourth seed costs (NET-48 follow-up)

`Logic.KneeMedianAmplification` proved, for the **three**-seed ensemble of round NET-48, that
the median rung strictly amplifies a per-seed majority: `p > 1/2 ⟹ 3p² − 2p³ > p`.  That is
the case `s = 1` of a general statement, which this file proves in full, on top of the
general-`n` rung theory of `Probability.SeedQuotaBinomial`.

Main results.

* `SeedCondorcet.rungProb_two_step` — adding two seeds and raising the quota by one:
  `rungProb (n+2) (m+2) p = p²·F m + 2p(1-p)·F (m+1) + (1-p)²·F (m+2)` with `F = rungProb n`.
* `SeedCondorcet.median_rung_gap` — the resulting exact gap between consecutive **odd**
  ensembles is a single monomial:
  `rungProb (2r+3) (r+2) p − rungProb (2r+1) (r+1) p = C(2r+1,r)·p^(r+1)·(1-p)^(r+1)·(2p−1)`.
  The whole Condorcet phenomenon is this one identity: the sign of the gap is the sign of
  `2p − 1`, so a per-seed majority is amplified, a per-seed minority suppressed, and a coin
  flip is a fixed point of the ladder — for every ensemble size at once.
* `SeedCondorcet.condorcet_ladder` / `condorcet_ladder_strict` — hence the median rung is
  monotone (strictly, for `1/2 < p < 1`) along the odd ensembles, and
  `SeedCondorcet.median_amplifies_general` : `p ≤ rungProb (2s+1) (s+1) p` for every `s`,
  strictly for `s ≥ 1`.  This is the **Condorcet jury theorem** in the seed-ensemble
  formulation, and it contains `KneeAmplify.median_amplifies` as the case `s = 1`
  (`rungProb_three_eq_quotaProb`).
* `SeedCondorcet.minority_ladder` — the exact mirror statement below `1/2`: reading the
  centre of a *bad* ensemble makes things strictly worse, so amplification is not a free
  lunch.

Lab-note readings for round NET-48 (`d = 4`, `ctx = 2048`; three seeds, knees
`{160, 224, 256}`, median `224 = (7/8)·(d·ctx/32)`; the stated next step is a fourth seed).

* `SeedCondorcet.net48_three_seed_calibrated` : the current three-seed reading is calibrated.
* `SeedCondorcet.net48_fourth_seed_defect` : a fourth seed destroys calibration by exactly
  `3/16` — its two central rungs read `11/16` and `5/16`, and no rung of a four-seed
  ensemble reads `1/2`.
* `SeedCondorcet.net48_fifth_seed_recalibrates` : a fifth seed restores exact calibration.
  So the deployment recommendation the parity law makes is sharp: **seed ensembles should be
  odd**; a fourth seed is only worth running as a step towards a fifth.
* `SeedCondorcet.net48_five_beats_three` : at the measured six-seed frequency `p = 2/3` of
  landing at or below the `7/8` budget, the median rung improves from `20/27` (three seeds)
  to `64/81` (five seeds).
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Logic.KneeMedianAmplification

namespace SeedCondorcet

open Finset SeedQuota

/-! ## 1.  Two more seeds: the exact gap between consecutive odd ensembles -/

/-- Conditioning on two extra seeds. -/
theorem rungProb_two_step (n m : ℕ) (p : ℝ) :
    rungProb (n + 2) (m + 2) p
      = p ^ 2 * rungProb n m p + 2 * p * (1 - p) * rungProb n (m + 1) p
        + (1 - p) ^ 2 * rungProb n (m + 2) p := by
  rw [show n + 2 = (n + 1) + 1 from rfl, show m + 2 = (m + 1) + 1 from rfl,
    rungProb_succ, rungProb_succ, rungProb_succ]
  ring

/-- **The Condorcet gap is a single monomial.**  Going from a `2r+1`-seed ensemble to a
`2r+3`-seed one changes the median rung by exactly
`C(2r+1,r)·p^(r+1)·(1-p)^(r+1)·(2p-1)`. -/
theorem median_rung_gap (r : ℕ) (p : ℝ) :
    rungProb (2 * r + 3) (r + 2) p - rungProb (2 * r + 1) (r + 1) p
      = ((2 * r + 1).choose r : ℝ) * p ^ (r + 1) * (1 - p) ^ (r + 1) * (2 * p - 1) := by
  have hstep := rungProb_two_step (2 * r + 1) r p
  rw [show 2 * r + 1 + 2 = 2 * r + 3 by ring] at hstep
  have hg1 : rungProb (2 * r + 1) r p - rungProb (2 * r + 1) (r + 1) p
      = ((2 * r + 1).choose r : ℝ) * p ^ r * (1 - p) ^ (2 * r + 1 - r) :=
    rungProb_sub_succ (by omega) p
  have hg2 : rungProb (2 * r + 1) (r + 1) p - rungProb (2 * r + 1) (r + 2) p
      = ((2 * r + 1).choose (r + 1) : ℝ) * p ^ (r + 1) * (1 - p) ^ (2 * r + 1 - (r + 1)) :=
    rungProb_sub_succ (by omega) p
  have hchoose : ((2 * r + 1).choose (r + 1) : ℝ) = ((2 * r + 1).choose r : ℝ) := by
    have hnat : (2 * r + 1).choose (r + 1) = (2 * r + 1).choose r := by
      have h := Nat.choose_symm (show r ≤ 2 * r + 1 by omega)
      rw [show 2 * r + 1 - r = r + 1 by omega] at h
      exact h
    exact_mod_cast hnat
  rw [show 2 * r + 1 - r = r + 1 by omega] at hg1
  rw [show 2 * r + 1 - (r + 1) = r by omega, hchoose] at hg2
  have hA : rungProb (2 * r + 1) r p
      = rungProb (2 * r + 1) (r + 1) p
        + ((2 * r + 1).choose r : ℝ) * p ^ r * (1 - p) ^ (r + 1) := by linarith
  have hC : rungProb (2 * r + 1) (r + 2) p
      = rungProb (2 * r + 1) (r + 1) p
        - ((2 * r + 1).choose r : ℝ) * p ^ (r + 1) * (1 - p) ^ r := by linarith
  rw [hstep, hA, hC]
  ring

/-- **One rung of the Condorcet ladder.**  For a per-seed majority the median rung of a
`2r+3`-seed ensemble is at least that of a `2r+1`-seed one. -/
theorem condorcet_step (r : ℕ) {p : ℝ} (h : 1/2 ≤ p) (h1 : p ≤ 1) :
    rungProb (2 * r + 1) (r + 1) p ≤ rungProb (2 * r + 3) (r + 2) p := by
  have hgap := median_rung_gap r p
  have hp0 : (0:ℝ) ≤ p := by linarith
  have hq0 : (0:ℝ) ≤ 1 - p := by linarith
  have hsign : (0:ℝ) ≤ 2 * p - 1 := by linarith
  have hc : (0:ℝ) ≤ ((2 * r + 1).choose r : ℝ) := Nat.cast_nonneg _
  nlinarith [hgap, mul_nonneg (mul_nonneg (mul_nonneg hc (pow_nonneg hp0 (r + 1)))
    (pow_nonneg hq0 (r + 1))) hsign]

/-- The strict form: a strict per-seed majority is strictly amplified at every step. -/
theorem condorcet_step_strict (r : ℕ) {p : ℝ} (h : 1/2 < p) (h1 : p < 1) :
    rungProb (2 * r + 1) (r + 1) p < rungProb (2 * r + 3) (r + 2) p := by
  have hgap := median_rung_gap r p
  have hp0 : (0:ℝ) < p := by linarith
  have hq0 : (0:ℝ) < 1 - p := by linarith
  have hsign : (0:ℝ) < 2 * p - 1 := by linarith
  have hc : (0:ℝ) < ((2 * r + 1).choose r : ℝ) := by
    exact_mod_cast Nat.choose_pos (by omega)
  nlinarith [hgap, mul_pos (mul_pos (mul_pos hc (pow_pos hp0 (r + 1)))
    (pow_pos hq0 (r + 1))) hsign]

/-- **The Condorcet ladder.**  For a per-seed majority the median rung is monotone in the
(odd) ensemble size. -/
theorem condorcet_ladder {p : ℝ} (h : 1/2 ≤ p) (h1 : p ≤ 1) {r s : ℕ} (hrs : r ≤ s) :
    rungProb (2 * r + 1) (r + 1) p ≤ rungProb (2 * s + 1) (s + 1) p := by
  induction s, hrs using Nat.le_induction with
  | base => exact le_rfl
  | succ s hs ih =>
      refine ih.trans ?_
      have := condorcet_step s h h1
      rw [show 2 * (s + 1) + 1 = 2 * s + 3 by ring, show s + 1 + 1 = s + 2 by ring]
      exact this

/-- Strict version of the ladder. -/
theorem condorcet_ladder_strict {p : ℝ} (h : 1/2 < p) (h1 : p < 1) {r s : ℕ} (hrs : r < s) :
    rungProb (2 * r + 1) (r + 1) p < rungProb (2 * s + 1) (s + 1) p := by
  induction s, hrs using Nat.le_induction with
  | base =>
      have := condorcet_step_strict r h h1
      rw [show 2 * (r + 1) + 1 = 2 * r + 3 by ring, show r + 1 + 1 = r + 2 by ring]
      exact this
  | succ s hs ih =>
      refine ih.trans ?_
      have := condorcet_step_strict s h h1
      rw [show 2 * (s + 1) + 1 = 2 * s + 3 by ring, show s + 1 + 1 = s + 2 by ring]
      exact this

/-- The one-seed ensemble reads the per-seed probability itself. -/
theorem rungProb_one_one (p : ℝ) : rungProb 1 1 p = p := by
  rw [rungProb, show Finset.Ico 1 (1 + 1) = ({1} : Finset ℕ) from rfl]
  simp

/-- **Condorcet jury theorem, seed-ensemble form.**  For any per-seed majority `p ≥ 1/2`, the
median rung of any odd ensemble is at least `p`: reading the centre never loses, and by
`median_amplifies_general_strict` it strictly gains from three seeds on.  This is the
general-`s` form of `KneeAmplify.median_amplifies`. -/
theorem median_amplifies_general (s : ℕ) {p : ℝ} (h : 1/2 ≤ p) (h1 : p ≤ 1) :
    p ≤ rungProb (2 * s + 1) (s + 1) p := by
  have := condorcet_ladder (p := p) h h1 (Nat.zero_le s)
  simpa [rungProb_one_one] using this

theorem median_amplifies_general_strict {s : ℕ} (hs : 1 ≤ s) {p : ℝ} (h : 1/2 < p)
    (h1 : p < 1) : p < rungProb (2 * s + 1) (s + 1) p := by
  have := condorcet_ladder_strict (p := p) h h1 (show 0 < s by omega)
  simpa [rungProb_one_one] using this

/-- **The mirror statement.**  Below `1/2` the ladder runs the other way: a per-seed minority
is strictly suppressed, so an ensemble centre is only as trustworthy as the per-seed
tendency it magnifies. -/
theorem minority_ladder {p : ℝ} (h0 : 0 < p) (h : p < 1/2) {r s : ℕ} (hrs : r < s) :
    rungProb (2 * s + 1) (s + 1) p < rungProb (2 * r + 1) (r + 1) p := by
  induction s, hrs using Nat.le_induction with
  | base =>
      have hgap := median_rung_gap r p
      have hq0 : (0:ℝ) < 1 - p := by linarith
      have hsign : (0:ℝ) < 1 - 2 * p := by linarith
      have hc : (0:ℝ) < ((2 * r + 1).choose r : ℝ) := by
        exact_mod_cast Nat.choose_pos (by omega)
      rw [show 2 * (r + 1) + 1 = 2 * r + 3 by ring, show r + 1 + 1 = r + 2 by ring]
      nlinarith [hgap, mul_pos (mul_pos (mul_pos hc (pow_pos h0 (r + 1)))
        (pow_pos hq0 (r + 1))) hsign]
  | succ s hs ih =>
      refine lt_trans ?_ ih
      have hgap := median_rung_gap s p
      have hq0 : (0:ℝ) < 1 - p := by linarith
      have hsign : (0:ℝ) < 1 - 2 * p := by linarith
      have hc : (0:ℝ) < ((2 * s + 1).choose s : ℝ) := by
        exact_mod_cast Nat.choose_pos (by omega)
      rw [show 2 * (s + 1) + 1 = 2 * s + 3 by ring, show s + 1 + 1 = s + 2 by ring]
      nlinarith [hgap, mul_pos (mul_pos (mul_pos hc (pow_pos h0 (s + 1)))
        (pow_pos hq0 (s + 1))) hsign]

/-! ## 2.  The bridge to the three-seed sample space of `Logic.KneeMedianAmplification` -/

theorem rungProb_three_two (p : ℝ) : rungProb 3 2 p = 3 * p ^ 2 - 2 * p ^ 3 := by
  rw [rungProb, show Finset.Ico 2 (3 + 1) = ({2, 3} : Finset ℕ) from rfl]
  norm_num [Nat.choose]
  ring

theorem rungProb_three_three (p : ℝ) : rungProb 3 3 p = p ^ 3 := by
  rw [rungProb, show Finset.Ico 3 (3 + 1) = ({3} : Finset ℕ) from rfl]
  norm_num [Nat.choose]

theorem rungProb_three_one (p : ℝ) : rungProb 3 1 p = 3 * p - 3 * p ^ 2 + p ^ 3 := by
  rw [rungProb, show Finset.Ico 1 (3 + 1) = ({1, 2, 3} : Finset ℕ) from rfl]
  norm_num [Nat.choose]
  ring

/-- **The general theory reproduces the measured three-seed sample space.**  For every
nontrivial quota the binomial rung of a three-seed ensemble is the polynomial computed from
the eight-point space in `Logic.KneeMedianAmplification`. -/
theorem rungProb_three_eq_quotaProb (p : ℝ) {m : ℕ} (h1 : 1 ≤ m) (h3 : m ≤ 3) :
    rungProb 3 m p = KneeAmplify.quotaProb p m := by
  interval_cases m
  · rw [rungProb_three_one, KneeAmplify.quotaProb_one]
  · rw [rungProb_three_two, KneeAmplify.quotaProb_two]
  · rw [rungProb_three_three, KneeAmplify.quotaProb_three]

/-! ## 3.  Lab notes: what the planned fourth seed at `(d = 4, ctx = 2048)` costs -/

/-- The completed NET-48 three-seed ensemble reads its centre without bias. -/
theorem net48_three_seed_calibrated : rungProb 3 2 (1/2 : ℝ) = 1/2 := by
  have := odd_median_rung_calibrated 1
  norm_num at this
  exact this

/-- **The cost of a fourth seed.**  The two central rungs of a four-seed ensemble read
`11/16` and `5/16` — a calibration defect of exactly `3/16` in either direction — and *no*
rung of a four-seed ensemble is calibrated. -/
theorem net48_fourth_seed_defect :
    rungProb 4 2 (1/2 : ℝ) = 11/16 ∧ rungProb 4 3 (1/2 : ℝ) = 5/16 ∧
      (∀ m : ℕ, rungProb 4 m (1/2 : ℝ) ≠ 1/2) := by
  have hcentral := even_central_rungs 2
  have hdef : defect 2 = 3/16 := by
    rw [defect]
    norm_num [Nat.choose]
  refine ⟨?_, ?_, ?_⟩
  · have h := hcentral.1
    rw [hdef] at h
    norm_num at h
    simpa using h
  · have h := hcentral.2
    rw [hdef] at h
    norm_num at h
    simpa using h
  · intro m
    have := even_no_calibrated_rung 2 m
    norm_num at this
    simpa using this

/-- **A fifth seed restores exact calibration** — the parity law's deployment content: read
ensembles of odd size. -/
theorem net48_fifth_seed_recalibrates : rungProb 5 3 (1/2 : ℝ) = 1/2 := by
  have := odd_median_rung_calibrated 2
  norm_num at this
  exact this

/-- The measured six-seed frequency of landing at or below the `7/8` budget is `2/3`.  At
that per-seed frequency the three-seed median rung reads `20/27`, and a five-seed median
rung would read `64/81 > 20/27` — the quantitative value of the *next odd* ensemble. -/
theorem net48_five_beats_three :
    rungProb 3 2 (2/3 : ℝ) = 20/27 ∧ rungProb 5 3 (2/3 : ℝ) = 64/81 ∧
      rungProb 3 2 (2/3 : ℝ) < rungProb 5 3 (2/3 : ℝ) := by
  have h3 : rungProb 3 2 (2/3 : ℝ) = 20/27 := by rw [rungProb_three_two]; norm_num
  have h5 : rungProb 5 3 (2/3 : ℝ) = 64/81 := by
    rw [rungProb, show Finset.Ico 3 (5 + 1) = ({3, 4, 5} : Finset ℕ) from rfl]
    norm_num [Nat.choose]
  exact ⟨h3, h5, by rw [h3, h5]; norm_num⟩

/-- Non-vacuity: the five-seed improvement is an instance of the general ladder, not a
numerical coincidence. -/
theorem net48_five_beats_three_general :
    rungProb 3 2 (2/3 : ℝ) < rungProb 5 3 (2/3 : ℝ) := by
  have := condorcet_ladder_strict (p := (2/3 : ℝ)) (by norm_num) (by norm_num)
    (show 1 < 2 by norm_num)
  norm_num at this
  exact this

end SeedCondorcet