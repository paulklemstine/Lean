
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

**Title**: `Catalog/Applications/BoltzmannBridge/InterleavingFunctor.lean` (Bridge IX)
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Boltzmann Bridge IX: The Persistence Functor and the Representation Theorem

## Synthesis

`Catalog/Applications/BoltzmannBridge/InterleavingFunctor.lean` (Bridge IX)
discharges **Future Directions 3 and 5** of Boltzmann Bridge VIII
(`InterleavingIsometry`) and, in doing so, turns the closed-form isometry of
Bridge VIII into *structural* statements about the whole space of filtrations.

Bridge VIII pinned the interleaving emetric to a sup-norm on weight functions:

> `eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ − G.weight σ|`.

Bridge IX exploits this in two complementary ways.

* **Functoriality (Direction 3).** A vertex map `f : α → β` pulls a filtration
  back, `(pullback f F).weight σ = F.weight (σ.image f)`, monotone because
  `Finset.image` is. This is a genuine contravariant functor (`pullback_id`,
  `pullback_comp`) and Bridge VIII makes it **1-Lipschitz**
  (`eInterleavingDist_pullback_le`, packaged as `pullback_lipschitzWith_one :
  LipschitzWith 1 (pullback f)`): the simplex-sup of pullback-weight gaps ranges
  over a *subset* of the simplex-sup of weight gaps, so the bound is monotonicity
  of `⨆` over a reindexing. When `f` is **surjective** the reindexing is itself
  surjective onto every simplex of `β`, upgrading the bound to an *equality*
  (`eInterleavingDist_pullback_eq_of_surjective`).

  This also **corrects** Bridge VIII's published narrative, which claimed equality
  for *injective* `f`. That is false — an injective `f : α → β` with `α` strictly
  smaller than `β` leaves simplices of `β` outside the image of `·.image f`, where
  the weights may differ arbitrarily, so the pullback distance can strictly
  undercut `eInterleavingDist F G`. The reindexing `σ ↦ σ.image f` is surjective
  (hence sup-preserving) exactly when `f` is surjective. Bridge IX proves the
  honest, surjective version.

* **Representation theorem (Direction 5).** Bridge VII's `ext_weight` showed
  `weight` is *injective*. The converse constructor `ofWeight` shows it is
  *surjective* onto the monotone, `∅`-grounded functions: every `w : Finset α → ℝ`
  with `w ∅ ≤ 0` and `Monotone w` is the weight of a unique filtration
  (`weight_surjective`). Packaged as the bijection `weightEquiv : Filtration α ≃
  {w // w ∅ ≤ 0 ∧ Monotone w}` and combined with Bridge VIII
  (`eInterleavingDist_ofWeight`), this **classifies** the persistence emetric: up
  to the explicit bijection, `(Filtration α, eInterleavingDist)` is nothing but the
  order interval of monotone, `∅`-grounded functions under the sup-emetric.

The methodological lesson of Bridge IX: once the metric is a sup-norm on
functions (Bridge VIII), every structural question — functoriality, isometry,
classification — collapses to elementary facts about `⨆` and `Finset.image`. The
closed form turns geometry into bookkeeping.

## Results Summary

All theorems in `InterleavingFunctor.lean` compile with `sorry`-count `0` and
depend only on `propext`, `Classical.choice`, `Quot.sound`.

| Theorem | Statement |
|---|---|
| `pullback` / `pullback_weight` | the pullback filtration along `f`, `(pullback f F).weight σ = F.weight (σ.image f)` |
| `pullback_id`, `pullback_comp` | the contravariant functor laws |
| `eInterleavingDist_pullback_le` | pullback is `1`-Lipschitz |
| `pullback_lipschitzWith_one` | `LipschitzWith 1 (pullback f)` (Mathlib short map) |
| `eInterleavingDist_pullback_eq_of_surjective` | pullback along a surjection is an isometry (corrected Direction 3) |
| `ofWeight` / `weight_surjective` | the converse constructor; `weight` is surjective |
| `weightEquiv` | the representation bijection `Filtration α ≃ {w // w ∅ ≤ 0 ∧ Monotone w}` |
| `eInterleavingDist_ofWeight` | the emetric in fully explicit weight-function form |

