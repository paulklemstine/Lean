/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Eulerian numbers and the row-sum identity

The *Eulerian number* `A(n, k)` counts the permutations of `{1, …, n}` with exactly `k`
ascents.  Here we define a concrete recursive version `eul n k` and prove the classical
**row-sum identity**: for `n ≥ 1`,

`∑_{k = 0}^{n-1} eul n k = n!`.

The definition follows the standard triangular recurrence
`A(n+1, k+1) = (k+2) · A(n, k+1) + (n - k) · A(n, k)`,
with base row `A(0, 0) = 1` and left column `A(n, 0) = 1`.
-/

namespace Catalog.EulerianNumbers

open Finset

/-- The Eulerian numbers, defined by the triangular recurrence. -/
def eul : ℕ → ℕ → ℕ
  | 0, 0 => 1
  | 0, (_ + 1) => 0
  | (_ + 1), 0 => 1
  | (n + 1), (k + 1) => (k + 2) * eul n (k + 1) + (n - k) * eul n k

@[simp] lemma eul_zero_zero : eul 0 0 = 1 := rfl

@[simp] lemma eul_zero_succ (k : ℕ) : eul 0 (k + 1) = 0 := rfl

@[simp] lemma eul_succ_zero (n : ℕ) : eul (n + 1) 0 = 1 := rfl

lemma eul_succ_succ (n k : ℕ) :
    eul (n + 1) (k + 1) = (k + 2) * eul n (k + 1) + (n - k) * eul n k := rfl

/-- `eul n 0 = 1` for every `n`. -/
@[simp] lemma eul_zero (n : ℕ) : eul n 0 = 1 := by
  cases n <;> rfl

/-- Above the diagonal the Eulerian numbers vanish. -/
lemma eul_eq_zero_of_lt : ∀ n k, n < k → eul n k = 0 := by
  intro n k; induction' n with n ih generalizing k; induction' k with k ih <;> simp_all +arith +decide;
  rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ eul_succ_succ ];
  grind

/-- On the diagonal (for a positive row) the Eulerian number vanishes. -/
lemma eul_diag_succ (n : ℕ) : eul (n + 1) (n + 1) = 0 := by
  rw [ eul_succ_succ ];
  simp +arith +decide [ eul_eq_zero_of_lt ]

/-- **Row-sum identity**: for `n ≥ 1`, the `n`-th row sums to `n!`. -/
theorem eul_row_sum (n : ℕ) (hn : 1 ≤ n) :
    ∑ k ∈ Finset.range n, eul n k = Nat.factorial n := by
  induction' hn with n hn ih;
  · rfl;
  · -- Apply `Finset.sum_range_succ'` to split the sum into two parts.
    have h_split : ∑ k ∈ Finset.range (Nat.succ n), eul (Nat.succ n) k = (∑ k ∈ Finset.range n, eul (Nat.succ n) (k + 1)) + eul (Nat.succ n) 0 := by
      rw [ Finset.sum_range_succ', add_comm ];
    -- We need to show that (∑ k ∈ range n, (k+2) * eul n (k+1)) + 1 = ∑ k ∈ range n, (k+1) * eul n k.
    have h_key : (∑ k ∈ Finset.range n, (k + 2) * eul n (k + 1)) + 1 = ∑ k ∈ Finset.range n, (k + 1) * eul n k := by
      have := Finset.sum_range_succ' ( fun k => ( k + 1 ) * eul n k ) n;
      simp_all +decide [ Finset.sum_range_succ ];
      rcases n with ( _ | _ | n ) <;> simp_all +decide [ eul_diag_succ ];
    -- Substitute the recurrence relation into the split sum.
    have h_subst : ∑ k ∈ Finset.range n, eul (Nat.succ n) (k + 1) = ∑ k ∈ Finset.range n, ((k + 2) * eul n (k + 1) + (n - k) * eul n k) := by
      exact Finset.sum_congr rfl fun x hx => eul_succ_succ _ _;
    -- Combine the sums and simplify.
    have h_combine : ∑ k ∈ Finset.range n, ((k + 2) * eul n (k + 1) + (n - k) * eul n k) + 1 = ∑ k ∈ Finset.range n, ((k + 1) + (n - k)) * eul n k := by
      simp_all +decide [ add_mul, Finset.sum_add_distrib ];
      linarith;
    -- Simplify the expression inside the sum.
    have h_simplify : ∑ k ∈ Finset.range n, ((k + 1) + (n - k)) * eul n k = ∑ k ∈ Finset.range n, (n + 1) * eul n k := by
      exact Finset.sum_congr rfl fun x hx => by rw [ show x + 1 + ( n - x ) = n + 1 by linarith [ Nat.sub_add_cancel ( show x ≤ n from Finset.mem_range_le hx ) ] ] ;
    simp_all +decide [ ← Finset.mul_sum _ _ _, Nat.factorial_succ ]

end Catalog.EulerianNumbers