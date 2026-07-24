import Mathlib
import Novelty.GreedyDegreeColoring

/-!
# Local flag algebras: maximum-degree normalisation

Local flag algebras replace order normalisation by maximum-degree normalisation.
This file isolates the elementary counting mechanism behind that change of scale:
once a root is fixed, each further vertex of a walk has at most `Δ(G)` choices.
Consequently rooted four-step configurations have mass at most `Δ(G)^4`, and
closed five-step configurations satisfy the same bound because closure only
removes choices. Summing over roots gives the natural scale `|G| Δ(G)^4` for
pentagons.

The count below is the labelled, oriented local count. In a triangle-free simple
graph, a closed walk of odd length five cannot backtrack into a shorter odd
cycle, so these objects are precisely the ten orientations and choices of root
of ordinary pentagons. The counting inequality itself is valid without the
triangle-free assumption and is therefore reusable for local flag extensions.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): six falsifiable targets were ranked by expected impact.
(1, bold; extremal combinatorics–optimisation bridge) the sharp triangle-free
pentagon constant is certified by a finite local positive-semidefinite identity;
(2, bold; graph limits–operator algebra bridge) every convergent bounded-degree
sequence induces a positive local flag functional and conversely every such
unimodular functional is approximable by finite graphs; (3, bold; complexity–
extremal bridge) bounded-radius certificates approximate every local extremal
problem effectively; (4, cross-domain) local flag moments are moments of the
adjacency extension operator; (5, cross-domain) bounded-degree colouring and
local pentagon density share the same controlling parameter; (6) rooted flags
obtained by four successive neighbour extensions admit a universal `Δ⁴`
majorant. The present cycle proves (6) and a precise form of (5), while isolating
(1)--(4) as stronger tests. This predicts the global `|V|Δ⁴` scale independently
of density or regularity.

EXPERIMENT (Experimenter): define endpoint-refined walk counts recursively,
prove a one-step fibre bound, sum over endpoints, and then restrict endpoints to
neighbours of the root to impose closure. Couple the resulting local count with
the catalogued greedy colouring theorem to expose a bridge between local-density
normalisation and bounded-degree colouring.

ANALYSIS (Analyst): the essential structure is a positive extension operator.
Its row sums are vertex degrees, hence at most `Δ`; iteration gives the power of
`Δ`. Closure is a restriction of the terminal fibre, not another extension,
which explains why pentagons scale as `Δ⁴` rather than `Δ⁵` after fixing a root.

CRITIQUE (Critic): these inequalities establish the normalisation and positivity
layer, not the semidefinite certificate giving the paper's sharp constant. The
bound counts labelled orientations and deliberately remains valid when triangles
are present. Empty graphs and `Δ = 0` are included, and no division by `Δ` is
used, avoiding a hidden nonzero-degree assumption.

SYNTHESIS (Principal Investigator): this target serves the cross-domain half of
the research menu, bridging local extremal counting with bounded-degree graph
colouring. Local extension, endpoint summation, closure, and global rooting form
a reusable hierarchy. The final theorem packages the `|V|Δ⁴` pentagon scale
together with the independent `(Δ+1)` colouring bound.
-- !-- end Lab Notes -- !--
-/

open Finset

namespace LocalFlagAlgebras

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The number of length-`k` walks from `v` to `w`. -/
def walkCount (G : SimpleGraph V) [DecidableRel G.Adj] : ℕ → V → V → ℕ
  | 0, v, w => if v = w then 1 else 0
  | k + 1, v, w => ∑ u ∈ G.neighborFinset v, walkCount G k u w

/-- The number of all length-`k` walks starting at a specified root. -/
def rootedWalkCount (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) (v : V) : ℕ :=
  ∑ w : V, walkCount G k v w

/-- The local labelled pentagon count at `v`: four steps from `v`, followed by
the requirement that the endpoint is adjacent to `v`. -/
def rootedClosedFiveCount (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) : ℕ :=
  ∑ w ∈ G.neighborFinset v, walkCount G 4 v w

/-- The global labelled, rooted, oriented closed-five count. -/
def closedFiveCount (G : SimpleGraph V) [DecidableRel G.Adj] : ℕ :=
  ∑ v : V, rootedClosedFiveCount G v

/-
Summing endpoint-refined counts after one extension is the same as summing
the rooted counts of all possible first neighbours.
-/
lemma rootedWalkCount_succ (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) (v : V) :
    rootedWalkCount G (k + 1) v =
      ∑ u ∈ G.neighborFinset v, rootedWalkCount G k u := by
  unfold rootedWalkCount;
  rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop

/-
A rooted length-`k` walk has at most `Δ(G)^k` possible extensions.
-/
theorem rootedWalkCount_le_maxDegree_pow
    (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) (v : V) :
    rootedWalkCount G k v ≤ G.maxDegree ^ k := by
  induction' k with k ih generalizing v;
  · simp +decide [ rootedWalkCount, walkCount ];
  · rw [ rootedWalkCount_succ ];
    refine' le_trans ( Finset.sum_le_sum fun u hu => ih u ) _;
    simp +decide [ pow_succ' ];
    exact Nat.mul_le_mul_right _ ( G.degree_le_maxDegree v )

/-
Closing a four-step rooted walk can only reduce its count.
-/
lemma rootedClosedFiveCount_le_rootedWalkCount
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    rootedClosedFiveCount G v ≤ rootedWalkCount G 4 v := by
  exact Finset.sum_le_sum_of_subset ( Finset.subset_univ _ )

/-- **Local maximum-degree pentagon scale.** At every root, the labelled closed
five-step count is at most `Δ(G)^4`. -/
theorem rootedClosedFiveCount_le_maxDegree_four
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    rootedClosedFiveCount G v ≤ G.maxDegree ^ 4 := by
  exact (rootedClosedFiveCount_le_rootedWalkCount G v).trans
    (rootedWalkCount_le_maxDegree_pow G 4 v)

/-
**Global maximum-degree pentagon scale.** The labelled rooted oriented
closed-five count is at most `|V| Δ(G)^4`.
-/
theorem closedFiveCount_le_card_mul_maxDegree_four
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    closedFiveCount G ≤ Fintype.card V * G.maxDegree ^ 4 := by
  exact le_trans (Finset.sum_le_sum fun _ _ =>
    rootedClosedFiveCount_le_maxDegree_four _ _) (by simp)

/-- **Local flags–colouring bridge.** The maximum-degree scale simultaneously
controls all labelled pentagonal closures and supplies a proper colouring with
one more than the same local parameter. -/
theorem pentagon_scale_and_degree_coloring
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    closedFiveCount G ≤ Fintype.card V * G.maxDegree ^ 4 ∧
      G.Colorable (G.maxDegree + 1) := by
  constructor
  · exact closedFiveCount_le_card_mul_maxDegree_four G
  · exact SimpleGraph.colorable_maxDegree_succ G

end LocalFlagAlgebras