/-! # CatalogBuild.EML.AIResearch.SelfLearningFoundations

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 5
-/

import Mathlib

noncomputable section

/-- A self-learning system: a performance metric on a parameter space,
with an improvement operator that maps parameters to better parameters. -/
structure SelfLearningSystem where
  /-- Dimension of parameter space -/
  dim : ℕ
  /-- Performance metric (higher = better), valued in [0,1] -/
  performance : (Fin dim → ℝ) → ℝ
  /-- The self-improvement operator -/
  improve : (Fin dim → ℝ) → (Fin dim → ℝ)
  /-- Performance is bounded in [0,1] -/
  perf_nonneg : ∀ θ, 0 ≤ performance θ
  perf_le_one : ∀ θ, performance θ ≤ 1


/-- The improvement gap after one step -/
def improvementGap (S : SelfLearningSystem) (θ : Fin S.dim → ℝ) : ℝ :=
  S.performance (S.improve θ) - S.performance θ


/-- Performance after k improvement steps -/
def performanceAfterSteps (S : SelfLearningSystem) (θ₀ : Fin S.dim → ℝ) : ℕ → ℝ
  | 0 => S.performance θ₀
  | n + 1 => S.performance (Nat.rec θ₀ (fun _ θ => S.improve θ) (n + 1))


/-- Standard parameter count for a layer of width d -/
def stdParams (d : ℕ) : ℕ := d * d


/-- A contraction on the performance space: the improvement operator brings
any two starting points closer together in performance. -/
def IsPerformanceContraction (S : SelfLearningSystem) (c : ℝ) : Prop :=
  0 ≤ c ∧ c < 1 ∧
  ∀ θ₁ θ₂ : Fin S.dim → ℝ,
    |S.performance (S.improve θ₁) - S.performance (S.improve θ₂)| ≤
    c * |S.performance θ₁ - S.performance θ₂|


end
