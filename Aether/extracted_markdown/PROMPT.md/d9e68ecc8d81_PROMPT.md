
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: This cycle deepened the set-local Hausdorff-dimension distortion theory begun in
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Composition Theory for Set-Local Distortion of Hausdorff Dimension

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

**Concept description**: # Future Directions: Composition Theory for Set-Local Distortion of Hausdorff Dimension

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

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
