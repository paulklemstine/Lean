import Mathlib

/-! # Counting a syntactic proof space

Over an alphabet of size `k`, the number of words of length **at most** `n` is

`S k n = ∑_{i ≤ n} kⁱ`.

This module records the exact count, its closed form, and the two-sided exponential
bounds `kⁿ ≤ S k n ≤ k^(n+1)` (for `k ≥ 2`) that pin down the entropy of the space.
-/

namespace ProofSpace

/-- The number of words of length at most `n` over an alphabet of size `k`. -/
def S (k n : ℕ) : ℕ := ∑ i ∈ Finset.range (n + 1), k ^ i

@[simp] theorem S_zero (k : ℕ) : S k 0 = 1 := by simp [S]

theorem S_succ (k n : ℕ) : S k (n + 1) = S k n + k ^ (n + 1) := by
  simp [S, Finset.sum_range_succ]

/-- **Closed form of the count** (in a division-free shape valid over `ℕ`):
`(k − 1)·S k n + 1 = k^(n+1)`. -/
theorem S_closed_form (k n : ℕ) (hk : 1 ≤ k) : (k - 1) * S k n + 1 = k ^ (n + 1) := by
  induction n with
  | zero => simp [S]; omega
  | succ n ih =>
    rw [S_succ, Nat.mul_add, add_assoc, add_comm ((k - 1) * k ^ (n + 1)) 1, ← add_assoc, ih]
    have : k ^ (n + 1) + (k - 1) * k ^ (n + 1) = k * k ^ (n + 1) := by
      cases k with
      | zero => omega
      | succ m => simp; ring
    rw [this, pow_succ]
    ring

/-- The count dominates the number of words of length exactly `n`. -/
theorem pow_le_S (k n : ℕ) : k ^ n ≤ S k n :=
  Finset.single_le_sum (f := fun i => k ^ i) (fun _ _ => Nat.zero_le _)
    (Finset.self_mem_range_succ n)

/-- For an alphabet with at least two letters the count is below `k^(n+1)`. -/
theorem S_le_pow (k n : ℕ) (hk : 2 ≤ k) : S k n ≤ k ^ (n + 1) := by
  induction n with
  | zero => simpa [S] using by omega
  | succ n ih =>
    rw [S_succ]
    calc S k n + k ^ (n + 1) ≤ k ^ (n + 1) + k ^ (n + 1) := by omega
      _ = 2 * k ^ (n + 1) := by ring
      _ ≤ k * k ^ (n + 1) := Nat.mul_le_mul_right _ hk
      _ = k ^ (n + 1 + 1) := by rw [pow_succ]; ring

theorem S_pos (k n : ℕ) : 0 < S k n := by
  have := pow_le_S k n
  calc 0 < 1 := one_pos
    _ ≤ S k 0 := by simp
    _ ≤ S k n := Finset.sum_le_sum_of_subset (by
        intro i hi
        simp only [Finset.mem_range] at hi ⊢
        omega)

theorem S_mono (k : ℕ) : Monotone (S k) := by
  intro m n hmn
  exact Finset.sum_le_sum_of_subset (by
    intro i hi
    simp only [Finset.mem_range] at hi ⊢
    omega)

end ProofSpace