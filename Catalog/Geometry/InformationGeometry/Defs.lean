/-
  Information Geometry: Core Definitions
  ======================================

  This file defines the foundational structures for information geometry
  on finite sample spaces with finite-dimensional parameter spaces.

  Key definitions:
  - `FiniteStatModel`: A parametric family of probability distributions on a finite sample space
  - `scoreVec`: The score vector (gradient of log-likelihood)
  - `fisherMatrix`: The Fisher information matrix
  - `varianceAt`, `covarianceAt`: Weighted variance and covariance
  - `ExponentialFamily`: Exponential family structure
  - `logPartition`: Log-partition (cumulant generating) function
  - `amariChentsovTensor`, `alphaChristoffel`: Alpha-connection geometry
-/

import Mathlib

open Finset BigOperators Matrix

noncomputable section

/-! ## Core Statistical Model -/

/-- A finite parametric statistical model: a family of probability mass functions
    indexed by a parameter `θ ∈ Θ`, over a finite sample space `Ω`. -/
structure FiniteStatModel (Θ Ω : Type*) [Fintype Ω] where
  /-- The log-likelihood function -/
  logLik    : Θ → Ω → ℝ
  /-- The probability mass function -/
  pmf       : Θ → Ω → ℝ
  /-- Probabilities are nonneg -/
  pmf_nonneg : ∀ θ ω, 0 ≤ pmf θ ω
  /-- Probabilities sum to 1 -/
  pmf_sum_one : ∀ θ, ∑ ω : Ω, pmf θ ω = 1
  /-- Log-likelihood is consistent with pmf where pmf is nonzero -/
  logLik_spec : ∀ θ ω, pmf θ ω ≠ 0 → logLik θ ω = Real.log (pmf θ ω)

variable {n : ℕ} {Ω : Type*} [Fintype Ω] [DecidableEq Ω]

/-! ## Score and Fisher Information -/

/-- The Fisher information matrix: I_{ij}(θ) = 𝔼_θ[sᵢ(θ,X) sⱼ(θ,X)]
    = ∑_ω p(ω;θ) sᵢ(θ,ω) sⱼ(θ,ω).
    Here `dlogp` represents the score function (partial derivatives of log p). -/
def fisherMatrix (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ) (θ : Fin n → ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => ∑ ω : Ω, M.pmf θ ω * dlogp θ ω i * dlogp θ ω j

/-! ## Expectation, Variance, Covariance -/

/-- Expectation of a real-valued function under the model at parameter θ. -/
def expectationAt {Θ : Type*} (M : FiniteStatModel Θ Ω) (θ : Θ) (f : Ω → ℝ) : ℝ :=
  ∑ ω : Ω, M.pmf θ ω * f ω

/-- Variance of a real-valued function under the model at parameter θ. -/
def varianceAt {Θ : Type*} (M : FiniteStatModel Θ Ω) (θ : Θ) (f : Ω → ℝ) : ℝ :=
  expectationAt M θ (fun ω => (f ω - expectationAt M θ f) ^ 2)

/-- Covariance of two real-valued functions under the model at parameter θ. -/
def covarianceAt {Θ : Type*} (M : FiniteStatModel Θ Ω) (θ : Θ) (f g : Ω → ℝ) : ℝ :=
  expectationAt M θ (fun ω => (f ω - expectationAt M θ f) * (g ω - expectationAt M θ g))

/-! ## Regularity and Unbiasedness -/

/-- Regularity hypotheses for a finite statistical model with score function. -/
structure RegularityHypotheses (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ) : Prop where
  /-- All probabilities are strictly positive -/
  pmf_pos : ∀ θ ω, 0 < M.pmf θ ω
  /-- The score has mean zero: ∑_ω p(ω;θ) sᵢ(θ,ω) = 0 for all i. -/
  score_mean_zero : ∀ θ (i : Fin n), ∑ ω : Ω, M.pmf θ ω * dlogp θ ω i = 0

/-- Directional derivative of g at θ in direction v, defined via Fréchet derivative. -/
def directionalDeriv (g : (Fin n → ℝ) → ℝ) (θ v : Fin n → ℝ) : ℝ :=
  (fderiv ℝ g θ) v

/-! ## Exponential Families -/

/-- An exponential family on a finite sample space: p_θ(ω) = exp(⟨θ, T(ω)⟩ - ψ(θ) + k(ω))
    where T is the sufficient statistic, ψ is the log-partition function, and k is the
    base measure log-density. -/
structure ExponentialFamily (n : ℕ) (Ω : Type*) [Fintype Ω] where
  /-- Sufficient statistic T : Ω → ℝⁿ -/
  suffStat : Ω → Fin n → ℝ
  /-- Base measure log-density k : Ω → ℝ -/
  baseMeasure : Ω → ℝ
  /-- Normalizing condition: the partition function is finite and positive -/
  partition_pos : ∀ θ : Fin n → ℝ,
    0 < ∑ ω : Ω, Real.exp (∑ i, θ i * suffStat ω i + baseMeasure ω)

/-- The log-partition (cumulant generating) function ψ(θ) = log ∑_ω exp(⟨θ,T(ω)⟩ + k(ω)). -/
def logPartition (E : ExponentialFamily n Ω) (θ : Fin n → ℝ) : ℝ :=
  Real.log (∑ ω : Ω, Real.exp (∑ i, θ i * E.suffStat ω i + E.baseMeasure ω))

/-- Auxiliary: the inner exponent for an exponential family. -/
def expFamilyExponent (E : ExponentialFamily n Ω) (θ : Fin n → ℝ) (ω : Ω) : ℝ :=
  ∑ i, θ i * E.suffStat ω i + E.baseMeasure ω

/-- The pmf of an exponential family. -/
def expFamilyPmf (E : ExponentialFamily n Ω) (θ : Fin n → ℝ) (ω : Ω) : ℝ :=
  Real.exp (expFamilyExponent E θ ω) /
    (∑ ω' : Ω, Real.exp (expFamilyExponent E θ ω'))

