/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Geometry.FanoStrongBlocking.Core

/-!
# Consequences of the Fano-plane threshold

Building on `fano_strongBlocking_iff_six` we record the sharp consequences of the
`h = 1` threshold result:

* the full point set is a strong blocking set (`strongBlocking_Pts`);
* deleting one point still leaves a strong blocking set of size `6`
  (`strongBlocking_erase`), so the bound `6` is *attained*;
* no strong blocking set has size `≤ 5` (`not_strongBlocking_of_card_le_five`);
* therefore `6` is the **least** size of a strong blocking set
  (`least_strongBlocking_card`), the exact minimal length of a nondegenerate
  minimal binary `[n, 3]` code under the projective-system correspondence.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): the threshold `6` is not merely a lower bound but is
  attained, and is attained by *every* 6-subset (each is `Pts` minus a point).
* Experiment (Experimenter): derived attainment from `fano_strongBlocking_iff_six`
  applied to `Pts.erase p`, whose card is `7 - 1 = 6` (`Finset.card_erase_of_mem`).
* Analysis (Analyst): packaging the two directions as `IsLeast` of the set of
  achievable strong-blocking-set sizes gives the cleanest statement of "the
  shortest minimal binary `[n,3]` code has length `6`".
* Critique (Critic): every result here is a genuine consequence (uses the main
  theorem plus `Finset` cardinality lemmas), none is `rfl`/`decide`-only; the
  `IsLeast` statement is non-vacuous because the witnessing 6-subset exists.
* Synthesis (PI): `least_strongBlocking_card` is the corollary headline; it is the
  exact formal counterpart of the informal claim in the mission statement.
-/

open Finset

namespace FanoStrongBlocking

/-- The full set of `7` points is a strong blocking set. -/
theorem strongBlocking_Pts : StrongBlocking Pts := by
  rw [fano_strongBlocking_iff_six (subset_refl Pts), Pts_card]
  norm_num

/-- Deleting any single point leaves a strong blocking set: the threshold `6` is
attained. -/
theorem strongBlocking_erase {p : V} (hp : p ∈ Pts) :
    StrongBlocking (Pts.erase p) ∧ (Pts.erase p).card = 6 := by
  have hsub : Pts.erase p ⊆ Pts := Finset.erase_subset p Pts
  have hc : (Pts.erase p).card = 6 := by rw [Finset.card_erase_of_mem hp, Pts_card]
  exact ⟨(fano_strongBlocking_iff_six hsub).mpr (by rw [hc]), hc⟩

/-- There is a strong blocking set of size exactly `6`. -/
theorem exists_strongBlocking_card_six :
    ∃ S, S ⊆ Pts ∧ StrongBlocking S ∧ S.card = 6 := by
  have hne : Pts.Nonempty := by
    rw [← Finset.card_pos, Pts_card]; norm_num
  obtain ⟨p, hp⟩ := hne
  obtain ⟨hsb, hc⟩ := strongBlocking_erase hp
  exact ⟨Pts.erase p, Finset.erase_subset p Pts, hsb, hc⟩

/-- No strong blocking set is contained in `5` or fewer points. -/
theorem not_strongBlocking_of_card_le_five {S : Finset V} (hS : S ⊆ Pts)
    (hcard : S.card ≤ 5) : ¬ StrongBlocking S := by
  intro hsb
  have := (fano_strongBlocking_iff_six hS).mp hsb
  omega

/-- **Threshold corollary.** `6` is the least size of a strong blocking set of
`PG(2,2)`: the shortest nondegenerate minimal binary `[n, 3]` code has length `6`. -/
theorem least_strongBlocking_card :
    IsLeast {n | ∃ S, S ⊆ Pts ∧ StrongBlocking S ∧ S.card = n} 6 := by
  constructor
  · exact exists_strongBlocking_card_six
  · rintro n ⟨S, hS, hsb, rfl⟩
    exact (fano_strongBlocking_iff_six hS).mp hsb

end FanoStrongBlocking