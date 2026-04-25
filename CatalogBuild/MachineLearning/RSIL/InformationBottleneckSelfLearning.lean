/-! # CatalogBuild.MachineLearning.RSIL.InformationBottleneckSelfLearning

Auto-generated from theorem catalog database.
Domain: MachineLearning/RSIL
Declarations: 18
-/

import Mathlib

noncomputable section

/-- KL divergence between two distributions (simplified: finite discrete). -/
def klDiv (p q : Fin n → ℝ) : ℝ :=
  ∑ i, p i * (Real.log (p i) - Real.log (q i))



/-- Information bottleneck objective: minimize complexity - β * relevance. -/
def ibObjective (complexity relevance β : ℝ) : ℝ :=
  complexity - β * relevance



/-- Information capacity of a layer with given parameters. -/
def infoCapacity (params : ℕ) (bitsPerParam : ℝ) : ℝ :=
  (params : ℝ) * bitsPerParam



/-- EML compression ratio: ratio of EML to standard capacity. -/
def emlCompressionRatio (d : ℕ) : ℝ :=
  (4 * d : ℝ) / (d * d : ℝ)



/-- Standard parameter count. -/
def ibStandardParams (d : ℕ) : ℕ := d * d



/-- EML parameter count. -/
def ibEmlParams (d : ℕ) : ℕ := 4 * d



/-- In fitting phase: training error is high, complexity is low. -/
def InFittingPhase (trainError complexity threshold : ℝ) : Prop :=
  trainError > threshold ∧ complexity < threshold



/-- In compression phase: training error is low, complexity is being reduced. -/
def InCompressionPhase (trainError complexity threshold : ℝ) : Prop :=
  trainError ≤ threshold ∧ complexity ≥ threshold



/-- [Section: ## Theorems] -/
theorem kl_div_self_zero {n : ℕ} (p : Fin n → ℝ) :
    klDiv p p = 0 := by
  exact Finset.sum_eq_zero fun i _ => by ring;



/-- [Section: # CatalogBuild.MachineLearning.RSIL.InformationBottleneckSelfLearning
Auto-generated from theorem catalog database.
Domain: MachineLearning/RSIL
Declarations: 18] -/
theorem kl_div_zero_iff {n : ℕ} (p : Fin n → ℝ) :
    klDiv p p = 0 := by
  exact?



theorem higher_beta_more_relevance (complexity relevance β₁ β₂ : ℝ)
    (hβ : β₁ ≤ β₂) (hr : 0 ≤ relevance) :
    ibObjective complexity relevance β₂ ≤ ibObjective complexity relevance β₁ := by
  exact sub_le_sub_left ( mul_le_mul_of_nonneg_right hβ hr ) _



theorem zero_beta_pure_compression (complexity relevance : ℝ) :
    ibObjective complexity relevance 0 = complexity := by
  unfold ibObjective; ring;



theorem eml_natural_bottleneck (d : ℕ) (bitsPerParam : ℝ)
    (hd : 5 ≤ d) (hb : 0 < bitsPerParam) :
    infoCapacity (ibEmlParams d) bitsPerParam <
    infoCapacity (ibStandardParams d) bitsPerParam := by
  unfold infoCapacity ibEmlParams ibStandardParams;
  exact mul_lt_mul_of_pos_right ( by norm_cast; nlinarith ) hb



theorem eml_compression_improves (d₁ d₂ : ℕ)
    (hd1 : 0 < d₁) (hd2 : 0 < d₂) (h : d₁ ≤ d₂) :
    emlCompressionRatio d₂ ≤ emlCompressionRatio d₁ := by
  unfold emlCompressionRatio;
  rw [ div_le_div_iff₀ ] <;> norm_cast <;> nlinarith [ mul_pos hd1 hd2 ]



theorem pac_bayes_nonneg (trainError klTerm logTerm n : ℝ)
    (hte : 0 ≤ trainError) (hkl : 0 ≤ klTerm)
    (hlog : 0 ≤ logTerm) (hn : 0 < n) :
    0 ≤ pacBayesBound trainError klTerm logTerm n := by
  exact add_nonneg hte ( Real.sqrt_nonneg _ )



theorem lower_kl_tighter_bound (trainError kl₁ kl₂ logTerm n : ℝ)
    (hkl : kl₁ ≤ kl₂) (hn : 0 < n) :
    pacBayesBound trainError kl₁ logTerm n ≤
    pacBayesBound trainError kl₂ logTerm n := by
  unfold pacBayesBound;
  norm_num [ div_eq_mul_inv ];
  exact Real.sqrt_le_sqrt ( mul_le_mul_of_nonneg_right ( by linarith ) ( by positivity ) )



theorem more_data_tighter_bound (trainError klTerm logTerm n₁ n₂ : ℝ)
    (hn1 : 0 < n₁) (hn2 : 0 < n₂) (hn : n₁ ≤ n₂)
    (hkl : 0 ≤ klTerm) (hlog : 0 ≤ logTerm) :
    pacBayesBound trainError klTerm logTerm n₂ ≤
    pacBayesBound trainError klTerm logTerm n₁ := by
  unfold pacBayesBound;
  gcongr



theorem phases_disjoint (trainError complexity threshold : ℝ) :
    ¬(InFittingPhase trainError complexity threshold ∧
      InCompressionPhase trainError complexity threshold) := by
  unfold InFittingPhase InCompressionPhase; aesop;



end
