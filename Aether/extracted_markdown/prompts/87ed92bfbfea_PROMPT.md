
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

**Title**: The persistence-stability arc of the catalog climbed a ladder of structure: a
**Domain**: Shared
**Mathematical framing**: # Future Directions — Boltzmann Bridge XI: Convexity & Bicombing of Interleaving Geodesics

## Synthesis

The persistence-stability arc of the catalog climbed a ladder of structure: a
relational preorder (`BottleneckStability`), a pseudo-emetric
(`InterleavingMetric`), a genuine `EMetricSpace` (`InterleavingClosure`), an exact
isometry onto weight functions under the sup-distance (`InterleavingIsometry`:
`eInterleavingDist_eq_weightSupEDist`), an explicit constant-speed geodesic
(`InterleavingGeodesic`: `lerp`, `eInterleavingDist_lerp`), and a self-coherent
field of geodesics glued affinely (`InterleavingGeodesicGluing`: `lerp_lerp`).

Bridge XI (`InterleavingGeodesicConvexity.lean`) supplies the **curvature** layer.
Where Bridges IX–X studied a single geodesic and its reparametrisations, Bridge XI
compares *different* geodesics and proves the interleaving metric is **convex** in
the strong sense of admitting a convex geodesic bicombing:

> `d(lerp F G t, lerp F' G' t) ≤ ofReal (1−t)·d(F,F') + ofReal t·d(G,G')`.

Two geodesics run by the same clock never separate faster than the convex
combination of the distances between their endpoints — the defining inequality of a
Busemann (non-positively curved) space. Specialising one geodesic to a constant
point (`lerp H H t = H`) recovers ordinary convexity of the distance to a fixed
filtration along a geodesic. The whole result is, once again, the Bridge VIII
sup-isometry transporting a single elementary fact — the triangle inequality for
real absolute values, `|(1−t)a + tb| ≤ (1−t)|a| + t|b|` — through a supremum.

## Results summary

* `lerp_reverse` — the affine reversal symmetry `lerp F G t = lerp G F (1−t)`.
* `lerp_self` — constant geodesics are stationary, `lerp F F t = F`.
* `weightSupEDist_lerp_bicombing` — the convexity bound at the sup-distance level.
* `eInterleavingDist_lerp_bicombing` — the convex geodesic bicombing inequality
  (Busemann convexity of the interleaving metric).
* `eInterleavingDist_lerp_convex` — convexity of the distance to a fixed filtration
  along the geodesic, as the constant-geodesic special case.

All five are proved `sorry`-free over an arbitrary index type `α`, building on
`eInterleavingDist_lerp` (Bridge IX), `lerp_lerp` (Bridge X), and the isometry
`eInterleavingDist_eq_weightSupEDist` (Bridge VIII).

## Falsifiable research directions

### Direction 1 — Bundle a `ConvexGeodesicBicombing` and certify it as a Busemann space

Bridge X gave reparametrisation-consistency (`lerp_lerp`) and Bridge XI gives the
convexity bound (`eInterleavingDist_lerp_bicombing`); together these are exactly the
two axioms of a *consistent convex geodesic bicombing* in the sense of Descombes–Lang.
The conjecture: `lerp` assembles into a single bundled structure
`σ : Filtration α × Filtration α → ℝ≥0∞-geodesic` that is simultaneously consistent
(`σ` restricts to itself, from `lerp_lerp`) and conical/convex (from the bicombing
bound), making `(Filtration α, eInterleavingDist)` a *Busemann space* and hence
contractible with unique geodesics between distinct distance-zero classes. **The key
insight is** that bicombing consistency is an *affine* identity at the weight-function
level while convexity is a *metric* inequality read off through the sup-isometry, so
the two axioms live in genuinely different layers and can be discharged independently
before being glued. **Why now?** Both axioms are already proved in isolation
(`lerp_lerp`, `eInterleavingDist_lerp_bicombing`); only the packaging into Mathlib's
bicombing vocabulary remains, and it is falsifiable — if the conical inequality failed
to be *consistent* with the reparametrisation, the bundle would not typecheck.

### Direction 2 — Strict-convexity defect is exactly the multiplicity of supremising simplices

