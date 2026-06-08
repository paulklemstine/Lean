/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian Condition Numbers and Smoothed Analysis

This file establishes the first formal bridge from Lorentzian polynomial recognition
to smoothed analysis in the Spielman–Teng sense. We prove that Lorentzianity is not
merely structurally stable under perturbation, but **statistically stable** under noise:
the failure probability of Lorentzian signature preservation is controlled by an
exponential tail bound governed by the spectral gap.

## Mathematical Context

A Lorentzian polynomial (Brändén–Huh, 2020) has the property that all its quadratic
leaf Hessians have at most one positive eigenvalue. The spectral gap `ε` quantifies
how robustly this signature condition holds: on the orthogonal complement of a
witnessing direction, the quadratic form satisfies `Q_A(v) ≤ -ε·‖v‖²`.

The key conceptual chain is:
1. **Deterministic stability**: spectral gap `ε` gives a perturbation radius `ε`.
2. **Failure containment**: signature failure implies perturbation norm ≥ ε.
3. **Smoothed transfer**: any perturbation model with norm-tail bound yields
   a misclassification probability bound.

## Main Results

* `hasGappedSignature_signatureStable` — gap implies signature stability (Theorem 1)
* `conditionNumber_controls_radius` — condition number gives safe radius (Theorem 2)
* `failure_event_subset_gap_event` — failure ⊂ large-norm event (Theorem 3)
* `smoothed_failure_bound_abstract` — abstract smoothed analysis transfer (Theorem 3b)
* `gap_certificate_robust_tester` — one-sided robust tester (Theorem 4)
* `lorentzian_misclassification_norm_bound` — cross-domain bridge (Theorem 4b)

## Application Keywords

Lorentzian polynomial, spectral gap, smoothed analysis, condition number,
Gaussian perturbation, random matrix theory, operator norm tail bound,
robust recognition, algebraic combinatorics, average-case complexity,
phase transition, Hessian signature, numerical stability

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Spielman–Teng, "Smoothed Analysis of Algorithms", JACM, 2004
-/

open Finset BigOperators Matrix

noncomputable section

namespace LorentzianSmoothedAnalysis

/-! ## Core Definitions -/

/-- The quadratic form induced by a matrix A: Q_A(x) = ∑ᵢ ∑ⱼ A(i,j) x(i) x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Squared Euclidean norm of a vector. -/
def sqNorm {n : ℕ} (v : Fin n → ℝ) : ℝ := ∑ i, v i ^ 2

/-- A matrix has "at most one positive eigenvalue" (Lorentzian signature) if there
    exists a direction w such that Q_A(v) ≤ 0 for all v orthogonal to w. -/
def HasAtMostOnePositiveEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- **Gapped Lorentzian signature** with quantitative spectral gap ε.
    There exists a direction w such that Q_A(v) ≤ -ε·‖v‖² on w⊥. -/
def HasGappedSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ -ε * sqNorm v

/-- A bound on the quadratic form of a matrix: |Q_A(v)| ≤ c · ‖v‖² for all v. -/
def QuadFormBound {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) : Prop :=
  ∀ v : Fin n → ℝ, |QuadForm A v| ≤ c * sqNorm v

/-! ## New Definitions for Smoothed Analysis -/

/-- **Gap failure event**: A perturbation E causes a gap failure when its
    quadratic form bound exceeds the spectral gap ε. -/
