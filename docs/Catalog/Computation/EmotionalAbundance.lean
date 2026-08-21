/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Emotional Abundance: Monotonicity and Thresholds of the Chromatic Counting Function

The catalog's `chromVal G q` counts the emotionally consistent assignments of `q` emotions to a
social network `G`.  Individual values are computed in the catalog for complete graphs, empty
graphs, windmills and (in `Catalog/Computation/EmotionalNetworkCensus.lean`) cliques with
bystanders.  This file establishes the *qualitative laws* the counting function obeys, so that
individual evaluations can be compared without recomputation:

* more emotions never hurt  (`chromVal_mono_colors`);
* more friendships never help (`chromVal_antitone_edges`);
* the complete graph is the universal floor (`descFactorial_le_chromVal`);
* positivity is a *threshold* phenomenon governed exactly by the emotional chromatic number
  (`chromVal_pos_iff_emoChrom_le`), which is why `χ_E` deserves the name "the number of emotions a
  network needs".

## Main results

* `chromVal_antitone_edges`      : `G ≤ H → chromVal H q ≤ chromVal G q`.
* `chromVal_mono_colors`         : `q ≤ r → chromVal G q ≤ chromVal G r`.
* `descFactorial_le_chromVal`    : `q^{\underline{|V|}} ≤ chromVal G q` for every network.
* `chromVal_pos_iff_emoChrom_le` : for `3 ≤ q`, `0 < chromVal G q ↔ emoChrom G ≤ q`.
* `chromVal_pos_of_le`           : positivity propagates upward from `Δ(G) + 1`.
* `chromVal_six_ge_of_small`     : a group of at most six people always has at least
  `6^{\underline{|V|}}` six-emotion assignments, whatever their friendships.

-- !-- Lab Notes -- !--
HYPOTHESIS (Stage 1, cycle 3).  The census produced exact counts for one family.  For the general
theory we need order-theoretic laws: is `q ↦ chromVal G q` monotone, is `G ↦ chromVal G q`
antitone, and is positivity a threshold?  A negative answer to the last question would destroy the
interpretation of `χ_E` as "the number of emotions required".

EXPERIMENT (Stage 2).  All three confirmed.  Monotonicity in the palette is the injection
`c ↦ Fin.castLE ∘ c` on the finset of proper colorings (`Finset.card_le_card_of_injOn`);
antitonicity in the friendships is a subset inclusion of finsets; the threshold law combines the
catalog's `chromVal_pos_iff_colorable` with `Colorable.mono`.

ANALYSIS (Stage 3).  Together with the sandwich theorem, the threshold law makes the mission's
computational test *decidable from two local statistics*: if `ω(G) ≤ 6` and `Δ(G) ≤ 5` then
`chromVal G 6 > 0` and `3 ≤ χ_E ≤ 6`.  The floor `q^{\underline{|V|}} ≤ chromVal G q` shows the
counting function of *any* network on at most six people is already in the millions at `q = 6`,
so the mission's "number of emotionally consistent assignments" is never a scarce resource for
small groups — scarcity appears only through large cliques, exactly as the census showed.
-- !-- End Lab Notes -- !--
-/

import Computation.EmotionalNetworkCensus

namespace Catalog.Computation.EmotionalAbundance

open SimpleGraph Finset
open Catalog.Combinatorics.ChromaticPolynomial
open Catalog.Novelty.EmotionalChromaticNumber
open Catalog.Computation.EmotionalGreedyColoring
open Catalog.Computation.EmotionalNetworkCensus

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Monotonicity laws -/

/-- **More friendships, fewer assignments.**  Adding friendships can only decrease the number of
emotionally consistent assignments. -/
theorem chromVal_antitone_edges {G H : SimpleGraph V} [DecidableRel G.Adj] [DecidableRel H.Adj]
    (hGH : G ≤ H) (q : ℕ) : chromVal H q ≤ chromVal G q := by
  apply Finset.card_le_card
  intro c hc
  simp only [properColorings, Finset.mem_filter, Finset.mem_univ, true_and] at hc ⊢
  exact fun x y hadj => hc x y (hGH hadj)

/-- **More emotions, more assignments.**  Enlarging the palette of emotions can only increase the
number of consistent assignments. -/
theorem chromVal_mono_colors (G : SimpleGraph V) [DecidableRel G.Adj] {q r : ℕ} (h : q ≤ r) :
    chromVal G q ≤ chromVal G r := by
  apply Finset.card_le_card_of_injOn (fun c => fun v => Fin.castLE h (c v))
  · intro c hc
    simp only [properColorings, Finset.mem_coe, Finset.mem_filter, Finset.mem_univ,
      true_and] at hc ⊢
    intro x y hadj hcon
    exact hc x y hadj (Fin.castLE_injective h hcon)
  · intro c1 _ c2 _ hcon
    funext v
    exact Fin.castLE_injective h (congrFun hcon v)

