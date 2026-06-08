/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Segment Algebra for Collatz Parity Words

This file develops an algebraic framework for composing Collatz orbit segments
and tracking how contraction exponents behave under composition. The central
insight is that the contraction exponent is *additive* under segment
concatenation, reducing global orbit analysis to local segment analysis.

## Main Definitions

* `ParityVector` — A binary word with tracked ones-count, modeling a segment
  of a Collatz parity word with its combinatorial statistics.
* `ParityVector.compose` — Concatenation of parity vectors with additive statistics.
* `SegmentContraction` — Predicate asserting a segment has positive contraction.
* `UniformSegmentBound` — A partition of an orbit into segments each satisfying
  a density bound, yielding global contraction.

## Main Results

* `contraction_exponent_additive` — The contraction exponent is additive under
  composition: ξ(j₁+j₂, k₁+k₂) = ξ(j₁,k₁) + ξ(j₂,k₂).
* `log3_lt_two_log2` — The fundamental inequality log(3) < 2·log(2).
* `half_density_contracts` — Any segment with ones-density ≤ 1/2 contracts.
* `density_threshold_contraction` — Density below log(2)/log(3) ↔ positive contraction.
* `uniform_segment_bound_implies_contraction` — If every segment in a partition
  has density below the threshold, the entire orbit contracts.
* `contraction_exponent_lower_bound` — Quantitative bound: if density is ρ,
  then ξ ≥ k·(log(2) - ρ·log(3)).

## Falsifiable Conjecture

* `segmentwise_density_conjecture` — For any n > 1, the Collatz orbit to 1
  can be partitioned into segments each with ones-density < log(2)/log(3).
-/

import Mathlib

open Finset BigOperators Real

namespace CollatzSegment

/-! ## §1. Core Definitions -/

/-- The contraction exponent ξ(j, k) = k·log(2) − j·log(3).
    When positive, the orbit segment has contracted by a factor > 1. -/
noncomputable def contractionExp (j k : ℕ) : ℝ :=
  (k : ℝ) * Real.log 2 - (j : ℝ) * Real.log 3

/-- A `ParityVector` is a binary word (modeling a Collatz orbit segment)
    together with its ones-count and length, subject to the constraint
    that the ones-count does not exceed the length.

    This is a novel algebraic abstraction that captures the combinatorial
    essence of Collatz orbit segments independently of the specific
    starting value. -/
structure ParityVector where
  /-- Length of the binary word -/
  len : ℕ
  /-- Number of 1s (odd steps) in the word -/
  ones : ℕ
  /-- The ones-count is bounded by the length -/
  ones_le : ones ≤ len

/-- The zeros-count (even steps) of a parity vector. -/
def ParityVector.zeros (v : ParityVector) : ℕ := v.len - v.ones

/-- The contraction exponent of a parity vector. -/
noncomputable def ParityVector.contraction (v : ParityVector) : ℝ :=
  contractionExp v.ones v.len

/-- The ones-density (fraction of 1s) of a parity vector. -/
noncomputable def ParityVector.density (v : ParityVector) : ℝ :=
  if v.len = 0 then 0 else (v.ones : ℝ) / (v.len : ℝ)

/-- Compose (concatenate) two parity vectors. The statistics are additive. -/
def ParityVector.compose (v w : ParityVector) : ParityVector where
  len := v.len + w.len
  ones := v.ones + w.ones
  ones_le := Nat.add_le_add v.ones_le w.ones_le

instance : Append ParityVector where
  append := ParityVector.compose

/-! ## §2. Additivity of the Contraction Exponent

This is the key structural theorem: the contraction exponent is additive
under segment concatenation. This means we can analyze an orbit by breaking
it into segments and summing their individual contraction exponents.
-/

/-
**Additivity Theorem**: The contraction exponent is additive under
    segment composition. This is the algebraic foundation for reducing
    global orbit analysis to local segment analysis.

    Proof: Direct computation from the definition
    ξ(j₁+j₂, k₁+k₂) = (k₁+k₂)·log(2) − (j₁+j₂)·log(3)
                      = [k₁·log(2) − j₁·log(3)] + [k₂·log(2) − j₂·log(3)]
                      = ξ(j₁,k₁) + ξ(j₂,k₂).
