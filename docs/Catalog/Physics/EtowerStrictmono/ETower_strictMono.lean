import Mathlib

/-! # CatalogBuild.Shared.ETower_strictMono

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5

Repaired: the definition of `eTower` was missing from the generated file (it
appeared after its uses) and the file carried unbalanced `end` markers.
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

/-- [Section: # CatalogBuild.Shared.ETower_strictMono
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 5] -/
theorem eTower_strictMono : StrictMono eTower := by
  refine strictMono_nat_of_lt_succ ?_
  intro n
  have h := Real.add_one_le_exp (eTower n)
  show eTower n < Real.exp (eTower n)
  linarith

/-- Auxiliary quadratic bound: `2 * t ≤ exp t` for `0 ≤ t`. -/
theorem two_mul_le_exp_of_nonneg {t : ℝ} (ht : 0 ≤ t) : 2 * t ≤ Real.exp t := by
  have hsplit : Real.exp t = Real.exp (t / 2) * Real.exp (t / 2) := by
    rw [← Real.exp_add]; ring_nf
  have h := Real.add_one_le_exp (t / 2)
  have hpos : (0:ℝ) < t / 2 + 1 := by linarith
  nlinarith [sq_nonneg (t - 2)]

/-- [Section: # CatalogBuild.Shared.ETower_strictMono
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5] -/
theorem eTower_ge_pow2 (n : ℕ) (hn : 1 ≤ n) : eTower n ≥ 2 ^ n := by
  induction n, hn using Nat.le_induction with
  | base =>
    have h := Real.add_one_le_exp (1 : ℝ)
    simpa [eTower] using (by linarith : (2:ℝ) ^ 1 ≤ Real.exp 1)
  | succ n hn ih =>
    have hp : (0:ℝ) ≤ 2 ^ n := by positivity
    have h2 : 2 * eTower n ≤ Real.exp (eTower n) :=
      two_mul_le_exp_of_nonneg (le_of_lt (eTower_pos n))
    have : (2:ℝ) ^ (n + 1) = 2 * 2 ^ n := by ring
    show (2:ℝ) ^ (n + 1) ≤ Real.exp (eTower n)
    linarith

/-- e-tower grows at least as fast as n. -/
theorem eTower_ge_n (n : ℕ) : eTower n ≥ n := by
  induction n with
  | zero => simp [eTower]
  | succ n ih =>
    have h := Real.add_one_le_exp (eTower n)
    have he : eTower (n + 1) = Real.exp (eTower n) := rfl
    rw [ge_iff_le, he]
    push_cast
    linarith

end