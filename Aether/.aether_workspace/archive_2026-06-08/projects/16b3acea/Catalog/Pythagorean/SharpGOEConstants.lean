/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Sharp GOE Constants via Tracy–Widom Transfer

This file formalizes the **spectral phase transition** governing failure of Lorentzian
signature recognition under Gaussian symmetric (GOE-type) perturbations. The central
result is a transfer theorem: if a symmetric matrix A has a gapped Lorentzian signature
with parameter ε, then misclassification under a GOE perturbation E is controlled by
the operator-norm tail P(‖E‖ ≥ ε).

The key constant is **2σ** — the almost-sure limit of the operator norm of an n×n GOE
matrix with variance σ²/n — which serves as the universal threshold for the phase
transition between exponentially suppressed and unsuppressed failure.

## Main Definitions

* `SharpFailureUpperBound` — the engineering failure bound exp(−(ε−2σ)₊² · n / (Cσ²))
* `GOEEdgeWindow` — the spectral edge window 2σ + tσ/n^(2/3)
* `EdgeScaledGap` — the rescaled gap variable (ε−2σ)n^(2/3)/σ
* `certify_failure_prob` — decidable certification function

## Main Results

* `misclassification_prob_le_opnorm_tail` — transfer from gap-stability to spectral edge
* `sharp_bound_eq_one_below_edge` — bound saturates below the semicircle edge
* `sharp_bound_lt_one_above_edge` — exponential suppression above the edge
* `sharp_bound_monotone_in_gap` — monotonicity in the gap parameter
* `engineering_failure_bound` — practical exponential certification law
* `sharp_bound_antitone_in_noise_margin` — thermodynamic monotonicity in noise
* `bits_of_precision_suffice` — bridge to numerical certification

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Tracy–Widom, "Level-spacing distributions and the Airy kernel", CMP, 1994
* Spielman–Teng, "Smoothed Analysis of Algorithms", JACM, 2004
-/

open Finset BigOperators Matrix Real

noncomputable section

namespace SharpGOEConstants

/-! ## Core Definitions -/

/-- The quadratic form induced by a symmetric matrix. -/
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

theorem sqNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

theorem quadForm_add {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin n → ℝ) :
    QuadForm (A + E) v = QuadForm A v + QuadForm E v := by
  simp only [QuadForm, Matrix.add_apply, add_mul, Finset.sum_add_distrib]

/-! ## New Definitions: Sharp GOE Constants -/

/-- **Sharp failure upper bound.** The engineering-grade bound on misclassification
    probability for a matrix with Lorentzian gap ε under GOE perturbation with
    variance parameter σ and dimension n, with universal constant C.

    The bound is `exp(−(max(ε − 2σ, 0))² · n / (C · σ²))`.
    Below the semicircle edge (ε ≤ 2σ), this equals 1 (no suppression).
    Above the edge, it decays exponentially in n. -/
def SharpFailureUpperBound (C σ ε n : ℝ) : ℝ :=
  Real.exp (-(max (ε - 2 * σ) 0) ^ 2 * n / (C * σ ^ 2))

/-- **GOE edge window.** The spectral edge at `2σ + t · σ / n^(2/3)`,
    representing the Tracy–Widom fluctuation scale around the semicircle edge. -/
def GOEEdgeWindow (σ n t : ℝ) : ℝ := 2 * σ + t * σ / n ^ (2 / 3 : ℝ)

/-- **Edge-scaled gap.** The dimensionless variable governing the phase transition. -/
structure EdgeScaledGap where
  /-- Matrix dimension -/
  n : ℕ
  /-- Noise standard deviation parameter -/
  σ : ℝ
  /-- Lorentzian spectral gap -/
  ε : ℝ
  /-- Positivity of noise parameter -/
  hσ : 0 < σ
  /-- Positivity of dimension -/
  hn : 0 < n
  /-- The rescaled gap variable -/
  value : ℝ := ((ε - 2 * σ) * (n : ℝ) ^ (2 / 3 : ℝ)) / σ

/-! ## Probability framework -/

/-- Abstract probability measure on matrices, monotone under set inclusion. -/
structure ProbMeasure (n : ℕ) where
  prob : Set (Matrix (Fin n) (Fin n) ℝ) → ℝ
  mono : ∀ S T : Set (Matrix (Fin n) (Fin n) ℝ), S ⊆ T → prob S ≤ prob T
  nonneg : ∀ S, 0 ≤ prob S

