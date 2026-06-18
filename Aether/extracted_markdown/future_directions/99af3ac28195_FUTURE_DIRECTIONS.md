# Future Directions — Tropicalization of Arithmetic Height

## Synthesis

The work in `Catalog/Bridges/TropicalArithmeticHeight.lean` settles a question left
implicit by the catalog: *can the raw rational arithmetic height
`ratArithHeight q = |num q| + den q` (from `Bridges/ArithmeticVCDimension.lean`) be made
to satisfy the strong (ultrametric) triangle inequality demanded by the tropical/ultrametric
interface in `Bridges/CategoricalTropicalUltrametric.lean`?* The answer is a precise **no, but**:
the raw height is archimedean (`rawHeight_not_ultrametric`), yet its **per-prime
tropicalization** — the negative `p`-adic valuation `vtropHeight p q = -padicValRat p q`,
together with its non-negative part `htropHeight p q = (-padicValRat p q).toNat` — *is*
genuinely ultrametric. We proved the full falsifiable hierarchy: identity (`dHt_self`),
symmetry (`dHt_comm`), the strong triangle inequality (`dHt_strong_triangle`), the ordinary
triangle inequality as a corollary (`dHt_triangle`), and that translation and negation are
*exact* isometries (`dHt_translation_isometry`, `dHt_neg_isometry`). We additionally pinned
down the two obstructions to a naive packaging: the raw height fails strong subadditivity,
and the tropical height fails the strict multiplicativity `norm(xy) = norm x · norm y`
required by `UltraNormObj.norm_mul` (`htropHeight_not_multiplicative`) — the *correct*
law being the tropical one `vtropHeight p (xy) = vtropHeight p x + vtropHeight p y`
(`vtropHeight_mul`): multiplication maps to tropical addition, not to ℕ-product.

## Results Summary

| Theorem | Statement |
|---|---|
| `htropHeight_add_le_max` | `htropHeight p (a+b) ≤ max (htropHeight p a) (htropHeight p b)` |
| `vtropHeight_mul` | `vtropHeight p (a*b) = vtropHeight p a + vtropHeight p b` (a,b ≠ 0) |
| `htropHeight_mul_le_add` | tropical/max-plus composition law for the ℕ-height |
| `dHt_self`, `dHt_comm` | `dHt` is a reflexive, symmetric pseudometric |
| `dHt_strong_triangle` | `dHt p x z ≤ max (dHt p x y) (dHt p y z)` (ultrametric) |
| `dHt_translation_isometry`, `dHt_neg_isometry` | `x↦x+c`, `x↦-x` are exact isometries |
| `dHt_eq_zero_iff` | kernel = `p`-integral differences (separation on the quotient) |
| `htropHeight_respects_trop_max` | bridge to `tropicalization_base.max_op` |
| `rawHeight_not_ultrametric`, `htropHeight_not_multiplicative` | the two obstructions |

## Research Directions

**1. Global tropical height as a product/sup over all primes, and a Northcott-style finiteness.**
Define `dHtGlobal x y := ∑' p, dHt p x y` (or the sup) over primes `p`, and conjecture that
the radius-`R` balls of this global pseudometric, intersected with bounded-`ratArithHeight`
sets, are *finite* — a tropical reflection of Northcott's theorem already gestured at in
`ArithmeticVCDimension.lean`. The key insight is that the strong triangle inequality holds
prime-by-prime, so the global object is a *coproduct of ultrametrics* whose finite balls are
governed by the denominator's factorization. Why now? We already have the per-prime
ultrametric proved with `sorry = 0`, and `ratArithHeight` finiteness lemmas live in the same
catalog file, so the only missing piece is summing a now-controlled family.

**2. A bona fide functor `Heightℚ ⟶ UltraNormObj` through a corrected codomain.**
`htropHeight_not_multiplicative` shows the strict `norm_mul` axiom is the obstruction. Conjecture
that replacing `UltraNormObj`'s `norm_mul : norm(xy)=norm x·norm y` by the *tropical*
`norm(xy) = norm x + norm y` (a `TropNormObj`) yields a category into which `(ℚ,+,·,vtropHeight)`
embeds as a genuine, nonexpansive valuation morphism. The key insight is that `vtropHeight_mul`
already proves the tropical multiplicativity, so the right target is max-plus, not the
ℕ-product semiring. Why now? The catalog's `valuationReconstruct` functor is one axiom away
from accepting our valuation; isolating that axiom is exactly what the obstruction theorem did.

**3. Completion and a `p`-adic metric realization.**
Conjecture that the metric completion of `(ℚ, λx y. p^(-dHt p x y))` (turning the additive
height into a multiplicative ultrametric distance) is isometric to the standard `p`-adic
numbers `ℚ_[p]`, and that `dHt` computes `-log_p` of the `p`-adic distance on the dense copy
of `ℚ`. The key insight is that `dHt p x y = 0 ↔ x-y` is `p`-integral (`dHt_eq_zero_iff`),
which is precisely the statement that the kernel is the valuation ring `ℤ_(p)`. Why now? With
the separation/kernel theorem in hand, the comparison map to Mathlib's `Padic` is well-defined,
and only the completeness/density estimate remains.

**4. Lipschitz/contraction spectrum of affine maps `x ↦ a·x + b`.**
We proved translation and negation are isometries; conjecture more generally that
`dHt p (a*x+b) (a*x'+b) = dHt p (x) (x') + htropHeight p a` whenever `a ≠ 0`, so every
nonzero affine map is an *exact* dilation by the height of its multiplier, and is nonexpansive
iff `a` is `p`-integral. The key insight is `vtropHeight_mul` again: scaling shifts the
valuation additively, hence shifts the ultrametric distance by a constant `htropHeight p a`.
Why now? The multiplicative law is already proved, so this is a direct, falsifiable
computation that would complete the "isometries/nonexpansive maps" item of the hierarchy.

**5. Cross-domain transfer to `ValuationDepthMeasure` (computation/complexity).**
`Computation/PadicValuationDepth.lean` posits an abstract `UltrametricCompositionLaw`
(composition uses `max`, not `+`). Conjecture that `htropHeight` is a concrete witness:
the map `q ↦ htropHeight p q` realizes a `ValuationDepthMeasure`-style cost on ℚ where
addition obeys `max` (our `htropHeight_add_le_max`) and multiplication obeys the additive
composition bound (`htropHeight_mul_le_add`), giving a certified `O(1)`-carry arithmetic
model. The key insight is that the two laws we proved are *exactly* the dual pair
(`add ↦ max`, `mul ↦ +`) that the depth typeclass abstracts. Why now? Both files now exist in
the catalog with compatible ℕ-valued signatures, so instantiating the typeclass is a matter
of supplying our two proved estimates.
