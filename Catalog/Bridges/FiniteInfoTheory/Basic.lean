/-
Copyright (c) 2025 Bridges Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Finite Information Theory: Core Definitions

This file establishes the foundational structures for finite information theory:
- Finite probability distributions (`FinProbDist`)
- Stochastic kernels (`StochasticKernel`)
- Expected distortion
- Feasible distortion sets
- The rate-distortion function

These definitions provide a reusable Lean foundation for rate-distortion theory
over finite alphabets, bridging classical Shannon theory with tropical/polyhedral
optimization and categorical information theory.
-/

import Mathlib

open Finset BigOperators Real

noncomputable section

/-- A finite probability distribution on a finite type `α`.
    `val a` is the probability of outcome `a`. -/
structure FinProbDist (α : Type*) [Fintype α] where
  val : α → ℝ
  nonneg : ∀ a, 0 ≤ val a
  sum_one : ∑ a : α, val a = 1

namespace FinProbDist

variable {α : Type*} [Fintype α]

/-- The support of a finite probability distribution. -/
def support (μ : FinProbDist α) : Finset α :=
  Finset.univ.filter (fun a => μ.val a ≠ 0)

/-- Each probability is at most 1. -/
theorem val_le_one (μ : FinProbDist α) (a : α) : μ.val a ≤ 1 := by
  have h := μ.sum_one
  have h2 : μ.val a ≤ ∑ x : α, μ.val x := by
    apply Finset.single_le_sum (fun x _ => μ.nonneg x)
    exact Finset.mem_univ a
  linarith

end FinProbDist

/-- A stochastic kernel from `α` to `β`: for each `a : α`,
    `K.val a` is a probability distribution on `β`. -/
structure StochasticKernel (α β : Type*) [Fintype α] [Fintype β] where
  val : α → β → ℝ
  nonneg : ∀ a b, 0 ≤ val a b
  row_sum_one : ∀ a, ∑ b : β, val a b = 1

namespace StochasticKernel

variable {α β : Type*} [Fintype α] [Fintype β]

/-- The joint distribution induced by source `μ` and kernel `K`. -/
def joint (μ : FinProbDist α) (K : StochasticKernel α β) : α → β → ℝ :=
  fun a b => μ.val a * K.val a b

/-- The output marginal distribution induced by source `μ` and kernel `K`. -/
def outputMarginal (μ : FinProbDist α) (K : StochasticKernel α β) : β → ℝ :=
  fun b => ∑ a : α, μ.val a * K.val a b

/-- Joint distribution values are nonneg. -/
theorem joint_nonneg (μ : FinProbDist α) (K : StochasticKernel α β) (a : α) (b : β) :
    0 ≤ K.joint μ a b :=
  mul_nonneg (μ.nonneg a) (K.nonneg a b)

/-- Output marginal values are nonneg. -/
theorem outputMarginal_nonneg (μ : FinProbDist α) (K : StochasticKernel α β) (b : β) :
    0 ≤ K.outputMarginal μ b :=
  Finset.sum_nonneg fun a _ => mul_nonneg (μ.nonneg a) (K.nonneg a b)

/-- The output marginal sums to 1. -/
theorem outputMarginal_sum_one (μ : FinProbDist α) (K : StochasticKernel α β) :
    ∑ b : β, K.outputMarginal μ b = 1 := by
  simp only [outputMarginal]
  rw [Finset.sum_comm]
  simp_rw [← Finset.mul_sum]
  simp [K.row_sum_one, μ.sum_one]

/-- Expected distortion of kernel `K` under source `μ` with distortion function `d`. -/
def expectedDistortion (μ : FinProbDist α) (K : StochasticKernel α β) (d : α → β → ℝ) : ℝ :=
  ∑ a : α, ∑ b : β, μ.val a * K.val a b * d a b

/-- Mixture of two stochastic kernels: `λ K₁ + (1-λ) K₂`. -/
def mix (K₁ K₂ : StochasticKernel α β) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    StochasticKernel α β where
  val a b := t * K₁.val a b + (1 - t) * K₂.val a b
  nonneg a b := by
    apply add_nonneg
    · exact mul_nonneg ht0 (K₁.nonneg a b)
    · exact mul_nonneg (by linarith) (K₂.nonneg a b)
  row_sum_one a := by
    simp_rw [Finset.sum_add_distrib, ← Finset.mul_sum]
    rw [K₁.row_sum_one, K₂.row_sum_one]
    ring

end StochasticKernel

/-- The feasible distortion set: values of `D` for which there exists a kernel
    with expected distortion ≤ `D`. -/
def feasibleDistortionSet {α β : Type*} [Fintype α] [Fintype β]
    (μ : FinProbDist α) (d : α → β → ℝ) : Set ℝ :=
  { D : ℝ | ∃ K : StochasticKernel α β, K.expectedDistortion μ d ≤ D }

/-- A distortion level `D` is feasible if there exists a kernel achieving it. -/
def FeasibleDistortion {α β : Type*} [Fintype α] [Fintype β]
    (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : Prop :=
  ∃ K : StochasticKernel α β, K.expectedDistortion μ d ≤ D

/-- The feasible distortion set equals the set of feasible distortions. -/
theorem feasibleDistortionSet_eq {α β : Type*} [Fintype α] [Fintype β]
    (μ : FinProbDist α) (d : α → β → ℝ) :
    feasibleDistortionSet μ d = { D | FeasibleDistortion μ d D } := rfl

/-- An abstract "information measure" on stochastic kernels.
    We parameterize by this to avoid committing to a specific definition
    of mutual information early. This enables proving structural theorems
    (monotonicity, convexity) that hold for any well-behaved measure. -/
structure InfoMeasure (α β : Type*) [Fintype α] [Fintype β] where
  /-- The information measure assigns a nonneg real to each (source, kernel) pair. -/
  measure : FinProbDist α → StochasticKernel α β → ℝ
  /-- The information measure is nonneg. -/
  measure_nonneg : ∀ μ K, 0 ≤ measure μ K
  /-- The information measure is convex in the kernel for fixed source. -/
  measure_convex : ∀ (μ : FinProbDist α) (K₁ K₂ : StochasticKernel α β)
    (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1),
    measure μ (K₁.mix K₂ t ht0 ht1) ≤ t * measure μ K₁ + (1 - t) * measure μ K₂

/-- The rate-distortion function: infimum of information measure over feasible kernels. -/
def rateDistortion {α β : Type*} [Fintype α] [Fintype β]
    (I : InfoMeasure α β) (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  iInf (fun (K : StochasticKernel α β) =>
    if K.expectedDistortion μ d ≤ D then I.measure μ K else I.measure μ K + 1)

/-- Alternative characterization: R(D) as infimum over the feasible set. -/
def rateDistortion' {α β : Type*} [Fintype α] [Fintype β]
    (I : InfoMeasure α β) (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  sInf { r : ℝ | ∃ K : StochasticKernel α β, K.expectedDistortion μ d ≤ D ∧ I.measure μ K = r }

/-- A kernel `K` is a rate-distortion minimizer at level `D` if it is feasible
    and achieves the infimum of the information measure. -/
def IsRateDistortionMinimizer {α β : Type*} [Fintype α] [Fintype β]
    (I : InfoMeasure α β) (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ)
    (K : StochasticKernel α β) : Prop :=
  K.expectedDistortion μ d ≤ D ∧
  ∀ K' : StochasticKernel α β, K'.expectedDistortion μ d ≤ D →
    I.measure μ K ≤ I.measure μ K'

end