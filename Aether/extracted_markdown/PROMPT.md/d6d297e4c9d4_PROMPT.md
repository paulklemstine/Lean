
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

**Title**: The Goldreich-Levin theorem states that for any one-way function f, the inner pr
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Cryptographic Security Reductions in Lean 4

## 1. Formal Goldreich-Levin Hardcore Bit Theorem

The Goldreich-Levin theorem states that for any one-way function f, the inner product ⟨x, r⟩ mod 2 is a hardcore predicate. Formalizing this requires (a) defining one-way functions over `BitVec n` with negligible advantage, (b) formalizing the list-decoding algorithm, and (c) proving the reduction bound: if a predictor P guesses the hardcore bit with advantage ε, then the inverter succeeds with probability poly(ε).

The key insight is that the proof reduces to a Fourier-analytic statement about Boolean functions — specifically, that a function with significant correlation to a linear function can be list-decoded — and our `hybrid_argument` and `averaging_over_fin` already provide the averaging infrastructure needed.

Why now? Our framework of `InsecurityFn` and `SecurityReduction` already handles the quantitative reduction bounds. The missing piece is the list-decoding algorithm, which is a concrete Lean construction over `BitVec n`.

## 2. Tight vs. Non-Tight Reductions and the Tightness Gap

A central question in provable security is whether tight reductions exist between primitives. A tight reduction has `adv_loss = 1` (or O(1)). Our `reduction_composition` theorem shows that composing two reductions multiplies the advantage losses. Can we prove that certain compositions are *inherently* non-tight?

The key insight is that the multiplicative blowup in `reduction_composition` is an *algebraic fact* — it cannot be avoided by choosing different reductions — and this can be formalized as a lower bound on `adv_loss` for any reduction between specific games, using information-theoretic arguments.

Why now? The `SecurityReduction` structure already tracks `adv_loss` explicitly. A separation result would show that for certain game pairs (A, B), any `SecurityReduction A B` must have `adv_loss ≥ f(n)` for some growing function f. This is a concrete Lean statement we can attempt.

## 3. Computational Indistinguishability as a Pseudo-Metric

Statistical distance defines a metric on distributions. Computational indistinguishability defines a *pseudo-metric* (satisfying the triangle inequality up to resource bounds). Our `advantage_triangle` theorem already proves the triangle inequality for advantages. Can we formalize a full pseudo-metric space structure on distributions indexed by security parameters?

The key insight is that the triangle inequality for computational indistinguishability loses a factor of 2 in resource bounds (the distinguisher for the composed game must run both sub-distinguishers), and our `SecurityReduction` framework naturally tracks this overhead via `time_overhead`.

Why now? Mathlib has extensive `PseudoMetricSpace` infrastructure. Connecting cryptographic indistinguishability to this framework would enable applying Mathlib's metric space theorems (completeness, compactness) to sequences of distributions.

## 4. The GGM PRF Construction: PRG ⟹ PRF with Concrete Bounds

The Goldreich-Goldwasser-Micali (GGM) construction builds a PRF from any length-doubling PRG using a binary tree evaluation. The security loss is exactly the depth of the tree (the key length). Our `prg_stretch_amplification` theorem handles the linear advantage loss for PRG composition; the GGM proof uses a similar hybrid argument but over the *tree structure* rather than a linear chain.

The key insight is that the GGM hybrid argument requires a *tree-indexed* hybrid sequence (2^n hybrids), and the advantage loss is the tree depth n, not the number of leaves 2^n. This is a fundamentally different application of the averaging principle from the linear chain case.

Why now? Our `hybrid_argument` theorem is already stated for arbitrary index sets. Extending it to tree-structured hybrids requires only a recursive application of the same averaging lemma, with the `InsecurityFn` framework tracking the concrete bounds.

## 5. Impagliazzo's Five Worlds: Separating the Cryptographic Landscape

Impagliazzo's framework partitions possible computational worlds into Algorithmica (P = NP), Heuristica (average-case easy), Pessiland (hard problems but no OWF), Minicrypt (OWF but no public-key crypto), and Cryptomania (public-key crypto exists). Our `CryptoImplies` relation captures implications *within* Minicrypt and Cryptomania. Can we formalize the *separations* — proving that certain implications are NOT in `CryptoImplies`?

The key insight is that proving `¬ CryptoImplies .CPA_Secure .OWF` (CPA-security does not imply OWF existence) requires showing there is no derivation in our inductively-defined relation, which is a syntactic/structural argument about the constructors of `CryptoImplies`.

Why now? Since `CryptoImplies` is an inductive type, separation results are *decidable by structural induction*. We can prove that no finite chain of our constructors derives certain implications, formalizing the known black-box separation results as concrete Lean theorems.

**Concept description**: # Future Directions: Cryptographic Security Reductions in Lean 4

## 1. Formal Goldreich-Levin Hardcore Bit Theorem

