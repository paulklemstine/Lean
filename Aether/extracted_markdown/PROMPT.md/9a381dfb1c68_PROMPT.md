
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

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

**Title**: Foundational analytic infrastructure for formalizing
**Domain**: Computation
**Mathematical framing**: # Future Directions: Diffusion Models as SDEs

## Synthesis

This cycle established the foundational analytic infrastructure for formalizing score-based diffusion models in Lean 4. We formalized the Ornstein-Uhlenbeck process through its deterministic signatures — mean decay, variance convergence, and information-theoretic properties — rather than attempting to axiomatize Itô calculus (which Mathlib lacks). The key structural insight is that the convergence theory of diffusion models can be cleanly decomposed into: (1) exponential decay of moments, (2) universality of the stationary distribution, and (3) information-theoretic monotonicity via KL divergence.

All five theorems were proved without sorry, using only standard axioms. The KL divergence nonnegativity proof (Gibbs' inequality for Gaussians) was the most technically interesting — it reduced to the fundamental inequality log(x) ≤ x − 1 via careful rewriting of log ratios. The variance positivity result ensures the Gaussian marginals remain well-defined throughout the process, which is a prerequisite for the KL divergence to be meaningful.

The main limitation of this cycle is that we work entirely at the level of moment equations rather than stochastic processes. The connection between the moment evolution and the actual SDE is assumed, not proved. Bridging this gap requires either formalizing Itô calculus or adopting an abstract categorical/measure-theoretic approach to Markov processes.

## Results Summary

- `ou_mean_tendsto_zero`: proved — OU mean decays exponentially to 0, formalizing the "forgetting" property of diffusion models
- `ou_variance_tendsto_stationary`: proved — OU variance converges to σ²/(2θ) universally, independent of initial variance
- `kl_div_gaussian_self_eq_zero`: proved — KL divergence is zero for identical distributions (identity of indiscernibles)
- `kl_div_gaussian_nonneg`: proved — Gibbs' inequality specialized to Gaussians, foundation for convergence guarantees
- `ou_variance_pos`: proved — OU variance remains positive, ensuring well-definedness of Gaussian marginals

## Research Directions

### Direction 1: Monotone KL Divergence Along the OU Flow
**Hypothesis**: For the OU process with θ > 0, the KL divergence from the time-t marginal to the stationary distribution, expressed as `klDivGaussian (ouMean m₀ θ t) (ouVariance v₀ σsq θ t) 0 (ouStationaryVariance σsq θ)`, is monotonically decreasing in t for t ≥ 0.
**Test**: Define the composed KL-along-flow function and prove it is antitone, or equivalently that its derivative (which should factor as a negative-definite quadratic form in the moment deviations) is ≤ 0.
**Why now**: We have all the ingredient lemmas — KL nonnegativity, variance positivity, and the explicit moment formulas. The key insight is that the composed function should simplify to a sum of exponentially decaying terms, each with negative exponent.
**If true**: This gives a formal Lyapunov function for the OU dynamics, which is the mathematical backbone of convergence guarantees for DDPM/score-matching models.
**If false**: Would indicate a subtlety in the interaction between mean and variance decay rates — possibly requiring σsq > 0 or specific relationships between parameters.

### Direction 2: Multivariate OU Process and Matrix Exponentials
**Hypothesis**: The convergence results generalize to ℝⁿ: for the multivariate OU process dX = -AX dt + B dW with A positive definite, the covariance matrix Σ(t) converges to the Lyapunov solution AΣ∞ + Σ∞Aᵀ = BBᵀ, and the matrix KL divergence is nonneg.
**Test**: Define `ouCovarianceMatrix` using matrix exponentials and prove `Tendsto` to the Lyapunov solution. The KL formula becomes ½[tr(Σ₂⁻¹Σ₁) + (μ₁-μ₂)ᵀΣ₂⁻¹(μ₁-μ₂) - n + log(det Σ₂/det Σ₁)].
**Why now**: Mathlib has `Matrix.exp` and spectral theory for symmetric matrices. The key insight is that positive definiteness of A ensures all eigenvalues of the matrix exponential decay, reducing the problem to n independent scalar OU processes in the eigenbasis.
**If true**: Opens formalization of practical diffusion models which operate in high-dimensional spaces.
**If false**: The matrix exponential API may be insufficient — would identify specific Mathlib gaps to fill.

### Direction 3: Score Function and Reverse-Time SDE
**Hypothesis**: The score function ∇ log p_t(x) of the OU marginal N(m(t), v(t)) equals -(x - m(t))/v(t), and the reverse-time drift coefficient 2σ²·∇ log p_t - f(x,t) (where f is the forward drift) can be expressed purely in terms of the moment functions ouMean and ouVariance.
**Test**: Define the Gaussian score function, verify it equals the negative of the natural sufficient statistic, and show the reverse drift formula produces an OU process with time-reversed parameters.
**Why now**: We have the moment evolution formulas and variance positivity (needed for the score to be well-defined). The key insight is that for Gaussians, the score is linear in x, so the reverse-time SDE is also an OU process — this is the mathematical reason diffusion models work.
**If true**: Completes the theoretical loop: forward OU → score → reverse OU → data recovery. This is the central theorem of score-based generative modeling.
**If false**: The formalization of "reverse-time SDE" may require more infrastructure than moment equations alone can provide.

### Direction 4: Fokker-Planck Verification for Gaussian Densities
**Hypothesis**: The Gaussian density p(x,t) = (2π v(t))^{-1/2} exp(-(x-m(t))²/(2v(t))), with m(t) = ouMean and v(t) = ouVariance, satisfies the Fokker-Planck equation ∂p/∂t = θ·∂(xp)/∂x + (σ²/2)·∂²p/∂x² pointwise for all x ∈ ℝ, t > 0.
**Test**: Define the Gaussian density, compute its partial derivatives using HasDerivAt, and verify the PDE identity. This is a verification problem, not an existence problem.
**Why now**: Mathlib has `HasDerivAt` for exp and basic compositions. The key insight is that the PDE verification reduces to algebraic identities between the moment evolution ODEs and the Gaussian density's derivatives — no PDE theory needed, just calculus.
**If true**: Provides a formal bridge between the moment-level description (our current results) and the distributional description (what the physics literature uses).
**If false**: The derivative computation for the composed Gaussian density may be too complex for current Mathlib automation, identifying a need for better `HasDerivAt` composition lemmas.

### Direction 5: Exponential Convergence Rate via Pinsker's Inequality
**Hypothesis**: The total variation distance between the OU marginal at time t and the stationary distribution decays at rate O(exp(-θt)), provable via Pinsker's inequality TV(p,q)² ≤ ½ KL(p||q) composed with the exponential decay of the Gaussian KL divergence.
**Test**: Formalize Pinsker's inequality for 1D Gaussians (or use the explicit TV formula for Gaussians), compose with the KL decay from Direction 1, and extract the exponential rate.
**Why now**: We have KL nonnegativity and the moment convergence rates. The key insight is that for Gaussians, both KL and TV have closed forms, so the convergence rate can be extracted without abstract functional analysis — just calculus on explicit formulas.
**If true**: Gives quantitative sampling guarantees: after t = O(1/θ · log(1/ε)) steps, the diffusion model is ε-close to the target. This is the type of result that bridges theory and practice.
**If false**: The constant in Pinsker's inequality may not be tight enough, or the TV formula for Gaussians may require integration theory not yet in Mathlib.

**Concept description**: # Future Directions: Diffusion Models as SDEs

## Synthesis

This cycle established the foundational analytic infrastructure for formalizing score-based diffusion models in Lean 4. We formalized the Ornstein-Uhlenbeck process through its deterministic signatures — mean decay, variance convergence, and information-theoretic properties — rather than attempting to axiomatize Itô calculus (which Mathlib lacks). The key structural insight is that the convergence theory of diffusion models can be cleanly decomposed into: (1) exponential decay of moments, (2) universality of the stationary distribution, and (3) information-theoretic monotonicity via KL divergence.

All five theorems were proved without sorry, using only standard axioms. The KL divergence nonnegativity proof (Gibbs' inequality for Gaussians) was the most technically interesting — it reduced to the fundamental inequality log(x) ≤ x − 1 via careful rewriting of log ratios. The variance positivity result ensures the Gaussian marginals remain well-defined throughout the process, which is a prerequisite for the KL divergence to be meaningful.

The main limitation of this cycle is that we work entirely at the level of moment equations rather than stochastic processes. The connection between the moment evolution and the actual SDE is assumed, not proved. Bridging this gap requires either formalizing Itô calculus or adopting an abstract categorical/measure-theoretic approach to Markov processes.

## Results Summary

- `ou_mean_tendsto_zero`: proved — OU mean decays exponentially to 0, formalizing the "forgetting" property of diffusion models
- `ou_variance_tendsto_stationary`: proved — OU variance converges to σ²/(2θ) universally, independent of initial variance
- `kl_div_gaussian_self_eq_zero`: proved — KL divergence is zero for identical distributions (identity of indiscernibles)
- `kl_div_gaussian_nonneg`: proved — Gibbs' inequality specialized to Gaussians, foundation for convergence guarantees
- `ou_variance_pos`: proved — OU variance remains positive, ensuring well-definedness of Gaussian marginals

## Research Directions

### Direction 1: Monotone KL Divergence Along the OU Flow
**Hypothesis**: For the OU process with θ > 0, the KL divergence from the time-t marginal to the stationary distribution, expressed as `klDivGaussian (ouMean m₀ θ t) (ouVariance v₀ σsq θ t) 0 (ouStationaryVariance σsq θ)`, is monotonically decreasing in t for t ≥ 0.
**Test**: Define the composed KL-along-flow function and prove it is antitone, or equivalently that its derivative (which should factor as a negative-definite quadratic form in the moment deviations) is ≤ 0.
**Why now**: We have all the ingredient lemmas — KL nonnegativity, variance positivity, and the explicit moment formulas. The key insight is that the composed function should simplify to a sum of exponentially decaying terms, each with negative exponent.
**If true**: This gives a formal Lyapunov function for the OU dynamics, which is the mathematical backbone of convergence guarantees for DDPM/score-matching models.
**If false**: Would indicate a subtlety in the interaction between mean and variance decay rates — possibly requiring σsq > 0 or specific relationships between parameters.

### Direction 2: Multivariate OU Process and Matrix Exponentials
**Hypothesis**: The convergence results generalize to ℝⁿ: for the multivariate OU process dX = -AX dt + B dW with A positive definite, the covariance matrix Σ(t) converges to the Lyapunov solution AΣ∞ + Σ∞Aᵀ = BBᵀ, and the matrix KL divergence is nonneg.
**Test**: Define `ouCovarianceMatrix` using matrix exponentials and prove `Tendsto` to the Lyapunov solution. The KL formula becomes ½[tr(Σ₂⁻¹Σ₁) + (μ₁-μ₂)ᵀΣ₂⁻¹(μ₁-μ₂) - n + log(det Σ₂/det Σ₁)].
**Why now**: Mathlib has `Matrix.exp` and spectral theory for symmetric matrices. The key insight is that positive definiteness of A ensures all eigenvalues of the matrix exponential decay, reducing the problem to n independent scalar OU processes in the eigenbasis.
**If true**: Opens formalization of practical diffusion models which operate in high-dimensional spaces.
**If false**: The matrix exponential API may be insufficient — would identify specific Mathlib gaps to fill.

### Direction 3: Score Function and Reverse-Time SDE
**Hypothesis**: The score function ∇ log p_t(x) of the OU marginal N(m(t), v(t)) equals -(x - m(t))/v(t), and the reverse-time drift coefficient 2σ²·∇ log p_t - f(x,t) (where f is the forward drift) can be expressed purely in terms of the moment functions ouMean and ouVariance.
**Test**: Define the Gaussian score function, verify it equals the negative of the natural sufficient statistic, and show the reverse drift formula produces an OU process with time-reversed parameters.
**Why now**: We have the moment evolution formulas and variance positivity (needed for the score to be well-defined). The key insight is that for Gaussians, the score is linear in x, so the reverse-time SDE is also an OU process — this is the mathematical reason diffusion models work.
**If true**: Completes the theoretical loop: forward OU → score → reverse OU → data recovery. This is the central theorem of score-based generative modeling.
**If false**: The formalization of "reverse-time SDE" may require more infrastructure than moment equations alone can provide.

### Direction 4: Fokker-Planck Verification for Gaussian Densities
**Hypothesis**: The Gaussian density p(x,t) = (2π v(t))^{-1/2} exp(-(x-m(t))²/(2v(t))), with m(t) = ouMean and v(t) = ouVariance, satisfies the Fokker-Planck equation ∂p/∂t = θ·∂(xp)/∂x + (σ²/2)·∂²p/∂x² pointwise for all x ∈ ℝ, t > 0.
**Test**: Define the Gaussian density, compute its partial derivatives using HasDerivAt, and verify the PDE identity. This is a verification problem, not an existence problem.
**Why now**: Mathlib has `HasDerivAt` for exp and basic compositions. The key insight is that the PDE verification reduces to algebraic identities between the moment evolution ODEs and the Gaussian density's derivatives — no PDE theory needed, just calculus.
**If true**: Provides a formal bridge between the moment-level description (our current results) and the distributional description (what the physics literature uses).
**If false**: The derivative computation for the composed Gaussian density may be too complex for current Mathlib automation, identifying a need for better `HasDerivAt` composition lemmas.

### Direction 5: Exponential Convergence Rate via Pinsker's Inequality
**Hypothesis**: The total variation distance between the OU marginal at time t and the stationary distribution decays at rate O(exp(-θt)), provable via Pinsker's inequality TV(p,q)² ≤ ½ KL(p||q) composed with the exponential decay of the Gaussian KL divergence.
**Test**: Formalize Pinsker's inequality for 1D Gaussians (or use the explicit TV formula for Gaussians), compose with the KL decay from Direction 1, and extract the exponential rate.
**Why now**: We have KL nonnegativity and the moment convergence rates. The key insight is that for Gaussians, both KL and TV have closed forms, so the convergence rate can be extracted without abstract functional analysis — just calculus on explicit formulas.
**If true**: Gives quantitative sampling guarantees: after t = O(1/θ · log(1/ε)) steps, the diffusion model is ε-close to the target. This is the type of result that bridges theory and practice.
**If false**: The constant in Pinsker's inequality may not be tight enough, or the TV formula for Gaussians may require integration theory not yet in Mathlib.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Computation
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