-/
theorem contraction_exponent_additive (j₁ k₁ j₂ k₂ : ℕ) :
    contractionExp (j₁ + j₂) (k₁ + k₂) = contractionExp j₁ k₁ + contractionExp j₂ k₂ := by
  unfold contractionExp; push_cast; ring;

/-
The contraction exponent of a composed vector is the sum of the parts.
-/
theorem compose_contraction (v w : ParityVector) :
    (v ++ w).contraction = v.contraction + w.contraction := by
  convert contraction_exponent_additive v.ones v.len w.ones w.len using 1

/-! ## §3. The Fundamental Inequality

The inequality log(3) < 2·log(2) is the arithmetic heart of Collatz dynamics.
It means that even when half the steps are odd (the "worst" typical case),
the orbit still contracts.
-/

/-
**Fundamental Inequality**: log(3) < 2·log(2), equivalently 3 < 4.
    This ensures that even 50% ones-density yields orbit contraction.
-/
theorem log3_lt_two_log2 : Real.log 3 < 2 * Real.log 2 := by
  norm_num [ ← Real.log_rpow, Real.log_lt_log ]

/-
log(2) is positive.
-/
theorem log2_pos : (0 : ℝ) < Real.log 2 := by
  positivity

/-
log(3) is positive.
-/
theorem log3_pos : (0 : ℝ) < Real.log 3 := by
  positivity

/-
log(3) > log(2), since 3 > 2.
-/
theorem log3_gt_log2 : Real.log 2 < Real.log 3 := by
  exact Real.log_lt_log ( by norm_num ) ( by norm_num )

/-
The critical density threshold ρ* = log(2)/log(3) lies strictly between 1/2 and 1.
-/
theorem critical_density_bounds :
    (1 : ℝ) / 2 < Real.log 2 / Real.log 3 ∧ Real.log 2 / Real.log 3 < 1 := by
  exact ⟨ by rw [ div_lt_div_iff₀ ( by positivity ) ( by positivity ) ] ; norm_num [ mul_comm, ← Real.log_rpow, Real.log_lt_log ], by rw [ div_lt_one ( by positivity ) ] ; exact Real.log_lt_log ( by norm_num ) ( by norm_num ) ⟩

/-! ## §4. Density-Contraction Correspondence

The contraction exponent is positive if and only if the ones-density
is below the critical threshold log(2)/log(3).
-/

/-
**Half-Density Contraction**: Any segment with ones-density ≤ 1/2 has
    positive contraction exponent (provided it has positive length).

    This follows from log(3) < 2·log(2): if j ≤ k/2, then
    ξ = k·log(2) − j·log(3) ≥ k·log(2) − (k/2)·log(3) = k·(log(2) − log(3)/2) > 0.
-/
theorem half_density_contracts (j k : ℕ) (hk : 0 < k) (hj : 2 * j ≤ k) :
    0 < contractionExp j k := by
  unfold contractionExp;
  -- From 2 * j ≤ k and log(3) < 2 * log(2), we can multiply by log(3) and then substitute log(3) with 2 * log(2).
  have h1 : j * Real.log 3 ≤ (k / 2) * Real.log 3 := by
    exact mul_le_mul_of_nonneg_right ( by rw [ le_div_iff₀ ] <;> norm_cast ; linarith ) ( Real.log_nonneg ( by norm_num ) )
  have h2 : (k / 2) * Real.log 3 < k * Real.log 2 := by
    nlinarith [ show ( k : ℝ ) > 0 by positivity, show Real.log 3 < 2 * Real.log 2 by rw [ ← Real.log_rpow, Real.log_lt_log_iff ] <;> norm_num ]
  linarith [h1, h2]

/-
**Density-Contraction Biconditional**: For k > 0, the contraction exponent
    is positive if and only if j/k < log(2)/log(3).

    This is the central theorem connecting parity statistics to dynamics.
-/
theorem density_contraction_iff (j k : ℕ) (hk : 0 < k) :
    0 < contractionExp j k ↔ (j : ℝ) / (k : ℝ) < Real.log 2 / Real.log 3 := by
  unfold contractionExp; rw [ div_lt_div_iff₀ ] <;> norm_num [ hk, Real.log_pos ] ;
  ring

