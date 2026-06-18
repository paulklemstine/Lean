
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

**Title**: The file `Catalog/Tropical/MultivariatePhaseTransition.lean` lifts the
**Domain**: Pythagorean
**Mathematical framing**: # Future Directions: Multivariate Tropical Phase Transitions in Learning

The file `Catalog/Tropical/MultivariatePhaseTransition.lean` lifts the
one-dimensional tropical phase-transition theory (`affine_convexOn`,
`tropical_poly_convexOn`, `crossover_monotone_in_gap` in
`Catalog/Tropical/GrokPhaseTransition.lean`) into `ℝⁿ`, the regime that actually
models a ReLU layer. It establishes (i) convexity of multivariate tropical
polynomials (`mvTropical_poly_convexOn`), (ii) the `m choose 2` upper bound on
the number of tropical-hypersurface facets (`tropical_hypersurface_facet_bound`),
(iii) convexity of two-layer ReLU networks with nonnegative outer weights
(`twoLayer_relu_convexOn`), and (iv) a line-restriction bridge back to the 1-D
crossover theory (`tropical_restrict_to_line_convexOn`). The following
conjectures are the natural next frontier.

## 1. Tightness of the facet bound (generic position)

We proved that a tropical polynomial with `m` monomials in `ℝⁿ` has **at most**
`m choose 2` codimension-one facets. The matching lower bound should hold in
generic position: choose slopes `aᵢ ∈ ℝⁿ` and intercepts `bᵢ` so that every pair
of monomials achieves codominance on a nonempty relatively-open piece of the
hyperplane `⟨aᵢ - aⱼ, x⟩ = bⱼ - bᵢ`. **The key insight is** that genericity of
the intercepts makes the `m choose 2` codominance hyperplanes mutually
non-redundant, so the `CoDominant` predicate of our formalization holds for every
2-subset and the filtered cardinality equals `(#s).choose 2` exactly. **Why now?**
The upper bound is already a one-line consequence of `card_filter_le` and
`card_powersetCard`; the lower bound only requires exhibiting a single explicit
witness family and proving each pair is active, which is a finite, constructive
obligation rather than new theory.

## 2. From convexity to non-realizability lower bounds for depth

`twoLayer_relu_convexOn` shows nonnegative-weight two-layer networks compute only
convex functions. This is a *separation engine*: any non-convex target (e.g. the
"tent"/triangle function `x ↦ -|x|` shifted upward, or any function with a strict
local maximum) is provably unreachable by such networks, no matter the width.
**The key insight is** that convexity is a coordinate-free, width-independent
invariant, so a single scalar certificate — the existence of a point where the
restricted function `tropical_restrict_to_line_convexOn` fails the midpoint
inequality — rules out an entire architecture class. **Why now?** We already have
the convexity theorem and the line-restriction lemma; combining them yields a
clean "if the restriction to some line is non-convex, no nonnegative two-layer net
realizes it" corollary, the first formal depth/sign lower bound in this catalog.

## 3. Tropical Legendre duality in `ℝⁿ` and minimum-perimeter regularization

The convexity result `mvTropical_poly_convexOn` is exactly the hypothesis needed
for the Legendre–Fenchel transform to be involutive. Define the tropical dual of
`p(x) = max_i (⟨aᵢ,x⟩ + bᵢ)` as the support function of the Newton polytope
`conv{aᵢ}` weighted by `bᵢ`. **The key insight is** that implicit regularization
(gradient descent preferring minimum-norm interpolants) corresponds to selecting
the tropical polynomial whose Newton polytope has minimum perimeter/surface area,
and convexity guarantees the dual is single-valued so this selection is
well-posed. **Why now?** Convexity over `ℝⁿ` is the precise missing prerequisite,
and Mathlib's `ConvexOn` / support-function API (`ConvexOn.comp_affineMap`,
`Set.support`-style constructions) makes the dual definable today.

## 4. Composition increases facet count multiplicatively (depth separation)

