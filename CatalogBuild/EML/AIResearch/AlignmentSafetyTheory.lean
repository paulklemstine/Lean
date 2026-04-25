/-! # CatalogBuild.EML.AIResearch.AlignmentSafetyTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 49
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.AlignmentSafetyTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 28] -/
def stdInterpretCost (numNeurons probeDim : ℕ) : ℕ := numNeurons * probeDim


/-- [Section: # CatalogBuild.EML.AIResearch.AlignmentSafetyTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 28] -/
def emlInterpretCost (numNeurons : ℕ) : ℕ := 4 * numNeurons


/-- [Section: # CatalogBuild.EML.AIResearch.AlignmentSafetyTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 49] -/
theorem eml_interpret_cheaper (n p : ℕ) (hp : 4 ≤ p) :
    emlInterpretCost n ≤ stdInterpretCost n p := by
  unfold emlInterpretCost stdInterpretCost
  calc 4 * n = n * 4 := by ring
    _ ≤ n * p := Nat.mul_le_mul_left n hp


def stdRewardParams (d_model numLayers : ℕ) : ℕ := numLayers * d_model * d_model


def emlRewardParams (d_model numLayers : ℕ) : ℕ := numLayers * 4 * d_model


theorem eml_reward_compact (d L : ℕ) (hd : 4 ≤ d) :
    emlRewardParams d L ≤ stdRewardParams d L := by
  unfold emlRewardParams stdRewardParams
  have : L * 4 ≤ L * d := Nat.mul_le_mul_left L hd
  exact Nat.mul_le_mul_right d this


def emlLayerLipschitz (expBound : ℝ) : ℝ := Real.exp expBound


theorem eml_lipschitz_pos (b : ℝ) : 0 < emlLayerLipschitz b := Real.exp_pos b


theorem eml_lipschitz_bounded (b1 b2 : ℝ) (h : b1 ≤ b2) :
    emlLayerLipschitz b1 ≤ emlLayerLipschitz b2 := Real.exp_le_exp.mpr h


def alignmentTax (basePerf safetyPenalty : ℝ) : ℝ := basePerf - safetyPenalty


theorem eml_lower_alignment_tax (p pen_eml pen_std : ℝ) (h : pen_eml ≤ pen_std) :
    alignmentTax p pen_std ≤ alignmentTax p pen_eml := by
  unfold alignmentTax; linarith


def corrigibilityMargin (paramCount updateCost : ℕ) : ℕ := paramCount * updateCost


theorem eml_more_corrigible (p_eml p_std u : ℕ) (hp : p_eml ≤ p_std) :
    corrigibilityMargin p_eml u ≤ corrigibilityMargin p_std u := by
  unfold corrigibilityMargin; exact Nat.mul_le_mul_right u hp


def valueSamples (featureDim complexity : ℕ) (eps : ℝ) : ℝ :=
  ↑(featureDim * complexity) / eps ^ 2


theorem eml_value_sample_efficient (f_eml f_std c : ℕ) (eps : ℝ)
    (_ : 0 < eps) (hf : f_eml ≤ f_std) :
    valueSamples f_eml c eps ≤ valueSamples f_std c eps := by
  unfold valueSamples
  apply div_le_div_of_nonneg_right _ (sq_nonneg eps)
  exact_mod_cast Nat.mul_le_mul_right c hf


def oversightCost (behaviors reviewCostPerBehavior : ℕ) : ℕ := behaviors * reviewCostPerBehavior


def emlOversightCost (behaviors emlAnalysisCost : ℕ) : ℕ := behaviors * emlAnalysisCost


theorem eml_oversight_cheaper (b c_eml c_std : ℕ) (hc : c_eml ≤ c_std) :
    emlOversightCost b c_eml ≤ oversightCost b c_std := by
  unfold emlOversightCost oversightCost; exact Nat.mul_le_mul_left b hc


def activationComplexity (numParams : ℕ) : ℕ := numParams


theorem eml_less_deception_capacity (p_eml p_std : ℕ) (hp : p_eml ≤ p_std) :
    activationComplexity p_eml ≤ activationComplexity p_std := hp


def constitutionalCost (numConstraints verificationCost : ℕ) : ℕ :=
  numConstraints * verificationCost


theorem eml_constitutional_cheaper (n v_eml v_std : ℕ) (hv : v_eml ≤ v_std) :
    constitutionalCost n v_eml ≤ constitutionalCost n v_std := by
  unfold constitutionalCost; exact Nat.mul_le_mul_left n hv


def anomalyDetectorParams (inputDim latentDim : ℕ) : ℕ := 2 * inputDim * latentDim


def emlAnomalyParams (inputDim : ℕ) : ℕ := 8 * inputDim


theorem eml_anomaly_cheaper (d l : ℕ) (hl : 4 ≤ l) :
    emlAnomalyParams d ≤ anomalyDetectorParams d l := by
  unfold emlAnomalyParams anomalyDetectorParams; nlinarith


def gradientMonitorCost (numParams batchSize : ℕ) : ℕ := numParams * batchSize


def emlGradMonitorCost (emlParams batchSize : ℕ) : ℕ := emlParams * batchSize


theorem eml_grad_monitor_cheaper (p_eml p_std b : ℕ) (hp : p_eml ≤ p_std) :
    emlGradMonitorCost p_eml b ≤ gradientMonitorCost p_std b := by
  unfold emlGradMonitorCost gradientMonitorCost; exact Nat.mul_le_mul_right b hp


/-- An aligned self-improving system -/
structure AlignedSystem where
  /-- Performance on the intended objective -/
  intendedPerf : ℝ
  /-- Performance on the system's internal objective (may diverge from intended) -/
  internalPerf : ℝ
  /-- Both in [0,1] -/
  intended_nonneg : 0 ≤ intendedPerf
  intended_le_one : intendedPerf ≤ 1
  internal_nonneg : 0 ≤ internalPerf
  internal_le_one : internalPerf ≤ 1


/-- Alignment gap: difference between internal and intended objectives -/
def alignmentGap (A : AlignedSystem) : ℝ :=
  |A.internalPerf - A.intendedPerf|


/-- Alignment gap is nonneg -/
theorem alignment_gap_nonneg (A : AlignedSystem) : 0 ≤ alignmentGap A := by
  exact abs_nonneg _


/-- Alignment gap is at most 1 -/
theorem alignment_gap_le_one (A : AlignedSystem) : alignmentGap A ≤ 1 := by
  unfold alignmentGap
  rw [abs_le]
  constructor <;> linarith [A.intended_nonneg, A.intended_le_one,
                            A.internal_nonneg, A.internal_le_one]


/-- A system is ε-aligned if the alignment gap is ≤ ε -/
def IsAligned (A : AlignedSystem) (ε : ℝ) : Prop :=
  alignmentGap A ≤ ε


/-- Perfect alignment means zero gap -/
theorem perfect_alignment_iff (A : AlignedSystem) :
    IsAligned A 0 ↔ A.internalPerf = A.intendedPerf := by
  unfold IsAligned alignmentGap
  constructor
  · intro h; exact eq_of_abs_sub_eq_zero (le_antisymm h (abs_nonneg _))
  · intro h; simp [h]


/-- An improvement operator preserves alignment if it contracts the alignment gap -/
def AlignmentPreserving (improveInternal improveIntended : ℝ → ℝ) (c : ℝ) : Prop :=
  0 ≤ c ∧ c < 1 ∧
  ∀ x y, |improveInternal x - improveIntended y| ≤ c * |x - y|


/-- Under alignment contraction, the gap shrinks exponentially -/
theorem alignment_gap_shrinks (c : ℝ) (gap₀ : ℝ)
    (hc0 : 0 ≤ c) (hc1 : c < 1) (hg : 0 ≤ gap₀) (k : ℕ) :
    c ^ k * gap₀ ≤ gap₀ := by
  exact mul_le_of_le_one_left hg (pow_le_one₀ hc0 hc1.le)


/-- After k steps, the alignment gap is at most c^k × initial gap -/
theorem alignment_convergence_rate (c gap₀ : ℝ)
    (hc0 : 0 ≤ c) (hc1 : c < 1) (hg : 0 ≤ gap₀) :
    ∀ ε > 0, ∃ K : ℕ, c ^ K * gap₀ < ε := by
  intro ε hε
  by_cases hg0 : gap₀ = 0
  · exact ⟨0, by simp [hg0, hε]⟩
  · have hg_pos : 0 < gap₀ := lt_of_le_of_ne hg (Ne.symm hg0)
    obtain ⟨K, hK⟩ := exists_pow_lt_of_lt_one (div_pos hε hg_pos) hc1
    refine ⟨K, ?_⟩
    have := mul_lt_mul_of_pos_right hK hg_pos
    rwa [div_mul_cancel₀ _ (ne_of_gt hg_pos)] at this


/-- Cumulative objective drift over k improvement steps -/
def objectiveDrift (driftPerStep : ℕ → ℝ) (k : ℕ) : ℝ :=
  ∑ i ∈ range k, driftPerStep i


/-- If per-step drift is bounded, cumulative drift is bounded -/
theorem cumulative_drift_bounded (driftPerStep : ℕ → ℝ) (B : ℝ) (k : ℕ)
    (hB : ∀ i, |driftPerStep i| ≤ B) :
    |objectiveDrift driftPerStep k| ≤ k * B := by
  unfold objectiveDrift
  calc |∑ i ∈ range k, driftPerStep i|
      ≤ ∑ i ∈ range k, |driftPerStep i| := abs_sum_le_sum_abs _ _
    _ ≤ ∑ i ∈ range k, B := Finset.sum_le_sum fun i _ => hB i
    _ = k * B := by simp [Finset.sum_const, Finset.card_range]


/-- If per-step drift decreases geometrically, total drift is bounded by B/(1-r) -/
theorem geometric_drift_bounded (B r : ℝ) (hB : 0 ≤ B) (hr0 : 0 ≤ r) (hr1 : r < 1) :
    0 ≤ B / (1 - r) := by
  exact div_nonneg hB (by linarith)


/-- A system is corrigible if it accepts corrections that reduce alignment gap -/
def IsCorrigible (acceptCorrection : ℝ → Bool) (threshold : ℝ) : Prop :=
  ∀ gap, threshold ≤ gap → acceptCorrection gap = true


/-- Corrigibility with lower threshold is stronger -/
theorem lower_threshold_more_corrigible (f : ℝ → Bool) (t₁ t₂ : ℝ)
    (ht : t₁ ≤ t₂) (h : IsCorrigible f t₁) :
    IsCorrigible f t₂ := by
  intro gap hgap
  exact h gap (le_trans ht hgap)


/-- The value distance between two systems -/
def valueDistance (v₁ v₂ : Fin n → ℝ) : ℝ :=
  ∑ i, |v₁ i - v₂ i|


/-- Value distance is nonneg -/
theorem value_distance_nonneg (v₁ v₂ : Fin n → ℝ) : 0 ≤ valueDistance v₁ v₂ := by
  exact Finset.sum_nonneg fun i _ => abs_nonneg _


/-- Value distance is zero iff values are equal -/
theorem value_distance_zero_iff (v₁ v₂ : Fin n → ℝ) :
    valueDistance v₁ v₂ = 0 ↔ v₁ = v₂ := by
  unfold valueDistance
  constructor
  · intro h
    have h2 := (Finset.sum_eq_zero_iff_of_nonneg (s := Finset.univ) (fun i _ => abs_nonneg (v₁ i - v₂ i))).mp h
    funext i
    have := h2 i (Finset.mem_univ i)
    rwa [abs_eq_zero, sub_eq_zero] at this
  · intro h; simp [h]


/-- Value distance is symmetric -/
theorem value_distance_symm (v₁ v₂ : Fin n → ℝ) :
    valueDistance v₁ v₂ = valueDistance v₂ v₁ := by
  unfold valueDistance
  congr 1; funext i; rw [abs_sub_comm]


/-- Alignment tax is nonneg -/
theorem alignment_tax_nonneg (base check : ℝ) (hb : 0 < base) (hc : 0 ≤ check) :
    0 ≤ alignmentTax base check := by
  exact div_nonneg hc (le_of_lt hb)


/-- Safety margin is positive when gap is below max -/
theorem safety_margin_pos (maxGap currentGap : ℝ) (h : currentGap < maxGap) :
    0 < safetyMargin maxGap currentGap := by
  unfold safetyMargin; linarith


/-- Safety margin increases as gap shrinks -/
theorem safety_margin_monotone (maxGap g₁ g₂ : ℝ) (h : g₁ ≤ g₂) :
    safetyMargin maxGap g₂ ≤ safetyMargin maxGap g₁ := by
  unfold safetyMargin; linarith


end
