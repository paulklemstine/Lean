import Mathlib

/-!
# Irrational Densities of Aperiodic (Beatty / Sturmian) Tilings

A one-dimensional quasicrystal (Sturmian / cut-and-project tiling) with slope `α`
is encoded by the step sequence `d(n) = ⌊(n+1)α⌋ - ⌊nα⌋ ∈ {⌊α⌋, ⌊α⌋+1}`, the two
tile types of the tiling.  The number of long-tile increments accumulated over the
first `N` cells telescopes to `⌊Nα⌋`, and hence the *tile density* converges to `α`.
When `α` is irrational the tiling is aperiodic and its density is irrational; the
golden slope `(√5 - 1)/2` gives the Fibonacci quasicrystal (Penrose 1-D analogue).

## Main results

* `tileCount_eq_floor` : the cumulative tile count telescopes to `⌊Nα⌋`.
* `tileDensity_tendsto` : the tile density `⌊Nα⌋/N → α`.
* `goldenSlope_irrational` : `(√5-1)/2` is irrational.
* `golden_tiling_irrational_density` : the Fibonacci quasicrystal has irrational
  density equal to the golden slope.

-- !-- Lab Notes -- !--
Hypothesis H2 (physics/tilings): the natural density of the long tile in a Beatty
tiling of slope `α` equals `α`, and is irrational exactly when `α` is.
Experiment: the step process `d(n)=⌊(n+1)α⌋-⌊nα⌋` is a telescoping difference, so
`∑_{n<N} d(n) = ⌊Nα⌋ - ⌊0⌋ = ⌊Nα⌋`.  Dividing by `N` and using
`0 ≤ Nα - ⌊Nα⌋ < 1` squeezes the density to `α`.
Outcome: confirmed.  The telescoping identity (`tileCount_eq_floor`) is the key; the
limit is then a clean floor-squeeze.
Insight: this links the *geometric* invariant (irrational density of an aperiodic
tiling) to a *number-theoretic* irrationality (`Irrational α`), realising the
"irrational densities" half of the research theme.  The bridge to the parabola
file: the golden slope is the unique positive root of `x²+x-1=0`, i.e. a parabola
intercept — see FUTURE_DIRECTIONS.
-/

namespace IrrationalDensity

open Filter Topology

/-- The tile-step process of a Beatty tiling of slope `α`: the increment of the
Beatty staircase at cell `n`. It takes one of two integer values, the two tiles. -/
noncomputable def tileStep (α : ℝ) (n : ℕ) : ℤ := ⌊((n : ℝ) + 1) * α⌋ - ⌊(n : ℝ) * α⌋

/-- Cumulative tile count over the first `N` cells. -/
noncomputable def tileCount (α : ℝ) (N : ℕ) : ℤ := ∑ n ∈ Finset.range N, tileStep α n

/-
The cumulative tile count telescopes to `⌊Nα⌋`.
-/
theorem tileCount_eq_floor (α : ℝ) (N : ℕ) :
    tileCount α N = ⌊(N : ℝ) * α⌋ := by
  convert Finset.sum_range_sub ( fun n => ⌊ ( n : ℝ ) * α⌋ ) N using 1 ; norm_num [ tileCount, tileStep ];
  norm_num

/-
The tile density of the Beatty tiling converges to the slope `α`.
-/
theorem tileDensity_tendsto (α : ℝ) :
    Tendsto (fun N : ℕ => (tileCount α N : ℝ) / (N : ℝ)) atTop (𝓝 α) := by
  -- We can use the fact that |⌊Nα⌋ - Nα| < 1 to bound the error term.
  have h_bound : ∀ N : ℕ, N > 0 → |(⌊(N : ℝ) * α⌋ : ℝ) / N - α| ≤ 1 / (N : ℝ) := by
    intro N hN; rw [ abs_le ] ; constructor <;> nlinarith [ Int.floor_le ( ( N : ℝ ) * α ), Int.lt_floor_add_one ( ( N : ℝ ) * α ), show ( N : ℝ ) ≥ 1 by exact Nat.one_le_cast.mpr hN, div_mul_cancel₀ ( ⌊ ( N : ℝ ) * α⌋ : ℝ ) ( by positivity : ( N : ℝ ) ≠ 0 ), div_mul_cancel₀ ( 1 : ℝ ) ( by positivity : ( N : ℝ ) ≠ 0 ) ] ;
  exact tendsto_iff_norm_sub_tendsto_zero.mpr <| squeeze_zero_norm' ( Filter.eventually_atTop.mpr ⟨ 1, fun N hN => by simpa [ tileCount_eq_floor ] using h_bound N <| pos_of_gt hN ⟩ ) <| tendsto_one_div_atTop_nhds_zero_nat

/-- The golden slope `(√5 - 1)/2`, the slope of the Fibonacci quasicrystal. -/
noncomputable def goldenSlope : ℝ := (Real.sqrt 5 - 1) / 2

/-
The golden slope is irrational.
-/
theorem goldenSlope_irrational : Irrational goldenSlope := by
  exact_mod_cast Nat.Prime.irrational_sqrt ( by norm_num ) |> Irrational.sub_ratCast 1 |> Irrational.div_ratCast <| by norm_num;

/-
The golden slope is the positive root of `x² + x - 1 = 0`.
-/
theorem goldenSlope_root : goldenSlope ^ 2 + goldenSlope - 1 = 0 := by
  unfold goldenSlope; ring_nf; norm_num;

/-- **Synthesis.** The Fibonacci quasicrystal tiling has an irrational density,
equal to the golden slope: the tile density converges to `goldenSlope`, which is
irrational. -/
theorem golden_tiling_irrational_density :
    Tendsto (fun N : ℕ => (tileCount goldenSlope N : ℝ) / (N : ℝ)) atTop (𝓝 goldenSlope)
      ∧ Irrational goldenSlope :=
  ⟨tileDensity_tendsto goldenSlope, goldenSlope_irrational⟩

end IrrationalDensity