/-
# Colour classes of a proper edge-colouring

Building on `Catalog/Applications/RainbowTriangle/Defs.lean`, this file develops the
**colour-class** structure of an edge-coloured simple graph `EdgeColoring V C`.

For an edge-colouring `E`, we assign to each *edge* `e` of `E.G` its colour via
`edgeColor E e : Option C` (`some (col u v)` when `e = s(u, v)` is an edge, `none`
otherwise), and collect the edges of a fixed colour `c` into the finset
`colorClass E c ⊆ E.G.edgeFinset`.

The main results are:

* `proper_colorClass_isMatching` — in a proper edge-colouring, any two edges of the same
  colour that share a vertex coincide; i.e. each colour class is a **matching**;
* `colorClass_disjoint` — distinct colours give disjoint colour classes;
* `colorClass_partition` — the colour classes `{colorClass E c | c : C}` **partition**
  `E.G.edgeFinset`: their union is the whole edge set and distinct classes are disjoint.

-- !-- Lab Notes -- !--
Experiment (Experimenter): Defined `edgeColor` via `Sym2.lift` of the symmetric colour
function `col`, guarded by edge membership, and `colorClass` as a `Finset.filter` on
`edgeFinset`.  The helper `colorClass_mem_vertex` extracts, from an edge `e` of colour `c`
through a vertex `x`, the other endpoint `y` with `e = s(x, y)`, `Adj x y`, `col x y = c`.

Analysis (Analyst): The matching property is the contrapositive of `IsProper`: two edges
`s(x, y₁)`, `s(x, y₂)` of the same colour through `x` force `y₁ = y₂` by properness, hence the
edges are equal.  Disjointness of colour classes is immediate from injectivity of `some`, and
the partition's covering half holds because every edge has a well-defined colour.

Critique (Critic): All proofs are `sorry`-free and reuse the `EdgeColoring` API from `Defs`.
The key mathematical steps are explicit tactic arguments; automation is used only for
finset/`Sym2` bookkeeping.
-- !-- Lab Notes -- !--
-/
import Catalog.Applications.RainbowTriangle.Defs

open Finset SimpleGraph

namespace RainbowTri

namespace EdgeColoring

variable {V : Type*} {C : Type*} [Fintype V] [DecidableEq V] [DecidableEq C]

/-- The colour of an edge `e` of `E.G`: `some (col u v)` if `e = s(u, v)` is an edge of `E.G`,
and `none` otherwise.  This uses `Sym2.lift` of the symmetric colour function `E.col`. -/
def edgeColor (E : EdgeColoring V C) [DecidableRel E.G.Adj] (e : Sym2 V) : Option C :=
  if e ∈ E.G.edgeSet then some (Sym2.lift ⟨E.col, E.col_symm⟩ e) else none

omit [Fintype V] [DecidableEq V] [DecidableEq C] in
/-- The colour of an actual edge `s(u, v)` (with `u ∼ v` in `E.G`) is `some (E.col u v)`. -/
lemma edgeColor_mk (E : EdgeColoring V C) [DecidableRel E.G.Adj] {u v : V} (h : E.G.Adj u v) :
    E.edgeColor s(u, v) = some (E.col u v) := by
  unfold edgeColor
  rw [if_pos (E.G.mem_edgeSet.2 h)]
  rfl

omit [Fintype V] [DecidableEq V] [DecidableEq C] in
/-- Any edge of `E.G` gets a colour of the form `some _`. -/
lemma edgeColor_mem (E : EdgeColoring V C) [DecidableRel E.G.Adj] {e : Sym2 V}
    (h : e ∈ E.G.edgeSet) : E.edgeColor e = some (Sym2.lift ⟨E.col, E.col_symm⟩ e) := by
  unfold edgeColor; rw [if_pos h]

/-- The **colour class** of colour `c`: the finset of edges of `E.G` whose colour is `c`. -/
def colorClass (E : EdgeColoring V C) [DecidableRel E.G.Adj] (c : C) : Finset (Sym2 V) :=
  E.G.edgeFinset.filter (fun e => E.edgeColor e = some c)

omit [DecidableEq V] in
/-- Membership in a colour class: an edge belongs to `colorClass c` iff it is an edge of `E.G`
with colour `c`. -/
lemma mem_colorClass (E : EdgeColoring V C) [DecidableRel E.G.Adj] {c : C} {e : Sym2 V} :
    e ∈ E.colorClass c ↔ e ∈ E.G.edgeFinset ∧ E.edgeColor e = some c := by
  unfold colorClass; rw [Finset.mem_filter]

