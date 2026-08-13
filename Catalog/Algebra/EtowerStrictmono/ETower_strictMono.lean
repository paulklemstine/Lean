import Mathlib

/-! # CatalogBuild.Shared.ETower_strictMono

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5

Repaired: `eTower` moved before its uses, the two stray `end`s removed, and the
`exact?` placeholder inside `eTower_ge_pow2` replaced by a genuine proof (via
the elementary bound `2x ≤ exp x`).
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

theorem eTower_strictMono : StrictMono eTower := by
  refine strictMono_nat_of_lt_succ ?_
  intro n
  have := Real.add_one_le_exp (eTower n)
  simp only [eTower]
  linarith

/-- e-tower grows at least as fast as n. -/
theorem eTower_ge_n (n : ℕ) : eTower n ≥ n := by
  induction n with
  | zero => simp [eTower]
  | succ n ih =>
    have := Real.add_one_le_exp (eTower n)
    simp only [eTower, Nat.cast_succ]
    linarith

/-- The elementary bound `2x ≤ exp x`, valid for every real `x`. -/
private lemma two_mul_le_exp (x : ℝ) : 2 * x ≤ Real.exp x := by
  have h : Real.exp x = Real.exp (x / 2) * Real.exp (x / 2) := by
    rw [← Real.exp_add]; ring_nf
  have h1 : x / 2 + 1 ≤ Real.exp (x / 2) := Real.add_one_le_exp _
  have h2 : (0:ℝ) < Real.exp (x / 2) := Real.exp_pos _
  nlinarith [sq_nonneg (x / 2 - 1), sq_nonneg (Real.exp (x / 2) - (x / 2 + 1))]

theorem eTower_ge_pow2 (n : ℕ) (hn : 1 ≤ n) : eTower n ≥ 2 ^ n := by
  induction n with
  | zero => omega
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le hn with h | h
    · have hn0 : n = 0 := by omega
      subst hn0
      have := Real.add_one_le_exp (1 : ℝ)
      simp [eTower]
      linarith
    · have hn' : 1 ≤ n := by omega
      have ihn := ih hn'
      have h1 : (2 : ℝ) * 2 ^ n ≤ Real.exp (2 ^ n) := two_mul_le_exp _
      have h2 : Real.exp ((2 : ℝ) ^ n) ≤ Real.exp (eTower n) := Real.exp_le_exp.mpr ihn
      simp only [eTower, pow_succ]
      linarith

end