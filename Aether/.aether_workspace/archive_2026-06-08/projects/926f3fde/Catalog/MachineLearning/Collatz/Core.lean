import Mathlib

/-!
# Collatz Dynamics — Core Definitions and Basic Lemmas

This file establishes the foundational definitions for the Collatz conjecture:
the standard step function, the notion of reaching 1, and basic properties
relating parity to the step function.
-/

namespace Collatz

/-- The standard Collatz step: divide by 2 if even, apply 3n+1 if odd. -/
def collatzStep (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

/-- A natural number `n` reaches 1 under iterated Collatz steps. -/
def reachesOne (n : ℕ) : Prop :=
  ∃ k : ℕ, (collatzStep^[k]) n = 1

/-- 1 reaches 1 in zero steps. -/
theorem reachesOne_one : reachesOne 1 := ⟨0, rfl⟩

/-- If `collatzStep n` reaches 1, then `n` reaches 1. -/
theorem reachesOne_of_step {n : ℕ} (h : reachesOne (collatzStep n)) : reachesOne n := by
  obtain ⟨k, hk⟩ := h
  exact ⟨k + 1, by simp [Function.iterate_succ_apply]; exact hk⟩

/-- If some iterate of `n` reaches 1, then `n` reaches 1. -/
theorem reachesOne_of_iterate {n : ℕ} {j : ℕ} (h : reachesOne ((collatzStep^[j]) n)) :
    reachesOne n := by
  obtain ⟨k, hk⟩ := h
  exact ⟨k + j, by rw [Function.iterate_add_apply]; exact hk⟩

/-- Collatz step on an even number. -/
theorem collatzStep_even {n : ℕ} (h : n % 2 = 0) : collatzStep n = n / 2 := by
  simp [collatzStep, h]

/-- Collatz step on an odd number. -/
theorem collatzStep_odd {n : ℕ} (h : n % 2 = 1) : collatzStep n = 3 * n + 1 := by
  simp [collatzStep, h]

/-- Collatz step of 0 is 0. -/
@[simp] theorem collatzStep_zero : collatzStep 0 = 0 := by
  simp [collatzStep]

/-- Collatz step of 1 is 4. -/
theorem collatzStep_one : collatzStep 1 = 4 := by
  simp [collatzStep]

/-- Collatz step of 2 is 1. -/
theorem collatzStep_two : collatzStep 2 = 1 := by
  simp [collatzStep]

/-- 2 reaches 1. -/
theorem reachesOne_two : reachesOne 2 :=
  ⟨1, by simp [collatzStep_two]⟩

/-- If `n` eventually reaches a value that reaches 1, then `n` reaches 1. -/
theorem reachesOne_trans {n m : ℕ} {k : ℕ}
    (hstep : (collatzStep^[k]) n = m) (hm : reachesOne m) : reachesOne n := by
  subst hstep
  exact reachesOne_of_iterate hm

/-- 3*n+1 is always even when n is odd. -/
theorem three_mul_add_one_even {n : ℕ} (h : n % 2 = 1) : (3 * n + 1) % 2 = 0 := by
  omega

end Collatz