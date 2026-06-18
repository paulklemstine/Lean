
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

**Title**: The Bernoulli Pinsker inequality `(p - q)² ≤ KL(Ber(p) ‖ Ber(q)) / 2` is now ful
**Domain**: Novelty
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
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
