/-
# Discrete Optimal Transport: Foundations

This module establishes the foundational definitions for discrete optimal transport
on finite types. We define finitely supported probability distributions, couplings
(transport plans), transport cost, dual potentials, and the key structures needed
for Kantorovich duality and Wasserstein geometry.
-/
import Mathlib

open Finset BigOperators

/-! ## Finite Probability Distributions -/

/-- A finitely supported probability distribution on a finite type `α`.
    Encodes a nonnegative weight function summing to 1. -/
structure FinProb (α : Type*) [Fintype α] where
  weight : α → ℝ
  nonneg : ∀ a, 0 ≤ weight a
  sum_eq_one : ∑ a, weight a = 1

/-! ## Couplings (Transport Plans) -/

/-- A coupling between two finite probability distributions `μ` and `ν`.
    The mass function `mass a b` represents the amount of probability transported
    from point `a` to point `b`. The marginal constraints ensure consistency
    with the source and target distributions. -/
structure Coupling {α β : Type*} [Fintype α] [Fintype β]
    (μ : FinProb α) (ν : FinProb β) where
  mass : α → β → ℝ
  nonneg : ∀ a b, 0 ≤ mass a b
  left_marginal : ∀ a, ∑ b, mass a b = μ.weight a
  right_marginal : ∀ b, ∑ a, mass a b = ν.weight b

/-! ## Transport Cost -/

/-- The total transport cost of a coupling `π` with respect to cost function `c`.
    This is the expected cost `𝔼_{(a,b)∼π}[c(a,b)]`. -/
def transportCost {α β : Type*} [Fintype α] [Fintype β]
    (c : α → β → ℝ) {μ : FinProb α} {ν : FinProb β}
    (π : Coupling μ ν) : ℝ :=
  ∑ a, ∑ b, c a b * π.mass a b

/-! ## Dual Potentials -/

/-- Admissibility of dual potentials: `φ a + ψ b ≤ c a b` for all `a, b`. -/
def admissiblePotential {α β : Type*} [Fintype α] [Fintype β]
    (c : α → β → ℝ) (φ : α → ℝ) (ψ : β → ℝ) : Prop :=
  ∀ a b, φ a + ψ b ≤ c a b

/-- The dual objective value for potentials `(φ, ψ)`:
    `∑_a φ(a) μ(a) + ∑_b ψ(b) ν(b)`. -/
def dualValue {α β : Type*} [Fintype α] [Fintype β]
    (μ : FinProb α) (ν : FinProb β)
    (φ : α → ℝ) (ψ : β → ℝ) : ℝ :=
  ∑ a, φ a * μ.weight a + ∑ b, ψ b * ν.weight b

/-! ## Lipschitz Critics and Adversarial Gaps -/

/-- A family of functions `F` is `K`-Lipschitz with respect to distance `d`. -/
def isKLipschitzFamily {α : Type*} [Fintype α]
    (d : α → α → ℝ) (K : ℝ) (F : Set (α → ℝ)) : Prop :=
  ∀ f ∈ F, ∀ a b, |f a - f b| ≤ K * d a b

/-- The critic gap (integral probability metric) between distributions `μ` and `ν`
    over a function family `F`:
    `sup_{f ∈ F} (𝔼_μ[f] - 𝔼_ν[f])`. -/
noncomputable def criticGap {α : Type*} [Fintype α]
    (μ ν : FinProb α) (F : Set (α → ℝ)) : ℝ :=
  sSup {r : ℝ | ∃ f ∈ F, (∑ a, f a * μ.weight a) - (∑ a, f a * ν.weight a) = r}

/-! ## Product Coupling -/

/-- The product (independent) coupling of `μ` and `ν`. This always exists and
    serves as a witness for nonemptiness of the coupling set. -/
def productCoupling {α β : Type*} [Fintype α] [Fintype β]
    (μ : FinProb α) (ν : FinProb β) : Coupling μ ν where
  mass a b := μ.weight a * ν.weight b
  nonneg a b := mul_nonneg (μ.nonneg a) (ν.nonneg b)
  left_marginal a := by
    simp only [← Finset.mul_sum]
    rw [ν.sum_eq_one, mul_one]
  right_marginal b := by
    simp only [mul_comm _ (ν.weight b), ← Finset.mul_sum]
    rw [μ.sum_eq_one, mul_one]