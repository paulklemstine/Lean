import Mathlib

/-! # CatalogBuild.Shared.ETower_strictMono

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5
-/

noncomputable section

/-- The e-tower: e↑↑n. -/
def eTower : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTower n)

/-- `exp` dominates doubling on the nonnegative reals: `2x ≤ exp x` for `0 ≤ x`. -/
theorem two_mul_le_exp (x : ℝ) (hx : 0 ≤ x) : 2 * x ≤ Real.exp x := by
  have h := Real.add_one_le_exp (x / 2)
  have h2 : Real.exp x = Real.exp (x / 2) * Real.exp (x / 2) := by
    rw [← Real.exp_add]; ring_nf
  have hnn : (0:ℝ) ≤ x / 2 + 1 := by linarith
  have h3 : (x / 2 + 1) * (x / 2 + 1) ≤ Real.exp (x / 2) * Real.exp (x / 2) :=
    mul_le_mul h h hnn (le_trans hnn h)
  rw [h2]
  nlinarith [sq_nonneg (x / 2 - 1)]

/-- [Section: # CatalogBuild.Shared.ETower_strictMono
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 5] -/
theorem eTower_strictMono : StrictMono eTower := by
  apply strictMono_nat_of_lt_succ
  intro n
  have h := Real.add_one_le_exp (eTower n)
  show eTower n < Real.exp (eTower n)
  linarith

/-- The e-tower is strictly positive. -/
theorem eTower_pos (n : ℕ) : 0 < eTower n := by
  induction n with
  | zero => simp [eTower]
  | succ n _ => exact Real.exp_pos _

/-- [Section: # CatalogBuild.Shared.ETower_strictMono
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5] -/
theorem eTower_ge_pow2 (n : ℕ) (hn : 1 ≤ n) : eTower n ≥ 2^n := by
  induction n with
  | zero => omega
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le hn with h | h
    · have hm : m = 0 := by omega
      subst hm
      show Real.exp (eTower 0) ≥ 2 ^ 1
      have : eTower 0 = 1 := rfl
      rw [this]
      have := Real.add_one_le_exp (1 : ℝ)
      norm_num
      linarith
    · have hm : 1 ≤ m := by omega
      have ihm := ih hm
      calc (2:ℝ) ^ (m + 1) = 2 * 2 ^ m := by ring
        _ ≤ 2 * eTower m := by linarith
        _ ≤ Real.exp (eTower m) := two_mul_le_exp _ (le_of_lt (eTower_pos m))
        _ = eTower (m + 1) := rfl

/-- e-tower grows at least as fast as n. -/
theorem eTower_ge_n (n : ℕ) : eTower n ≥ n := by
  induction n with
  | zero => simp [eTower]
  | succ n ih =>
    simp only [eTower, Nat.cast_add, Nat.cast_one, ge_iff_le]
    linarith [Real.add_one_le_exp (eTower n)]

end