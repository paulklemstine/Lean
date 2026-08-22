-- Repaired copy: this module was a stale, non-compiling duplicate of `Shared.EtowerStrictmono.ETower_strictMono`.
-- Its content is synchronised with that (compiling) module.
import Mathlib

/-! # CatalogBuild.Shared.ETower_strictMono

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5

Repaired: the definition `eTower` now precedes the statements about it, the
stray `end` markers are removed, and the two proofs that were left open
(`eTower_strictMono`, `eTower_ge_pow2`) are completed.  The growth step
`2 * x ≤ exp x` is isolated as `two_mul_le_exp`, proved by squaring the
elementary bound `1 + x/2 ≤ exp (x/2)`.
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

/-- The exponential doubles: `2 * x ≤ exp x` for `x ≥ 0`.  Squaring
`1 + x / 2 ≤ exp (x / 2)` gives `1 + x + x ^ 2 / 4 ≤ exp x`, and
`x ^ 2 / 4 - x + 1 = (x / 2 - 1) ^ 2 ≥ 0`. -/
theorem two_mul_le_exp {x : ℝ} (hx : 0 ≤ x) : 2 * x ≤ Real.exp x := by
  have h : x / 2 + 1 ≤ Real.exp (x / 2) := Real.add_one_le_exp _
  have hnn : (0 : ℝ) ≤ x / 2 + 1 := by linarith
  have hsq : (x / 2 + 1) ^ 2 ≤ Real.exp (x / 2) ^ 2 := by
    nlinarith [Real.exp_pos (x / 2)]
  have hexp : Real.exp (x / 2) ^ 2 = Real.exp x := by
    rw [sq, ← Real.exp_add]; ring_nf
  nlinarith [sq_nonneg (x / 2 - 1)]

/-- [Section: # CatalogBuild.Shared.ETower_strictMono
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 5] -/
theorem eTower_strictMono : StrictMono eTower := by
  refine strictMono_nat_of_lt_succ fun n => ?_
  have h : eTower n + 1 ≤ Real.exp (eTower n) := Real.add_one_le_exp _
  show eTower n < Real.exp (eTower n)
  linarith

/-- [Section: # CatalogBuild.Shared.ETower_strictMono
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 5] -/
theorem eTower_ge_pow2 (n : ℕ) (hn : 1 ≤ n) : eTower n ≥ 2 ^ n := by
  induction n with
  | zero => omega
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le hn with h | h
    · -- `n + 1 = 1`
      have hn0 : n = 0 := by omega
      subst hn0
      have h1 : (2 : ℝ) ≤ Real.exp 1 := by
        have := Real.add_one_le_exp (1 : ℝ)
        linarith
      simpa [eTower] using h1
    · have hn1 : 1 ≤ n := by omega
      have ihn : eTower n ≥ 2 ^ n := ih hn1
      have hpow : (0 : ℝ) ≤ 2 ^ n := by positivity
      have hstep : 2 * (2 : ℝ) ^ n ≤ Real.exp (2 ^ n) := two_mul_le_exp hpow
      have hmono : Real.exp ((2 : ℝ) ^ n) ≤ Real.exp (eTower n) :=
        Real.exp_le_exp.mpr ihn
      have : (2 : ℝ) ^ (n + 1) = 2 * 2 ^ n := by ring
      show eTower (n + 1) ≥ 2 ^ (n + 1)
      simp only [eTower, this]
      linarith

/-- e-tower grows at least as fast as n. -/
theorem eTower_ge_n (n : ℕ) : eTower n ≥ n := by
  induction n with
  | zero => simp [eTower]
  | succ n ih =>
    have h : eTower n + 1 ≤ Real.exp (eTower n) := Real.add_one_le_exp _
    have : eTower (n + 1) = Real.exp (eTower n) := rfl
    rw [ge_iff_le, this]
    push_cast
    linarith

end