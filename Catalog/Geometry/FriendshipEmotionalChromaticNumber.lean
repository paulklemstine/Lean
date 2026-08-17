/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Emotional Chromatic Number of the Friendship (Windmill) Graph

This file bridges the two strands of the "Graph Coloring with Emotions" thread:

* the *quantitative* closed form for the chromatic counting function of the friendship graph
  `F_n` developed in `Catalog.Novelty.FriendshipChromaticPolynomial`
  (`chromVal_friendship : P(F_n, q) = q · ((q-1)(q-2))^n`), and
* the *qualitative* emotional-chromatic-number invariant `emoChrom` developed in
  `Catalog.Novelty.EmotionalChromaticNumber` (the least number of emotions `k ≥ 3` that
  suffice to colour a social network).

It closes future direction 6 of that thread by concluding, for every `n`, that the emotional
chromatic number of the friendship network `F_n` is exactly `3` — the emotional floor — safely inside
the six-emotion window `[3, 6]`.

## Main results

* `emoChrom_friendship` : `emoChrom (F_n) = 3` for every `n`.
* `emoChrom_friendship_within_window` : `3 ≤ emoChrom (F_n) ∧ emoChrom (F_n) ≤ 6`.
* `chromVal_emoChrom_friendship` : evaluating the counting function at the emotional chromatic number
  gives `P(F_n, emoChrom (F_n)) = 3 · 2^n`, the number of consistent assignments at the floor.
-/

import Geometry.FriendshipChromaticPolynomial
import Geometry.EmotionalChromaticNumber
namespace Catalog.Novelty.FriendshipEmotionalChromaticNumber

open Catalog.Novelty.FriendshipChromaticPolynomial
open Catalog.Novelty.EmotionalChromaticNumber

/-- **The emotional chromatic number of the friendship graph is `3`.**  Three emotions always
suffice (`friendship_colorable_three`) and, being at least the emotional floor, `emoChrom` cannot
drop below `3`; hence it is exactly `3` for every `n` (including the degenerate lone-centre case
`n = 0`).  This closes the "bridge to `emoChrom`" future direction of the thread. -/
theorem emoChrom_friendship (n : ℕ) : emoChrom (friendship n) = 3 :=
  (emoChrom_eq_three_iff (friendship n)).mpr (friendship_colorable_three n)

/-- The emotional chromatic number of every friendship network lies inside the six-basic-emotions
window `[3, 6]`. -/
theorem emoChrom_friendship_within_window (n : ℕ) :
    3 ≤ emoChrom (friendship n) ∧ emoChrom (friendship n) ≤ 6 := by
  rw [emoChrom_friendship]; exact ⟨le_rfl, by norm_num⟩

/-- Evaluating the chromatic counting function at the emotional chromatic number of `F_n` counts the
consistent assignments available at the emotional floor: `P(F_n, emoChrom (F_n)) = 3 · 2^n`. -/
theorem chromVal_emoChrom_friendship (n : ℕ) :
    chromVal n (emoChrom (friendship n)) = 3 * 2 ^ n := by
  rw [emoChrom_friendship, chromVal_friendship]

/-- For a nonempty friendship network, the emotional chromatic number coincides with the ordinary
chromatic number: both equal `3`.  (For `n = 0` the chromatic number is `1` while the emotional floor
keeps `emoChrom` at `3`, so nonemptiness is genuinely needed here.) -/
theorem emoChrom_eq_chromaticNumber_friendship {n : ℕ} (hn : 1 ≤ n) :
    (emoChrom (friendship n) : ℕ∞) = (friendship n).chromaticNumber := by
  rw [emoChrom_friendship, friendship_chromaticNumber hn]; norm_cast

end Catalog.Novelty.FriendshipEmotionalChromaticNumber