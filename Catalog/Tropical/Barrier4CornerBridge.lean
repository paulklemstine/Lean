import Tropical.Barrier4SetCostDichotomy
import Tropical.FactorLocationBarriers

/-!
# Bridge: the barrier-4 laws at the tropical corner of the divisor hyperbola

This file connects the two strata proved in `Tropical.Barrier4FixedWindowOracle` /
`Tropical.Barrier4SetCostDichotomy` to the catalogue's factor-location barriers
(`Tropical.FactorLocationBarriers`), where the search window is the corner window `[1, √N]` of the
tropical line `X ⊙ Y = N`.

The window carries relative measure `μ = 1/√N` inside the full residue range, and by
`FactorLocationBarriers.nontrivial_witness_below_corner` it contains exactly **one** nontrivial
witness.  Consequently:

* `residue_sieve_cannot_break_sqrt` : a pipeline consisting of any positional stage whose cost is
  at least the corner measure `1/√N`, composed with any residue filter (cost `≥ 3/4`, the COST-class
  cap), has speedup at most `(4/3)·√N`.  The residue class buys a *constant* `4/3` on top of the
  positional `√N`; it cannot change the exponent.
* `semiprime_corner_barrier` : the same statement at a semiprime `N = pq`, packaged together with
  the catalogue's uniqueness of the nontrivial witness in the corner window.
* `corner_measure_cap` : the certified fixed-window law at the corner measure is capped by `√N`
  exactly, attained at a perfect oracle.
-/

namespace Barrier4

open Real

/-- **Residue sieving cannot break the `√N` barrier.**  Any pipeline whose positional stage costs
at least the corner measure `1/√N` and whose residue stage costs at least the cap value `3/4` has
speedup at most `(4/3)·√N`. -/
theorem residue_sieve_cannot_break_sqrt {N cR cF : ℝ} (hN : 1 ≤ N)
    (hcR : 1 / Real.sqrt N ≤ cR) (hcF : 3 / 4 ≤ cF) :
    speedup (pipelineCost cR cF) ≤ 4 / 3 * Real.sqrt N := by
  have hs : 0 < Real.sqrt N := Real.sqrt_pos.mpr (by linarith)
  have hcR0 : 0 < cR := lt_of_lt_of_le (by positivity) hcR
  have hcF0 : (0:ℝ) < cF := by linarith
  have hprod : 3 / (4 * Real.sqrt N) ≤ cR * cF := by
    have h1 : 1 / Real.sqrt N * (3 / 4) ≤ cR * cF := by
      apply mul_le_mul hcR hcF (by norm_num) hcR0.le
    calc 3 / (4 * Real.sqrt N) = 1 / Real.sqrt N * (3 / 4) := by field_simp
      _ ≤ cR * cF := h1
  have hpos : 0 < cR * cF := mul_pos hcR0 hcF0
  unfold speedup pipelineCost
  rw [div_le_iff₀ hpos]
  have hlow : 0 < 3 / (4 * Real.sqrt N) := by positivity
  calc (1:ℝ) = 4 / 3 * Real.sqrt N * (3 / (4 * Real.sqrt N)) := by field_simp
    _ ≤ 4 / 3 * Real.sqrt N * (cR * cF) := by
        apply mul_le_mul_of_nonneg_left hprod (by positivity)

/-- **Corner-window cap.**  At the corner measure `μ = 1/√N` (with `N ≥ 4`, so `μ ≤ 1/2`) the
certified fixed-window oracle is capped by `√N`, and the cap is attained exactly at a perfect
oracle. -/
theorem corner_measure_cap {N : ℝ} (hN : 4 ≤ N) {P : ℝ} (hP0 : 0 ≤ P) (hP1 : P ≤ 1) :
    speedup (costCert (1 / Real.sqrt N) P) ≤ Real.sqrt N ∧
      costCert (1 / Real.sqrt N) 1 = 1 / Real.sqrt N := by
  have hs2 : (2:ℝ) ≤ Real.sqrt N := by
    have : Real.sqrt 4 ≤ Real.sqrt N := Real.sqrt_le_sqrt hN
    calc (2:ℝ) = Real.sqrt 4 := by
          rw [show (4:ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
      _ ≤ Real.sqrt N := this
  have hs : 0 < Real.sqrt N := by linarith
  have hmu0 : 0 < 1 / Real.sqrt N := by positivity
  have hmu : 1 / Real.sqrt N ≤ 1 / 2 := by
    rw [div_le_div_iff₀ hs (by norm_num)]
    linarith
  refine ⟨?_, speedupCert_at_hit_one _⟩
  have h := speedupCert_le_inv_mu hmu0 hmu hP0 hP1
  rwa [one_div_one_div] at h

/-- **The corner barrier at a semiprime.**  For `N = p·q` the corner window contains exactly one
nontrivial witness (the catalogue's `nontrivial_witness_below_corner`), and no pipeline built from
a positional stage of cost at least the corner measure and a residue filter can beat
`(4/3)·√N`. -/
theorem semiprime_corner_barrier {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q)
    {cR cF : ℝ} (hcR : 1 / Real.sqrt (p * q) ≤ cR) (hcF : 3 / 4 ≤ cF) :
    (((p * q).divisors.filter (fun d => d * d ≤ p * q)).erase 1 = {p}) ∧
      speedup (pipelineCost cR cF) ≤ 4 / 3 * Real.sqrt (p * q) := by
  refine ⟨FactorLocationBarriers.nontrivial_witness_below_corner p q hp hq hlt, ?_⟩
  have hp1 : (1:ℝ) ≤ (p : ℝ) := by exact_mod_cast hp.one_lt.le
  have hq1 : (1:ℝ) ≤ (q : ℝ) := by exact_mod_cast hq.one_lt.le
  have hN : (1:ℝ) ≤ (p : ℝ) * (q : ℝ) := by nlinarith
  exact residue_sieve_cannot_break_sqrt hN hcR hcF

end Barrier4