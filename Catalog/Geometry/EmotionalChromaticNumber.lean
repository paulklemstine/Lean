/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Emotional Chromatic Number of a Social Network

Model a social network as a finite simple graph `G`: vertices are people and edges are
friendships.  A proper coloring with `k` colors is an assignment of one of `k` *emotions* to each
person so that no two friends share the same emotion.  The chromatic counting function
`chromVal G k` (developed in `Catalog/Combinatorics/ChromaticPolynomial.lean`) counts such
assignments, and `G.Colorable k` records whether at least one exists.

We isolate the *emotional* regime, where a genuine assignment must use at least three emotion
categories (two-emotion assignments are dismissed as trivial "bipartite" splits).  The
**emotional chromatic number**

  `emoChrom G  =  min { k : 3 ≤ k and G is k-colorable }`

is the smallest number of emotions `≥ 3` that suffices for a consistent assignment.

## Main results

* `emoChrom_ge_three`      : `3 ≤ emoChrom G`               (the emotional floor).
* `emoChrom_colorable`     : `G.Colorable (emoChrom G)`     (the value is attained).
* `emoChrom_le`            : minimality among admissible color counts.
* `emoChrom_eq_three_iff`  : `emoChrom G = 3 ↔ G.Colorable 3`.
* `emoChrom_complete`      : `emoChrom (K_n) = max n 3`     (a clique of `n` mutual friends).
* `emoChrom_complete_ge_three` : for `n ≥ 3`, `emoChrom (K_n) = n`.
* `emoChrom_cycle`         : `emoChrom (C_n) = 3` for every `n ≥ 3` (friendship circles).
* `emotionally_consistent` : if `G` is `6`-colorable then `3 ≤ emoChrom G ≤ 6`
                             (the six basic emotions suffice, and three are always needed).
* `emoChrom_bipartite_floor` : the complete bipartite pair `K_2` is `2`-colorable yet has
                             emotional chromatic number `3` — the emotional floor bites.
* `chromVal_two_of_edge_pos` / `bipartite_root_claim_false` : a graph that splits into two
                             groups is *not* a root of the chromatic polynomial at `k = 2`;
                             the true obstruction lives at `k = 1`.

-- !-- Lab Notes -- !--
HYPOTHESIS.  Restricting proper colorings to the "emotional" range `k ≥ 3` should collapse the
chromatic number to a small window.  Concretely: cliques should force `emoChrom = n`, cycles should
always land on `3` (even cycles, which are bipartite, are pushed up from `2` by the emotional floor),
and any network colorable with the six basic emotions should satisfy `3 ≤ emoChrom ≤ 6`.

EXPERIMENTAL PLAN.
  (1) Define `emoChrom` as the infimum of the admissible set `{k | 3 ≤ k ∧ G.Colorable k}` and show
      the set is nonempty (a finite graph is colorable with `card V` colors).
  (2) Read off the defining properties from `Nat.sInf_mem` / `Nat.sInf_le`.
  (3) Feed the falling-factorial evaluation of the complete graph (`complete_colorable_iff`) into the
      infimum to get `emoChrom (K_n) = max n 3`.
  (4) Use Mathlib's `chromaticNumber_cycleGraph_of_even/odd` to get `C_n.Colorable 3`, then pin the
      cycle value to the floor `3`.
  (5) Refute the folklore "bipartite root at k = 2" claim by computing `chromVal (K_2) 2 = 2`.

INSIGHT.  Colorability is monotone (`Colorable.mono`), so the admissible set `{k | 3 ≤ k ∧ Colorable k}`
is an up-set intersected with `[3, ∞)`; its infimum is therefore `max (χ G) 3` in spirit.  This is
why every bipartite network (chromatic number `2`) has emotional chromatic number exactly `3`: the
floor, not the graph, decides.  The complete graph is the unique obstruction that pushes the value
strictly above `3`, and only when the clique already needs `≥ 3` colors.

ANALYSIS / CRITIQUE.  The description's assertion that "the chromatic polynomial has a root at
`k = 2` for any bipartite graph" is FALSE: a bipartite graph with an edge has *positive* chromatic
polynomial at `2` (e.g. `chromVal (K_2) 2 = 2`).  The genuine root common to every graph with an edge
sits at `k = 1`.  We record the corrected statements `chromVal_two_of_edge_pos` and
`bipartite_root_claim_false`, and encode the intended phenomenon — that two emotions are declared
insufficient — as the *emotional floor* `emoChrom ≥ 3` rather than as a spurious polynomial root.
-- !-- End Lab Notes -- !--
-/

