
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

**Title**: Our `exists_revSim_of_surjective` proves that surjective endofunctions on `Fin n
**Domain**: Computation
**Mathematical framing**: # Future Directions: Reversible Computing and Thermodynamic Efficiency

## 1. Tight Ancilla Bound for General (Non-Surjective) Functions

Our `exists_revSim_of_surjective` proves that surjective endofunctions on `Fin n` can be made reversible with 1 ancilla bit (since surjective = bijective on finite types). The genuinely hard case is non-surjective functions where the max fiber size exceeds 1.

**Conjecture**: For any `f : Fin n → Fin n` with maximum fiber size `k`, there exists a reversible simulation using exactly `Fin k` ancilla, and this is tight — no simulation with `Fin (k-1)` ancilla exists.

The key insight is that the lower bound follows from a pigeonhole argument: if the ancilla space has fewer than `k` elements, then two inputs in the same fiber with the same ancilla must collide, violating injectivity of the simulation bijection.

**Why now?** We have the fiber infrastructure (`fiber`, `maxFiberSize`, `injective_iff_maxFiber_le_one`) and the `RevSim` structure already in place. The upper bound construction requires enumerating fibers and constructing an explicit bijection using `Finset.equivFin`, which is available in Mathlib.

## 2. Circuit Complexity of Reversible Simulation

The Toffoli gate is universal for reversible Boolean computation (any bijection on `Bool^n` can be decomposed into Toffoli gates). We formalized the Toffoli gate and showed it simulates AND.

**Conjecture**: Any function `f : (Fin 2)^n → (Fin 2)^n` can be expressed as a composition of at most `O(n · 2^n)` Toffoli gates applied to `(Fin 2)^(n + O(n))` (i.e., with O(n) ancilla bits). Furthermore, there exist functions requiring `Ω(2^n / n)` Toffoli gates (a counting/Shannon-style lower bound).

The key insight is that the upper bound follows from the standard construction: decompose f into a sequence of controlled-NOT operations using the truth table, and each row requires at most n Toffoli gates. The lower bound is a counting argument comparing the number of possible circuits of given size to the number of bijections.

**Why now?** The Toffoli and Fredkin gate formalizations provide the atomic building blocks. Formalizing circuit composition as lists of gate applications on `(Fin 2)^n` would connect to the existing `rev_compose` theorem and the group structure of `Equiv.Perm`.

## 3. Shannon Entropy Preservation Under Bijections

We proved that bijections preserve cardinality (`bijection_preserves_fiber_card`) and information content of uniform distributions (`bijection_preserves_info`). The natural next step is full Shannon entropy.

**Conjecture**: For any probability distribution `p : α → ℝ≥0∞` on a finite type and any bijection `σ : α ≃ α`, the Shannon entropy `H(p) = -∑_x p(x) log p(x)` equals `H(p ∘ σ⁻¹)`. Moreover, for any non-injective function `f : α → α`, there exists a distribution `p` such that `H(f_* p) < H(p)` (entropy strictly decreases under irreversible maps for some distributions).

The key insight is that Shannon entropy is a symmetric function of the probability vector, and bijections merely permute the vector. The strict decrease for non-injective maps follows because collapsing fibers forces probability mass to merge, which strictly decreases entropy by the strict concavity of `-x log x`.

**Why now?** Mathlib has `MeasureTheory.entropy` and related infrastructure. The challenge is connecting our finite combinatorial setup to the measure-theoretic entropy definition, but `Finset.sum` over explicit distributions avoids most measure theory overhead.

## 4. Reversible Computation and Kolmogorov Complexity

**Conjecture**: For any computable bijection `f : ℕ → ℕ`, the Kolmogorov complexity satisfies `K(f(n)) ≤ K(n) + O(1)` and `K(n) ≤ K(f(n)) + O(1)`. That is, reversible computation preserves Kolmogorov complexity up to an additive constant. For non-injective computable `f`, there exist infinitely many `n` with `K(f(n)) < K(n) - log(|f⁻¹(f(n))|) + O(1)`.

The key insight is that reversibility in the Kolmogorov setting means the description of the inverse is bounded (since it's computable), so the overhead is O(1). The loss for non-injective functions comes from the coding theorem: you lose the information needed to distinguish elements within a fiber.

**Why now?** While Kolmogorov complexity is not directly computable, the inequalities can be stated as relations between program sizes in a fixed universal Turing machine model. Our fiber-size infrastructure provides the combinatorial backbone, and Lean's computability library provides the TM model.

## 5. Thermodynamic Cost of Sorting

**Conjecture**: Any comparison-based sorting algorithm on `n` elements, when implemented reversibly, requires at least `⌈log₂(n!)⌉` ancilla bits, and merge sort achieves this bound (up to lower-order terms). The thermodynamic cost (in units of `kT ln 2`) of irreversible sorting is exactly `log₂(n!)`.

The key insight is that sorting maps `n!` permutations to a single sorted output, so the fiber of the "sort" function has size `n!`. By our `maxFiberSize` framework, this requires `n!` ancilla states, which is `⌈log₂(n!)⌉` bits. This connects algorithmic complexity (comparison lower bounds) to thermodynamic cost via Landauer's principle.

**Why now?** We have the fiber framework and the Landauer bound infrastructure. Formalizing sorting as a function `Equiv.Perm (Fin n) → Fin 1` (collapsing all permutations to one output) makes the fiber size exactly `n!`, directly applying our theory. Mathlib's `Nat.factorial` and Stirling's approximation provide the asymptotic analysis.

**Concept description**: # Future Directions: Reversible Computing and Thermodynamic Efficiency

## 1. Tight Ancilla Bound for General (Non-Surjective) Functions

Our `exists_revSim_of_surjective` proves that surjective endofunctions on `Fin n` can be made reversible with 1 ancilla bit (since surjective = bijective on finite types). The genuinely hard case is non-surjective functions where the max fiber size exceeds 1.

**Conjecture**: For any `f : Fin n → Fin n` with maximum fiber size `k`, there exists a reversible simulation using exactly `Fin k` ancilla, and this is tight — no simulation with `Fin (k-1)` ancilla exists.

The key insight is that the lower bound follows from a pigeonhole argument: if the ancilla space has fewer than `k` elements, then two inputs in the same fiber with the same ancilla must collide, violating injectivity of the simulation bijection.

**Why now?** We have the fiber infrastructure (`fiber`, `maxFiberSize`, `injective_iff_maxFiber_le_one`) and the `RevSim` structure already in place. The upper bound construction requires enumerating fibers and constructing an explicit bijection using `Finset.equivFin`, which is available in Mathlib.

## 2. Circuit Complexity of Reversible Simulation

The Toffoli gate is universal for reversible Boolean computation (any bijection on `Bool^n` can be decomposed into Toffoli gates). We formalized the Toffoli gate and showed it simulates AND.

**Conjecture**: Any function `f : (Fin 2)^n → (Fin 2)^n` can be expressed as a composition of at most `O(n · 2^n)` Toffoli gates applied to `(Fin 2)^(n + O(n))` (i.e., with O(n) ancilla bits). Furthermore, there exist functions requiring `Ω(2^n / n)` Toffoli gates (a counting/Shannon-style lower bound).

The key insight is that the upper bound follows from the standard construction: decompose f into a sequence of controlled-NOT operations using the truth table, and each row requires at most n Toffoli gates. The lower bound is a counting argument comparing the number of possible circuits of given size to the number of bijections.

**Why now?** The Toffoli and Fredkin gate formalizations provide the atomic building blocks. Formalizing circuit composition as lists of gate applications on `(Fin 2)^n` would connect to the existing `rev_compose` theorem and the group structure of `Equiv.Perm`.

## 3. Shannon Entropy Preservation Under Bijections

We proved that bijections preserve cardinality (`bijection_preserves_fiber_card`) and information content of uniform distributions (`bijection_preserves_info`). The natural next step is full Shannon entropy.

**Conjecture**: For any probability distribution `p : α → ℝ≥0∞` on a finite type and any bijection `σ : α ≃ α`, the Shannon entropy `H(p) = -∑_x p(x) log p(x)` equals `H(p ∘ σ⁻¹)`. Moreover, for any non-injective function `f : α → α`, there exists a distribution `p` such that `H(f_* p) < H(p)` (entropy strictly decreases under irreversible maps for some distributions).

The key insight is that Shannon entropy is a symmetric function of the probability vector, and bijections merely permute the vector. The strict decrease for non-injective maps follows because collapsing fibers forces probability mass to merge, which strictly decreases entropy by the strict concavity of `-x log x`.

**Why now?** Mathlib has `MeasureTheory.entropy` and related infrastructure. The challenge is connecting our finite combinatorial setup to the measure-theoretic entropy definition, but `Finset.sum` over explicit distributions avoids most measure theory overhead.

## 4. Reversible Computation and Kolmogorov Complexity

**Conjecture**: For any computable bijection `f : ℕ → ℕ`, the Kolmogorov complexity satisfies `K(f(n)) ≤ K(n) + O(1)` and `K(n) ≤ K(f(n)) + O(1)`. That is, reversible computation preserves Kolmogorov complexity up to an additive constant. For non-injective computable `f`, there exist infinitely many `n` with `K(f(n)) < K(n) - log(|f⁻¹(f(n))|) + O(1)`.

The key insight is that reversibility in the Kolmogorov setting means the description of the inverse is bounded (since it's computable), so the overhead is O(1). The loss for non-injective functions comes from the coding theorem: you lose the information needed to distinguish elements within a fiber.

**Why now?** While Kolmogorov complexity is not directly computable, the inequalities can be stated as relations between program sizes in a fixed universal Turing machine model. Our fiber-size infrastructure provides the combinatorial backbone, and Lean's computability library provides the TM model.

## 5. Thermodynamic Cost of Sorting

**Conjecture**: Any comparison-based sorting algorithm on `n` elements, when implemented reversibly, requires at least `⌈log₂(n!)⌉` ancilla bits, and merge sort achieves this bound (up to lower-order terms). The thermodynamic cost (in units of `kT ln 2`) of irreversible sorting is exactly `log₂(n!)`.

The key insight is that sorting maps `n!` permutations to a single sorted output, so the fiber of the "sort" function has size `n!`. By our `maxFiberSize` framework, this requires `n!` ancilla states, which is `⌈log₂(n!)⌉` bits. This connects algorithmic complexity (comparison lower bounds) to thermodynamic cost via Landauer's principle.

**Why now?** We have the fiber framework and the Landauer bound infrastructure. Formalizing sorting as a function `Equiv.Perm (Fin n) → Fin 1` (collapsing all permutations to one output) makes the fiber size exactly `n!`, directly applying our theory. Mathlib's `Nat.factorial` and Stirling's approximation provide the asymptotic analysis.

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
