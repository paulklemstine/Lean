# Future Directions — Boltzmann Bridge IX: the Interleaving Metric is *Geodesic*

## Synthesis

`Applications/BoltzmannBridge/InterleavingGeodesic.lean` closes the
persistence-stability arc's metric story and opens its **homotopical** chapter.
The arc moved from a relational preorder (`Interleaved`, with
`Interleaved_refl/symm/mono/trans`), to a pseudo-emetric (`eInterleavingDist`,
`interleavingPseudoEMetric`), to a genuine `EMetricSpace` with attained infimum
(`eInterleavingDist_eq_zero_iff_eq`), to an exact isometry onto weight functions
under the extended sup-distance (`eInterleavingDist_eq_weightSupEDist`,
`weightSupEDist`).

Bridge IX adds the missing geometric layer: the space is not merely isometric to a
sup-space but is itself **geodesic**. Convex interpolation of weights, `lerp F G t`
with weight `σ ↦ (1−t)·F.weight σ + t·G.weight σ`, is a valid filtration for
`0 ≤ t ≤ 1`, gives a path from `F` (`lerp_zero`) to `G` (`lerp_one`), and the
interleaving distance varies *exactly linearly* along it (`eInterleavingDist_lerp`:
`d(lerp s, lerp t) = ofReal |s − t| · d(F, G)`), with the midpoint bisecting the
distance additively (`eInterleavingDist_midpoint`). This is the first explicit
**path of filtrations** in the catalog — a homotopy between data shapes that
realises the interleaving distance at constant speed — and the natural launch point
for a path-space / fundamental-groupoid treatment of persistence.

## Results summary

* `lerp`, `lerp_weight`, `lerp_zero`, `lerp_one` — the convex-interpolation path of
  filtrations and its endpoints.
* `weight_lerp_sub` — pointwise weight gaps scale linearly:
  `|lerp s − lerp t| = |s − t| · |F − G|`.
* `weightSupEDist_lerp` — the extended sup-distance is linear along the path.
* `eInterleavingDist_lerp` — **the constant-speed geodesic identity**, built on
  Bridge VIII's `eInterleavingDist_eq_weightSupEDist`.
* `eInterleavingDist_lerp_left` — distance from the endpoint `F` is
  `ofReal t · d(F, G)`.
* `eInterleavingDist_midpoint` — the midpoint bisects the distance additively.

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Research directions

### Direction 1 — The path space of filtrations is contractible

Conjecture: for any basepoint `F₀ : Filtration α`, the straight-line map
`H : Filtration α × [0,1] → Filtration α`, `H(G, t) = lerp G F₀ t`, is a continuous
(indeed `1`-Lipschitz-in-`t`) contraction of `(Filtration α, eInterleavingDist)`
onto `F₀`, so the metric space is contractible and its fundamental groupoid is
trivial. Falsifiable: exhibit two paths between fixed endpoints whose concatenation
is not null-homotopic, or show `H` fails continuity at some `(G, t)`.

The key insight is that the geodesic identity `eInterleavingDist_lerp` already
delivers `d(H(G,t), H(G,t')) = ofReal |t−t'| · d(G,F₀)`, while `1`-Lipschitzness of
`lerp` in its moving endpoint (the same `weight_lerp_sub` factorisation, now applied
to the endpoint rather than the parameter) gives `d(H(G,t), H(G',t)) ≤ d(G,G')`; so
joint continuity is a pure `ENNReal`-triangle estimate the existing lemmas almost
deliver.

Why now? Bridge IX has just produced the segment geodesics and the linear distance
law; assembling them into a single straight-line homotopy is the immediate next
algebraic step, and it converts the *metric* result into a genuine *homotopy*
invariant (contractibility), exactly the engine's path-space mandate.

### Direction 2 — Uniqueness fails: characterise *all* geodesics

Conjecture: a path `γ : [0,1] → Filtration α` from `F` to `G` is a constant-speed
geodesic for `eInterleavingDist` **iff** for every simplex `σ` the scalar path
`t ↦ γ(t).weight σ` stays monotonically between `F.weight σ` and `G.weight σ`, and
the *sup* over `σ` of the gap travels at constant speed. In particular `lerp` is one
geodesic among a convex family, so the space is geodesic but **not uniquely
geodesic**. Falsifiable: produce a constant-speed geodesic *not* of this
pointwise-between form, or prove `lerp` is the unique geodesic.

