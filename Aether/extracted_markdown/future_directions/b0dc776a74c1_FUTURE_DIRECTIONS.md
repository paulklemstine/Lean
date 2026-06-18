# Future Directions — Boltzmann Bridge X: Local-to-Global Gluing of Interleaving Geodesics

## Synthesis

Bridge IX (`InterleavingGeodesic.lean`) turned the persistence-stability metric into
a *geodesic* one: the convex-interpolation path `lerp F G t := σ ↦ (1−t)·F.weight σ +
t·G.weight σ` runs from `F` to `G` and the interleaving distance varies *exactly
linearly* along it (`eInterleavingDist_lerp`). Bridge X
(`InterleavingGeodesicGluing.lean`) promotes this single path to a *self-coherent
field of geodesics*. The keystone is the affine gluing law

> `lerp (lerp F G s) (lerp F G t) r = lerp F G ((1−r)·s + r·t)`  (`lerp_lerp`),

which says the geodesic between two points *on* a geodesic is the **same** geodesic,
merely reparametrised. This is exactly a local-to-global coherence condition: the
global segment restricts consistently to every subinterval — the defining sheaf-like
axiom of a geodesic structure. Every metric corollary then falls out by linearity of
`ENNReal.ofReal` on nonnegative parameter gaps: distance to the far endpoint
(`eInterleavingDist_lerp_right`), exact additive *betweenness* for ordered parameters
(`eInterleavingDist_lerp_betweenness`), the universal additive split at every interior
point (`eInterleavingDist_lerp_bisect`, generalising the `t = ½` midpoint bisection
`eInterleavingDist_midpoint` of Bridge IX to the full continuum), and multiplicativity
of speed under nesting (`eInterleavingDist_lerp_lerp`). The proofs are purely affine:
`lerp_lerp` is a `ring` identity in the two interpolation parameters, and the metric is
only consulted afterwards through the Bridge VIII isometry
`eInterleavingDist_eq_weightSupEDist`.

## Results Summary

- `lerp_lerp` — affine self-similarity / gluing of the geodesic (the keystone).
- `eInterleavingDist_lerp_right` — `d(lerp F G t, G) = ofReal (1−t) · d(F,G)`.
- `eInterleavingDist_lerp_betweenness` — `d(s,u) + d(u,t) = d(s,t)` for `s ≤ u ≤ t`,
  betweenness as an *equation*, not an inequality.
- `eInterleavingDist_lerp_bisect` — `d(F, lerp t) + d(lerp t, G) = d(F,G)` for *all* `t`.
- `eInterleavingDist_lerp_lerp` — nested speed multiplies:
  `ofReal|a−b| · (ofReal|s−t| · d(F,G))`.

