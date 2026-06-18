# Future Directions — Boltzmann Bridge X: The Path Space of Filtrations

## Synthesis

Bridge IX (`InterleavingGeodesic.lean`) gave the persistence-stability arc its first
explicit *path of filtrations*: the convex-interpolation geodesic `lerp` and the
constant-speed identity `eInterleavingDist (lerp F G s) (lerp F G t) = ofReal |s−t| ·
eInterleavingDist F G`. Bridge X (`InterleavingPathSpace.lean`) turns that single
geodesic into a **path space** and exposes its homotopical and curvature structure.

Three structurally different facts now coexist over the same object `lerp`:

* an **algebraic** law — `lerp_lerp` shows the geodesics are closed under
  reparametrisation, a `lerp` of two `lerp`s being the `lerp` at the affine parameter
  `(1−t)·a + t·b`. This is the combinatorial skeleton of a fundamental groupoid: paths
  compose to paths, and reparametrisations stay inside the family.
* a **metric** law — `eInterleavingDist_lerp_betweenness` upgrades Bridge IX's midpoint
  bisection to the full geodesic-segment additivity `d(s,u)+d(u,t)=d(s,t)` for any
  `s ≤ u ≤ t`, and `exists_constantSpeed_geodesic` packages everything into the textbook
  statement *the space is geodesic*.
* an **analytic** law — `eInterleavingDist_convex` proves Busemann convexity
  `d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F) + ofReal t·d(H,G)`, inherited from the
  sup-distance through Bridge VIII's isometry `eInterleavingDist_eq_weightSupEDist`.

The decisive insight of this cycle is that **geodesy is the sharp diagonal of
convexity**: the constant-speed equality of Bridge IX is exactly the convexity
inequality of Bridge X restricted to the endpoints' own geodesic, where the
non-maximising slack over the simplex supremum vanishes. Convexity holds for every
third point `H`; equality holds only when the maximising simplex is shared. That single
asymmetry organises everything below.

## Results summary

| Theorem | Statement | Role |
|---|---|---|
| `lerp_self` | `lerp F F t = F` | degenerate geodesic |
| `lerp_lerp` | `lerp (lerp F G a) (lerp F G b) t = lerp F G ((1−t)a+tb)` | reparametrisation closure |
| `eInterleavingDist_lerp_betweenness` | `d(s,u)+d(u,t)=d(s,t)` for `s ≤ u ≤ t` | geodesic-segment law |
| `eInterleavingDist_convex` | `d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F)+ofReal t·d(H,G)` | Busemann convexity |
| `exists_constantSpeed_geodesic` | `∃ γ, γ 0 = F ∧ γ 1 = G ∧ d(γ s, γ t)=ofReal\|s−t\|·d(F,G)` | the space is geodesic |

All five compile with `sorry`-count 0 and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

---

## Direction 1 — The convexity defect and the failure of unique geodesy

**Conjecture.** Define the convexity defect
`δ(H,F,G,t) := ofReal(1−t)·d(H,F) + ofReal t·d(H,G) − d(H, lerp F G t)`. Then `δ ≥ 0`
always (this is `eInterleavingDist_convex`), but `δ` is *not* identically zero: there is
a concrete triple `F, G, H` of three-simplex filtrations and a `t ∈ (0,1)` with
`δ(H,F,G,t) > 0`, and moreover there exist two genuinely distinct constant-speed
geodesics between some `F` and `G` — so `(Filtration α, eInterleavingDist)` is geodesic
but **not uniquely geodesic**, hence not CAT(0), despite satisfying Busemann convexity.

**The key insight is** that the interleaving metric is an ℓ∞-type supremum, and ℓ∞
geometry is flat with square balls: between two points whose displacement is
concentrated on different coordinates, any monotone staircase is a geodesic. Concretely,
choose weights so the maximiser of `|H − lerp t|` migrates from one simplex to another as
`t` crosses ½ — then the straight-line convex bound is strictly slack, and a "bent"
path through a third filtration realises the same endpoint distance.

