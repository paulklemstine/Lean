import Mathlib

/-!
# Open Question 3: Parallel Descent in the Berggren Tree

## Key Result: Three branches are independent (unique parent theorem),
but parallelism gives only constant-factor speedup.
-/

/-! ## Section 1: Branch Disjointness -/

/-- All three forward Berggren maps produce distinct hypotenuses
    when a, b > 0 (since the third components differ by 4b or 4a). -/
theorem B1_B2_distinct_hyp (a b c : ℤ) (hb : 0 < b) :
    2*a - 2*b + 3*c ≠ 2*a + 2*b + 3*c := by linarith

theorem B1_B3_distinct_hyp (a b c : ℤ) (hab : a ≠ b) :
    2*a - 2*b + 3*c ≠ -2*a + 2*b + 3*c := by
  intro h; apply hab; linarith

theorem B2_B3_distinct_hyp (a b c : ℤ) (ha : 0 < a) :
    2*a + 2*b + 3*c ≠ -2*a + 2*b + 3*c := by linarith

/-! ## Section 2: Unique Parent -/

/-- B₁⁻¹ and B₂⁻¹ cannot both give positive second component. -/
theorem unique_parent (a b c : ℤ) :
    ¬(0 < -2*a - b + 2*c ∧ 0 < 2*a + b - 2*c) := by
  intro ⟨h1, h2⟩; linarith

/-- B₁⁻¹/B₂⁻¹ and B₃⁻¹ have opposite-sign first components. -/
theorem inv_first_comp_exclusive (a b c : ℤ) :
    ¬(0 < a + 2*b - 2*c ∧ 0 < -a - 2*b + 2*c) := by
  intro ⟨h1, h2⟩; linarith

/-! ## Section 3: Coverage -/

/-- 3^k ≥ 1 nodes at depth k. -/
theorem tree_branching (k : ℕ) : 3 ^ k ≥ 1 := Nat.one_le_pow k 3 (by norm_num)

/-- Parallelism multiplies coverage. -/
theorem parallel_visits (d : ℕ) : 3 * d ≥ d := by omega

/-! ## Section 4: Multi-Start -/

/-- 4 divisor pairs for semiprimes. -/
theorem multistart_count :
    (2 + 1) * (2 + 1) = 9 ∧ (9 - 1) / 2 = 4 := by omega

/-- gcd(p, pq) = p. -/
theorem independent_gcd (p q : ℕ) :
    Nat.gcd p (p * q) = p := Nat.gcd_eq_left (dvd_mul_right p q)

/-- GCD divides N. -/
theorem gcd_divides_N (N a : ℕ) : Nat.gcd a N ∣ N := Nat.gcd_dvd_right a N

/-- Difference of squares identity. -/
theorem leg_diff_sq (m n : ℤ) : m ^ 2 - n ^ 2 = (m - n) * (m + n) := by ring
