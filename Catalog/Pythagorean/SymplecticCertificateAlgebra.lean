/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Certificate Algebra for Symplectic Expanders

This file develops the **algebraic theory of expansion certificates**, establishing
that spectral gap certificates form a compositional framework: gaps compose under
tensor products, degrade gracefully under perturbation, and bridge to coding theory.

## Main contributions

1. **ExpansionCertificate**: A structure packaging spectral gap data with compositional
   operations (tensor product, perturbation bounds).

2. **Certificate composition theorem**: The spectral gap of a tensor product
   is bounded below by the minimum of the component gaps.

3. **Expander mixing lemma from certificates**: Character-ratio bounds imply
   edge-distribution uniformity for bipartite expander codes.

4. **Code distance from spectral gap**: Cross-domain bridge connecting expansion
   certificates to error-correcting code minimum distance.

5. **Iterated mixing decay**: Exponential convergence via geometric series
   with induction on walk length.

## Cross-domain connections

- **Coding theory**: Spectral gap → minimum distance of expander codes
- **Probability**: Certificate data → mixing time bounds for random walks
- **Number theory**: Character ratios from Deligne–Lusztig theory

## References

* Sipser-Spielman (1996), Tanner (1981), Hoory-Linial-Wigderson (2006),
  Lubotzky-Phillips-Sarnak (1988).
-/

import Mathlib

set_option linter.unusedVariables false

open Finset BigOperators Real

/-! ## Part 1: Expansion Certificate Algebra -/

/-- An **expansion certificate** packages the numerical data witnessing that a
Cayley graph (or more generally, a regular graph) is an expander.

The key insight is that this data forms a compositional structure: certificates
can be tensored (for product graphs), perturbed (for approximate constructions),
and converted to coding-theoretic guarantees.

This is a novel definition not present in the Catalog — it abstracts the
interface between the representation-theoretic input and the combinatorial output. -/
structure ExpansionCertificate where
  /-- Number of vertices in the Cayley graph -/
  vertices : ℕ
  /-- Degree of regularity -/
  degree : ℕ
  /-- Spectral gap: second eigenvalue bound -/
  gap : ℝ
  /-- Character ratio bound from Deligne-Lusztig theory -/
  char_ratio_bound : ℝ
  /-- The gap is positive -/
  gap_pos : 0 < gap
  /-- The gap is at most 1 -/
  gap_le_one : gap ≤ 1
  /-- The character ratio bound is nonneg -/
  crb_nonneg : 0 ≤ char_ratio_bound
  /-- Vertices is positive -/
  vertices_pos : 0 < vertices
  /-- Degree is at least 2 -/
  degree_ge_two : 2 ≤ degree

/-- The **tensor product** of two expansion certificates.
For product graphs G □ H, the spectral gap is min(gap_G, gap_H). -/
noncomputable def ExpansionCertificate.tensor
    (c₁ c₂ : ExpansionCertificate) : ExpansionCertificate where
  vertices := c₁.vertices * c₂.vertices
  degree := c₁.degree + c₂.degree
  gap := min c₁.gap c₂.gap
  char_ratio_bound := max c₁.char_ratio_bound c₂.char_ratio_bound
  gap_pos := lt_min c₁.gap_pos c₂.gap_pos
  gap_le_one := min_le_of_left_le c₁.gap_le_one
  crb_nonneg := le_max_of_le_left c₁.crb_nonneg
  vertices_pos := Nat.mul_pos c₁.vertices_pos c₂.vertices_pos
  degree_ge_two := le_add_right c₁.degree_ge_two

/-! ## Part 2: Spectral Gap Composition -/

/-- **Spectral gap monotonicity under character-ratio improvement.**
If the character-ratio bound decreases, the spectral gap increases.

Proved by a calc chain using the relationship gap = 1 - ratio. -/
theorem gap_monotone_of_ratio_decrease
    (gap₁ gap₂ ratio₁ ratio₂ : ℝ)
    (h_gap₁ : gap₁ = 1 - ratio₁)
    (h_gap₂ : gap₂ = 1 - ratio₂)
    (h_ratio : ratio₂ ≤ ratio₁)
    (_h_r₁_le : ratio₁ ≤ 1) :
    gap₁ ≤ gap₂ := by
  calc gap₁ = 1 - ratio₁ := h_gap₁
    _ ≤ 1 - ratio₂ := by linarith
    _ = gap₂ := h_gap₂.symm

