# Future Directions — Boltzmann Bridge X: The Persistence Geodesic is a Functorial, Self-Similar, Convexly-Stable Path Space

## Synthesis

The Boltzmann Bridge arc reduced the metric theory of persistence stability to a
single closed form and then to a single geodesic. Bridge V proved the contraction
inequality (`eInterleavingDist_le_supDist`); Bridge VII pinned the boundary case
(distance `0` ⇔ equal weights) and the `EMetricSpace` separation; Bridge VIII
(`InterleavingIsometry.lean`) upgraded these to the **isometry formula**
`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`, exhibiting
`Filtration α` as an isometric subspace of the weight functions under the extended
sup-distance; the companion `InterleavingFunctor.lean` showed the contravariant
`pullback` functor is `1`-Lipschitz (an isometry along surjections) and classified
filtrations as monotone, `∅`-grounded weight functions (`weightEquiv`). Bridge IX
(`InterleavingGeodesic.lean`) opened the path-space chapter with the affine weight
path `lerp F G t` and the constant-speed geodesic identity
`eInterleavingDist (lerp F G s) (lerp F G t) = ofReal |s − t| · eInterleavingDist F G`.

This cycle's contribution, `InterleavingGeodesicTransfer.lean` (Bridge X, sorry-free),
closes the *structural* layer of the path space by proving the geodesic is

- **natural** under the persistence functor — `pullback f (lerp F G t) =
  lerp (pullback f F) (pullback f G) t` exactly (`pullback_lerp`), so persistence is a
  functor into geodesic spaces and short maps, not merely metric spaces;
- **self-similar** — `lerp (lerp F G a) (lerp F G b) t = lerp F G ((1−t)·a + t·b)`
  (`lerp_lerp`), the algebraic witness that the curve is a genuine straight segment,
  every sub-segment of which is again the geodesic;
- **convexly (jointly) stable** — `eInterleavingDist (lerp F₁ G₁ t) (lerp F₂ G₂ t) ≤
  ofReal (1−t)·d(F₁,F₂) + ofReal t·d(G₁,G₂)` (`eInterleavingDist_lerp_endpoints_le`),
  whence the uniform-in-`t` capstone `eInterleavingDist_lerp_endpoints_le_of_le`:
  `ε`-close endpoints give `ε`-close geodesics for every parameter.

The persistence space is therefore not just an isometric copy of an `L∞` space and not
just geodesic — it is a space whose geodesics are themselves transported by the functor,
closed under reparametrisation, and Lipschitz-stable in their endpoints. The unifying
principle of the entire cycle is that **every structural property of the geodesic is a
linearity phenomenon read through Bridge VIII's isometry**: naturality and
self-similarity are `ring` identities on weights, convex stability is the coordinatewise
triangle inequality pushed through `ENNReal.ofReal` and `⨆`.

## Results Summary

- `InterleavingGeodesicTransfer.lean` (Bridge X, new this cycle, sorry-free, axioms
  `propext`/`Classical.choice`/`Quot.sound` only):
  - `pullback_lerp` — pullback preserves the affine geodesic on the nose (Direction 4
    of the Bridge IX list).
  - `lerp_lerp` — the geodesic is self-similar under affine reparametrisation.
  - `eInterleavingDist_lerp_endpoints_le` — joint convex Lipschitz bound on interpolant
    distance (Direction 5 core).
  - `eInterleavingDist_lerp_endpoints_le_of_le` — uniform `ε`-stability of geodesics in
    the parameter `t`.
- Build infrastructure: the project `lakefile.toml` now declares `srcDir = "Catalog"`
  and an `Applications` library so the BoltzmannBridge modules elaborate under `lake
  build`.

## Research Directions

### 1. The persistence geodesic is the *unique* geodesic exactly when every simplex weight gap is attained at the supremum, and otherwise sits in a positive-dimensional convex family.

Bridge IX proved `lerp` is *a* constant-speed geodesic and Bridge X proved it is
canonical (natural, self-similar). The falsifiable conjecture: in `(Filtration α,
eInterleavingDist)` the affine geodesic between `F` and `G` is the *unique* geodesic if
and only if the sup `⨆ σ, |F.weight σ − G.weight σ|` is attained at every simplex
simultaneously (i.e. all nonzero gaps are equal); when the maximising set is a proper
subset, the geodesics form a convex polytope of positive dimension whose vertices move
the non-maximising simplices along any 1-Lipschitz-in-`t` schedule. **The key insight
is** that the interleaving distance is a `⨆` over independent coordinates, so the
slack in any non-maximising simplex is free to wander without changing the distance —
uniqueness is precisely the absence of slack. **Why now?** Bridge VIII's isometry
formula already gives the distance coordinatewise and Bridge X's `lerp_lerp` already
parametrises straight segments, so a non-uniqueness witness can be built explicitly on
a two-simplex filtration and checked with `#eval`-style finite reasoning before
formalising.

