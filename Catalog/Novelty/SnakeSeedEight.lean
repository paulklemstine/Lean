/-
# An explicit snake of length 86 in `Q 8`, and the growth constant beyond 1.6

`Novelty/SnakeSeed.lean` and `Novelty/SnakeSeedSeven.lean` supply kernel-verified
snakes of `Q 6` and `Q 7` with `26` and `47` edges.  This file adds the eight
dimensional seed: an explicit chordless induced path with **86 edges** in `Q 8`,
found by depth-first search with restarts and verified here by kernel computation
(`decide`, no `native_decide`).  The true optimum is `s(8) = 98`; no optimality is
claimed, only the verified existence of the snake exhibited.

Because `86` is *even*, the sharp comb bound of `Novelty/SnakeCombSharp.lean`
applies to it without any rounding loss, and the two general lemmas
`maxLen_exp_of_seed` and `snakeGrowth_ge_of_maxLen` convert the seed into

> `maxLen_exponential_eight : 8 ≤ n → 44 ^ ⌊n/8⌋ ≤ maxLen n`,
> `snakeGrowth_ge_eight     : 43 ^ (1/8) ≤ snakeGrowth`,
> `one_point_six_lt_snakeGrowth : 1.6 < snakeGrowth`,

improving the previous cycle's `23 ^ ⌊n/7⌋` and `23 ^ (1/7) ≈ 1.5637`.
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.SnakeGridComb
import Novelty.SnakeGrowthConstant
import Novelty.SnakeCombSharp

namespace SnakeInTheBox

set_option maxRecDepth 100000