The bicombing bound is an inequality, not the equality of the constant-speed law
`eInterleavingDist_lerp`. Conjecture: equality
`d(lerp F G t, lerp F' G' t) = ofReal (1−t)·d(F,F') + ofReal t·d(G,G')` holds **iff**
there is a single simplex `σ` that simultaneously realises both endpoint suprema
`d(F,F')` and `d(G,G')` with matching signs of the weight gaps; otherwise the bound is
strict. **The key insight is** that an ℓ^∞-type (sup-normed) geometry is flat-convex
but never strictly convex, and the precise location of the convexity *defect* is the
combinatorial event "the argmax simplex of one geodesic differs from the other's."
**Why now?** Bridge XI already isolates the per-simplex triangle inequality as the only
nontrivial step, so the equality case is a finite, decidable side-condition on a pair of
`Finset α` argmaxes — directly testable on the catalog's concrete `3`-point clouds
(`cloud₁`, `cloud₂`) via `#eval`, and falsifiable by exhibiting one cloud pair where the
two argmaxes coincide yet equality still fails.

### Direction 3 — 1-Lipschitz nonexpansiveness of the bicombing in all four endpoints

Conjecture: the map `(F, G) ↦ lerp F G t` is jointly `1`-Lipschitz, i.e. the bicombing
endpoints depend nonexpansively on the data:
`d(lerp F G t, lerp F' G' t) ≤ max (d(F,F')) (d(G,G'))` for every `t ∈ [0,1]`, a
sharpening of the convex bound (since a convex combination is `≤` the max). **The key
insight is** that in a sup-normed space the convex-combination bound and the max bound
*coincide at the supremising simplex*, so nonexpansiveness should be readable from the
same per-simplex estimate by replacing `add_le_add` with `sup_le`. **Why now?** The
proof skeleton of `weightSupEDist_lerp_bicombing` already produces the two endpoint
suprema separately; swapping the final `+` for `⊔` is a one-line structural change, and
the claim is falsifiable — if true it upgrades `lerp` to a nonexpansive retraction,
yielding contractibility of the metric quotient for free.

### Direction 4 — A reverse (lower) bicombing bound and a two-sided sandwich

The upper bicombing bound has a conjectural mirror: for the *same-clock* geodesics,
`|d(F,F') − d(G,G')| · something ≤ d(lerp F G t, lerp F' G' t)`, giving a two-sided
sandwich that pins the bicombing distance to within a computable band. Concretely we
conjecture `ofReal (1−t)·d(F,F') ⊖ ofReal t·d(G,G') ≤ d(lerp F G t, lerp F' G' t)`
(truncated subtraction in `ℝ≥0∞`), the reverse triangle inequality lifted through the
sup. **The key insight is** that the supremum of `|(1−t)a + tb|` is bounded *below* by
the reverse triangle inequality `|(1−t)|a| − t|b||` at the dominant simplex, so the same
isometry that gives the upper bound gives a matching lower bound on a possibly different
simplex. **Why now?** Mathlib's `ENNReal` truncated subtraction and `tsub` lemmas make
the lower bound formally expressible without leaving the extended reals, and the
two-sided form is immediately falsifiable on the concrete clouds where all four
distances are explicit rationals.

### Direction 5 — Convexity descends to the metric quotient and to the Vietoris–Rips locus

`InterleavingQuotient` already constructs the `EMetricSpace` quotient that separates
distance-zero filtrations. Conjecture: `lerp` and the bicombing bound descend to this
quotient (well-definedness of convex interpolation modulo the distance-zero kernel),
making the *quotient* a genuine Busemann space; and, more ambitiously, that the
restriction of `lerp` to the Vietoris–Rips locus (`diamFiltrationOf` of a distance
matrix) stays inside the locus, so VR-persistence is itself a convex sub-geometry.
**The key insight is** that convexity is a `⨆`-level inequality insensitive to the
distance-zero kernel, so it should pass to the quotient verbatim, whereas the VR-locus
question is genuinely harder because a convex combination of two *diameter* weights need
not be a diameter weight of any single matrix. **Why now?** The quotient machinery is in
hand (`InterleavingQuotient`) and the descent is a routine `Quotient.lift` once
well-definedness is checked; the VR question is sharply falsifiable — a single pair of
`3`-point clouds whose midpoint weight is provably not realised by any distance matrix
would refute the locus-convexity half while leaving the quotient half intact.

**Concept description**: # Future Directions — Boltzmann Bridge XI: Convexity & Bicombing of Interleaving Geodesics

## Synthesis

