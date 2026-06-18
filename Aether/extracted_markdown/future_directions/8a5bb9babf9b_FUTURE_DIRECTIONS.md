# Future Directions — Boltzmann Bridge XI: Self-Similar Dilations of the Persistence Geodesic Space

## Synthesis

The Boltzmann Bridge arc reduced the metric theory of persistence stability to a
single, sharp object: the interleaving distance on filtrations is *exactly* the
extended sup-distance of their weight functions (Bridge VIII,
`eInterleavingDist_eq_weightSupEDist`), a flat, positively-homogeneous geometry that
is geodesic (Bridge IX, `eInterleavingDist_lerp`), reparametrisation-closed and
Busemann-convex (Bridge X, `lerp_lerp`, `eInterleavingDist_convex`).

Bridge XI (`SelfSimilarDilation.lean`) adds the missing *scaling symmetry*. The
dilation `scale F c := c · F.weight` is a valid filtration for `c ≥ 0`, the ratios
compose as the multiplicative monoid `(ℝ≥0, ·)` (`scale_scale`, `scale_one`), and the
action is a genuine **homothety**:
`eInterleavingDist (scale F c) (scale G c) = ENNReal.ofReal c · eInterleavingDist F G`
(`eInterleavingDist_scale`). Dilations intertwine with the Bridge X geodesic
(`scale_lerp`), and the zero filtration `zeroFil` is their unique attracting fixed
point, with each sub-unit ratio a contraction toward it
(`eInterleavingDist_scale_zeroFil`, `eInterleavingDist_scale_contraction`). The
persistence geometry is thus a self-similar attractor of its own dilation semigroup —
the same `ENNReal.mul_iSup` mechanism that made Bridge IX's geodesic speed constant
now makes the metric scale-invariant.

## Results Summary

* `scale`, `scale_one`, `scale_scale` — the dilation monoid `(ℝ≥0, ·)` acts on
  `Filtration α`.
* `eInterleavingDist_scale` — the self-similarity / homothety identity (equality, not
  inequality).
* `scale_lerp` — dilations are geodesic-preserving, hence functorial on the Bridge X
  path space.
* `zeroFil`, `scale_zeroFil`, `eInterleavingDist_scale_zeroFil` — the zero filtration
  is the homothety centre / dilation fixed point.
* `eInterleavingDist_scale_contraction` — sub-unit dilations contract the metric.

## Research Directions

### 1. A Banach / Hutchinson fixed-point theorem on bounded-weight filtrations

The contraction `eInterleavingDist_scale_contraction` is the metric skeleton of a
genuine attractor statement, but the present space is incomplete: `zeroFil` only
attracts those `F` with `eInterleavingDist F zeroFil < ⊤`, i.e. uniformly
bounded-weight filtrations. Restrict to the sub-type `{F // eInterleavingDist F
zeroFil < ⊤}`, prove it inherits a *complete* `EMetricSpace` from Bridge VII/VIII,
and show that for a fixed `c < 1` the map `scale · c` is a strict contraction with
unique fixed point `zeroFil`, recovering the Banach fixed-point theorem; then extend
to a Hutchinson operator `F ↦ ⨆ᵢ scale (Tᵢ F) cᵢ` and prove existence/uniqueness of
its self-similar attractor. **The key insight is** that bounded-weight filtrations are
precisely the finite-radius ball around `zeroFil`, on which the sup-metric is complete
and the homothety identity upgrades "≤ d" to "= c·d", making the contraction constant
explicit and uniform. **Why now?** Bridge XI has just supplied the exact homothety
constant `ofReal c`; without it the contraction ratio was only an upper bound, and a
Banach argument needs the sharp constant to certify `c < 1` rigorously.

### 2. The dilation–geodesic group and a one-parameter flow

