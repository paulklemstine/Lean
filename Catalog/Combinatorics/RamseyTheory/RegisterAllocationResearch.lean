/-
# Register Allocation: Chordal Coloring, Degree Bounds, and Spill Boundaries

Register allocation is represented by proper coloring of an interference graph.  The
central distinction developed here is between a universal degree upper bound and the
exact clique bound available for chordal interference graphs.  The file also records a
small obstruction to treating maximum degree as an exact register requirement.
-/
import Shared.RamseyTheory.RegisterGraphColoring

open SimpleGraph Finset Function

noncomputable section

namespace Catalog.Combinatorics.RegisterAllocation

/-
!-- Lab Notes -- !--

HYPOTHESIS.  Seven falsifiable targets were ranked by structural impact:
(1) chordal interference graphs support exactly the palettes allowed by their cliques;
(2) interval-liveness systems inherit this exactness;
(3) list palettes of clique size suffice;
(4) clique pressure gives an unavoidable spill lower bound;
(5) the universal degree bound is sufficient but generally not exact;
(6) maximum-degree spilling is optimal for arbitrary weighted costs;
(7) elimination pressure is a certificate shared by coloring and spilling.
Targets (1), (3), and (7) bridge elimination combinatorics, compiler liveness, and
finite resource assignment.  Targets (5) and (6) were treated adversarially because
they make stronger optimization claims than coloring theory supports.

EXPERIMENT.  The three-vertex path was used as the smallest diagnostic instance.  It
has a two-coloring while its middle vertex has degree two.  Thus the proposed exact
formula based on `Delta + 1` predicts three colors where two suffice.  This is a
structural counterexample, not a sampling anomaly.  Clique-based exactness survives
once a perfect elimination ordering is assumed.

ANALYSIS.  Degree controls the number of forbidden colors during greedy extension,
whereas clique size controls simultaneous pairwise interference.  These quantities
coincide only under additional hypotheses.  Chordality supplies the missing bridge:
later neighbors in an elimination ordering form a clique, turning the greedy upper
bound into the clique lower bound.

CRITIQUE.  SSA interference graphs require an explicit liveness model before
chordality may be inferred; “SSA-form” alone is not used as an unproved graph-theoretic
assumption here.  The claim that spilling is needed whenever `k < Delta + 1` fails on
the path example.  Degree-only spilling also ignores execution-frequency weights and
interactions among several removed vertices, so no universal optimality claim is made.

SYNTHESIS.  The surviving theorem is the palette-level perfectness statement for a
graph equipped with a perfect elimination ordering.  The failed degree equality is
replaced by a strict separation theorem and by the sound universal sufficiency bound
already available for arbitrary finite interference graphs.  No arXiv abstract, OEIS
entry, or LMFDB object was supplied as an external signal; target selection therefore
followed the graph-theoretic and compiler-semantic evidence in the mission itself.

