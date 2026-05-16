import Mathlib
import MarkovBridge.Basic

/-!
# Asymptotic Corollaries of the Tropical Gap Theorem

This file provides additional corollaries and infrastructure
for the multi-step tropical gap theorem.

## Main Results

* `pow_rowStochastic`: Powers of row-stochastic matrices are row-stochastic.
* `positive_triangleCyc_of_mixing_bound`: Existence of a mixing bound
  implies strict positivity of the tropical cycle mean.
* `mixing_speed_limit`: The tropical cycle mean imposes a speed limit
  on mixing — transition probabilities cannot decay faster than
  `exp(-m · triangleCyc)`.
* `uniform_ceiling_from_entry_bound`: When ALL single-step entries
  satisfy `P i j ≤ 1/(n+1)`, the tropical cycle mean is at least `log(n+1)`.

## Note on the asymptotic ceiling

The statement `log(n+1) ≤ triangleCyc(-log P)` does NOT hold for
arbitrary positive row-stochastic matrices with uniform mixing convergence.
Counterexample: `P = [[0.99, 0.01], [0.01, 0.99]]` on 2 states has
`triangleCyc ≈ -log(0.99) ≈ 0.01 < log(2) ≈ 0.69`.
The theorem DOES hold when single-step entries are already bounded by `1/(n+1)`.
-/

noncomputable section

open Finset BigOperators Real Matrix Filter

namespace MarkovTropicalBridge

variable {n : ℕ}

/-! ## Row-stochastic powers -/

/-
Row-stochastic matrices have power entries bounded above by 1.
-/
lemma pow_entry_le_one
    (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (m : ℕ) (i j : Fin (n+1)) :
    (P ^ m) i j ≤ 1 := by
  -- By induction on $m$, we can show that the sum of the entries in each row of $P^m$ is 1.
  have h_row_sum : ∀ m i, ∑ j, (P ^ m) i j = 1 := by
    intro m i; induction' m with m ih generalizing i <;> simp_all +decide [ pow_succ', Matrix.mul_apply, Finset.mul_sum _ _ _ ] ;
    · simp +decide [ Matrix.one_apply ];
    · rw [ Finset.sum_comm ];
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hrow.2, ih ];
  exact h_row_sum m i ▸ Finset.single_le_sum ( fun a _ => show 0 ≤ ( P ^ m ) i a from by
                                                            apply MarkovTropicalBridge.pow_entry_nonneg <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
                                                            exact hrow.1 ) ( Finset.mem_univ j )

/-
Row sums are preserved under matrix powers.
-/
lemma pow_row_sum_eq_one
    (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (m : ℕ) (i : Fin (n+1)) :
    ∑ j, (P ^ m) i j = 1 := by
  have h_sum_transpose : ∀ m : ℕ, ∀ i : Fin (n + 1), ∑ j, (P ^ m) i j = 1 := by
    intro m i; induction' m with m ih generalizing i <;> simp_all +decide [ pow_succ', Matrix.mul_apply, Finset.mul_sum _ _ _, Finset.sum_mul ] ;
    · simp +decide [ Matrix.one_apply ];
    · rw [ Finset.sum_comm ];
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hrow.2, ih ];
  convert h_sum_transpose m i using 1

/-- Powers of row-stochastic matrices are row-stochastic. -/
lemma pow_rowStochastic
    (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (m : ℕ) :
    RowStochastic (P ^ m) :=
  ⟨fun i j => pow_entry_nonneg hrow.1 m i j, pow_row_sum_eq_one P hrow m⟩

/-! ## Positivity of tropical cycle mean -/

/-
**Positivity from mixing.**
If there exist `m ≥ 1` and `α < 1` such that all `m`-step transition
probabilities are at most `α`, then the tropical cycle mean is
strictly positive.
-/
theorem positive_triangleCyc_of_mixing_bound
    (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    {m : ℕ} (hm : 1 ≤ m) {α : ℝ} (hα : 0 < α) (hα1 : α < 1)
    (hpow : ∀ i j, (P ^ m) i j ≤ α) :
    0 < triangleCyc (tropicalCost P) := by
  exact lt_of_lt_of_le ( by exact div_pos ( neg_pos_of_neg ( Real.log_neg hα hα1 ) ) ( by positivity ) ) ( multi_step_tropical_gap P hrow hpos α hα hα1 hm hpow )

/-! ## Mixing speed limit -/

/-
**Mixing speed limit.**
The tropical cycle mean sets a lower bound on how quickly transition
probabilities can decay. For any `m ≥ 1`, the best achievable uniform
mixing bound `α` satisfies `α ≥ exp(-m · triangleCyc(-log P))`.

Equivalently: `-log α ≤ m · triangleCyc(-log P)`.

This is just `multi_step_tropical_gap_mul` rephrased.
-/
theorem mixing_speed_limit
    {m : ℕ} (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    (α : ℝ) (hα : 0 < α) (hα1 : α < 1)
    (hm : 1 ≤ m)
    (hpow : ∀ i j, (P ^ m) i j ≤ α) :
    Real.exp (-(↑m * triangleCyc (tropicalCost P))) ≤ α := by
  convert Real.exp_le_exp.mpr ( neg_le_neg <| multi_step_tropical_gap_mul P hrow hpos α hα hα1 hm hpow ) using 1 ; norm_num [ Real.exp_neg, Real.exp_log hα ]

/-! ## Uniform ceiling from entry bounds -/

/-
**Uniform ceiling (entry-level).**
If ALL single-step entries satisfy `P i j ≤ 1/(n+1)`, then the tropical
cycle mean is at least `log(n+1)`. This is a direct corollary of
`one_step_tropical_gap`.
-/
theorem uniform_ceiling_from_entry_bound
    (P : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P)
    (hn : 0 < n)
    (hbound : ∀ i j, P i j ≤ 1 / (↑(n + 1) : ℝ)) :
    Real.log (↑(n + 1) : ℝ) ≤ triangleCyc (tropicalCost P) := by
  -- Apply one_step_tropical_gap with α = 1/(n+1).
  have := one_step_tropical_gap P hrow hpos (1 / (n + 1 : ℝ)) (by
  positivity) (by
  rw [ div_lt_iff₀ ] <;> norm_cast <;> linarith) (by
  aesop);
  convert this using 1 ; norm_num [ Real.log_div, Nat.cast_add_one_ne_zero ]

end MarkovTropicalBridge

end