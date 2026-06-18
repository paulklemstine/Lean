# Future Directions: From Maslov Dequantization to Tropical Amoebas

This cycle delivered, in `Catalog/Tropical/MaslovMultivariate.lean`, three load-bearing
theorems and two supporting bounds that close the gap between the catalog's one-variable
log-sum-exp results (`Tropical.NeuralNetworks.NDimLogSumExp`, `Tropical.LSEConvexity`) and the
genuinely multivariate / asymptotic tropical picture:

- `tropical_poly_convexOn` — a tropical polynomial `x ↦ ⨆ᵢ (mᵢ x + aᵢ)` over **any** real
  vector space `E` is convex on all of `E`.
- `maslov_dequantization` — `h · log (∑ᵢ exp(aᵢ/h)) → maxᵢ aᵢ` as `h → 0⁺`, for any finite
  nonempty family, via the collapsing sandwich `max ≤ h·log Σ ≤ max + h·log(card)`.
- `maslov_two_point_rate` — the sharp catalog specialization `|h·log(eᵃ́ʰ+eᵇ́ʰ) − max a b| ≤ h·log 2`.

The synthesis is that **convexity (a static, geometric fact) and dequantization (a dynamic,
asymptotic fact) are two faces of the same `Finset.sup'` object**: the same finite-max structure
that is preserved by `ConvexOn.sup` is the structure that the temperature limit `h → 0⁺` carves
out of the smooth log-sum-exp. The remaining program is to push this duality into the *geometry*
of the maximizing locus (the tropical hypersurface / amoeba) rather than just its value.

Below are five falsifiable directions, ordered by how directly they build on what is now proved.

## 1. The dequantization gap is exactly the soft-max entropy, and it is monotone in `h`

The proved bound `0 ≤ h·log Σ − max ≤ h·log(card)` hides a sharper identity: the gap equals
`h · log (∑ᵢ exp((aᵢ − M)/h))` where `M = max`, and dividing through, `(h·log Σ − M)/h` is the
free energy whose `h`-derivative is the Gibbs/soft-max entropy `−∑ pᵢ log pᵢ` with
`pᵢ = exp(aᵢ/h)/Σ`. **Conjecture:** `h ↦ h·log(∑ᵢ exp(aᵢ/h)) − maxᵢ aᵢ` is nonnegative,
monotone nondecreasing in `h > 0`, and its right-derivative at `0⁺` equals `0` exactly when the
argmax is unique (and equals `log(#argmax)`-rate otherwise). The key insight is that the gap is a
relative entropy, so monotonicity is convexity of `t ↦ log ∑ exp(t aᵢ)` in disguise — a property
we already have machinery for via `tropical_poly_convexOn`. Why now? Both the upper/lower bounds
and the convexity engine are formalized in this file, so the only new ingredient is
differentiating log-sum-exp, for which Mathlib's `Real.add` / `deriv` API suffices.

## 2. The tropical hypersurface is the non-differentiability locus, with codimension ≥ 1

Define the tropical hypersurface `V(f)` of `f(x) = ⨆ᵢ (mᵢ x + aᵢ)` as the set where the `sup'`
is attained by at least two distinct indices. **Conjecture:** `V(f)` is exactly the set where the
convex function `f` (proved convex in `tropical_poly_convexOn`) fails to be differentiable, and on
each connected component of its complement `f` is affine (equal to a single `mᵢ · + aᵢ`). The key
insight is that for a finite max of affine functions, the subdifferential at `x` is the convex hull
of the *active* gradients `{mᵢ : mᵢ x + aᵢ = f x}`, so differentiability ⇔ a single active index ⇔
`x ∉ V(f)`. Why now? `tropical_poly_convexOn` supplies the convex object; Mathlib's
`ConvexOn`/subgradient API (`hasSubgradientAt`, `Convex`) lets us state the active-set
characterization without leaving the formalized framework.

## 3. Maslov dequantization of integrals (finite-support Laplace principle)

Generalize `maslov_dequantization` from finite sums to integrals against a finitely-supported (or
discrete) measure as a first step toward Laplace's method:
`h · log (∫ exp(f/h) dμ) → ess-sup f`. **Conjecture:** for `μ` a finite measure with finite
support `S` and `f` bounded, `h·log(∫ exp(f/h) dμ) → max_{x∈S} f x`, with the *same* sandwich
`max ≤ … ≤ max + h·log(μ-mass · /min-weight)`. The key insight is that the finite-support integral
**is** a weighted finite sum, so the proof is `maslov_dequantization` plus the catalog's already-
proved weighted bounds (`weighted_logsumexp_upper/lower` in `LSEConvexity`). Why now? It reuses two
existing formalized results verbatim and is the cleanest on-ramp to the full
`MeasureTheory.integral` Laplace principle that direction #2 of the seed concept calls for.

## 4. Newton-polytope duality: slopes of `f` are vertices of `conv{mᵢ}`

For the special case `E = ℝⁿ`, `mᵢ x = ⟨nᵢ, x⟩` with integer exponent vectors `nᵢ`, the regions
where `f` is affine are indexed by the vertices of the Newton polytope `conv{nᵢ}` that actually
"win" for some `x`. **Conjecture:** the gradient map `x ↦ ∇f(x)` (defined off `V(f)`) takes values
exactly in the vertex set of `conv{nᵢ}`, and the induced cell decomposition of `ℝⁿ` is the normal
fan of the regular subdivision of `{nᵢ}` lifted by the heights `aᵢ`. The key insight is that the
Legendre/Fenchel transform of a finite max of linear forms is the support function of a finite
point set, so the dual subdivision is forced by Fenchel duality — and the catalog already contains
a Fenchel–Moreau result (`Tropical.FenchelMoreau`) to anchor this. Why now? `tropical_poly_convexOn`
plus the existing Fenchel infrastructure means the conjugate is available; only the
vertex-enumeration combinatorics is new.

## 5. The catalog's tropical semiring homomorphism IS the `h → 0` functor

The catalog has `TropicalSemiringHom` (log-sum-exp as an approximate `(+,×) → (max,+)`
homomorphism) and we now have `maslov_dequantization` making the limit exact. **Conjecture:** the
family `Lₕ(a,b) = h·log(eᵃ́ʰ+eᵇ́ʰ)` is, for each `h>0`, a commutative-monoid structure on `ℝ`
deforming the real additive monoid to the tropical (max) monoid, and `maslov_dequantization`
exhibits a continuous path of monoid structures from "+ on exponentials" to "max", i.e. a
*homotopy of algebraic structures* whose endpoint is the tropical semiring. The key insight is
that dequantization is not just a numerical limit but a deformation of the *operation itself*, so
it should be packaged as a one-parameter family of `CommMonoid` instances converging in the
sense of pointwise `Tendsto` — the algebraic shadow of Berkovich's `val` map (seed direction #5).
Why now? The two endpoints (`TropicalSemiringHom`, the tropical `max` monoid) are already in the
catalog, and `maslov_dequantization` is precisely the continuity statement that glues them into a
path, making this the natural unifying capstone for the next cycle.
