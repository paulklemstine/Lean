import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenABranchForAll

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 9
-/

/-- B₁ applied to a triple -/
def applyB₁ (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 - 2*t.2.1 + 2*t.2.2, 2*t.1 - t.2.1 + 2*t.2.2, 2*t.1 - 2*t.2.1 + 3*t.2.2)

/-- B₁ⁿ · (3,4,5) by iteration -/
def A_iter : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => applyB₁ (A_iter n)

/-- The A-branch closed form -/
def A_closed (n : ℕ) : ℤ × ℤ × ℤ :=
  (2 * ↑n + 3, 2 * (↑n + 1) * (↑n + 2), 2 * (↑n : ℤ)^2 + 6 * ↑n + 5)

/-- B₁ applied to the closed form gives the next closed form -/
theorem A_closed_recurrence (n : ℕ) :
    applyB₁ ((A_closed n).1, (A_closed n).2.1, (A_closed n).2.2) =
    ((A_closed (n + 1)).1, (A_closed (n + 1)).2.1, (A_closed (n + 1)).2.2) := by
  simp only [A_closed, applyB₁]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> push_cast <;> ring

/-- **The closed form matches iteration for ALL n** -/
theorem A_iter_eq_A_closed : ∀ n : ℕ, A_iter n = ((A_closed n).1, (A_closed n).2) := by
  intro n
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [A_iter, ih]
    exact A_closed_recurrence n

/-- [Section: ## A-Branch Gap: c - b = 1 for all n] -/
theorem A_branch_gap_all (n : ℕ) : (A_closed n).2.2 - (A_closed n).2.1 = 1 := by
  simp only [A_closed]; ring

/-- [Section: ## A-Branch GCD: always coprime] -/
theorem A_branch_coprime (n : ℕ) :
    Int.gcd (A_closed n).1 (A_closed n).2.1 = 1 := by
  unfold A_closed; norm_num;
  norm_num [ Int.gcd, Int.natAbs_mul, Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
  norm_cast ; norm_num [ ( by ring : 2 * n + 3 = n + 1 + ( n + 2 ) ) ];
  norm_num [ ( by ring : n + 2 = n + 1 + 1 ) ]

/-- Verification for small values -/
theorem A_branch_coprime_vals :
    Int.gcd (A_closed 0).1 (A_closed 0).2.1 = 1 ∧
    Int.gcd (A_closed 1).1 (A_closed 1).2.1 = 1 ∧
    Int.gcd (A_closed 2).1 (A_closed 2).2.1 = 1 ∧
    Int.gcd (A_closed 3).1 (A_closed 3).2.1 = 1 ∧
    Int.gcd (A_closed 4).1 (A_closed 4).2.1 = 1 := by native_decide

/-- [Section: ## A-Branch Pythagorean] -/
theorem A_closed_pythagorean (n : ℕ) :
    (A_closed n).1 ^ 2 + (A_closed n).2.1 ^ 2 = (A_closed n).2.2 ^ 2 := by
  simp only [A_closed]; ring