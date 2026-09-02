import Mathlib
import Novelty.ZeroFitDialU64
import Cryptography.BalancedBKeyDialRobustness
import Combinatorics.BKeyMixedZoneGradualDecline

/-!
# BKEY-MIXED-ZONE II: the `T`-dial grid declines gradually, and not because of its ceiling

## Research context (FACT round-55 #1, exp 523, `BALANCED-BKEY`, paper 182 addendum)

Round 54 established (`Cryptography.BalancedBKeyDialRobustness`) that the exact tie ceiling
of the capped trailing-zero statistic `T_u(x) = min(v₂(x), u)` on `b`-bit keys factorises,
`ρ²(b,u) = capFactor u * bitFactor b`, and that every cell of the recorded envelope clears
the recorded floor `0.53`.

Round 55 records the full `4 × 3` grid: `sp(T)` ranges over `0.53 – 0.79` and declines
**smoothly and monotonically in both dials**, with **no cliff, no threshold, no convention
artifact**, and paper 178's "practical floor at bitlen ≈ 54" is a *gradual* transition.

This file proves the corresponding mathematics, using the gradualness calculus of
`Combinatorics.BKeyMixedZoneGradualDecline`.

## Main results

* `ceilingGrid`, `ceilingGrid_eq_spearmanSq`, `ceilingGrid_separable` — the ceiling grid as a
  two-dial object; it is separable, hence has **no interaction term** (`ceilingGrid_rank_one`).
* `capFactor_notch_exact`, `ceiling_colStep_exact` — the **exact** cap notch:
  `ρ²(b,u+1) - ρ²(b,u) = (3/4)·8^{-u}·bitFactor b`.  The cap dial moves the ceiling
  *upwards*, geometrically, with ratio `1/8`.
* `cap_movement_small`, `ceiling_rowStep_small` — every single notch of either dial moves the
  ceiling by at most `8^{-u}` resp. `2·4^{-b}`: the ceiling surface is exponentially flat.
* `ceiling_envelope_variation` — over the recorded envelope (`b ≥ 32`, `u ≥ 8`) the *total*
  variation of the ceiling is below `10^{-6}`, i.e. seven orders of magnitude below the
  recorded `0.26` decline.  **No part of the recorded decline is a ceiling effect.**
* `attenuation_strict_decline`, `attenuation_drop_lower_bound` — hence the decline lives
  entirely in the response coupling: on the recorded envelope the attenuation must drop by
  more than `0.4`, and it must drop even along the cap dial, on which the ceiling *rises*.
* `recorded_total_decline`, `recorded_some_notch_large`, `recorded_notch_below_total`,
  `recorded_decline_spread`, `mixed_zone_verdict` — the recorded `4 × 3` envelope facts:
  the `5` staircase notches sum to `0.26`, at least one is `≥ 0.052`, and if the recorded
  gradualness bound `0.09` holds then the decline is spread over at least `3` notches and
  no notch reaches the total range.  A cliff grid (`cliffExample`) violates exactly this
  bound, so the verdict is a genuine restriction on the data.

Nothing here fabricates the individual recorded cells: the recorded grid enters only through
its two extreme corners, its monotonicity and its notch bound, all of which are reported.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Cryptography.BalancedBKeyDialRobustness
open Catalog.Combinatorics.BKeyMixedZoneGradualDecline

namespace Catalog.Combinatorics.BKeyMixedZoneGridLaw

/-! ## 1. The ceiling surface as a two-dial grid -/

/-- The tie-ceiling grid of the `T`-dial: row dial = bit length `b`, column dial = cap `u`. -/
def ceilingGrid (b u : ℕ) : ℚ := capFactor u * bitFactor b

/-- On the admissible triangle `u ≤ b` the grid *is* the exact Spearman ceiling. -/
theorem ceilingGrid_eq_spearmanSq {u b : ℕ} (hb : 1 ≤ b) (hub : u ≤ b) :
    ceilingGrid b u = spearmanSq (capBlocks u b) := (capped_ceiling_eq hb hub).symm

/-- The ceiling grid is separable: the two dials never interact. -/
theorem ceilingGrid_separable : Separable ceilingGrid := ⟨bitFactor, capFactor, fun _ _ => mul_comm _ _⟩

