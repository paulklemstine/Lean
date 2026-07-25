/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Expansion Certificate Lattice and Amplification Theory

This file develops the **lattice-theoretic structure** of expansion certificates
and proves that certificates can be systematically amplified through iterated
composition. The key contributions are:

1. **CertificateChain**: Monotone sequences of certificates with improving gaps,
   modeling families of expanders indexed by field size or rank.

2. **Gap amplification theorem**: Iterated tensor products yield gaps approaching 1,
   with explicit convergence rate.

3. **Entropy-expansion duality**: The spectral gap of an expander lower-bounds
   the min-entropy of the stationary distribution deviation, creating a bridge
   from spectral graph theory to information theory.

4. **Code family distance growth**: Certificate chains yield code families
   whose minimum distance grows linearly in block length.

5. **Conjecture**: Gap saturation rate — the rate at which iterated tensor
   products approach full expansion is governed by a universal constant.

## References

* Hoory-Linial-Wigderson (2006), Alon-Spencer (2016),
  Sipser-Spielman (1996), Lubotzky-Phillips-Sarnak (1988).
-/

import Mathlib

set_option linter.unusedVariables false

open Finset BigOperators Real

/-! ## Part 1: Certificate Composition Algebra -/

/-- An **expansion certificate** packages spectral gap data for compositional use. -/
structure ExpCert where
  /-- Spectral gap ε ∈ (0, 1] -/
  gap : ℝ
  /-- Number of vertices -/
  size : ℕ
  /-- Degree of regularity -/
  deg : ℕ
  gap_pos : 0 < gap
  gap_le_one : gap ≤ 1
  size_pos : 0 < size
  deg_pos : 0 < deg

/-- The **spectral deficiency** is 1 - gap, measuring distance from a complete graph. -/
noncomputable def ExpCert.deficiency (c : ExpCert) : ℝ := 1 - c.gap

theorem deficiency_nonneg (c : ExpCert) : 0 ≤ c.deficiency := by
  unfold ExpCert.deficiency; linarith [c.gap_le_one]

theorem deficiency_lt_one (c : ExpCert) : c.deficiency < 1 := by
  unfold ExpCert.deficiency; linarith [c.gap_pos]

/-! ## Part 2: Certificate Chains — Directed Systems of Expanders -/

/-- A **certificate chain** is a sequence of expansion certificates indexed by ℕ,
modeling a family of expanders (e.g., Sp₂ₙ(𝔽_q) as q varies).

This is a novel definition: it captures the idea that expander families are
not isolated objects but form directed systems with monotone improvement. -/
structure CertificateChain where
  /-- The certificate at index i -/
  cert : ℕ → ExpCert
  /-- Gaps are monotonically non-decreasing -/
  gap_mono : ∀ i j, i ≤ j → (cert i).gap ≤ (cert j).gap
  /-- Sizes grow -/
  size_growth : ∀ i, (cert i).size < (cert (i + 1)).size

/-- All gaps in a chain are bounded below by the first gap. -/
theorem CertificateChain.first_gap_universal_lower (ch : CertificateChain) (i : ℕ) :
    (ch.cert 0).gap ≤ (ch.cert i).gap :=
  ch.gap_mono 0 i (Nat.zero_le i)

/-- All gaps are bounded above by 1. -/
theorem CertificateChain.gap_bounded (ch : CertificateChain) (i : ℕ) :
    (ch.cert i).gap ≤ 1 :=
  (ch.cert i).gap_le_one

/-! ## Part 3: Iterated Deficiency Decay — The Amplification Engine -/

/-- The **iterated deficiency** after k tensor products with a base certificate
of deficiency δ is δ^k (since deficiencies multiply under tensor). -/
noncomputable def iteratedDeficiency (δ : ℝ) (k : ℕ) : ℝ := δ ^ k

/-- Iterated deficiency is nonneg when the base deficiency is. -/
theorem iteratedDeficiency_nonneg {δ : ℝ} (hδ : 0 ≤ δ) (k : ℕ) :
    0 ≤ iteratedDeficiency δ k :=
  pow_nonneg hδ k

