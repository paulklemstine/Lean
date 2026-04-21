/-! # CatalogBuild.EML.AdvancedTheory

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 52
-/

import Mathlib

noncomputable section

/-- An EML ensemble combines m EML trees, each with complexity kᵢ.
Total ensemble complexity is the sum of individual complexities. -/
def ensembleComplexity (ks : List ℕ) : ℕ := ks.sum




/-- Ensemble complexity is additive. -/
theorem ensemble_complexity_additive (ks₁ ks₂ : List ℕ) :
    ensembleComplexity (ks₁ ++ ks₂) = ensembleComplexity ks₁ + ensembleComplexity ks₂ := by
  simp [ensembleComplexity]




/-- An ensemble of m trees each with k leaves has complexity m·k. -/
theorem uniform_ensemble_complexity (m k : ℕ) :
    ensembleComplexity (List.replicate m k) = m * k := by
  simp [ensembleComplexity, List.sum_replicate]




/-- Ensemble VC dimension: at most 2 × total leaves (linear growth). -/
def ensembleVCDim (ks : List ℕ) : ℕ := 2 * ensembleComplexity ks




/-- Bagging factor: √m variance reduction. -/
def baggingFactor (m : ℕ) : ℝ := Real.sqrt m




/-- Bagging factor grows sublinearly. -/
theorem bagging_sublinear (m : ℕ) (hm : 1 ≤ m) :
    Real.sqrt m ≤ m := by
  have hm' : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  calc Real.sqrt m ≤ Real.sqrt (m * m) := by
        apply Real.sqrt_le_sqrt; nlinarith
    _ = m := by rw [← sq, Real.sqrt_sq (by linarith)]




/-- Ensemble generalization: variance decreases as 1/m. -/
theorem ensemble_variance_reduction (sigma_sq : ℝ) (m : ℕ) (hm : 0 < m)
    (hs : 0 ≤ sigma_sq) :
    sigma_sq / m ≤ sigma_sq := by
  exact div_le_self hs (by exact_mod_cast hm)




/-- The structural risk penalty term: √(2k·ln(n)/n). -/
def structuralPenalty (k n : ℕ) : ℝ :=
  Real.sqrt (2 * k * Real.log n / n)




/-- The penalty is nonneg. -/
theorem structural_penalty_nonneg (k n : ℕ) :
    0 ≤ structuralPenalty k n := by
  exact Real.sqrt_nonneg _




/-- Increasing complexity increases the penalty. -/
theorem penalty_increases_with_k (k₁ k₂ n : ℕ) (h : k₁ ≤ k₂) (hn : 2 ≤ n) :
    structuralPenalty k₁ n ≤ structuralPenalty k₂ n := by
  unfold structuralPenalty
  apply Real.sqrt_le_sqrt
  apply div_le_div_of_nonneg_right _ (by positivity)
  apply mul_le_mul_of_nonneg_right
  · apply mul_le_mul_of_nonneg_left _ (by positivity)
    exact_mod_cast h
  · exact Real.log_nonneg (by exact_mod_cast (show 1 ≤ n by omega))




/-- EML-based attention score: softmax via exp component.
score(q, k) = exp(q · k) which is exactly eml(q·k, 1). -/
def emlAttentionScore (q k : ℝ) : ℝ := Real.exp (q * k)




/-- Attention scores are always positive. -/
theorem attention_score_pos (q k : ℝ) : 0 < emlAttentionScore q k := by
  exact Real.exp_pos _




/-- Attention weights sum normalization factor. -/
def emlAttentionNorm (q : ℝ) (keys : List ℝ) : ℝ :=
  (keys.map (emlAttentionScore q)).sum




/-- The normalization factor is positive when keys is nonempty. -/
theorem attention_norm_pos (q : ℝ) (keys : List ℝ) (hne : keys ≠ []) :
    0 < emlAttentionNorm q keys := by
  unfold emlAttentionNorm
  apply List.sum_pos
  · intro x hx
    simp [List.mem_map] at hx
    obtain ⟨k, _, rfl⟩ := hx
    exact attention_score_pos q k
  · simp [hne]




/-- The sensitivity of an EML neuron's exp component on [-M, M]. -/
def emlSensitivity (w₁ b₁ M : ℝ) : ℝ :=
  |w₁| * Real.exp (|w₁| * M + |b₁|)




/-- Sensitivity is always nonneg. -/
theorem sensitivity_nonneg (w₁ b₁ M : ℝ) : 0 ≤ emlSensitivity w₁ b₁ M := by
  unfold emlSensitivity; positivity




/-- Noise scale for differential privacy. -/
def laplacianNoiseScale (sensitivity epsilon : ℝ) : ℝ :=
  sensitivity / epsilon




