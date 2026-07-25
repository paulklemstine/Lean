import Mathlib

/-! # CatalogBuild.Logic.DynamicalSystems

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13
-/

/-- [Section: # CatalogBuild.Logic.DynamicalSystems
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13] -/
theorem involution_period (f : ℤ → ℤ) (hf : ∀ x, f (f x) = x) (x : ℤ) :
    f (f x) = x := hf x

/-- [Section: # CatalogBuild.Logic.DynamicalSystems
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13] -/
theorem neg_involution' : ∀ x : ℤ, -(-x) = x := neg_neg

theorem zero_fixed_point_div2 : (0 : ℤ) / 2 = 0 := by norm_num

def collatz_step (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

theorem collatz_reaches_1_from_6 : collatz_step^[8] 6 = 1 := by native_decide

theorem collatz_reaches_1_from_7 : collatz_step^[16] 7 = 1 := by native_decide

theorem collatz_reaches_1_from_27 : collatz_step^[111] 27 = 1 := by native_decide

theorem logistic_fixed_point_r2 : (2 : ℚ) * (1/2) * (1 - 1/2) = 1/2 := by norm_num

theorem logistic_fixed_point_r3 : (3 : ℚ) * (2/3) * (1 - 2/3) = 2/3 := by norm_num

def rule110 (p q r : Bool) : Bool :=
  match p, q, r with
  | true, true, true => false
  | true, true, false => true
  | true, false, true => true
  | true, false, false => false
  | false, true, true => true
  | false, true, false => true
  | false, false, true => true
  | false, false, false => false

theorem rule110_check : (rule110 true true false = true) ∧
    (rule110 false false false = false) := by decide

theorem tent_period2 : ((2 : ℚ) * (2/5) = 4/5) ∧ ((2 : ℚ) * (1 - 4/5) = 2/5) := by
  constructor <;> norm_num

theorem berggren_M1_fixed_eigenvalue' : (2 - 1 : ℤ) * (0 + 1) - 1 * 1 = 0 := by ring