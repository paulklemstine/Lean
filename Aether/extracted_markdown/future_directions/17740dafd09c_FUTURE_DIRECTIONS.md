# Future Directions: Functoriality of the Valuation–Tropicalization Bridge

## Synthesis

This cycle took the *easy half* of the Fundamental Theorem of Tropical Geometry already in
`TropicalValuationLimitBridge.lean` (`kapranov_easy_direction`, the ultrametric winner-takes-all
lemma `addValuation_sum_eq_of_unique_min`, and min-plus multiplicativity `TropPoly.eval_mul`) and
turned three of its stated future directions into compiling Lean theorems. The unifying discovery
is that the corner-locus predicate `AttainedAtLeastTwice` is *functorial*: it is invariant under
positive rescaling of weights, and it interacts with the min-plus product exactly as a "support
of a sum-of-corners" should. Concretely, the minimiser set of a separated sum
`(i,k) ↦ f i + g k` is the **product** of the two minimiser sets, so the sum has a corner iff one
of the factors does. This single combinatorial fact (`attainedTwice_product_add_iff`) is the
pointwise engine behind both the slogan "tropicalize a product = add the tropicalizations"
(`TropPoly.eval_mul`, already in the catalog) and the geometric union law
`V(P ⊙ Q) = V(P) ∪ V(Q)` (`TropPoly.tropHypersurface_mul`, new here).

A second thread closed Direction 5: the valuation map is an *honest tropical morphism away from
ties*. We proved `v (x + y) = min (v x) (v y)` whenever `v x ≠ v y`
(`addValuation_add_eq_min_of_ne`), and packaged its contrapositive as
`addValuation_defect_imp_tie`: the locus where additivity fails is contained in the diagonal
`{v x = v y}`. This makes precise that the *same* tie coincidence that powers
`kapranov_easy_direction` (a minimum attained twice) is the *only* obstruction to `v` being a
strict min-plus semiring homomorphism. The additive and the corner-locus stories are one story.

What did not get formalized, and why: the *hard* direction of Kapranov (surjectivity onto the
corner locus) genuinely needs a lifting step (Newton polygon + Hensel) and remains a conjecture;
and the full tropical Bézout *count* needs to be glued to the catalog's `mixedLatticeIndex`
lattice arithmetic, which is a cross-file integration rather than a single lemma. Both are now
much closer: the union law removes the only analytic ingredient that was missing on the Bézout
side, and the scale-invariance lemma removes the only analytic ingredient that was missing on the
limit side.

## Results Summary

- `attainedTwice_smul_iff`: proved — the corner locus is invariant under positive rescaling of all
  weights, so the family `v_t = t·v` shares one fixed tropical shape (Direction 2 made algebraic).
- `attainedTwice_product_add_iff`: proved — a separated sum `f i + g k` has its minimum attained
  at least twice iff one of `f`, `g` does; the minimiser set of a sum is the product of minimiser
  sets.
- `TropPoly.termVal_mul`: proved — each monomial of a min-plus product splits as the sum of the
  corresponding monomials of the factors.
- `TropPoly.tropHypersurface_mul`: proved — the union law `V(P ⊙ Q) = V(P) ∪ V(Q)`, the analytic
  half of tropical Bézout.
- `addValuation_add_eq_min_of_ne`: proved — an additive valuation is exactly min-plus additive
  away from the tie set `{v x = v y}`.
- `addValuation_defect_imp_tie`: proved — the additive-defect locus of `v` is contained in the
  diagonal tie set, unifying "morphism defect" with "corner locus".

## Research Directions

### Direction 1: Bundle the valuation as a defect-controlled tropical morphism
**Hypothesis**: The pair (`AddValuation.map_mul`, `addValuation_add_eq_min_of_ne`) assembles into
a bundled structure `TropicalQuasiHom` carrying `map_mul` exactly and `map_add` as the inequality
`min (v x) (v y) ≤ v (x + y)` with equality off the explicit "defect set" `{(x,y) | v x = v y}`,
and every classical identity transports to a tropical (in)equality through it.
**Test**: Define the structure, instantiate it from any `AddValuation`, and prove that
`v (∏ xᵢ) = ∑ v xᵢ` and `min ≤ v (∑ xᵢ)` follow from the bundled fields alone (no re-derivation).
**Why now**: We have both halves as standalone lemmas; only the definitional wrapper is missing.
**If true**: A reusable transport mechanism — algebraic identities become tropical bounds for free
across the whole catalog.
**If false**: The defect set is not closed under the operations needed to bundle, revealing that
"morphism up to ties" is genuinely weaker than a quasimorphism.

