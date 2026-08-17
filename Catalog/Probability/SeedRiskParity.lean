/-
# Parity governs calibration, never risk: conjecture C5 refuted and corrected

Conjecture **C5** of the previous cycle's `FUTURE_DIRECTIONS.md` proposed that the deployment
risk of an ensemble reading is *not* monotone across parities — that an even ensemble read at
its **upper** central rung is safer than the next odd ensemble read at its median, so that
odd ensembles should be read for calibrated science and even ones for conservative
deployment.

This file settles it, in the adversarial direction: **the first half of C5 is false.**  The
rung distribution function is monotone in the ensemble size at a *fixed* quota
(`SeedRisk.rungProb_mono_size`), so the risk `1 - rungProb n m p` is antitone in `n`; in
particular the even upper central rung is *strictly riskier* than the odd median that follows
it (`SeedRisk.even_upper_central_strictly_riskier`), the exact opposite of the conjectured
inequality, with the numerical counterexample at the round's own frequency recorded in
`SeedRisk.net48_C5_counterexample` (`risk = 11/27` for four seeds at the upper central rung
versus `7/27` for three seeds at the median).

What survives is the *second* half of C5, in corrected form: safety and calibration really are
different objectives, but the knob is the **quota**, not the parity
(`SeedRisk.risk_lowering_quota`, `SeedRisk.parity_dichotomy`).  Lowering the quota by one rung
buys strictly less risk at a strictly lower reported budget; changing parity buys calibration
and nothing else.

Main results.

* `SeedRisk.rungProb_mono_n`, `rungProb_mono_size`, `risk_antitone_size` — more seeds at the
  same quota is always safer, for every `n`, `m` and `0 ≤ p ≤ 1`.
* `SeedRisk.even_upper_central_strictly_riskier` — the exact excess is
  `p·C(2r,r)·p^r(1-p)^r > 0`, so the conjectured inequality fails for **every** `r` and every
  `0 < p < 1`, not just asymptotically.
* `SeedRisk.central_rung_bracket_strict` — the corrected picture: the odd median rung sits
  strictly between the two central even rungs, so no parity argument can make an even reading
  safer than the odd one at the same quota.
* `SeedRisk.parity_dichotomy` — risk is parity-blind (monotone in `n` at fixed quota) while
  calibration is parity-determined (`SeedQuota.exists_calibrated_rung_iff_odd`).
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Probability.SeedCondorcetLadder
import Probability.SeedCondorcetConvergence

namespace SeedRisk

open SeedQuota SeedCondorcet

/-! ## 1.  More seeds at the same quota is always safer -/

/-- **One extra seed cannot hurt a fixed quota.**  Conditioning on the extra seed
(`SeedQuota.rungProb_succ`) and using that rungs are antitone in the quota. -/
theorem rungProb_mono_n (n m : ℕ) {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) :
    rungProb n m p ≤ rungProb (n + 1) m p := by
  cases m with
  | zero => simp [rungProb_zero]
  | succ k =>
      rw [rungProb_succ]
      have hanti : rungProb n (k + 1) p ≤ rungProb n k p :=
        rungProb_antitone h0 h1 (Nat.le_succ k)
      nlinarith [hanti, h0, h1]

/-- Monotonicity in the ensemble size, at a fixed quota. -/
theorem rungProb_mono_size {n n' m : ℕ} (hnn : n ≤ n') {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) :
    rungProb n m p ≤ rungProb n' m p := by
  induction n', hnn using Nat.le_induction with
  | base => exact le_rfl
  | succ k hk ih => exact ih.trans (rungProb_mono_n k m h0 h1)

/-- The deployment risk of the `m`-th rung of an `n`-seed ensemble: the probability that the
reported budget fails on a fresh seed configuration, i.e. that fewer than `m` seeds pass. -/
noncomputable def risk (n m : ℕ) (p : ℝ) : ℝ := 1 - rungProb n m p

/-- **Risk is antitone in the ensemble size** — with no parity dependence whatsoever. -/
theorem risk_antitone_size {n n' m : ℕ} (hnn : n ≤ n') {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) :
    risk n' m p ≤ risk n m p := by
  have := rungProb_mono_size (m := m) hnn h0 h1
  simp only [risk]
  linarith