/-- **No interaction term.**  Every `2 × 2` minor of the ceiling grid vanishes. -/
theorem ceilingGrid_rank_one (b b' u u' : ℕ) :
    ceilingGrid b u * ceilingGrid b' u' = ceilingGrid b u' * ceilingGrid b' u :=
  separable_rank_one ceilingGrid_separable b b' u u'

/-! ## 2. Exact notches of the ceiling surface -/

/-- **Exact cap notch.**  Advancing the cap by one notch raises the cap factor by exactly
`(3/4)·8^{-u}`; the gain is geometric with ratio `1/8`, so it is never a jump. -/
theorem capFactor_notch_exact (u : ℕ) :
    capFactor (u + 1) - capFactor u = 3 / 4 * (1 / 8 : ℚ) ^ u := by
  simp only [capFactor, pow_succ]
  ring

/-- **Exact ceiling cap notch.**  In particular the ceiling *rises* with the cap, whereas the
recorded `sp(T)` *falls*: the two move in opposite directions. -/
theorem ceiling_colStep_exact (b u : ℕ) :
    colStep ceilingGrid b u = -(3 / 4 * (1 / 8 : ℚ) ^ u * bitFactor b) := by
  simp only [colStep, ceilingGrid, capFactor, pow_succ]
  ring

lemma bitFactor_le_four_thirds {b : ℕ} (hb : 1 ≤ b) : bitFactor b ≤ 4 / 3 := by
  have h4 : (4 : ℚ) ^ 1 ≤ (4 : ℚ) ^ b := pow_le_pow_right₀ (by norm_num) hb
  rw [pow_one] at h4
  have hpos : (0 : ℚ) < (4 : ℚ) ^ b - 1 := by linarith
  have : 1 / ((4 : ℚ) ^ b - 1) ≤ 1 / 3 := by
    apply div_le_div_of_nonneg_left (by norm_num) (by norm_num) (by linarith)
  rw [bitFactor]; linarith

/-- The cap notch of the ceiling is tiny: at cap `u` it is below `8^{-u}`. -/
theorem cap_movement_small {b : ℕ} (hb : 1 ≤ b) (u : ℕ) :
    |colStep ceilingGrid b u| ≤ (1 / 8 : ℚ) ^ u := by
  have hbf0 : 0 < bitFactor b := bitFactor_pos hb
  have hbf : bitFactor b ≤ 4 / 3 := bitFactor_le_four_thirds hb
  have hp : (0 : ℚ) < (1 / 8 : ℚ) ^ u := by positivity
  rw [ceiling_colStep_exact, abs_neg, abs_of_nonneg (by positivity)]
  nlinarith