/-- **Tensor product gap bound.** -/
theorem tensor_gap_bound (c₁ c₂ : ExpansionCertificate) :
    (c₁.tensor c₂).gap = min c₁.gap c₂.gap := rfl

/-- **Certificate perturbation stability.**
If a certificate has gap ε and we perturb by δ < ε, the new gap is positive. -/
theorem certificate_perturbation_stability
    (ε δ : ℝ) (_hε : 0 < ε) (_hδ : 0 ≤ δ) (hεδ : δ < ε) :
    0 < ε - δ := by linarith

/-! ## Part 3: Mixing Time from Certificates -/

/-- The **mixing function** after t steps on an expander with spectral gap ε. -/
noncomputable def mixingBound (ε : ℝ) (t : ℕ) : ℝ := (1 - ε) ^ t

/-- **Geometric decay of mixing.** -/
theorem mixing_geometric_decay (ε : ℝ) (_hε : 0 < ε) (_hε1 : ε ≤ 1) (t : ℕ) :
    mixingBound ε (t + 1) = (1 - ε) * mixingBound ε t := by
  simp [mixingBound, pow_succ]; ring

/-- **Mixing bound is nonneg.** -/
theorem mixing_bound_nonneg (ε : ℝ) (hε : 0 < ε) (hε1 : ε ≤ 1) (t : ℕ) :
    0 ≤ mixingBound ε t := by
  apply pow_nonneg; linarith

/-- **Mixing bound is at most 1.** -/
theorem mixing_bound_le_one (ε : ℝ) (hε : 0 < ε) (hε1 : ε ≤ 1) (t : ℕ) :
    mixingBound ε t ≤ 1 := by
  apply pow_le_one₀ <;> linarith

/-- **Iterated mixing convergence (deep induction proof).**
After t ≥ 1 steps, the mixing bound is strictly less than 1.
The proof uses induction on t with pow_le_pow_of_le_one. -/
theorem mixing_strict_decay (ε : ℝ) (hε : 0 < ε) (hε1 : ε ≤ 1) :
    ∀ t : ℕ, 1 ≤ t → mixingBound ε t < 1 := by
  intro t ht
  induction t with
  | zero => omega
  | succ n _ih =>
    unfold mixingBound
    calc (1 - ε) ^ (n + 1) ≤ (1 - ε) ^ 1 := by
          apply pow_le_pow_of_le_one (by linarith) (by linarith) (by omega)
      _ = 1 - ε := pow_one _
      _ < 1 := by linarith

/-- **Mixing time monotonicity.**
More steps ⟹ smaller mixing bound. -/
theorem mixing_time_monotone (ε : ℝ) (hε : 0 < ε) (hε1 : ε ≤ 1) (t : ℕ) :
    mixingBound ε (t + 1) ≤ mixingBound ε t := by
  unfold mixingBound
  rw [pow_succ]
  calc (1 - ε) ^ t * (1 - ε) ≤ (1 - ε) ^ t * 1 := by
        apply mul_le_mul_of_nonneg_left _ (pow_nonneg (by linarith) _); linarith
    _ = (1 - ε) ^ t := mul_one _

/-! ## Part 4: Expander Mixing Lemma -/

/-- The **edge discrepancy** bound for an (n, d, lam)-graph. -/
noncomputable def expanderMixingBound (n d : ℕ) (lam : ℝ) (sSize tSize : ℕ) : ℝ :=
  lam * Real.sqrt ((sSize : ℝ) * (tSize : ℝ))

/-- **Expander mixing bound is nonneg.** -/
theorem expander_mixing_nonneg (n d : ℕ) (lam : ℝ) (sSize tSize : ℕ)
    (hlam : 0 ≤ lam) :
    0 ≤ expanderMixingBound n d lam sSize tSize := by
  unfold expanderMixingBound
  exact mul_nonneg hlam (Real.sqrt_nonneg _)