/-- **Risk decreases when the quota is lowered**, at a fixed ensemble size: the genuine
safety knob. -/
theorem risk_lowering_quota {n m m' : ℕ} (hm : m ≤ m') {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) :
    risk n m p ≤ risk n m' p := by
  have := rungProb_antitone (n := n) h0 h1 hm
  simp only [risk]
  linarith

/-! ## 2.  C5 refuted: the even upper central rung is strictly riskier -/

/-- **The exact excess of the odd median over the even upper central rung.**  Adding the
`(2r+1)`-st seed to a `2r`-seed ensemble read at quota `r+1` gains exactly
`p·C(2r,r)·p^r(1-p)^r`. -/
theorem odd_median_sub_even_upper (r : ℕ) (p : ℝ) :
    rungProb (2 * r + 1) (r + 1) p - rungProb (2 * r) (r + 1) p
      = p * (((2 * r).choose r : ℝ) * p ^ r * (1 - p) ^ r) := by
  have hconv := odd_rung_convex r p
  have hgap : rungProb (2 * r) r p - rungProb (2 * r) (r + 1) p
      = ((2 * r).choose r : ℝ) * p ^ r * (1 - p) ^ (2 * r - r) :=
    rungProb_sub_succ (by omega) p
  rw [show 2 * r - r = r by omega] at hgap
  rw [hconv, show p * rungProb (2 * r) r p + (1 - p) * rungProb (2 * r) (r + 1) p
      - rungProb (2 * r) (r + 1) p
      = p * (rungProb (2 * r) r p - rungProb (2 * r) (r + 1) p) by ring, hgap]

/-- **C5 is false, for every ensemble size and every nondegenerate `p`.**  The even ensemble
read at its upper central rung is *strictly riskier* than the odd ensemble one seed larger
read at its median — the opposite of the conjectured inequality. -/
theorem even_upper_central_strictly_riskier (r : ℕ) {p : ℝ} (h0 : 0 < p) (h1 : p < 1) :
    rungProb (2 * r) (r + 1) p < rungProb (2 * r + 1) (r + 1) p := by
  have hgap := odd_median_sub_even_upper r p
  have hc : (0:ℝ) < ((2 * r).choose r : ℝ) := by exact_mod_cast Nat.choose_pos (by omega)
  have hq : (0:ℝ) < 1 - p := by linarith
  have hpos : 0 < p * (((2 * r).choose r : ℝ) * p ^ r * (1 - p) ^ r) := by positivity
  linarith

/-- Risk form of the refutation. -/
theorem risk_even_upper_gt_odd_median (r : ℕ) {p : ℝ} (h0 : 0 < p) (h1 : p < 1) :
    risk (2 * r + 1) (r + 1) p < risk (2 * r) (r + 1) p := by
  have := even_upper_central_strictly_riskier r h0 h1
  simp only [risk]
  linarith

/-- **The corrected picture.**  The odd median rung lies *strictly* between the two central
even rungs of the ensemble one seed smaller: strictly safer than the upper one, strictly
riskier than the lower one.  Parity offers no free safety; only the quota does. -/
theorem central_rung_bracket_strict (r : ℕ) {p : ℝ} (h0 : 0 < p) (h1 : p < 1) :
    rungProb (2 * r) (r + 1) p < rungProb (2 * r + 1) (r + 1) p ∧
      rungProb (2 * r + 1) (r + 1) p < rungProb (2 * r) r p := by
  refine ⟨even_upper_central_strictly_riskier r h0 h1, ?_⟩
  have hconv := odd_rung_convex r p
  have hgap : rungProb (2 * r) r p - rungProb (2 * r) (r + 1) p
      = ((2 * r).choose r : ℝ) * p ^ r * (1 - p) ^ (2 * r - r) :=
    rungProb_sub_succ (by omega) p
  rw [show 2 * r - r = r by omega] at hgap
  have hc : (0:ℝ) < ((2 * r).choose r : ℝ) := by exact_mod_cast Nat.choose_pos (by omega)
  have hq : (0:ℝ) < 1 - p := by linarith
  have hpos : 0 < (1 - p) * (((2 * r).choose r : ℝ) * p ^ r * (1 - p) ^ r) := by positivity
  nlinarith [hconv, hgap, hpos]

