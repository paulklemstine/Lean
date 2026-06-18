
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

**Title**: Combinatorial foundation for depth separation theorem
**Domain**: Novelty
**Mathematical framing**: # Future Directions: ML Universal Approximation — Width vs Depth Trade-offs

## Synthesis

This cycle established the combinatorial foundation for depth separation theorems in ReLU networks. We formalized the tent map `T(x) = 1 - |2x - 1|` and proved that its n-fold iterate `T^n` evaluates to 0 at even dyadic grid points and 1 at odd grid points of `{k/2^n : 0 ≤ k ≤ 2^n}`. This yields exactly `2^{n-1}` full oscillations between 0 and 1, establishing that `T^n` has exponential complexity as a function of composition depth.

The key structural insight is that the tent map acts as multiplication by 2 on `[0, 1/2]` and as reflection `x ↦ 2(1-x)` on `[1/2, 1]`, which preserves parity of dyadic indices. This parity-tracking argument is the combinatorial engine behind all depth separation results. The absolute value decomposition `|x| = relu(x) + relu(-x)` establishes that the tent map is itself a width-2 ReLU network, completing the bridge from combinatorics to neural network architecture.

What we did NOT prove: the formal connection between oscillation count and minimum network width. The missing step is a formalization of "piecewise linear functions with k breakpoints can cross a horizontal line at most k times" — a topological fact that would complete the depth separation theorem. This is the most promising immediate target.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `relu_abs_decomposition` | **proved** | Absolute value = 2-neuron ReLU network; foundational expressiveness result |
| `tent_lower_half` / `tent_upper_half` | **proved** | Piecewise linear structure of tent map enabling inductive arguments |
| `tent_iter_peak` | **proved** | Depth-n tent iteration reaches maximum 1 at scale 1/2^n; exponential resolution |
| `tent_iter_grid_even` / `tent_iter_grid_odd` | **proved** | Grid evaluation theorem: the combinatorial heart of depth separation |
| `tent_iter_oscillation_count` | **proved** | Corollary packaging the grid theorem as 2^{n-1} oscillations |

## Research Directions

### Direction 1: Piecewise Linear Crossing Bound
**Hypothesis**: A continuous piecewise linear function `f : [0,1] → ℝ` with at most `k` linear pieces can achieve both `f(x) = 0` and `f(x) = 1` at most `k` times in alternation. Formally: if `x_1 < x_2 < ... < x_{2m+1}` with `f(x_{2i}) = 0` and `f(x_{2i+1}) = 1`, then `2m + 1 ≤ 2k + 1`.
**Test**: Formalize `PiecewiseLinear` as a structure with a `Finset` of breakpoints and prove the crossing bound by induction on the number of pieces.
**Why now**: We have the oscillation count for `tent^[n]` (2^{n-1} oscillations); combining with this bound immediately yields the width lower bound `w ≥ 2^{n-1} - 1` for depth-1 approximation.
**If true**: Completes the formal depth separation theorem: depth-n constant-width ReLU networks are exponentially more expressive than depth-1.
**If false**: Would imply pathological piecewise linear functions exist — unlikely but would be a significant finding in real analysis.

### Direction 2: Continuity of Iterated Tent Maps
**Hypothesis**: `tent^[n]` is continuous on `[0,1]` for all `n`.
**Test**: Prove `ContinuousOn tent (Set.Icc 0 1)` using `continuous_sub`, `continuous_abs`, then lift to iterates by `ContinuousOn.comp`.
**Why now**: The algebraic properties (tent_lower_half, tent_upper_half) are proved; continuity is a direct consequence of continuity of `|·|` and affine maps.
**If true**: Enables application of the Intermediate Value Theorem to convert oscillation counts into rigorous crossing counts, strengthening Direction 1.
**If false**: Not possible — this is certainly true, but the formalization might reveal interesting difficulties with `ContinuousOn` for function iterates.

### Direction 3: Multivariate Extension via Tensor Products
**Hypothesis**: For the n-dimensional cube `[-1,1]^n`, the width-(n+4) depth-L ReLU network class can approximate any continuous function to ε accuracy, with the approximation error controlled by the modulus of continuity.
**Test**: Define `ReLUNetwork (n d w : ℕ)` as a structure (weight matrices + bias vectors), define its evaluation function, and prove that the 1D tent map approximation lifts to tensor products `T^L(x_1) · T^L(x_2) · ... · T^L(x_n)`.
**Why now**: The 1D oscillation machinery is complete. The tensor product construction is the standard route from 1D to nD approximation.
**If true**: Gives the first formal proof of the width bound `n+4` from Kidger-Lyons (2020) in a theorem prover.
**If false**: Would indicate that the tensor product construction loses more width than expected — potentially interesting for network architecture design.