/-- The vertices of an explicit snake of length 86 in the eight-cube. -/
def snake8v : ℕ → Cube 8
  | 0 => ![false, false, false, false, false, false, false, false]
  | 1 => ![false, false, false, false, false, false, true, false]
  | 2 => ![false, false, false, true, false, false, true, false]
  | 3 => ![false, true, false, true, false, false, true, false]
  | 4 => ![false, true, true, true, false, false, true, false]
  | 5 => ![false, true, true, true, true, false, true, false]
  | 6 => ![false, false, true, true, true, false, true, false]
  | 7 => ![false, false, true, true, true, true, true, false]
  | 8 => ![false, false, false, true, true, true, true, false]
  | 9 => ![false, false, false, true, true, true, false, false]
  | 10 => ![false, false, false, true, false, true, false, false]
  | 11 => ![false, false, true, true, false, true, false, false]
  | 12 => ![false, false, true, true, false, false, false, false]
  | 13 => ![false, false, true, true, false, false, false, true]
  | 14 => ![false, false, true, true, true, false, false, true]
  | 15 => ![false, false, true, true, true, true, false, true]
  | 16 => ![false, true, true, true, true, true, false, true]
  | 17 => ![false, true, true, true, false, true, false, true]
  | 18 => ![false, true, true, true, false, true, true, true]
  | 19 => ![false, true, false, true, false, true, true, true]
  | 20 => ![true, true, false, true, false, true, true, true]
  | 21 => ![true, true, false, true, false, true, true, false]
  | 22 => ![true, true, false, true, false, true, false, false]
  | 23 => ![true, true, true, true, false, true, false, false]
  | 24 => ![true, true, true, true, false, false, false, false]
  | 25 => ![true, true, true, false, false, false, false, false]
  | 26 => ![true, true, false, false, false, false, false, false]
  | 27 => ![true, true, false, false, false, false, true, false]
  | 28 => ![true, true, false, false, false, false, true, true]
  | 29 => ![false, true, false, false, false, false, true, true]
  | 30 => ![false, true, true, false, false, false, true, true]
  | 31 => ![false, true, true, false, false, false, false, true]
  | 32 => ![false, true, true, false, true, false, false, true]
  | 33 => ![true, true, true, false, true, false, false, true]
  | 34 => ![true, false, true, false, true, false, false, true]
  | 35 => ![true, false, true, false, false, false, false, true]
  | 36 => ![true, false, false, false, false, false, false, true]
  | 37 => ![true, false, false, true, false, false, false, true]
  | 38 => ![true, false, false, true, false, true, false, true]
  | 39 => ![true, false, true, true, false, true, false, true]
  | 40 => ![true, false, true, true, false, true, true, true]
  | 41 => ![true, false, true, true, false, true, true, false]
  | 42 => ![true, false, true, true, false, false, true, false]
  | 43 => ![true, false, true, false, false, false, true, false]
  | 44 => ![true, false, true, false, true, false, true, false]
  | 45 => ![true, false, false, false, true, false, true, false]
  | 46 => ![true, false, false, false, true, false, false, false]
  | 47 => ![true, false, false, true, true, false, false, false]
  | 48 => ![true, false, true, true, true, false, false, false]
  | 49 => ![true, false, true, true, true, true, false, false]
  | 50 => ![true, false, true, false, true, true, false, false]
  | 51 => ![true, false, true, false, false, true, false, false]
  | 52 => ![true, false, false, false, false, true, false, false]
  | 53 => ![true, false, false, false, false, true, true, false]
  | 54 => ![true, false, false, false, false, true, true, true]
  | 55 => ![true, false, false, false, true, true, true, true]
  | 56 => ![true, false, true, false, true, true, true, true]
  | 57 => ![false, false, true, false, true, true, true, true]
  | 58 => ![false, false, true, false, false, true, true, true]
  | 59 => ![false, false, true, false, false, true, false, true]
  | 60 => ![false, false, false, false, false, true, false, true]
  | 61 => ![false, false, false, false, true, true, false, true]
  | 62 => ![false, false, false, false, true, false, false, true]
  | 63 => ![false, false, false, false, true, false, true, true]
  | 64 => ![false, false, false, true, true, false, true, true]
  | 65 => ![true, false, false, true, true, false, true, true]
  | 66 => ![true, false, true, true, true, false, true, true]
  | 67 => ![true, true, true, true, true, false, true, true]
  | 68 => ![true, true, true, true, true, true, true, true]
  | 69 => ![true, true, true, true, true, true, true, false]
  | 70 => ![true, true, true, false, true, true, true, false]
  | 71 => ![true, true, true, false, false, true, true, false]
  | 72 => ![true, true, true, false, false, true, true, true]
  | 73 => ![true, true, true, false, false, true, false, true]
  | 74 => ![true, true, false, false, false, true, false, true]
  | 75 => ![true, true, false, false, true, true, false, true]
  | 76 => ![true, true, false, true, true, true, false, true]
  | 77 => ![true, true, false, true, true, false, false, true]
  | 78 => ![false, true, false, true, true, false, false, true]
  | 79 => ![false, true, false, true, true, false, false, false]
  | 80 => ![false, true, false, false, true, false, false, false]
  | 81 => ![false, true, false, false, true, false, true, false]
  | 82 => ![false, true, false, false, true, true, true, false]
  | 83 => ![false, true, false, false, false, true, true, false]
  | 84 => ![false, true, false, false, false, true, false, false]
  | 85 => ![false, true, true, false, false, true, false, false]
  | 86 => ![false, true, true, false, true, true, false, false]
  | _ => ![false, false, false, false, false, false, false, false]

theorem snake8_step : ∀ i, i < 86 → Adj (snake8v i) (snake8v (i + 1)) := by
  intro i hi
  interval_cases i <;> decide

theorem snake8_chord_fin : ∀ i j : Fin 87, (i : ℕ) + 2 ≤ (j : ℕ) →
    2 ≤ hammingDist (snake8v i) (snake8v j) := by decide

