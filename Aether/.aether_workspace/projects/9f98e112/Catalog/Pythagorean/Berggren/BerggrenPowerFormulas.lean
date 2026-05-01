import Mathlib

/-! # CatalogBuild.Speculative.BerggrenPowerFormulas

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 27
-/

/-- Berggren matrix B₁ -/
def B1 : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- The nilpotent part N = B₁ - I -/
def N1 : Matrix (Fin 3) (Fin 3) ℤ := !![0, -2, 2; 2, -2, 2; 2, -2, 2]

/-- N² = (B₁ - I)² -/
def N1sq : Matrix (Fin 3) (Fin 3) ℤ := !![0, 0, 0; 0, -4, 4; 0, -4, 4]

/-- [Section: # CatalogBuild.Speculative.BerggrenPowerFormulas
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 27] -/
theorem N1_eq : N1 = B1 - 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [N1, B1]

/-- [Section: # CatalogBuild.Speculative.BerggrenPowerFormulas
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 27] -/
theorem N1sq_eq : N1sq = N1 * N1 := by native_decide

theorem N1_cubed_zero : N1 * N1 * N1 = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide

theorem N1sq_ne_zero : N1 * N1 ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide

/-- B₁ⁿ computed recursively -/
def B1pow : ℕ → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => 1
  | n + 1 => B1 * B1pow n

/-- The A-branch triple at depth n -/
def A_triple (n : ℕ) : ℤ × ℤ × ℤ :=
  (2 * n + 3, 2 * (n + 1) * (n + 2), 2 * n^2 + 6 * n + 5)

theorem B1pow_0 : B1pow 0 = 1 := rfl

theorem B1pow_2 : B1pow 2 = !![1, (-4 : ℤ), 4; 4, -7, 8; 4, -8, 9] := by native_decide

theorem B1pow_3 : B1pow 3 = !![1, (-6 : ℤ), 6; 6, -17, 18; 6, -18, 19] := by native_decide

theorem B1pow_4 : B1pow 4 = !![1, (-8 : ℤ), 8; 8, -31, 32; 8, -32, 33] := by native_decide

def B1_applied (n : ℕ) : ℤ × ℤ × ℤ :=
  let M := B1pow n
  let v := M * !![(3 : ℤ); 4; 5]
  (v 0 0, v 1 0, v 2 0)

theorem B1_applied_0 : B1_applied 0 = (3, 4, 5) := by native_decide

theorem B1_applied_1 : B1_applied 1 = (5, 12, 13) := by native_decide

theorem B1_applied_2 : B1_applied 2 = (7, 24, 25) := by native_decide

theorem B1_applied_3 : B1_applied 3 = (9, 40, 41) := by native_decide

theorem B1_applied_4 : B1_applied 4 = (11, 60, 61) := by native_decide

theorem B1_applied_5 : B1_applied 5 = (13, 84, 85) := by native_decide

theorem A_triple_0 : A_triple 0 = (3, 4, 5) := by simp [A_triple]

/-- The A-branch formula always produces Pythagorean triples -/
theorem A_branch_pythagorean (n : ℕ) :
    (2 * (n : ℤ) + 3)^2 + (2 * (↑n + 1) * (↑n + 2))^2 = (2 * (n : ℤ)^2 + 6 * n + 5)^2 := by
  ring

theorem A_branch_consecutive (n : ℕ) :
    (2 * (n : ℤ)^2 + 6 * n + 5) - 2 * (↑n + 1) * (↑n + 2) = 1 := by
  ring

theorem A_branch_first_odd (n : ℕ) : Odd (2 * n + 3) := ⟨n + 1, by omega⟩

theorem A_triple_is_pythagorean (n : ℕ) :
    (A_triple n).1 ^ 2 + (A_triple n).2.1 ^ 2 = (A_triple n).2.2 ^ 2 := by
  simp only [A_triple]; ring

theorem B1pow_succ (n : ℕ) : B1pow (n + 1) = B1 * B1pow n := rfl

theorem A_branch_gcd_structure (n : ℕ) :
    ∃ k : ℕ, (2 * (n : ℤ) + 3) = 2 * (k : ℤ) + 1 ∧
    ∃ m : ℤ, 2 * (↑n + 1) * (↑n + 2) = 2 * m :=
  ⟨n + 1, by push_cast; ring, (↑n + 1) * (↑n + 2), by ring⟩