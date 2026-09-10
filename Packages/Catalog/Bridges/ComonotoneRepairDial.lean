/-
# The repair distance caps the dial

Closing instalment of the repair-distance thread.  The previous files compared the
comonotone repair distance `δ` with the discordance mass `Δ` (two-sided bounds, sharpness,
scaling, stability, attainment).  Here the comparison is pushed all the way back to the
observable that motivated the whole thread: the *dial reading* `wcov` of
`Combinatorics.UniformDialDrawInvariance`.

* `uniform_wcov_identity` — for the uniform draw regime,
  `2 |ι|² · wcov = concordanceMass − discordanceMass`.  This is the Hoeffding pair
  identity in its unnormalised, regime-free form.
* `uniform_wcov_le_of_repairDist` — hence `2 |ι|² · wcov ≤ C − g · δ`: the amount of ℓ¹
  repair a population needs is subtracted, one for one (up to the footprint separation
  `g`), from the largest dial reading it can possibly produce.
* `repairDist_le_of_dial` — the contrapositive reading: a large dial certifies a small
  repair distance, `g · δ ≤ C − 2 |ι|² · wcov`.

The two statements together say that the repair distance is not a side quantity: it is a
budget line in the dial itself.
-/
import Bridges.ComonotoneRepairDistance

open Finset

namespace Catalog.UniformDial

variable {ι : Type*} [Fintype ι]

/-- The uniform draw regime. -/
noncomputable def uniformWeights (ι : Type*) [Fintype ι] : ι → ℝ :=
  fun _ => 1 / (Fintype.card ι : ℝ)

lemma uniformWeights_total [Nonempty ι] : ∑ _i : ι, uniformWeights ι _i = 1 := by
  have hn : (Fintype.card ι : ℝ) ≠ 0 := by
    have : 0 < Fintype.card ι := Fintype.card_pos
    positivity
  simp only [uniformWeights, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

/-- **Unnormalised Hoeffding identity.**  Under the uniform draw regime the dial reading is
exactly the concordance/discordance balance of the population, divided by `2 |ι|²`. -/
theorem uniform_wcov_identity [Nonempty ι] (x y : ι → ℝ) :
    2 * (Fintype.card ι : ℝ) ^ 2 * wcov (uniformWeights ι) x y
      = concordanceMass x y - discordanceMass x y := by
  have hn : (Fintype.card ι : ℝ) ≠ 0 := by
    have : 0 < Fintype.card ι := Fintype.card_pos
    positivity
  have hpair := wcov_eq_half_double_sum (p := uniformWeights ι) (x := x) (y := y)
    uniformWeights_total
  have hrw : ∑ i, ∑ j, uniformWeights ι i * uniformWeights ι j * ((x i - x j) * (y i - y j))
      = (1 / (Fintype.card ι : ℝ) ^ 2) * ∑ i, ∑ j, ((x i - x j) * (y i - y j)) := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun j _ => ?_
    simp only [uniformWeights]
    ring
  rw [hrw, ← uniform_budget_eq] at hpair
  field_simp at hpair ⊢
  nlinarith [hpair]

/-- **The repair distance caps the dial.**  For a `g`-separated footprint, the uniform dial
reading is bounded by the concordance mass *minus* the repair budget `g · δ`. -/
theorem uniform_wcov_le_of_repairDist [Nonempty ι] {x y : ι → ℝ} {g : ℝ} (hg : 0 < g)
    (hgap : ∀ i j, x i < x j → g ≤ x j - x i) :
    2 * (Fintype.card ι : ℝ) ^ 2 * wcov (uniformWeights ι) x y
      ≤ concordanceMass x y - g * repairDist x y := by
  have hid := uniform_wcov_identity (x := x) (y := y)
  have hΔ := repairDist_le_discordanceMass (x := x) (y := y) hg hgap
  linarith

/-- **A strong dial certifies cheap repair.**  Contrapositive form of the previous bound:
the repair budget is at most the slack between the concordance mass and the dial. -/
theorem repairDist_le_of_dial [Nonempty ι] {x y : ι → ℝ} {g : ℝ} (hg : 0 < g)
    (hgap : ∀ i j, x i < x j → g ≤ x j - x i) :
    g * repairDist x y
      ≤ concordanceMass x y - 2 * (Fintype.card ι : ℝ) ^ 2 * wcov (uniformWeights ι) x y := by
  have := uniform_wcov_le_of_repairDist hg hgap (x := x) (y := y)
  linarith

end Catalog.UniformDial