All five are proved `sorry`-free over an arbitrary index type `α`, building on the
Bridge VIII isometry and the Bridge IX law `eInterleavingDist_lerp`. Axiom footprint is
the standard `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### Direction 1 — Chart the convex family of non-unique geodesics.

Because `eInterleavingDist` is a supremum over simplices (Bridge VIII's
`weightSupEDist`), any path whose weights agree with `lerp` on the *maximising*
simplices but wander — while staying within the sup bound — on the rest is *also* a
constant-speed geodesic. Conjecture: the set of constant-speed geodesics from `F` to
`G` is exactly the convex set of `Filtration`-valued paths `P` with `P 0 = F`, `P 1 =
G`, and `|P t .weight σ − (lerp F G t).weight σ| ≤ slack(σ)` for every non-maximising
`σ`, where `slack(σ) = weightSupEDist F G − ofReal|F.weight σ − G.weight σ|`. The key
insight is that *betweenness is controlled coordinatewise but the metric only sees the
supremum*, so the freedom lives precisely in the gap between the per-simplex gaps and
their supremum. Why now? Bridge X's `eInterleavingDist_lerp_betweenness` already
isolates betweenness as the additive structure of `[0,1]` pushed through the isometry;
the same isometry makes the non-uniqueness statement a finite/`iSup` book-keeping
problem rather than a geometric one, so it is formalisable without new analytic
machinery — start with a two-simplex toy `α` where uniqueness provably fails.

### Direction 2 — Geodesic convexity of the distance functional.

For a fixed third filtration `H`, conjecture that `t ↦ eInterleavingDist (lerp F G t)
H` is *convex* on `[0,1]`: `d(lerp t, H) ≤ ofReal(1−t)·d(F,H) + ofReal t·d(G,H)`. The
key insight is that under the Bridge VIII isometry this is the pointwise convexity of
`σ ↦ |(1−t)F(σ)+tG(σ) − H(σ)|` — the absolute value of an affine function of `t`, hence
convex — commuting with `⨆`, since a supremum of convex functions is convex. Why now?
`eInterleavingDist_eq_weightSupEDist` reduces the whole statement to `Convex`-on-`ℝ`
facts already in Mathlib (`convexOn_abs`, `ConvexOn.sup`/`iSup`) plus
`iSup`-monotonicity, and the `lerp_lerp` reparametrisation supplies the affine
substitution needed to phrase midpoint-convexity, which upgrades to full convexity by
continuity. The subtlety to pressure-test: `⨆` of convex functions over an *infinite*
index set in `ℝ≥0∞` needs the convexity packaged in `ℝ≥0∞` (or proved on the real
representatives before `ofReal`).

### Direction 3 — A fundamental groupoid / path category of filtrations.

Compose geodesics end-to-end: define concatenation of `lerp`-paths and ask whether the
resulting *path category* — objects = filtrations, morphisms = constant-speed geodesics
up to affine reparametrisation — is a groupoid, with `lerp F G` and `lerp G F` mutually
inverse. The key insight is that `lerp_lerp` already proves the only nontrivial
coherence (affine reparametrisation invariance), so associativity and inverses reduce to
arithmetic in `[0,1]`. Why now? The gluing law is the categorical glue; with it the path
space studied in `InterleavingPathSpace.lean` acquires honest composition, turning the
metric geodesic structure into a `1`-truncated homotopy type of persistence data. Begin
by proving `lerp G F (1−t) = lerp F G t` (a one-line `ext_weight`/`ring` fact), which is
the inverse law in disguise.

### Direction 4 — Realising geodesics inside the Vietoris–Rips locus.

The weights here are abstract; the geometrically meaningful filtrations are *diameter*
filtrations of finite metric spaces (`vr_mem_iff_diam_le` in `HigherPersistence.lean`).
Conjecture: the linear interpolation `lerp` of two diameter-filtrations is itself a
diameter-filtration of an interpolated (pseudo-)metric *only* when the two metrics are
*comonotone* on simplices; otherwise the geodesic leaves the Rips locus. The key insight
is that diameter is a *max* over edges, and a convex combination of maxima is not the max
of the convex combination, so the Rips locus is geodesically convex exactly at the
comonotone boundary. Why now? Bridge X gives the ambient geodesic explicitly, so the
obstruction to staying inside the Rips locus becomes a concrete, falsifiable inequality
on edge-weights — testable on a 3-point cloud (two edges) by `#eval`/`decide` before any
general proof. Adversarial test: find the smallest non-comonotone pair where `lerp F G
(½)` is provably *not* a diameter filtration.

### Direction 5 — Cohomological obstruction to global geodesic sections.

Treat "is there a constant-speed geodesic through a prescribed finite family of
filtrations in the right order?" as a *local-to-global extension* problem: local geodesic
segments always exist (Bridge X), and the obstruction to gluing them into one globally
monotone path is a class in a (Čech-style) cohomology of the betweenness relation over
the indexing poset. The key insight is that `eInterleavingDist_lerp_betweenness` makes
each local compatibility an *equation* (additivity `d(i,j) + d(j,k) = d(i,k)`), so the
gluing obstruction is literally the failure of this cocycle condition to hold globally.
Why now? With betweenness proved as an equality rather than merely the triangle
inequality, the obstruction theory has an *exact* (not lax) cocycle to measure,
connecting this metric arc to the cohomological thread of `CechNerve.lean` already in the
BoltzmannBridge catalog. Concretely: define the discrepancy `δ(i,j,k) := d(i,k) − (d(i,j)
+ d(j,k))` and prove it vanishes iff the three points are collinear on a common `lerp`,
making `δ` the primary obstruction cochain.
