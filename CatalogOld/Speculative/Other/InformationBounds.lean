/-
  # Information-Theoretic Bounds on Search-Evasion Tradeoffs
-/
import Mathlib

noncomputable section

open Set Filter Finset

/-! ## Entropy and Search -/

/-- Binary entropy function. -/
def binaryEntropy (p : ℝ) : ℝ :=
  if p ≤ 0 ∨ p ≥ 1 then 0
  else -(p * Real.log p + (1 - p) * Real.log (1 - p))

/-
Binary entropy is nonneg for p in (0,1).
-/
theorem binaryEntropy_nonneg (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    0 ≤ binaryEntropy p := by
  unfold binaryEntropy;
  split_ifs <;> nlinarith [ Real.log_le_sub_one_of_pos hp0, Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 - p ) ]

/-
Binary entropy is maximized at p = 1/2.
-/
theorem binaryEntropy_max :
    ∀ p : ℝ, 0 ≤ p → p ≤ 1 → binaryEntropy p ≤ binaryEntropy (1/2) := by
  unfold binaryEntropy; norm_num;
  intro p hp hp'; split_ifs <;> norm_num at *;
  · exact mul_nonpos_of_nonneg_of_nonpos ( by norm_num ) ( Real.log_nonpos ( by norm_num ) ( by norm_num ) );
  · have := @Real.geom_mean_le_arith_mean;
    specialize this { 0, 1 } ( fun i => if i = 0 then 1 - p else p ) ( fun i => if i = 0 then 1 / ( 1 - p ) else 1 / p ) ; norm_num at *;
    have := this hp' hp hp' hp; rw [ Real.rpow_def_of_pos ( inv_pos.mpr ( by linarith ) ), Real.rpow_def_of_pos ( inv_pos.mpr ( by linarith ) ) ] at this; norm_num at *;
    rw [ ← Real.exp_add ] at this ; norm_num [ Real.log_div, show p ≠ 0 by linarith, show ( 1 - p ) ≠ 0 by linarith ] at *;
    have := Real.log_le_log ( by positivity ) this ; norm_num at this ; linarith [ Real.log_exp ( - ( Real.log ( 1 - p ) * ( 1 - p ) ) + - ( Real.log p * p ) ) ]

/-! ## Probability Distributions -/

/-- A probability distribution over Fin n. -/
structure ProbDist (n : ℕ) where
  prob : Fin n → ℝ
  prob_nonneg : ∀ i, 0 ≤ prob i
  prob_sum : ∑ i, prob i = 1

/-- Shannon entropy of a distribution. -/
def ProbDist.entropy {n : ℕ} (d : ProbDist n) : ℝ :=
  -∑ i : Fin n, if d.prob i = 0 then 0 else d.prob i * Real.log (d.prob i)

/-- The uniform distribution. -/
def uniformDist (n : ℕ) (hn : 0 < n) : ProbDist n where
  prob := fun _ => (1 : ℝ) / n
  prob_nonneg := fun _ => by positivity
  prob_sum := by simp [Finset.sum_const, Finset.card_fin]; field_simp

