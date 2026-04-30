import Mathlib

/-! # Niven Integral Framework for Irrationality of exp(n)

We formalize key components of the Niven integral approach to proving
that exp(n) is irrational for positive integers n.

## The Niven Integral

The key object is `I(a,b,n) = ∫₀ⁿ e^(n-t) · t^a · (n-t)^b dt`

Properties:
1. I(a,b,n) > 0 (positivity)
2. I(a,b,n) → 0 as a → ∞ (for fixed b,n) (boundedness)
3. I(a,b,n) is an integer linear combination of e^n and 1 (integrality)

## Research Direction 2.1
-/

open MeasureTheory Real Set

noncomputable section

/-- exp(1) > 2: fundamental lower bound -/
theorem exp_one_gt_two : (2 : ℝ) < exp 1 := by linarith [Real.exp_one_gt_d9]

/-- The key positivity lemma: the Niven integrand is nonneg on [0, n]. -/
theorem niven_integrand_nonneg (n a b : ℕ) (t : ℝ) (ht : t ∈ Icc 0 (n : ℝ)) :
    0 ≤ t ^ a * ((n : ℝ) - t) ^ b * exp ((n : ℝ) - t) := by
  apply mul_nonneg
  · apply mul_nonneg
    · exact pow_nonneg ht.1 a
    · exact pow_nonneg (by linarith [ht.2]) b
  · exact le_of_lt (exp_pos _)

/-- exp(n) is positive for all n -/
theorem exp_nat_pos (n : ℕ) : 0 < exp (n : ℝ) := exp_pos _

/-- exp(n) > 1 for n ≥ 1 -/
theorem exp_nat_gt_one (n : ℕ) (hn : 1 ≤ n) : 1 < exp (n : ℝ) := by
  calc (1 : ℝ) = exp 0 := by simp
    _ < exp (n : ℝ) := exp_strictMono (by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hn)

/-- Key inequality for Niven's method: t * (n - t) ≤ n²/4 (AM-GM). -/
theorem niven_amgm (n t : ℝ) : t * (n - t) ≤ n ^ 2 / 4 := by
  nlinarith [sq_nonneg (t - n / 2)]

/-- The Niven bound: t^a * (n-t)^a ≤ (n²/4)^a on [0,n]. -/
theorem niven_integrand_bound (n : ℝ) (a : ℕ) (t : ℝ)
    (ht1 : 0 ≤ t) (ht2 : t ≤ n) :
    t ^ a * (n - t) ^ a ≤ (n ^ 2 / 4) ^ a := by
  rw [← mul_pow]
  gcongr
  · exact mul_nonneg ht1 (by linarith)
  · exact niven_amgm n t

/-- exp is convex on ℝ -/
theorem exp_convex' : ConvexOn ℝ Set.univ (exp : ℝ → ℝ) := convexOn_exp

/-- The ratio x^k/k! → 0 as k → ∞ (key for Niven's method) -/
theorem niven_ratio_tendsto_zero (x : ℝ) :
    Filter.Tendsto (fun k : ℕ => x ^ k / (k.factorial : ℝ)) Filter.atTop (nhds 0) :=
  FloorSemiring.tendsto_pow_div_factorial_atTop x

end
