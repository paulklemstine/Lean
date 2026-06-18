# Future Directions — Boltzmann Bridge IX: Persistence as a Geodesic Path Space

## Synthesis

The Boltzmann Bridge arc has, over several cycles, reduced the entire metric theory
of persistence stability to a single closed form. Bridge V proved one inequality
(`eInterleavingDist_le_supDist`); Bridge VII proved the boundary case (distance `0`
⇔ equal weights, the `EMetricSpace` separation); Bridge VIII
(`Applications/BoltzmannBridge/InterleavingIsometry.lean`) upgraded these to the
**isometry formula**

> `eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`,

exhibiting `Filtration α` as an isometric subspace of the weight functions under
the extended sup-distance. The companion `InterleavingFunctor.lean` showed the
persistence functor is `1`-Lipschitz (and an isometry along surjective pullbacks)
and classified filtrations as monotone, `∅`-grounded weight functions
(`weightEquiv`).

This cycle's contribution, `InterleavingGeodesic.lean`, closes the arc on the
**homotopy / path-space** side. It introduces the weight-linear path
`weightLerp F G t` (the convex combination of weights, well-defined exactly for
`t ∈ [0,1]`) and proves the *constant-speed geodesic identity*

> `eInterleavingDist (weightLerp F G s) (weightLerp F G t)
>     = ENNReal.ofReal |t − s| · eInterleavingDist F G`,

together with the endpoint scaling laws and the betweenness/additivity
`d(F, ·) + d(·, G) = d(F, G)`. The persistence space is therefore not merely an
isometric copy of an `L∞` space — it is a **geodesically convex** one, and the
comparison of two filtrations is witnessed by an explicit, canonical 1-parameter
deformation: the path object of the persistence space.

## Results Summary

- `InterleavingIsometry.lean` (Bridge VIII, verified complete and sorry-free this
  cycle): the isometry formula and its corollaries.
- `InterleavingGeodesic.lean` (Bridge IX, new this cycle, sorry-free):
  - `weightLerp`, `weightLerp_zero`, `weightLerp_one` — the canonical path and its
    endpoints.
  - `eInterleavingDist_weightLerp` — the constant-speed geodesic identity.
  - `eInterleavingDist_weightLerp_left` / `_right` — linear distance growth from each
    endpoint.
  - `weightLerp_betweenness` — geodesic additivity, exhibiting `Filtration α` as a
    geodesic space.
- Build infrastructure repaired: `lakefile.toml` now declares `srcDir = "Catalog"`
  and an `Applications` library, so the BoltzmannBridge modules elaborate; an absent
  `Shared.CarmichaelHelper` import was pruned from `Shared/CarmichaelProof.lean`.

## Research Directions

### 1. The persistence space is *uniquely* geodesic in the `L∞` metric only up to reparametrisation — but matching-based (bottleneck) interpolation gives a genuinely different geodesic.

We proved that the affine weight path is *a* constant-speed geodesic for the
interleaving (sup) metric. The falsifiable conjecture: for the bottleneck distance
on persistence *diagrams* (the quotient that forgets simplex labels), the affine
weight path is **not** geodesic in general, and the geodesic is instead realised by
a partial-matching interpolation that moves each matched birth–death pair linearly
while sending unmatched points to the diagonal at constant speed. **The key insight
is** that the sup metric is realised coordinatewise (every simplex independently),
whereas bottleneck couples coordinates through an optimal matching, so the two
metrics must disagree on which paths are length-minimising. **Why now?** Bridge VIII
already gives the exact `L∞` distance in closed form, so the discrepancy between the
two geodesics can be exhibited on a concrete 2-point example (cf. the `cloud₁/cloud₂`
witnesses in `BottleneckStability.lean`) and checked numerically before formalising.

### 2. `Filtration α` is an injective object (a hyperconvex / nonexpansive-retract metric space).

