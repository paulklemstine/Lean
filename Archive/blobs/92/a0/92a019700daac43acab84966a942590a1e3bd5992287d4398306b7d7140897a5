
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

**Title**: The catalog's Carmichael work (`Catalog/Speculative/AutoResearch/CarmichaelCompo
**Domain**: Applications
**Mathematical framing**: # Future Directions — Fibonacci Entry-Point Theory and Carmichael's Primitive-Divisor Theorem

## Synthesis

The catalog's Carmichael work (`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`,
`Catalog/Shared/CarmichaelProof.lean`, `Catalog/Novelty/FibonacciEntryPointDuality.lean`)
is organized around the *entry point* (rank of apparition) `entryPt m = min { k > 0 : m ∣ F_k }`.
Those files establish the divisibility plumbing (`fibEntryPt_dvd_of_fib_dvd`,
`primitive_of_entryPt_eq`) but treat totality of the entry point and the finite range
`n ≤ 10000` as `native_decide` certificates, and leave the genuine tail — every composite
`n > 10000` admits a primitive prime divisor of `F_n` — as a `sorry`.

This cycle isolates and proves, fully `sorry`-free, the *structural core* on which all of
that rests (`Catalog/Novelty/FibonacciEntryPointTheory.lean`):

* `entry_exists` — **totality**: every `m ≥ 1` divides some positive Fibonacci number,
  so `entryPt` is a genuine total function rather than a partial one patched with `0`.
  The proof is a pure-periodicity / pigeonhole argument on the state `(F_k, F_{k+1}) mod m`.
* `fib_dvd_iff_entryPt_dvd` — the **divisibility characterization** `m ∣ F_n ↔ entryPt m ∣ n`,
  generalising `Nat.fib_dvd` and `Nat.fib_gcd` into a single biconditional.
* `primitive_iff_entryPt_eq` — `p` is a primitive prime divisor of `F_n` **iff** `entryPt p = n`,
  abstracting the catalog's one-directional `primitive_of_entryPt_eq` into an exact criterion.

## Results Summary

Six theorems, no `sorry`, axioms `{propext, Classical.choice, Quot.sound}` only.
The headline characterizations turn "primitive divisor" questions into elementary
divisibility questions about a single total arithmetic function `entryPt`.

## Research Directions

### 1. Entry points respect the CRT: a coprime-multiplicativity law
**Conjecture.** For coprime `m, n ≥ 1`, `entryPt (m * n) = Nat.lcm (entryPt m) (entryPt n)`.
The key insight is that, via `fib_dvd_iff_entryPt_dvd`, the predicate `m * n ∣ F_k` factors
as `(m ∣ F_k) ∧ (n ∣ F_k)`, i.e. `entryPt m ∣ k ∧ entryPt n ∣ k`, whose least positive
solution is exactly `lcm`. **Why now?** The biconditional `fib_dvd_iff_entryPt_dvd` proved
this cycle reduces the statement to `Nat.lcm` being the join of the divisibility lattice —
no new analysis is needed, only `Nat.Coprime.dvd_of_dvd_mul_right` style plumbing. This is
the cleanest possible falsifiable next step and immediately reduces `entryPt` of any integer
to its prime-power components.

### 2. The size estimate that closes the `n > 10000` Carmichael tail
**Conjecture.** For all `n ≥ 13`, the primitive part `primPart n` (defined in
`Catalog/Shared/CarmichaelProof.lean`) satisfies `1 < primPart n` *unboundedly*, because
`log F_n ≈ n log φ` strictly dominates `∑_{d ∣ n, d < n} log F_d`. Concretely, for composite
`n`, `∏_{d ∣ n, d < n} F_d < F_n`, so stripping all `F_d` from `F_n` cannot reach `1`.
The key insight is that primitivity is *forced by growth*: the entry-point characterization
already guarantees that any surviving prime factor is primitive, so the only missing ingredient
is the inequality `∑_{d ∣ n, d < n} d ≤ n - 1` combined with `F_d ≤ φ^{d-1}` and
`F_n ≥ φ^{n-2}`. **Why now?** `primitive_iff_entryPt_eq` removes the number-theoretic content
and leaves a purely *quantitative* comparison of Fibonacci magnitudes — a `Nat`/`Real`
inequality of the kind that is routine to formalise, directly retiring the catalog `sorry`.

### 3. Exact exception set for primitive divisors (sharp Carmichael)
**Conjecture.** `F_n` has a primitive prime divisor for every `n` *except* `n ∈ {1, 2, 6, 12}`,
and these four are the *only* exceptions. The key insight is that `primitive_iff_entryPt_eq`
recasts "no primitive divisor" as "every prime factor `p ∣ F_n` has `entryPt p < n`", a finite,
checkable condition once the growth bound of Direction 2 caps the candidate range. **Why now?**
With totality (`entry_exists`) and the primitivity criterion in hand, the exceptional set is a
*finite* search glued to the asymptotic bound, making the sharp statement provable rather than
merely verified on a range.