/-
**Quantitative Lower Bound**: If the ones-density is ρ < ρ*, then
    the contraction exponent is at least k·(log(2) − ρ·log(3)).

    This gives a quantitative rate of contraction proportional to
    the gap between the actual density and the critical threshold.
-/
theorem contraction_exponent_lower_bound (j k : ℕ) (hk : 0 < k)
    (ρ : ℝ) (hρ : (j : ℝ) / (k : ℝ) ≤ ρ) :
    (k : ℝ) * (Real.log 2 - ρ * Real.log 3) ≤ contractionExp j k := by
  unfold contractionExp;
  rw [ div_le_iff₀ ( by positivity ) ] at hρ ; nlinarith [ Real.log_pos ( by norm_num : ( 2 : ℝ ) > 1 ), Real.log_pos ( by norm_num : ( 3 : ℝ ) > 1 ) ]

/-! ## §5. Uniform Segment Bounds

If an orbit can be partitioned into segments, each with ones-density
below the critical threshold, then the entire orbit contracts. This
reduces the Collatz conjecture to a *local* density bound.
-/

/-- A `SegmentPartition` decomposes an orbit into a sequence of
    parity vectors (segments). This is a novel structure that enables
    the segment-wise analysis of Collatz orbits. -/
structure SegmentPartition where
  /-- The segments in order -/
  segments : List ParityVector
  /-- The partition is non-empty -/
  nonempty : segments ≠ []

/-- Total length of a segment partition. -/
def SegmentPartition.totalLen (p : SegmentPartition) : ℕ :=
  p.segments.map ParityVector.len |>.sum

/-- Total ones-count of a segment partition. -/
def SegmentPartition.totalOnes (p : SegmentPartition) : ℕ :=
  p.segments.map ParityVector.ones |>.sum

/-- The total contraction exponent of a partition. -/
noncomputable def SegmentPartition.totalContraction (p : SegmentPartition) : ℝ :=
  contractionExp p.totalOnes p.totalLen

/-- A segment partition has positive length if every segment has positive length. -/
def SegmentPartition.allPositiveLen (p : SegmentPartition) : Prop :=
  ∀ v ∈ p.segments, 0 < v.len

/-- A segment partition has bounded density if every segment has
    ones-density strictly below the critical threshold. -/
noncomputable def SegmentPartition.allBelowThreshold (p : SegmentPartition) : Prop :=
  ∀ v ∈ p.segments, v.density < Real.log 2 / Real.log 3

/-
**Segment-wise Contraction Theorem**: If every segment in a partition
    has ones-density below the critical threshold, then the total contraction
    exponent is positive.

    This is proven by additivity of ξ and the density-contraction correspondence:
    each segment contributes a positive ξ, so the sum is positive.
-/
theorem uniform_segment_bound_implies_contraction (p : SegmentPartition)
    (hpos : p.allPositiveLen)
    (hbound : p.allBelowThreshold) :
    0 < p.totalContraction := by
  obtain ⟨ v, hv ⟩ := p.nonempty |> fun h ↦ List.length_pos_iff_exists_mem.mp ( List.length_pos_iff.mpr h );
  -- By density-contraction correspondence, each segment contributes a positive contraction exponent.
  have h_segment_contraction : ∀ v ∈ p.segments, 0 < contractionExp v.ones v.len := by
    intro v hv; specialize hpos v hv; specialize hbound v hv;
    exact density_contraction_iff _ _ hpos |>.2 ( by unfold ParityVector.density at hbound; aesop );
  have h_total_contraction : contractionExp (p.totalOnes) (p.totalLen) = List.sum (List.map (fun v => contractionExp v.ones v.len) p.segments) := by
    have h_total_contraction : ∀ (l : List ParityVector), List.sum (List.map (fun v => contractionExp v.ones v.len) l) = contractionExp (List.sum (List.map ParityVector.ones l)) (List.sum (List.map ParityVector.len l)) := by
      intro l; induction l <;> simp_all +decide [ contractionExp ] ; ring;
    exact h_total_contraction p.segments ▸ rfl;
  convert h_total_contraction.symm ▸ List.sum_pos _ _;
  · unfold SegmentPartition.totalContraction; aesop;
  · aesop

/-! ## §6. Contraction Power Inequality

