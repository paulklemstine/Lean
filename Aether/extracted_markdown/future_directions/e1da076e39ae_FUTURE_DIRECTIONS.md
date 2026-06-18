# Future Directions — Boltzmann Bridge XI: Functorial Transport and the Contractible Path Space

## Synthesis

Bridge XI (`InterleavingPathFunctor.lean`) discharged the two purely *constructive*
Future Directions left open by Bridge X. It turned the static path space of
filtrations into a **functorial and contractible** object, resting on a single
structural observation: both the pullback `pullback f` and the geodesic interpolation
`lerp` are *affine in the weight*, so they commute on the nose.

Three facts now interlock over the geodesic `lerp`:

* a **functorial** law — `pullback_lerp` shows `pullback f (lerp F G t) =
  lerp (pullback f F) (pullback f G) t`, so the contravariant persistence functor
  carries the `F`–`G` geodesic onto the geodesic of the pulled-back endpoints. This
  upgrades Bridge IX''s point-level `1`-Lipschitz statement (`pullback_lipschitzWith_one`)
  to the path-level isometry `eInterleavingDist_pullback_lerp` and its contraction
  bound `eInterleavingDist_pullback_lerp_le`. The assignment `α ↦ (Filtration α, lerp)`
  is thus a functor into geodesic spaces.
* a **homotopical** law — `lerp_straightLine_contraction` builds the explicit
  straight-line homotopy `H s r = lerp F (γ r) s` contracting any path `γ` to its
  basepoint `F` at constant `s`-speed, witnessing that the path space is contractible.
* a **diagonal** law — `eInterleavingDist_convex_sharp` records that Bridge X's
  Busemann convexity inequality becomes an *equality* at `H = F`, identifying the
  Bridge IX geodesic identity as the sharp diagonal of convexity.

The decisive insight of this cycle is that **transport and contraction are the same
algebraic fact wearing two hats**: "affine commutes with affine" is what makes
`pullback` commute with `lerp` (functoriality) and equally what keeps the contracting
two-parameter family `lerp F (γ r) s` inside the geodesic algebra (contractibility).
No metric reasoning enters the structural layer; the metric content is inherited
verbatim through the Bridge VIII isometry and the Bridge IX geodesic identity.

## Results summary

| Theorem | Statement | Role |
|---|---|---|
| `pullback_lerp` | `pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t` | geodesic transport (algebraic) |
| `eInterleavingDist_pullback_lerp` | `d(pb (lerp s), pb (lerp t)) = ofReal\|s−t\|·d(pb F, pb G)` | path-level isometry |
| `eInterleavingDist_pullback_lerp_le` | `… ≤ ofReal\|s−t\|·d(F,G)` | pullback is short on paths |
| `lerp_straightLine_contraction` | `∃ H, H 0 = F ∧ H 1 = γ ∧ constant-speed` | contractible path space |
| `eInterleavingDist_convex_sharp` | `d(F, lerp F G t) = ofReal(1−t)·d(F,F)+ofReal t·d(F,G)` | sharp diagonal of convexity |

All five compile with `sorry`-count 0 and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

---

## Direction 1 — The strict convexity defect and genuinely non-unique geodesics

