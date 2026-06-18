# Future Directions: Combinatorial Types of Tropical Moduli Curves

The file `Tropical/MarkedModuli.lean` formalizes the combinatorial type `MarkedCombType`
of a stable tropical curve of genus `g` with `n` marked points, and proves the sharp
edge/dimension bound `|E| ≤ 3g − 3 + n` (with the unmarked case `|E| ≤ 3g − 3`), the
tree characterization `g = 0 ↔ |E| = |V| − 1`, genus-invariance under edge contraction,
and a tight trivalent construction realizing `|E| = 3g − 3` for every `g ≥ 2`. The
directions below extend that scaffold.

## 1. The full face poset of M_{g,n}^trop is graded by edge count

We proved that contracting a non-loop edge preserves genus (`genus_contraction`). The
natural next step is to upgrade `MarkedCombType` from a bare arithmetic record into a
*poset* under the contraction relation `G' ≤ G ⇔ G'` is obtained from `G` by a sequence
of edge contractions, and to prove this poset is **graded** by `|E|`, with the top elements
exactly the trivalent types of `exists_tight_trivalent`.

The key insight is that each contraction lowers `|E|` by exactly one while leaving `g`
(and, in the marked refinement, `n`) fixed, so `|E|` is a rank function: every maximal
chain from a type with `e` edges down to the one-vertex type has length `e`. This makes
the abstract bound `|E| ≤ 3g − 3 + n` literally the *dimension* of the corresponding cone
of `M_{g,n}^trop`.

**Why now?** `genus_contraction` already isolates the only nontrivial arithmetic; what
remains is order-theoretic bookkeeping on top of the existing structure, for which
Mathlib's `Order`/`Preorder` and `Nat`-graded API are directly applicable.

## 2. Refine the leg structure to recover the stability inequality 2g(v) − 2 + val(v) > 0

Our `deg` field lumps edge-ends and legs together. Splitting it into `edgeDeg` and `legDeg`
with a per-vertex genus `g(v)` would let us state the *true* stability condition
`2·g(v) − 2 + edgeDeg(v) + legDeg(v) > 0` instead of the blanket `deg ≥ 3`, and recover the
edge bound as a corollary by summing the local inequalities.

The key insight is that the global handshaking sum of the local stability quantities
telescopes: `∑_v (2g(v) − 2 + val(v)) = 2·(total vertex genus) − 2|V| + 2|E| + n`, so the
positivity of each summand controls `|E|` exactly as the uniform `deg ≥ 3` hypothesis does,
but now allows higher-genus vertices (vertices of positive weight).

**Why now?** The proof of `marked_edge_bound` is a single `Finset.sum_le_sum` plus
`linarith`; replacing the constant lower bound `3` by the vertex-dependent stability
quantity is a localized change that reuses the same summation lemma.

## 3. A balancing condition turning MarkedCombType into a tropical subvariety of ℤ^d

Equip each edge with a primitive integer direction vector `d_e ∈ ℤ^d` and a weight
`w_e ∈ ℕ`, and impose the **balancing condition** `∑_{e ∋ v} w_e · d_e = 0` at every
vertex. The conjecture to formalize: a balanced weighted `MarkedCombType` of genus `g`
spans an affine subspace of `ℝ^d` of dimension `≤ min(d, 3g − 3 + n)`, tying the
combinatorial bound to the ambient embedding dimension.

The key insight is that balancing is the tropical analogue of the Cauchy–Riemann
equations: it is a finite system of linear equations over `ℤ` whose solution space is
exactly the lattice of admissible slope data, so its rank is computable by Mathlib's
`Matrix.rank` machinery and bounded by our edge count.

**Why now?** `MarkedCombType` already records vertex–edge incidence through `deg`; adding
`dir : edges → ℤ^d` and `wt : edges → ℕ` plus a `balanced` field is a conservative
extension, and the resulting statement is a finite `ℤ`-linear-algebra fact Lean checks
directly.

## 4. Euler characteristic for disconnected types: β₁ = |E| − |V| + c and the forest theorem

Our `genus = |E| − |V| + 1` is correct only for connected graphs. Introducing the number
of connected components `c` and defining `betti₁ := |E| − |V| + c` would let us prove
`betti₁ ≥ 0` for arbitrary types and characterize **forests** by `betti₁ = 0`, generalizing
`genus_zero_iff_tree`.

The key insight is that `c` and `|E| − |V|` move in lock-step under edge deletion: deleting
an edge either drops `|E|` by one and raises `c` by one (a bridge) or just drops `|E|` by
one, so `betti₁` only ever decreases by `1` or stays fixed — an induction that yields both
nonnegativity and the forest characterization in one stroke.

**Why now?** Mathlib supplies `SimpleGraph.IsTree.card_edgeFinset` (`|E| + 1 = |V|` for
trees) and `SimpleGraph.IsAcyclic`; proving the converse direction — connected with
`|E| = |V| − 1` implies tree — would bridge our `MarkedCombType` arithmetic to Mathlib's
graph theory and close a genuine gap in the library.

## 5. Failure of tropical Torelli at genus 3 via the metric-graph Laplacian

Attach edge lengths (as in a full `TropicalCurve` over `MarkedCombType`) and define the
weighted graph Laplacian `L` with `L_{ii} = ∑_j 1/ℓ(ij)` and `L_{ij} = −1/ℓ(ij)`. The
tropical Jacobian is `ℝ^g / im(L†)`. The conjecture: the tropical Torelli map
(combinatorial type ↦ Jacobian) is **non-injective starting at g = 3**, with the failure
detected by two distinct trivalent types sharing the same period matrix.

The key insight is that, unlike the classical Torelli theorem, the tropical period matrix
forgets enough of the combinatorial type that genus-3 graphs can collide; exhibiting one
explicit colliding pair (e.g. the `K_4` graph versus a theta-with-a-loop) and verifying
equal Laplacian periods makes the non-injectivity fully constructive.

**Why now?** `exists_tight_trivalent` already produces trivalent witnesses to plug in, and
Mathlib's real matrix theory (`Matrix.of`, `Matrix.rank`, generalized inverses) is mature
enough that the period-matrix equality reduces to a finite-dimensional linear-algebra
computation Lean can carry out.
