import Algebra.NonBacktracking.HashimotoTrace

/-!
# Worked examples of the non-backtracking trace formula

Concrete graphs on which the counting theorem
`trace (B ^ n) = #{rooted closed non-backtracking walks of length n}` is exercised.

* the **triangle** `K₃`: its Hashimoto matrix is a permutation matrix of order `3`
  (`Hashimoto.Examples.K3_hashimoto_pow_three`), whence the exact periodic count
  `trace (B ^ n) = 6` if `3 ∣ n` and `0` otherwise;
* the **complete graph** `K₄`: `trace (B³) = 24 = 6 · 4` (four triangles) and
  `trace (B⁴) = 24 = 8 · 3` (three quadrilaterals);
* the **path** `P₃`, a tree: `B² = 0`, so a tree has no closed non-backtracking walk
  of any length.

All numeric statements are checked by kernel evaluation (`decide`) and then combined
with the general theorems, so no example is a bare computation.
-/

namespace Hashimoto.Examples

open Hashimoto

/-! ## The triangle -/

/-- The triangle `K₃`. -/
def K3 : SimpleGraph (Fin 3) := ⊤

instance : DecidableRel K3.Adj := fun a b => by unfold K3; infer_instance

theorem K3_card_darts : Fintype.card K3.Dart = 6 := by decide

/-- On the triangle every dart has a unique non-backtracking continuation, and the
resulting permutation of the six darts has order three. -/
theorem K3_hashimoto_pow_three : hashimoto K3 ^ 3 = 1 := by decide

/-- The number of rooted closed non-backtracking walks of length `3k` in `K₃` is `6`. -/
theorem K3_closedNBWalks_mul_three (k : ℕ) :
    (closedNBWalks K3 (3 * k)).card = 6 := by
  rw [← trace_hashimoto_pow, pow_mul, K3_hashimoto_pow_three, one_pow, Matrix.trace_one,
    K3_card_darts]
  norm_num

/-- There is no rooted closed non-backtracking walk of length `3k + 1` in `K₃`. -/
theorem K3_closedNBWalks_mul_three_add_one (k : ℕ) :
    (closedNBWalks K3 (3 * k + 1)).card = 0 := by
  rw [← trace_hashimoto_pow, pow_add, pow_mul, K3_hashimoto_pow_three, one_pow, one_mul]
  exact trace_hashimoto K3

/-- There is no rooted closed non-backtracking walk of length `3k + 2` in `K₃`. -/
theorem K3_closedNBWalks_mul_three_add_two (k : ℕ) :
    (closedNBWalks K3 (3 * k + 2)).card = 0 := by
  rw [← trace_hashimoto_pow, pow_add, pow_mul, K3_hashimoto_pow_three, one_pow, one_mul]
  exact trace_hashimoto_sq K3

/-- Complete periodicity statement for the triangle: the number of rooted closed
non-backtracking walks of length `n` is `6` when `3 ∣ n` and `0` otherwise. -/
theorem K3_closedNBWalks (n : ℕ) :
    (closedNBWalks K3 n).card = if 3 ∣ n then 6 else 0 := by
  obtain ⟨k, r, hr, rfl⟩ : ∃ k r, r < 3 ∧ n = 3 * k + r :=
    ⟨n / 3, n % 3, Nat.mod_lt _ (by norm_num), by omega⟩
  interval_cases r
  · simpa using K3_closedNBWalks_mul_three k
  · rw [K3_closedNBWalks_mul_three_add_one k, if_neg (by omega)]
  · rw [K3_closedNBWalks_mul_three_add_two k, if_neg (by omega)]

/-! ## The complete graph on four vertices -/

/-- The complete graph `K₄`. -/
def K4 : SimpleGraph (Fin 4) := ⊤

instance : DecidableRel K4.Adj := fun a b => by unfold K4; infer_instance

