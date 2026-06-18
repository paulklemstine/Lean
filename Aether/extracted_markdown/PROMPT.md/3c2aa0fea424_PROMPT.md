
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

**Title**: The natural next step is to formalize the Sauer-Shelah lemma: if a family F of s
**Domain**: Computation
**Mathematical framing**: # Future Directions: Generalization Bounds via Rademacher Complexity

## 1. Sauer-Shelah Lemma (Full Formalization)

The natural next step is to formalize the Sauer-Shelah lemma: if a family F of subsets of [n] does not shatter any set of size d+1, then |F| ≤ ∑_{i=0}^d C(n,i). Combined with our `binomial_partial_sum_le_pow`, this would immediately yield the classical VC-dimension growth bound |F| ≤ (n+1)^d.

The key insight is that the standard double-induction proof (on n and the family size) should decompose cleanly into Lean lemmas by splitting the family at a distinguished element — the "shifting" step creates two sub-families on n-1 elements whose union is controlled by induction.

Why now? We already have both the polynomial bound `binomial_partial_sum_le_pow` and the shattering lower bound `shattering_card_lower_bound`. The Sauer-Shelah lemma is the missing piece that connects VC-dimension (a semantic property about shattering) to growth function bounds (a counting property), completing the combinatorial chain.

## 2. Massart's Finite Lemma and Empirical Rademacher Complexity

Formalize the definition of empirical Rademacher complexity for finite hypothesis classes over finite samples, and prove Massart's lemma: for a finite set A ⊆ ℝ^n with |A| = m and max_{a ∈ A} ‖a‖₂ ≤ c, the empirical Rademacher complexity satisfies R̂(A) ≤ c√(2 log m / n).

The key insight is that Massart's lemma follows from a clean application of Hoeffding's inequality to the moment generating function of the Rademacher average, then optimizing the exponential parameter. The proof requires only basic properties of expectations over the uniform distribution on {-1,+1}^n, which can be modeled as finite sums without full measure theory.

Why now? Mathlib's `MeasureTheory.ProbabilityMeasure` and its `Finset`-based expectations are now mature enough to support the discrete probability calculations. Our growth function bounds provide the combinatorial input (log |F| ≤ d log(n+1)) that feeds into Massart's lemma to yield the VC-dimension → Rademacher complexity pipeline.

## 3. Rademacher Contraction Principle

Formalize the Ledoux-Talagrand contraction principle: if φ : ℝ → ℝ is L-Lipschitz with φ(0) = 0, then the Rademacher complexity of {φ ∘ f : f ∈ F} is at most L · R(F). This is the key tool for extending Rademacher bounds from linear to nonlinear hypothesis classes (e.g., neural networks with Lipschitz activations).

The key insight is that the contraction principle reduces to a symmetrization argument combined with the Lipschitz property. In the finite/discrete setting, this becomes a clean inequality about weighted sums of Rademacher random variables, avoiding the full machinery of sub-Gaussian processes.

Why now? The contraction principle would bridge our combinatorial bounds to modern deep learning theory, where the relevant hypothesis classes are compositions of Lipschitz maps. With the base Rademacher framework formalized, adding contraction is the most impactful single extension.

## 4. Margin-Based Generalization Bound for Linear Classifiers

Formalize the margin bound: for linear classifiers with ‖w‖ ≤ W acting on data with ‖x‖ ≤ B and margin γ > 0, the Rademacher complexity is O(WB/γ√n), independent of the ambient dimension. This is strictly tighter than the VC-dimension bound (which scales with the dimension) for high-dimensional problems.

The key insight is that the margin constraint restricts the effective hypothesis class to a ball in function space, whose covering number is controlled by the ratio WB/γ rather than by the ambient dimension. The proof requires formalizing ε-covers and Dudley's entropy integral in the finite-dimensional case.

Why now? Our `polynomial_beats_exponential_eventually` theorem demonstrates that structural constraints improve generalization bounds. The margin bound is the prototypical example where Rademacher complexity yields dimension-free bounds that VC-dimension cannot match, directly supporting the paper's thesis that Rademacher bounds dominate VC bounds for structured classes.

## 5. Kernel Rademacher Complexity via Reproducing Kernel Hilbert Spaces

Extend the margin bound to kernel methods by formalizing: for a kernel K with tr(K) ≤ T acting on n data points, the Rademacher complexity of the induced hypothesis class satisfies R̂(F) ≤ √(T/n). This subsumes linear classifiers (K = identity) and captures nonlinear classifiers via the kernel trick.

The key insight is that the Rademacher complexity of the unit ball in a reproducing kernel Hilbert space can be computed exactly using the eigenvalues of the kernel matrix, yielding R̂ = √(tr(K̃)/n) where K̃ is the centered kernel matrix. This converts an infinite-dimensional optimization problem into a finite linear algebra computation.

Why now? Mathlib's `InnerProductSpace` and spectral theory for self-adjoint operators on finite-dimensional spaces provide the foundation. Combined with our empirical Rademacher framework, this would give the first fully-formalized proof that kernel methods enjoy dimension-independent generalization guarantees — a foundational result in statistical learning theory that has never been machine-verified.

