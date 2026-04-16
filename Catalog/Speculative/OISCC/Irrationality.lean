/-
# OISCC V9.1: Irrationality and Transcendence Results
-/

import Mathlib

noncomputable section

open Real

def EML_irr (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-
e is irrational.
-/
theorem e_irrational : Irrational (Real.exp 1) := by
  -- Assume for contradiction that $e$ is rational, so $e = \frac{p}{q}$ for some coprime positive integers $p$ and $q$.
  by_contra h_contra
  obtain ⟨p, q, h_coprime, h_eq⟩ : ∃ p q : ℕ, Nat.gcd p q = 1 ∧ Real.exp 1 = p / q := by
    obtain ⟨ p, hp ⟩ := Classical.not_not.1 h_contra;
    exact ⟨ p.num.natAbs, p.den, p.reduced, by simpa [ abs_of_nonneg ( Rat.num_nonneg.mpr ( show 0 ≤ p by exact_mod_cast hp.symm ▸ Real.exp_nonneg _ ) ), Rat.cast_def ] using hp.symm ⟩;
  -- Consider the expression $q! \left( e - \sum_{k=0}^{q} \frac{1}{k!} \right)$.
  set expr := (Nat.factorial q : ℝ) * (Real.exp 1 - ∑ k ∈ Finset.range (q + 1), (1 / (Nat.factorial k) : ℝ)) with hexpr_def
  have hexpr_int : ∃ m : ℤ, expr = m := by
    -- Since $e = \frac{p}{q}$, we can rewrite $expr$ as $p \cdot (q-1)! - \sum_{k=0}^{q} \frac{q!}{k!}$.
    have hexpr_rewrite : expr = p * (Nat.factorial (q - 1) : ℝ) - ∑ k ∈ Finset.range (q + 1), (Nat.factorial q / Nat.factorial k : ℝ) := by
      by_cases hq : q = 0 <;> simp_all +decide [ div_eq_mul_inv, mul_sub, mul_comm, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ];
      exact Or.inl ( by rw [ inv_mul_eq_div, div_eq_iff ( by positivity ) ] ; cases q <;> norm_num [ Nat.factorial ] at * ; linarith );
    use p * (Nat.factorial (q - 1) : ℤ) - ∑ k ∈ Finset.range (q + 1), (Nat.factorial q / Nat.factorial k : ℤ);
    simp +zetaDelta at *;
    exact hexpr_rewrite.trans ( by rw [ Finset.sum_congr rfl ] ; intros; rw [ Int.cast_div ( mod_cast Nat.factorial_dvd_factorial <| by linarith [ Finset.mem_range.mp ‹_› ] ) ( by positivity ) ] ; push_cast ; ring );
  -- However, we can also bound $expr$ between $0$ and $1$.
  have hexpr_bounds : 0 < expr ∧ expr < 1 := by
    have hexpr_bounds : expr = ∑' k : ℕ, (Nat.factorial q : ℝ) / (Nat.factorial (q + k + 1) : ℝ) := by
      have hexpr_simplified : expr = ∑' k : ℕ, (Nat.factorial q : ℝ) / (Nat.factorial (k + q + 1) : ℝ) := by
        have h_series : Real.exp 1 = ∑' k : ℕ, (1 / (Nat.factorial k : ℝ)) := by
          simp +decide [ Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div ]
        have h_series_split : ∑' k : ℕ, (1 / (Nat.factorial k : ℝ)) = (∑ k ∈ Finset.range (q + 1), (1 / (Nat.factorial k : ℝ))) + (∑' k : ℕ, (1 / (Nat.factorial (k + q + 1) : ℝ))) := by
          rw [ ← Summable.sum_add_tsum_nat_add ];
          exacts [ rfl, by simpa using Real.summable_pow_div_factorial 1 ];
        simp_all +decide [ div_eq_mul_inv, tsum_mul_left ];
      simpa only [ add_comm, add_left_comm ] using hexpr_simplified;
    -- We'll use that the series $\sum_{k=q+1}^{\infty} \frac{q!}{k!}$ is a geometric series with the first term $\frac{q!}{(q+1)!} = \frac{1}{q+1}$ and common ratio $\frac{1}{q+2}$.
    have h_geo_series : ∑' k : ℕ, (Nat.factorial q : ℝ) / (Nat.factorial (q + k + 1) : ℝ) ≤ ∑' k : ℕ, (1 / (q + 1) : ℝ) * (1 / (q + 2)) ^ k := by
      refine' Summable.tsum_le_tsum _ _ _;
      · field_simp;
        intro i; rw [ mul_comm ] ; induction i <;> simp_all +decide [ Nat.factorial, pow_succ' ];
        field_simp at *;
        nlinarith [ ( by positivity : 0 < ( q + 1 : ℝ ) * q.factorial * ( q + 2 ) ^ ‹_› ) ];
      · exact Summable.mul_left _ <| by simpa using Summable.comp_injective ( Real.summable_pow_div_factorial 1 ) <| by intros a b; aesop;
      · exact Summable.mul_left _ <| summable_geometric_of_lt_one ( by positivity ) <| by rw [ div_lt_iff₀ ] <;> linarith;
    rw [ tsum_mul_left, tsum_geometric_of_lt_one ] at * <;> norm_num at * <;> try positivity;
    · rcases q with ( _ | _ | q ) <;> norm_num at *;
      · exact ⟨ by have := Real.exp_one_gt_d9.le; norm_num1 at *; linarith, by have := Real.exp_one_lt_d9.le; norm_num1 at *; linarith ⟩;
      · refine' ⟨ _, _ ⟩;
        · exact hexpr_bounds.symm ▸ lt_of_lt_of_le ( by positivity ) ( Summable.le_tsum ( by exact ( by simpa using Summable.mul_left _ <| Real.summable_pow_div_factorial 1 |> Summable.comp_injective <| by intros a b; aesop ) ) 0 <| by intros; positivity );
        · exact hexpr_bounds.symm ▸ h_geo_series.trans_lt ( by rw [ ← mul_inv, inv_lt_one₀ ] <;> nlinarith [ inv_mul_cancel₀ ( by linarith : ( q : ℝ ) + 1 + 1 + 2 ≠ 0 ) ] );
    · exact inv_lt_one_of_one_lt₀ ( by linarith );
  obtain ⟨ m, hm ⟩ := hexpr_int; rcases m with ⟨ _ | _ | m ⟩ <;> norm_num at hm <;> linarith;

/-- EML(1, 1) = e is irrational (conditional on e being irrational). -/
theorem EML_one_one_irrational (h : Irrational (Real.exp 1)) :
    Irrational (EML_irr 1 1) := by
  convert h using 1; simp [EML_irr, Real.log_one]

/-- exp(n) is irrational for n ≥ 1 (Lindemann-Weierstrass). -/
theorem exp_nat_irrational (n : ℕ) (hn : 1 ≤ n) : Irrational (Real.exp n) := by sorry

/-- EML(0, 1) = 1 is rational. -/
theorem EML_zero_one_rational : ¬ Irrational (EML_irr 0 1) := by
  have : EML_irr 0 1 = 1 := by simp [EML_irr, Real.log_one]
  rw [this]; exact not_irrational_one

end