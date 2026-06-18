# Future Directions: Certified Novelty — Filtrations, Depth Budgets, and Hausdorff Stability

## Synthesis

This cycle extended the *pointwise* novelty-certification framework of
`Catalog/Novelty/CertifiedNovelty.lean` along three orthogonal axes, each an instance
of the "duality & representation" program: replace a hard object by an easier dual one
and transport structure across the dictionary.

1. **Geometry of the certificate (point → region).** In `NoveltyRegions.lean` the
   continuous novelty score `noveltyScore S x = infDist x S` is represented by its
   strict super-level sets, the *novelty regions* `noveltyRegion S ε`. Continuity of
   the score becomes *openness* of the region (`noveltyRegion_isOpen`), and the
   threshold-indexed family is a decreasing filtration of open sets
   (`noveltyRegion_threshold_antitone`, `noveltyRegion_antitone_set`). The score
   doubles as the persistence **birth time**, so each point's barcode is the half-line
   `[0, birthTime S x)` (`mem_noveltyRegion_iff_lt_birthTime`). The new identity
   `noveltyRegion_eq_compl_cthickening` proves the region is *exactly* the complement of
   the closed Čech/offset thickening — tying novelty to persistent homology.

2. **Robustness under approximate maps (exact → approximate).** In
   `ApproxLipschitz.lean` we model real embeddings that satisfy Lipschitz/antilipschitz
   bounds only up to an additive error. We introduced `ApproxLipschitzWith K c` and
   `ApproxAntilipschitzWith K c`, showed the exact catalog theory is the `c = 0`
   fragment (`LipschitzWith.approxLipschitzWith`), and proved the compositional error
   law `(K₂,c₂) ∘ (K₁,c₁) = (K₂·K₁, K₂·c₁+c₂)` (`ApproxLipschitzWith.comp`). Iterating
   gives the **layer-budget theorem**: the depth-`n` iterate is
   `(Kⁿ, c·∑_{i<n}Kⁱ)`-approximately Lipschitz (`ApproxLipschitzWith.iterate`), with
   closed form `c·(Kⁿ−1)/(K−1)` (`ApproxLipschitzWith.iterate_error_closed`). The
   error-aware certificate transfer `approx_novel_transfer` deflates the threshold both
   multiplicatively (`/K`) and additively (`−c`).

3. **Set-level novelty (point → set via Hausdorff duality).** In `HausdorffNovelty.lean`
   each set becomes a *point* of the Hausdorff metric space `NonemptyCompacts β`, so
   every pointwise theorem casts a set-level shadow (`IsNovelSet`,
   `novelSet_triangle_transfer`, `isNovelSet_antitone_family`). We also proved the
   second-variable regularity `birthTime_lipschitz_reference`: the birth time is
   `1`-Lipschitz in the *reference set* under Hausdorff distance, the dual of the
   catalog's point-variable `noveltyScore_lipschitz`.

## Results Summary

| Theorem | File | Content |
|---|---|---|
| `noveltyRegion_isOpen` | `NoveltyRegions.lean` | Stability: certified-novel region is open |
| `noveltyRegion_threshold_antitone` | `NoveltyRegions.lean` | Decreasing filtration in the threshold |
| `noveltyRegion_antitone_set` | `NoveltyRegions.lean` | More knowledge ⇒ smaller region |
| `mem_noveltyRegion_iff_lt_birthTime` | `NoveltyRegions.lean` | Persistence barcode of a point |
| `noveltyRegion_subset_isNovel` | `NoveltyRegions.lean` | Bridge to the `IsNovel` predicate |
| `noveltyRegion_eq_compl_cthickening` | `NoveltyRegions.lean` | Region = complement of the Čech thickening |
| `ApproxLipschitzWith.comp` | `ApproxLipschitz.lean` | Affine error accumulation under composition |
| `ApproxLipschitzWith.iterate` | `ApproxLipschitz.lean` | Depth-`n` layer budget (geometric error) |
| `ApproxLipschitzWith.iterate_error_closed` | `ApproxLipschitz.lean` | Closed-form geometric error budget |
| `LipschitzWith.approxLipschitzWith` | `ApproxLipschitz.lean` | Exact theory ⊆ approximate theory |
| `approx_novel_transfer` | `ApproxLipschitz.lean` | Certificate transfer with multiplicative + additive deflation |
| `birthTime_lipschitz_reference` | `HausdorffNovelty.lean` | Birth time `1`-Lipschitz in the reference set |
| `novelSet_triangle_transfer` | `HausdorffNovelty.lean` | Set-level robustness via the Hausdorff triangle |
| `isNovelSet_antitone_family` | `HausdorffNovelty.lean` | Family antitonicity of set-level novelty |

All main results compile with zero `sorry` and depend only on
`propext`, `Classical.choice`, `Quot.sound`.

## Bold, Falsifiable Research Directions