**Why now?** `eInterleavingDist_convex` has just pinned the inequality and isolated
exactly the slack term; the only remaining work is to *witness* the slack with a finite
example over `α = Fin 3`, which is a finite `#eval`-checkable search rather than an
analytic argument. The negative curvature question is reduced to a counterexample hunt.

---

## Direction 2 — Concatenation and a contractible fundamental groupoid

**Conjecture.** The reparametrisation law `lerp_lerp` extends to a full
*path-concatenation* operation `γ ⋆ γ'` on `lerp`-paths that is associative and
unital up to reparametrisation, and the resulting path space is **contractible**: every
loop based at `F` is `lerp`-homotopic to the constant loop `lerp_self F`. Consequently
the fundamental groupoid of `(Filtration α, eInterleavingDist)` is trivial (equivalent to
a point on each connected component), and `Filtration α` is an Eilenberg–MacLane space of
no positive homotopy.

**The key insight is** that geodesic convexity (`eInterleavingDist_convex`) forces
straight-line contractibility: the homotopy `(s, r) ↦ lerp F (γ r) s` contracts any path
`γ` to the constant `F`, and `lerp_lerp` guarantees this two-parameter family stays inside
the geodesic algebra so the contraction is internal, not merely topological.

**Why now?** Both ingredients are in hand — `lerp_lerp` gives the algebra of paths and
`lerp_self` gives the constant path — so the contraction can be *built as a Lean term*
(`fun s r => lerp F (γ r) ...`) rather than asserted abstractly. This is the natural first
genuinely 2-dimensional (homotopical) theorem of the arc.

---

## Direction 3 — Geodesics do not stay in the Vietoris–Rips locus

**Conjecture.** Let `diamFiltration` (from `HigherPersistence.lean`) be the
Vietoris–Rips diameter filtration of a finite metric space. Then the geodesic between two
diameter-filtrations generically *leaves* the diameter locus: there is a finite metric
configuration and a `t ∈ (0,1)` for which `lerp (diamFiltration X) (diamFiltration Y) t`
is **not** equal to `diamFiltration Z` for any metric `Z`. Equivalently, the set of
Vietoris–Rips filtrations is geodesically *non-convex* inside `(Filtration α,
eInterleavingDist)`.

**The key insight is** that diameter weights satisfy a triangle-type compatibility
constraint across simplices (the weight of a triangle is determined by its edges via a
max), whereas convex interpolation mixes weights simplex-by-simplex independently and
destroys that constraint — the interpolant is a valid monotone filtration but not a valid
*metric* filtration.

**Why now?** Bridge IX explicitly flagged this as its geometric-vs-combinatorial frontier
but lacked the path object to test it; Bridge X's `lerp` plus the existing
`diamFiltration` make the statement a direct computation on a 3- or 4-point space,
falsifiable by exhibiting a single simplex whose interpolated weight violates the
diameter max-rule.

---

## Direction 4 — Functorial transport of geodesics

**Conjecture.** The pullback functor of `InterleavingFunctor.lean`
(`F ↦ ⟨σ ↦ F.weight (σ.image f), …⟩` for `f : α → β`) sends geodesics to geodesics and is
**1-Lipschitz on paths**: `pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t`
and therefore `d(pullback f (lerp F G s), pullback f (lerp F G t)) ≤ ofReal|s−t| ·
d(pullback f F, pullback f G)`, with equality iff `f` does not collapse the maximising
simplex. Hence `pullback f` is a morphism of geodesic spaces, and the assignment
`α ↦ (Filtration α, lerp)` is a functor into the category of geodesic spaces.

**The key insight is** that `pullback` acts on weights by *precomposition* with
`σ ↦ σ.image f`, an operation that is **affine** in the weight, so it commutes
definitionally with the affine `lerp` — the geodesic structure is preserved for the same
algebraic reason `lerp_lerp` holds.

**Why now?** The pullback functor already exists and is proven 1-Lipschitz on points in
`InterleavingFunctor.lean`; combined with `lerp` from this cycle, the commutation
`pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t` is a one-line
`ext_weight`/`simp` away, immediately upgrading a point-level isometry statement to a
path-level (functorial) one and connecting the metric and homotopical chapters of the arc.
