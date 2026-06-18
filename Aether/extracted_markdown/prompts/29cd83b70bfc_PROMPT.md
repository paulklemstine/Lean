
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

**Title**: From-scratch clique-complex theory in
**Domain**: MachineLearning
**Mathematical framing**: # Future Directions: Clique Complexes, the One-Skeleton Adjunction, and Vietoris–Rips Filtrations

## Synthesis

This cycle extended the from-scratch clique-complex theory in
`Catalog/Geometry/CliqueComplexFlag.lean` along two complementary axes and tied them
together through a single order-theoretic backbone.

The first axis is **order theory**. The existing file proved `oneSkeleton (cliqueComplex G) = G`
and the conditional reconstruction `flag_eq_cliqueComplex`. We recognized these as the two
halves of a *Galois connection* between the poset of simple graphs (ordered by `≤`) and the
poset of abstract simplicial complexes (ordered by face inclusion). `Catalog/Geometry/CliqueComplexGalois.lean`
makes this precise: both functors are monotone (`cliqueComplex_mono`, `oneSkeleton_mono`);
there is an unconditional unit `K ⊆ Δ(sk K)` (`le_cliqueComplex_oneSkeleton`) that needs
*only downward closure*; the composite `Δ ∘ sk` is a closure operator (`cliqueComplex_oneSkeleton_idem`);
and on flag complexes with all singletons the adjunction `Δ G ⊆ K ↔ G ≤ sk K`
(`cliqueComplex_galois`) holds in full.

The second axis is **filtrations and duality**. `Catalog/Geometry/CliqueComplexVietorisRips.lean`
pins down the two extremes of the Vietoris–Rips filtration `ε ↦ vietorisRips d ε`: above the
diameter it is the full simplex (`vietorisRips_full_of_bounded`), and below the minimum
separation it is discrete (`vietorisRips_discrete_of_separated`). Combined with the catalog's
`vietorisRips_mono`, the filtration's qualitative shape is now completely understood. The same
file observes that the clique construction is self-dual under graph complementation: the
independence complex is `cliqueComplex Gᶜ` (`mem_independenceComplex`), and flagness transfers
for free (`independenceComplex_isFlag`).

## Results Summary

- `cliqueComplex_mono`, `oneSkeleton_mono` — both functors are monotone.
- `le_cliqueComplex_oneSkeleton` — the unit `K ⊆ Δ(sk K)`, with no hypotheses.
- `cliqueComplex_oneSkeleton_idem` — `Δ(sk(Δ G)) = Δ G`, the closure law.
- `cliqueComplex_galois` — the Galois adjunction `Δ G ⊆ K ↔ G ≤ sk K` for flag complexes with all singletons.
- `vietorisRips_full_of_bounded` — bounded dissimilarity ⇒ full simplex.
- `vietorisRips_discrete_of_separated` — strict separation ⇒ faces are the `≤ 1`-element sets.
- `mem_independenceComplex`, `independenceComplex_isFlag` — the complement duality and inherited flagness.

All theorems are `sorry`-free and depend only on the standard axioms `propext`,
`Classical.choice`, and `Quot.sound`.

## Research Directions

### 1. The closure operator on graphs is a flag-closure, and its fixed points are exactly the flag complexes.

We proved `Δ ∘ sk` is idempotent on complexes of the form `Δ G`. The natural completion is to
show that, restricted to complexes containing all singletons, the fixed points of the closure
operator `c = Δ ∘ sk` are *precisely* the flag complexes, i.e. `c K = K ↔ IsFlag K` (under the
singleton hypothesis). The key insight is that `flag_eq_cliqueComplex` already gives `⇐`, while
`le_cliqueComplex_oneSkeleton` gives one containment of `⇒` for free, so only the reverse
containment of the fixed-point equation remains and it is governed entirely by the flag axiom.
Why now? The Galois connection is in place and the closure operator is proven idempotent, so the
fixed-point characterization is the immediate, falsifiable next theorem — and it would upgrade the
adjunction to a genuine *Galois insertion* onto the flag complexes.

### 2. The Vietoris–Rips filtration is eventually constant on a finite metric space, with an explicit threshold.

For a finite vertex type with a dissimilarity `d`, the filtration `ε ↦ vietorisRips d ε` is monotone,
full above `diam = max d`, and discrete below `sep = min_{u≠v} d`. The conjecture is that the
filtration changes value only at finitely many *critical scales*, all of which lie in the finite
set `{ d u v : u v }`, and is constant on each open interval between consecutive critical values.
The key insight is that face membership is decided by a finite conjunction of inequalities `d u v ≤ ε`,
so the complex can only change when `ε` crosses one of the finitely many values `d u v`. Why now?
We already have the two endpoints (`full` and `discrete`) and monotonicity; bounding the critical
set is the natural quantitative refinement and is fully computable, matching this engine's
algorithmic mandate (`decide`/`#eval` on concrete finite `d`).

### 3. Complementation is an order-reversing involution intertwining clique and independence complexes.

