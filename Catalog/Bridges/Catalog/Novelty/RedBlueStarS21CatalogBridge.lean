/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A catalog bridge: the `S_{2,1}` edge-density ceiling versus the cycle-decomposition thresholds

The complement-split construction for the red-blue star `S_{2,1}` has edge density capped at
`1/2` (`RedBlueStarS21.edgeDensity_le_half`).  The generalized Nash–Williams cycle thresholds
of `Catalog/Novelty/C5Threshold.lean`, `δ_{C_ℓ} = ℓ/(2ℓ − 2)`, form a strictly decreasing
sequence converging *down to* `1/2` but staying strictly above it (`C5Decomp.nwThreshold_gt_half`).

This file records the elementary but genuine cross-result that the `S_{2,1}` edge-density
ceiling `1/2` lies strictly below every cycle-decomposition threshold `δ_{C_ℓ}` (`ℓ ≥ 2`), and
in particular below the headline value `δ_{C_5} = 5/8`.  Both quantities share `1/2` as their
extreme value — the construction *attains* it from below, the thresholds *approach* it from
above — so `1/2` is the common boundary witnessed from the two opposite sides.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): `1/2` is a shared structural boundary: the `S_{2,1}` construction's
  attainable edge densities and the Nash–Williams thresholds meet exactly at `1/2`.
Experiment (Experimenter): Imported `C5Decomp.nwThreshold` and combined
  `edgeDensity_le_half`/`edgeDensity_one` with `nwThreshold_gt_half`/`nwThreshold_five` to prove
  `edgeDensity t < nwThreshold ℓ` for all `t ∈ [0,1]`, `ℓ ≥ 2`.
Analysis (Analyst): The two families approach `1/2` from opposite sides — the construction from
  below (sup `= 1/2`, attained at `t = 1`), the thresholds from above (inf `= 1/2`, never
  attained).  This makes `1/2` a genuine two-sided limit point linking the two catalog entries.
Critique (Critic): The bridge would be vacuous if it merely re-stated `edgeDensity_one`; instead
  it chains two independently nontrivial inequalities (`edgeDensity_le_half`, `nwThreshold_gt_half`)
  and is *strict*, so it carries content beyond either endpoint evaluation.
Synthesis (PI): Confirms `S_{2,1}` lives strictly inside the `β ≤ 1/2` regime that the cycle
  thresholds bound from above; the `β > 1/2` half-range must be a different (complement) story.
-/
import Mathlib
import Novelty.RedBlueStarS21Profile
import Novelty.C5Threshold

namespace RedBlueStarS21

open Set

/-- **Catalog cross-result.** Every edge density attainable by the `S_{2,1}` complement-split
construction (`t ∈ [0,1]`) is strictly below every generalized Nash–Williams cycle threshold
`δ_{C_ℓ} = ℓ/(2ℓ − 2)` with `ℓ ≥ 2`.  Uses `C5Decomp.nwThreshold_gt_half` from
`Catalog/Novelty/C5Threshold.lean`. -/
theorem edgeDensity_lt_nwThreshold {t : ℝ} (ht : t ∈ Icc (0 : ℝ) 1)
    {l : ℕ} (hl : 2 ≤ l) : edgeDensity t < C5Decomp.nwThreshold l := by
  have h1 : edgeDensity t ≤ 1 / 2 := edgeDensity_le_half ht
  have h2 : 1 / 2 < C5Decomp.nwThreshold l := C5Decomp.nwThreshold_gt_half l hl
  linarith

/-- The construction's edge-density ceiling `1/2` (attained at `t = 1`) is strictly below the
headline cycle-decomposition threshold `δ_{C_5} = 5/8`. -/
theorem edgeDensity_ceiling_lt_C5 : edgeDensity 1 < C5Decomp.nwThreshold 5 := by
  rw [edgeDensity_one, C5Decomp.nwThreshold_five]; norm_num

end RedBlueStarS21