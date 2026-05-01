/-! # CatalogBuild.Speculative.EllipticDivisibility

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 6
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.EllipticDivisibility
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 7] -/
theorem pisano_period_2 : fib 3 % 2 = 0 ∧ fib 4 % 2 = 1 := by decide


/-- [Section: # CatalogBuild.Speculative.EllipticDivisibility
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 7] -/
theorem pisano_period_3 : fib 8 % 3 = 0 ∧ fib 9 % 3 = 1 := by native_decide


/-- [Section: # CatalogBuild.Speculative.EllipticDivisibility
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 7] -/
theorem fib_5_div_5 : fib 5 % 5 = 0 := by native_decide


theorem ecm_success_condition (ord k : ℕ) :
    ord ∣ k ↔ k % ord = 0 := Nat.dvd_iff_mod_eq_zero


structure EDS where
  val : ℕ → ℤ
  zero_eq : val 0 = 0
  one_eq : val 1 = 1
  divides : ∀ m n : ℕ, 1 ≤ m → 1 ≤ n → val m ∣ val (m * n)


theorem eds_divisibility (E : EDS) {p k : ℕ} (hk : 1 ≤ k)
    (hpk : (p : ℤ) ∣ E.val k) (n : ℕ) (hn : 1 ≤ n) :
    (p : ℤ) ∣ E.val (k * n) :=
  dvd_trans hpk (E.divides k n hk hn)

