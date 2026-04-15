/-! # CatalogBuild.Speculative.SciFi.AlienLife_2

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 7
-/

import Mathlib

/-- [Section: ## Section 10.1: The Infinite Monkey Theorem] -/
theorem miss_probability_decreases (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    StrictAnti (fun n : ℕ => (1 - p) ^ n) := by
  exact fun n m hnm => pow_lt_pow_right_of_lt_one₀ ( by linarith ) ( by linarith ) hnm


theorem miss_probability_vanishes (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    Filter.Tendsto (fun n : ℕ => (1 - p) ^ n) Filter.atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one ( by linarith ) ( by linarith )


theorem hit_probability_approaches_one (p : ℝ) (hp : 0 < p) (hp1 : p < 1) :
    Filter.Tendsto (fun n : ℕ => 1 - (1 - p) ^ n) Filter.atTop (nhds 1) := by
  exact le_trans ( tendsto_const_nhds.sub ( tendsto_pow_atTop_nhds_zero_of_lt_one ( by linarith ) ( by linarith ) ) ) ( by norm_num )


/-- [Section: ## Section 10.2: Poisson Processes and Nearest Neighbors] -/
theorem poisson_void_probability (lam : ℝ) (hlam : 0 < lam) :
    Real.exp (-lam) < 1 := by
  aesop


theorem poisson_detection_limit :
    Filter.Tendsto (fun x : ℝ => 1 - Real.exp (-x)) Filter.atTop (nhds 1) := by
  simpa using tendsto_const_nhds.sub ( Real.tendsto_exp_atBot.comp Filter.tendsto_neg_atTop_atBot )


/-- [Section: ## Combinatorics of Molecular Assembly] -/
theorem arrangements_grow (k : ℕ) (hk : 0 < k) :
    StrictMono (fun n : ℕ => n ^ k) := by
  exact fun a b h => Nat.pow_lt_pow_left h hk.ne'


theorem factorial_beats_exponential :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → 2 ^ n < n.factorial := by
  exact ⟨ 4, fun n hn => by induction hn <;> norm_num [ Nat.factorial_succ, pow_succ' ] at * ; nlinarith ⟩

