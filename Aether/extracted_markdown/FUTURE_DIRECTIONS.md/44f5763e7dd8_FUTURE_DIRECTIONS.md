# Future Directions: Composition Theory for Set-Local Distortion of Hausdorff Dimension

## Synthesis

This cycle deepened the set-local Hausdorff-dimension distortion theory begun in
`Geometry.FractalDimension` (cycle 7007fa32). That earlier file proved how a
*single* map that is Lipschitz / antilipschitz / Hölder *only on a subset* `s`
distorts Hausdorff dimension, culminating in a two-sided Hölder
("quasi-symmetric flavoured") estimate. The structural gap it left open was
**closure under composition**: fractals, IFS attractors and quasi-symmetric
conjugacies are all assembled by chaining good maps on nested pieces, so a
distortion calculus that does not compose is not yet usable. The key insight of
this cycle is that the set-local classes *do* compose, and that the distortion
**exponents are multiplicative under composition** — the dimension shadow of the
fact that snowflaking / Hölder conjugation composes.

Concretely we proved that the set-local antilipschitz predicate
`AntilipschitzOnWith` is closed under composition (constants multiply), under
restriction to subsets, and that global antilipschitz maps restrict to it. These
closure lemmas then upgrade the single-map invariance theorem to a *composite*
bi-Lipschitz invariance theorem, and — the headline result — to a composite
two-sided bi-Hölder distortion bound in which the four exponents combine as the
two products `rg·rf` and `rf'·rg'`. Setting all exponents to `1` recovers exact
composite invariance, confirming internal consistency.

Nothing was disproved this cycle; the main friction was bookkeeping
(`Set.image_comp` to identify `(g∘f)''s` with `g''(f''s)`, and the `MapsTo`
side-conditions for the two `HolderOnWith.comp` applications). The emergent
structural lesson is that the entire theory is *functorial in the set-local map*:
once the relevant class is shown closed under composition and restriction, the
dimension estimates lift mechanically. This points toward formalizing the
distortion data as an actual category or groupoid, which is the unifying thread
behind the directions below.

## Results Summary

- `AntilipschitzOnWith.comp`: proved — the set-local antilipschitz class is closed under composition with multiplied constants (the dual of `LipschitzOnWith.comp`).
- `AntilipschitzOnWith.mono`: proved — restriction of a set-local antilipschitz map to a subset stays antilipschitz with the same constant.
- `antilipschitzOnWith_of_antilipschitzWith`: proved — a globally antilipschitz map is antilipschitz on every subset.
- `dimH_image_comp_eq_of_lipschitzOn_antilipschitzOn`: proved — Hausdorff dimension is invariant under a composite of two set-local bi-Lipschitz maps.
- `dimH_image_comp_bounds_of_biholderOn`: proved — composite quasi-symmetric distortion: chaining two bi-Hölder maps multiplies the exponents, giving `dimH((g∘f)''s) ≤ dimH s/(rg·rf)` and `dimH s ≤ dimH((g∘f)''s)/(rf'·rg')`.

## Research Directions

### Direction 1: A category/groupoid of set-local bi-Hölder maps
**Hypothesis**: The set-local bi-Hölder maps form a category whose objects are
pairs `(X, s)` and whose morphisms carry the four-tuple of Hölder data
`(Cf, rf, Cf', rf')`; composition multiplies exponents and identities are the
exponent-`1`, constant-`1` maps. The Hausdorff-dimension distortion bound is a
*functor* from this category to the ordered monoid of dimension-ratio intervals.
**Test**: Formalize `Comp` and `id` instances, prove associativity of the
exponent/constant bookkeeping (already implicitly used) and a functoriality lemma
`distortion (g ∘ f) = distortion g ∘ distortion f`.
**Why now**: This cycle proved exactly the composition and identity laws such a
category requires; the remaining work is packaging, not new mathematics.
**If true**: Distortion estimates for arbitrarily long conjugacy chains become a
single `simp`-style computation in the morphism monoid.
**If false**: A failure of associativity would reveal a hidden asymmetry between
the forward and inverse exponents, sharpening our understanding of orientation in
quasi-symmetric distortion.