The key insight is that `eInterleavingDist` is a `⨆` of per-simplex absolute-value
metrics, and while the real line `[a,b]` is uniquely geodesic, a *supremum* of such
intervals is highly non-uniquely geodesic — the slack in non-maximising simplices is
free to wander without affecting the sup.

Why now? `weight_lerp_sub` isolates exactly the per-simplex contribution, so
non-uniqueness can be exhibited by perturbing `lerp` on a single non-maximising
simplex and re-running the `⨆`-argument of `eInterleavingDist_lerp` — no new
infrastructure is needed, only a concrete two-simplex witness.

### Direction 3 — Geodesic convexity of the Vietoris–Rips locus

Conjecture: the image of the Vietoris–Rips functor `d ↦ diamFiltrationOf d`
is a *geodesically convex* subset of `(Filtration α, eInterleavingDist)`: the `lerp`
of two diameter-filtrations is again a diameter-filtration of the linearly
interpolated distance matrix `(1−t)d₁ + t d₂`, provided that interpolation remains a
pseudometric. Falsifiable: find `d₁, d₂` whose midpoint diameter-filtration differs
from `diamFiltrationOf ((d₁+d₂)/2)` at some simplex.

The key insight is that the diameter weight is a *pointwise supremum* of edge
distances, and suprema commute with convex combinations only up to inequality — so
the conjecture pins down precisely when persistence interpolation is "geometric"
(stays inside the VR locus) versus merely "combinatorial".

Why now? Bridge VIII flagged "realising the sup for the Vietoris–Rips functor" as
its open frontier; the geodesic `lerp` now provides the canonical interpolation to
test that realisation against, turning a vague frontier into a sharp
commuting-square question about `diamFiltrationOf` and `lerp`.

### Direction 4 — Curvature: a geodesic sup-space, Busemann-convex but not CAT(0)

Conjecture: `(Filtration α, eInterleavingDist)` satisfies the *Busemann*
non-positive-curvature inequality
`d(lerp F G ½, lerp F H ½) ≤ ½ · d(G, H)` (convexity of the metric along
`lerp`-geodesics), inherited from the sup-metric structure; it is, however, **not**
CAT(0) in general (sup-metrics are flat-but-cornered, like `ℓ^∞`). Falsifiable:
violate the Busemann inequality for some `F, G, H`, or verify the CAT(0) four-point
condition and refute the `ℓ^∞`-analogy.

The key insight is that an `ℓ^∞`/sup-metric is Busemann-convex but not CAT(0), and
Bridge VIII proved `eInterleavingDist` *is* such a sup-metric — so curvature bounds
transfer term-by-term through the same `⨆`-and-`mul_iSup` machinery that drove
`weightSupEDist_lerp`.

Why now? The midpoint lemma `eInterleavingDist_midpoint` is the `G = H` instance of
the Busemann inequality; generalising one endpoint is the smallest possible step and
immediately upgrades the *metric* statement to a *curvature* classification — the
deepest invariant of a geodesic space.

### Direction 5 — The geodesic identity characterises the sup-metric (rigidity)

Conjecture: among all translation-invariant metrics on weight functions
`Finset α → ℝ` for which every `lerp`-segment is a constant-speed geodesic with the
*same* per-simplex speeds, the sup-distance is the unique one realised by an
interleaving-type stability relation; i.e. `eInterleavingDist` is *rigid* — the
geodesic law plus `1`-Lipschitz stability forces the formula
`eInterleavingDist_eq_weightSupEDist`. Falsifiable: construct a different metric
(e.g. an `ℓ^p` weight-distance, `p < ∞`) that also makes `lerp` geodesic yet arises
from a stability relation, contradicting uniqueness.

The key insight is that geodesy plus the linear speed law `eInterleavingDist_lerp`
encodes a functional equation on the metric, and on a sup-of-coordinates space only
the `ℓ^∞` norm solves it compatibly with the one-edge stability witnesses of
`stability_supDist`.

Why now? With the isometry (Bridge VIII) and the geodesic law (Bridge IX) both
formalised, the inverse problem — *which* metric is forced by these properties — is
now a precisely stated rigidity theorem rather than an informal expectation, and
proving it would crown the arc by characterising the interleaving distance uniquely.
