import Mathlib

/-!
# Deterministic scaling-law engine from two-sided polynomial tail bounds

This file develops a minimal, fully-compiling deterministic scaling-law engine
built from two-sided polynomial tail bounds on a loss function `L : ℕ → ℝ`.

A `TailBounds` packages a loss function together with constants `c < C` and a
decay exponent `α > 0` such that, for all `n ≥ 1`,
`c * n ^ (-α) ≤ L n ≤ C * n ^ (-α)`.

From these bounds we derive five elementary consequences relating capacity
(the index `n`, e.g. number of samples / parameters) to the achievable loss `ε`.
-/

namespace ScalingLaws

/-- Two-sided polynomial tail bounds on a loss function. -/
structure TailBounds where
  /-- The loss function. -/
  L : ℕ → ℝ
  /-- The polynomial decay exponent. -/
  α : ℝ
  /-- The lower constant. -/
  c : ℝ
  /-- The upper constant. -/
  C : ℝ
  /-- The decay exponent is positive. -/
  α_pos : 0 < α
  /-- The lower constant is positive. -/
  c_pos : 0 < c
  /-- The lower constant is strictly below the upper constant. -/
  c_lt_C : c < C
  /-- Lower tail bound. -/
  lower : ∀ n : ℕ, n ≥ 1 → c * (n : ℝ) ^ (-α) ≤ L n
  /-- Upper tail bound. -/
  upper : ∀ n : ℕ, n ≥ 1 → L n ≤ C * (n : ℝ) ^ (-α)

variable (tb : TailBounds)

/-- The loss is strictly positive on `n ≥ 1`. -/
theorem loss_pos : ∀ n : ℕ, n ≥ 1 → 0 < tb.L n := by
  exact fun n hn => lt_of_lt_of_le ( mul_pos tb.c_pos ( Real.rpow_pos_of_pos ( Nat.cast_pos.mpr hn ) _ ) ) ( tb.lower n hn )

/-- Capacity sufficiency: any target loss `ε > 0` is achievable at some capacity `n ≥ 1`. -/
theorem capacity_sufficient : ∀ ε > 0, ∃ n : ℕ, n ≥ 1 ∧ tb.L n ≤ ε := by
  intro ε hε;
  -- We need to show that there exists an $n$ such that $tb.C * (n : ℝ) ^ (-tb.α) ≤ ε$.
  have h_exists_n : ∃ n : ℕ, n ≥ 1 ∧ tb.C * (n : ℝ) ^ (-tb.α) ≤ ε := by
    -- By definition of exponentiation, we know that if $n \geq 1$, then $(n : ℝ) ^ (-tb.α) \leq (tb.C / ε) ^ (-tb.α)$.
    have h_exp : Filter.Tendsto (fun n : ℕ => tb.C * (n : ℝ) ^ (-tb.α)) Filter.atTop (nhds 0) := by
      simpa using tendsto_const_nhds.mul ( tendsto_rpow_neg_atTop tb.α_pos ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop;
    exact Filter.eventually_atTop.mp ( h_exp.eventually ( ge_mem_nhds hε ) ) |> fun ⟨ n, hn ⟩ => ⟨ n + 1, by linarith, hn _ <| by linarith ⟩;
  exact ⟨ h_exists_n.choose, h_exists_n.choose_spec.1, le_trans ( tb.upper _ h_exists_n.choose_spec.1 ) h_exists_n.choose_spec.2 ⟩

/-- Capacity necessity: achieving loss `≤ ε` forces a lower bound on the capacity `n`. -/
theorem capacity_necessary :
    ∀ ε > 0, ∀ n ≥ 1, tb.L n ≤ ε → (n : ℝ) ≥ (tb.c / ε) ^ (1 / tb.α) := by
  intro ε hε n hn hεn
  have h_bound : (tb.c / ε) ≤ (n : ℝ) ^ tb.α := by
    rw [ div_le_iff₀ hε ];
    have := tb.lower n hn;
    convert mul_le_mul_of_nonneg_left ( this.trans hεn ) ( Real.rpow_nonneg ( Nat.cast_nonneg n ) tb.α ) using 1 ; rw [ mul_left_comm, ← Real.rpow_add ( by positivity ) ] ; norm_num;
  exact le_trans ( Real.rpow_le_rpow ( div_nonneg tb.c_pos.le hε.le ) h_bound ( by exact one_div_nonneg.mpr tb.α_pos.le ) ) ( by rw [ ← Real.rpow_mul ( by positivity ), mul_one_div_cancel ( ne_of_gt tb.α_pos ), Real.rpow_one ] )

/-- Loss ratio bound: for `m ≤ n`, the ratio of losses is controlled by the
condition-number `C / c` times the polynomial ratio `(m / n) ^ α`. -/
theorem loss_ratio_bound :
    ∀ n m : ℕ, 1 ≤ n → 1 ≤ m → m ≤ n →
      tb.L n / tb.L m ≤ (tb.C / tb.c) * ((m : ℝ) / n) ^ tb.α := by
  intros n m hn hm hmn
  have h_bound : tb.L n / tb.L m ≤ (tb.C * (n : ℝ) ^ (-tb.α)) / (tb.c * (m : ℝ) ^ (-tb.α)) := by
    gcongr
    · exact mul_nonneg (le_of_lt (by linarith [tb.c_pos, tb.c_lt_C])) (Real.rpow_nonneg (Nat.cast_nonneg _) _)
    · exact mul_pos tb.c_pos (Real.rpow_pos_of_pos (Nat.cast_pos.mpr hm) _)
    · exact tb.upper n hn
    · exact tb.lower m hm
  refine h_bound.trans_eq ?_
  have hn0 : (0 : ℝ) < (n : ℝ) := Nat.cast_pos.mpr hn
  have hm0 : (0 : ℝ) < (m : ℝ) := Nat.cast_pos.mpr hm
  rw [Real.div_rpow hm0.le hn0.le, Real.rpow_neg hn0.le, Real.rpow_neg hm0.le]
  field_simp

/-- Sample lower bound: below the necessary capacity the loss cannot reach `ε`. -/
theorem sample_lower_bound :
    ∀ ε > 0, ∀ n : ℕ, n ≥ 1 → (n : ℝ) < (tb.c / ε) ^ (1 / tb.α) → ε < tb.L n := by
  intro ε hε n hn hn';
  -- By raising both sides of the inequality `n < (tb.c / ε) ^ (1 / tb.α)` to the power of `tb.α`, we get `n ^ tb.α < tb.c / ε`.
  have h_pow : (n : ℝ) ^ tb.α < tb.c / ε := by
    exact lt_of_lt_of_le ( Real.rpow_lt_rpow ( by positivity ) hn' ( by linarith [ tb.α_pos ] ) ) ( by rw [ ← Real.rpow_mul ( by exact div_nonneg ( le_of_lt tb.c_pos ) hε.le ), one_div_mul_cancel ( ne_of_gt tb.α_pos ), Real.rpow_one ] );
  refine' lt_of_lt_of_le _ ( tb.lower n hn );
  rw [ Real.rpow_neg ( by positivity ) ];
  rw [ ← div_eq_mul_inv, lt_div_iff₀ ] <;> first | positivity | rw [ lt_div_iff₀ ] at * <;> linarith;

end ScalingLaws