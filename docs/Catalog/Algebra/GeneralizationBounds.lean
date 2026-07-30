import MachineLearning.EffectiveComplexity

/-!
# Algebraic Generalization Bounds for Compressed Neural Networks

This file extends the catalog's `EffectiveComplexityProfile` with reusable certificates
for PAC-Bayes and compression arguments.  The statements isolate the algebraic core of
such bounds: quotient complexity, description length, and posterior KL divergence add,
whereas unused ambient parameters do not.
-/

open Real

noncomputable section

namespace AlgebraicGeneralizationBounds

open EffectiveComplexity

/-- A finite architecture summary. `rawParameters` counts all trainable parameters,
while `activeParameters` counts those retained by a compression certificate. -/
structure ArchitectureSummary where
  layerWidths : List ℕ
  rawParameters : ℕ
  activeParameters : ℕ
  active_le_raw : activeParameters ≤ rawParameters

/-- An additive architecture complexity: retained parameters plus layer widths. -/
def ArchitectureSummary.structuralComplexity (A : ArchitectureSummary) : ℕ :=
  A.activeParameters + A.layerWidths.sum

/-- A simultaneous compression and PAC-Bayes certificate for an existing catalog
profile.  The natural-valued part combines quotient and code complexity. -/
structure ComplexityCertificate (P : EffectiveComplexityProfile) where
  structuralBudget : ℕ
  posteriorBudget : ℝ
  structural_bound : P.quotientComplexity + P.codeLength ≤ structuralBudget
  posterior_bound : P.posteriorKL ≤ posteriorBudget
  posterior_nonneg : 0 ≤ P.posteriorKL

/-- Total real-valued budget supplied by a complexity certificate. -/
def ComplexityCertificate.totalBudget {P : EffectiveComplexityProfile}
    (C : ComplexityCertificate P) : ℝ :=
  (C.structuralBudget : ℝ) + C.posteriorBudget

/-- The square-root complexity radius appearing in elementary PAC-Bayes and
compression bounds. -/
def complexityRadius (complexity samples : ℝ) : ℝ :=
  Real.sqrt (complexity / samples)

/-- The effective complexity is bounded by the sum of a compression budget and a
posterior KL budget. -/
theorem effectiveRate_le_certificate
    (P : EffectiveComplexityProfile) (C : ComplexityCertificate P) :
    P.effectiveRate ≤ C.totalBudget := by
  unfold EffectiveComplexityProfile.effectiveRate ComplexityCertificate.totalBudget
  have hstruct :
      (P.quotientComplexity : ℝ) + (P.codeLength : ℝ) ≤ C.structuralBudget := by
    exact_mod_cast C.structural_bound
  linarith [C.posterior_bound]

/-- Unified PAC-Bayes/compression bound: a certificate fitting inside the sample
budget proves generalization at the requested scale. -/
theorem generalizes_of_certificate
    (P : EffectiveComplexityProfile) (C : ComplexityCertificate P)
    (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ)
    (hbudget : C.totalBudget ≤ (P.sampleSize : ℝ) * ε ^ 2) :
    GeneralizesAtScale P ε δ := by
  exact ⟨hε, hδ, (effectiveRate_le_certificate P C).trans hbudget⟩

/-- Standard confidence specialization.  A posterior budget of `log (1/δ)` and a
compression budget below the residual sample budget imply generalization. -/
theorem pacBayes_compression_confidence_bound
    (P : EffectiveComplexityProfile) (C : ComplexityCertificate P)
    (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ)
    (hpost : C.posteriorBudget ≤ Real.log (1 / δ))
    (hstruct : (C.structuralBudget : ℝ) + Real.log (1 / δ) ≤
      (P.sampleSize : ℝ) * ε ^ 2) :
    GeneralizesAtScale P ε δ := by
  apply generalizes_of_certificate P C ε δ hε hδ
  unfold ComplexityCertificate.totalBudget
  linarith