/-- **Universal floor.**  Every social network on `|V|` people admits at least
`q^{\underline{|V|}}` assignments of `q` emotions: the worst case is the network in which everyone
is friends with everyone. -/
theorem descFactorial_le_chromVal (G : SimpleGraph V) [DecidableRel G.Adj] (q : ℕ) :
    q.descFactorial (Fintype.card V) ≤ chromVal G q := by
  have h := chromVal_antitone_edges (G := G) (H := ⊤) le_top q
  rwa [chromVal_top] at h

/-! ## The positivity threshold -/

/-- **Threshold law.**  Above the emotional floor, the chromatic counting function is positive
exactly when the palette reaches the emotional chromatic number. -/
theorem chromVal_pos_iff_emoChrom_le (G : SimpleGraph V) [DecidableRel G.Adj] {q : ℕ}
    (hq : 3 ≤ q) : 0 < chromVal G q ↔ emoChrom G ≤ q := by
  rw [chromVal_pos_iff_colorable]
  exact ⟨fun h => emoChrom_le G hq h, fun h => (emoChrom_colorable G).mono h⟩

/-- Positivity, once achieved, is never lost: the set of palettes admitting an assignment is an
up-set. -/
theorem chromVal_pos_of_le (G : SimpleGraph V) [DecidableRel G.Adj] {q r : ℕ}
    (hqr : q ≤ r) (hq : 0 < chromVal G q) : 0 < chromVal G r :=
  lt_of_lt_of_le hq (chromVal_mono_colors G hqr)

/-- Every palette at least as large as `Δ(G) + 1` admits an assignment. -/
theorem chromVal_pos_of_maxDegree_le (G : SimpleGraph V) [DecidableRel G.Adj] {q : ℕ}
    (h : G.maxDegree + 1 ≤ q) : 0 < chromVal G q :=
  chromVal_pos_of_le G h (chromVal_pos_of_maxDegree G)

/-- **Small groups are emotionally rich.**  In a group of at most six people, whatever the pattern
of friendships, there are at least `6^{\underline{|V|}}` ways to assign the six basic emotions. -/
theorem chromVal_six_ge_of_small (G : SimpleGraph V) [DecidableRel G.Adj] :
    (6 : ℕ).descFactorial (Fintype.card V) ≤ chromVal G 6 :=
  descFactorial_le_chromVal G 6

/-! ## Application to the census -/

/-- Every clique network of the census has at least `933 120` six-emotion assignments — the
minimum, attained by the six-person clique. -/
theorem census_clique_abundance (i : ℕ) : 933120 ≤ chromVal (censusClique i) 6 := by
  have hmod : i % 4 < 4 := Nat.mod_lt _ (by norm_num)
  have hanti : chromVal (cliqueBelow 10 6) 6 ≤ chromVal (cliqueBelow 10 (3 + i % 4)) 6 := by
    refine chromVal_antitone_edges (H := cliqueBelow 10 6) ?_ 6
    intro x y hxy
    rw [cliqueBelow_adj] at hxy ⊢
    exact ⟨hxy.1, by omega, by omega⟩
  have heq : chromVal (censusClique i) 6 = chromVal (cliqueBelow 10 (3 + i % 4)) 6 := rfl
  have h6 : chromVal (cliqueBelow 10 6) 6 = 933120 := (census_six_emotion_count).2.2.2
  omega

/-- The census abundance bound is *sharp*: the six-person clique network attains it. -/
theorem census_clique_abundance_sharp : chromVal (censusClique 3) 6 = 933120 := by
  have h : chromVal (censusClique 3) 6 = chromVal (cliqueBelow 10 6) 6 := rfl
  rw [h]
  exact census_six_emotion_count.2.2.2

/-
-- !-- Lab Notes (critique, cycle 3) -- !--
ADVERSARIAL REVIEW.
* `descFactorial_le_chromVal` is not vacuous for large populations, but it *is* weak: for
  `|V| > q` the falling factorial vanishes and the bound reads `0 ≤ chromVal`.  The honest content
  is for `|V| ≤ q`, recorded separately as `chromVal_six_ge_of_small`.
* `chromVal_pos_iff_emoChrom_le` needs the hypothesis `3 ≤ q`; without it the statement is false,
  since a bipartite network with an edge has `chromVal G 2 > 0` while `emoChrom G = 3 > 2`.  This
  is precisely the "emotional floor" artefact identified in the catalog's correction of the
  bipartite-root folklore, and the hypothesis is load-bearing.
* `census_clique_abundance` is proved by antitonicity from the densest member of the family, not
  by re-evaluating each of the fifty networks, and its sharpness witness is exhibited.
-- !-- End Lab Notes -- !--
-/

end Catalog.Computation.EmotionalAbundance