The persistence-stability arc of the catalog climbed a ladder of structure: a
relational preorder (`BottleneckStability`), a pseudo-emetric
(`InterleavingMetric`), a genuine `EMetricSpace` (`InterleavingClosure`), an exact
isometry onto weight functions under the sup-distance (`InterleavingIsometry`:
`eInterleavingDist_eq_weightSupEDist`), an explicit constant-speed geodesic
(`InterleavingGeodesic`: `lerp`, `eInterleavingDist_lerp`), and a self-coherent
field of geodesics glued affinely (`InterleavingGeodesicGluing`: `lerp_lerp`).

Bridge XI (`InterleavingGeodesicConvexity.lean`) supplies the **curvature** layer.
Where Bridges IX–X studied a single geodesic and its reparametrisations, Bridge XI
compares *different* geodesics and proves the interleaving metric is **convex** in
the strong sense of admitting a convex geodesic bicombing:

> `d(lerp F G t, lerp F' G' t) ≤ ofReal (1−t)·d(F,F') + ofReal t·d(G,G')`.

Two geodesics run by the same clock never separate faster than the convex
combination of the distances between their endpoints — the defining inequality of a
Busemann (non-positively curved) space. Specialising one geodesic to a constant
point (`lerp H H t = H`) recovers ordinary convexity of the distance to a fixed
filtration along a geodesic. The whole result is, once again, the Bridge VIII
sup-isometry transporting a single elementary fact — the triangle inequality for
real absolute values, `|(1−t)a + tb| ≤ (1−t)|a| + t|b|` — through a supremum.

## Results summary

* `lerp_reverse` — the affine reversal symmetry `lerp F G t = lerp G F (1−t)`.
* `lerp_self` — constant geodesics are stationary, `lerp F F t = F`.
* `weightSupEDist_lerp_bicombing` — the convexity bound at the sup-distance level.
* `eInterleavingDist_lerp_bicombing` — the convex geodesic bicombing inequality
  (Busemann convexity of the interleaving metric).
* `eInterleavingDist_lerp_convex` — convexity of the distance to a fixed filtration
  along the geodesic, as the constant-geodesic special case.

All five are proved `sorry`-free over an arbitrary index type `α`, building on
`eInterleavingDist_lerp` (Bridge IX), `lerp_lerp` (Bridge X), and the isometry
`eInterleavingDist_eq_weightSupEDist` (Bridge VIII).

## Falsifiable research directions

### Direction 1 — Bundle a `ConvexGeodesicBicombing` and certify it as a Busemann space

Bridge X gave reparametrisation-consistency (`lerp_lerp`) and Bridge XI gives the
convexity bound (`eInterleavingDist_lerp_bicombing`); together these are exactly the
two axioms of a *consistent convex geodesic bicombing* in the sense of Descombes–Lang.
The conjecture: `lerp` assembles into a single bundled structure
`σ : Filtration α × Filtration α → ℝ≥0∞-geodesic` that is simultaneously consistent
(`σ` restricts to itself, from `lerp_lerp`) and conical/convex (from the bicombing
bound), making `(Filtration α, eInterleavingDist)` a *Busemann space* and hence
contractible with unique geodesics between distinct distance-zero classes. **The key
insight is** that bicombing consistency is an *affine* identity at the weight-function
level while convexity is a *metric* inequality read off through the sup-isometry, so
the two axioms live in genuinely different layers and can be discharged independently
before being glued. **Why now?** Both axioms are already proved in isolation
(`lerp_lerp`, `eInterleavingDist_lerp_bicombing`); only the packaging into Mathlib's
bicombing vocabulary remains, and it is falsifiable — if the conical inequality failed
to be *consistent* with the reparametrisation, the bundle would not typecheck.

### Direction 2 — Strict-convexity defect is exactly the multiplicity of supremising simplices

The bicombing bound is an inequality, not the equality of the constant-speed law
`eInterleavingDist_lerp`. Conjecture: equality
`d(lerp F G t, lerp F' G' t) = ofReal (1−t)·d(F,F') + ofReal t·d(G,G')` holds **iff**
there is a single simplex `σ` that simultaneously realises both endpoint suprema
`d(F,F')` and `d(G,G')` with matching signs of the weight gaps; otherwise the bound is
strict. **The key insight is** that an ℓ^∞-type (sup-normed) geometry is flat-convex
but never strictly convex, and the precise location of the convexity *defect* is the
combinatorial event "the argmax simplex of one geodesic differs from the other's."
**Why now?** Bridge XI already isolates the per-simplex triangle inequality as the only
nontrivial step, so the equality case is a finite, decidable side-condition on a pair of
`Finset α` argmaxes — directly testable on the catalog's concrete `3`-point clouds
(`cloud₁`, `cloud₂`) via `#eval`, and falsifiable by exhibiting one cloud pair where the
two argmaxes coincide yet equality still fails.

