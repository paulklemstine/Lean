# Future Directions — Tropical Valuation Profiles of Rips Edge-Count Data

Derived from the two research cycles in
`RipsTropicalValuationProfile.lean` (cycle 1) and `RipsTropicalInterleaving.lean` (cycle 2),
which built the first explicit **Applications → Bridges** valuation bridge: the monotone
edge-count profile of the Vietoris–Rips graph is a morphism of the additive-idempotent
(`max`) monoid underlying the Bridges tropical valuation object `tropicalization_base`, and
this morphism is stable under both pointwise metric domination and additive interleaving.

Each conjecture below is falsifiable and stated so it can be attempted directly in Lean 4.

## 1. Tropical multiplicative obstruction is exactly the cardinality bound

**Conjecture.** For every finite metric space `α` with `2 ≤ Fintype.card α`, the edge-count
profile is *never* a full `TropHom` into `tropicalization_base`: there exist `r s` with
`edgeCountProfile α (r * s) ≠ edgeCountProfile α r * edgeCountProfile α s`, and the
obstruction is witnessed by the uniform bound `edgeCountProfile α r ≤ Fintype.card (Sym2 α)`.

The key insight is that a *counting* invariant forgets the multiplicative semiring and can
only ever be a max-semilattice morphism, so the failure of multiplicativity is structural,
not incidental — it is forced by the finite radius `Fintype.card (Sym2 α)`.

Why now? Cycle 1 already isolated `edgeCountProfile_tropical_add` (max preserved) and
`edgeCountProfile_le_card_sym2` (finite radius); negating multiplicativity is the natural
next falsification and pins down the precise categorical home of the invariant.

## 2. The profile is the tropical valuation of a genuine `TropicalValuationCarrier`

**Conjecture.** There is a `TropicalValuationCarrier` whose carrier is the free product of
the edge indicators of `α` and whose `val` recovers `edgeCountProfile` at each integer
threshold; consequently `valuationReconstruct` produces an `UltraNormObj` whose norm is the
edge count, and the Bridges theorem `valuationReconstruct_obj_ultrametric` yields a genuine
ultrametric (strong-triangle) inequality on edge-count data.

The key insight is that edge counts, being subadditive under union of threshold-graphs,
already satisfy `val_add ≤ max`, so they fit the `TropicalValuationCarrier` axioms once the
carrier is taken to be the lattice of Rips subgraphs rather than `ℕ` itself.

Why now? The Bridges file exposes `valuationReconstruct` and its ultrametric theorem as a
ready-made functor; cycle 1 supplied the `max`-monoid morphism, so only the carrier needs to
be constructed to upgrade the bridge from a monoid map to a full reconstruction.

## 3. Interleaving distance of profiles is Lipschitz in the dissimilarity sup-distance

**Conjecture.** Define the profile interleaving distance `d_I(P₁, P₂)` as the least `c` such
that `P₁(ε) ≤ P₂(ε+c)` and `P₂(ε) ≤ P₁(ε+c)` for all `ε`. Then for symmetric dissimilarities
`d₁, d₂` on a finite carrier, `d_I(profile d₁, profile d₂) ≤ sup_{x,y} |d₁ x y − d₂ x y|`.

The key insight is that cycle 2's `dissimEdgeCount_additive_interleaving` is exactly the
one-sided half of a bottleneck/interleaving stability theorem; symmetrizing the additive
bound turns the comparison principle into a genuine 1-Lipschitz stability estimate.

Why now? Cycle 2 already proved the one-directional shift bound with a clean `linarith`
argument; the symmetric packaging is within reach and would connect this bridge directly to
the persistence-stability theory used throughout the BoltzmannBridge applications subtree.

## 4. Tropical functoriality under 1-Lipschitz maps of point clouds

**Conjecture.** A 1-Lipschitz (distance non-increasing) map `f : α → β` of finite metric
spaces induces, for every threshold, an inequality `edgeCountProfile_image ≤ edgeCountProfile α`
on the edge counts of the image graph, and this assignment is functorial (respects identities
and composition), giving a `TropHom`-compatible action on the tropical `max`-monoids.

The key insight is that 1-Lipschitz maps send Rips edges to Rips edges (the cycle-1
`dissimGraph_dominated_le` mechanism applied to the pullback dissimilarity), so the
edge-count profile becomes a *functor* from the category of finite metric spaces and
contractions into the tropical valuation category.

Why now? Cycle 1 generalized `ripsGraph` to arbitrary dissimilarities via `dissimGraph`,
which is precisely the device needed to pull back a metric along `f`; the functoriality
laws then mirror the already-proven `TropHom.comp`/`TropHom.id` laws in the Bridges file.

## 5. A strict-jump count equals the number of distinct pairwise distances

**Conjecture.** For a finite metric space `α`, the number of thresholds at which
`edgeCountProfile α` strictly increases equals the number of *distinct* values taken by the
pairwise distance function on unordered pairs (restricted to integer thresholds), and the
total increase telescopes to `Fintype.card (Sym2 α)` minus the diagonal contribution.

The key insight is that each new edge appears at exactly one critical scale, so the profile's
jump set is in bijection with the (ceilinged) distance spectrum — turning a tropical
valuation profile into a combinatorial fingerprint of the metric.

Why now? Cycle 1 established monotonicity and the `Fintype.card (Sym2 α)` ceiling; counting
the jumps is the natural quantitative refinement and would make the profile a computable,
distance-recovering invariant suitable for downstream TDA algorithms.
