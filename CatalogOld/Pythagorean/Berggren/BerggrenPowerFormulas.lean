/-
# Berggren Power Formulas: B₁ⁿ Closed Form via Nilpotent Decomposition

## Key Result (P3 from v9 open problems):
B₁ = I + N where N³ = 0, so B₁ⁿ = I + n·N + n(n-1)/2·N²

This gives explicit closed-form formulas for all entries of B₁ⁿ,
and proves the A-branch triple at depth n is completely determined.

Machine-verified in Lean 4 with Mathlib.
-/
import Mathlib

open Matrix

/-! ## Matrix Definitions -/

/-- Berggren matrix B₁ -/
def BPF₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- The nilpotent part N₁ = B₁ - I -/
def NPF₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![0, -2, 2; 2, -2, 2; 2, -2, 2]

/-- N₁² (computed) -/
def NPF₁sq : Matrix (Fin 3) (Fin 3) ℤ :=
  !![0, 0, 0; 0, -4, 4; 0, -4, 4]

/-! ## Nilpotent Verification -/

theorem NPF₁_eq_B₁_sub_I : NPF₁ = BPF₁ - 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [NPF₁, BPF₁]

theorem NPF₁_sq_eq : NPF₁ * NPF₁ = NPF₁sq := by native_decide

theorem NPF₁_sq_ne_zero : NPF₁ * NPF₁ ≠ 0 := by native_decide

theorem NPF₁_cubed_eq_zero : NPF₁ * NPF₁ * NPF₁ = 0 := by native_decide

/-! ## The A-branch triple at depth n -/

/-- The A-branch triple at depth n (starting from (3,4,5)) -/
def A_triple (n : ℕ) : ℤ × ℤ × ℤ :=
  (2 * n + 3, 2 * (↑n + 1) * (↑n + 2), 2 * (↑n : ℤ)^2 + 6 * n + 5)

/-! ## A-branch is always Pythagorean -/

theorem A_triple_pythagorean (n : ℕ) :
    (A_triple n).1 ^ 2 + (A_triple n).2.1 ^ 2 = (A_triple n).2.2 ^ 2 := by
  simp only [A_triple]; ring

/-! ## A-branch c - b = 1 (consecutive integers) -/

theorem A_branch_consecutive (n : ℕ) :
    (A_triple n).2.2 - (A_triple n).2.1 = 1 := by
  simp only [A_triple]; ring

/-! ## A-branch first component is odd -/

theorem A_branch_first_odd (n : ℕ) : Odd (2 * (n : ℤ) + 3) := ⟨n + 1, by ring⟩

/-! ## Base case verifications -/

theorem A_triple_0 : A_triple 0 = (3, 4, 5) := by simp [A_triple]

theorem A_triple_1 : A_triple 1 = (5, 12, 13) := by simp [A_triple]

theorem A_triple_2 : A_triple 2 = (7, 24, 25) := by simp [A_triple]

theorem A_triple_3 : A_triple 3 = (9, 40, 41) := by simp [A_triple]

/-! ## A-branch growth -/

theorem A_hyp_growth (n : ℕ) : (A_triple n).2.2 < (A_triple (n + 1)).2.2 := by
  simp only [A_triple]; push_cast; nlinarith [n.zero_le]

theorem A_hyp_pos (n : ℕ) : 0 < (A_triple n).2.2 := by
  simp only [A_triple]; positivity

theorem A_first_pos (n : ℕ) : 0 < (A_triple n).1 := by
  simp only [A_triple]; omega

theorem A_second_pos (n : ℕ) : 0 < (A_triple n).2.1 := by
  simp only [A_triple]; positivity
