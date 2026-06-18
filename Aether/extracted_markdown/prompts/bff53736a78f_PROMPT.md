
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

**Title**: The `tropical_power_gap_diagonal` theorem establishes that negative-diagonal tro
**Domain**: Shared
**Mathematical framing**: # Future Directions: Tropical Cryptographic Hardness Hierarchy

## 1. Tropical Matrix Power Stabilization and Effective One-Wayness

The `tropical_power_gap_diagonal` theorem establishes that negative-diagonal tropical matrices produce non-increasing diagonal sequences under powering. A natural next step is proving that these sequences eventually **stabilize** — reaching a fixed point after finitely many steps (the "critical exponent"). The key insight is that in the min-plus semiring over integers, a monotonically non-increasing sequence bounded below by the shortest-path weight must stabilize, and this stabilization exponent is precisely the matrix dimension (by the Bellman-Ford analogy). Why now? The orbit structure theorems (`tropPow_add`, `tropMul_assoc`) provide the algebraic infrastructure to reason about power sequences, and Mathlib's `WithTop ℤ` has the well-order properties needed for the descent argument.

**Conjecture**: For any n×n tropical matrix G with all entries in ℤ (no ⊤), `tropPow G n = tropPow G (n + k)` for all k ≥ 0. This is the tropical analogue of the Bellman-Ford convergence theorem and would give a concrete security parameter for tropical OWFs.

## 2. Tropical PRG Stretch Amplification via Polynomial Composition

The current `prg_stretch_composition` theorem shows multiplicative stretch but uses a trivial construction (ignoring half the outputs). A deeper result would show that tropical PRG stretch can be amplified from 1+ε to polynomial via the Nisan-Wigderson framework adapted to the min-plus setting. The key insight is that tropical polynomial composition (which corresponds to matrix powering chains) creates exponentially many distinct power indices from logarithmically many seed values, and the min-plus structure ensures that each composition step preserves computational indistinguishability. Why now? The `tropPow_add` identity provides the compositional structure, and the `orbitHash` framework gives a natural encoding of PRG outputs as power sequences.

**Conjecture**: For any tropical PRG with stretch m > 1, there exists a tropical PRG with stretch m^d for any d, where each output is a product of at most d original PRG outputs. Moreover, if the original PRG is based on k-th power computation, the amplified PRG has security reducible to (k·d)-th power inversion.

## 3. Max-Affine CPL Decomposition Depth and Network Complexity

The `max_affine_is_cpl` theorem shows that the max of two affine functions is CPL with one breakpoint. The `cpl_add` and `cpl_sub` theorems show CPL closure under arithmetic. A major open direction is formalizing the **depth-width tradeoff**: any CPL function with N breakpoints can be computed by a ReLU network of depth O(log N) and width O(N), but requires width Ω(N^{1/d}) at depth d. The key insight is that tropical polynomial evaluation (pointwise max of affine pieces) corresponds exactly to a single ReLU layer, and the depth of the tropical rational representation equals the network depth. Why now? The `max_affine_is_cpl` result provides the base case, and the CPL closure properties give the inductive structure needed for the width-depth analysis.

**Conjecture**: There exists a family of CPL functions f_n with n breakpoints such that any ReLU network computing f_n with depth d requires width at least n^{1/(d-1)}. This would formalize the folk theorem that "deep networks can represent exponentially more breakpoints."

## 4. Tropical Hybrid Arguments and Computational Indistinguishability

The hierarchy theorems (OWF→PRG→PRF→CPA) currently use type-level implications without computational indistinguishability bounds. A natural extension is formalizing **tropical hybrid arguments**: given a sequence of n tropical matrix distributions where consecutive pairs are (ε/n)-indistinguishable, the endpoints are ε-indistinguishable. The key insight is that tropical matrix addition (which is pointwise min) preserves statistical distance bounds multiplicatively, unlike classical addition which preserves them additively — this gives tighter security reductions in the tropical setting. Why now? The orbit hash structure provides a natural sequence of hybrids (G^1, G^2, ..., G^n), and the power gap theorem constrains how much information each step reveals.

**Conjecture**: If tropical k-th power inversion has advantage at most ε, then the tropical PRG with outputs (G^k, G^{k+1}) has distinguishing advantage at most ε + negl(n), where negl(n) comes from the tropical Goldreich-Levin hard-core predicate (diagonal extraction).

## 5. Tropical Canonical Forms for Multivariate ReLU Networks

The current results handle univariate ReLU networks and their tropical polynomial representations. The multivariate case — ReLU networks ℝ^d → ℝ — involves **tropical rational functions in d variables**, where evaluation is the max of d-variable affine functions. The key insight is that the canonical form theory generalizes: multivariate tropical polynomials correspond to polyhedral complexes (Newton polytopes), and canonicality reduces to the facial structure of these polytopes. Why now? Mathlib's `Convex` and polyhedral geometry infrastructure is maturing, and the univariate results provide the template for the inductive argument on dimension.

**Conjecture**: Every continuous piecewise-linear function ℝ^d → ℝ with N linear regions can be represented as a tropical rational function with at most N terms in the numerator and N terms in the denominator. Moreover, the minimal such representation is unique up to a tropical common factor, generalizing `canonical_tropical_poly_unique` from the univariate case.

