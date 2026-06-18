
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

**Title**: Extend the novelty certification framework from individual points to *sets*,
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Certified Novelty Detection in Metric Spaces

## 1. Hausdorff Distance Novelty for Convex Bodies

Extend the novelty certification framework from individual points to *sets*,
using Hausdorff distance as the separation metric. For convex bodies in ℝⁿ,
the Hausdorff distance between convex hulls of finite point sets is
computable, and novelty of a new convex body could be certified by showing
its Hausdorff distance exceeds a threshold from all reference bodies.

The key insight is that the Hausdorff distance on compact convex sets in ℝⁿ
forms a proper metric space (Blaschke's selection theorem), so the
noveltyRegion_isOpen theorem lifts to the space of convex bodies, giving
stability of set-level novelty certificates for free.

Why now? Mathlib already has `Metric.hausdorffDist` and basic convexity
infrastructure. The main gap is connecting `hausdorffDist` with `Finset`-based
convex hull computations, which is a tractable formalization target.

## 2. Dimension-Dependent Novelty Bounds via Johnson-Lindenstrauss

Prove that random linear projections ℝⁿ → ℝᵈ (d = O(log |S| / ε²)) preserve
novelty certificates with high probability: if a point is r-novel in the
original space, it remains (1-ε)r-novel in the projection with probability
≥ 1 - δ. This would formalize the theoretical foundation for practical
high-dimensional novelty detection.

The key insight is combining our Lipschitz transfer theorem with the
Johnson-Lindenstrauss lemma: random projections are (1+ε)-Lipschitz with
high probability, so our `lipschitz_novelty_transfer` theorem applies with
K = 1+ε, giving quantitative bounds on the threshold inflation needed.

Why now? The JL lemma itself is not yet in Mathlib but has been formalized
in other proof assistants. Formalizing even a weak version (e.g., for
Gaussian projections) would immediately compose with our framework.

## 3. Novelty Certificates for Riemannian Manifolds

Generalize the framework from metric spaces to Riemannian manifolds, where
the "distance" is geodesic distance. The noveltyRegion_isOpen theorem should
generalize directly since geodesic distance is continuous. The Lipschitz
transfer theorem would apply to smooth maps between manifolds with bounded
differential (where K = sup ‖df‖).

The key insight is that on a complete Riemannian manifold, the geodesic
distance function is 1-Lipschitz in each variable (by the triangle inequality),
so the continuity argument in noveltyRegion_isOpen transfers verbatim. The
interesting new content is bounding the Lipschitz constant of the exponential
map to enable local-to-global certificate transfer.

Why now? Mathlib's manifold infrastructure (`SmoothManifoldWithCorners`,
`ContMDiff`) has matured significantly. The missing piece is a formal
connection between the Riemannian metric tensor and the induced geodesic
distance as a `MetricSpace` instance — a challenging but well-defined target.

## 4. Persistent Novelty and Filtration Stability

Define a *persistent novelty certificate* that tracks how the novelty status
of a point changes as the threshold r varies from 0 to ∞. The "birth time"
of novelty is the infimum of r values for which x is r-novel (i.e., the
distance to the nearest reference point). This connects our framework to
persistent homology — the novelty region for threshold r is the complement
of the Čech complex's union of balls.

The key insight is that our `noveltyRegion_threshold_antitone` theorem already
establishes the filtration structure: {noveltyRegion S r}_{r≥0} is a
decreasing family of open sets. The persistent novelty "barcode" of a point
is simply the interval [d(x, S), ∞), where d(x, S) = inf_{s∈S} d(x, s).
Formalizing this connection would bridge certified novelty detection with
topological data analysis.

Why now? The monotonicity infrastructure is already in place. The key
formalization target is showing that the map r ↦ noveltyRegion S r is
right-continuous in the Hausdorff metric on open sets, which follows from
the continuity of distance functions.

## 5. Compositional Certification with Error Bounds

Extend the composed_novelty_transfer theorem to handle *approximate* Lipschitz
maps — functions that are Lipschitz up to an additive error ε. This models
practical scenarios where embedding functions (e.g., neural networks) satisfy
dist(f(x), f(y)) ≤ K · dist(x, y) + ε rather than exact Lipschitz bounds.
The certificate transfer would then require threshold inflation by both the
multiplicative factor K and the additive error ε.

The key insight is that "approximate Lipschitz" maps compose: if f is
(K₁, ε₁)-approximately Lipschitz and g is (K₂, ε₂)-approximately Lipschitz,
then g ∘ f is (K₂·K₁, K₂·ε₁ + ε₂)-approximately Lipschitz. This
multiplicative accumulation of errors through layers gives concrete bounds on
how many embedding layers can be composed before the certificate becomes
vacuous (threshold exceeds the space diameter).

Why now? The exact Lipschitz composition theorem is already proven. The
approximate version requires only straightforward algebraic manipulation
of the error bounds, making it an immediately tractable extension.

**Concept description**: # Future Directions: Certified Novelty Detection in Metric Spaces

## 1. Hausdorff Distance Novelty for Convex Bodies

Extend the novelty certification framework from individual points to *sets*,
using Hausdorff distance as the separation metric. For convex bodies in ℝⁿ,
the Hausdorff distance between convex hulls of finite point sets is
computable, and novelty of a new convex body could be certified by showing
its Hausdorff distance exceeds a threshold from all reference bodies.

