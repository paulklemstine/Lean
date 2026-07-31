import Mathlib

open Finset

namespace ErdosFaberLovasz

variable {V : Type*} [DecidableEq V]

/-- A finite hypergraph is represented by its finite set of finite edges. -/
abbrev Hypergraph (V : Type*) [DecidableEq V] := Finset (Finset V)

/-- Every edge of an `r`-uniform hypergraph has exactly `r` vertices. -/
def IsUniform (H : Hypergraph V) (r : ℕ) : Prop :=
  ∀ e ∈ H, e.card = r

/-- A hypergraph is linear when two different edges share at most one vertex. -/
def IsLinear (H : Hypergraph V) : Prop :=
  ∀ e ∈ H, ∀ f ∈ H, e ≠ f → (e ∩ f).card ≤ 1

/-- A hypergraph is intersecting when every two of its edges meet. -/
def IsIntersecting (H : Hypergraph V) : Prop :=
  ∀ e ∈ H, ∀ f ∈ H, (e ∩ f).Nonempty

/-- A coloring is proper for the clique-union graph when every hyperedge is rainbow:
distinct vertices in one edge receive distinct colors. -/
def IsProperColoring (H : Hypergraph V) (color : V → Fin k) : Prop :=
  ∀ e ∈ H, ∀ x ∈ e, ∀ y ∈ e, x ≠ y → color x ≠ color y

/-- The EFL chromatic conclusion: the clique-union graph of the hypergraph admits a
proper coloring with `k` colors. -/
def Colorable (H : Hypergraph V) (k : ℕ) : Prop :=
  ∃ color : V → Fin k, IsProperColoring H color

/-- On each hyperedge, a proper EFL coloring restricts to an injective map. -/
theorem properColoring_injective_on_edge {H : Hypergraph V} {color : V → Fin k}
    (hcolor : IsProperColoring H color) {e : Finset V} (he : e ∈ H) :
    Set.InjOn color (e : Set V) := by
  intro x hx y hy hxy
  by_contra hne
  exact hcolor e he x hx y hy hne hxy

/-- In a linear hypergraph, an edge different from `e` contains at most one vertex of `e`. -/
theorem unique_intersection_on_edge {H : Hypergraph V} (hlin : IsLinear H)
    {e f : Finset V} (he : e ∈ H) (hf : f ∈ H) (hne : e ≠ f) :
    ∀ x ∈ e, x ∈ f → ∀ y ∈ e, y ∈ f → x = y := by
  intro x hxe hxf y hye hyf
  have h := hlin e he f hf hne
  have : (e ∩ f).card ≤ 1 := h
  contrapose! this
  calc (e ∩ f).card ≥ ({x, y} : Finset V).card := by
        apply card_le_card
        intro z hz
        aesop
    _ = 2 := by simp [this]

/-- Fixing an edge in a linear intersecting hypergraph assigns every other edge to a
unique point of the fixed edge. -/
theorem exists_unique_intersection_on_edge {H : Hypergraph V}
    (hlin : IsLinear H) (hint : IsIntersecting H)
    {e f : Finset V} (he : e ∈ H) (hf : f ∈ H) (hne : e ≠ f) :
    ∃! x, x ∈ e ∧ x ∈ f := by
  have hne0 : (e ∩ f).Nonempty := hint e he f hf
  obtain ⟨a, ha⟩ := hne0
  use a
  refine ⟨⟨Finset.mem_inter.mp ha |>.1, Finset.mem_inter.mp ha |>.2⟩, ?_⟩
  intro y hy
  exact unique_intersection_on_edge hlin he hf hne y hy.1 hy.2 a (Finset.mem_inter.mp ha |>.1) (Finset.mem_inter.mp ha |>.2)

/-- Two distinct edges through the same vertex have disjoint sets of remaining vertices.
This is the local disjointness principle behind the standard EFL degree estimates. -/
theorem erase_disjoint_of_common_vertex {H : Hypergraph V} (hlin : IsLinear H)
    {e f : Finset V} (he : e ∈ H) (hf : f ∈ H) (hne : e ≠ f)
    {x : V} (hxe : x ∈ e) (hxf : x ∈ f) :
    Disjoint (e.erase x) (f.erase x) := by
  rw [Finset.disjoint_left]
  intro y hye hyf
  rw [Finset.mem_erase] at hye hyf
  obtain ⟨hyne, hye⟩ := hye
  obtain ⟨_, hyf⟩ := hyf
  have hcard : (e ∩ f).card ≤ 1 := hlin e he f hf hne
  have hxfy : x ∈ e ∩ f := Finset.mem_inter.mpr ⟨hxe, hxf⟩
  have hyxf : y ∈ e ∩ f := Finset.mem_inter.mpr ⟨hye, hyf⟩
  have hcard2 : (e ∩ f).card ≥ 2 := by
    have hsub : {x, y} ⊆ e ∩ f := by
      rw [Finset.insert_subset_iff]
      exact ⟨hxfy, Finset.singleton_subset_iff.mpr hyxf⟩
    calc (e ∩ f).card ≥ (({x, y} : Finset V)).card := Finset.card_le_card hsub
      _ = 2 := Finset.card_pair hyne.symm
  linarith

/-- Distinct edges in a linear intersecting hypergraph meet in exactly one vertex. -/
theorem intersection_card_eq_one {H : Hypergraph V}
    (hlin : IsLinear H) (hint : IsIntersecting H)
    {e f : Finset V} (he : e ∈ H) (hf : f ∈ H) (hne : e ≠ f) :
    (e ∩ f).card = 1 := by
  apply Nat.le_antisymm (hlin e he f hf hne)
  exact Finset.one_le_card.mpr (hint e he f hf)

/-- Removing the unique common point from either of two distinct edges destroys
all overlap; equivalently, their union has the inclusion-exclusion cardinality. -/
theorem union_card_of_distinct_edges {H : Hypergraph V}
    (hlin : IsLinear H) (hint : IsIntersecting H)
    {e f : Finset V} (he : e ∈ H) (hf : f ∈ H) (hne : e ≠ f) :
    (e ∪ f).card + 1 = e.card + f.card := by
  calc
    (e ∪ f).card + 1 = (e ∪ f).card + (e ∩ f).card := by
      rw [intersection_card_eq_one hlin hint he hf hne]
    _ = e.card + f.card := Finset.card_union_add_card_inter e f

/-- In an `r`-uniform linear intersecting hypergraph, the union of two distinct
edges has exactly `2r-1` vertices. -/
theorem union_card_eq_two_mul_sub_one {H : Hypergraph V} {r : ℕ}
    (huni : IsUniform H r) (hlin : IsLinear H) (hint : IsIntersecting H)
    {e f : Finset V} (he : e ∈ H) (hf : f ∈ H) (hne : e ≠ f) :
    (e ∪ f).card = 2 * r - 1 := by
  have h := union_card_of_distinct_edges hlin hint he hf hne
  rw [huni e he, huni f hf] at h
  omega

end ErdosFaberLovasz