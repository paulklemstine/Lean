/-
Copyright (c) 2025. All rights reserved.

# Log-Sum-Exp Duality (Finite Donsker–Varadhan Inequality)

This file proves the finite version of the Donsker–Varadhan variational formula,
which states that for probability distributions P, Q on a finite set and any
function f : Ω → ℝ:

  ∑ Q(p) * f(p) ≤ KL(Q ‖ P) + log(∑ P(p) * exp(f(p)))

This is the core engine of PAC-Bayesian learning theory.

## Main results

- `log_sum_exp_dual`: The finite Donsker–Varadhan variational inequality
- `pac_bayes_variational_bound`: Consequence for bounded moment generating functions
-/

import Bridges.PACBayes.KLDivergence

noncomputable section
open scoped BigOperators
open Finset Real

variable {Ω : Type*} [Fintype Ω]

/-
**Finite Donsker–Varadhan inequality** (log-sum-exp duality):
For probability distributions P, Q with P strictly positive, and any f : Ω → ℝ,
  ∑ Q(p) * f(p) ≤ KL(Q ‖ P) + log(∑ P(p) * exp(f(p)))

Proof strategy: Define the Gibbs measure G(p) = P(p)*exp(f(p))/Z. Then
KL(Q ‖ P) + log Z = KL(Q ‖ G) + ∑ Q(p)*f(p). Since KL(Q ‖ G) ≥ 0,
the result follows.
-/
theorem log_sum_exp_dual
    (P Q : Ω → ℝ)
    (hP : IsProb P) (hQ : IsProb Q)
    (hPpos : ∀ p, 0 < P p)
    (f : Ω → ℝ) :
    ∑ p, Q p * f p ≤ klDiv Q P + Real.log (∑ p, P p * Real.exp (f p)) := by
  -- By definition of the Gibbs measure, we have that $G(p) = \frac{P(p) \exp(f(p))}{Z}$ where $Z = \sum P(q) \exp(f(q))$.
  set G : Ω → ℝ := fun p => P p * Real.exp (f p) / (∑ q, P q * Real.exp (f q)) with hG_def
  have hG_prob : IsProb G := by
    constructor;
    · exact fun p => div_nonneg ( mul_nonneg ( le_of_lt ( hPpos p ) ) ( Real.exp_nonneg _ ) ) ( Finset.sum_nonneg fun _ _ => mul_nonneg ( le_of_lt ( hPpos _ ) ) ( Real.exp_nonneg _ ) );
    · rw [ ← Finset.sum_div, div_self ];
      exact ne_of_gt ( Finset.sum_pos ( fun _ _ => mul_pos ( hPpos _ ) ( Real.exp_pos _ ) ) ⟨ Classical.choose ( Finset.nonempty_of_sum_ne_zero ( by rw [ hP.2 ] ; norm_num ) ), Finset.mem_univ _ ⟩ );
  have h_kl_div_G : ∑ p, Q p * Real.log (Q p / G p) = ∑ p, Q p * Real.log (Q p / P p) - ∑ p, Q p * f p + Real.log (∑ p, P p * Real.exp (f p)) := by
    have h_kl_div_G : ∀ p, Q p * Real.log (Q p / G p) = Q p * (Real.log (Q p / P p) - f p + Real.log (∑ q, P q * Real.exp (f q))) := by
      intro p; by_cases hp : Q p = 0 <;> simp +decide [ hp, hG_def, Real.log_div, ne_of_gt ( hPpos _ ), ne_of_gt ( Real.exp_pos _ ), ne_of_gt ( Finset.sum_pos ( fun q _ => mul_pos ( hPpos q ) ( Real.exp_pos ( f q ) ) ) ⟨ p, Finset.mem_univ p ⟩ ) ] ; ring;
      rw [ Real.log_mul ( ne_of_gt ( hPpos p ) ) ( ne_of_gt ( Real.exp_pos _ ) ), Real.log_exp ] ; ring;
    simp +decide only [h_kl_div_G, mul_add, mul_sub, sum_add_distrib, sum_sub_distrib];
    simp +decide [ ← Finset.sum_mul _ _ _, hQ.2 ];
  have h_kl_div_G_nonneg : 0 ≤ ∑ p, Q p * Real.log (Q p / G p) := by
    convert klDiv_nonneg G Q hG_prob hQ _ using 1;
    · exact Finset.sum_congr rfl fun p _ => by aesop;
    · exact fun p => div_pos ( mul_pos ( hPpos p ) ( Real.exp_pos _ ) ) ( Finset.sum_pos ( fun q _ => mul_pos ( hPpos q ) ( Real.exp_pos _ ) ) ⟨ p, Finset.mem_univ p ⟩ );
  unfold klDiv; simp_all +decide [ mul_div_cancel₀, ne_of_gt ] ;
  exact le_of_sub_nonneg ( by rw [ show ( ∑ p : Ω, if Q p = 0 then 0 else Q p * Real.log ( Q p / P p ) ) = ∑ p : Ω, Q p * Real.log ( Q p / P p ) by exact Finset.sum_congr rfl fun _ _ => by aesop ] ; linarith )

/-
**PAC-Bayes variational bound**: If the moment generating function under P
is bounded by C, then the expected value under Q is bounded by KL + log C.
-/
theorem pac_bayes_variational_bound
    (P Q : Ω → ℝ)
    (hP : IsProb P) (hQ : IsProb Q)
    (g : Ω → ℝ)
    (C : ℝ)
    (hexp : ∑ p, P p * Real.exp (g p) ≤ C)
    (hPpos : ∀ p, 0 < P p)
    (hC : 0 < C) :
    ∑ p, Q p * g p ≤ klDiv Q P + Real.log C := by
  convert log_sum_exp_dual P Q hP hQ hPpos g |> le_trans <| ?_;
  exact add_le_add le_rfl ( Real.log_le_log ( Finset.sum_pos ( fun _ _ => mul_pos ( hPpos _ ) ( Real.exp_pos _ ) ) ⟨ Classical.choose ( Finset.exists_ne_zero_of_sum_ne_zero ( by linarith [ hP.2 ] : ( ∑ p : Ω, P p ) ≠ 0 ) ), Finset.mem_univ _ ⟩ ) hexp )

end