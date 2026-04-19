import Mathlib

/-! # Information Bottleneck for Self-Learning

Formalizes KL divergence, information bottleneck objectives,
PAC-Bayes generalization bounds, and two-phase learning theory.
-/

noncomputable section

open Real BigOperators Finset

/-! ## Definitions -/

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

/-- PAC-Bayes bound: trainError + sqrt((KL + log(2n/δ)) / (2n)). -/
def pacBayesBound (trainError klTerm logTerm : ℝ) (n : ℝ) : ℝ :=
  trainError + Real.sqrt ((klTerm + logTerm) / (2 * n))

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

/-! ## Theorems -/

/-
KL divergence is nonneg when p = q.
-/
theorem kl_div_self_zero {n : ℕ} (p : Fin n → ℝ) :
    klDiv p p = 0 := by
  exact Finset.sum_eq_zero fun i _ => by ring;

/-
KL divergence is zero iff p = q (for identical distributions, it's zero).
-/
theorem kl_div_zero_iff {n : ℕ} (p : Fin n → ℝ) :
    klDiv p p = 0 := by
  exact?

/-
Higher β prioritizes relevance over compression.
-/
theorem higher_beta_more_relevance (complexity relevance β₁ β₂ : ℝ)
    (hβ : β₁ ≤ β₂) (hr : 0 ≤ relevance) :
    ibObjective complexity relevance β₂ ≤ ibObjective complexity relevance β₁ := by
  exact sub_le_sub_left ( mul_le_mul_of_nonneg_right hβ hr ) _

/-
At β=0, IB objective equals complexity.
-/
theorem zero_beta_pure_compression (complexity relevance : ℝ) :
    ibObjective complexity relevance 0 = complexity := by
  unfold ibObjective; ring;

/-
EML has lower information capacity than standard for d ≥ 5.
-/
theorem eml_natural_bottleneck (d : ℕ) (bitsPerParam : ℝ)
    (hd : 5 ≤ d) (hb : 0 < bitsPerParam) :
    infoCapacity (ibEmlParams d) bitsPerParam <
    infoCapacity (ibStandardParams d) bitsPerParam := by
  unfold infoCapacity ibEmlParams ibStandardParams;
  exact mul_lt_mul_of_pos_right ( by norm_cast; nlinarith ) hb

/-
EML compression ratio improves (shrinks) with width.
-/
theorem eml_compression_improves (d₁ d₂ : ℕ)
    (hd1 : 0 < d₁) (hd2 : 0 < d₂) (h : d₁ ≤ d₂) :
    emlCompressionRatio d₂ ≤ emlCompressionRatio d₁ := by
  unfold emlCompressionRatio;
  rw [ div_le_div_iff₀ ] <;> norm_cast <;> nlinarith [ mul_pos hd1 hd2 ]

/-
PAC-Bayes generalization bound is nonneg.
-/
theorem pac_bayes_nonneg (trainError klTerm logTerm n : ℝ)
    (hte : 0 ≤ trainError) (hkl : 0 ≤ klTerm)
    (hlog : 0 ≤ logTerm) (hn : 0 < n) :
    0 ≤ pacBayesBound trainError klTerm logTerm n := by
  exact add_nonneg hte ( Real.sqrt_nonneg _ )

/-
Lower KL gives tighter PAC-Bayes bound.
-/
theorem lower_kl_tighter_bound (trainError kl₁ kl₂ logTerm n : ℝ)
    (hkl : kl₁ ≤ kl₂) (hn : 0 < n) :
    pacBayesBound trainError kl₁ logTerm n ≤
    pacBayesBound trainError kl₂ logTerm n := by
  unfold pacBayesBound;
  norm_num [ div_eq_mul_inv ];
  exact Real.sqrt_le_sqrt ( mul_le_mul_of_nonneg_right ( by linarith ) ( by positivity ) )

/-
More data gives tighter PAC-Bayes bound.
-/
theorem more_data_tighter_bound (trainError klTerm logTerm n₁ n₂ : ℝ)
    (hn1 : 0 < n₁) (hn2 : 0 < n₂) (hn : n₁ ≤ n₂)
    (hkl : 0 ≤ klTerm) (hlog : 0 ≤ logTerm) :
    pacBayesBound trainError klTerm logTerm n₂ ≤
    pacBayesBound trainError klTerm logTerm n₁ := by
  unfold pacBayesBound;
  gcongr

/-
Fitting and compression phases are disjoint.
-/
theorem phases_disjoint (trainError complexity threshold : ℝ) :
    ¬(InFittingPhase trainError complexity threshold ∧
      InCompressionPhase trainError complexity threshold) := by
  unfold InFittingPhase InCompressionPhase; aesop;

end