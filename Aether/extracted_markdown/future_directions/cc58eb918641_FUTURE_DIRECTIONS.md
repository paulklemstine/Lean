# Future Directions — Boltzmann Bridge XI: Convexity & Bicombing of Interleaving Geodesics

## Synthesis

The persistence-stability arc of the catalog has climbed a ladder of structure: a
relational preorder (`BottleneckStability`), a pseudo-emetric
(`InterleavingMetric`), a genuine `EMetricSpace` (`InterleavingClosure`), an exact
isometry onto weight functions under the sup-distance (`InterleavingIsometry`:
`eInterleavingDist_eq_weightSupEDist`), an explicit constant-speed geodesic
(`InterleavingGeodesic`: `lerp`, `eInterleavingDist_lerp`), and a self-coherent
field of geodesics glued affinely (`InterleavingGeodesicGluing`: `lerp_lerp`).

Bridge XI (`InterleavingGeodesicConvexity.lean`) supplies the **curvature** layer.
Where Bridges IX–X studied a single geodesic and its reparametrisations, Bridge XI
compares *different* geodesics run by the same clock and proves the interleaving
metric is **convex** in the strong sense of admitting a convex geodesic bicombing:

> `d(lerp F G t, lerp F' G' t) ≤ ofReal (1−t)·d(F,F') + ofReal t·d(G,G')`.

Two geodesics run by the same clock never separate faster than the convex
combination of the distances between their endpoints — the defining inequality of a
Busemann (non-positively curved) space. Specialising one geodesic to a constant
point (`lerp H H t = H`) recovers ordinary convexity of the distance to a fixed
filtration along a geodesic. The whole result is, once again, the Bridge VIII
sup-isometry transporting a single elementary fact — the triangle inequality for
real absolute values, `|(1−t)a + tb| ≤ (1−t)|a| + t|b|` — through a supremum.

## Results summary

* `lerp_reverse` — the affine reversal symmetry `lerp F G t = lerp G F (1−t)`.
* `lerp_self` — constant geodesics are stationary, `lerp F F t = F`.
* `weightSupEDist_lerp_bicombing` — the convexity bound at the sup-distance level.
* `eInterleavingDist_lerp_bicombing` — the convex geodesic bicombing inequality
  (Busemann convexity of the interleaving metric).
* `eInterleavingDist_lerp_convex` — convexity of the distance to a fixed filtration
  along the geodesic, as the constant-geodesic special case.

All five are proved `sorry`-free over an arbitrary index type `α`, building on
`eInterleavingDist_lerp` (Bridge IX), `lerp_lerp` (Bridge X), and the isometry
`eInterleavingDist_eq_weightSupEDist` (Bridge VIII). Each depends only on the
standard kernel axioms (`propext`, `Classical.choice`, `Quot.sound`).

## Falsifiable research directions

### Direction 1 — Bundle a `ConvexGeodesicBicombing` and certify a Busemann space

Bridge X gave reparametrisation-consistency (`lerp_lerp`) and Bridge XI gives the
convexity bound (`eInterleavingDist_lerp_bicombing`); together these are exactly the
two axioms of a *consistent convex geodesic bicombing* in the sense of Descombes–Lang.
The conjecture: `lerp` assembles into a single bundled structure that is
simultaneously consistent (it restricts to itself, from `lerp_lerp`) and
conical/convex (from the bicombing bound), making `(Filtration α, eInterleavingDist)`
a *Busemann space* and hence contractible with unique geodesics between distinct
distance-zero classes. **The key insight is** that bicombing consistency is an
*affine* identity at the weight-function level while convexity is a *metric*
inequality read off through the sup-isometry, so the two axioms live in genuinely
different layers and can be discharged independently before being glued. **Why now?**
Both axioms are already proved in isolation (`lerp_lerp`,
`eInterleavingDist_lerp_bicombing`); only the packaging into a bicombing vocabulary
remains, and it is falsifiable — if the conical inequality failed to be *consistent*
with the reparametrisation, the bundle would not typecheck.

### Direction 2 — Strict-convexity defect = multiplicity of supremising simplices