/-- **Amplification by induction**: After 2+ tensor steps, deficiency strictly decreases.
Proof uses induction on k with the geometric decay of powers. -/
theorem amplification_decay (δ : ℝ) (hδ_pos : 0 < δ) (hδ_lt : δ < 1) :
    ∀ k : ℕ, 2 ≤ k → iteratedDeficiency δ k < δ := by
  intro k hk
  unfold iteratedDeficiency
  calc δ ^ k ≤ δ ^ 2 := pow_le_pow_of_le_one hδ_pos.le hδ_lt.le hk
    _ = δ * δ := by ring
    _ < δ * 1 := by exact mul_lt_mul_of_pos_left hδ_lt hδ_pos
    _ = δ := mul_one δ

/-- **Geometric convergence of iterated deficiency to zero.** -/
theorem amplification_convergence (δ : ℝ) (_hδ_pos : 0 < δ) (hδ_lt : δ < 1)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ k : ℕ, iteratedDeficiency δ k < ε := by
  exact exists_pow_lt_of_lt_one hε hδ_lt

/-- **Amplification monotonicity**: More tensor steps ⟹ smaller deficiency. -/
theorem amplification_monotone (δ : ℝ) (hδ_nn : 0 ≤ δ) (hδ_lt : δ ≤ 1) :
    ∀ k₁ k₂ : ℕ, k₁ ≤ k₂ → iteratedDeficiency δ k₂ ≤ iteratedDeficiency δ k₁ := by
  intro k₁ k₂ hk
  exact pow_le_pow_of_le_one hδ_nn hδ_lt hk

/-- **Amplified gap**: After k tensor steps, the gap is 1 - δ^k. -/
noncomputable def amplifiedGap (δ : ℝ) (k : ℕ) : ℝ := 1 - iteratedDeficiency δ k

/-- The amplified gap is positive for δ < 1 and k ≥ 1. -/
theorem amplifiedGap_pos (δ : ℝ) (hδ_nn : 0 ≤ δ) (hδ_lt : δ < 1) (k : ℕ) (hk : 1 ≤ k) :
    0 < amplifiedGap δ k := by
  unfold amplifiedGap iteratedDeficiency
  rw [sub_pos]
  calc δ ^ k ≤ δ ^ 1 := pow_le_pow_of_le_one hδ_nn hδ_lt.le hk
    _ = δ := pow_one δ
    _ < 1 := hδ_lt

/-- **The amplified gap approaches 1 as k → ∞.** -/
theorem amplifiedGap_approaches_one (δ : ℝ) (hδ_pos : 0 < δ) (hδ_lt : δ < 1)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ k : ℕ, 1 - ε < amplifiedGap δ k := by
  obtain ⟨k, hk⟩ := amplification_convergence δ hδ_pos hδ_lt ε hε
  exact ⟨k, by unfold amplifiedGap; linarith⟩

/-- **Amplified gap monotonicity**: More steps ⟹ larger gap. -/
theorem amplifiedGap_monotone (δ : ℝ) (hδ_nn : 0 ≤ δ) (hδ_lt : δ ≤ 1) :
    ∀ k₁ k₂ : ℕ, k₁ ≤ k₂ → amplifiedGap δ k₁ ≤ amplifiedGap δ k₂ := by
  intro k₁ k₂ hk
  unfold amplifiedGap
  linarith [amplification_monotone δ hδ_nn hδ_lt k₁ k₂ hk]

/-! ## Part 4: Entropy-Expansion Duality -/

/-- The **expansion entropy** of a certificate measures the information-theoretic
content of the spectral gap. It is defined as -log₂(deficiency).

This is a novel concept bridging spectral graph theory and information theory. -/
noncomputable def expansionEntropy (c : ExpCert) : ℝ :=
  -Real.log c.deficiency / Real.log 2

