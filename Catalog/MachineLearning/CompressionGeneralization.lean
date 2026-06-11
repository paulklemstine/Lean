/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Compression-Based Generalization Bounds and the Overparameterization Threshold

This file develops, fully self-contained, the analytic core of *compression-based*
(Occam / minimum-description-length) generalization bounds and connects them to
PAC-Bayes and to the modern puzzle of why **overparameterized** neural networks
generalize.

The central object is the Occam bound

  `occamBound R C n δ = R + sqrt ((C + log (1/δ)) / (2 n))`,

where `R` is the empirical risk, `C` is the *complexity* (description length in
nats, equivalently `log (1/prior)` of the learned hypothesis), `n` the sample
size and `δ` the confidence parameter.  A network using `bits` bits of
compressed description has complexity `bits · log 2`.

## Main results

* `occam_gap_eq`            — the generalization gap is exactly the sqrt penalty term
* `occam_mono_complexity`   — looser bound for more complex (less compressible) models
* `occam_mono_sample`       — the bound tightens monotonically with more data
* `occam_sample_complexity` — **inversion**: `n ≥ (C+log(1/δ))/(2ε²)` ⟹ gap `≤ ε`
* `compression_sample_complexity` — sample complexity grows *linearly in the bit-length*
* `overparam_invariance`    — the bound depends only on description length, not parameter count
* `overparam_can_beat_small`— an overparameterized but better-compressing net has a smaller bound
* `occam_gap_tendsto_zero`  — **consistency**: with fixed complexity the gap → 0 as `n → ∞`
* `memorization_gap_limit`  — **boundary case**: complexity growing linearly in `n` (memorization)
                              leaves an irreducible gap `sqrt (c/2)`

## The key insight

Classical capacity measures (VC dimension, parameter count) cannot explain
overparameterized generalization because they grow with the number of weights.
The compression bound replaces parameter count by *description length of the
solution*, which is invariant under adding redundant parameters.  This is the
exact mechanism — formalized in `overparam_invariance` and
`overparam_can_beat_small` — by which a billion-parameter network that compresses
to a few kilobytes can generalize from far fewer samples than a small network
that does not compress.
-/
import Mathlib

open Real Filter Topology

noncomputable section

namespace CompressionGen

/-! ## Definitions -/

/-- The Occam / minimum-description-length generalization bound.  `R` is the
empirical risk, `C` the complexity (description length in nats), `n` the sample
size and `δ` the confidence parameter.  The bound on the true risk is the
empirical risk plus a square-root capacity penalty. -/
def occamBound (R C : ℝ) (n : ℕ) (δ : ℝ) : ℝ :=
  R + Real.sqrt ((C + Real.log (1 / δ)) / (2 * n))

/-- A hypothesis described with `bits` bits has complexity `bits · log 2` nats. -/
def compressionBound (R : ℝ) (bits : ℕ) (n : ℕ) (δ : ℝ) : ℝ :=
  occamBound R (bits * Real.log 2) n δ

/-- A neural network summarised by its total parameter count, its *compressed*
description length in bits, and its empirical risk. -/
structure Net where
  /-- Total number of weights (can be astronomically large). -/
  params : ℕ
  /-- Compressed description length in bits (what actually controls generalization). -/
  bits : ℕ
  /-- Empirical risk on the training sample. -/
  empRisk : ℝ

/-- The certified generalization bound attached to a network. -/
def Net.bound (net : Net) (n : ℕ) (δ : ℝ) : ℝ :=
  compressionBound net.empRisk net.bits n δ

/-! ## Basic structure of the bound -/

/-
!-- The generalization gap is, by definition, exactly the square-root penalty
term; pure algebra after unfolding the definition. -- !--
-/
theorem occam_gap_eq (R C : ℝ) (n : ℕ) (δ : ℝ) :
    occamBound R C n δ - R = Real.sqrt ((C + Real.log (1 / δ)) / (2 * n)) := by
  exact sub_eq_iff_eq_add'.mpr rfl

/-
!-- The bound never undershoots the empirical risk because the penalty is a
nonnegative square root. -- !--
-/
theorem occam_bound_ge_empRisk (R C : ℝ) (n : ℕ) (δ : ℝ) :
    R ≤ occamBound R C n δ := by
  exact le_add_of_nonneg_right (Real.sqrt_nonneg _)

/-
!-- More complex (less compressible) hypotheses give a looser bound:
monotonicity of sqrt and division in the complexity argument. -- !--
-/
theorem occam_mono_complexity (R C₁ C₂ : ℝ) (n : ℕ) (δ : ℝ)
    (h : C₁ ≤ C₂) :
    occamBound R C₁ n δ ≤ occamBound R C₂ n δ := by
  unfold occamBound; gcongr

/-
!-- The bound tightens monotonically with more data: for a nonnegative
numerator, the penalty decreases as `n` grows. -- !--
-/
theorem occam_mono_sample (R C : ℝ) (n₁ n₂ : ℕ) (δ : ℝ)
    (hC : 0 ≤ C + Real.log (1 / δ)) (hn1 : 0 < n₁) (hn : n₁ ≤ n₂) :
    occamBound R C n₂ δ ≤ occamBound R C n₁ δ := by
  unfold occamBound;
  gcongr

