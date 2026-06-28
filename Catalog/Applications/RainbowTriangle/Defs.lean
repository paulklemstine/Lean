/-
# Rainbow triangles in edge-coloured graphs — definitions and proper-colouring core

This file sets up the basic theory of **rainbow triangles** in edge-coloured graphs and
proves the structural backbone used elsewhere in the `RainbowTriangle` development.

It is motivated by the conjecture of **Li, Ning, Shi, Zhang (2024)** (`LiNingShiZhang2024`):

> Every edge-coloured graph `G` on `n ≥ 3` vertices with minimum colour degree
> `δc(G) ≥ (n+1)/2` satisfies `rt(G) ≥ ⌈(n-1)(n-3)/8⌉`, with equality only for the
> extremal construction obtained from a proper edge-colouring of `Kₙ` when `n` is odd.

Here we model an edge-coloured graph as a `SimpleGraph` together with a symmetric colour
function `col`.  We define:

* `colorDegree E v` — the number of distinct colours on edges incident to `v` (`= dc(v)`);
* `IsRainbowTriangle E a b c` — three pairwise-adjacent vertices whose three edges carry
  three distinct colours;
* `IsProper E` — a proper edge-colouring (edges sharing a vertex get distinct colours);
* `IsRainbowTriangleSet E s` — the set-level predicate used to count rainbow triangles.

The main proven facts are:

* `colorDegree_le_degree`, `colorDegree_le_card_sub_one` — basic bounds on the colour
  degree (`dc(v) ≤ deg(v) ≤ n - 1`);
* `proper_isRainbowTriangle` — in a properly coloured graph **every** triangle is rainbow;
* `proper_colorDegree_eq_degree` — under a proper colouring `dc(v) = deg(v)`;
* `complete_proper_colorDegree` / `complete_proper_meets_hypothesis` — a properly coloured
  complete graph on `n ≥ 3` vertices has `δc = n - 1 ≥ (n+1)/2`, i.e. it lies exactly in the
  hypothesis regime of the conjecture.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The conjecture's extremal object is a properly edge-coloured
complete graph.  A proper colouring forces every triangle to be rainbow, so such graphs
should be a clean, fully-formalisable witness that the regime `δc ≥ (n+1)/2` is non-empty
and that the lower bound is *consistent* (indeed far exceeded) there.

Experiment (Experimenter): Formalised `EdgeColoring`, `colorDegree`, `IsRainbowTriangle`,
`IsProper`.  Proved `proper_isRainbowTriangle` by a pure case analysis on the three shared
vertices using `col_symm`; proved `proper_colorDegree_eq_degree` via injectivity of the
colour map on the neighbourhood (`Finset.card_image_of_injOn`).

Analysis (Analyst): The proper-colouring hypothesis collapses the rainbow condition to mere
distinctness of vertices, because in a triangle every pair of edges shares a vertex.  This is
the structural reason the extremal construction in the conjecture uses proper colourings.

Critique (Critic): None of these results are vacuous — `proper_isRainbowTriangle` genuinely
needs the symmetry axiom and the proper hypothesis, and `complete_proper_meets_hypothesis`
needs `n ≥ 3` (for `n ≤ 2` the regime is empty).  All proofs are `sorry`-free.
-- !-- Lab Notes -- !--
-/
import Mathlib

open Finset SimpleGraph

namespace RainbowTri

variable {V : Type*} {C : Type*}

/-- An edge-colouring of a simple graph: an underlying graph `G` together with a symmetric
colour function `col`.  Only the values of `col` on edges of `G` are meaningful. -/
structure EdgeColoring (V C : Type*) where
  G : SimpleGraph V
  col : V → V → C
  col_symm : ∀ u v, col u v = col v u

namespace EdgeColoring

variable [Fintype V] [DecidableEq C]

/-- The **colour degree** `dc(v)`: the number of distinct colours appearing on edges
incident to `v`. -/
def colorDegree (E : EdgeColoring V C) [DecidableRel E.G.Adj] (v : V) : ℕ :=
  ((E.G.neighborFinset v).image (E.col v)).card

/-- `a, b, c` form a **rainbow triangle**: they are pairwise adjacent and the three edge
colours are pairwise distinct. -/
def IsRainbowTriangle (E : EdgeColoring V C) (a b c : V) : Prop :=
  E.G.Adj a b ∧ E.G.Adj a c ∧ E.G.Adj b c ∧
  E.col a b ≠ E.col a c ∧ E.col a b ≠ E.col b c ∧ E.col a c ≠ E.col b c

/-- A **proper edge-colouring**: any two edges sharing a vertex have different colours. -/
def IsProper (E : EdgeColoring V C) : Prop :=
  ∀ ⦃u v w⦄, v ≠ w → E.G.Adj u v → E.G.Adj u w → E.col u v ≠ E.col u w

/-- The set-level rainbow-triangle predicate, used to count rainbow triangles as
three-element vertex sets. -/
def IsRainbowTriangleSet [DecidableEq V] (E : EdgeColoring V C) (s : Finset V) : Prop :=
  ∃ a b c, s = {a, b, c} ∧ E.IsRainbowTriangle a b c