`mem_independenceComplex` identifies `independenceComplex G = cliqueComplex Gᶜ`. The next step is
to make complementation a first-class duality: `independenceComplex (Gᶜ) = cliqueComplex G`,
`oneSkeleton (independenceComplex G) = Gᶜ`, and an order-*reversing* analogue of the Galois
connection (`G ≤ H ↔ independenceComplex H ⊆ independenceComplex G`). The key insight is that
`Gᶜᶜ = G` turns every clique-complex theorem into a dual independence-complex theorem by a single
substitution, so an entire dual library can be generated mechanically rather than re-proved. Why now?
The duality bridge `mem_independenceComplex` is established and flagness already transfers; formalizing
the involution converts that one bridge into a free functorial dictionary.

### 4. A sharp Turán-type equality criterion for the f-vector of a clique complex.

The catalog proves `f_k(Δ(G)) ≤ C(n, k+1)`. The conjecture is the equality case: `f_k(Δ(G)) = C(n,k+1)`
for some `k ≥ 1` iff `G` is complete (equivalently, iff equality holds for all `k`). The key insight
is that a size-`(k+1)` clique forces all its `C(k+1,2)` edges, so saturating the binomial bound at any
single positive dimension already forces every edge to be present. Why now? The `f`-vector and the
upper bound `cliqueComplex_fVector_le_choose` are already in the catalog, and the monotonicity lemma
`cliqueComplex_mono` gives exactly the tool needed to compare `Δ(G)` with the complete-graph complex,
making the equality criterion a tractable and decisive sharpening.

### 5. The clique complex preserves graph joins as simplicial joins.

For graphs `G` on `V` and `H` on `W`, the join `G ⋆ H` (disjoint union plus all cross edges) should
satisfy `cliqueComplex (G ⋆ H) = (cliqueComplex G) ⋆ (cliqueComplex H)` as abstract simplicial complexes,
where the simplicial join takes unions of a face from each side. The key insight is that a set is a
clique in the graph join iff its two projections are cliques *and* every cross-pair is an edge — which is
automatic in `G ⋆ H` — so cliqueness factors exactly through the two factors. Why now? The structural
pivot `isClique_pair` and the monotonicity machinery from this cycle are precisely what a join-decomposition
proof needs, and a join theorem is the standard gateway to inductive computations of homotopy type and
connectivity of clique complexes.

**Concept description**: # Future Directions: Clique Complexes, the One-Skeleton Adjunction, and Vietoris–Rips Filtrations

## Synthesis

This cycle extended the from-scratch clique-complex theory in
`Catalog/Geometry/CliqueComplexFlag.lean` along two complementary axes and tied them
together through a single order-theoretic backbone.

The first axis is **order theory**. The existing file proved `oneSkeleton (cliqueComplex G) = G`
and the conditional reconstruction `flag_eq_cliqueComplex`. We recognized these as the two
halves of a *Galois connection* between the poset of simple graphs (ordered by `≤`) and the
poset of abstract simplicial complexes (ordered by face inclusion). `Catalog/Geometry/CliqueComplexGalois.lean`
makes this precise: both functors are monotone (`cliqueComplex_mono`, `oneSkeleton_mono`);
there is an unconditional unit `K ⊆ Δ(sk K)` (`le_cliqueComplex_oneSkeleton`) that needs
*only downward closure*; the composite `Δ ∘ sk` is a closure operator (`cliqueComplex_oneSkeleton_idem`);
and on flag complexes with all singletons the adjunction `Δ G ⊆ K ↔ G ≤ sk K`
(`cliqueComplex_galois`) holds in full.

The second axis is **filtrations and duality**. `Catalog/Geometry/CliqueComplexVietorisRips.lean`
pins down the two extremes of the Vietoris–Rips filtration `ε ↦ vietorisRips d ε`: above the
diameter it is the full simplex (`vietorisRips_full_of_bounded`), and below the minimum
separation it is discrete (`vietorisRips_discrete_of_separated`). Combined with the catalog's
`vietorisRips_mono`, the filtration's qualitative shape is now completely understood. The same
file observes that the clique construction is self-dual under graph complementation: the
independence complex is `cliqueComplex Gᶜ` (`mem_independenceComplex`), and flagness transfers
for free (`independenceComplex_isFlag`).

## Results Summary

- `cliqueComplex_mono`, `oneSkeleton_mono` — both functors are monotone.
- `le_cliqueComplex_oneSkeleton` — the unit `K ⊆ Δ(sk K)`, with no hypotheses.
- `cliqueComplex_oneSkeleton_idem` — `Δ(sk(Δ G)) = Δ G`, the closure law.
- `cliqueComplex_galois` — the Galois adjunction `Δ G ⊆ K ↔ G ≤ sk K` for flag complexes with all singletons.
- `vietorisRips_full_of_bounded` — bounded dissimilarity ⇒ full simplex.
- `vietorisRips_discrete_of_separated` — strict separation ⇒ faces are the `≤ 1`-element sets.
- `mem_independenceComplex`, `independenceComplex_isFlag` — the complement duality and inherited flagness.