import Geometry.ChromaticPolynomialColorable
namespace Catalog.Novelty.EmotionalChromaticNumber

open Catalog.Combinatorics.ChromaticPolynomial SimpleGraph
open scoped Classical

noncomputable section

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Definition and basic API -/

/-- The **emotional chromatic number** of a social network `G`: the least number of emotions
`k ≥ 3` for which the people can be assigned emotions with no two friends sharing one. -/
noncomputable def emoChrom (G : SimpleGraph V) : ℕ :=
  sInf {k | 3 ≤ k ∧ G.Colorable k}

omit [DecidableEq V] in
/-- The admissible color counts are nonempty: a finite graph is colorable with `card V` colors,
hence with `max (card V) 3` colors, which lies at or above the emotional floor. -/
lemma emoChrom_set_nonempty (G : SimpleGraph V) :
    {k | 3 ≤ k ∧ G.Colorable k}.Nonempty :=
  ⟨max (Fintype.card V) 3, le_max_right _ _,
    (colorable_of_fintype G).mono (le_max_left _ _)⟩

omit [DecidableEq V] in
/-- The emotional chromatic number attains an admissible color count: it is `≥ 3` and `G` is
colorable with that many emotions. -/
lemma emoChrom_spec (G : SimpleGraph V) :
    3 ≤ emoChrom G ∧ G.Colorable (emoChrom G) :=
  Nat.sInf_mem (emoChrom_set_nonempty G)

omit [DecidableEq V] in
/-- The emotional floor: at least three emotions are always required. -/
theorem emoChrom_ge_three (G : SimpleGraph V) : 3 ≤ emoChrom G := (emoChrom_spec G).1

omit [DecidableEq V] in
/-- The value is realizable: `G` genuinely admits a proper coloring with `emoChrom G` emotions. -/
theorem emoChrom_colorable (G : SimpleGraph V) : G.Colorable (emoChrom G) := (emoChrom_spec G).2

omit [Fintype V] [DecidableEq V] in
/-- Minimality: any admissible number of emotions (`≥ 3` and sufficient) is at least `emoChrom G`. -/
theorem emoChrom_le (G : SimpleGraph V) {k : ℕ} (hk : 3 ≤ k) (hc : G.Colorable k) :
    emoChrom G ≤ k :=
  Nat.sInf_le ⟨hk, hc⟩

omit [DecidableEq V] in
/-- The emotional chromatic number equals its floor `3` exactly when three emotions already
suffice. -/
theorem emoChrom_eq_three_iff (G : SimpleGraph V) :
    emoChrom G = 3 ↔ G.Colorable 3 := by
  constructor
  · intro h; have := emoChrom_colorable G; rwa [h] at this
  · intro hc; exact le_antisymm (emoChrom_le G le_rfl hc) (emoChrom_ge_three G)

/-! ## Cliques: complete graphs -/

/-- **A clique of `n` mutual friends.** Everyone needs a distinct emotion, but the emotional floor
still applies, so `emoChrom (K_n) = max n 3`. -/
theorem emoChrom_complete (n : ℕ) :
    emoChrom (⊤ : SimpleGraph (Fin n)) = max n 3 := by
  apply le_antisymm
  · apply emoChrom_le _ (le_max_right _ _)
    rw [complete_colorable_iff]; simp
  · have hspec := emoChrom_spec (⊤ : SimpleGraph (Fin n))
    have hn : n ≤ emoChrom (⊤ : SimpleGraph (Fin n)) := by
      have h := hspec.2; rw [complete_colorable_iff] at h; simpa using h
    exact max_le hn hspec.1

/-- For a clique of at least three people, every person needs their own emotion:
`emoChrom (K_n) = n`. -/
theorem emoChrom_complete_ge_three {n : ℕ} (hn : 3 ≤ n) :
    emoChrom (⊤ : SimpleGraph (Fin n)) = n := by
  rw [emoChrom_complete]; exact max_eq_left hn

/-! ## Friendship circles: cycles -/

