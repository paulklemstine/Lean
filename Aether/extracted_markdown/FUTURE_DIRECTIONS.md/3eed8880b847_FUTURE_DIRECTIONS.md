# Future Directions: Tropical Bézout and the Valuation-Limit Bridge

This cycle extended `Bridges.AlgebraTropicalGeometry.TropicalValuationLimitBridge`
(home of `kapranov_easy_direction` and the min-plus multiplicativity engine
`TropPoly.eval_mul`) into the file `TropicalBezoutFactorization.lean`, which now
contains four cross-domain results connecting non-Archimedean valuations,
corner loci, and tropical intersection theory:

- `attainedTwice_smul` — the corner locus is invariant under positive rescaling
  of the weights, the precise "valuation → ∞" limit statement;
- `tropRoot_mul_iff` / `tropRootSet_mul` — the tropical hypersurface of a product
  is the union of the factors' hypersurfaces, `V(P ⊙ Q) = V(P) ∪ V(Q)`;
- `range_exp_mul` — Newton polytopes add as a Minkowski sum under tropical product.

Together with `eval_mul` (degrees add) these are exactly the two combinatorial
ingredients of tropical Bézout. The directions below push toward the full
intersection-number theorem and a tighter dictionary with classical geometry.

---

## Direction 1: From union-of-hypersurfaces to a counted intersection number

The factorization `V(P ⊙ Q) = V(P) ∪ V(Q)` is the *set-theoretic* skeleton of
tropical Bézout. The quantitative theorem counts stable intersection points of two
tropical curves of degrees `d` and `e` with multiplicity, and asserts the total is
exactly `d · e`. The natural next object is a `TropMultiplicity` assigning to each
transverse corner the lattice index `|det|` of the two edge directions, and a theorem
`∑ multiplicities = d * e` for generic translates.

**The key insight is** that `range_exp_mul` already proves the Newton polytopes
Minkowski-add, and the mixed volume of the summands is the Bézout number — so the
intersection count is a *volume* computation on the polytopes we have already
formalized, not a new geometric input. **Why now?** With `eval_mul`,
`range_exp_mul`, and `tropRoot_mul_iff` in place, the only missing piece is the
local multiplicity bookkeeping; Mathlib's `Finset`/lattice-determinant API makes the
`|det|` weights and a genericity (transversality) hypothesis directly expressible.

This is falsifiable: state it for two explicit tropical lines (`d = e = 1`) and check
the unique stable intersection has multiplicity `1`; a wrong multiplicity definition
will fail this base case immediately.

## Direction 2: The hard (converse) direction of the Fundamental Theorem

`kapranov_easy_direction` shows tropicalization lands in the corner locus. The
converse — every corner-locus point lifts to an actual point of the variety over the
valued field (the Kapranov/Speyer–Sturmfels theorem) — is the deep half and is not
yet formalized. A tractable first case is a single hypersurface defined by a binomial
or trinomial, where the lift is an explicit Newton–Puiseux / Hensel construction.

**The key insight is** that for the lift one only needs surjectivity of the value
group plus one application of Hensel's lemma per corner, both of which exist in
Mathlib (`Valuation`, `HenselianLocalRing`); the corner condition
`AttainedAtLeastTwice` is exactly the hypothesis that makes two leading terms cancel,
enabling the Hensel step. **Why now?** The `addValuation_sum_eq_of_unique_min`
"winner-takes-all" lemma from the bridge file is the obstruction analysis for the
lift — its *failure* (a tie) is precisely the corner, so the same lemma drives both
directions.

Falsifiable check: produce the lift for `x + y + 1` over the Puiseux series field and
verify its valuation hits a prescribed corner ray.

## Direction 3: Stable intersection as a genuine limit of the rescaled family

`attainedTwice_smul` proves the corner locus is fixed under `v ↦ t·v`. The stronger
dynamical statement is that the *amoeba* `Log_t(V)` of the classical variety converges
(Hausdorff) to the tropical variety as `t → ∞`, and that classical intersection
points limit onto stable tropical intersection points without count loss.

**The key insight is** that scale-invariance of the limit object (already proven)
means the limit, if it exists, *must* be the corner locus — so the remaining work is
purely an equicontinuity/compactness estimate on the family, not an identification of
the limit. **Why now?** Mathlib's `Filter.Tendsto`, `EMetric.hausdorffEdist`, and
`Bornology` machinery are mature enough to phrase Hausdorff convergence of compact
pieces, and the invariant target is pinned down, removing the usual hardest step.

Falsifiable check: for `V = {x + y = 1}` in `(ℂ^*)^2`, verify the rescaled amoebae
converge to the standard tropical line (a tripod) and that the corner count is stable.

## Direction 4: Functoriality — tropicalization as a semiring homomorphism out of valuations

`eval_mul` (product ↦ sum) and the additive `addValuation_sum_eq_of_unique_min`
(generic sum ↦ min) together say tropicalization is a *generic* min-plus semiring
homomorphism. The clean structural theorem is a bundled
`RingHom`-to-`TropicalSemiring`-flavored map that is exactly multiplicative and
*sub*additive, with equality on the open dense locus of unique minima.

**The key insight is** that the two bridge lemmas are the two semiring axioms of
this map (`map_mul` exact, `map_add` an inequality saturated generically), so
tropicalization is not an analogy but a literal lax morphism. **Why now?** Mathlib
already has `Tropical` and `AddValuation`; bundling the existing pointwise lemmas into
the morphism interface is mostly plumbing and unlocks transport of all
semiring-level facts for free.

Falsifiable check: the bundled map must satisfy `map_one` and `map_mul` definitionally
on `Tropical (WithTop Γ)`; any sign/convention error breaks `map_mul` on a 2-element
example.

## Direction 5: Higher-codimension factorization and the Bernstein–Kushnirenko bound

`tropRoot_mul_iff` factorizes a single product hypersurface. The codimension-`k`
analogue concerns the stable intersection of `k` tropical hypersurfaces, and the count
is governed by the *mixed volume* of the `k` Newton polytopes (tropical
Bernstein–Kushnirenko), generalizing Bézout's `d · e`.

**The key insight is** that `range_exp_mul` shows the relevant operation on Newton
polytopes is exactly Minkowski sum, and mixed volume is the unique multilinear
symmetric functional polarizing ordinary volume of Minkowski sums — so the whole
count is determined by the polytope additivity we have already proven. **Why now?**
Building mixed volume from `MeasureTheory.volume` on `Fin n → ℝ` plus the proven
Minkowski-sum law is self-contained and would give the first formalized
Bernstein–Kushnirenko bound, a genuinely new contribution to formalized algebraic
geometry.

Falsifiable check: in dimension `1` the mixed volume reduces to a sum of lengths and
must reproduce the `d · e` Bézout number of Direction 1; disagreement flags a wrong
normalization of mixed volume.
