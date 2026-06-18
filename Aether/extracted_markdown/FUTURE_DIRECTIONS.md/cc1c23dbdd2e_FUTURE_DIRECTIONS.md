# Future Directions: Combinatorial Types of Tropical Moduli Curves

The file `ModuliCurves.lean` formalizes the combinatorial backbone of the tropical
moduli space `M_{g,n}^trop`. We model a combinatorial type by its degree sequence
`degs : Multiset ℕ` together with the bounded-edge count `E`, the leg count `n`, and
the genus `g`, constrained by the handshaking identity `∑ val(v) = 2E + n` and the
connected-graph Euler relation `E + 1 = |V| + g`. From this abstraction we proved the
marked dimension bound `edge_bound` (`|E| ≤ 3g − 3 + n`), its unmarked corollary
`unmarked_edge_bound`, the sharpness statement `trivalent_eq`, the maximal-cell
characterization `eq_bound_iff_trivalent` (equality ⇔ trivalent), and
`genus_preserved_under_contraction`. The directions below extend this frontier.

## 1. The full face poset of `M_{g,n}^trop` as a graded poset

We proved that contracting a single non-loop edge lowers `|E|` by one and preserves
`g` and `n`. The natural next step is to assemble the set of all combinatorial types
of fixed `(g, n)` into a partially ordered set under iterated contraction and prove it
is **graded** by `|E|`, with the trivalent types (`eq_bound_iff_trivalent`) as the
top-dimensional cells and the single-vertex type as the unique minimum.

The key insight is that `genus_preserved_under_contraction` already supplies the
covering relation of the poset: each cover drops `|E|` by exactly one, so the rank
function is literally `|E|` and the maximal rank is `3g − 3 + n` by `edge_bound`.

**Why now?** Mathlib has `Order.Grade` / `GradeOrder` and a developed order-theory
library; combining it with our contraction lemma turns a purely arithmetic fact into a
structural statement about the cone complex, with no new geometry required.

## 2. Vertex-weighted stability and the genus decomposition `g = b₁ + ∑ g(v)`

Our `Stable` predicate is the `g(v) = 0` (pure) case of the true stability condition
`2g(v) − 2 + val(v) > 0`. Generalizing `degs` to a multiset of pairs `(g(v), val(v))`
and replacing `Stable` with the weighted condition would let us prove the refined
bound `|E| ≤ 3g − 3 + n` where the *total* genus `g = b₁(Γ) + ∑_v g(v)` splits into a
graph (first Betti number) part and a vertex part.

The key insight is that a positive vertex weight `g(v) ≥ 1` relaxes the valence floor
from `3` to `1`, so the same `three_card_le_sum` argument goes through with a
weight-dependent lower bound, and the slack is exactly `∑_v (something)`.

**Why now?** `edge_bound` is currently proved purely by `omega` from
`three_card_le_sum`; the weighted version only changes the per-vertex constant, so the
existing proof skeleton generalizes with a modified termwise inequality lemma.

## 3. Counting trivalent types: the Euler-relation Diophantine system

`trivalent_eq` shows trivalent types saturate the bound, and for trivalent graphs
`2E = 3V` and `E + 1 = V + g` force `V = 2g − 2`, `E = 3g − 3` (unmarked). The open
combinatorial question is to **enumerate** the connected trivalent multigraphs of
genus `g`, i.e. count the top cells of `M_g^trop` for small `g`.

The key insight is that for trivalent graphs the two linear constraints pin `(V, E)`
exactly, reducing the count to enumerating connected 3-regular multigraphs on `2g − 2`
vertices — a finite, decidable problem for each `g`.

**Why now?** Our structure already isolates the arithmetic constraints; pairing it with
Mathlib's `SimpleGraph`/`Multigraph` enumeration tooling makes the `g = 2` case
(the well-known "theta" and "dumbbell" graphs giving exactly two top cells) a concrete,
machine-checkable theorem.

## 4. Bridge to Mathlib graph theory: `b₁ = 0 ⇔ forest`

We define genus via `E + 1 = |V| + g`, valid for connected graphs, and `g = 0`
recovers the tree relation `E + 1 = |V|`. The direction is to connect our abstract
degree-sequence model to an honest `SimpleGraph` and prove `b₁ = 0 ⇔ IsAcyclic`,
generalizing the genus-0-iff-tree fact to possibly disconnected graphs via the first
Betti number `b₁ = |E| − |V| + c` with `c` connected components.

The key insight is that the converse of Mathlib's `SimpleGraph.IsTree.card_edgeFinset`
— that connected `+` `|E| = |V| − 1` implies tree — is the missing link, and it is
exactly the `g = 0` specialization of an Euler-relation argument.

**Why now?** Mathlib already provides `SimpleGraph.IsAcyclic`, `SimpleGraph.Connected`,
and `SimpleGraph.IsTree.card_edgeFinset`; only the converse direction is absent, and our
Euler bookkeeping supplies the arithmetic core.

## 5. The balancing condition: from metric graphs to tropical subvarieties

A tropical curve embedded in `ℝ^N` carries primitive integer direction vectors
`d_e ∈ ℤ^N` and multiplicities `w_e ∈ ℕ` on its edges, subject to the **balancing
condition** `∑_{e ∋ v} w_e · d_e = 0` at every vertex. Extending `StableGraph` with an
incidence-respecting direction assignment and proving that balancing is preserved under
edge contraction (the contracted directions add) would tie our combinatorial types to
genuine tropical algebraic geometry.

The key insight is that balancing is a finite `ℤ`-linear condition, the tropical analogue
of the Cauchy–Riemann equations, and it interacts with contraction additively: merging
two balanced vertices yields a balanced vertex because the shared edge's contributions
cancel.

**Why now?** Mathlib's `ℤ`-module and `Finsupp`/`Fintype` linear-algebra API makes the
balancing equation directly expressible, and our `genus_preserved_under_contraction`
gives the template for proving the corresponding direction-vector cancellation.
