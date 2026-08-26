import Pythagorean.DriftGateClusterFloor
import Pythagorean.DriftGateHypotenuseMultiplicity

/-!
# U9-DRIFT-GATE synthesis: the recorded run against the structural floors

This file joins the two halves of the round.

* From `DriftGateClusterFloor.lean`: the cluster-bootstrap **resolution floor**
  `share − 1/m ≤ relClusterSD` and the **sign-flip coverage audit**.
* From `DriftGateHypotenuseMultiplicity.lean`: hypotenuse clusters carry **unboundedly
  many** hits.

Results proved here.

* `arbiter_sign_flip` — the recorded point estimates really do straddle `1`: the
  `20260824` family reads a deficit (`0.9468`) and the `20260825` arbiter reads a surplus
  (`40617/38594 > 1`, and `2598/2252 > 1` at the primary cut).  This is a *directional*
  disagreement, not a magnitude disagreement.
* `arbiter_cluster_floor` — instantiating the floor at the recorded cluster profile
  (`m = 128` clusters, top cluster `600` hits, total `40617`) gives a nonzero one-run
  resolution floor of more than `0.0069`, and the stored `cut_1e6` half-width `0.048`
  comfortably exceeds twice that floor: the reported interval is *consistent* with the
  cluster structure (audit item 3 discharged), rather than narrower than the structure
  permits.
* `hypotenuse_cluster_floor_near_half` — **the bold consequence**: because hypotenuse
  multiplicities are unbounded, one can exhibit genuine two-hypotenuse cluster families
  whose one-run relative resolution floor is arbitrarily close to `1/2`.  Clustered
  Pythagorean search has no universal averaging: overdispersion is not a nuisance
  parameter that vanishes with more pairs.
* `truncation_can_leave_interval` — audit item 1 in formal form: five-decimal display
  truncation can push a value that lies inside an interval to a displayed value outside
  it, so an "out-of-CI" appearance produced by formatting is not evidence.
-/

namespace Catalog.Pythagorean.DriftGate

open Finset

/-! ## 1. The recorded sign flip -/

/-- **Sign flip, exactly as recorded.**  The `20260824` seed family reports `0.9468 < 1`
at `cut_1e6`; the independent `20260825` arbiter reports `40617/38594 > 1` at the same cut
and `2598/2252 > 1` at the primary cut `1e5`.  The three ratios do not agree on a
direction. -/
theorem arbiter_sign_flip :
    (0.9468 : ℝ) < 1 ∧ 1 < (40617 : ℝ) / 38594 ∧ 1 < (2598 : ℝ) / 2252 := by
  refine ⟨by norm_num, ?_, ?_⟩ <;> rw [lt_div_iff₀ (by norm_num)] <;> norm_num

/-- The arbiter's primary-cut ratio is strictly larger than its `cut_1e6` ratio: the
apparent effect *shrinks* as the cut is loosened, which is the signature of a fluctuation
rather than of a scale-stable deviation. -/
theorem arbiter_cut_ordering : (40617 : ℝ) / 38594 < (2598 : ℝ) / 2252 := by
  rw [div_lt_div_iff₀ (by norm_num) (by norm_num)]
  norm_num

open MeasureTheory in
/-- **The gate rejection, formally.**  Model the unknown estimand as a random variable `ρ`
on a probability space.  Let `A` be the event that the `20260824` family's interval (which
lies in `(0, 1]`) covers `ρ`, and `B` the event that the arbiter's recorded `cut_1e6`
interval `[1.0051, 1.1016]` covers `ρ`.  The two intervals are disjoint, so by
`no_disjoint_95_coverage` the two nominal `95%` coverage claims are jointly impossible:
the seed families cannot both be reading the same quantity with correct coverage.  This
is precisely the ground on which gate `G1` fails *by sign*. -/
theorem recorded_no_joint_coverage {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] (ρ : Ω → ℝ) (hmeas : Measurable ρ)
    (hcovA : 0.95 ≤ μ.real {ω | ρ ω ≤ 1})
    (hcovB : 0.95 ≤ μ.real {ω | 1.0051 ≤ ρ ω}) : False := by
  have hBmeas : MeasurableSet {ω | (1.0051 : ℝ) ≤ ρ ω} := measurableSet_le measurable_const hmeas
  have hdisj : Disjoint {ω | ρ ω ≤ 1} {ω | (1.0051 : ℝ) ≤ ρ ω} := by
    rw [Set.disjoint_left]
    intro ω hω hω'
    simp only [Set.mem_setOf_eq] at hω hω'
    linarith
  exact no_disjoint_95_coverage μ hBmeas hdisj hcovA hcovB

