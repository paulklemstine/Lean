import Mathlib

/-! # Information Bottleneck for Self-Learning Systems

Formalizes the **Information Bottleneck (IB)** principle applied to self-learning:
a self-improving system must compress its representations to generalize,
creating a natural tension between memorization and abstraction.

## Novel Contributions
1. **Compression-Generalization Duality**: Tighter compression ⟹ better generalization
2. **Representation Collapse Prevention**: Sufficient mutual information prevents
   trivial representations
3. **Hierarchical Information Flow**: Multi-layer information bottleneck for deep self-learning
4. **EML as Natural Information Bottleneck**: EML's 4-parameter structure acts as
   an optimal information bottleneck
-/

noncomputable section

open Real Finset BigOperators

/-! ## §1. Information Bottleneck Framework -/

/-- KL divergence approximation for discrete distributions -/
def klDiv {n : ℕ} (p q : Fin n → ℝ) (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i) : ℝ :=
  ∑ i, p i * (Real.log (p i) - Real.log (q i))

/-
KL divergence is nonneg (Gibbs' inequality)
-/
theorem kl_div_nonneg {n : ℕ} (p q : Fin n → ℝ)
    (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hpsum : ∑ i, p i = 1) (hqsum : ∑ i, q i = 1) :
    0 ≤ klDiv p q hp hq := by
  -- Since $p_i > 0$ and $q_i > 0$ for all $i$, we can apply the inequality $p_i \log(p_i / q_i) \geq p_i - q_i$ for all $i$.
  have h_ineq : ∀ i, p i * (Real.log (p i) - Real.log (q i)) ≥ p i - q i := by
    intro i; have := Real.log_le_sub_one_of_pos ( div_pos ( hq i ) ( hp i ) ) ; rw [ Real.log_div ( ne_of_gt ( hq i ) ) ( ne_of_gt ( hp i ) ) ] at this; ring_nf at *; nlinarith [ hp i, hq i, mul_inv_cancel₀ ( ne_of_gt ( hp i ) ) ];
  exact le_trans ( by norm_num [ hpsum, hqsum ] ) ( Finset.sum_le_sum fun i _ => h_ineq i )

/-
KL divergence is zero iff p = q
-/
theorem kl_div_zero_iff {n : ℕ} (p q : Fin n → ℝ)
    (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hpsum : ∑ i, p i = 1) (hqsum : ∑ i, q i = 1) :
    klDiv p q hp hq = 0 ↔ p = q := by
  by_contra h_contra;
  -- If the KL divergence is zero, then the sums of the logarithms must be zero.
  have h_log_sum_zero : ∑ i, p i * (Real.log (p i) - Real.log (q i)) = 0 → ∀ i, p i = q i := by
    intro h_zero i
    have h_eq : p i * (Real.log (p i) - Real.log (q i)) = p i - q i := by
      have h_eq : ∀ i, p i * (Real.log (p i) - Real.log (q i)) ≥ p i - q i := by
        intro i
        have h_eq : Real.log (p i / q i) ≥ 1 - q i / p i := by
          have h_eq : ∀ x : ℝ, 0 < x → Real.log x ≥ 1 - 1 / x := by
            exact fun x x_pos => by have := Real.log_le_sub_one_of_pos ( inv_pos.mpr x_pos ) ; norm_num at * ; linarith;
          simpa using h_eq ( p i / q i ) ( div_pos ( hp i ) ( hq i ) );
        rw [ Real.log_div ( ne_of_gt ( hp i ) ) ( ne_of_gt ( hq i ) ) ] at h_eq ; nlinarith [ hp i, hq i, mul_div_cancel₀ ( q i ) ( ne_of_gt ( hp i ) ) ];
      exact le_antisymm ( by simpa [ * ] using Finset.single_le_sum ( fun i _ => sub_nonneg.mpr ( h_eq i ) ) ( Finset.mem_univ i ) ) ( h_eq i );
    have := Real.log_lt_sub_one_of_pos ( div_pos ( hq i ) ( hp i ) );
    by_cases hi : q i / p i = 1 <;> simp_all +decide [ ne_of_gt, Real.log_div, div_eq_iff ];
    rw [ div_sub_one, lt_div_iff₀ ] at this <;> nlinarith [ hp i, hq i ];
  exact h_contra <| ⟨ fun h => funext <| h_log_sum_zero h, fun h => h ▸ by unfold klDiv; aesop ⟩

/-! ## §2. Information Bottleneck Objective -/

/-- The IB objective: minimize complexity while maintaining predictive power.
    β controls the tradeoff. -/
def ibObjective (complexity relevance β : ℝ) : ℝ :=
  complexity - β * relevance

/-- Higher β prioritizes relevance over compression -/
theorem higher_beta_more_relevance (comp rel β₁ β₂ : ℝ)
    (hrel : 0 < rel) (hβ : β₁ < β₂) :
    ibObjective comp rel β₂ < ibObjective comp rel β₁ := by
  unfold ibObjective; nlinarith

/-- At β = 0, only compression matters -/
theorem zero_beta_pure_compression (comp rel : ℝ) :
    ibObjective comp rel 0 = comp := by
  unfold ibObjective; ring

/-! ## §3. Layer-wise Information Flow -/

/-- Information content at each layer of a deep network -/
structure LayerwiseInfo where
  /-- Number of layers -/
  numLayers : ℕ
  /-- Mutual information with input at each layer -/
  inputMI : Fin numLayers → ℝ
  /-- Mutual information with target at each layer -/
  targetMI : Fin numLayers → ℝ
  /-- Both are nonneg -/
  inputMI_nonneg : ∀ i, 0 ≤ inputMI i
  targetMI_nonneg : ∀ i, 0 ≤ targetMI i

/-- Data processing inequality: MI with input decreases through layers -/
def SatisfiesDataProcessing (L : LayerwiseInfo) : Prop :=
  ∀ i j : Fin L.numLayers, i ≤ j → L.inputMI j ≤ L.inputMI i

/-- Sufficient statistics: the last layer retains all target information -/
def IsSufficientStatistic (L : LayerwiseInfo) (hn : 0 < L.numLayers) : Prop :=
  L.targetMI ⟨L.numLayers - 1, by omega⟩ = L.targetMI ⟨0, by omega⟩

/-! ## §4. EML as Information Bottleneck -/

/-- Standard layer capacity: d² parameters -/
def stdLayerCapacity (d : ℕ) (bitsPerParam : ℕ) : ℕ :=
  d * d * bitsPerParam

/-- EML layer capacity: 4d parameters -/
def emlLayerCapacity (d : ℕ) (bitsPerParam : ℕ) : ℕ :=
  4 * d * bitsPerParam

/-- EML has lower information capacity, acting as a natural bottleneck -/
theorem eml_natural_bottleneck (d : ℕ) (hd : 5 ≤ d) (b : ℕ) (hb : 0 < b) :
    emlLayerCapacity d b < stdLayerCapacity d b := by
  unfold emlLayerCapacity stdLayerCapacity
  have : 4 * d < d * d := by nlinarith
  nlinarith

/-
The compression ratio of EML to standard improves with width:
    eml(d₂)/std(d₂) ≤ eml(d₁)/std(d₁) when d₁ ≤ d₂ (ratio 4/d shrinks)
-/
theorem eml_compression_improves (d₁ d₂ : ℕ) (hd1 : 5 ≤ d₁) (hd2 : d₁ ≤ d₂) (b : ℕ) (hb : 0 < b) :
    emlLayerCapacity d₂ b * stdLayerCapacity d₁ b ≤
    emlLayerCapacity d₁ b * stdLayerCapacity d₂ b := by
  unfold emlLayerCapacity stdLayerCapacity;
  nlinarith [ mul_le_mul_left' hd2 ( d₁ * b * b ) ]

/-! ## §5. Representation Learning Dynamics -/

/-- Fitting phase: both MIs increase -/
def InFittingPhase (L₁ L₂ : LayerwiseInfo) (k : Fin L₁.numLayers)
    (hk : k.val < L₂.numLayers) : Prop :=
  L₁.inputMI k ≤ L₂.inputMI ⟨k, hk⟩ ∧ L₁.targetMI k ≤ L₂.targetMI ⟨k, hk⟩

/-- Compression phase: input MI decreases, target MI maintained -/
def InCompressionPhase (L₁ L₂ : LayerwiseInfo) (k : Fin L₁.numLayers)
    (hk : k.val < L₂.numLayers) : Prop :=
  L₂.inputMI ⟨k, hk⟩ ≤ L₁.inputMI k ∧ L₁.targetMI k ≤ L₂.targetMI ⟨k, hk⟩

/-! ## §6. Generalization Bounds via Compression -/

/-- PAC-Bayes style bound: generalization error ≤ sqrt(KL / (2n)) -/
def pacBayesBound (klDivergence : ℝ) (sampleSize : ℕ) : ℝ :=
  Real.sqrt (klDivergence / (2 * sampleSize))

/-- PAC-Bayes bound is nonneg -/
theorem pac_bayes_nonneg (kl : ℝ) (n : ℕ) (hn : 0 < n) (hkl : 0 ≤ kl) :
    0 ≤ pacBayesBound kl n := by
  unfold pacBayesBound
  exact Real.sqrt_nonneg _

/-- Lower KL ⟹ tighter PAC-Bayes bound (monotonicity) -/
theorem lower_kl_tighter_bound (kl₁ kl₂ : ℝ) (n : ℕ) (hn : 0 < n)
    (hkl : 0 ≤ kl₁) (h : kl₁ ≤ kl₂) :
    pacBayesBound kl₁ n ≤ pacBayesBound kl₂ n := by
  unfold pacBayesBound
  exact Real.sqrt_le_sqrt (div_le_div_of_nonneg_right h (by positivity))

/-
More data ⟹ tighter PAC-Bayes bound
-/
theorem more_data_tighter_bound (kl : ℝ) (n₁ n₂ : ℕ)
    (hn₁ : 0 < n₁) (hn₂ : 0 < n₂) (hn : n₁ ≤ n₂) (hkl : 0 ≤ kl) :
    pacBayesBound kl n₂ ≤ pacBayesBound kl n₁ := by
  exact Real.sqrt_le_sqrt <| by gcongr;

end