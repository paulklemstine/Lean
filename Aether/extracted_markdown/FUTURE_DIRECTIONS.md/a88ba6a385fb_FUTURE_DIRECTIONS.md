# Future Directions — Arithmetic Heights as Tropical Valuations Inducing Ultrametric Lipschitz Bounds

## Synthesis

The catalog's `Bridges/CategoricalTropicalUltrametric.lean` built an *abstract* functor
`valuationReconstruct : TropicalValuationCarrier → UltraNormObj` and proved that tropical
Lipschitz bounds transfer to ultrametric ones with the *same constant*
(`tropical_lipschitz_to_ultrametric_lipschitz`, `sharp_lipschitz_transfer`,
`iterated_ultrametric_lipschitz_rate`). What that file never supplied was a *non-trivial
witness*: every interesting consequence of the bridge was about an abstract carrier whose
valuation might as well have been the trivial one.

The new file `Bridges/ArithmeticHeightTropicalUltrametric.lean` closes that gap. It exhibits
the **polynomial degree height** `degHeight p = 2 ^ (natDegree p)` (with `degHeight 0 = 0`) as
a fully verified, genuinely non-trivial `TropicalValuationCarrier` over any field, and uses it
to make the bridge *quantitative*: left multiplication by a fixed polynomial `g` is an
ultrametric–Lipschitz map whose Lipschitz constant is *exactly* `degHeight g`, i.e. the
tropical valuation (the degree datum) of the multiplier — and this constant is **attained**
(`mul_left_lipschitz_sharp`), not just an upper bound. Alongside it, the rational naive height
`ratHeight q = max |num q| (den q)` is shown to be self-dual under inversion
(`ratHeight_inv`) and reflection invariant (`ratHeight_neg`), but — adversarially — **not**
multiplicative (`ratHeight_not_val_mul`), so it is *not* a `TropicalValuationCarrier`.

## Results summary (all `sorry`-free; axioms ⊆ {propext, Classical.choice, Quot.sound})

* `degHeight_mul` — multiplicativity (the tropical `val_mul` axiom), an equality, via
  `natDegree_mul`.
* `degHeight_add_le` — the ultrametric strong-triangle inequality (the `val_add` axiom), via
  `natDegree_add_le` and monotonicity of `2 ^ ·`.
* `degHeight_neg`, `degHeight_pow` — reflection invariance and the closed power form
  `degHeight (gⁿ) = (degHeight g)ⁿ`.
* `degreeValuationCarrier` — the concrete `TropicalValuationCarrier` instance on `F[X]`.
* `degree_reconstruct_ultrametric`, `degree_reconstruct_mul` — the reconstructed `F[X]`-norm
  is a genuine multiplicative ultrametric seminorm.
* `mul_left_tropical_lipschitz` / `mul_left_ultrametric_lipschitz` / `mul_left_lipschitz_sharp`
  / `mul_left_iterated_ultrametric` — **the headline**: the tropical valuation of the
  multiplier is the (attained) ultrametric Lipschitz constant, and the iterate has constant
  `(degHeight g)ⁿ`.
* `one_le_ratHeight`, `ratHeight_neg`, `ratHeight_inv`, `ratHeight_not_val_mul` — positivity,
  reflection invariance, inversion duality, and the failure of multiplicativity.

---

## Direction 1 — Sharpness as a representability theorem

We proved `degHeight (g * x) = degHeight g * degHeight x` (`mul_left_lipschitz_sharp`), so the
constant `degHeight g` is attained. The conjecture is that this *characterises* left
multiplications among additive endomorphisms of `F[X]`: an additive, degree-multiplicative,
`degHeight g`-Lipschitz map that fixes `1` up to scaling is necessarily multiplication by a
polynomial of degree `log₂ (degHeight g)`. This would upgrade the quantitative bound into a
representation theorem for the endomorphism monoid in the spirit of Gelfand duality
(operators ↔ functions).

The key insight is that the Lipschitz constant in the reconstructed ultrametric world is a
*complete invariant* of the multiplier's tropical valuation, so the constant alone should
reconstruct the operator up to the kernel of `degHeight`.