All theorems are `sorry`-free and depend only on the standard axioms `propext`,
`Classical.choice`, and `Quot.sound`.

## Research Directions

### 1. The closure operator on graphs is a flag-closure, and its fixed points are exactly the flag complexes.

We proved `Δ ∘ sk` is idempotent on complexes of the form `Δ G`. The natural completion is to
show that, restricted to complexes containing all singletons, the fixed points of the closure
operator `c = Δ ∘ sk` are *precisely* the flag complexes, i.e. `c K = K ↔ IsFlag K` (under the
singleton hypothesis). The key insight is that `flag_eq_cliqueComplex` already gives `⇐`, while
`le_cliqueComplex_oneSkeleton` gives one containment of `⇒` for free, so only the reverse
containment of the fixed-point equation remains and it is governed entirely by the flag axiom.
Why now? The Galois connection is in place and the closure operator is proven idempotent, so the
fixed-point characterization is the immediate, falsifiable next theorem — and it would upgrade the
adjunction to a genuine *Galois insertion* onto the flag complexes.

### 2. The Vietoris–Rips filtration is eventually constant on a finite metric space, with an explicit threshold.

For a finite vertex type with a dissimilarity `d`, the filtration `ε ↦ vietorisRips d ε` is monotone,
full above `diam = max d`, and discrete below `sep = min_{u≠v} d`. The conjecture is that the
filtration changes value only at finitely many *critical scales*, all of which lie in the finite
set `{ d u v : u v }`, and is constant on each open interval between consecutive critical values.
The key insight is that face membership is decided by a finite conjunction of inequalities `d u v ≤ ε`,
so the complex can only change when `ε` crosses one of the finitely many values `d u v`. Why now?
We already have the two endpoints (`full` and `discrete`) and monotonicity; bounding the critical
set is the natural quantitative refinement and is fully computable, matching this engine's
algorithmic mandate (`decide`/`#eval` on concrete finite `d`).

### 3. Complementation is an order-reversing involution intertwining clique and independence complexes.

`mem_independenceComplex` identifies `independenceComplex G = cliqueComplex Gᶜ`. The next step is
to make complementation a first-class duality: `independenceComplex (Gᶜ) = cliqueComplex G`,
`oneSkeleton (independenceComplex G) = Gᶜ`, and an order-*reversing* analogue of the Galois
connection (`G ≤ H ↔ independenceComplex H ⊆ independenceComplex G`). The key insight is that
`Gᶜᶜ = G` turns every clique-complex theorem into a dual independence-complex theorem by a single
substitution, so an entire dual library can be generated mechanically rather than re-proved. Why now?
The duality bridge `mem_independenceComplex` is established and flagness already transfers; formalizing
the involution converts that one bridge into a free functorial dictionary.

### 4. A sharp Turán-type equality criterion for the f-vector of a clique complex.

The catalog proves `f_k(Δ(G)) ≤ C(n, k+1)`. The conjecture is the equality case: `f_k(Δ(G)) = C(n,k+1)`
for some `k ≥ 1` iff `G` is complete (equivalently, iff equality holds for all `k`). The key insight
is that a size-`(k+1)` clique forces all its `C(k+1,2)` edges, so saturating the binomial bound at any
single positive dimension already forces every edge to be present. Why now? The `f`-vector and the
upper bound `cliqueComplex_fVector_le_choose` are already in the catalog, and the monotonicity lemma
`cliqueComplex_mono` gives exactly the tool needed to compare `Δ(G)` with the complete-graph complex,
making the equality criterion a tractable and decisive sharpening.

### 5. The clique complex preserves graph joins as simplicial joins.

For graphs `G` on `V` and `H` on `W`, the join `G ⋆ H` (disjoint union plus all cross edges) should
satisfy `cliqueComplex (G ⋆ H) = (cliqueComplex G) ⋆ (cliqueComplex H)` as abstract simplicial complexes,
where the simplicial join takes unions of a face from each side. The key insight is that a set is a
clique in the graph join iff its two projections are cliques *and* every cross-pair is an edge — which is
automatic in `G ⋆ H` — so cliqueness factors exactly through the two factors. Why now? The structural
pivot `isClique_pair` and the monotonicity machinery from this cycle are precisely what a join-decomposition
proof needs, and a join theorem is the standard gateway to inductive computations of homotopy type and
connectivity of clique complexes.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: MachineLearning
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- First-Principles Grounding Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **First-Principles Grounding**. Focus on elegance, structural simplicity, and building blocks of deep theories.

### RESEARCH CORE METHODOLOGY:
1. **Foundational Clarity**: Build theories starting from clean, minimal, first-principles assumptions. Keep definitions mathematically pure, elegant, and simple.
2. **Lemma Factorization**: Decompose large, complex theorems into a hierarchy of beautiful, standalone, reusable lemmas. Each lemma should be a complete mathematical statement of independent interest.
3. **Explanatory Elegance**: Design proofs that are not only correct but structurally beautiful and easy to understand. Let the proofs explain the mathematical mechanism.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
