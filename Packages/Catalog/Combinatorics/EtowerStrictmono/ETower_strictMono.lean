import Mathlib

/-! # CatalogBuild.Shared.ETower_strictMono

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5

The generated source listed the definition `eTower` *after* the theorems that use
it (and closed more sections than it opened), so the file did not compile.  The
declarations are reordered below and the two proofs that were left incomplete
(`eTower_strictMono` and `eTower_ge_pow2`) are finished.
-/

noncomputable section

namespace ETower

/-- The e-tower: e↑↑n. -/
def eTower : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower n)

/-- The e-tower is strictly positive. -/
theorem eTower_pos (n : ℕ) : 0 < eTower n := by
  induction n with
  | zero => simp [eTower]
  | succ n _ => exact Real.exp_pos _

/-- Every real is strictly below its exponential. -/
theorem lt_exp_self (x : ℝ) : x < Real.exp x :=
  lt_of_lt_of_le (by linarith) (Real.add_one_le_exp x)

theorem eTower_strictMono : StrictMono eTower := by
  refine strictMono_nat_of_lt_succ fun n => ?_
  show eTower n < Real.exp (eTower n)
  exact lt_exp_self _

/-- `2x ≤ exp x` for `x ≥ 0`: square the tangent-line bound at `x/2`. -/
theorem two_mul_le_exp (x : ℝ) (hx : 0 ≤ x) : 2 * x ≤ Real.exp x := by
  have h := Real.add_one_le_exp (x / 2)
  have hpos : 0 < Real.exp (x / 2) := Real.exp_pos _
  have hsq : Real.exp x = Real.exp (x / 2) * Real.exp (x / 2) := by
    rw [← Real.exp_add]; ring_nf
  rw [hsq]
  nlinarith [h, hpos, hx, sq_nonneg (x / 2 - 1)]

theorem eTower_ge_pow2 (n : ℕ) (hn : 1 ≤ n) : eTower n ≥ 2 ^ n := by
  induction n with
  | zero => omega
  | succ n ih =>
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · have h := Real.add_one_le_exp (1 : ℝ)
      have : eTower 1 = Real.exp 1 := by simp [eTower]
      rw [this]
      norm_num
      linarith
    · have h1 := ih hpos
      calc (2 : ℝ) ^ (n + 1) = 2 * 2 ^ n := by ring
        _ ≤ Real.exp (2 ^ n) := two_mul_le_exp _ (by positivity)
        _ ≤ Real.exp (eTower n) := Real.exp_le_exp.mpr h1
        _ = eTower (n + 1) := rfl

/-- e-tower grows at least as fast as n. -/
theorem eTower_ge_n (n : ℕ) : eTower n ≥ n := by
  induction n with
  | zero => simp [eTower]
  | succ n ih =>
    have h : eTower (n + 1) = Real.exp (eTower n) := rfl
    have := Real.add_one_le_exp (eTower n)
    push_cast
    rw [h]
    linarith

end ETower

end