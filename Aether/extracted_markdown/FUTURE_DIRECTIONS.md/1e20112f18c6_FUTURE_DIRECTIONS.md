# Future Directions — Arithmetic Heights as Tropical Valuations Inducing Ultrametric Lipschitz Bounds

## Synthesis

The catalog's `Bridges/CategoricalTropicalUltrametric.lean` built an *abstract* functor
`valuationReconstruct : TropicalValuationCarrier → UltraNormObj` and proved that tropical
Lipschitz bounds transfer to ultrametric ones with the *same constant*
(`tropical_lipschitz_to_ultrametric_lipschitz`, `sharp_lipschitz_transfer`). What that file
never supplied was a *non-trivial witness* — every interesting consequence of the bridge was
about an abstract carrier whose valuation might as well have been the trivial one.

The new file `Bridges/ArithmeticHeightTropicalUltrametric.lean` closes that gap. It exhibits
the **polynomial degree height** `degHeight p = 2^(deg p)` (with `degHeight 0 = 0`) as a fully
verified, genuinely non-trivial `TropicalValuationCarrier` over any integral domain, and uses
it to make the bridge *quantitative*: multiplication by a fixed polynomial `g` is an
ultrametric–Lipschitz map whose Lipschitz constant is *exactly* `degHeight g`, i.e. the
tropical valuation (the degree datum) of the multiplier. Alongside it, the rational naive
height `ratHeight q = max |num q| (den q)` is shown to be **self-dual under inversion**
(`ratHeight q⁻¹ = ratHeight q`) and reflection invariant — the `x ↔ 1/x` and `x ↔ -x`
symmetries that any place-theoretic height must satisfy.

## Results summary (all `sorry`-free, only `propext`/`Classical.choice`/`Quot.sound`)

* `degHeight_mul` — multiplicativity (the tropical `val_mul` axiom), via `natDegree_mul`.
* `degHeight_add_le` — the ultrametric strong-triangle inequality (the `val_add` axiom),
  via `natDegree_add_le` and monotonicity of `2^·`.
* `degreeValuationCarrier` — the concrete `TropicalValuationCarrier` instance on `F[X]`.
* `degree_reconstruct_ultrametric`, `degree_reconstruct_mul` — the reconstructed `F[X]`-norm
  is a genuine multiplicative ultrametric seminorm.
* `mul_left_tropical_lipschitz` / `mul_left_ultrametric_lipschitz` — **the headline**: the
  tropical valuation of the multiplier is the ultrametric Lipschitz constant.
* `one_le_ratHeight`, `ratHeight_neg`, `ratHeight_inv` — positivity, reflection invariance,
  and the inversion duality of the rational arithmetic height.

---

## Direction 1 — Sharpness of the degree Lipschitz constant (a representability theorem)

We proved `degHeight (g * x) = degHeight g * degHeight x`, so the constant `degHeight g` is
attained, not merely an upper bound. The conjecture is that this *characterises* left
multiplications among additive endomorphisms: **an additive, degree-multiplicative,
`degHeight g`-Lipschitz map of `F[X]` that fixes `1` up to scaling is necessarily
multiplication by a polynomial of degree `log₂ (degHeight g)`.** This would turn the
quantitative bound into a representation theorem for the endomorphism monoid in the spirit of
Gelfand duality (operators ↔ functions).

The key insight is that the Lipschitz constant in the reconstructed ultrametric world is a
*complete invariant* of the multiplier's tropical valuation, so the constant should be enough
to reconstruct the operator up to the kernel of `degHeight`.

Why now? The carrier and its `valuationReconstruct` image already exist and are proven
ultrametric; the only missing ingredient is an injectivity/rigidity lemma for
degree-preserving additive maps, which is a finite linear-algebra computation Mathlib's
`Polynomial.natDegree` API can support directly.

## Direction 2 — Iterating the bound: spectral radius via the catalog's `iterated_*_lipschitz_rate`