### Direction 3 — 1-Lipschitz nonexpansiveness of the bicombing in all four endpoints

Conjecture: the map `(F, G) ↦ lerp F G t` is jointly `1`-Lipschitz, i.e. the bicombing
endpoints depend nonexpansively on the data:
`d(lerp F G t, lerp F' G' t) ≤ max (d(F,F')) (d(G,G'))` for every `t ∈ [0,1]`, a
sharpening of the convex bound (since a convex combination is `≤` the max). **The key
insight is** that in a sup-normed space the convex-combination bound and the max bound
*coincide at the supremising simplex*, so nonexpansiveness should be readable from the
same per-simplex estimate by replacing `add_le_add` with `sup_le`. **Why now?** The
proof skeleton of `weightSupEDist_lerp_bicombing` already produces the two endpoint
suprema separately; swapping the final `+` for `⊔` is a one-line structural change, and
the claim is falsifiable — if true it upgrades `lerp` to a nonexpansive retraction,
yielding contractibility of the metric quotient for free.

### Direction 4 — A reverse (lower) bicombing bound and a two-sided sandwich

The upper bicombing bound has a conjectural mirror: for the *same-clock* geodesics,
`|d(F,F') − d(G,G')| · something ≤ d(lerp F G t, lerp F' G' t)`, giving a two-sided
sandwich that pins the bicombing distance to within a computable band. Concretely we
conjecture `ofReal (1−t)·d(F,F') ⊖ ofReal t·d(G,G') ≤ d(lerp F G t, lerp F' G' t)`
(truncated subtraction in `ℝ≥0∞`), the reverse triangle inequality lifted through the
sup. **The key insight is** that the supremum of `|(1−t)a + tb|` is bounded *below* by
the reverse triangle inequality `|(1−t)|a| − t|b||` at the dominant simplex, so the same
isometry that gives the upper bound gives a matching lower bound on a possibly different
simplex. **Why now?** Mathlib's `ENNReal` truncated subtraction and `tsub` lemmas make
the lower bound formally expressible without leaving the extended reals, and the
two-sided form is immediately falsifiable on the concrete clouds where all four
distances are explicit rationals.

### Direction 5 — Convexity descends to the metric quotient and to the Vietoris–Rips locus

`InterleavingQuotient` already constructs the `EMetricSpace` quotient that separates
distance-zero filtrations. Conjecture: `lerp` and the bicombing bound descend to this
quotient (well-definedness of convex interpolation modulo the distance-zero kernel),
making the *quotient* a genuine Busemann space; and, more ambitiously, that the
restriction of `lerp` to the Vietoris–Rips locus (`diamFiltrationOf` of a distance
matrix) stays inside the locus, so VR-persistence is itself a convex sub-geometry.
**The key insight is** that convexity is a `⨆`-level inequality insensitive to the
distance-zero kernel, so it should pass to the quotient verbatim, whereas the VR-locus
question is genuinely harder because a convex combination of two *diameter* weights need
not be a diameter weight of any single matrix. **Why now?** The quotient machinery is in
hand (`InterleavingQuotient`) and the descent is a routine `Quotient.lift` once
well-definedness is checked; the VR question is sharply falsifiable — a single pair of
`3`-point clouds whose midpoint weight is provably not realised by any distance matrix
would refute the locus-convexity half while leaving the quotient half intact.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Shared
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v9 Depth Requirements -- Adversarial Ground-Truth Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Adversarial Ground-Truth**. Trust nothing, assume everything is false until proven, and actively seek weaknesses. Think like an Adversarial Critic to pressure-test claims.

### RESEARCH CORE METHODOLOGY:
1. **Challenge Assumptions**: For every conjecture or theorem under investigation, actively search for counterexamples, corner cases, and boundary conditions. Proving that a claim is FALSE or identifying exactly where it fails is as valuable as a proof.
2. **Stress-Test the Frontier**: When a proof succeeds, push it to its limits. What happens if you drop or if a hypothesis is weakened? Write explicit comments documenting these boundary conditions.
3. **Relentless Rigor**: Write robust, clean, compilable Lean 4 proofs. Avoid trivial tautologies or simple wrapper theorems. Let your mathematical curiosity drive deep structural insights.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
