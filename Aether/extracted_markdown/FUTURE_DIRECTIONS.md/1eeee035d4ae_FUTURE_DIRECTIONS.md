# Future Directions: Combinatorial Types of Marked Tropical Moduli Curves

The file `Tropical/MarkedModuli.lean` formalizes the combinatorial type
`TropicalModuli.MarkedCombType` of a stable tropical curve of genus `g` with `n`
marked points (legs), and proves:

* `marked_edge_bound` — the sharp dimension bound `|E| + 3 ≤ 3g + n` (i.e. `|E| ≤ 3g − 3 + n`);
* `unmarked_edge_bound` — the classical `|E| + 3 ≤ 3g` when `n = 0`;
* `genus_zero_iff_tree` — the tree characterization `g = 0 ↔ |E| + 1 = |V|`;
* `contract` / `genus_invariance_counts` / `genus_contraction` — a total non-loop
  edge-contraction construction and genus invariance under it;
* `exists_tight_trivalent` — a trivalent realization with `|E| = 3g − 3` for every `g ≥ 2`,
  proving the bound is sharp.

The directions below extend this scaffold; each is testable and falsifiable.

## 1. The face poset of `M_{g,n}^trop` is graded by edge count

Upgrade `MarkedCombType` to a *poset* under the contraction order `G' ≤ G` iff `G'` is
obtained from `G` by a finite sequence of edge contractions, and prove this poset is
**graded** with rank function `|E|`, the top elements being exactly the trivalent types
produced by `exists_tight_trivalent`.

The key insight is that `genus_contraction` together with `genus_invariance_counts` shows
each contraction lowers `|E|` by exactly one while fixing `g` and `n`, so `|E|` is a
genuine rank: every maximal chain from an `e`-edge type to the one-vertex type has length
`e`, making `marked_edge_bound` literally the dimension of the corresponding cone.

**Why now?** The arithmetic core is already isolated in `genus_invariance_counts`; what
remains is order-theoretic bookkeeping built directly on Mathlib's `Order`/`Preorder` and
`Nat`-graded API, with `contract` supplying the covering relation.

## 2. Per-vertex genus and the local stability inequality `2g(v) − 2 + val(v) > 0`

Refine the `deg` field into `edgeDeg` and `legDeg` and add a per-vertex genus `g(v)`, then
replace the blanket `stable : 3 ≤ deg v` by the true stability condition
`2·g(v) − 2 + edgeDeg(v) + legDeg(v) > 0`, recovering `marked_edge_bound` by summing local
inequalities and allowing positive-weight (higher-genus) vertices.

The key insight is that the handshaking sum of the local stability quantities telescopes:
`∑_v (2g(v) − 2 + val(v)) = 2·(total vertex genus) − 2|V| + 2|E| + n`, so positivity of
each summand controls `|E|` exactly as the uniform `deg ≥ 3` hypothesis does in the current
`marked_edge_bound` proof.

**Why now?** That proof is a single `Finset.sum_le_sum` plus `omega`; swapping the constant
lower bound `3` for the vertex-dependent stability quantity reuses the very same summation
lemma, so the change is localized and conservative.

## 3. A balancing condition embedding `MarkedCombType` into `ℤ^d`

Equip each edge with a primitive direction `d_e ∈ ℤ^d` and weight `w_e ∈ ℕ` and impose the
**balancing condition** `∑_{e ∋ v} w_e · d_e = 0` at every vertex. Conjecture: a balanced
weighted type of genus `g` spans an affine subspace of dimension `≤ min(d, 3g − 3 + n)`,
tying `marked_edge_bound` to the ambient embedding dimension.

The key insight is that balancing is the tropical analogue of the Cauchy–Riemann
equations — a finite `ℤ`-linear system whose solution space is the lattice of admissible
slope data, so its rank is computed by `Matrix.rank` and bounded by the edge count from
`marked_edge_bound`.

**Why now?** `MarkedCombType` already records incidence through `deg`; adding `dir`, `wt`,
and a `balanced` field is a conservative extension, and the resulting statement is a finite
linear-algebra fact Lean checks directly.

## 4. Betti number for disconnected types and the forest theorem

The current `genus_rel` encodes connectedness. Introduce the component count `c` and define
`betti₁ := |E| − |V| + c`; prove `betti₁ ≥ 0` for arbitrary types and characterize
**forests** by `betti₁ = 0`, generalizing `genus_zero_iff_tree`.

The key insight is that `c` and `|E| − |V|` move in lock-step under edge deletion: removing
an edge either drops `|E|` by one and raises `c` by one (a bridge) or only drops `|E|`, so
`betti₁` decreases by `1` or is unchanged — a single induction yielding both nonnegativity
and the forest characterization.

**Why now?** Mathlib supplies `SimpleGraph.IsTree.card_edgeFinset` and
`SimpleGraph.IsAcyclic`; proving the converse (connected with `|E| = |V| − 1` ⇒ tree) would
bridge the `MarkedCombType` arithmetic to Mathlib's graph theory and close a real gap.

## 5. Failure of tropical Torelli at genus 3 via the metric-graph Laplacian

Attach edge lengths and define the weighted graph Laplacian `L` (`L_{ii} = ∑_j 1/ℓ(ij)`,
`L_{ij} = −1/ℓ(ij)`), with tropical Jacobian `ℝ^g / im(L†)`. Conjecture: the tropical
Torelli map (type ↦ Jacobian) is **non-injective starting at `g = 3`**, witnessed by two
distinct trivalent types sharing a period matrix.

The key insight is that, unlike the classical Torelli theorem, the tropical period matrix
forgets enough of the combinatorial type that genus-3 graphs collide; exhibiting one
explicit colliding pair (e.g. `K_4` versus theta-with-a-loop) and verifying equal Laplacian
periods makes non-injectivity fully constructive.

**Why now?** `exists_tight_trivalent` already produces trivalent witnesses to feed in, and
Mathlib's real matrix theory (`Matrix.of`, `Matrix.rank`, generalized inverses) is mature
enough that the period-matrix equality reduces to a finite-dimensional computation Lean can
carry out.
