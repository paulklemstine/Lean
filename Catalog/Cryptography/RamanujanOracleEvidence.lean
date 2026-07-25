import Cryptography.RamanujanOracle

/-! Kernel-checked small cases supporting `ComputationalEvidence.md`. -/

open RamanujanOracle

example : Fintype.card (Fin 0 → Verdict) = 1 := by
  simp

example : Fintype.card (Fin 1 → Verdict) = 3 := by
  simpa using number_of_finite_oracles 1

example : Fintype.card (Fin 2 → Verdict) = 9 := by
  simpa using number_of_finite_oracles 2

example : Fintype.card (Fin 3 → Verdict) = 27 := by
  simpa using number_of_finite_oracles 3

example : Fintype.card (Fin 4 → Verdict) = 81 := by
  simpa using number_of_finite_oracles 4

example : Fintype.card (Fin 5 → Verdict) = 243 := by
  simpa using number_of_finite_oracles 5

example : Fintype.card (Fin 5 → Bool) = 32 := by
  simp

/-- On 20 statements, the integer definition of 95% means at least 19 correct. -/
theorem accurate95_twenty_threshold (k : ℕ) :
    19 * 20 ≤ 20 * k ↔ 19 ≤ k := by
  omega

/-- On 100 statements, the integer definition means at least 95 correct. -/
theorem accurate95_hundred_threshold (k : ℕ) :
    19 * 100 ≤ 20 * k ↔ 95 ≤ k := by
  omega