
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

**Title**: The current work formalizes phase transitions for one-dimensional tropical polyn
**Domain**: Applications
**Mathematical framing**: # Future Directions: Tropical Phase Transitions in Learning

## 1. Multi-dimensional tropical bifurcation and ReLU network expressivity

The current work formalizes phase transitions for one-dimensional tropical polynomials (max of affine functions in one variable). The natural extension is to ℝⁿ: a tropical polynomial in n variables is `max_i(⟨aᵢ, x⟩ + bᵢ)` where `aᵢ ∈ ℝⁿ`. The tropical hypersurface (set where the max is achieved by ≥2 monomials) is a polyhedral complex whose combinatorial structure determines the decision boundaries of a ReLU network layer.

**Conjecture**: For a tropical polynomial with m monomials in ℝⁿ, the tropical hypersurface has at most `m choose 2` facets of codimension 1, and this bound is tight. The key insight is that each facet corresponds to a pair of monomials achieving co-dominance, and the arrangement of these hyperplanes `⟨aᵢ - aⱼ, x⟩ = bⱼ - bᵢ` is governed by the same linear algebra that controls ReLU network decision boundaries.

**Why now?** The one-dimensional crossover theory is fully formalized. Extending to ℝⁿ requires formalizing tropical hypersurfaces as polyhedral complexes, which is tractable given Mathlib's growing polyhedral geometry infrastructure.

## 2. Tropical gradient flow and delayed generalization dynamics

The bifurcation theorem shows that parameter changes cause monomial dominance switches. A deeper question: what is the dynamics of these switches under gradient descent? In the tropical limit, gradient descent on a loss landscape `L(θ) = max_i fᵢ(θ)` becomes a piecewise-linear dynamical system whose trajectories follow the 1-skeleton of a polyhedral complex.

**Conjecture**: For a tropical loss landscape with k monomials, the gradient flow trajectory crosses at most `k - 1` phase boundaries before converging, and the time spent in each region is bounded below by `Ω(1/gap)` where gap is the minimum spectral gap between co-dominant monomials at a boundary. The key insight is that the "delayed generalization" phenomenon (grokking) corresponds to the trajectory spending exponential time near a phase boundary where the gap is exponentially small — a tropical analogue of the classical saddle-point slowdown.

**Why now?** The crossover monotonicity theorem (`crossover_monotone_in_gap`) provides the foundation: it shows that the phase boundary position depends continuously and monotonically on parameters, which is the first step toward analyzing gradient flow near boundaries.

## 3. Tropical Legendre duality and implicit regularization

The Legendre-Fenchel transform has a natural tropical analogue: for `f(x) = max_i(aᵢx + bᵢ)`, the tropical Legendre dual is `f*(y) = -min_i(bᵢ : aᵢ = y)` (the negative of the intercept of the monomial with slope y). This duality exchanges the "weight space" and "feature space" views of a ReLU network.

**Conjecture**: Implicit regularization in neural network training (the tendency of gradient descent to find minimum-norm solutions) corresponds to selecting the tropical polynomial whose Legendre dual has minimum total variation. The key insight is that minimum total variation of `f*` is equivalent to the Newton polygon of the tropical polynomial having minimum perimeter, which selects the "simplest" piecewise-linear function consistent with the training data.

**Why now?** The convexity theorem (`tropical_poly_convexOn`) establishes that tropical polynomials are convex, which is the essential prerequisite for Legendre duality to be well-defined and involutive.

## 4. Tropical composition and depth separation

A two-layer ReLU network computes `max_j(∑ₖ w₂ⱼₖ · max_i(w₁ₖᵢ · x + b₁ₖᵢ) + b₂ⱼ)`, which is the tropical composition of two tropical polynomials. The composition operation is not a tropical polynomial in general — it produces a "tropical rational function" (difference of two tropical polynomials).

**Conjecture**: The set of functions computable by depth-d tropical circuits with width w is strictly contained in the set computable by depth-(d+1) circuits with width w, for all d ≥ 1 and w ≥ 2. Moreover, the separation is witnessed by a function whose tropical hypersurface has a topological invariant (Betti number) that requires depth d+1 to realize. The key insight is that tropical composition can increase the number of "bends" multiplicatively, and the Betti numbers of the resulting polyhedral complex serve as a depth-lower-bound certificate.

**Why now?** The `tropical_sum_two_convexOn` and `tropical_poly_convexOn` results formalize how tropical addition (max) preserves convexity. Extending to tropical composition requires tracking how convexity interacts with the nested max-plus structure, which is the next natural step.

## 5. Quantitative grokking bounds via tropical spectral theory

The eigenvalues of tropical (max-plus) matrices control the long-term behavior of iterated tropical matrix-vector multiplication. If training dynamics can be approximated as iterated tropical linear maps `x ↦ A ⊗ x` (where ⊗ is tropical matrix multiplication), then the tropical spectral radius determines the convergence rate.

**Conjecture**: For a training process on a dataset of size n with a two-layer ReLU network of width w, the grokking time (number of epochs before generalization) is Θ(exp(n/w) · 1/λ₂) where λ₂ is the second-largest tropical eigenvalue of the weight matrix. The key insight is that the tropical eigenvalue gap λ₁ - λ₂ controls how quickly the dominant monomial separates from competitors, and the exponential factor captures the time spent in the "memorization" phase where all monomials are nearly co-dominant.

**Why now?** The bifurcation threshold theorem provides the static characterization of when dominance switches occur. The spectral theory would provide the dynamic characterization of how fast the system moves toward or away from these switch points, completing the picture.

