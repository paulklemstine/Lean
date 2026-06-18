# Future Directions: Combinatorial Types of Marked Tropical Moduli Curves

The file `Tropical/MarkedModuli.lean` introduces the arithmetic combinatorial type
`MarkedCombType` of a stable tropical curve of genus `g` with `n` marked legs, and proves
a tight package of results: the sharp dimension/edge bound `marked_edge_bound`
(`|E| ≤ 3g − 3 + n`), its unmarked corollary `unmarked_edge_bound` (`|E| ≤ 3g − 3`), the
tree characterization `genus_zero_iff_tree` (`g = 0 ↔ |E| = |V| − 1`), genus invariance
under contraction of a non-loop edge `genus_contraction`, and the tight trivalent
realization `exists_tight_trivalent` (`|E| = 3g − 3` for every `g ≥ 2`). The adversarial
witness `exists_negative_genus` stress-tests the bound and shows it is a consequence of
*stability alone*, surviving disconnection and signed (negative) genus.

The synthesis to carry forward: the entire dimension theory of `M_{g,n}^trop` collapses to
two local facts — the handshake identity `∑ deg = 2|E| + n` and vertex stability
`deg ≥ 3` — with the genus entering only through the linear substitution `|V| = |E| − g + 1`.
Everything below pushes on exactly that pressure point. These directions also connect to the
existing catalog: the genus formula and canonical-divisor arithmetic in
`Tropical/CompleteGraph.lean` (`completeGraph_genus`, `K3_genus`, `K4_genus`) provide
ready-made worked examples (`K_4` is trivalent of genus 3), and the chip-firing /
Baker–Norine machinery referenced there is the natural home for the Jacobian directions.

## 1. The contraction poset of `M_{g,n}^trop` is graded by edge count

Upgrade `MarkedCombType` to a poset under the contraction relation `G' ≤ G ⇔ G'` arises
from `G` by a sequence of non-loop contractions, and prove this poset is **graded** with
rank function `|E|`, top elements exactly the trivalent types of `exists_tight_trivalent`.

The key insight is that `genus_contraction` already shows each contraction drops `|E|` by
exactly one while fixing `g` (and `n`), so `|E|` is a literal rank function: every maximal
chain from an `e`-edge type down to the one-vertex type has length `e`, making the abstract
bound `|E| ≤ 3g − 3 + n` the *dimension* of the corresponding cone.

**Why now?** `genus_contraction` plus `contractDeg_card` isolate the only arithmetic; what
remains is order-theoretic bookkeeping on Mathlib's `Preorder`/`Nat`-graded API, and the
trivalent tops are already constructed.

## 2. Local stability `2g(v) − 2 + val(v) > 0` from a refined leg structure

Split `deg` into `edgeDeg` and `legDeg` with a per-vertex genus weight `g(v)`, and replace
the blanket `deg ≥ 3` by the true stability inequality `2·g(v) − 2 + edgeDeg(v) + legDeg(v) > 0`,
recovering the edge bound by summing the local inequalities.

The key insight is that the global handshake sum of the local stability quantities
telescopes: `∑_v (2g(v) − 2 + val(v)) = 2·(total vertex genus) − 2|V| + 2|E| + n`, so the
positivity of each summand controls `|E|` exactly as the uniform `deg ≥ 3` hypothesis does,
while now admitting higher-genus (positive-weight) vertices.

**Why now?** `marked_edge_bound` is literally `three_mul_numVerts_le` (a `card_nsmul_le_sum`)
plus `linarith`; swapping the constant lower bound `3` for the vertex-dependent stability
quantity is a localized edit that reuses the same summation lemma.

## 3. A balancing condition embedding `MarkedCombType` into `ℤ^d`

Equip each edge with a primitive direction `d_e ∈ ℤ^d` and weight `w_e ∈ ℕ`, imposing the
**balancing condition** `∑_{e ∋ v} w_e · d_e = 0` at every vertex, and conjecture that a
balanced weighted type of genus `g` spans an affine subspace of dimension `≤ min(d, 3g − 3 + n)`.

The key insight is that balancing is the tropical analogue of the Cauchy–Riemann equations:
a finite `ℤ`-linear system whose solution lattice is the admissible slope data, with rank
computable via Mathlib's `Matrix.rank` and bounded by our edge count.

**Why now?** Adding `dir` and `wt` fields plus a `balanced` field is a conservative extension
of the existing incidence data, and the resulting bound is a finite linear-algebra fact Lean
checks directly — and `exists_tight_trivalent` already supplies extremal witnesses to embed.

## 4. Betti number `β₁ = |E| − |V| + c` and the forest theorem for disconnected types

`genus = |E| − |V| + 1` is correct only for connected types — `exists_negative_genus`
exhibits a disconnected type with `g = −1`. Introduce the component count `c`, define
`betti₁ := |E| − |V| + c`, prove `betti₁ ≥ 0` for arbitrary types, and characterize
**forests** by `betti₁ = 0`, generalizing `genus_zero_iff_tree`.

The key insight is that `c` and `|E| − |V|` move in lock-step under edge deletion: removing
an edge either drops `|E|` by one and raises `c` by one (a bridge) or only drops `|E|`, so
`betti₁` never increases — an induction yielding nonnegativity and the forest characterization
together. The negative-genus witness shows precisely why `c` cannot be ignored.

**Why now?** Mathlib supplies `SimpleGraph.IsTree.card_edgeFinset` and `SimpleGraph.IsAcyclic`;
proving the converse (connected with `|E| = |V| − 1` ⟹ tree) would bridge our `MarkedCombType`
arithmetic to Mathlib's graph theory and close a genuine library gap.

## 5. Failure of tropical Torelli at genus 3 via the metric-graph Laplacian

Attach edge lengths and define the weighted graph Laplacian `L` (`L_{ii} = ∑_j 1/ℓ(ij)`,
`L_{ij} = −1/ℓ(ij)`), with tropical Jacobian `ℝ^g / im(L†)`. Conjecture: the tropical Torelli
map (type ↦ Jacobian) is **non-injective starting at `g = 3`**, witnessed by two distinct
trivalent types sharing a period matrix.

The key insight is that, unlike the classical Torelli theorem, the tropical period matrix
forgets enough combinatorial data that genus-3 graphs collide; exhibiting one explicit
colliding pair (the `K_4` graph — already available via `completeGraph_genus 4` /
`K4_genus` in `Tropical/CompleteGraph.lean` — versus a theta-with-a-loop) and verifying
equal Laplacian periods makes the non-injectivity fully constructive.

**Why now?** `exists_tight_trivalent` and the catalog's `K4_genus` provide concrete trivalent
genus-3 witnesses, and Mathlib's real matrix theory (`Matrix.of`, `Matrix.rank`, generalized
inverses) reduces the period-matrix equality to a finite-dimensional computation Lean can run.