### 2. The midpoint map `(F, G) ↦ lerp F G (1/2)` makes `Filtration α` a convex (Busemann nonpositively curved) space, with the geodesic-bisection inequality.

Bridge X gives joint convex stability of *same-parameter* interpolants; the next layer
is the metric convexity inequality `d(lerp F G ½, lerp F H ½) ≤ ½·d(G, H)` and its
symmetric companion, the defining inequality of a Busemann-convex (globally NPC in the
Busemann sense) metric space. Conjecture: `(Filtration α, eInterleavingDist)` is
Busemann convex, so the distance between any two geodesics with a common endpoint is a
convex function of the parameter. **The key insight is** that the midpoint of weights
is the coordinatewise average, and the sup-distance of two coordinatewise averages is
bounded by the average of the sup-distances — convexity of `⨆` of convex functions.
**Why now?** `eInterleavingDist_lerp_endpoints_le` is the `F₁ = F₂` special case of
exactly this inequality, so the general Busemann statement is a one-parameter
strengthening of an already-proved lemma, reachable with the same `gcongr`/`ofReal`
machinery.

### 3. `Filtration α` is hyperconvex (injective in the category of metric spaces and short maps), giving a persistence Kirszbraun/Tietze extension theorem.

`L∞` spaces are the prototypical hyperconvex (injective) metric spaces. Conjecture:
`(Filtration α, eInterleavingDist)` is hyperconvex — every family of pairwise-compatible
closed balls has a common point — and consequently every filtration-valued `1`-Lipschitz
map defined on a subspace extends to the whole space with the same Lipschitz constant.
**The key insight is** that Bridge VIII's isometry turns balls in the interleaving metric
into products of real intervals indexed by `Finset α`, and products of intervals have the
binary-intersection (Helly) property characterising hyperconvexity; the order constraints
`weight ∅ ≤ 0` and `Monotone weight` from `weightEquiv` carve out a sublattice that is
still closed under the coordinatewise median, which is exactly the retraction witnessing
injectivity. **Why now?** `weightEquiv` plus the isometry formula reduce the abstract
hyperconvexity question to an elementary statement about families of real intervals over
`Finset α`, which Mathlib's order/interval API can attack directly, and Bridge X's
`pullback_lerp` already supplies the short maps whose extension is sought.

### 4. The geodesic functor is *monoidal*: `lerp` commutes with the product/join of filtrations, so persistence preserves geodesics of product data.

Persistence of a product (or disjoint union) of point clouds should relate to the
filtrations of the factors via a `max`/sum on weights. Conjecture: there is a product
operation `F ⊗ G` on filtrations (weight `σ ↦ max (F.weight (σ ∩ A)) (G.weight (σ ∩ B))`
for a fixed vertex partition) for which `lerp (F₁ ⊗ G₁) (F₂ ⊗ G₂) t = lerp F₁ F₂ t ⊗
lerp G₁ G₂ t`, exhibiting `lerp` as a monoidal-functorial construction and yielding a
Pythagorean-type distance law `d(F₁⊗G₁, F₂⊗G₂) = max (d F₁ F₂) (d G₁ G₂)`. **The key
insight is** that the sup-distance of a coordinatewise `max` of weights is the `max` of
the two sup-distances (the supremum distributes over the product of coordinate blocks),
so both the geodesic and the metric factor through the product. **Why now?** Bridge VIII
gives the sup-distance in closed form and Bridge X gives the geodesic in closed form, so
the monoidal identity reduces to `lerp_weight` + `ring` on each block and a
`max`-distributes-over-`⨆` lemma, all elementary.

### 5. Second-order Vietoris–Rips stability: nearby distance matrices induce uniformly close persistence geodesics, with an explicit `2ε` bound.

Composing Bridge X's `eInterleavingDist_lerp_endpoints_le_of_le` with the Vietoris–Rips
endpoint stability of `InterleavingMetric.lean`, conjecture: if two distance matrices
`d₁, d₂` are `ε`-close in sup-norm and likewise `d₁', d₂'`, then the geodesic interpolants
of their Rips filtrations satisfy `eInterleavingDist (lerp (Rips d₁) (Rips d₁') t)
(lerp (Rips d₂) (Rips d₂') t) ≤ ε` (indeed `2ε` with the naive bound, `ε` with the convex
one), *uniformly in* `t`. **The key insight is** that Bridge X already made the
interpolant distance affine in the endpoint distances, so endpoint stability propagates
to the whole path with no loss of constant — the path-space stability is a pure corollary
of the metric stability. **Why now?** The endpoint stability bound already exists and the
uniform-in-`t` interpolation bound is now proved (`eInterleavingDist_lerp_endpoints_le_of_le`),
so the capstone is their direct composition, connecting the metric, functorial, and
path-space strands of the entire Boltzmann Bridge arc into a single quantitative theorem.