### Direction 4: Sharp Width-Depth Product Bounds
**Hypothesis**: For approximating Lipschitz-L functions on `[0,1]` to accuracy ε with ReLU networks, the optimal width × depth product satisfies `W · D = Θ(L/ε)`, with depth-1 requiring `W = Ω(L/ε)` but depth-D requiring only `W = O(L/(ε·D) + 1)`.
**Test**: Use the tent map grid theorem to construct explicit approximations achieving the upper bound, and use the crossing bound (Direction 1) for the lower bound.
**Why now**: The grid theorem gives exact control over oscillation at each depth; converting oscillation count to approximation quality is the natural next step.
**If true**: Gives the first mechanized proof of optimal width-depth trade-offs, resolving a question from approximation theory.
**If false**: The constants might differ from the conjectured bounds, which would be interesting for practitioners tuning architecture hyperparameters.

### Direction 5: Depth Separation for Smooth Functions
**Hypothesis**: There exist C^∞ functions on [0,1] that require exponentially more neurons in depth-1 networks than in depth-L networks to approximate to accuracy ε, even though the tent map examples are only piecewise linear.
**Test**: Mollify `tent^[n]` with a smooth kernel of width `δ = 1/2^{n+2}` and show the smoothed version retains `2^{n-1} - O(1)` oscillations while gaining smoothness.
**Why now**: The discrete oscillation structure (`tent_iter_grid_even/odd`) gives explicit control points that survive mollification.
**If true**: Extends depth separation from piecewise linear to smooth function classes, matching known informal results by Telgarsky (2016) and Eldan-Shamir (2016).
**If false**: Would suggest that smoothness fundamentally changes the depth-width trade-off — a major finding for understanding why deep networks excel at smooth functions.

**Concept description**: # Future Directions: ML Universal Approximation — Width vs Depth Trade-offs

## Synthesis

This cycle established the combinatorial foundation for depth separation theorems in ReLU networks. We formalized the tent map `T(x) = 1 - |2x - 1|` and proved that its n-fold iterate `T^n` evaluates to 0 at even dyadic grid points and 1 at odd grid points of `{k/2^n : 0 ≤ k ≤ 2^n}`. This yields exactly `2^{n-1}` full oscillations between 0 and 1, establishing that `T^n` has exponential complexity as a function of composition depth.

The key structural insight is that the tent map acts as multiplication by 2 on `[0, 1/2]` and as reflection `x ↦ 2(1-x)` on `[1/2, 1]`, which preserves parity of dyadic indices. This parity-tracking argument is the combinatorial engine behind all depth separation results. The absolute value decomposition `|x| = relu(x) + relu(-x)` establishes that the tent map is itself a width-2 ReLU network, completing the bridge from combinatorics to neural network architecture.

What we did NOT prove: the formal connection between oscillation count and minimum network width. The missing step is a formalization of "piecewise linear functions with k breakpoints can cross a horizontal line at most k times" — a topological fact that would complete the depth separation theorem. This is the most promising immediate target.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `relu_abs_decomposition` | **proved** | Absolute value = 2-neuron ReLU network; foundational expressiveness result |
| `tent_lower_half` / `tent_upper_half` | **proved** | Piecewise linear structure of tent map enabling inductive arguments |
| `tent_iter_peak` | **proved** | Depth-n tent iteration reaches maximum 1 at scale 1/2^n; exponential resolution |
| `tent_iter_grid_even` / `tent_iter_grid_odd` | **proved** | Grid evaluation theorem: the combinatorial heart of depth separation |
| `tent_iter_oscillation_count` | **proved** | Corollary packaging the grid theorem as 2^{n-1} oscillations |

## Research Directions

### Direction 1: Piecewise Linear Crossing Bound
**Hypothesis**: A continuous piecewise linear function `f : [0,1] → ℝ` with at most `k` linear pieces can achieve both `f(x) = 0` and `f(x) = 1` at most `k` times in alternation. Formally: if `x_1 < x_2 < ... < x_{2m+1}` with `f(x_{2i}) = 0` and `f(x_{2i+1}) = 1`, then `2m + 1 ≤ 2k + 1`.
**Test**: Formalize `PiecewiseLinear` as a structure with a `Finset` of breakpoints and prove the crossing bound by induction on the number of pieces.
**Why now**: We have the oscillation count for `tent^[n]` (2^{n-1} oscillations); combining with this bound immediately yields the width lower bound `w ≥ 2^{n-1} - 1` for depth-1 approximation.
**If true**: Completes the formal depth separation theorem: depth-n constant-width ReLU networks are exponentially more expressive than depth-1.
**If false**: Would imply pathological piecewise linear functions exist — unlikely but would be a significant finding in real analysis.

