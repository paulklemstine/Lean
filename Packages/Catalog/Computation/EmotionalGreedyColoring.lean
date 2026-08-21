/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Greedy Emotion Assignment: a Degree Bound for the Emotional Chromatic Number

This file supplies the missing *upper* half of the emotional chromatic theory developed in
`Catalog/Geometry/EmotionalChromaticNumber.lean`.  There, `emoChrom G` (the least number of
emotions `k ≥ 3` for which a social network `G` admits an assignment of emotions with no two
friends sharing one) is shown to be `3` for cycles and `max n 3` for cliques, and to lie in the
window `[3, 6]` *whenever the network happens to be six-colorable*.  The hypothesis
"six-colorable" was, however, left unexplained: nothing in the catalog says which social networks
satisfy it.

Here we prove the greedy bound

  `G.Colorable (Δ(G) + 1)`   (`colorable_maxDegree_add_one`)

for every finite graph, where `Δ(G) = G.maxDegree` is the largest number of friends of any person.
Mathlib (v4.28.0) contains no such statement — `Mathlib/Combinatorics/SimpleGraph/Coloring.lean`
has only the trivial `colorable_of_fintype` bound `χ(G) ≤ |V|` — so the greedy argument is
developed from scratch, by induction over a finset of already-colored people.

The consequence for the psychology model is sharp and checkable on real data:

  **if nobody has more than five friends, the six basic emotions always suffice**
  (`six_emotions_suffice`).

## Main results

* `exists_proper_coloring_on_finset` : greedy induction — a `d + 1` palette properly colors any
  finset of people, provided every person has at most `d` friends.
* `colorable_of_degree_le`           : `(∀ v, G.degree v ≤ d) → G.Colorable (d + 1)`.
* `colorable_maxDegree_add_one`      : `G.Colorable (G.maxDegree + 1)`.
* `emoChrom_le_maxDegree_add_one`    : `emoChrom G ≤ max (Δ(G) + 1) 3`.
* `six_emotions_suffice`             : `Δ(G) ≤ 5 → 3 ≤ emoChrom G ∧ emoChrom G ≤ 6`.
* `chromVal_pos_of_maxDegree`        : the chromatic polynomial is *strictly positive* at
  `Δ(G) + 1`, so the emotional count of assignments is nonzero there.
* `emoChrom_le_card`                 : the universal fallback `emoChrom G ≤ max |V| 3`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Stage 1).  The mission's empirical claim — "the emotional chromatic number of a real
social network is between 3 and 6" — should not be an empirical accident but a theorem about
sparse graphs: social networks have bounded local degree, and bounded degree forces small
chromatic number.

EXPERIMENT (Stage 2).  We searched Mathlib for a greedy/Brooks-type bound and found none, so the
greedy colouring theorem itself became the experiment.  The proof that worked colors people one at
a time along an arbitrary enumeration (`Finset.induction_on`), maintaining a partial assignment; at
each step the new person `a` sees at most `deg a ≤ d` already-colored friends, hence at most `d`
forbidden emotions out of `d + 1`, and a free emotion exists by pigeonhole
(`Finset.card_image_le` composed with `Finset.card_le_card`).  Formalizing the partial colorings as
*total* functions `V → Fin (d+1)` that are proper *only on the finset* avoided every induced
subgraph / subtype coercion; this reformulation is what made the induction go through.

DATA.  `Δ = 0` (no friendships) gives `Colorable 1`; `Δ = 1` (pairings) gives `Colorable 2`;
`Δ = 2` (chains and circles) gives `Colorable 3`, matching `emoChrom (C_n) = 3` exactly;
`Δ = 5` gives `Colorable 6`, the six basic emotions.  The bound is tight on cliques
(`Δ(K_n) = n - 1`, `χ(K_n) = n`) and on odd cycles (`Δ = 2`, `χ = 3`), and loose on even cycles
(`Δ = 2`, `χ = 2`) — the emotional floor `≥ 3` repairs exactly that gap, which is why the
*emotional* chromatic number is better behaved than the classical one here.
-- !-- End Lab Notes -- !--
-/

import Geometry.EmotionalChromaticNumber

namespace Catalog.Computation.EmotionalGreedyColoring

open SimpleGraph Finset
open Catalog.Combinatorics.ChromaticPolynomial
open Catalog.Novelty.EmotionalChromaticNumber

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## The greedy induction -/

