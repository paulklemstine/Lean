
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

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

**Title**: The file `MirrorSymmetry/ArithmeticMirror.lean` formalizes a rigorous,
**Domain**: Geometry
**Mathematical framing**: # Future Directions: Arithmetic Mirror Symmetry

The file `MirrorSymmetry/ArithmeticMirror.lean` formalizes a rigorous,
self-contained skeleton of mirror symmetry: the Hodge-diamond mirror reflection
`p ↦ n - p`, the resulting Euler-characteristic relation `χ(Y) = (-1)^n χ(X)`
(specializing to `χ(Y) = -χ(X)` for threefolds), the combinatorial form of
*"rational curves on `X` ↔ rank of `Pic(Y)`"* via the `h^{1,1} ↔ h^{2,1}` swap,
and — on the arithmetic side — the Weil functional equation for the zeta function
of projective space, proved as a polynomial identity over an arbitrary
commutative ring. The following directions extend this nucleus toward genuine
arithmetic mirror symmetry.

## 1. Hodge symmetry and the full mirror diamond

The current `mirror` only reflects the first index `p ↦ n - p`. A Calabi–Yau
diamond also enjoys complex conjugation `h^{p,q} = h^{q,p}` and Serre duality
`h^{p,q} = h^{n-p,n-q}`. **Conjecture:** under the joint hypotheses of Hodge
symmetry and Serre duality, the mirror map composed with conjugation is an
involution that fixes the Euler characteristic up to the global sign `(-1)^n`,
and the diagonal Hodge numbers `h^{p,p}` of `Y` are a permutation of the
anti-diagonal `h^{p,n-p}` of `X`.

The key insight is that mirror symmetry is the *second* reflection symmetry of an
already doubly-symmetric diamond, so all three reflections (conjugation, Serre,
mirror) generate a finite reflection group acting on the diamond, and the Euler
characteristic is the unique (up to scale) alternating invariant of that group.

Why now? The Euler-characteristic machinery (`eulerChar_mirror`) is already in
place and only manipulates alternating sums under index reflection; adding the
two extra reflections is the same `Finset.sum_range_reflect` argument applied in
the second variable, so the proof obligations are immediate variations of what is
proved.

## 2. Stringy Hodge numbers and the topological mirror test

Batyrev–Dais stringy Hodge numbers `h^{p,q}_{st}` extend ordinary Hodge numbers
to singular and orbifold Calabi–Yau, and the *topological mirror symmetry test*
asserts `h^{p,q}_{st}(X) = h^{n-p,q}_{st}(Y)`. **Conjecture:** for a Hodge
diamond enriched with a `ℚ`-valued correction supported on a finite set of
"singular strata", the stringy Euler characteristic still satisfies
`χ_{st}(Y) = (-1)^n χ_{st}(X)`, and the correction terms cancel pairwise under
the mirror reflection.

The key insight is that the stringy invariant is again an alternating sum over a
reflection-symmetric index set, merely valued in `ℚ` rather than `ℤ`, so the sign
bookkeeping of `eulerChar_mirror` transfers verbatim once the summand type is
generalized from `ℤ` to a `CommRing`.

Why now? `eulerChar` is defined over `ℤ` but its proof uses only ring identities
and `sum_range_reflect`; generalizing the codomain to an arbitrary commutative
ring is a low-risk refactor that immediately unlocks the rational-valued stringy
setting.

## 3. Functional equation for products of projective spaces and hypersurfaces

`projectiveSpace_zeta_functional_equation` proves the Weil functional equation
for `ℙⁿ`. **Conjecture:** the zeta function of a product `ℙ^{n_1} × ⋯ × ℙ^{n_k}`
satisfies the functional equation with reflection exponent
`N = Σ n_i` and sign `(-1)^{Σ(n_i+1)}`, obtained as the product of the individual
functional equations; and for a degree-`d` Calabi–Yau hypersurface in `ℙ^{n+1}`
(`d = n + 2`) the *primitive* part of the zeta numerator is palindromic of even
weight `n`.