/-- The colour degree never exceeds the ordinary degree. -/
theorem colorDegree_le_degree (E : EdgeColoring V C) [DecidableRel E.G.Adj] (v : V) :
    E.colorDegree v ≤ E.G.degree v := by
  unfold colorDegree
  rw [← SimpleGraph.card_neighborFinset_eq_degree]
  exact Finset.card_image_le

/-- The colour degree is at most `n - 1`. -/
theorem colorDegree_le_card_sub_one (E : EdgeColoring V C) [DecidableRel E.G.Adj] (v : V) :
    E.colorDegree v ≤ Fintype.card V - 1 := by
  have h1 := colorDegree_le_degree E v
  have h2 := E.G.degree_lt_card_verts v
  omega

omit [Fintype V] [DecidableEq C] in
/-- The rainbow-triangle predicate is invariant under swapping the first two vertices. -/
theorem rainbowTriangle_symm₁ (E : EdgeColoring V C) {a b c : V}
    (h : E.IsRainbowTriangle a b c) : E.IsRainbowTriangle b a c := by
  obtain ⟨Eab, Eac, Ebc, h1, h2, h3⟩ := h
  refine ⟨E.G.symm Eab, Ebc, Eac, ?_, ?_, ?_⟩
  · rw [E.col_symm b a]; exact h2
  · rw [E.col_symm b a]; exact h1
  · exact h3.symm

omit [Fintype V] [DecidableEq C] in
/-- **Proper colourings make every triangle rainbow.**  If `E` is a proper edge-colouring and
`a, b, c` are three distinct pairwise-adjacent vertices, then `a, b, c` is a rainbow triangle.
This is the structural heart of the extremal construction in the conjecture. -/
theorem proper_isRainbowTriangle (E : EdgeColoring V C) (hp : E.IsProper)
    {a b c : V} (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c)
    (Eab : E.G.Adj a b) (Eac : E.G.Adj a c) (Ebc : E.G.Adj b c) :
    E.IsRainbowTriangle a b c := by
  refine ⟨Eab, Eac, Ebc, hp hbc Eab Eac, ?_, ?_⟩
  · have h := hp hac (E.G.symm Eab) Ebc
    rwa [E.col_symm b a] at h
  · have h := hp hab (E.G.symm Eac) (E.G.symm Ebc)
    rwa [E.col_symm c a, E.col_symm c b] at h

/-- Under a proper colouring the colour degree equals the ordinary degree, because the colour
map is injective on each neighbourhood. -/
theorem proper_colorDegree_eq_degree (E : EdgeColoring V C) [DecidableRel E.G.Adj]
    (hp : E.IsProper) (v : V) : E.colorDegree v = E.G.degree v := by
  unfold colorDegree
  rw [← SimpleGraph.card_neighborFinset_eq_degree]
  apply Finset.card_image_of_injOn
  intro a ha b hb hcol
  by_contra hne
  rw [mem_coe, mem_neighborFinset] at ha hb
  exact hp hne ha hb hcol

omit [DecidableEq C] in
/-- Every vertex of the complete graph has degree `n - 1`. -/
theorem complete_degree (E : EdgeColoring V C) [DecidableEq V] [DecidableRel E.G.Adj]
    (hG : E.G = completeGraph V) (v : V) : E.G.degree v = Fintype.card V - 1 := by
  rw [← SimpleGraph.card_neighborFinset_eq_degree, SimpleGraph.neighborFinset_eq_filter]
  have : (univ.filter (fun u => E.G.Adj v u)) = univ.erase v := by
    ext u
    simp only [mem_filter, mem_univ, true_and, mem_erase, hG, completeGraph, top_adj]
    tauto
  rw [this, card_erase_of_mem (mem_univ v), card_univ]

/-- A properly coloured complete graph has colour degree `n - 1` at every vertex. -/
theorem complete_proper_colorDegree (E : EdgeColoring V C) [DecidableEq V] [DecidableRel E.G.Adj]
    (hG : E.G = completeGraph V) (hp : E.IsProper) (v : V) :
    E.colorDegree v = Fintype.card V - 1 := by
  rw [proper_colorDegree_eq_degree E hp v, complete_degree E hG v]

/-- **Consistency with the conjecture's hypothesis.**  A properly edge-coloured complete graph
on `n ≥ 3` vertices has minimum colour degree `n - 1 ≥ (n+1)/2`, so it lies exactly in the
regime `δc(G) ≥ (n+1)/2` of the Li–Ning–Shi–Zhang conjecture. -/
theorem complete_proper_meets_hypothesis (E : EdgeColoring V C) [DecidableEq V]
    [DecidableRel E.G.Adj] (hG : E.G = completeGraph V) (hp : E.IsProper)
    (h3 : 3 ≤ Fintype.card V) (v : V) :
    (Fintype.card V + 1) / 2 ≤ E.colorDegree v := by
  rw [complete_proper_colorDegree E hG hp v]
  omega

end EdgeColoring
end RainbowTri