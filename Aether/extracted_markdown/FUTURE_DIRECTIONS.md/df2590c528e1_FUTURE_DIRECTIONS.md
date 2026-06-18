# Future Directions — Threshold Clique-Count Tropical Valuations

Derived from the research cycle that produced
`Catalog/Bridges/RipsCliqueTropical.lean` and
`Catalog/Bridges/RipsCliqueAdditivity.lean`. Those files define, for each fixed
clique dimension `k`, the threshold clique count `cliqueCount α k t` of the Rips
graph `ripsGraph α t`, and prove: scale monotonicity, dimension-0 stability
(`= Fintype.card α`), vanishing at negative scale, functoriality under injective
1-Lipschitz maps, exact additivity over a no-cross-edge partition, and a max-plus
tropical packaging on `WithBot ℕ` with the bridge identity
`c_k(s) ⊕ c_k(t) = c_k(max s t)`.

The following conjectures are bold, falsifiable, and within reach of the same
machinery.

## 1. Strict clique-jump scales are finite and dimension-monotone

**Conjecture.** For a finite pseudometric space `α`, the set of scales `t` at
which `cliqueCount α k` strictly increases is finite, has cardinality at most
`Nat.choose (Fintype.card α) (k+1)`, and the largest such jump scale is
*nonincreasing* in `k` (higher simplices appear no later than lower ones once
they can appear at all).

**The key insight is** that every jump happens exactly at a *pairwise distance
value*, so the jump set injects into the finite multiset of realized distances;
counting cliques through these breakpoints turns the real-parameter filtration
into a finite combinatorial word.

**Why now?** `cliqueCount_mono` already gives monotone step functions and
`cliqueCount_neg_eq_zero` / `cliqueCount_zero` pin the boundary values, so the
jump set is a well-defined finite object whose cardinality bound is a direct
`Set.ncard` estimate against the clique Finset.

## 2. Tropical clique polynomial is a complete distance-order invariant

**Conjecture.** The tropical generating object `t ↦ ⨁ₖ X^k · c_k(α,t)` (max-plus
coefficients in `WithBot ℕ`) determines, and is determined by, the *order type*
of the pairwise distance matrix of `α` up to isometry-of-orderings; two finite
spaces share all profiles `c_k(·,t)` iff their Rips filtrations are simplicially
isomorphic at every scale.

**The key insight is** that the whole family `(c_k)_k` records the face vector of
each threshold complex, and the threshold complex is exactly the order-filtration
of the distance matrix — so the tropical polynomial is the persistence-style
fingerprint of that order.

**Why now?** `tropNatValuation` and `ripsCliqueProfile_trop_add` already package
single dimensions tropically; assembling them across `k` is a finite max-plus sum,
and the additivity lemma supplies the building block for the reconstruction
direction on block-diagonal distance matrices.

## 3. Functoriality is sharp: 1-Lipschitz quotients lose exactly the collapsed cliques

**Conjecture.** For a (not necessarily injective) 1-Lipschitz `f : α → β`,
`cliqueCount β k t = cliqueCount α k t − (number of α-cliques whose image under
f has fewer than k+1 vertices)` whenever `f` is *edge-surjective* onto
`ripsGraph β t`; injectivity is the special case where the correction term is `0`.

**The key insight is** that the only way functoriality (`cliqueCount_le_of_
lipschitz_injective`) can fail without injectivity is vertex identification inside
a clique, so the defect is governed precisely by fibers meeting a common clique.

**Why now?** The image lemma `isNClique_image_of_lipschitz` already isolates the
card-preservation step at `Finset.card_image_of_injective`; replacing it by
`Finset.card_image_le` exposes the exact loss term, making the correction
formula a bookkeeping refinement rather than new theory.

## 4. Max-plus superadditivity is the generic law; additivity detects disconnection

**Conjecture.** For *every* partition `A ∪ B = univ` (cross-edges allowed),
`cliqueCount α k t ≥ cliqueCountIn α k t A + cliqueCountIn α k t B`, with equality
for all `k ≥ 1` **iff** there are no cross-edges at scale `t`. Thus the additivity
defect `c_k(univ) − c_k(A) − c_k(B)` is a nonnegative monotone "interaction
energy" that first becomes positive exactly at the scale where `A` and `B` merge.

**The key insight is** that cross-spanning cliques are counted by neither
restricted term, so the defect equals the number of cliques meeting both parts —
a quantity that is zero precisely under the `no-cross-edge` hypothesis already
used in `cliqueCount_eq_add_of_noCross`.

**Why now?** The exact-additivity theorem is the equality case; the inequality is
the same `Set.ncard_le_ncard` argument applied to the (still disjoint) union of
restricted clique sets, and the "iff" is `clique_subset_or_of_noCross` read
contrapositively.

## 5. The clique profile dominates the edge profile and refines connectivity

**Conjecture.** For `k = 1` the threshold clique count equals the edge count of
`ripsGraph α t`, and the first scale at which `cliqueCount α (n−1) t` becomes
positive (an `n`-clique = complete subgraph on all points) coincides with the
diameter of `α`; more generally `c_k` strictly refines the connected-component
profile, separating point clouds that `π₀`-persistence cannot.

**The key insight is** that a single scalar dimension parameter `k` interpolates
between edge statistics (`k = 1`) and the global completeness threshold
(`k = n−1`), so one definition subsumes the edge-count and diameter bridges
already in the catalog (`RipsEdgeCountProfile`, `sphere_diam_bound`).

**Why now?** `cliqueCount_zero` and `cliqueCount_mono` are the `k = 0` and
monotonicity anchors; the `k = 1` identification is a direct count of 2-element
cliques against `SimpleGraph.edgeFinset`, and `sphere_diam_bound` already provides
the diameter machinery for the top-dimensional endpoint.
