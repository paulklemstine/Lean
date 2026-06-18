
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

**Title**: Algebraic and order-theoretic backbone of stereograph
**Domain**: Geometry
**Mathematical framing**: # Future Directions: Stereographic Capacity Theory

This cycle established the algebraic and order-theoretic backbone of stereographic
capacity theory in `Geometry/StereographicCapacity/Theorems.lean`, building directly
on the definitions in `Geometry/StereographicCapacity/Defs.lean`
(`stereoFactor`, `stereoExclusionRadius`, `StereoSeparated`, `sphericalCapArea`,
`SphericalPackingBound`, `stereoBoundS2`, `stereoBoundS2Closed`). We proved that the
distortion bound collapses to a clean closed form (`stereoBoundS2_eq_closed`), that a
cap never exceeds the sphere it lives on (`sphericalCapArea_le_sphereArea`), that cap
area is monotone in geodesic radius (`sphericalCapArea_monotone`), and — the geometric
heart of the cycle — that beyond the diameter threshold only one point can be packed
(`sphericalPackingBound_large_radius`), with packing budgets behaving monotonically
(`sphericalPackingBound_mono_B`). The directions below push from these "skeleton"
results toward the genuinely quantitative packing theorems the framework was built for.

## Direction 1: The stereographic transfer principle

The defining bet of the theory is that a `StereoSeparated` Euclidean configuration is
exactly the stereographic image of a `2r`-separated spherical configuration. We should
prove the transfer lemma: if a finite set on `S^n` is `2r`-separated, then its image
under stereographic projection (excluding the north pole) is `StereoSeparated` for `r`,
and conversely. This converts `SphericalPackingBound` statements into statements about
Euclidean exclusion balls, where volume packing arguments are available.

The key insight is that the conformal factor `stereoFactor x = 2/(1+‖x‖²)` is precisely
the first-order ratio between spherical and Euclidean distance, so the exclusion radius
`stereoExclusionRadius r x = tan r / stereoFactor x` is the *correct* linearization that
makes separation transfer hold to leading order — the `tan r` (not `sin r`) is what
upgrades the leading-order statement to an exact pairwise inequality.

Why now? We already have `stereoFactor_pos` and the closed-form distortion bound; the
transfer lemma is the one missing bridge that turns every spherical packing question in
this module into a plane-geometry question, unlocking all later directions.

## Direction 2: A proved Euclidean volume packing bound for `S²`

With the transfer principle in hand, the quantity `stereoBoundS2Closed r =
8/(cos²r·(1−cos r))` should become a *theorem*, not just a definition: for suitable
`r ∈ (0, π/2)`, `SphericalPackingBound 2 r (stereoBoundS2Closed r)` holds. The proof
route is a volume/measure argument — disjoint exclusion balls of total measure at most
the measure of an enclosing region — combined with `stereoBoundS2_eq_closed` to present
the answer in closed form.

The key insight is that `stereoBoundS2_eq_closed` already isolates the *only* analytic
content (an algebraic identity), so the remaining work is purely a disjointness-of-balls
measure estimate, which Mathlib's `MeasureTheory` volume-of-ball API supports directly.

Why now? `stereoBoundS2_eq_closed` and `sphericalCapArea_le_sphereArea` are proved, so
the target inequality is the natural and immediate next milestone, and it would be the
first *quantitative* (non-degenerate) packing bound in the catalog's geometry tree.

## Direction 3: Sharpness at the diameter threshold

`sphericalPackingBound_large_radius` shows at most one point fits when `r > 1`. We should
prove this is sharp and locate the exact transition: for `r ≤ 1` an antipodal pair gives
a `2r`-separated 2-element configuration, so `SphericalPackingBound n r 1` *fails* for
`r ≤ 1` (when `n ≥ 1`), and at the critical value `r = 1` (chord `2`, i.e. antipodal)
exactly two points fit.

The key insight is that the chord length between unit-sphere points equals
`2·sin(θ/2)` for geodesic angle `θ`, so the diameter-2 obstruction used in our proof is
attained *only* by antipodal pairs — making `r = 1` a genuine phase boundary rather than
an artifact of the triangle-inequality slack.

Why now? The upper bound `sphericalPackingBound_large_radius` is freshly proved with an
explicit antipodal witness already implicit in its triangle-inequality argument;
formalizing the matching lower bound is a small, self-contained companion result.

## Direction 4: Dimension-uniform caps and the simplex bound

`sphericalCapArea` is currently `S²`-specific. We should define the `S^n` cap measure
and prove the analogue of `sphericalCapArea_le_sphereArea` and
`sphericalCapArea_monotone` in every dimension, then derive the classical *simplex
bound*: for `2r ≥ π/2` (caps subtending a right angle), at most `n + 2` points fit on
`S^n`, realized by the regular simplex.

