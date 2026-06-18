
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

**Title**: The Bernoulli Pinsker inequality `(p - q)² ≤ KL(Ber(p) ‖ Ber(q)) / 2` is now ful
**Domain**: Applications
**Mathematical framing**: # Future Directions: Neural Tangent Kernel Convergence Theory

## 1. General Pinsker Inequality for Finite Distributions

The Bernoulli Pinsker inequality `(p - q)² ≤ KL(Ber(p) ‖ Ber(q)) / 2` is now fully proved. The natural next step is the general Pinsker inequality: `TV(Q, P)² ≤ KL(Q ‖ P) / 2` for arbitrary finite distributions Q, P over a type α.

The key insight is that the general Pinsker inequality reduces to the Bernoulli case via the data-processing inequality (or equivalently, by projecting onto binary events). For any set A ⊆ α, define Q_A = Q(A) and P_A = P(A). Then KL(Ber(Q_A) ‖ Ber(P_A)) ≤ KL(Q ‖ P) by data processing, and TV(Q, P) = max_A |Q(A) - P(A)| ≤ √(KL(Q ‖ P)/2) follows from the Bernoulli case.

Why now? The Bernoulli Pinsker proof uses a novel MVT-based approach (factoring the derivative as `(q-p) * (1/(q(1-q)) - 4)`) that avoids the usual convex duality arguments. Formalizing the data-processing inequality for finite distributions would complete the picture and unlock tighter PAC-Bayes bounds in the Catalog.

## 2. Spectral Convergence Rate with Eigenvalue Decay

We proved that the spectral contraction constant for the update operator I - ηK equals `(κ-1)/(κ+1)` at the optimal learning rate, where κ = λ_max/λ_min is the condition number. For overparameterized neural networks, the NTK eigenvalues typically decay as a power law: λ_k ~ k^{-α} for some α > 1.

The key insight is that under power-law spectral decay, the effective condition number for the top-k eigenvalues grows as k^α, so convergence of the first k components takes O(k^α · log(1/ε)) steps. A formal theorem would bound the residual `‖u_t - u*‖` by decomposing into spectral components and summing geometric decays with different rates.

Why now? The spectral contraction and optimal learning rate theorems provide the per-eigenvalue convergence rate. The missing piece is the summation argument over the spectrum, which requires formalizing the eigendecomposition of the NTK Gram matrix (available in Mathlib as `Matrix.IsHermitian.spectral_theorem`).

## 3. Lazy Training Regime: Kernel Perturbation Bounds

The NTKCore file proves that the linearized model has constant kernel along the gradient flow trajectory. The next step is to formalize the perturbation theory: if the actual (nonlinear) kernel deviates from the initial kernel by at most δ at each step, how does the trajectory diverge from the kernel regression solution?

The key insight is a Gronwall-type stability estimate: if `‖K_t - K_0‖_op ≤ δ` for all t, then `‖u_t^{actual} - u_t^{linear}‖ ≤ C · δ · t · ‖u_0‖ · exp(η · ‖K_0‖_op · t)`. This exponential growth is tamed by the finite training time T ~ log(1/ε) / (η · λ_min), giving a polynomial-in-parameters bound.

Why now? The single-step perturbation bound `ntk_single_step_perturbation` in NTKConvergence.lean already formalizes the per-step error. The discrete Gronwall lemma in Mathlib (`Finset.prod_le_prod`) provides the induction machinery. Combining these would give the first formalized NTK width-convergence result.

## 4. PAC-Bayes Generalization Bounds via Catoni's Method

With the Bernoulli Pinsker inequality and the Catoni bound infrastructure both formalized, we can now prove end-to-end generalization bounds for NTK-trained networks. The target theorem: for an NTK model with n training points and kernel condition number κ, the generalization gap is O(√(κ · log(n) / n)).

The key insight is that the PAC-Bayes framework with the Catoni bound (already in Bounds.lean) combined with the Bernoulli Pinsker inequality converts KL control of the posterior into risk bounds. The NTK spectral theory provides the KL bound through the effective dimension d_eff = Σ_k λ_k/(λ_k + λ), connecting kernel spectrum to model complexity.

Why now? All three ingredients (Catoni bound, Pinsker inequality, NTK spectral theory) are now formalized. The main remaining work is the bridge theorem connecting NTK eigenvalues to PAC-Bayes posteriors, which requires the Gaussian measure formalization in Mathlib.

## 5. Stochastic Gradient Descent Extension

The current theory covers full-batch gradient descent. Extending to stochastic gradient descent (SGD) requires formalizing the martingale structure of the gradient noise and proving that the NTK remains approximately constant under mini-batch updates.

The key insight is that under the lazy training regime, SGD on the linearized model is equivalent to kernel regression with noise-perturbed updates. The residual satisfies `u_{t+1} = (I - η_t K) u_t + η_t ξ_t` where ξ_t is a martingale difference sequence with `E[ξ_t | F_t] = 0` and `E[‖ξ_t‖² | F_t] ≤ σ²`. The convergence rate becomes O(1/t) for appropriately decaying learning rates, matching the minimax optimal rate for kernel regression.

