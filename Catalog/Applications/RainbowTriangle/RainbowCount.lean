/-
# Counting rainbow triangles: the conjecture verified on properly coloured complete graphs

This file defines the rainbow-triangle count `rt(G)` and proves the **Li–Ning–Shi–Zhang
conjecture** (`LiNingShiZhang2024`) on the family of *properly edge-coloured complete graphs*,
which are exactly the extremal objects named in the conjecture.

For a properly coloured complete graph `Kₙ`:

* `complete_proper_exists_rainbow` — there is a rainbow triangle whenever `n ≥ 3`
  (the existence half of the conjecture);
* `complete_proper_rtCount` — *every* triangle is rainbow, so `rt(Kₙ) = C(n,3)`;
* `complete_proper_conjecture` — therefore `rt(Kₙ) ≥ ⌈(n-1)(n-3)/8⌉`, the full conjectured
  inequality, on a family that simultaneously satisfies the hypothesis `δc ≥ (n+1)/2`
  (`EdgeColoring.complete_proper_meets_hypothesis`).

The count is defined by filtering the `3`-clique finset by the rainbow predicate, so
`rt(G) = #{ 3-cliques that are rainbow }`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): On a properly coloured complete graph the conjecture should hold
with enormous slack: every one of the `C(n,3)` triangles is rainbow, and `C(n,3)` dominates
`⌈(n-1)(n-3)/8⌉`.  This makes the family a clean, fully-verifiable instance of the conjecture.

Experiment (Experimenter): Defined `rtCount` via `Finset.filter` on `cliqueFinset 3`.  Proved
`complete_proper_rtCount` by showing the filter is *all* of `cliqueFinset 3` (each 3-clique is
rainbow by `proper_isRainbowTriangle`), then identifying `cliqueFinset 3` of the complete graph
with `powersetCard 3 univ` and counting with `Finset.card_powersetCard`.  Combined with
`rtBound_le_choose` (from `Bound.lean`) to get the conjectured inequality.

Analysis (Analyst): The proof never rewrites the underlying graph inside a
`DecidableRel`-dependent term (which fails with a "motive is not type correct" error); instead
the complete-graph adjacency is unfolded *inside the membership Prop only*.  This is the key
technical lesson for reasoning about `cliqueFinset` up to the decidability instance.

Critique (Critic): `rtCount` is a genuine count (not `0`): for `n = 4` it equals `C(4,3) = 4`
while the bound is `1`.  The result is the conjecture's inequality on a real, non-empty family
satisfying the hypothesis, with all proofs `sorry`-free.  What is *not* proved here is the
conjecture for arbitrary graphs in the regime, nor the equality/extremality clause — these are
recorded in `FUTURE_DIRECTIONS.md`.
-- !-- Lab Notes -- !--
-/
import Catalog.Applications.RainbowTriangle.Defs
import Catalog.Applications.RainbowTriangle.Bound

open Finset SimpleGraph

namespace RainbowTri
namespace EdgeColoring

variable {V : Type*} {C : Type*} [Fintype V] [DecidableEq V] [DecidableEq C]

/-- The **rainbow-triangle count** `rt(G)`: the number of `3`-cliques that are rainbow. -/
open Classical in
noncomputable def rtCount (E : EdgeColoring V C) [DecidableRel E.G.Adj] : ℕ :=
  ((E.G.cliqueFinset 3).filter (E.IsRainbowTriangleSet)).card

/-- **Existence of a rainbow triangle.**  A properly edge-coloured complete graph on `n ≥ 3`
vertices contains a rainbow triangle. -/
theorem complete_proper_exists_rainbow (E : EdgeColoring V C) [DecidableRel E.G.Adj]
    (hG : E.G = completeGraph V) (hp : E.IsProper) (h3 : 3 ≤ Fintype.card V) :
    ∃ a b c, E.IsRainbowTriangle a b c := by
  have h2 : 2 < (Finset.univ : Finset V).card := by simpa using h3
  obtain ⟨a, b, c, _, _, _, hab, hac, hbc⟩ := Finset.two_lt_card_iff.mp h2
  refine ⟨a, b, c, proper_isRainbowTriangle E hp hab hac hbc ?_ ?_ ?_⟩ <;>
    rw [hG] <;> simp only [completeGraph, top_adj] <;> assumption

/-- **Every triangle of a properly coloured complete graph is rainbow**, hence
`rt(Kₙ) = C(n,3)`. -/
theorem complete_proper_rtCount (E : EdgeColoring V C) [DecidableRel E.G.Adj]
    (hG : E.G = completeGraph V) (hp : E.IsProper) :
    E.rtCount = (Fintype.card V).choose 3 := by
  classical
  unfold rtCount
  have hfilter : (E.G.cliqueFinset 3).filter (E.IsRainbowTriangleSet) = E.G.cliqueFinset 3 := by
    apply Finset.filter_true_of_mem
    intro s hs
    rw [SimpleGraph.mem_cliqueFinset_iff, SimpleGraph.isNClique_iff] at hs
    obtain ⟨hclique, hcard⟩ := hs
    rw [Finset.card_eq_three] at hcard
    obtain ⟨a, b, c, hab, hac, hbc, rfl⟩ := hcard
    have ha : a ∈ ({a, b, c} : Finset V) := by simp
    have hb : b ∈ ({a, b, c} : Finset V) := by simp
    have hc : c ∈ ({a, b, c} : Finset V) := by simp
    exact ⟨a, b, c, rfl, proper_isRainbowTriangle E hp hab hac hbc
      (hclique ha hb hab) (hclique ha hc hac) (hclique hb hc hbc)⟩
  rw [hfilter]
  have hset : E.G.cliqueFinset 3 = (Finset.univ : Finset V).powersetCard 3 := by
    ext s
    rw [SimpleGraph.mem_cliqueFinset_iff, SimpleGraph.isNClique_iff, mem_powersetCard]
    constructor
    · rintro ⟨_, hc⟩; exact ⟨Finset.subset_univ _, hc⟩
    · rintro ⟨_, hc⟩
      refine ⟨?_, hc⟩
      intro x _ y _ hxy
      rw [hG]; exact hxy
  rw [hset, Finset.card_powersetCard, Finset.card_univ]

/-- **The Li–Ning–Shi–Zhang inequality, verified on properly coloured complete graphs.**
A properly edge-coloured complete graph on `n` vertices satisfies the conjectured bound
`rt(G) ≥ ⌈(n-1)(n-3)/8⌉`.  (By `complete_proper_meets_hypothesis` this family also satisfies
the conjecture's hypothesis `δc(G) ≥ (n+1)/2` once `n ≥ 3`.) -/
theorem complete_proper_conjecture (E : EdgeColoring V C) [DecidableRel E.G.Adj]
    (hG : E.G = completeGraph V) (hp : E.IsProper) :
    rtBound (Fintype.card V) ≤ E.rtCount := by
  rw [complete_proper_rtCount E hG hp]
  exact rtBound_le_choose _

end EdgeColoring
end RainbowTri