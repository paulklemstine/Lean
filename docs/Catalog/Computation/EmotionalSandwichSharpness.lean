/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Both Sides of the Sandwich Are Strict: the Hub-and-Circle Network

`Catalog/Computation/EmotionalChromaticSandwich.lean` proves
`max ω(G) 3 ≤ emoChrom G ≤ max (Δ(G) + 1) 3` for every finite social network.  The critique stage
of that cycle asked whether either side can be *simultaneously* strict — whether there is a network
whose emotional demand is genuinely between the "largest group of mutual friends" bound and the
"most popular person" bound.  This file answers yes, with an explicit six-person network.

**The hub-and-circle network** `wheelNet`: five people sit in a friendship circle, and a sixth
person (the hub) is friends with all five.  For it we verify

* `wheelNet_chromVal_three` : `chi(3) = 0`   — three emotions are impossible;
* `wheelNet_chromVal_four`  : `chi(4) = 120` — with four emotions there are exactly 120 consistent
  assignments (matching the wheel formula `q · ((q-2)^5 - (q-2))` at `q = 4`);
* `wheelNet_cliqueNum`      : `ω = 3`  — the largest group of mutual friends is a triangle;
* `wheelNet_maxDegree`      : `Δ = 5`  — the hub;
* `wheelNet_emoChrom`       : `emoChrom = 4`;
* `wheelNet_sandwich_strict`: `max ω 3 = 3 < 4 = emoChrom < 6 = max (Δ+1) 3`.

So neither the clique bound nor the greedy bound is attained: the emotional chromatic number is a
genuinely global quantity, not a function of the two local statistics.

-- !-- Lab Notes -- !--
HYPOTHESIS (Stage 1, cycle 5).  The sandwich might be an equality in one of its two sides for every
network, in which case `emoChrom` would be locally computable.  Falsify or confirm.

EXPERIMENT (Stage 2).  Falsified by the hub-and-circle network.  The counting facts are finite
checks over `Fin 6 → Fin q` verified by kernel reduction (`decide`), and everything about
`emoChrom` is then *derived* — `emoChrom = 4` follows from the catalog threshold law
`chromVal_pos_iff_colorable` plus the emotional floor, not from any further computation.  The
clique number is pinned by a structural argument: a clique of size `≥ 4` would contain a four-person
sub-clique, and no four-element subset of the six people is a clique.

ANALYSIS (Stage 3).  The gap is caused by the odd circle: the five circle-dwellers need three
emotions among themselves (odd cycle) and the hub needs a fourth, yet no four of them are mutual
friends.  This is the smallest instance of the general phenomenon that `χ - ω` is unbounded, and it
tells the psychology model that "emotional diversity" cannot be read off from either the largest
clique of friends or the most connected person.
-- !-- End Lab Notes -- !--
-/

import Computation.EmotionalChromaticSandwich

namespace Catalog.Computation.EmotionalSandwichSharpness

set_option maxRecDepth 100000

open SimpleGraph Finset
open Catalog.Combinatorics.ChromaticPolynomial
open Catalog.Novelty.EmotionalChromaticNumber
open Catalog.Computation.EmotionalChromaticSandwich

/-! ## The hub-and-circle network -/

/-- Friendship relation of the hub-and-circle network: person `5` (the hub) is friends with
everyone, and persons `0,1,2,3,4` sit in a circle. -/
def wheelRel (x y : Fin 6) : Prop :=
  (x.val = 5 ∧ y.val < 5) ∨ (x.val < 5 ∧ y.val < 5 ∧ (x.val + 1) % 5 = y.val)

instance : DecidableRel wheelRel := fun x y => by unfold wheelRel; infer_instance

/-- The **hub-and-circle network**: a friendship circle of five people together with one person
who is friends with all of them. -/
def wheelNet : SimpleGraph (Fin 6) := SimpleGraph.fromRel wheelRel

instance : DecidableRel wheelNet.Adj := fun x y => by
  unfold wheelNet SimpleGraph.fromRel
  infer_instance

/-! ## Finite verification of the chromatic counts -/

/-- Three emotions cannot be distributed consistently over the hub-and-circle network. -/
theorem wheelNet_chromVal_three : chromVal wheelNet 3 = 0 := by decide

/-- With four emotions there are exactly `120` consistent assignments — the value of the wheel
polynomial `q · ((q-2)^5 - (q-2))` at `q = 4`. -/
theorem wheelNet_chromVal_four : chromVal wheelNet 4 = 120 := by decide

/-- The hub has five friends, and nobody has more. -/
theorem wheelNet_maxDegree : wheelNet.maxDegree = 5 := by decide

/-- Persons `0`, `1` and the hub form a triangle. -/
theorem wheelNet_triangle : wheelNet.IsClique ((({0, 1, 5} : Finset (Fin 6)) : Set (Fin 6))) := by
  decide

