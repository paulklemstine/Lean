/-! # CatalogBuild.Algebra.AnalysisExploration

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 13
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.AnalysisExploration
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 13] -/
theorem cauchy_schwarz_finset' {n : ℕ} (a b : Fin n → ℝ) :
    (∑ i, a i * b i) ^ 2 ≤ (∑ i, a i ^ 2) * (∑ i, b i ^ 2) := by
  exact?





/-- [Section: # CatalogBuild.Algebra.AnalysisExploration
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 13] -/
theorem power_mean_two (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    x * y ≤ ((x + y) / 2) ^ 2 := by
  linarith [ sq_nonneg ( x - y ) ]





/-- [Section: # CatalogBuild.Algebra.AnalysisExploration
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 13] -/
theorem inv_n_tendsto : Filter.Tendsto (fun n : ℕ => (1 : ℝ) / (n + 1)) Filter.atTop (nhds 0) := by
  exact tendsto_one_div_add_atTop_nhds_zero_nat





theorem geometric_sum_formula (r : ℝ) (hr : r ≠ 1) (n : ℕ) :
    ∑ k ∈ Finset.range n, r ^ k = (1 - r ^ n) / (1 - r) := by
  rw [ ← neg_div_neg_eq, geom_sum_eq ] <;> aesop





theorem basel_partial_sums_bounded :
    BddAbove (Set.range (fun n : ℕ => ∑ k ∈ Finset.range n, (1 : ℝ) / ((k + 1) ^ 2))) := by
  exact ⟨ _, Set.forall_mem_range.2 fun n => Summable.sum_le_tsum ( Finset.range n ) ( fun _ _ => by positivity ) ( by simpa using summable_nat_add_iff 1 |>.2 <| Real.summable_one_div_nat_pow.2 one_lt_two ) ⟩





/-- Exponential is always positive. -/
theorem exp_pos_everywhere (x : ℝ) : 0 < Real.exp x := Real.exp_pos x





/-- e^0 = 1. -/
theorem exp_zero_eq_one : Real.exp 0 = 1 := Real.exp_zero





theorem log_mul_eq (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    Real.log (a * b) = Real.log a + Real.log b := by
  exact Real.log_mul ha.ne' hb.ne'





theorem binary_entropy_half :
    -(1/2 : ℝ) * Real.log (1/2) - (1/2) * Real.log (1/2) = Real.log 2 := by
  simpa using by ring;





/-- Vieta's formulas check: x² - 5x + 6 = (x-2)(x-3). -/
theorem vieta_example : (2 : ℤ) + 3 = 5 ∧ 2 * 3 = 6 := by omega





theorem bits_needed_8 : Nat.log 2 8 = 3 := by native_decide




theorem bits_needed_16 : Nat.log 2 16 = 4 := by native_decide




theorem bits_needed_1024 : Nat.log 2 1024 = 10 := by native_decide