### 4. Pisano period versus entry point
**Conjecture.** The Pisano period `π(m)` (least `t > 0` with `F_{k+t} ≡ F_k (mod m)` for all `k`)
is always a multiple of `entryPt m`, and for an odd prime `p` the ratio `π(p) / entryPt(p) ∈ {1, 2, 4}`.
The key insight is that the pigeonhole/pure-periodicity argument inside `entry_exists` actually
constructs `π(m)` as the order of the state-transition map `T(a,b) = (b, a+b)` on `(ZMod m)²`,
and `entryPt m` is the first return of the *first coordinate* to `0`; the quotient measures the
multiplicative order of `F_{entryPt+1}` modulo `m`. **Why now?** The state-map machinery is
already built and verified in this cycle, so promoting it from "a period exists" to "the period
is `orderOf T`" is an incremental, falsifiable refinement.

### 5. Zsygmondy beyond Fibonacci: nondegenerate Lucas sequences
**Conjecture.** For a nondegenerate Lucas sequence `U_n(P, Q)` (with `U_0 = 0`, `U_1 = 1`,
`U_{n+2} = P·U_{n+1} - Q·U_n`, `gcd(P,Q)=1`, `P² - 4Q ≠ 0`), the entry-point characterization
`m ∣ U_n ↔ entryPt_U m ∣ n` holds verbatim, and `U_n` has a primitive prime divisor for all
`n` outside an explicit finite set depending only on `(P, Q)`. The key insight is that *nothing*
in this cycle's proofs used `P = Q = 1` beyond the recurrence and the reversibility
`U_a = (U_{a+2} - P·U_{a+1}) / (-Q)` modulo `m` (a unit since `gcd(Q,m)=1` on the relevant part);
the state map `(a,b) ↦ (b, P·b - Q·a)` is still a bijection on `(ZMod m)²` when `Q` is a unit.
**Why now?** The Fibonacci proofs are written against the abstract two-term recurrence pattern,
so generalising them is a parameterisation exercise rather than a new theory — the most direct
route toward a Lean formalisation of the Bilu–Hanrot–Voutier primitive-divisor theorem.

**Concept description**: # Future Directions — Fibonacci Entry-Point Theory and Carmichael's Primitive-Divisor Theorem

## Synthesis

The catalog's Carmichael work (`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`,
`Catalog/Shared/CarmichaelProof.lean`, `Catalog/Novelty/FibonacciEntryPointDuality.lean`)
is organized around the *entry point* (rank of apparition) `entryPt m = min { k > 0 : m ∣ F_k }`.
Those files establish the divisibility plumbing (`fibEntryPt_dvd_of_fib_dvd`,
`primitive_of_entryPt_eq`) but treat totality of the entry point and the finite range
`n ≤ 10000` as `native_decide` certificates, and leave the genuine tail — every composite
`n > 10000` admits a primitive prime divisor of `F_n` — as a `sorry`.

This cycle isolates and proves, fully `sorry`-free, the *structural core* on which all of
that rests (`Catalog/Novelty/FibonacciEntryPointTheory.lean`):

* `entry_exists` — **totality**: every `m ≥ 1` divides some positive Fibonacci number,
  so `entryPt` is a genuine total function rather than a partial one patched with `0`.
  The proof is a pure-periodicity / pigeonhole argument on the state `(F_k, F_{k+1}) mod m`.
* `fib_dvd_iff_entryPt_dvd` — the **divisibility characterization** `m ∣ F_n ↔ entryPt m ∣ n`,
  generalising `Nat.fib_dvd` and `Nat.fib_gcd` into a single biconditional.
* `primitive_iff_entryPt_eq` — `p` is a primitive prime divisor of `F_n` **iff** `entryPt p = n`,
  abstracting the catalog's one-directional `primitive_of_entryPt_eq` into an exact criterion.

## Results Summary

Six theorems, no `sorry`, axioms `{propext, Classical.choice, Quot.sound}` only.
The headline characterizations turn "primitive divisor" questions into elementary
divisibility questions about a single total arithmetic function `entryPt`.

## Research Directions

### 1. Entry points respect the CRT: a coprime-multiplicativity law
**Conjecture.** For coprime `m, n ≥ 1`, `entryPt (m * n) = Nat.lcm (entryPt m) (entryPt n)`.
The key insight is that, via `fib_dvd_iff_entryPt_dvd`, the predicate `m * n ∣ F_k` factors
as `(m ∣ F_k) ∧ (n ∣ F_k)`, i.e. `entryPt m ∣ k ∧ entryPt n ∣ k`, whose least positive
solution is exactly `lcm`. **Why now?** The biconditional `fib_dvd_iff_entryPt_dvd` proved
this cycle reduces the statement to `Nat.lcm` being the join of the divisibility lattice —
no new analysis is needed, only `Nat.Coprime.dvd_of_dvd_mul_right` style plumbing. This is
the cleanest possible falsifiable next step and immediately reduces `entryPt` of any integer
to its prime-power components.