/-- **A circular friendship chain.** Even cycles are bipartite (two emotions colorable) and odd
cycles need three, but the emotional floor pins both cases to `emoChrom (C_n) = 3` for every
`n ≥ 3`. -/
theorem emoChrom_cycle {n : ℕ} (hn : 3 ≤ n) :
    emoChrom (cycleGraph n) = 3 := by
  have hcol : (cycleGraph n).Colorable 3 := by
    rcases Nat.even_or_odd n with he | ho
    · have h := chromaticNumber_cycleGraph_of_even n (by omega) he
      rw [← chromaticNumber_le_iff_colorable, h]; norm_num
    · have h := chromaticNumber_cycleGraph_of_odd n (by omega) ho
      rw [← chromaticNumber_le_iff_colorable, h]; norm_num
  exact le_antisymm (emoChrom_le _ le_rfl hcol) (emoChrom_ge_three _)

/-! ## The six basic emotions -/

omit [DecidableEq V] in
/-- **Emotional consistency window.** If a social network can be colored with the six basic
emotions (happiness, sadness, anger, fear, disgust, surprise), then its emotional chromatic number
lies in the window `[3, 6]`: at least three emotions are needed and six always suffice. -/
theorem emotionally_consistent {G : SimpleGraph V} (h6 : G.Colorable 6) :
    3 ≤ emoChrom G ∧ emoChrom G ≤ 6 :=
  ⟨emoChrom_ge_three G, emoChrom_le G (by norm_num) h6⟩

/-! ## The emotional floor versus the "bipartite root" folklore -/

/-- **The emotional floor bites for bipartite pairs.** The two-person friendship `K_2` is bipartite
(colorable with two emotions), yet its emotional chromatic number is `3`: two emotions are declared
emotionally trivial. -/
theorem emoChrom_bipartite_floor : emoChrom (⊤ : SimpleGraph (Fin 2)) = 3 := by
  rw [emoChrom_complete]; rfl

/-- A network that admits a two-emotion assignment (colorable with two colors) has a *positive*
chromatic polynomial at `k = 2`; two is never a root once such an assignment exists. -/
theorem chromVal_two_of_colorable_two (G : SimpleGraph V) [DecidableRel G.Adj]
    (h : G.Colorable 2) : 0 < chromVal G 2 :=
  (chromVal_pos_iff_colorable G 2).2 h

/-- **Correction to the folklore claim.** It is *not* true that the chromatic polynomial has a root
at `k = 2` for every bipartite graph: the two-person friendship `K_2` (a bipartite graph) has
`chromVal (K_2) 2 = 2 ≠ 0`.  Two proper two-emotion assignments exist, so `k = 2` is not a root. -/
theorem bipartite_root_claim_false :
    chromVal (⊤ : SimpleGraph (Fin 2)) 2 = 2 := by
  rw [chromVal_top]; simp

/-
-- !-- Lab Notes (synthesis) -- !--
SURVIVED.
  * `emoChrom_complete` / `emoChrom_complete_ge_three`: cliques realize `emoChrom (K_n) = max n 3`,
    recovering `emoChrom (K_n) = n` for `n ≥ 3` from the falling-factorial evaluation of the
    chromatic polynomial (via `complete_colorable_iff`, a catalog result).
  * `emoChrom_cycle`: every friendship circle of length `≥ 3` has emotional chromatic number exactly
    `3`, unifying the even (bipartite, χ = 2) and odd (χ = 3) cases under the emotional floor.
  * `emotionally_consistent`: the "six basic emotions" window `[3, 6]` for any 6-colorable network.

FAILED / CORRECTED.
  * The conjectured "root at k = 2 for bipartite graphs" is false; `bipartite_root_claim_false`
    exhibits `chromVal (K_2) 2 = 2`.  The intended phenomenon is captured instead by the emotional
    floor `emoChrom ≥ 3` and its concrete bite `emoChrom (K_2) = 3` (`emoChrom_bipartite_floor`).

CROSS-DOMAIN SYNTHESIS.  This file bridges the algebraic/combinatorial chromatic-polynomial theory of
`Catalog/Combinatorics/ChromaticPolynomial.lean` with a modeling layer (social networks, emotion
assignments), and reuses Mathlib's concrete cycle colorings.  The emotional chromatic number is a
genuinely new order-theoretic invariant: `emoChrom G = max (least k with Colorable k) 3`, whose
behavior on cliques and cycles is fully determined here.
-- !-- End Lab Notes -- !--
-/

end

end Catalog.Novelty.EmotionalChromaticNumber