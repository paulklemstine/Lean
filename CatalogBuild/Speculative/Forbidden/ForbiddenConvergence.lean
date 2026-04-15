/-! # CatalogBuild.Speculative.Forbidden.ForbiddenConvergence

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7
-/

import Mathlib

noncomputable section

theorem geometric_series_rational (r : ℚ) (hr : r ≠ 1) (n : ℕ) :
    (∑ i ∈ Finset.range n, r ^ i) = (1 - r ^ n) / (1 - r) := by
  rw [ ← neg_div_neg_eq, geom_sum_eq ] <;> aesop

/-! ## §2: The Grandi Series -/

/-
PROBLEM
The partial sums of the Grandi series 1 - 1 + 1 - 1 + ... oscillate
    between 0 and 1.

PROVIDED SOLUTION
By induction on n. Base case n=0: empty sum = 0, Even 0, so if-then-else gives 0. ✓. Inductive step: ∑_{i<n+1} (-1)^i = ∑_{i<n} (-1)^i + (-1)^n. By IH, this equals (if Even n then 0 else 1) + (-1)^n. Case Even n: 0 + 1 = 1, and Odd (n+1). Case Odd n: 1 + (-1) = 0, and Even (n+1). Use Int.neg_one_pow_eq_one_iff_even or similar.
-/

theorem grandi_partial_sums (n : ℕ) :
    (∑ i ∈ Finset.range n, ((-1 : ℤ) ^ i)) = if Even n then 0 else 1 := by
  cases Nat.even_or_odd' n ; aesop

/-! ## §3: Telescoping — The Forbidden Cancellation -/

/-
PROBLEM
Telescoping sum: everything cancels except the endpoints

PROVIDED SOLUTION
Use Finset.sum_range_sub from Mathlib, which is exactly the telescoping identity.
-/

theorem telescoping_sum (f : ℕ → ℤ) (n : ℕ) :
    (∑ i ∈ Finset.range n, (f (i + 1) - f i)) = f n - f 0 := by
  rw [ Finset.sum_range_sub ]

/-
PROBLEM
The sum of 1/(k(k+1)) telescopes to n/(n+1)

PROVIDED SOLUTION
By induction on n. Base: empty sum = 0 = 0/1. Step: add 1/((n+1)(n+2)) to n/(n+1). Common denominator: n(n+2)/((n+1)(n+2)) + 1/((n+1)(n+2)) = (n²+2n+1)/((n+1)(n+2)) = (n+1)²/((n+1)(n+2)) = (n+1)/(n+2). Use field_simp and ring.
-/

theorem partial_fractions_sum (n : ℕ) :
    (∑ k ∈ Finset.range n, (1 : ℚ) / ((↑k + 1) * (↑k + 2))) =
    (↑n : ℚ) / (↑n + 1) := by
  induction n <;> simp_all +decide [ Finset.sum_range_succ ] ; ring;
  -- Combine and simplify the fractions
  field_simp
  ring

/-! ## §4: The Harmonic Series Diverges -/

/-
PROBLEM
The harmonic partial sums are at least 1 for any n.

PROVIDED SOLUTION
The sum includes the term i=0 which gives 1/(0+1) = 1. So the sum is ≥ 1. Use Finset.sum_nonneg and the term at i=0.
-/

theorem harmonic_lower_bound (n : ℕ) :
    (∑ i ∈ Finset.range (n + 1), (1 : ℚ) / (↑i + 1)) ≥ 1 := by
  exact le_trans ( by norm_num ) ( Finset.single_le_sum ( fun i _ => by positivity ) ( Finset.mem_range.mpr ( Nat.succ_pos _ ) ) )

/-! ## §5: The Forbidden Sum — 1 + 2 + 3 + ... = -1/12 -/

/-
PROBLEM
We don't prove that 1+2+3+... = -1/12 (that requires regularization).
    But we CAN prove the formula behind it: the Gauss identity.

PROVIDED SOLUTION
By induction on n. Or use the identity ∑_{i=0}^{n-1} (i+1) = ∑_{i=1}^{n} i = n(n+1)/2. Use Finset.sum_range_id_eq_sum_range_succ or similar Mathlib lemma, or induction with field_simp and ring.
-/

theorem sum_first_n (n : ℕ) :
    (∑ i ∈ Finset.range n, (↑i + 1 : ℚ)) = ↑n * (↑n + 1) / 2 := by
  induction n <;> simp +decide [ Finset.sum_range_succ, * ] ; ring

/-
PROBLEM
Sum of squares formula

PROVIDED SOLUTION
By induction on n with field_simp and ring at the inductive step.
-/

theorem bernoulli_inequality (x : ℝ) (hx : -1 ≤ x) (n : ℕ) :
    (1 + x) ^ n ≥ 1 + ↑n * x := by
  exact one_add_mul_le_pow ( by linarith ) _

/-! ## §7: The AM-GM Inequality (2 variables) -/

/-
PROBLEM
The AM-GM inequality for two non-negative reals

PROVIDED SOLUTION
Use the fact that (√a - √b)² ≥ 0, which expands to a - 2√(ab) + b ≥ 0, giving √(ab) ≤ (a+b)/2. Or use Real.add_sq_le_sq_mul_sq from Mathlib, or just nlinarith after appropriate setup. The Mathlib lemma might be Real.sqrt_mul_le_add_of_sq_le_sq or similar.
-/

end
