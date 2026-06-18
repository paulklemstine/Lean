
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

**Title**: The geometric convergence theorem (`gdResidual_geometric_decay`) assumes a contr
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Neural Tangent Kernel Formalization

## 1. Spectral Convergence Rate with Explicit Eigenvalue Bounds

The geometric convergence theorem (`gdResidual_geometric_decay`) assumes a contractivity constant `c < 1` as a black box. The natural next step is to relate `c` to the spectrum of the kernel matrix K: specifically, if K has eigenvalues λ₁ ≥ ... ≥ λₙ ≥ 0 and we choose η < 2/λ₁, then c = max(|1 - ηλ₁|, |1 - ηλₙ|) and the optimal learning rate is η* = 2/(λ₁ + λₙ). The key insight is that Mathlib's spectral theory for self-adjoint operators on finite-dimensional inner product spaces (`Matrix.IsHermitian.eigenvalues`) provides the eigenvalue decomposition needed to make this explicit. Why now? The PSD proof (`ntkGramMatrix_posSemidef`) and symmetry preservation (`gdUpdateOp_isSymm`) in this file give us the structural prerequisites; what remains is connecting to Mathlib's eigenvalue API and proving the operator norm bound ‖I - ηK‖ = max_i |1 - ηλ_i|.

## 2. Quantitative Kernel Perturbation and Width-Dependent Stability

The linearized model kernel constancy theorem (`linearized_residual_dynamics`) shows that the NTK is *exactly* constant for the linearized model. For the actual (nonlinear) neural network, the NTK drifts during training, but this drift vanishes as width → ∞. Formalizing this requires bounding ‖K(θ_t) - K(θ_0)‖ ≤ C/√m where m is the width. The key insight is that this reduces to a Lipschitz estimate on the Jacobian: if ‖J(θ) - J(θ₀)‖ ≤ L‖θ - θ₀‖ and the parameter displacement stays small (O(1/√m)), then the kernel perturbation is O(1/√m). Why now? The single-step perturbation bound infrastructure exists in the companion Catalog file; what's needed is a clean formalization of Jacobian Lipschitz continuity for ReLU networks and the resulting inductive bound on parameter displacement.

## 3. Loss Landscape Convexity Under Overparameterization

When K is strictly positive definite (λ_min > 0), the squared loss L(θ) = ½‖f(θ) - y‖² is locally strongly convex in the linearized regime. This gives not just convergence but a convergence *rate*: L(θ_t) ≤ (1 - ηλ_min)^{2t} L(θ_0). The key insight is that positive definiteness of the Gram matrix is equivalent to the feature vectors {∇_θ f(θ₀, x_i)} being linearly independent, which holds almost surely for random initializations when p ≥ n. Why now? The PSD result is proved; upgrading to PD requires formalizing the rank condition on the Jacobian matrix, which connects to Mathlib's `Matrix.rank` and linear independence theory.

## 4. Multi-Output NTK and Block Matrix Structure

Real neural networks have vector-valued outputs (e.g., classification with k classes). The NTK becomes a block matrix K ∈ ℝ^{nk × nk} with K_{(i,a),(j,b)} = Σ_l (∂f_a/∂θ_l)(x_i) · (∂f_b/∂θ_l)(x_j). The key insight is that this block NTK is still a Gram matrix (hence PSD), and the convergence theory generalizes by replacing Fin n with Fin n × Fin k throughout. Why now? The current formalization is parameterized by the index type `Fin n` and the proofs are largely index-agnostic; extending to product index types `Fin n × Fin k` should be a relatively mechanical generalization that tests the robustness of the proof architecture.

## 5. Connection to Reproducing Kernel Hilbert Spaces (RKHS)

The NTK defines a reproducing kernel Hilbert space H_K, and the infinite-width limit theorem states that gradient descent converges to the minimum-RKHS-norm interpolant. Formalizing this requires: (a) constructing the RKHS from a positive definite kernel function (not just a matrix), (b) proving the representer theorem (the optimal function lies in span{K(x_i, ·)}), and (c) showing that the gradient descent solution converges to this optimum. The key insight is that step (b) is a finite-dimensional projection theorem in disguise — the representer theorem follows from orthogonal projection in the RKHS, which Mathlib's inner product space theory supports. Why now? Mathlib has `InnerProductSpace` and orthogonal projection (`orthogonalProjection`); what's missing is the construction of the RKHS itself as a completion of the span of kernel sections, which would be a valuable standalone contribution to the Mathlib ecosystem.