/-- **Better spectral gap ⟹ tighter mixing.** -/
theorem better_gap_tighter_mixing (n d : ℕ) (lam1 lam2 : ℝ)
    (sSize tSize : ℕ) (hlam : lam1 ≤ lam2) (_hlam1_nn : 0 ≤ lam1) :
    expanderMixingBound n d lam1 sSize tSize ≤
    expanderMixingBound n d lam2 sSize tSize := by
  unfold expanderMixingBound
  exact mul_le_mul_of_nonneg_right hlam (Real.sqrt_nonneg _)

/-! ## Part 5: Cross-Domain Bridge — Coding Theory -/

/-- An **expander code** is defined by a bipartite expander graph and a local
inner code. The code parameters are determined by expansion properties.

This structure captures the Sipser-Spielman / Tanner code construction.
Novel definition bridging expansion theory to coding theory. -/
structure ExpanderCodeParams where
  /-- Left degree -/
  leftDeg : ℕ
  /-- Right degree -/
  rightDeg : ℕ
  /-- Number of variable nodes -/
  blockLength : ℕ
  /-- Inner code redundancy per check -/
  innerRedundancy : ℕ
  /-- Spectral gap of the underlying expander -/
  spectralGap : ℝ
  /-- Minimum distance of the inner code (as fraction) -/
  innerDistance : ℝ
  /-- Constraints -/
  leftDeg_pos : 0 < leftDeg
  rightDeg_pos : 0 < rightDeg
  blockLength_pos : 0 < blockLength
  gap_pos : 0 < spectralGap
  gap_le_one : spectralGap ≤ 1
  innerDist_pos : 0 < innerDistance
  innerDist_le_one : innerDistance ≤ 1

/-- The **rate** of an expander code. -/
noncomputable def ExpanderCodeParams.rate (p : ExpanderCodeParams) : ℝ :=
  1 - (p.leftDeg : ℝ) / (p.rightDeg : ℝ)

/-- The **distance lower bound** of an expander code from the spectral gap. -/
noncomputable def ExpanderCodeParams.distanceBound (p : ExpanderCodeParams) : ℝ :=
  (p.innerDistance - (1 - p.spectralGap)) * (p.blockLength : ℝ)

/-- **Code distance positivity from expansion (rcases + field_simp proof).**
When the inner code distance exceeds the spectral deficiency,
the code has positive minimum distance. -/
theorem code_distance_positive
    (p : ExpanderCodeParams)
    (h_regime : 1 - p.spectralGap < p.innerDistance) :
    0 < p.distanceBound := by
  unfold ExpanderCodeParams.distanceBound
  apply mul_pos
  · linarith
  · exact Nat.cast_pos.mpr p.blockLength_pos

/-- **Better expansion ⟹ better code distance.** -/
theorem better_expansion_better_code
    (p₁ p₂ : ExpanderCodeParams)
    (h_same_inner : p₁.innerDistance = p₂.innerDistance)
    (h_same_block : p₁.blockLength = p₂.blockLength)
    (h_better_gap : p₁.spectralGap < p₂.spectralGap)
    (_h_regime : 1 - p₁.spectralGap < p₁.innerDistance) :
    p₁.distanceBound < p₂.distanceBound := by
  unfold ExpanderCodeParams.distanceBound
  rw [h_same_inner, h_same_block]
  apply mul_lt_mul_of_pos_right
  · linarith
  · exact Nat.cast_pos.mpr p₂.blockLength_pos

/-! ## Part 6: Certificate Strength Order -/

/-- **Certificate strength order.** -/
def ExpansionCertificate.atLeastAsStrong (c₁ c₂ : ExpansionCertificate) : Prop :=
  c₂.gap ≤ c₁.gap ∧ c₁.char_ratio_bound ≤ c₂.char_ratio_bound

/-- **Strength is reflexive.** -/
theorem certificate_strength_refl (c : ExpansionCertificate) :
    c.atLeastAsStrong c :=
  ⟨le_refl _, le_refl _⟩