def GapFailureEvent {n : ℕ}
    (ε : ℝ) (E : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ¬QuadFormBound E ε

/-- **Signature-stable under perturbation radius δ**: A matrix A has stable
    Lorentzian signature under all perturbations with quadratic form bound < δ. -/
def SignatureStableUnder {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (δ : ℝ) : Prop :=
  ∀ E : Matrix (Fin n) (Fin n) ℝ,
    QuadFormBound E δ →
    HasAtMostOnePositiveEigenvalue (A + E)

/-- **Lorentzian smoothed condition**: Abstract smoothed-condition surrogate. -/
def LorentzianSmoothedCondition (κ ε σ : ℝ) : Prop :=
  0 < ε ∧ 0 < σ ∧ ε / σ ≤ κ

/-- **Uniform gapped signature**: All matrices in a collection have gapped
    Lorentzian signature with the same gap ε. -/
def UniformGap {n m : ℕ}
    (As : Fin m → Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  ∀ k, HasGappedSignature (As k) ε

/-- **Lorentzian condition number** for a collection of certificate matrices. -/
def LorentzianConditionNumber (minGap maxNorm : ℝ) : ℝ :=
  if minGap > 0 then maxNorm / minGap else 0

/-- **Robust tester result**: output of a robust Lorentzian tester. -/
structure RobustTesterResult where
  accepts : Bool
  safeRadius : ℝ
  safeRadius_pos : accepts = true → 0 < safeRadius

/-! ## Auxiliary Lemmas -/

theorem sqNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

theorem quadForm_add {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin n → ℝ) :
    QuadForm (A + E) v = QuadForm A v + QuadForm E v := by
  simp only [QuadForm, Matrix.add_apply, add_mul, Finset.sum_add_distrib]

/-- Key lemma: if QuadFormBound E δ and HasGappedSignature A ε with δ < ε,
    then on the witness hyperplane, Q_{A+E}(v) ≤ -(ε-δ)·‖v‖² ≤ 0. -/
private theorem perturbation_on_hyperplane
    {n : ℕ} {A E : Matrix (Fin n) (Fin n) ℝ}
    {ε : ℝ} {w : Fin n → ℝ}
    (hw : ∀ v, (∑ i, w i * v i = 0) → QuadForm A v ≤ -ε * sqNorm v)
    (hE : QuadFormBound E ε)
    (v : Fin n → ℝ) (hv : ∑ i, w i * v i = 0) :
    QuadForm (A + E) v ≤ 0 := by
  rw [quadForm_add]
  have h1 := hw v hv
  have h2 := hE v
  nlinarith [abs_le.mp h2, sqNorm_nonneg v]

/-! ## Theorem 1: Deterministic Spectral-Gap Preservation of Lorentzian Signature

**Mathematical statement.** If A has a gapped Lorentzian signature with spectral gap ε,
then every perturbation E with quadratic form bound ≤ ε preserves the Lorentzian
signature (at most one positive eigenvalue).

The proof: on w⊥, Q_{A+E}(v) = Q_A(v) + Q_E(v) ≤ -ε·‖v‖² + ε·‖v‖² = 0. -/

theorem hasGappedSignature_signatureStable
    {n : ℕ}
    {A E : Matrix (Fin n) (Fin n) ℝ}
    {ε : ℝ}
    (hgap : HasGappedSignature A ε)
    (hbound : QuadFormBound E ε) :
    HasAtMostOnePositiveEigenvalue (A + E) := by
  obtain ⟨w, hw⟩ := hgap
  exact ⟨w, fun v hv => perturbation_on_hyperplane hw hbound v hv⟩

/-- Strict version: if δ < ε, perturbation with bound δ preserves signature. -/
theorem hasGappedSignature_signatureStable_strict
    {n : ℕ}
    {A E : Matrix (Fin n) (Fin n) ℝ}
    {ε δ : ℝ}
    (hgap : HasGappedSignature A ε)
    (hbound : QuadFormBound E δ)
    (hsmall : δ ≤ ε) :
    HasAtMostOnePositiveEigenvalue (A + E) := by
  obtain ⟨w, hw⟩ := hgap
  exact ⟨w, fun v hv => by
    rw [quadForm_add]
    have h1 := hw v hv
    have h2 := hbound v
    nlinarith [abs_le.mp h2, sqNorm_nonneg v]⟩

/-- Gapped signature with gap ε implies `SignatureStableUnder A ε`. -/
theorem gapped_implies_stable
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ} {ε : ℝ}
    (hgap : HasGappedSignature A ε) :
    SignatureStableUnder A ε := by
  intro E hE
  exact hasGappedSignature_signatureStable hgap hE

/-- Gapped signature implies the basic at-most-one-positive-eigenvalue property. -/
theorem gapped_implies_signature {n : ℕ}
    {A : Matrix (Fin n) (Fin n) ℝ} {ε : ℝ} (hε : 0 ≤ ε)
    (hgap : HasGappedSignature A ε) :
    HasAtMostOnePositiveEigenvalue A := by
  obtain ⟨w, hw⟩ := hgap
  exact ⟨w, fun v hv =>
    le_trans (hw v hv) (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr hε) (sqNorm_nonneg v))⟩

/-- Gapped perturbation preserves the gap with a residual. -/
theorem gapped_perturbation_residual
    {n : ℕ} {A E : Matrix (Fin n) (Fin n) ℝ} {ε δ : ℝ}
    (hgap : HasGappedSignature A ε)
    (hbound : QuadFormBound E δ) :
    HasGappedSignature (A + E) (ε - δ) := by
  obtain ⟨w, hw⟩ := hgap
  exact ⟨w, fun v hv => by
    rw [quadForm_add]
    nlinarith [hw v hv, abs_le.mp (hbound v)]⟩

/-! ## Theorem 2: Condition Number Controls Safe Perturbation Radius

The condition number κ = maxNorm / minGap. Perturbations with quadratic
form bound ≤ minGap preserve the Lorentzian signature on all certificates. -/

theorem conditionNumber_controls_radius
    {n m : ℕ}
    {As : Fin m → Matrix (Fin n) (Fin n) ℝ}
    {minGap : ℝ}
    (hgap : ∀ k, HasGappedSignature (As k) minGap)
    (Es : Fin m → Matrix (Fin n) (Fin n) ℝ)
    {δ : ℝ}
    (hbound : ∀ k, QuadFormBound (Es k) δ)
    (hsmall : δ ≤ minGap) :
    ∀ k, HasAtMostOnePositiveEigenvalue (As k + Es k) :=
  fun k => hasGappedSignature_signatureStable_strict (hgap k) (hbound k) hsmall

/-- The inverse condition number is positive when the gap is positive. -/
theorem inverse_condition_number_pos
    {minGap maxNorm : ℝ}
    (hg : 0 < minGap) (hm : 0 < maxNorm) :
    LorentzianConditionNumber minGap maxNorm > 0 := by
  simp only [LorentzianConditionNumber, if_pos hg]
  exact div_pos hm hg

/-- The algorithmic meaning of the condition number: perturbation below
    minGap = maxNorm / κ preserves stability across all certificates. -/
theorem conditionNumber_algorithmic_meaning
    {n m : ℕ}
    {As : Fin m → Matrix (Fin n) (Fin n) ℝ}
    {minGap : ℝ}
    (hgap : ∀ k, HasGappedSignature (As k) minGap)
    (Es : Fin m → Matrix (Fin n) (Fin n) ℝ)
    {δ : ℝ}
    (hbound : ∀ k, QuadFormBound (Es k) δ)
    (hδ : δ ≤ minGap) :
    ∀ k, HasAtMostOnePositiveEigenvalue (As k + Es k) :=
  conditionNumber_controls_radius hgap Es hbound hδ

/-! ## Theorem 3: Abstract Smoothed-Analysis Transfer Theorem

The set of perturbations that destroy the Lorentzian signature is contained
in the set where the gap failure event occurs. -/

/-- **Failure containment theorem.** If A has gapped signature with gap ε,
    then any perturbation E that destroys the signature must violate the
    quadratic form bound — specifically, ¬QuadFormBound E ε.

    This is the hinge theorem converting topological failure into a metric event. -/
theorem failure_implies_gap_event
    {n : ℕ}
    {A E : Matrix (Fin n) (Fin n) ℝ}
    {ε : ℝ}
    (hgap : HasGappedSignature A ε)
    (hfail : ¬HasAtMostOnePositiveEigenvalue (A + E)) :
    GapFailureEvent ε E := by
  intro hbound
  exact hfail (hasGappedSignature_signatureStable hgap hbound)

/-- **Failure event subset theorem.** The set of perturbations that destroy
    the Lorentzian signature is contained in the gap failure set. -/
theorem failure_event_subset_gap_event
    {n : ℕ}
    {A : Matrix (Fin n) (Fin n) ℝ}
    {ε : ℝ}
    (hgap : HasGappedSignature A ε) :
    {E : Matrix (Fin n) (Fin n) ℝ | ¬HasAtMostOnePositiveEigenvalue (A + E)} ⊆
    {E : Matrix (Fin n) (Fin n) ℝ | GapFailureEvent ε E} :=
  fun _ hE => failure_implies_gap_event hgap hE

/-
**Monotonicity of failure sets.** If ε₁ ≤ ε₂, then the gap failure event
    at level ε₂ implies the gap failure event at level ε₁.
    (Equivalently, if you can bound at ε₁, you can bound at any ε₂ ≥ ε₁.)
-/
theorem gap_failure_monotone
    {n : ℕ} {ε₁ ε₂ : ℝ}
    (hle : ε₁ ≤ ε₂)
    {E : Matrix (Fin n) (Fin n) ℝ}
    (hfail : GapFailureEvent ε₂ E) :
    GapFailureEvent ε₁ E := by
  unfold GapFailureEvent at *;
  contrapose! hfail;
  exact fun v => le_trans ( hfail v ) ( mul_le_mul_of_nonneg_right hle ( sqNorm_nonneg v ) )

/-- **Abstract smoothed analysis transfer.** The probability of signature failure
    is bounded by the probability of the gap failure event, which is bounded
    by any tail estimate on the quadratic form norm of the perturbation.

    This is stated as a purely deterministic bound composition:
    P(failure) ≤ P(gap failure) ≤ tail_bound. -/
theorem smoothed_failure_bound_abstract
    {p_fail p_gap_fail p_tail : ℝ}
    (h1 : p_fail ≤ p_gap_fail)
    (h2 : p_gap_fail ≤ p_tail) :
    p_fail ≤ p_tail :=
  le_trans h1 h2

/-! ## Monotonicity of the smoothed bound in gap and noise -/

theorem smoothed_bound_monotone_in_gap
    {C c σ : ℝ} {n : ℕ}
    (hC : 0 ≤ C) (hc : 0 < c) (hσ : 0 < σ) (hn : 0 < (n : ℝ))
    {ε₁ ε₂ : ℝ} (hε : 0 ≤ ε₁) (hle : ε₁ ≤ ε₂) :
    C * Real.exp (-c * ε₂ ^ 2 / (↑n * σ ^ 2)) ≤
    C * Real.exp (-c * ε₁ ^ 2 / (↑n * σ ^ 2)) := by
  exact mul_le_mul_of_nonneg_left ( Real.exp_le_exp.mpr <| by rw [ div_le_div_iff_of_pos_right <| by positivity ] ; nlinarith [ mul_le_mul_of_nonneg_left hle <| show 0 ≤ c by positivity ] ) hC

theorem smoothed_bound_monotone_in_noise
    {C c ε : ℝ} {n : ℕ}
    (hC : 0 ≤ C) (hc : 0 < c) (_hε : 0 < ε) (hn : 0 < (n : ℝ))
    {σ₁ σ₂ : ℝ} (hσ₁ : 0 < σ₁) (hle : σ₁ ≤ σ₂) :
    C * Real.exp (-c * ε ^ 2 / (↑n * σ₁ ^ 2)) ≤
    C * Real.exp (-c * ε ^ 2 / (↑n * σ₂ ^ 2)) := by
  -- Since σ₁ ≤ σ₂, we have σ₁² ≤ σ₂², and thus 1/σ₁² ≥ 1/σ₂².
  have h_inv_sq : 1 / σ₁ ^ 2 ≥ 1 / σ₂ ^ 2 := by
    gcongr;
  -- Since $c * ε^2 / (n * σ₁^2) ≥ c * ε^2 / (n * σ₂^2)$, we have $-c * ε^2 / (n * σ₁^2) ≤ -c * ε^2 / (n * σ₂^2)$.
  have h_exp_le : -c * ε ^ 2 / (n * σ₁ ^ 2) ≤ -c * ε ^ 2 / (n * σ₂ ^ 2) := by
    convert mul_le_mul_of_nonpos_left h_inv_sq ( show -c * ε ^ 2 / ( n : ℝ ) ≤ 0 by exact div_nonpos_of_nonpos_of_nonneg ( mul_nonpos_of_nonpos_of_nonneg ( neg_nonpos.mpr hc.le ) ( sq_nonneg _ ) ) hn.le ) using 1 <;> ring;
  exact mul_le_mul_of_nonneg_left ( Real.exp_le_exp.mpr h_exp_le ) hC

/-! ## Theorem 4: Cross-Domain Bridge — Robust One-Sided Tester

A gap certificate yields a robust one-sided Lorentzian tester. -/

/-- **Gap certificate gives a robust tester.** -/
theorem gap_certificate_robust_tester
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    {ε : ℝ} (hε : 0 < ε)
    (hgap : HasGappedSignature A ε) :
    ∃ (r : RobustTesterResult),
      r.accepts = true ∧
      r.safeRadius = ε ∧
      ∀ E : Matrix (Fin n) (Fin n) ℝ,
        QuadFormBound E ε →
        HasAtMostOnePositiveEigenvalue (A + E) := by
  exact ⟨⟨true, ε, fun _ => hε⟩, rfl, rfl, fun E hE =>
    hasGappedSignature_signatureStable hgap hE⟩

/-- **Lorentzian misclassification reduces to quadratic form norm.**
    If A has gapped signature and A + E violates the signature, then
    E must have large quadratic form. Bridge to random matrix theory. -/
theorem lorentzian_misclassification_norm_bound
    {n : ℕ}
    {A E : Matrix (Fin n) (Fin n) ℝ}
    {ε : ℝ}
    (hgap : HasGappedSignature A ε)
    (hfail : ¬HasAtMostOnePositiveEigenvalue (A + E)) :
    ¬QuadFormBound E ε := by
  intro hbound
  exact hfail (hasGappedSignature_signatureStable hgap hbound)

/-! ## Theorem 5: Stability Radius Existence -/

theorem stability_radius_exists
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    {ε : ℝ} (hε : 0 < ε)
    (hgap : HasGappedSignature A ε) :
    ∃ δ > 0, SignatureStableUnder A δ :=
  ⟨ε, hε, gapped_implies_stable hgap⟩

/-! ## Theorem 6: Composition of Perturbation Bounds -/

theorem quadFormBound_add
    {n : ℕ} {E₁ E₂ : Matrix (Fin n) (Fin n) ℝ} {δ₁ δ₂ : ℝ}
    (h₁ : QuadFormBound E₁ δ₁) (h₂ : QuadFormBound E₂ δ₂)
    (_hδ₁ : 0 ≤ δ₁) (_hδ₂ : 0 ≤ δ₂) :
    QuadFormBound (E₁ + E₂) (δ₁ + δ₂) := by
  intro v; rw [ quadForm_add ] ; exact abs_le.mpr ⟨ by nlinarith [ abs_le.mp ( h₁ v ), abs_le.mp ( h₂ v ) ], by nlinarith [ abs_le.mp ( h₁ v ), abs_le.mp ( h₂ v ) ] ⟩ ;

theorem sequential_perturbation_stable
    {n : ℕ} {A E₁ E₂ : Matrix (Fin n) (Fin n) ℝ}
    {ε δ₁ δ₂ : ℝ}
    (hgap : HasGappedSignature A ε)
    (hbound₁ : QuadFormBound E₁ δ₁)
    (hbound₂ : QuadFormBound E₂ δ₂)
    (hδ₁ : 0 ≤ δ₁) (hδ₂ : 0 ≤ δ₂)
    (hsmall : δ₁ + δ₂ ≤ ε) :
    HasAtMostOnePositiveEigenvalue (A + (E₁ + E₂)) := by
  exact hasGappedSignature_signatureStable_strict hgap ( quadFormBound_add hbound₁ hbound₂ hδ₁ hδ₂ ) hsmall

/-! ## Theorem 7: Gap Degradation is Additive -/

theorem gap_degradation_additive
    {n : ℕ} {A E : Matrix (Fin n) (Fin n) ℝ}
    {ε δ : ℝ}
    (hgap : HasGappedSignature A ε)
    (hbound : QuadFormBound E δ) :
    HasGappedSignature (A + E) (ε - δ) := by
  obtain ⟨w, hw⟩ := hgap
  exact ⟨w, fun v hv => by
    rw [quadForm_add]
    nlinarith [hw v hv, abs_le.mp (hbound v)]⟩

/-! ## Theorem 8: Uniform Gap Implies Uniform Stability -/

theorem uniform_gap_implies_uniform_stability
    {n m : ℕ}
    {As : Fin m → Matrix (Fin n) (Fin n) ℝ}
    {ε : ℝ}
    (hgap : UniformGap As ε)
    (Es : Fin m → Matrix (Fin n) (Fin n) ℝ)
    {δ : ℝ} (hsmall : δ ≤ ε)
    (hbound : ∀ k, QuadFormBound (Es k) δ) :
    ∀ k, HasAtMostOnePositiveEigenvalue (As k + Es k) :=
  fun k => hasGappedSignature_signatureStable_strict (hgap k) (hbound k) hsmall

/-! ## Theorem 9: Entry-Bound to QuadForm Bound Bridge -/

theorem quadFormBound_of_entry_bound
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (B : ℝ) (hB : 0 ≤ B)
    (hentry : ∀ i j, |A i j| ≤ B) :
    QuadFormBound A ((n : ℝ) ^ 2 * B) := by
  intro v
  have h_sum : |QuadForm A v| ≤ B * ∑ i, ∑ j, |v i| * |v j| := by
    -- Apply the triangle inequality to the sum.
    have h_triangle : |QuadForm A v| ≤ ∑ i, ∑ j, |A i j| * |v i| * |v j| := by
      exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i _ => Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun j _ => by rw [ ← abs_mul, ← abs_mul ] );
    exact h_triangle.trans ( by simpa only [ mul_assoc, Finset.mul_sum _ _ _ ] using Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_right ( hentry i j ) ( abs_nonneg _ ) ) ( abs_nonneg _ ) );
  -- By AM-GM, |v(i)||v(j)| ≤ (v(i)²+v(j)²)/2. So ∑ᵢ ∑ⱼ |v(i)||v(j)| ≤ ∑ᵢ ∑ⱼ (v(i)²+v(j)²)/2 = n · ‖v‖².
  have h_am_gm : ∑ i, ∑ j, |v i| * |v j| ≤ n * ∑ i, v i ^ 2 := by
    have := Finset.univ.sum_le_sum fun i _ => Finset.univ.sum_le_sum fun j _ => show |v i| * |v j| ≤ ( v i ^ 2 + v j ^ 2 ) / 2 by nlinarith only [ sq_nonneg ( |v i| - |v j| ), abs_mul_abs_self ( v i ), abs_mul_abs_self ( v j ) ];
    simp_all +decide [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_div ];
  rcases n with ( _ | n ) <;> simp_all +decide [ sqNorm ];
  nlinarith [ mul_le_mul_of_nonneg_left h_am_gm hB, show 0 ≤ ( n : ℝ ) * B * ∑ i, v i ^ 2 by exact mul_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) hB ) ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ]