**Concept description**: # Future Directions: Neural Tangent Kernel Formalization

## 1. Spectral Convergence Rate with Explicit Eigenvalue Bounds

The geometric convergence theorem (`gdResidual_geometric_decay`) assumes a contractivity constant `c < 1` as a black box. The natural next step is to relate `c` to the spectrum of the kernel matrix K: specifically, if K has eigenvalues λ₁ ≥ ... ≥ λₙ ≥ 0 and we choose η < 2/λ₁, then c = max(|1 - ηλ₁|, |1 - ηλₙ|) and the optimal learning rate is η* = 2/(λ₁ + λₙ). The key insight is that Mathlib's spectral theory for self-adjoint operators on finite-dimensional inner product spaces (`Matrix.IsHermitian.eigenvalues`) provides the eigenvalue decomposition needed to make this explicit. Why now? The PSD proof (`ntkGramMatrix_posSemidef`) and symmetry preservation (`gdUpdateOp_isSymm`) in this file give us the structural prerequisites; what remains is connecting to Mathlib's eigenvalue API and proving the operator norm bound ‖I - ηK‖ = max_i |1 - ηλ_i|.

## 2. Quantitative Kernel Perturbation and Width-Dependent Stability

The linearized model kernel constancy theorem (`linearized_residual_dynamics`) shows that the NTK is *exactly* constant for the linearized model. For the actual (nonlinear) neural network, the NTK drifts during training, but this drift vanishes as width → ∞. Formalizing this requires bounding ‖K(θ_t) - K(θ_0)‖ ≤ C/√m where m is the width. The key insight is that this reduces to a Lipschitz estimate on the Jacobian: if ‖J(θ) - J(θ₀)‖ ≤ L‖θ - θ₀‖ and the parameter displacement stays small (O(1/√m)), then the kernel perturbation is O(1/√m). Why now? The single-step perturbation bound infrastructure exists in the companion Catalog file; what's needed is a clean formalization of Jacobian Lipschitz continuity for ReLU networks and the resulting inductive bound on parameter displacement.

## 3. Loss Landscape Convexity Under Overparameterization

When K is strictly positive definite (λ_min > 0), the squared loss L(θ) = ½‖f(θ) - y‖² is locally strongly convex in the linearized regime. This gives not just convergence but a convergence *rate*: L(θ_t) ≤ (1 - ηλ_min)^{2t} L(θ_0). The key insight is that positive definiteness of the Gram matrix is equivalent to the feature vectors {∇_θ f(θ₀, x_i)} being linearly independent, which holds almost surely for random initializations when p ≥ n. Why now? The PSD result is proved; upgrading to PD requires formalizing the rank condition on the Jacobian matrix, which connects to Mathlib's `Matrix.rank` and linear independence theory.

## 4. Multi-Output NTK and Block Matrix Structure

Real neural networks have vector-valued outputs (e.g., classification with k classes). The NTK becomes a block matrix K ∈ ℝ^{nk × nk} with K_{(i,a),(j,b)} = Σ_l (∂f_a/∂θ_l)(x_i) · (∂f_b/∂θ_l)(x_j). The key insight is that this block NTK is still a Gram matrix (hence PSD), and the convergence theory generalizes by replacing Fin n with Fin n × Fin k throughout. Why now? The current formalization is parameterized by the index type `Fin n` and the proofs are largely index-agnostic; extending to product index types `Fin n × Fin k` should be a relatively mechanical generalization that tests the robustness of the proof architecture.

## 5. Connection to Reproducing Kernel Hilbert Spaces (RKHS)

The NTK defines a reproducing kernel Hilbert space H_K, and the infinite-width limit theorem states that gradient descent converges to the minimum-RKHS-norm interpolant. Formalizing this requires: (a) constructing the RKHS from a positive definite kernel function (not just a matrix), (b) proving the representer theorem (the optimal function lies in span{K(x_i, ·)}), and (c) showing that the gradient descent solution converges to this optimum. The key insight is that step (b) is a finite-dimensional projection theorem in disguise — the representer theorem follows from orthogonal projection in the RKHS, which Mathlib's inner product space theory supports. Why now? Mathlib has `InnerProductSpace` and orthogonal projection (`orthogonalProjection`); what's missing is the construction of the RKHS itself as a completion of the span of kernel sections, which would be a valuable standalone contribution to the Mathlib ecosystem.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
