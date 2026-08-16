/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Chromatic Thresholds for Emotion Assignments

A finite social network is represented by a simple graph.  Its emotional chromatic number is the
least admissible palette size at or above three, while its chromatic counting function records the
number of proper assignments.  The results below identify these order-theoretic and enumerative
views exactly, and then specialize the bridge to friendship networks.

-- !-- Lab Notes -- !--
HYPOTHESIS.  Six falsifiable targets were ranked by expected impact.
  (1) [Famous-open-problem subtask, bold] A positivity-threshold reformulation of Hadwiger's
      conjecture should turn clique-minor forcing into a vanishing statement for all palettes below
      the minor order.
  (2) [Famous-open-problem subtask, bold] Distinguishing zero from positivity for succinct chromatic
      evaluations should retain the hardness boundary of graph colorability, linking the threshold
      to the P versus NP problem.
  (3) [Famous-open-problem subtask, bold] Restricted families of triangle-free graphs should expose
      quantitative chromatic thresholds relevant to the Erdős high-girth, high-chromatic-number
      phenomenon.
  (4) [Cross-domain bridge] Above the three-emotion floor, the emotional chromatic number should be
      the exact positivity threshold of the chromatic counting function.
  (5) [Cross-domain bridge] A candidate palette should be minimal exactly when its count is positive
      and every smaller admissible palette is a root.
  (6) [Cross-domain bridge] Friendship geometry should have an explicit two-scale profile at the
      minimum palette and at the six-emotion palette.
The first three are retained as long-range targets; the last three form the fully resolved target
of this cycle, linking graph geometry, finite enumeration, order theory, and network modeling.

EXPERIMENT.  Small cases supplied an adversarial check: a single edge has two proper two-colorings,
a triangle has six proper three-colorings, and the friendship formula predicts `3 * 2^n` at the
minimum palette and `6 * 20^n` at six.  Thus the proposed universal bipartite root at two fails
already on one edge.  The threshold was then split into two directions.  Minimality of the infimum gives the
forward implication.  For the reverse implication, an attained coloring at the minimum is enlarged
to the proposed palette.  Positivity is then substituted using the catalog's colorability oracle.
The friendship graph was tested through its independent closed-form count.

ANALYSIS.  The surviving invariant is a truncated positivity threshold: restriction to palettes
of size at least three replaces the ordinary chromatic threshold by its intersection with the
interval `[3,∞)`.  Consequently, all smaller admissible values vanish exactly when the candidate is
minimal.  The six-emotion condition is therefore equivalent to a single positive evaluation at six.

CRITIQUE.  The claim that every bipartite graph has a root at two is false; a single edge has two
proper two-colorings.  No theorem below uses that claim.  The floor is imposed by the definition,
not inferred from bipartiteness.  Empty and edgeless graphs are covered: they still have emotional
chromatic number three.  Every result has substantive hypotheses and uses an attained coloring,
monotonicity, a positivity oracle, or the friendship counting formula.

SYNTHESIS.  The emotional chromatic number is characterized both by an upper-threshold law and by
a minimal-positive-value law.  The latter simultaneously records positivity at the selected palette
and vanishing at every smaller admissible palette.  For friendship networks this yields the exact
minimum-palette count `3 * 2^n` and the six-palette count `6 * 20^n`.
-- !-- End Lab Notes -- !--
-/

import Geometry.FriendshipEmotionalChromaticNumber
namespace Catalog.Geometry.GraphColoringEmotions

open SimpleGraph
open Catalog.Combinatorics.ChromaticPolynomial
open Catalog.Novelty.EmotionalChromaticNumber
open Catalog.Novelty.FriendshipChromaticPolynomial
open Catalog.Novelty.FriendshipEmotionalChromaticNumber

variable {V : Type*} [Fintype V] [DecidableEq V]

omit [DecidableEq V] in
/-- Above the emotional floor, a palette bounds the emotional chromatic number exactly when it
supports a proper assignment.
-/
theorem emoChrom_le_iff_colorable (G : SimpleGraph V) {k : ℕ} (hk : 3 ≤ k) :
    emoChrom G ≤ k ↔ G.Colorable k := by
  constructor;
  · exact fun h => by have := emoChrom_colorable G; exact this.mono h;
  · exact fun h => emoChrom_le G hk h

/-- Above the emotional floor, positivity of the chromatic counting function is equivalent to
crossing the emotional chromatic threshold.
-/
theorem emoChrom_le_iff_chromVal_pos (G : SimpleGraph V) [DecidableRel G.Adj]
    {k : ℕ} (hk : 3 ≤ k) :
    emoChrom G ≤ k ↔ 0 < chromVal G k := by
  exact emoChrom_le_iff_colorable G hk |>.trans <| chromVal_pos_iff_colorable G k |> Iff.symm

/-- A palette size is the emotional chromatic number exactly when its counting value is positive
and every smaller palette above the emotional floor has counting value zero.
-/
theorem emoChrom_eq_iff_minimal_positive (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) :
    emoChrom G = k ↔
      3 ≤ k ∧ 0 < chromVal G k ∧
        ∀ j : ℕ, 3 ≤ j → j < k → chromVal G j = 0 := by
  constructor;
  · intro hk;
    refine' ⟨ hk ▸ emoChrom_ge_three G, _, _ ⟩;
    · exact hk ▸ ( emoChrom_colorable G ) |> fun h => chromVal_pos_iff_colorable G k |>.2 h;
    · intro j hj₁ hj₂
      have h_colorable : ¬G.Colorable j := by
        exact fun h => hj₂.not_ge ( hk ▸ emoChrom_le G hj₁ h );
      exact Nat.eq_zero_of_not_pos fun h => h_colorable <| by simpa using chromVal_pos_iff_colorable G j |>.1 h;
  · intro h
    apply le_antisymm;
    · apply emoChrom_le_iff_chromVal_pos G h.left |>.2 h.right.left;
    · contrapose! h;
      refine' fun hk hk' => ⟨ emoChrom G, _, _, _ ⟩;
      · exact emoChrom_ge_three G;
      · exact h;
      · exact ne_of_gt ( chromVal_pos_iff_colorable G _ |>.2 ( emoChrom_colorable G ) )

/-- Six basic emotions suffice exactly when the chromatic counting function is positive at six;
in that event the emotional chromatic number lies in the interval from three through six.
-/
theorem six_emotions_characterization (G : SimpleGraph V) [DecidableRel G.Adj] :
    (0 < chromVal G 6 ↔ 3 ≤ emoChrom G ∧ emoChrom G ≤ 6) := by
  have hthreshold := emoChrom_le_iff_chromVal_pos G (show 3 ≤ 6 by norm_num)
  constructor
  · intro hpos
    exact ⟨emoChrom_ge_three G, hthreshold.mpr hpos⟩
  · rintro ⟨_, hle⟩
    exact hthreshold.mp hle

/-- Friendship networks realize the threshold bridge in closed form: three is the minimum
admissible palette, with `3 * 2^n` assignments there and `6 * 20^n` assignments at six.
-/
theorem friendship_threshold_profile (n : ℕ) :
    emoChrom (friendship n) = 3 ∧
      chromVal n (emoChrom (friendship n)) = 3 * 2 ^ n ∧
      chromVal n 6 = 6 * 20 ^ n := by
  convert Catalog.Novelty.FriendshipEmotionalChromaticNumber.emoChrom_friendship n using 1;
  constructor <;> intro h <;> simp_all +decide [ Catalog.Novelty.FriendshipChromaticPolynomial.chromVal_friendship ]

end Catalog.Geometry.GraphColoringEmotions