Why now? Mathlib's measure theory library now includes conditional expectation and martingale convergence theorems. The deterministic NTK convergence results in this file provide the "signal" component; what remains is layering the stochastic analysis on top.

**Concept description**: # Future Directions: Neural Tangent Kernel Convergence Theory

## 1. General Pinsker Inequality for Finite Distributions

The Bernoulli Pinsker inequality `(p - q)² ≤ KL(Ber(p) ‖ Ber(q)) / 2` is now fully proved. The natural next step is the general Pinsker inequality: `TV(Q, P)² ≤ KL(Q ‖ P) / 2` for arbitrary finite distributions Q, P over a type α.

The key insight is that the general Pinsker inequality reduces to the Bernoulli case via the data-processing inequality (or equivalently, by projecting onto binary events). For any set A ⊆ α, define Q_A = Q(A) and P_A = P(A). Then KL(Ber(Q_A) ‖ Ber(P_A)) ≤ KL(Q ‖ P) by data processing, and TV(Q, P) = max_A |Q(A) - P(A)| ≤ √(KL(Q ‖ P)/2) follows from the Bernoulli case.

Why now? The Bernoulli Pinsker proof uses a novel MVT-based approach (factoring the derivative as `(q-p) * (1/(q(1-q)) - 4)`) that avoids the usual convex duality arguments. Formalizing the data-processing inequality for finite distributions would complete the picture and unlock tighter PAC-Bayes bounds in the Catalog.

## 2. Spectral Convergence Rate with Eigenvalue Decay

We proved that the spectral contraction constant for the update operator I - ηK equals `(κ-1)/(κ+1)` at the optimal learning rate, where κ = λ_max/λ_min is the condition number. For overparameterized neural networks, the NTK eigenvalues typically decay as a power law: λ_k ~ k^{-α} for some α > 1.

The key insight is that under power-law spectral decay, the effective condition number for the top-k eigenvalues grows as k^α, so convergence of the first k components takes O(k^α · log(1/ε)) steps. A formal theorem would bound the residual `‖u_t - u*‖` by decomposing into spectral components and summing geometric decays with different rates.

Why now? The spectral contraction and optimal learning rate theorems provide the per-eigenvalue convergence rate. The missing piece is the summation argument over the spectrum, which requires formalizing the eigendecomposition of the NTK Gram matrix (available in Mathlib as `Matrix.IsHermitian.spectral_theorem`).

## 3. Lazy Training Regime: Kernel Perturbation Bounds

The NTKCore file proves that the linearized model has constant kernel along the gradient flow trajectory. The next step is to formalize the perturbation theory: if the actual (nonlinear) kernel deviates from the initial kernel by at most δ at each step, how does the trajectory diverge from the kernel regression solution?

The key insight is a Gronwall-type stability estimate: if `‖K_t - K_0‖_op ≤ δ` for all t, then `‖u_t^{actual} - u_t^{linear}‖ ≤ C · δ · t · ‖u_0‖ · exp(η · ‖K_0‖_op · t)`. This exponential growth is tamed by the finite training time T ~ log(1/ε) / (η · λ_min), giving a polynomial-in-parameters bound.

Why now? The single-step perturbation bound `ntk_single_step_perturbation` in NTKConvergence.lean already formalizes the per-step error. The discrete Gronwall lemma in Mathlib (`Finset.prod_le_prod`) provides the induction machinery. Combining these would give the first formalized NTK width-convergence result.

## 4. PAC-Bayes Generalization Bounds via Catoni's Method

With the Bernoulli Pinsker inequality and the Catoni bound infrastructure both formalized, we can now prove end-to-end generalization bounds for NTK-trained networks. The target theorem: for an NTK model with n training points and kernel condition number κ, the generalization gap is O(√(κ · log(n) / n)).

The key insight is that the PAC-Bayes framework with the Catoni bound (already in Bounds.lean) combined with the Bernoulli Pinsker inequality converts KL control of the posterior into risk bounds. The NTK spectral theory provides the KL bound through the effective dimension d_eff = Σ_k λ_k/(λ_k + λ), connecting kernel spectrum to model complexity.

Why now? All three ingredients (Catoni bound, Pinsker inequality, NTK spectral theory) are now formalized. The main remaining work is the bridge theorem connecting NTK eigenvalues to PAC-Bayes posteriors, which requires the Gaussian measure formalization in Mathlib.

## 5. Stochastic Gradient Descent Extension

The current theory covers full-batch gradient descent. Extending to stochastic gradient descent (SGD) requires formalizing the martingale structure of the gradient noise and proving that the NTK remains approximately constant under mini-batch updates.

The key insight is that under the lazy training regime, SGD on the linearized model is equivalent to kernel regression with noise-perturbed updates. The residual satisfies `u_{t+1} = (I - η_t K) u_t + η_t ξ_t` where ξ_t is a martingale difference sequence with `E[ξ_t | F_t] = 0` and `E[‖ξ_t‖² | F_t] ≤ σ²`. The convergence rate becomes O(1/t) for appropriately decaying learning rates, matching the minimax optimal rate for kernel regression.

Why now? Mathlib's measure theory library now includes conditional expectation and martingale convergence theorems. The deterministic NTK convergence results in this file provide the "signal" component; what remains is layering the stochastic analysis on top.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
