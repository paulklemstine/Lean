/-
# An explicit snake of length 26 in `Q 6`, and the improved linear lower bound

`Novelty.SnakeConcat` proved that the maximal snake length is superadditive.
Superadditivity turns any single explicit snake into a linear lower bound whose
slope is that snake's *density per dimension*.  The catalog's seed is the snake
of length four in `Q 3` (slope `4/3` per dimension, improved to two per
dimension by the two-ended lift `Snake.lift2`).

Here we verify — by kernel computation, with `decide`, no `native_decide` — an
explicit snake with 27 vertices and 26 edges in the six-cube.  It was found by
a depth-first search; 26 is in fact the known optimum `s(6) = 26`, but the
optimality is *not* claimed here: only the (fully verified) existence.

Feeding it into superadditivity, and topping up the remaining dimensions with
the catalog's two-edges-per-dimension lift, gives

> `maxLen_lower_four : 6 ≤ n → 4 * n ≤ maxLen n + 8`,

which doubles the growth rate `2n - 2` of the catalog.
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.SnakeConcat

namespace SnakeInTheBox

set_option maxRecDepth 20000

/-- The vertices of an explicit snake of length 26 in the six-cube, found by
depth-first search. -/
def snake6v : ℕ → Cube 6
  | 0 => ![false, false, false, false, false, false]
  | 1 => ![false, true, false, false, false, false]
  | 2 => ![true, true, false, false, false, false]
  | 3 => ![true, true, true, false, false, false]
  | 4 => ![true, true, true, true, false, false]
  | 5 => ![false, true, true, true, false, false]
  | 6 => ![false, false, true, true, false, false]
  | 7 => ![false, false, true, true, false, true]
  | 8 => ![false, false, true, false, false, true]
  | 9 => ![false, true, true, false, false, true]
  | 10 => ![false, true, true, false, true, true]
  | 11 => ![false, true, true, false, true, false]
  | 12 => ![false, false, true, false, true, false]
  | 13 => ![true, false, true, false, true, false]
  | 14 => ![true, false, true, true, true, false]
  | 15 => ![true, false, true, true, true, true]
  | 16 => ![true, true, true, true, true, true]
  | 17 => ![true, true, false, true, true, true]
  | 18 => ![true, true, false, true, true, false]
  | 19 => ![false, true, false, true, true, false]
  | 20 => ![false, false, false, true, true, false]
  | 21 => ![false, false, false, true, true, true]
  | 22 => ![false, false, false, false, true, true]
  | 23 => ![true, false, false, false, true, true]
  | 24 => ![true, false, false, false, false, true]
  | 25 => ![true, false, false, true, false, true]
  | 26 => ![true, false, false, true, false, false]
  | _ => ![false, false, false, false, false, false]

theorem snake6_step : ∀ i, i < 26 → Adj (snake6v i) (snake6v (i + 1)) := by
  intro i hi
  interval_cases i <;> decide

/-- The chord condition, checked on all pairs of indices at once. -/
theorem snake6_chord_fin : ∀ i j : Fin 27, (i : ℕ) + 2 ≤ (j : ℕ) →
    2 ≤ hammingDist (snake6v i) (snake6v j) := by decide

theorem snake6_chord : ∀ i j, j ≤ 26 → i + 2 ≤ j →
    2 ≤ hammingDist (snake6v i) (snake6v j) := by
  intro i j hj hij
  exact snake6_chord_fin ⟨i, by omega⟩ ⟨j, by omega⟩ (by simpa using hij)

/-- **An explicit snake of length 26 in `Q 6`.** -/
def snake6 : Snake 6 26 := ⟨snake6v, snake6_step, snake6_chord⟩

theorem maxLen_six_ge : 26 ≤ maxLen 6 := le_maxLen snake6

/-- Superadditivity with the six-dimensional seed, topped up by the
two-edges-per-dimension lift. -/
theorem maxLen_lower_six (k r : ℕ) (hk : 1 ≤ k) : 26 * k + 2 * r ≤ maxLen (6 * k + r) := by
  induction r with
  | zero =>
    have h1 : k * maxLen 6 ≤ maxLen (k * 6) := maxLen_nsmul k 6
    rw [show k * 6 = 6 * k from by ring] at h1
    have h2 : 26 * k ≤ k * maxLen 6 := by
      calc 26 * k = k * 26 := by ring
        _ ≤ k * maxLen 6 := Nat.mul_le_mul_left k maxLen_six_ge
    simp only [Nat.add_zero, Nat.mul_zero]
    exact le_trans h2 h1
  | succ q ih =>
    have h1 : maxLen (6 * k + q) + 2 ≤ maxLen (6 * k + q + 1) :=
      maxLen_succ_ge_two (by omega)
    have h2 : 6 * k + (q + 1) = 6 * k + q + 1 := by ring
    rw [h2]
    omega

/-- **Improved linear lower bound.**  Every `Q n` with `n ≥ 6` contains a snake with at
least `4n - 8` edges — twice the growth rate of the catalog bound `2n - 2`. -/
theorem maxLen_lower_four (hn : 6 ≤ n) : 4 * n ≤ maxLen n + 8 := by
  have hdm : 6 * (n / 6) + n % 6 = n := Nat.div_add_mod n 6
  have hr : n % 6 < 6 := Nat.mod_lt _ (by norm_num)
  have hk : 1 ≤ n / 6 := Nat.one_le_div_iff (by norm_num) |>.mpr hn
  have h := maxLen_lower_six (n / 6) (n % 6) hk
  rw [hdm] at h
  omega

end SnakeInTheBox