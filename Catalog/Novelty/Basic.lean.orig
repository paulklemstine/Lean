import Mathlib

/-!
# Fermat Near-Misses

Elementary existence, optimality, counting, and quantitative error bounds for
`|a^n + b^n - c^n|`.
-/

namespace FermatNearMisses

/-- The nonnegative integral error in a Fermat-type equation. -/
def error (a b c n : ℕ) : ℕ :=
  ((a : ℤ) ^ n + (b : ℤ) ^ n - (c : ℤ) ^ n).natAbs

/-- A triple is a near-miss at tolerance `B` when its integral error is at most `B`. -/
def IsNearMiss (B a b c n : ℕ) : Prop := error a b c n ≤ B

/-- In the cancellation family `(t,s,t)`, the Fermat error is exactly `s^n`. -/
theorem cancellation_family_exact_error (t s n : ℕ) : error t s t n = s ^ n := by
  unfold error
  norm_num

/-- Every exponent has an unbounded family of integral near-misses with error one. -/
theorem adjacent_family_exact_error (t n : ℕ) : error t 1 t n = 1 := by
  simpa using cancellation_family_exact_error t 1 n

/-- Every exponent admits a positive error-one triple whose two scalable entries
exceed any prescribed cutoff. -/
theorem arbitrarily_large_optimal_near_misses (n cutoff : ℕ) :
    ∃ a b c : ℕ, cutoff < a ∧ 0 < b ∧ cutoff < c ∧ error a b c n = 1 := by
  use cutoff + 1, 1, cutoff + 1
  exact ⟨Nat.lt_succ_self _, by decide, Nat.lt_succ_self _,
    adjacent_family_exact_error _ _⟩

/-- The distinct positive triple `(6,8,9)` is an optimal cubic near-miss:
`6^3 + 8^3 = 9^3 - 1`. -/
theorem optimal_cubic_near_miss :
    error 6 8 9 3 = 1 ∧ 0 < 6 ∧ 6 < 8 ∧ 8 < 9 := by
  norm_num [error]

/-- On the diagonal `(t,t,t)`, the absolute Fermat error is exactly `t^n`. -/
theorem diagonal_error (t n : ℕ) : error t t t n = t ^ n := by
  unfold error
  norm_num

/-- The diagonal error satisfies an exact quadratic-scale normalization identity. -/
theorem diagonal_relative_error_identity (t n : ℕ) :
    error t t t n * t ^ n = t ^ (2 * n) := by
  rw [diagonal_error, pow_mul']
  ring

/-- At base two, the quadratic-scale normalized diagonal error decays exponentially,
expressed here without division. -/
theorem binary_diagonal_exponential_decay (n : ℕ) :
    error 2 2 2 n * 2 ^ n = 2 ^ (2 * n) := by
  convert diagonal_relative_error_identity 2 n using 1

/-- For fixed exponent, there are exactly `N` members of the error-one
cancellation family indexed by `t < N`. -/
theorem count_exact_near_miss_family (n N : ℕ) :
    ((Finset.range N).filter fun t => error t 1 t n = 1).card = N := by
  rw [Finset.filter_true_of_mem]
  · exact Finset.card_range N
  · exact fun t _ => adjacent_family_exact_error t n

/-- Any nonzero integral Fermat error is at least one, so the cancellation family
attains the least possible positive error. -/
theorem one_le_error_of_ne_zero {a b c n : ℕ} (h : error a b c n ≠ 0) :
    1 ≤ error a b c n := by
  exact Nat.pos_of_ne_zero h

/-- Changing a nonnegative integral base from `b` to `a` changes its `n`th power
by at most `n |a-b| max(a,b)^(n-1)`. -/
theorem power_gap_bound (a b n : ℕ) :
    |(a : ℤ) ^ n - (b : ℤ) ^ n| ≤
      |(a : ℤ) - (b : ℤ)| * (n : ℤ) * (max a b : ℤ) ^ (n - 1) := by
  have h := abs_pow_sub_pow_le (a : ℤ) (b : ℤ) n
  convert h using 1; norm_num [abs_of_nonneg]

/-- If the sum of powers lies below `c^n`, adding the error produces an exact
additive equation. This is the elementary bridge from near-misses to abc-type
triples. -/
theorem deficit_identity {a b c n : ℕ} (h : a ^ n + b ^ n ≤ c ^ n) :
    a ^ n + b ^ n + error a b c n = c ^ n := by
  unfold error;
  grind

/-- The genuinely ordered family `(t,1,t+1)` has error at most the first-order
power-gap bound plus one. Thus for fixed exponent its error is `O(t^(n-1))`,
one degree smaller than the scale of the entries' `n`th powers. -/
theorem ordered_adjacent_error_bound (t n : ℕ) :
    error t 1 (t + 1) n ≤ n * (t + 1) ^ (n - 1) + 1 := by
  set x : ℤ := (t + 1 : ℤ) ^ n - t ^ n
  have hx_nonneg : x ≥ 0 := by
    exact sub_nonneg_of_le <| mod_cast Nat.pow_le_pow_left (Nat.le_succ _) _
  have h_abs : Int.natAbs (1 - x) ≤ n * (t + 1) ^ (n - 1) + 1 := by
    have h_power_gap : Int.natAbs x ≤ n * (t + 1) ^ (n - 1) := by
      have h := power_gap_bound (t + 1) t n
      simp_all +decide [abs_of_nonneg]
      linarith [abs_of_nonneg hx_nonneg]
    omega
  convert h_abs using 1
  norm_num [error]
  ring_nf!

/-- Exact small cases for the ordered family, recording the numerical evidence
behind its polynomial growth pattern. -/
theorem ordered_small_cases :
    error 1 1 2 2 = 2 ∧ error 2 1 3 2 = 4 ∧ error 3 1 4 2 = 6 ∧
    error 1 1 2 3 = 6 ∧ error 2 1 3 3 = 18 ∧ error 3 1 4 3 = 36 ∧
    error 1 1 2 4 = 14 ∧ error 2 1 3 4 = 64 ∧ error 3 1 4 4 = 174 := by
  norm_num [error]

/-- The ordered near-miss family is nondegenerate: both smaller entries are
positive and strictly below the largest whenever `t` is positive. -/
theorem ordered_adjacent_nondegenerate {t : ℕ} (ht : 0 < t) :
    0 < t ∧ 0 < 1 ∧ t < t + 1 ∧ 1 < t + 1 := by
  omega

end FermatNearMisses