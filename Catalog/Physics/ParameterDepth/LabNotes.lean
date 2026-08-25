import Physics.ParameterDepth.Asymptotics
import Physics.ParameterDepth.Deficit

/-!
# Parameter-derived depth — Lab Notes

Experimental data collected while developing `Physics.ParameterDepth.*`, together with the
Lean certificates for every number quoted.  Each entry below is *not* a table lookup: the
depth is pinned by the frontier (the stated depth fits the budget, the next one does not),
so every line is a maximality statement.

## Run 1 — depth versus threshold at fixed branching `B = 2`

| T      | foamCells 2 d | foamCells 2 (d+1) | maximal depth | Nat.log 2 T | deficit |
|--------|---------------|-------------------|---------------|-------------|---------|
| 10     | 7             | 15                | 2             | 3           | 1       |
| 100    | 63            | 127               | 5             | 6           | 1       |
| 1000   | 511           | 1023              | 8             | 9           | 1       |
| 10000  | 8191          | 16383             | 12            | 13          | 1       |

Observation: for `B = 2` the deficit was `1` at every sampled threshold.  That is not an
accident of the sample — `Deficit.lossy_density_tendsto` shows the density of deficit-one
budgets tends to `1/(B-1)^2 = 1` when `B = 2`.

## Run 2 — depth versus branching at fixed threshold `T = 1000`

| B  | maximal depth |
|----|---------------|
| 2  | 8             |
| 4  | 4             |
| 10 | 2             |

Observation: depth falls off like `1/log B`, consistent with the analytic window
`log_B T - 2 < d ≤ log_B T` of `Asymptotics.foamDepth_logb_bounds`.

## Run 3 — large-budget spot check

`B = 5`, `T = 10^6`: `foamCells 5 8 = 488281 ≤ 10^6 < 2441406 = foamCells 5 9`, depth `8`.

## Run 4 — deficit block counts (see `ComputationalEvidence.md`)

Counting deficit-one budgets in the block `B^L ≤ T < B^(L+1)` reproduced
`foamCells B (L-1)` for `B ∈ {2,3,4,5}` and `L ≤ 5`; this is
`Deficit.lossy_card`, proved for all `B ≥ 2`, `L ≥ 1`.
-/

namespace Physics.ParameterDepth

/-! ### Run 1 -/

theorem foamDepth_two_ten : foamDepth 2 10 = 2 := by
  refine foamDepth_eq_of_frontier (by norm_num) (by norm_num) ?_ ?_ <;>
    simp [foamCells, Finset.sum_range_succ]

theorem foamDepth_two_hundred : foamDepth 2 100 = 5 := by
  refine foamDepth_eq_of_frontier (by norm_num) (by norm_num) ?_ ?_ <;>
    simp [foamCells, Finset.sum_range_succ]

theorem foamDepth_two_ten_thousand : foamDepth 2 10000 = 12 := by
  refine foamDepth_eq_of_frontier (by norm_num) (by norm_num) ?_ ?_ <;>
    simp [foamCells, Finset.sum_range_succ]

/-- Every sampled binary budget of Run 1 pays the one-level overhead. -/
theorem deficit_two_run_one :
    deficit 2 10 = 1 ∧ deficit 2 100 = 1 ∧ deficit 2 1000 = 1 ∧ deficit 2 10000 = 1 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp only [deficit, foamDepth_two_ten, foamDepth_two_hundred, foamDepth_two_thousand,
      foamDepth_two_ten_thousand] <;>
    norm_num

/-! ### Run 2 -/

theorem foamDepth_four_thousand : foamDepth 4 1000 = 4 := by
  refine foamDepth_eq_of_frontier (by norm_num) (by norm_num) ?_ ?_ <;>
    simp [foamCells, Finset.sum_range_succ]

theorem foamDepth_ten_thousand_budget : foamDepth 10 1000 = 2 := by
  refine foamDepth_eq_of_frontier (by norm_num) (by norm_num) ?_ ?_ <;>
    simp [foamCells, Finset.sum_range_succ]

/-- Run 2 is an instance of the general antitonicity in the branching number. -/
theorem run_two_antitone : foamDepth 10 1000 ≤ foamDepth 4 1000 ∧ foamDepth 4 1000 ≤ foamDepth 2 1000 :=
  ⟨foamDepth_antitone_base (by norm_num) (by norm_num) (by norm_num),
   foamDepth_antitone_base (by norm_num) (by norm_num) (by norm_num)⟩

/-! ### Run 3 -/

theorem foamDepth_five_million : foamDepth 5 1000000 = 8 := by
  refine foamDepth_eq_of_frontier (by norm_num) (by norm_num) ?_ ?_ <;>
    simp [foamCells, Finset.sum_range_succ]

/-- Run 3 lands inside the analytic window of `Asymptotics`, checked through the general
theorem rather than by evaluating a logarithm. -/
theorem run_three_in_window :
    Real.logb 5 1000000 - 2 < (8 : ℝ) ∧ (8 : ℝ) ≤ Real.logb 5 1000000 := by
  have h := foamDepth_logb_bounds (B := 5) (T := 1000000) (by norm_num) (by norm_num)
  rwa [foamDepth_five_million] at h

end Physics.ParameterDepth