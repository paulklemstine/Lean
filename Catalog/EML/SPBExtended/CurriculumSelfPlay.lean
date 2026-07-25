import Mathlib

/-! # CatalogBuild.MachineLearning.RSIL.CurriculumSelfPlay

Auto-generated from theorem catalog database.
Domain: MachineLearning/RSIL
Declarations: 19
-/


noncomputable section

/-- Average difficulty of a curriculum over N tasks. -/
def avgDifficulty (difficulty : Fin N → ℝ) : ℝ :=
  (∑ i, difficulty i) / N


/-- A curriculum has difficulties in [0,1]. -/
def ValidCurriculum (difficulty : Fin N → ℝ) : Prop :=
  ∀ i, 0 ≤ difficulty i ∧ difficulty i ≤ 1


/-- Zero-sum payoff function: antisymmetric. -/
def zeroSumPayoff (payoff : ℝ) : ℝ × ℝ := (payoff, -payoff)


/-- Elo expected score: σ(Δ) = 1 / (1 + 10^(-Δ/400)). -/
def eloExpected (ratingDiff : ℝ) : ℝ :=
  1 / (1 + (10 : ℝ) ^ (-ratingDiff / 400))


/-- Cost of self-play with given parameter count. -/
def selfPlayCost (params : ℕ) (baseCost : ℝ) : ℝ :=
  baseCost * (params : ℝ) ^ 2


/-- Number of games playable within a compute budget. -/
def gamesPerBudget (params : ℕ) (budget : ℝ) : ℝ :=
  budget / selfPlayCost params 1


/-- Learning rate as function of difficulty and competence: peak at difficulty = competence. -/
def learningRate (difficulty competence : ℝ) : ℝ :=
  1 - (difficulty - competence) ^ 2


/-- Standard parameter count. -/
def csStandardParams (d : ℕ) : ℕ := d * d


/-- EML parameter count. -/
def csEmlParams (d : ℕ) : ℕ := 4 * d


/-- [Section: ## Theorems] -/
theorem avg_difficulty_bounded {N : ℕ} (hN : 0 < N)
    (difficulty : Fin N → ℝ) (hv : ValidCurriculum difficulty) :
    0 ≤ avgDifficulty difficulty ∧ avgDifficulty difficulty ≤ 1 := by
  exact ⟨ div_nonneg ( Finset.sum_nonneg fun _ _ => hv _ |>.1 ) ( Nat.cast_nonneg _ ), div_le_one_of_le₀ ( le_trans ( Finset.sum_le_sum fun _ _ => hv _ |>.2 ) ( by norm_num ) ) ( Nat.cast_nonneg _ ) ⟩


theorem zero_sum_payoff (p : ℝ) :
    (zeroSumPayoff p).1 + (zeroSumPayoff p).2 = 0 := by
  exact sub_self p


theorem self_play_zero_value :
    eloExpected 0 = 1 / 2 := by
  unfold eloExpected; norm_num;


theorem elo_expected_in_unit (Δ : ℝ) :
    0 < eloExpected Δ ∧ eloExpected Δ < 1 := by
  exact ⟨ by exact div_pos zero_lt_one ( by positivity ), by exact div_lt_one ( by positivity ) |>.2 ( by linarith [ Real.rpow_pos_of_pos ( by norm_num : ( 0 : ℝ ) < 10 ) ( -Δ / 400 ) ] ) ⟩


theorem elo_equal_ratings :
    eloExpected 0 = 1 / 2 := by
  exact?


theorem elo_monotone (Δ₁ Δ₂ : ℝ) (h : Δ₁ ≤ Δ₂) :
    eloExpected Δ₁ ≤ eloExpected Δ₂ := by
  unfold eloExpected; gcongr;
  norm_num


theorem eml_self_play_cheaper (d : ℕ) (baseCost : ℝ)
    (hd : 5 ≤ d) (hbc : 0 < baseCost) :
    selfPlayCost (csEmlParams d) baseCost ≤
    selfPlayCost (csStandardParams d) baseCost := by
  unfold selfPlayCost csEmlParams csStandardParams;
  exact mul_le_mul_of_nonneg_left ( mod_cast by nlinarith [ Nat.pow_le_pow_left hd 2 ] ) hbc.le


theorem eml_more_games_per_compute (d : ℕ) (budget : ℝ)
    (hd : 5 ≤ d) (hb : 0 < budget) :
    gamesPerBudget (csStandardParams d) budget ≤
    gamesPerBudget (csEmlParams d) budget := by
  unfold gamesPerBudget;
  unfold selfPlayCost csStandardParams csEmlParams; gcongr ; nlinarith;


theorem optimal_difficulty_at_competence (competence : ℝ) :
    learningRate competence competence = 1 := by
  unfold learningRate; ring


theorem easy_task_less_improvement (difficulty competence : ℝ)
    (h : difficulty ≠ competence) :
    learningRate difficulty competence < learningRate competence competence := by
  unfold learningRate; nlinarith [ mul_self_pos.mpr ( sub_ne_zero.mpr h ) ] ;


end