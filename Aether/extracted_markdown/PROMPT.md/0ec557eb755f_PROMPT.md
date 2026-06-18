
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

**Title**: `Applications/BoltzmannBridge/InterleavingGeodesic.lean` closes the
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Boltzmann Bridge IX: the Interleaving Metric is *Geodesic*

## Synthesis

`Applications/BoltzmannBridge/InterleavingGeodesic.lean` closes the
persistence-stability arc's metric story and opens its **homotopical** chapter.
The arc moved from a relational preorder (`BottleneckStability`, `Interleaved`),
to a pseudo-emetric (`InterleavingMetric`, `eInterleavingDist`), to a genuine
`EMetricSpace` with attained infimum (`InterleavingClosure`,
`eInterleavingDist_eq_zero_iff_eq`), to an exact isometry onto weight functions
under the sup-distance (`InterleavingIsometry`,
`eInterleavingDist_eq_weightSupEDist`).

Bridge IX adds the missing geometric layer: the space is not merely isometric to a
sup-space but is itself **geodesic**. Convex interpolation of weights,
`lerp F G t` with weight `(1−t)·F.weight + t·G.weight`, is a valid filtration for
`0 ≤ t ≤ 1`, gives a path from `F` (`lerp_zero`) to `G` (`lerp_one`), and the
interleaving distance varies *exactly linearly* along it
(`eInterleavingDist_lerp`: `d(lerp s, lerp t) = ofReal |s − t| · d(F, G)`), with the
midpoint bisecting the distance additively (`eInterleavingDist_midpoint`). This is
the first explicit **path of filtrations** in the catalog — a homotopy between data
shapes that realises the interleaving distance — and it is the natural launch point
for a full path-space / fundamental-groupoid treatment of persistence.

## Results summary

* `lerp`, `lerp_zero`, `lerp_one` — the convex-interpolation path of filtrations and
  its endpoints.
* `weight_lerp_sub` — pointwise weight gaps scale linearly: `|lerp s − lerp t| =
  |s − t| · |F − G|`.