omit [DecidableEq V] in
/-- From an edge `e` of colour `c` passing through the vertex `x`, extract the other endpoint
`y`: we have `e = s(x, y)`, `x ∼ y` in `E.G`, and `E.col x y = c`. -/
lemma colorClass_mem_vertex (E : EdgeColoring V C) [DecidableRel E.G.Adj] {c : C} {e : Sym2 V}
    (he : e ∈ E.colorClass c) {x : V} (hx : x ∈ e) :
    ∃ y, e = s(x, y) ∧ E.G.Adj x y ∧ E.col x y = c := by
  induction e with
  | h a b =>
    rw [E.mem_colorClass] at he
    obtain ⟨hedge, hcol⟩ := he
    rw [mem_edgeFinset, SimpleGraph.mem_edgeSet] at hedge
    rw [Sym2.mem_iff] at hx
    rcases hx with rfl | rfl
    · refine ⟨b, rfl, hedge, ?_⟩
      rw [E.edgeColor_mk hedge] at hcol
      exact Option.some.inj hcol
    · refine ⟨a, Sym2.eq_swap, hedge.symm, ?_⟩
      rw [E.edgeColor_mk hedge] at hcol
      rw [E.col_symm]
      exact Option.some.inj hcol

/-- **Each colour class is a matching.**  In a proper edge-colouring, any two edges of the
same colour that share a vertex coincide. -/
theorem proper_colorClass_isMatching (E : EdgeColoring V C) [DecidableRel E.G.Adj]
    (hp : E.IsProper) (c : C) {e₁ e₂ : Sym2 V}
    (h₁ : e₁ ∈ E.colorClass c) (h₂ : e₂ ∈ E.colorClass c)
    {x : V} (hx₁ : x ∈ e₁) (hx₂ : x ∈ e₂) : e₁ = e₂ := by
  -- Normalise both edges to pass through the shared vertex `x`.
  obtain ⟨y₁, he₁eq, hadj₁, hcol₁⟩ := E.colorClass_mem_vertex h₁ hx₁
  obtain ⟨y₂, he₂eq, hadj₂, hcol₂⟩ := E.colorClass_mem_vertex h₂ hx₂
  -- Both edges `s(x, y₁)`, `s(x, y₂)` have colour `c`; properness forces `y₁ = y₂`.
  have hy : y₁ = y₂ := by
    by_contra hne
    exact hp hne hadj₁ hadj₂ (hcol₁.trans hcol₂.symm)
  rw [he₁eq, he₂eq, hy]

omit [DecidableEq V] in
/-- **Distinct colours give disjoint colour classes.** -/
theorem colorClass_disjoint (E : EdgeColoring V C) [DecidableRel E.G.Adj] {c₁ c₂ : C}
    (h : c₁ ≠ c₂) : Disjoint (E.colorClass c₁) (E.colorClass c₂) := by
  rw [Finset.disjoint_left]
  intro e he₁ he₂
  rw [E.mem_colorClass] at he₁ he₂
  -- The single edge `e` would then have both colours `c₁` and `c₂`.
  exact h (Option.some.inj (he₁.2.symm.trans he₂.2))

/-- **The colour classes partition the edge set.**  Their union is `E.G.edgeFinset`, and
distinct colour classes are disjoint. -/
theorem colorClass_partition (E : EdgeColoring V C) [Fintype C] [DecidableRel E.G.Adj] :
    (Finset.univ.biUnion (fun c => E.colorClass c) = E.G.edgeFinset) ∧
    (∀ c₁ c₂, c₁ ≠ c₂ → Disjoint (E.colorClass c₁) (E.colorClass c₂)) := by
  refine ⟨?_, fun c₁ c₂ h => E.colorClass_disjoint h⟩
  ext e
  simp only [Finset.mem_biUnion, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨c, hc⟩
    exact (E.mem_colorClass.1 hc).1
  · intro he
    -- The colour of `e` is `some (lift col e)`, so `e` lies in that colour's class.
    exact ⟨Sym2.lift ⟨E.col, E.col_symm⟩ e,
      E.mem_colorClass.2 ⟨he, E.edgeColor_mem (mem_edgeFinset.1 he)⟩⟩

end EdgeColoring

end RainbowTri