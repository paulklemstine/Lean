
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

**Title**: We proved that KL(p‖q) ≥ 0 for discrete distributions. The natural next step is 
**Domain**: Applications
**Mathematical framing**: # Future Directions: Information-Theoretic Inequalities and Entropy Power

## 1. Sharp Equality Conditions for Gibbs' Inequality

We proved that KL(p‖q) ≥ 0 for discrete distributions. The natural next step is to formalize the equality characterization: KL(p‖q) = 0 if and only if p = q on the support of p. The key insight is that log(t) = t − 1 holds if and only if t = 1, so equality in each term forces p(x)/q(x) = 1 wherever p(x) > 0. This extends to a quantitative stability bound: KL(p‖q) ≥ (1/2)·‖p − q‖₁² (Pinsker's inequality), which would bridge information theory to total variation distance.

**Why now?** The `kl_term_ge_diff` lemma already isolates the pointwise inequality, and the strict version of `Real.log_le_sub_one_of_pos` (equality iff argument = 1) is available in Mathlib. The infrastructure for TV distance exists via `MeasureTheory.Measure.totalVariation`.

## 2. Continuous Entropy Power Inequality via Fisher Information

The full EPI for continuous distributions states N(X+Y) ≥ N(X) + N(Y) where N(X) = (1/(2πe))·exp(2h(X)/n). The standard proof goes through Fisher information: J(X) ≥ n/N(X) (the Cramér-Rao bound), and the Fisher information inequality J(X+Y)⁻¹ ≥ J(X)⁻¹ + J(Y)⁻¹. The key insight is that Fisher information is additive for independent random variables under convolution, and the de Bruijn identity connects differential entropy to Fisher information via the heat equation. Our algebraic equivalence `entropy_power_ineq_iff` already captures the analytic skeleton.

**Why now?** Mathlib has `MeasureTheory.Measure.absolutelyContinuous`, Radon-Nikodym derivatives, and L² space infrastructure. The main gap is formalizing Fisher information as J(X) = E[(∂/∂x log f(x))²] and proving the Cramér-Rao bound. The abstract `EPIFunctional` structure we defined provides a target interface.

## 3. Rényi Entropy Power Inequality and Interpolation

The Shannon EPI generalizes to Rényi entropies: for order α ∈ (0,1), the Rényi entropy power N_α(X+Y) ≥ N_α(X) + N_α(Y). The key insight is that Rényi entropy H_α(p) = (1/(1−α))·log(∑ pᵢ^α) interpolates between min-entropy (α→∞), Shannon entropy (α→1), and collision entropy (α=2), and the EPI should be proved by showing the entropy power is concave along heat flow for each order. Our `max_entropy_exponential` theorem on exponential family optimality extends naturally: the Rényi entropy maximizer under moment constraints is a q-exponential distribution.

**Why now?** The algebraic framework of `entropyPower` and `entropy_power_ineq_iff` generalizes directly. The Rényi entropy is a simpler analytic object than Shannon entropy (finite sums of powers), making it more tractable for formalization. The monotonicity of Rényi entropy in α (H_α ≥ H_β for α < β) can be proved from Hölder's inequality, which is in Mathlib.

## 4. Discrete Brunn-Minkowski via Entropy Method

Our `brunn_minkowski_epi_bridge` shows the algebraic equivalence between BM and EPI. The next step is to prove the discrete Brunn-Minkowski inequality |A+B| ≥ |A| + |B| − 1 for finite subsets of ℤ, using the entropy method: assign the uniform distribution on A and B, compute entropies, and apply the discrete EPI. The key insight is that for independent uniform random variables X ∈ A, Y ∈ B, we have H(X+Y) ≥ max(H(X), H(Y)) = max(log|A|, log|B|), and the discrete EPI provides a sharper bound. This would close the loop between our abstract `EPIFunctional` and concrete combinatorial geometry.

**Why now?** We have `shannon_entropy_le_log_card` (entropy ≤ log of support size) and the abstract EPI framework. The discrete BM is a finite combinatorial statement that doesn't require measure theory. Mathlib's `Finset.add` (Minkowski sum of finsets) and cardinality lemmas provide the combinatorial substrate.

## 5. Entropic Central Limit Theorem

Our `epi_iterated_growth` shows that iterated convolution grows the entropy power linearly. The entropic CLT strengthens this: for i.i.d. X₁,...,Xₙ with finite variance σ², the normalized sum Sₙ = (X₁+...+Xₙ)/√n satisfies H(Sₙ) → H(N(0,σ²)) as n→∞, where N(0,σ²) is the Gaussian. The key insight is that the deficit D(Sₙ ‖ Gaussian) decreases monotonically by the EPI, and the rate of convergence is O(1/n) in KL divergence (Barron's theorem). This would connect our discrete infrastructure to the continuous limit and provide a quantitative version of the CLT.

**Why now?** The iterated growth theorem provides the qualitative bound. The abstract `EPIFunctional` can be instantiated with normalized sums. Mathlib has the Gaussian distribution (`MeasureTheory.Measure.gaussian`) and characteristic function machinery that could support the convergence argument.

**Concept description**: # Future Directions: Information-Theoretic Inequalities and Entropy Power

## 1. Sharp Equality Conditions for Gibbs' Inequality

We proved that KL(p‖q) ≥ 0 for discrete distributions. The natural next step is to formalize the equality characterization: KL(p‖q) = 0 if and only if p = q on the support of p. The key insight is that log(t) = t − 1 holds if and only if t = 1, so equality in each term forces p(x)/q(x) = 1 wherever p(x) > 0. This extends to a quantitative stability bound: KL(p‖q) ≥ (1/2)·‖p − q‖₁² (Pinsker's inequality), which would bridge information theory to total variation distance.

**Why now?** The `kl_term_ge_diff` lemma already isolates the pointwise inequality, and the strict version of `Real.log_le_sub_one_of_pos` (equality iff argument = 1) is available in Mathlib. The infrastructure for TV distance exists via `MeasureTheory.Measure.totalVariation`.

## 2. Continuous Entropy Power Inequality via Fisher Information

The full EPI for continuous distributions states N(X+Y) ≥ N(X) + N(Y) where N(X) = (1/(2πe))·exp(2h(X)/n). The standard proof goes through Fisher information: J(X) ≥ n/N(X) (the Cramér-Rao bound), and the Fisher information inequality J(X+Y)⁻¹ ≥ J(X)⁻¹ + J(Y)⁻¹. The key insight is that Fisher information is additive for independent random variables under convolution, and the de Bruijn identity connects differential entropy to Fisher information via the heat equation. Our algebraic equivalence `entropy_power_ineq_iff` already captures the analytic skeleton.

**Why now?** Mathlib has `MeasureTheory.Measure.absolutelyContinuous`, Radon-Nikodym derivatives, and L² space infrastructure. The main gap is formalizing Fisher information as J(X) = E[(∂/∂x log f(x))²] and proving the Cramér-Rao bound. The abstract `EPIFunctional` structure we defined provides a target interface.

## 3. Rényi Entropy Power Inequality and Interpolation

The Shannon EPI generalizes to Rényi entropies: for order α ∈ (0,1), the Rényi entropy power N_α(X+Y) ≥ N_α(X) + N_α(Y). The key insight is that Rényi entropy H_α(p) = (1/(1−α))·log(∑ pᵢ^α) interpolates between min-entropy (α→∞), Shannon entropy (α→1), and collision entropy (α=2), and the EPI should be proved by showing the entropy power is concave along heat flow for each order. Our `max_entropy_exponential` theorem on exponential family optimality extends naturally: the Rényi entropy maximizer under moment constraints is a q-exponential distribution.

**Why now?** The algebraic framework of `entropyPower` and `entropy_power_ineq_iff` generalizes directly. The Rényi entropy is a simpler analytic object than Shannon entropy (finite sums of powers), making it more tractable for formalization. The monotonicity of Rényi entropy in α (H_α ≥ H_β for α < β) can be proved from Hölder's inequality, which is in Mathlib.

## 4. Discrete Brunn-Minkowski via Entropy Method

Our `brunn_minkowski_epi_bridge` shows the algebraic equivalence between BM and EPI. The next step is to prove the discrete Brunn-Minkowski inequality |A+B| ≥ |A| + |B| − 1 for finite subsets of ℤ, using the entropy method: assign the uniform distribution on A and B, compute entropies, and apply the discrete EPI. The key insight is that for independent uniform random variables X ∈ A, Y ∈ B, we have H(X+Y) ≥ max(H(X), H(Y)) = max(log|A|, log|B|), and the discrete EPI provides a sharper bound. This would close the loop between our abstract `EPIFunctional` and concrete combinatorial geometry.

**Why now?** We have `shannon_entropy_le_log_card` (entropy ≤ log of support size) and the abstract EPI framework. The discrete BM is a finite combinatorial statement that doesn't require measure theory. Mathlib's `Finset.add` (Minkowski sum of finsets) and cardinality lemmas provide the combinatorial substrate.

## 5. Entropic Central Limit Theorem

Our `epi_iterated_growth` shows that iterated convolution grows the entropy power linearly. The entropic CLT strengthens this: for i.i.d. X₁,...,Xₙ with finite variance σ², the normalized sum Sₙ = (X₁+...+Xₙ)/√n satisfies H(Sₙ) → H(N(0,σ²)) as n→∞, where N(0,σ²) is the Gaussian. The key insight is that the deficit D(Sₙ ‖ Gaussian) decreases monotonically by the EPI, and the rate of convergence is O(1/n) in KL divergence (Barron's theorem). This would connect our discrete infrastructure to the continuous limit and provide a quantitative version of the CLT.

**Why now?** The iterated growth theorem provides the qualitative bound. The abstract `EPIFunctional` can be instantiated with normalized sums. Mathlib has the Gaussian distribution (`MeasureTheory.Measure.gaussian`) and characteristic function machinery that could support the convergence argument.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
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
