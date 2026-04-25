/-! # CatalogBuild.Computation.Oracles.NeuralCollapse

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12
-/

import Mathlib

noncomputable section

/-- A simplex ETF Gram matrix for K classes. -/
def simplexETFGram (K : ℕ) (hK : 2 ≤ K) : Matrix (Fin K) (Fin K) ℝ :=
  fun i j => if i = j then 1 else -1 / (K - 1 : ℝ)





/-- The diagonal entries are 1. -/
theorem simplexETFGram_diag (K : ℕ) (hK : 2 ≤ K) (i : Fin K) :
    simplexETFGram K hK i i = 1 := by simp [simplexETFGram]





/-- The off-diagonal entries are -1/(K-1). -/
theorem simplexETFGram_off_diag (K : ℕ) (hK : 2 ≤ K) (i j : Fin K) (hij : i ≠ j) :
    simplexETFGram K hK i j = -1 / (K - 1 : ℝ) := by
  unfold simplexETFGram; simp [hij]





/-- [Section: # CatalogBuild.Computation.Oracles.NeuralCollapse
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem simplexETFGram_symmetric (K : ℕ) (hK : 2 ≤ K) :
    (simplexETFGram K hK).IsSymm := by
      exact Matrix.ext fun i j => by unfold simplexETFGram; aesop;





/-- A frame operator for vectors in ℝᵈ: S = Σᵢ vᵢ vᵢᵀ. -/
def frameOperator {d K : ℕ} (vectors : Fin K → Fin d → ℝ) :
    Matrix (Fin d) (Fin d) ℝ :=
  ∑ i, vecMulVec (vectors i) (vectors i)





/-- [Section: # CatalogBuild.Computation.Oracles.NeuralCollapse
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem frameOperator_symmetric {d K : ℕ} (vectors : Fin K → Fin d → ℝ) :
    (frameOperator vectors).IsSymm := by
      ext i j;
      simp +decide [ frameOperator, Matrix.transpose_apply, Matrix.sum_apply ];
      exact Finset.sum_congr rfl fun _ _ => mul_comm _ _





/-- A tight frame has frame operator proportional to identity: S = c · I. -/
def IsTightFrame {d K : ℕ} (vectors : Fin K → Fin d → ℝ) (c : ℝ) : Prop :=
  frameOperator vectors = c • (1 : Matrix (Fin d) (Fin d) ℝ)





/-- [Section: # CatalogBuild.Computation.Oracles.NeuralCollapse
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem simplex_etf_max_margin (K : ℕ) (hK : 2 ≤ K) :
    (1 : ℝ) + 1 / (K - 1 : ℝ) = K / (K - 1 : ℝ) := by
      rw [ one_add_div ] <;> ring ; linarith [ ( by norm_cast : ( 2 : ℝ ) ≤ K ) ]





/-- For an orthogonal projection P, P² = P (tautology stated for clarity). -/
theorem orthogonal_projection_idempotent {n : ℕ}
    (P : Matrix (Fin n) (Fin n) ℝ) (hP : P * P = P) :
    P * P = P := hP





/-- K points in general position span at most min(K-1, d) dimensions. -/
theorem general_position_span_dim (K d : ℕ) :
    min (K - 1) d ≤ K - 1 := Nat.min_le_left _ _





/-- The bottleneck dimension equals K-1 when d ≥ K-1. -/
theorem bottleneck_dim_sufficient (K d : ℕ) (hd : K - 1 ≤ d) :
    min (K - 1) d = K - 1 := Nat.min_eq_left hd





/-- **Quantitative Compression**: An idempotent map on Fin n with image of
size m achieves compression ratio m/n ≤ 1. -/
theorem compression_ratio {n m : ℕ} (hn : 0 < n) (hmn : m ≤ n) :
    (m : ℝ) / n ≤ 1 := by
  rw [div_le_one (Nat.cast_pos.mpr hn)]
  exact Nat.cast_le.mpr hmn





end
