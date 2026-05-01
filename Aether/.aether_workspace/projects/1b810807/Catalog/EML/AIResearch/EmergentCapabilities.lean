import Mathlib

/-! # CatalogBuild.EML.AIResearch.EmergentCapabilities

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 7
-/

noncomputable section

/-- A capability tree: complex capabilities built from simpler ones -/
structure CapabilityTree where
  /-- Number of base capabilities -/
  numBase : ℕ
  /-- Proficiency at each base capability -/
  baseProficiency : Fin numBase → ℝ
  /-- Base proficiencies in [0,1] -/
  base_nonneg : ∀ i, 0 ≤ baseProficiency i
  base_le_one : ∀ i, baseProficiency i ≤ 1

/-- Number of capabilities that have "emerged" (proficiency > threshold) at a given scale -/
def numEmergedCapabilities (numCaps : ℕ) (proficiency : Fin numCaps → ℝ) (threshold : ℝ) : ℕ :=
  (Finset.univ.filter fun i => threshold < proficiency i).card

/-- Self-learning focuses compute on the capabilities closest to emergence,
reducing the effective midpoint -/
def adjustedMidpoint (baseMidpoint focusFactor : ℝ) : ℝ :=
  baseMidpoint * (1 - focusFactor)

/-- EML's compression means the same compute budget trains a larger effective model,
moving past the emergence threshold earlier -/
def effectiveScale (computeBudget modelCost : ℕ) (hc : 0 < modelCost) : ℕ :=
  computeBudget / modelCost

/-- [Section: ## §5. EML Enables Earlier Emergence] -/
theorem eml_higher_effective_scale (budget d : ℕ) (hd : 5 ≤ d)
    (hb : d * d ≤ budget) :
    budget / (d * d) ≤ budget / (4 * d) := by
  gcongr ; nlinarith

/-- Below a critical mass of data, a capability appears absent.
Above it, the capability appears suddenly. -/
def criticalMassModel (dataSize criticalSize : ℕ) : ℝ :=
  if dataSize < criticalSize then 0
  else 1 - Real.exp (-(↑(dataSize - criticalSize) : ℝ) / ↑criticalSize)

/-- At critical mass, capability begins emerging -/
theorem at_critical_mass_emerges (c : ℕ) (hc : 0 < c) :
    criticalMassModel c c = 0 := by
  unfold criticalMassModel; simp

end