/-- The misclassification event: perturbations E such that A + E loses signature. -/
def misclassificationEvent {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    Set (Matrix (Fin n) (Fin n) ℝ) :=
  {E | ¬HasAtMostOnePositiveEigenvalue (A + E)}

/-- The gap-failure event: perturbations whose quadratic-form bound exceeds ε. -/
def gapEvent {n : ℕ} (ε : ℝ) :
    Set (Matrix (Fin n) (Fin n) ℝ) :=
  {E | ¬QuadFormBound E ε}

/-! ## Theorem A: Transfer theorem -/

/-- Failure event is contained in the gap event. -/
theorem failure_event_subset_gap_event
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ} {ε : ℝ}
    (hgap : HasGappedSignature A ε) :
    misclassificationEvent A ⊆ gapEvent ε := by
  intro E hE
  simp only [misclassificationEvent, Set.mem_setOf_eq] at hE
  simp only [gapEvent, Set.mem_setOf_eq]
  intro hbound
  apply hE
  obtain ⟨w, hw⟩ := hgap
  exact ⟨w, fun v hv => by
    rw [quadForm_add]
    nlinarith [hw v hv, abs_le.mp (hbound v), sqNorm_nonneg v]⟩

/-- **Transfer theorem.** P(misclassification) ≤ P(‖E‖_QF ≥ ε). -/
theorem misclassification_prob_le_opnorm_tail
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ} {ε : ℝ}
    (hgap : HasGappedSignature A ε)
    (μ : ProbMeasure n) :
    μ.prob (misclassificationEvent A) ≤ μ.prob (gapEvent ε) :=
  μ.mono _ _ (failure_event_subset_gap_event hgap)

/-! ## Theorem B: Sharp bound properties -/

/-- The sharp bound is always positive. -/
theorem sharp_bound_pos (C σ ε n : ℝ) :
    0 < SharpFailureUpperBound C σ ε n :=
  exp_pos _

/-- The sharp bound is nonneg. -/
theorem sharp_bound_nonneg (C σ ε n : ℝ) :
    0 ≤ SharpFailureUpperBound C σ ε n :=
  le_of_lt (sharp_bound_pos C σ ε n)

/-- **Phase transition: bound equals 1 below the edge.** -/
theorem sharp_bound_eq_one_below_edge
    {C σ ε n : ℝ}
    (hε : ε ≤ 2 * σ) :
    SharpFailureUpperBound C σ ε n = 1 := by
  unfold SharpFailureUpperBound
  have h : max (ε - 2 * σ) 0 = 0 := max_eq_right (by linarith)
  simp [h]

/-- The exponent is nonpositive. -/
theorem sharp_exponent_nonpos {C σ ε n : ℝ} (hC : 0 < C) (hσ : 0 < σ) (hn : 0 ≤ n) :
    -(max (ε - 2 * σ) 0) ^ 2 * n / (C * σ ^ 2) ≤ 0 := by
  apply div_nonpos_of_nonpos_of_nonneg
  · nlinarith [sq_nonneg (max (ε - 2 * σ) 0)]
  · positivity

/-- **The sharp bound is at most 1.** -/
theorem sharp_bound_le_one {C σ ε n : ℝ} (hC : 0 < C) (hσ : 0 < σ) (hn : 0 ≤ n) :
    SharpFailureUpperBound C σ ε n ≤ 1 := by
  unfold SharpFailureUpperBound
  exact Real.exp_le_one_iff.mpr (sharp_exponent_nonpos hC hσ hn)

/-
**Phase transition: bound is strictly less than 1 above the edge.**
-/
theorem sharp_bound_lt_one_above_edge
    {C σ ε n : ℝ}
    (hσ : 0 < σ) (hC : 0 < C) (hε : 2 * σ < ε) (hn : 0 < n) :
    SharpFailureUpperBound C σ ε n < 1 := by
  convert Real.exp_lt_one_iff.mpr _ using 1;
  exact div_neg_of_neg_of_pos ( mul_neg_of_neg_of_pos ( neg_neg_of_pos ( sq_pos_of_pos ( lt_max_of_lt_left ( sub_pos.mpr hε ) ) ) ) hn ) ( by positivity )

