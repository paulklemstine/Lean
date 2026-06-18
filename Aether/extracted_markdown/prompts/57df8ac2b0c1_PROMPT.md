
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

**Title**: The current formalization defines `HasLinearRegions` for individual functions bu
**Domain**: Novelty
**Mathematical framing**: # Future Directions: ReLU Network Depth-Width Trade-offs

## 1. Compositional Region Multiplication Theorem

The current formalization defines `HasLinearRegions` for individual functions but does not yet prove the composition theorem: if f has m linear regions and g has n linear regions, then f ∘ g has at most m · n linear regions. This is the core algebraic fact that underlies the exponential depth advantage.

The key insight is that on each of g's n linear pieces, g is affine, so f ∘ g restricted to that piece inherits f's piecewise structure with at most m sub-pieces. The proof requires formalizing how breakpoints of f pull back through affine maps, which involves careful interval arithmetic on sorted lists.

Why now? The `HasLinearRegions` definition and sorted breakpoint infrastructure are already in place. The main technical challenge is a lemma about interleaving breakpoint lists under affine preimages, which is purely combinatorial.

## 2. Multivariate Region Counting via Hyperplane Arrangements

The single-variable theory gives (w+1)^L regions. In d dimensions, a single ReLU layer of width w partitions ℝ^d into at most ∑_{i=0}^{d} C(w, i) regions (the Zaslavsky hyperplane arrangement bound). Formalizing this connects the network theory to combinatorial geometry.

The key insight is that each ReLU neuron in d dimensions defines a hyperplane in ℝ^d, and the number of regions of an arrangement of w hyperplanes in general position is exactly ∑_{i=0}^{d} C(w, i). This is bounded by O(w^d) for fixed d, establishing the Ω(ε^{-d}) lower bound for shallow approximation.

Why now? Mathlib has extensive combinatorics infrastructure (binomial coefficients, Finset.sum). The Zaslavsky formula itself would be a valuable standalone contribution to Mathlib, independent of the neural network application.

## 3. Universal Approximation via Stone-Weierstrass

The depth separation results show that deep networks *can* represent more complex functions, but do not prove they can approximate *any* continuous function. The classical universal approximation theorem (Cybenko 1989, Hornik 1991) follows from the Stone-Weierstrass theorem applied to the algebra generated by ReLU compositions.

The key insight is that ReLU networks separate points (given by the two-piece structure of individual neurons) and do not vanish identically, which are the hypotheses of Stone-Weierstrass. The formal proof would connect our `HasLinearRegions` machinery to `ContinuousMap` and the Stone-Weierstrass theorem in Mathlib.

Why now? Mathlib already has `stone_weierstrass_subalgebra` for subalgebras of C(X, ℝ) on compact spaces. The missing piece is showing that the set of functions representable by ReLU networks of unbounded width forms a subalgebra separating points.

## 4. Quantitative Approximation Rates: Jackson-type Bounds

Beyond existence, one wants quantitative bounds: a continuous function f with modulus of continuity ω(δ) can be ε-approximated by a depth-L width-w network when (w+1)^L ≥ C · ω⁻¹(ε)^d. For Lipschitz functions (ω(δ) = Lδ), this gives w = O(ε^{-d/L}), showing the logarithmic depth advantage: depth L = O(d · log(1/ε)) suffices with bounded width.

The key insight is that the approximation rate is controlled by the number of linear regions needed to partition the domain into cells of diameter ≤ ω⁻¹(ε), which is a covering number. The depth advantage appears because covering numbers compose multiplicatively under function composition, matching the region multiplication theorem.

Why now? The sawtooth lower bound already demonstrates that Ω(N) regions are needed for N oscillations. Formalizing the upper bound requires connecting `HasLinearRegions` to `Metric.coveringNumber` (which exists in Mathlib) and the modulus of continuity.

## 5. Depth Separation Witness: The Bit Extraction Function

Our sawtooth-based separation shows that *some* function needs many regions in a shallow network. A stronger result: the function f_L(x) = (sawtooth composed L times)(x) is computable by a depth-L network of width 3 but requires width Ω(2^L) in depth 1. This would give an explicit exponential separation.

The key insight is that iterating the tent map x ↦ min(2x, 2-2x) doubles the number of linear pieces at each step, giving 2^L pieces after L compositions. By the composition region theorem (Direction 1), a depth-1 network needs width ≥ 2^L - 1 to match this. The iterated tent map is also connected to symbolic dynamics and chaos theory.

Why now? The tent map t(x) = min(2x, 2-2x) can be expressed as 2·relu(x) - 4·relu(x - 1/2) + 2·relu(x - 1) using ReLU, which means a width-3 depth-1 network computes t, and depth-L composition gives a width-3 depth-L network for t^L. The `relu_neuron` definition and `relu_has_two_regions` theorem provide the foundation.

