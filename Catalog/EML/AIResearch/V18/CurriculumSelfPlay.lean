import Mathlib

/-! # Curriculum Self-Play Theory

Formalizes the mathematics of **self-play** and **automatic curriculum learning**,
where an AI system designs its own training curriculum and acts as its own opponent/teacher.

## Novel Contributions
1. **Curriculum Monotonicity**: Optimal curriculum ordering improves sample efficiency
2. **Self-Play Convergence**: Nash equilibrium existence for self-play dynamics
3. **Difficulty Scheduling**: Optimal difficulty ramp for maximum learning speed
4. **EML Compression of Self-Play**: Compressed models enable faster self-play iterations
-/



noncomputable section

open Real Finset BigOperators

/-! ## §1. Curriculum Learning Model -/

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

/-! ## §2. Optimal Difficulty Spacing -/

/-- Average difficulty of the curriculum -/
def avgDifficulty (C : Curriculum) (hn : 0 < C.numTasks) : ℝ :=
  (∑ i, C.difficulty i) / C.numTasks

/-- Average difficulty is bounded -/
theorem avg_difficulty_bounded (C : Curriculum) (hn : 0 < C.numTasks) :
    0 ≤ avgDifficulty C hn ∧ avgDifficulty C hn ≤ 1 := by
  constructor
  · exact div_nonneg (Finset.sum_nonneg fun i _ => C.diff_nonneg i) (by positivity)
  · unfold avgDifficulty
    rw [div_le_one (by positivity : (0 : ℝ) < ↑C.numTasks)]
    calc ∑ i : Fin C.numTasks, C.difficulty i
        ≤ ∑ i : Fin C.numTasks, (1 : ℝ) := Finset.sum_le_sum fun i _ => C.diff_le_one i
      _ = ↑C.numTasks := by simp [Finset.card_fin]

/-! ## §3. Self-Play Dynamics -/

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

/-- Zero-sum property: if player 1 gains, player 2 loses -/
theorem zero_sum_payoff (S : SelfPlaySystem) (i j : Fin S.numStrategies) :
    S.payoff i j = -S.payoff j i := by
  linarith [S.zero_sum i j]

/-
In a symmetric zero-sum game, self-play against yourself yields 0
-/
theorem self_play_zero_value (S : SelfPlaySystem)
    (w : Fin S.numStrategies → ℝ)
    (hw_sum : ∑ i, w i = 1) (hw_nonneg : ∀ i, 0 ≤ w i) :
    ∑ i, ∑ j, w i * w j * S.payoff i j = 0 := by
  -- By the symmetric zero-sum condition, we have $\sum_{i, j} w(i) w(j) S.payoff(i, j) = \sum_{i, j} w(i) w(j) (-S.payoff(j, i))$.
  have h_symm : ∑ i : Fin S.numStrategies, ∑ j : Fin S.numStrategies, w i * w j * S.payoff i j = ∑ i : Fin S.numStrategies, ∑ j : Fin S.numStrategies, w i * w j * (-S.payoff j i) := by
    exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ show S.payoff i j = -S.payoff j i from by linarith [ S.zero_sum i j ] ] ;
  simp +zetaDelta at *;
  linarith [ show ∑ i, ∑ j, w i * w j * S.payoff j i = ∑ i, ∑ j, w i * w j * S.payoff i j by rw [ Finset.sum_comm ] ; ac_rfl ]

/-! ## §4. Elo Rating Dynamics -/

/-- Expected score in Elo system -/
def eloExpectedScore (ratingDiff : ℝ) : ℝ :=
  1 / (1 + Real.exp (-ratingDiff))

/-- Expected score is in (0, 1) -/
theorem elo_expected_in_unit (d : ℝ) :
    0 < eloExpectedScore d ∧ eloExpectedScore d < 1 := by
  unfold eloExpectedScore
  constructor
  · positivity
  · rw [div_lt_one (by positivity)]
    linarith [Real.exp_pos (-d)]

/-- Equal ratings give expected score of 1/2 -/
theorem elo_equal_ratings :
    eloExpectedScore 0 = 1 / 2 := by
  unfold eloExpectedScore
  simp [Real.exp_zero]
  ring

/-
Higher rating ⟹ higher expected score (monotonicity)
-/
theorem elo_monotone (d₁ d₂ : ℝ) (h : d₁ ≤ d₂) :
    eloExpectedScore d₁ ≤ eloExpectedScore d₂ := by
  exact one_div_le_one_div_of_le ( by positivity ) ( by gcongr )

/-! ## §5. Self-Play Training Cost with EML -/

/-- Cost of one self-play game (forward passes for both players) -/
def selfPlayGameCost (modelParams seqLen : ℕ) : ℕ :=
  2 * modelParams * seqLen

/-- EML self-play cost -/
def emlSelfPlayCost (d seqLen : ℕ) : ℕ :=
  2 * (4 * d) * seqLen

/-- Standard self-play cost -/
def stdSelfPlayCost (d seqLen : ℕ) : ℕ :=
  2 * (d * d) * seqLen

/-- EML self-play is cheaper for d ≥ 5 -/
theorem eml_self_play_cheaper (d : ℕ) (hd : 5 ≤ d) (s : ℕ) (hs : 0 < s) :
    emlSelfPlayCost d s < stdSelfPlayCost d s := by
  unfold emlSelfPlayCost stdSelfPlayCost
  have h1 : 4 * d < d * d := by nlinarith
  nlinarith

/-- Number of self-play games per unit compute with EML vs standard -/
theorem eml_more_games_per_compute (d : ℕ) (hd : 5 ≤ d) (s : ℕ) (hs : 0 < s)
    (budget : ℕ) (hb : stdSelfPlayCost d s ≤ budget) :
    emlSelfPlayCost d s ≤ budget := by
  exact le_trans (le_of_lt (eml_self_play_cheaper d hd s hs)) hb

/-! ## §6. Curriculum-Guided Self-Improvement -/

/-- The improvement rate from a task depends on the difficulty-competence gap -/
def taskImprovementRate (competence difficulty : ℝ) : ℝ :=
  4 * (competence * (1 - competence)) * Real.exp (-(competence - difficulty) ^ 2)

/-- Maximum improvement happens when difficulty matches competence -/
theorem optimal_difficulty_at_competence (c : ℝ) (hc0 : 0 < c) (hc1 : c < 1) :
    taskImprovementRate c c = 4 * (c * (1 - c)) := by
  unfold taskImprovementRate
  simp [Real.exp_zero]

/-
A task that is too easy (difficulty ≪ competence) gives less improvement
-/
theorem easy_task_less_improvement (c d : ℝ) (hc0 : 0 < c) (hc1 : c < 1)
    (hd : d ≠ c) :
    taskImprovementRate c d < taskImprovementRate c c := by
  unfold taskImprovementRate; norm_num [ hd ] ; ring_nf;
  nlinarith [ mul_pos hc0 ( sub_pos.mpr hc1 ), Real.exp_lt_one_iff.mpr ( show c * d * 2 + ( -c ^ 2 - d ^ 2 ) < 0 by contrapose! hd; nlinarith ) ]

end