## Falsifiable Research Directions

### Direction 1 — Completeness of the representation: the constraint set is closed

**Conjecture.** Equip `{w : Finset α → ℝ // w ∅ ≤ 0 ∧ Monotone w}` with the sup-
emetric `edist f g = ⨆ σ, ENNReal.ofReal |f σ − g σ|`. Then this subtype is a
*closed* subset of `(Finset α → ℝ)` under uniform (sup-emetric) convergence, and
consequently `(Filtration α, eInterleavingDist)` — already a genuine
`EMetricSpace` by Bridge VII and isometric to the subtype by Bridge IX's
`weightEquiv` + `eInterleavingDist_ofWeight` — is a **complete** extended metric
space, with the weight of any Cauchy limit equal to the uniform limit of the
weights.

The key insight is that the two defining constraints `w ∅ ≤ 0` and `Monotone w`
are both *non-strict* inequalities (`w ∅ ≤ 0` and `∀ σ ⊆ τ, w σ ≤ w τ`), hence
closed conditions preserved under pointwise limits; Bridge IX has already reduced
"the space of filtrations" to exactly this constraint set, so completeness is no
longer a persistence question but the Mathlib-shaped lemma "a uniform limit of
monotone, `∅`-grounded functions is monotone and `∅`-grounded."

Why now? Completeness was ill-posed while distinct filtrations could sit at
distance `0`; Bridge VII separated points, Bridge VIII identified the metric with a
sup-norm, and Bridge IX's `weightEquiv` makes the carrier *literally* the
constraint set — so the only remaining content is closedness, an immediate falsifier
being any uniformly-convergent sequence of monotone functions with a non-monotone
limit (which cannot exist, making the conjecture sharp).

### Direction 2 — A left adjoint to pullback: the pushforward and a Galois connection

**Conjecture.** For `f : α → β` there is a **pushforward** `pushforward f :
Filtration α → Filtration β`, `(pushforward f F).weight τ = ⨆ {σ | σ.image f ⊆ τ}
F.weight σ` (the largest monotone, `∅`-grounded weight on `β` below the data),
which is `1`-Lipschitz and forms an **adjunction / Galois connection** with
`pullback f` on the weight order: `pushforward f F ⊑ G ↔ F ⊑ pullback f G`, where
`⊑` is pointwise `≤` of weights. Hence `pullback` has a left adjoint and the
persistence functor is part of an adjoint pair between `Filtration α` and
`Filtration β`.

The key insight is that Bridge IX's representation theorem turns `Filtration γ`
into the complete lattice of monotone `∅`-grounded functions under pointwise `≤`
(monotone functions are closed under `⨆`/`⨅`), and `pullback f` is just precomposition
with `·.image f` on that lattice; precomposition between complete lattices always
has both adjoints by the adjoint functor theorem for posets, so the pushforward
exists and is given by the displayed `⨆`-formula.

Why now? `pullback` and the lattice structure on weights are both now explicit
(Bridge IX); the adjunction is a one-line `le_iSup`/`iSup_le` Galois-connection
proof rather than a categorical abstraction, and it is falsified the instant the
displayed `⨆` fails to be `∅`-grounded — i.e. exactly when `f` is not surjective on
the relevant simplices, pinpointing where the adjunction degenerates.

### Direction 3 — Vietoris–Rips stability is tight: an entrywise isometry

**Conjecture.** For symmetric, hollow distance matrices `d₁ d₂ : α → α → ℝ` over a
finite vertex type,
`eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
   = ⨆ x, ⨆ y, ENNReal.ofReal |d₁ x y − d₂ x y|`,
