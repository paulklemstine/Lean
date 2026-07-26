/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Finite policy-gradient and exploration-variance theorems

A self-contained finite-action formalization. Policies are differentiable
families of probability vectors. The score identity is represented without
logs by `∂p(a) = p(a) ψ(a)`.
-/
import Mathlib

namespace PolicyGradient

open scoped BigOperators

variable {n d : ℕ}

/-- Finite expectation with respect to a weight vector. -/
def expect (p f : Fin n → ℝ) : ℝ := ∑ a, p a * f a

/-- The second moment of a scalar importance-weighted estimator. -/
noncomputable def importanceSecondMoment (behavior target g : Fin n → ℝ) : ℝ :=
  ∑ a, behavior a * (target a / behavior a * g a) ^ 2

/-- Policy-gradient theorem for a finite action space. If the coordinatewise
policy derivative factors as probability times score, then the derivative of
the expected action value is the expected score-weighted action value. -/
theorem finite_policyGradient
    (policy : ℝ → Fin n → ℝ) (score Q : Fin n → ℝ) (θ : ℝ)
    (hderiv : ∀ a, HasDerivAt (fun t => policy t a)
      (policy θ a * score a) θ) :
    HasDerivAt (fun t => expect (policy t) Q)
      (expect (policy θ) (fun a => score a * Q a)) θ := by
  unfold expect
  have h := HasDerivAt.sum (fun a (_ : a ∈ Finset.univ) =>
    (hderiv a).mul_const (Q a))
  convert h using 1
  · ext t
    simp only [Finset.sum_apply]
  · apply Finset.sum_congr rfl
    intro a _
    ring

/-- Differentiating normalization gives the mean-zero score identity. -/
theorem score_mean_zero
    (policy : ℝ → Fin n → ℝ) (score : Fin n → ℝ) (θ : ℝ)
    (hnorm : ∀ t, ∑ a, policy t a = 1)
    (hderiv : ∀ a, HasDerivAt (fun t => policy t a)
      (policy θ a * score a) θ) :
    expect (policy θ) score = 0 := by
  have h1 : HasDerivAt (fun t => ∑ a, policy t a)
      (∑ a, policy θ a * score a) θ := by
    convert HasDerivAt.sum (fun a _ => hderiv a)
    simp
  have h2 : HasDerivAt (fun _ => (1 : ℝ)) 0 θ := hasDerivAt_const θ 1
  have hfun : (fun t => ∑ a, policy t a) = fun _ => (1 : ℝ) := funext hnorm
  rw [hfun] at h1
  exact h1.unique h2

/-- Subtracting an action-independent baseline does not bias a policy-gradient
coordinate when the score has mean zero. -/
theorem baseline_unbiased (p score Q : Fin n → ℝ) (b : ℝ)
    (hscore : expect p score = 0) :
    expect p (fun a => score a * (Q a - b)) =
      expect p (fun a => score a * Q a) := by
  unfold expect at *
  calc
    ∑ a, p a * (score a * (Q a - b)) =
        (∑ a, p a * (score a * Q a)) - b * (∑ a, p a * score a) := by
          rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
          apply Finset.sum_congr rfl
          intro a _
          ring
    _ = ∑ a, p a * (score a * Q a) := by rw [hscore, mul_zero, sub_zero]

/-- Coordinate form of compatible function approximation. If the advantage is
exactly `ψ(a)·w`, its policy gradient is the Fisher matrix applied to `w`. -/
theorem compatible_approximation
    (p : Fin n → ℝ) (ψ : Fin n → Fin d → ℝ) (w : Fin d → ℝ) (j : Fin d) :
    expect p (fun a => ψ a j * (∑ k, ψ a k * w k)) =
      ∑ k, (expect p (fun a => ψ a j * ψ a k)) * w k := by
  simp [expect, Finset.mul_sum, Finset.sum_mul]
  rw [Finset.sum_comm]
  simp [mul_comm, mul_left_comm]

/-- Exact `O(1/ε)` second-moment bound for importance weighting. The condition
`behavior ≥ ε·target` includes ε-greedy exploration relative to a target
policy, and the constant is explicit. -/
theorem importanceSecondMoment_le_inv_epsilon
    (behavior target g : Fin n → ℝ) (ε : ℝ)
    (hε : 0 < ε) (hb : ∀ a, 0 < behavior a)
    (ht : ∀ a, 0 ≤ target a)
    (hexplore : ∀ a, ε * target a ≤ behavior a) :
    importanceSecondMoment behavior target g ≤
      (1 / ε) * expect target (fun a => (g a) ^ 2) := by
  unfold importanceSecondMoment expect
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro a _
  have hratio : target a / behavior a ≤ 1 / ε := by
    apply (div_le_iff₀ (hb a)).2
    calc
      target a = (1 / ε) * (ε * target a) := by field_simp
      _ ≤ (1 / ε) * behavior a := by
        exact mul_le_mul_of_nonneg_left (hexplore a) (by positivity)
  calc
    behavior a * (target a / behavior a * g a) ^ 2 =
        target a * (target a / behavior a) * (g a) ^ 2 := by
          field_simp
    _ ≤ target a * (1 / ε) * (g a) ^ 2 := by
          exact mul_le_mul_of_nonneg_right
            (mul_le_mul_of_nonneg_left hratio (ht a)) (sq_nonneg _)
    _ = (1 / ε) * (target a * (g a) ^ 2) := by ring

/-- The inverse-`ε` rate is sharp. For a deterministic target on the first of
two actions, an exploration policy assigning that action probability `ε`, and
a unit signal there, the second moment is exactly `1 / ε`. -/
theorem importanceSecondMoment_inverse_epsilon_sharp (ε : ℝ) (hε : ε ≠ 0) :
    importanceSecondMoment
        (fun a : Fin 2 => if a = 0 then ε else 1 - ε)
        (fun a : Fin 2 => if a = 0 then 1 else 0)
        (fun a : Fin 2 => if a = 0 then 1 else 0) = 1 / ε := by
  unfold importanceSecondMoment
  rw [Fin.sum_univ_two]
  simp
  field_simp

/-- Any variance bounded by the estimator's second moment inherits the same
explicit inverse-exploration bound. -/
theorem variance_le_inv_epsilon
    (variance : ℝ) (behavior target g : Fin n → ℝ) (ε : ℝ)
    (hvar : variance ≤ importanceSecondMoment behavior target g)
    (hε : 0 < ε) (hb : ∀ a, 0 < behavior a)
    (ht : ∀ a, 0 ≤ target a)
    (hexplore : ∀ a, ε * target a ≤ behavior a) :
    variance ≤ (1 / ε) * expect target (fun a => (g a) ^ 2) := by
  exact hvar.trans
    (importanceSecondMoment_le_inv_epsilon behavior target g ε hε hb ht hexplore)

end PolicyGradient