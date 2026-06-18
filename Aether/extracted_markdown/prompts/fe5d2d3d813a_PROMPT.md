
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

**Title**: The entry point machinery developed here (fibEntryPoint, its divisibility proper
**Domain**: Applications
**Mathematical framing**: # Future Directions: Fibonacci Entry Point Theory and Primitive Divisors

## 1. Full Carmichael Primitive Divisor Theorem

The entry point machinery developed here (fibEntryPoint, its divisibility property,
and the primitive divisor characterization) provides exactly the framework needed
to prove Carmichael's theorem: for all n ≥ 13, F(n) has a primitive prime divisor.

The key insight is that the entry point characterization reduces Carmichael's theorem
to showing that for each n ≥ 13, there exists a prime p with fibEntryPoint p = n,
which can be established by analyzing the "coprime part" of F(n) — the quotient after
removing all prime factors that appear in F(d) for proper divisors d | n.

Why now? The `isPrimitivePrimeDivisor_iff` theorem gives an exact algebraic criterion
for primitive divisors in terms of entry points. Combined with computational verification
for small cases (which Lean's `native_decide` can handle for n ≤ 10000) and analytic
growth bounds for large n, a complete proof is within reach.

## 2. Pisano Period Exact Formula

The `fib_periodic_mod` theorem establishes existence of periodicity mod m, but does not
characterize the minimal period π(m) (the Pisano period). A natural conjecture is:

**Conjecture**: For prime p ≠ 5, π(p) divides p² − 1. More precisely, π(p) divides
p − 1 if p ≡ ±1 (mod 5), and π(p) divides 2(p + 1) if p ≡ ±2 (mod 5).

The key insight is that the Fibonacci sequence mod p is governed by the splitting behavior
of x² − x − 1 in F_p, which depends on whether 5 is a quadratic residue mod p. This
connects Pisano periods to the Legendre symbol (5/p) and quadratic reciprocity.

Why now? The periodicity infrastructure is in place. The connection to quadratic residues
can leverage Mathlib's existing `ZMod.legendreSym` and `QuadraticReciprocity` machinery.

## 3. Fibonacci Representations and Zeckendorf's Theorem

Every positive integer has a unique representation as a sum of non-consecutive Fibonacci
numbers (Zeckendorf's theorem). This is a constructive result that connects to the
greedy algorithm for Fibonacci representations.

**Conjecture**: The Zeckendorf representation can be computed by the greedy algorithm,
and the number of terms in the representation of n is O(log n / log φ) where φ is the
golden ratio.

The key insight is that the proof of existence uses the entry point theory indirectly:
the gap condition (no consecutive Fibonacci numbers) is forced by the identity
F(k) + F(k+1) = F(k+2), which collapses adjacent terms. Uniqueness follows from
a counting argument using the Cassini identity proved here.

Why now? The `fib_cassini` identity and the strong induction pattern used in
`fib_periodic_mod` provide the exact proof technology needed. Mathlib's `Finset`
API handles the representation as a finite set of indices.

## 4. Entry Point and the ABC Conjecture for Fibonacci

A deep open question is whether the entry point function α(p) satisfies
α(p) > p^ε for some ε > 0 and all sufficiently large primes p. This is
related to the ABC conjecture applied to Fibonacci numbers.

**Conjecture**: For every ε > 0, there exist only finitely many primes p with
α(p) < p^ε (the "Wall-Sun-Sun prime" generalization).

The key insight is that if α(p) is very small relative to p, then F(α(p)) has
an unusually large prime factor relative to its size, creating tension with
the ABC conjecture. The entry point divisibility theorem proved here
(`fibEntryPoint_dvd`) is the foundational tool for any progress on this question.

Why now? While a full resolution likely requires ABC, partial results bounding
α(p) ≥ c·log(p) for an explicit constant c are accessible using the Pisano
period bounds and our periodicity theorem. Even formalizing the precise
relationship between entry points and ABC would be novel.

## 5. Generalized Entry Points for Lucas Sequences

The Fibonacci sequence is a special case of a Lucas sequence U_n(P, Q) with P = Q = 1.
The entry point theory generalizes: for any Lucas sequence, if p | U_n then α(p) | n.

**Conjecture**: For Lucas sequences U_n(P, Q) with Δ = P² − 4Q ≠ 0, the entry point
α(p) of a prime p ∤ 2QΔ satisfies: α(p) | p − (Δ/p), where (Δ/p) is the Legendre symbol.

The key insight is that the proof of `fibEntryPoint_dvd` used only the GCD property
(fib_dvd_of_dvd_gcd), which generalizes to all Lucas sequences via the analogous
identity gcd(U_m, U_n) = U_{gcd(m,n)}. The Cassini identity also generalizes:
U_{n+1}² − P·U_{n+1}·U_n + Q·U_n² = Q^n.

Why now? The proof architecture (entry point → divisibility → periodicity → primitive divisors)
is modular and transfers directly. Mathlib has partial infrastructure for general linear
recurrences that could serve as a foundation.

**Concept description**: # Future Directions: Fibonacci Entry Point Theory and Primitive Divisors

## 1. Full Carmichael Primitive Divisor Theorem

The entry point machinery developed here (fibEntryPoint, its divisibility property,
and the primitive divisor characterization) provides exactly the framework needed
to prove Carmichael's theorem: for all n ≥ 13, F(n) has a primitive prime divisor.

The key insight is that the entry point characterization reduces Carmichael's theorem
to showing that for each n ≥ 13, there exists a prime p with fibEntryPoint p = n,
which can be established by analyzing the "coprime part" of F(n) — the quotient after
removing all prime factors that appear in F(d) for proper divisors d | n.

Why now? The `isPrimitivePrimeDivisor_iff` theorem gives an exact algebraic criterion
for primitive divisors in terms of entry points. Combined with computational verification
for small cases (which Lean's `native_decide` can handle for n ≤ 10000) and analytic
growth bounds for large n, a complete proof is within reach.

## 2. Pisano Period Exact Formula

The `fib_periodic_mod` theorem establishes existence of periodicity mod m, but does not
characterize the minimal period π(m) (the Pisano period). A natural conjecture is:

**Conjecture**: For prime p ≠ 5, π(p) divides p² − 1. More precisely, π(p) divides
p − 1 if p ≡ ±1 (mod 5), and π(p) divides 2(p + 1) if p ≡ ±2 (mod 5).

The key insight is that the Fibonacci sequence mod p is governed by the splitting behavior
of x² − x − 1 in F_p, which depends on whether 5 is a quadratic residue mod p. This
connects Pisano periods to the Legendre symbol (5/p) and quadratic reciprocity.

Why now? The periodicity infrastructure is in place. The connection to quadratic residues
can leverage Mathlib's existing `ZMod.legendreSym` and `QuadraticReciprocity` machinery.

## 3. Fibonacci Representations and Zeckendorf's Theorem

Every positive integer has a unique representation as a sum of non-consecutive Fibonacci
numbers (Zeckendorf's theorem). This is a constructive result that connects to the
greedy algorithm for Fibonacci representations.

**Conjecture**: The Zeckendorf representation can be computed by the greedy algorithm,
and the number of terms in the representation of n is O(log n / log φ) where φ is the
golden ratio.

The key insight is that the proof of existence uses the entry point theory indirectly:
the gap condition (no consecutive Fibonacci numbers) is forced by the identity
F(k) + F(k+1) = F(k+2), which collapses adjacent terms. Uniqueness follows from
a counting argument using the Cassini identity proved here.

Why now? The `fib_cassini` identity and the strong induction pattern used in
`fib_periodic_mod` provide the exact proof technology needed. Mathlib's `Finset`
API handles the representation as a finite set of indices.

## 4. Entry Point and the ABC Conjecture for Fibonacci

A deep open question is whether the entry point function α(p) satisfies
α(p) > p^ε for some ε > 0 and all sufficiently large primes p. This is
related to the ABC conjecture applied to Fibonacci numbers.

**Conjecture**: For every ε > 0, there exist only finitely many primes p with
α(p) < p^ε (the "Wall-Sun-Sun prime" generalization).

The key insight is that if α(p) is very small relative to p, then F(α(p)) has
an unusually large prime factor relative to its size, creating tension with
the ABC conjecture. The entry point divisibility theorem proved here
(`fibEntryPoint_dvd`) is the foundational tool for any progress on this question.

Why now? While a full resolution likely requires ABC, partial results bounding
α(p) ≥ c·log(p) for an explicit constant c are accessible using the Pisano
period bounds and our periodicity theorem. Even formalizing the precise
relationship between entry points and ABC would be novel.

## 5. Generalized Entry Points for Lucas Sequences

The Fibonacci sequence is a special case of a Lucas sequence U_n(P, Q) with P = Q = 1.
The entry point theory generalizes: for any Lucas sequence, if p | U_n then α(p) | n.

**Conjecture**: For Lucas sequences U_n(P, Q) with Δ = P² − 4Q ≠ 0, the entry point
α(p) of a prime p ∤ 2QΔ satisfies: α(p) | p − (Δ/p), where (Δ/p) is the Legendre symbol.

The key insight is that the proof of `fibEntryPoint_dvd` used only the GCD property
(fib_dvd_of_dvd_gcd), which generalizes to all Lucas sequences via the analogous
identity gcd(U_m, U_n) = U_{gcd(m,n)}. The Cassini identity also generalizes:
U_{n+1}² − P·U_{n+1}·U_n + Q·U_n² = Q^n.

Why now? The proof architecture (entry point → divisibility → periodicity → primitive divisors)
is modular and transfers directly. Mathlib has partial infrastructure for general linear
recurrences that could serve as a foundation.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- First-Principles Grounding Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **First-Principles Grounding**. Focus on elegance, structural simplicity, and building blocks of deep theories.

### RESEARCH CORE METHODOLOGY:
1. **Foundational Clarity**: Build theories starting from clean, minimal, first-principles assumptions. Keep definitions mathematically pure, elegant, and simple.
2. **Lemma Factorization**: Decompose large, complex theorems into a hierarchy of beautiful, standalone, reusable lemmas. Each lemma should be a complete mathematical statement of independent interest.
3. **Explanatory Elegance**: Design proofs that are not only correct but structurally beautiful and easy to understand. Let the proofs explain the mathematical mechanism.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