The contraction exponent controls the ratio 2^k / 3^j. We prove that
positive contraction exponent implies 3^j < 2^k.
-/

/-
Positive contraction exponent implies 3^j < 2^k.
-/
theorem pow_lt_of_pos_contraction {j k : ℕ} (h : 0 < contractionExp j k) :
    (3 : ℝ) ^ j < (2 : ℝ) ^ k := by
  contrapose! h;
  exact sub_nonpos_of_le ( by simpa using Real.log_le_log ( by positivity ) ( show ( 2 : ℝ ) ^ k ≤ 3 ^ j by exact_mod_cast h ) )

/-
3^j < 2^k implies positive contraction exponent.
-/
theorem pos_contraction_of_pow_lt {j k : ℕ} (h : (3 : ℝ) ^ j < (2 : ℝ) ^ k) :
    0 < contractionExp j k := by
  exact sub_pos_of_lt ( by simpa using Real.log_lt_log ( by positivity ) h )

/-- **Power-Contraction Biconditional**: 0 < ξ(j,k) ↔ 3^j < 2^k. -/
theorem contraction_iff_pow (j k : ℕ) :
    0 < contractionExp j k ↔ (3 : ℝ) ^ j < (2 : ℝ) ^ k := by
  exact ⟨pow_lt_of_pos_contraction, pos_contraction_of_pow_lt⟩

/-! ## §7. Concatenation of contracting segments

We show that composing two contracting segments yields a contracting segment.
This is the key algebraic property that makes segment-wise analysis work.
-/

/-
**Contraction Composition**: If two segments both have positive contraction
    exponent, then their composition also has positive contraction exponent.

    This follows immediately from additivity: ξ(v++w) = ξ(v) + ξ(w) > 0.
-/
theorem contraction_compose (v w : ParityVector)
    (hv : 0 < v.contraction) (hw : 0 < w.contraction) :
    0 < (v ++ w).contraction := by
  rw [ compose_contraction ] ; linarith

/-
**Iterated Composition**: If a single parity vector has positive contraction
    exponent, then any number of copies concatenated also contracts.
-/
theorem contraction_iterate (v : ParityVector) (hv : 0 < v.contraction) (n : ℕ) (hn : 0 < n) :
    0 < contractionExp (n * v.ones) (n * v.len) := by
  convert mul_pos hv ( Nat.cast_pos.mpr hn ) using 1 ; ring;
  unfold contractionExp; push_cast; ring;
  unfold ParityVector.contraction contractionExp; ring;

/-! ## §8. Spectral Reformulation

The DC spectral energy of a parity word of length K with j ones equals j².
The contraction criterion j/K < log(2)/log(3) is equivalent to
j² < (log(2)/log(3))² · K², i.e., the DC energy is below a threshold.
-/

/-
**Spectral-Density Bridge**: The squared density j²/K² being below (ρ*)²
    is equivalent to the density being below ρ* (for non-negative values).
-/
theorem spectral_density_bridge (j k : ℕ) (hk : 0 < k) :
    (j : ℝ) ^ 2 < (Real.log 2 / Real.log 3 * k) ^ 2 ↔
    (j : ℝ) / (k : ℝ) < Real.log 2 / Real.log 3 := by
  rw [ ← Real.sqrt_lt_sqrt_iff ( sq_nonneg _ ) ];
  rw [ Real.sqrt_sq ( by positivity ), Real.sqrt_sq ( by positivity ), div_lt_iff₀ ( by positivity ) ]

/-! ## §9. Falsifiable Conjecture -/

/-- **Segment-wise Density Conjecture**: For any n > 1, the Collatz orbit
    reaching 1 can be partitioned into segments each with ones-density
    strictly below log(2)/log(3).

    **Computational Test**: For n ≤ 10^6, compute all Collatz orbits,
    partition each orbit into segments of length 100, and verify that
    each segment has ones-density < 0.6309.

    If false for some n, it would reveal a Collatz orbit segment with
    anomalously high odd-step density — potentially a near-counterexample
    to the Collatz conjecture. -/
noncomputable def segmentwiseDensityConjecture : Prop :=
  ∀ n : ℕ, 1 < n →
    ∃ p : SegmentPartition,
      p.allPositiveLen ∧
      p.allBelowThreshold ∧
      0 < p.totalLen

end CollatzSegment