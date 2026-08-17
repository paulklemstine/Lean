/-
# The width of the contamination curve, and where it is minimised

Conjecture **E4** of `FUTURE_DIRECTIONS.md`: cycle 4 identified the set of readings a rung can
be pushed to by `c` corrupted seeds with the clean interval
`[quotaBudget K (m-c), quotaBudget K (m+c)]` (`SeedContamination.contamination_curve`), so the
*width* of that interval is the deployment-relevant robustness measure.  E4 conjectured that
the median rung minimises this width **for every clean sample**, matching the parity law's
choice of the calibrated rung.

This file settles E4 with a split verdict.

* **Refuted as stated.**  `SeedWindow.median_not_always_narrowest` exhibits an explicit
  five-seed sample (`![0,0,0,10,20]`, the shape of a run in which three seeds agree and two
  are stragglers) whose median window is *strictly wider* than an off-centre window.  The
  minimiser of the width follows the sample's gaps, not its centre.
* **True under the hypothesis the experiment is supposed to supply.**
  `SeedWindow.width_median_minimal` : if the ladder's gaps are *centre-minimal* — the closer a
  gap sits to the middle of the ladder, the smaller it is, which is what order statistics of a
  unimodal law do — then the median window is narrowest among *all* rungs, for every radius
  `c ≤ r`.  The proof is a two-sided induction along the ladder driven by the exact step
  criterion `SeedWindow.width_step`: the window widens on moving outwards exactly when the gap
  it takes in exceeds the gap it lets out.
* **Lab note.**  `SeedWindow.net48_sample_not_centre_minimal` : the round's own three-seed
  sample `{160, 224, 256}` *fails* the centre-minimality hypothesis (its two gaps `64` and `32`
  are equidistant from the centre but unequal), so at `(d = 4, ctx = 2048)` the median's
  robustness is not explained by E4's mechanism — it is explained by the breakdown number, the
  median being the only rung of a three-seed ensemble with a nonempty curve at all.

Everything is stated for the quota ladder `KneeQuota.quotaBudget` of the previous files.
-/

import Mathlib
import Probability.SeedContaminationCurve

namespace SeedWindow

open Finset KneeMedian KneeQuota

/-! ## 1.  Windows on an abstract ladder -/

/-- The gap between two consecutive rungs of a ladder `a`. -/
def gap (a : ℕ → ℕ) (j : ℕ) : ℕ := a (j + 1) - a j

/-- The width of the symmetric window of radius `c` about the `m`-th rung: by
`SeedContamination.contamination_curve` this is exactly the diameter of the set of readings the
`m`-th rung can be pushed to by corrupting `c` seeds. -/
def width (a : ℕ → ℕ) (c m : ℕ) : ℕ := a (m + c) - a (m - c)

/-- Twice the distance of the gap `j` from the centre of an `n`-rung ladder, i.e. `|2j - n|`,
written with truncated subtraction so that it stays in `ℕ`. -/
def centreDist (n j : ℕ) : ℕ := (2 * j - n) + (n - 2 * j)

theorem centreDist_eq_of_le {n j : ℕ} (h : 2 * j ≤ n) : centreDist n j = n - 2 * j := by
  simp [centreDist, Nat.sub_eq_zero_of_le h]

/-- **The exact step criterion, outwards.**  Moving the window one rung up widens it exactly
when the gap it takes in is at least the gap it lets out. -/
theorem width_step (a : ℕ → ℕ) {c m : ℕ} (hc : c ≤ m)
    (h1 : a (m - c) ≤ a (m + c)) (h2 : a (m - c) ≤ a (m - c + 1))
    (h3 : a (m + c) ≤ a (m + c + 1)) (h : gap a (m - c) ≤ gap a (m + c)) :
    width a c m ≤ width a c (m + 1) := by
  have e1 : m + 1 - c = (m - c) + 1 := by omega
  have e2 : m + 1 + c = (m + c) + 1 := by omega
  simp only [width, gap, e1, e2] at *
  omega

/-- **The exact step criterion, inwards.**  Moving the window one rung down widens it exactly
when the gap it takes in is at least the gap it lets out. -/
theorem width_step' (a : ℕ → ℕ) {c m : ℕ} (hc : c ≤ m)
    (h1 : a (m - c) ≤ a (m + c)) (h2 : a (m - c) ≤ a (m - c + 1))
    (h3 : a (m + c) ≤ a (m + c + 1)) (h : gap a (m + c) ≤ gap a (m - c)) :
    width a c (m + 1) ≤ width a c m := by
  have e1 : m + 1 - c = (m - c) + 1 := by omega
  have e2 : m + 1 + c = (m + c) + 1 := by omega
  simp only [width, gap, e1, e2] at *
  omega