The Goldreich-Levin theorem states that for any one-way function f, the inner product ⟨x, r⟩ mod 2 is a hardcore predicate. Formalizing this requires (a) defining one-way functions over `BitVec n` with negligible advantage, (b) formalizing the list-decoding algorithm, and (c) proving the reduction bound: if a predictor P guesses the hardcore bit with advantage ε, then the inverter succeeds with probability poly(ε).

The key insight is that the proof reduces to a Fourier-analytic statement about Boolean functions — specifically, that a function with significant correlation to a linear function can be list-decoded — and our `hybrid_argument` and `averaging_over_fin` already provide the averaging infrastructure needed.

Why now? Our framework of `InsecurityFn` and `SecurityReduction` already handles the quantitative reduction bounds. The missing piece is the list-decoding algorithm, which is a concrete Lean construction over `BitVec n`.

## 2. Tight vs. Non-Tight Reductions and the Tightness Gap

A central question in provable security is whether tight reductions exist between primitives. A tight reduction has `adv_loss = 1` (or O(1)). Our `reduction_composition` theorem shows that composing two reductions multiplies the advantage losses. Can we prove that certain compositions are *inherently* non-tight?

The key insight is that the multiplicative blowup in `reduction_composition` is an *algebraic fact* — it cannot be avoided by choosing different reductions — and this can be formalized as a lower bound on `adv_loss` for any reduction between specific games, using information-theoretic arguments.

Why now? The `SecurityReduction` structure already tracks `adv_loss` explicitly. A separation result would show that for certain game pairs (A, B), any `SecurityReduction A B` must have `adv_loss ≥ f(n)` for some growing function f. This is a concrete Lean statement we can attempt.

## 3. Computational Indistinguishability as a Pseudo-Metric

Statistical distance defines a metric on distributions. Computational indistinguishability defines a *pseudo-metric* (satisfying the triangle inequality up to resource bounds). Our `advantage_triangle` theorem already proves the triangle inequality for advantages. Can we formalize a full pseudo-metric space structure on distributions indexed by security parameters?

The key insight is that the triangle inequality for computational indistinguishability loses a factor of 2 in resource bounds (the distinguisher for the composed game must run both sub-distinguishers), and our `SecurityReduction` framework naturally tracks this overhead via `time_overhead`.

Why now? Mathlib has extensive `PseudoMetricSpace` infrastructure. Connecting cryptographic indistinguishability to this framework would enable applying Mathlib's metric space theorems (completeness, compactness) to sequences of distributions.

## 4. The GGM PRF Construction: PRG ⟹ PRF with Concrete Bounds

The Goldreich-Goldwasser-Micali (GGM) construction builds a PRF from any length-doubling PRG using a binary tree evaluation. The security loss is exactly the depth of the tree (the key length). Our `prg_stretch_amplification` theorem handles the linear advantage loss for PRG composition; the GGM proof uses a similar hybrid argument but over the *tree structure* rather than a linear chain.

The key insight is that the GGM hybrid argument requires a *tree-indexed* hybrid sequence (2^n hybrids), and the advantage loss is the tree depth n, not the number of leaves 2^n. This is a fundamentally different application of the averaging principle from the linear chain case.

Why now? Our `hybrid_argument` theorem is already stated for arbitrary index sets. Extending it to tree-structured hybrids requires only a recursive application of the same averaging lemma, with the `InsecurityFn` framework tracking the concrete bounds.

## 5. Impagliazzo's Five Worlds: Separating the Cryptographic Landscape

Impagliazzo's framework partitions possible computational worlds into Algorithmica (P = NP), Heuristica (average-case easy), Pessiland (hard problems but no OWF), Minicrypt (OWF but no public-key crypto), and Cryptomania (public-key crypto exists). Our `CryptoImplies` relation captures implications *within* Minicrypt and Cryptomania. Can we formalize the *separations* — proving that certain implications are NOT in `CryptoImplies`?

The key insight is that proving `¬ CryptoImplies .CPA_Secure .OWF` (CPA-security does not imply OWF existence) requires showing there is no derivation in our inductively-defined relation, which is a syntactic/structural argument about the constructors of `CryptoImplies`.

Why now? Since `CryptoImplies` is an inductive type, separation results are *decidable by structural induction*. We can prove that no finite chain of our constructors derives certain implications, formalizing the known black-box separation results as concrete Lean theorems.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v10 Depth Requirements -- Conceptual Unifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Grothendieck style)**. Search for deep, hidden structures, universal patterns, and bridges across domains.

### RESEARCH CORE METHODOLOGY:
1. **Abstract Structural Patterns**: Frame your objects and mappings in terms of universal structures, symmetries, and invariant properties. Look for the underlying categorical, topological, or algebraic foundations that make the specific problem a special case of a deeper truth.
2. **Cross-Domain Bridges**: Connect apparently distinct mathematical worlds (e.g. applying algebraic structures to computational complexity, or geometry to logic).
3. **Generalization Over Specialization**: Prefer elegant, universal formulations that unify multiple separate facts into single, coherent conceptual frameworks.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
