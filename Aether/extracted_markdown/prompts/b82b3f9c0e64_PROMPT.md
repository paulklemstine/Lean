
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

**Title**: The breakpoint count bound we proved (`TropPoly.breakpoint_count_le`) shows that
**Domain**: MachineLearning
**Mathematical framing**: # Future Directions: Tropical Compactification of Moduli Spaces

## 1. Tropical Polynomial Root Multiplicity and the Fundamental Theorem

The breakpoint count bound we proved (`TropPoly.breakpoint_count_le`) shows that
a tropical polynomial with n terms and distinct slopes has at most n-1 breakpoints.
The natural next step is to define **tropical root multiplicity** as the change in
slope at each breakpoint and prove the **Fundamental Theorem of Tropical Algebra**:
the sum of all tropical root multiplicities equals the degree of the tropical polynomial.

The key insight is that the multiplicity at a breakpoint x where slopes change from
s_i to s_j is exactly |s_j - s_i|, and the total multiplicity telescopes to
max(slopes) - min(slopes) = degree.

Why now? We have the convexity framework (`TropPoly.eval_convexOn`) and the
breakpoint finiteness result. The multiplicity definition is a straightforward
extension, and the telescoping argument reduces to a finite sum manipulation
that the current infrastructure can support.

## 2. Tropical Matrix Closure and the Floyd-Warshall Correspondence

Our tropical matrix algebra file establishes the semiring-like structure of
min-plus matrices. The critical next result is to define the **Kleene star**
(tropical matrix closure) A* = I ⊕ A ⊕ A² ⊕ ⋯ and prove that for matrices
without negative-weight cycles, A* converges in at most n-1 steps and computes
all-pairs shortest paths.

The key insight is that the tropical matrix power A^k at entry (i,j) gives the
minimum-weight k-hop path from i to j. By the pigeonhole principle, if there are
no negative cycles, any shortest path visits at most n-1 intermediate vertices,
so A^(n-1) already contains all shortest path weights.

Why now? The idempotent semiring structure (`tropAdd_idem`, `tropAdd_assoc`) is
in place. The convergence argument requires only showing that the decreasing
sequence A^k_{ij} stabilizes, which follows from the finiteness of the Fin n
index set combined with the well-ordering of WithTop ℝ.

## 3. Tropical Determinant and Permanent Coincidence via Sign Cancellation

In classical algebra, det(A) involves signs while permanent(A) does not. Over the
tropical semiring, both reduce to the same optimization problem: finding the
minimum-weight perfect matching. Formalizing this **tropical det = perm** identity
and connecting it to the Hungarian algorithm would bridge our matrix algebra with
combinatorial optimization.

The key insight is that in the tropical semiring, addition (= min) is idempotent,
so negative signs cannot cancel — the sign of each permutation term becomes
irrelevant. More precisely, for any permutation σ, the sign (-1)^σ acts trivially
under the tropicalization functor because min(a, a) = a.

Why now? The tropical matrix type and operations are defined. The connection to
permutation groups requires only Mathlib's `Equiv.Perm` and `Finset.univ` over
`Equiv.Perm (Fin n)`, which are mature parts of the library.

## 4. Legendre-Fenchel Duality for Tropical Polynomials

Our result `TropPoly.eval_eq_iSup` shows that tropical polynomial evaluation
equals the supremum of affine functions. This is precisely the **Legendre-Fenchel
transform** of a discrete measure. The conjecture is that the tropical polynomial
can be recovered from its Legendre dual, establishing a bijection between tropical
polynomials and their Newton polygons.

The key insight is that for convex piecewise-linear functions (which tropical
polynomials are), the Legendre-Fenchel transform is an involution. The dual of
max_i(a_i·x + b_i) is the convex hull of the points (a_i, b_i), which is
exactly the Newton polygon. This involution provides a canonical way to read
off the tropical polynomial from its Newton polygon.

Why now? The convexity result (`TropPoly.eval_convexOn`) and the iSup
characterization are proven. Mathlib has `ConvexOn` and support for convex
conjugates via `inner_le_Lnorm_mul_Lnorm` and related results. The remaining
gap is defining the tropical Legendre transform and showing involutivity for
piecewise-linear functions.

## 5. Tropical Compactification via Toric Fans

The original motivation — connecting tropical compactification of moduli spaces
to toric varieties — requires defining **tropical fans** as polyhedral complexes
satisfying the balancing condition. The conjecture is that every tropical curve
of genus g corresponds to a cone in the modular fan Δ_g, and the resulting toric
variety is the Deligne-Mumford compactification M̄_g.

The key insight is that the dual graph of a stable curve (with edge lengths going
to zero) naturally defines a tropical curve, and the combinatorial types of these
dual graphs stratify M̄_g. Each stratum corresponds to a cone in a fan, and the
toric variety of this fan recovers the compactification.

Why now? The foundations we have built — tropical polynomial theory, breakpoint
counting, matrix algebra — provide the computational backbone. The next step
requires defining polyhedral fans and the balancing condition, which are
geometric concepts that can be built from Mathlib's existing affine geometry
and polyhedral combinatorics modules.

**Concept description**: # Future Directions: Tropical Compactification of Moduli Spaces

## 1. Tropical Polynomial Root Multiplicity and the Fundamental Theorem