The key insight is that the Hausdorff distance on compact convex sets in ℝⁿ
forms a proper metric space (Blaschke's selection theorem), so the
noveltyRegion_isOpen theorem lifts to the space of convex bodies, giving
stability of set-level novelty certificates for free.

Why now? Mathlib already has `Metric.hausdorffDist` and basic convexity
infrastructure. The main gap is connecting `hausdorffDist` with `Finset`-based
convex hull computations, which is a tractable formalization target.

## 2. Dimension-Dependent Novelty Bounds via Johnson-Lindenstrauss

Prove that random linear projections ℝⁿ → ℝᵈ (d = O(log |S| / ε²)) preserve
novelty certificates with high probability: if a point is r-novel in the
original space, it remains (1-ε)r-novel in the projection with probability
≥ 1 - δ. This would formalize the theoretical foundation for practical
high-dimensional novelty detection.

The key insight is combining our Lipschitz transfer theorem with the
Johnson-Lindenstrauss lemma: random projections are (1+ε)-Lipschitz with
high probability, so our `lipschitz_novelty_transfer` theorem applies with
K = 1+ε, giving quantitative bounds on the threshold inflation needed.

Why now? The JL lemma itself is not yet in Mathlib but has been formalized
in other proof assistants. Formalizing even a weak version (e.g., for
Gaussian projections) would immediately compose with our framework.

## 3. Novelty Certificates for Riemannian Manifolds

Generalize the framework from metric spaces to Riemannian manifolds, where
the "distance" is geodesic distance. The noveltyRegion_isOpen theorem should
generalize directly since geodesic distance is continuous. The Lipschitz
transfer theorem would apply to smooth maps between manifolds with bounded
differential (where K = sup ‖df‖).

The key insight is that on a complete Riemannian manifold, the geodesic
distance function is 1-Lipschitz in each variable (by the triangle inequality),
so the continuity argument in noveltyRegion_isOpen transfers verbatim. The
interesting new content is bounding the Lipschitz constant of the exponential
map to enable local-to-global certificate transfer.

Why now? Mathlib's manifold infrastructure (`SmoothManifoldWithCorners`,
`ContMDiff`) has matured significantly. The missing piece is a formal
connection between the Riemannian metric tensor and the induced geodesic
distance as a `MetricSpace` instance — a challenging but well-defined target.

## 4. Persistent Novelty and Filtration Stability

Define a *persistent novelty certificate* that tracks how the novelty status
of a point changes as the threshold r varies from 0 to ∞. The "birth time"
of novelty is the infimum of r values for which x is r-novel (i.e., the
distance to the nearest reference point). This connects our framework to
persistent homology — the novelty region for threshold r is the complement
of the Čech complex's union of balls.

The key insight is that our `noveltyRegion_threshold_antitone` theorem already
establishes the filtration structure: {noveltyRegion S r}_{r≥0} is a
decreasing family of open sets. The persistent novelty "barcode" of a point
is simply the interval [d(x, S), ∞), where d(x, S) = inf_{s∈S} d(x, s).
Formalizing this connection would bridge certified novelty detection with
topological data analysis.

Why now? The monotonicity infrastructure is already in place. The key
formalization target is showing that the map r ↦ noveltyRegion S r is
right-continuous in the Hausdorff metric on open sets, which follows from
the continuity of distance functions.

## 5. Compositional Certification with Error Bounds

Extend the composed_novelty_transfer theorem to handle *approximate* Lipschitz
maps — functions that are Lipschitz up to an additive error ε. This models
practical scenarios where embedding functions (e.g., neural networks) satisfy
dist(f(x), f(y)) ≤ K · dist(x, y) + ε rather than exact Lipschitz bounds.
The certificate transfer would then require threshold inflation by both the
multiplicative factor K and the additive error ε.

The key insight is that "approximate Lipschitz" maps compose: if f is
(K₁, ε₁)-approximately Lipschitz and g is (K₂, ε₂)-approximately Lipschitz,
then g ∘ f is (K₂·K₁, K₂·ε₁ + ε₂)-approximately Lipschitz. This
multiplicative accumulation of errors through layers gives concrete bounds on
how many embedding layers can be composed before the certificate becomes
vacuous (threshold exceeds the space diameter).

Why now? The exact Lipschitz composition theorem is already proven. The
approximate version requires only straightforward algebraic manipulation
of the error bounds, making it an immediately tractable extension.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Conceptual Unifier: Duality & Representation Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Duality & Representation)**. Search for deep dualities, representation theorems, and dual translations (such as Stone duality, Gelfand duality, or Fourier/Pontryagin dualities).

### RESEARCH CORE METHODOLOGY:
1. **Dual Translations**: Look for dual formulations of your mathematical objects. Translate geometric or topological spaces into algebraic representations (e.g. rings of functions), and algebraic structures back into geometric spaces.
2. **Representation Theorems**: Seek to represent abstract algebraic or topological structures as concrete operations on simpler, well-understood spaces (e.g. matrices, sets, or functions).
3. **Spectral Perspectives**: Leverage spectral properties, duality pairings, and transform methods to translate hard problems in the primary space into easier problems in the dual space.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