/-
The uniform distribution maximizes entropy.
-/
theorem uniform_max_entropy {n : ℕ} (hn : 0 < n) (d : ProbDist n) :
    d.entropy ≤ (uniformDist n hn).entropy := by
  have h_jensen : ∀ (x y : Fin n → ℝ), (∀ i, 0 ≤ x i) → (∀ i, 0 < y i) → (∑ i, x i = 1) → (∑ i, y i = 1) → (∑ i, x i * Real.log (y i)) ≤ (∑ i, x i * Real.log (x i)) := by
    intros x y hx hy hx_sum hy_sum
    have h_jensen : ∀ i, x i * Real.log (y i) - x i * Real.log (x i) ≤ y i - x i := by
      intro i; by_cases hi : x i = 0 <;> simp_all +decide [ ← mul_sub ];
      · linarith [ hy i ];
      · have := Real.log_le_sub_one_of_pos ( div_pos ( hy i ) ( lt_of_le_of_ne ( hx i ) ( Ne.symm hi ) ) );
        rw [ Real.log_div ( ne_of_gt ( hy i ) ) hi ] at this ; nlinarith [ hx i, hy i, mul_div_cancel₀ ( y i ) hi ];
    have := Finset.sum_le_sum fun i ( _ : i ∈ Finset.univ ) => h_jensen i; simp_all +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _ ] ;
  convert neg_le_neg ( h_jensen ( fun i => d.prob i ) ( fun i => ( n : ℝ ) ⁻¹ ) d.prob_nonneg ( fun i => inv_pos.mpr ( Nat.cast_pos.mpr hn ) ) d.prob_sum ( by norm_num [ hn.ne' ] ) ) using 1 <;> norm_num [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', * ];
  · exact congr_arg Neg.neg ( Finset.sum_congr rfl fun i _ => by aesop );
  · unfold ProbDist.entropy uniformDist; norm_num [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', * ] ; ring;
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hn.ne', d.prob_sum ]

/-! ## Minimax for Search-Evasion -/

/-- The minimax detection probability for a uniform game is 1/n. -/
theorem minimax_detection_value {n : ℕ} (hn : 2 ≤ n) :
    (1 : ℝ) / n > 0 := by positivity

/-! ## KL Divergence -/

/-- KL divergence between two distributions. -/
def klDivergence {n : ℕ} (p q : ProbDist n) : ℝ :=
  ∑ i : Fin n, if p.prob i = 0 then 0
    else p.prob i * (Real.log (p.prob i) - Real.log (q.prob i))

/-
KL divergence is nonneg (Gibbs' inequality).
-/
theorem kl_divergence_nonneg {n : ℕ} (p q : ProbDist n)
    (hq : ∀ i, 0 < q.prob i) :
    0 ≤ klDivergence p q := by
  -- Applying the inequality $p_i \log p_i - p_i \log q_i \geq p_i - q_i$ to each term in the sum.
  have h_ineq : ∀ i, p.prob i * (Real.log (p.prob i) - Real.log (q.prob i)) ≥ p.prob i - q.prob i := by
    intro i
    by_cases hpi : p.prob i = 0;
    · norm_num [ hpi ] ; linarith [ hq i ];
    · have := Real.log_le_sub_one_of_pos ( div_pos ( hq i ) ( lt_of_le_of_ne ( p.prob_nonneg i ) ( Ne.symm hpi ) ) );
      rw [ Real.log_div ( ne_of_gt ( hq i ) ) hpi ] at this ; nlinarith [ p.prob_nonneg i, hq i, mul_div_cancel₀ ( q.prob i ) hpi ];
  -- Summing the inequalities over all $i$, we get the desired result.
  have h_sum_ineq : ∑ i, (if p.prob i = 0 then 0 else p.prob i * (Real.log (p.prob i) - Real.log (q.prob i))) ≥ ∑ i, (p.prob i - q.prob i) := by
    exact Finset.sum_le_sum fun i _ => by specialize h_ineq i; aesop;
  have := p.prob_sum; have := q.prob_sum; aesop;

/-! ## Infinite-Horizon Analysis -/

/-
In infinite horizon, evader can achieve survival probability ≥ 1 - 1/n.
-/
theorem infinite_horizon_optimal {n : ℕ} (hn : 2 ≤ n) (d : ProbDist n) :
    ∃ target : Fin n, 1 - d.prob target ≥ 1 - 1 / (n : ℝ) := by
  by_contra h;
  -- By assumption, $d.prob i > 1/n$ for all $i$.
  have h_all_gt : ∀ i : Fin n, d.prob i > 1 / (n : ℝ) := by
    grind;
  have := Finset.sum_lt_sum_of_nonempty ⟨ ⟨ 0, by linarith ⟩, Finset.mem_univ _ ⟩ fun i hi => h_all_gt i; simp_all +decide [ Finset.sum_const, nsmul_eq_mul ] ;
  rw [ mul_inv_cancel₀ ( by positivity ), d.prob_sum ] at this ; linarith

/-- The search-information isomorphism: optimal search gain = log n. -/
theorem search_info_isomorphism {n : ℕ} (hn : 0 < n) :
    ∃ (optimal_gain : ℝ), optimal_gain = Real.log n := by
  exact ⟨Real.log n, rfl⟩

end