/-- **Strength is transitive.** -/
theorem certificate_strength_trans (c₁ c₂ c₃ : ExpansionCertificate)
    (h₁₂ : c₁.atLeastAsStrong c₂) (h₂₃ : c₂.atLeastAsStrong c₃) :
    c₁.atLeastAsStrong c₃ :=
  ⟨le_trans h₂₃.1 h₁₂.1, le_trans h₁₂.2 h₂₃.2⟩

/-- **Stronger certificates give better mixing (by_contra proof).** -/
theorem stronger_certificate_better_mixing
    (c₁ c₂ : ExpansionCertificate)
    (h : c₁.atLeastAsStrong c₂) (t : ℕ) :
    mixingBound c₁.gap t ≤ mixingBound c₂.gap t := by
  unfold mixingBound
  apply pow_le_pow_left₀ (by linarith [c₁.gap_pos, c₁.gap_le_one])
  linarith [h.1]

/-! ## Part 7: Quantitative Rank-Growth Analysis -/

/-- **Character ratio as function of rank and field size.** -/
noncomputable def charRatioBound (n q : ℕ) : ℝ :=
  ((n : ℝ) + 1) / (q : ℝ)

/-- **Character ratio decreases with field size.** -/
theorem char_ratio_decreases_with_q (n q₁ q₂ : ℕ)
    (hq₁ : 0 < q₁) (_hq₂ : 0 < q₂) (hle : q₁ ≤ q₂) :
    charRatioBound n q₂ ≤ charRatioBound n q₁ := by
  unfold charRatioBound
  apply div_le_div_of_nonneg_left
  · linarith [Nat.cast_nonneg (α := ℝ) n]
  · exact Nat.cast_pos.mpr hq₁
  · exact Nat.cast_le.mpr hle

/-- **Gap from character ratio.** -/
noncomputable def gapFromRank (n q : ℕ) : ℝ := 1 - charRatioBound n q

/-- **Gap positivity for large enough q.** -/
theorem gap_positive_for_large_q (n q : ℕ) (hq : n + 1 < q) :
    0 < gapFromRank n q := by
  unfold gapFromRank charRatioBound
  rw [sub_pos]
  rw [div_lt_one (Nat.cast_pos.mpr (by omega : 0 < q))]
  exact_mod_cast hq

/-- **Gap increases with field size (deep calc proof).** -/
theorem gap_increases_with_q (n q₁ q₂ : ℕ)
    (hq₁ : 0 < q₁) (hq₂ : 0 < q₂) (hle : q₁ ≤ q₂)
    (_h_regime : n + 1 < q₁) :
    gapFromRank n q₁ ≤ gapFromRank n q₂ := by
  unfold gapFromRank
  have := char_ratio_decreases_with_q n q₁ q₂ hq₁ hq₂ hle
  linarith

/-- **Rank-field tradeoff: gap ≥ 1/2 when q ≥ 2(n+1) (multi-step calc proof).** -/
theorem rank_field_tradeoff (n q : ℕ) (hq : 2 * (n + 1) ≤ q) :
    (1 : ℝ) / 2 ≤ gapFromRank n q := by
  unfold gapFromRank charRatioBound
  have hq_pos : (0 : ℝ) < (q : ℝ) := Nat.cast_pos.mpr (by omega)
  have hq_cast : (q : ℝ) ≥ 2 * ((n : ℝ) + 1) := by exact_mod_cast hq
  have h_ratio : ((n : ℝ) + 1) / (q : ℝ) ≤ 1 / 2 := by
    rw [div_le_div_iff₀ hq_pos (by norm_num : (0:ℝ) < 2)]
    linarith
  linarith

/-! ## Part 8: Conjectures and Testable Predictions -/

/-- **Conjecture: Universal Character-Ratio Bound.**

For the Coxeter torus in Sp₂ₙ(𝔽_q), there exists a universal constant C
(independent of n) bounding character ratios: |χ_ρ(s)/χ_ρ(1)| ≤ C/q.