Why now? The carrier `degreeValuationCarrier` and its `valuationReconstruct` image already
exist and are proven ultrametric; the only missing ingredient is a rigidity lemma for
degree-preserving additive maps, a finite computation supported directly by Mathlib's
`Polynomial.natDegree` API.

## Direction 2 — Tropical spectral radius

`mul_left_iterated_ultrametric` plus `degHeight_pow` already give that the `n`-fold map
`x ↦ gⁿ · x` has ultrametric Lipschitz constant exactly `(degHeight g)ⁿ = degHeight (gⁿ)`. The
conjecture is a **tropical spectral-radius formula**:
`limₙ (degHeight (gⁿ))^{1/n} = 2^{deg g}` exactly, with no slack, making `deg g` the tropical
analogue of the logarithm of a spectral radius.

The key insight is that exact multiplicativity removes the usual sub-multiplicative gap, so the
Gelfand spectral-radius limit collapses to a single closed form determined by the tropical
valuation.

Why now? The iterate's constant is already a clean `Nat` power `(degHeight g)ⁿ`; the remaining
work is an elementary `Real`-valued `n`-th-root limit, well within Mathlib's
`Filter.Tendsto`/`Real.rpow` toolkit.

## Direction 3 — The product formula as a tropical-carrier coproduct

The rational height is, by Weil's theory, a sum over all places of local ultrametric
contributions, exactly one of which is archimedean. The conjecture is that
`TropicalValuationCarrier` is closed under a "restricted product" reproducing the **product
formula** `∏_v |q|_v = 1` for `q ≠ 0`, and that `ratHeight` is the reconstruction of the
finite-place part of this product carrier.

The key insight is that `ratHeight_inv` (`H(q⁻¹) = H(q)`), which we proved, is precisely the
shadow of the product formula under inversion — duality at a single symmetric height level — so
the full product formula should say the family of place-carriers forms a self-dual system.

Why now? We now have a verified single-place carrier (`degreeValuationCarrier`, the
function-field place at infinity) and the rational height with its inversion duality; gluing
finitely many `p`-adic carriers needs only Mathlib's mature `padicValNat`/`padicValRat`.

## Direction 4 — Failure-driven: lax tropical carriers

`ratHeight_not_val_mul` records that `ratHeight` violates the strict `val_mul` equality
(witness `(2/3)·(3/2) = 1` vs `3·3 = 9`), so it is **not** a `TropicalValuationCarrier`. The
conjecture is that weakening `val_mul` from an equation to the inequality
`val (x·y) ≤ val x · val y` yields a *lax tropical carrier* whose `valuationReconstruct` is
still functorial and still transfers Lipschitz bounds (now with a controlled multiplicative
defect), and that `ratHeight` *is* a lax carrier in this sense.

The key insight is that the catalog's reconstruction proofs only ever use `val_mul` in the `≤`
direction for Lipschitz transfer, so the equality is stronger than necessary; a lax relaxation
should preserve every downstream theorem while admitting genuine arithmetic heights.

Why now? The exact dependency is visible in `CategoricalTropicalUltrametric.lean`
(`tropical_bound_to_ultrametric_bound` consumes `val` monotonically), so the relaxation is a
surgical edit plus re-verification — and `ratHeight` is the ready-made first example.

## Direction 5 — Tight certified-robustness for symbolic feature maps

The catalog frames `UltraLipschitzWith` as a certified-robustness radius for nonarchimedean
models, and `depth_lipschitz_separation` gives a per-layer `Cᴸ` bound. The conjecture is that,
for symbolic/polynomial feature maps, the degree-height ultrametric yields a **provably tight**
certificate: a degree-`d` polynomial multiplication layer is `2^d`-Lipschitz and no smaller
constant works, so a depth-`L` symbolic network has exactly computable certified radius
`∏ᵢ 2^{dᵢ}`, with `depth_lipschitz_separation` sharp in this model.

The key insight is that `mul_left_lipschitz_sharp` makes the per-layer constant an *equality*,
turning the usual loose Lipschitz robustness bounds into exact, attainable certificates.

Why now? `depth_lipschitz_separation` and the iterated-rate lemmas already exist; our witness
supplies the matching tightness, so the only new work is a worst-case `degHeight`-evaluation
giving the lower bound.