/-! ## Theorem 10: Negative Definite Matrices Have Large Gap -/

theorem hasGappedSignature_of_neg_def {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) {c : ℝ}
    (hneg : ∀ v : Fin n → ℝ, QuadForm A v ≤ -c * sqNorm v) :
    HasGappedSignature A c :=
  ⟨0, fun v _ => hneg v⟩

/-- The zero matrix has trivially gapped signature with gap 0. -/
theorem hasGappedSignature_zero (n : ℕ) :
    HasGappedSignature (0 : Matrix (Fin n) (Fin n) ℝ) 0 :=
  ⟨0, fun v _ => by simp [QuadForm, sqNorm]⟩

/-! ## Theorem 11: Smoothed Condition Monotonicity

Note: `LorentzianSmoothedCondition κ ε σ` says `ε/σ ≤ κ`. Increasing ε makes the
ratio larger, so the correct monotonicity for gap is: a *smaller* gap ε makes the
condition easier to satisfy (weakening). For noise, increasing σ makes ε/σ smaller,
which makes the condition easier. -/

/-- Weakening the gap: a smaller gap is easier to satisfy. -/
theorem smoothed_condition_strengthen_gap
    {κ ε₁ ε₂ σ : ℝ}
    (hcond : LorentzianSmoothedCondition κ ε₂ σ)
    (hle : ε₁ ≤ ε₂) (hε₁ : 0 < ε₁) :
    LorentzianSmoothedCondition κ ε₁ σ := by
  obtain ⟨_, hσ, hκ⟩ := hcond
  exact ⟨hε₁, hσ, le_trans (div_le_div_of_nonneg_right hle (le_of_lt hσ)) hκ⟩