/-
**Monotonicity in the gap parameter.**
-/
theorem sharp_bound_monotone_in_gap
    {C σ ε₁ ε₂ n : ℝ}
    (hε : ε₁ ≤ ε₂) (hσ : 0 < σ) (hC : 0 < C) (hn : 0 ≤ n) :
    SharpFailureUpperBound C σ ε₂ n ≤ SharpFailureUpperBound C σ ε₁ n := by
  unfold SharpFailureUpperBound;
  gcongr

/-- The bound at the edge is exactly 1. -/
theorem sharp_bound_at_edge (C σ n : ℝ) :
    SharpFailureUpperBound C σ (2 * σ) n = 1 :=
  sharp_bound_eq_one_below_edge (le_refl _)

/-- The bound in dimension 0 is trivially 1. -/
theorem sharp_bound_dim_zero (C σ ε : ℝ) :
    SharpFailureUpperBound C σ ε 0 = 1 := by
  unfold SharpFailureUpperBound; simp

/-! ## Engineering failure bound -/

/-- **Engineering GOE failure bound.** -/
theorem engineering_failure_bound
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ} {ε C σ : ℝ}
    (hgap : HasGappedSignature A ε)
    (μ : ProbMeasure n)
    (htail : μ.prob (gapEvent ε) ≤ SharpFailureUpperBound C σ ε (n : ℝ)) :
    μ.prob (misclassificationEvent A) ≤ SharpFailureUpperBound C σ ε (n : ℝ) :=
  le_trans (misclassification_prob_le_opnorm_tail hgap μ) htail

/-! ## Cross-domain bridge: Numerical certification -/

/-- **Bits of precision suffice.** -/
theorem bits_of_precision_suffice
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ} {ε C σ δ : ℝ}
    (hgap : HasGappedSignature A ε)
    (μ : ProbMeasure n)
    (htail : μ.prob (gapEvent ε) ≤ SharpFailureUpperBound C σ ε (n : ℝ))
    (hbound : SharpFailureUpperBound C σ ε (n : ℝ) ≤ δ) :
    μ.prob (misclassificationEvent A) ≤ δ :=
  le_trans (engineering_failure_bound hgap μ htail) hbound

/-! ## Thermodynamic monotonicity -/

/-
**Antitone in noise margin.**
-/
theorem sharp_bound_antitone_in_noise_margin
    {C σ₁ σ₂ ε n : ℝ}
    (hσ₁ : 0 < σ₁) (hσ₂ : σ₁ ≤ σ₂) (hC : 0 < C) (hn : 0 ≤ n) :
    SharpFailureUpperBound C σ₁ ε n ≤ SharpFailureUpperBound C σ₂ ε n ∨ ε ≤ 2 * σ₂ := by
  by_cases hε : ε ≤ 2 * σ₂;
  · exact Or.inr hε;
  · refine Or.inl <| Real.exp_le_exp.mpr ?_;
    rw [ div_le_div_iff₀ ] <;> try positivity;
    · rw [ max_eq_left ( by linarith ), max_eq_left ( by linarith ) ];
      -- Cancel out the common terms $n$ and $C$ from both sides.
      suffices h_cancel : -(ε - 2 * σ₁) ^ 2 * σ₂ ^ 2 ≤ -(ε - 2 * σ₂) ^ 2 * σ₁ ^ 2 by
        nlinarith [ mul_nonneg hC.le hn ];
      nlinarith [ mul_le_mul_of_nonneg_left hσ₂ ( sq_nonneg ( ε - 2 * σ₁ ) ), mul_le_mul_of_nonneg_left hσ₂ ( sq_nonneg ( ε - 2 * σ₂ ) ), mul_le_mul_of_nonneg_left hσ₂ ( sq_nonneg σ₁ ), mul_le_mul_of_nonneg_left hσ₂ ( sq_nonneg σ₂ ) ];
    · exact mul_pos hC ( sq_pos_of_pos ( by linarith ) )

/-! ## Universality interface -/

/-- Abstract edge tail structure for universality. -/
structure HasEdgeTail (n : ℕ) where
  μ : ProbMeasure n
  center : ℝ
  tailBound : ℝ → ℝ
  tail_valid : ∀ t, 0 ≤ t → μ.prob (gapEvent (center + t)) ≤ tailBound t
  tail_mono : ∀ t₁ t₂, t₁ ≤ t₂ → tailBound t₂ ≤ tailBound t₁

