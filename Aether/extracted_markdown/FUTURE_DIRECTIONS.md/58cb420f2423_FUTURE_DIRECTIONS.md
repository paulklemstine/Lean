# Future Directions

These directions extend the `ordEGF` bridge in
`Catalog/Bridges/SpeciesTropicalValuation.lean` from a single order-only invariant toward
richer tropical and valuation-theoretic semantics for combinatorial sequences.

## 1. From order-only profiles to coefficientwise valuation profiles

The current invariant `ordEGF a = order (egf a)` retains only the *first* place where the EGF
is supported; it discards everything about the remaining coefficients. The key insight is that
the order map is just the degree-`0` shadow of a far finer object — the full *valuation profile*
`n ↦ v(coeff n (egf a))` valued in an ordered value group — and the same two transport lemmas
(`order_mul`, `min_order_le_order_add`) are the leading-term specializations of coefficientwise
additivity and ultrametric subadditivity. Why now? Because the bridge already isolates the exact
two power-series facts being transported, so swapping `order` for a `p`-adic or `X`-adic
valuation profile is a localized change: once Mathlib's valuation infrastructure on
`PowerSeries`/Laurent series is connected to `egf`, the present theorems generalize almost
verbatim to a coefficientwise profile that detects cancellation in *every* degree rather than
only the first.

## 2. A genuine tropical-semiring homomorphism object

Right now the multiplicative and additive bridges live as two separate theorems. The key
insight is that `ordEGF` is a structure-preserving map from the exponential-convolution
semiring `(ℕ → ℚ, binConv, +)` into the tropical semiring `(WithTop ℕ, +, min)`, and that this
should be packaged as a bundled semiring (or at least monoid) homomorphism rather than as loose
lemmas. Why now? Because `Catalog/Applications/SpeciesConvolutionRing.lean` already exhibits the
counting sequences as a commutative semiring under `binConv`, so the domain object exists; the
only missing piece is choosing the right tropical target instance, after which `ordEGF_binConv`
and `ordEGF_add_ge` become the `map_mul`/`map_add`-style fields of a single bundled morphism that
downstream files can apply uniformly.

## 3. Sharp cancellation criteria for the additive bridge

The additive bridge is an inequality, `min (ordEGF a) (ordEGF b) ≤ ordEGF (a + b)`, and the gap
is exactly leading-term cancellation. The key insight is that equality fails *iff* the lowest
nonvanishing coefficients of `egf a` and `egf b` sit in the same degree and cancel, which is a
decidable, fully explicit condition on `a` and `b` at the common order. Why now? Because the
order API in Mathlib (`order_le`, `coeff_order`, and friends) already exposes the leading
coefficient, so a clean `ordEGF (a + b) = min (ordEGF a) (ordEGF b)` theorem under a
"no leading cancellation" hypothesis is within immediate reach and would turn the present
superadditivity into a tight tropical valuation law.

## 4. Tropicalized species operations and a Newton-polygon layer

The species corollary layer is currently a thin wrapper (`speciesOrdEGF`, with `setSpecies` as a
worked example). The key insight is that order is the first vertex of the Newton polygon of the
EGF, so attaching the *whole lower convex hull* of `(n, v(aₙ))` to a species would upgrade
`speciesOrdEGF` from a single number to a piecewise-linear tropical curve that is additive under
species product (Newton polygons add via Minkowski sum). Why now? Because the project's species
infrastructure already supplies the counting sequence and its EGF for concrete species (sets,
linear orders, derivative, pointing), giving a ready supply of test cases on which a
Newton-polygon invariant can be defined and validated before any heavy general theory is built.

## 5. Transfer to ordinary generating functions and other transforms

The bridge is currently tied to the *exponential* transform `egf`. The key insight is that the
order valuation is transform-agnostic: any coefficient-preserving-up-to-units transform (the
ordinary generating function, the Borel transform, Hadamard products) induces its own order
bridge, and the divisor `n!` in `egf` is a unit in `ℚ` precisely so that `ordEGF` coincides with
the raw support order of `a`. Why now? Because the proofs here factor cleanly through `egf_mul`
and `egf_add` rather than through the specific shape of `egf`, so re-deriving the same package for
an OGF transform (with the appropriate convolution `Finset.antidiagonal` instead of `binConv`)
is a parallel, low-risk development that would let later work compare valuation profiles across
transforms within one uniform tropical framework.