A depth-`d` tropical circuit composes `d` layers; each composition can multiply
the number of linear regions. Conjecture: there is a width-`w` depth-`(d+1)`
circuit whose tropical hypersurface has strictly more facets than any width-`w`
depth-`d` circuit can produce, with the gap growing like `w^{d}`. **The key
insight is** that our facet-counting functional `tropical_hypersurface_facet_bound`
is *sub-multiplicative under tropical sum but super-additive under composition*,
so iterating the `CoDominant` construction across layers yields a facet count that
no shallower circuit can match — a combinatorial depth-lower-bound certificate.
**Why now?** The facet count is now a formally defined, monotone `Finset`
cardinality; tracking how it transforms under the (already-convexity-preserving)
two-layer map `twoLayer_relu_convexOn` is the concrete next step.

## 5. Quantitative crossover dynamics along training lines

`tropical_restrict_to_line_convexOn` says that restricting the loss landscape to
any straight line in parameter space yields a 1-D tropical polynomial, hence a
convex piecewise-linear curve with finitely many breakpoints (crossovers).
Conjecture: gradient flow projected onto such a line crosses at most `m - 1`
breakpoints, and the dwell time near a breakpoint scales as `Θ(1/gap)` in the
co-dominance gap — the tropical analogue of saddle-point slowdown that produces
delayed generalization ("grokking"). **The key insight is** that convexity of the
restriction forces the breakpoints to be *totally ordered along the line*, so the
trajectory visits them monotonically and the dwell-time analysis reduces to the
1-D `crossover_monotone_in_gap` estimate already in the catalog. **Why now?** The
line-restriction theorem converts the multivariate dynamical question into the
exact 1-D setting where the monotone-crossover machinery is fully formalized.

**Concept description**: # Future Directions: Multivariate Tropical Phase Transitions in Learning

The file `Catalog/Tropical/MultivariatePhaseTransition.lean` lifts the
one-dimensional tropical phase-transition theory (`affine_convexOn`,
`tropical_poly_convexOn`, `crossover_monotone_in_gap` in
`Catalog/Tropical/GrokPhaseTransition.lean`) into `ℝⁿ`, the regime that actually
models a ReLU layer. It establishes (i) convexity of multivariate tropical
polynomials (`mvTropical_poly_convexOn`), (ii) the `m choose 2` upper bound on
the number of tropical-hypersurface facets (`tropical_hypersurface_facet_bound`),
(iii) convexity of two-layer ReLU networks with nonnegative outer weights
(`twoLayer_relu_convexOn`), and (iv) a line-restriction bridge back to the 1-D
crossover theory (`tropical_restrict_to_line_convexOn`). The following
conjectures are the natural next frontier.

## 1. Tightness of the facet bound (generic position)

We proved that a tropical polynomial with `m` monomials in `ℝⁿ` has **at most**
`m choose 2` codimension-one facets. The matching lower bound should hold in
generic position: choose slopes `aᵢ ∈ ℝⁿ` and intercepts `bᵢ` so that every pair
of monomials achieves codominance on a nonempty relatively-open piece of the
hyperplane `⟨aᵢ - aⱼ, x⟩ = bⱼ - bᵢ`. **The key insight is** that genericity of
the intercepts makes the `m choose 2` codominance hyperplanes mutually
non-redundant, so the `CoDominant` predicate of our formalization holds for every
2-subset and the filtered cardinality equals `(#s).choose 2` exactly. **Why now?**
The upper bound is already a one-line consequence of `card_filter_le` and
`card_powersetCard`; the lower bound only requires exhibiting a single explicit
witness family and proving each pair is active, which is a finite, constructive
obligation rather than new theory.

## 2. From convexity to non-realizability lower bounds for depth