/-! ## 2.  Centre-minimal ladders: the median window is the narrowest -/

section CentreMinimal

variable {a : ℕ → ℕ} {r c : ℕ}

/-- The ladder is *centre-minimal*: a gap strictly closer to the middle of the ladder is no
larger.  This is the finite-sample shadow of "the order statistics of a unimodal law are
densest in the middle".  Nothing is demanded of two gaps at the *same* distance from the
centre — the induction below never compares such a pair, and demanding equality there would
make the hypothesis fail almost surely for a sample from a continuous law. -/
def CentreMinimal (a : ℕ → ℕ) (n : ℕ) : Prop :=
  ∀ j k, j < n → k < n → centreDist n j < centreDist n k → gap a j ≤ gap a k

/-- Monotonicity of the ladder up to its top rung. -/
def LadderMono (a : ℕ → ℕ) (n : ℕ) : Prop := ∀ i j, i ≤ j → j ≤ n → a i ≤ a j

/-- Above the median the window only widens. -/
theorem width_le_of_high (hmono : LadderMono a (2 * r + 1))
    (hgap : CentreMinimal a (2 * r + 1)) (hc1 : 1 ≤ c) :
    ∀ t : ℕ, r + 1 + t + c ≤ 2 * r + 1 → width a c (r + 1) ≤ width a c (r + 1 + t) := by
  intro t
  induction t with
  | zero => intro _; exact le_rfl
  | succ t ih =>
      intro ht
      have hIH : width a c (r + 1) ≤ width a c (r + 1 + t) := ih (by omega)
      set m := r + 1 + t with hm
      have hcm : c ≤ m := by omega
      have h1 : a (m - c) ≤ a (m + c) := hmono _ _ (by omega) (by omega)
      have h2 : a (m - c) ≤ a (m - c + 1) := hmono _ _ (by omega) (by omega)
      have h3 : a (m + c) ≤ a (m + c + 1) := hmono _ _ (by omega) (by omega)
      have hd : centreDist (2 * r + 1) (m - c) < centreDist (2 * r + 1) (m + c) := by
        simp only [centreDist]; omega
      have hgg : gap a (m - c) ≤ gap a (m + c) :=
        hgap _ _ (by omega) (by omega) hd
      have := width_step a hcm h1 h2 h3 hgg
      have e : r + 1 + (t + 1) = m + 1 := by omega
      rw [e]
      exact hIH.trans this

/-- Below the median the window only widens. -/
theorem width_le_of_low (hmono : LadderMono a (2 * r + 1))
    (hgap : CentreMinimal a (2 * r + 1)) (hc : c ≤ r) (hc1 : 1 ≤ c) :
    ∀ t : ℕ, t + c ≤ r + 1 → width a c (r + 1) ≤ width a c (r + 1 - t) := by
  intro t
  induction t with
  | zero => intro _; exact le_rfl
  | succ t ih =>
      intro ht
      have hIH : width a c (r + 1) ≤ width a c (r + 1 - t) := ih (by omega)
      set m := r - t with hm
      have hcm : c ≤ m := by omega
      have h1 : a (m - c) ≤ a (m + c) := hmono _ _ (by omega) (by omega)
      have h2 : a (m - c) ≤ a (m - c + 1) := hmono _ _ (by omega) (by omega)
      have h3 : a (m + c) ≤ a (m + c + 1) := hmono _ _ (by omega) (by omega)
      have hd : centreDist (2 * r + 1) (m + c) < centreDist (2 * r + 1) (m - c) := by
        simp only [centreDist]; omega
      have hgg : gap a (m + c) ≤ gap a (m - c) :=
        hgap _ _ (by omega) (by omega) hd
      have hstep := width_step' a hcm h1 h2 h3 hgg
      have e1 : r + 1 - t = m + 1 := by omega
      have e2 : r + 1 - (t + 1) = m := by omega
      rw [e2]
      rw [e1] at hIH
      exact hIH.trans hstep