omit [DecidableEq Ω] in
theorem expFamilyPmf_nonneg (E : ExponentialFamily n Ω) (θ : Fin n → ℝ) (ω : Ω) :
    0 ≤ expFamilyPmf E θ ω := by
  unfold expFamilyPmf
  positivity

omit [DecidableEq Ω] in
theorem expFamilyPmf_sum_one (E : ExponentialFamily n Ω) (θ : Fin n → ℝ) :
    ∑ ω : Ω, expFamilyPmf E θ ω = 1 := by
  unfold expFamilyPmf
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt (E.partition_pos θ))

/-- Convert an exponential family to a finite statistical model. -/
def ExponentialFamily.toStatModel (E : ExponentialFamily n Ω) :
    FiniteStatModel (Fin n → ℝ) Ω where
  logLik θ ω := expFamilyExponent E θ ω - logPartition E θ
  pmf := expFamilyPmf E
  pmf_nonneg := expFamilyPmf_nonneg E
  pmf_sum_one := expFamilyPmf_sum_one E
  logLik_spec θ ω _ := by
    unfold expFamilyPmf logPartition expFamilyExponent
    rw [Real.log_div (ne_of_gt (Real.exp_pos _)) (ne_of_gt (E.partition_pos θ)),
        Real.log_exp]

/-- Expectation parameter η(θ) = 𝔼_θ[T] = ∑_ω p(ω;θ) T(ω). -/
def expectationParameter (E : ExponentialFamily n Ω) (θ : Fin n → ℝ) :
    Fin n → ℝ :=
  fun i => ∑ ω : Ω, E.toStatModel.pmf θ ω * E.suffStat ω i

/-- Covariance matrix of the sufficient statistic under the model. -/
def sufficientStatCov (E : ExponentialFamily n Ω) (θ : Fin n → ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j =>
    (∑ ω : Ω, E.toStatModel.pmf θ ω * E.suffStat ω i * E.suffStat ω j) -
    (∑ ω : Ω, E.toStatModel.pmf θ ω * E.suffStat ω i) *
    (∑ ω : Ω, E.toStatModel.pmf θ ω * E.suffStat ω j)

/-! ## Alpha-connections and Dual Geometry -/

/-- The Amari–Chentsov cubic tensor C_{ijk}(θ) = ∑_ω p(ω;θ) sᵢ(θ,ω) sⱼ(θ,ω) sₖ(θ,ω),
    the third moment of the score. -/
def amariChentsovTensor (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ) (θ : Fin n → ℝ) :
    Fin n → Fin n → Fin n → ℝ :=
  fun i j k => ∑ ω : Ω, M.pmf θ ω * dlogp θ ω i * dlogp θ ω j * dlogp θ ω k

/-- The α-Christoffel symbols (lowered, first-kind):
    Γ^(α)_{ij,k} = Γ^(0)_{ij,k} + (α/2) C_{ijk}. -/
def alphaChristoffel (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ)
    (leviCivita : (Fin n → ℝ) → Fin n → Fin n → Fin n → ℝ)
    (α : ℝ) (θ : Fin n → ℝ) : Fin n → Fin n → Fin n → ℝ :=
  fun i j k => leviCivita θ i j k + (α / 2) * amariChentsovTensor M dlogp θ i j k

/-- The (+1) Christoffel symbols vanish: flatness condition. -/
def PlusOneFlat (Γ : Fin n → Fin n → Fin n → ℝ) : Prop :=
  ∀ i j k, Γ i j k = 0

end