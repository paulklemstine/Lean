/-
# An explicit snake of length 47 in `Q 7` and the best linear lower bound of this file

Same scheme as `Novelty.SnakeSeed`, one dimension higher.  The 48 vertices below
were found by depth-first search and are verified here by kernel computation
(`decide`, no `native_decide`).  Seven dimensions buy `47` edges, a slope of
`47/7 ≈ 6.71` edges per dimension, against `26/6 ≈ 4.33` in `Q 6` and `2` for
the catalog's lift.  Superadditivity (`Novelty.SnakeConcat`) turns this into

> `maxLen_lower_six_slope : 7 ≤ n → 6 * n ≤ maxLen n + 19`.

The true optimum in dimension seven is `s(7) = 50`; no optimality is claimed
here, only the verified existence of the snake exhibited.
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.SnakeConcat
import Novelty.SnakeSeed

namespace SnakeInTheBox

set_option maxRecDepth 40000

/-- The vertices of an explicit snake of length 47 in the seven-cube. -/
def snake7v : ℕ → Cube 7
  | 0 => ![false, false, false, false, false, false, false]
  | 1 => ![false, false, false, true, false, false, false]
  | 2 => ![false, false, false, true, true, false, false]
  | 3 => ![false, false, false, true, true, false, true]
  | 4 => ![false, false, false, true, true, true, true]
  | 5 => ![false, false, false, false, true, true, true]
  | 6 => ![false, false, false, false, true, true, false]
  | 7 => ![false, false, true, false, true, true, false]
  | 8 => ![false, false, true, false, false, true, false]
  | 9 => ![false, false, true, true, false, true, false]
  | 10 => ![false, false, true, true, false, true, true]
  | 11 => ![false, false, true, true, false, false, true]
  | 12 => ![false, false, true, false, false, false, true]
  | 13 => ![true, false, true, false, false, false, true]
  | 14 => ![true, false, false, false, false, false, true]
  | 15 => ![true, false, false, true, false, false, true]
  | 16 => ![true, false, false, true, false, true, true]
  | 17 => ![true, false, false, true, false, true, false]
  | 18 => ![true, false, false, true, true, true, false]
  | 19 => ![true, true, false, true, true, true, false]
  | 20 => ![true, true, true, true, true, true, false]
  | 21 => ![true, true, true, true, false, true, false]
  | 22 => ![true, true, true, true, false, false, false]
  | 23 => ![true, true, true, false, false, false, false]
  | 24 => ![false, true, true, false, false, false, false]
  | 25 => ![false, true, true, false, true, false, false]
  | 26 => ![false, true, true, true, true, false, false]
  | 27 => ![false, true, true, true, true, false, true]
  | 28 => ![false, true, true, true, true, true, true]
  | 29 => ![false, true, true, false, true, true, true]
  | 30 => ![false, true, true, false, false, true, true]
  | 31 => ![true, true, true, false, false, true, true]
  | 32 => ![true, true, false, false, false, true, true]
  | 33 => ![true, true, false, false, false, true, false]
  | 34 => ![false, true, false, false, false, true, false]
  | 35 => ![false, true, false, true, false, true, false]
  | 36 => ![false, true, false, true, false, true, true]
  | 37 => ![false, true, false, true, false, false, true]
  | 38 => ![false, true, false, false, false, false, true]
  | 39 => ![false, true, false, false, true, false, true]
  | 40 => ![true, true, false, false, true, false, true]
  | 41 => ![true, true, false, false, true, false, false]
  | 42 => ![true, false, false, false, true, false, false]
  | 43 => ![true, false, true, false, true, false, false]
  | 44 => ![true, false, true, true, true, false, false]
  | 45 => ![true, false, true, true, true, false, true]
  | 46 => ![true, false, true, true, true, true, true]
  | 47 => ![true, false, true, false, true, true, true]
  | _ => ![false, false, false, false, false, false, false]

theorem snake7_step : ∀ i, i < 47 → Adj (snake7v i) (snake7v (i + 1)) := by
  intro i hi
  interval_cases i <;> decide

/-- The chord condition, checked on all pairs of indices at once. -/
theorem snake7_chord_fin : ∀ i j : Fin 48, (i : ℕ) + 2 ≤ (j : ℕ) →
    2 ≤ hammingDist (snake7v i) (snake7v j) := by decide

theorem snake7_chord : ∀ i j, j ≤ 47 → i + 2 ≤ j →
    2 ≤ hammingDist (snake7v i) (snake7v j) := by
  intro i j hj hij
  exact snake7_chord_fin ⟨i, by omega⟩ ⟨j, by omega⟩ (by simpa using hij)

/-- **An explicit snake of length 47 in `Q 7`.** -/
def snake7 : Snake 7 47 := ⟨snake7v, snake7_step, snake7_chord⟩

theorem maxLen_seven_ge : 47 ≤ maxLen 7 := le_maxLen snake7

/-- Superadditivity with the seven-dimensional seed, topped up by the
two-edges-per-dimension lift. -/
theorem maxLen_lower_seven (k r : ℕ) (hk : 1 ≤ k) : 47 * k + 2 * r ≤ maxLen (7 * k + r) := by
  induction r with
  | zero =>
    have h1 : k * maxLen 7 ≤ maxLen (k * 7) := maxLen_nsmul k 7
    rw [show k * 7 = 7 * k from by ring] at h1
    have h2 : 47 * k ≤ k * maxLen 7 := by
      calc 47 * k = k * 47 := by ring
        _ ≤ k * maxLen 7 := Nat.mul_le_mul_left k maxLen_seven_ge
    simp only [Nat.add_zero, Nat.mul_zero]
    exact le_trans h2 h1
  | succ q ih =>
    have h1 : maxLen (7 * k + q) + 2 ≤ maxLen (7 * k + q + 1) :=
      maxLen_succ_ge_two (by omega)
    have h2 : 7 * k + (q + 1) = 7 * k + q + 1 := by ring
    rw [h2]
    omega

/-- **Linear lower bound with slope six.**  Every `Q n` with `n ≥ 7` contains a snake with
at least `6n - 19` edges, three times the growth rate of the catalog bound `2n - 2`. -/
theorem maxLen_lower_six_slope (hn : 7 ≤ n) : 6 * n ≤ maxLen n + 19 := by
  have hdm : 7 * (n / 7) + n % 7 = n := Nat.div_add_mod n 7
  have hr : n % 7 < 7 := Nat.mod_lt _ (by norm_num)
  have hk : 1 ≤ n / 7 := Nat.one_le_div_iff (by norm_num) |>.mpr hn
  have h := maxLen_lower_seven (n / 7) (n % 7) hk
  rw [hdm] at h
  omega

/-- The final two-sided picture for the maximal snake length: a linear lower bound of
slope six from the explicit seven-dimensional seed and superadditivity, against the
catalog's strict counting ceiling. -/
theorem maxLen_final_picture (hn : 7 ≤ n) :
    6 * n ≤ maxLen n + 19 ∧ maxLen n + 1 < 3 * 2 ^ (n - 2) :=
  ⟨maxLen_lower_six_slope hn, maxLen_upper (by omega)⟩

end SnakeInTheBox