`twoLayer_relu_convexOn` shows nonnegative-weight two-layer networks compute only
convex functions. This is a *separation engine*: any non-convex target (e.g. the
"tent"/triangle function `x ↦ -|x|` shifted upward, or any function with a strict
local maximum) is provably unreachable by such networks, no matter the width.
**The key insight is** that convexity is a coordinate-free, width-independent
invariant, so a single scalar certificate — the existence of a point where the
restricted function `tropical_restrict_to_line_convexOn` fails the midpoint
inequality — rules out an entire architecture class. **Why now?** We already have
the convexity theorem and the line-restriction lemma; combining them yields a
clean "if the restriction to some line is non-convex, no nonnegative two-layer net
realizes it" corollary, the first formal depth/sign lower bound in this catalog.

## 3. Tropical Legendre duality in `ℝⁿ` and minimum-perimeter regularization

The convexity result `mvTropical_poly_convexOn` is exactly the hypothesis needed
for the Legendre–Fenchel transform to be involutive. Define the tropical dual of
`p(x) = max_i (⟨aᵢ,x⟩ + bᵢ)` as the support function of the Newton polytope
`conv{aᵢ}` weighted by `bᵢ`. **The key insight is** that implicit regularization
(gradient descent preferring minimum-norm interpolants) corresponds to selecting
the tropical polynomial whose Newton polytope has minimum perimeter/surface area,
and convexity guarantees the dual is single-valued so this selection is
well-posed. **Why now?** Convexity over `ℝⁿ` is the precise missing prerequisite,
and Mathlib's `ConvexOn` / support-function API (`ConvexOn.comp_affineMap`,
`Set.support`-style constructions) makes the dual definable today.

## 4. Composition increases facet count multiplicatively (depth separation)

A depth-`d` tropical circuit composes `d` layers; each composition can multiply
the number of linear regions. Conjecture: there is a width-`w` depth-`(d+1)`
circuit whose tropical hypersurface has strictly more facets than any width-`w`
depth-`d` circuit can produce, with the gap growing like `w^{d}`. **The key
insight is** that our facet-counting functional `tropical_hypersurface_facet_bound`
is *sub-multiplicative under tropical sum but super-additive under composition*,
so iterating the `CoDominant` construction across layers yields a facet count that
no shallower circuit can match — a combinatorial depth-lower-bound certificate.
**Why now?** The facet count is now a formally defined, monotone `Finset`
cardinality; tracking how it transforms under the (already-convexity-preserving)
two-layer map `twoLayer_relu_convexOn` is the concrete next step.

## 5. Quantitative crossover dynamics along training lines

`tropical_restrict_to_line_convexOn` says that restricting the loss landscape to
any straight line in parameter space yields a 1-D tropical polynomial, hence a
convex piecewise-linear curve with finitely many breakpoints (crossovers).
Conjecture: gradient flow projected onto such a line crosses at most `m - 1`
breakpoints, and the dwell time near a breakpoint scales as `Θ(1/gap)` in the
co-dominance gap — the tropical analogue of saddle-point slowdown that produces
delayed generalization ("grokking"). **The key insight is** that convexity of the
restriction forces the breakpoints to be *totally ordered along the line*, so the
trajectory visits them monotonically and the dwell-time analysis reduces to the
1-D `crossover_monotone_in_gap` estimate already in the catalog. **Why now?** The
line-restriction theorem converts the multivariate dynamical question into the
exact 1-D setting where the monotone-crossover machinery is fully formalized.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Pythagorean
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v12 Depth Requirements -- Speculative Specifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Speculative Specifying (Bold Conjectures)**. Target high-risk, high-reward, grand-challenge level research.

### RESEARCH CORE METHODOLOGY:
1. **Grand Challenges**: Formulate bold, surprising, and non-trivial conjectures that challenge existing intuition. Even if a complete proof cannot be achieved in this cycle, outline precise strategies, obstacles, and partial results.
2. **Deep Speculation**: Explore radical connections that seem distant or impossible at first glance. Frame your theorems as seeds for entirely new fields of study.
3. **Long-Term Roadmap**: Dedicate significant intellectual effort to detailing the proof strategies and testable predictions in your future directions, laying out a clear path for future researchers.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
