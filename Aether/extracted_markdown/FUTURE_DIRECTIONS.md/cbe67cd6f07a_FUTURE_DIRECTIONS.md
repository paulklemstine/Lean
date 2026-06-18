# Future Directions: Tropical Hypersurfaces, Products, and Bézout

This cycle proved the **structural decomposition of tropical hypersurfaces under products**,
`V(P ⊙ Q) = V(P) ∪ V(Q)` (`attainedTwice_mul_iff`, `tropicalHypersurface_mul`), together with a
ternary generalization and the monomial boundary case. It sits between the catalog's two existing
halves of tropical Bézout: the analytic min-plus multiplicativity `TropPoly.eval_mul`
(`TropicalValuationLimitBridge.lean`, "degrees add") and the numerical intersection count
`tropical_bezout_transverse_plane` (`Tropical/Bezout.lean`, "multiplicities multiply"). The
following directions push toward closing the loop into a single end-to-end tropical Bézout
theorem stated over `TropPoly`.

## 1. Finite-product decomposition by induction

Extend `tropicalHypersurface_mul3` to an arbitrary finite tropical product
`V(⊙ᵢ Pᵢ) = ⋃ᵢ V(Pᵢ)`. The natural carrier is an indexed family `P : Π a, TropPoly (κ a) n`
with `tropProd` folding `TropPoly.mul`, and the union over `a` of the factor hypersurfaces.
**The key insight is** that the argmin of a min-plus product is the *Cartesian product* of the
factor argmins (`prod_isGlobalMin_iff`), so a global minimiser is repeated iff some single factor
has a repeated minimiser — an invariant that survives any associative fold.
**Why now?** The binary and ternary cases are already mechanized and the argmin-factoring lemma is
fully general; only a `Finset.prod`-style induction wrapper and the right dependent index
bookkeeping remain, which is routine given the proven base case.

## 2. Newton-polytope additivity from `eval_mul`

Define the (sub)gradient/Newton-polytope support of a `TropPoly` as the set of exponent vectors
that are active (attain the min) somewhere, and prove `Newt(P ⊙ Q) = Newt(P) + Newt(Q)`
(Minkowski sum). **The key insight is** that `TropPoly.eval_mul` already shows the tropical value
is additive, so the active monomials of the product are exactly sums of active monomials of the
factors — the same Cartesian-product-of-argmins phenomenon, now read on exponents rather than
indices. **Why now?** `Tropical/Bezout.lean` proves `minkowskiSum (degreeSimplex d₁)
(degreeSimplex d₂) = degreeSimplex (d₁+d₂)` for the lattice model; bridging that combinatorial
fact to the analytic `eval_mul` model would unify the two Bézout files under one Newton-polytope
API.

## 3. Multiplicity = local branch count at a corner

Attach to each point `x ∈ V(P)` the cardinality of its argmin set minus one (the local "corner
multiplicity") and show it is additive under products: the product multiplicity at `x` equals the
sum of factor multiplicities. **The key insight is** that `|argmin(P ⊙ Q)| = |argmin P| · |argmin
Q|`, so taking `log`/counting branches turns the multiplicative argmin product into an additive
multiplicity, which is precisely how stable intersection numbers accumulate. **Why now?**
`prod_isGlobalMin_iff` already pins the argmin of the product to a Cartesian product, so the
cardinality identity is one `Fintype.card_prod` away; this is the missing pointwise link to
`totalStableIntersectionMultiplicity` in `Tropical/Bezout.lean`.

## 4. Kapranov surjectivity (hard direction) for the `TropPoly` model

The catalog has only the *easy* direction of the Fundamental Theorem
(`kapranov_easy_direction`: tropicalization ⊆ corner locus). Pursue the converse for the concrete
`TropPoly` model: every corner-locus point is the tropicalization of an actual root over a
suitable non-Archimedean field. **The key insight is** that a point of `V(P)` provides two
competing minimal monomials whose coefficients can be balanced by a Hensel/Newton-polygon lift,
producing a genuine root with the prescribed valuation. **Why now?** With `attainedTwice_mul_iff`
the corner locus is now a first-class, product-compatible object, so a constructive lift can be
built one factor at a time and assembled via the union decomposition rather than all at once.

## 5. Stable intersection of complementary-dimension hypersurfaces = degree product

Combine directions 1–3 into the full statement: for `n` tropical hypersurfaces in `ℝⁿ` in general
position, the stable intersection is finite and its weighted count equals the product of degrees,
recovering `tropical_bezout_transverse_plane` from the analytic `TropPoly` side. **The key insight
is** that union decomposition (this cycle) plus Newton-polytope additivity (direction 2) plus
multiplicity additivity (direction 3) together force the mixed-volume formula, since mixed volume
is the unique multilinear-symmetric valuation that is additive under Minkowski sums. **Why now?**
Each ingredient is independently within reach given the lemmas proven here, and Mathlib already
supplies the mixed-volume/`MixedArea` scaffolding used in `Tropical/Bezout.lean`, so the synthesis
is an assembly problem rather than a new theory.