### 1. Bottleneck stability of the full novelty barcode
Conjecture: the joint map `(S, x) ↦ birthTime S x` is `1`-Lipschitz in *each* argument
simultaneously, and consequently the entire novelty persistence diagram is
`1`-Lipschitz (in bottleneck distance) under joint perturbation of the knowledge base
`S` (Hausdorff) and the query distribution (sup metric):
`|birthTime S x − birthTime T y| ≤ hausdorffDist S T + dist x y`.
**The key insight is** that we have already separately proven Lipschitzness in the query
point (`noveltyScore_lipschitz`, catalog) and in the reference set
(`birthTime_lipschitz_reference`, this cycle); the joint bound is their triangle
composition, and bottleneck stability is then the standard interleaving consequence for
the *complement-of-thickening* filtration that `noveltyRegion_eq_compl_cthickening`
exhibits.
**Why now?** Both single-variable Lipschitz facts are formalized and discharged with
`linarith`; the joint statement is one more triangle inequality, and Mathlib's
`Metric.hausdorffDist`/`infDist` API already supplies every ingredient. This is the
theorem that upgrades "stability of one barcode endpoint" to "stability of the whole
persistence diagram".

### 2. The depth at which a certificate dies is `⌈log_K(1 + ε(K−1)/c)⌉`
Conjecture: for an `n`-fold composition of `(K, c)`-approximately-antilipschitz layers
with `K > 1`, the transferred novelty threshold `approx_novel_transfer` becomes vacuous
(`≤ 0`) exactly when `n ≥ log_K(1 + ε(K−1)/c)`, and this bound is *tight* — there is a
concrete layered embedding meeting it with equality.
**The key insight is** that `ApproxLipschitzWith.iterate_error_closed` already gives the
accumulated error in closed form `c·(Kⁿ−1)/(K−1)`, so "certificate survives depth `n`"
reduces to the single scalar inequality `c·(Kⁿ−1)/(K−1) < ε`, whose solution is the
stated logarithm — turning a structural question about deep networks into elementary
real analysis.
**Why now?** The closed form is proven; the remaining step is `Real.logb` monotonicity
plus `Real.rpow`/`pow` comparison lemmas, all present in Mathlib, and the tightness
witness is a one-dimensional affine map `x ↦ Kx + c`.

### 3. Novelty regions are open in the space of convex bodies
Conjecture: on `NonemptyCompacts β` for a proper space `β`, the *set-level* novelty
region `{A | ε < infDist A Fam}` is open, and (via Blaschke selection) the subspace of
convex bodies is proper, so the entire filtration/birth-time theory of `NoveltyRegions`
lifts verbatim from points to convex bodies.
**The key insight is** that `IsNovelSet` is literally the catalog `IsNovel` predicate in
the Hausdorff metric space `NonemptyCompacts β` — a fact this cycle made explicit — so
`noveltyRegion_isOpen` and `noveltyRegion_eq_compl_cthickening` should apply *unchanged*
once `noveltyScore`/`birthTime` are read in that base space; no new analysis is
required, only a change of carrier.
**Why now?** `birthTime_lipschitz_reference` and `novelSet_triangle_transfer` already
exhibit sets behaving as metric points, and Mathlib provides the `EMetricSpace`
instance on `NonemptyCompacts`; the only gap is instantiating the region theory at that
type, which the proofs in `NoveltyRegions.lean` are written generically enough to allow.

### 4. Capacity ⇔ emptiness of the novelty region
Conjecture: in a totally bounded space with `ε`-covering number `N(ε)`, a mutually
`ε`-separated reference set `S` has `|S| ≤ N(ε/2)`, and the novelty region
`noveltyRegion S ε` is nonempty **iff** the `ε`-packing `S` is not maximal.
**The key insight is** that the catalog's `separated_balls_pairwiseDisjoint` turns
separation into disjoint half-radius balls, while this cycle's filtration structure
makes "there is room for a new novel point" literally the statement
`(noveltyRegion S ε).Nonempty`; equating the two converts a counting/capacity bound
into a topological emptiness statement.
**Why now?** The disjoint-balls lemma already exists in the catalog and the novelty
region is now a first-class object with a complement-of-thickening description;
combining them with Mathlib's `TotallyBounded`/`Metric.exists_finset_cover` API yields
the counting inequality and the maximality equivalence directly.

### 5. The non-strict region is the complement of the open thickening
Conjecture: the *non-strict* novelty region `{x | ε ≤ infDist x S}` equals
`(Metric.thickening ε S)ᶜ` (for nonempty `S`), giving a clean order-theoretic dual
pairing: strict region ↔ complement of *closed* thickening (`cthickening`, proven this
cycle), non-strict region ↔ complement of *open* thickening (`thickening`). Together
they sandwich the boundary `{x | infDist x S = ε}`, the "death front" of the Čech
filtration.
**The key insight is** that `Metric.mem_thickening_iff_infDist_lt` is the open-ball
analogue of the `mem_cthickening_iff` step used in `noveltyRegion_eq_compl_cthickening`,
so the proof is the same `infDist` super-level computation with `<` replaced by `≤` and
`cthickening` by `thickening`.
**Why now?** The closed-thickening identity is already formalized and the only required
lemma (`mem_thickening_iff_infDist_lt`) is present in Mathlib; proving both identities
makes the novelty/Čech dictionary complete and lets persistent-homology results about
offset filtrations be re-imported as novelty statements with no further work.
