import Mathlib

/-!
# A concrete non-injective oddomorphism

This self-contained file exhibits a concrete **oddomorphism that is neither injective
nor an isomorphism**, witnessing that oddomorphisms are strictly richer than graph
isomorphisms and directly reflecting the "minor" side of the oddomorphism / split-off
minor story.

We take:

* `twoEdges` : the graph `2·K₂` on `Fin 4` consisting of two disjoint edges
  `{0,1}` and `{2,3}`;
* `oneEdge`  : the single edge `K₂` on `Fin 2`;
* `merge`    : the map `0,2 ↦ 0` and `1,3 ↦ 1` folding the two parallel edges
  onto one.

The map `merge` is a *surjective, non-injective* oddomorphism `2·K₂ → K₂`, and
`K₂` is indeed a minor of `2·K₂` (obtained by deleting one edge and identifying its
endpoints with the other's).  By contrast the constant map `0,1,2,3 ↦ 0` is **not**
an oddomorphism, so oddomorphisms genuinely constrain the map.

The oddomorphism condition is the GF(2) intertwining
`A_F * funMatrix φ = funMatrix φ * A_G`, which for these fixed finite data is
decidable and checked by `decide`.
-/

namespace OddomorphismSplitMinor.Examples

/-- The `0/1` matrix over `GF(2)` of a function `φ`; the `(u,a)` entry is `1` iff
`φ u = a`. -/
def funMatrix {α β : Type*} [DecidableEq β] (φ : α → β) :
    Matrix α β (ZMod 2) :=
  Matrix.of (fun u a => if φ u = a then 1 else 0)

/-- An oddomorphism: its function matrix intertwines the adjacency matrices over
`GF(2)`. -/
def IsOddomorphism {VF VG : Type*} [Fintype VF] [Fintype VG] [DecidableEq VG]
    (F : SimpleGraph VF) (G : SimpleGraph VG)
    [DecidableRel F.Adj] [DecidableRel G.Adj] (φ : VF → VG) : Prop :=
  F.adjMatrix (ZMod 2) * funMatrix φ = funMatrix φ * G.adjMatrix (ZMod 2)

/-- Adjacency relation of `2·K₂`: edges `{0,1}` and `{2,3}`. -/
def rF : Fin 4 → Fin 4 → Prop := fun a b => (a = 0 ∧ b = 1) ∨ (a = 2 ∧ b = 3)

instance : DecidableRel rF := fun a b => by unfold rF; infer_instance

/-- The graph `2·K₂` (two disjoint edges) on `Fin 4`. -/
def twoEdges : SimpleGraph (Fin 4) := SimpleGraph.fromRel rF

instance : DecidableRel twoEdges.Adj := fun a b => by
  unfold twoEdges SimpleGraph.fromRel; infer_instance

/-- Adjacency relation of `K₂`: the single edge `{0,1}`. -/
def rG : Fin 2 → Fin 2 → Prop := fun a b => a = 0 ∧ b = 1

instance : DecidableRel rG := fun a b => by unfold rG; infer_instance

/-- The single-edge graph `K₂` on `Fin 2`. -/
def oneEdge : SimpleGraph (Fin 2) := SimpleGraph.fromRel rG

instance : DecidableRel oneEdge.Adj := fun a b => by
  unfold oneEdge SimpleGraph.fromRel; infer_instance

/-- The folding map `0,2 ↦ 0`, `1,3 ↦ 1`. -/
def merge : Fin 4 → Fin 2 := ![0, 1, 0, 1]

/-- The folding map is an oddomorphism from `2·K₂` onto `K₂`. -/
theorem merge_isOddomorphism : IsOddomorphism twoEdges oneEdge merge := by
  unfold IsOddomorphism; decide

/-- The constant map is **not** an oddomorphism: oddomorphisms are constrained. -/
theorem const_not_isOddomorphism :
    ¬ IsOddomorphism twoEdges oneEdge (fun _ => 0) := by
  unfold IsOddomorphism; decide

/-- `merge` is surjective. -/
theorem merge_surjective : Function.Surjective merge := by
  decide

/-- `merge` is **not** injective: it folds two disjoint edges onto one. -/
theorem merge_not_injective : ¬ Function.Injective merge := by
  intro h
  have : (0 : Fin 4) = 2 := h (a₁ := 0) (a₂ := 2) rfl
  exact absurd this (by decide)

/-- Consequently there is a non-injective, surjective oddomorphism `2·K₂ → K₂`,
so the class of oddomorphisms strictly contains the graph isomorphisms. -/
theorem exists_noninjective_oddomorphism :
    ∃ φ : Fin 4 → Fin 2,
      IsOddomorphism twoEdges oneEdge φ ∧
      Function.Surjective φ ∧ ¬ Function.Injective φ :=
  ⟨merge, merge_isOddomorphism, merge_surjective, merge_not_injective⟩

end OddomorphismSplitMinor.Examples