/-! # CatalogBuild.Speculative.Forbidden.ForbiddenConvergence

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7
-/

import Mathlib

noncomputable section

/-- [Section: ## §1: Geometric Series — The Gateway Drug] -/
theorem geometric_series_rational (r : ℚ) (hr : r ≠ 1) (n : ℕ) :
    (∑ i ∈ Finset.range n, r ^ i) = (1 - r ^ n) / (1 - r) := by
  rw [ ← neg_div_neg_eq, geom_sum_eq ] <;> aesop


/-- [Section: ## §2: The Grandi Series] -/
theorem grandi_partial_sums (n : ℕ) :
    (∑ i ∈ Finset.range n, ((-1 : ℤ) ^ i)) = if Even n then 0 else 1 := by
  cases Nat.even_or_odd' n ; aesop


/-- [Section: ## §3: Telescoping — The Forbidden Cancellation] -/
theorem telescoping_sum (f : ℕ → ℤ) (n : ℕ) :
    (∑ i ∈ Finset.range n, (f (i + 1) - f i)) = f n - f 0 := by
  rw [ Finset.sum_range_sub ]


theorem partial_fractions_sum (n : ℕ) :
    (∑ k ∈ Finset.range n, (1 : ℚ) / ((↑k + 1) * (↑k + 2))) =
    (↑n : ℚ) / (↑n + 1) := by
  induction n <;> simp_all +decide [ Finset.sum_range_succ ] ; ring;
  -- Combine and simplify the fractions
  field_simp
  ring


/-- [Section: ## §4: The Harmonic Series Diverges] -/
theorem harmonic_lower_bound (n : ℕ) :
    (∑ i ∈ Finset.range (n + 1), (1 : ℚ) / (↑i + 1)) ≥ 1 := by
  exact le_trans ( by norm_num ) ( Finset.single_le_sum ( fun i _ => by positivity ) ( Finset.mem_range.mpr ( Nat.succ_pos _ ) ) )


/-- [Section: ## §5: The Forbidden Sum — 1 + 2 + 3 + ... = -1/12] -/
theorem sum_first_n (n : ℕ) :
    (∑ i ∈ Finset.range n, (↑i + 1 : ℚ)) = ↑n * (↑n + 1) / 2 := by
  induction n <;> simp +decide [ Finset.sum_range_succ, * ] ; ring


/-- [Section: ## §6: Bernoulli's Inequality] -/
theorem bernoulli_inequality (x : ℝ) (hx : -1 ≤ x) (n : ℕ) :
    (1 + x) ^ n ≥ 1 + ↑n * x := by
  exact one_add_mul_le_pow ( by linarith ) _


end
