/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Fano plane is slower than the uniform triple mechanism (q = 2)

This file records the concrete `q = 2` instance of the Projective-Plane Coupon
Collection Slowness phenomenon — the case (the Fano plane) that disproved the
Grünbaum–Yaakobi conjecture.

We work on the `n = 7` points `Fin 7`.  Two coupon-collection mechanisms with the
**same block size `q+1 = 3`** are compared:

* `fanoLines` — the `7` lines of the Fano plane, each a `3`-subset (the *plane*
  mechanism);
* `allTriples` — *all* `C(7,3) = 35` three-element subsets (the *uniform*
  mechanism).

The expected cover time is the inclusion–exclusion functional
`expCoverTime B = Σ_{∅ ≠ S} (-1)^{|S|+1} · |B| / (#blocks of B meeting S)`,
the same functional used in `Catalog.Combinatorics.CouponCoverFramework`.

## Main result

* `fano_slower_than_uniform` :
  `expCoverTime allTriples < expCoverTime fanoLines`,
  i.e. the Fano (plane) mechanism is strictly **slower** than the uniform
  `3`-subset mechanism on the same `7` points.  The two exact values are
  `expCoverTime fanoLines = 163/30 ≈ 5.4333` and
  `expCoverTime allTriples = 85691/15810 ≈ 5.4201`.

## Why this is the *right* comparison

`Catalog.Combinatorics.CouponCoverFramework` compared the Fano lines against the
family of `7` *singletons* and found the lines *faster* — but that is a
comparison between mechanisms of different block sizes (`3` vs `1`) and is **not**
the Grünbaum–Yaakobi question.  The genuine question fixes the block size (`q+1`)
and pits the structured *line* family against the *uniform* `(q+1)`-subset
family.  Under that fair comparison the plane is slower, as proved here.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): With block size fixed at `q+1 = 3`, the Fano lines
  are slower than uniform triples (the true disproof of Grünbaum–Yaakobi), even
  though the gap is tiny (`163/30 − 85691/15810 = 7/527 ≈ 0.0133`).
Experiment (Experimenter): Evaluated the inclusion–exclusion functional on both
  families exactly over the `127` nonempty subsets of `Fin 7`.  The Fano value is
  `163/30`; the uniform value is `85691/15810`.  Their difference is positive.
Analysis (Analyst): Orders 1 and 2 contribute identically (each Fano point lies
  on `3` lines, each pair on a unique line, matching the uniform marginals — cf.
  `Engine.match1`, `Engine.match2`).  The strict gap is created at orders ≥ 3,
  where the Fano family carries two distinct triple-cover-counts (`7` for
  collinear, `6` for generic) while the uniform family is flat — exactly the
  convexity engine of `Engine.slowness3`.  The tiny size of the gap explains why
  the phenomenon was historically counter-intuitive.
Critique (Critic): The block sizes are equal (both `3`), so the comparison is
  fair; verified `block_sizes_equal` below.  The comparison `<` is obtained by
  reducing to two exact rational values and a single `norm_num` inequality, not
  by an opaque `decide` on the inequality itself.
Synthesis (PI): The `q = 2` instance confirms the general structural prediction
  of `Engine.slowness_through_order3`: the plane is slower, and the divergence is
  driven by collinearity at order three.
-/
import Mathlib

open Finset

namespace FanoDisproof

/-- `coverCount B S` is the number of blocks of `B` that meet `S`.  (Same model as
`Catalog.Combinatorics.CouponCoverFramework`.) -/
def coverCount (B : Finset (Finset (Fin 7))) (S : Finset (Fin 7)) : ℕ :=
  (B.filter (fun b => (b ∩ S).Nonempty)).card

/-- Expected cover time: `Σ_{∅ ≠ S} (-1)^{|S|+1} · |B| / coverCount B S`. -/
def expCoverTime (B : Finset (Finset (Fin 7))) : ℚ :=
  ∑ S ∈ (univ.powerset.erase ∅), (-1 : ℚ) ^ (S.card + 1) * (B.card : ℚ) / (coverCount B S : ℚ)

/-- The Fano plane: the `7` lines of the `2-(7,3,1)` design on `Fin 7`. -/
def fanoLines : Finset (Finset (Fin 7)) :=
  {{0, 1, 2}, {0, 3, 4}, {0, 5, 6}, {1, 3, 5}, {1, 4, 6}, {2, 3, 6}, {2, 4, 5}}

/-- The uniform mechanism: all `C(7,3) = 35` three-element subsets of `Fin 7`. -/
def allTriples : Finset (Finset (Fin 7)) :=
  univ.powerset.filter (fun s => s.card = 3)

/-- There are `35` triples. -/
theorem allTriples_card : allTriples.card = 35 := by decide

/-- The Fano family has `7` blocks. -/
theorem fanoLines_card : fanoLines.card = 7 := by decide

set_option maxRecDepth 10000 in
/-- Both mechanisms use blocks of the **same size** `3`: the comparison is fair. -/
theorem block_sizes_equal :
    (∀ b ∈ fanoLines, b.card = 3) ∧ (∀ b ∈ allTriples, b.card = 3) := by
  refine ⟨by decide, ?_⟩
  intro b hb
  simpa [allTriples, mem_filter] using (mem_filter.mp hb).2

/-- The Fano (plane) mechanism's exact expected cover time. -/
theorem expCoverTime_fano : expCoverTime fanoLines = 163 / 30 := by
  native_decide

/-- The uniform `3`-subset mechanism's exact expected cover time. -/
theorem expCoverTime_uniform : expCoverTime allTriples = 85691 / 15810 := by
  native_decide

/-- **Fano slowness (q = 2).** The Fano (plane) mechanism is strictly *slower*
than the uniform `3`-subset mechanism on the same `7` points.  This is the
genuine disproof of the Grünbaum–Yaakobi conjecture at `q = 2`: with block size
fixed at `q + 1 = 3`, the structured line family takes strictly longer to cover
all points than the uniform family.  The exact gap is `7/527 ≈ 0.0133`. -/
theorem fano_slower_than_uniform :
    expCoverTime allTriples < expCoverTime fanoLines := by
  rw [expCoverTime_fano, expCoverTime_uniform]
  norm_num

/-- The exact slowness gap. -/
theorem fano_uniform_gap :
    expCoverTime fanoLines - expCoverTime allTriples = 7 / 527 := by
  rw [expCoverTime_fano, expCoverTime_uniform]
  norm_num

end FanoDisproof