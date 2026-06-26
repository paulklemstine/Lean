/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Bridge: exponential contraction ⇒ finite refinement budget and exponential covering

This file is the *synthesis* connecting the mission's two halves:

* the contraction theorem of `Contraction.lean`
  (`d k ≤ (1/λ)^k · D`, the formal core of the Delaunay diameter conjecture), and
* the approximate-Carathéodory / Maurey results of `Maurey.lean`
  (every domain point lies within one current simplex of a sample vertex, so the
  *covering radius* is at most the maximum simplex diameter).

Combining them yields two genuinely new consequences:

* **Finite total refinement budget** (`total_budget`): the *sum over all
  refinement steps* of the maximum diameters is finite, with the explicit
  geometric-series bound `∑ d k ≤ D · λ/(λ-1)`. So exponential per-step
  contraction makes the *cumulative* work geometrically bounded.
* **Exponential covering** (`covering_tendsto_zero`, `covering_budget`): if the
  covering radius is dominated by the maximum diameter (Maurey/Carathéodory),
  then it too decays exponentially and is summable.

Self-contained: the two source theorems enter as hypotheses (exactly the
conclusions exported by the other files), so this file consumes them cleanly
without cross-imports. All results have zero `sorry`s.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): If per-step contraction is exponential, then not only
does the diameter vanish, but the *accumulated* diameter over infinitely many
refinements is finite — a geometric series. Moreover the Carathéodory covering
radius inherits the same decay.

Experiment (Experimenter): Took the exported bound `d k ≤ (1/λ)^k D` (`hpow`) as a
hypothesis. Established `Summable d` by comparison with the geometric series
`(1/λ)^k D`, then bounded `∑ d k` by `∑ (1/λ)^k D = D/(1-1/λ) = D λ/(λ-1)`.
For covering, dominated `cov ≤ d` to transfer summability, the tsum bound, and the
limit `cov → 0`.

Analysis (Analyst): The summability is *only* available because `λ > 1` strictly
(ratio `1/λ < 1`); at `λ = 1` the series diverges. So the "constant factor `> 1`"
in the conjecture is exactly the line between a finite and an infinite refinement
budget — a sharper reason to care about strictness than mere decay-to-zero.

Critique (Critic): The covering hypothesis `cov k ≤ d k` is the honest content of
Maurey/Carathéodory (a point of a simplex is within its diameter of a vertex), not
a smuggled assumption; it is flagged as such. No theorem is `simp`-only: each uses
comparison, `tsum` algebra, or a squeeze.

Synthesis (PI): "Exponential contraction" upgrades from a limit statement to a
*budget* statement; combined with Carathéodory it bounds the total covering error
of an infinite refinement by a closed-form constant.
-- !-- end Lab Notes -- !--
-/

namespace DelaunayContraction.Bridge

open Filter

variable {d : ℕ → ℝ} {lam D : ℝ}

/-- Under exponential contraction, the diameter sequence is summable. -/
theorem summable_of_contraction (hlam : 1 < lam) (hd0 : ∀ k, 0 ≤ d k)
    (hpow : ∀ k, d k ≤ (1 / lam) ^ k * D) : Summable d := by
  have hr0 : (0 : ℝ) ≤ 1 / lam := by positivity
  have hr1 : 1 / lam < 1 := by rw [div_lt_one (lt_trans one_pos hlam)]; exact hlam
  exact ((summable_geometric_of_lt_one hr0 hr1).mul_right D).of_nonneg_of_le hd0 hpow

/-- **Finite total refinement budget.** The sum over *all* refinement steps of the
maximum diameters is bounded by the closed-form geometric constant `D · λ/(λ-1)`.
Exponential per-step contraction ⇒ geometrically bounded cumulative diameter. -/
theorem total_budget (hlam : 1 < lam) (hd0 : ∀ k, 0 ≤ d k)
    (hpow : ∀ k, d k ≤ (1 / lam) ^ k * D) :
    ∑' k, d k ≤ D * lam / (lam - 1) := by
  have hlam0 : 0 < lam := lt_trans one_pos hlam
  have hr0 : (0 : ℝ) ≤ 1 / lam := by positivity
  have hr1 : 1 / lam < 1 := by rw [div_lt_one hlam0]; exact hlam
  have hcomp : Summable (fun k => (1 / lam) ^ k * D) :=
    (summable_geometric_of_lt_one hr0 hr1).mul_right D
  have hsumd : Summable d := hcomp.of_nonneg_of_le hd0 hpow
  calc ∑' k, d k ≤ ∑' k, (1 / lam) ^ k * D := hsumd.tsum_le_tsum hpow hcomp
    _ = (∑' k, (1 / lam) ^ k) * D := by rw [tsum_mul_right]
    _ = (1 - 1 / lam)⁻¹ * D := by rw [tsum_geometric_of_lt_one hr0 hr1]
    _ = D * lam / (lam - 1) := by
        rw [one_sub_div (ne_of_gt hlam0)]
        field_simp

/-- **Exponential decay of the covering radius.** If, as approximate Carathéodory
guarantees, every domain point is within one current simplex of a sample (so the
covering radius `cov k` is at most the maximum diameter `d k`), then the covering
radius tends to `0`. -/
theorem covering_tendsto_zero {cov : ℕ → ℝ} (hlam : 1 < lam)
    (hcov0 : ∀ k, 0 ≤ cov k) (hcovle : ∀ k, cov k ≤ d k)
    (hpow : ∀ k, d k ≤ (1 / lam) ^ k * D) :
    Tendsto cov atTop (nhds 0) := by
  have hlam0 : 0 < lam := lt_trans one_pos hlam
  have hb : Tendsto (fun k => (1 / lam) ^ k * D) atTop (nhds 0) := by
    have habs : |1 / lam| < 1 := by
      rw [abs_of_pos (by positivity), div_lt_one hlam0]; exact hlam
    simpa using (tendsto_pow_atTop_nhds_zero_of_abs_lt_one habs).mul_const D
  exact squeeze_zero hcov0 (fun k => le_trans (hcovle k) (hpow k)) hb

/-- **Finite covering budget.** The total covering error over all refinements is
finite and bounded by the same geometric constant. -/
theorem covering_budget {cov : ℕ → ℝ} (hlam : 1 < lam)
    (hcov0 : ∀ k, 0 ≤ cov k) (hcovle : ∀ k, cov k ≤ d k)
    (hpow : ∀ k, d k ≤ (1 / lam) ^ k * D) :
    ∑' k, cov k ≤ D * lam / (lam - 1) := by
  have hdpow : ∀ k, d k ≤ (1 / lam) ^ k * D := hpow
  have hd0 : ∀ k, 0 ≤ d k := fun k => le_trans (hcov0 k) (hcovle k)
  have hsumd : Summable d := summable_of_contraction hlam hd0 hdpow
  have hsumc : Summable cov := hsumd.of_nonneg_of_le hcov0 hcovle
  exact le_trans (hsumc.tsum_le_tsum hcovle hsumd)
    (total_budget hlam hd0 hdpow)

end DelaunayContraction.Bridge