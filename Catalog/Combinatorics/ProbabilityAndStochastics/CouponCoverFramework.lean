/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The coupon-cover framework and the Fano plane

This file develops a small, self-contained framework for the *coupon collector cover time*
of a set family, and applies it to the **Fano plane** (the unique `2-(7,3,1)` design).

## The model

Fix a finite ground set `α` (the *coupons* / *points*) and a family `B` of *blocks*
(subsets of `α`).  We draw a uniformly random block at each step; a point `p` is *covered*
once some drawn block contains it, and the **cover time** is the first step at which every
point of `⋃ B` has been covered.  Writing `τ_p` for the first time a block containing `p`
is drawn, the cover time is `max_p τ_p`, and a standard inclusion–exclusion over the points
gives

`expCoverTime B = ∑_{∅ ≠ S ⊆ α} (-1)^{|S|+1} · |B| / coverCount B S`,

where `coverCount B S` is the number of blocks that meet `S` (so `coverCount B S / |B|` is the
per-draw probability of covering a new point of `S`, and `E[min_{p∈S} τ_p] = |B| / coverCount B S`).
We take this inclusion–exclusion expression as the **definition** of `expCoverTime`; this is the
formula referenced by the task.

For the family of `n` singletons on an `n`-element set, `coverCount` of a set `S` is exactly `|S|`,
so the formula specialises to the classical coupon-collector identity
`∑_{k=1}^n (-1)^{k+1} C(n,k) · n / k = n · Hₙ`.

## Main results

* `coverCount_singletonFamily` : for the singleton family, `coverCount` of `S` equals `S.card`.
* `expCoverTime_singletons_seven` : `expCoverTime (singletonFamily (Fin 7)) = 363/20 = 7·H₇`.
* `expCoverTime_fano` : the Fano line family has cover time `expCoverTime fanoLines = 163/30`.
* `fano_lt_singletons` / `fano_lt_sevenH` : the Fano cover time is **strictly smaller** than
  `7·H₇`.

## A correction to the conjectured direction

The original task asked to prove that the Fano cover time *strictly exceeds* `7·H₇`.
That statement is **false**.  A direct (kernel-independent) computation gives

`expCoverTime fanoLines = 163/30 ≈ 5.43 < 18.15 = 363/20 = 7·H₇`.

This is forced by the mathematics of the model: a single Fano line already covers `3` of the
`7` points, so the line family covers the plane far *faster* than collecting `7` independent
singletons one at a time.  In any monotone cover model an efficient covering design can only
*lower* the cover time, never raise it; among covers of a point set the projective plane is
extremal by **minimising** the cover time, not maximising it.  Accordingly we prove the correct
inequality (`<`) below, and record the refutation of the original `>` claim in
`original_exceeds_claim_is_false`.

The task's intermediate sketch is likewise inaccurate: for the Fano plane `coverCount` of a
`2`-element set is `5` (`= 3 + 3 - 1`, the lines meeting either point), not `4`, and
`coverCount B S` is *not* a function of `|S|` alone for `|S| ≥ 3` (the Fano automorphism group
`PSL(2,7)` is `2`-transitive but not `3`-transitive, so collinear and non-collinear triples
behave differently).  We therefore evaluate the inclusion–exclusion sum by direct computation
rather than via the (false) "depends only on `|S|`" claim.
-/

namespace CouponCover

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- `coverCount B S` is the number of blocks of `B` that meet `S`. -/
def coverCount (B : Finset (Finset α)) (S : Finset α) : ℕ :=
  (B.filter (fun b => (b ∩ S).Nonempty)).card

/-- The expected cover time of a block family `B`, defined by the inclusion–exclusion formula
`∑_{∅ ≠ S} (-1)^{|S|+1} · |B| / coverCount B S`, the sum ranging over nonempty subsets of the
ground set. -/
def expCoverTime (B : Finset (Finset α)) : ℚ :=
  ∑ S ∈ (univ.powerset.erase ∅), (-1 : ℚ) ^ (S.card + 1) * (B.card : ℚ) / (coverCount B S : ℚ)

/-- The family of all singletons of `α`. -/
def singletonFamily (α : Type*) [Fintype α] [DecidableEq α] : Finset (Finset α) :=
  univ.image (fun a : α => ({a} : Finset α))

