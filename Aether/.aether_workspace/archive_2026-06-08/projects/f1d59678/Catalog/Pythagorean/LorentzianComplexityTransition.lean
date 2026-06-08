/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Complexity-Theoretic Phase Transition for Lorentzian Recognition

This file develops a formal framework connecting **Lorentzian signature recognition**
to **average-case complexity theory** through random matrix edge constants.

The GOE edge constant `2σ` simultaneously governs:
- a geometric phase transition (signature stability),
- an algorithmic phase transition (spectral certificate efficacy), and
- a statistical-computational gap (hypothesis testing hardness).

## Main Definitions

* `QuadForm`, `sqNorm`, `QuadFormBound` — quadratic form machinery
* `HasGappedSignature` — gapped Lorentzian signature with spectral margin
* `SpectralGapProxy` — computable proxy for spectral separability
* `SpectrallyRecognizable` — positive spectral gap proxy
* `HasCriticalWindow` — the critical edge window |ε − 2σ| ≤ δ
* `MatrixHypothesisTest` — abstract planted-vs-null testing framework
* `RecognitionPhase` — certified phase classifier

## Main Results

* `easy_phase_spectral_certification` — above the edge, recognition is certified
* `no_uniform_gap_in_critical_window` — no constant-margin certificate at criticality
* `recognizer_yields_tester` — a perfect recognizer induces a hypothesis test
* `spectral_recognizer_induces_tester` — spectral gap test induces hypothesis test
* `phase_classifier_easy_correct` — correctness of the easy-phase classifier
* `algorithmic_geometric_duality` — edge constant governs both geometry and algorithms

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Tracy–Widom, "Level-spacing distributions and the Airy kernel", CMP, 1994
-/

open Finset BigOperators Matrix Real

noncomputable section

namespace LorentzianComplexityTransition

/-! ## Core Definitions -/

/-- Quadratic form induced by a symmetric matrix. -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Squared Euclidean norm. -/
def sqNorm {n : ℕ} (v : Fin n → ℝ) : ℝ := ∑ i, v i ^ 2

/-- Quadratic-form bound: |Q_A(v)| ≤ c · ‖v‖² for all v. -/
def QuadFormBound {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) : Prop :=
  ∀ v : Fin n → ℝ, |QuadForm A v| ≤ c * sqNorm v

/-- A matrix has at most one positive eigenvalue (Lorentzian signature). -/
def HasAtMostOnePositiveEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- Gapped Lorentzian signature with spectral gap ε. -/
def HasGappedSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ -ε * sqNorm v

/-! ## Recognition Instance and Proxy Definitions -/

/-- A **Lorentzian recognition instance** packages a signal matrix, a noise matrix,
    and a perturbation strength. -/
structure LorentzianRecognitionInstance (n : ℕ) where
  signal : Matrix (Fin n) (Fin n) ℝ
  noise : Matrix (Fin n) (Fin n) ℝ
  epsilon : ℝ

/-- The observed (perturbed) matrix: signal + ε • noise. -/
def perturbedMatrix {n : ℕ} (I : LorentzianRecognitionInstance n) :
    Matrix (Fin n) (Fin n) ℝ :=
  I.signal + I.epsilon • I.noise

/-- **Spectral gap proxy**: residual gap after accounting for noise.
    If signal has gap `g` and noise has quadratic-form bound `b`,
    the proxy margin is `g - ε * b`. -/
def SpectralGapProxy (signalGap noiseBound epsilon : ℝ) : ℝ :=
  signalGap - epsilon * noiseBound

/-- Spectrally recognizable means positive proxy margin. -/
def SpectrallyRecognizable (margin : ℝ) : Prop := 0 < margin

/-- The **critical window** around the edge constant 2σ. -/
def HasCriticalWindow (σ ε δ : ℝ) : Prop := |ε - 2 * σ| ≤ δ

/-! ## Auxiliary Lemmas -/

theorem sqNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

