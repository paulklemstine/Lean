# Future Directions: Certified Novelty — Regions, Filtrations, and Dual Representations

## Synthesis

This cycle extended the *pointwise* novelty-certification framework of
`Catalog/Novelty/CertifiedNovelty.lean` along three orthogonal axes, each realizing the
"duality & representation" program: replacing a hard object by an easier dual one and
transporting structure across the dictionary.

1. **Geometry of the certificate (point → region).** The continuous novelty score
   `noveltyScore S x = infDist x S` is represented by its strict super-level sets, the
   *novelty regions* `noveltyRegion S ε`. Continuity of the score becomes *openness* of
   the region (`noveltyRegion_isOpen`), and the threshold-indexed family is a decreasing
   filtration of open sets (`noveltyRegion_threshold_antitone`). The score doubles as the
   persistence **birth time**, so each point's "barcode" is the half-line
   `[0, birthTime S x)` (`mem_noveltyRegion_iff_lt_birthTime`).

2. **Robustness under approximate maps (exact → approximate).** Real embeddings only
   satisfy Lipschitz bounds up to an additive error. We introduced
   `ApproxLipschitzWith K c` / `ApproxAntilipschitzWith K c`, showed the exact theory is
   the `c = 0` fragment, and proved the compositional error law
   `(K₂, c₂) ∘ (K₁, c₁) = (K₂·K₁, K₂·c₁ + c₂)` (`ApproxLipschitzWith.comp`) and the
   error-aware certificate transfer `approx_novel_transfer`.

3. **Set-level novelty (point → set, via Hausdorff duality).** Viewing each set as a
   *point* of the Hausdorff metric space, every pointwise theorem casts a set-level
   shadow. We defined `IsNovelSet` and transported the triangle-robustness theorem to
   `novelSet_triangle_transfer`, with family antitonicity in `isNovelSet_antitone_family`.

## Results Summary

| Theorem | File | Content |
|---|---|---|
| `noveltyRegion_isOpen` | `NoveltyRegions.lean` | Stability: certified-novel region is open |
| `noveltyRegion_threshold_antitone` | `NoveltyRegions.lean` | Decreasing filtration in the threshold |
| `noveltyRegion_antitone_set` | `NoveltyRegions.lean` | More knowledge ⇒ smaller region |
| `mem_noveltyRegion_iff_lt_birthTime` | `NoveltyRegions.lean` | Persistent-novelty barcode |
| `noveltyRegion_subset_isNovel` | `NoveltyRegions.lean` | Bridge to the predicate framework |
| `ApproxLipschitzWith.comp` | `ApproxLipschitz.lean` | Affine error accumulation under composition |
| `approx_novel_transfer` | `ApproxLipschitz.lean` | Certificate transfer with multiplicative + additive deflation |
| `LipschitzWith.approxLipschitzWith` | `ApproxLipschitz.lean` | Exact theory ⊆ approximate theory |
| `novelSet_triangle_transfer` | `HausdorffNovelty.lean` | Set-level robustness via Hausdorff triangle |
| `isNovelSet_antitone_family` | `HausdorffNovelty.lean` | Family antitonicity of set-level novelty |

All main results compile with zero `sorry` and depend only on
`propext`, `Classical.choice`, `Quot.sound`.

## Bold, Falsifiable Research Directions

### 1. The novelty region is exactly the complement of an open thickening
Conjecture: `noveltyRegion S ε = (Metric.cthickening ε S)ᶜ` is **false** in general but the
non-strict variant `{x | ε < infDist x S} = (Metric.thickening ε S)ᶜ` holds, identifying
the novelty filtration with the *complement of the offset filtration* used in persistent
homology (the union-of-balls / Čech picture).
**The key insight is** that `infDist x S > ε` is precisely the statement that `x` escapes
every closed `ε`-ball around `S`, so the novelty barcode of a point is dual (order-reversed)
to the death time of the corresponding component in the Čech filtration.
**Why now?** Mathlib already has `Metric.thickening`, `Metric.cthickening`, and
`Metric.infDist_lt_iff`; the proof is a super-level-set computation that directly composes
with `noveltyRegion_isOpen` and `noveltyRegion_threshold_antitone` proven this cycle.

### 2. Layer-budget theorem for approximate embeddings
Conjecture: for an `n`-fold composition of `(K, c)`-approximately-Lipschitz layers, the
accumulated additive error is exactly `c · (K^{n} − 1)/(K − 1)` (for `K ≠ 1`), and the
transferred certificate becomes vacuous (threshold `≤ 0`) once
`n > log_K(1 + ε(K−1)/c)`.
**The key insight is** that `ApproxLipschitzWith.comp` iterates to a geometric series in the
error coordinate, so the certificate's survival is governed by a single closed-form
inequality — a concrete "depth budget" for certified embeddings.
**Why now?** The single-step composition law is already formalized; the iterate is a clean
induction over `Nat`, and `Finset.geom_sum_eq` supplies the closed form.

### 3. Hausdorff novelty regions are open in the space of compact sets
Conjecture: on the metric space of nonempty compact subsets of a proper space (with
`Metric.hausdorffDist`), the set-level novelty region
`{A | ε < infDist A Fam}` is open, and Blaschke selection makes this space proper, so the
filtration/birth-time theory of Direction 1 lifts verbatim to *convex bodies*.
**The key insight is** that `IsNovelSet` is literally the pointwise `IsNovel` predicate in
the Hausdorff metric space, so `noveltyRegion_isOpen` should apply once the compact-sets
metric instance is in scope — no new analysis, only a change of base space.
**Why now?** `novelSet_triangle_transfer` already exhibits sets behaving as metric points;
Mathlib's `EMetric`/`Metric` Hausdorff API plus `TopologicalSpace.NonemptyCompacts` give the
carrier, making the instance plumbing the only gap.

### 4. Quantitative packing/capacity bound from the filtration
Conjecture: in a space with finite `ε`-covering number `N(ε)`, any mutually `ε`-separated
reference set `S` satisfies `|S| ≤ N(ε/2)`, and the novelty region at threshold `ε` is
nonempty iff the `ε`-packing is not maximal.
**The key insight is** that `separated_balls_pairwiseDisjoint` (catalog) plus the filtration
structure proven here means "room for a new novel point" is equivalent to "the packing can
grow", turning capacity into a statement about emptiness of `noveltyRegion`.
**Why now?** The disjoint-balls lemma already exists in the catalog; combining it with
Mathlib's `Metric.exists_finset_cover`/totally-bounded API yields the counting bound
directly.

### 5. Lipschitz dependence of the birth time on the reference set
Conjecture: the map `S ↦ birthTime S x` is `1`-Lipschitz with respect to the Hausdorff
distance on reference sets: `|birthTime S x − birthTime T x| ≤ hausdorffDist S T`. Hence
small Hausdorff perturbations of the *knowledge base* move every barcode endpoint by at
most the perturbation — stability of the entire persistence diagram.
**The key insight is** that `birthTime = infDist x ·` and `infDist` is itself `1`-Lipschitz
in the set argument under Hausdorff distance, so this is the *second-variable* dual of the
already-proven `noveltyScore_lipschitz` (which is Lipschitz in the point).
**Why now?** This unifies the point-variable regularity (this cycle) with set-variable
regularity, and Mathlib's `Metric.infDist_le_infDist_add_hausdorffDist`-style lemmas make
it a short transport argument that immediately stabilizes Directions 1 and 3.
