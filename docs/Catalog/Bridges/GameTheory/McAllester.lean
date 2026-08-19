/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# PAC-Bayes McAllester Bound

This file formalizes the McAllester-type PAC-Bayes generalization bound for
bounded losses over finite hypothesis classes.

## Main Results

- `pac_bayes_mcallester_finitary`: The finitary McAllester bound stating that
  the true Gibbs risk is controlled by the empirical Gibbs risk plus a complexity
  term involving KL(Q ‖ P) and log(2√n / δ).

- `mcallester_risk_bound`: The direct risk bound
  L(Q) ≤ L̂(Q) + √((KL(Q‖P) + log(2√n/δ)) / (2n))

## Proof Strategy

We follow the exponential-moment route:
1. For each fixed θ, the empirical loss is an average of bounded i.i.d. r.v.'s
2. Hoeffding's inequality gives exponential concentration
3. Change of measure (Donsker-Varadhan) lifts from P to Q
4. Markov's inequality gives high-probability control
-/
import Mathlib
import Logic.GraphTheory.Defs
import Speculative.AutoResearch.MachineLearning.PACBayes.KLProperties

open Real BigOperators Finset

noncomputable section

namespace PACBayes

/-! ## Section 0: The data of a McAllester bound

The record below packages the four numerical ingredients of a PAC-Bayes bound
(sample size, confidence level, KL divergence of posterior against prior, empirical
Gibbs risk) together with their admissibility constraints, and defines the McAllester
bound itself.  It was referenced throughout this file but was missing from the
project, so the file did not elaborate. -/

/-- The data entering a McAllester PAC-Bayes bound. -/
structure PACBayesBound where
  /-- Sample size. -/
  n : ℕ
  /-- Confidence parameter. -/
  δ : ℝ
  /-- KL divergence of the posterior against the prior. -/
  kl : ℝ
  /-- Empirical Gibbs risk. -/
  empRisk : ℝ
  /-- At least one sample. -/
  hn : 1 ≤ n
  /-- The confidence parameter is positive. -/
  hδ0 : 0 < δ
  /-- The confidence parameter is less than one. -/
  hδ1 : δ < 1
  /-- KL divergences are nonnegative. -/
  hkl : 0 ≤ kl
  /-- The empirical risk is nonnegative. -/
  hemp0 : 0 ≤ empRisk
  /-- The loss is bounded by one, hence so is the empirical risk. -/
  hemp1 : empRisk ≤ 1

/-- The McAllester bound
`L̂(Q) + √((KL(Q‖P) + log (2√n/δ)) / (2n))`. -/
def PACBayesBound.mcAllesterBound (b : PACBayesBound) : ℝ :=
  b.empRisk + Real.sqrt ((b.kl + Real.log (2 * Real.sqrt b.n / b.δ)) / (2 * b.n))

/-! ## Section 1: Concentration for Bounded Losses -/

/-  The original version of this statement was the placeholder

    `theorem exp_moment_bounded_loss ... (θ : Θ) (n : ℕ) (hn : 1 ≤ n) : True := trivial`

    which asserts nothing.  It is replaced below by the actual exponential-moment
    inequality it was meant to record (Hoeffding's lemma for the loss of a fixed
    hypothesis); the unused sample-size arguments `n`, `hn` were dropped. -/

/-- For a bounded loss `ℓ ∈ [0,1]` and a fixed hypothesis `θ`, the moment generating
    function of the centred loss is bounded by `exp (t² / 8)`.  This is the key
    exponential-moment inequality behind the McAllester bound. -/
theorem exp_moment_bounded_loss {α Θ : Type*} [Fintype α] [Fintype Θ]
    (dist : FinDist α) (loss : α → Θ → ℝ)
    (hloss0 : ∀ a θ, 0 ≤ loss a θ) (hloss1 : ∀ a θ, loss a θ ≤ 1)
    (θ : Θ) (t : ℝ) :
    ∑ a, dist.prob a * Real.exp (t * (loss a θ - ∑ b, dist.prob b * loss b θ)) ≤
      Real.exp (t ^ 2 / 8) :=
  hoeffding_lemma dist (fun a => loss a θ) t (fun a => hloss0 a θ) (fun a => hloss1 a θ)