### Direction 2: Multiplicity-aware union law and tropical Bézout end-to-end
**Hypothesis**: Refining `TropPoly.tropHypersurface_mul`, the *local multiplicity* of `V(P ⊙ Q)`
at a point `x` equals the sum of the multiplicities of `V(P)` and `V(Q)` at `x`, where
multiplicity is `(card of minimiser set) − 1`; summing this over a plane curve recovers
`deg P · deg Q` via the catalog's `mixedLatticeIndex`.
**Test**: Prove `(minimisers of (P⊙Q).termVal x) ≃ (minimisers P.termVal x) ×ˢ (minimisers
Q.termVal x)` as finsets, take cardinalities, and connect to `mixedLatticeIndex` in
`Tropical/Bezout.lean`.
**Why now**: `attainedTwice_product_add_iff` already proves the *set* version; upgrading "∃ two" to
"card of the product" is the natural strengthening and needs only `Finset.card_product`.
**If true**: The first end-to-end tropical Bézout in the catalog linking the analytic (min-plus)
and combinatorial (Newton-polytope) descriptions.
**If false**: Stable intersection requires a genericity perturbation that the naive count misses,
pinpointing exactly where transversality enters.

### Direction 3: Scale-invariance ⇒ the corner locus is the literal `t → ∞` limit
**Hypothesis**: Because `t • v` is again an `AddValuation` and `attainedTwice_smul_iff` shows the
corner locus is homothety-invariant, the normalized corner loci of the family `v_t = t·v` are
*equal as sets after rescaling by `1/t`*, hence trivially Hausdorff-convergent; the "limit" is the
fixed shape all members already share.
**Test**: Prove `tropHypersurface` of the `t`-rescaled tropical polynomial equals `t •`
(`tropHypersurface` of the original), then derive constancy of the normalized family.
**Why now**: `attainedTwice_smul_iff` is the exact invariance needed; the remaining step is the
equivariance of `termVal` under scaling coefficients and exponents.
**If true**: The slogan "tropicalization is the valuation-going-to-infinity limit" becomes a
one-line corollary rather than an analytic theorem.
**If false**: The coefficient and exponent scalings are not simultaneously homothetic, exposing a
genuine analytic deformation hiding behind the slogan.

### Direction 4: Kapranov's hard direction in the univariate case
**Hypothesis**: For `K` algebraically closed with a non-trivial divisible-value-group valuation,
every point of the corner locus of a univariate `trop(f)` (`Fin 1` variables) lifts to a root `p`
with `v p = w`, via the Newton polygon being the lower convex hull of `{(i, v cᵢ)}` plus Hensel.
**Test**: State the lift as the converse of `kapranov_easy_direction` for `n = 1`; reduce to
Mathlib's Hensel's lemma after building a `NewtonPolygon` predicate (a finite convex-hull object).
**Why now**: The easy direction and the winner-takes-all machinery are done; the missing glue is a
finite-combinatorial Newton-polygon predicate analogous to the already-proven `inf'_product_add`.
**If true**: Completes the Fundamental Theorem of Tropical Geometry in the univariate case inside
the catalog.
**If false**: The failure must occur at a tie of slopes (a vertical Newton segment), isolating the
precise combinatorial obstruction to lifting.

### Direction 5: Balancing condition from the tie set
**Hypothesis**: At a corner point of `V(P)`, the indices achieving the minimum (the tie set
produced by `kapranov_easy_direction`/`attainedTwice_product_add_iff`) span exponent differences
whose primitive directions, weighted by lattice length, sum to zero — the balancing condition.
**Test**: For `n = 2` and two-term ties, prove that the two primitive edge directions emanating
from a corner are negatives of each other (the simplest balancing instance), using the exponent
vectors of the tied monomials.
**Why now**: We can now *produce* the tie set explicitly and reason about its product structure;
balancing is the statement that this set's exponent fan is complete, a `Finset`-geometry claim.
**If true**: Balancing becomes the "conservation law" shadow of the tie phenomenon, available for
free from data we already extract.
**If false**: Balancing needs multiplicity weights beyond the bare tie set, showing that the
combinatorics of corners under-determines the metric geometry of the curve.