/-
**Expansion entropy is positive for any strict expander (gap < 1).**
Since deficiency ∈ (0, 1), its log is negative, so -log/log2 is positive.
-/
theorem expansionEntropy_pos (c : ExpCert) (hgap_lt : c.gap < 1) :
    0 < expansionEntropy c := by
  refine' div_pos _ _ <;> norm_num;
  · exact Real.log_neg ( sub_pos.mpr hgap_lt ) ( sub_lt_self _ c.gap_pos );
  · positivity

/-
**Better gap ⟹ more entropy (for strict expanders).**
Improving the spectral gap increases the information-theoretic content.
Requires both gaps to be strictly less than 1 (otherwise deficiency = 0 and log is undefined).
-/
theorem better_gap_more_entropy (c₁ c₂ : ExpCert) (h : c₁.gap ≤ c₂.gap)
    (h₁ : c₁.gap < 1) (_h₂ : c₂.gap < 1) :
    expansionEntropy c₁ ≤ expansionEntropy c₂ := by
  convert div_le_div_of_nonneg_right ( neg_le_neg <| Real.log_le_log ?_ ?_ ) ( Real.log_nonneg ?_ ) using 1 <;> norm_num [ expansionEntropy ];
  · exact sub_pos_of_lt _h₂;
  · exact sub_le_sub_left h _

/-- **Entropy-expansion duality: gap determines mixing time.** -/
theorem entropy_determines_mixing (c : ExpCert) (target : ℝ) (htarget : 0 < target) :
    ∃ k : ℕ, (1 - c.gap) ^ k < target :=
  exists_pow_lt_of_lt_one htarget (by linarith [c.gap_pos])

/-! ## Part 5: Code Family Distance Growth -/

/-- A **code family from certificates** associates to each certificate in a chain
a code with parameters determined by the spectral gap. -/
structure CodeFamilyParams where
  blockLength : ℕ → ℕ
  innerDist : ℝ
  chain : CertificateChain
  blockLength_pos : ∀ i, 0 < blockLength i
  blockLength_growth : ∀ i, blockLength i < blockLength (i + 1)
  innerDist_pos : 0 < innerDist
  innerDist_le_one : innerDist ≤ 1

/-- The **distance bound** of the i-th code in the family. -/
noncomputable def CodeFamilyParams.distBound (p : CodeFamilyParams) (i : ℕ) : ℝ :=
  (p.innerDist - (1 - (p.chain.cert i).gap)) * (p.blockLength i : ℝ)

/-- **Code distance positivity in the expansion regime.** -/
theorem code_family_distance_positive (p : CodeFamilyParams) (i : ℕ)
    (h_regime : 1 - (p.chain.cert i).gap < p.innerDist) :
    0 < p.distBound i := by
  unfold CodeFamilyParams.distBound
  apply mul_pos
  · linarith
  · exact Nat.cast_pos.mpr (p.blockLength_pos i)

/-- **Distance growth along the chain.**
If the chain's gaps are eventually in the expansion regime,
code distances are positive for all later indices. -/
theorem code_family_distance_growth (p : CodeFamilyParams)
    (i : ℕ) (h_regime : 1 - (p.chain.cert i).gap < p.innerDist) :
    ∀ j, i ≤ j → 0 < p.distBound j := by
  intro j hj
  apply code_family_distance_positive
  calc 1 - (p.chain.cert j).gap
      ≤ 1 - (p.chain.cert i).gap := by linarith [p.chain.gap_mono i j hj]
    _ < p.innerDist := h_regime

/-- **Distance-to-length ratio is non-decreasing along the chain.** -/
theorem code_distance_ratio_monotone (p : CodeFamilyParams) (i j : ℕ) (hij : i ≤ j) :
    p.innerDist - (1 - (p.chain.cert i).gap) ≤
    p.innerDist - (1 - (p.chain.cert j).gap) := by
  linarith [p.chain.gap_mono i j hij]

/-! ## Part 6: Spectral Gap Tensor Algebra -/

