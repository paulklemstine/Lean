/-
# Coils grow at exactly the snake rate

`Novelty/HypercubeCoil.lean` defines `maxCoil n`, the maximal length of an
*induced cycle* (a coil) of `Q n`, and proves `maxCoil n ≤ maxLen n + 2`
(deleting a vertex of a coil leaves a snake).  `Novelty/CoilRectangle.lean`
proves the converse-direction construction
`maxCoil_ge_two_mul : 2 ≤ maxLen m → 2 ≤ maxLen n → 2 * (maxLen m + maxLen n) ≤ maxCoil (m + n)`.

Together these sandwich the coil numbers between the snake numbers of dimension
`n - 3` and of dimension `n`, up to bounded factors.  Since
`Novelty/SnakeGrowthConstant.lean` shows `(maxLen n) ^ (1/n)` converges to
`snakeGrowth`, and a shift of the dimension by a constant does not change an
exponential rate, the same is true for coils:

> `maxCoil_rpow_tendsto` : `(maxCoil n) ^ (1/n) → snakeGrowth`.

This is Conjecture 3 of the previous cycle ("coils are asymptotically as long as
snakes") in the strong form: the two families have *the same* growth constant,
so no coil-specific loss occurs in the exponential rate.
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.HypercubeCoil
import Novelty.CoilRectangle
import Novelty.SnakeSupport
import Novelty.SnakeGrowthConstant

namespace SnakeInTheBox

open Filter Topology Set

/-- The logarithmic growth rate: `Real.log snakeGrowth`. -/
noncomputable def logSnakeGrowth : ℝ := -(Subadditive.lim snakeU_subadditive)

theorem log_snakeGrowth : Real.log snakeGrowth = logSnakeGrowth := by
  simp [snakeGrowth, logSnakeGrowth]

/-! ## Step 1: the logarithmic form of the snake limit -/

theorem log_maxLen_tendsto :
    Tendsto (fun n : ℕ => Real.log (maxLen n) / n) atTop (𝓝 logSnakeGrowth) := by
  have hfac : Tendsto (fun n : ℕ => Real.log 2 / n) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop
  have hmain : Tendsto (fun n : ℕ => -(snakeU n / n)) atTop (𝓝 logSnakeGrowth) := by
    simpa [logSnakeGrowth] using snakeU_tendsto.neg
  have hsum := hfac.add hmain
  rw [zero_add] at hsum
  refine hsum.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hpos : 0 < halfLen n := halfLen_pos hn
  have hsplit : Real.log (maxLen n : ℝ) = Real.log 2 + Real.log (halfLen n) := by
    have h : (maxLen n : ℝ) = 2 * halfLen n := by
      simp only [halfLen]; ring
    rw [h, Real.log_mul (by norm_num) (ne_of_gt hpos)]
  simp only [snakeU, hsplit]
  ring

/-! ## Step 2: shifting the dimension by a constant does not change the rate -/

theorem tendsto_sub_atTop (k : ℕ) : Tendsto (fun n : ℕ => n - k) atTop atTop := by
  refine tendsto_atTop_atTop.2 fun b => ⟨b + k, fun a ha => by omega⟩

theorem log_maxLen_shift_tendsto :
    Tendsto (fun n : ℕ => Real.log (maxLen (n - 3)) / n) atTop (𝓝 logSnakeGrowth) := by
  have hcomp : Tendsto (fun n : ℕ => Real.log (maxLen (n - 3)) / ((n - 3 : ℕ) : ℝ)) atTop
      (𝓝 logSnakeGrowth) := log_maxLen_tendsto.comp (tendsto_sub_atTop 3)
  have hratio : Tendsto (fun n : ℕ => ((n - 3 : ℕ) : ℝ) / (n : ℝ)) atTop (𝓝 1) := by
    have h3 : Tendsto (fun n : ℕ => (3 : ℝ) / n) atTop (𝓝 0) :=
      tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop
    have hone : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 1) := tendsto_const_nhds
    have hsub := hone.sub h3
    rw [sub_zero] at hsub
    refine hsub.congr' ?_
    filter_upwards [eventually_ge_atTop 3] with n hn
    have hnR : (0 : ℝ) < (n : ℝ) := by
      have : (0 : ℕ) < n := by omega
      exact_mod_cast this
    have hcast : ((n - 3 : ℕ) : ℝ) = (n : ℝ) - 3 := by
      have : (3 : ℕ) ≤ n := hn
      push_cast [Nat.cast_sub this]
      ring
    rw [hcast]
    field_simp
  have hprod := hcomp.mul hratio
  rw [mul_one] at hprod
  refine hprod.congr' ?_
  filter_upwards [eventually_ge_atTop 4] with n hn
  have hn3 : (0 : ℝ) < ((n - 3 : ℕ) : ℝ) := by
    have : (0 : ℕ) < n - 3 := by omega
    exact_mod_cast this
  have hnR : (0 : ℝ) < (n : ℝ) := by
    have : (0 : ℕ) < n := by omega
    exact_mod_cast this
  field_simp

/-! ## Step 3: the sandwich -/

/-- A snake of `Q (n-3)` is shorter than a coil of `Q n`. -/
theorem maxLen_sub_three_le_maxCoil {n : ℕ} (hn : 5 ≤ n) : maxLen (n - 3) ≤ maxCoil n := by
  have hm : 2 ≤ maxLen (n - 3) := le_trans (by omega) (dim_le_maxLen (n - 3))
  have h3 : 2 ≤ maxLen 3 := by rw [maxLen_three]; omega
  have h := maxCoil_ge_two_mul (m := n - 3) (n := 3) hm h3
  have hdim : n - 3 + 3 = n := by omega
  rw [hdim] at h
  omega

