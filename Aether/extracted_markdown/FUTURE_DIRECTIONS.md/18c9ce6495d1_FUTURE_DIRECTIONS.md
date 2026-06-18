# Future Directions: Fractal Topology via Lattice-Theoretic Dimension

This cycle established the foundational toolkit for the **topological Krull dimension**
`topKrullDim X := Order.krullDim (Opens X)` — the order-theoretic Krull dimension of the
frame of open sets of a space. The file `Geometry/TopologicalKrullDim.lean` proves, with
`sorry = 0` and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

* `topKrullDim_eq_of_homeo` — full homeomorphism invariance (via `Homeomorph.opensCongr`);
* `topKrullDim_le_of_isOpenEmbedding` — monotonicity along open embeddings (via the image
  map `opensImg` and `Order.krullDim_le_of_strictMono`);
* `topKrullDim_of_isEmpty = 0` and `topKrullDim_punit = 1` — the small-space base cases;
* `topKrullDim_le_prod_left` / `topKrullDim_le_prod_right` — product lower bounds for
  nonempty factors (via `opensProdUniv`);
* `topKrullDim_eq_of_discrete` — for discrete spaces it is the Krull dimension of the
  full power-set lattice (via the order isomorphism `opensEquivSetDiscrete`);
* `topKrullDim_fin n = n` — the explicit constructive computation on the `n`-point
  discrete space, with an initial-segment chain for the lower bound and a cardinality
  grading `U ↦ #U ∈ Fin (n+1)` (using `krullDim_fin`) for the upper bound.

These results are the "exact tools" the program needs: a transport law, a monotonicity
law, a product law, and a fully worked finite model. The directions below build directly
on these named lemmas.

## 1. The discrete dimension is the cardinality, in full generality

The result `topKrullDim_fin n = n` is the finite shadow of a much larger statement: for a
*discrete* space the open-set lattice is the whole power set, so its chain depth should be
governed purely by cardinality. We conjecture the clean dichotomy.

**Conjecture.** For a discrete space `X`: if `X` is infinite then `topKrullDim X = ⊤`, and
if `X` is finite then `topKrullDim X = Fintype.card X` (as an element of `WithBot ℕ∞`).

The key insight is that `topKrullDim_eq_of_discrete` already reduces this to a *purely
order-theoretic* fact about `Order.krullDim (Set X)`, and the finite case is exactly the
cardinality grading already used in `topKrullDim_fin` — only the indexing type changes
from `Fin n` to an arbitrary `Fintype`. The infinite case follows by exhibiting an
`LTSeries` of every finite length using nested finite subsets, so `le_krullDim_iff`
forces the supremum to `⊤`.

**Why now?** Both halves are within reach of the present file: `topKrullDim_eq_of_discrete`
supplies the bridge to `Set X`, and the strict-mono cardinality argument from
`topKrullDim_fin` generalizes verbatim once `Fin n` is replaced by `Fintype.card`. This is
the natural "finish the base case" step before tackling non-discrete spaces.

## 2. A sum law for disjoint unions (coproducts)

Products gave us the inequalities `topKrullDim_le_prod_left/right`. The dual construction —
the disjoint union `X ⊕ Y` — should admit an *exact* law rather than a one-sided bound,
because an open set in `X ⊕ Y` is precisely a pair of open sets.

**Conjecture.** `topKrullDim (X ⊕ Y) = max (topKrullDim X) (topKrullDim Y)` whenever both
summands are nonempty, and the two open inclusions `X ↪ X ⊕ Y`, `Y ↪ X ⊕ Y` realize the
`≥` direction through `topKrullDim_le_of_isOpenEmbedding`.

The key insight is that `Opens (X ⊕ Y) ≃o Opens X × Opens Y` as a *product of lattices*,
and the Krull dimension of a product of two bounded lattices is the maximum of the two
dimensions (a chain in the product projects to chains in each factor whose lengths add up,
but a longest chain can only ever move in one coordinate at a time once the other is
saturated). The inclusions being open embeddings is exactly the hypothesis of the lemma we
already proved.

**Why now?** `topKrullDim_le_of_isOpenEmbedding` immediately delivers `max (…) (…) ≤
topKrullDim (X ⊕ Y)`; only the reverse `≤` needs the lattice-product isomorphism, which is
a small addition to the `opensEquivSetDiscrete`-style boilerplate already in the file.