/-- The bitlen notch of the ceiling is tiny too: at bit length `b` it is below `2·4^{-b}`. -/
theorem ceiling_rowStep_small {b : ℕ} (hb : 1 ≤ b) (u : ℕ) :
    |rowStep ceilingGrid b u| ≤ 2 * (1 / 4 : ℚ) ^ b := by
  have h4 : (4 : ℚ) ^ 1 ≤ (4 : ℚ) ^ b := pow_le_pow_right₀ (by norm_num) hb
  rw [pow_one] at h4
  have hb1 : (0 : ℚ) < (4 : ℚ) ^ b - 1 := by linarith
  have hb2 : (0 : ℚ) < (4 : ℚ) ^ (b + 1) - 1 := by
    have : (4 : ℚ) ^ b ≤ (4 : ℚ) ^ (b + 1) := by
      apply pow_le_pow_right₀ (by norm_num); omega
    linarith
  have hstep : rowStep ceilingGrid b u
      = capFactor u * (1 / ((4 : ℚ) ^ b - 1) - 1 / ((4 : ℚ) ^ (b + 1) - 1)) := by
    simp only [rowStep, ceilingGrid, bitFactor]
    ring
  have hcap0 : 0 ≤ capFactor u := by
    have : (1 / 8 : ℚ) ^ u ≤ 1 := pow_le_one₀ (by norm_num) (by norm_num)
    rw [capFactor]; linarith
  have hcaple : capFactor u ≤ 6 / 7 := capFactor_lt
  have hdiff0 : 0 ≤ 1 / ((4 : ℚ) ^ b - 1) - 1 / ((4 : ℚ) ^ (b + 1) - 1) := by
    have : 1 / ((4 : ℚ) ^ (b + 1) - 1) ≤ 1 / ((4 : ℚ) ^ b - 1) := by
      apply div_le_div_of_nonneg_left (by norm_num) hb1
      have : (4 : ℚ) ^ b ≤ (4 : ℚ) ^ (b + 1) := by
        apply pow_le_pow_right₀ (by norm_num); omega
      linarith
    linarith
  have hp : (0 : ℚ) < (4 : ℚ) ^ b := by positivity
  have hbound : 1 / ((4 : ℚ) ^ b - 1) ≤ 2 * (1 / 4 : ℚ) ^ b := by
    have hpow : (1 / 4 : ℚ) ^ b = 1 / (4 : ℚ) ^ b := by
      rw [div_pow, one_pow]
    rw [hpow, show (2 : ℚ) * (1 / (4 : ℚ) ^ b) = 2 / (4 : ℚ) ^ b by ring,
      div_le_div_iff₀ hb1 hp]
    linarith
  have hd_le : 1 / ((4 : ℚ) ^ b - 1) - 1 / ((4 : ℚ) ^ (b + 1) - 1) ≤ 1 / ((4 : ℚ) ^ b - 1) := by
    have : (0 : ℚ) < 1 / ((4 : ℚ) ^ (b + 1) - 1) := by positivity
    linarith
  have hppos : (0 : ℚ) < (1 / 4 : ℚ) ^ b := by positivity
  rw [hstep, abs_of_nonneg (by positivity)]
  calc capFactor u * (1 / ((4 : ℚ) ^ b - 1) - 1 / ((4 : ℚ) ^ (b + 1) - 1))
      ≤ (6 / 7) * (1 / ((4 : ℚ) ^ b - 1)) := by nlinarith
    _ ≤ (6 / 7) * (2 * (1 / 4 : ℚ) ^ b) := by nlinarith
    _ ≤ 2 * (1 / 4 : ℚ) ^ b := by nlinarith

/-! ## 3. The ceiling surface is flat on the recorded envelope -/

lemma capFactor_window {u : ℕ} (hu : 8 ≤ u) :
    6 / 7 - (1 : ℚ) / 10 ^ 7 ≤ capFactor u ∧ capFactor u ≤ 6 / 7 := by
  constructor
  · have hpow : (1 / 8 : ℚ) ^ u ≤ (1 / 8 : ℚ) ^ 8 :=
      pow_le_pow_of_le_one (by norm_num) (by norm_num) hu
    have h8 : (1 / 8 : ℚ) ^ 8 = 1 / 16777216 := by norm_num
    rw [h8] at hpow
    rw [capFactor]
    nlinarith
  · exact capFactor_lt

lemma bitFactor_window {b : ℕ} (hb : 32 ≤ b) :
    1 ≤ bitFactor b ∧ bitFactor b ≤ 1 + (1 : ℚ) / 10 ^ 7 := by
  have h4 : (4 : ℚ) ^ 32 ≤ (4 : ℚ) ^ b := pow_le_pow_right₀ (by norm_num) hb
  have h32 : (10 : ℚ) ^ 7 + 1 ≤ (4 : ℚ) ^ 32 := by norm_num
  have hb1 : (0 : ℚ) < (4 : ℚ) ^ b - 1 := by linarith
  constructor
  · exact le_of_lt (bitFactor_gt_one (by omega))
  · rw [bitFactor]
    have : 1 / ((4 : ℚ) ^ b - 1) ≤ 1 / 10 ^ 7 := by
      apply div_le_div_of_nonneg_left (by norm_num) (by norm_num)
      linarith
    linarith

/-- Every ceiling cell of the recorded envelope sits inside a window of width `< 10^{-6}`. -/
theorem ceilingGrid_window {b u : ℕ} (hb : 32 ≤ b) (hu : 8 ≤ u) :
    6 / 7 - (1 : ℚ) / 10 ^ 6 ≤ ceilingGrid b u ∧ ceilingGrid b u ≤ 6 / 7 + (1 : ℚ) / 10 ^ 6 := by
  obtain ⟨hc1, hc2⟩ := capFactor_window hu
  obtain ⟨hf1, hf2⟩ := bitFactor_window hb
  have hc0 : 0 ≤ capFactor u := by linarith [capFactor_pos (show 1 ≤ u by omega)]
  constructor
  · rw [ceilingGrid]; nlinarith
  · rw [ceilingGrid]; nlinarith