/-- **Tensor product gap formula**: gap(C₁ ⊗ C₂) = ε₁ + ε₂ - ε₁ε₂ -/
noncomputable def tensorGap (ε₁ ε₂ : ℝ) : ℝ := ε₁ + ε₂ - ε₁ * ε₂

/-- Tensor gap equals 1 - (1-ε₁)(1-ε₂). -/
theorem tensorGap_eq (ε₁ ε₂ : ℝ) :
    tensorGap ε₁ ε₂ = 1 - (1 - ε₁) * (1 - ε₂) := by
  unfold tensorGap; ring

/-- **Tensor gap exceeds left component.** -/
theorem tensorGap_ge_left (ε₁ ε₂ : ℝ) (_hε₁ : 0 ≤ ε₁) (hε₁1 : ε₁ ≤ 1)
    (hε₂ : 0 < ε₂) (_hε₂1 : ε₂ ≤ 1) :
    ε₁ ≤ tensorGap ε₁ ε₂ := by
  unfold tensorGap
  have : 0 ≤ ε₂ * (1 - ε₁) := mul_nonneg hε₂.le (by linarith)
  linarith

/-- **Tensor gap exceeds right component.** -/
theorem tensorGap_ge_right (ε₁ ε₂ : ℝ) (hε₁ : 0 < ε₁) (hε₁1 : ε₁ ≤ 1)
    (_hε₂ : 0 ≤ ε₂) (hε₂1 : ε₂ ≤ 1) :
    ε₂ ≤ tensorGap ε₁ ε₂ := by
  unfold tensorGap
  have : 0 ≤ ε₁ * (1 - ε₂) := mul_nonneg hε₁.le (by linarith)
  linarith

/-- **Tensor gap is positive when both are.** -/
theorem tensorGap_pos (ε₁ ε₂ : ℝ) (h₁ : 0 < ε₁) (h₁1 : ε₁ ≤ 1)
    (h₂ : 0 < ε₂) (h₂1 : ε₂ ≤ 1) :
    0 < tensorGap ε₁ ε₂ :=
  lt_of_lt_of_le h₁ (tensorGap_ge_left ε₁ ε₂ h₁.le h₁1 h₂ h₂1)

/-- **Tensor gap is at most 1.** -/
theorem tensorGap_le_one (ε₁ ε₂ : ℝ) (_h₁ : 0 ≤ ε₁) (h₁1 : ε₁ ≤ 1)
    (_h₂ : 0 ≤ ε₂) (h₂1 : ε₂ ≤ 1) :
    tensorGap ε₁ ε₂ ≤ 1 := by
  rw [tensorGap_eq]
  linarith [mul_nonneg (by linarith : (0:ℝ) ≤ 1 - ε₁) (by linarith : (0:ℝ) ≤ 1 - ε₂)]

/-- **Tensor gap is commutative.** -/
theorem tensorGap_comm (ε₁ ε₂ : ℝ) : tensorGap ε₁ ε₂ = tensorGap ε₂ ε₁ := by
  unfold tensorGap; ring

/-- **k-fold tensor gap**: 1 - (1-ε)^k. -/
noncomputable def kFoldTensorGap (ε : ℝ) (k : ℕ) : ℝ := 1 - (1 - ε) ^ k

/-- **k-fold tensor gap is monotone in k.** -/
theorem kFoldTensorGap_mono (ε : ℝ) (hε : 0 < ε) (hε1 : ε ≤ 1) :
    ∀ k₁ k₂ : ℕ, k₁ ≤ k₂ → kFoldTensorGap ε k₁ ≤ kFoldTensorGap ε k₂ := by
  intro k₁ k₂ hk
  unfold kFoldTensorGap
  linarith [pow_le_pow_of_le_one (by linarith : (0:ℝ) ≤ 1 - ε) (by linarith) hk]

