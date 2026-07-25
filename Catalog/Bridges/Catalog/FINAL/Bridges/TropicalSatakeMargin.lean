/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Satake Margin Theorem for GL₃ Hecke Score Classifiers

This file formalizes a certified robustness framework for multiclass linear
score classifiers whose weight vectors arise from a finite tropical Satake
test family attached to GL₃ Hecke data.

## Main results

- `abs_score_sub_le_sum`: pointwise score perturbation bound
- `abs_score_sub_le_l1_mul_eps`: Lipschitz transfer lemma
- `score_gap_lower_bound`: pairwise gap lower bound under perturbation
- `pairwise_margin_preserved`: binary margin preservation
- `multiclass_argmax_invariant`: multiclass argmax certificate
- `separating_implies_exists_distinguishing_coordinate`: separation → coordinate witness
- `separating_implies_exists_feature_with_positive_gap`: separation → score distinction
- `tropical_satake_multiclass_certificate`: final bridge theorem

## Overview

The analytic core is a Lipschitz-type estimate: if each coordinate of a feature
vector is perturbed by at most `ε`, then the score `⟨w, φ⟩` changes by at most
`‖w‖₁ · ε`. When the original margin exceeds this perturbation budget for every
competitor class, the argmax is preserved.

The representation-theoretic content enters through the finite tropical Satake
test map `T : H → Fin n → ℝ`, which is injective by the GL₃ separation theorem.
This ensures that distinct Hecke data produce genuinely different score functionals,
so certified margins are not artifacts of duplicated class vectors.
-/

noncomputable section

open Finset BigOperators

/-! ### Core definitions -/

/-- A test vector is a function `Fin n → ℝ`. -/
abbrev TestVec (n : ℕ) := Fin n → ℝ

/-- The score (inner product) of weight vector `w` and feature vector `φ`. -/
def score {n : ℕ} (w φ : TestVec n) : ℝ :=
  ∑ i : Fin n, w i * φ i

/-- The ℓ¹ norm of a weight vector. -/
def l1Norm {n : ℕ} (w : TestVec n) : ℝ :=
  ∑ i : Fin n, |w i|

/-- The pairwise margin between classes `a` and `b` at feature vector `φ`. -/
def pairwiseMargin {κ n : ℕ} (W : Fin κ → TestVec n) (φ : TestVec n)
    (a b : Fin κ) : ℝ :=
  score (W a) φ - score (W b) φ

/-- Class `a` is the strict argmax at `ψ` given reference `φ`:
    every other class `b` has strictly lower score at `ψ`. -/
def argmaxInvariant {κ n : ℕ} (W : Fin κ → TestVec n) (_φ ψ : TestVec n)
    (a : Fin κ) : Prop :=
  ∀ b : Fin κ, b ≠ a → score (W a) ψ > score (W b) ψ

/-! ### Theorem 1: Lipschitz transfer lemma -/

/-- Score difference equals the sum of `w i * (φ i - ψ i)`. -/
theorem score_sub_eq_sum {n : ℕ} (w φ ψ : TestVec n) :
    score w φ - score w ψ = ∑ i : Fin n, w i * (φ i - ψ i) := by
  simp only [score, ← Finset.sum_sub_distrib]
  congr 1; ext i; ring

/-- The absolute score difference is bounded by
    `∑ i, |w i| * |φ i - ψ i|`. -/
theorem abs_score_sub_le_sum {n : ℕ} (w φ ψ : TestVec n) :
    |score w φ - score w ψ| ≤ ∑ i : Fin n, |w i| * |φ i - ψ i| := by
  rw [← Finset.sum_congr rfl fun i _ => abs_mul (w i) (φ i - ψ i)]
  convert Finset.abs_sum_le_sum_abs _ _
  · exact score_sub_eq_sum w φ ψ
  · infer_instance

/-- **Lipschitz transfer lemma (with `0 ≤ ε`).**
    If each coordinate differs by at most `ε`, the score changes by
    at most `l1Norm w * ε`. -/
theorem abs_score_sub_le_l1_mul_eps' {n : ℕ} (w φ ψ : TestVec n) {ε : ℝ}
    (_hε₀ : 0 ≤ ε) (hε : ∀ i, |φ i - ψ i| ≤ ε) :
    |score w φ - score w ψ| ≤ l1Norm w * ε := by
  calc |score w φ - score w ψ|
      ≤ ∑ i : Fin n, |w i| * |φ i - ψ i| := abs_score_sub_le_sum w φ ψ
    _ ≤ l1Norm w * ε := by
        simpa only [l1Norm, Finset.sum_mul] using
          Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hε i) (abs_nonneg _)

