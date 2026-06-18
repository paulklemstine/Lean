# Future Directions — Boltzmann Bridge XII: Sheaf-Theoretic Transport and the ℓ∞ Curvature Obstruction

## Synthesis

Bridge XII (`InterleavingSheafTransport.lean`) reads the persistence interleaving
metric through a **local-to-global / sheaf** lens and, on that basis, discharges four
constructive Future Directions left open by Bridge XI.

The organising principle is Bridge VIII's isometry
`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`
(`eInterleavingDist_eq_weightSupEDist`): a filtration is a **section** of the presheaf
`σ ↦ ℝ` of local birth-times, the contravariant `pullback f` (`InterleavingFunctor`)
is the **restriction map** of that presheaf along a change of vertex cover, and the
global metric is the gluing — a supremum — of the per-simplex (stalk-level) gaps.
Four facts now interlock:

* a **sheaf-gluing** law — `eInterleavingDist_pullback_lerp_eq_of_surjective` shows
  that when `f` is surjective (its induced simplex map *covers* the global index set)
  restriction sends the `F`–`G` geodesic to a constant-speed geodesic of *exactly* the
  same speed, `d(pb(lerp s), pb(lerp t)) = ofReal|s−t|·d(F,G)`. This is the sheaf
  condition for the geodesic transport, upgrading Bridge XI's contraction inequality
  to a path-level isometry.
* a **naturality** law — `pullback_straightLineContraction` shows restriction commutes
  with the *entire* two-parameter contracting homotopy of Bridge XI, so `pullback f`
  is a morphism of contractible path spaces, not merely of geodesic spaces.
* a **curvature-obstruction** law — `eInterleavingDist_convex_strict` exhibits an
  explicit triple `wZero, wFull, wCorner` over `Fin 2` with a strictly positive
  Busemann defect at `t = 1/2`: the space is geodesic and Busemann-convex (Bridge X)
  yet **not uniquely geodesic**, hence **not CAT(0)**.
* an **obstruction-class** law — `eInterleavingDist_pullback_lerp_lt_of_not_surjective`
  shows restriction along a proper subcover (the non-surjective `Fin 1 → Fin 2`)
  *strictly* contracts the geodesic, collapsing its endpoints to a point of distance
  `0` against a positive upstream length.

The decisive insight of this cycle is that **sharpness of transport is the sheaf
condition, and curvature is the geometry of the gluing**: a cover loses no information
(sharp restriction) precisely when it is surjective, while the flatness of the ℓ∞
unit cube — its argmax coordinate can *migrate* between simplices — is exactly what
obstructs gluing a nonpositively-curved (CAT(0)) global structure from the flat local
pieces.

## Results summary

| Theorem | Statement | Role |
|---|---|---|
| `eInterleavingDist_pullback_lerp_eq_of_surjective` | `d(pb(lerp s), pb(lerp t)) = ofReal\|s−t\|·d(F,G)` for surjective `f` | sheaf gluing (sharp transport) |
| `pullback_straightLineContraction` | `pb f (H s r) = H' s r` for the contraction homotopy | naturality (functor of contractible spaces) |
| `eInterleavingDist_convex_strict` | `d(wCorner, mid) < ½·d(wCorner,wZero) + ½·d(wCorner,wFull)` | ℓ∞ curvature obstruction (not CAT(0)) |
| `eInterleavingDist_pullback_lerp_lt_of_not_surjective` | `0 = d(pb(lerp 0), pb(lerp 1)) < ofReal\|0−1\|·d(wZero,wCorner)` | obstruction class of a subcover |

All four compile with `sorry`-count 0 and depend only on `propext`,
`Classical.choice`, `Quot.sound`.

---

## Direction 1 — The curvature defect as a quantitative obstruction class over `Fin n`

**Conjecture.** Define the Busemann defect
`δ(H,F,G,t) := ofReal(1−t)·d(H,F) + ofReal t·d(H,G) − d(H, lerp F G t)`. Bridge XII
witnessed `δ = 1 > 0` for one triple over `Fin 2`. Conjecture that the *maximal*
defect over all ℓ∞-extreme triples on `Fin n` (filtrations valued in `{0, c}` per
singleton) grows like `c·⌊n/2⌋` at `t = 1/2`: the obstruction to CAT(0) is not a
single bit but a graded quantity counting how many independent coordinates can host a
migrating argmax simultaneously. In particular `δ_max(Fin 1) = 0` (uniquely geodesic),
`δ_max(Fin 2) = c`, and the defect is strictly monotone in the number of incomparable
singletons.

**The key insight is** that the ℓ∞ cube on `n` independent coordinates has `2^n`
vertices, and a "corner" filtration can be the *opposite* vertex from the midpoint in
each of `⌊n/2⌋` coordinate pairs at once; each independent pair contributes one unit of
slack, so the defect is the additive aggregate of per-coordinate flatness — a
cohomology-flavoured count of independent obstruction cells, not a yes/no flag.