/-- **Greedy colouring, partial form.**  If nobody in the network has more than `d` friends, then
for *any* set `s` of people there is an assignment of `d + 1` emotions to the whole population that
is emotionally consistent on `s` (no two friends inside `s` share an emotion).

The proof colors the people of `s` one at a time: a newly added person sees at most `d` already
colored friends, so at most `d` of the `d + 1` emotions are forbidden. -/
theorem exists_proper_coloring_on_finset (G : SimpleGraph V) [DecidableRel G.Adj] {d : ℕ}
    (hd : ∀ v, G.degree v ≤ d) (s : Finset V) :
    ∃ c : V → Fin (d + 1), ∀ x ∈ s, ∀ y ∈ s, G.Adj x y → c x ≠ c y := by
  classical
  induction s using Finset.induction_on with
  | empty => exact ⟨fun _ => 0, by simp⟩
  | @insert a s ha ih =>
      obtain ⟨c, hc⟩ := ih
      -- The emotions already used by the friends of `a` inside `s`.
      set T : Finset (Fin (d + 1)) := (G.neighborFinset a ∩ s).image c with hT
      have hTcard : T.card < d + 1 := by
        have h1 : T.card ≤ (G.neighborFinset a ∩ s).card := Finset.card_image_le
        have h2 : (G.neighborFinset a ∩ s).card ≤ (G.neighborFinset a).card :=
          Finset.card_le_card Finset.inter_subset_left
        have h3 : (G.neighborFinset a).card = G.degree a := rfl
        have h4 := hd a
        omega
      -- Pigeonhole: some emotion is still free for `a`.
      obtain ⟨b, hb⟩ : ∃ b : Fin (d + 1), b ∉ T := by
        by_contra h
        push_neg at h
        have hsub : (Finset.univ : Finset (Fin (d + 1))) ⊆ T := fun x _ => h x
        have hcard := Finset.card_le_card hsub
        simp only [Finset.card_univ, Fintype.card_fin] at hcard
        omega
      refine ⟨Function.update c a b, ?_⟩
      intro x hx y hy hadj
      have hxy : x ≠ y := hadj.ne
      rcases Finset.mem_insert.1 hx with rfl | hxs
      · rcases Finset.mem_insert.1 hy with rfl | hys
        · exact absurd rfl hxy
        · have hya : y ≠ x := fun h => ha (h ▸ hys)
          rw [Function.update_self, Function.update_of_ne hya]
          intro hcon
          exact hb (hT ▸ Finset.mem_image.2
            ⟨y, Finset.mem_inter.2 ⟨by simpa using hadj, hys⟩, hcon.symm⟩)
      · rcases Finset.mem_insert.1 hy with rfl | hys
        · have hxa : x ≠ y := fun h => ha (h ▸ hxs)
          rw [Function.update_self, Function.update_of_ne hxa]
          intro hcon
          exact hb (hT ▸ Finset.mem_image.2
            ⟨x, Finset.mem_inter.2 ⟨by simpa using hadj.symm, hxs⟩, hcon⟩)
        · have hxa : x ≠ a := fun h => ha (h ▸ hxs)
          have hya : y ≠ a := fun h => ha (h ▸ hys)
          rw [Function.update_of_ne hxa, Function.update_of_ne hya]
          exact hc x hxs y hys hadj

/-! ## The degree bound -/

/-- **Greedy bound.**  A social network in which nobody has more than `d` friends can be given a
consistent assignment of `d + 1` emotions. -/
theorem colorable_of_degree_le (G : SimpleGraph V) [DecidableRel G.Adj] {d : ℕ}
    (hd : ∀ v, G.degree v ≤ d) : G.Colorable (d + 1) := by
  obtain ⟨c, hc⟩ := exists_proper_coloring_on_finset G hd Finset.univ
  exact ⟨SimpleGraph.Coloring.mk c
    (fun {x y} hadj => hc x (Finset.mem_univ _) y (Finset.mem_univ _) hadj)⟩

/-- **Greedy bound, maximum-degree form**: `χ(G) ≤ Δ(G) + 1`.  (Absent from Mathlib v4.28.0.) -/
theorem colorable_maxDegree_add_one (G : SimpleGraph V) [DecidableRel G.Adj] :
    G.Colorable (G.maxDegree + 1) :=
  colorable_of_degree_le G (fun v => G.degree_le_maxDegree v)

