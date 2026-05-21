import Mathlib

/-!
# Regev Reduction: Core Definitions

This module defines the compositional structures for formalizing the Regev
worst-case-to-average-case reduction for Learning With Errors (LWE).

## Key Definitions

- `tvd`: Total variation distance between PMFs on finite types
- `ModuleReductionStep`: A certified reduction step between finite modules
- `BDDInstance`: Bounded Distance Decoding instance
- `ApproxDiscreteGaussian`: Certified approximate discrete Gaussian sampler

These definitions encode the claim that the Regev reduction can be decomposed
into module-theoretic morphisms that preserve hardness guarantees.
-/

open Finset BigOperators

noncomputable section

/-! ## Total Variation Distance -/

/-- Total variation distance between two PMFs on a finite type.
    TVD(μ, ν) = (1/2) ∑_x |μ(x) - ν(x)| -/
def tvd {α : Type*} [Fintype α] (μ ν : PMF α) : ℝ :=
  (1 / 2) * ∑ a : α, |(μ a).toReal - (ν a).toReal|

/-- TVD is nonnegative. -/
theorem tvd_nonneg {α : Type*} [Fintype α] (μ ν : PMF α) :
    0 ≤ tvd μ ν := by
  unfold tvd
  apply mul_nonneg (by norm_num)
  exact Finset.sum_nonneg fun a _ => abs_nonneg _

/-- TVD is symmetric. -/
theorem tvd_symm {α : Type*} [Fintype α] (μ ν : PMF α) :
    tvd μ ν = tvd ν μ := by
  unfold tvd
  congr 1
  apply Finset.sum_congr rfl
  intro a _
  rw [abs_sub_comm]

/-- TVD satisfies the triangle inequality. -/
theorem tvd_triangle {α : Type*} [Fintype α] (μ ν ρ : PMF α) :
    tvd μ ρ ≤ tvd μ ν + tvd ν ρ := by
  unfold tvd
  rw [← mul_add]
  gcongr
  calc ∑ a : α, |(μ a).toReal - (ρ a).toReal|
      ≤ ∑ a : α, (|(μ a).toReal - (ν a).toReal| + |(ν a).toReal - (ρ a).toReal|) :=
        Finset.sum_le_sum fun a _ => abs_sub_le _ _ _
    _ = _ := Finset.sum_add_distrib

/-- TVD is zero for identical distributions. -/
theorem tvd_self {α : Type*} [Fintype α] (μ : PMF α) :
    tvd μ μ = 0 := by
  unfold tvd; simp [sub_self]

/-! ## Module Reduction Step -/

/-- A `ModuleReductionStep` encodes a single certified step in a hardness-preserving
    reduction between finite modules.

    The key property is `tvd_bound`: pushing distributions through `noisePush`
    cannot increase total variation distance. This encodes the data-processing
    inequality / functoriality of TVD under deterministic maps. -/
structure ModuleReductionStep (R M N : Type*)
    [CommRing R] [AddCommGroup M] [Module R M]
    [AddCommGroup N] [Module R N]
    [Fintype M] [Fintype N] where
  /-- The underlying linear map between modules. -/
  map : M →ₗ[R] N
  /-- The noise/distribution pushforward function. -/
  noisePush : PMF M → PMF N
  /-- TVD is non-increasing under pushforward. -/
  tvd_bound : ∀ μ ν : PMF M, tvd (noisePush μ) (noisePush ν) ≤ tvd μ ν

/-! ## Bounded Distance Decoding -/

/-- A `BDDInstance` encodes a bounded-distance decoding problem instance.

    This is the output type for the worst-case reduction: GapSVP hardness
    yields an instance where we must find a lattice point within bounded
    distance of a target. -/
structure BDDInstance where
  /-- Dimension of the ambient space. -/
  n : ℕ
  /-- The lattice, as a submodule of ℤⁿ. -/
  lattice : Submodule ℤ (Fin n → ℤ)
  /-- Target point to decode. -/
  target : Fin n → ℤ
  /-- Decoding radius. -/
  radius : ℝ
  /-- Radius is positive. -/
  radius_pos : 0 < radius

/-- Distance between two points in ℤⁿ (Euclidean norm via ℝ). -/
def intDist (n : ℕ) (x y : Fin n → ℤ) : ℝ :=
  Real.sqrt (∑ i : Fin n, ((x i - y i : ℤ) : ℝ) ^ 2)

/-- A point is within the decoding radius of the target. -/
def withinRadius (I : BDDInstance) (x : Fin I.n → ℤ) : Prop :=
  intDist I.n I.target x ≤ I.radius

/-- The BDD instance is well-separated: the minimum distance between
    distinct lattice points exceeds twice the decoding radius.
    This ensures at most one lattice point is within radius of any target. -/
def BDDInstance.wellSeparated (I : BDDInstance) : Prop :=
  ∀ x y : Fin I.n → ℤ, x ∈ I.lattice → y ∈ I.lattice →
    x ≠ y → intDist I.n x y > 2 * I.radius

/-! ## Approximate Discrete Gaussian -/

/-- A certified approximate discrete Gaussian sampler.

    This captures exactly what the Regev reduction needs from the
    quantum sampling step: a PMF whose total variation distance from
    the ideal target distribution is bounded by a certified error. -/
structure ApproxDiscreteGaussian (α : Type*) [Fintype α] where
  /-- The actual sampling distribution. -/
  sample : PMF α
  /-- The ideal target distribution. -/
  target : PMF α
  /-- Certified TVD error bound. -/
  tvdError : ℝ
  /-- The error bound is nonnegative. -/
  tvdError_nonneg : 0 ≤ tvdError
  /-- The sample is within tvdError of the target in TVD. -/
  certified : tvd sample target ≤ tvdError

/-! ## Search-to-Decision Structure -/

/-- Packages the search-to-decision reduction data for an LWE-type problem
    over a finite module. -/
structure SearchToDecisionData (α : Type*) [Fintype α] where
  /-- Number of hybrid steps. -/
  numHybrids : ℕ
  /-- The hybrid distributions. -/
  hybrids : Fin (numHybrids + 1) → PMF α
  /-- Per-step advantage bounds. -/
  stepBounds : Fin numHybrids → ℝ
  /-- Each step bound is nonneg. -/
  stepBounds_nonneg : ∀ i, 0 ≤ stepBounds i

end