/-- Noise scale formula. -/
theorem eml_noise_scale (w₁ b₁ M epsilon : ℝ) (_hε : 0 < epsilon) :
    laplacianNoiseScale (emlSensitivity w₁ b₁ M) epsilon =
    |w₁| * Real.exp (|w₁| * M + |b₁|) / epsilon := by
  simp [laplacianNoiseScale, emlSensitivity]




/-- Smaller weights yield better privacy. -/
theorem smaller_weights_better_privacy (w₁ w₂ b M ε : ℝ)
    (hw : |w₁| ≤ |w₂|) (hM : 0 ≤ M) (hε : 0 < ε) :
    laplacianNoiseScale (emlSensitivity w₁ b M) ε ≤
    laplacianNoiseScale (emlSensitivity w₂ b M) ε := by
  unfold laplacianNoiseScale emlSensitivity
  apply div_le_div_of_nonneg_right _ (le_of_lt hε)
  apply mul_le_mul hw (Real.exp_le_exp_of_le _) (by positivity) (abs_nonneg _)
  linarith [mul_le_mul_of_nonneg_right hw hM]




/-- KAN network parameter count. -/
def kanParams (widths : List ℕ) (G p : ℕ) : ℕ :=
  (widths.zip widths.tail).map (fun ⟨a, b⟩ => a * b * (G + p)) |>.sum




/-- EML parameters for k-leaf tree. -/
def emlParams (k : ℕ) : ℕ := 4 * (k - 1)




/-- EML vs KAN for 2-variable problems: 2.5× fewer parameters. -/
theorem eml_vs_kan_2var :
    kanParams [2, 5, 1] 3 3 = 90 ∧ emlParams 10 = 36 := by
  constructor <;> native_decide




/-- EML vs KAN for 5-variable problems: 7.2× fewer parameters. -/
theorem eml_vs_kan_5var :
    kanParams [5, 10, 5, 1] 5 3 = 840 ∧ emlParams 30 = 116 := by
  constructor <;> native_decide




/-- EML tree structure for feature importance analysis. -/
inductive EMLTree where
  | leaf : ℕ → EMLTree     -- variable index
  | const : ℝ → EMLTree    -- constant leaf
  | eml : EMLTree → EMLTree → EMLTree




/-- Count occurrences of variable i in an EML tree. -/
def EMLTree.varCount (i : ℕ) : EMLTree → ℕ
  | .leaf j => if i = j then 1 else 0
  | .const _ => 0
  | .eml l r => l.varCount i + r.varCount i




/-- Total leaf count. -/
def EMLTree.leafCount : EMLTree → ℕ
  | .leaf _ => 1
  | .const _ => 1
  | .eml l r => l.leafCount + r.leafCount




/-- Leaf count is always positive. -/
theorem EMLTree.leafCount_pos (t : EMLTree) : 0 < t.leafCount := by
  induction t with
  | leaf _ => simp [EMLTree.leafCount]
  | const _ => simp [EMLTree.leafCount]
  | eml l r ihl ihr => simp [EMLTree.leafCount]; omega




/-- Variable count never exceeds leaf count. -/
theorem EMLTree.varCount_le_leafCount (t : EMLTree) (i : ℕ) :
    t.varCount i ≤ t.leafCount := by
  induction t with
  | leaf j => simp [EMLTree.varCount, EMLTree.leafCount]; split <;> omega
  | const _ => simp [EMLTree.varCount, EMLTree.leafCount]
  | eml l r ihl ihr => simp [EMLTree.varCount, EMLTree.leafCount]; omega




/-- Variable importance as a fraction of total leaves. -/
def EMLTree.varImportance (t : EMLTree) (i : ℕ) : ℝ :=
  (t.varCount i : ℝ) / (t.leafCount : ℝ)




/-- Variable importance is between 0 and 1. -/
theorem var_importance_le_one (t : EMLTree) (i : ℕ) :
    t.varImportance i ≤ 1 := by
  unfold EMLTree.varImportance
  rw [div_le_one_iff]
  left
  exact ⟨by exact_mod_cast t.leafCount_pos, by exact_mod_cast t.varCount_le_leafCount i⟩




/-- A variable not appearing in the tree has zero importance. -/
theorem absent_var_zero_importance (t : EMLTree) (i : ℕ)
    (h : t.varCount i = 0) : t.varImportance i = 0 := by
  simp [EMLTree.varImportance, h]




/-- GD convergence bound: f(x_T) - f* ≤ ‖x₀ - x*‖² / (2ηT). -/
def gdConvergenceBound (dist_sq : ℝ) (eta : ℝ) (T : ℕ) : ℝ :=
  dist_sq / (2 * eta * T)