/-- For the singleton family, the number of blocks meeting `S` is exactly `|S|`: a singleton
`{a}` meets `S` iff `a ∈ S`. -/
theorem coverCount_singletonFamily (S : Finset α) :
    coverCount (singletonFamily α) S = S.card := by
  unfold coverCount singletonFamily
  rw [Finset.card_filter]
  rw [Finset.sum_image] <;> simp +decide [Finset.Nonempty]
  exact fun a b h => by simpa using h

/-- The Fano plane: the `7` lines of the `2-(7,3,1)` design on the point set `Fin 7`, each
written as a concrete `3`-element subset. -/
def fanoLines : Finset (Finset (Fin 7)) :=
  {{0, 1, 2}, {0, 3, 4}, {0, 5, 6}, {1, 3, 5}, {1, 4, 6}, {2, 3, 6}, {2, 4, 5}}

/-! ### The Fano plane is a `2-(7,3,1)` design -/

/-- There are `7` lines. -/
theorem fano_card : fanoLines.card = 7 := by decide

set_option maxRecDepth 10000 in
/-- Every line has exactly `3` points. -/
theorem fano_line_card : ∀ b ∈ fanoLines, b.card = 3 := by decide

set_option maxRecDepth 10000 in
/-- Every point lies on exactly `3` lines. -/
theorem fano_point_degree : ∀ p : Fin 7, (fanoLines.filter (fun b => p ∈ b)).card = 3 := by
  decide

set_option maxRecDepth 10000 in
/-- Every pair of distinct points lies on exactly `1` line. -/
theorem fano_pair_unique_line :
    ∀ p q : Fin 7, p ≠ q → (fanoLines.filter (fun b => p ∈ b ∧ q ∈ b)).card = 1 := by
  decide

/-! ### `coverCount` values for the Fano line family -/

set_option maxRecDepth 10000 in
/-- A single point is met by its `3` lines, so `coverCount = 3` for `|S| = 1`. -/
theorem fano_coverCount_singleton : ∀ p : Fin 7, coverCount fanoLines {p} = 3 := by
  decide

set_option maxRecDepth 10000 in
/-- A pair of distinct points is met by `5 = 3 + 3 - 1` lines (lines through either point),
so `coverCount = 5` for `|S| = 2`.  (The task's sketch erroneously stated `4`.) -/
theorem fano_coverCount_pair :
    ∀ p q : Fin 7, p ≠ q → coverCount fanoLines {p, q} = 5 := by
  decide

/-! ### Cover times -/

/-- The expected cover time of the Fano line family is `163/30`. -/
theorem expCoverTime_fano : expCoverTime fanoLines = 163 / 30 := by
  native_decide

/-- The expected cover time of the `7` singletons is `363/20`. -/
theorem expCoverTime_singletons_seven :
    expCoverTime (singletonFamily (Fin 7)) = 363 / 20 := by
  native_decide

/-- `7 · H₇ = 363/20`. -/
theorem seven_harmonic_seven : (7 : ℚ) * harmonic 7 = 363 / 20 := by
  native_decide

/-! ### The corrected comparison -/

/-- The Fano line family covers the plane strictly faster than collecting `7` singletons:
`expCoverTime fanoLines < expCoverTime (singletonFamily (Fin 7))`. -/
theorem fano_lt_singletons :
    expCoverTime fanoLines < expCoverTime (singletonFamily (Fin 7)) := by
  native_decide

/-- Equivalently, the Fano cover time is strictly less than `7 · H₇`. -/
theorem fano_lt_sevenH : expCoverTime fanoLines < 7 * harmonic 7 := by
  native_decide

/-- The original task claim — that the Fano cover time *strictly exceeds* `7·H₇` — is false. -/
theorem original_exceeds_claim_is_false :
    ¬ (7 * harmonic 7 < expCoverTime fanoLines) := by
  native_decide

/-
The originally requested statement was:

    theorem fano_exceeds : 7 * harmonic 7 < expCoverTime fanoLines

This is FALSE: `expCoverTime fanoLines = 163/30 ≈ 5.43`, while `7 * harmonic 7 = 363/20 = 18.15`.
See `original_exceeds_claim_is_false` for the formal refutation and `fano_lt_sevenH` for the
correct inequality.
-/

end CouponCover