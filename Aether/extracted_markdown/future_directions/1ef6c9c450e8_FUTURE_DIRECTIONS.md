# FUTURE DIRECTIONS — Functorial Lipschitz comparison: valuation depth ↔ tropical shadow

This cycle salvaged and completed the depth ↔ tropical-shadow bridge as three
self-contained, sorry-free Lean files in `Catalog/Bridges/`:

* `FunctorialDepthTropicalLipschitz.lean` — `MaxPlusDepthSystem`, the
  `shadow b f = b ^ depth f` functor, the multiplicative Lipschitz bound
  `shadow_comp_le`, the iterate bound `shadow_iter_le`, and the concrete
  valuation-depth instance `ofUltrametricCompositionLaw` /
  `shadow_comp_le_valuation` (reusing the catalog adapter
  `UltrametricCompositionLaw.vdepth_comp` from `Computation/PadicValuationDepth`).
* `TropicalRipsConnectivity.lean` — ultrametric collapse of Rips reachability
  (`reachable_iff`) and the tropical connectivity-threshold functor
  (`connThreshold_ultra`).
* `CayleyConnectivityEnergy.lean` — generation ⇒ Cayley walk-connectivity and the
  zero-Cayley-Dirichlet-energy ⇔ constant characterization.

The unifying finding: a `Nat`-valued depth obeying the tropical (max-plus)
composition inequality `depth (f∘g) ≤ max (depth f) (depth g) + 1` is *exactly*
a contraction in disguise. Exponentiation `b ^ (·)` is the order isomorphism that
carries the max-plus semiring into a multiplicative Lipschitz estimate with
constant `b`.

---

## Conjecture 1 — Exact (not just upper-bound) Lipschitz constant on a graded subclass
On the subclass of depth systems where `depth (comp f g) = max (depth f) (depth g) + 1`
holds with *equality* (e.g. strictly nondegenerate valuation pipelines), the shadow
satisfies `shadow b (comp f g) = b * max (shadow b f) (shadow b g)`, so `b` is the
*sharp* Lipschitz constant, not merely an upper bound.

The key insight is that `pow_max_eq_max_pow` is an equality, so the only slack in
`shadow_comp_le` comes from `depth_comp_le`; removing that slack makes the bridge an
isomorphism of max-structures rather than a one-sided estimate.

Why now? `pow_max_eq_max_pow` and `shadow_comp_le` are already proved here; the
equality version only needs a strengthened structure field, an immediately testable
refactor.

## Conjecture 2 — Sub-multiplicative depths give a genuine ultrametric on the shadow
Define `d(f,g) = shadow b (comp f g)` on an idempotent depth system. Then `log_b d`
is an ultrametric pseudo-distance, i.e. `connThreshold_ultra`'s strong triangle
inequality holds for the depth-shadow exactly as it does for the Rips threshold.

The key insight is that both files in this cycle instantiate the *same* max-plus
triangle inequality — `depth_comp_le` and `dist_triangle_max` are the identical
algebraic law — so the connectivity-threshold functor and the shadow functor are two
realizations of one tropical metric.

Why now? `TropicalRipsConnectivity.connThreshold_ultra` supplies the metric template
and `shadow_comp_le` supplies the depth side; merging them is a direct comparison.

## Conjecture 3 — Iterated-shadow growth is the spectral radius of the depth operator
For a fixed `f`, the exponential growth rate `limsup_n (shadow b (iter n f))^(1/n)`
equals `b` whenever `f` has positive depth, matching `shadow_iter_le`'s `b ^ n` rate;
i.e. the bound `shadow_iter_le` is asymptotically tight.

The key insight is that `depth_iter_succ_le` gives `depth (iter n f) ≤ depth f + n`,
and on nondegenerate systems this is an equality, pinning the growth rate to exactly
`b`.

Why now? `depth_iter_succ_le` and `shadow_iter_le` are proved; the asymptotic
statement is a `Nat`-arithmetic limit that the same machinery supports.

## Conjecture 4 — Zero-energy rigidity transfers to the depth shadow
On a Cayley-generated depth system, the only function with zero tropical "oscillation"
(`shadow`-difference identically `b ^ 0 = 1` across generators) is the constant-depth
function — the depth analogue of `cayleyDirichletEnergy_eq_zero_iff_constant`.

The key insight is that the zero-energy proof only uses (a) nonnegativity of squares
and (b) generation; replacing squares by the order-preserving `shadow` gap preserves
both ingredients.

Why now? `cayleyDirichletEnergy_eq_zero_iff_constant` and `word_in_generators_of_mem_closure`
are in hand; the transfer reuses the generation-to-constancy lemma verbatim.

## Conjecture 5 — Functoriality: depth-preserving maps induce shadow contractions
A morphism of depth systems (a map commuting with `comp` and not increasing `depth`)
induces a `b`-Lipschitz map of shadows; thus `shadow` is a functor from
`MaxPlusDepthSystem` to the category of `b`-Lipschitz `Nat`-metric spaces.

The key insight is that every estimate in this file is natural in the system `S`
(none use `α`-specific structure beyond `comp`/`depth`), so the bridge is functorial
rather than pointwise.

Why now? The `MaxPlusDepthSystem` structure and all of its proved bounds are stated
generically over `S`, so defining the morphism class and checking functoriality is a
purely formal next step.