/-- **The median window is the narrowest, on a centre-minimal ladder.**  For every radius
`c ≤ r` and every rung `m` whose window of radius `c` fits inside the ladder, the median rung's
window is at most as wide.  This is conjecture E4 under the hypothesis that makes it true. -/
theorem width_median_minimal (hmono : LadderMono a (2 * r + 1))
    (hgap : CentreMinimal a (2 * r + 1)) (hc : c ≤ r) {m : ℕ}
    (hcm : c ≤ m) (hmn : m + c ≤ 2 * r + 1) :
    width a c (r + 1) ≤ width a c m := by
  rcases Nat.eq_zero_or_pos c with hc0 | hc1
  · subst hc0; simp [width]
  rcases le_or_gt m (r + 1) with hle | hgt
  · have h := width_le_of_low hmono hgap hc hc1 (r + 1 - m) (by omega)
    have e : r + 1 - (r + 1 - m) = m := by omega
    rwa [e] at h
  · have h := width_le_of_high (c := c) hmono hgap hc1 (m - (r + 1)) (by omega)
    have e : r + 1 + (m - (r + 1)) = m := by omega
    rwa [e] at h

end CentreMinimal

/-! ## 3.  The hypothesis cannot be dropped -/

section Counterexample

open KneeQuota

variable {ι : Type*} [Fintype ι]

/-- Identification of a quota budget: `b` is the `m`-th rung as soon as the quota is met at `b`
and missed below it. -/
theorem quotaBudget_eq_of {K : ι → ℕ} {m b : ℕ} (h1 : m ≤ (passSet K b).card)
    (h2 : ∀ b' < b, (passSet K b').card < m) : quotaBudget K m = b := by
  refine le_antisymm (quotaBudget_le_of_card h1) ?_
  by_contra hcon
  push_neg at hcon
  have hne : {t | m ≤ (passSet K t).card}.Nonempty := ⟨b, h1⟩
  have hmem : m ≤ (passSet K (quotaBudget K m)).card := by
    simpa [quotaBudget] using Nat.sInf_mem hne
  exact absurd hmem (Nat.not_le.2 (h2 _ hcon))

/-- The empty quota costs nothing: the bottom of every ladder is `0`. -/
theorem quotaBudget_zero (K : ι → ℕ) : quotaBudget K 0 = 0 :=
  quotaBudget_eq_of (by simp) (by omega)

/-- The counterexample sample: three seeds agree at `0`, two stragglers sit at `10` and `20`. -/
def straggler : Fin 5 → ℕ := ![0, 0, 0, 10, 20]

theorem passSet_straggler_low {b : ℕ} (hb : b < 10) :
    passSet straggler b = ({0, 1, 2} : Finset (Fin 5)) := by
  ext i
  simp only [passSet, mem_filter, mem_univ, true_and]
  fin_cases i <;> simp [straggler] <;> omega

theorem quotaBudget_straggler_low {m : ℕ} (hm : m ≤ 3) :
    quotaBudget straggler m = 0 := by
  refine quotaBudget_eq_of ?_ (by omega)
  have h : passSet straggler 0 = ({0, 1, 2} : Finset (Fin 5)) := passSet_straggler_low (by omega)
  rw [h]
  simpa using hm

theorem quotaBudget_straggler_four : quotaBudget straggler 4 = 10 := by
  refine quotaBudget_eq_of ?_ ?_
  · have h : passSet straggler 10 = ({0, 1, 2, 3} : Finset (Fin 5)) := by
      ext i
      simp only [passSet, mem_filter, mem_univ, true_and]
      fin_cases i <;> simp [straggler]
    rw [h]
    decide
  · intro b' hb'
    rw [passSet_straggler_low (by omega)]
    decide

/-- **Conjecture E4 is false as stated.**  For the straggler sample the median window of
radius `1` has width `10`, while the window of radius `1` about the *second* rung has width
`0`: the median is strictly wider, so it does not minimise the contamination curve for every
sample.  (Both windows are legitimate: `1 ≤ m - 1` and `m + 1 ≤ 5` in both cases.) -/
theorem median_not_always_narrowest :
    width (quotaBudget straggler) 1 2 = 0 ∧
      width (quotaBudget straggler) 1 3 = 10 ∧
      width (quotaBudget straggler) 1 2 < width (quotaBudget straggler) 1 3 := by
  have h1 : quotaBudget straggler 1 = 0 := quotaBudget_straggler_low (by omega)
  have h2 : quotaBudget straggler 2 = 0 := quotaBudget_straggler_low (by omega)
  have h3 : quotaBudget straggler 3 = 0 := quotaBudget_straggler_low (by omega)
  have h4 : quotaBudget straggler 4 = 10 := quotaBudget_straggler_four
  refine ⟨?_, ?_, ?_⟩ <;> simp [width, h1, h2, h3, h4]

