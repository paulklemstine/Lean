/-! # CatalogBuild.Algebra.IntegerEnergy.TemporalSheaves

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 12
-/

import Mathlib

noncomputable section

/-- A time interval [a, b] in ℝ -/
structure TimeInterval where
  left : ℝ
  right : ℝ
  valid : left ≤ right





/-- Two time intervals overlap -/
def TimeInterval.overlaps (I J : TimeInterval) : Prop :=
  I.left < J.right ∧ J.left < I.right





/-- An ensemble of predictors, each making predictions in ℝ -/
structure Ensemble where
  n : ℕ
  predictors : Fin n → (ℝ → ℝ)
  weights : Fin n → ℝ
  weights_nonneg : ∀ i, 0 ≤ weights i
  weights_sum : ∑ i, weights i = 1





/-- The ensemble prediction at time t -/
noncomputable def Ensemble.predict (E : Ensemble) (t : ℝ) : ℝ :=
  ∑ i, E.weights i * E.predictors i t





/-- [Section: # CatalogBuild.MachineLearning.Prediction.TemporalSheaves
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 12] -/
theorem Ensemble.predict_convex (E : Ensemble) (t : ℝ)
    (h_lower : ∀ i, 0 ≤ E.predictors i t)
    (h_upper : ∀ i, E.predictors i t ≤ 1) :
    0 ≤ E.predict t ∧ E.predict t ≤ 1 := by
  exact ⟨ Finset.sum_nonneg fun i _ => mul_nonneg ( E.weights_nonneg i ) ( h_lower i ), by simpa [ Finset.sum_mul _ _ _, E.weights_sum ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => mul_le_mul_of_nonneg_left ( h_upper i ) ( E.weights_nonneg i ) ⟩





/-- A discrete prediction sequence -/
structure PredictionSequence where
  values : ℕ → ℝ
  bounded : ∃ M : ℝ, ∀ n, |values n| ≤ M





/-- Mean squared prediction error over first N steps -/
noncomputable def mspe (prediction actual : ℕ → ℝ) (N : ℕ) : ℝ :=
  (1 / N) * ∑ i ∈ Finset.range N, (prediction i - actual i) ^ 2





/-- [Section: # CatalogBuild.MachineLearning.Prediction.TemporalSheaves
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 12] -/
theorem mspe_nonneg (prediction actual : ℕ → ℝ) (N : ℕ) (hN : 0 < N) :
    0 ≤ mspe prediction actual N := by
  exact mul_nonneg ( by positivity ) ( Finset.sum_nonneg fun _ _ => sq_nonneg _ )





/-- Prediction difficulty levels, ordered by computational complexity -/
inductive PredictionClass where
  | deterministic    -- Fully predictable (periodic, convergent)
  | stochastic       -- Predictable in distribution (ergodic)
  | chaotic          -- Short-term predictable, long-term unpredictable
  | adversarial      -- Actively resists prediction (game-theoretic)
  | incomputable     -- No algorithm can predict (Turing-degree argument)
  deriving DecidableEq





/-- The prediction class determines the achievable horizon -/
noncomputable def horizonByClass : PredictionClass → ENNReal
  | .deterministic => ⊤
  | .stochastic    => ⊤
  | .chaotic       => 42
  | .adversarial   => 1
  | .incomputable  => 0





/-- Deterministic systems have infinite prediction horizon -/
theorem deterministic_infinite_horizon :
    horizonByClass .deterministic = ⊤ := by rfl





/-- Incomputable systems have zero prediction horizon -/
theorem incomputable_zero_horizon :
    horizonByClass .incomputable = 0 := by rfl





end