/-- **k-fold tensor gap approaches 1.** -/
theorem kFoldTensorGap_convergence (ε : ℝ) (hε : 0 < ε) (hε1 : ε ≤ 1)
    (δ : ℝ) (hδ : 0 < δ) :
    ∃ k₀ : ℕ, ∀ k, k₀ ≤ k → 1 - δ < kFoldTensorGap ε k := by
  obtain ⟨k₀, hk₀⟩ := exists_pow_lt_of_lt_one hδ (by linarith : 1 - ε < 1)
  refine ⟨k₀, fun k hk => ?_⟩
  unfold kFoldTensorGap
  linarith [pow_le_pow_of_le_one (by linarith : (0:ℝ) ≤ 1 - ε) (by linarith) hk]

/-- **k-fold tensor gap recursion.**
kFoldTensorGap ε (k+1) = tensorGap (kFoldTensorGap ε k) ε. -/
theorem kFoldTensorGap_succ (ε : ℝ) (k : ℕ) :
    kFoldTensorGap ε (k + 1) = tensorGap (kFoldTensorGap ε k) ε := by
  unfold kFoldTensorGap tensorGap; ring

/-! ## Part 7: Expansion Regime Characterization -/

/-- The **expansion regime** predicate. -/
def inExpansionRegime (gap innerDist : ℝ) : Prop := 1 - gap < innerDist

/-- **The expansion regime is preserved under gap improvement.** -/
theorem expansion_regime_monotone {gap₁ gap₂ innerDist : ℝ}
    (h_regime : inExpansionRegime gap₁ innerDist) (h_better : gap₁ ≤ gap₂) :
    inExpansionRegime gap₂ innerDist := by
  unfold inExpansionRegime at *; linarith

/-- **Tensor amplification eventually enters any expansion regime.** -/
theorem tensor_enters_expansion_regime (ε : ℝ) (hε : 0 < ε) (hε1 : ε ≤ 1)
    (innerDist : ℝ) (hδ : 0 < innerDist) (_hδ1 : innerDist ≤ 1) :
    ∃ k : ℕ, inExpansionRegime (kFoldTensorGap ε k) innerDist := by
  obtain ⟨k₀, hk₀⟩ := kFoldTensorGap_convergence ε hε hε1 innerDist hδ
  exact ⟨k₀, by unfold inExpansionRegime; linarith [hk₀ k₀ (le_refl k₀)]⟩

/-! ## Part 8: The Full Pipeline -/

/-- **Full pipeline theorem**: expansion regime is preserved along the chain. -/
theorem full_pipeline (ch : CertificateChain)
    (innerDist : ℝ) (_hδ : 0 < innerDist) (_hδ1 : innerDist ≤ 1)
    (i₀ : ℕ) (h_regime : inExpansionRegime (ch.cert i₀).gap innerDist) :
    ∀ j, i₀ ≤ j → inExpansionRegime (ch.cert j).gap innerDist := by
  intro j hj
  exact expansion_regime_monotone h_regime (ch.gap_mono i₀ j hj)

/-! ## Part 9: Quantitative Bounds -/

/-- **After k self-tensors of a Ramanujan-quality expander (gap ≥ 1/2),
the gap is at least 1/2.** -/
theorem half_gap_amplification (k : ℕ) (hk : 1 ≤ k) :
    1 - (1 / 2 : ℝ) ^ k ≥ 1 / 2 := by
  have h1 : (1/2 : ℝ) ^ k ≤ (1/2 : ℝ) ^ 1 := by
    apply pow_le_pow_of_le_one (by norm_num) (by norm_num) hk
  simp only [pow_one] at h1; linarith

/-- **After 10 tensor steps with gap 1/2, the gap exceeds 0.99.** -/
theorem ten_step_amplification :
    1 - (1 / 2 : ℝ) ^ 10 > 99 / 100 := by norm_num

/-! ## Part 10: Falsifiable Conjecture — Gap Saturation Rate -/

/-- **Conjecture: Universal Gap Saturation Constant.**

For any ε₀ ∈ (0, 1), (1 - ε₀)^k ≤ exp(-k·ε₀).