The key insight is that mutually `90°`-or-more separated unit vectors are pairwise
non-acute, and a set of pairwise non-acute unit vectors in `ℝ^{n+1}` has size at most
`n + 2` — a linear-algebra fact (rank/Gram-matrix positivity) that sidesteps measure
theory entirely and meshes with the catalog's existing Gram-matrix and inner-product
machinery.

Why now? Our monotonicity and budget-monotonicity lemmas (`sphericalCapArea_monotone`,
`sphericalPackingBound_mono_B`) are dimension-agnostic in spirit; generalizing the cap
definitions is the cross-domain step that connects this geometry module to the catalog's
linear-algebra results and yields an integer packing bound provable without analysis.

## Direction 5: Asymptotics of the distortion bound as `r → 0`

The closed form `stereoBoundS2Closed r = 8/(cos²r·(1−cos r))` should be analyzed in the
small-cap limit. Using `1 − cos r ∼ r²/2` and `cos²r → 1`, we get
`stereoBoundS2Closed r ∼ 16/r²`, matching the known `Θ(r^{-2})` growth of `S²` packing
numbers. We should prove a two-sided asymptotic `c₁/r² ≤ stereoBoundS2Closed r ≤ c₂/r²`
on a fixed interval `(0, r₀]`.

The key insight is that `stereoBoundS2_eq_closed` already gives the exact rational-trig
form, so the asymptotic reduces to elementary bounds on `cos` and `1 − cos` that
Mathlib provides (`Real.cos_le_one`, `Real.one_sub_cos_*` style estimates and
`Real.cos_lt_one`), making a fully rigorous packing-number growth rate attainable.

Why now? With the closed form proved this cycle, the order-of-growth statement is the
cheapest way to demonstrate the theory recovers the textbook `r^{-2}` packing scaling,
providing an external sanity check on the whole framework.

**Concept description**: # Future Directions: Stereographic Capacity Theory

This cycle established the algebraic and order-theoretic backbone of stereographic
capacity theory in `Geometry/StereographicCapacity/Theorems.lean`, building directly
on the definitions in `Geometry/StereographicCapacity/Defs.lean`
(`stereoFactor`, `stereoExclusionRadius`, `StereoSeparated`, `sphericalCapArea`,
`SphericalPackingBound`, `stereoBoundS2`, `stereoBoundS2Closed`). We proved that the
distortion bound collapses to a clean closed form (`stereoBoundS2_eq_closed`), that a
cap never exceeds the sphere it lives on (`sphericalCapArea_le_sphereArea`), that cap
area is monotone in geodesic radius (`sphericalCapArea_monotone`), and — the geometric
heart of the cycle — that beyond the diameter threshold only one point can be packed
(`sphericalPackingBound_large_radius`), with packing budgets behaving monotonically
(`sphericalPackingBound_mono_B`). The directions below push from these "skeleton"
results toward the genuinely quantitative packing theorems the framework was built for.

## Direction 1: The stereographic transfer principle

The defining bet of the theory is that a `StereoSeparated` Euclidean configuration is
exactly the stereographic image of a `2r`-separated spherical configuration. We should
prove the transfer lemma: if a finite set on `S^n` is `2r`-separated, then its image
under stereographic projection (excluding the north pole) is `StereoSeparated` for `r`,
and conversely. This converts `SphericalPackingBound` statements into statements about
Euclidean exclusion balls, where volume packing arguments are available.

The key insight is that the conformal factor `stereoFactor x = 2/(1+‖x‖²)` is precisely
the first-order ratio between spherical and Euclidean distance, so the exclusion radius
`stereoExclusionRadius r x = tan r / stereoFactor x` is the *correct* linearization that
makes separation transfer hold to leading order — the `tan r` (not `sin r`) is what
upgrades the leading-order statement to an exact pairwise inequality.

Why now? We already have `stereoFactor_pos` and the closed-form distortion bound; the
transfer lemma is the one missing bridge that turns every spherical packing question in
this module into a plane-geometry question, unlocking all later directions.

## Direction 2: A proved Euclidean volume packing bound for `S²`

With the transfer principle in hand, the quantity `stereoBoundS2Closed r =
8/(cos²r·(1−cos r))` should become a *theorem*, not just a definition: for suitable
`r ∈ (0, π/2)`, `SphericalPackingBound 2 r (stereoBoundS2Closed r)` holds. The proof
route is a volume/measure argument — disjoint exclusion balls of total measure at most
the measure of an enclosing region — combined with `stereoBoundS2_eq_closed` to present
the answer in closed form.