The bicombing bound is an inequality, not the equality of the constant-speed law
`eInterleavingDist_lerp`. Conjecture: equality
`d(lerp F G t, lerp F' G' t) = ofReal (1−t)·d(F,F') + ofReal t·d(G,G')` holds **iff**
there is a single simplex `σ` that simultaneously realises both endpoint suprema
`d(F,F')` and `d(G,G')` with matching signs of the weight gaps; otherwise the bound
is strict. **The key insight is** that an ℓ^∞-type (sup-normed) geometry is
flat-convex but never strictly convex, and the precise location of the convexity
*defect* is the combinatorial event "the argmax simplex of one geodesic differs from
the other's." **Why now?** Bridge XI already isolates the per-simplex triangle
inequality as the only nontrivial step, so the equality case is a finite, decidable
side-condition on a pair of `Finset α` argmaxes — directly testable on concrete
finite point clouds via `#eval`, and falsifiable by exhibiting one cloud pair where
the two argmaxes coincide yet equality still fails.

### Direction 3 — 1-Lipschitz nonexpansiveness of the bicombing endpoints

Conjecture: the map `(F, G) ↦ lerp F G t` is jointly `1`-Lipschitz, i.e. the
bicombing endpoints depend nonexpansively on the data:
`d(lerp F G t, lerp F' G' t) ≤ max (d(F,F')) (d(G,G'))` for every `t ∈ [0,1]`, a
sharpening of the convex bound (since a convex combination is `≤` the max). **The key
insight is** that in a sup-normed space the convex-combination bound and the max
bound *coincide at the supremising simplex*, so nonexpansiveness should be readable
from the same per-simplex estimate by replacing `add_le_add`/`gcongr` with `sup_le`.
**Why now?** The proof skeleton of `weightSupEDist_lerp_bicombing` already produces
the two endpoint suprema separately; swapping the final `+` for `⊔` is a structural
change, and the claim is falsifiable — if true it upgrades `lerp` to a nonexpansive
retraction, yielding contractibility of the metric quotient for free.

### Direction 4 — A reverse (lower) bicombing bound and a two-sided sandwich

The upper bicombing bound has a conjectural mirror: for same-clock geodesics there
should be a lower bound pinning the bicombing distance into a computable band.
Concretely we conjecture `ofReal (1−t)·d(F,F') ⊖ ofReal t·d(G,G') ≤
d(lerp F G t, lerp F' G' t)` (truncated subtraction `⊖` in `ℝ≥0∞`), the reverse
triangle inequality lifted through the sup. **The key insight is** that the supremum
of `|(1−t)a + tb|` is bounded *below* by the reverse triangle inequality
`|(1−t)|a| − t|b||` at the dominant simplex, so the same isometry that gives the
upper bound gives a matching lower bound on a possibly different simplex. **Why now?**
Mathlib's `ENNReal` truncated subtraction and `tsub` lemmas make the lower bound
formally expressible without leaving the extended reals, and the two-sided form is
immediately falsifiable on concrete clouds where all four distances are explicit
rationals.

### Direction 5 — Convexity descends to the quotient and to the Vietoris–Rips locus

`InterleavingQuotient` already constructs the `EMetricSpace` quotient that separates
distance-zero filtrations. Conjecture: `lerp` and the bicombing bound descend to this
quotient (well-definedness of convex interpolation modulo the distance-zero kernel),
making the *quotient* a genuine Busemann space; and, more ambitiously, that the
restriction of `lerp` to the Vietoris–Rips locus stays inside the locus, so
VR-persistence is itself a convex sub-geometry. **The key insight is** that convexity
is a `⨆`-level inequality insensitive to the distance-zero kernel, so it should pass
to the quotient verbatim, whereas the VR-locus question is genuinely harder because a
convex combination of two *diameter* weights need not be a diameter weight of any
single matrix. **Why now?** The quotient machinery is in hand
(`InterleavingQuotient`) and the descent is a routine `Quotient.lift` once
well-definedness is checked; the VR question is sharply falsifiable — a single pair of
finite clouds whose midpoint weight is provably not realised by any distance matrix
would refute the locus-convexity half while leaving the quotient half intact.