**Concept description**: # Future Directions: Tropical Phase Transitions in Learning

## 1. Multi-dimensional tropical bifurcation and ReLU network expressivity

The current work formalizes phase transitions for one-dimensional tropical polynomials (max of affine functions in one variable). The natural extension is to ℝⁿ: a tropical polynomial in n variables is `max_i(⟨aᵢ, x⟩ + bᵢ)` where `aᵢ ∈ ℝⁿ`. The tropical hypersurface (set where the max is achieved by ≥2 monomials) is a polyhedral complex whose combinatorial structure determines the decision boundaries of a ReLU network layer.

**Conjecture**: For a tropical polynomial with m monomials in ℝⁿ, the tropical hypersurface has at most `m choose 2` facets of codimension 1, and this bound is tight. The key insight is that each facet corresponds to a pair of monomials achieving co-dominance, and the arrangement of these hyperplanes `⟨aᵢ - aⱼ, x⟩ = bⱼ - bᵢ` is governed by the same linear algebra that controls ReLU network decision boundaries.

**Why now?** The one-dimensional crossover theory is fully formalized. Extending to ℝⁿ requires formalizing tropical hypersurfaces as polyhedral complexes, which is tractable given Mathlib's growing polyhedral geometry infrastructure.

## 2. Tropical gradient flow and delayed generalization dynamics

The bifurcation theorem shows that parameter changes cause monomial dominance switches. A deeper question: what is the dynamics of these switches under gradient descent? In the tropical limit, gradient descent on a loss landscape `L(θ) = max_i fᵢ(θ)` becomes a piecewise-linear dynamical system whose trajectories follow the 1-skeleton of a polyhedral complex.

**Conjecture**: For a tropical loss landscape with k monomials, the gradient flow trajectory crosses at most `k - 1` phase boundaries before converging, and the time spent in each region is bounded below by `Ω(1/gap)` where gap is the minimum spectral gap between co-dominant monomials at a boundary. The key insight is that the "delayed generalization" phenomenon (grokking) corresponds to the trajectory spending exponential time near a phase boundary where the gap is exponentially small — a tropical analogue of the classical saddle-point slowdown.

**Why now?** The crossover monotonicity theorem (`crossover_monotone_in_gap`) provides the foundation: it shows that the phase boundary position depends continuously and monotonically on parameters, which is the first step toward analyzing gradient flow near boundaries.

## 3. Tropical Legendre duality and implicit regularization

The Legendre-Fenchel transform has a natural tropical analogue: for `f(x) = max_i(aᵢx + bᵢ)`, the tropical Legendre dual is `f*(y) = -min_i(bᵢ : aᵢ = y)` (the negative of the intercept of the monomial with slope y). This duality exchanges the "weight space" and "feature space" views of a ReLU network.

**Conjecture**: Implicit regularization in neural network training (the tendency of gradient descent to find minimum-norm solutions) corresponds to selecting the tropical polynomial whose Legendre dual has minimum total variation. The key insight is that minimum total variation of `f*` is equivalent to the Newton polygon of the tropical polynomial having minimum perimeter, which selects the "simplest" piecewise-linear function consistent with the training data.

**Why now?** The convexity theorem (`tropical_poly_convexOn`) establishes that tropical polynomials are convex, which is the essential prerequisite for Legendre duality to be well-defined and involutive.

## 4. Tropical composition and depth separation

A two-layer ReLU network computes `max_j(∑ₖ w₂ⱼₖ · max_i(w₁ₖᵢ · x + b₁ₖᵢ) + b₂ⱼ)`, which is the tropical composition of two tropical polynomials. The composition operation is not a tropical polynomial in general — it produces a "tropical rational function" (difference of two tropical polynomials).

**Conjecture**: The set of functions computable by depth-d tropical circuits with width w is strictly contained in the set computable by depth-(d+1) circuits with width w, for all d ≥ 1 and w ≥ 2. Moreover, the separation is witnessed by a function whose tropical hypersurface has a topological invariant (Betti number) that requires depth d+1 to realize. The key insight is that tropical composition can increase the number of "bends" multiplicatively, and the Betti numbers of the resulting polyhedral complex serve as a depth-lower-bound certificate.

**Why now?** The `tropical_sum_two_convexOn` and `tropical_poly_convexOn` results formalize how tropical addition (max) preserves convexity. Extending to tropical composition requires tracking how convexity interacts with the nested max-plus structure, which is the next natural step.

## 5. Quantitative grokking bounds via tropical spectral theory

The eigenvalues of tropical (max-plus) matrices control the long-term behavior of iterated tropical matrix-vector multiplication. If training dynamics can be approximated as iterated tropical linear maps `x ↦ A ⊗ x` (where ⊗ is tropical matrix multiplication), then the tropical spectral radius determines the convergence rate.

**Conjecture**: For a training process on a dataset of size n with a two-layer ReLU network of width w, the grokking time (number of epochs before generalization) is Θ(exp(n/w) · 1/λ₂) where λ₂ is the second-largest tropical eigenvalue of the weight matrix. The key insight is that the tropical eigenvalue gap λ₁ - λ₂ controls how quickly the dominant monomial separates from competitors, and the exponential factor captures the time spent in the "memorization" phase where all monomials are nearly co-dominant.

**Why now?** The bifurcation threshold theorem provides the static characterization of when dominance switches occur. The spectral theory would provide the dynamic characterization of how fast the system moves toward or away from these switch points, completing the picture.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
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