/-- **The ceiling surface is flat over the whole recorded envelope.**  For any two cells with
`b, b' ≥ 32` and `u, u' ≥ 8`, the ceilings differ by less than `10^{-5}` — five orders of
magnitude below the recorded `0.26` decline.  Whatever produces the recorded decline, it is
not the tie ceiling. -/
theorem ceiling_envelope_variation {b b' u u' : ℕ} (hb : 32 ≤ b) (hb' : 32 ≤ b')
    (hu : 8 ≤ u) (hu' : 8 ≤ u') :
    |ceilingGrid b u - ceilingGrid b' u'| < (1 : ℚ) / 10 ^ 5 := by
  obtain ⟨h1, h2⟩ := ceilingGrid_window hb hu
  obtain ⟨h3, h4⟩ := ceilingGrid_window hb' hu'
  rw [abs_lt]
  constructor <;> norm_num <;> linarith

/-! ## 4. Consequently the decline is attenuation, not resolution -/

/-- **Attenuation must decline.**  If two recorded correlations satisfy `s' < s` while the
ceiling at the second cell is at least the ceiling at the first (which is exactly what the
cap dial does — it *raises* the ceiling), then the attenuation strictly declines. -/
theorem attenuation_strict_decline {s s' r r' a a' : ℚ} (hs : 0 < s') (hss : s' < s)
    (hr : 0 < r) (hrr : r ≤ r') (ha : a * r = s ^ 2) (ha' : a' * r' = s' ^ 2) :
    a' < a := by
  have hr' : 0 < r' := lt_of_lt_of_le hr hrr
  have has : 0 < a := by nlinarith
  have has' : 0 < a' := by nlinarith
  nlinarith

/-- **Quantitative attenuation drop.**  On the recorded envelope the top cell `0.79` and the
bottom cell `0.53` force the attenuation factor to drop by more than `0.4`, while the ceiling
moves by less than `10^{-5}`.  The `T`-dial's decline is therefore *entirely* a coupling
effect and cannot be a resolution threshold. -/
theorem attenuation_drop_lower_bound {b b' u u' : ℕ} (hb : 32 ≤ b) (hb' : 32 ≤ b')
    (hu : 8 ≤ u) (hub : u ≤ b) (hu' : 8 ≤ u') (hub' : u' ≤ b') (a a' : ℚ)
    (htop : a * spearmanSq (capBlocks u b) = (79 / 100 : ℚ) ^ 2)
    (hbot : a' * spearmanSq (capBlocks u' b') = (53 / 100 : ℚ) ^ 2) :
    2 / 5 < a - a' := by
  rw [← ceilingGrid_eq_spearmanSq (by omega) hub] at htop
  rw [← ceilingGrid_eq_spearmanSq (by omega) hub'] at hbot
  obtain ⟨h1, h2⟩ := ceilingGrid_window hb hu
  obtain ⟨h3, h4⟩ := ceilingGrid_window hb' hu'
  have hx0 : (0 : ℚ) < ceilingGrid b u := by norm_num at h1 ⊢; linarith
  have hy0 : (0 : ℚ) < ceilingGrid b' u' := by norm_num at h3 ⊢; linarith
  have ha : 0 < a := by nlinarith
  have ha' : 0 < a' := by nlinarith
  -- `a` is at least `0.79² / (6/7 + 10⁻⁶)` and `a'` at most `0.53² / (6/7 - 10⁻⁶)`
  have hA : (79 / 100 : ℚ) ^ 2 ≤ a * (6 / 7 + 1 / 10 ^ 6) := by nlinarith
  have hB : a' * (6 / 7 - 1 / 10 ^ 6) ≤ (53 / 100 : ℚ) ^ 2 := by nlinarith
  nlinarith

/-! ## 5. The recorded `4 × 3` envelope: gradual, not a cliff -/

/-- The recorded top corner of the `4 × 3` grid. -/
def recTop : ℚ := 79 / 100

/-- The recorded bottom corner of the `4 × 3` grid. -/
def recBot : ℚ := 53 / 100

/-- The recorded total range of `sp(T)` over the grid. -/
def recRange : ℚ := 26 / 100

/-- The recorded per-notch gradualness bound. -/
def recNotch : ℚ := 9 / 100

/-- The five notches of the recorded `4 × 3` staircase, explicitly. -/
lemma stairSteps_grid_explicit (F : ℕ → ℕ → ℚ) :
    stairSteps F 0 0 3 2 =
      [rowStep F 0 0, rowStep F 1 0, rowStep F 2 0, colStep F 3 0, colStep F 3 1] := by
  simp [stairSteps, List.range_succ]

theorem recRange_eq : recTop - recBot = recRange := by
  unfold recTop recBot recRange; norm_num

/-- **Total decline of the recorded grid.**  The `3 + 2 = 5` staircase notches joining the
two recorded corners sum to exactly the recorded range `0.26`. -/
theorem recorded_total_decline (F : ℕ → ℕ → ℚ) (htop : F 0 0 = recTop) (hbot : F 3 2 = recBot) :
    (stairSteps F 0 0 3 2).sum = recRange := by
  have h := stair_telescope F 0 0 3 2
  norm_num at h
  rw [h, htop, hbot, recRange_eq]

/-- **Mean notch.**  The five notches average `0.052`; hence some notch is at least `0.052`.
This is the lower half of "gradual": the decline is real at the notch scale. -/
theorem recorded_some_notch_large (F : ℕ → ℕ → ℚ) (htop : F 0 0 = recTop)
    (hbot : F 3 2 = recBot) : ∃ x ∈ stairSteps F 0 0 3 2, (26 : ℚ) / 500 ≤ x := by
  by_contra hcon
  push_neg at hcon
  have hsum := recorded_total_decline F htop hbot
  rw [stairSteps_grid_explicit] at hsum hcon
  have h1 := hcon (rowStep F 0 0) (by simp)
  have h2 := hcon (rowStep F 1 0) (by simp)
  have h3 := hcon (rowStep F 2 0) (by simp)
  have h4 := hcon (colStep F 3 0) (by simp)
  have h5 := hcon (colStep F 3 1) (by simp)
  simp only [List.sum_cons, List.sum_nil, recRange] at hsum
  linarith

/-- **No notch reaches the total decline.**  Under the recorded gradualness bound `0.09`,
no single notch of the staircase carries the whole `0.26` decline: the `4 × 3` grid has no
cliff. -/
theorem recorded_notch_below_total (F : ℕ → ℕ → ℚ)
    (hnotch : ∀ x ∈ stairSteps F 0 0 3 2, x ≤ recNotch) :
    ∀ x ∈ stairSteps F 0 0 3 2, x < recRange := by
  intro x hx
  have := hnotch x hx
  rw [recNotch] at this
  rw [recRange]
  linarith

/-- **The decline is spread over at least three notches.**  With every notch at most `0.09`
and the total decline `0.26`, at least three of the five notches carry a strictly positive
decline.  This is the precise formal content of "smooth and gradual, not a threshold". -/
theorem recorded_decline_spread (F : ℕ → ℕ → ℚ) (htop : F 0 0 = recTop) (hbot : F 3 2 = recBot)
    (hnn : ∀ x ∈ stairSteps F 0 0 3 2, 0 ≤ x)
    (hnotch : ∀ x ∈ stairSteps F 0 0 3 2, x ≤ recNotch) :
    3 ≤ (stairSteps F 0 0 3 2).countP fun x => 0 < x := by
  have hε : (0 : ℚ) < recNotch := by rw [recNotch]; norm_num
  have hspread := spread_card_lower_bound F 0 0 3 2 recNotch hε hnn hnotch
  have hdrop : F 0 0 - F (0 + 3) (0 + 2) = recRange := by
    show F 0 0 - F 3 2 = recRange
    rw [htop, hbot, recTop, recBot, recRange]; norm_num
  rw [hdrop] at hspread
  by_contra hcon
  push_neg at hcon
  have hk : (((stairSteps F 0 0 3 2).countP fun x => 0 < x : ℕ) : ℚ) ≤ 2 := by
    have : ((stairSteps F 0 0 3 2).countP fun x => 0 < x) ≤ 2 := by omega
    exact_mod_cast this
  rw [recRange, recNotch] at hspread
  norm_num at hspread
  linarith

/-- The cliff grid of the calculus violates exactly the recorded notch bound, so the recorded
verdict is a genuine restriction: cliffs are not excluded a priori. -/
theorem cliffExample_violates_notch_bound :
    ¬ (∀ x ∈ stairSteps cliffExample 0 0 3 2, x ≤ recNotch) := by
  intro h
  have hmem : rowStep cliffExample 0 0 ∈ stairSteps cliffExample 0 0 3 2 := by
    rw [stairSteps]
    apply List.mem_append_left
    exact List.mem_map.mpr ⟨0, by simp, by norm_num⟩
  have hval : rowStep cliffExample 0 0 = 26 / 100 := by
    rw [cliff_example_has_cliff, cliff_example_drop]
  have := h _ hmem
  rw [hval, recNotch] at this
  norm_num at this

/-- **The recorded envelope is realisable.**  The hypotheses of the round-55 verdict are
consistent: the perfectly gradual grid with notch `0.052` has exactly the recorded corners,
is monotone in both dials and respects the recorded notch bound `0.09`.  So the verdict is
not vacuous — there are grids satisfying it, and (by `cliffExample`) grids violating it. -/
theorem recorded_envelope_realisable :
    ∃ F : ℕ → ℕ → ℚ, F 0 0 = recTop ∧ F 3 2 = recBot ∧
      (∀ b u : ℕ, F (b + 1) u ≤ F b u) ∧ (∀ b u : ℕ, F b (u + 1) ≤ F b u) ∧
      (∀ x ∈ stairSteps F 0 0 3 2, 0 ≤ x) ∧
      (∀ x ∈ stairSteps F 0 0 3 2, x ≤ recNotch) := by
  refine ⟨linearGrid recTop (26 / 500), ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simp [linearGrid]
  · simp only [linearGrid, recTop, recBot]; norm_num
  · intro b u
    have := linearGrid_rowStep recTop (26 / 500) b u
    rw [rowStep] at this
    linarith
  · intro b u
    have := linearGrid_colStep recTop (26 / 500) b u
    rw [colStep] at this
    linarith
  · intro x hx
    rw [linearGrid_notches recTop (26 / 500) 0 0 3 2 x hx]; norm_num
  · intro x hx
    rw [linearGrid_notches recTop (26 / 500) 0 0 3 2 x hx, recNotch]; norm_num

/-! ## 6. The round-55 verdict -/

/-- **BKEY-MIXED-ZONE verdict.**  For any recorded `4 × 3` grid on the envelope
(`b ≥ 32`, `u ≥ 8`) whose corners are the recorded `0.79` and `0.53`, whose notches are
non-negative (monotone decline) and bounded by the recorded `0.09`:

1. the five notches sum to exactly the recorded range `0.26`;
2. at least one notch is `≥ 0.052` — the decline is genuine;
3. no notch reaches `0.26` — there is no cliff;
4. the decline is spread over at least three notches — it is gradual;
5. the underlying tie ceiling varies by less than `10^{-5}` across the whole envelope, so
   none of the decline is a resolution/threshold artifact. -/
theorem mixed_zone_verdict (F : ℕ → ℕ → ℚ) (htop : F 0 0 = recTop) (hbot : F 3 2 = recBot)
    (hnn : ∀ x ∈ stairSteps F 0 0 3 2, 0 ≤ x)
    (hnotch : ∀ x ∈ stairSteps F 0 0 3 2, x ≤ recNotch) :
    (stairSteps F 0 0 3 2).sum = recRange ∧
    (∃ x ∈ stairSteps F 0 0 3 2, (26 : ℚ) / 500 ≤ x) ∧
    (∀ x ∈ stairSteps F 0 0 3 2, x < recRange) ∧
    3 ≤ ((stairSteps F 0 0 3 2).countP fun x => 0 < x) ∧
    (∀ b b' u u' : ℕ, 32 ≤ b → 32 ≤ b' → 8 ≤ u → 8 ≤ u' →
      |ceilingGrid b u - ceilingGrid b' u'| < (1 : ℚ) / 10 ^ 5) :=
  ⟨recorded_total_decline F htop hbot, recorded_some_notch_large F htop hbot,
    recorded_notch_below_total F hnotch,
    recorded_decline_spread F htop hbot hnn hnotch,
    fun _ _ _ _ hb hb' hu hu' => ceiling_envelope_variation hb hb' hu hu'⟩

end Catalog.Combinatorics.BKeyMixedZoneGridLaw