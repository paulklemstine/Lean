import Mathlib

/-! # CatalogBuild.MachineLearning.Prediction.MartingalePrediction

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 17
-/


noncomputable section

/-- [Section: # CatalogBuild.MachineLearning.Prediction.MartingalePrediction
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 17] -/
def isSupermartingale (X : ℕ → ℝ) : Prop :=
  ∀ n, X (n + 1) ≤ X n




/-- [Section: # CatalogBuild.MachineLearning.Prediction.MartingalePrediction
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 17] -/
def isSubmartingale (X : ℕ → ℝ) : Prop :=
  ∀ n, X n ≤ X (n + 1)




def isMartingale (X : ℕ → ℝ) : Prop :=
  ∀ n, X (n + 1) = X n




theorem martingale_is_super_and_sub (X : ℕ → ℝ) (hX : isMartingale X) :
    isSupermartingale X ∧ isSubmartingale X :=
  ⟨fun n => le_of_eq (hX n), fun n => le_of_eq (hX n).symm⟩




theorem martingale_constant_value (X : ℕ → ℝ) (hX : isMartingale X) (n : ℕ) :
    X n = X 0 := by
  induction n with
  | zero => rfl
  | succ n ih => rw [hX n, ih]




theorem supermartingale_value_decreases (X : ℕ → ℝ) (hX : isSupermartingale X)
    (n : ℕ) : X n ≤ X 0 := by
  induction n with
  | zero => exact le_rfl
  | succ n ih => exact le_trans (hX n) ih




structure PredictionMarket where
  price : ℝ
  price_nonneg : 0 ≤ price
  price_le_one : price ≤ 1




def MarketHistory := ℕ → PredictionMarket




def isEfficient (history : MarketHistory) : Prop :=
  isMartingale (fun n => (history n).price)




theorem efficient_market_constant (history : MarketHistory)
    (h : isEfficient history) (n : ℕ) :
    (history n).price = (history 0).price :=
  martingale_constant_value _ h n




structure DoobDecomposition (X : ℕ → ℝ) where
  martingalePart : ℕ → ℝ
  predictablePart : ℕ → ℝ
  is_martingale : isMartingale martingalePart
  predictable_starts_zero : predictablePart 0 = 0
  decomposition : ∀ n, X n = martingalePart n + predictablePart n




noncomputable def doobDecompose (X : ℕ → ℝ) : DoobDecomposition X where
  martingalePart := fun _ => X 0
  predictablePart := fun n => X n - X 0
  is_martingale := fun _ => rfl
  predictable_starts_zero := by simp
  decomposition := fun _ => by ring




def hasBoundedIncrements (X : ℕ → ℝ) (c : ℝ) : Prop :=
  ∀ n, |X (n + 1) - X n| ≤ c




theorem bounded_increments_total_bound (X : ℕ → ℝ) (c : ℝ) (hc : 0 ≤ c)
    (hX : hasBoundedIncrements X c) (n : ℕ) :
    |X n - X 0| ≤ n * c := by
  induction' n with n ih;
  · norm_num;
  · exact abs_le.mpr ⟨ by push_cast; linarith [ abs_le.mp ih, abs_le.mp ( hX n ) ], by push_cast; linarith [ abs_le.mp ih, abs_le.mp ( hX n ) ] ⟩




def predictionsConverge (predictions : ℕ → ℝ) (truth : ℝ) : Prop :=
  Filter.Tendsto predictions Filter.atTop (nhds truth)




/-- Exponential smoothing predictor -/
noncomputable def exponentialSmoothing (seq : ℕ → ℝ) (α_param : ℝ) : ℕ → ℝ
  | 0 => seq 0
  | n + 1 => α_param * seq (n + 1) + (1 - α_param) * exponentialSmoothing seq α_param n




/-- Exponential smoothing preserves bounds when 0 ≤ α ≤ 1 -/
theorem exponentialSmoothing_convex (seq : ℕ → ℝ) (α_param : ℝ)
    (hα0 : 0 ≤ α_param) (hα1 : α_param ≤ 1)
    (h_bound : ∀ n, 0 ≤ seq n ∧ seq n ≤ 1) (n : ℕ) :
    0 ≤ exponentialSmoothing seq α_param n ∧ exponentialSmoothing seq α_param n ≤ 1 := by
  induction n with
  | zero => simp [exponentialSmoothing]; exact h_bound 0
  | succ n ih =>
    simp only [exponentialSmoothing]
    constructor
    · nlinarith [(h_bound (n + 1)).1, ih.1]
    · nlinarith [(h_bound (n + 1)).2, ih.2]




end
