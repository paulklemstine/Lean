# Future Directions — Tropical Valuations of Combinatorial Species Profiles

Follow-up conjectures arising from `Catalog/Bridges/SpeciesTropicalValuation.lean`, which
constructed the max-plus tropical valuation object `maxPlusTrop = (WithBot ℕ, max, +)` and
proved that the **degree** of a finite species coefficient profile is a valuation into it,
with the headline result `tropDeg_blind`: the Cauchy product and the species (binomial
convolution) product have identical tropicalizations.

Each conjecture below is stated so that it can be turned directly into a Lean theorem (and
hence confirmed or refuted) in a follow-up cycle.

---

## Conjecture 1 — The dual min-plus *order* valuation
Let `egf a = ∑ (aₙ/n!) Xⁿ ∈ ℚ⟦X⟧` (catalog `CombinatorialSpecies.egf`) and let
`ord : ℚ⟦X⟧ → WithTop ℕ` be `PowerSeries.order`. Then `ord ∘ egf` is a valuation into the
**min-plus** tropical object `minPlusTrop = (WithTop ℕ, min, +)` (the order-reversed mirror
of `maxPlusTrop`), satisfying
`ord(egf (binConv a b)) = ord(egf a) + ord(egf b)` and
`ord(egf (a+b)) ≥ min (ord(egf a)) (ord(egf b))`.
*Test:* build `minPlusTrop` as a `TropicalValuationObject (WithTop ℕ)` with reversed order
and discharge via `egf_mul` + `PowerSeries.order_mul`. This makes degree (max-plus) and
order (min-plus) the two extreme tropical valuations of a species.

## Conjecture 2 — Tropical blindness upgrades to the whole Newton polygon
For finite profiles `p, q` and a prime `r`, form the Newton polygon of the `r`-adic
valuations of the coefficients. Conjecture: the Newton polygon of `binConvP p q` equals the
**Minkowski sum** of the Newton polygons of `p` and `q`, *identically* to that of the Cauchy
product `p*q`. I.e. tropical blindness is not just an equality of top degrees but of the
entire piecewise-linear tropical curve. *Test:* compare lower convex hulls of
`{(n, padicVal (coeff n))}`; `degree_binConvP` is the single-vertex (top) case.

## Conjecture 3 — Tropical action of the differential operators
The catalog's species calculus has derivative `F′` (shift `aₙ ↦ a_{n+1}`) and pointing `F•`
(`aₙ ↦ n·aₙ`). Conjecture, for the degree valuation of a nonzero finite profile `P` of
degree `d ≥ 1`:
`tropDeg(P′) = d - 1` (tropical "division by the unit", `tropDeg P ⊘ one`) and
`tropDeg(P•) = d`. *Test:* `Polynomial.derivative` and the Euler operator `X · d/dX`; the
edge case `d = 0` (constants) is the falsifiable boundary.

## Conjecture 4 — `tropDeg` is a semiring homomorphism with degenerate-difference kernel
The set of finite profiles under (binomial product, pointwise sum) is a commutative
semiring `S`. Conjecture: `tropDeg : S → maxPlusTrop` is a semiring homomorphism onto its
image, and two profiles `p, q` satisfy `tropDeg p = tropDeg q` iff they have the same
degree — so the induced congruence collapses `S` exactly to the chain `WithBot ℕ`.
*Test:* package `tropDeg` as a `TropHom`-style map and prove surjectivity via `setsProfile`.

## Conjecture 5 — A second tropical layer from species substitution
For the substitution (plethystic composition) `F ∘ G` of species with `G` having no
constant term, the finite-profile degree multiplies:
`tropDeg(profile (F ∘ G)) = tropDeg(profile F) * tropDeg(profile G)` (ordinary `ℕ`-product
inside `WithBot ℕ`). This would exhibit composition as a *second* monoid operation whose
tropical shadow is multiplication — stacking on top of the max-plus `(max, +)` structure to
give a tropical *semiring with two products*. *Test:* `Polynomial.comp` degree law
`natDegree (p.comp q) = natDegree p * natDegree q`, then transfer to `binConvP`-composition.
