# Future Directions: Adaptive, Compositional, and Multi-Scale Novelty Certification

## Synthesis

This cycle extended the metric novelty-certification framework of
`Novelty/CertifiedNovelty.lean` into three new regimes, all in
`Novelty/AdaptiveNovelty.lean`. The unifying discovery is that the single regularity
fact `noveltyScore S = Metric.infDist · S` — already shown `1`-Lipschitz and antitone in
the corpus — is enough to drive *adaptive*, *compositional*, and *multi-scale* novelty
theory without any new analytic input. Three structural levers do all the work:

1. **`dist x x = 0`** ⟹ any positive threshold automatically rejects corpus members
   (soundness of `isNovel_pos_notMem`, `adaptive_threshold_separates`).
2. **`infDist` monotonicity / triangle geometry** ⟹ knowledge saturation: an `ε`-net
   collapses all scores below `ε` (`noveltyScore_le_of_isEpsNet`) and kills every
   threshold above `ε` (`not_isNovel_of_isEpsNet`), with an honest approximate converse
   (`isEpsNet_approx_of_noveltyScore_le`) — exactness fails only because `infDist` need
   not be attained.
3. **Lipschitz closure under `min` and projections** ⟹ compositional scores on products
   are `1`-Lipschitz (`compNovelty_lipschitz`), and anti-monotonicity in both parameters
   yields the bifiltration chain (`noveltySet_antitone_threshold`,
   `noveltySet_antitone_corpus`, `noveltySet_mono`).

## Results Summary

* `noveltyScore_le_of_isEpsNet`, `not_isNovel_of_isEpsNet` — knowledge saturation.
* `isEpsNet_approx_of_noveltyScore_le` — approximate converse (slack `η > 0`).
* `adaptive_threshold_separates` — separation-scaled threshold is exactly discriminating.
* `compNovelty_lipschitz`, `compNovelty_le_left/right` — compositional novelty.
* `noveltySet_antitone_threshold/corpus`, `noveltySet_mono` — the novelty bifiltration.

All main results compile with `sorry`-free proofs depending only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

## Direction 1 — Exact saturation on proper / compact spaces

Conjecture: if the ambient space is proper (closed balls compact) and the corpus `S` is
closed and nonempty, then `(∀ x, noveltyScore S x ≤ ε) ↔ IsEpsNet ε S` *exactly* — the
slack `η` in `isEpsNet_approx_of_noveltyScore_le` can be removed. The key insight is that
properness makes `Metric.infDist` *attained* (`IsClosed.exists_infDist_eq_dist`-style
results), turning the approximate witness into an exact net witness. Why now? We already
have both directions up to slack; only the attainment lemma is missing, and Mathlib's
`Metric.exists_dist_eq_infDist` / proper-space API supplies it. Falsifiable: exhibit a
proper closed corpus with `noveltyScore ≤ ε` everywhere but no exact `ε`-net.

## Direction 2 — Covering-number lower bounds from packing

Conjecture: in a totally bounded space, if `S` is mutually `σ`-separated then
`S.card ≤ (covering number at scale σ/2)`, fusing `separated_balls_pairwiseDisjoint` with
`adaptive_threshold_separates`. The key insight is that the adaptive threshold turns each
corpus element into the center of a disjoint `σ/2`-ball, so the corpus size is literally a
packing number, the Gilbert–Varshamov dual of a covering number. Why now? The disjoint-ball
lemma is already proved; Mathlib's `TotallyBounded` and `Metric.exists_finite_cover` give
the matching cover. Falsifiable: a separated corpus larger than the covering number.

## Direction 3 — Quantitative `n`-ary compositional novelty

Conjecture: the binary `compNovelty` generalizes to `Fin n → α` (or dependent
`Π i, α i`) with the score `⨅ i, noveltyScore (S i) (x i)` remaining `1`-Lipschitz in the
`ℓ^∞` product metric, and the bound is *tight* (some perturbation achieves it). The key
insight is that `LipschitzWith.min` iterates over `Finset.inf'`, and projections
`Π i, α i → α i` are each `1`-Lipschitz, so the binary proof is the base case of a finite
induction. Why now? `compNovelty_lipschitz` is exactly the `n = 2` instance, and Mathlib's
`Finset.inf'` Lipschitz API plus `Pi.pseudoMetricSpace` close the gap. Falsifiable: a
finite product on which the `n`-ary score is not `1`-Lipschitz.

## Direction 4 — Persistence stability of the novelty bifiltration

Conjecture: the map `corpus ↦ novelty bifiltration` is `1`-Lipschitz from the Hausdorff
distance on corpora to the interleaving (bottleneck) distance on the resulting
two-parameter persistence modules `δ ↦ noveltySet δ S`. The key insight is that
`noveltyScore_antitone` plus the `1`-Lipschitz score means a Hausdorff-`r` perturbation of
`S` shifts every birth/death threshold by at most `r`, which is precisely an `r`-interleaving.
Why now? The chain structure (`noveltySet_mono`) is in hand; only a lightweight encoding of
interleaving distance is needed, and the metric estimates are already proved. Falsifiable:
two corpora at Hausdorff distance `r` whose novelty filtrations are not `r`-interleaved.

## Direction 5 — Information-theoretic floor on novelty

Conjecture: for a uniform distribution on a finite `σ`-separated corpus, adding a point `x`
with `noveltyScore S x ≥ σ` increases the Shannon entropy of the (renormalized) corpus
distribution by at least `log(1 + 1/|S|)`, giving a Fano-type bridge between geometric and
information-theoretic novelty. The key insight is that a `σ`-novel point cannot collide with
any existing atom (`isNovel_pos_notMem`), so it is a genuinely new mass point, and entropy of
a uniform distribution is monotone and concave in the number of atoms. Why now? We now have
the collision-freeness lemma exactly; combining it with `Real.log` concavity and
`Finset.card` arithmetic is elementary. Falsifiable: a separated corpus where a `σ`-novel
addition raises entropy by strictly less than `log(1 + 1/|S|)`.