/-- The straggler sample indeed violates centre-minimality: the gap `3 → 4`, which sits
*closer* to the centre of the five-rung ladder than the gap `1 → 2`, is the strictly larger
one. -/
theorem straggler_not_centreMinimal : ¬ CentreMinimal (quotaBudget straggler) 5 := by
  intro h
  have h2 : quotaBudget straggler 2 = 0 := quotaBudget_straggler_low (by omega)
  have h1 : quotaBudget straggler 1 = 0 := quotaBudget_straggler_low (by omega)
  have h3 : quotaBudget straggler 3 = 0 := quotaBudget_straggler_low (by omega)
  have h4 : quotaBudget straggler 4 = 10 := quotaBudget_straggler_four
  have hd : centreDist 5 3 < centreDist 5 1 := by simp [centreDist]
  have hcon := h 3 1 (by omega) (by omega) hd
  simp only [gap, h1, h2, h3, h4] at hcon
  omega

end Counterexample

/-! ## 4.  The centre-minimal hypothesis is not vacuous, and the round's sample fails it -/

/-- A centre-minimal five-rung ladder: rungs `0, 6, 10, 12, 14, 18` (the rung `0` is the empty
quota), with gaps `6, 4, 2, 2, 4` — small in the middle, large at the ends, the shape the order
statistics of a unimodal law have. -/
def unimodalLadder : ℕ → ℕ
  | 0 => 0
  | 1 => 6
  | 2 => 10
  | 3 => 12
  | 4 => 14
  | _ => 18

theorem unimodalLadder_centreMinimal : CentreMinimal unimodalLadder 5 := by
  intro j k hj hk hd
  interval_cases j <;> interval_cases k <;> revert hd <;> decide

theorem unimodalLadder_mono : LadderMono unimodalLadder 5 := by
  intro i j hij hj
  interval_cases j <;> interval_cases i <;> decide

/-- On a centre-minimal ladder the theorem bites: the median window is strictly narrower than
either off-centre window of the same radius, and narrowest among all of them. -/
theorem unimodal_median_strictly_narrowest :
    width unimodalLadder 1 3 = 4 ∧ width unimodalLadder 1 2 = 6 ∧
      width unimodalLadder 1 4 = 6 ∧
      ∀ m, 1 ≤ m → m + 1 ≤ 5 → width unimodalLadder 1 3 ≤ width unimodalLadder 1 m := by
  refine ⟨by decide, by decide, by decide, ?_⟩
  intro m hm1 hm5
  exact width_median_minimal (r := 2) (c := 1) unimodalLadder_mono
    unimodalLadder_centreMinimal (by omega) hm1 (by omega)

/-- **Lab note (NET-48).**  The round's own three-seed sample `{160, 224, 256}` has gaps `64`
and `32` sitting at the *same* distance from the centre of its ladder, so centre-minimality
holds only vacuously there: no pair of gaps is strictly closer to the centre than another, and
the hypothesis carries no information at three seeds.  Correspondingly the conclusion is empty
too — at `n = 3` and radius `1` the median is the only rung with a contamination window at all
(`SeedBreakdown.breakdownNumber 3 2 = 1`, while both other rungs have breakdown number `0`).
The mechanism of `width_median_minimal` therefore has no content at the measured cell; it
first bites at five seeds, which is what the announced fourth and fifth seeds would supply. -/
theorem net48_gaps_equidistant_and_unequal :
    gap (quotaBudget knees16) 1 = 64 ∧
      gap (quotaBudget knees16) 2 = 32 ∧
      centreDist 3 1 = centreDist 3 2 ∧
      CentreMinimal (quotaBudget knees16) 3 ∧
      SeedBreakdown.breakdownNumber 3 2 = 1 ∧
      SeedBreakdown.breakdownNumber 3 1 = 0 ∧ SeedBreakdown.breakdownNumber 3 3 = 0 := by
  obtain ⟨hm2, hm1, hm3⟩ := SeedContamination.net48_median_curve
  refine ⟨by simp [gap, hm1, hm2], by simp [gap, hm2, hm3], by simp [centreDist], ?_,
    by simp [SeedBreakdown.breakdownNumber], by simp [SeedBreakdown.breakdownNumber],
    by simp [SeedBreakdown.breakdownNumber]⟩
  have h0 : quotaBudget knees16 0 = 0 := quotaBudget_zero _
  intro j k hj hk hd
  interval_cases j <;> interval_cases k <;>
    simp_all [centreDist, gap]

end SeedWindow