import Mathlib
import Novelty.WallMengerSubwall
import Novelty.Connectivity

/-!
# Bridge: vertex `k`-connectivity feeds the packing side of the wall–Menger duality

This file connects the catalog's vertex-connectivity development
(`Novelty.Connectivity`, the cut-based `IsKConnected` and the Whitney bound
`κ(G) ≤ δ(G)`) to the packing–cover duality of `Novelty.WallMengerCore`.

The bridge is the observation that the *packing side* of the wall–Menger
dichotomy is automatically witnessed in a highly connected graph: in a
`k`-connected graph every vertex `w` has at least `k` neighbours
(`IsKConnected.le_ncard_neighborSet`), and the `|N(w)|` neighbour singletons form
a pairwise-disjoint family — a packing of size `≥ k`.  Thus, whenever `k ≥ s`, the
local neighbourhood already realises the `s`-packing horn of `wall_menger_dichotomy`.

## Main result

* `kConnected_neighbor_packing` — a `k`-connected graph exhibits, around every
  vertex, a pairwise-disjoint family of `≥ k` nonempty vertex sets (the neighbour
  singletons), i.e. the packing horn of the duality with packing number `≥ k`.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): high connectivity should *force* the packing horn of
  the dichotomy, never the separator horn — connectivity is exactly "no small
  separator", which is the negation of the cover side.
* Experiment (Experimenter): formalised the cheapest witness — the singleton
  family `{n}` over `n ∈ N(w)`.  Injectivity of `v ↦ {v}` turns
  `|N(w)| ≥ k` (the catalog's Whitney bound) into `card ≥ k`; pairwise
  disjointness of distinct singletons is immediate.
* Analysis (Analyst): the catalog lemma `IsKConnected.le_ncard_neighborSet` is
  used as a black box; the only translation cost is `ncard`↔`Finset.card`, handled
  by `Set.ncard_coe_finset` through `coe_neighborFinset`.
* Critique (Critic): the packing here is the *trivial* (singleton) packing, which
  is honest — it shows the duality's packing bound is never the obstruction in a
  connected graph; the real content of the conjecture is the routing into ONE
  subwall, which lives in `WallMengerSubwall.lean`, not here.
* Synthesis (PI): the three files now span both horns — cover (Core), subwall
  pigeonhole (Subwall), and the connectivity-driven packing witness (this file).
-- !-- end Lab Notes -- !--
-/

open SimpleGraph Finset
open ConnPreservingHamPath

namespace WallMenger

variable {V : Type*}

/-- **Connectivity feeds the packing horn.**  In a `k`-connected finite simple
graph, the neighbour singletons of any vertex `w` form a pairwise-disjoint family
of nonempty vertex sets of size at least `k`.  This is exactly the packing side of
`wall_menger_dichotomy` with packing number `≥ k`, witnessed locally. -/
theorem kConnected_neighbor_packing [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} [DecidableRel G.Adj] {k : ℕ}
    (h : IsKConnected G k) (w : V) :
    ∃ P : Finset (Finset V), (↑P : Set (Finset V)).PairwiseDisjoint id ∧
      (∀ A ∈ P, A.Nonempty) ∧ k ≤ P.card := by
  classical
  refine ⟨(G.neighborFinset w).image (fun v => ({v} : Finset V)), ?_, ?_, ?_⟩
  · -- pairwise disjoint: distinct singletons are disjoint
    intro A hA B hB hAB
    simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe, mem_neighborFinset] at hA hB
    obtain ⟨a, _, rfl⟩ := hA
    obtain ⟨b, _, rfl⟩ := hB
    rw [Function.onFun, id_eq, id_eq, Finset.disjoint_singleton]
    rintro rfl
    exact hAB rfl
  · -- every member is a nonempty singleton
    intro A hA
    simp only [Finset.mem_image, mem_neighborFinset] at hA
    obtain ⟨a, _, rfl⟩ := hA
    exact Finset.singleton_nonempty a
  · -- size at least k, from the Whitney bound κ ≤ δ
    have hinj : Function.Injective (fun v : V => ({v} : Finset V)) := by
      intro a b hab
      simpa using hab
    rw [Finset.card_image_of_injective _ hinj]
    have hk : k ≤ (G.neighborSet w).ncard := h.le_ncard_neighborSet w
    have hcoe : (G.neighborSet w).ncard = (G.neighborFinset w).card := by
      rw [← Set.ncard_coe_finset, coe_neighborFinset]
    omega

end WallMenger