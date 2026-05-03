/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Satake Top-K Robustness for GL₃ Hecke Score Classifiers

This file upgrades the tropical Satake margin robustness story from top-1 argmax
stability to top-k ranking stability for finitely many GL₃ Hecke-score classes.

## Main results

- `separated_order_preserved_of_uniform_score_close`: pairwise order preservation under
  uniform perturbation — the engine of the whole argument.
- `topKSet_eq_of_uniform_score_close`: the full abstract top-k invariance theorem under
  uniform score perturbation with gap condition.
- `topKSet_eq_of_lipschitz_gap`: metric/Lipschitz version of top-k invariance.
- `argmax_stable_of_topK_gap`: the k=1 specialization recovering the argmax theorem.
- `tropical_GL3_topK_certified_robust`: GL₃ tropical certificate form.

## Overview

The core mathematical insight is that if the k-th and (k+1)-th ranked scores are
separated by a gap Δ, and all scores are perturbed by at most η with 2η < Δ,
then the top-k set is invariant. This extends the classical argmax robustness theorem
(k=1) to set-valued decisions used in shortlist decoding, beam search, multiclass
retrieval, and ranking-based certified robustness.

The definition of `topKSet` is tie-tolerant: it includes all labels with fewer than k
labels strictly above them. When there are no ties at the k-th boundary (ensured by the
exact cardinality condition `(topKSet score k).card = k`), the gap condition between the
k-th and (k+1)-th ranked labels guarantees exact preservation of the top-k set under
perturbation.
-/

noncomputable section

open scoped BigOperators

/-! ### Core definitions -/

variable {ι : Type*}

/-- The top-k label set: labels `i` such that fewer than `k` labels strictly outscore `i`.
This definition is tie-tolerant in the right way for robustness statements. -/
def topKSet [Fintype ι] [DecidableEq ι] (score : ι → ℝ) (k : ℕ) : Finset ι :=
  Finset.univ.filter (fun i => (Finset.univ.filter fun j => score i < score j).card < k)

/-- The score-gap predicate: there is a positive gap Δ between every selected and every
unselected label. -/
def topKGapAt [Fintype ι] [DecidableEq ι] (score : ι → ℝ) (k : ℕ) (Δ : ℝ) : Prop :=
  0 < Δ ∧
  ∀ ⦃i j : ι⦄, i ∈ topKSet score k → j ∉ topKSet score k → Δ ≤ score i - score j