**Concept description**: # Future Directions: Tropical Cryptographic Hardness Hierarchy

## 1. Tropical Matrix Power Stabilization and Effective One-Wayness

The `tropical_power_gap_diagonal` theorem establishes that negative-diagonal tropical matrices produce non-increasing diagonal sequences under powering. A natural next step is proving that these sequences eventually **stabilize** — reaching a fixed point after finitely many steps (the "critical exponent"). The key insight is that in the min-plus semiring over integers, a monotonically non-increasing sequence bounded below by the shortest-path weight must stabilize, and this stabilization exponent is precisely the matrix dimension (by the Bellman-Ford analogy). Why now? The orbit structure theorems (`tropPow_add`, `tropMul_assoc`) provide the algebraic infrastructure to reason about power sequences, and Mathlib's `WithTop ℤ` has the well-order properties needed for the descent argument.

**Conjecture**: For any n×n tropical matrix G with all entries in ℤ (no ⊤), `tropPow G n = tropPow G (n + k)` for all k ≥ 0. This is the tropical analogue of the Bellman-Ford convergence theorem and would give a concrete security parameter for tropical OWFs.

## 2. Tropical PRG Stretch Amplification via Polynomial Composition

The current `prg_stretch_composition` theorem shows multiplicative stretch but uses a trivial construction (ignoring half the outputs). A deeper result would show that tropical PRG stretch can be amplified from 1+ε to polynomial via the Nisan-Wigderson framework adapted to the min-plus setting. The key insight is that tropical polynomial composition (which corresponds to matrix powering chains) creates exponentially many distinct power indices from logarithmically many seed values, and the min-plus structure ensures that each composition step preserves computational indistinguishability. Why now? The `tropPow_add` identity provides the compositional structure, and the `orbitHash` framework gives a natural encoding of PRG outputs as power sequences.

**Conjecture**: For any tropical PRG with stretch m > 1, there exists a tropical PRG with stretch m^d for any d, where each output is a product of at most d original PRG outputs. Moreover, if the original PRG is based on k-th power computation, the amplified PRG has security reducible to (k·d)-th power inversion.

## 3. Max-Affine CPL Decomposition Depth and Network Complexity

The `max_affine_is_cpl` theorem shows that the max of two affine functions is CPL with one breakpoint. The `cpl_add` and `cpl_sub` theorems show CPL closure under arithmetic. A major open direction is formalizing the **depth-width tradeoff**: any CPL function with N breakpoints can be computed by a ReLU network of depth O(log N) and width O(N), but requires width Ω(N^{1/d}) at depth d. The key insight is that tropical polynomial evaluation (pointwise max of affine pieces) corresponds exactly to a single ReLU layer, and the depth of the tropical rational representation equals the network depth. Why now? The `max_affine_is_cpl` result provides the base case, and the CPL closure properties give the inductive structure needed for the width-depth analysis.

**Conjecture**: There exists a family of CPL functions f_n with n breakpoints such that any ReLU network computing f_n with depth d requires width at least n^{1/(d-1)}. This would formalize the folk theorem that "deep networks can represent exponentially more breakpoints."

## 4. Tropical Hybrid Arguments and Computational Indistinguishability

The hierarchy theorems (OWF→PRG→PRF→CPA) currently use type-level implications without computational indistinguishability bounds. A natural extension is formalizing **tropical hybrid arguments**: given a sequence of n tropical matrix distributions where consecutive pairs are (ε/n)-indistinguishable, the endpoints are ε-indistinguishable. The key insight is that tropical matrix addition (which is pointwise min) preserves statistical distance bounds multiplicatively, unlike classical addition which preserves them additively — this gives tighter security reductions in the tropical setting. Why now? The orbit hash structure provides a natural sequence of hybrids (G^1, G^2, ..., G^n), and the power gap theorem constrains how much information each step reveals.

**Conjecture**: If tropical k-th power inversion has advantage at most ε, then the tropical PRG with outputs (G^k, G^{k+1}) has distinguishing advantage at most ε + negl(n), where negl(n) comes from the tropical Goldreich-Levin hard-core predicate (diagonal extraction).

## 5. Tropical Canonical Forms for Multivariate ReLU Networks

The current results handle univariate ReLU networks and their tropical polynomial representations. The multivariate case — ReLU networks ℝ^d → ℝ — involves **tropical rational functions in d variables**, where evaluation is the max of d-variable affine functions. The key insight is that the canonical form theory generalizes: multivariate tropical polynomials correspond to polyhedral complexes (Newton polytopes), and canonicality reduces to the facial structure of these polytopes. Why now? Mathlib's `Convex` and polyhedral geometry infrastructure is maturing, and the univariate results provide the template for the inductive argument on dimension.

**Conjecture**: Every continuous piecewise-linear function ℝ^d → ℝ with N linear regions can be represented as a tropical rational function with at most N terms in the numerator and N terms in the denominator. Moreover, the minimal such representation is unique up to a tropical common factor, generalizing `canonical_tropical_poly_unique` from the univariate case.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Shared
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
