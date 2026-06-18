# Future Directions — Boltzmann Bridge X: The Path Space of the Interleaving Geodesic

## Synthesis

`Catalog/Applications/BoltzmannBridge/InterleavingPathSpace.lean` continues the
persistence-stability arc one step past where Bridge IX
(`InterleavingGeodesic.lean`) left it. Bridge IX produced a single object — the
convex-interpolation path `lerp F G t` — and proved it is a *constant-speed
geodesic*, with the linear law

> `eInterleavingDist (lerp F G s) (lerp F G t) = ofReal |s − t| · d(F, G)`
> (`eInterleavingDist_lerp`),

itself riding on Bridge VIII's isometry
`eInterleavingDist_eq_weightSupEDist` (`InterleavingIsometry.lean`) and Bridge
VII's faithfulness `ext_weight` (`InterleavingClosure.lean`). What Bridge X adds
is the *global geometry of the family of all such geodesics* — the data one needs
to speak of a path space rather than a single path:

* **Reversal** (`lerp_reverse`): `lerp G F (1 − t) = lerp F G t`. The geodesic
  segment is an unoriented subset of `Filtration α`, so the path space is
  symmetric — the first ingredient of a fundamental groupoid.
* **Affine flatness / self-similarity** (`lerp_lerp`):
  `lerp (lerp F G a) (lerp F G b) t = lerp F G ((1−t)·a + t·b)`. The image of a
  geodesic is closed under reinterpolation; it is a genuinely 1-dimensional
  affine segment. This is the metric analogue of "the line through two points of
  a line is that line".
* **Geodesic concatenation** (`eInterleavingDist_lerp_concat`): for `s ≤ u ≤ t`
  the intermediate point splits the distance *additively*,
  `d(lerp s, lerp u) + d(lerp u, lerp t) = d(lerp s, lerp t)`. The triangle
  inequality of `interleavingPseudoEMetric` becomes a triangle *equality* on the
  geodesic — exact straightness, not mere subadditivity.
* **Uniform Lipschitz contraction to a base point**
  (`weightSupEDist_lerp_common_base`, `eInterleavingDist_lerp_common_base`):
  sliding two endpoints `F, G` a fraction `t` toward a common base `B` scales
  their distance *exactly* by `t`:
  `d(lerp B F t, lerp B G t) = ofReal t · d(F, G)`.
* **Contractibility witness** (`eInterleavingDist_lerp_common_base_le`): that
  contraction is nonexpansive, and at `t = 0` it collapses everything onto `B`
  (`lerp B · 0 = B` from `lerp_zero`, `lerp B · 1 = id` from `lerp_one`). The
  interleaving space is therefore contractible via a 1-Lipschitz straight-line
  deformation.

The conceptual payoff is a clean dictionary: holding the base fixed and varying
the parameter gap gives the **geodesic** (Bridge IX); holding the parameter fixed
and varying the endpoints toward a base gives the **contraction** (Bridge X).
Both are a single nonnegative scalar pulled out of a `⨆` by `ENNReal.mul_iSup`,
because the interleaving distance is a supremum of independent coordinate motions
on which a uniform scalar acts diagonally.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `lerp_reverse` | `lerp G F (1−t) = lerp F G t` | proved, no `sorry` |
| `lerp_lerp` | geodesics closed under reinterpolation | proved, no `sorry` |
| `eInterleavingDist_lerp_concat` | additive split for `s ≤ u ≤ t` | proved, no `sorry` |
| `weightSupEDist_lerp_common_base` | sup-distance contraction `= ofReal t · d` | proved, no `sorry` |
| `eInterleavingDist_lerp_common_base` | interleaving-distance contraction `= ofReal t · d` | proved, no `sorry` |
| `eInterleavingDist_lerp_common_base_le` | contraction is nonexpansive | proved, no `sorry` |

All six depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### Direction 1 — Classify the full geodesic bundle (non-uniqueness off the maximiser)

Bridge X shows `lerp` is *a* geodesic, but `eInterleavingDist` is a supremum over
simplices, so any deformation that fixes the *maximising* simplices' weights and
wiggles the slack coordinates inside their own straight segments should remain a
constant-speed geodesic between the same endpoints. **Conjecture:** the set of
constant-speed geodesics from `F` to `G` is in bijection with the choices of,
for each non-maximising simplex `σ`, an arbitrary 1-Lipschitz reparametrised path
from `F.weight σ` to `G.weight σ` staying within distance `d(F,G)` of the linear
one; in particular `lerp` is the unique geodesic iff *every* simplex attains the
supremum `d(F, G)`. This is falsifiable: exhibit two filtrations and a second
geodesic not equal to `lerp` (disproving uniqueness), or prove the uniqueness
characterisation. The key insight is that geodesic uniqueness in a sup-metric is
controlled entirely by the *argmax set* of the coordinate gaps, so the geodesic
bundle is a product of intervals indexed by the non-maximising simplices. Why
now? Bridge VIII already gives the exact coordinatewise description of
`eInterleavingDist` as `weightSupEDist`, so the argmax set is a directly
accessible, already-formalised object — the classification reduces to bookkeeping
over `⨆`, not new metric theory.

