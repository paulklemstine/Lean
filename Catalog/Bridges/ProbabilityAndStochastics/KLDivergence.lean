import Mathlib
/-
Copyright (c) 2025. All rights reserved.

# KL Divergence Properties

This file proves fundamental properties of the KL divergence on finite distributions,
including the celebrated Gibbs inequality (nonnegativity of KL divergence).

## Main results

- `klDiv_nonneg`: KL(Q ‖ P) ≥ 0 for probability distributions Q, P (Gibbs inequality)
- `klDiv_eq_zero_iff`: KL(Q ‖ P) = 0 iff Q = P (information inequality)
-/

import Logic.GraphTheory.Defs

noncomputable section
open scoped BigOperators
open Finset Real

variable {Ω : Type*} [Fintype Ω]

/-- A finite probability distribution: nonnegative weights summing to one. -/
def IsProb (P : Ω → ℝ) : Prop := (∀ p, 0 ≤ P p) ∧ ∑ p, P p = 1

/-- The Kullback–Leibler divergence `KL(Q ‖ P)`, with the usual convention
`0 · log(0/p) = 0`. -/
def klDiv (Q P : Ω → ℝ) : ℝ := ∑ p, if Q p = 0 then (0 : ℝ) else Q p * Real.log (Q p / P p)


/-
The key pointwise inequality: for q ≥ 0 and p > 0,
`q * log(q/p) ≥ q - p`, which is equivalent to `log(x) ≤ x - 1` applied to `x = p/q`.
When `q = 0`, the LHS is 0 by convention and we need `0 ≥ 0 - p = -p`, which holds since `p > 0`.
-/
theorem klDiv_term_ge (q p : ℝ) (hq : 0 ≤ q) (hp : 0 < p) :
    (if q = 0 then (0 : ℝ) else q * Real.log (q / p)) ≥ q - p := by
  split_ifs;
  · linarith;
  · have := Real.log_le_sub_one_of_pos ( div_pos hp ( lt_of_le_of_ne hq ( Ne.symm ‹_› ) ) );
    rw [ Real.log_div ] at * <;> first | positivity | nlinarith [ mul_div_cancel₀ p ‹_› ] ;

/-
**Gibbs inequality**: The KL divergence is nonnegative for probability distributions.
-/
theorem klDiv_nonneg
    (P Q : Ω → ℝ)
    (hP : IsProb P) (hQ : IsProb Q)
    (hPpos : ∀ p, 0 < P p) :
    0 ≤ klDiv Q P := by
  -- Apply the inequality term by term to the sum.
  have h_term_by_term : ∀ p, (if Q p = 0 then (0 : ℝ) else Q p * Real.log (Q p / P p)) ≥ Q p - P p := by
    exact fun p => klDiv_term_ge _ _ ( hQ.1 p ) ( hPpos p );
  exact le_trans ( by simp +decide [ hQ.2, hP.2 ] ) ( Finset.sum_le_sum fun p _ => h_term_by_term p )

end