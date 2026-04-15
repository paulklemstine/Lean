/-! # CatalogBuild.EML.AIResearch.NeuralArchitectureTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 18
-/

import Mathlib

noncomputable section

def archSpace (d w : ℕ) : ℕ := w ^ d

def emlArchSpace (d : ℕ) : ℕ := 3 ^ d


theorem eml_search_reduction (d : ℕ) (w : ℕ) (hw : 4 ≤ w) :
    emlArchSpace d ≤ archSpace d w := by
  simp only [emlArchSpace, archSpace]
  exact Nat.pow_le_pow_left (by omega) d


theorem arch_space_exp_growth (w : ℕ) (hw : 2 ≤ w) (d : ℕ) :
    archSpace d w < archSpace (d + 1) w := by
  simp only [archSpace, pow_succ]
  exact lt_mul_of_one_lt_right (Nat.pos_of_ne_zero (by positivity)) (by omega)


theorem eml_vs_standard_nas (d : ℕ) :
    emlArchSpace d ≤ archSpace d 10 :=
  eml_search_reduction d 10 (by omega)

/-! ## §2. Depth-Width Tradeoffs -/


def denseParams (layers width : ℕ) : ℕ := layers * width * width

theorem eml_param_efficiency (d w : ℕ) (hd : 0 < d) (hw : 5 ≤ w) :
    emlParams d w ≤ denseParams d w := by
  exact le_of_lt ( by { unfold emlParams denseParams; nlinarith [ mul_le_mul_left' hw d ] } )


theorem eml_depth_cheaper_than_width (d w : ℕ) (hd : 1 ≤ d) (hw : 2 ≤ w) :
    emlParams (2 * d) w ≤ emlParams d (2 * w) := by
  unfold emlParams; nlinarith

/-! ## §3. Skip Connections and Residual EML -/


def gradientFlow (r : ℝ) (d : ℕ) : ℝ := r ^ d

def residualGradientFlow (r : ℝ) (d : ℕ) : ℝ := 1 + r ^ d


theorem residual_gradient_pos (r : ℝ) (d : ℕ) (hr : 0 ≤ r) :
    0 < residualGradientFlow r d := by
  unfold residualGradientFlow; linarith [pow_nonneg hr d]


theorem skip_prevents_vanishing (r : ℝ) (d : ℕ) :
    gradientFlow r d ≤ residualGradientFlow r d := by
  unfold gradientFlow residualGradientFlow; linarith


def archScore (accuracy : ℝ) (params : ℕ) : ℝ := accuracy / Real.sqrt ↑params


theorem score_mono_accuracy (a1 a2 : ℝ) (p : ℕ) (hp : 0 < p) (ha : a1 ≤ a2) :
    archScore a1 p ≤ archScore a2 p := by
  unfold archScore
  apply div_le_div_of_nonneg_right ha
  exact Real.sqrt_nonneg _


theorem score_mono_params (a : ℝ) (p1 p2 : ℕ) (ha : 0 ≤ a) (hp1 : 0 < p1) (hp : p1 ≤ p2) :
    archScore a p2 ≤ archScore a p1 := by
  unfold archScore; gcongr;

/-! ## §5. EML Layer Composition -/


def emlExpressivity (d : ℕ) : ℕ := 3 ^ d


theorem eml_expressivity_triple (d : ℕ) :
    emlExpressivity (d + 1) = 3 * emlExpressivity d := by
  simp [emlExpressivity, pow_succ, mul_comm]


theorem eml_expressivity_superlinear (d : ℕ) (hd : 3 ≤ d) :
    d < emlExpressivity d := by
  simp only [emlExpressivity]
  calc d < 2 ^ d := Nat.lt_two_pow_self
    _ ≤ 3 ^ d := Nat.pow_le_pow_left (by omega) d


end
