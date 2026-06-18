# FUTURE_DIRECTIONS — Rips Filtrations ↔ Tropical Valuation Objects

Cycle output. This cycle formalized, in Lean 4 (0 sorries, only the standard
`propext`/`Classical.choice`/`Quot.sound` axioms), the Rips→Tropical functor and four of
the five mission conjectures:

* `Catalog/Bridges/RipsTropicalFunctor.lean` — the core dictionary
  (`simplexCount`, `tropBirthSum`, `tropMaxPlus`), the 1-skeleton bridge
  (`rips_complete_iff_tropBirthSum_le`, and its graph form
  `ripsGraph_eq_top_iff_tropBirthSum_le` stated with the catalog's actual `ripsGraph`),
  **Conjecture 3** (`tropBirthSum_eq_sInf_threshold`), and **Conjecture 4**
  (`tropBirthSum_isometry_invariant`, `simplexCount_isometry_invariant`).
* `Catalog/Bridges/RipsTropicalProducts.lean` — **Conjecture 2 (ℓ∞)**
  (`tropBirthSum_prod_linf`: `tropBirthSum (α × β) = max (tropBirthSum α) (tropBirthSum β)`).
* `Catalog/Bridges/RipsTropicalCliques.lean` — **Conjecture 5**
  (`cliqueCount_monotone`, `rips_kskeleton_complete_iff_tropBirthSum_le`: the *same*
  tropical scalar governs every dimension `k`).

The conjectures below are the bold, falsifiable next steps that these findings expose.

---

## Conjecture A (Connectivity threshold = tropical minimax / single-linkage)

For a finite pseudometric space `α` with `≥ 2` points, the **connectivity threshold**
`εc = sInf {ε | (ripsGraph α ε).Connected}` equals the **tropical minimax over spanning
trees**: `εc = ⊓_{T spanning tree} ⊔_{e ∈ T} dist e`, the bottleneck (largest edge of the
minimum spanning tree). For `{0,1,3,7} ⊂ ℝ`, `εc = 3` while `tropBirthSum = 7`.

* **The key insight is** that `tropBirthSum` (proved this cycle to be the *completeness*
  threshold via the `max` of all edges) and the *connectivity* threshold are two different
  tropical reductions of the **same** edge-weight data: completeness is `⊔` over all edges,
  connectivity is `⊓_T ⊔_{e∈T}` (min over spanning trees of the max edge). Proving Conjecture A
  exhibits both tropical operations (`max` and `min`-of-`max`) acting on one metric input,
  realizing single-linkage clustering inside the tropical semiring.
* **Why now?** We have a fully formal `tropBirthSum`/`ripsGraph` bridge and
  `ripsGraph_eq_top_iff_tropBirthSum_le`; the connectivity side reuses the identical
  `ripsGraph` filtration and `MetricFiltration` monotonicity, so the contrast is one
  spanning-tree lemma away from formalization.

## Conjecture B (`tropBirthSum` is exactly the metric diameter)

For a finite pseudometric space with `≥ 2` points,
`tropBirthSum α = ((Metric.diam (Set.univ : Set α) : ℝ) : WithBot ℝ)`.

* **The key insight is** that `tropBirthSum` — the `WithBot ℝ`-supremum over `univ.offDiag`
  of pairwise distances — adds only the diagonal `0`s to the diameter's supremum, so the two
  coincide whenever a distinct pair exists. Combined with this cycle's
  `tropBirthSum_isometry_invariant`, this would *identify* the tropical invariant with the
  single most classical isometry invariant, turning the abstract functor into a computable
  diameter.
* **Why now?** Isometry invariance is already proved; `Metric.diam` is the canonical
  isometry invariant, and the only formalization gap is the `WithBot ℝ ↔ ENNReal.toReal`
  bridge between `Finset.sup` and `Metric.diam`/`EMetric.diam`.

## Conjecture C (ℓ¹ products give tropical *multiplication*)

With the **ℓ¹** product metric `dist((a,b),(a',b')) = dist a a' + dist b b'` on `α × β`
(both nonempty, `≥ 2` points), `tropBirthSum (α × β) ≤ tropBirthSum α + tropBirthSum β`
(tropical *multiplication* `mul = +` of `tropMaxPlus`), with equality iff the two factor
diameters are realized on a common pair of coordinates.

* **The key insight is** that the catalog's "`add = max`, `mul = +`" dictionary becomes a
  *product law*: this cycle proved the ℓ∞ product realizes tropical addition
  (`= max`); the ℓ¹ product should realize tropical multiplication (`≤ +`). Together they
  make Rips→Tropical a **(lax) monoidal functor** under both monoidal structures on metric
  spaces.
* **Why now?** `tropBirthSum_prod_linf` is the exact ℓ∞ template; the ℓ¹ case needs only a
  custom product-metric instance and the elementary bound `max(x+y) ≤ max x + max y`
  (using `dist ≥ 0`), reusing the same `Finset.sup` machinery.

## Conjecture D (Dimension-uniform persistence barcode)

Define the persistent `H_k` "top bar" as the largest scale interval on which the full
`k`-skeleton appears. Then for every `1 ≤ k ≤ #α − 1`, that top bar **ends at the same
scale** `tropBirthSum α`, independent of `k`; equivalently the family
`k ↦ (scale at which `cliqueCount α k` saturates)` is constant on `[1, #α − 1]`.

* **The key insight is** that this cycle's `rips_kskeleton_complete_iff_tropBirthSum_le`
  already shows the saturation scale is `k`-independent at the *combinatorial* (clique-count)
  level; promoting it to the *homological* (barcode) level predicts that the entire
  Vietoris–Rips complex collapses to one tropical scalar simultaneously in all dimensions.
* **Why now?** The all-dimensions single-threshold law is proved combinatorially; the
  remaining step is to connect `cliqueCount` saturation to simplicial-complex/`H_k`
  vanishing, for which the catalog's `MetricFiltration` already supplies the filtration.

## Conjecture E (Full functoriality: identity, composition, lax bound)

`tropBirthSum` is a functor from the category of finite pseudometric spaces with
**1-Lipschitz surjections** to `(WithBot ℝ, ≤)`: it sends isometric bijections to equalities
(proved: `tropBirthSum_isometry_invariant`), identities to identities, and a composite of
1-Lipschitz surjections `g ∘ f` to a chained bound `tropBirthSum (codomain) ≤ tropBirthSum
(domain)` that factors through the intermediate space.

* **The key insight is** that this cycle upgraded one-sided functoriality to genuine
  *invariance* under isometry; the missing ingredient is the **composition law**, which
  makes `tropBirthSum` a bona fide functor rather than merely a monotone assignment, with
  `tropMaxPlus` as a strict codomain object.
* **Why now?** The isometry-invariance proof gives the identity/iso laws for free, and the
  product law (`tropBirthSum_prod_linf`) supplies the monoidal structure; only the 2-step
  contraction-composition corollary remains, a direct chaining of two `Finset.sup`
  inequalities.
