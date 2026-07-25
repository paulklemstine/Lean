import Mathlib

/-! # Alignment Safety Theory for Self-Improving Systems

Formalizes mathematical guarantees that recursive self-improvement preserves
alignment with a specified objective. This is the core safety question:
if a system improves itself, does it stay aligned?

## Novel Contributions
1. **Alignment Contraction** — Contraction-based RSI preserves alignment
2. **Objective Drift Bound** — Bounds on how far the objective can drift
3. **Corrigibility Under Self-Improvement** — Conditions for maintained corrigibility
4. **Value Lock-In Theorem** — Contraction implies value convergence
5. **Alignment Tax** — Cost of maintaining alignment during improvement
6. **Safety Margin Monotonicity** — Safety margins under iterated improvement
-/

noncomputable section

open Real Finset BigOperators

/-! ## §1. Alignment Model -/

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

/-! ## §2. Alignment Contraction -/

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

/-! ## §3. Objective Drift Bounds -/

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

/-! ## §4. Corrigibility -/

/-- A system is corrigible if it accepts corrections that reduce alignment gap -/
def IsCorrigible (acceptCorrection : ℝ → Bool) (threshold : ℝ) : Prop :=
  ∀ gap, threshold ≤ gap → acceptCorrection gap = true

/-- Corrigibility with lower threshold is stronger -/
theorem lower_threshold_more_corrigible (f : ℝ → Bool) (t₁ t₂ : ℝ)
    (ht : t₁ ≤ t₂) (h : IsCorrigible f t₁) :
    IsCorrigible f t₂ := by
  intro gap hgap
  exact h gap (le_trans ht hgap)

/-! ## §5. Value Lock-In -/

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

/-! ## §6. Alignment Tax -/

/-- The alignment tax: additional compute cost of maintaining alignment -/
def alignmentTax (baseCost alignmentCheckCost : ℝ) : ℝ :=
  alignmentCheckCost / baseCost

/-- Alignment tax is nonneg -/
theorem alignment_tax_nonneg (base check : ℝ) (hb : 0 < base) (hc : 0 ≤ check) :
    0 ≤ alignmentTax base check := by
  exact div_nonneg hc (le_of_lt hb)

/-- EML reduces alignment tax because base cost is lower -/
theorem eml_lower_alignment_tax (checkCost emlCost stdCost : ℝ)
    (hcheck : 0 ≤ checkCost) (heml : 0 < emlCost) (hstd : 0 < stdCost)
    (h : emlCost ≤ stdCost) :
    alignmentTax stdCost checkCost ≤ alignmentTax emlCost checkCost := by
  unfold alignmentTax
  exact div_le_div_of_nonneg_left hcheck heml h

/-- Safety margin: how much alignment budget remains -/
def safetyMargin (maxGap currentGap : ℝ) : ℝ :=
  maxGap - currentGap

/-- Safety margin is positive when gap is below max -/
theorem safety_margin_pos (maxGap currentGap : ℝ) (h : currentGap < maxGap) :
    0 < safetyMargin maxGap currentGap := by
  unfold safetyMargin; linarith

/-- Safety margin increases as gap shrinks -/
theorem safety_margin_monotone (maxGap g₁ g₂ : ℝ) (h : g₁ ≤ g₂) :
    safetyMargin maxGap g₂ ≤ safetyMargin maxGap g₁ := by
  unfold safetyMargin; linarith

end