/-- If the effective rate is nonnegative and fits in an `ε²` sample budget, its
square-root PAC-Bayes radius is at most `ε`. -/
theorem complexityRadius_le_accuracy
    (P : EffectiveComplexityProfile) (ε : ℝ)
    (hn : 0 < P.sampleSize) (hε : 0 ≤ ε)
    (hbudget : P.effectiveRate ≤ (P.sampleSize : ℝ) * ε ^ 2) :
    complexityRadius P.effectiveRate P.sampleSize ≤ ε := by
  unfold complexityRadius
  rw [Real.sqrt_le_left hε]
  have hn' : (0 : ℝ) < P.sampleSize := by exact_mod_cast hn
  exact (div_le_iff₀ hn').2 (by simpa [mul_comm] using hbudget)

/-- A strictly smaller certified complexity gives a strictly smaller square-root
bound whenever the sample size is positive. -/
theorem tighter_radius_of_strict_compression
    (compressed raw samples : ℝ)
    (hc : 0 ≤ compressed) (hlt : compressed < raw) (hs : 0 < samples) :
    complexityRadius compressed samples < complexityRadius raw samples := by
  unfold complexityRadius
  apply Real.sqrt_lt_sqrt
  · exact div_nonneg hc hs.le
  · exact (div_lt_div_iff_of_pos_right hs).2 hlt

/-- Architecture-to-sample-complexity bridge.  If quotient and code complexity are
controlled by the retained architecture, then its structural complexity plus the
posterior term controls generalization. -/
theorem architecture_controls_sample_complexity
    (P : EffectiveComplexityProfile) (A : ArchitectureSummary)
    (ε δ κ : ℝ) (hε : 0 < ε) (hδ : 0 < δ)
    (hqcode : P.quotientComplexity + P.codeLength ≤ A.structuralComplexity)
    (hkl : P.posteriorKL ≤ κ)
    (hbudget : (A.structuralComplexity : ℝ) + κ ≤
      (P.sampleSize : ℝ) * ε ^ 2) :
    GeneralizesAtScale P ε δ := by
  unfold GeneralizesAtScale EffectiveComplexityProfile.effectiveRate
  have hstruct : (P.quotientComplexity : ℝ) + (P.codeLength : ℝ) ≤
      A.structuralComplexity := by
    exact_mod_cast hqcode
  exact ⟨hε, hδ, by linarith⟩

/-- Increasing only ambient parameter dimension preserves a certificate and hence
all certificate-derived generalization guarantees. -/
theorem overparameterized_profile_generalizes
    (P : EffectiveComplexityProfile) (C : ComplexityCertificate P)
    (k : ℕ) (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ)
    (hbudget : C.totalBudget ≤ (P.sampleSize : ℝ) * ε ^ 2) :
    ∃ C' : ComplexityCertificate (P.overparametrizedBy k),
      C'.totalBudget = C.totalBudget ∧
      GeneralizesAtScale (P.overparametrizedBy k) ε δ := by
  let C' : ComplexityCertificate (P.overparametrizedBy k) :=
    { structuralBudget := C.structuralBudget
      posteriorBudget := C.posteriorBudget
      structural_bound := by
        simpa [EffectiveComplexityProfile.overparametrizedBy] using C.structural_bound
      posterior_bound := by
        simpa [EffectiveComplexityProfile.overparametrizedBy] using C.posterior_bound
      posterior_nonneg := by
        simpa [EffectiveComplexityProfile.overparametrizedBy] using C.posterior_nonneg }
  refine ⟨C', rfl, ?_⟩
  apply generalizes_of_certificate _ C' ε δ hε hδ
  simpa [C', EffectiveComplexityProfile.overparametrizedBy] using hbudget

/-- There are arbitrarily overparameterized profiles with a fixed, nonzero effective
complexity that generalize once the sample budget dominates that complexity. -/
theorem arbitrarily_overparameterized_nonzero_generalization
    (n extra : ℕ) (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ)
    (hone : (1 : ℝ) ≤ (n : ℝ) * ε ^ 2) :
    ∃ P : EffectiveComplexityProfile,
      P.paramDim = n + extra + 1 ∧
      P.sampleSize = n ∧
      P.paramDim > P.sampleSize ∧
      P.effectiveRate = 1 ∧
      GeneralizesAtScale P ε δ := by
  let P : EffectiveComplexityProfile := ⟨n + extra + 1, 1, 0, 0, n⟩
  refine ⟨P, rfl, rfl, ?_, ?_, hε, hδ, ?_⟩
  · dsimp [P]
    omega
  · norm_num [P, EffectiveComplexityProfile.effectiveRate]
  · simpa [P, EffectiveComplexityProfile.effectiveRate] using hone

end AlgebraicGeneralizationBounds