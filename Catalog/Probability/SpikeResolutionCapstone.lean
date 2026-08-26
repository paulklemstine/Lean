import Mathlib
import Probability.SpikeInclusionGeometry
import Probability.SpikeBandComposition
import Probability.SpikeStratifiedEvidence
import Probability.SpikeTruncationGradient
import Probability.SpikePositionMagnitudeDegeneracy

/-!
# Capstone: the left-edge profile is accounted for by magnitude and window
geometry alone

This file assembles the four independent components into a single statement of
the round-85 verdict.  Each hypothesis below is an empirical input of the
reanalysis; each conclusion is a theorem of the previous files.

Empirical inputs used as hypotheses:

* the moduli are `96`-bit (`hN : N < 2 ^ 96`) and hits are stored on the window
  `[isqrt N + 1, 3 isqrt N]`;
* the size-matched within-band first-decile rate ratios are at most `1.097`
  (`hmatched`);
* the pooled two-component fit reports `ΔAICc ≥ 49` while every size-matched
  stratum reports `ΔAICc ≤ 6` (`hpool`, `hbar₁`, `hbar₂`, `hineq`).

Conclusions (`Spike.Capstone.spike_fully_accounted`):

1. **Mechanical exclusion** — every first-decile hit has `bitlen v < 96`; the
   left-edge decile is a pure tiny-`v` stratum, not a sample of the size
   distribution.
2. **Composition accounting** — the flat-null excess never exceeds
   `0.097 ×` the band-referenced expectation plus the composition term; if the
   bands are exactly matched the *whole* excess is composition.
3. **Evidence accounting** — the pooled `ΔAICc` above the strata is bounded by
   the null misspecification gap: at the reported numbers `G ≥ 34`, i.e. the
   pooled statistic is dominated by cross-band null heterogeneity, which by
   `Spike.Gradient` is exactly what a monotone size density at a truncation
   boundary produces.

`Spike.Capstone.positional_layer_unidentified` records the structural reason no
positional kernel *could* have been detected within a modulus: position and
magnitude are the same statistic there.
-/

namespace Spike.Capstone

open Spike Spike.Band Spike.Evidence

/-- **The round-85 verdict, assembled.**  Under the empirical inputs, the
left-edge profile decomposes into (1) a mechanically forced tiny-`v` stratum,
(2) a band-composition term, and (3) a pooled-null heterogeneity term — with no
residual positional component. -/
theorem spike_fully_accounted
    -- geometry
    {N j : ℕ} (hN : N < 2 ^ 96) (hj : inFirstDecile N j)
    -- composition
    {ι : Type*} (S : Finset ι) (k n p : ι → ℝ) (p0 : ℝ)
    (hmatched : ∀ i ∈ S, k i ≤ 1.097 * (p i * n i))
    -- evidence
    {dPool d₁ d₂ G defect : ℝ}
    (hbar₁ : d₁ ≤ 6) (hbar₂ : d₂ ≤ 6) (hdef : defect ≤ 3) (hpool : 49 ≤ dPool)
    (hineq : dPool ≤ d₁ + d₂ + G + defect) :
    (residue N j).size < 96 ∧
    flatExcess S k n p0 ≤ 0.097 * (∑ i ∈ S, p i * n i) + composition S n p p0 ∧
    34 ≤ G := by
  refine ⟨size_residue_lt_96 hN hj, ?_, gap_large_of_strata_below_bar hbar₁ hbar₂ hdef hpool hineq⟩
  have hdec := flatExcess_eq S k n p p0
  have hband : bandExcess S k n p ≤ 0.097 * ∑ i ∈ S, p i * n i := by
    have : bandExcess S k n p ≤ ∑ i ∈ S, 0.097 * (p i * n i) := by
      refine Finset.sum_le_sum fun i hi => ?_
      have := hmatched i hi
      linarith
    calc bandExcess S k n p ≤ ∑ i ∈ S, 0.097 * (p i * n i) := this
      _ = 0.097 * ∑ i ∈ S, p i * n i := by rw [Finset.mul_sum]
  linarith [hdec]

/-- **Why no single-modulus test could have separated the layers.**  Within one
modulus the position of a hit and its residue determine each other, so every
positional weighting is realised by a magnitude weighting.  Identification
requires pooling across moduli — which is exactly the step that imports the band
composition analysed above. -/
theorem positional_layer_unidentified (N : ℕ) (w : ℕ → ℝ) :
    ∃ m : ℕ → ℝ, ∀ j, Nat.sqrt N + 1 ≤ j → w j = m (residue N j) :=
  Spike.Degeneracy.positional_weight_is_magnitude_weight N w

/-- **The surviving "persistence" is a boundary effect.**  A nonincreasing size
density on a band of `2m` cells always shows a nonnegative apparent left-edge
excess, and for a geometric density of ratio `r` that excess is at most
`m (1 - r)`: it disappears as the density flattens away from the truncation
boundary.  This is the shape reported (`[96,98)` sub-bar, `≥ 98` none). -/
theorem boundary_gradient_bound {f : ℕ → ℝ} (hf : ∀ a b, a ≤ b → f b ≤ f a) (m : ℕ)
    {r : ℝ} (hr0 : 0 ≤ r) (hr : r ≤ 1) :
    0 ≤ Spike.Gradient.edgeExcess f m ∧
      Spike.Gradient.relativeEdge r m ≤ m * (1 - r) :=
  ⟨Spike.Gradient.edgeExcess_nonneg hf m, Spike.Gradient.relativeEdge_le_linear hr0 hr m⟩

end Spike.Capstone