### Direction 2 — A `GeodesicSpace`/`Convex`-style bundled instance

The catalog has `interleavingPseudoEMetric` and the `EMetricSpace` upgrade from
`InterleavingClosure`. Bridge X supplies exactly the data of a *geodesic metric
space* but as standalone lemmas. **Conjecture:** one can bundle a Mathlib-style
structure `IsGeodesic`/`GeodesicSpace` (or a `MidpointConvex` predicate) on
`(Filtration α, eInterleavingDist)` and discharge its axioms purely from
`eInterleavingDist_lerp`, `eInterleavingDist_lerp_concat`, and
`eInterleavingDist_midpoint`, with no new analytic input. This is falsifiable by
attempting the instance: it either type-checks against the chosen interface or a
concrete axiom fails (e.g. the `EMetric` vs `Metric` `⊤`-value obstruction forces
the predicate to be stated for the extended metric only). The key insight is that
"geodesic" here is *not* an analytic limit statement but a finite algebraic
identity inherited through the Bridge VIII isometry, so the instance should be
constructive and `Decidable`-friendly. Why now? With all the pointwise scaling
laws proved, the only remaining work is matching them to an existing bundled
interface — the mathematics is done, the abstraction is missing.

### Direction 3 — Stay inside the Vietoris–Rips locus

`HigherPersistence.lean` realises the diameter weight's sublevel sets as the
Vietoris–Rips filtration (`vr_mem_iff_diam_le`). The geodesic `lerp` operates on
*arbitrary* monotone weights and need not preserve the property "is the diameter
weight of some metric". **Conjecture:** the set of diameter-induced filtrations is
**not** `lerp`-convex — there exist two metrics whose diameter filtrations'
midpoint `lerp · · (1/2)` is not the diameter filtration of any metric — but it
*is* geodesically convex after passing to the larger class of "weights satisfying
the triangle-style monotonicity that `vr_mono` uses". This is sharply falsifiable:
find a midpoint that *is* a diameter filtration for all test pairs (supporting
convexity), or exhibit one that provably is not. The key insight is that the
convex structure on *weights* (linear, unconstrained) is strictly looser than the
metric realisability constraint (a closure condition), so the geodesic escapes the
VR locus exactly when realisability is non-convex. Why now? Both endpoints of the
comparison — `lerp` and the VR characterisation `vr_mem_iff_diam_le` — are already
formalised in adjacent files, so the obstruction can be probed by a direct finite
search over small vertex sets using `#eval`.

### Direction 4 — Fundamental groupoid and homotopy of filtration paths

Reversal (`lerp_reverse`) and concatenation (`eInterleavingDist_lerp_concat`)
are precisely the inverse and composition needed for a groupoid of paths.
**Conjecture:** because the space is contractible
(`eInterleavingDist_lerp_common_base_le` with the `t = 0` collapse), the
fundamental groupoid of `(Filtration α, eInterleavingDist)` is trivial — every
loop of filtrations is nullhomotopic through a Lipschitz homotopy built by
double-`lerp` (`lerp_lerp` provides the reparametrisation algebra). This is
falsifiable: either construct the contracting homotopy of an arbitrary loop
explicitly from `lerp` and `lerp_lerp`, or identify a topological obstruction (a
non-Hausdorff/`⊤`-distance pathology that breaks path-connectivity for some `α`).
The key insight is that `lerp_lerp` is exactly the algebraic identity that lets
two homotopies be *spliced and rescaled*, which is the only nontrivial axiom of a
homotopy of paths. Why now? The path-space scaffolding (reversal, concatenation,
self-similarity, contraction) is now complete and `sorry`-free, so the groupoid
can be assembled from these lemmas rather than from analysis.

### Direction 5 — Quantitative speed and a Finsler/length-metric refinement

`eInterleavingDist_lerp` says the geodesic has constant *speed* `d(F, G)` in the
parameter `t`. **Conjecture:** the interleaving distance equals the infimum of
the `lerp`-lengths over all monotone reparametrisations — i.e.
`(Filtration α, eInterleavingDist)` is an *intrinsic/length* space and `lerp`
realises the length — and moreover the "speed" defines a Finsler-type norm on the
tangent directions `G.weight − F.weight` equal to the sup-norm
`⨆ σ, |·.weight σ|`. This is falsifiable by computing a piecewise path strictly
shorter than `lerp` (disproving length-minimality) or by proving the length-space
identity from `eInterleavingDist_lerp_concat` via a telescoping sum. The key
insight is that constant speed plus additive concatenation already force
length-minimality on a single segment, so the only open content is the *infimum
over all paths*, which the sup-norm description from Bridge VIII pins down
coordinatewise. Why now? The exact (not approximate) scaling laws make the length
integral collapse to a finite supremum, turning an analytic length computation
into an algebraic one that the current lemmas nearly finish.
