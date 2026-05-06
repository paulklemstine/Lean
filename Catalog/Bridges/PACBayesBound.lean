/-
Copyright (c) 2025. All rights reserved.

# PAC-Bayesian Generalization Bound

This file derives the PAC-Bayesian generalization bound from the variational
inequality, providing a bridge from empirical risk to true risk via KL divergence.

## Main results

- `square_root_bound_from_beta`: The calculus lemma for optimizing over β
- `pac_bayes_prime_spectral_bound_of_mgf`: PAC-Bayes bound conditional on MGF control
-/

import Bridges.PACBayes.GibbsPosterior

noncomputable section
open scoped BigOperators
open Finset Real

variable {Ω : Type*} [Fintype Ω]

/-
**Square root optimization lemma**: If `t ≤ a/β + β*b` for all `β > 0`,
then `t ≤ 2 * sqrt(a * b)`.

This is the calculus step that converts the exponential variational bound
into the standard PAC-Bayes square-root form.
-/
theorem square_root_bound_from_beta
    {a b t : ℝ} (ha : 0 ≤ a) (hb : 0 < b)
    (ht : ∀ β : ℝ, 0 < β → t ≤ a / β + β * b) :
    t ≤ 2 * Real.sqrt (a * b) := by
  by_cases ha_pos : 0 < a;
  · convert ht ( Real.sqrt ( a / b ) ) ( Real.sqrt_pos.mpr ( div_pos ha_pos hb ) ) using 1 ; ring;
    -- Simplifying the right-hand side:
    field_simp
    ring;
    rw [ Real.sq_sqrt ( by positivity ) ] ; rw [ ← Real.sqrt_mul ( by positivity ) ] ; ring_nf ; norm_num [ ha_pos.le, hb.le, ha_pos.ne', hb.ne' ] ; ring;
  · contrapose! ht;
    norm_num [ show a = 0 by linarith ] at *;
    exact ⟨ t / ( 2 * b ), by positivity, by nlinarith [ mul_div_cancel₀ t ( by positivity : ( 2 * b ) ≠ 0 ) ] ⟩

/-- The true risk averaged over primes. -/
def trueRiskPrimeAverage {S : Type*} {n : ℕ}
    (D : Dataset S n) (Q : Ω → ℝ) (loss : LossFn S Ω) : ℝ :=
  ∑ p, Q p * semanticGap loss D p

/-
**PAC-Bayes prime-spectral bound (conditional on MGF control)**:
Given control on the moment generating function of the generalization gap,
the true risk is bounded by the empirical risk plus a complexity term
involving the KL divergence.

This isolates the only genuinely probabilistic ingredient (the MGF bound)
into a single hypothesis, making the rest of the argument purely algebraic.
-/
theorem pac_bayes_prime_spectral_bound_of_mgf {S : Type*} {n : ℕ}
    (P Q : Ω → ℝ) (hP : IsProb P) (hQ : IsProb Q)
    (hPpos : ∀ p, 0 < P p)
    (loss : LossFn S Ω) (D : Dataset S n)
    (hn : 0 < n)
    (δ : ℝ) (_hδ : 0 < δ)
    (hmgf : ∑ p, P p * Real.exp (2 * ↑n *
      (trueRiskPrimeAverage D Q loss - empiricalRisk D Q loss) ^ 2) ≤ 1 / δ) :
    trueRiskPrimeAverage D Q loss ≤
      empiricalRisk D Q loss +
        Real.sqrt ((klDiv Q P + Real.log (1 / δ)) / (2 * ↑n)) := by
  -- By dividing both sides of the inequality by $2n$, we obtain the desired result.
  have h_div : (trueRiskPrimeAverage D Q loss - empiricalRisk D Q loss) ^ 2 ≤ (klDiv Q P + Real.log (1 / δ)) / (2 * n) := by
    have h_div : 2 * n * (trueRiskPrimeAverage D Q loss - empiricalRisk D Q loss)^2 ≤ Real.log (1 / δ) := by
      have h_exp : Real.exp (2 * n * (trueRiskPrimeAverage D Q loss - empiricalRisk D Q loss)^2) ≤ 1 / δ := by
        simp_all +decide [ ← Finset.sum_mul _ _ _ ];
        exact le_trans ( le_mul_of_one_le_left ( Real.exp_nonneg _ ) ( by rw [ hP.2 ] ) ) hmgf;
      simpa using Real.log_le_log ( by positivity ) h_exp;
    rw [ le_div_iff₀ ] <;> nlinarith [ show ( n : ℝ ) > 0 by positivity, klDiv_nonneg P Q hP hQ hPpos ];
  nlinarith [ Real.sqrt_nonneg ( ( klDiv Q P + Real.log ( 1 / δ ) ) / ( 2 * n ) ), Real.mul_self_sqrt ( show 0 ≤ ( klDiv Q P + Real.log ( 1 / δ ) ) / ( 2 * n ) by exact le_trans ( sq_nonneg _ ) h_div ) ]

end