The catalog already proved `iterated_tropical_lipschitz_rate` and
`iterated_ultrametric_lipschitz_rate` (constant `C^n` after `n` iterations). Composing with our
witness gives, for free, that the `n`-fold multiplication map `x ↦ gⁿ · x` has ultrametric
Lipschitz constant `(degHeight g)^n = degHeight (gⁿ)`. The conjecture is a **tropical spectral
radius formula**: `lim_{n→∞} (degHeight (gⁿ))^{1/n} = 2^{deg g}` exactly, with no slack,
making `deg g` the tropical analogue of the logarithm of a spectral radius.

The key insight is that multiplicativity removes the usual sub-multiplicative gap, so the
Gelfand spectral-radius limit collapses to a single closed form determined by the tropical
valuation.

Why now? `iterated_ultrametric_lipschitz_rate` is already in the catalog and our
`mul_left_ultrametric_lipschitz` plugs straight into it; the limit is then an elementary
`Nat`-power computation.

## Direction 3 — Many places at once: the product formula as a tropical-carrier coproduct

The rational height is, by Weil's theory, a *sum over all places* of local ultrametric
contributions, exactly one of which is archimedean. The conjecture is that the catalog's
`TropicalValuationCarrier` interface is closed under a "restricted product" that reproduces the
**product formula** `∑_v v(q) = 0` (additively) / `∏_v |q|_v = 1` (multiplicatively) for
`q ≠ 0`, and that `ratHeight` is the reconstruction of the *finite-place part* of this product
carrier.

The key insight is that `ratHeight q⁻¹ = ratHeight q`, which we proved, is precisely the
shadow of the product formula under inversion — duality at a single symmetric height level —
so the full product formula should be the statement that the family of place-carriers forms a
self-dual (Pontryagin-style) system.

Why now? We now have a working, verified single-place carrier (`degreeValuationCarrier`, the
function-field place at infinity) and the rational height with its inversion duality; gluing
finitely many `p`-adic carriers requires only Mathlib's `padicValNat`/`padicValRat`, which are
already mature.

## Direction 4 — Failure-driven: repairing sub-multiplicativity into a lax carrier

Our Failure analysis records that `ratHeight` is only *sub*-multiplicative
(`ratHeight (x·y) ≤ ratHeight x · ratHeight y`), so it is **not** a `TropicalValuationCarrier`
(which demands strict `val_mul` equality). The conjecture is that weakening the carrier axiom
`val_mul` from an equation to an inequality yields a *lax tropical carrier* whose
`valuationReconstruct` is still functorial and still transfers Lipschitz bounds, now with a
controlled multiplicative defect, and that `ratHeight` is a lax carrier in this sense.

The key insight is that the catalog's reconstruction proofs only ever *use* `val_mul` in the
`≤` direction for the Lipschitz transfer, so the equality is stronger than necessary and a lax
relaxation should preserve every downstream theorem while admitting genuine arithmetic heights.

Why now? The exact dependency is visible in `CategoricalTropicalUltrametric.lean`
(`tropical_bound_to_ultrametric_bound` consumes `val` monotonically), so the relaxation is a
surgical edit plus re-verification, immediately enlarging the bridge to cover all classical
heights.

## Direction 5 — Cross-domain: degree-height ultrametric as a certified-robustness metric for symbolic ML

The catalog frames `UltraLipschitzWith` as a certified-robustness radius for nonarchimedean
neural models. The conjecture is that, for symbolic/polynomial feature maps, the degree-height
ultrametric gives a **provably tight robustness certificate**: a degree-`d` polynomial layer is
`2^d`-Lipschitz and no smaller constant works, so depth-`L` symbolic networks have an exactly
computable certified radius `∏ 2^{dᵢ}` and the catalog's `depth_lipschitz_separation` is sharp
in this model.

The key insight is that our `mul_left_*_lipschitz` makes the per-layer constant an *equality*,
turning the usual loose Lipschitz robustness bounds into exact, attainable certificates for the
symbolic regime.

Why now? `depth_lipschitz_separation` and `lipschitz_composition_constant` already exist in the
catalog; our witness supplies the missing tightness, so the only new work is the matching lower
bound, a single `degHeight`-evaluation at a worst-case input.