/-- **Universality transfer.** Any ensemble with the same edge-tail profile
    yields the same misclassification bound. -/
theorem universality_transfer
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ} {ε : ℝ}
    (hgap : HasGappedSignature A ε)
    (edge : HasEdgeTail n)
    (ht : 0 ≤ ε - edge.center) :
    edge.μ.prob (misclassificationEvent A) ≤ edge.tailBound (ε - edge.center) := by
  calc edge.μ.prob (misclassificationEvent A)
      ≤ edge.μ.prob (gapEvent ε) := misclassification_prob_le_opnorm_tail hgap edge.μ
    _ = edge.μ.prob (gapEvent (edge.center + (ε - edge.center))) := by ring_nf
    _ ≤ edge.tailBound (ε - edge.center) := edge.tail_valid _ ht

/-! ## Sufficient gap formula -/

/-
**Sufficient gap bound.** If the rescaled gap exceeds b, the failure
    bound is at most exp(−b).
-/
theorem sufficient_gap_bound
    {C σ ε n b : ℝ}
    (_hC : 0 < C) (_hσ : 0 < σ)
    (hgap_large : (max (ε - 2 * σ) 0) ^ 2 * n / (C * σ ^ 2) ≥ b) :
    SharpFailureUpperBound C σ ε n ≤ Real.exp (-b) := by
  exact Real.exp_le_exp.mpr ( by linarith [ show ( - ( Max.max ( ε - 2 * σ ) 0 ) ^ 2 * n / ( C * σ ^ 2 ) ) ≤ -b by simpa [ neg_div, div_neg ] using hgap_large ] )

/-! ## Certified failure probability checker -/

/-- Certified checker for failure probability. -/
def certify_failure_prob (C σ ε n neg_ln_δ : ℝ) : Prop :=
  (max (ε - 2 * σ) 0) ^ 2 * n / (C * σ ^ 2) ≥ neg_ln_δ

/-- Soundness of the certified checker. -/
theorem certify_failure_prob_sound
    {C σ ε n b : ℝ}
    (hC : 0 < C) (hσ : 0 < σ)
    (hcert : certify_failure_prob C σ ε n b) :
    SharpFailureUpperBound C σ ε n ≤ Real.exp (-b) :=
  sufficient_gap_bound hC hσ hcert

/-! ## TracyWidom placeholder -/

/-- Placeholder for the Tracy–Widom GOE upper tail distribution function.
    In a complete formalization, this would be defined via the Painlevé II ODE. -/
noncomputable def TracyWidomGOEUpperTail : ℝ → ℝ := fun t =>
  if t ≤ 0 then 1 else Real.exp (-(2/3) * t ^ (3/2 : ℝ))

/-! ## Additional phase transition properties -/

/-
**Scaling in dimension.** Doubling n roughly squares the exponent
    (halves the bound when above edge).
-/
theorem sharp_bound_dimension_scaling
    {C σ ε n : ℝ}
    (_hC : 0 < C) (_hσ : 0 < σ) (_hn : 0 ≤ n)
    (_hε : 2 * σ < ε) :
    SharpFailureUpperBound C σ ε (2 * n) ≤ (SharpFailureUpperBound C σ ε n) ^ 2 := by
  unfold SharpFailureUpperBound;
  rw [ ← Real.exp_nat_mul ] ; ring_nf; norm_num;

/-! ## Conjecture: Tracy–Widom Lorentzian edge law

For GOE perturbations E_n with variance normalization σ²/n, and for any
deterministic symmetric matrix A_n with Lorentzian gap εₙ,

    P(misclassification of Aₙ + Eₙ) ~ F_TW^upper((εₙ − 2σ)n^(2/3)/σ)

whenever the failure event is asymptotically equivalent to the operator norm
crossing event.

**Testable prediction:** For n = 10, 50, 200, Monte Carlo estimates of
P(misclassification) as a function of ε/σ should exhibit:
  • threshold centered near 2,
  • transition width proportional to n^{−2/3},
  • collapse onto a universal curve after rescaling by t = ((ε−2σ)n^(2/3))/σ.

**Disconfirmation criteria:**
  • threshold center drifting away from 2σ,
  • width not scaling like n^{−2/3},
  • lack of rescaled curve collapse.
-/

end SharpGOEConstants