theorem snake8_chord : ∀ i j, j ≤ 86 → i + 2 ≤ j →
    2 ≤ hammingDist (snake8v i) (snake8v j) := by
  intro i j hj hij
  exact snake8_chord_fin ⟨i, by omega⟩ ⟨j, by omega⟩ (by simpa using hij)

/-- **An explicit snake of length 86 in `Q 8`.** -/
def snake8 : Snake 8 86 := ⟨snake8v, snake8_step, snake8_chord⟩

theorem maxLen_eight_ge : 86 ≤ maxLen 8 := le_maxLen snake8

/-! ## Consequences of the eight-dimensional seed -/

variable {n : ℕ}

/-- **Exponential lower bound, base `44 ^ (1/8) ≈ 1.6047`.**  Each block of eight
dimensions multiplies the maximal snake length by `44`, improving the previous
`23` per seven dimensions. -/
theorem maxLen_exponential_eight (hn : 8 ≤ n) : 44 ^ (n / 8) ≤ maxLen n := by
  have h := maxLen_exp_of_seed (k := 8) (N := 86) (by norm_num) (by norm_num) (by norm_num)
    maxLen_eight_ge hn
  norm_num at h
  exact h

/-- The eight-dimensional seed bounds the growth constant from below by
`43 ^ (1/8) ≈ 1.6003`. -/
theorem snakeGrowth_ge_eight : (43 : ℝ) ^ ((8 : ℝ)⁻¹) ≤ snakeGrowth := by
  have h := snakeGrowth_ge_of_maxLen (k := 8) (N := 86) (by norm_num) (by norm_num)
    maxLen_eight_ge
  have e : (((86 : ℕ) : ℝ) / 2) = 43 := by norm_num
  have e' : (((8 : ℕ) : ℝ))⁻¹ = ((8 : ℝ))⁻¹ := by norm_num
  rw [e, e'] at h
  exact h

/-- **The growth constant exceeds `1.6`**, improving `three_halves_lt_snakeGrowth`. -/
theorem one_point_six_lt_snakeGrowth : (1.6 : ℝ) < snakeGrowth := by
  have hbase : (1.6 : ℝ) < (43 : ℝ) ^ ((8 : ℝ)⁻¹) := by
    have hpow : ((1.6 : ℝ) ^ (8 : ℕ)) < 43 := by norm_num
    have h1 : ((1.6 : ℝ) ^ (8 : ℕ)) ^ ((8 : ℝ)⁻¹) < (43 : ℝ) ^ ((8 : ℝ)⁻¹) :=
      Real.rpow_lt_rpow (by positivity) hpow (by norm_num)
    have h2 : ((1.6 : ℝ) ^ (8 : ℕ)) ^ ((8 : ℝ)⁻¹) = (1.6 : ℝ) := by
      rw [← Real.rpow_natCast (1.6 : ℝ) 8, ← Real.rpow_mul (by norm_num)]
      norm_num
    rwa [h2] at h1
  linarith [snakeGrowth_ge_eight, hbase]

/-- **The improved two-sided picture.**  For every dimension `n ≥ 8` the maximal snake
length is squeezed between the seeded exponential bound of base `44 ^ (1/8) ≈ 1.6047`
and the strict counting ceiling of base `2`. -/
theorem maxLen_picture_eight (hn : 8 ≤ n) :
    44 ^ (n / 8) ≤ maxLen n ∧ maxLen n + 1 < 3 * 2 ^ (n - 2) :=
  ⟨maxLen_exponential_eight hn, maxLen_upper (by omega)⟩

/-- **The improved bracket for the growth constant.** -/
theorem snakeGrowth_bracket_sharp :
    (43 : ℝ) ^ ((8 : ℝ)⁻¹) ≤ snakeGrowth ∧ snakeGrowth ≤ 2 ∧ (1.6 : ℝ) < snakeGrowth :=
  ⟨snakeGrowth_ge_eight, snakeGrowth_le_two, one_point_six_lt_snakeGrowth⟩

end SnakeInTheBox