/-! ## 3.  The dichotomy that survives -/

/-- **Parity dichotomy.**  Risk is parity-blind: it only ever improves with ensemble size, at
a fixed quota.  Calibration is parity-determined: a calibrated rung exists exactly for odd
ensembles.  The two objectives are therefore controlled by different variables — the quota
and the parity — and C5's proposal to trade one for the other by reading an even ensemble at
its upper central rung buys strictly *more* risk. -/
theorem parity_dichotomy {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) :
    (∀ n m : ℕ, risk (n + 1) m p ≤ risk n m p) ∧
      (∀ n : ℕ, (∃ m, rungProb n m (1/2 : ℝ) = 1/2) ↔ Odd n) := by
  refine ⟨fun n m => risk_antitone_size (Nat.le_succ n) h0 h1, exists_calibrated_rung_iff_odd⟩

/-! ## 4.  Lab notes: the four-seed reading at the measured frequency -/

theorem rungProb_four_four (p : ℝ) : rungProb 4 4 p = p ^ 4 := by
  have h := rungProb_sub_succ (n := 4) (m := 4) (by norm_num) p
  rw [rungProb_of_gt (n := 4) (m := 5) (by norm_num) p,
    show Nat.choose 4 4 = 1 from rfl, show 4 - 4 = 0 from rfl] at h
  norm_num at h
  linarith

theorem rungProb_four_three (p : ℝ) : rungProb 4 3 p = p ^ 4 + 4 * p ^ 3 * (1 - p) := by
  have h := rungProb_sub_succ (n := 4) (m := 3) (by norm_num) p
  rw [show (3 : ℕ) + 1 = 4 from rfl, rungProb_four_four,
    show Nat.choose 4 3 = 4 from rfl, show 4 - 3 = 1 from rfl, pow_one] at h
  norm_num at h
  linarith

theorem rungProb_four_two (p : ℝ) :
    rungProb 4 2 p = p ^ 4 + 4 * p ^ 3 * (1 - p) + 6 * p ^ 2 * (1 - p) ^ 2 := by
  have h := rungProb_sub_succ (n := 4) (m := 2) (by norm_num) p
  rw [show (2 : ℕ) + 1 = 3 from rfl, rungProb_four_three,
    show Nat.choose 4 2 = 6 from rfl, show 4 - 2 = 2 from rfl] at h
  norm_num at h
  linarith

/-- **The numerical counterexample to C5** at the round's measured per-seed frequency
`p = 2/3`: reading four seeds at the conservative (upper central) rung carries risk `11/27`,
strictly worse than the three-seed median's `7/27`.  Only *lowering* the quota helps: the
four-seed lower central rung carries risk `1/9`. -/
theorem net48_C5_counterexample :
    risk 4 3 (2/3 : ℝ) = 11/27 ∧ risk 3 2 (2/3 : ℝ) = 7/27 ∧ risk 4 2 (2/3 : ℝ) = 1/9 ∧
      risk 3 2 (2/3 : ℝ) < risk 4 3 (2/3 : ℝ) ∧ risk 4 2 (2/3 : ℝ) < risk 3 2 (2/3 : ℝ) := by
  have h43 : risk 4 3 (2/3 : ℝ) = 11/27 := by
    simp only [risk, rungProb_four_three]; norm_num
  have h32 : risk 3 2 (2/3 : ℝ) = 7/27 := by
    simp only [risk, rungProb_three_two]; norm_num
  have h42 : risk 4 2 (2/3 : ℝ) = 1/9 := by
    simp only [risk, rungProb_four_two]; norm_num
  refine ⟨h43, h32, h42, ?_, ?_⟩
  · rw [h43, h32]; norm_num
  · rw [h42, h32]; norm_num

end SeedRisk