# Future Directions: Certified Novelty Detection in Metric Spaces

The file `CertifiedNovelty.lean` establishes the quantitative core of metric novelty
certification: the predicate `IsNovel`, the continuous `noveltyScore = Metric.infDist`,
their equivalence (`isNovel_iff_le_noveltyScore`), regularity (1-Lipschitz, antitone),
two transport principles (`novel_triangle_transfer`, `novel_transport_antilipschitz`),
and the packing core (`separated_balls_pairwiseDisjoint`). The following five directions
extend this frontier; each is stated as a falsifiable conjecture with a concrete Lean
target.

## 1. Quantitative packing capacity from disjoint balls

Building directly on `separated_balls_pairwiseDisjoint`, conjecture that in a finite
volume / finite-measure setting the number of mutually `ε`-separated points in a region
`B` is bounded by `volume(B_{ε/2}) / volume(ball ε/2)`, and in `ℝ^d` specializes to
`(2R/ε + 1)^d` for a radius-`R` ball. The disjoint-ball lemma already supplies the
denominator; the numerator is a monotonicity-of-measure argument over the union.

**The key insight is** that `separated_balls_pairwiseDisjoint` converts mutual separation
into a disjoint union of equal-radius balls, so a single application of measure additivity
plus monotonicity turns the qualitative packing predicate into a hard cardinality ceiling
on how many "genuinely novel" outputs can coexist in a bounded region.

**Why now?** Mathlib's `MeasureTheory.measure_biUnion_finset` (for `PairwiseDisjoint`
finite families) and `Measure.addHaar_ball` in finite-dimensional normed spaces give both
ingredients; the proof is a finite sum bound rather than new analysis.

## 2. Exact packing in ultrametric spaces

Conjecture that when `[IsUltrametricDist α]`, the inequality in the packing bound becomes
an equality at the level of balls: every `ε`-ball is both open and closed, distinct
`ε`-balls are either equal or disjoint, and `MutuallySeparated ε` is *equivalent* to the
points lying in distinct `ε`-balls. Hence `separated_balls_pairwiseDisjoint` upgrades to a
biconditional and the packing count is exact, not merely an upper bound.

**The key insight is** that the strong triangle inequality makes "being within `ε`" an
equivalence relation, so the ball cover is a genuine partition and the curse-of-dimension
slack present in the Euclidean bound vanishes entirely.

**Why now?** Mathlib already has `IsUltrametricDist`, `IsUltrametricDist.ball_eq_of_mem`,
and the open/closed ball coincidence; the partition structure is one `Equivalence`
construction away from the existing API used in `CertifiedNovelty.lean`.

## 3. Bi-Lipschitz faithfulness of novelty embeddings

`novel_transport_antilipschitz` and `novel_transport_lipschitz_le` already give the two
one-sided bounds. Conjecture the packaged corollary: an `AntilipschitzWith K₁` /
`LipschitzWith K₂` (bi-Lipschitz) embedding `f` sends `ε`-novel points to points whose
exact novelty score lies in `[ε/K₁, K₂·(score)]`, so embeddings neither destroy real
novelty nor manufacture spurious novelty beyond the distortion factor `K₁K₂`.

**The key insight is** that distance distortion is two-sided exactly when the map is
bi-Lipschitz, so composing the contraction and expansion lemmas pins the transported
`noveltyScore` inside a multiplicative window whose width is the embedding's distortion.

**Why now?** Both directional lemmas are already proven in `CertifiedNovelty.lean`; the
remaining step is to combine them with `Metric.infDist` image bounds, for which Mathlib's
`AntilipschitzWith`/`LipschitzWith` interface is mature.

## 4. Compositional novelty for product feature spaces

For the sup-metric product `α × β`, conjecture `IsNovel ε (S₁ ×ˢ S₂) (x₁, x₂)` is
controlled componentwise: it holds whenever `IsNovel ε S₁ x₁` or (a dominance condition
on) `IsNovel ε S₂ x₂`, and conversely component novelty lower-bounds product novelty. For
the `WithLp 2` (Euclidean) product the Pythagorean refinement `ε² ≤ ε₁² + ε₂²` should give
a tight composable bound, enabling modular certification of structured objects.

**The key insight is** that `dist` on a metric product is a fixed aggregation (max for the
sup metric, `√(·²+·²)` for the L² metric) of component distances, so novelty in the
product is a pure algebraic combination of the component novelty scores.

**Why now?** Mathlib's `Prod.dist_eq` (sup form) and the `WithLp 2 (α × β)` /
`EuclideanSpace` distance formulas are available, so the componentwise inequalities reduce
to `max`/`Real.sqrt` monotonicity facts already in the library.

## 5. Greedy nets realize the packing bound

Conjecture an algorithmic converse: in a totally bounded space, a maximal mutually
`ε`-separated set (a greedy `ε`-net) is automatically an `ε`-covering, yielding the
classical sandwich `M(S, 2ε) ≤ N(S, ε) ≤ M(S, ε)` between packing number `M` and covering
number `N`. This makes `separated_balls_pairwiseDisjoint` the lower half of a two-sided
capacity estimate and certifies that greedy novelty selection is within a factor of 2 of
optimal.

**The key insight is** that maximality of a separated set forces every other point to be
within `ε` of it (else it could be added), so a packing that cannot be extended is exactly
a covering — the duality is a single maximality argument, not a new construction.

**Why now?** `Metric.exists_finset_cover` / total-boundedness API and `Finset` maximality
arguments are in Mathlib; combined with the disjoint-ball lemma here, the sandwich
inequality becomes a finite combinatorial proof.