/-- **Lipschitz transfer lemma (general `ε`).**
    If each coordinate differs by at most `ε`, the score changes by
    at most `l1Norm w * ε`. -/
theorem abs_score_sub_le_l1_mul_eps {n : ℕ} (w φ ψ : TestVec n) (ε : ℝ)
    (hε : ∀ i, |φ i - ψ i| ≤ ε) :
    |score w φ - score w ψ| ≤ l1Norm w * ε := by
  calc |score w φ - score w ψ|
      ≤ ∑ i : Fin n, |w i| * |φ i - ψ i| := abs_score_sub_le_sum w φ ψ
    _ ≤ l1Norm w * ε := by
        simpa only [l1Norm, Finset.sum_mul] using
          Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hε i) (abs_nonneg _)

/-! ### Theorem 2: Pairwise margin preservation -/

/-- **Score gap lower bound.** Under coordinatewise `ε`-perturbation,
    the gap `score wa ψ - score wb ψ` is at least the original gap
    minus `(l1Norm wa + l1Norm wb) * ε`. -/
theorem score_gap_lower_bound {n : ℕ} (wa wb φ ψ : TestVec n) {ε : ℝ}
    (hε₀ : 0 ≤ ε) (hcoord : ∀ i, |φ i - ψ i| ≤ ε) :
    score wa ψ - score wb ψ ≥
      (score wa φ - score wb φ) - (l1Norm wa + l1Norm wb) * ε := by
  have h1 : |score wa φ - score wa ψ| ≤ l1Norm wa * ε :=
    abs_score_sub_le_l1_mul_eps' wa φ ψ hε₀ hcoord
  have h2 : |score wb φ - score wb ψ| ≤ l1Norm wb * ε :=
    abs_score_sub_le_l1_mul_eps' wb φ ψ hε₀ hcoord
  linarith [abs_le.mp h1, abs_le.mp h2]

/-- **Pairwise margin preservation.** If the original margin exceeds the
    perturbation budget `(l1Norm wa + l1Norm wb) * ε`, then the score
    ordering is preserved. -/
theorem pairwise_margin_preserved {n : ℕ} (wa wb φ ψ : TestVec n) {ε : ℝ}
    (hε₀ : 0 ≤ ε) (hcoord : ∀ i, |φ i - ψ i| ≤ ε)
    (hmargin : score wa φ - score wb φ > (l1Norm wa + l1Norm wb) * ε) :
    score wa ψ > score wb ψ := by
  linarith [score_gap_lower_bound wa wb φ ψ hε₀ hcoord]

/-! ### Theorem 3: Multiclass argmax certificate -/

/-- **Multiclass argmax invariance.** If class `a` has sufficient margin
    over every competitor at `φ`, then `a` remains the strict argmax at `ψ`. -/
theorem multiclass_argmax_invariant {κ n : ℕ} (W : Fin κ → TestVec n)
    (a : Fin κ) (φ ψ : TestVec n) {ε : ℝ}
    (hε₀ : 0 ≤ ε) (hcoord : ∀ i, |φ i - ψ i| ≤ ε)
    (hmargin : ∀ b : Fin κ, b ≠ a →
      score (W a) φ - score (W b) φ > (l1Norm (W a) + l1Norm (W b)) * ε) :
    ∀ b : Fin κ, b ≠ a → score (W a) ψ > score (W b) ψ := by
  intro b hb
  exact pairwise_margin_preserved (W a) (W b) φ ψ hε₀ hcoord (hmargin b hb)

/-- Equivalent formulation using the `argmaxInvariant` predicate. -/
theorem multiclass_argmax_invariant' {κ n : ℕ} (W : Fin κ → TestVec n)
    (a : Fin κ) (φ ψ : TestVec n) {ε : ℝ}
    (hε₀ : 0 ≤ ε) (hcoord : ∀ i, |φ i - ψ i| ≤ ε)
    (hmargin : ∀ b : Fin κ, b ≠ a →
      score (W a) φ - score (W b) φ > (l1Norm (W a) + l1Norm (W b)) * ε) :
    argmaxInvariant W φ ψ a :=
  multiclass_argmax_invariant W a φ ψ hε₀ hcoord hmargin

