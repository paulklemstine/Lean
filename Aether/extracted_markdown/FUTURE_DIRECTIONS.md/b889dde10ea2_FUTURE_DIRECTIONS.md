# Future Directions: Finite Tropical Updates for the Rips Profile Bridge

These directions continue the finite weighted-graph extension formalized in
`Catalog/Bridges/RipsTropicalProfileExtensions.lean`. Each is phrased to be a
concrete next formalization target rather than a vague aspiration.

## 1. Mayer–Vietoris merge for profiles of overlapping covers

The current `birth_glue` theorem assumes a cut-vertex separation hypothesis
(`L ∩ R = {c}`, every edge inside `L` or inside `R`). The natural generalization
is a genuine pushout: glue two finite weighted graphs along a shared *induced
subgraph*, construct the merged weight function, and prove that cross births
factor through the shared boundary as an iterated tropical sum. The key insight
is that the bottleneck distance is an ultrametric, so a cross path's value is
always the `max` over a *bounded* set of boundary-to-boundary legs, which means
the merge rule is a finite `min`-over-`max` formula rather than an unbounded
optimization. **Why now?** The achievement lemma `connAt_birth` and the master
sublevel law `connAt_iff_birth_le` already give exact equalities at the attained
threshold, so the only missing ingredient is the boundary bookkeeping — the hard
analytic core is done, and the remaining work is combinatorial.

## 2. Higher-dimensional Rips births and a multi-parameter profile

So far `birth` is a vertex-pair (1-skeleton) invariant. The next step is to
define a birth valuation for `k`-simplices of the Rips complex — the threshold at
which a simplex first appears — and to assemble the `edgeProfile` into a graded
profile counting simplices of each dimension at each scale. The key insight is
that, for the Rips construction, the birth of a simplex is exactly the `max` of
the births of its edges, so the entire higher-dimensional filtration is *still*
governed by the tropical `⊔` algebra established here, with no new metric input.
**Why now?** Mathlib already provides `SimpleGraph`, `Sym2`, and clique/cofan
machinery, and the sibling file `RipsEdgeCountProfile.lean` defines the
1-skeleton edge count; extending to cliques reuses both directly.

## 3. A quantitative, invertible reconstruction map

`profileM_injective` shows the profile determines the weight multiset but is
non-constructive about *how few* thresholds suffice. A sharper result would prove
that evaluating the profile at exactly the realized edge values (a finite set of
size `≤ |E|`) recovers the sorted weight list, and would package this as a
computable inverse `profile ↦ multiset`. The key insight is that the profile is a
step function whose only jumps occur at realized weights, so the realized weights
are precisely the discontinuity set — finitely many, totally ordered, and read
off by finite differencing. **Why now?** The reconstruction proof already locates
the critical value `a` and its predecessor `a⁻` among realized weights, so the
discontinuity-set characterization is a refactor of an argument we have verified,
not a new theorem.

## 4. Stability upgraded to a Lipschitz/interleaving statement

The present `birth_stability` and `profileF_stability` give one-sided
`ε`-shift bounds. These should be upgraded to a bona fide stability theorem: the
sup-norm distance between two weight functions controls the bottleneck distance
between their birth valuations, and the profiles are interleaved with shift `ε`.
The key insight is that the two one-sided shift inequalities already proved are
exactly the two halves of an `ε`-interleaving, so bundling them yields a
Lipschitz map into the (extended) bottleneck metric with constant `1`. **Why
now?** The Boltzmann-bridge arc in this repository already defines
`interleavingDist` and `eInterleavingDist` with a full isometry/transport API
(`CategoricalTropicalRips.lean`), so the bundled statement can be stated and
proved against existing infrastructure instead of from scratch.

## 5. Computable union–find realization with a verified `@[csimp]` bridge

The birth valuation is the classic single-linkage / minimum-bottleneck distance,
computable by union–find over edges sorted by weight. A valuable direction is to
give an explicit functional implementation of `birth` on `Fintype` vertices and
prove it equal to the `sInf` definition, exposing the equality through a kernel-
checked `@[csimp]` lemma so the spec becomes executable. The key insight is that
processing edges in nondecreasing weight order makes the *first* threshold that
connects `x` and `y` coincide with the attained infimum `connAt_birth`, so
correctness reduces to the achievement lemma we already have. **Why now?** With
`connAt_birth` and `connAt_iff_birth_le` in hand, the union–find correctness
proof is an induction matching the sorted-edge sweep to monotone growth of
`connAt`, and `@[csimp]` keeps the result sound without any `@[implemented_by]`
escape hatch.