The breakpoint count bound we proved (`TropPoly.breakpoint_count_le`) shows that
a tropical polynomial with n terms and distinct slopes has at most n-1 breakpoints.
The natural next step is to define **tropical root multiplicity** as the change in
slope at each breakpoint and prove the **Fundamental Theorem of Tropical Algebra**:
the sum of all tropical root multiplicities equals the degree of the tropical polynomial.

The key insight is that the multiplicity at a breakpoint x where slopes change from
s_i to s_j is exactly |s_j - s_i|, and the total multiplicity telescopes to
max(slopes) - min(slopes) = degree.

Why now? We have the convexity framework (`TropPoly.eval_convexOn`) and the
breakpoint finiteness result. The multiplicity definition is a straightforward
extension, and the telescoping argument reduces to a finite sum manipulation
that the current infrastructure can support.

## 2. Tropical Matrix Closure and the Floyd-Warshall Correspondence

Our tropical matrix algebra file establishes the semiring-like structure of
min-plus matrices. The critical next result is to define the **Kleene star**
(tropical matrix closure) A* = I ⊕ A ⊕ A² ⊕ ⋯ and prove that for matrices
without negative-weight cycles, A* converges in at most n-1 steps and computes
all-pairs shortest paths.

The key insight is that the tropical matrix power A^k at entry (i,j) gives the
minimum-weight k-hop path from i to j. By the pigeonhole principle, if there are
no negative cycles, any shortest path visits at most n-1 intermediate vertices,
so A^(n-1) already contains all shortest path weights.

Why now? The idempotent semiring structure (`tropAdd_idem`, `tropAdd_assoc`) is
in place. The convergence argument requires only showing that the decreasing
sequence A^k_{ij} stabilizes, which follows from the finiteness of the Fin n
index set combined with the well-ordering of WithTop ℝ.

## 3. Tropical Determinant and Permanent Coincidence via Sign Cancellation

In classical algebra, det(A) involves signs while permanent(A) does not. Over the
tropical semiring, both reduce to the same optimization problem: finding the
minimum-weight perfect matching. Formalizing this **tropical det = perm** identity
and connecting it to the Hungarian algorithm would bridge our matrix algebra with
combinatorial optimization.

The key insight is that in the tropical semiring, addition (= min) is idempotent,
so negative signs cannot cancel — the sign of each permutation term becomes
irrelevant. More precisely, for any permutation σ, the sign (-1)^σ acts trivially
under the tropicalization functor because min(a, a) = a.

Why now? The tropical matrix type and operations are defined. The connection to
permutation groups requires only Mathlib's `Equiv.Perm` and `Finset.univ` over
`Equiv.Perm (Fin n)`, which are mature parts of the library.

## 4. Legendre-Fenchel Duality for Tropical Polynomials

Our result `TropPoly.eval_eq_iSup` shows that tropical polynomial evaluation
equals the supremum of affine functions. This is precisely the **Legendre-Fenchel
transform** of a discrete measure. The conjecture is that the tropical polynomial
can be recovered from its Legendre dual, establishing a bijection between tropical
polynomials and their Newton polygons.

The key insight is that for convex piecewise-linear functions (which tropical
polynomials are), the Legendre-Fenchel transform is an involution. The dual of
max_i(a_i·x + b_i) is the convex hull of the points (a_i, b_i), which is
exactly the Newton polygon. This involution provides a canonical way to read
off the tropical polynomial from its Newton polygon.

Why now? The convexity result (`TropPoly.eval_convexOn`) and the iSup
characterization are proven. Mathlib has `ConvexOn` and support for convex
conjugates via `inner_le_Lnorm_mul_Lnorm` and related results. The remaining
gap is defining the tropical Legendre transform and showing involutivity for
piecewise-linear functions.

## 5. Tropical Compactification via Toric Fans

The original motivation — connecting tropical compactification of moduli spaces
to toric varieties — requires defining **tropical fans** as polyhedral complexes
satisfying the balancing condition. The conjecture is that every tropical curve
of genus g corresponds to a cone in the modular fan Δ_g, and the resulting toric
variety is the Deligne-Mumford compactification M̄_g.

The key insight is that the dual graph of a stable curve (with edge lengths going
to zero) naturally defines a tropical curve, and the combinatorial types of these
dual graphs stratify M̄_g. Each stratum corresponds to a cone in a fan, and the
toric variety of this fan recovers the compactification.

Why now? The foundations we have built — tropical polynomial theory, breakpoint
counting, matrix algebra — provide the computational backbone. The next step
requires defining polyhedral fans and the balancing condition, which are
geometric concepts that can be built from Mathlib's existing affine geometry
and polyhedral combinatorics modules.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: MachineLearning
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v10 Depth Requirements -- Conceptual Unifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Grothendieck style)**. Search for deep, hidden structures, universal patterns, and bridges across domains.

### RESEARCH CORE METHODOLOGY:
1. **Abstract Structural Patterns**: Frame your objects and mappings in terms of universal structures, symmetries, and invariant properties. Look for the underlying categorical, topological, or algebraic foundations that make the specific problem a special case of a deeper truth.
2. **Cross-Domain Bridges**: Connect apparently distinct mathematical worlds (e.g. applying algebraic structures to computational complexity, or geometry to logic).
3. **Generalization Over Specialization**: Prefer elegant, universal formulations that unify multiple separate facts into single, coherent conceptual frameworks.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
