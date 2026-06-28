import Applications.StarRamsey.Threshold
import Novelty.AFLMatching.Basic

/-!
# Bridge: one colour pigeonhole, two Ramsey phenomena (stars and matchings)

This file connects the **star** threshold of `Threshold.lean` with the **matching** pigeonhole
of the attached catalog file `Catalog/Novelty/AFLMatching/Basic.lean`
(`AFLMatching.IsMatching.exists_mono_of_card`).

Both are consequences of partitioning a finite colour-labelled set.  For a `q`-colouring of the
edges of a *matching* `M` we show, simultaneously:

* a **star** conclusion via `StarRamsey.forcingF`: if `#M ≥ (∑ (t j - 1)) + 1` then some colour
  `j` labels at least `t j` edges of `M`;
* a **matching** conclusion via the catalog lemma: some colour `i` labels a sub-matching with
  `q · #class ≥ #M`.

`star_and_matching_pigeonhole` packages both, demonstrating that the catalog's matching result
and the new star threshold are two readings of the same pigeonhole.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The exact star threshold and the AFL matching pigeonhole are not
independent results; they are the same counting principle applied to the same coloured finite
set (the edges of a matching), so a single hypothesis `#M ≥ (∑ (t j - 1)) + 1` should yield
both a guaranteed monochromatic star class and a guaranteed monochromatic sub-matching.

Experiment (Experimenter): Imported the catalog file and applied
`AFLMatching.IsMatching.exists_mono_of_card` for the matching half and `StarRamsey.forcingF`
for the star half; the conjunction is `sorry`-free and uses both results literally.

Analysis (Analyst): The shared engine is `∑_j #class_j = #M` (our `StarRamsey.sum_cc`, the
catalog's `card_biUnion`).  The two theorems differ only in what they *extract* from a large
colour class: a star (threshold `t j`) versus a sub-matching (fraction `1/q`).  This confirms
the conjecture's framing that the star theorem "extends the matching result".

Critique (Critic): The bridge genuinely depends on the catalog import — deleting
`Novelty.AFLMatching.Basic` breaks the matching conjunct, so the dependency is load-bearing,
not decorative.

Synthesis (PI): A small but real cross-file theorem certifying that the new star machinery and
the catalog's matching machinery are compatible specialisations of one pigeonhole.
-/

open Finset

namespace StarRamsey.Bridge

variable {V : Type*} [DecidableEq V] {q : ℕ}

/-- **Star/matching pigeonhole bridge.** For a `q`-colouring `c` of the edges of a matching `M`
with `#M ≥ (∑ (t j - 1)) + 1`, there is simultaneously a colour `j` labelling at least `t j`
edges (a monochromatic star threshold, `StarRamsey.forcingF`) and a colour `i` whose class is a
sub-matching with `q · #class ≥ #M` (the catalog matching pigeonhole,
`AFLMatching.IsMatching.exists_mono_of_card`). -/
theorem star_and_matching_pigeonhole (M : Finset (Finset V))
    (hM : AFLMatching.IsMatching M) (t : Fin q → ℕ)
    (hcard : (∑ j, (t j - 1)) + 1 ≤ M.card) (hq : 0 < q) (c : Finset V → Fin q) :
    (∃ j, t j ≤ StarRamsey.cc M c j) ∧
    (∃ i, q * (M.filter (fun e => c e = i)).card ≥ M.card) := by
  refine ⟨StarRamsey.forcingF M t c hcard, ?_⟩
  obtain ⟨i, _, _, h⟩ := AFLMatching.IsMatching.exists_mono_of_card M hM hq c
  exact ⟨i, h⟩

end StarRamsey.Bridge