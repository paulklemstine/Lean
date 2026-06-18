# Future Directions: Certified Novelty Detection in Metric Spaces

## Synthesis

This cycle extended the qualitative novelty framework of `Catalog/Novelty/CertifiedNovelty.lean`
(the predicate `IsNovel ε S x := ∀ s ∈ S, ε ≤ dist x s` and the `infDist`-based score
`noveltyScore`) along three of the five directions sketched there, and discovered a fourth
phenomenon — *exact* novelty stability — that the original sketch did not anticipate.

Two new files were added, both in the `CertifiedNovelty` namespace so they compose with the
existing catalog API:

* **`Catalog/Novelty/NoveltyTransport.lean`** — a *computable* novelty score over finite
  reference sets (`noveltyScoreFinset = Finset.inf' (dist x ·)`), proven to (a) characterize
  `IsNovel` exactly (`isNovel_iff_le_noveltyScoreFinset`) and (b) coincide with the abstract
  `infDist` score (`noveltyScoreFinset_eq_noveltyScore`); the *reflection* half of bi-Lipschitz
  transport (`novel_reflect_lipschitz`) which complements the catalog's antilipschitz *push*
  to give two-sided faithfulness (`novel_biLipschitz_sandwich`); and *compositional* novelty
  in product (sup-metric) spaces (`novel_prod_of_left`, `novel_prod_of_right`).

* **`Catalog/Novelty/UltrametricNovelty.lean`** — the hierarchical/ultrametric specialization:
  transitivity of `ε`-closeness (`ultrametric_close_trans`), *exact* novelty stability under
  sub-threshold perturbations (`novel_ultrametric_stable`) which strictly sharpens the catalog's
  graceful-degradation `novel_triangle_transfer`, novelty being constant on each `ε`-ball
  (`novel_ultrametric_constant_on_ball`), and exact full-radius packing of separated sets
  (`mutuallySeparated_ultrametric_pairwise`).

The cross-domain bridge this cycle exposes: the *same* `IsNovel` predicate determines two
different reals (the `Finset.inf'` minimum and the `infDist` infimum), and a real number is
fixed by which thresholds it dominates — so the bridge `noveltyScoreFinset_eq_noveltyScore`
needs no infimum-API at all, only the shared characterization theorems. This "characterize,
don't compute" pattern is reusable across the catalog wherever an abstract quantity and a
concrete witness obey the same order-theoretic predicate.

## Results Summary

| Theorem | Statement | Sharpens / builds on |
| --- | --- | --- |
| `isNovel_iff_le_noveltyScoreFinset` | finite novelty ⇔ explicit min ≥ ε | `isNovel_iff_le_noveltyScore` |
| `noveltyScoreFinset_eq_noveltyScore` | explicit min = `infDist` score | both characterizations |
| `novel_reflect_lipschitz` | Lipschitz maps reflect novelty (`ε/K`) | `novel_transport_lipschitz_le` |
| `novel_biLipschitz_sandwich` | two-sided faithful transport | `novel_transport_antilipschitz` |
| `novel_prod_of_left/right` | one novel component ⇒ novel pair | `Prod.dist_eq` |
| `ultrametric_close_trans` | `ε`-closeness transitive | `dist_triangle_max` |
| `novel_ultrametric_stable` | sub-threshold perturbation costs nothing | `novel_triangle_transfer` |
| `novel_ultrametric_constant_on_ball` | novelty constant on `ε`-balls | `novel_ultrametric_stable` |
| `mutuallySeparated_ultrametric_pairwise` | exact full-radius packing | `separated_balls_pairwiseDisjoint` |

All nine results compile with `sorry`-count 0 and depend only on
`propext, Classical.choice, Quot.sound`.

## Direction 1 — Quantitative cardinality bounds from packing

The catalog gives pairwise-disjoint balls from separation; this cycle adds *exact* full-radius
disjointness in the ultrametric case. The missing quantitative step is a genuine *cardinality*
theorem: a mutually `ε`-separated subset of a bounded region has at most `(2R/ε + 1)^d` (resp.
an exact tree-node count in the ultrametric case) elements.