/-! ## 2. The recorded cluster profile against the floor -/

/-- The recorded arbiter cluster profile at `cut_1e6`, idealised: `128` clusters, the top
one carrying `600` hits and the remaining mass spread evenly, for a grand total of
`40617`. -/
noncomputable def arbiterProfile : ℕ → ℝ :=
  fun i => if i = 0 then 600 else 40017 / 127

private theorem arbiterProfile_sum :
    ∑ i ∈ Finset.range 128, arbiterProfile i = 40617 := by
  have hsplit : ∀ i ∈ Finset.range 128,
      arbiterProfile i = (if i = 0 then (600 : ℝ) - 40017 / 127 else 0) + 40017 / 127 := by
    intro i _
    unfold arbiterProfile
    split <;> ring
  rw [Finset.sum_congr rfl hsplit, Finset.sum_add_distrib,
    Finset.sum_ite_eq' (Finset.range 128) 0 (fun _ => (600 : ℝ) - 40017 / 127)]
  norm_num

/-- **The recorded run against its own floor.**  The idealised recorded profile has a
nonzero one-run resolution floor exceeding `0.0069`, and the stored `cut_1e6` half-width
`(1.1016 − 1.0051)/2` is larger than twice that floor.  The reported interval is therefore
consistent with the observed cluster overdispersion. -/
theorem arbiter_cluster_floor :
    0.0069 ≤ relClusterSD (Finset.range 128) arbiterProfile ∧
      (2 : ℝ) * 0.0069 ≤ (1.1016 - 1.0051) / 2 := by
  constructor
  · have hS : (0 : ℝ) < ∑ i ∈ Finset.range 128, arbiterProfile i := by
      rw [arbiterProfile_sum]; norm_num
    have hmem : (0 : ℕ) ∈ Finset.range 128 := Finset.mem_range.2 (by norm_num)
    have hfloor := share_sub_inv_card_le_relClusterSD (Finset.range 128) arbiterProfile hS hmem
    rw [arbiterProfile_sum] at hfloor
    have hcard : ((Finset.range 128).card : ℝ) = 128 := by simp
    rw [hcard] at hfloor
    have hval : arbiterProfile 0 = 600 := by unfold arbiterProfile; norm_num
    rw [hval] at hfloor
    have : (0.0069 : ℝ) ≤ 600 / 40617 - 1 / 128 := by norm_num
    linarith
  · norm_num

/-! ## 3. Intrinsic overdispersion forces a near-`1/2` floor -/

/-- **Bold consequence.**  For every `ε > 0` there are two distinct hypotenuses whose
genuine hit clusters form a two-cluster family with relative resolution floor at least
`1/2 − ε`.  Unbounded hypotenuse multiplicity (`exists_hypotenuse_multiplicity`) means the
cluster-bootstrap dispersion of a Pythagorean search cannot be bounded away from the
worst case by increasing the number of sampled pairs. -/
theorem hypotenuse_cluster_floor_near_half (ε : ℝ) (hε : 0 < ε) :
    ∃ c₁ c₂ : ℕ, c₁ ≠ c₂ ∧
      1 / 2 - ε ≤ relClusterSD (Finset.univ : Finset (Fin 2))
        (fun i => if i = 0 then ((hypSolutions c₁).card : ℝ)
                  else ((hypSolutions c₂).card : ℝ)) := by
  obtain ⟨K, hK⟩ := exists_nat_gt (2 / ε)
  obtain ⟨c, _, hc⟩ := exists_hypotenuse_multiplicity (K + 3)
  set h : ℕ := (hypSolutions c).card with hh
  have hh3 : (3 : ℝ) ≤ (h : ℝ) := by
    have : (3 : ℕ) ≤ h := le_trans (by omega) hc
    exact_mod_cast this
  have hKh : (2 / ε : ℝ) ≤ (h : ℝ) := by
    have : ((K : ℝ)) ≤ (h : ℝ) := by
      have : (K : ℕ) ≤ h := le_trans (by omega) hc
      exact_mod_cast this
    linarith
  have hcard5 : (hypSolutions 5).card = 2 := by rw [hypSolutions_five]; decide
  have hne : c ≠ 5 := by
    intro hcon
    rw [hcon, hcard5] at hh
    omega
  refine ⟨c, 5, hne, ?_⟩
  set x : Fin 2 → ℝ := fun i => if i = 0 then ((hypSolutions c).card : ℝ)
                                else ((hypSolutions 5).card : ℝ) with hx
  have hx0 : x 0 = (h : ℝ) := by simp [hx, hh]
  have hx1 : x 1 = 2 := by simp [hx, hcard5]
  have hsum : ∑ i ∈ (Finset.univ : Finset (Fin 2)), x i = (h : ℝ) + 2 := by
    rw [Fin.sum_univ_two, hx0, hx1]
  have hS : (0 : ℝ) < ∑ i ∈ (Finset.univ : Finset (Fin 2)), x i := by
    rw [hsum]; linarith
  have hfloor := share_sub_inv_card_le_relClusterSD (Finset.univ : Finset (Fin 2)) x hS
    (Finset.mem_univ 0)
  rw [hsum, hx0] at hfloor
  have hcard : ((Finset.univ : Finset (Fin 2)).card : ℝ) = 2 := by simp
  rw [hcard] at hfloor
  -- `h/(h+2) − 1/2 = 1/2 − 2/(h+2) ≥ 1/2 − ε`
  have hpos : (0 : ℝ) < (h : ℝ) + 2 := by linarith
  have hεh : 2 ≤ ε * (h : ℝ) := by
    have h' := (div_le_iff₀ hε).1 hKh
    nlinarith
  have hdiv : 2 / ((h : ℝ) + 2) ≤ ε := by
    rw [div_le_iff₀ hpos]; nlinarith
  have hrw : (h : ℝ) / ((h : ℝ) + 2) = 1 - 2 / ((h : ℝ) + 2) := by
    field_simp
    ring
  have hkey : 1 / 2 - ε ≤ (h : ℝ) / ((h : ℝ) + 2) - 1 / 2 := by
    rw [hrw]; linarith
  exact le_trans hkey hfloor

/-! ## 4. Audit item 1: display truncation is not evidence -/

/-- Truncation of a positive value to five decimals. -/
noncomputable def trunc5 (x : ℝ) : ℝ := (⌊x * 100000⌋ : ℝ) / 100000

/-- **Formatting artefact, formalised.**  There is a value strictly inside an interval
whose five-decimal truncation lies strictly below the interval.  Hence the coordinator's
"out-of-CI" reading, produced by `:.5f` formatting of `3.38e-05`, carries no information
about the underlying quantity. -/
theorem truncation_can_leave_interval :
    ∃ lo hi x : ℝ, lo < x ∧ x < hi ∧ trunc5 x < lo := by
  refine ⟨0.000031, 0.000035, 0.0000338, by norm_num, by norm_num, ?_⟩
  have hfloor : ⌊(0.0000338 : ℝ) * 100000⌋ = 3 := by
    apply Int.floor_eq_iff.2
    constructor <;> norm_num
  unfold trunc5
  rw [hfloor]
  norm_num

end Catalog.Pythagorean.DriftGate