The key insight is that `stereoBoundS2_eq_closed` already isolates the *only* analytic
content (an algebraic identity), so the remaining work is purely a disjointness-of-balls
measure estimate, which Mathlib's `MeasureTheory` volume-of-ball API supports directly.

Why now? `stereoBoundS2_eq_closed` and `sphericalCapArea_le_sphereArea` are proved, so
the target inequality is the natural and immediate next milestone, and it would be the
first *quantitative* (non-degenerate) packing bound in the catalog's geometry tree.

## Direction 3: Sharpness at the diameter threshold

`sphericalPackingBound_large_radius` shows at most one point fits when `r > 1`. We should
prove this is sharp and locate the exact transition: for `r ≤ 1` an antipodal pair gives
a `2r`-separated 2-element configuration, so `SphericalPackingBound n r 1` *fails* for
`r ≤ 1` (when `n ≥ 1`), and at the critical value `r = 1` (chord `2`, i.e. antipodal)
exactly two points fit.

The key insight is that the chord length between unit-sphere points equals
`2·sin(θ/2)` for geodesic angle `θ`, so the diameter-2 obstruction used in our proof is
attained *only* by antipodal pairs — making `r = 1` a genuine phase boundary rather than
an artifact of the triangle-inequality slack.

Why now? The upper bound `sphericalPackingBound_large_radius` is freshly proved with an
explicit antipodal witness already implicit in its triangle-inequality argument;
formalizing the matching lower bound is a small, self-contained companion result.

## Direction 4: Dimension-uniform caps and the simplex bound

`sphericalCapArea` is currently `S²`-specific. We should define the `S^n` cap measure
and prove the analogue of `sphericalCapArea_le_sphereArea` and
`sphericalCapArea_monotone` in every dimension, then derive the classical *simplex
bound*: for `2r ≥ π/2` (caps subtending a right angle), at most `n + 2` points fit on
`S^n`, realized by the regular simplex.

The key insight is that mutually `90°`-or-more separated unit vectors are pairwise
non-acute, and a set of pairwise non-acute unit vectors in `ℝ^{n+1}` has size at most
`n + 2` — a linear-algebra fact (rank/Gram-matrix positivity) that sidesteps measure
theory entirely and meshes with the catalog's existing Gram-matrix and inner-product
machinery.

Why now? Our monotonicity and budget-monotonicity lemmas (`sphericalCapArea_monotone`,
`sphericalPackingBound_mono_B`) are dimension-agnostic in spirit; generalizing the cap
definitions is the cross-domain step that connects this geometry module to the catalog's
linear-algebra results and yields an integer packing bound provable without analysis.

## Direction 5: Asymptotics of the distortion bound as `r → 0`

The closed form `stereoBoundS2Closed r = 8/(cos²r·(1−cos r))` should be analyzed in the
small-cap limit. Using `1 − cos r ∼ r²/2` and `cos²r → 1`, we get
`stereoBoundS2Closed r ∼ 16/r²`, matching the known `Θ(r^{-2})` growth of `S²` packing
numbers. We should prove a two-sided asymptotic `c₁/r² ≤ stereoBoundS2Closed r ≤ c₂/r²`
on a fixed interval `(0, r₀]`.

The key insight is that `stereoBoundS2_eq_closed` already gives the exact rational-trig
form, so the asymptotic reduces to elementary bounds on `cos` and `1 − cos` that
Mathlib provides (`Real.cos_le_one`, `Real.one_sub_cos_*` style estimates and
`Real.cos_lt_one`), making a fully rigorous packing-number growth rate attainable.

Why now? With the closed form proved this cycle, the order-of-growth statement is the
cheapest way to demonstrate the theory recovers the textbook `r^{-2}` packing scaling,
providing an external sanity check on the whole framework.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Geometry
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v11 Depth Requirements -- Algorithmic & Constructive Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Algorithmic & Constructive Generation**. Prioritize concrete computation, explicit witness constructions, and algorithmic content.

### RESEARCH CORE METHODOLOGY:
1. **Constructive Witness Extraction**: Whenever asserting that an object exists, focus on constructing it explicitly. Avoid non-constructive classical axioms (like double negation elimination or classical choice) unless absolutely necessary.
2. **Computational Verification**: Build definitions that can be computationally evaluated (`#eval` or `decide`). Connect abstract algebra/topology directly to effective algorithms and discrete models.
3. **Algorithmic Complexity**: Focus on the computational power and structures of your mathematical objects, proving properties about their stability, convergence, or decidability.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