**Concept description**: # Future Directions: Generalization Bounds via Rademacher Complexity

## 1. Sauer-Shelah Lemma (Full Formalization)

The natural next step is to formalize the Sauer-Shelah lemma: if a family F of subsets of [n] does not shatter any set of size d+1, then |F| ≤ ∑_{i=0}^d C(n,i). Combined with our `binomial_partial_sum_le_pow`, this would immediately yield the classical VC-dimension growth bound |F| ≤ (n+1)^d.

The key insight is that the standard double-induction proof (on n and the family size) should decompose cleanly into Lean lemmas by splitting the family at a distinguished element — the "shifting" step creates two sub-families on n-1 elements whose union is controlled by induction.

Why now? We already have both the polynomial bound `binomial_partial_sum_le_pow` and the shattering lower bound `shattering_card_lower_bound`. The Sauer-Shelah lemma is the missing piece that connects VC-dimension (a semantic property about shattering) to growth function bounds (a counting property), completing the combinatorial chain.

## 2. Massart's Finite Lemma and Empirical Rademacher Complexity

Formalize the definition of empirical Rademacher complexity for finite hypothesis classes over finite samples, and prove Massart's lemma: for a finite set A ⊆ ℝ^n with |A| = m and max_{a ∈ A} ‖a‖₂ ≤ c, the empirical Rademacher complexity satisfies R̂(A) ≤ c√(2 log m / n).

The key insight is that Massart's lemma follows from a clean application of Hoeffding's inequality to the moment generating function of the Rademacher average, then optimizing the exponential parameter. The proof requires only basic properties of expectations over the uniform distribution on {-1,+1}^n, which can be modeled as finite sums without full measure theory.

Why now? Mathlib's `MeasureTheory.ProbabilityMeasure` and its `Finset`-based expectations are now mature enough to support the discrete probability calculations. Our growth function bounds provide the combinatorial input (log |F| ≤ d log(n+1)) that feeds into Massart's lemma to yield the VC-dimension → Rademacher complexity pipeline.

## 3. Rademacher Contraction Principle

Formalize the Ledoux-Talagrand contraction principle: if φ : ℝ → ℝ is L-Lipschitz with φ(0) = 0, then the Rademacher complexity of {φ ∘ f : f ∈ F} is at most L · R(F). This is the key tool for extending Rademacher bounds from linear to nonlinear hypothesis classes (e.g., neural networks with Lipschitz activations).

The key insight is that the contraction principle reduces to a symmetrization argument combined with the Lipschitz property. In the finite/discrete setting, this becomes a clean inequality about weighted sums of Rademacher random variables, avoiding the full machinery of sub-Gaussian processes.

Why now? The contraction principle would bridge our combinatorial bounds to modern deep learning theory, where the relevant hypothesis classes are compositions of Lipschitz maps. With the base Rademacher framework formalized, adding contraction is the most impactful single extension.

## 4. Margin-Based Generalization Bound for Linear Classifiers

Formalize the margin bound: for linear classifiers with ‖w‖ ≤ W acting on data with ‖x‖ ≤ B and margin γ > 0, the Rademacher complexity is O(WB/γ√n), independent of the ambient dimension. This is strictly tighter than the VC-dimension bound (which scales with the dimension) for high-dimensional problems.

The key insight is that the margin constraint restricts the effective hypothesis class to a ball in function space, whose covering number is controlled by the ratio WB/γ rather than by the ambient dimension. The proof requires formalizing ε-covers and Dudley's entropy integral in the finite-dimensional case.

Why now? Our `polynomial_beats_exponential_eventually` theorem demonstrates that structural constraints improve generalization bounds. The margin bound is the prototypical example where Rademacher complexity yields dimension-free bounds that VC-dimension cannot match, directly supporting the paper's thesis that Rademacher bounds dominate VC bounds for structured classes.

## 5. Kernel Rademacher Complexity via Reproducing Kernel Hilbert Spaces

Extend the margin bound to kernel methods by formalizing: for a kernel K with tr(K) ≤ T acting on n data points, the Rademacher complexity of the induced hypothesis class satisfies R̂(F) ≤ √(T/n). This subsumes linear classifiers (K = identity) and captures nonlinear classifiers via the kernel trick.

The key insight is that the Rademacher complexity of the unit ball in a reproducing kernel Hilbert space can be computed exactly using the eigenvalues of the kernel matrix, yielding R̂ = √(tr(K̃)/n) where K̃ is the centered kernel matrix. This converts an infinite-dimensional optimization problem into a finite linear algebra computation.

Why now? Mathlib's `InnerProductSpace` and spectral theory for self-adjoint operators on finite-dimensional spaces provide the foundation. Combined with our empirical Rademacher framework, this would give the first fully-formalized proof that kernel methods enjoy dimension-independent generalization guarantees — a foundational result in statistical learning theory that has never been machine-verified.

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
