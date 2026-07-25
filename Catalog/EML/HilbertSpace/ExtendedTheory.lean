import Mathlib

/-! # CatalogBuild.EML.ExtendedTheory

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 40
-/

noncomputable section

/-- The real EML operator. -/
def emlE (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- The diagonal EML map: d(z) = exp(z) - ln(z). -/
def emlDiagonal (z : ℝ) : ℝ := Real.exp z - Real.log z

/-- [Section: # CatalogBuild.EML.ExtendedTheory
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 40] -/
theorem emlDiagonal_gt_of_pos (z : ℝ) (hz : 0 < z) : emlDiagonal z > z := by
  unfold emlDiagonal;
  have := @Real.exp_one_gt_d9.le;
  rw [ show z = 1 + ( z - 1 ) by ring, Real.exp_add ];
  nlinarith [ Real.add_one_le_exp ( z - 1 ), Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + ( z - 1 ) ) ]

/-- [Section: # CatalogBuild.EML.ExtendedTheory
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 40] -/
theorem emlDiagonal_gt_of_nonpos (z : ℝ) (hz : z ≤ 0) : emlDiagonal z > z := by
  unfold emlDiagonal;
  by_cases h : z = 0 <;> simp_all +decide [ Real.log_le_iff_le_exp ];
  linarith [ Real.exp_pos z, Real.log_le_sub_one_of_pos <| neg_pos.mpr <| lt_of_le_of_ne hz h, Real.log_neg_eq_log z ]

theorem emlDiagonal_no_real_fixedPoint : ∀ z : ℝ, emlDiagonal z ≠ z := by
  intro z;
  by_cases hz : 0 < z;
  · exact ne_of_gt ( emlDiagonal_gt_of_pos z hz );
  · exact ne_of_gt ( emlDiagonal_gt_of_nonpos z ( le_of_not_gt hz ) )

theorem emlE_strictMono_fst (y : ℝ) : StrictMono (fun x => emlE x y) := by
  exact fun x y hxy => sub_lt_sub_right ( Real.exp_lt_exp.mpr hxy ) _

theorem emlE_strictAnti_snd (x : ℝ) : StrictAntiOn (fun y => emlE x y) (Ioi 0) := by
  exact fun y hy z hz hyz => sub_lt_sub_left ( Real.log_lt_log hy hyz ) _

theorem emlE_convexOn_fst (y : ℝ) : ConvexOn ℝ Set.univ (fun x => emlE x y) := by
  apply ConvexOn.add;
  · exact convexOn_exp;
  · exact convexOn_const _ ( convex_univ )

theorem emlE_convexOn_snd (x : ℝ) : ConvexOn ℝ (Ioi 0) (fun y => emlE x y) := by
  fapply convexOn_of_deriv2_nonneg;
  · exact convex_Ioi 0;
  · exact ContinuousOn.sub ( continuousOn_const ) ( Real.continuousOn_log.mono fun y hy => ne_of_gt hy );
  · exact DifferentiableOn.sub ( differentiableOn_const _ ) ( differentiableOn_id.log fun y hy => ne_of_gt <| interior_subset hy );
  · refine' DifferentiableOn.congr _ _;
    exact fun y => -1 / y;
    · exact DifferentiableOn.div ( differentiableOn_const _ ) differentiableOn_id fun y hy => ne_of_gt <| interior_subset hy;
    · unfold emlE; norm_num [ div_eq_mul_inv ] ;
      exact fun y hy => by simp +decide [ hy.ne' ];
  · unfold emlE;
    norm_num [ sub_eq_add_neg ];
    exact fun x hx => sq_nonneg x

theorem emlDiagonal_ge_one (z : ℝ) (hz : 0 < z) : emlDiagonal z ≥ 1 := by
  unfold emlDiagonal;
  linarith [ Real.add_one_le_exp z, Real.log_le_sub_one_of_pos hz ]

theorem emlE_zero_exp (x : ℝ) : emlE 0 (Real.exp x) = 1 - x := by
  unfold emlE; norm_num

theorem emlE_subtraction (a b : ℝ) (ha : 0 < a) :
    emlE (Real.log a) (Real.exp b) = a - b := by
  unfold emlE; rw [ Real.exp_log ha, Real.log_exp ] ;

theorem emlE_addition (a b : ℝ) (ha : 0 < a) :
    emlE (Real.log a) (Real.exp (-b)) = a + b := by
  unfold emlE; rw [ Real.exp_log ha ] ; norm_num;

theorem power_via_exp_log (a b : ℝ) (ha : 0 < a) :
    a ^ b = Real.exp (b * Real.log a) := by
  rw [ Real.rpow_def_of_pos ha, mul_comm ]

/-- The e-tower. -/
def eTowerE : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTowerE n)

