import Mathlib
import Probability.F1TightnessCore
import Probability.F1TightnessQuantitative
import Probability.F1TightnessSharpness

/-!
# The optimal normalisation of the dispersion correction

`Probability.F1TightnessQuantitative` proved the refined master inequality
`S · (1 + ‖p − flat‖₁/(2M)) ≤ bound`, with the dispersion functional normalised
by `2M`.  Direction 2 of `FUTURE_DIRECTIONS.md` asks whether that normalisation
is optimal, and in particular whether the `2M` can be replaced by the strictly
smaller `2·c_asc` that the proof actually supplies.  This file answers both
questions.

* `one_add_flatDist_div_scanCost_le_gapX` — the **sharper** form
  `1 + ‖p − flat‖₁/(2·c_asc) ≤ X`;
* `flatDist_div_card_le_div_scanCost` — the sharper form dominates the booked
  one, because `c_asc ≤ M`;
* `speedup_mul_le_bound_dispersion` — the corresponding refinement of the master
  inequality;
* `twoCell_dispersion_exact` — on the two-cell family the sharper inequality is
  an **identity**: `X = 1 + ‖p − flat‖₁/(2·c_asc)`;
* `dispersion_constant_optimal` — consequently no constant `c > 1` is admissible
  in `1 + c·‖p − flat‖₁/(2·c_asc) ≤ X`, so the constant `1` is optimal and the
  extremal profiles are supported on two cells, exactly as conjectured.
-/

namespace F1Tightness

open Finset

variable {M : ℕ}

/-- **The sharper dispersion bound.**  The slack exceeds one by the L¹ distance
to flatness normalised by twice the *ascending cost* (not by `2M`). -/
theorem one_add_flatDist_div_scanCost_le_gapX {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) (hanti : Antitone p) :
    1 + flatDist p / (2 * scanCost p) ≤ gapX p := by
  have hc := scanCost_pos hp hsum
  have hb := scanCost_le_baseCost_sub_flatDist hsum hanti
  have hmul : (1 + flatDist p / (2 * scanCost p)) * scanCost p
      = scanCost p + flatDist p / 2 := by
    field_simp
  unfold gapX
  rw [le_div_iff₀ hc, hmul]
  linarith

/-- The sharper normalisation dominates the booked one. -/
theorem flatDist_div_card_le_div_scanCost {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) :
    flatDist p / (2 * (M : ℝ)) ≤ flatDist p / (2 * scanCost p) := by
  have hc := scanCost_pos hp hsum
  have hcM := scanCost_le_card hp hsum
  have hL := flatDist_nonneg p
  have hM : 0 < (M : ℝ) := lt_of_lt_of_le hc hcM
  exact div_le_div_of_nonneg_left hL (by positivity) (by linarith)

/-- **The dispersion-refined master inequality.**  Every realizable policy on an
antitone profile satisfies `S · (1 + ‖p − flat‖₁/(2·c_asc)) ≤ bound`. -/
theorem speedup_mul_le_bound_dispersion {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) (hanti : Antitone p) (σ : Equiv.Perm (Fin M)) :
    speedup p σ * (1 + flatDist p / (2 * scanCost p)) ≤ boundF1 (Lam p) (Theta p) 1 := by
  have hc := scanCost_pos hp hsum
  have hL := flatDist_nonneg p
  have hV : 0 ≤ 1 + flatDist p / (2 * scanCost p) := by positivity
  have hS : speedup p σ ≤ Sasc p := policy_speedup_le_Sasc hp hsum hanti σ
  have hSpos : 0 < Sasc p := div_pos (revCost_pos hp hsum) hc
  have hX := one_add_flatDist_div_scanCost_le_gapX hp hsum hanti
  calc speedup p σ * (1 + flatDist p / (2 * scanCost p))
      ≤ Sasc p * (1 + flatDist p / (2 * scanCost p)) := mul_le_mul_of_nonneg_right hS hV
    _ ≤ Sasc p * gapX p := mul_le_mul_of_nonneg_left hX hSpos.le
    _ = boundF1 (Lam p) (Theta p) 1 := by rw [slack_identity hp hsum]; ring

/-! ## The two-cell family makes the sharper inequality an identity -/

theorem twoCell_flatDist {δ : ℝ} (h0 : 0 ≤ δ) : flatDist (twoCell δ) = 2 * δ := by
  have h : flatDist (twoCell δ) = |1 / 2 + δ - 2⁻¹| + |1 / 2 - δ - 2⁻¹| := by
    rw [flatDist, Fin.sum_univ_two]
    norm_num [twoCell]
  rw [h]
  rw [show (1 : ℝ) / 2 + δ - 2⁻¹ = δ by ring, show (1 : ℝ) / 2 - δ - 2⁻¹ = -δ by ring,
    abs_of_nonneg h0, abs_neg, abs_of_nonneg h0]
  ring

/-- **Exactness on two cells.**  For the two-cell family the sharper dispersion
inequality holds with equality. -/
theorem twoCell_dispersion_exact {δ : ℝ} (h0 : 0 ≤ δ) (h1 : δ < 1 / 2) :
    gapX (twoCell δ) = 1 + flatDist (twoCell δ) / (2 * scanCost (twoCell δ)) := by
  have hc : scanCost (twoCell δ) = 3 / 2 - δ := twoCell_scanCost δ
  have hcpos : (0 : ℝ) < 3 / 2 - δ := by linarith
  have hne : (3 / 2 : ℝ) - δ ≠ 0 := ne_of_gt hcpos
  have h2 : (2 : ℝ) * δ / (2 * (3 / 2 - δ)) = δ / (3 / 2 - δ) :=
    mul_div_mul_left δ (3 / 2 - δ) two_ne_zero
  have hne2 : (3 : ℝ) - δ * 2 ≠ 0 := fun h => hne (by linarith)
  have h3 : (1 : ℝ) + δ / (3 / 2 - δ) = (3 / 2) / (3 / 2 - δ) := by
    field_simp
    ring
  rw [twoCell_gapX, twoCell_flatDist h0, hc, h2, h3]

/-- **Optimality of the constant.**  No constant `c > 1` can be inserted in the
dispersion correction: the two-cell profiles already achieve equality, so the
inequality `1 + c·‖p − flat‖₁/(2·c_asc) ≤ X` fails for them. -/
theorem dispersion_constant_optimal {c : ℝ} (hc : 1 < c) :
    ∃ p : Fin 2 → ℝ, (∀ i, 0 ≤ p i) ∧ (∑ i : Fin 2, p i = 1) ∧ Antitone p ∧
      gapX p < 1 + c * (flatDist p / (2 * scanCost p)) := by
  refine ⟨twoCell (1 / 4), twoCell_nonneg (by norm_num) (by norm_num), twoCell_sum _,
    twoCell_antitone (by norm_num), ?_⟩
  have heq := twoCell_dispersion_exact (δ := 1 / 4) (by norm_num) (by norm_num)
  have hD : flatDist (twoCell (1 / 4 : ℝ)) = 1 / 2 := by
    rw [twoCell_flatDist (by norm_num)]; norm_num
  have hs : scanCost (twoCell (1 / 4 : ℝ)) = 5 / 4 := by
    rw [twoCell_scanCost]; norm_num
  rw [hD, hs] at heq ⊢
  rw [heq]
  have : (0 : ℝ) < 1 / 2 / (2 * (5 / 4)) := by norm_num
  nlinarith

end F1Tightness