**Concept description**: # Future Directions: ReLU Network Depth-Width Trade-offs

## 1. Compositional Region Multiplication Theorem

The current formalization defines `HasLinearRegions` for individual functions but does not yet prove the composition theorem: if f has m linear regions and g has n linear regions, then f ∘ g has at most m · n linear regions. This is the core algebraic fact that underlies the exponential depth advantage.

The key insight is that on each of g's n linear pieces, g is affine, so f ∘ g restricted to that piece inherits f's piecewise structure with at most m sub-pieces. The proof requires formalizing how breakpoints of f pull back through affine maps, which involves careful interval arithmetic on sorted lists.

Why now? The `HasLinearRegions` definition and sorted breakpoint infrastructure are already in place. The main technical challenge is a lemma about interleaving breakpoint lists under affine preimages, which is purely combinatorial.

## 2. Multivariate Region Counting via Hyperplane Arrangements

The single-variable theory gives (w+1)^L regions. In d dimensions, a single ReLU layer of width w partitions ℝ^d into at most ∑_{i=0}^{d} C(w, i) regions (the Zaslavsky hyperplane arrangement bound). Formalizing this connects the network theory to combinatorial geometry.

The key insight is that each ReLU neuron in d dimensions defines a hyperplane in ℝ^d, and the number of regions of an arrangement of w hyperplanes in general position is exactly ∑_{i=0}^{d} C(w, i). This is bounded by O(w^d) for fixed d, establishing the Ω(ε^{-d}) lower bound for shallow approximation.

Why now? Mathlib has extensive combinatorics infrastructure (binomial coefficients, Finset.sum). The Zaslavsky formula itself would be a valuable standalone contribution to Mathlib, independent of the neural network application.

## 3. Universal Approximation via Stone-Weierstrass

The depth separation results show that deep networks *can* represent more complex functions, but do not prove they can approximate *any* continuous function. The classical universal approximation theorem (Cybenko 1989, Hornik 1991) follows from the Stone-Weierstrass theorem applied to the algebra generated by ReLU compositions.

The key insight is that ReLU networks separate points (given by the two-piece structure of individual neurons) and do not vanish identically, which are the hypotheses of Stone-Weierstrass. The formal proof would connect our `HasLinearRegions` machinery to `ContinuousMap` and the Stone-Weierstrass theorem in Mathlib.

Why now? Mathlib already has `stone_weierstrass_subalgebra` for subalgebras of C(X, ℝ) on compact spaces. The missing piece is showing that the set of functions representable by ReLU networks of unbounded width forms a subalgebra separating points.

## 4. Quantitative Approximation Rates: Jackson-type Bounds

Beyond existence, one wants quantitative bounds: a continuous function f with modulus of continuity ω(δ) can be ε-approximated by a depth-L width-w network when (w+1)^L ≥ C · ω⁻¹(ε)^d. For Lipschitz functions (ω(δ) = Lδ), this gives w = O(ε^{-d/L}), showing the logarithmic depth advantage: depth L = O(d · log(1/ε)) suffices with bounded width.

The key insight is that the approximation rate is controlled by the number of linear regions needed to partition the domain into cells of diameter ≤ ω⁻¹(ε), which is a covering number. The depth advantage appears because covering numbers compose multiplicatively under function composition, matching the region multiplication theorem.

Why now? The sawtooth lower bound already demonstrates that Ω(N) regions are needed for N oscillations. Formalizing the upper bound requires connecting `HasLinearRegions` to `Metric.coveringNumber` (which exists in Mathlib) and the modulus of continuity.

## 5. Depth Separation Witness: The Bit Extraction Function

Our sawtooth-based separation shows that *some* function needs many regions in a shallow network. A stronger result: the function f_L(x) = (sawtooth composed L times)(x) is computable by a depth-L network of width 3 but requires width Ω(2^L) in depth 1. This would give an explicit exponential separation.

The key insight is that iterating the tent map x ↦ min(2x, 2-2x) doubles the number of linear pieces at each step, giving 2^L pieces after L compositions. By the composition region theorem (Direction 1), a depth-1 network needs width ≥ 2^L - 1 to match this. The iterated tent map is also connected to symbolic dynamics and chaos theory.

Why now? The tent map t(x) = min(2x, 2-2x) can be expressed as 2·relu(x) - 4·relu(x - 1/2) + 2·relu(x - 1) using ReLU, which means a width-3 depth-1 network computes t, and depth-L composition gives a width-3 depth-L network for t^L. The `relu_neuron` definition and `relu_has_two_regions` theorem provide the foundation.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