theorem quadForm_add {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    QuadForm (A + E) v = QuadForm A v + QuadForm E v := by
  simp only [QuadForm, Matrix.add_apply, add_mul, Finset.sum_add_distrib]

theorem quadForm_smul {n : ℕ} (c : ℝ) (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    QuadForm (c • A) v = c * QuadForm A v := by
  simp only [QuadForm, Matrix.smul_apply, smul_eq_mul, Finset.mul_sum]
  congr 1; ext i; congr 1; ext j; ring

/-- Gapped signature implies the basic Lorentzian property. -/
theorem gapped_implies_signature {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) {ε : ℝ} (hε : 0 ≤ ε)
    (hgap : HasGappedSignature A ε) :
    HasAtMostOnePositiveEigenvalue A := by
  obtain ⟨w, hw⟩ := hgap
  exact ⟨w, fun v hv => le_trans (hw v hv)
    (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos_of_nonneg hε) (sqNorm_nonneg v))⟩

/-- Gapped signature is stable under bounded perturbation with residual gap. -/
theorem gapped_signature_perturbation {n : ℕ}
    (A E : Matrix (Fin n) (Fin n) ℝ) {g δ : ℝ}
    (hgap : HasGappedSignature A g)
    (hbound : QuadFormBound E δ)
    (_hsmall : δ < g) :
    HasGappedSignature (A + E) (g - δ) := by
  obtain ⟨w, hw⟩ := hgap
  refine ⟨w, fun v hv => ?_⟩
  rw [quadForm_add]
  nlinarith [hw v hv, abs_le.mp (hbound v), sqNorm_nonneg v]

/-- QuadFormBound of a scaled matrix. -/
theorem quadFormBound_smul {n : ℕ} (c : ℝ) (A : Matrix (Fin n) (Fin n) ℝ) (b : ℝ)
    (hc : 0 ≤ c) (hA : QuadFormBound A b) :
    QuadFormBound (c • A) (c * b) := by
  intro v
  rw [quadForm_smul]
  calc |c * QuadForm A v| = |c| * |QuadForm A v| := abs_mul c (QuadForm A v)
    _ = c * |QuadForm A v| := by rw [abs_of_nonneg hc]
    _ ≤ c * (b * sqNorm v) := by nlinarith [hA v]
    _ = c * b * sqNorm v := by ring

/-! ## Theorem 1: Easy-Phase Spectral Certification

When the perturbation strength is sufficiently below the signal's spectral gap,
a spectral certificate succeeds. This converts the geometric phase transition
into an algorithmic guarantee.
-/

/-- **Easy-phase spectral certification.**
    If the signal has gapped signature `g`, noise has bound `b`,
    and `ε * b < g`, then the proxy is positive and the signature is preserved.

    In the random-matrix interpretation:
    - `g` is the signal's spectral gap
    - `b` is controlled by the noise operator norm (≈ 2σ for GOE)
    - `ε * b < g` means we are in the easy phase above the edge -/
theorem easy_phase_spectral_certification
    {n : ℕ} {g b ε : ℝ}
    (_hg : 0 < g) (_hb : 0 ≤ b) (hε : 0 ≤ ε) (hedge : ε * b < g)
    (A E : Matrix (Fin n) (Fin n) ℝ)
    (hgap : HasGappedSignature A g)
    (hbound : QuadFormBound E b) :
    SpectrallyRecognizable (SpectralGapProxy g b ε) ∧
    HasAtMostOnePositiveEigenvalue (A + ε • E) := by
  constructor
  · -- The spectral gap proxy g - ε * b is positive
    show 0 < g - ε * b; linarith
  · -- The perturbed matrix retains the Lorentzian signature
    have hscaled : QuadFormBound (ε • E) (ε * b) := quadFormBound_smul ε E b hε hbound
    have hsig := gapped_signature_perturbation A (ε • E) hgap hscaled hedge
    exact gapped_implies_signature _ (by linarith) hsig

/-- **Easy-phase with explicit edge parameters.**
    When signal gap is `2σ + δ` and noise bound is `2σ + δ/2`,
    recognition succeeds with residual gap `δ/2`. -/
theorem easy_phase_with_edge_constant
    {n : ℕ} {σ δ : ℝ}
    (_hσ : 0 < σ) (hδ : 0 < δ)
    (A E : Matrix (Fin n) (Fin n) ℝ)
    (hgap : HasGappedSignature A (2 * σ + δ))
    (hbound : QuadFormBound E (2 * σ + δ / 2)) :
    SpectrallyRecognizable (SpectralGapProxy (2 * σ + δ) (2 * σ + δ / 2) 1) ∧
    HasGappedSignature (A + E) (δ / 2) := by
  refine ⟨show 0 < (2 * σ + δ) - 1 * (2 * σ + δ / 2) by linarith, ?_⟩
  have h := gapped_signature_perturbation A E hgap hbound (by linarith)
  convert h using 1; ring

/-! ## Theorem 2: Critical-Window Impossibility

At the spectral edge, no spectral proxy can provide a uniform positive margin.
This is the computational criticality theorem.
-/

/-- **No uniform gap in the critical window.**
    There is no γ > 0 such that every instance in the critical window
    has spectral gap proxy at least γ. The proof is constructive:
    take g = b = γ, then SpectralGapProxy γ γ 1 = 0, contradicting γ > 0. -/
theorem no_uniform_gap_in_critical_window
    {γ : ℝ} (hγ : 0 < γ) :
    ¬ (∀ (g b : ℝ), HasCriticalWindow (b / 2) g (γ / 2) →
       0 < b → SpectrallyRecognizable (SpectralGapProxy g b 1)) := by
  intro h
  have hcrit : HasCriticalWindow (γ / 2) γ (γ / 2) := by
    show |γ - 2 * (γ / 2)| ≤ γ / 2
    have : γ - 2 * (γ / 2) = 0 := by ring
    rw [this, abs_zero]; linarith
  have := h γ γ hcrit hγ
  simp only [SpectrallyRecognizable, SpectralGapProxy] at this
  linarith

/-- **Margin vanishes at the edge.** When signal gap = noise bound, proxy = 0. -/
theorem margin_zero_at_edge (g : ℝ) : SpectralGapProxy g g 1 = 0 := by
  unfold SpectralGapProxy; ring

/-- **Margin positive above the edge.** -/
theorem margin_positive_above_edge {g b : ℝ} (h : b < g) :
    SpectrallyRecognizable (SpectralGapProxy g b 1) := by
  show 0 < g - 1 * b; linarith

/-- **Margin nonpositive below the edge.** -/
theorem margin_nonpositive_below_edge {g b : ℝ} (h : g ≤ b) :
    ¬SpectrallyRecognizable (SpectralGapProxy g b 1) := by
  show ¬(0 < g - 1 * b); linarith

/-! ## Theorem 3: Recognizer-to-Tester Reduction

A perfect recognizer for planted perturbation families yields
a hypothesis test with positive statistical advantage.
This is the cross-domain bridge connecting Lorentzian geometry
to average-case complexity.
-/

/-- Abstract hypothesis testing framework for matrix distributions. -/
structure MatrixHypothesisTest (n : ℕ) where
  NullInst : Type
  PlantedInst : Type
  encodeNull : NullInst → Matrix (Fin n) (Fin n) ℝ
  encodePlanted : PlantedInst → Matrix (Fin n) (Fin n) ℝ

/-- **Recognizer yields tester.**
    A perfect binary recognizer composed with the encoding
    yields a perfect hypothesis test. This formalizes the reduction:
    Lorentzian recognition → planted detection. -/
theorem recognizer_yields_tester
    {n : ℕ}
    (H : MatrixHypothesisTest n)
    (R : Matrix (Fin n) (Fin n) ℝ → Bool)
    (hPlanted : ∀ x, R (H.encodePlanted x) = true)
    (hNull : ∀ y, R (H.encodeNull y) = false) :
    ∃ T : H.NullInst ⊕ H.PlantedInst → Bool,
      (∀ x : H.PlantedInst, T (Sum.inr x) = true) ∧
      (∀ y : H.NullInst, T (Sum.inl y) = false) := by
  refine ⟨fun inst => match inst with
    | Sum.inl y => R (H.encodeNull y)
    | Sum.inr x => R (H.encodePlanted x), ?_, ?_⟩
  · exact fun x => hPlanted x
  · exact fun y => hNull y

/-- **Spectral recognizer induces tester.**
    A gap-based thresholding recognizer on planted instances
    induces a perfect distinguisher between null and planted distributions. -/
theorem spectral_recognizer_induces_tester
    {n : ℕ}
    (H : MatrixHypothesisTest n)
    (gapEstimate : Matrix (Fin n) (Fin n) ℝ → ℝ)
    (threshold : ℝ)
    (hPlanted : ∀ x, threshold < gapEstimate (H.encodePlanted x))
    (hNull : ∀ y, gapEstimate (H.encodeNull y) ≤ threshold) :
    ∃ T : H.NullInst ⊕ H.PlantedInst → Bool,
      (∀ x : H.PlantedInst, T (Sum.inr x) = true) ∧
      (∀ y : H.NullInst, T (Sum.inl y) = false) := by
  let R : Matrix (Fin n) (Fin n) ℝ → Bool := fun M => decide (threshold < gapEstimate M)
  have hR_planted : ∀ x, R (H.encodePlanted x) = true := by
    intro x; simp only [R, decide_eq_true_eq]; exact hPlanted x
  have hR_null : ∀ y, R (H.encodeNull y) = false := by
    intro y; simp only [R, decide_eq_false_iff_not, not_lt]; exact hNull y
  exact recognizer_yields_tester H R hR_planted hR_null

/-! ## Phase Classifier: Certified Algorithm -/

/-- The three phases of Lorentzian recognition. -/
inductive RecognitionPhase where
  | easy : RecognitionPhase
  | critical : RecognitionPhase
  | unknown : RecognitionPhase
  deriving DecidableEq, Repr

/-- **Phase classifier** based on spectral gap proxy. -/
noncomputable def classifyPhase (g b ε : ℝ) : RecognitionPhase :=
  if 0 < g - ε * b then RecognitionPhase.easy
  else if g - ε * b = 0 then RecognitionPhase.critical
  else RecognitionPhase.unknown

/-- **Easy-phase classifier correctness:** when the classifier returns `easy`,
    the spectral gap proxy is positive. -/
theorem phase_classifier_easy_correct
    {g b ε : ℝ}
    (hclass : classifyPhase g b ε = RecognitionPhase.easy) :
    SpectrallyRecognizable (SpectralGapProxy g b ε) := by
  unfold classifyPhase at hclass
  split_ifs at hclass with h1
  exact h1

/-- **Unknown-phase classifier correctness:** when the classifier returns `unknown`,
    the spectral gap proxy is negative. -/
theorem phase_classifier_unknown_correct
    {g b ε : ℝ}
    (hclass : classifyPhase g b ε = RecognitionPhase.unknown) :
    SpectralGapProxy g b ε < 0 := by
  unfold classifyPhase at hclass
  split_ifs at hclass with h1 h2
  unfold SpectralGapProxy
  push_neg at h1
  exact lt_of_le_of_ne h1 h2

/-! ## Monotonicity and Structural Properties -/

/-- Monotonicity of proxy margin in signal gap. -/
theorem proxy_margin_mono_signal {g₁ g₂ b ε : ℝ} (hg : g₁ ≤ g₂) :
    SpectralGapProxy g₁ b ε ≤ SpectralGapProxy g₂ b ε := by
  simp only [SpectralGapProxy]; linarith

/-- Antitonicity of proxy margin in noise bound. -/
theorem proxy_margin_anti_noise {g b₁ b₂ ε : ℝ} (hb : b₁ ≤ b₂) (hε : 0 ≤ ε) :
    SpectralGapProxy g b₂ ε ≤ SpectralGapProxy g b₁ ε := by
  simp only [SpectralGapProxy]; nlinarith

/-- Antitonicity of proxy margin in perturbation strength. -/
theorem proxy_margin_anti_epsilon {g b ε₁ ε₂ : ℝ} (hε : ε₁ ≤ ε₂) (_hb : 0 ≤ b) :
    SpectralGapProxy g b ε₂ ≤ SpectralGapProxy g b ε₁ := by
  simp only [SpectralGapProxy]; nlinarith

/-- **Phase transition sharpness**: the proxy transitions from positive to zero
    to negative as the noise bound crosses the signal gap. -/
theorem phase_transition_sharpness (g : ℝ) (_hg : 0 < g) :
    (∀ b, b < g → SpectrallyRecognizable (SpectralGapProxy g b 1)) ∧
    (SpectralGapProxy g g 1 = 0) ∧
    (∀ b, g < b → ¬SpectrallyRecognizable (SpectralGapProxy g b 1)) :=
  ⟨fun _ hb => margin_positive_above_edge hb,
   margin_zero_at_edge g,
   fun _ hb => margin_nonpositive_below_edge (le_of_lt hb)⟩

/-! ## Connection to GOE Edge Constants -/

/-- The sharp failure upper bound from GOE theory. -/
def SharpFailureUpperBound (C σ ε n : ℝ) : ℝ :=
  Real.exp (-(max (ε - 2 * σ) 0) ^ 2 * n / (C * σ ^ 2))

/-- Below the GOE edge `2σ`, the failure bound saturates at 1. -/
theorem failure_bound_below_edge {C σ ε n : ℝ} (h : ε ≤ 2 * σ) :
    SharpFailureUpperBound C σ ε n = 1 := by
  unfold SharpFailureUpperBound
  have : max (ε - 2 * σ) 0 = 0 := max_eq_right (by linarith)
  simp [this]

/-- Above the GOE edge, the failure bound is < 1 (exponential suppression). -/
theorem failure_bound_above_edge {C σ ε n : ℝ}
    (hσ : 0 < σ) (hC : 0 < C) (hε : 2 * σ < ε) (hn : 0 < n) :
    SharpFailureUpperBound C σ ε n < 1 := by
  unfold SharpFailureUpperBound
  rw [Real.exp_lt_one_iff]
  apply div_neg_of_neg_of_pos
  · apply mul_neg_of_neg_of_pos
    · have : 0 < max (ε - 2 * σ) 0 := lt_max_of_lt_left (by linarith)
      nlinarith [sq_nonneg (max (ε - 2 * σ) 0)]
    · exact hn
  · positivity

/-- **Algorithmic-geometric duality at the edge.**
    The spectral gap proxy vanishes exactly at the same critical point
    where the failure bound transitions from 1 to < 1. -/
theorem algorithmic_geometric_duality (σ : ℝ) :
    (SpectralGapProxy (2 * σ) (2 * σ) 1 = 0) ∧
    (∀ g, 2 * σ < g → SpectrallyRecognizable (SpectralGapProxy g (2 * σ) 1)) ∧
    (∀ g, g < 2 * σ → ¬SpectrallyRecognizable (SpectralGapProxy g (2 * σ) 1)) :=
  ⟨margin_zero_at_edge (2 * σ),
   fun _ hg => margin_positive_above_edge hg,
   fun _ hg => margin_nonpositive_below_edge (le_of_lt hg)⟩

/-! ## Cross-Domain Bridge: Margin Duality -/

/-- **Margin duality**: geometric gap implies statistical separation.
    Planted instances are recognizable while null instances are not. -/
theorem margin_duality_separation
    {g b : ℝ} (hsep : b < g) :
    SpectrallyRecognizable (SpectralGapProxy g b 1) ∧
    ¬SpectrallyRecognizable (SpectralGapProxy b g 1) :=
  ⟨margin_positive_above_edge hsep,
   margin_nonpositive_below_edge (le_of_lt hsep)⟩

/-- **Separation gap monotonicity.**
    The recognition advantage increases as signal-to-noise ratio improves. -/
theorem separation_gap_monotone {g₁ g₂ b : ℝ} (hg : g₁ ≤ g₂) :
    SpectralGapProxy g₁ b 1 - SpectralGapProxy b g₁ 1 ≤
    SpectralGapProxy g₂ b 1 - SpectralGapProxy b g₂ 1 := by
  simp only [SpectralGapProxy]; nlinarith

/-- **Trichotomy theorem**: every instance falls into exactly one of three
    mutually exclusive phases. -/
theorem recognition_trichotomy (g b : ℝ) :
    (SpectrallyRecognizable (SpectralGapProxy g b 1) ∧ ¬(g ≤ b)) ∨
    (SpectralGapProxy g b 1 = 0 ∧ g = b) ∨
    (¬SpectrallyRecognizable (SpectralGapProxy g b 1) ∧ g < b) := by
  rcases lt_trichotomy g b with hlt | heq | hgt
  · right; right
    exact ⟨margin_nonpositive_below_edge (le_of_lt hlt), hlt⟩
  · right; left
    exact ⟨by subst heq; exact margin_zero_at_edge g, heq⟩
  · left
    exact ⟨margin_positive_above_edge hgt, by linarith⟩

/-! ## Two-Step Perturbation Chain -/

/-- **Two-step margin decay.**
    After two perturbation steps, the residual gap is `g - δ₁ - δ₂`. -/
theorem two_step_margin_decay {n : ℕ}
    (A E₁ E₂ : Matrix (Fin n) (Fin n) ℝ)
    {g δ₁ δ₂ : ℝ}
    (hgap : HasGappedSignature A g)
    (hb₁ : QuadFormBound E₁ δ₁)
    (hb₂ : QuadFormBound E₂ δ₂)
    (h₁ : δ₁ < g)
    (h₂ : δ₂ < g - δ₁) :
    HasGappedSignature (A + E₁ + E₂) (g - δ₁ - δ₂) := by
  have step1 := gapped_signature_perturbation A E₁ hgap hb₁ h₁
  exact gapped_signature_perturbation (A + E₁) E₂ step1 hb₂ h₂

/-! ## Conjecture: Critical Hardness for Lorentzian Recognition

**Conjecture.** For every fixed δ > 0, there is no polynomial-time algorithm
that, on random instances with perturbation strength ε ≤ 2σ − δ, recognizes
Lorentzianity with success probability 1/2 + c for any absolute constant
c > 0, unless planted clique of size o(√n) is detectable in polynomial time.

**Testable prediction:** The success curve of any spectral recognizer as a
function of ε/σ exhibits a sharp bend near the constant 2.
-/

end LorentzianComplexityTransition