/-- `K₄` has `4` triangles, hence `24` ordered triangles, hence `24` rooted closed
non-backtracking walks of length three. -/
theorem K4_closedNBWalks_three : (closedNBWalks K4 3).card = 24 := by
  rw [← trace_hashimoto_pow, trace_hashimoto_cube]
  decide

/-- The three quadrilaterals of `K₄` give `3 · 8 = 24` rooted closed non-backtracking
walks of length four. -/
theorem K4_closedNBWalks_four : (closedNBWalks K4 4).card = 24 := by
  rw [← trace_hashimoto_pow]
  decide

/-! ## The pentagon -/

/-- The cycle graph `C₅`. -/
def C5 : SimpleGraph (Fin 5) := SimpleGraph.fromRel fun u v => (u.val + 1) % 5 = v.val

instance : DecidableRel C5.Adj := fun a b => by unfold C5 SimpleGraph.fromRel; infer_instance

set_option maxHeartbeats 2000000 in
/-- On a cycle graph every dart has a unique continuation; for `C₅` the resulting
permutation of the ten darts has order five (two `5`-cycles: one per orientation). -/
theorem C5_hashimoto_pow_five : hashimoto C5 ^ 5 = 1 := by decide

theorem C5_card_darts : Fintype.card C5.Dart = 10 := by decide

set_option maxHeartbeats 1000000 in
/-- `C₅` has no closed non-backtracking walk of length three. -/
theorem C5_trace_pow_three : (hashimoto C5 ^ 3).trace = 0 := by decide

set_option maxHeartbeats 2000000 in
/-- `C₅` has no closed non-backtracking walk of length four. -/
theorem C5_trace_pow_four : (hashimoto C5 ^ 4).trace = 0 := by decide

/-- The pentagon has `10` rooted closed non-backtracking walks of every length divisible
by `5` (five rotations times two orientations) and none of any other positive length. -/
theorem C5_closedNBWalks (n : ℕ) (hn : 1 ≤ n) :
    (closedNBWalks C5 n).card = if 5 ∣ n then 10 else 0 := by
  obtain ⟨k, r, hr, rfl⟩ : ∃ k r, r < 5 ∧ n = 5 * k + r :=
    ⟨n / 5, n % 5, Nat.mod_lt _ (by norm_num), by omega⟩
  rw [← trace_hashimoto_pow, pow_add, pow_mul, C5_hashimoto_pow_five, one_pow, one_mul]
  interval_cases r
  · rw [pow_zero, Matrix.trace_one, C5_card_darts, if_pos (by omega)]
    norm_num
  · rw [if_neg (by omega)]
    exact trace_hashimoto C5
  · rw [if_neg (by omega)]
    exact trace_hashimoto_sq C5
  · rw [if_neg (by omega)]
    exact C5_trace_pow_three
  · rw [if_neg (by omega)]
    exact C5_trace_pow_four

/-! ## A tree -/

/-- The path `0 — 1 — 2`. -/
def P3 : SimpleGraph (Fin 3) := SimpleGraph.fromRel fun u v => u.val + 1 = v.val

instance : DecidableRel P3.Adj := fun a b => by unfold P3 SimpleGraph.fromRel; infer_instance

/-- On a path the non-backtracking matrix is nilpotent of order two. -/
theorem P3_hashimoto_sq : hashimoto P3 ^ 2 = 0 := by decide

/-- A tree carries no rooted closed non-backtracking walk of any positive length.
(For `n = 0` the count is the number of darts, namely `4`.) -/
theorem P3_closedNBWalks {n : ℕ} (hn : 1 ≤ n) : (closedNBWalks P3 n).card = 0 := by
  rw [← trace_hashimoto_pow]
  match n, hn with
  | 1, _ => exact trace_hashimoto P3
  | (m + 2), _ => rw [pow_add, P3_hashimoto_sq, mul_zero, Matrix.trace_zero]

end Hashimoto.Examples