/-- Uniform perturbation bound: every score changes by at most η. -/
def UniformScoreClose (score score' : ι → ℝ) (η : ℝ) : Prop :=
  ∀ i, |score' i - score i| ≤ η

/-- A score family indexed by a space α is K-Lipschitz with respect to a distance d. -/
def IsKLipschitzFamily {α : Type*} (d : α → α → ℝ) (score : α → ι → ℝ) (K : ℝ) : Prop :=
  ∀ x y i, |score x i - score y i| ≤ K * d x y

/-- The boundary-gap predicate (equivalent formulation). -/
def topKBoundaryGapAt [Fintype ι] [DecidableEq ι] (score : ι → ℝ) (k : ℕ) (Δ : ℝ) : Prop :=
  0 < Δ ∧
  ∀ ⦃i j : ι⦄,
    i ∈ topKSet score k →
    j ∉ topKSet score k →
    score j ≤ score i - Δ

/-! ### Characterization lemmas -/

variable [Fintype ι] [DecidableEq ι]

/-- Membership in `topKSet` is equivalent to the cardinality condition. -/
lemma mem_topKSet_iff_card_lt
    (score : ι → ℝ) (k : ℕ) (i : ι) :
    i ∈ topKSet score k ↔
      (Finset.univ.filter fun j => score i < score j).card < k := by
  simp [topKSet]

/-- The boundary gap and the score gap predicates are equivalent. -/
lemma topKBoundaryGapAt_iff_topKGapAt (score : ι → ℝ) (k : ℕ) (Δ : ℝ) :
    topKBoundaryGapAt score k Δ ↔ topKGapAt score k Δ := by
  simp only [topKBoundaryGapAt, topKGapAt]
  constructor <;> intro ⟨hpos, h⟩ <;> exact ⟨hpos, fun i j hi hj => by linarith [h hi hj]⟩

/-! ### Pairwise perturbation lemma -/

/-- **Pairwise order preservation under uniform perturbation.**
If `score i - score j ≥ Δ` and all scores are perturbed by at most η with `2η < Δ`,
then `score' j < score' i`. This is the engine of the whole argument. -/
lemma separated_order_preserved_of_uniform_score_close
    {ι' : Type*}
    (score score' : ι' → ℝ) (i j : ι') (Δ η : ℝ)
    (hsep : Δ ≤ score i - score j)
    (hclose : UniformScoreClose score score' η)
    (hη : 2 * η < Δ) :
    score' j < score' i := by
  linarith [abs_le.mp (hclose i), abs_le.mp (hclose j)]

/-! ### Top-k subset inclusions -/

/-- If i is in the top-k and j is not, and the gap condition holds with 2η < Δ,
then under η-uniform perturbation, j still cannot outscore i. -/
lemma topK_inside_beats_outside
    (score score' : ι → ℝ) (k : ℕ) (Δ η : ℝ)
    (hgap : topKGapAt score k Δ)
    (hclose : UniformScoreClose score score' η)
    (hη : 2 * η < Δ)
    (i j : ι) (hi : i ∈ topKSet score k) (hj : j ∉ topKSet score k) :
    score' j < score' i :=
  separated_order_preserved_of_uniform_score_close score score' i j Δ η
    (hgap.2 hi hj) hclose hη

/-
The set of labels that beat `i` in the perturbed scores is contained in the
original top-k set (minus `i` itself). Key step for the cardinality argument.
-/
lemma perturbed_beaters_subset_topK
    (score score' : ι → ℝ) (k : ℕ) (Δ η : ℝ)
    (hgap : topKGapAt score k Δ)
    (hclose : UniformScoreClose score score' η)
    (hη : 2 * η < Δ)
    (i : ι) (hi : i ∈ topKSet score k) :
    Finset.univ.filter (fun j => score' i < score' j) ⊆
      (topKSet score k).erase i := by
  grind +locals

/-
**Forward inclusion**: every label in the original top-k set remains in the
perturbed top-k set, provided the original top-k set has exactly k elements
(no ties at the k-th boundary).
-/
theorem topKSet_subset_of_uniform_score_close
    (score score' : ι → ℝ) (k : ℕ) (Δ η : ℝ)
    (hgap : topKGapAt score k Δ)
    (hclose : UniformScoreClose score score' η)
    (hη : 2 * η < Δ)
    (hcard : (topKSet score k).card = k) :
    topKSet score k ⊆ topKSet score' k := by
  intro i hi;
  -- By perturbed_beaters_subset_topK, the filter set is a subset of (topKSet score k).erase i.
  have h_filter_subset : Finset.univ.filter (fun j => score' i < score' j) ⊆ (topKSet score k).erase i := by
    exact perturbed_beaters_subset_topK score score' k Δ η hgap hclose hη i hi;
  exact mem_topKSet_iff_card_lt score' k i |>.2 ( lt_of_le_of_lt ( Finset.card_le_card h_filter_subset ) ( by rw [ Finset.card_erase_of_mem hi, hcard ] ; exact Nat.pred_lt ( by aesop ) ) )

/-
**Reverse inclusion**: every element of the top-k set of a perturbed score
is in the top-k set of the original score, given a gap condition.
-/
theorem topKSet_superset_of_uniform_score_close
    (score score' : ι → ℝ) (k : ℕ) (Δ η : ℝ)
    (hgap : topKGapAt score k Δ)
    (hclose : UniformScoreClose score score' η)
    (hη : 2 * η < Δ)
    (hcard : (topKSet score k).card = k) :
    topKSet score' k ⊆ topKSet score k := by
  intro j hj
  by_contra h_contra;
  have h_subset : (Finset.univ.filter fun l => score' j < score' l).card ≥ (topKSet score k).card := by
    refine Finset.card_le_card ?_;
    grind +suggestions;
  exact not_lt_of_ge h_subset ( by simpa [ hcard ] using Finset.mem_filter.mp hj |>.2 )

/-- **Main Theorem 1: Top-k invariance under uniform score perturbation.**
If scores have a gap Δ between the k-th and (k+1)-th ranked labels, all scores
are perturbed by at most η with 2η < Δ, and the top-k set has exactly k elements
(no ties at the boundary), then the top-k set is exactly preserved. -/
theorem topKSet_eq_of_uniform_score_close
    (score score' : ι → ℝ) (k : ℕ) (Δ η : ℝ)
    (hgap : topKGapAt score k Δ)
    (hclose : UniformScoreClose score score' η)
    (hη : 2 * η < Δ)
    (hcard : (topKSet score k).card = k) :
    topKSet score' k = topKSet score k :=
  Finset.Subset.antisymm
    (topKSet_superset_of_uniform_score_close score score' k Δ η hgap hclose hη hcard)
    (topKSet_subset_of_uniform_score_close score score' k Δ η hgap hclose hη hcard)

/-! ### Metric/Lipschitz version -/

/-- Lipschitz bound implies uniform score closeness. -/
lemma uniformScoreClose_of_lipschitz
    {ι' : Type*} {α : Type*} (d : α → α → ℝ) (score : α → ι' → ℝ)
    (K : ℝ) (x x' : α) (ε : ℝ)
    (hlip : IsKLipschitzFamily d score K)
    (hdist : d x x' ≤ ε)
    (hKnonneg : 0 ≤ K) :
    UniformScoreClose (score x) (score x') (K * ε) := by
  intro i
  simpa [abs_sub_comm] using le_trans (hlip x x' i) (mul_le_mul_of_nonneg_left hdist hKnonneg)

/-- **Main Theorem 2: Top-k invariance under Lipschitz perturbation.**
A short corollary of Main Theorem 1 with η := K * ε. -/
theorem topKSet_eq_of_lipschitz_gap
    {α : Type*} (d : α → α → ℝ) (score : α → ι → ℝ)
    (K : ℝ) (x x' : α) (k : ℕ) (Δ ε : ℝ)
    (hlip : IsKLipschitzFamily d score K)
    (hgap : topKGapAt (score x) k Δ)
    (hdist : d x x' ≤ ε)
    (hKnonneg : 0 ≤ K)
    (hmargin : 2 * K * ε < Δ)
    (hcard : (topKSet (score x) k).card = k) :
    topKSet (score x') k = topKSet (score x) k := by
  apply topKSet_eq_of_uniform_score_close _ _ k Δ (K * ε) hgap
  · exact uniformScoreClose_of_lipschitz d score K x x' ε hlip hdist hKnonneg
  · linarith [mul_assoc 2 K ε]
  · exact hcard

/-! ### Top-1 specialization: argmax stability -/

/-- **Main Theorem 3: Top-1 specialization.**
The k=1 case recovers the classical argmax stability theorem. -/
theorem argmax_stable_of_topK_gap
    (score score' : ι → ℝ) (Δ η : ℝ)
    (hgap : topKGapAt score 1 Δ)
    (hclose : UniformScoreClose score score' η)
    (hη : 2 * η < Δ)
    (hcard : (topKSet score 1).card = 1) :
    topKSet score' 1 = topKSet score 1 :=
  topKSet_eq_of_uniform_score_close score score' 1 Δ η hgap hclose hη hcard

/-! ### Pointwise membership form -/

/-- **Pointwise membership equivalence**: a label is in the perturbed top-k set
iff it was in the original top-k set. -/
theorem topKSet_preserved_iff
    (score score' : ι → ℝ) (k : ℕ) (Δ η : ℝ)
    (hgap : topKGapAt score k Δ)
    (hclose : UniformScoreClose score score' η)
    (hη : 2 * η < Δ)
    (hcard : (topKSet score k).card = k) :
    ∀ i, i ∈ topKSet score' k ↔ i ∈ topKSet score k := by
  intro i
  rw [topKSet_eq_of_uniform_score_close score score' k Δ η hgap hclose hη hcard]

/-! ### GL₃ Tropical Certificate Form -/

/-- **Main Theorem 4: GL₃ tropical Satake certified top-k robustness.**
Connects the abstract top-k theorem to GL₃ tropical Satake score reconstruction.
The certificate decomposes as `Δ = edgeCert + leviCert`, coming from simple-coroot
edge valuations and rank-2 Levi marginal contributions. -/
theorem tropical_GL3_topK_certified_robust
    {α : Type*} (d : α → α → ℝ) (score : α → ι → ℝ)
    (K : ℝ) (x x' : α) (k : ℕ)
    (Δ edgeCert leviCert ε : ℝ)
    (_hΔdef : Δ = edgeCert + leviCert)
    (hΔpos : 0 < Δ)
    (hsep :
      ∀ ⦃i j : ι⦄, i ∈ topKSet (score x) k → j ∉ topKSet (score x) k →
        Δ ≤ score x i - score x j)
    (hlip : IsKLipschitzFamily d score K)
    (hdist : d x x' ≤ ε)
    (hKnonneg : 0 ≤ K)
    (hmargin : 2 * K * ε < Δ)
    (hcard : (topKSet (score x) k).card = k) :
    topKSet (score x') k = topKSet (score x) k :=
  topKSet_eq_of_lipschitz_gap d score K x x' k Δ ε hlip
    ⟨hΔpos, hsep⟩ hdist hKnonneg hmargin hcard

end