`scale_lerp` shows dilations commute with `lerp`, and `scale_scale` shows ratios
multiply. Reparametrise by `c = exp(−s)` to obtain a one-parameter semigroup `Φ_s :=
scale · exp(−s)` (`s ≥ 0`) and prove it is a *contracting metric flow*:
`eInterleavingDist (Φ_s F) (Φ_s G) = exp(−s) · eInterleavingDist F G`, with generator
"multiply all weights by −1" and the whole space collapsing to `zeroFil` as `s → ∞`.
**The key insight is** that the homothety identity makes `eInterleavingDist` an
*eigen-distance* of the flow with eigenvalue `exp(−s)`, so the flow is conjugate to
linear scalar contraction on `ℝ≥0∞` coordinatewise. **Why now?** Bridges IX–XI have
assembled both the geodesic parameter (`lerp`) and the scaling parameter (`scale`);
combining them into a single `(parameter, ratio)` action is the immediate next
structural object, and `scale_lerp` already proves the two parameters commute.

### 3. Self-similarity *inside* the Vietoris–Rips locus

`scale` acts on abstract weight functions, but is the dilation of a *diameter*
filtration again a diameter filtration? For a finite metric space `(X, d)`, rescaling
the metric `d ↦ c · d` rescales `diamWeight` by `c`, so `scale (diamFiltration_d) c =
diamFiltration_{c·d}` should hold, identifying the abstract homothety with the
geometric "zoom" of a point cloud. **The key insight is** that `diamWeight` is itself
positively homogeneous in the metric, so the abstract dilation and the geometric
rescaling of the data are the *same* operation viewed on either side of Bridge II's
`vr_mem_iff_diam_le`. **Why now?** Bridge XI proved homogeneity at the abstract weight
level; pushing it through the VR bridge `vr_mem_iff_diam_le` (already in
`HigherPersistence`) connects self-similarity of the metric to the empirically
meaningful operation of zooming a data set, the form practitioners actually use.

### 4. Strict convexity defect and the failure of CAT(0)

Bridge X recorded that the Busemann convexity inequality `eInterleavingDist_convex` is
not sharp, the shadow of geodesic non-uniqueness. Combine this with Bridge XI: under a
sub-unit dilation the *defect* `D(H,F,G,t) := ofReal(1−t)·d(H,F) + ofReal t·d(H,G) −
d(H, lerp F G t)` scales by exactly `c` (`eInterleavingDist_scale` applied to all
three terms), so the convexity defect is itself self-similar. Prove `D` is identically
zero iff the maximising simplex is shared by all three legs, giving an explicit
necessary-and-sufficient flatness criterion and a clean proof that the space is
geodesic but not CAT(0). **The key insight is** that self-similarity turns a single
counterexample to strict convexity into a whole scaling family, so the defect is
either identically zero or unbounded along the dilation orbit — there is no
intermediate "almost CAT(0)" regime. **Why now?** Bridge X left the defect
uncomputed and Bridge XI now makes it a homogeneous function of degree one, so its
zero-set is a cone and can be characterised combinatorially rather than analytically.

### 5. The dilation-invariant persistence spectrum

Because `scale · c` multiplies every weight gap by `c`, any functional `μ` on
filtrations satisfying `μ(scale F c) = c^k · μ(F)` is a degree-`k` self-similar
invariant. Construct the leading one — `μ(F) := eInterleavingDist F zeroFil = ⨆ σ,
ofReal |F.weight σ|` (degree 1) — prove it is a seminorm, and search for independent
higher-degree invariants (e.g. moments `⨆ σ, ofReal |F.weight σ|^k` after a suitable
renormalisation), assembling a graded "persistence spectrum" on which the dilation
monoid acts by weights. **The key insight is** that `eInterleavingDist_scale_zeroFil`
already exhibits the degree-1 invariant explicitly, so the homothety identity is a
*grading* on the algebra of persistence functionals. **Why now?** With the homothety
constant pinned, scale-covariance becomes a checkable algebraic constraint, turning
the open-ended search for persistence invariants into the concrete classification of
homogeneous functionals on a flat sup-space.