A graph with a perfect elimination ordering is colorable with `k` registers
exactly when no finite clique asks for more than `k` registers.
-/
theorem chordal_register_palette_iff {n k : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (peo : PerfectEliminationOrdering G) :
    G.Colorable k ↔
      ∀ s : Finset (Fin n), G.IsClique (s : Set (Fin n)) → s.card ≤ k := by
  refine' ⟨ fun h s hs => _, fun h => _ ⟩;
  · convert clique_size_le_colorable _ _ _ _;
    exact n;
    exact G;
    exacts [ h, s, rfl, hs ];
  · exact chordal_colorable_of_clique_bound G peo k h

/-
Consequently, any palette strictly larger than the maximum degree is sufficient.
This statement is deliberately one-sided: degree is an upper bound, not an exact
chromatic formula.
-/
theorem degree_budget_suffices {n k : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (hk : G.maxDegree < k) :
    G.Colorable k := by
  exact no_spill_sufficient_registers G k hk

/-
If a `k`-coloring exists below `Delta + 1`, then the chromatic number cannot equal
`Delta + 1`.  This isolates the logical defect in the proposed exact degree formula.
-/
theorem degree_formula_fails_of_smaller_coloring {n k : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (hcol : G.Colorable k) (hgap : k < G.maxDegree + 1) :
    G.chromaticNumber ≠ (G.maxDegree + 1 : ℕ) := by
  exact ne_of_lt ( lt_of_le_of_lt ( hcol.chromaticNumber_le ) ( WithTop.coe_lt_coe.mpr hgap ) )

/-
The middle vertex of the three-vertex path has degree two.
-/
lemma path_three_middle_degree : (SimpleGraph.pathGraph 3).degree (1 : Fin 3) = 2 := by
  simp +decide only [degree, pathGraph];
  simp +decide [ SimpleGraph.neighborFinset, hasse ];
  simp +decide [ CovBy ];
  simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ]

/-
The three-vertex path is the minimal concrete separation: two colors suffice even
though `Delta + 1` is three.
-/
theorem path_three_refutes_degree_formula :
    letI : DecidableRel (SimpleGraph.pathGraph 3).Adj := Classical.decRel _
    (SimpleGraph.pathGraph 3).Colorable 2 ∧
    (SimpleGraph.pathGraph 3).chromaticNumber ≠
      ((SimpleGraph.pathGraph 3).maxDegree + 1 : ℕ) := by
  constructor;
  · use fun v => if v = 0 then 0 else if v = 1 then 1 else 0;
    simp +decide [ Fin.forall_fin_succ, pathGraph_adj ];
  · refine' ne_of_lt _;
    refine' lt_of_le_of_lt ( SimpleGraph.chromaticNumber_le_iff_colorable.mpr _ ) _;
    exact 2;
    · refine' ⟨ fun x => if x = 0 then 0 else if x = 1 then 1 else 0, _ ⟩ ; simp +decide [ SimpleGraph.pathGraph ] ;
      simp +decide [ CovBy ];
    · simp +decide [ SimpleGraph.maxDegree ];
      simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ];
      simp +decide [ pathGraph ];
      simp +decide [ CovBy ]

/-
A clique of size `m` forces at least `m-k` members of that clique to be spilled
when only `k` registers are available.
-/
theorem unavoidable_clique_spills {n k m : ℕ} {G : SimpleGraph (Fin n)}
    [DecidableRel G.Adj] (s : Finset (Fin n)) (hs : s.card = m)
    (hclique : G.IsClique (s : Set (Fin n))) (spilled : Finset (Fin n))
    (hk : k < m)
    (hvalid : ∃ c : Fin n → Fin k,
      ∀ u v, u ∉ spilled → v ∉ spilled → G.Adj u v → c u ≠ c v) :
    m - k ≤ (s ∩ spilled).card := by
  convert spill_cost_clique_lower_bound s hs hclique spilled hk hvalid using 1

/-
Example: the path diagnostic has an explicit Boolean two-coloring.
-/
example : (SimpleGraph.pathGraph 3).Colorable 2 := by
  convert path_three_refutes_degree_formula.1 using 1

/-
Example: every clique of the three-vertex path has at most two vertices, obtained
from chordal exactness and its explicit two-coloring once a PEO is supplied.
-/
example (peo : @PerfectEliminationOrdering 3 (SimpleGraph.pathGraph 3) (Classical.decRel _))
    (s : Finset (Fin 3))
    (hs : (SimpleGraph.pathGraph 3).IsClique (s : Set (Fin 3))) :
    s.card ≤ 2 := by
  letI : DecidableRel (SimpleGraph.pathGraph 3).Adj := Classical.decRel _
  apply (chordal_register_palette_iff (SimpleGraph.pathGraph 3) peo).mp
    path_three_refutes_degree_formula.1 s hs

#check chordal_register_palette_iff
#check path_three_refutes_degree_formula
#check unavoidable_clique_spills

/-
GENERALIZATION.  The palette theorem extends from uniform registers to per-variable
lists: a chordal graph remains colorable when each variable's admissible list has at
least the clique bound.  A broader extension should attach register classes and spill
weights while preserving the elimination certificate.

BOUNDARIES.  Odd holes show that clique number alone does not control coloring outside
perfect graph classes.  The three-vertex path is the opposite boundary case: maximum
degree overestimates coloring even inside a chordal class.  Weighted spill objectives
cannot be recovered from degree data alone, and program extraction must justify that
the chosen liveness semantics really produces the assumed graph class.
-/

end Catalog.Combinatorics.RegisterAllocation