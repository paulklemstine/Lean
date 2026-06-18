
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
**Domain**: MachineLearning
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
Research domain: MachineLearning
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