/-- The classical chromatic number is bounded by the maximum degree plus one. -/
theorem chromaticNumber_le_maxDegree_add_one (G : SimpleGraph V) [DecidableRel G.Adj] :
    G.chromaticNumber ≤ (G.maxDegree + 1 : ℕ) :=
  chromaticNumber_le_iff_colorable.2 (colorable_maxDegree_add_one G)

/-! ## Consequences for the emotional chromatic number -/

/-- **Emotional greedy bound.**  The number of emotions actually needed by a social network never
exceeds one more than the largest friend count — subject to the emotional floor `3`. -/
theorem emoChrom_le_maxDegree_add_one (G : SimpleGraph V) [DecidableRel G.Adj] :
    emoChrom G ≤ max (G.maxDegree + 1) 3 :=
  emoChrom_le G (le_max_right _ _)
    ((colorable_maxDegree_add_one G).mono (le_max_left _ _))

/-- **Six emotions suffice.**  If everybody in the social network has at most five friends, then
the emotional chromatic number lies in the window `[3, 6]`: happiness, sadness, anger, fear,
disgust and surprise can always be distributed consistently, and three emotions are always
needed. -/
theorem six_emotions_suffice (G : SimpleGraph V) [DecidableRel G.Adj]
    (h : G.maxDegree ≤ 5) : 3 ≤ emoChrom G ∧ emoChrom G ≤ 6 := by
  refine ⟨emoChrom_ge_three G, ?_⟩
  have h1 : emoChrom G ≤ max (G.maxDegree + 1) 3 := emoChrom_le_maxDegree_add_one G
  have h2 : max (G.maxDegree + 1) 3 ≤ 6 := max_le (by omega) (by norm_num)
  omega

/-- Degree-bounded networks have a *positive* chromatic polynomial value at `d + 1`: there really
are emotionally consistent assignments to count. -/
theorem chromVal_pos_of_degree_le (G : SimpleGraph V) [DecidableRel G.Adj] {d : ℕ}
    (hd : ∀ v, G.degree v ≤ d) : 0 < chromVal G (d + 1) :=
  (chromVal_pos_iff_colorable G (d + 1)).2 (colorable_of_degree_le G hd)

/-- The chromatic polynomial of any finite network is strictly positive at `Δ(G) + 1`. -/
theorem chromVal_pos_of_maxDegree (G : SimpleGraph V) [DecidableRel G.Adj] :
    0 < chromVal G (G.maxDegree + 1) :=
  chromVal_pos_of_degree_le G (fun v => G.degree_le_maxDegree v)

/-- A network with at most five friends per person has a positive number of assignments of the six
basic emotions. -/
theorem chromVal_six_pos_of_maxDegree_le_five (G : SimpleGraph V) [DecidableRel G.Adj]
    (h : G.maxDegree ≤ 5) : 0 < chromVal G 6 :=
  (chromVal_pos_iff_colorable G 6).2
    ((colorable_maxDegree_add_one G).mono (by omega))

omit [DecidableEq V] in
/-- The universal fallback bound: a population of `|V|` people never needs more than
`max |V| 3` emotions. -/
theorem emoChrom_le_card (G : SimpleGraph V) :
    emoChrom G ≤ max (Fintype.card V) 3 :=
  emoChrom_le G (le_max_right _ _) ((colorable_of_fintype G).mono (le_max_left _ _))

/-
-- !-- Lab Notes (analysis) -- !--
SURVIVED.  The greedy theorem `colorable_maxDegree_add_one`, its emotional corollary
`six_emotions_suffice`, and the strict positivity `chromVal_pos_of_maxDegree` of the chromatic
polynomial at `Δ + 1`.  Together they convert the mission's empirical claim ("χ_E is between 3 and
6 for most networks") into a verifiable structural criterion: *degree at most five*.

WHY THE NAIVE ROUTE FAILED.  An induction deleting one vertex at a time and passing to
`G.induce {v | v ≠ x}` forces one to re-prove `degree_induce_le`, which Mathlib does not have, and
drags subtype coercions through every step.  Carrying total functions `V → Fin (d+1)` that are only
required to be proper on a finset removes the obstruction entirely: the induction hypothesis is
about the *same* graph throughout.

BOUNDARY.  `six_emotions_suffice` is sharp: `K_6` has `Δ = 5` and `emoChrom = 6`, so `6` cannot be
lowered; and `K_7` has `Δ = 6` and `emoChrom = 7 > 6`, so the hypothesis cannot be weakened.
-- !-- End Lab Notes -- !--
-/

end Catalog.Computation.EmotionalGreedyColoring