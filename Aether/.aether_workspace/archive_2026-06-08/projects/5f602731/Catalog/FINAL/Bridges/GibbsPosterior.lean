/-
Copyright (c) 2025. All rights reserved.

# Gibbs Posterior Properties and Variational Optimality

This file proves that the Gibbs posterior is a valid probability distribution
and that it minimizes the free energy functional among all posteriors.

## Main results

- `gibbsZ_pos`: The partition function is strictly positive
- `gibbsMeasure_isProb`: The Gibbs measure is a valid probability distribution
- `gibbsPosterior_isProb`: The Gibbs posterior is a valid probability distribution
- `gibbs_minimizes_free_energy`: The Gibbs posterior minimizes empirical risk + (1/β) * KL
- `prime_spectral_gibbs_variational_principle`: The full variational principle
-/

import Bridges.PACBayes.LogSumExpDual

noncomputable section
open scoped BigOperators
open Finset Real

variable {Ω : Type*} [Fintype Ω]

/-
The partition function is strictly positive when the prior is strictly positive.
-/
theorem gibbsZ_pos (P : Ω → ℝ) (hP : IsProb P) (hPpos : ∀ p, 0 < P p) (f : Ω → ℝ) :
    0 < gibbsZ P f := by
  apply_rules [ Finset.sum_pos ];
  · exact fun p _ => mul_pos ( hPpos p ) ( Real.exp_pos _ );
  · have := hP.2; contrapose! this; aesop

/-
The Gibbs measure is a valid probability distribution.
-/
theorem gibbsMeasure_isProb (P : Ω → ℝ) (hP : IsProb P) (hPpos : ∀ p, 0 < P p)
    (f : Ω → ℝ) :
    IsProb (gibbsMeasure P f) := by
  refine' ⟨ fun p => _, _ ⟩;
  · exact div_nonneg ( mul_nonneg ( le_of_lt ( hPpos p ) ) ( Real.exp_nonneg _ ) ) ( Finset.sum_nonneg fun _ _ => mul_nonneg ( le_of_lt ( hPpos _ ) ) ( Real.exp_nonneg _ ) );
  · unfold gibbsMeasure;
    rw [ ← Finset.sum_div, div_eq_iff ];
    · simp [gibbsZ];
    · exact ne_of_gt ( gibbsZ_pos P hP hPpos f )

/-- The Gibbs posterior is a valid probability distribution. -/
theorem gibbsPosterior_isProb {S : Type*} {n : ℕ}
    (P : Ω → ℝ) (hP : IsProb P) (hPpos : ∀ p, 0 < P p)
    (loss : LossFn S Ω) (D : Dataset S n) (β : ℝ) :
    IsProb (gibbsPosterior P loss D β) :=
  gibbsMeasure_isProb P hP hPpos _

/-! ## Free energy and variational optimality -/

/-- The free energy functional: empirical risk + (1/β) * KL divergence from prior. -/
def freeEnergy {S : Type*} {n : ℕ}
    (D : Dataset S n) (Q : Ω → ℝ) (loss : LossFn S Ω) (P : Ω → ℝ) (β : ℝ) : ℝ :=
  empiricalRisk D Q loss + (1 / β) * klDiv Q P

/-
The empirical risk can be written as a sum involving the semantic gap.
-/
theorem empiricalRisk_eq_sum_semanticGap {S : Type*} {n : ℕ}
    (D : Dataset S n) (Q : Ω → ℝ) (loss : LossFn S Ω) :
    empiricalRisk D Q loss = ∑ p, Q p * semanticGap loss D p := by
  unfold empiricalRisk semanticGap;
  unfold expectedRisk; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ] ;
  exact Finset.sum_comm

/-
**Gibbs variational optimality**: The Gibbs posterior minimizes the free energy
functional `empiricalRisk(Q) + (1/β) * KL(Q ‖ P)` among all probability distributions Q.

This is the central theorem connecting proof semantics to statistical mechanics.
-/
theorem gibbs_minimizes_free_energy {S : Type*} {n : ℕ}
    (P : Ω → ℝ) (hP : IsProb P) (hPpos : ∀ p, 0 < P p)
    (loss : LossFn S Ω) (D : Dataset S n) (β : ℝ) (hβ : 0 < β) :
    ∀ Q, IsProb Q →
      freeEnergy D (gibbsPosterior P loss D β) loss P β ≤ freeEnergy D Q loss P β := by
  unfold freeEnergy gibbsPosterior;
  intro Q hQ
  have h_log_sum_exp : ∑ p, Q p * (-β * semanticGap loss D p) ≤ klDiv Q P + Real.log (∑ p, P p * Real.exp (-β * semanticGap loss D p)) := by
    exact log_sum_exp_dual P Q hP hQ hPpos _;
  have h_log_sum_exp_gibbs : ∑ p, (gibbsMeasure P (fun p => -β * semanticGap loss D p)) p * (-β * semanticGap loss D p) = klDiv (gibbsMeasure P (fun p => -β * semanticGap loss D p)) P + Real.log (∑ p, P p * Real.exp (-β * semanticGap loss D p)) := by
    unfold klDiv gibbsMeasure;
    unfold gibbsZ; simp +decide [ Finset.sum_div _ _ _, mul_div_assoc, ne_of_gt ( hPpos _ ), Real.exp_ne_zero ] ;
    split_ifs <;> simp_all +decide [ Finset.sum_div _ _ _, mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv, Real.log_mul, ne_of_gt, Real.exp_pos ];
    simp +decide [ mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib, ‹_› ];
    simp +decide [ ← mul_assoc, ← Finset.sum_mul _ _ _, ‹_› ];
  simp_all +decide [ empiricalRisk_eq_sum_semanticGap, div_eq_inv_mul, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ];
  field_simp;
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] at * ; nlinarith

/-
**Prime-spectral Gibbs variational principle**: The Gibbs posterior on any finite
type (in particular the prime spectrum of a proof semiring) satisfies:
1. It is a valid probability distribution.
2. For any other distribution Q, the free energy of the Gibbs posterior is at most
   that of Q. Equivalently, ∑ Q(p)*E(p) + (1/β)*KL(Q‖P) ≥ -(1/β)*log Z.
-/
theorem prime_spectral_gibbs_variational_principle
    (P : Ω → ℝ)
    (hP : IsProb P)
    (hPpos : ∀ p, 0 < P p)
    (E : Ω → ℝ)
    (β : ℝ) (hβ : 0 < β) :
    IsProb (gibbsMeasure P (fun p => -β * E p)) ∧
    ∀ Q, IsProb Q →
      (∑ p, Q p * E p) + (1 / β) * klDiv Q P
        ≥ -(1 / β) * Real.log (∑ p, P p * Real.exp (-β * E p)) := by
  refine' ⟨ gibbsMeasure_isProb _ hP hPpos _, fun Q hQ => _ ⟩;
  have := log_sum_exp_dual P Q hP hQ hPpos ( fun p => -β * E p );
  simp_all +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, mul_comm, div_eq_inv_mul ];
  rw [ ← Finset.mul_sum _ _ _ ] at * ; nlinarith [ inv_pos.2 hβ, mul_inv_cancel_left₀ hβ.ne' ( ∑ x : Ω, Q x * E x ), mul_inv_cancel_left₀ hβ.ne' ( klDiv Q P ), mul_inv_cancel_left₀ hβ.ne' ( Real.log ( ∑ x : Ω, P x * Real.exp ( - ( β * E x ) ) ) ) ]

end