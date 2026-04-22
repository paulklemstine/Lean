import Mathlib

/-! # CatalogBuild.EML.AIResearch.ConvergenceGuarantees

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 4
-/

noncomputable section

/-- A performance sequence from iterating self-improvement -/
def perfSequence (f : ℝ → ℝ) (p₀ : ℝ) : ℕ → ℝ
  | 0 => p₀
  | n + 1 => f (perfSequence f p₀ n)

/-- A Lyapunov function for self-learning: measures "distance to optimality" -/
def lyapunovFunction (performance target : ℝ) : ℝ :=
  (performance - target) ^ 2

/-- During the "rapid improvement" phase, performance grows exponentially
toward the ceiling -/
def exponentialImprovement (p₀ pMax rate : ℝ) (t : ℕ) : ℝ :=
  pMax - (pMax - p₀) * rate ^ t

/-- The number of gradient steps to ε-optimality scales with parameter count -/
def gradientStepsToConverge (numParams : ℕ) (lipschitz : ℕ) : ℕ :=
  numParams * lipschitz

end