/-- A coil is at most three times as long as the longest snake of the same cube. -/
theorem maxCoil_le_three_mul_maxLen {n : ℕ} (hn : 1 ≤ n) : maxCoil n ≤ 3 * maxLen n := by
  have h1 := maxCoil_le_maxLen_add_two n
  have h2 : 1 ≤ maxLen n := le_trans hn (dim_le_maxLen n)
  omega

theorem log_maxCoil_tendsto :
    Tendsto (fun n : ℕ => Real.log (maxCoil n) / n) atTop (𝓝 logSnakeGrowth) := by
  have hupper : Tendsto (fun n : ℕ => Real.log 3 / n + Real.log (maxLen n) / n) atTop
      (𝓝 logSnakeGrowth) := by
    have h3 : Tendsto (fun n : ℕ => Real.log 3 / n) atTop (𝓝 0) :=
      tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop
    have := h3.add log_maxLen_tendsto
    rwa [zero_add] at this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' log_maxLen_shift_tendsto hupper ?_ ?_
  · filter_upwards [eventually_ge_atTop 5] with n hn
    have hnR : (0 : ℝ) < (n : ℝ) := by
      have : (0 : ℕ) < n := by omega
      exact_mod_cast this
    have hle : (maxLen (n - 3) : ℝ) ≤ (maxCoil n : ℝ) := by
      exact_mod_cast maxLen_sub_three_le_maxCoil hn
    have hpos : (0 : ℝ) < (maxLen (n - 3) : ℝ) := by
      have : (0 : ℕ) < maxLen (n - 3) := lt_of_lt_of_le (by omega) (dim_le_maxLen (n - 3))
      exact_mod_cast this
    have := Real.log_le_log hpos hle
    gcongr
  · filter_upwards [eventually_ge_atTop 5] with n hn
    have hnR : (0 : ℝ) < (n : ℝ) := by
      have : (0 : ℕ) < n := by omega
      exact_mod_cast this
    have hposC : (0 : ℝ) < (maxCoil n : ℝ) := by
      have h1 : 0 < maxCoil n := by
        have := maxLen_sub_three_le_maxCoil hn
        have : 0 < maxLen (n - 3) := lt_of_lt_of_le (by omega) (dim_le_maxLen (n - 3))
        omega
      exact_mod_cast h1
    have hposL : (0 : ℝ) < (maxLen n : ℝ) := by
      have : (0 : ℕ) < maxLen n := lt_of_lt_of_le (by omega) (dim_le_maxLen n)
      exact_mod_cast this
    have hle : (maxCoil n : ℝ) ≤ 3 * (maxLen n : ℝ) := by
      have := maxCoil_le_three_mul_maxLen (n := n) (by omega)
      exact_mod_cast this
    have hlog : Real.log (maxCoil n : ℝ) ≤ Real.log 3 + Real.log (maxLen n : ℝ) := by
      have h := Real.log_le_log hposC hle
      rwa [Real.log_mul (by norm_num) (ne_of_gt hposL)] at h
    rw [← add_div]
    gcongr

/-! ## Step 4: the coil growth constant equals the snake growth constant -/

/-- **Coils grow at the snake rate.**  `(maxCoil n) ^ (1/n)` converges, and to the
same constant as `(maxLen n) ^ (1/n)`. -/
theorem maxCoil_rpow_tendsto :
    Tendsto (fun n : ℕ => (maxCoil n : ℝ) ^ ((n : ℝ)⁻¹)) atTop (𝓝 snakeGrowth) := by
  have hexp := (Real.continuous_exp.tendsto logSnakeGrowth).comp log_maxCoil_tendsto
  have hg : Real.exp logSnakeGrowth = snakeGrowth := rfl
  rw [Function.comp_def, hg] at hexp
  refine hexp.congr' ?_
  filter_upwards [eventually_ge_atTop 5] with n hn
  have hposC : (0 : ℝ) < (maxCoil n : ℝ) := by
    have h1 : 0 < maxCoil n := by
      have h2 := maxLen_sub_three_le_maxCoil hn
      have h3 : 0 < maxLen (n - 3) := lt_of_lt_of_le (by omega) (dim_le_maxLen (n - 3))
      omega
    exact_mod_cast h1
  rw [Real.rpow_def_of_pos hposC]
  ring_nf

/-- **Same exponential rate for snakes and coils.**  Both normalised sequences
converge to `snakeGrowth`, which lies in `[23 ^ (1/7), 2]`. -/
theorem snake_coil_same_growth :
    Tendsto (fun n : ℕ => (maxLen n : ℝ) ^ ((n : ℝ)⁻¹)) atTop (𝓝 snakeGrowth) ∧
      Tendsto (fun n : ℕ => (maxCoil n : ℝ) ^ ((n : ℝ)⁻¹)) atTop (𝓝 snakeGrowth) ∧
      (23 : ℝ) ^ ((7 : ℝ)⁻¹) ≤ snakeGrowth ∧ snakeGrowth ≤ 2 :=
  ⟨snakeGrowth_tendsto, maxCoil_rpow_tendsto, snakeGrowth_ge, snakeGrowth_le_two⟩

end SnakeInTheBox