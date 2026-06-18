# Future Directions: The Novelty Frontier

`Catalog/Novelty/NoveltyFrontier.lean` closes four of the frontier directions opened by
`CertifiedNovelty.lean`: bi-Lipschitz faithfulness of the novelty score
(`noveltyScore_biLipschitz_window`, built from `noveltyScore_image_le_lipschitz` and
`noveltyScore_antilipschitz_le_image`), the ultrametric partition mechanism
(`ultrametric_close_equivalence`, `ultrametric_ball_eq_or_disjoint`), compositional
product novelty (`isNovel_prod_of_left` / `isNovel_prod_of_right`), and the
packing/covering duality of greedy nets (`maximal_separated_is_cover`).

The synthesis is a single principle: **a novelty certificate is monotone under the
geometry.** Either it survives a distance distortion with a controlled multiplicative
rescaling (the Lipschitz/antilipschitz window), or it is *forced* by a combinatorial
extremality condition (a maximal packing must cover). The ultrametric case is the
degenerate-distortion limit where the packing slack collapses to zero because balls
genuinely partition. These four results now form a connected skeleton: regularity →
transport → packing → covering. The next cycle should turn this skeleton into
*quantitative capacity* statements with explicit numbers.

## 1. Quantitative packing capacity via measure

Conjecture: in a finite-dimensional normed space with Haar measure `μ`, a mutually
`ε`-separated finite set `S` contained in a bounded region `B` satisfies
`S.card · μ(ball x (ε/2)) ≤ μ(thickening (ε/2) B)`, because
`separated_balls_pairwiseDisjoint` makes the half-radius balls a disjoint family whose
union sits inside the `ε/2`-thickening of `B`. Specializing to a radius-`R` Euclidean
ball gives the classical `card S ≤ (1 + 2R/ε)^d` ceiling.

**The key insight is** that the disjoint-ball lemma already in the catalog converts the
qualitative separation predicate into a disjoint union, so capacity becomes a single
application of measure additivity plus monotonicity — no new analysis, only
`measure_biUnion_finset` and `Measure.addHaar_ball`.

**Why now?** Both Mathlib ingredients (`MeasureTheory.measure_biUnion_finset` for
`PairwiseDisjoint` finite families and `Measure.addHaar_ball`) are mature, and the new
`maximal_separated_is_cover` supplies the matching lower bound for a two-sided estimate.

## 2. The greedy-net sandwich `M(S,2ε) ≤ N(S,ε) ≤ M(S,ε)`

`maximal_separated_is_cover` proves the covering half. Conjecture the full sandwich:
define packing number `M` and covering number `N` as `Finset` cardinalities, and show a
maximal `ε`-separated set is simultaneously an `ε`-cover (upper bound `N ≤ M(ε)`) while a
`2ε`-packing cannot exceed any `ε`-cover (lower bound `M(2ε) ≤ N`). This certifies greedy
novelty selection to within a factor of 2 of optimal.

**The key insight is** that maximality already gives covering for free (proven here), so
only the pigeonhole direction — two `2ε`-separated points cannot share an `ε`-ball of a
cover — remains, and that is a one-line triangle inequality.

**Why now?** With `maximal_separated_is_cover` done, the remaining inequality is finite
combinatorics over `Finset`s using total-boundedness API (`Metric.exists_finset_cover`),
not new metric theory.

## 3. Exact packing count in ultrametric spaces

`ultrametric_close_equivalence` and `ultrametric_ball_eq_or_disjoint` show ultrametric
balls partition. Conjecture the exact count: the maximal number of mutually `ε`-separated
points equals the number of distinct `ε`-balls (the index of the equivalence relation),
turning the Euclidean *upper bound* into an *equality*. Formally, `MutuallySeparated ε S`
is equivalent to the points lying in pairwise-distinct `ε`-balls, so packing number =
`Set.ncard` of the quotient.

**The key insight is** that the strong triangle inequality removes the curse-of-dimension
slack entirely: the relation is a genuine equivalence (already proven), so counting
packed points is literally counting equivalence classes.

**Why now?** The equivalence and partition lemmas are now in place; the count is a
`Quotient`/`Setoid` cardinality computation directly on top of them.

## 4. Pythagorean composition for L² product novelty

`isNovel_prod_of_left/right` handle the sup metric, where the aggregation is `max`.
Conjecture the refinement for the Euclidean (`WithLp 2`) product: the squared novelty
score is additive across factors, `noveltyScore² ≥ noveltyScore₁² + noveltyScore₂²` is
false in general but `IsNovel ε₁ S x₁` and `IsNovel ε₂ T x₂` together give
`IsNovel (√(ε₁²+ε₂²)) (S ×ˢ T) (x₁,x₂)` in `WithLp 2 (α × β)`. This is the tight,
quantitatively-composable certificate the sup metric lacks.

**The key insight is** that for the L² product the distance is `√(d₁²+d₂²)`, so component
certificates combine by the Pythagorean theorem rather than by `max`, yielding a strictly
stronger threshold whenever both factors contribute.

**Why now?** The `WithLp 2 (α × β)` / `EuclideanSpace` distance formula and
`Real.sqrt` monotonicity are in Mathlib, so the proof reduces to a square-root inequality
on top of the componentwise structure already established here.

## 5. Distortion-optimal embeddings preserve packing number

Combining `noveltyScore_biLipschitz_window` with direction 1, conjecture that a
bi-Lipschitz embedding `f` with distortion `K₁K₂` changes the packing number of any set by
at most the factor `(K₁K₂)^d` in dimension `d`: novelty-faithful embeddings are also
*capacity-faithful*. This bridges the regularity layer (transport) to the capacity layer
(packing/measure).

**The key insight is** that the multiplicative novelty window proven here rescales every
separation threshold by a factor in `[1/K₁, K₂]`, so a packing at scale `ε` maps to a
packing at a scale within that window, and the measure-capacity bound of direction 1
converts the scale change into a controlled cardinality change.

**Why now?** `noveltyScore_biLipschitz_window` is proven and direction 1 supplies the
capacity machinery; the composition is multiplicative bookkeeping, the natural capstone
unifying transport and packing.