### Direction 2: Continuity of Iterated Tent Maps
**Hypothesis**: `tent^[n]` is continuous on `[0,1]` for all `n`.
**Test**: Prove `ContinuousOn tent (Set.Icc 0 1)` using `continuous_sub`, `continuous_abs`, then lift to iterates by `ContinuousOn.comp`.
**Why now**: The algebraic properties (tent_lower_half, tent_upper_half) are proved; continuity is a direct consequence of continuity of `|·|` and affine maps.
**If true**: Enables application of the Intermediate Value Theorem to convert oscillation counts into rigorous crossing counts, strengthening Direction 1.
**If false**: Not possible — this is certainly true, but the formalization might reveal interesting difficulties with `ContinuousOn` for function iterates.

### Direction 3: Multivariate Extension via Tensor Products
**Hypothesis**: For the n-dimensional cube `[-1,1]^n`, the width-(n+4) depth-L ReLU network class can approximate any continuous function to ε accuracy, with the approximation error controlled by the modulus of continuity.
**Test**: Define `ReLUNetwork (n d w : ℕ)` as a structure (weight matrices + bias vectors), define its evaluation function, and prove that the 1D tent map approximation lifts to tensor products `T^L(x_1) · T^L(x_2) · ... · T^L(x_n)`.
**Why now**: The 1D oscillation machinery is complete. The tensor product construction is the standard route from 1D to nD approximation.
**If true**: Gives the first formal proof of the width bound `n+4` from Kidger-Lyons (2020) in a theorem prover.
**If false**: Would indicate that the tensor product construction loses more width than expected — potentially interesting for network architecture design.

### Direction 4: Sharp Width-Depth Product Bounds
**Hypothesis**: For approximating Lipschitz-L functions on `[0,1]` to accuracy ε with ReLU networks, the optimal width × depth product satisfies `W · D = Θ(L/ε)`, with depth-1 requiring `W = Ω(L/ε)` but depth-D requiring only `W = O(L/(ε·D) + 1)`.
**Test**: Use the tent map grid theorem to construct explicit approximations achieving the upper bound, and use the crossing bound (Direction 1) for the lower bound.
**Why now**: The grid theorem gives exact control over oscillation at each depth; converting oscillation count to approximation quality is the natural next step.
**If true**: Gives the first mechanized proof of optimal width-depth trade-offs, resolving a question from approximation theory.
**If false**: The constants might differ from the conjectured bounds, which would be interesting for practitioners tuning architecture hyperparameters.

### Direction 5: Depth Separation for Smooth Functions
**Hypothesis**: There exist C^∞ functions on [0,1] that require exponentially more neurons in depth-1 networks than in depth-L networks to approximate to accuracy ε, even though the tent map examples are only piecewise linear.
**Test**: Mollify `tent^[n]` with a smooth kernel of width `δ = 1/2^{n+2}` and show the smoothed version retains `2^{n-1} - O(1)` oscillations while gaining smoothness.
**Why now**: The discrete oscillation structure (`tent_iter_grid_even/odd`) gives explicit control points that survive mollification.
**If true**: Extends depth separation from piecewise linear to smooth function classes, matching known informal results by Telgarsky (2016) and Eldan-Shamir (2016).
**If false**: Would suggest that smoothness fundamentally changes the depth-width trade-off — a major finding for understanding why deep networks excel at smooth functions.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Synthetic Catalog Integration Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Synthetic Catalog Integration**. Focus on building a coherent body of work on top of our existing catalog.

### RESEARCH CORE METHODOLOGY:
1. **Lineage Synthesis**: Analyze the existing catalog context deeply. Do not reinvent definitions; import and build directly on top of the validated catalog results.
2. **Connect the Dots**: Search for "orphan" results or gaps in the catalog and construct bridges to connect them. Show how new theorems advance the overall mathematical architecture of the repository.
3. **Foundational Extension**: Take successful packages from the catalog and extend their results to broader algebraic settings, sharper bounds, or new domain applications.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
