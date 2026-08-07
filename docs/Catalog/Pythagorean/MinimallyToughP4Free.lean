import Mathlib

/-! # `P₄`-free graphs (cographs) and their basic closure properties

A graph is `P₄`-free — a *cograph* — when it contains no induced path on four
vertices.  This module provides the `ToughP4` vocabulary used by the
complete-host induced-containment study in `Shared.CompleteInducedThreshold`.

Main results.

* `isP4Free_top`, `isP4Free_bot` — complete and edgeless graphs are `P₄`-free.
* `isP4Free_compl_iff` — `P₄`-freeness is a self-complementary property: `G` is
  `P₄`-free iff its complement is.  (The path `P₄` is a self-complementary graph,
  and the proof below is exactly that observation, carried out on the
  five-condition unfolded definition.)
* `IsInducedSubgraph` and `isP4Free_of_induced` — `P₄`-freeness is inherited by
  induced subgraphs, which is the form in which the property is used.
-/

namespace ToughP4

variable {V W : Type*}

/-- An induced path on the four distinct vertices `a, b, c, d`: the edges
`ab`, `bc`, `cd` are present and the three chords `ac`, `bd`, `ad` are absent. -/
def IsInducedP4 (G : SimpleGraph V) (a b c d : V) : Prop :=
  G.Adj a b ∧ G.Adj b c ∧ G.Adj c d ∧ ¬ G.Adj a c ∧ ¬ G.Adj b d ∧ ¬ G.Adj a d

/-- A graph is `P₄`-free (a cograph) when no four vertices induce a path. -/
def IsP4Free (G : SimpleGraph V) : Prop := ∀ a b c d : V, ¬ IsInducedP4 G a b c d

/-- The complete graph is `P₄`-free: an induced `P₄` needs a non-adjacent pair. -/
theorem isP4Free_top : IsP4Free (⊤ : SimpleGraph V) := by
  rintro a b c d ⟨_hab, _hbc, hcd, hac, _hbd, had⟩
  simp only [SimpleGraph.top_adj, ne_eq, not_not] at hcd hac had
  exact hcd (by rw [← hac, had])

/-- The edgeless graph is `P₄`-free: an induced `P₄` needs an edge. -/
theorem isP4Free_bot : IsP4Free (⊥ : SimpleGraph V) := by
  rintro a b c d ⟨hab, _, _, _, _, _⟩
  exact hab.elim

/-- The four vertices of an induced `P₄` are pairwise distinct. -/
theorem isInducedP4_distinct {G : SimpleGraph V} {a b c d : V} (h : IsInducedP4 G a b c d) :
    a ≠ b ∧ b ≠ c ∧ c ≠ d ∧ a ≠ c ∧ b ≠ d ∧ a ≠ d := by
  obtain ⟨hab, hbc, hcd, hac, hbd, had⟩ := h
  refine ⟨hab.ne, hbc.ne, hcd.ne, ?_, ?_, ?_⟩
  · rintro rfl; exact had hcd
  · rintro rfl; exact had hab
  · rintro rfl; exact hac hcd.symm

/-- **The complement of an induced `P₄` is an induced `P₄`.**  If `a-b-c-d` is an induced
path in `G`, then `c-a-d-b` is an induced path in the complement. -/
theorem isInducedP4_compl {G : SimpleGraph V} {a b c d : V} (h : IsInducedP4 G a b c d) :
    IsInducedP4 Gᶜ c a d b := by
  obtain ⟨hab, hbc, hcd, hac, hbd, had⟩ := h
  obtain ⟨_, _, hcdne, hacne, hbdne, hadne⟩ := isInducedP4_distinct
    (G := G) (a := a) (b := b) (c := c) (d := d) ⟨hab, hbc, hcd, hac, hbd, had⟩
  refine ⟨⟨hacne.symm, fun h => hac h.symm⟩, ⟨hadne, had⟩, ⟨hbdne.symm, fun h => hbd h.symm⟩,
    ?_, ?_, ?_⟩
  · simp only [SimpleGraph.compl_adj, not_and, not_not]
    exact fun _ => hcd
  · simp only [SimpleGraph.compl_adj, not_and, not_not]
    exact fun _ => hab
  · simp only [SimpleGraph.compl_adj, not_and, not_not]
    exact fun _ => hbc.symm

/-- **`P₄`-freeness is self-complementary.** -/
theorem isP4Free_compl {G : SimpleGraph V} (h : IsP4Free G) : IsP4Free Gᶜ := by
  intro a b c d hp
  have hcompl := isInducedP4_compl hp
  simp only [compl_compl] at hcompl
  exact h _ _ _ _ hcompl

theorem isP4Free_compl_iff {G : SimpleGraph V} : IsP4Free Gᶜ ↔ IsP4Free G := by
  refine ⟨fun h => ?_, isP4Free_compl⟩
  have := isP4Free_compl h
  simpa using this

/-- `H` occurs as an induced subgraph of `G` via an embedding of vertex sets. -/
def IsInducedSubgraph (H : SimpleGraph W) (G : SimpleGraph V) : Prop :=
  ∃ f : W ↪ V, ∀ a b, H.Adj a b ↔ G.Adj (f a) (f b)

/-- `G` is induced-`H`-free when `H` does not occur as an induced subgraph of `G`. -/
def InducedFree (H : SimpleGraph W) (G : SimpleGraph V) : Prop :=
  ¬ ∃ f : W ↪ V, ∀ a b, H.Adj a b ↔ G.Adj (f a) (f b)

theorem inducedFree_iff_not_isInducedSubgraph {H : SimpleGraph W} {G : SimpleGraph V} :
    InducedFree H G ↔ ¬ IsInducedSubgraph H G := Iff.rfl

/-- `P₄`-freeness passes to induced subgraphs. -/
theorem isP4Free_of_induced {H : SimpleGraph W} {G : SimpleGraph V}
    (hind : IsInducedSubgraph H G) (hG : IsP4Free G) : IsP4Free H := by
  obtain ⟨f, hf⟩ := hind
  rintro a b c d ⟨hab, hbc, hcd, hac, hbd, had⟩
  exact hG (f a) (f b) (f c) (f d)
    ⟨(hf a b).mp hab, (hf b c).mp hbc, (hf c d).mp hcd,
      fun h => hac ((hf a c).mpr h), fun h => hbd ((hf b d).mpr h),
      fun h => had ((hf a d).mpr h)⟩

end ToughP4