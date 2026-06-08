Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Idempotent Kantorovich–Rubinstein Duality: Core Definitions

This file defines the fundamental objects for tropical/idempotent optimal transport:
maxitive probability profiles, their integral functionals, 1-Lipschitz test functions,
the KR dual distance, couplings, and the primal Wasserstein cost.

## Mathematical context

In the max-plus semiring (ℝ, max, +), the analogue of a probability measure is a
"maxitive probability profile" μ : X → ℝ with values ≤ 0 and sup = 0. The
analogue of integration is the maxitive integral Λ_μ(f) = sup_x(μ(x) + f(x)).

The Kantorovich–Rubinstein dual distance is then defined as
  d_KR(μ, ν) = sup_{f 1-Lip} (Λ_μ(f) - Λ_ν(f))

This is the tropical analogue of the classical Wasserstein-1 / earth mover's distance.
-/

import Mathlib

noncomputable section

open scoped BigOperators

/-! ## 1-Lipschitz functions -/

/-- The type of 1-Lipschitz real-valued functions on a pseudo-metric space. -/
def LipOne (X : Type*) [PseudoMetricSpace X] :=
  {f : X → ℝ // LipschitzWith 1 f}

namespace LipOne

variable {X : Type*} [PseudoMetricSpace X]

instance : CoeFun (LipOne X) (fun _ => X → ℝ) :=
  ⟨fun f => f.1⟩

/-- The constant zero function is 1-Lipschitz. -/
def zero : LipOne X :=
  ⟨fun _ => 0, LipschitzWith.of_dist_le_mul (fun _ _ => by simp [dist_nonneg])⟩

/-- The negation of a 1-Lipschitz function is 1-Lipschitz. -/
def neg (f : LipOne X) : LipOne X :=
  ⟨-f.1, f.2.neg⟩

/-- The distance function from a fixed point is 1-Lipschitz. -/
def distFrom (x₀ : X) : LipOne X :=
  ⟨fun x => dist x x₀, LipschitzWith.of_dist_le_mul fun a b => by
    simp only [Real.dist_eq, NNReal.coe_one, one_mul]
    exact abs_dist_sub_le a b x₀⟩

/-- Composing a 1-Lipschitz function with a 1-Lipschitz map yields a 1-Lipschitz function. -/
def comp {Y : Type*} [PseudoMetricSpace Y] (f : LipOne Y) (T : X → Y)
    (hT : LipschitzWith 1 T) : LipOne X :=
  ⟨fun x => f.1 (T x), by
    have h := f.2.comp hT
    simp only [one_mul] at h; exact h⟩

end LipOne

/-! ## Maxitive probability profiles -/

/-- A maxitive probability profile on a finite type `X`: a function `X → ℝ` with
    values ≤ 0 and max = 0. This is the tropical analogue of a probability measure.

    The value μ(x) represents the log-possibility weight at x. Points with μ(x) = 0
    are "fully possible" (the mode), while μ(x) < 0 indicates reduced possibility. -/
structure MaxitiveProb (X : Type*) [Fintype X] [Nonempty X] where
  /-- The log-possibility density function. -/
  toFun : X → ℝ
  /-- All values are non-positive. -/
  nonpos : ∀ x, toFun x ≤ 0
  /-- The profile is normalized: the maximum is 0. -/
  normalized : Finset.univ.sup' Finset.univ_nonempty toFun = 0

namespace MaxitiveProb

variable {X : Type*} [Fintype X] [Nonempty X]

instance : CoeFun (MaxitiveProb X) (fun _ => X → ℝ) :=
  ⟨fun μ => μ.toFun⟩

/-- The Dirac maxitive profile at a point. -/
def dirac [DecidableEq X] (x₀ : X) : MaxitiveProb X where
  toFun x := if x = x₀ then 0 else -1
  nonpos x := by split_ifs <;> norm_num
  normalized := by
    apply le_antisymm
    · exact Finset.sup'_le _ _ fun x _ => by split_ifs <;> norm_num
    · exact Finset.le_sup' _ (Finset.mem_univ x₀) |>.trans' (by simp)

/-
Existence of a mode point: there exists x with μ(x) = 0.
-/
theorem exists_mode (μ : MaxitiveProb X) : ∃ x₀ : X, μ.toFun x₀ = 0 := by
  -- Let `x₀` be the mode point of `μ`, which is defined as the element that maximizes `μ`.
  obtain ⟨x₀, hx₀⟩ :
      ∃ x₀, (μ.toFun x₀) = (Finset.univ.sup' Finset.univ_nonempty μ.toFun) := by
        have := Finset.exists_max_image Finset.univ μ.toFun ( Finset.univ_nonempty );
        exact ⟨ this.choose, le_antisymm ( Finset.le_sup' ( fun x => μ.toFun x ) ( Finset.mem_univ _ ) ) ( Finset.sup'_le _ _ fun x _ => this.choose_spec.2 x ( Finset.mem_univ x ) ) ⟩;
  exact ⟨ x₀, hx₀.trans μ.normalized ⟩

end MaxitiveProb

/-! ## Maxitive integral (tropical expectation) -/

/-- The maxitive integral of f with respect to μ:
    `Λ_μ(f) = max_x (μ(x) + f(x))`.
    This is the tropical analogue of the expectation `𝔼_μ[f]`. -/
def maxIntegral {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxitiveProb X) (f : X → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun x => μ.toFun x + f x

/-! ## KR Dual Distance -/

/-- The idempotent Kantorovich–Rubinstein dual discrepancy:
    `d_KR(μ, ν) = sup_{f 1-Lip} (Λ_μ(f) - Λ_ν(f))`.

    This is the directed tropical analogue of the Wasserstein-1 distance.
    It measures how much μ "exceeds" ν as tested by 1-Lipschitz observables. -/
def iKRDual {X : Type*} [Fintype X] [Nonempty X] [PseudoMetricSpace X]
    (μ ν : MaxitiveProb X) : ℝ :=
  sSup {r : ℝ | ∃ f : LipOne X, r = maxIntegral μ f.1 - maxIntegral ν f.1}

/-! ## Maxitive Coupling -/

/-- A maxitive coupling of two profiles μ and ν on a finite type:
    a joint weight function π : X → X → ℝ with prescribed max-marginals. -/
structure MaxitiveCoupling {X : Type*} [Fintype X] [Nonempty X] [PseudoMetricSpace X]
    (μ ν : MaxitiveProb X) where
  /-- The joint weight function. -/
  toFun : X → X → ℝ
  /-- All values are non-positive. -/
  nonpos : ∀ x y, toFun x y ≤ 0
  /-- First marginal: max over Y gives μ. -/
  fst_marginal : ∀ x, Finset.univ.sup' Finset.univ_nonempty (toFun x) = μ.toFun x
  /-- Second marginal: max over X gives ν. -/
  snd_marginal : ∀ y, Finset.univ.sup' Finset.univ_nonempty (fun x => toFun x y) = ν.toFun y

/-! ## Transport Cost -/

/-- The max-plus transport cost of a coupling π:
    `C(π) = max_{x,y} (π(x,y) + dist(x,y))`. -/
def transportCost {X : Type*} [Fintype X] [Nonempty X] [PseudoMetricSpace X]
    {μ ν : MaxitiveProb X} (π : MaxitiveCoupling μ ν) : ℝ :=
  (Finset.univ ×ˢ Finset.univ).sup'
    (by simp [Finset.Nonempty]) fun p => π.toFun p.1 p.2 + dist p.1 p.2

/-- The idempotent Wasserstein distance (primal formulation):
    `W(μ,ν) = inf_π C(π)`. -/
def iWasserstein {X : Type*} [Fintype X] [Nonempty X] [PseudoMetricSpace X]
    (μ ν : MaxitiveProb X) : ℝ :=
  sInf {r : ℝ | ∃ π : MaxitiveCoupling μ ν, transportCost π ≤ r}

/-! ## Tropical Kernel Mean Embedding -/

/-- A tropical kernel on X: a function k : X → X → ℝ. -/
abbrev TropicalKernel (X : Type*) := X → X → ℝ

/-- The tropical kernel mean embedding (finite version):
    `kme_μ(y) = max_x (μ(x) + k(x, y))`. -/
def tropKME {X : Type*} [Fintype X] [Nonempty X]
    (k : TropicalKernel X) (μ : MaxitiveProb X) : X → ℝ :=
  fun y => Finset.univ.sup' Finset.univ_nonempty fun x => μ.toFun x + k x y

/-- A kernel is characteristic if tropKME is injective. -/
def IsCharacteristicKernel {X : Type*} [Fintype X] [Nonempty X]
    (k : TropicalKernel X) : Prop :=
  Function.Injective (tropKME k : MaxitiveProb X → X → ℝ)

/-- A kernel represents all 1-Lipschitz functions if every 1-Lip test is in the
    max-plus span of kernel slices. -/
def KernelRepresentsLipOne {X : Type*} [Fintype X] [Nonempty X] [PseudoMetricSpace X]
    (k : TropicalKernel X) : Prop :=
  ∀ f : LipOne X, ∃ (a : X → ℝ),
    ∀ x, f.1 x = Finset.univ.sup' Finset.univ_nonempty fun z => a z + k z x

end