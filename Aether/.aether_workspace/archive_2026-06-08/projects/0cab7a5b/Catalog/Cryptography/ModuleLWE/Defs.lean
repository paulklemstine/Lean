import Mathlib

/-!
# Module-LWE: Core Definitions

This module establishes the algebraic foundation for module-theoretic lattice
cryptography. We define:

- `KernelInvariantError`: a distribution constant on kernel cosets
- `acceptProb` / `distinguishAdvantage`: distinguishing advantage
- `tvd`: total variation distance between PMFs on finite types
- `Message`: abstract message type for encryption

These definitions serve as the reusable vocabulary for expressing
cryptographic security reductions as module-theoretic transport theorems.
-/

open Finset BigOperators

noncomputable section

/-! ## Message type -/

/-- Abstract message type for encryption schemes. -/
abbrev Message := ℕ

/-! ## Kernel-Invariant Error Distributions -/

/-- A distribution `χ` on a module `M` is kernel-invariant with respect to
a linear map `f : M →ₗ[R] N` if `χ` assigns equal probability to any two
elements in the same kernel coset. This is the exact hypothesis that makes
quotient-security arguments go through: it ensures that the pushforward
`f_* χ` loses no information about `χ`'s security properties.

Mathematically, `χ` is constant on cosets of `ker f`. -/
def KernelInvariantError
    {R M N : Type*}
    [CommRing R]
    [AddCommGroup M] [Module R M]
    [AddCommGroup N] [Module R N]
    (f : M →ₗ[R] N) (χ : PMF M) : Prop :=
  ∀ m k, k ∈ LinearMap.ker f → χ m = χ (m + k)

/-! ## Distinguishing Advantage -/

/-- Acceptance probability: probability that distinguisher `D` outputs `true`
when given a sample from `χ`. Uses ENNReal → ℝ≥0∞ sum then converts. -/
def acceptProb {α : Type*} [Fintype α] (χ : PMF α) (D : α → Bool) : ℝ :=
  ∑ a : α, if D a then (χ a).toReal else 0

/-- Distinguishing advantage between two distributions for a specific test. -/
def distinguishAdvantage {α : Type*} [Fintype α]
    (χ ψ : PMF α) (D : α → Bool) : ℝ :=
  |acceptProb χ D - acceptProb ψ D|

/-! ## Total Variation Distance -/

/-- Total variation distance between two PMFs on a finite type.
Equal to `(1/2) ∑_x |χ(x) - ψ(x)|` where values are in ℝ via `toReal`. -/
def tvd {α : Type*} [Fintype α] (χ ψ : PMF α) : ℝ :=
  (1/2) * ∑ a : α, |(χ a).toReal - (ψ a).toReal|

/-- TVD is nonneg. -/
theorem tvd_nonneg {α : Type*} [Fintype α] (χ ψ : PMF α) :
    0 ≤ tvd χ ψ := by
  unfold tvd
  apply mul_nonneg (by norm_num)
  exact Finset.sum_nonneg fun a _ => abs_nonneg _

/-- TVD is symmetric. -/
theorem tvd_symm {α : Type*} [Fintype α] (χ ψ : PMF α) :
    tvd χ ψ = tvd ψ χ := by
  unfold tvd
  congr 1
  apply Finset.sum_congr rfl
  intro a _
  rw [abs_sub_comm]

/-! ## Compliance Window -/

/-- A compliance window certifies that an error vector lies within a specified
radius, enabling correctness guarantees for compression schemes. -/
structure ComplianceWindow (M : Type*) [SeminormedAddCommGroup M] where
  /-- The maximum allowed error norm. -/
  radius : ℝ
  /-- The radius is positive. -/
  radius_pos : 0 < radius

/-! ## Linear Noise Certificate -/

/-- An error vector `e` is certified within radius `δ` if its norm is bounded. -/
def LinearNoiseCertified {M : Type*} [SeminormedAddCommGroup M]
    (e : M) (δ : ℝ) : Prop :=
  ‖e‖ ≤ δ

end