* `weightSupEDist_lerp` — the sup-distance is linear along the path.
* `eInterleavingDist_lerp` — **the constant-speed geodesic identity** (built on
  Bridge VIII's `eInterleavingDist_eq_weightSupEDist`).
* `eInterleavingDist_lerp_left` — distance from the endpoint is `ofReal t · d(F, G)`.
* `eInterleavingDist_midpoint` — the midpoint bisects the distance additively.

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research directions

### Direction 1 — The path space of filtrations is contractible

Conjecture: for any basepoint `F₀ : Filtration α`, the map
`H : Filtration α × [0,1] → Filtration α`, `H(G, t) = lerp G F₀ t`, is a
*continuous* (indeed `1`-Lipschitz-in-`t`) contraction of `(Filtration α,
eInterleavingDist)` onto `F₀`, so the metric space is contractible and its
fundamental groupoid is trivial. Falsifiable: exhibit two paths between fixed
endpoints whose concatenation is not null-homotopic, or show `H` fails continuity at
some `(G, t)`.

The key insight is that the geodesic identity `eInterleavingDist_lerp` already gives
`d(H(G,t), H(G,t')) = ofReal|t−t'|·d(G,F₀)` and `d(H(G,t),H(G',t)) ≤ d(G,G')`
(by `1`-Lipschitzness of `lerp` in its endpoint, which follows from the same
`weight_lerp_sub` factorisation), so joint continuity is purely an
`ENNReal`-estimate the existing lemmas almost deliver.

Why now? Bridge IX has just produced the segment-geodesics and proved the linear
distance law; assembling them into a single straight-line homotopy is the immediate
next algebraic step, and it converts the *metric* result into a genuine *homotopy*
invariant (contractibility) that the engine's homotopy/path-space mandate targets.

### Direction 2 — Uniqueness fails: characterise *all* geodesics

Conjecture: a path `γ : [0,1] → Filtration α` from `F` to `G` is a (constant-speed)
geodesic for `eInterleavingDist` **iff** for every simplex `σ` the scalar path
`t ↦ γ(t).weight σ` stays monotonically between `F.weight σ` and `G.weight σ` and
the *sup* over `σ` of the gap travels at constant speed. In particular `lerp` is one
geodesic among a convex family, so the space is geodesic but **not uniquely
geodesic**. Falsifiable: produce a constant-speed geodesic that is *not* of this
pointwise-between form, or prove the `lerp` geodesic is the unique one.

The key insight is that `eInterleavingDist` is a `⨆` of per-simplex absolute-value
metrics, and on the real line `[a,b]` is uniquely geodesic while a *supremum* of
such intervals is highly non-uniquely geodesic — the slack in non-maximising
simplices is free to wander.

Why now? `weight_lerp_sub` isolates exactly the per-simplex contribution, so the
non-uniqueness can be tested by perturbing `lerp` on a single non-maximising simplex
and re-running `eInterleavingDist_lerp`'s `⨆`-argument — no new infrastructure
needed.

### Direction 3 — Geodesic convexity of the Vietoris–Rips locus

Conjecture: the image of the Vietoris–Rips functor `d ↦ diamFiltration d`
(`HigherPersistence`) is a *geodesically convex* subset of `(Filtration α,
eInterleavingDist)`: the `lerp` of two diameter-filtrations is again a
diameter-filtration of the linearly interpolated distance matrix `(1−t)d₁ + t d₂`,
provided that interpolation remains a pseudometric. Falsifiable: find `d₁, d₂` whose
midpoint diameter-filtration differs from `diamFiltration((d₁+d₂)/2)` at some
simplex.

The key insight is that the diameter weight is a *pointwise supremum* of edge
distances, and suprema commute with convex combinations only up to inequality — so
the conjecture pins down precisely when persistence interpolation is "geometric"
versus merely "combinatorial".

Why now? Bridge VIII flagged "realising the sup for the Vietoris–Rips functor" as
its open frontier; the geodesic `lerp` now gives the canonical interpolation to test
that realisation against, turning a vague frontier into a sharp commuting-square
question.

### Direction 4 — Curvature: the interleaving space is a geodesic `CAT(0)`–style sup-space

Conjecture: `(Filtration α, eInterleavingDist)` satisfies the *Busemann
non-positive curvature* inequality
`d(lerp F G ½, lerp F H ½) ≤ ½ · d(G, H)` (convexity of the metric along
`lerp`-geodesics), inherited from the sup-metric structure. It is, however, **not**
`CAT(0)` in general (sup-metrics are flat-but-cornered, like `ℓ^∞`). Falsifiable:
violate the Busemann inequality for some `F, G, H`, or conversely verify the
`CAT(0)` four-point condition and refute the `ℓ^∞`-analogy.

The key insight is that an `ℓ^∞`/sup-metric is Busemann-convex but not `CAT(0)`, and
Bridge VIII proved `eInterleavingDist` *is* such a sup-metric — so curvature bounds
transfer term-by-term through the same `⨆`-and-`mul_iSup` machinery used in
`weightSupEDist_lerp`.

Why now? The midpoint lemma `eInterleavingDist_midpoint` is the `F = G` instance of
the Busemann inequality; generalising one endpoint is the smallest possible step and
immediately yields a *curvature* statement, the deepest classification of a geodesic
space.

### Direction 5 — The geodesic identity characterises the sup-metric (rigidity)

Conjecture: among all translation-invariant metrics on weight functions
`Finset α → ℝ` for which every `lerp`-segment is a constant-speed geodesic with the
*same* per-simplex speeds, the sup-distance is the unique one realised by an
interleaving-type relation; i.e. `eInterleavingDist` is *rigid* — the geodesic law
plus `1`-Lipschitz stability forces the formula
`eInterleavingDist_eq_weightSupEDist`. Falsifiable: construct a different metric
(e.g. an `ℓ^p` weight-distance, `p < ∞`) that also makes `lerp` geodesic yet arises
from a stability relation, contradicting uniqueness.

The key insight is that geodesy plus the linear speed law `eInterleavingDist_lerp`
encodes a functional equation on the metric, and on a sup-of-coordinates space only
the `ℓ^∞` norm solves it compatibly with the *one-edge* stability witnesses of
`stability_supDist`.

Why now? With the isometry (Bridge VIII) and the geodesic law (Bridge IX) both
formalised, the inverse problem — *which* metric is forced by these properties — is
now a precisely stated rigidity theorem rather than an informal expectation, and it
would crown the arc by characterising the interleaving distance uniquely.

**Concept description**: # Future Directions — Boltzmann Bridge IX: the Interleaving Metric is *Geodesic*

## Synthesis

`Applications/BoltzmannBridge/InterleavingGeodesic.lean` closes the
persistence-stability arc's metric story and opens its **homotopical** chapter.
The arc moved from a relational preorder (`BottleneckStability`, `Interleaved`),
to a pseudo-emetric (`InterleavingMetric`, `eInterleavingDist`), to a genuine
`EMetricSpace` with attained infimum (`InterleavingClosure`,
`eInterleavingDist_eq_zero_iff_eq`), to an exact isometry onto weight functions
under the sup-distance (`InterleavingIsometry`,
`eInterleavingDist_eq_weightSupEDist`).

Bridge IX adds the missing geometric layer: the space is not merely isometric to a
sup-space but is itself **geodesic**. Convex interpolation of weights,
`lerp F G t` with weight `(1−t)·F.weight + t·G.weight`, is a valid filtration for
`0 ≤ t ≤ 1`, gives a path from `F` (`lerp_zero`) to `G` (`lerp_one`), and the
interleaving distance varies *exactly linearly* along it
(`eInterleavingDist_lerp`: `d(lerp s, lerp t) = ofReal |s − t| · d(F, G)`), with the
midpoint bisecting the distance additively (`eInterleavingDist_midpoint`). This is
the first explicit **path of filtrations** in the catalog — a homotopy between data
shapes that realises the interleaving distance — and it is the natural launch point
for a full path-space / fundamental-groupoid treatment of persistence.

## Results summary

* `lerp`, `lerp_zero`, `lerp_one` — the convex-interpolation path of filtrations and
  its endpoints.
* `weight_lerp_sub` — pointwise weight gaps scale linearly: `|lerp s − lerp t| =
  |s − t| · |F − G|`.
* `weightSupEDist_lerp` — the sup-distance is linear along the path.
* `eInterleavingDist_lerp` — **the constant-speed geodesic identity** (built on
  Bridge VIII's `eInterleavingDist_eq_weightSupEDist`).
* `eInterleavingDist_lerp_left` — distance from the endpoint is `ofReal t · d(F, G)`.
* `eInterleavingDist_midpoint` — the midpoint bisects the distance additively.

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research directions

### Direction 1 — The path space of filtrations is contractible

Conjecture: for any basepoint `F₀ : Filtration α`, the map
`H : Filtration α × [0,1] → Filtration α`, `H(G, t) = lerp G F₀ t`, is a
*continuous* (indeed `1`-Lipschitz-in-`t`) contraction of `(Filtration α,
eInterleavingDist)` onto `F₀`, so the metric space is contractible and its
fundamental groupoid is trivial. Falsifiable: exhibit two paths between fixed
endpoints whose concatenation is not null-homotopic, or show `H` fails continuity at
some `(G, t)`.

The key insight is that the geodesic identity `eInterleavingDist_lerp` already gives
`d(H(G,t), H(G,t')) = ofReal|t−t'|·d(G,F₀)` and `d(H(G,t),H(G',t)) ≤ d(G,G')`
(by `1`-Lipschitzness of `lerp` in its endpoint, which follows from the same
`weight_lerp_sub` factorisation), so joint continuity is purely an
`ENNReal`-estimate the existing lemmas almost deliver.

Why now? Bridge IX has just produced the segment-geodesics and proved the linear
distance law; assembling them into a single straight-line homotopy is the immediate
next algebraic step, and it converts the *metric* result into a genuine *homotopy*
invariant (contractibility) that the engine's homotopy/path-space mandate targets.

### Direction 2 — Uniqueness fails: characterise *all* geodesics

Conjecture: a path `γ : [0,1] → Filtration α` from `F` to `G` is a (constant-speed)
geodesic for `eInterleavingDist` **iff** for every simplex `σ` the scalar path
`t ↦ γ(t).weight σ` stays monotonically between `F.weight σ` and `G.weight σ` and
the *sup* over `σ` of the gap travels at constant speed. In particular `lerp` is one
geodesic among a convex family, so the space is geodesic but **not uniquely
geodesic**. Falsifiable: produce a constant-speed geodesic that is *not* of this
pointwise-between form, or prove the `lerp` geodesic is the unique one.

The key insight is that `eInterleavingDist` is a `⨆` of per-simplex absolute-value
metrics, and on the real line `[a,b]` is uniquely geodesic while a *supremum* of
such intervals is highly non-uniquely geodesic — the slack in non-maximising
simplices is free to wander.

Why now? `weight_lerp_sub` isolates exactly the per-simplex contribution, so the
non-uniqueness can be tested by perturbing `lerp` on a single non-maximising simplex
and re-running `eInterleavingDist_lerp`'s `⨆`-argument — no new infrastructure
needed.

### Direction 3 — Geodesic convexity of the Vietoris–Rips locus

Conjecture: the image of the Vietoris–Rips functor `d ↦ diamFiltration d`
(`HigherPersistence`) is a *geodesically convex* subset of `(Filtration α,
eInterleavingDist)`: the `lerp` of two diameter-filtrations is again a
diameter-filtration of the linearly interpolated distance matrix `(1−t)d₁ + t d₂`,
provided that interpolation remains a pseudometric. Falsifiable: find `d₁, d₂` whose
midpoint diameter-filtration differs from `diamFiltration((d₁+d₂)/2)` at some
simplex.

The key insight is that the diameter weight is a *pointwise supremum* of edge
distances, and suprema commute with convex combinations only up to inequality — so
the conjecture pins down precisely when persistence interpolation is "geometric"
versus merely "combinatorial".

Why now? Bridge VIII flagged "realising the sup for the Vietoris–Rips functor" as
its open frontier; the geodesic `lerp` now gives the canonical interpolation to test
that realisation against, turning a vague frontier into a sharp commuting-square
question.

### Direction 4 — Curvature: the interleaving space is a geodesic `CAT(0)`–style sup-space

Conjecture: `(Filtration α, eInterleavingDist)` satisfies the *Busemann
non-positive curvature* inequality
`d(lerp F G ½, lerp F H ½) ≤ ½ · d(G, H)` (convexity of the metric along
`lerp`-geodesics), inherited from the sup-metric structure. It is, however, **not**
`CAT(0)` in general (sup-metrics are flat-but-cornered, like `ℓ^∞`). Falsifiable:
violate the Busemann inequality for some `F, G, H`, or conversely verify the
`CAT(0)` four-point condition and refute the `ℓ^∞`-analogy.

The key insight is that an `ℓ^∞`/sup-metric is Busemann-convex but not `CAT(0)`, and
Bridge VIII proved `eInterleavingDist` *is* such a sup-metric — so curvature bounds
transfer term-by-term through the same `⨆`-and-`mul_iSup` machinery used in
`weightSupEDist_lerp`.

Why now? The midpoint lemma `eInterleavingDist_midpoint` is the `F = G` instance of
the Busemann inequality; generalising one endpoint is the smallest possible step and
immediately yields a *curvature* statement, the deepest classification of a geodesic
space.

### Direction 5 — The geodesic identity characterises the sup-metric (rigidity)

Conjecture: among all translation-invariant metrics on weight functions
`Finset α → ℝ` for which every `lerp`-segment is a constant-speed geodesic with the
*same* per-simplex speeds, the sup-distance is the unique one realised by an
interleaving-type relation; i.e. `eInterleavingDist` is *rigid* — the geodesic law
plus `1`-Lipschitz stability forces the formula
`eInterleavingDist_eq_weightSupEDist`. Falsifiable: construct a different metric
(e.g. an `ℓ^p` weight-distance, `p < ∞`) that also makes `lerp` geodesic yet arises
from a stability relation, contradicting uniqueness.

The key insight is that geodesy plus the linear speed law `eInterleavingDist_lerp`
encodes a functional equation on the metric, and on a sup-of-coordinates space only
the `ℓ^∞` norm solves it compatibly with the *one-edge* stability witnesses of
`stability_supDist`.

Why now? With the isometry (Bridge VIII) and the geodesic law (Bridge IX) both
formalised, the inverse problem — *which* metric is forced by these properties — is
now a precisely stated rigidity theorem rather than an informal expectation, and it
would crown the arc by characterising the interleaving distance uniquely.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