**Why now?** `eInterleavingDist_convex_strict` already packages the single-coordinate
defect as a clean `le_iSup`/`iSup_le` sandwich over `ofWeight` tables, and
`eInterleavingDist_ofWeight` reduces every distance to a finite supremum over
`Finset (Fin n)`. Scaling the one-coordinate witness to `n` coordinates is a direct
product construction whose defect is checkable termwise, so the graded growth law is a
finite `#eval`-verifiable computation rather than an analytic curvature estimate.

---

## Direction 2 — Sharp transport is an *iff*: the strict defect for every non-surjective map

**Conjecture.** `eInterleavingDist_pullback_lerp_eq_of_surjective` proves surjective ⇒
path-isometry, and `eInterleavingDist_pullback_lerp_lt_of_not_surjective` proves one
non-surjective map is strict. Conjecture the full trichotomy: for *every* non-surjective
`f : α → β` there exist filtrations `F, G` (differing on a simplex outside the image of
`·.image f`) and `s ≠ t` with `d(pb(lerp s), pb(lerp t)) < ofReal|s−t|·d(F,G)`. Hence
`pullback f` is a path-isometry for all geodesics iff it is an endpoint isometry iff
`f` is surjective — a clean equivalence completing Bridge IX's corrected Direction 3 at
the path level.

**The key insight is** that `eInterleavingDist_pullback_lerp` factors the transported
speed as the scalar `ofReal|s−t|` times the *endpoint* distance `d(pb F, pb G)`, so the
path-level equality locus is the scalar multiple of the endpoint-level equality locus;
Bridge IX's `eInterleavingDist_pullback_eq_of_surjective` already pins the latter to
surjectivity, and the missing direction only needs one separating weight gap on an
omitted simplex.

**Why now?** Both endpoints exist as named lemmas (`eInterleavingDist_pullback_lerp`
for the factorisation, the surjective-isometry for one side); multiplying the endpoint
strictness through by `ofReal|s−t| > 0` is a one-step `ENNReal.mul_lt_mul` argument, so
the iff is assembled from parts already in the catalog rather than proved afresh.

---

## Direction 3 — A Mayer–Vietoris / gluing law for jointly surjective covers

**Conjecture.** Let `{f_i : α_i → β}` be a *jointly surjective* family of vertex maps
(every simplex of `β` is `σ.image f_i` for some `i, σ`). Conjecture the gluing identity
`eInterleavingDist F G = ⨆ i, eInterleavingDist (pullback (f_i) F) (pullback (f_i) G)`:
the global interleaving distance is recovered as the supremum of its restrictions to
the cover. When the family is *not* jointly surjective the supremum strictly undercuts
the global distance, and the defect
`eInterleavingDist F G − ⨆ i, eInterleavingDist (pb f_i F) (pb f_i G)` is the
**obstruction class** measuring the simplices the cover misses — a Čech-`H^0`-style
failure of the section to be determined locally.

**The key insight is** that each `pullback f_i` restricts the global supremum
`⨆ σ, ofReal|F.weight σ − G.weight σ|` to the sub-supremum over the image simplices of
`f_i` (exactly the content of `eInterleavingDist_pullback_le`), and a supremum over a
family of subsets equals the global supremum precisely when the subsets *cover* the
index set — the sheaf gluing axiom written in ℓ∞.

**Why now?** `eInterleavingDist_pullback_le` already exhibits each restriction as a
sub-supremum and `eInterleavingDist_pullback_eq_of_surjective` handles the single-map
cover; the jointly-surjective case is the `iSup`-of-`iSup` reindexing
`⨆ i, ⨆ σ ∈ image_i = ⨆ τ` over the cover, a direct `le_antisymm` with `le_iSup` that
needs no new metric input — the Bridge VIII isometry does all the work.

---

## Direction 4 — Geodesics leave the Vietoris–Rips locus (geodesic non-convexity)

**Conjecture.** Let `diamFiltration` (from `HigherPersistence.lean`) be the
Vietoris–Rips diameter filtration of a finite metric space. Conjecture there is a
3-point metric configuration and a `t ∈ (0,1)` for which
`(lerp (diamFiltration X) (diamFiltration Y) t).weight` violates the diameter max-rule
`weight(triangle) = max over its edges`, so no metric `Z` has `diamFiltration Z` equal
to the interpolant. The VR locus is therefore geodesically **non-convex** inside
`(Filtration α, eInterleavingDist)`: the constant-speed geodesic of Bridge IX leaves
the space of *metric* filtrations even though it stays a valid monotone filtration.

**The key insight is** that diameter weights obey a cross-simplex compatibility
constraint (a triangle's weight is the max of its three edge weights), whereas `lerp`
blends each simplex's weight *independently and affinely*; an affine combination of two
maxima is generally not the max of the blended edges, so the interpolant is monotone
(stays in `Filtration`) but is no longer realisable by any metric.

**Why now?** Bridge XII has confirmed `lerp` is transported and contracted
functorially, and `diamWeight` is already a concrete `sup'` over pairwise distances
(`HigherPersistence.lean`); the violation reduces to a single arithmetic inequality on
one triangle of an explicit 3-point space — a finite `#eval`-falsifiable check rather
than an analytic argument, and the natural geometric counterpart to the curvature
obstruction of Direction 1.