**Conjecture.** The Busemann defect
`δ(H,F,G,t) := ofReal(1−t)·d(H,F) + ofReal t·d(H,G) − d(H, lerp F G t)` is `≥ 0`
everywhere (Bridge X's `eInterleavingDist_convex`) and equals `0` at `H = F`
(Bridge XI's `eInterleavingDist_convex_sharp`), but is *not* identically zero: over
`α = Fin 2` there is an explicit triple `F, G, H` of `ofWeight`-filtrations and a
`t ∈ (0,1)` with `δ(H,F,G,t) > 0`. Consequently `(Filtration α, eInterleavingDist)`
admits two genuinely distinct constant-speed geodesics between some pair, so it is
geodesic but **not uniquely geodesic**, hence not CAT(0), despite Busemann convexity.

**The key insight is** that the interleaving metric is, by Bridge VIII's
`eInterleavingDist_eq_weightSupEDist`, an ℓ∞-type supremum over simplices, and ℓ∞
balls are cubes: when the simplex maximising `|H − lerp t|` *migrates* from one
coordinate to another as `t` crosses a threshold, the straight convex bound is
strictly slack and a bent path realises the same endpoint distance.

**Why now?** Bridge VIII already reduces every distance to a finite `⨆` over
`Finset (Fin 2)` (four simplices), and `ofWeight` builds filtrations from explicit
weight tables. The defect is therefore a finite `#eval`-checkable sup computation, not
an analytic argument — the entire CAT(0) question collapses to exhibiting one weight
table where the argmax of the gap moves with `t`.

---

## Direction 2 — Naturality of the contraction: pullback transports homotopies

**Conjecture.** The straight-line contraction of `lerp_straightLine_contraction` is
*natural* in the vertex type: for `f : α → β`, pulling back the contraction of a path
`γ` based at `F` is the contraction of the pulled-back path `pullback f ∘ γ` based at
`pullback f F`, i.e. `pullback f (H s r) = H' s r` where `H'` is the contraction
produced from `pullback f F` and `pullback f ∘ γ`. Hence `pullback f` is not merely a
morphism of geodesic spaces but a morphism of **contractions**, and the assignment
`α ↦ (path space of Filtration α)` is a functor into contractible spaces with
basepoint-preserving, contraction-preserving maps.

**The key insight is** that `pullback_lerp` already commutes `pullback` past a single
`lerp`, and the contraction homotopy `H s r = lerp F (γ r) s` is built entirely from
`lerp`s; so `pullback` commutes past the *whole two-parameter family* for the same
"affine commutes with affine" reason, with no new metric input.

**Why now?** `pullback_lerp` is the exact one-step commutation lemma, and
`lerp_straightLine_contraction` packages the homotopy explicitly as a term in `lerp`;
the naturality square is therefore a direct `ext_weight`/`simp` rewrite of the
homotopy term, immediately promoting Bridge XI's two separate functorial and
homotopical chapters into a single functor-of-contractible-spaces statement.

---

## Direction 3 — Geodesics leave the Vietoris–Rips locus

**Conjecture.** Let `diamFiltration` (from `HigherPersistence.lean`) be the
Vietoris–Rips diameter filtration of a finite metric space. The geodesic between two
diameter-filtrations generically *leaves* the diameter locus: there is a finite metric
configuration (a 3- or 4-point space) and a `t ∈ (0,1)` for which
`(lerp (diamFiltration X) (diamFiltration Y) t).weight` violates the diameter
max-rule `weight(triangle) = max over its edges`, so no metric `Z` has
`diamFiltration Z = lerp (diamFiltration X) (diamFiltration Y) t`. The VR locus is
geodesically *non-convex* inside `(Filtration α, eInterleavingDist)`.

**The key insight is** that diameter weights obey a cross-simplex compatibility
constraint — a triangle's weight is the max of its three edge weights — whereas
`lerp` mixes the weight of each simplex *independently* and affinely; an affine blend
of two maxima is generally not the max of the blended edges, so the interpolant stays
a valid monotone filtration but ceases to be a valid *metric* filtration.

**Why now?** Bridge IX flagged this frontier but had no path object; Bridge X gave
`lerp` and Bridge XI confirmed `lerp` is transported and contracted functorially.
With `diamWeight` already a concrete `sup'` over pairwise distances, the violation is
a single arithmetic inequality on one triangle of a 3-point space — falsifiable by one
`#eval`.

---

## Direction 4 — The equality locus of functorial transport

**Conjecture.** The path-level contraction `eInterleavingDist_pullback_lerp_le` is
*sharp exactly when `f` is surjective*: for surjective `f`, the transported geodesic
speed equals the upstream speed, `d(pb (lerp s), pb (lerp t)) = ofReal|s−t|·d(F,G)`
for all `s,t ∈ [0,1]`; and for any non-surjective `f` whose missed simplices carry a
strictly larger weight gap, the inequality is strict at every `s ≠ t`. Thus
`pullback f` is a *path-isometry* iff it is a metric isometry iff `f` is surjective —
a clean trichotomy fusing Bridge IX''s corrected Direction 3 with Bridge XI's path
layer.

**The key insight is** that `eInterleavingDist_pullback_lerp` already factors the
transported speed as `ofReal|s−t|` times `d(pb F, pb G)`, and Bridge IX''s
`eInterleavingDist_pullback_eq_of_surjective` pins exactly when `d(pb F, pb G) =
d(F,G)`; the path equality is therefore the scalar `ofReal|s−t|` multiplied through
the *endpoint* equality, so the geodesic-speed equality locus *is* the endpoint
isometry locus.

**Why now?** Both halves exist: `eInterleavingDist_pullback_lerp` gives the speed
factorisation and `eInterleavingDist_pullback_eq_of_surjective` gives the endpoint
characterisation. Multiplying one by `ofReal|s−t|` is a one-line `congr`/`rw`, turning
two endpoint-level facts into a complete path-level isometry classification — the
natural capstone of the functorial-transport chapter.
