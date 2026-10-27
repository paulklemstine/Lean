import Catalog.Combinatorics.MultiWindowCrossingLaw

/-!
# Multi-window crossing law, part III: continuum limit, boundary witnesses, worked instance

* `priced_speedup_tendsto` — the exact finite-`M` priced speedup `minBlind M / (M Φ + c)`
  converges to the continuum speedup `1/(3Φ)`; together with `committed_cost_normalized` this
  shows the finite gate of `multi_window_crossing_law_exact` converges to `multi_crossing_law`.
* `calibration_needed` — the calibration hypothesis of `multi_window_bayes_optimal` cannot be
  dropped: for an anti-calibrated hint (`M = 6`, window `[0,3)` with reliability `1/10`) the
  reversed order strictly beats committed search.
* `worked_example` — `M = 6`, windows of widths `1, 3` with cumulative reliabilities `1/2, 5/6`:
  the committed cost is `13/6` and no order among the `720` beats it.
-/

namespace MultiWindowCrossingLaw

open Finset Filter Topology

/-- **Continuum limit of the exact gate.**  For `Φ > 0` and any offset `c`,
`minBlind M / (M Φ + c) → 1/(3Φ)`. -/
theorem priced_speedup_tendsto (Φ c : ℝ) (hΦ : 0 < Φ) :
    Tendsto (fun M : ℕ => minBlind M / (M * Φ + c)) atTop (𝓝 (1 / (3 * Φ))) := by
  have hinv : Tendsto (fun M : ℕ => (1 : ℝ) / M) atTop (𝓝 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have hnum : Tendsto (fun M : ℕ => (1 + (1 : ℝ) / M) * (2 + 1 / M) / 6) atTop
      (𝓝 ((1 + 0) * (2 + 0) / 6)) :=
    ((tendsto_const_nhds.add hinv).mul (tendsto_const_nhds.add hinv)).div_const 6
  have hden : Tendsto (fun M : ℕ => Φ + c * (1 / (M : ℝ))) atTop (𝓝 (Φ + c * 0)) :=
    tendsto_const_nhds.add (hinv.const_mul c)
  have hq := hnum.div hden (by simp; exact hΦ.ne')
  have he : (1 : ℝ) / (3 * Φ) = (1 + 0) * (2 + 0) / 6 / (Φ + c * 0) := by
    rw [mul_zero, add_zero, add_zero, add_zero, div_div]; ring
  rw [he]
  refine hq.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with M hM
  have hM' : (M : ℝ) ≠ 0 := by exact_mod_cast hM.ne'
  simp only [Pi.div_apply]
  unfold minBlind
  have hrw : Φ + c * (1 / (M : ℝ)) = (M * Φ + c) / M := by field_simp
  rw [hrw]
  rcases eq_or_ne ((M : ℝ) * Φ + c) 0 with hD | hD
  · rw [hD]; simp
  · field_simp

/-- **Calibration is load-bearing.**  Two blocks `[0,3)`, `[3,6)` with masses `1/10`, `9/10`
(increasing densities): the reversed order is strictly cheaper than committed search
(`23/10 < 47/10`). -/
theorem calibration_needed :
    probeCost (stepPosterior (M := 6) 2 (fun i => 3 * i)
        (fun i => if i = 0 then 0 else if i = 1 then 1 / 10 else 1)) Fin.revPerm <
      probeCost (stepPosterior (M := 6) 2 (fun i => 3 * i)
        (fun i => if i = 0 then 0 else if i = 1 then 1 / 10 else 1)) (Equiv.refl _) := by
  simp [probeCost, stepPosterior, stepWeight, blockDensity, Fin.sum_univ_six, sum_range_succ]
  norm_num

/-- Boundaries `0, 1, 3, 6` (extended strictly beyond). -/
def exB : ℕ → ℕ := fun i =>
  if i = 0 then 0 else if i = 1 then 1 else if i = 2 then 3 else 3 * i - 3

/-- Cumulative reliabilities `0, 1/2, 5/6, 1`. -/
noncomputable def exA : ℕ → ℝ := fun i =>
  if i = 0 then 0 else if i = 1 then 1 / 2 else if i = 2 then 5 / 6 else 1

/-- **Worked instance.**  Committed cost `13/6`, optimal among all `6! = 720` orders. -/
theorem worked_example (σ : Equiv.Perm (Fin 6)) :
    probeCost (stepPosterior (M := 6) 3 exB exA) (Equiv.refl _) = 13 / 6 ∧
      13 / 6 ≤ probeCost (stepPosterior (M := 6) 3 exB exA) σ := by
  have hB : StrictMono exB := strictMono_nat_of_lt_succ fun i => by
    rcases i with _ | _ | _ | n <;> simp [exB]
    omega
  have hc : probeCost (stepPosterior (M := 6) 3 exB exA) (Equiv.refl _) = 13 / 6 := by
    rw [committed_cost_blocks 6 3 exB exA hB (by simp [exB])]
    simp [sum_range_succ, exA, exB]; norm_num
  refine ⟨hc, ?_⟩
  have hd : AntitoneOn (blockDensity exB exA) (Set.Iio 3) := by
    intro a ha b hb hab
    simp only [Set.mem_Iio] at ha hb
    interval_cases a <;> interval_cases b <;> norm_num [blockDensity, exA, exB]
  have := multi_window_bayes_optimal 3 exB exA hB (by simp [exB]) hd σ
  simpa [exB, hc] using this

end MultiWindowCrossingLaw