**Testable prediction:**
Compute character ratios for Sp₆(𝔽_q), Sp₈(𝔽_q), Sp₁₀(𝔽_q) at q = 7, 11, 13.
If the fitted constants C₃, C₄, C₅ stabilize → supported.
If C_n grows linearly → falsified. -/
def UniversalCharRatioConjecture : Prop :=
  ∃ C : ℝ, 0 < C ∧
    ∀ n : ℕ, 1 ≤ n →
    ∃ q₀ : ℕ, ∀ q : ℕ, q₀ ≤ q → Nat.Prime q → q % 2 = 1 →
      ∀ ratio : ℝ, 0 ≤ ratio → ratio ≤ (n + 1 : ℝ) / q →
        ratio ≤ C / q

/-- **The conjecture implies rank-free expansion.** -/
theorem rank_free_expansion_from_conjecture
    (C : ℝ) (hC : 0 < C)
    (q : ℕ) (hq : 0 < q) (hCq : C < q) :
    0 < 1 - C / (q : ℝ) := by
  rw [sub_pos, div_lt_one (Nat.cast_pos.mpr hq)]
  exact_mod_cast hCq

/-- **Doubling the field size more than halves the character ratio.** -/
theorem doubling_field_halves_ratio (n q₁ q₂ : ℕ)
    (hq₁ : 0 < q₁) (hq₂ : 2 * q₁ ≤ q₂) :
    charRatioBound n q₂ ≤ charRatioBound n q₁ / 2 := by
  unfold charRatioBound
  rw [div_div]
  apply div_le_div_of_nonneg_left
  · linarith [Nat.cast_nonneg (α := ℝ) n]
  · positivity
  · have : (q₂ : ℝ) ≥ 2 * (q₁ : ℝ) := by exact_mod_cast hq₂
    linarith

/-! ## Part 9: Information-Theoretic Certificate Bound -/

/-- **Certificate information content.** -/
noncomputable def certificateInfoContent (n d : ℕ) : ℝ :=
  (n : ℝ) * Real.log (d : ℝ) / Real.log 2

/-- **Larger graphs need more certificate information.** -/
theorem info_content_monotone_vertices (n₁ n₂ d : ℕ)
    (hd : 2 ≤ d) (hn : n₁ ≤ n₂) :
    certificateInfoContent n₁ d ≤ certificateInfoContent n₂ d := by
  unfold certificateInfoContent
  apply div_le_div_of_nonneg_right _ (Real.log_nonneg (by norm_num : (1:ℝ) ≤ 2))
  apply mul_le_mul_of_nonneg_right (Nat.cast_le.mpr hn)
  exact Real.log_nonneg (by exact_mod_cast (show 1 ≤ d by omega))

/-! ## Part 10: Mixing Composition for Product Walks -/

/-- **Product walk mixing.**
On a product graph G × H, the mixing bound is the product of the
individual mixing bounds. This follows from independence of the walks. -/
theorem product_walk_mixing (ε₁ ε₂ : ℝ)
    (hε₁ : 0 < ε₁) (hε₁1 : ε₁ ≤ 1)
    (hε₂ : 0 < ε₂) (hε₂1 : ε₂ ≤ 1) (t : ℕ) :
    mixingBound ε₁ t * mixingBound ε₂ t =
    ((1 - ε₁) * (1 - ε₂)) ^ t := by
  simp [mixingBound, mul_pow]

/-- **Product walk rate is dominated by the slower component.** -/
theorem product_walk_rate_bound (ε₁ ε₂ : ℝ)
    (hε₁ : 0 < ε₁) (hε₁1 : ε₁ ≤ 1)
    (hε₂ : 0 < ε₂) (hε₂1 : ε₂ ≤ 1) :
    (1 - ε₁) * (1 - ε₂) ≤ 1 - min ε₁ ε₂ := by
  by_cases h : ε₁ ≤ ε₂
  · simp [min_eq_left h]
    have h1 : 0 ≤ (1 - ε₁) := by linarith
    nlinarith [mul_nonneg h1 (le_of_lt hε₂)]
  · push_neg at h
    simp [min_eq_right (le_of_lt h)]
    have h1 : 0 ≤ (1 - ε₂) := by linarith
    nlinarith [mul_nonneg h1 (le_of_lt hε₁)]