**The key insight is** that disjoint clopen `ε`-balls inside a totally bounded set can be
injected into a finite `ε`-net, so the packing number is finite and bounded by the covering
number — the classical sandwich `M(S, 2ε) ≤ N(S, ε) ≤ M(S, ε)` made effective.

**Why now?** With `mutuallySeparated_ultrametric_pairwise` we already have honest disjointness;
Mathlib's `TotallyBounded`, `Metric.finite_approx`, and `Set.Finite` cardinality API close the
gap without needing measure theory. The ultrametric case is even cleaner: the balls partition,
so the count is literally the number of distinct `ε`-balls met.

## Direction 2 — A bona fide `Setoid`/quotient for ultrametric clustering

`ultrametric_close_trans` is the transitivity half of an equivalence relation. Package
"within `ε`" as a `Setoid α` (reflexivity and symmetry are immediate) and identify its quotient
with the set of `ε`-balls, then show `noveltyScore`/`IsNovel` descend to the quotient.

**The key insight is** that hierarchical novelty is *literally* a quotient construction: novelty
is a well-defined function on `α / (within-ε)`, so certifying novelty reduces to certifying it on
representatives — one check per cluster instead of one per point.

**Why now?** `novel_ultrametric_constant_on_ball` already proves the descent property (novelty is
constant on classes); turning it into `Quotient.lift` is mechanical, and Mathlib's `Setoid`/`Quotient`
API is mature. This would connect the metric file to the catalog's order/lattice material.

## Direction 3 — Sharp threshold rescaling and tightness of the bi-Lipschitz sandwich

`novel_biLipschitz_sandwich` rescales thresholds by `1/K₂` and `1/K₁`. Prove these constants are
*sharp*: exhibit, for each `K`, a map and a configuration where the `ε/K` threshold is attained,
and conversely that no larger transported threshold is provable.

**The key insight is** that the antilipschitz and Lipschitz bounds are simultaneously tight exactly
on the extremal pairs realizing the constants, so the sandwich collapses to an equality
`noveltyScore (f '' S) (f x) = K · noveltyScore S x` precisely for *similarities* (where `K₁ = K₂`).

**Why now?** The forward/backward inequalities are already formalized; tightness is a matter of
constructing scaling maps on `ℝ` or `EuclideanSpace`, for which `LipschitzWith`/`AntilipschitzWith`
witnesses are explicit and computable.

## Direction 4 — Compositional novelty in the L² (and `Pi`) product, with a Pythagorean law

This cycle proved the sufficient, one-component direction for the *sup* metric. The original sketch
asked for the L² law `ε² ≤ ε₁² + ε₂²`. Formalize novelty in `WithLp 2 (α × β)` and the finite
`PiLp 2` product, and prove the Pythagorean aggregation of component novelty scores.

**The key insight is** that under the L² metric component novelty scores combine in quadrature, so
the total novelty certificate is the Euclidean norm of the per-component certificates — giving
strictly more novelty than any single component, unlike the sup metric where one component dominates.

**Why now?** Mathlib's `WithLp`/`PiLp` instances and `EuclideanSpace.dist_eq` (sum-of-squares) make
the quadratic identity directly available; the sup-metric results here are the `p = ∞` endpoint of
the same family, so the two together would bracket the whole `Lᵖ` scale.

## Direction 5 — Decidable novelty certification over computable metrics

`noveltyScoreFinset` is an explicit `Finset.inf'`, hence effectively computable once `dist` is. Specialize
to a concrete computable metric (e.g. `ℚ`-valued distances, Hamming distance on `Fin n → Bool`, or
`p`-adic-style ultrametrics on finite strings) and provide a `Decidable (IsNovel ε S x)` instance plus
`#eval`-able novelty scores.

**The key insight is** that over a decidable metric the qualitative predicate `IsNovel` becomes a
`decide`-able proposition and the score becomes a runnable function, turning certified novelty detection
into an executable algorithm with a machine-checked correctness proof.

**Why now?** `isNovel_iff_le_noveltyScoreFinset` already reduces the `∀ s ∈ S` predicate to a single
numeric comparison against `Finset.inf'`; combined with a `DecidableEq`/`LinearOrder` on a concrete
value type this yields decidability essentially for free, bridging the metric framework to the catalog's
computation/decidability domain.