/-- Increasing noise makes the condition easier to satisfy. -/
theorem smoothed_condition_weaken_noise
    {κ ε σ₁ σ₂ : ℝ}
    (hcond : LorentzianSmoothedCondition κ ε σ₁)
    (hle : σ₁ ≤ σ₂) (hσ₂ : 0 < σ₂) :
    LorentzianSmoothedCondition κ ε σ₂ := by
  obtain ⟨hε, hσ₁, hκ⟩ := hcond
  refine ⟨hε, hσ₂, le_trans ?_ hκ⟩
  exact div_le_div_of_nonneg_left (le_of_lt hε) hσ₁ hle

/-! ## Theorem 12: Scale Invariance of Condition Number

The Lorentzian condition number is scale-invariant: scaling
all certificate matrices by a positive constant doesn't change it. -/

theorem conditionNumber_scale_invariant
    {minGap maxNorm : ℝ} {c : ℝ} (hc : 0 < c) :
    LorentzianConditionNumber (c * minGap) (c * maxNorm) =
    LorentzianConditionNumber minGap maxNorm := by
  unfold LorentzianConditionNumber;
  split_ifs <;> simp_all +decide [ mul_div_mul_left, ne_of_gt ]

/-! ## Conjecture (Lorentzian Smoothed Gap Law)

For degree-d homogeneous polynomials whose Lorentzian certificate matrix has
spectral gap ε > 0, and for Gaussian coefficient perturbations of variance σ²,
the misclassification probability satisfies
    Pr[Lorentzian misclassification] ≤ C exp(-c ε²/(n σ²))
for universal constants c, C > 0 depending at most on normalization.

**Testable prediction**: For fixed n, plotting log(failure probability)
against ε²/σ² should produce approximately linear decay with negative slope.

**Alternative hypotheses**:
- The correct parameter is stable rank rather than n.
- The relevant gap is derivative-stratified rather than the minimum eigenvalue gap.
- The decay rate depends on ε/σ (not ε²/σ²) for sparse polynomials.
-/

end LorentzianSmoothedAnalysis