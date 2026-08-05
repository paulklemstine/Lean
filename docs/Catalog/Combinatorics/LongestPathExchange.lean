import Mathlib
import Bridges.GraphTheory.K2UnionIndependentFree
import Combinatorics.K2UnionK1FreeInvariants

/-!
# Longest paths and the `(K₂ ∪ kK₁)`-free exchange step

Milestone 4 of the programme started in `Bridges.GraphTheory.K2UnionIndependentFree` asks
for the longest-path extension and endpoint-exchange lemmas underlying Hamiltonicity
arguments. This file provides the extension half together with the step where
`(K₂ ∪ kK₁)`-freeness is actually used.

* `IsLongestPath p` says that `p` is a path of maximum length among *all* paths of `G`
  (endpoints are allowed to vary).
* `exists_isLongestPath` — a finite nonempty graph has a longest path.
* `IsLongestPath.reverse`, `IsLongestPath.isPath`, `IsLongestPath.dist_le` — basic API.
* `IsLongestPath.mem_support_of_adj_fst` / `IsLongestPath.mem_support_of_adj_snd` —
  **the extension lemma**: every neighbour of an endpoint of a longest path lies on that
  path, since otherwise the path could be extended.
* `IsLongestPath.not_adj_of_notMem_support` — equivalently, the endpoints are anticomplete
  to the set of vertices missed by the path.
* `IsLongestPath.card_lt_of_indepSet_off` and `IsLongestPath.indepNum_off_lt` —
  **the exchange step**: if the two endpoints of a longest path are adjacent, then in a
  `(K₂ ∪ kK₁)`-free graph fewer than `k` pairwise non-adjacent vertices can be missed by
  the path, because such vertices together with the endpoint edge would form the forbidden
  induced configuration.
* `IsLongestPath.spanning_of_free_one` — the extreme case `k = 1`: a longest path with
  adjacent endpoints in a `(K₂ ∪ K₁)`-free graph is spanning (Hamiltonian).
-/

open Finset SimpleGraph K2UnionIndependentFree K2UnionK1FreeInvariants

namespace LongestPathExchange

variable {V : Type*} {G : SimpleGraph V}

/-- `p` is a path of maximum length among all paths of `G`. -/
def IsLongestPath {u w : V} (p : G.Walk u w) : Prop :=
  p.IsPath ∧ ∀ (a b : V) (q : G.Walk a b), q.IsPath → q.length ≤ p.length

theorem IsLongestPath.isPath {u w : V} {p : G.Walk u w} (h : IsLongestPath p) : p.IsPath :=
  h.1

theorem IsLongestPath.le {u w : V} {p : G.Walk u w} (h : IsLongestPath p) {a b : V}
    (q : G.Walk a b) (hq : q.IsPath) : q.length ≤ p.length :=
  h.2 a b q hq

/-- Every finite nonempty graph has a longest path. -/
theorem exists_isLongestPath [Fintype V] [Nonempty V] (G : SimpleGraph V) :
    ∃ (u w : V) (p : G.Walk u w), IsLongestPath p := by
  classical
  set S : Set ℕ := {n | ∃ (a b : V) (q : G.Walk a b), q.IsPath ∧ q.length = n} with hS
  have hne : S.Nonempty := by
    obtain ⟨v⟩ := ‹Nonempty V›
    exact ⟨0, v, v, SimpleGraph.Walk.nil, SimpleGraph.Walk.IsPath.nil, rfl⟩
  have hbdd : BddAbove S := by
    refine ⟨Fintype.card V, ?_⟩
    rintro n ⟨a, b, q, hq, rfl⟩
    exact le_of_lt hq.length_lt
  obtain ⟨a, b, q, hq, hqlen⟩ : sSup S ∈ S := Nat.sSup_mem hne hbdd
  refine ⟨a, b, q, hq, fun x y r hr => ?_⟩
  rw [hqlen]
  exact le_csSup hbdd ⟨x, y, r, hr, rfl⟩

/-- Reversing a longest path gives a longest path. -/
theorem IsLongestPath.reverse {u w : V} {p : G.Walk u w} (h : IsLongestPath p) :
    IsLongestPath p.reverse :=
  ⟨h.isPath.reverse, fun a b q hq => by
    simpa using h.le q hq⟩

/-- The length of a longest path bounds every distance in the graph. -/
theorem IsLongestPath.dist_le {u w : V} {p : G.Walk u w} (h : IsLongestPath p) {a b : V}
    (hab : G.Reachable a b) : G.dist a b ≤ p.length := by
  obtain ⟨q, hq⟩ := hab.exists_path_of_dist
  exact hq.2 ▸ h.le q hq.1

