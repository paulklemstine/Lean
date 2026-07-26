/-
  The graph (r = 1) case and the bridge to the flag-complex catalog
  =================================================================

  The signless Laplacian of `Core.lean` specializes, when `r = 1`, to the
  classical signless Laplacian `Q = D + A` of a finite simple graph: the
  ridges are the vertices and the facets are the edges, each edge being the
  `2`-element set of its endpoints.  The Core bound `specRad ≤ s·Δ` with the
  facet size `s = 2` recovers the textbook bound `q(G) ≤ 2Δ(G)`.

  We also connect to the catalog file `Catalog.Geometry.FlagComplex`: using
  its `clique_pair_iff` we prove `oneSkel (cliqueComplex G) = G`, so the
  signless Laplacian of the 1-skeleton of the clique complex of `G` is the
  signless Laplacian of `G` itself.

  -- !-- Lab Notes -- !--
  Hypothesis: the abstract facet/ridge signless Laplacian restricts to the
    usual graph signless Laplacian for `r = 1`, with facet size `2`.
  Experiment: model edges as `2`-element facets via `Sym2` membership; feed
    facet-size `= 2` into `Core.specRad_le`.
  Analysis: the only graph-specific input is `edgeFacet_card_two` (an edge is
    a genuine `2`-set); everything else is the dimension-free Core engine.
  Critique: we genuinely import and *use* a catalog theorem
    (`clique_pair_iff`) to identify `oneSkel (cliqueComplex G) = G`, so the
    bridge is not cosmetic.
  Synthesis: `q(G) ≤ 2Δ`, the `r = 1` instance of the conjecture's bound.
-/
import Geometry.SignlessLaplacian.Core
import Geometry.RamseyTheory.FlagComplex

open Finset BigOperators

namespace SignlessLaplacian

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- Edges as facets: each edge becomes the `2`-element finset of its
    endpoints.  This is the `r = 1` (graph) incidence structure. -/
def edgeFacet (G : SimpleGraph V) [DecidableRel G.Adj] :
    G.edgeFinset → Finset V :=
  fun e => Finset.univ.filter (· ∈ (e : Sym2 V))

/-
Every edge facet has exactly two ridges (its two endpoints).
-/
theorem edgeFacet_card_two (G : SimpleGraph V) [DecidableRel G.Adj]
    (e : G.edgeFinset) : (edgeFacet G e).card = 2 := by
  obtain ⟨a, b, hab⟩ : ∃ a b : V, e.val = Sym2.mk (a, b) ∧ a ≠ b := by
    rcases e with ⟨ e, he ⟩;
    rcases e with ⟨ a, b ⟩;
    exact ⟨ a, b, rfl, by rintro rfl; exact absurd he ( by simp +decide ) ⟩;
  convert Finset.card_pair hab.2;
  ext v; simp [edgeFacet, hab]

/-
The graph signless Laplacian spectral bound: if every vertex of `G` lies
    in at most `D` edges, then `specRad (edgeFacet G) ≤ 2·D`.  With
    `D = Δ(G)` this is the classical bound `q(G) ≤ 2Δ(G)`.
-/
theorem graph_specRad_le (G : SimpleGraph V) [DecidableRel G.Adj] (D : ℕ)
    (hD : ∀ v, degree (edgeFacet G) v ≤ D) :
    specRad (edgeFacet G) ≤ (2 * D : ℝ) := by
  convert specRad_le ( edgeFacet G ) 2 D _ _;
  · exact fun f => le_of_eq ( edgeFacet_card_two G f );
  · assumption

/-
Catalog bridge (uses `FlagComplex.clique_pair_iff`): the 1-skeleton of
    the clique complex of `G` is `G` itself.
-/
omit [Fintype V] in
theorem oneSkel_cliqueComplex_eq (G : SimpleGraph V) :
    oneSkel (cliqueComplex G) = G := by
  ext a b;
  by_cases hab : a = b <;> simp +decide [ hab, oneSkel_adj, clique_pair_iff ]

end SignlessLaplacian