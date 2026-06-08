/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# PAC-Bayes Generalization Theory: Core Definitions

This file defines the fundamental objects for PAC-Bayes generalization bounds:
- Empirical and true risks for deterministic predictors
- Gibbs (posterior-averaged) risks
- KL divergence for finite distributions
- Bernoulli KL divergence
- Gaussian shift complexity

These definitions form the foundation for the McAllester bound, Catoni bound,
Gaussian perturbation bounds, and asymptotic tightness theorems.
-/
import Mathlib

open Real BigOperators Finset

noncomputable section

namespace PACBayes

/-! ## Section 1: Finite Probability Distributions -/

/-- A finite probability distribution over a finite type, represented as a
    function summing to 1 with all nonneg values. -/
structure FinDist (α : Type*) [Fintype α] where
  prob : α → ℝ
  prob_nonneg : ∀ a, 0 ≤ prob a
  prob_sum_one : ∑ a : α, prob a = 1

/-- The uniform distribution over a nonempty finite type. -/
def FinDist.uniform (α : Type*) [Fintype α] [Nonempty α] : FinDist α where
  prob := fun _ => 1 / Fintype.card α
  prob_nonneg := fun _ => by positivity
  prob_sum_one := by simp [Finset.card_univ]

/-! ## Section 2: Risk Definitions -/

/-- Empirical risk of a hypothesis θ on a sample S : Fin n → α. -/
def empiricalRisk {α : Type*} (loss : α → ℝ) (S : Fin n → α) : ℝ :=
  (∑ i : Fin n, loss (S i)) / n

/-- True (population) risk under a distribution. -/
def trueRisk {α : Type*} [Fintype α] (loss : α → ℝ) (dist : FinDist α) : ℝ :=
  ∑ a : α, dist.prob a * loss a

/-- Gibbs (posterior-averaged) empirical risk. -/
def empiricalGibbsRisk {α Θ : Type*} [Fintype Θ]
    (loss : α → Θ → ℝ) (Q : FinDist Θ) (S : Fin n → α) : ℝ :=
  ∑ θ : Θ, Q.prob θ * empiricalRisk (fun a => loss a θ) S

/-- Gibbs (posterior-averaged) true risk under a data distribution. -/
def trueGibbsRisk {α Θ : Type*} [Fintype α] [Fintype Θ]
    (loss : α → Θ → ℝ) (dist : FinDist α) (Q : FinDist Θ) : ℝ :=
  ∑ θ : Θ, Q.prob θ * trueRisk (fun a => loss a θ) dist

/-! ## Section 3: KL Divergence for Finite Distributions -/

/-- KL divergence between two finite distributions.
    KL(Q ‖ P) = ∑_x Q(x) * log(Q(x) / P(x))
    We define this only when both distributions are supported on the same set. -/
def klFinDist {α : Type*} [Fintype α] (Q P : FinDist α) : ℝ :=
  ∑ a : α, if Q.prob a = 0 then 0
            else Q.prob a * Real.log (Q.prob a / P.prob a)

/-! ## Section 4: Bernoulli KL Divergence -/

/-- Bernoulli KL divergence: KL(Ber(p) ‖ Ber(q)).
    For p, q ∈ (0,1):
    KL = p * log(p/q) + (1-p) * log((1-p)/(1-q)) -/
def klBernoulli (p q : ℝ) : ℝ :=
  if p = 0 then -Real.log (1 - q)
  else if p = 1 then -Real.log q
  else p * Real.log (p / q) + (1 - p) * Real.log ((1 - p) / (1 - q))

/-! ## Section 5: Gaussian Shift Complexity -/

/-- The KL divergence between N(w, σ²I) and N(0, σ²I) in d dimensions.
    Equal to ‖w‖² / (2σ²). -/
def gaussianShiftKL (d : ℕ) (w : Fin d → ℝ) (σ : ℝ) : ℝ :=
  (∑ i : Fin d, (w i)^2) / (2 * σ^2)

/-- The full KL divergence between N(w, σ²I) and N(0, τ²I) in d dimensions.
    Equal to d/2 * (σ²/τ² - 1 - log(σ²/τ²)) + ‖w‖² / (2τ²). -/
def gaussianShiftKLFull (d : ℕ) (w : Fin d → ℝ) (σ τ : ℝ) : ℝ :=
  (d : ℝ) / 2 * (σ^2 / τ^2 - 1 - Real.log (σ^2 / τ^2)) + (∑ i : Fin d, (w i)^2) / (2 * τ^2)

/-- Gaussian shift complexity: the PAC-Bayes complexity term for
    posterior N(w, σ²I) and prior N(0, τ²I).
    This is the quantity that appears in the PAC-Bayes bound divided by n. -/
def gaussianShiftComplexity (d : ℕ) (w : Fin d → ℝ) (σ τ : ℝ) (n : ℕ) (δ : ℝ) : ℝ :=
  (gaussianShiftKLFull d w σ τ + Real.log (2 * Real.sqrt n / δ)) / n

/-! ## Section 6: Perturbation Risk Definitions -/

/-- The perturbation penalty: how much the loss changes when parameters are perturbed.
    For a predictor f : (Fin d → ℝ) → α → ℝ with loss function. -/
def perturbationPenalty {α : Type*} [Fintype α] (d : ℕ)
    (_loss : α → ℝ → ℝ) (f : (Fin d → ℝ) → α → ℝ)
    (w : Fin d → ℝ) (σ : ℝ) (dist : FinDist α) : ℝ :=
  σ * ∑ a : α, dist.prob a * ∑ i : Fin d,
    |f (Function.update w i (w i + σ)) a - f w a| / σ

/-! ## Section 7: PAC-Bayes Bound Structures -/

/-- A PAC-Bayes bound configuration. -/
structure PACBayesBound where
  /-- Number of training samples -/
  n : ℕ
  /-- Confidence parameter -/
  δ : ℝ
  /-- KL divergence between posterior and prior -/
  kl : ℝ
  /-- Empirical Gibbs risk -/
  empRisk : ℝ
  /-- Proof that n ≥ 1 -/
  hn : 1 ≤ n
  /-- Proof that δ ∈ (0, 1) -/
  hδ0 : 0 < δ
  hδ1 : δ < 1
  /-- KL is nonneg -/
  hkl : 0 ≤ kl
  /-- Empirical risk in [0,1] -/
  hrisk0 : 0 ≤ empRisk
  hrisk1 : empRisk ≤ 1

/-- McAllester-style generalization bound: the bound on population risk. -/
def PACBayesBound.mcAllesterBound (b : PACBayesBound) : ℝ :=
  b.empRisk + Real.sqrt ((b.kl + Real.log (2 * Real.sqrt b.n / b.δ)) / (2 * b.n))

/-- Catoni-style generalization bound with parameter λ > 0. -/
def PACBayesBound.catoniBound (b : PACBayesBound) (lam : ℝ) : ℝ :=
  (1 / (1 - Real.exp (-lam))) *
    (1 - Real.exp (-lam * b.empRisk - (b.kl + Real.log (1 / b.δ)) / b.n))

end PACBayes

end