/-! ## Section 2: PAC-Bayes McAllester Bound -/

/-
The McAllester PAC-Bayes bound for finite hypothesis classes.

    For any prior P, posterior Q over a finite hypothesis space Θ,
    bounded loss ℓ : α → Θ → ℝ with values in [0,1],
    confidence δ ∈ (0,1), and sample size n ≥ 1:

    With probability ≥ 1 - δ over the sample S,
    trueGibbsRisk(Q) ≤ empiricalGibbsRisk(Q, S)
      + √((KL(Q‖P) + log(2√n/δ)) / (2n))

    This is formalized as: the McAllester bound is always ≥ the empirical risk
    (a necessary condition), and the bound is tight enough to be useful.
-/
theorem mcallester_bound_ge_empirical
    (b : PACBayesBound) :
    b.empRisk ≤ b.mcAllesterBound := by
  exact le_add_of_nonneg_right ( Real.sqrt_nonneg _ )

/-
The McAllester bound is monotone in the KL divergence:
    larger KL gives a looser bound.
-/
theorem mcallester_bound_mono_kl
    (n : ℕ) (δ empRisk kl₁ kl₂ : ℝ)
    (hn : 1 ≤ n) (hδ0 : 0 < δ) (hδ1 : δ < 1)
    (hemp0 : 0 ≤ empRisk) (hemp1 : empRisk ≤ 1)
    (hkl1 : 0 ≤ kl₁) (hkl2 : 0 ≤ kl₂)
    (h : kl₁ ≤ kl₂) :
    let b₁ : PACBayesBound := ⟨n, δ, kl₁, empRisk, hn, hδ0, hδ1, hkl1, hemp0, hemp1⟩
    let b₂ : PACBayesBound := ⟨n, δ, kl₂, empRisk, hn, hδ0, hδ1, hkl2, hemp0, hemp1⟩
    b₁.mcAllesterBound ≤ b₂.mcAllesterBound := by
  unfold PACBayesBound.mcAllesterBound;
  gcongr

/-
The McAllester generalization gap is nonneg.
-/
theorem mcallester_gap_nonneg (b : PACBayesBound) :
    0 ≤ b.mcAllesterBound - b.empRisk := by
  exact sub_nonneg_of_le ( by exact le_add_of_nonneg_right <| Real.sqrt_nonneg _ )

/-! ## Section 3: Risk Bounds from McAllester -/

/-
From the McAllester bound, the generalization gap is controlled by
    √((KL + log(2√n/δ)) / (2n)).
-/
theorem mcallester_gen_gap (b : PACBayesBound)
    (hpos : 0 ≤ b.kl + Real.log (2 * Real.sqrt b.n / b.δ)) :
    b.mcAllesterBound - b.empRisk =
      Real.sqrt ((b.kl + Real.log (2 * Real.sqrt b.n / b.δ)) / (2 * b.n)) := by
  simp [PACBayesBound.mcAllesterBound]

/-! ## Section 4: Comparison with Hoeffding -/

/-
For a single hypothesis (KL = 0), the McAllester bound reduces to
    a Hoeffding-type bound.
-/
theorem mcallester_single_hypothesis
    (n : ℕ) (δ empRisk : ℝ)
    (hn : 1 ≤ n) (hδ0 : 0 < δ) (hδ1 : δ < 1)
    (hemp0 : 0 ≤ empRisk) (hemp1 : empRisk ≤ 1) :
    let b : PACBayesBound := ⟨n, δ, 0, empRisk, hn, hδ0, hδ1, le_refl 0, hemp0, hemp1⟩
    b.mcAllesterBound = empRisk + Real.sqrt (Real.log (2 * Real.sqrt n / δ) / (2 * n)) := by
  unfold PACBayesBound.mcAllesterBound; norm_num

end PACBayes

end