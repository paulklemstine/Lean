import Mathlib

/-! # CatalogBuild.Shared.ETower_strictMono

The iterated exponential ("e-tower") `e↑↑n` and its growth.

The auto-generated catalog file listed these theorems before the definition
`eTower` that they all use (and closed three sections it never opened); the
declarations are collected here in dependency order.
-/

noncomputable section

/-- The e-tower: e↑↑n. -/
def eTower : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower n)

/-- The e-tower is strictly positive. -/
theorem eTower_pos (n : ℕ) : 0 < eTower n := by
  induction n with
  | zero => simp [eTower]
  | succ n _ => exact Real.exp_pos _

/-- `2x ≤ eˣ` for `x ≥ 0`: the doubling bound behind the exponential growth. -/
theorem two_mul_le_exp {x : ℝ} (hx : 0 ≤ x) : 2 * x ≤ Real.exp x := by
  have h := Real.add_one_le_exp (x / 2)
  have hp : (0 : ℝ) < Real.exp (x / 2) := Real.exp_pos _
  have hsq : Real.exp (x / 2) ^ 2 = Real.exp x := by
    rw [← Real.exp_nat_mul]
    norm_num
    ring_nf
  nlinarith [hsq, sq_nonneg (x / 2 - 1)]

theorem eTower_strictMono : StrictMono eTower := by
  refine strictMono_nat_of_lt_succ ?_
  intro n
  have h := Real.add_one_le_exp (eTower n)
  show eTower n < Real.exp (eTower n)
  linarith

theorem eTower_ge_pow2 (n : ℕ) (hn : 1 ≤ n) : eTower n ≥ 2 ^ n := by
  induction n with
  | zero => omega
  | succ n ih =>
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · show Real.exp (eTower 0) ≥ 2 ^ 1
      have := Real.add_one_le_exp (1 : ℝ)
      simp [eTower]
      linarith
    · have ihn := ih hpos
      have hpow : (0 : ℝ) ≤ 2 ^ n := by positivity
      have hstep : 2 * eTower n ≤ Real.exp (eTower n) :=
        two_mul_le_exp (le_of_lt (eTower_pos n))
      show Real.exp (eTower n) ≥ 2 ^ (n + 1)
      have : (2 : ℝ) ^ (n + 1) = 2 * 2 ^ n := by ring
      linarith

/-- e-tower grows at least as fast as n. -/
theorem eTower_ge_n (n : ℕ) : eTower n ≥ n := by
  induction n with
  | zero => simp [eTower]
  | succ n ih =>
    have hstep : eTower (n + 1) = Real.exp (eTower n) := rfl
    rw [hstep]
    push_cast
    linarith [Real.add_one_le_exp (eTower n)]

end