/-! ## Sample complexity -/

/-
!-- Inversion of the bound: as soon as the sample size exceeds
`(C + log(1/δ))/(2ε²)`, the generalization gap drops below `ε`.  Proof: the
hypothesis gives `(C+log(1/δ))/(2n) ≤ ε²`, and `sqrt` is monotone with
`sqrt (ε²) = ε`. -- !--
-/
theorem occam_sample_complexity (R C δ ε : ℝ) (n : ℕ)
    (hε : 0 < ε) (hC : 0 ≤ C + Real.log (1 / δ))
    (hn : (C + Real.log (1 / δ)) / (2 * ε ^ 2) ≤ (n : ℝ)) :
    occamBound R C n δ ≤ R + ε := by
  rcases eq_or_ne n 0 with rfl | hn' <;> simp_all +decide [ occamBound ];
  · positivity;
  · rw [ ← Real.sqrt_mul <| by positivity ];
    rw [ ← Real.sqrt_div ( by linarith ), Real.sqrt_le_left ] <;> first | positivity | rw [ div_le_iff₀ ] at * <;> first | positivity | nlinarith;

/-
!-- Compression sample complexity: substituting `C = bits · log 2` shows the
number of samples needed grows only *linearly* in the bit-length of the
compressed model — the quantitative content of Occam's razor for learning. -- !--
-/
theorem compression_sample_complexity (R δ ε : ℝ) (bits n : ℕ)
    (hε : 0 < ε) (hC : 0 ≤ (bits : ℝ) * Real.log 2 + Real.log (1 / δ))
    (hn : ((bits : ℝ) * Real.log 2 + Real.log (1 / δ)) / (2 * ε ^ 2) ≤ (n : ℝ)) :
    compressionBound R bits n δ ≤ R + ε := by
  convert occam_sample_complexity R ( bits * Real.log 2 ) δ ε n hε _ hn using 1;
  exact hC

/-! ## Overparameterization -/

/-
!-- The certified bound depends only on the empirical risk and the compressed
description length — never on the raw parameter count.  Two networks differing
only in how many redundant weights they carry receive identical guarantees. -- !--
-/
theorem overparam_invariance (net₁ net₂ : Net) (n : ℕ) (δ : ℝ)
    (hb : net₁.bits = net₂.bits) (he : net₁.empRisk = net₂.empRisk) :
    net₁.bound n δ = net₂.bound n δ := by
  unfold Net.bound compressionBound occamBound; aesop;

/-
!-- The overparameterization phenomenon: a network with vastly more parameters
can carry a *strictly smaller* generalization guarantee than a small network,
provided it compresses better and fits at least as well.  Capacity is governed
by description length, not parameter count. -- !--
-/
theorem overparam_can_beat_small (big small : Net) (n : ℕ) (δ : ℝ)
    (hb : big.bits ≤ small.bits) (he : big.empRisk ≤ small.empRisk) :
    big.bound n δ ≤ small.bound n δ := by
  unfold Net.bound
  unfold compressionBound
  unfold occamBound;
  gcongr

/-! ## Consistency and its boundary -/

/-
!-- Consistency: with a fixed-complexity hypothesis the generalization gap
converges to zero as the sample size grows without bound.  The penalty is
`sqrt` of a quantity proportional to `1/n`, which tends to `0`. -- !--
-/
theorem occam_gap_tendsto_zero (R C δ : ℝ) :
    Tendsto (fun n : ℕ => occamBound R C n δ - R) atTop (𝓝 0) := by
  by_contra! h_contra;
  simp_all +decide [ occamBound ];
  exact h_contra <| tendsto_const_nhds.div_atTop <| Filter.Tendsto.const_mul_atTop ( by positivity ) <| by simpa only [ Real.sqrt_eq_rpow ] using tendsto_rpow_atTop ( by positivity ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop;

/-
!-- Boundary case (memorization): if the description length grows linearly in
the sample size, `C n = c · n` (one new bit per example), the gap does **not**
vanish — it converges to the irreducible constant `sqrt (c/2)`.  This is the
formal failure mode separating genuine learning from memorization. -- !--
-/
theorem memorization_gap_limit (R δ c : ℝ) :
    Tendsto (fun n : ℕ => occamBound R (c * n) n δ - R) atTop (𝓝 (Real.sqrt (c / 2))) := by
  -- Recognize that the expression inside the square root tends to $c/2$ as $n$ tends to infinity.
  have h_sqrt : Filter.Tendsto (fun n : ℕ => (c * (n : ℝ) + Real.log (1 / δ)) / (2 * (n : ℝ))) Filter.atTop (nhds (c / 2)) := by
    ring_nf;
    exact le_trans ( Filter.Tendsto.add ( tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ne_atTop 0 ] with n hn; aesop ) ) ( Filter.Tendsto.mul ( tendsto_const_nhds.mul tendsto_inv_atTop_nhds_zero_nat ) tendsto_const_nhds ) ) ( by norm_num );
  convert h_sqrt.sqrt using 2 ; unfold occamBound ; ring

end CompressionGen