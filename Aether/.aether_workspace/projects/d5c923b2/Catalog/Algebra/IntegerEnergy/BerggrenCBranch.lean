import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenCBranch

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22
-/

/-- The C-branch triple at depth n (B₃ⁿ applied to (3,4,5)) -/
def C_branch (n : ℕ) : ℤ × ℤ × ℤ :=
  ((2 * ↑n + 1) * (2 * ↑n + 3), 4 * (↑n + 1), 4 * (↑n : ℤ)^2 + 8 * ↑n + 5)

/-- [Section: ## Base Case Verifications] -/
theorem C_branch_0 : C_branch 0 = (3, 4, 5) := by simp [C_branch]

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenCBranch
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22] -/
theorem C_branch_1 : C_branch 1 = (15, 8, 17) := by simp [C_branch]

theorem C_branch_2 : C_branch 2 = (35, 12, 37) := by simp [C_branch]

theorem C_branch_3 : C_branch 3 = (63, 16, 65) := by simp [C_branch]

theorem C_branch_4 : C_branch 4 = (99, 20, 101) := by simp [C_branch]

/-- [Section: ## C-Branch is Always Pythagorean] -/
theorem C_branch_pythagorean (n : ℕ) :
    (C_branch n).1 ^ 2 + (C_branch n).2.1 ^ 2 = (C_branch n).2.2 ^ 2 := by
  simp only [C_branch]; ring

/-- The hypotenuse minus the odd leg is always 2 -/
theorem C_branch_gap (n : ℕ) :
    (C_branch n).2.2 - (C_branch n).1 = 2 := by
  simp only [C_branch]; ring

/-- The first component (odd leg) is always odd -/
theorem C_branch_first_odd (n : ℕ) : Odd (C_branch n).1 := by
  simp only [C_branch]
  exact ⟨2 * (↑n : ℤ) ^2 + 4 * ↑n + 1, by ring⟩

/-- The second component (even leg) is always divisible by 4 -/
theorem C_branch_second_div4 (n : ℕ) : (4 : ℤ) ∣ (C_branch n).2.1 :=
  ⟨↑n + 1, by simp [C_branch]⟩

/-- The hypotenuse is always odd -/
theorem C_branch_hyp_odd (n : ℕ) : Odd (C_branch n).2.2 := by
  simp only [C_branch]
  exact ⟨2 * (↑n : ℤ)^2 + 4 * ↑n + 2, by ring⟩

/-- The hypotenuse is strictly increasing -/
theorem C_branch_hyp_growth (n : ℕ) :
    (C_branch n).2.2 < (C_branch (n + 1)).2.2 := by
  simp only [C_branch]; push_cast; nlinarith [n.zero_le]

/-- All components are positive -/
theorem C_branch_all_pos (n : ℕ) :
    0 < (C_branch n).1 ∧ 0 < (C_branch n).2.1 ∧ 0 < (C_branch n).2.2 := by
  refine ⟨?_, ?_, ?_⟩ <;> simp only [C_branch] <;> positivity

/-- B₃ applied to (a,b,c) -/
def applyB₃ (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (-t.1 + 2*t.2.1 + 2*t.2.2, -2*t.1 + t.2.1 + 2*t.2.2, -2*t.1 + 2*t.2.1 + 3*t.2.2)

/-- B₃ⁿ applied to (3,4,5) by iteration -/
def C_iter : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => applyB₃ (C_iter n)

/-- [Section: ## C-Branch Inductive Proof] -/
theorem C_branch_recurrence (n : ℕ) :
    applyB₃ ((C_branch n).1, (C_branch n).2.1, (C_branch n).2.2) =
    ((C_branch (n + 1)).1, (C_branch (n + 1)).2.1, (C_branch (n + 1)).2.2) := by
  simp only [C_branch, applyB₃]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> push_cast <;> ring

/-- The closed form matches the B₃ iteration for ALL n -/
theorem C_iter_eq_C_branch : ∀ n : ℕ, C_iter n = ((C_branch n).1, (C_branch n).2) := by
  intro n
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [C_iter, ih]
    exact C_branch_recurrence n

/-- A-branch definition -/
def A_branch' (n : ℕ) : ℤ × ℤ × ℤ :=
  (2 * ↑n + 3, 2 * (↑n + 1) * (↑n + 2), 2 * (↑n : ℤ)^2 + 6 * ↑n + 5)

/-- A-branch gap is 1 -/
theorem A_branch_gap' (n : ℕ) : (A_branch' n).2.2 - (A_branch' n).2.1 = 1 := by
  simp only [A_branch']; ring

/-- A-branch + C-branch: two fundamental families of PPTs -/
theorem AC_families_distinct (n : ℕ) (hn : 0 < n) :
    (A_branch' n).1 ≠ (C_branch n).1 := by
  simp only [A_branch', C_branch]
  intro h
  have h1 : (2 * (↑n : ℤ) + 3) = (2 * ↑n + 1) * (2 * ↑n + 3) := by linarith
  have h2 : 1 = 2 * (↑n : ℤ) + 1 := by nlinarith
  linarith [show (0 : ℤ) < n from Nat.cast_pos.mpr hn]

/-- The odd legs are products of consecutive odd numbers -/
theorem C_branch_odd_leg_factored (n : ℕ) :
    (C_branch n).1 = (2 * ↑n + 1) * (2 * ↑n + 3) := by
  simp [C_branch]

/-- The even legs form an arithmetic progression with common difference 4 -/
theorem C_branch_even_leg_arith (n : ℕ) :
    (C_branch (n + 1)).2.1 - (C_branch n).2.1 = 4 := by
  simp only [C_branch]; push_cast; ring