sharpening the one-sided `vr_eStability` (Bridge V) to an equality and making the
Vietoris–Rips functor a *distortion-preserving* embedding of distance matrices.

The key insight is that Bridge VIII already rewrites the left side as
`⨆ σ, ENNReal.ofReal |diamWeightOf d₁ σ − diamWeightOf d₂ σ|`, and `diamWeightOf`
is a finite `sup'` over the vertex pairs of `σ`; the gap of two `sup'`s is bounded
by the worst single pair (`diamWeightOf_dist_le` gives `≤`, and the pair attaining
`diamWeightOf d₁ σ` realises the reverse), so the whole equality is a finite
extremal-pair argument over edges with no new analysis.

Why now? Bridge VIII converted the abstract interleaving infimum into a concrete
weight sup and Bridge IX showed how to collapse such sups along reindexings; the
only remaining content is the combinatorial identity "the diameter gap is attained
on an edge," and the explicit `cloud₁`/`cloud₂` pair in `BottleneckStability.lean`
is an immediate falsifier if the edge sup ever strictly exceeds the simplex sup.

### Direction 4 — Where the isometry breaks: non-Archimedean weight codomains

**Conjecture.** Replace the codomain `ℝ` of `Filtration.weight` by an ordered
additive structure `W` that is not densely ordered / not order-complete (e.g. the
min-plus tropical semiring of `Catalog/Tropical/MinPlusAlgebra.lean`, or a discrete
value group). Then the *relational* characterisation `interleaved_iff_weightCloseBy`
**survives** (it is pure order algebra), but the attained-infimum step
`eInterleavingDist_le_weightSupEDist` **fails**: the sup of weight gaps need not be
an admissible shift, so `eInterleavingDist` strictly undercuts the weight sup, the
T0 collapse of Bridge VII degenerates back to a genuine pseudometric, and the
Bridge VI `SeparationQuotient` becomes nontrivial — while Bridge IX's `pullback`
functoriality and the `ext_weight`/`ofWeight` representation survive verbatim.

The key insight is that Bridges VIII–IX isolate the *unique* analytic input — the
step "`c.toReal` is itself a witness," which silently uses `ENNReal.ofReal_toReal`
and the order-completeness of `ℝ` — so removing density/completeness surgically
removes exactly the attainment, leaving the order-algebraic and functorial layers
intact; the residual kernel then measures the order-completeness of `W`.

Why now? Bridge VIII names the single load-bearing lemma and Bridge IX shows the
functorial/representation layer is codomain-agnostic, so a counterexample is a
single explicit `W`-filtration pair; the catalog already ships the tropical
scaffolding to instantiate `W`, making the obstruction constructible and
falsifiable today.

### Direction 5 — Faithfulness and the persistence (co)presheaf

