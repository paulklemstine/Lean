# Future Directions: The Chain Complex of a Clique Complex

The new file `Catalog/Shared/CliqueComplexChain.lean` builds, fully formally and
with zero `sorry`, the integral simplicial chain complex attached to the clique
complex `Δ(G)` of an arbitrary simple graph. Its centerpiece is an
order-theoretic, self-contained proof of the defining chain-complex identity
`∂ ∘ ∂ = 0` (`boundary_comp_self` / `boundary_sq_zero`), obtained from a
sign-reversing involution on ordered pairs of vertices (`sgn_swap`,
`bd_bdSingle`). The clique-theoretic side is anchored by `IsFace`,
`isFace_downward_closed`, `empty_isFace`, `singleton_isFace`, and the bridge
lemma `bdSingle_support_isFace`, which shows the boundary of a clique-face is
supported on clique-faces — so the whole construction genuinely restricts to
`Δ(G)`. This connects directly to the catalog's existing graph-theoretic work
(`Catalog/Shared/RegisterGraphColoring.lean`, `Catalog/Computation/CliqueLowerBound.lean`,
`Catalog/Geometry/HadwigerConjecture.lean`) where cliques already play a central
role, and it supplies the missing homological-algebra layer over those purely
combinatorial files. The directions below are concrete, falsifiable next steps.

## 1. The boundary restricts to an honest endomorphism of the clique subcomplex

Right now `bd` is defined on the free module on *all* finite vertex sets, and
`bdSingle_support_isFace` only certifies that clique-chains map to clique-chains
at the level of supports. The next step is to package the clique-chains as an
actual submodule `cliqueChains G = Finsupp.supported ℤ ℤ {s | IsFace G s}` and
prove `bd` maps it into itself, yielding a genuine `ℤ`-chain complex
`(cliqueChains G, bd)` and hence well-defined homology groups `Hₖ(Δ(G); ℤ)`.

The key insight is that downward closure of cliques (`isFace_downward_closed`)
is exactly the algebraic condition needed for `Finsupp.supported` to be
`bd`-invariant: every face appearing in `∂s` is a subface of `s`, so no chain
ever "leaves" the subcomplex.

Why now? The submodule machinery (`Finsupp.supported`, `LinearMap.restrict`) and
`bdSingle_support_isFace` are already in place; the only missing glue is the
restriction lemma, which is a direct corollary of what is proved.

## 2. Euler characteristic equals the alternating clique-count, and is a homotopy invariant

Define the reduced Euler characteristic `χ(Δ(G)) = Σ_k (-1)^k · |{(k+1)-cliques}|`
using Mathlib's `SimpleGraph.cliqueFinset`. Conjecture: `χ(Δ(G))` equals the
alternating sum of ranks of the homology groups from Direction 1
(Euler–Poincaré), and in particular two graphs with isomorphic clique complexes
have equal `χ`.

The key insight is that the involution proving `∂² = 0` already exhibits the
exact local cancellation that, summed globally, forces the rank-counting
identity; the same `sgn`-bookkeeping that kills `∂²` controls the Euler
characteristic.

Why now? `SimpleGraph.cliqueFinset` and `Finset.card` give a fully computable
`χ`, so the conjecture can be *tested by `#eval`* on small graphs (paths, cycles,
complete graphs `Kₙ` where `Δ(Kₙ)` is a simplex with `χ = 1`) before any general
proof is attempted, making it cheaply falsifiable.

## 3. Contractibility of cone clique complexes (the apex/dominated-vertex theorem)

Conjecture: if `G` has a vertex `v` adjacent to every other vertex (a universal
"apex"), then `Δ(G)` is contractible, i.e. its reduced homology vanishes in all
degrees. More generally, if `v` is *dominated* by `w` (every neighbor of `v` is a
neighbor of `w`), then `Δ(G)` and `Δ(G - v)` have the same homology.

The key insight is that an apex vertex turns `Δ(G)` into a cone, and the cone's
nullhomotopy is realized concretely by the chain-level operator
`hₖ(s) = ± (insert v s)` satisfying the algebraic homotopy identity
`∂h + h∂ = id`, which can be verified by exactly the kind of `sgn`/`erase`
manipulation already automated in `sgn_erase_lt` and `sgn_erase_not_lt`.

Why now? The sign lemmas needed for an `insert`-vs-`erase` chain homotopy are the
mirror image of the `erase`-vs-`erase` lemmas just proved, so the hardest
infrastructure already exists and can be reused with minimal adaptation.

## 4. Homology detects independent sets: H₀ counts connected components of G

Conjecture: `H₀(Δ(G); ℤ) ≅ ℤ^{c}` where `c` is the number of connected
components of `G`, because the `1`-faces (edges) are precisely `G`'s edges and
`0`-homology of any simplicial complex counts path-components of its 1-skeleton.
This is the first nontrivial homology computation and directly links the abstract
complex back to the combinatorics of `SimpleGraph.ConnectedComponent`.

The key insight is that the image of `∂₁` is spanned by `{w} - {v}` for each edge
`v ~ w`, so the cokernel `H₀` is exactly the quotient of the free module on
vertices by the "edge-difference" relations — which is the definition of the free
module on connected components.

Why now? Mathlib already has `SimpleGraph.ConnectedComponent` with a developed
API and `Finsupp` quotient tooling, so the isomorphism can be built from existing
parts rather than from scratch, and it can be sanity-checked on disjoint unions
of complete graphs.

## 5. A persistence/filtration version: homology of the clique complex along an edge ordering

Order the edges of `G` and consider the increasing filtration `G₀ ⊆ G₁ ⊆ ⋯ ⊆ G`
adding one edge at a time. Conjecture: the resulting maps on clique homology
`Hₖ(Δ(Gᵢ)) → Hₖ(Δ(Gᵢ₊₁))` define a persistence module whose barcode is a graph
isomorphism invariant strictly finer than the `f`-vector of cliques.

The key insight is that adding a single edge `e = {u,v}` changes `Δ(G)` only by
attaching the new cliques containing `e`, so each filtration step is a controlled
"cofiber" whose effect on homology is computable from the link of `e` — a local
move whose chain-level description is again governed by the `sgn`/`erase`
calculus established here.

Why now? Topological data analysis over `ℤ` is essentially absent from the
catalog, yet the clique (Vietoris–Rips) complex is its canonical input; with the
`∂² = 0` foundation in hand, persistence is the natural high-impact direction,
and small filtrations are again `#eval`-checkable for rapid falsification.