/-! ### Theorem 4: Representation-theoretic separation -/

/-- A test map `T : H → Fin n → ℝ` is *separating* if it is injective. -/
def Separating {H : Type*} {n : ℕ} (T : H → TestVec n) : Prop :=
  Function.Injective T

/-- Injective maps send distinct inputs to distinct outputs.
    (Trivial but makes the GL₃ separation content explicit.) -/
theorem separating_implies_nonzero_pairwise_vector
    {H : Type*} {n : ℕ} (T : H → TestVec n)
    (hsep : Function.Injective T) {ha hb : H} (hne : ha ≠ hb) :
    T ha ≠ T hb :=
  fun h => hne (hsep h)

/-- If the test map is separating, distinct Hecke data differ on
    at least one coordinate. -/
theorem separating_implies_exists_distinguishing_coordinate
    {H : Type*} {n : ℕ} (T : H → TestVec n)
    (hsep : Function.Injective T) {ha hb : H} (hne : ha ≠ hb) :
    ∃ i : Fin n, T ha i ≠ T hb i :=
  Function.ne_iff.mp (hsep.ne hne)

/-- If the test map is separating, there exists a feature vector that
    produces distinct scores for distinct Hecke data. -/
theorem separating_implies_exists_feature_with_positive_gap
    {H : Type*} {n : ℕ} (T : H → TestVec n)
    (hsep : Function.Injective T) {ha hb : H} (hne : ha ≠ hb) :
    ∃ φ : TestVec n, score (T ha) φ ≠ score (T hb) φ := by
  contrapose! hne
  exact hsep (by ext i; specialize hne (fun j => if j = i then 1 else 0); simp_all +decide [score])

/-! ### Final bridge: Tropical Satake multiclass certificate -/

/-- **Tropical Satake multiclass certificate.**
    Let `T : H → Fin n → ℝ` be a separating tropical test map (e.g. from
    GL₃ Hecke data), and let `cls : Fin κ → H` assign Hecke data to each
    class. If the transformed margin of class `a` exceeds the perturbation
    budget at every competitor, then `a` is the strict argmax at `ψ`. -/
theorem tropical_satake_multiclass_certificate
    {H : Type*} {κ n : ℕ} (T : H → TestVec n) (cls : Fin κ → H)
    (_hsep : Function.Injective T)
    (a : Fin κ) (φ ψ : TestVec n) {ε : ℝ}
    (hε₀ : 0 ≤ ε) (hcoord : ∀ i, |φ i - ψ i| ≤ ε)
    (hmargin : ∀ b : Fin κ, b ≠ a →
      score (T (cls a)) φ - score (T (cls b)) φ >
        (l1Norm (T (cls a)) + l1Norm (T (cls b))) * ε) :
    ∀ b : Fin κ, b ≠ a →
      score (T (cls a)) ψ > score (T (cls b)) ψ :=
  multiclass_argmax_invariant (fun c => T (cls c)) a φ ψ hε₀ hcoord hmargin

/-- **Normalized margin form.** If `ε` is strictly below the normalized
    margin for each competitor, argmax is preserved. Requires
    positive denominators. -/
theorem tropical_satake_multiclass_certificate_normalized
    {H : Type*} {κ n : ℕ} (T : H → TestVec n) (cls : Fin κ → H)
    (a : Fin κ) (φ ψ : TestVec n) {ε : ℝ}
    (_hε₀ : 0 ≤ ε) (hcoord : ∀ i, |φ i - ψ i| ≤ ε)
    (hpos : ∀ b : Fin κ, b ≠ a →
      0 < l1Norm (T (cls a)) + l1Norm (T (cls b)))
    (hnorm : ∀ b : Fin κ, b ≠ a →
      ε < (score (T (cls a)) φ - score (T (cls b)) φ) /
          (l1Norm (T (cls a)) + l1Norm (T (cls b)))) :
    ∀ b : Fin κ, b ≠ a →
      score (T (cls a)) ψ > score (T (cls b)) ψ := by
  intro b hb
  have h := hnorm b hb
  rw [lt_div_iff₀ (hpos b hb)] at h
  linarith [abs_le.mp (abs_score_sub_le_l1_mul_eps (T (cls a)) φ ψ ε hcoord),
            abs_le.mp (abs_score_sub_le_l1_mul_eps (T (cls b)) φ ψ ε hcoord)]

end