/-- No four people in the network are mutual friends. -/
theorem wheelNet_no_four_clique :
    ¬ ∃ s : Finset (Fin 6), s.card = 4 ∧ wheelNet.IsClique (s : Set (Fin 6)) := by decide

/-! ## The clique number -/

/-- The largest group of mutual friends has exactly three members. -/
theorem wheelNet_cliqueNum : wheelNet.cliqueNum = 3 := by
  refine le_antisymm ?_ ?_
  · refine csSup_le ⟨0, ∅, by simp⟩ ?_
    rintro n ⟨s, hs⟩
    by_contra hlt
    push_neg at hlt
    obtain ⟨t, hts, htcard⟩ := Finset.exists_subset_card_eq (n := 4) (s := s)
      (by rw [hs.card_eq]; omega)
    exact wheelNet_no_four_clique ⟨t, htcard, hs.isClique.subset (by exact_mod_cast hts)⟩
  · have h : (({0, 1, 5} : Finset (Fin 6))).card ≤ wheelNet.cliqueNum :=
      SimpleGraph.IsClique.card_le_cliqueNum (tc := wheelNet_triangle)
    simpa using h

/-! ## The emotional chromatic number -/

/-- Three emotions do not suffice for the hub-and-circle network. -/
theorem wheelNet_not_colorable_three : ¬ wheelNet.Colorable 3 := by
  intro h
  have hpos : 0 < chromVal wheelNet 3 := (chromVal_pos_iff_colorable wheelNet 3).2 h
  rw [wheelNet_chromVal_three] at hpos
  exact absurd hpos (lt_irrefl 0)

/-- Four emotions do suffice. -/
theorem wheelNet_colorable_four : wheelNet.Colorable 4 :=
  (chromVal_pos_iff_colorable wheelNet 4).1 (by rw [wheelNet_chromVal_four]; norm_num)

/-- **The hub-and-circle network needs exactly four emotions.** -/
theorem wheelNet_emoChrom : emoChrom wheelNet = 4 := by
  refine le_antisymm (emoChrom_le _ (by norm_num) wheelNet_colorable_four) ?_
  have h3 : 3 ≤ emoChrom wheelNet := emoChrom_ge_three wheelNet
  have hne : emoChrom wheelNet ≠ 3 := by
    intro h
    exact wheelNet_not_colorable_three ((emoChrom_eq_three_iff wheelNet).1 h)
  omega

/-! ## Both sides of the sandwich are strict -/

/-- **Strictness.**  For the hub-and-circle network the clique bound reads `3`, the emotional
chromatic number is `4`, and the greedy bound reads `6`: both inequalities of the sandwich theorem
are strict at the same time. -/
theorem wheelNet_sandwich_strict :
    max wheelNet.cliqueNum 3 < emoChrom wheelNet ∧
      emoChrom wheelNet < max (wheelNet.maxDegree + 1) 3 := by
  rw [wheelNet_cliqueNum, wheelNet_maxDegree, wheelNet_emoChrom]
  norm_num

/-- The sandwich theorem is nonetheless satisfied, as it must be. -/
theorem wheelNet_sandwich_holds :
    max wheelNet.cliqueNum 3 ≤ emoChrom wheelNet ∧
      emoChrom wheelNet ≤ max (wheelNet.maxDegree + 1) 3 :=
  emoChrom_sandwich wheelNet

/-- The hub-and-circle network sits inside the mission's window `[3,6]`, but strictly between the
two local bounds, so its position there is not explained by either statistic alone. -/
theorem wheelNet_in_window : 3 ≤ emoChrom wheelNet ∧ emoChrom wheelNet ≤ 6 := by
  rw [wheelNet_emoChrom]
  norm_num

/-
-- !-- Lab Notes (critique, cycle 5) -- !--
ADVERSARIAL REVIEW.
* Is this a `decide`-only file?  No.  `decide` supplies four finite facts about a concrete
  six-person network (two chromatic counts, the maximum degree, and the absence of a four-person
  clique).  Every statement about `emoChrom` and `cliqueNum` is derived from those facts by
  structural arguments (`csSup_le` plus subset-of-a-clique for `ω`, the catalog threshold law plus
  the emotional floor for `emoChrom`).
* Is the example degenerate?  No: it is connected, has six people (the size of the emotion
  palette), and its chromatic count at `q = 4` agrees with the classical wheel polynomial, which is
  an independent check of the encoding.
* Does it contradict anything proved earlier?  No: `wheelNet_sandwich_holds` re-derives the
  sandwich for this network from the general theorem, and the strict version refines it.
-- !-- End Lab Notes -- !--
-/

end Catalog.Computation.EmotionalSandwichSharpness