**Conjecture.** The assignment `α ↦ Filtration α`, `f ↦ pullback f` is a faithful
contravariant functor from (vertex types, surjections) to (extended metric spaces,
short maps): on the subcategory of *surjections* it is full-and-faithful on the
metric, i.e. `eInterleavingDist (pullback f F) (pullback f G) = eInterleavingDist F
G` (Bridge IX's `…_of_surjective`) characterises surjectivity, and distinct
filtrations stay distinct under any *injective* pullback section.

The key insight is that `pullback_comp` and `pullback_id` already give the functor
laws, and Bridge IX's isometry-under-surjection plus the representation bijection
`weightEquiv` reduce faithfulness to the statement that `·.image f` is injective on
`Finset α` exactly when... `f` is injective — a clean `Finset.image_injective`
dichotomy that mirrors the surjective/injective split governing the metric.

Why now? With `pullback` a verified functor (Bridge IX) and the carrier identified
with a function lattice (representation theorem), "faithful/full" become literal
Mathlib predicates on `Finset.image`, and the dichotomy is falsified by any `f`
that is injective but whose `Finset.image` collapses two filtrations — which the
representation theorem shows is impossible, making the conjecture sharp.

**Concept description**: # Future Directions — Boltzmann Bridge IX: The Persistence Functor and the Representation Theorem

## Synthesis

`Catalog/Applications/BoltzmannBridge/InterleavingFunctor.lean` (Bridge IX)
discharges **Future Directions 3 and 5** of Boltzmann Bridge VIII
(`InterleavingIsometry`) and, in doing so, turns the closed-form isometry of
Bridge VIII into *structural* statements about the whole space of filtrations.

Bridge VIII pinned the interleaving emetric to a sup-norm on weight functions:

> `eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ − G.weight σ|`.

Bridge IX exploits this in two complementary ways.

* **Functoriality (Direction 3).** A vertex map `f : α → β` pulls a filtration
  back, `(pullback f F).weight σ = F.weight (σ.image f)`, monotone because
  `Finset.image` is. This is a genuine contravariant functor (`pullback_id`,
  `pullback_comp`) and Bridge VIII makes it **1-Lipschitz**
  (`eInterleavingDist_pullback_le`, packaged as `pullback_lipschitzWith_one :
  LipschitzWith 1 (pullback f)`): the simplex-sup of pullback-weight gaps ranges
  over a *subset* of the simplex-sup of weight gaps, so the bound is monotonicity
  of `⨆` over a reindexing. When `f` is **surjective** the reindexing is itself
  surjective onto every simplex of `β`, upgrading the bound to an *equality*
  (`eInterleavingDist_pullback_eq_of_surjective`).

  This also **corrects** Bridge VIII's published narrative, which claimed equality
  for *injective* `f`. That is false — an injective `f : α → β` with `α` strictly
  smaller than `β` leaves simplices of `β` outside the image of `·.image f`, where
  the weights may differ arbitrarily, so the pullback distance can strictly
  undercut `eInterleavingDist F G`. The reindexing `σ ↦ σ.image f` is surjective
  (hence sup-preserving) exactly when `f` is surjective. Bridge IX proves the
  honest, surjective version.

* **Representation theorem (Direction 5).** Bridge VII's `ext_weight` showed
  `weight` is *injective*. The converse constructor `ofWeight` shows it is
  *surjective* onto the monotone, `∅`-grounded functions: every `w : Finset α → ℝ`
  with `w ∅ ≤ 0` and `Monotone w` is the weight of a unique filtration
  (`weight_surjective`). Packaged as the bijection `weightEquiv : Filtration α ≃
  {w // w ∅ ≤ 0 ∧ Monotone w}` and combined with Bridge VIII
  (`eInterleavingDist_ofWeight`), this **classifies** the persistence emetric: up
  to the explicit bijection, `(Filtration α, eInterleavingDist)` is nothing but the
  order interval of monotone, `∅`-grounded functions under the sup-emetric.

The methodological lesson of Bridge IX: once the metric is a sup-norm on
functions (Bridge VIII), every structural question — functoriality, isometry,
classification — collapses to elementary facts about `⨆` and `Finset.image`. The
closed form turns geometry into bookkeeping.

## Results Summary

All theorems in `InterleavingFunctor.lean` compile with `sorry`-count `0` and
depend only on `propext`, `Classical.choice`, `Quot.sound`.

| Theorem | Statement |
|---|---|
| `pullback` / `pullback_weight` | the pullback filtration along `f`, `(pullback f F).weight σ = F.weight (σ.image f)` |
| `pullback_id`, `pullback_comp` | the contravariant functor laws |
| `eInterleavingDist_pullback_le` | pullback is `1`-Lipschitz |
| `pullback_lipschitzWith_one` | `LipschitzWith 1 (pullback f)` (Mathlib short map) |
| `eInterleavingDist_pullback_eq_of_surjective` | pullback along a surjection is an isometry (corrected Direction 3) |
| `ofWeight` / `weight_surjective` | the converse constructor; `weight` is surjective |
| `weightEquiv` | the representation bijection `Filtration α ≃ {w // w ∅ ≤ 0 ∧ Monotone w}` |
| `eInterleavingDist_ofWeight` | the emetric in fully explicit weight-function form |

## Falsifiable Research Directions

### Direction 1 — Completeness of the representation: the constraint set is closed

**Conjecture.** Equip `{w : Finset α → ℝ // w ∅ ≤ 0 ∧ Monotone w}` with the sup-
emetric `edist f g = ⨆ σ, ENNReal.ofReal |f σ − g σ|`. Then this subtype is a
*closed* subset of `(Finset α → ℝ)` under uniform (sup-emetric) convergence, and
consequently `(Filtration α, eInterleavingDist)` — already a genuine
`EMetricSpace` by Bridge VII and isometric to the subtype by Bridge IX's
`weightEquiv` + `eInterleavingDist_ofWeight` — is a **complete** extended metric
space, with the weight of any Cauchy limit equal to the uniform limit of the
weights.

The key insight is that the two defining constraints `w ∅ ≤ 0` and `Monotone w`
are both *non-strict* inequalities (`w ∅ ≤ 0` and `∀ σ ⊆ τ, w σ ≤ w τ`), hence
closed conditions preserved under pointwise limits; Bridge IX has already reduced
"the space of filtrations" to exactly this constraint set, so completeness is no
longer a persistence question but the Mathlib-shaped lemma "a uniform limit of
monotone, `∅`-grounded functions is monotone and `∅`-grounded."

Why now? Completeness was ill-posed while distinct filtrations could sit at
distance `0`; Bridge VII separated points, Bridge VIII identified the metric with a
sup-norm, and Bridge IX's `weightEquiv` makes the carrier *literally* the
constraint set — so the only remaining content is closedness, an immediate falsifier
being any uniformly-convergent sequence of monotone functions with a non-monotone
limit (which cannot exist, making the conjecture sharp).

### Direction 2 — A left adjoint to pullback: the pushforward and a Galois connection

**Conjecture.** For `f : α → β` there is a **pushforward** `pushforward f :
Filtration α → Filtration β`, `(pushforward f F).weight τ = ⨆ {σ | σ.image f ⊆ τ}
F.weight σ` (the largest monotone, `∅`-grounded weight on `β` below the data),
which is `1`-Lipschitz and forms an **adjunction / Galois connection** with
`pullback f` on the weight order: `pushforward f F ⊑ G ↔ F ⊑ pullback f G`, where
`⊑` is pointwise `≤` of weights. Hence `pullback` has a left adjoint and the
persistence functor is part of an adjoint pair between `Filtration α` and
`Filtration β`.

The key insight is that Bridge IX's representation theorem turns `Filtration γ`
into the complete lattice of monotone `∅`-grounded functions under pointwise `≤`
(monotone functions are closed under `⨆`/`⨅`), and `pullback f` is just precomposition
with `·.image f` on that lattice; precomposition between complete lattices always
has both adjoints by the adjoint functor theorem for posets, so the pushforward
exists and is given by the displayed `⨆`-formula.

Why now? `pullback` and the lattice structure on weights are both now explicit
(Bridge IX); the adjunction is a one-line `le_iSup`/`iSup_le` Galois-connection
proof rather than a categorical abstraction, and it is falsified the instant the
displayed `⨆` fails to be `∅`-grounded — i.e. exactly when `f` is not surjective on
the relevant simplices, pinpointing where the adjunction degenerates.

### Direction 3 — Vietoris–Rips stability is tight: an entrywise isometry

**Conjecture.** For symmetric, hollow distance matrices `d₁ d₂ : α → α → ℝ` over a
finite vertex type,
`eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
   = ⨆ x, ⨆ y, ENNReal.ofReal |d₁ x y − d₂ x y|`,
sharpening the one-sided `vr_eStability` (Bridge V) to an equality and making the
Vietoris–Rips functor a *distortion-preserving* embedding of distance matrices.

The key insight is that Bridge VIII already rewrites the left side as
`⨆ σ, ENNReal.ofReal |diamWeightOf d₁ σ − diamWeightOf d₂ σ|`, and `diamWeightOf`
is a finite `sup'` over the vertex pairs of `σ`; the gap of two `sup'`s is bounded
by the worst single pair (`diamWeightOf_dist_le` gives `≤`, and the pair attaining
`diamWeightOf d₁ σ` realises the reverse), so the whole equality is a finite
extremal-pair argument over edges with no new analysis.

Why now? Bridge VIII converted the abstract interleaving infimum into a concrete
weight sup and Bridge IX showed how to collapse such sups along reindexings; the
only remaining content is the combinatorial identity "the diameter gap is attained
on an edge," and the explicit `cloud₁`/`cloud₂` pair in `BottleneckStability.lean`
is an immediate falsifier if the edge sup ever strictly exceeds the simplex sup.

### Direction 4 — Where the isometry breaks: non-Archimedean weight codomains

**Conjecture.** Replace the codomain `ℝ` of `Filtration.weight` by an ordered
additive structure `W` that is not densely ordered / not order-complete (e.g. the
min-plus tropical semiring of `Catalog/Tropical/MinPlusAlgebra.lean`, or a discrete
value group). Then the *relational* characterisation `interleaved_iff_weightCloseBy`
**survives** (it is pure order algebra), but the attained-infimum step
`eInterleavingDist_le_weightSupEDist` **fails**: the sup of weight gaps need not be
an admissible shift, so `eInterleavingDist` strictly undercuts the weight sup, the
T0 collapse of Bridge VII degenerates back to a genuine pseudometric, and the
Bridge VI `SeparationQuotient` becomes nontrivial — while Bridge IX's `pullback`
functoriality and the `ext_weight`/`ofWeight` representation survive verbatim.

The key insight is that Bridges VIII–IX isolate the *unique* analytic input — the
step "`c.toReal` is itself a witness," which silently uses `ENNReal.ofReal_toReal`
and the order-completeness of `ℝ` — so removing density/completeness surgically
removes exactly the attainment, leaving the order-algebraic and functorial layers
intact; the residual kernel then measures the order-completeness of `W`.

Why now? Bridge VIII names the single load-bearing lemma and Bridge IX shows the
functorial/representation layer is codomain-agnostic, so a counterexample is a
single explicit `W`-filtration pair; the catalog already ships the tropical
scaffolding to instantiate `W`, making the obstruction constructible and
falsifiable today.

### Direction 5 — Faithfulness and the persistence (co)presheaf

**Conjecture.** The assignment `α ↦ Filtration α`, `f ↦ pullback f` is a faithful
contravariant functor from (vertex types, surjections) to (extended metric spaces,
short maps): on the subcategory of *surjections* it is full-and-faithful on the
metric, i.e. `eInterleavingDist (pullback f F) (pullback f G) = eInterleavingDist F
G` (Bridge IX's `…_of_surjective`) characterises surjectivity, and distinct
filtrations stay distinct under any *injective* pullback section.

The key insight is that `pullback_comp` and `pullback_id` already give the functor
laws, and Bridge IX's isometry-under-surjection plus the representation bijection
`weightEquiv` reduce faithfulness to the statement that `·.image f` is injective on
`Finset α` exactly when... `f` is injective — a clean `Finset.image_injective`
dichotomy that mirrors the surjective/injective split governing the metric.

Why now? With `pullback` a verified functor (Bridge IX) and the carrier identified
with a function lattice (representation theorem), "faithful/full" become literal
Mathlib predicates on `Finset.image`, and the dichotomy is falsified by any `f`
that is injective but whose `Finset.image` collapses two filtrations — which the
representation theorem shows is impossible, making the conjecture sharp.

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