### 2. The size estimate that closes the `n > 10000` Carmichael tail
**Conjecture.** For all `n ≥ 13`, the primitive part `primPart n` (defined in
`Catalog/Shared/CarmichaelProof.lean`) satisfies `1 < primPart n` *unboundedly*, because
`log F_n ≈ n log φ` strictly dominates `∑_{d ∣ n, d < n} log F_d`. Concretely, for composite
`n`, `∏_{d ∣ n, d < n} F_d < F_n`, so stripping all `F_d` from `F_n` cannot reach `1`.
The key insight is that primitivity is *forced by growth*: the entry-point characterization
already guarantees that any surviving prime factor is primitive, so the only missing ingredient
is the inequality `∑_{d ∣ n, d < n} d ≤ n - 1` combined with `F_d ≤ φ^{d-1}` and
`F_n ≥ φ^{n-2}`. **Why now?** `primitive_iff_entryPt_eq` removes the number-theoretic content
and leaves a purely *quantitative* comparison of Fibonacci magnitudes — a `Nat`/`Real`
inequality of the kind that is routine to formalise, directly retiring the catalog `sorry`.

### 3. Exact exception set for primitive divisors (sharp Carmichael)
**Conjecture.** `F_n` has a primitive prime divisor for every `n` *except* `n ∈ {1, 2, 6, 12}`,
and these four are the *only* exceptions. The key insight is that `primitive_iff_entryPt_eq`
recasts "no primitive divisor" as "every prime factor `p ∣ F_n` has `entryPt p < n`", a finite,
checkable condition once the growth bound of Direction 2 caps the candidate range. **Why now?**
With totality (`entry_exists`) and the primitivity criterion in hand, the exceptional set is a
*finite* search glued to the asymptotic bound, making the sharp statement provable rather than
merely verified on a range.

### 4. Pisano period versus entry point
**Conjecture.** The Pisano period `π(m)` (least `t > 0` with `F_{k+t} ≡ F_k (mod m)` for all `k`)
is always a multiple of `entryPt m`, and for an odd prime `p` the ratio `π(p) / entryPt(p) ∈ {1, 2, 4}`.
The key insight is that the pigeonhole/pure-periodicity argument inside `entry_exists` actually
constructs `π(m)` as the order of the state-transition map `T(a,b) = (b, a+b)` on `(ZMod m)²`,
and `entryPt m` is the first return of the *first coordinate* to `0`; the quotient measures the
multiplicative order of `F_{entryPt+1}` modulo `m`. **Why now?** The state-map machinery is
already built and verified in this cycle, so promoting it from "a period exists" to "the period
is `orderOf T`" is an incremental, falsifiable refinement.

### 5. Zsygmondy beyond Fibonacci: nondegenerate Lucas sequences
**Conjecture.** For a nondegenerate Lucas sequence `U_n(P, Q)` (with `U_0 = 0`, `U_1 = 1`,
`U_{n+2} = P·U_{n+1} - Q·U_n`, `gcd(P,Q)=1`, `P² - 4Q ≠ 0`), the entry-point characterization
`m ∣ U_n ↔ entryPt_U m ∣ n` holds verbatim, and `U_n` has a primitive prime divisor for all
`n` outside an explicit finite set depending only on `(P, Q)`. The key insight is that *nothing*
in this cycle's proofs used `P = Q = 1` beyond the recurrence and the reversibility
`U_a = (U_{a+2} - P·U_{a+1}) / (-Q)` modulo `m` (a unit since `gcd(Q,m)=1` on the relevant part);
the state map `(a,b) ↦ (b, P·b - Q·a)` is still a bijection on `(ZMod m)²` when `Q` is a unit.
**Why now?** The Fibonacci proofs are written against the abstract two-term recurrence pattern,
so generalising them is a parameterisation exercise rather than a new theory — the most direct
route toward a Lean formalisation of the Bilu–Hanrot–Voutier primitive-divisor theorem.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v11 Depth Requirements -- Algorithmic & Constructive Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Algorithmic & Constructive Generation**. Prioritize concrete computation, explicit witness constructions, and algorithmic content.

### RESEARCH CORE METHODOLOGY:
1. **Constructive Witness Extraction**: Whenever asserting that an object exists, focus on constructing it explicitly. Avoid non-constructive classical axioms (like double negation elimination or classical choice) unless absolutely necessary.
2. **Computational Verification**: Build definitions that can be computationally evaluated (`#eval` or `decide`). Connect abstract algebra/topology directly to effective algorithms and discrete models.
3. **Algorithmic Complexity**: Focus on the computational power and structures of your mathematical objects, proving properties about their stability, convergence, or decidability.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