### Direction 2: Self-similar attractors via iterated composition
**Hypothesis**: If `f` is bi-Lipschitz on `s` with `f '' s ⊆ s`, then every iterate
`f^[n]` is bi-Lipschitz on `s` and `dimH (f^[n] '' s) = dimH s` for all `n`,
giving dimension invariance of the whole forward orbit and (under completeness) of
the attractor `⋂ₙ f^[n] '' s`.
**Test**: Induct on `n` using `dimH_image_comp_eq_of_lipschitzOn_antilipschitzOn`
for the step, then pass to the intersection with a monotone-limit argument.
**Why now**: The composite invariance theorem is precisely the induction step;
only the `f '' s ⊆ s` invariance hypothesis and the limit need adding.
**If true**: Yields a clean dimension-invariance statement for IFS-type attractors
built from a single contraction-like map.
**If false**: The break must occur at the intersection/limit, isolating where
finite invariance fails to pass to the infinite attractor.

### Direction 3: Quantitative quasi-symmetry ⇒ explicit Hölder exponents
**Hypothesis**: A genuinely η-quasi-symmetric embedding `f` of a doubling space,
with power-type control `η(t) = C·max(t^α, t^{1/α})`, is bi-Hölder on each bounded
piece with exponents expressible in `α` and the doubling constant, so that
`dimH_image_comp_bounds_of_biholderOn` applies with *computed* exponents.
**Test**: Define `QuasiSymmetricWith η f` in Lean, prove the local bi-Hölder bound
from power-type `η` plus doubling, and instantiate the composite distortion bound.
**Why now**: The composite Hölder machinery is now in place and waiting for an
input; the only missing layer is the η-to-Hölder bridge on doubling spaces.
**If true**: Closes the original conjecture that motivated this programme —
quantitative dimension distortion directly from the quasi-symmetry gauge `η`.
**If false**: Pinpoints the metric hypothesis (likely doubling) that quasi-symmetry
alone cannot supply, clarifying the boundary of the Hölder reduction.

### Direction 4: Sharpness of the product-exponent bound
**Hypothesis**: The bounds `dimH((g∘f)''s) ≤ dimH s/(rg·rf)` are *attained*:
there exist snowflake metrics and maps for which equality holds, so the
product-exponent constant cannot be improved.
**Test**: Construct, on a self-similar Cantor set, explicit Hölder maps realizing
prescribed exponents `rf, rg` and compute both sides; alternatively, the Critic
should attempt to *disprove* sharpness by finding a strictly better universal
bound.
**Why now**: We have the upper bound in hand and an exact-invariance corollary at
exponent `1`; testing equality at exponent `≠ 1` is the natural next probe.
**If true**: Certifies the theorem as optimal, not merely valid.
**If false**: A universal improvement would signal that Hölder exponents are not
the right invariant and that a finer (e.g. gauge-function) bound is available.

### Direction 5: From `dimH` to Hausdorff/Minkowski measure distortion
**Hypothesis**: The set-local Hölder maps not only bound dimension but also give
two-sided bounds on the `d`-dimensional Hausdorff *measure* `μH^d (f '' s)` in
terms of `μH^{d·rf}(s)`, with the same multiplicative behaviour under composition.
**Test**: Replace `dimH_image_le` by the underlying Hausdorff-measure estimate
(`HolderOnWith.hausdorffMeasure_image_le` or its set-local analogue) and re-run the
composition argument.
**Why now**: The dimension proofs already factor through Hausdorff-measure
inequalities, so the measure-level statements are one abstraction layer below what
we proved.
**If true**: Upgrades the whole theory from a dimension calculus to a measure
calculus, the natural setting for rectifiability and energy estimates.
**If false**: The obstruction would reveal that dimension invariance is strictly
coarser than measure comparability under set-local Hölder maps — itself a
structural discovery.