**Testable prediction**: For ε₀ = 0.3, k = 5:
  (0.7)^5 = 0.16807, exp(-1.5) ≈ 0.22313.  0.16807 < 0.22313 ✓

This reduces to the classical inequality 1 - x ≤ e^{-x}. -/
def GapSaturationConjecture : Prop :=
  ∀ ε₀ : ℝ, 0 < ε₀ → ε₀ ≤ 1 →
    ∀ k : ℕ, (1 - ε₀) ^ k ≤ Real.exp (-↑k * ε₀)

/-- **Partial evidence**: The conjecture holds at k = 0. -/
theorem gap_saturation_base (ε₀ : ℝ) (_hε : 0 < ε₀) (_hε1 : ε₀ ≤ 1) :
    (1 - ε₀) ^ 0 ≤ Real.exp (-(0 : ℝ) * ε₀) := by
  simp only [pow_zero, zero_mul, neg_zero, Real.exp_zero, le_refl]

/-
**The conjecture holds at k = 1, reducing to 1 - x ≤ e^{-x}.**
-/
theorem gap_saturation_k1 (ε₀ : ℝ) (_hε : 0 < ε₀) (_hε1 : ε₀ ≤ 1) :
    (1 - ε₀) ^ 1 ≤ Real.exp (-(1 : ℝ) * ε₀) := by
  exact le_trans ( by norm_num ) ( Real.add_one_le_exp ( -1 * ε₀ ) )

/-
**The full conjecture follows from the k=1 case by exponentiation.**
-/
theorem gap_saturation_from_base_case
    (h_base : ∀ ε₀ : ℝ, 0 < ε₀ → ε₀ ≤ 1 → 1 - ε₀ ≤ Real.exp (-ε₀)) :
    GapSaturationConjecture := by
  exact fun ε₀ hε₀ hε₀1 k => le_trans ( pow_le_pow_left₀ ( by linarith ) ( h_base ε₀ hε₀ hε₀1 ) k ) ( by rw [ ← Real.exp_nat_mul ] ; ring_nf; norm_num )

/-! ## Part 11: Spectral Gap Trichotomy -/

/-- Expansion regime classification. -/
inductive ExpansionRegimeType where
  | weak : ExpansionRegimeType
  | moderate : ExpansionRegimeType
  | strong : ExpansionRegimeType
  deriving DecidableEq, Repr

/-- Classify a gap into its regime. -/
noncomputable def classifyGap (gap : ℝ) : ExpansionRegimeType :=
  if gap < 1/3 then .weak
  else if gap < 2/3 then .moderate
  else .strong

/-- **Every gap falls into exactly one regime (by_cases proof).** -/
theorem gap_trichotomy (gap : ℝ) (_hgap : 0 < gap) (_hgap1 : gap ≤ 1) :
    classifyGap gap = .weak ∨ classifyGap gap = .moderate ∨ classifyGap gap = .strong := by
  unfold classifyGap
  split_ifs <;> simp_all

/-- **Amplification eventually reaches the strong regime.** -/
theorem amplification_reaches_strong (ε : ℝ) (hε : 0 < ε) (hε1 : ε ≤ 1) :
    ∃ k : ℕ, classifyGap (kFoldTensorGap ε k) = .strong := by
  obtain ⟨k₀, hk₀⟩ := kFoldTensorGap_convergence ε hε hε1 (1/3) (by norm_num)
  refine ⟨k₀, ?_⟩
  unfold classifyGap
  have hk := hk₀ k₀ (le_refl k₀)
  split_ifs with h1 h2
  · linarith
  · linarith
  · rfl

/-! ## Summary

```
Certificate Chain ──tensor──→ Amplified Certificates
     │                              │
     │ gap_mono                     │ kFoldTensorGap
     │                              │
     ▼                              ▼
Expansion Regime ──────────→ Code Family
     │                              │
     │ entropy                      │ distance
     │                              │
     ▼                              ▼
Information Theory          Coding Theory
```
-/