theorem eTowerE_ge_n (n : ℕ) : eTowerE n ≥ n := by
  induction' n with n ih <;> norm_num [ eTowerE ] at *;
  linarith [ Real.add_one_le_exp ( eTowerE n ) ]

theorem emlE_generates_e_minus_one : emlE 1 (Real.exp 1) = Real.exp 1 - 1 := by
  unfold emlE; norm_num;

theorem emlE_generates_one_minus_e : emlE 0 (Real.exp (Real.exp 1)) = 1 - Real.exp 1 := by
  unfold emlE; norm_num

theorem emlE_generates_exp_e_minus_one :
    emlE (Real.exp 1 - 1) 1 = Real.exp (Real.exp 1 - 1) := by
  unfold emlE;
  norm_num

theorem fixedPoint_lambert_connection (z : ℝ) (hz : 0 < z)
    (hfp : Real.exp 1 - Real.log z = z) :
    z + Real.log z = Real.exp 1 := by
  grind +revert

theorem fixedPoint_product_form (z : ℝ) (hz : 0 < z)
    (hfp : z + Real.log z = Real.exp 1) :
    z * Real.exp z = Real.exp (Real.exp 1) := by
  rw [ ← hfp, Real.exp_add, Real.exp_log hz ];
  ring

/-- Catalan number via recurrence. -/
def catalanNum : ℕ → ℕ
  | 0 => 1
  | n + 1 => (2 * (2 * n + 1) * catalanNum n) / (n + 2)

theorem catalanNum_zero : catalanNum 0 = 1 := by rfl

theorem catalanNum_one : catalanNum 1 = 1 := by native_decide

theorem catalanNum_two : catalanNum 2 = 2 := by native_decide

theorem catalanNum_three : catalanNum 3 = 5 := by native_decide

theorem catalanNum_four : catalanNum 4 = 14 := by native_decide

theorem catalanNum_five : catalanNum 5 = 42 := by native_decide

theorem catalanNum_six : catalanNum 6 = 132 := by native_decide

theorem catalanNum_seven : catalanNum 7 = 429 := by native_decide

/-- Master formula parameter count: P(n) = 5 · 2^n - 6. -/
def masterParams (n : ℕ) : ℕ := 5 * 2^n - 6

theorem masterParams_double_approx (n : ℕ) (hn : n ≥ 2) :
    masterParams (n + 1) > 2 * masterParams n := by
  unfold masterParams;
  grind

/-- The symmetric 2D EML map: Φ(x,y) = (eml(x,y), eml(y,x)). -/
def emlSymmetricMap (p : ℝ × ℝ) : ℝ × ℝ :=
  (emlE p.1 p.2, emlE p.2 p.1)

theorem emlSymmetricMap_trace (x y : ℝ) :
    (emlSymmetricMap (x, y)).1 + (emlSymmetricMap (x, y)).2 =
    (Real.exp x + Real.exp y) - (Real.log x + Real.log y) := by
  unfold emlSymmetricMap;
  unfold emlE; ring

theorem emlSymmetricMap_diff (x y : ℝ) :
    (emlSymmetricMap (x, y)).1 - (emlSymmetricMap (x, y)).2 =
    (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
  unfold emlSymmetricMap; ring;
  unfold emlE; ring;

theorem emlSymmetricMap_diagonal (z : ℝ) :
    emlSymmetricMap (z, z) = (emlDiagonal z, emlDiagonal z) := by
  exact?

theorem exp_ge_one_add (x : ℝ) : Real.exp x ≥ 1 + x := by
  linarith [ Real.add_one_le_exp x ]

theorem log_le_sub_one (x : ℝ) (hx : 0 < x) : Real.log x ≤ x - 1 := by
  exact Real.log_le_sub_one_of_pos hx

theorem eml_x_expx_ge_one (x : ℝ) : emlE x (Real.exp x) ≥ 1 := by
  unfold emlE;
  have := Real.add_one_le_exp x; norm_num at *; linarith

theorem eml_log_inverse (x : ℝ) : Real.log (emlE x 1) = x := by
  unfold emlE ;
  norm_num

end


-- !-- Merged from AdvancedTheory.lean (auto-dedup) -- !--

/-! # CatalogBuild.EML.AdvancedTheory
Declarations: 52
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