## 3. Sober reconstruction: `topKrullDim` sees only the locale

Our invariant is defined entirely from `Opens X`, so it is blind to any topological data
not visible in the frame. This predicts that `topKrullDim` is invariant under the
soberification (and, more strongly, under any map inducing a frame isomorphism), even when
the spaces are not homeomorphic.

**Conjecture.** If `f : X → Y` induces an order isomorphism `Opens Y ≃o Opens X` (e.g. the
soberification unit, or any `Topology.IsInducing` dense-image map with the right
properties), then `topKrullDim X = topKrullDim Y`. In particular sober reflection preserves
`topKrullDim`.

The key insight is that `topKrullDim_eq_of_homeo` is really a corollary of a sharper lemma
"`Opens X ≃o Opens Y ⇒ topKrullDim X = topKrullDim Y`", which factors directly through
`Order.krullDim_eq_of_orderIso` — the homeomorphism is only used to *produce* the order
isomorphism via `opensCongr`. Extracting that intermediate lemma makes the locale-level
invariance explicit and immediately reusable.

**Why now?** The proof of `topKrullDim_eq_of_homeo` already passes through exactly this
order isomorphism; refactoring it to take an `Opens X ≃o Opens Y` argument is a one-line
generalization that unlocks the entire "locale, not space" viewpoint and connects to
Mathlib's developing frame/locale theory.

## 4. Subspace monotonicity and the open-cover formula

`topKrullDim_le_of_isOpenEmbedding` handles open subspaces. The next structural question is
how dimension behaves for *arbitrary* subspaces and for *covers*, the local-to-global step
needed for any fractal application.

**Conjecture.** (a) For any subspace `A ⊆ X`, `topKrullDim A ≤ topKrullDim X` is *false* in
general but holds for locally closed `A`; (b) if `X = ⋃ i, Uᵢ` is an open cover then
`topKrullDim X = ⨆ i, topKrullDim Uᵢ`.

The key insight is that a chain of open sets of `X` restricts to a chain on each `Uᵢ`, and
a maximal chain must "live" in some single member of the cover near its top — so the global
chain depth is the supremum of the local depths, exactly mirroring how covering dimension
is computed locally. Part (a)'s open case is `topKrullDim_le_of_isOpenEmbedding`; the
locally-closed case composes it with the closed-subspace analogue.

**Why now?** The open-embedding lemma is precisely the `≥`-direction building block for the
cover formula, and `opensImg` already provides the restriction machinery. The cover formula
is the indispensable bridge toward the iterated-function-system fractals (Cantor set,
Sierpiński triangle) that motivate the whole program, since those are presented by
self-similar open covers.

## 5. Decidable `#eval` of `topKrullDim` for finite `T₀` spaces

`topKrullDim_fin` shows the discrete (antichain) finite case equals the point count. For
*general* finite spaces — equivalently finite preorders — the dimension should be the
height of the specialization order and, crucially, **computable**.

**Conjecture.** For a finite `T₀` space `X`, `topKrullDim X` equals the height (longest
chain minus one) of the specialization preorder, and there is a `Decidable`/`#eval`-able
function `finiteTopKrullDim : X → ℕ` proven equal to it, runnable on concrete examples such
as the Sierpiński space (giving `1`) and the `n`-point chain (giving `n`).

The key insight is that for a finite space, `Opens X` is order-isomorphic to the lattice of
down-sets of the specialization preorder, and the Krull dimension of a finite distributive
lattice equals the height of its poset of join-irreducibles (Birkhoff representation) —
which for the down-set lattice is just the preorder itself. So the abstract `Order.krullDim`
collapses to a finite, decidable graph-height computation.

**Why now?** `topKrullDim_eq_of_discrete` plus `topKrullDim_fin` already verify the
antichain case as a `#eval`-checkable instance, demonstrating that the lattice side is
tractable in Lean. Replacing "power set" by "down-set lattice" is the single missing
ingredient, and once present it makes `topKrullDim` a *computable* invariant of finite
topological models — directly enabling decidable verification of all the conjectures above
on small examples.