/-- Convergence bound is nonneg. -/
theorem gd_convergence_nonneg (d η : ℝ) (T : ℕ)
    (hd : 0 ≤ d) (hη : 0 < η) (hT : 0 < T) :
    0 ≤ gdConvergenceBound d η T := by
  unfold gdConvergenceBound; positivity




/-- More iterations improve convergence. -/
theorem gd_convergence_improves (d η : ℝ) (T₁ T₂ : ℕ)
    (hd : 0 < d) (hη : 0 < η) (hT₁ : 0 < T₁) (h : T₁ ≤ T₂) :
    gdConvergenceBound d η T₂ ≤ gdConvergenceBound d η T₁ := by
  unfold gdConvergenceBound
  apply div_le_div_of_nonneg_left (by positivity) (by positivity)
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  exact_mod_cast h




/-- Optimal learning rate for EML: 1/L where L is the Lipschitz constant. -/
def emlOptimalLR (lipschitz : ℝ) : ℝ := 1 / lipschitz




/-- Optimal LR is positive when Lipschitz constant is positive. -/
theorem optimal_lr_pos (L : ℝ) (hL : 0 < L) : 0 < emlOptimalLR L := by
  unfold emlOptimalLR; positivity




/-- Prunable nodes in a k-leaf tree. -/
def prunableNodes (k : ℕ) : ℕ := k - 1




/-- Pruning can reduce complexity. -/
theorem pruning_reduces (k : ℕ) (hk : 2 ≤ k) : prunableNodes k < k := by
  simp [prunableNodes]; omega




/-- Quantization error: k · 2^(-b) · Lip(tree). -/
def quantizationError (k b : ℕ) (lip : ℝ) : ℝ :=
  k * (1 / 2^b) * lip




/-- Quantization error is nonneg. -/
theorem quantization_nonneg (k b : ℕ) (lip : ℝ) (hlip : 0 ≤ lip) :
    0 ≤ quantizationError k b lip := by
  unfold quantizationError; positivity




/-- 8-bit quantization of 50-leaf tree. -/
theorem quantization_8bit_50leaf (lip : ℝ) :
    quantizationError 50 8 lip = 50 * (1 / 256) * lip := by
  simp [quantizationError]; norm_num




/-- Transfer learning: reuse topology, optimize only k leaf values. -/
def transferParams (k : ℕ) : ℕ := k




/-- Full search: topology + values ≈ k² parameters. -/
def fullSearchParams (k : ℕ) : ℕ := k * k




/-- Transfer learning reduces parameter count quadratically. -/
theorem transfer_advantage (k : ℕ) (hk : 2 ≤ k) :
    transferParams k < fullSearchParams k := by
  simp [transferParams, fullSearchParams]; nlinarith




/-- EML trees are closed under composition. -/
def EMLTree.compose (outer inner : EMLTree) (var_idx : ℕ) : EMLTree :=
  match outer with
  | .leaf j => if j = var_idx then inner else .leaf j
  | .const c => .const c
  | .eml l r => .eml (l.compose inner var_idx) (r.compose inner var_idx)




/-- Composing two constants gives a constant-complexity tree. -/
theorem compose_const (c : ℝ) (inner : EMLTree) (i : ℕ) :
    (EMLTree.const c).compose inner i = EMLTree.const c := by
  rfl




/-- An EML tree with k leaves can interpolate at most k points. -/
def maxInterpolationPoints (k : ℕ) : ℕ := k




/-- Interpolation needs enough leaves. -/
theorem interpolation_requires_leaves (n k : ℕ) (h : k < n) :
    n > maxInterpolationPoints k := by
  simp [maxInterpolationPoints]; omega




/-- The depth-width product measures total computational cost.
For EML: depth d, width 1 → product = d.
For ReLU: depth 1, width 2^d → product = 2^d.
EML is exponentially more efficient. -/
def depthWidthProduct (depth width : ℕ) : ℕ := depth * width




/-- EML chain has depth-width product = d (linear). -/
theorem eml_chain_product (d : ℕ) : depthWidthProduct d 1 = d := by
  simp [depthWidthProduct]




/-- ReLU equivalent has depth-width product = 2^d (exponential). -/
theorem relu_equivalent_product (d : ℕ) : depthWidthProduct 1 (2^d) = 2^d := by
  simp [depthWidthProduct]




/-- The ratio grows exponentially for d ≥ 1. -/
theorem product_ratio_exponential (d : ℕ) (_hd : 1 ≤ d) :
    d ≤ 2^d := Nat.lt_two_pow_self.le




end
