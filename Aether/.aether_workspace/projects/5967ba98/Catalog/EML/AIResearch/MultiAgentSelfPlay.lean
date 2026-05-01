import Mathlib

/-! # CatalogBuild.EML.AIResearch.MultiAgentSelfPlay

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 19
-/

noncomputable section

/-- A population of self-improving agents -/
structure AgentPopulation where
  /-- Number of agents -/
  numAgents : ℕ
  /-- Performance of each agent -/
  performance : Fin numAgents → ℝ
  /-- Performances in [0,1] -/
  perf_nonneg : ∀ i, 0 ≤ performance i
  perf_le_one : ∀ i, performance i ≤ 1

/-- Average population performance -/
def avgPerformance (P : AgentPopulation) (hn : 0 < P.numAgents) : ℝ :=
  (∑ i, P.performance i) / P.numAgents

/-- Average performance is in [0,1] -/
theorem avg_performance_bounded (P : AgentPopulation) (hn : 0 < P.numAgents) :
    0 ≤ avgPerformance P hn ∧ avgPerformance P hn ≤ 1 := by
  constructor
  · exact div_nonneg (Finset.sum_nonneg fun i _ => P.perf_nonneg i) (by positivity)
  · unfold avgPerformance
    rw [div_le_one (by positivity : (0 : ℝ) < ↑P.numAgents)]
    calc ∑ i, P.performance i
        ≤ ∑ _i : Fin P.numAgents, (1 : ℝ) := Finset.sum_le_sum fun i _ => P.perf_le_one i
      _ = ↑P.numAgents := by simp [Finset.card_univ, Fintype.card_fin]

/-- Population diversity: variance of performances -/
def populationDiversity (P : AgentPopulation) (hn : 0 < P.numAgents) : ℝ :=
  (∑ i, (P.performance i - avgPerformance P hn) ^ 2) / P.numAgents

/-- Diversity is nonneg -/
theorem diversity_nonneg (P : AgentPopulation) (hn : 0 < P.numAgents) :
    0 ≤ populationDiversity P hn := by
  exact div_nonneg (Finset.sum_nonneg fun i _ => sq_nonneg _) (by positivity)

/-- Zero diversity means all agents have the same performance -/
theorem zero_diversity_uniform (P : AgentPopulation) (hn : 0 < P.numAgents)
    (h : populationDiversity P hn = 0) :
    ∀ i, P.performance i = avgPerformance P hn := by
  unfold populationDiversity at h
  have h_sum : ∑ i, (P.performance i - avgPerformance P hn) ^ 2 = 0 := by
    by_contra h_ne
    have h_pos : 0 < ∑ i, (P.performance i - avgPerformance P hn) ^ 2 :=
      lt_of_le_of_ne (Finset.sum_nonneg fun i _ => sq_nonneg _) (Ne.symm h_ne)
    linarith [div_pos h_pos (by positivity : (0 : ℝ) < ↑P.numAgents)]
  intro i
  have : (P.performance i - avgPerformance P hn) ^ 2 = 0 := by
    have h2 := (Finset.sum_eq_zero_iff_of_nonneg (s := Finset.univ)
      (fun i _ => sq_nonneg (P.performance i - avgPerformance P hn))).mp h_sum
    exact h2 i (Finset.mem_univ i)
  nlinarith [sq_nonneg (P.performance i - avgPerformance P hn)]

/-- Elo update: winner gains K points, loser loses K points -/
def eloUpdate (ratingWinner ratingLoser K : ℝ) : ℝ × ℝ :=
  (ratingWinner + K, ratingLoser - K)

/-- Total Elo is conserved after an update -/
theorem elo_conservation (rW rL K : ℝ) :
    (eloUpdate rW rL K).1 + (eloUpdate rW rL K).2 = rW + rL := by
  unfold eloUpdate; ring

/-- Selection pressure: fraction of population replaced per generation -/
def selectionPressure (numReplaced numTotal : ℕ) : ℝ :=
  (numReplaced : ℝ) / (numTotal : ℝ)

/-- Selection pressure is in [0,1] -/
theorem selection_pressure_bounded (r n : ℕ) (hr : r ≤ n) (hn : 0 < n) :
    0 ≤ selectionPressure r n ∧ selectionPressure r n ≤ 1 := by
  unfold selectionPressure
  constructor
  · positivity
  · rw [div_le_one (by positivity : (0 : ℝ) < ↑n)]
    exact_mod_cast hr

/-- Higher selection pressure means more competition -/
theorem higher_pressure_more_competition (r₁ r₂ n : ℕ)
    (hn : 0 < n) (hr : r₁ ≤ r₂) :
    selectionPressure r₁ n ≤ selectionPressure r₂ n := by
  unfold selectionPressure
  exact div_le_div_of_nonneg_right (by exact_mod_cast hr) (by positivity)

/-- Transfer efficiency: how much of agent i's skill transfers to agent j -/
def transferEfficiency (similarity : ℝ) (taskOverlap : ℝ) : ℝ :=
  similarity * taskOverlap

/-- Transfer efficiency is bounded by similarity when overlap ≤ 1 -/
theorem transfer_le_similarity (s t : ℝ) (hs : 0 ≤ s) (ht : 0 ≤ t) (ht1 : t ≤ 1) :
    transferEfficiency s t ≤ s := by
  unfold transferEfficiency
  nlinarith

/-- Transfer efficiency is bounded by overlap when similarity ≤ 1 -/
theorem transfer_le_overlap (s t : ℝ) (hs : 0 ≤ s) (hs1 : s ≤ 1) (ht : 0 ≤ t) :
    transferEfficiency s t ≤ t := by
  unfold transferEfficiency
  nlinarith

/-- Perfect similarity and full overlap give perfect transfer -/
theorem perfect_transfer (t : ℝ) :
    transferEfficiency 1 t = t := by
  unfold transferEfficiency; ring

/-- With a fixed compute budget, EML enables more agents -/
def maxAgents (budget agentCost : ℕ) : ℕ :=
  budget / agentCost

/-- EML enables more agents due to lower per-agent cost -/
theorem eml_more_agents (budget d : ℕ) (hd : 5 ≤ d) (hb : d * d ≤ budget) :
    maxAgents budget (d * d) ≤ maxAgents budget (4 * d) := by
  unfold maxAgents
  exact Nat.div_le_div_left (by nlinarith) (by positivity)

/-- Population fitness improves if every agent improves -/
theorem population_improves {n : ℕ} (perf₁ perf₂ : Fin n → ℝ)
    (h : ∀ i, perf₁ i ≤ perf₂ i) :
    ∑ i, perf₁ i ≤ ∑ i, perf₂ i := by
  exact Finset.sum_le_sum fun i _ => h i

/-- Average performance improves if every agent improves -/
theorem avg_performance_improves {n : ℕ} (perf₁ perf₂ : Fin n → ℝ)
    (hn : 0 < n) (h : ∀ i, perf₁ i ≤ perf₂ i) :
    (∑ i, perf₁ i) / n ≤ (∑ i, perf₂ i) / n := by
  exact div_le_div_of_nonneg_right (population_improves perf₁ perf₂ h) (by positivity)

end
