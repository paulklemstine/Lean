/-! # CatalogBuild.Bridges.IrrationtalityBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 5
-/

import Computation.ExpIrrational
import Mathlib

noncomputable section

/-- [Section: # Irrationality Bridge
New theorems connecting irrationality results to the SPB framework.
## Main Results
- `sqrt_prime_irrational`: √p is irrational for prime p
- `e_plus_one_irrational`: e + 1 is irrational
- `e_times_nat_irrational`: n·e is irrational for n ≥ 1
- `sqrt2_plus_sqrt3_irrational`: √2 + √3 is irrational
- `log2_irrational`: log(2) is irrational] -/
theorem sqrt_prime_irrational (p : ℕ) (hp : Nat.Prime p) :
    Irrational (Real.sqrt p) := by
  exact Nat.Prime.irrational_sqrt hp


theorem e_plus_one_irrational : Irrational (Real.exp 1 + 1) := by
  have sqrt2_irr : Irrational (Real.sqrt 2) := by
    exact irrational_sqrt_two
  have e_irr : Irrational (Real.exp 1) := by
    by_contra h_contra
    obtain ⟨p, q, hq_pos, h_eq⟩ : ∃ p q : ℕ, q > 0 ∧ Real.exp 1 = p / q := by
      obtain ⟨ p, hp ⟩ := Classical.not_not.1 h_contra;
      exact ⟨ p.num.natAbs, p.den, Nat.cast_pos.mpr p.pos, by simpa [ abs_of_nonneg ( Rat.num_nonneg.mpr ( show 0 ≤ p by exact_mod_cast hp.symm ▸ Real.exp_nonneg _ ) ), Rat.cast_def ] using hp.symm ⟩;
    -- Consider the series expansion of $e$: $e = \sum_{n=0}^{\infty} \frac{1}{n!}$.
    have h_series : Real.exp 1 = ∑' n : ℕ, (1 : ℝ) / Nat.factorial n := by
      simp +decide [ Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div ];
    -- Consider the partial sum $S_q = \sum_{n=0}^{q} \frac{1}{n!}$. We have $0 < e - S_q < \frac{1}{q!q}$.
    have h_partial_sum : 0 < Real.exp 1 - ∑ n ∈ Finset.range (q + 1), (1 : ℝ) / Nat.factorial n ∧ Real.exp 1 - ∑ n ∈ Finset.range (q + 1), (1 : ℝ) / Nat.factorial n < 1 / (Nat.factorial q * q) := by
      -- We'll use that the series $\sum_{n=q+1}^{\infty} \frac{1}{n!}$ is strictly decreasing and positive.
      have h_tail : ∑' n : ℕ, (1 : ℝ) / Nat.factorial (n + q + 1) < 1 / (Nat.factorial q * q) := by
        -- We'll use that the series $\sum_{n=q+1}^{\infty} \frac{1}{n!}$ is strictly decreasing and positive to bound it above.
        have h_tail_bound : ∑' n : ℕ, (1 : ℝ) / Nat.factorial (n + q + 1) ≤ ∑' n : ℕ, (1 : ℝ) / (Nat.factorial (q + 1) * (q + 2) ^ n) := by
          refine' Summable.tsum_le_tsum _ _ _;
          · intro i; rw [ div_le_div_iff₀ ] <;> norm_cast <;> first | positivity | induction i <;> simp_all +decide [ Nat.factorial, pow_succ' ];
            rw [ Nat.succ_add ];
            nlinarith [ Nat.factorial_succ ( ‹_› + q ) ];
          · simpa using summable_nat_add_iff ( q + 1 ) |>.2 <| Real.summable_pow_div_factorial 1;
          · simpa using Summable.mul_right _ ( summable_geometric_of_lt_one ( by positivity ) ( inv_lt_one_of_one_lt₀ ( by norm_cast; linarith ) ) );
        -- We'll use that the series $\sum_{n=q+1}^{\infty} \frac{1}{n!}$ is strictly decreasing and positive to bound it above by a geometric series.
        have h_geo_series : ∑' n : ℕ, (1 : ℝ) / (Nat.factorial (q + 1) * (q + 2) ^ n) = (1 / (Nat.factorial (q + 1))) * (1 / (1 - 1 / (q + 2))) := by
          norm_num [ tsum_mul_left ];
          rw [ ← tsum_geometric_of_lt_one ( by positivity ) ( inv_lt_one_of_one_lt₀ ( by linarith ) ) ] ; rw [ ← tsum_mul_left ] ; exact tsum_congr fun n => by ring;
        refine lt_of_le_of_lt h_tail_bound <| h_geo_series.symm ▸ ?_;
        field_simp;
        rw [ div_lt_iff₀ ] <;> norm_num [ Nat.factorial_succ ] <;> ring <;> norm_cast <;> nlinarith [ Nat.factorial_pos q, Nat.factorial_succ q ];
      have h_split : ∑' n : ℕ, (1 : ℝ) / Nat.factorial n = ∑ n ∈ Finset.range (q + 1), (1 : ℝ) / Nat.factorial n + ∑' n : ℕ, (1 : ℝ) / Nat.factorial (n + q + 1) := by
        rw [ ← Summable.sum_add_tsum_nat_add ];
        exacts [ rfl, by simpa using Real.summable_pow_div_factorial 1 ];
      exact ⟨ by linarith [ show 0 < ∑' n : ℕ, ( 1 : ℝ ) / ( n + q + 1 ).factorial from lt_of_lt_of_le ( by positivity ) ( Summable.le_tsum ( by exact ( by simpa using summable_nat_add_iff ( q + 1 ) |>.2 <| Real.summable_pow_div_factorial 1 ) ) 0 fun _ _ => by positivity ) ], by linarith ⟩;
    -- Multiply both sides of the inequality by $q!$ to obtain $0 < q!e - q!S_q < \frac{1}{q}$.
    have h_mul_factorial : 0 < (Nat.factorial q : ℝ) * Real.exp 1 - ∑ n ∈ Finset.range (q + 1), (Nat.factorial q : ℝ) / Nat.factorial n ∧ (Nat.factorial q : ℝ) * Real.exp 1 - ∑ n ∈ Finset.range (q + 1), (Nat.factorial q : ℝ) / Nat.factorial n < 1 / q := by
      simp_all +decide [ div_eq_mul_inv, mul_sub, Finset.mul_sum _ _ _ ];
      simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
      exact ⟨ mul_lt_mul_of_pos_left h_partial_sum.1 <| by positivity, by nlinarith [ inv_pos.mpr <| show 0 < ( q.factorial : ℝ ) by positivity, mul_inv_cancel₀ <| show ( q.factorial : ℝ ) ≠ 0 by positivity ] ⟩;
    -- Since $q!e$ and $q!S_q$ are both integers, their difference must also be an integer.
    have h_diff_int : ∃ m : ℤ, (Nat.factorial q : ℝ) * Real.exp 1 - ∑ n ∈ Finset.range (q + 1), (Nat.factorial q : ℝ) / Nat.factorial n = m := by
      use p * Nat.factorial q / q - ∑ n ∈ Finset.range (q + 1), Nat.factorial q / Nat.factorial n;
      rw [ Int.cast_sub, Int.cast_div ] <;> norm_num [ h_eq, mul_comm, Finset.mul_sum _ _ _, Nat.factorial_ne_zero ];
      · exact congrArg₂ _ ( by ring ) ( Finset.sum_congr rfl fun _ _ => by rw [ Int.cast_div ( by exact_mod_cast Nat.factorial_dvd_factorial ( Finset.mem_range_succ_iff.mp ‹_› ) ) ( by positivity ) ] ; push_cast; ring );
      · exact dvd_mul_of_dvd_right ( mod_cast Nat.dvd_factorial ( by positivity ) ( by linarith ) ) _;
      · exact?;
    obtain ⟨ m, hm ⟩ := h_diff_int; rw [ hm ] at h_mul_factorial; rcases m with ⟨ _ | _ | m ⟩ <;> norm_num at h_mul_factorial <;> nlinarith [ inv_mul_cancel₀ ( by positivity : ( q : ℝ ) ≠ 0 ), ( by norm_cast : ( 1 :ℝ ) ≤ q ) ] ;
  exact (by
  simpa using e_irr.add_ratCast 1)


theorem e_times_nat_irrational (n : ℕ) (hn : 1 ≤ n) :
    Irrational ((n : ℝ) * Real.exp 1) := by
  have := @e_plus_one_irrational;
  convert this.mul_ratCast ( show ( n : ℚ ) ≠ 0 by positivity ) |> Irrational.sub_ratCast ( n : ℚ ) using 1 ; ring;
  norm_num [ mul_comm ]


theorem sqrt2_plus_sqrt3_irrational :
    Irrational (Real.sqrt 2 + Real.sqrt 3) := by
  by_contra h_contra
  obtain ⟨q, hq⟩ : ∃ q : ℚ, Real.sqrt 2 + Real.sqrt 3 = q := by
    simpa [ eq_comm ] using Classical.not_not.1 h_contra
  have h_sqrt2 : ∃ r : ℚ, Real.sqrt 2 = r := by
    exact ⟨ ( q^2 + 2 - 3 ) / ( 2 * q ), by push_cast [ ← hq ] ; rw [ eq_div_iff ( by positivity ) ] ; linarith [ Real.mul_self_sqrt ( show 0 ≤ 2 by norm_num ), Real.mul_self_sqrt ( show 0 ≤ 3 by norm_num ) ] ⟩
  obtain ⟨r, hr⟩ := h_sqrt2
  exact irrational_sqrt_two ⟨r, by
    exact hr.symm⟩


theorem log2_irrational : Irrational (Real.log 2) := by
  -- Assume log 2 is rational, get q : ℚ with Real.log 2 = q
  by_contra h
  obtain ⟨q, hq⟩ : ∃ q : ℚ, Real.log 2 = q := by
    simpa [ eq_comm ] using Classical.not_not.1 h;
  -- Since Real.log 2 > 0, q > 0, so q.num > 0 and q.den > 0
  have hq_pos : 0 < q.num ∧ 0 < q.den := by
    exact ⟨ Rat.num_pos.mpr ( by exact_mod_cast hq ▸ Real.log_pos one_lt_two ), q.pos ⟩;
  -- exp(q.num) = 2^(q.den) by raising both sides to q.den
  have h_exp_eq : Real.exp (q.num : ℝ) = 2 ^ (q.den : ℕ) := by
    rw [ ← Real.rpow_natCast, eq_comm, Real.rpow_def_of_pos ] <;> norm_num [ hq.symm ];
    rw [ hq, Rat.cast_def ] ; ring_nf ; norm_num [ hq_pos.2.ne' ];
  -- But exp(q.num) is irrational by exp_nat_irrational since q.num ≥ 1
  have h_exp_irr : Irrational (Real.exp (q.num : ℝ)) := by
    convert exp_nat_irrational ( q.num.natAbs ) ( by linarith [ abs_of_pos hq_pos.1 ] ) using 1;
    norm_num [ abs_of_pos hq_pos.1 ];
  exact h_exp_irr ⟨ 2 ^ q.den, by aesop ⟩


end
