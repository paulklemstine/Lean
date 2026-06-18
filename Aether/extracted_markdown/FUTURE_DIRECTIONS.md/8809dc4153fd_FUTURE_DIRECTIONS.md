# Future Directions: Combinatorial Types of Tropical Moduli Curves

The file `Tropical/MarkedModuli.lean` formalizes the combinatorial type `MarkedCombType`
of a stable tropical curve of genus `g` with `n` marked points, modelled by the multiset
of vertex valences together with the edge and leg counts. On top of this scaffold it
proves the handshake lower bound `3|V| ≤ ∑ deg(v)` (`three_card_le_sum`), the sharp
edge/dimension bound `|E| + 3 ≤ 3g + n` (`marked_edge_bound`) with its unmarked
specialization (`unmarked_edge_bound`), the tree characterization `g = 0 ↔ |E| + 1 = |V|`
(`genus_zero_iff_tree`), genus-invariance under contraction of a non-loop edge
(`genus_contraction`), and a tight trivalent construction realizing `|E| = 3g − 3` for
every `g ≥ 2` (`exists_tight_trivalent`). The directions below extend that scaffold.

## 1. The face poset of `M_{g,n}^trop` is graded by edge count

Upgrade `MarkedCombType` from a bare arithmetic record into a *poset* under the
contraction relation `G' ≤ G ⇔ G'` is obtained from `G` by a sequence of edge
contractions, and prove this poset is **graded** by `|E|`, with the top elements exactly
the trivalent types produced by `exists_tight_trivalent`.

The key insight is that each contraction lowers `|E|` by exactly one while leaving `g` and
`n` fixed — this is precisely what `genus_contraction` already certifies — so `|E|` is a
rank function: every maximal chain from a type with `e` edges down to the one-vertex type
has length `e`, making the abstract bound `|E| ≤ 3g − 3 + n` literally the *dimension* of
the corresponding cone of `M_{g,n}^trop`.

**Why now?** `genus_contraction` already isolates the only nontrivial arithmetic step;
what remains is order-theoretic bookkeeping for which Mathlib's `Preorder`/`GradeOrder`
and `Nat`-graded API are directly applicable. The conjecture is falsifiable: if a single
contraction failed to drop `|E|` by exactly one, the rank function would break.

## 2. Local stability `2g(v) − 2 + val(v) > 0` recovers the edge bound

The `degs` field lumps edge-ends and legs together. Splitting it into per-vertex edge
valence, leg valence, and a vertex genus `g(v)` lets us state the *true* stability
condition `2·g(v) − 2 + edgeDeg(v) + legDeg(v) > 0` in place of the blanket `deg ≥ 3`, and
recover the edge bound as a corollary by summing the local inequalities.

The key insight is that the global handshaking sum of the local stability quantities
telescopes: `∑_v (2g(v) − 2 + val(v)) = 2·(total vertex genus) − 2|V| + 2|E| + n`, so the
positivity of each summand controls `|E|` exactly as the uniform `deg ≥ 3` hypothesis does
in `three_card_le_sum` and `marked_edge_bound`, but now admits higher-genus (positive
weight) vertices.

**Why now?** The current proof of `marked_edge_bound` is a single multiset summation plus
`omega`; replacing the constant lower bound `3` by the vertex-dependent stability quantity
is a localized change reusing the same summation lemma. It is falsifiable: a weighted type
violating `|E| ≤ 3g − 3 + n` would refute the telescoping identity.

## 3. A balancing condition embeds `MarkedCombType` as a tropical subvariety of `ℤ^d`

Equip each edge with a primitive integer direction `d_e ∈ ℤ^d` and a weight `w_e ∈ ℕ`,
and impose the **balancing condition** `∑_{e ∋ v} w_e · d_e = 0` at every vertex. The
conjecture: a balanced weighted `MarkedCombType` of genus `g` spans an affine subspace of
`ℝ^d` of dimension `≤ min(d, 3g − 3 + n)`, tying the combinatorial bound to the ambient
embedding dimension.

The key insight is that balancing is the tropical analogue of the Cauchy–Riemann
equations: it is a finite `ℤ`-linear system whose solution space is exactly the lattice of
admissible slope data, so its rank is computable by Mathlib's `Matrix.rank` machinery and
bounded by the edge count controlled in `marked_edge_bound`.

**Why now?** `MarkedCombType` already records vertex–edge incidence through valences;
adding direction and weight data plus a `balanced` field is a conservative extension, and
the resulting statement is a finite-dimensional linear-algebra fact Lean checks directly.
Falsifiable: an explicit balanced type whose span exceeds `3g − 3 + n` would refute it.

## 4. Euler characteristic for disconnected types and the forest theorem

The current `genus = |E| − |V| + 1` is correct only for connected graphs (enforced by the
`connected` field). Introducing the number of connected components `c` and defining
`betti₁ := |E| − |V| + c` would let us prove `betti₁ ≥ 0` for arbitrary types and
characterize **forests** by `betti₁ = 0`, generalizing `genus_zero_iff_tree`.

The key insight is that `c` and `|E| − |V|` move in lock-step under edge deletion: deleting
an edge either drops `|E|` by one and raises `c` by one (a bridge) or drops `|E|` by one
alone, so `betti₁` only ever decreases by one or stays fixed — an induction yielding both
nonnegativity and the forest characterization in one stroke, exactly mirroring the
single-step arithmetic of `genus_contraction`.

**Why now?** Mathlib supplies `SimpleGraph.IsTree.card_edgeFinset` (`|E| + 1 = |V|` for
trees) and `SimpleGraph.IsAcyclic`; proving the converse — connected with `|E| = |V| − 1`
implies tree — would bridge our `MarkedCombType` arithmetic (where `genus_zero_iff_tree`
gives the numerical half) to Mathlib's graph theory and close a genuine library gap.

## 5. Failure of tropical Torelli at genus 3 via the metric-graph Laplacian

Attach edge lengths to a `MarkedCombType` and define the weighted graph Laplacian `L` with
`L_{ii} = ∑_j 1/ℓ(ij)` and `L_{ij} = −1/ℓ(ij)`; the tropical Jacobian is `ℝ^g / im(L†)`.
The conjecture: the tropical Torelli map (combinatorial type ↦ Jacobian) is
**non-injective starting at g = 3**, the failure detected by two distinct trivalent types
sharing the same period matrix.

The key insight is that, unlike the classical Torelli theorem, the tropical period matrix
forgets enough of the combinatorial type that genus-3 graphs can collide; exhibiting one
explicit colliding pair (e.g. the `K₄` graph versus a theta-with-a-loop, both reachable
from `exists_tight_trivalent`) and verifying equal Laplacian periods makes the
non-injectivity fully constructive and falsifiable.

**Why now?** `exists_tight_trivalent` already produces trivalent witnesses to plug in, and
Mathlib's real matrix theory (`Matrix.of`, `Matrix.rank`, generalized inverses) is mature
enough that the period-matrix equality reduces to a finite-dimensional linear-algebra
computation Lean can carry out.
