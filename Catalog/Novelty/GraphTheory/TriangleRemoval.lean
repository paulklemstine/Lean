/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Consequences of the triangle removal lemma

Mathlib's `SimpleGraph.triangle_removal` (built on Szemerédi's regularity lemma)
states that a graph with very few triangles can be made triangle-free by deleting
few edges; its dual `SimpleGraph.FarFromTriangleFree.le_card_cliqueFinset` says
that an `ε`-far-from-triangle-free graph has at least
`triangleRemovalBound ε · n³` triangles.

From this we extract two clean consequences:

* `far_triangle_density_lower_bound`: the *triangle density* of an
  `ε`-far-from-triangle-free graph is bounded below by the positive constant
  `triangleRemovalBound ε`, **uniformly in the number of vertices** — the
  qualitative heart of the removal lemma.
* `far_from_triangleFree_contains_triangle`: such a graph contains an actual
  triangle.
-/
import Mathlib

namespace Catalog.Combinatorics.ExtremalGraphTheory

open SimpleGraph Finset

/-- **Uniform triangle-density lower bound.**
If `G` is `ε`-far from triangle-free (`ε > 0`) on a nonempty vertex set, then its
triangle density `#(triangles) / n³` is at least the positive constant
`triangleRemovalBound ε`, independent of `n`.  This is the contrapositive content
of the triangle removal lemma. -/
theorem far_triangle_density_lower_bound {α : Type*} [DecidableEq α] [Fintype α]
    {G : SimpleGraph α} [DecidableRel G.Adj] {ε : ℝ} (hn : 0 < Fintype.card α)
    (h : G.FarFromTriangleFree ε) :
    triangleRemovalBound ε ≤ (#(G.cliqueFinset 3) : ℝ) / (Fintype.card α : ℝ) ^ 3 := by
  have hle := h.le_card_cliqueFinset
  have hn3 : (0 : ℝ) < (Fintype.card α : ℝ) ^ 3 := by positivity
  rw [le_div_iff₀ hn3]
  linarith [hle]

/-- **An `ε`-far-from-triangle-free graph contains a triangle.**
For `ε > 0` and at least one vertex, the positive triangle-count guaranteed by
the removal lemma forces a nonempty triangle set. -/
theorem far_from_triangleFree_contains_triangle {α : Type*} [DecidableEq α] [Fintype α]
    {G : SimpleGraph α} [DecidableRel G.Adj] {ε : ℝ} (hε : 0 < ε) (hn : 0 < Fintype.card α)
    (h : G.FarFromTriangleFree ε) :
    (G.cliqueFinset 3).Nonempty := by
  have hle := h.le_card_cliqueFinset
  have hpos : 0 < triangleRemovalBound ε := triangleRemovalBound_pos hε
  rw [← Finset.card_pos]
  have hcard : (0 : ℝ) < #(G.cliqueFinset 3) := by
    have hn3 : (0 : ℝ) < (Fintype.card α : ℝ) ^ 3 := by positivity
    nlinarith [hle, hpos, hn3]
  exact_mod_cast hcard

/-
-- !-- Lab Notes -- !--

HYPOTHESIS.
  The triangle removal lemma is usually quoted as "few triangles ⇒ few edits to
  triangle-free".  We hypothesised its most useful working form is the
  *density* dual: being `ε`-far forces a triangle density bounded below by a
  constant that does **not** decay with `n`.

EXPERIMENT.
  `FarFromTriangleFree.le_card_cliqueFinset` gives
  `triangleRemovalBound ε · n³ ≤ #triangles`.  Dividing by `n³ > 0`
  (`le_div_iff₀`) yields the uniform density bound; positivity of
  `triangleRemovalBound ε` (`triangleRemovalBound_pos`) plus `n³ > 0` makes the
  triangle count strictly positive, hence the triangle set is nonempty
  (`nlinarith`, then `card_pos`).

ANALYSIS.
  The uniformity in `n` is the entire point: it is what powers the Ruzsa–
  Szemerédi / corners route to Roth's theorem.  The nonemptiness corollary is the
  qualitative shadow of the same inequality.

CRITIQUE.
  Both results require `0 < card α` (otherwise `n³ = 0` trivialises the bound)
  and `far_from_triangleFree_contains_triangle` needs `ε > 0` for positivity of
  the removal bound; without these the statements would be vacuous, so the
  hypotheses are load-bearing rather than decorative.  We rely on Mathlib's
  regularity-lemma-backed `triangle_removal`; we do not reprove regularity here.

SYNTHESIS.
  The removal lemma is best wielded as a density statement: `ε`-farness is a
  *robust* witness of triangles, scale-invariantly so.  This is exactly the
  lever the additive-combinatorics applications (corners, Roth) pull on.
-/

end Catalog.Combinatorics.ExtremalGraphTheory