# Future Directions — A Tropical Ultrametric from p-adic Valuation Depth

## Synthesis

This cycle built a concrete, fully formal bridge from a *computational valuation
statistic* to *nonarchimedean geometry*. On the additive group of finitely supported
integer sequences `ι →₀ ℤ` we defined the valuation depth `seqDepth p x` as the
infimum over coordinates of `emultiplicity p (x i)` (the honest, overhead-free
non-archimedean analogue of the catalog's circuit-depth `vdepth_sum_le`), valued in
`ℕ∞`. Exponentiating the depth of differences, `d(x,y) = 2^{-depth(x-y)}`, yields a
genuine ultrametric: we proved the strong triangle inequality, translation invariance,
symmetry, the separation property for non-units, and a 1-Lipschitz stability principle
for every depth-nondecreasing additive endomorphism. The construction was packaged two
ways: into Mathlib's own `IsUltrametricDist` typeclass (via a phantom-tagged carrier
`PadicSeq p ι`), and into the catalog's `CategoricalTropicalUltrametric.TropicalValuationObject`
as the order-reversed `(min, +)` tropical semiring on `ℕ∞`. All main results are
`sorry`-free and depend only on `propext`, `Classical.choice`, and `Quot.sound`.

## Results Summary

- `seqDepth_zero`, `seqDepth_neg`, `seqDepth_add_ge` — depth is a tropical valuation.
- `expDepth_antitone`, `expDepth_min` — the order-reversing exponential turns `min` into `max`.
- `udist_self`, `udist_comm`, `udist_strong_triangle`, `udist_triangle`,
  `udist_translation`, `udist_eq_zero_iff` — a translation-invariant (pseudo)ultrametric,
  separating for `|p| ≠ 1`.
- `udist_one_lipschitz` — valuation-monotone additive maps are nonexpansive.
- `PadicSeq.instIsUltrametricDist` — Mathlib-native packaging.
- `tropDepthObj` + `seqDepth_tropical_subadditive` — catalog `TropicalValuationObject` packaging.

## Research Directions

### 1. Completeness of the p-adic sequence ultrametric

Conjecture: for `|p| ≥ 2` and a *finite* index type `ι`, the metric space
`PadicSeq p ι` (after promotion to a `PseudoMetricSpace`/`MetricSpace`) is complete,
and its completion for general `ι` is the space of formal `p`-adic sequences
`ι → ℤ_p` with the sup-of-coordinatewise valuation. The key insight is that
coordinatewise valuation depth makes Cauchy sequences *stabilize coordinate-by-coordinate*,
so completeness reduces to completeness of `ℤ_p` in each fixed coordinate plus the
finiteness of the support obstruction. Why now? We already have the strong triangle
inequality and `IsUltrametricDist` instance in hand, and Mathlib provides `PadicInt`
with its complete ultrametric, so the completion can be assembled functorially rather
than from first principles. Falsifiable: produce a Cauchy sequence in `PadicSeq p ℕ`
whose coordinatewise limits have infinite support, contradicting completeness in the
finitely-supported model.

### 2. The 1-Lipschitz principle characterizes valuation-monotone maps

Conjecture: an additive endomorphism `F : (ι →₀ ℤ) →+ (ι →₀ ℤ)` is 1-Lipschitz for
`udist p` **iff** it does not decrease valuation depth, i.e. `udist_one_lipschitz`'s
hypothesis is not merely sufficient but necessary. The key insight is that the
exponential `expDepth` is a strictly-monotone bijection onto `{2^{-n}} ∪ {0}`, so a
metric contraction must reflect back to a depth inequality termwise via single-generator
test vectors `Finsupp.single i (p^k)`. Why now? The forward direction is already proved;
the converse needs only the explicit value `udist p (single i (p^k)) 0 = 2^{-k}`, which
follows from the depth API just built. Falsifiable: exhibit a 1-Lipschitz `F` and an
index `i` with `seqDepth p (F (single i 1)) < seqDepth p (single i 1)`.

### 3. Matrix actions and a spectral valuation-radius bound

Conjecture: for an integer matrix `M : Matrix ι ι ℤ` acting on `ι →₀ ℤ` (finite `ι`),
the induced map is 1-Lipschitz for `udist p` iff every entry of `M` is a `p`-adic
integer of nonnegative valuation, and more sharply the best Lipschitz constant equals
`2^{-(min entry valuation)}`. The key insight is that coordinatewise valuation depth
linearizes under matrix multiplication through `min_le_emultiplicity_add` and
`emultiplicity` of products, turning a spectral/operator-norm question into a tropical
min over matrix entries. Why now? The additive-hom Lipschitz theorem already covers the
"≤ 1" regime; extending the depth bookkeeping to bilinear (matrix) combinations is the
natural next lemma and connects directly to the catalog's expander/operator-norm files.
Falsifiable: find an integer matrix all of whose entries have nonnegative `p`-valuation
yet whose induced map strictly increases some `udist p` distance.

### 4. Functoriality: valuation depth as a functor to `TropObj`

Conjecture: the assignment `(ι →₀ ℤ) ↦ tropDepthObj` together with `seqDepth` extends to
a functor from the category of `ℤ`-valued finitely-supported sequence spaces (with
depth-nondecreasing additive maps) into the catalog's `TropObj`/`TropHom` category, and
this functor is faithful. The key insight is that `seqDepth_tropical_subadditive` is
exactly a `TropHom.map_add'`-shaped axiom once the order is reversed, so morphism data
transports for free. Why now? The `TropicalValuationObject` packaging `tropDepthObj` is
already built and the catalog supplies the full `TropHom` categorical scaffolding, so
only the morphism-mapping and composition laws remain. Falsifiable: discover two distinct
depth-nondecreasing additive maps inducing the same `TropHom`, breaking faithfulness.

### 5. Mixed-prime depth and an adelic ultrametric

Conjecture: combining the per-prime ultrametrics via `d(x,y) = ⨆ p prime, c_p · udist p x y`
(with summable weights `c_p`) yields a single ultrametric whose isometry group is exactly
the depth-preserving maps simultaneously at every prime, recovering an adelic flavour on
`ι →₀ ℤ`. The key insight is that an idempotent (sup/max) combination of ultrametrics is
again an ultrametric — the strong triangle inequality is preserved by `iSup` of nonexpansive
families — so the per-prime `udist_strong_triangle` lemmas combine without analytic input.
Why now? Each `udist p` is already a proven `IsUltrametricDist`, and Mathlib's
`IsUltrametricDist` is closed under suitable suprema, making the assembly a packaging
exercise rather than new hard analysis. Falsifiable: exhibit primes `p ≠ q` and points
where the `max`-combined distance violates the strong triangle inequality, which would
refute closure of ultrametrics under weighted suprema in this setting.