`L∞` spaces are the prototypical hyperconvex spaces, and hyperconvexity is exactly
injectivity in the category of metric spaces with `1`-Lipschitz maps. Conjecture:
`(Filtration α, eInterleavingDist)` is hyperconvex — every family of mutually
compatible closed balls has a common point — and hence every filtration-valued
`1`-Lipschitz map defined on a subspace extends to the whole space (a persistence
Tietze/Kirszbraun theorem). **The key insight is** that the isometry formula makes
balls in the interleaving metric into *products of intervals* in weight space, and
products of intervals have the binary-intersection (Helly) property that
characterises hyperconvexity. **Why now?** `weightEquiv` plus the isometry formula
turn the abstract hyperconvexity question into an elementary statement about
families of real intervals indexed by `Finset α`, which Mathlib's order/interval API
can attack directly.

### 3. The fundamental group(oid) of the sublevel-set filtration is a `1`-Lipschitz invariant, with an explicit interleaving-to-homotopy comparison bound.

Bridge VIII compares filtrations *metrically*; the next layer compares the
*homotopy types* of their sublevel complexes. Conjecture: if
`eInterleavingDist F G ≤ δ`, then for every threshold `t` the sublevel inclusions
induce maps on fundamental groupoids that are inverse up to a `2δ`-shift, yielding a
well-defined limiting groupoid invariant that is itself `1`-Lipschitz in the
interleaving distance. **The key insight is** that an interleaving is literally a
homotopy-coherent pair of maps between the sublevel diagrams (`Interleaved` unfolds
to mutual `δ`-shifted inclusions), so the persistence functor factors through the
fundamental-groupoid functor and inherits its homotopy invariance. **Why now?** The
`Interleaved` relation is already formalised as shifted set inclusions
(`BottleneckStability.lean`), so the comparison maps exist on the nose; only the
groupoid bookkeeping is new, and Mathlib's `FundamentalGroupoid` supplies it.

### 4. Geodesic convexity transfers along the `1`-Lipschitz pullback functor, making persistence a functor into the category of geodesic spaces and short maps.

We have geodesy (this cycle) and `1`-Lipschitz functoriality (`InterleavingFunctor`).
Conjecture: the pullback `pullback f` sends the affine geodesic `weightLerp F G` to
the affine geodesic `weightLerp (pullback f F) (pullback f G)` *exactly* (not merely
up to the Lipschitz bound), i.e. `pullback f (weightLerp F G t) =
weightLerp (pullback f F) (pullback f G) t`. **The key insight is** that pullback
acts on weights by precomposition with `σ ↦ σ.image f`, an operation that is linear,
so it commutes with the convex combination defining `weightLerp`. **Why now?** Both
sides are `ofWeight` of explicit linear expressions, so the identity reduces to
`ext_weight` plus `ring`, and it would upgrade the existing Lipschitz statement to a
clean "persistence preserves geodesics" theorem with almost no new machinery.

### 5. A quantitative geodesic stability principle: nearby data clouds have uniformly close persistence geodesics.

Combining Bridge IX with the Vietoris–Rips stability of `InterleavingMetric.lean`
(`vr_eStability`), conjecture a *second-order* stability: if two distance matrices
`d₁, d₂` are `ε`-close in sup-norm, then for every `t` the geodesic interpolants of
their Rips filtrations satisfy `eInterleavingDist (weightLerp (Rips d₁) (Rips d₁') t)
(weightLerp (Rips d₂) (Rips d₂') t) ≤ 2ε`, uniformly in `t`. **The key insight is**
that the geodesic identity makes the interpolant distance *affine* in the endpoint
distances, so endpoint stability propagates linearly to the whole path with no loss.
**Why now?** The endpoint stability bound already exists (`vr_eStability`) and the
geodesic identity is now proved, so the uniform-in-`t` statement is their direct
composition — a high-value, low-risk capstone connecting the metric, functorial, and
path-space strands of the entire Boltzmann Bridge arc.
