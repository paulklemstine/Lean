import Mathlib

/-! # CatalogBuild.EML.AIResearch.CurriculumSelfPlay

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 10
-/

noncomputable section

/-- A curriculum: an ordering of training tasks by difficulty -/
structure Curriculum where
  /-- Number of tasks -/
  numTasks : ℕ
  /-- Difficulty of each task (in [0,1]) -/
  difficulty : Fin numTasks → ℝ
  /-- Learning gain from each task given current competence level -/
  learningGain : ℝ → Fin numTasks → ℝ
  /-- Difficulty is in [0,1] -/
  diff_nonneg : ∀ i, 0 ≤ difficulty i
  diff_le_one : ∀ i, difficulty i ≤ 1

/-- Total learning gain from a curriculum given initial competence -/
def totalGain (C : Curriculum) (initCompetence : ℝ) : ℝ :=
  ∑ i, C.learningGain initCompetence i

/-- The zone of proximal development: tasks that are neither too easy nor too hard -/
def inZPD (C : Curriculum) (competence : ℝ) (i : Fin C.numTasks) (margin : ℝ) : Prop :=
  competence - margin ≤ C.difficulty i ∧ C.difficulty i ≤ competence + margin

/-- A two-player self-play system -/
structure SelfPlaySystem where
  /-- Number of strategies -/
  numStrategies : ℕ
  /-- Payoff matrix: row player's payoff -/
  payoff : Fin numStrategies → Fin numStrategies → ℝ
  /-- Zero-sum: row + col = 0 -/
  zero_sum : ∀ i j, payoff i j + payoff j i = 0

/-- The value of a pure strategy against a mixed opponent -/
def strategyValue (S : SelfPlaySystem) (i : Fin S.numStrategies)
    (opponentMix : Fin S.numStrategies → ℝ) : ℝ :=
  ∑ j, opponentMix j * S.payoff i j

/-- Expected score in Elo system -/
def eloExpectedScore (ratingDiff : ℝ) : ℝ :=
  1 / (1 + Real.exp (-ratingDiff))

/-- Cost of one self-play game (forward passes for both players) -/
def selfPlayGameCost (modelParams seqLen : ℕ) : ℕ :=
  2 * modelParams * seqLen

/-- EML self-play cost -/
def emlSelfPlayCost (d seqLen : ℕ) : ℕ :=
  2 * (4 * d) * seqLen

/-- Standard self-play cost -/
def stdSelfPlayCost (d seqLen : ℕ) : ℕ :=
  2 * (d * d) * seqLen

/-- The improvement rate from a task depends on the difficulty-competence gap -/
def taskImprovementRate (competence difficulty : ℝ) : ℝ :=
  4 * (competence * (1 - competence)) * Real.exp (-(competence - difficulty) ^ 2)

end