The key insight is that the functional equation is multiplicative for the zeta
function of a product (the reciprocal-root multiset is the Minkowski sum of the
factors' multisets), so the global identity factors through the single-factor
identity already proved.

Why now? The proved identity is stated over an arbitrary `CommRing` and is a pure
`Finset.prod` manipulation, so the product case is a `Finset.prod_mul_distrib`
away, and the palindromy of the primitive part reduces to the same
`prod_range_reflect` sign computation used in the base case.

## 4. Mirror congruences for point counts (Wan's theorem, toy form)

Wan's theorem on mirror symmetry for zeta functions predicts congruences between
the number of `𝔽_q`-points of a Calabi–Yau and its mirror. **Conjecture:** for
the combinatorial point-count model `N_m = Σ_{i=0}^n q^{im}` attached to `ℙⁿ` and
the mirror-reflected weights, the difference of point counts of a mirror pair is
divisible by `q - 1` for all `m`, and the quotient is itself a palindromic
polynomial in `q^m`.

The key insight is that `q - 1` divisibility is exactly the geometric-series
identity `(q^m - 1) · Σ_{i<n+1} (q^m)^i = (q^m)^{n+1} - 1`, so congruences between
mirror point counts reduce to congruences between *Hodge numbers* via the
already-proven Euler-characteristic exchange.

Why now? The geometric-series identity is one `Finset.geom_series` lemma away in
Mathlib, and `eulerChar_mirror` already provides the bridge from point-count
differences to Hodge-number differences; the only new ingredient is the explicit
divisibility, which `omega`/`Finset` arithmetic can discharge.

## 5. Modularity of the weight as a categorical shadow

The deepest prediction is that the zeta function of a rigid Calabi–Yau threefold
is modular of weight `4`. A fully rigorous formalization is far off, but a
*falsifiable shadow* is reachable: **Conjecture:** the reflection exponent
`N = n` and weight `w = n` extracted from `projectiveSpace_zeta_functional_equation`
satisfy `w = N`, and for a rigid CY threefold model (`h^{2,1} = 0`, so
`h^{1,1}` determined by `χ`) the functional-equation sign forced by
`eulerChar_mirror_threefold` is exactly the sign `+1` compatible with a weight-`4`
modular form's functional equation.

The key insight is that the *sign* of the Weil functional equation and the
*parity* of the Euler characteristic are the same `(-1)^{n}` datum, so the
"modularity-compatible sign" is not an extra hypothesis but a theorem of the
combinatorial model already built.

Why now? Both the sign of the functional equation
(`projectiveSpace_zeta_functional_equation`) and the threefold Euler sign
(`eulerChar_mirror_threefold`) are now formal theorems; equating them is a finite
sign check, giving the first machine-checked compatibility statement between the
arithmetic and Hodge-theoretic sides of mirror symmetry.

**Concept description**: # Future Directions: Arithmetic Mirror Symmetry

The file `MirrorSymmetry/ArithmeticMirror.lean` formalizes a rigorous,
self-contained skeleton of mirror symmetry: the Hodge-diamond mirror reflection
`p ↦ n - p`, the resulting Euler-characteristic relation `χ(Y) = (-1)^n χ(X)`
(specializing to `χ(Y) = -χ(X)` for threefolds), the combinatorial form of
*"rational curves on `X` ↔ rank of `Pic(Y)`"* via the `h^{1,1} ↔ h^{2,1}` swap,
and — on the arithmetic side — the Weil functional equation for the zeta function
of projective space, proved as a polynomial identity over an arbitrary
commutative ring. The following directions extend this nucleus toward genuine
arithmetic mirror symmetry.

## 1. Hodge symmetry and the full mirror diamond

The current `mirror` only reflects the first index `p ↦ n - p`. A Calabi–Yau
diamond also enjoys complex conjugation `h^{p,q} = h^{q,p}` and Serre duality
`h^{p,q} = h^{n-p,n-q}`. **Conjecture:** under the joint hypotheses of Hodge
symmetry and Serre duality, the mirror map composed with conjugation is an
involution that fixes the Euler characteristic up to the global sign `(-1)^n`,
and the diagonal Hodge numbers `h^{p,p}` of `Y` are a permutation of the
anti-diagonal `h^{p,n-p}` of `X`.

The key insight is that mirror symmetry is the *second* reflection symmetry of an
already doubly-symmetric diamond, so all three reflections (conjugation, Serre,
mirror) generate a finite reflection group acting on the diamond, and the Euler
characteristic is the unique (up to scale) alternating invariant of that group.

Why now? The Euler-characteristic machinery (`eulerChar_mirror`) is already in
place and only manipulates alternating sums under index reflection; adding the
two extra reflections is the same `Finset.sum_range_reflect` argument applied in
the second variable, so the proof obligations are immediate variations of what is
proved.

## 2. Stringy Hodge numbers and the topological mirror test

Batyrev–Dais stringy Hodge numbers `h^{p,q}_{st}` extend ordinary Hodge numbers
to singular and orbifold Calabi–Yau, and the *topological mirror symmetry test*
asserts `h^{p,q}_{st}(X) = h^{n-p,q}_{st}(Y)`. **Conjecture:** for a Hodge
diamond enriched with a `ℚ`-valued correction supported on a finite set of
"singular strata", the stringy Euler characteristic still satisfies
`χ_{st}(Y) = (-1)^n χ_{st}(X)`, and the correction terms cancel pairwise under
the mirror reflection.

The key insight is that the stringy invariant is again an alternating sum over a
reflection-symmetric index set, merely valued in `ℚ` rather than `ℤ`, so the sign
bookkeeping of `eulerChar_mirror` transfers verbatim once the summand type is
generalized from `ℤ` to a `CommRing`.

Why now? `eulerChar` is defined over `ℤ` but its proof uses only ring identities
and `sum_range_reflect`; generalizing the codomain to an arbitrary commutative
ring is a low-risk refactor that immediately unlocks the rational-valued stringy
setting.

## 3. Functional equation for products of projective spaces and hypersurfaces

`projectiveSpace_zeta_functional_equation` proves the Weil functional equation
for `ℙⁿ`. **Conjecture:** the zeta function of a product `ℙ^{n_1} × ⋯ × ℙ^{n_k}`
satisfies the functional equation with reflection exponent
`N = Σ n_i` and sign `(-1)^{Σ(n_i+1)}`, obtained as the product of the individual
functional equations; and for a degree-`d` Calabi–Yau hypersurface in `ℙ^{n+1}`
(`d = n + 2`) the *primitive* part of the zeta numerator is palindromic of even
weight `n`.

The key insight is that the functional equation is multiplicative for the zeta
function of a product (the reciprocal-root multiset is the Minkowski sum of the
factors' multisets), so the global identity factors through the single-factor
identity already proved.

Why now? The proved identity is stated over an arbitrary `CommRing` and is a pure
`Finset.prod` manipulation, so the product case is a `Finset.prod_mul_distrib`
away, and the palindromy of the primitive part reduces to the same
`prod_range_reflect` sign computation used in the base case.

## 4. Mirror congruences for point counts (Wan's theorem, toy form)

Wan's theorem on mirror symmetry for zeta functions predicts congruences between
the number of `𝔽_q`-points of a Calabi–Yau and its mirror. **Conjecture:** for
the combinatorial point-count model `N_m = Σ_{i=0}^n q^{im}` attached to `ℙⁿ` and
the mirror-reflected weights, the difference of point counts of a mirror pair is
divisible by `q - 1` for all `m`, and the quotient is itself a palindromic
polynomial in `q^m`.

The key insight is that `q - 1` divisibility is exactly the geometric-series
identity `(q^m - 1) · Σ_{i<n+1} (q^m)^i = (q^m)^{n+1} - 1`, so congruences between
mirror point counts reduce to congruences between *Hodge numbers* via the
already-proven Euler-characteristic exchange.

Why now? The geometric-series identity is one `Finset.geom_series` lemma away in
Mathlib, and `eulerChar_mirror` already provides the bridge from point-count
differences to Hodge-number differences; the only new ingredient is the explicit
divisibility, which `omega`/`Finset` arithmetic can discharge.

## 5. Modularity of the weight as a categorical shadow

The deepest prediction is that the zeta function of a rigid Calabi–Yau threefold
is modular of weight `4`. A fully rigorous formalization is far off, but a
*falsifiable shadow* is reachable: **Conjecture:** the reflection exponent
`N = n` and weight `w = n` extracted from `projectiveSpace_zeta_functional_equation`
satisfy `w = N`, and for a rigid CY threefold model (`h^{2,1} = 0`, so
`h^{1,1}` determined by `χ`) the functional-equation sign forced by
`eulerChar_mirror_threefold` is exactly the sign `+1` compatible with a weight-`4`
modular form's functional equation.

The key insight is that the *sign* of the Weil functional equation and the
*parity* of the Euler characteristic are the same `(-1)^{n}` datum, so the
"modularity-compatible sign" is not an extra hypothesis but a theorem of the
combinatorial model already built.

Why now? Both the sign of the functional equation
(`projectiveSpace_zeta_functional_equation`) and the threefold Euler sign
(`eulerChar_mirror_threefold`) are now formal theorems; equating them is a finite
sign check, giving the first machine-checked compatibility statement between the
arithmetic and Hodge-theoretic sides of mirror symmetry.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Geometry
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- Conceptual Unifier: Homotopy & Path Spaces Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Homotopy & Path Spaces)**. Explore topological paths, homotopical structures, and higher categorical localization (such as infinity-categories, model categories, and path spaces).

### RESEARCH CORE METHODOLOGY:
1. **Homotopy & Deformation**: Model mathematical structures and mappings up to continuous deformation or equivalence. Study path spaces, fundamental groupoids, and higher-dimensional homotopical invariants.
2. **Localization & Universality**: Define localizations that invert specific classes of morphisms, exposing the underlying universal homotopy properties of your mathematical structures.
3. **Higher Categorical Invariance**: Frame results through the lens of infinity-categories or model categories, ensuring definitions are invariant under homotopical equivalence.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