/-- **Extension lemma.** Every neighbour of the initial vertex of a longest path lies on
that path: otherwise the path could be prolonged. -/
theorem IsLongestPath.mem_support_of_adj_fst {u w x : V} {p : G.Walk u w}
    (h : IsLongestPath p) (hadj : G.Adj x u) : x ∈ p.support := by
  by_contra hx
  have hq : (SimpleGraph.Walk.cons hadj p).IsPath := h.isPath.cons hx
  have := h.le (SimpleGraph.Walk.cons hadj p) hq
  simp only [SimpleGraph.Walk.length_cons] at this
  omega

/-- Every neighbour of the terminal vertex of a longest path lies on that path. -/
theorem IsLongestPath.mem_support_of_adj_snd {u w x : V} {p : G.Walk u w}
    (h : IsLongestPath p) (hadj : G.Adj x w) : x ∈ p.support := by
  have := h.reverse.mem_support_of_adj_fst hadj
  simpa using this

/-- The endpoints of a longest path are anticomplete to the vertices it misses. -/
theorem IsLongestPath.not_adj_of_notMem_support {u w x : V} {p : G.Walk u w}
    (h : IsLongestPath p) (hx : x ∉ p.support) : ¬ G.Adj u x ∧ ¬ G.Adj w x :=
  ⟨fun hadj => hx (h.mem_support_of_adj_fst hadj.symm),
   fun hadj => hx (h.mem_support_of_adj_snd hadj.symm)⟩

/-- **The exchange step.** In a `(K₂ ∪ kK₁)`-free graph, if the endpoints of a longest
path are adjacent, then any set of pairwise non-adjacent vertices missed by the path has
fewer than `k` elements: together with the endpoint edge, `k` of them would form the
forbidden induced configuration. -/
theorem IsLongestPath.card_lt_of_indepSet_off {k : ℕ} (hfree : IsK2UnionK1Free G k)
    {u w : V} {p : G.Walk u w} (h : IsLongestPath p) (huw : G.Adj u w) {I : Finset V}
    (hI : G.IsIndepSet (I : Set V)) (hIoff : ∀ x ∈ I, x ∉ p.support) : I.card < k := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨J, hJI, hJcard⟩ := Finset.exists_subset_card_eq hcon
  refine hfree huw J hJcard (hI.mono (by exact_mod_cast hJI)) fun x hx => ?_
  exact h.not_adj_of_notMem_support (hIoff x (hJI hx))

/-- The same statement in terms of the independence number of the subgraph induced on the
vertices missed by the path. -/
theorem IsLongestPath.indepNum_off_lt [Fintype V] [DecidableEq V] {k : ℕ}
    (hfree : IsK2UnionK1Free G k) {u w : V} {p : G.Walk u w} (h : IsLongestPath p)
    (huw : G.Adj u w) :
    (G.induce {x : V | x ∉ p.support}).indepNum < k := by
  classical
  obtain ⟨s, hs, hscard⟩ := (G.induce {x : V | x ∉ p.support}).exists_isNIndepSet_indepNum
  have hmap : ((s.image Subtype.val).card) = s.card :=
    Finset.card_image_of_injective _ Subtype.val_injective
  have hIndep : G.IsIndepSet ((s.image Subtype.val : Finset V) : Set V) := by
    intro x hx y hy hne hadj
    simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe] at hx hy
    obtain ⟨a, ha, rfl⟩ := hx
    obtain ⟨b, hb, rfl⟩ := hy
    have hab : a ≠ b := fun hab => hne (congrArg Subtype.val hab)
    exact hs (by exact_mod_cast ha) (by exact_mod_cast hb) hab (by simpa using hadj)
  have hoff : ∀ x ∈ s.image Subtype.val, x ∉ p.support := by
    intro x hx
    simp only [Finset.mem_image] at hx
    obtain ⟨a, -, rfl⟩ := hx
    exact a.2
  have := h.card_lt_of_indepSet_off hfree huw hIndep hoff
  rw [hmap, hscard] at this
  exact this

/-- In a `(K₂ ∪ K₁)`-free graph a longest path whose endpoints are adjacent is spanning:
it misses no vertex at all. -/
theorem IsLongestPath.spanning_of_free_one (hfree : IsK2UnionK1Free G 1) {u w : V}
    {p : G.Walk u w} (h : IsLongestPath p) (huw : G.Adj u w) (x : V) : x ∈ p.support := by
  classical
  by_contra hx
  have hI : G.IsIndepSet (({x} : Finset V) : Set V) := by
    simp [SimpleGraph.IsIndepSet]
  have := h.card_lt_of_indepSet_off hfree huw hI (by simpa using hx)
  simp at this

end LongestPathExchange