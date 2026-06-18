# Future Directions: Tropical Separation, Rank, and the Helly Bridge

The file `Catalog/Bridges/TropicalSeparationRank.lean` turns the catalog's tropical
convexity primitives (`IsTropConvex`, `tropConvexHull`, `TropHalfspace` from
`Speculative/AutoResearch/TropicalHelly.lean`) into a *constructive* separation
theorem built on the Develin–Sturmfels tropical projection `tropProj`, and packages
its witnesses as a rank/dependence certificate (`tropical_separation`,
`not_mem_tropSpan_iff_exists_tropSep`, `tropDependence_certificate`).  The projection
is the constructive engine: `x ∈ tropSpan V ↔ tropProj V x = x`, and when membership
fails the maximal-gap coordinate set `I` and the weights `w = -tropProj V x` define a
separating sector halfspace `TropSep w I`.  The directions below extend this engine.

## 1. Closing the `tropical_helly` sorry through projection-based Radon partitions

The catalog's `tropical_helly` (in `TropicalHelly.lean`) is still `sorry`.  The
classical route is via a tropical Radon partition lemma: any `n + 2` points in `ℝⁿ`
split into two groups whose tropical hulls meet.  Conjecture: the tropical projection
`tropProj` *computes* a Radon partition — for `n + 2` generators, the argmax gap set
`I` of the projection of one generator onto the others, together with its complement,
is a Radon partition, and the common point is `tropProj` of that generator.

**The key insight is** that the separating index set `I` produced by
`tropical_separation` is exactly the combinatorial "type" data a Radon partition
needs, so Radon (and hence Helly) should follow from the *already proven* separation
theorem rather than from an independent geometric argument.  **Why now?** The
separation theorem and the membership criterion `mem_tropSpan_iff_tropProj_eq` are now
formally available, so the only missing step is to verify that `I`/`Iᶜ` is a Radon
partition — a finite, checkable statement that directly discharges the existing
`sorry`. Falsifiable: exhibit `n+2` tropical points whose projection-induced `I, Iᶜ`
have disjoint tropical hulls.

## 2. A tropical Carathéodory number equal to the coordinate dimension

Define the tropical rank of a family `V : κ → ι → ℝ` as the least `r` such that every
point of `tropSpan V` lies in the tropical span of some `r` generators.  Conjecture:
this rank is at most `Fintype.card ι` (the number of coordinates), independent of the
number of generators, and the projection coefficients `tropProjCoeff` select the
witnessing generators (those attaining the coordinatewise minima).

**The key insight is** that `tropProj V x i = max_k (tropProjCoeff V x k + V k i)` is a
max over generators that, coordinate by coordinate, is attained by at most `card ι`
distinct generators, so the *attaining set* across all coordinates is a Carathéodory
witness of size `≤ card ι`.  **Why now?** `tropProjCoeff`/`tropProj` are defined and
their optimality is proved (`coeff_le_tropProjCoeff`), so the attaining-generator set
is a concrete finite object ready to be extracted and bounded. Falsifiable: a family
needing strictly more than `card ι` generators to reproduce some span point.

## 3. Quantitative separation margins and certified robustness

`tropical_separation` is currently qualitative (it produces a strict inequality at the
maximal-gap coordinate).  Conjecture: the separation margin equals the maximal gap
`M = ⨆ i (x i - tropProj V x i)`, and this `M` is exactly the `ℓ∞` tropical distance
from `x` to `tropSpan V`; moreover `TropSep w I` is stable under perturbations of `x`
of size `< M`.

**The key insight is** that the projection gap `M`, which the proof already isolates
as the threshold defining `I`, is simultaneously the separation strength *and* the
distance to the span, unifying the convex-geometric and metric pictures.  **Why now?**
The catalog file `Bridges/TropicalSeparationClassifier.lean` already formalizes
margins for max-plus classifiers, so connecting `M` to a certified margin links the new
separation theorem to that existing robustness infrastructure. Falsifiable: a point and
a perturbation smaller than `M` that nonetheless crosses into the span.

## 4. Duality: every sector halfspace containing a span is induced by a projection

`tropical_separation` *produces* a separator of the special form `w = -tropProj`,
`I = argmax gap`.  Conjecture (converse/duality): every tropical sector halfspace
`TropSep w I` that contains `tropSpan V` but excludes some `x` can be normalized to the
canonical projection separator without enlarging the excluded set — i.e. the projection
separators are a complete, minimal certificate family.

**The key insight is** that `not_mem_tropSpan_iff_exists_tropSep` already shows
*existence* is equivalent to non-membership, so the remaining content is a *canonical
form* theorem: arbitrary separators factor through the projection, making `tropProj`
the universal separator generator.  **Why now?** With the iff in hand, the duality is a
self-contained normalization statement about `TropSep`, not a new geometric existence
result. Falsifiable: a separating `TropSep w I` excluding strictly more points than any
projection separator.

## 5. Tropical bases and uniqueness of minimal generating sets

Call `V` tropically independent if no generator lies in the tropical span of the
others.  Conjecture: independent generating families of a fixed tropical polytope have
the same cardinality (a tropical "dimension"), and `tropDependence_certificate`
detects redundancy — a generator is removable iff no sector halfspace separates it from
the rest.

**The key insight is** that `tropDependence_certificate` converts "no separator" into
an explicit max-plus combination, so redundancy testing reduces to checking the
membership criterion `mem_tropSpan_iff_tropProj_eq` on each generator against the
others — a finite, decidable loop.  **Why now?** The dependence certificate and the
membership criterion are both proven, so a basis-extraction algorithm and its
well-definedness proof can be built directly on top of them without new analytic input.
Falsifiable: two independent generating sets of one tropical polytope with different
sizes.
