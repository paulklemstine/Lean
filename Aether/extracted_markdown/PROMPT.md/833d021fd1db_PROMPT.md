
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

**Title**: `Speculative/AutoResearch/FibonacciEntryPointDuality.lean`,
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Entry-Point Duality and Primitive Divisors

## Synthesis

This cycle produced `Speculative/AutoResearch/FibonacciEntryPointDuality.lean`, a
self-contained, `sorry`-free development of the *rank of apparition* (entry point)
`z(p)` of the Fibonacci sequence and four results built on it:

* `fib_dvd_iff_fibEntry_dvd` — the master biconditional `p ∣ F_n ↔ z(p) ∣ n`;
* `isFibPrimitiveDivisor_iff_entry` — primitivity of `p` for `F_n` reduces to the
  single equation `z(p) = n`;
* `fib_dvd_iff` — the strong-divisibility law `F_m ∣ F_n ↔ m ∣ n` (`m ≥ 3`),
  recovered as the special case `p = F_m`;
* `fib_primitive_divisor_verified` — a `native_decide` certificate of Carmichael's
  theorem for `1 ≤ n ≤ 40`, `n ∉ {1,2,6,12}`.

The unifying discovery is that the previously *scattered, one-directional*
entry-point lemmas in the catalog (`CarmichaelComposite.fibEntryPt_dvd_of_fib_dvd`,
the `Algebra` LTE file's `fibEntryPoint`, and the computational primitive-part
extractors `CarmichaelProof.primPart` / `CarmichaelComposite.fibCoprimePart`) are
all corollaries of one biconditional, and that biconditional needs nothing beyond
`Nat.fib_gcd` and `Nat.fib_dvd`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_dvd_iff_fibEntry_dvd` | `p ∣ F_n ↔ z(p) ∣ n` | proved (sorry-free) |
| `isFibPrimitiveDivisor_iff_entry` | primitivity `⇔ z(p) = n` | proved (sorry-free) |
| `fib_dvd_iff` | `F_m ∣ F_n ↔ m ∣ n`, `m ≥ 3` | proved (sorry-free) |
| `fib_primitive_divisor_verified` | Carmichael for `n ≤ 40` | proved (`native_decide`) |

The genuinely open object in the catalog remains the *infinite tail* of
Carmichael's composite case (`Shared/CarmichaelProof.lean`, `fib_carmichael_composite`
for composite `n > 10000`), whose surrounding files additionally depend on a
missing `Shared.CarmichaelHelper` module. The directions below are chosen to chip
away at exactly that frontier with reusable, falsifiable lemmas.

---

## Direction 1 — A closed-form lower bound on the primitive part

**Conjecture.** Let `Φ*(n)` be the primitive part of `F_n` (the largest divisor of
`F_n` coprime to every `F_d` with `d ∣ n`, `d < n`, as already computed by
`CarmichaelProof.primPart`). Then for every composite `n ≥ 14`,
`Φ*(n) > n`, and in particular `Φ*(n) > 1`.

The key insight is that `Φ*(n)` tracks the cyclotomic factor `Φ_n(φ, ψ)` evaluated
at the Fibonacci recurrence roots, so `log Φ*(n) = φ(n)·log((1+√5)/2) + o(φ(n))`;
once Euler's totient `φ(n)` is shown to dominate `log n`, the inequality is purely
analytic and *uniform* in `n`, eliminating the `native_decide` ceiling at 10000.

Why now? The entry-point duality of this cycle already certifies that every prime
factor of `Φ*(n)` is primitive, so a single size bound `Φ*(n) > 1` upgrades to a
full existence proof — turning the open infinite tail into one growth lemma rather
than a case analysis.

## Direction 2 — Lifting-the-Exponent collapses the intrinsic prime

**Conjecture.** For a prime `p` with entry point `z = z(p)` and any `n` with `z ∣ n`,
`v_p(F_n) = v_p(F_z) + v_p(n/z)`, and consequently the only prime that can divide
`Φ*(n)` *without* being primitive is the largest prime factor of `n`.

The key insight is that LTE makes the `p`-adic valuation of `F_n` an *affine*
function of `v_p(n)`, so non-primitive contributions to `F_n` are bounded by `n`
itself — exactly the slack needed to make Direction 1's inequality `Φ*(n) > n`
sufficient rather than merely necessary.

Why now? The catalog's `Algebra/…Lifting_the_Exponent…` file already states the LTE
scaffold; combining it with `fib_dvd_iff_fibEntry_dvd` (this cycle) gives the
valuation identity on the nose, with no new transcendence input.

## Direction 3 — Entry points are eventually surjective onto divisor lattices

**Conjecture.** The map `p ↦ z(p)` from primes to positive integers hits every
sufficiently large integer: there is `N₀` such that for all `n ≥ N₀`, some prime `p`
has `z(p) = n`. (This is Carmichael's theorem restated through `isFibPrimitiveDivisor_iff_entry`.)

The key insight is that `isFibPrimitiveDivisor_iff_entry` already proves
"primitive divisor of `F_n`" and "`z(p) = n`" are *literally the same statement*,
so surjectivity of `z` past `N₀` is logically equivalent to the eventual existence
of primitive divisors — letting one attack the analytic Direction 1 and the
combinatorial surjectivity statement interchangeably.

Why now? With the equation `z(p)=n` in hand, the problem detaches from Fibonacci
specifics and becomes a clean statement about a single arithmetic function, inviting
sieve- or density-style arguments that do not need the recurrence at all.

## Direction 4 — A bounded-degree CSS chain complex from the entry-point lattice

**Conjecture.** Order the indices `{1,…,N}` by divisibility and form the boundary map
`∂` sending `n` to the formal sum of its maximal proper divisors. Assigning to each
index `n` the `𝔽₂`-vector `(p ∣ F_n)_p` over primitive primes yields a 2-term chain
complex whose homology has dimension equal to the number of `n ≤ N` possessing a
primitive divisor; for `N` large this dimension is `N − 4` (the four exceptions
`1,2,6,12`).

The key insight is that primitivity = "`z(p)=n`" makes the primitive-prime
indicator a *diagonal* cochain in the divisor lattice, so the CSS distance and the
homology dimension are governed by the same entry-point equation that this cycle
isolated — a concrete bridge from the requested expander/quantum-code framing to the
number theory actually present in the catalog.

Why now? The catalog has both Fibonacci primitive-divisor machinery and cellular
sheaf/cohomology files (`Cryptography/CellularSheafCohomology.lean`); the entry-point
duality is the missing dictionary that lets a homological statement be *decided*
index-by-index, exactly as `fib_primitive_divisor_verified` does for `N = 40`.

## Direction 5 — Replace `native_decide` with a verified primitive-divisor algorithm

**Conjecture.** The `Nat.find`-based `fibEntry` extends to a *fuel-free, structurally
terminating* function `firstPrimitiveDivisor : ℕ → ℕ` that returns the least
primitive prime divisor of `F_n` (or `0` for `n ∈ {1,2,6,12}`), and one can prove
`∀ n, firstPrimitiveDivisor n ≠ 0 → IsFibPrimitiveDivisor (firstPrimitiveDivisor n) n`
*without* `native_decide`, by reflection on the entry-point equation.

The key insight is that `isFibPrimitiveDivisor_iff_entry` reduces correctness of the
algorithm to the decidable check `z(p) = n`, so the verification becomes a
`decide`-on-`Bool` reflection rather than an opaque kernel-trusted `native_decide`,
removing `Lean.ofReduceBool` / `Lean.trustCompiler` from the axiom footprint.

Why now? The constructive `fibEntry` of this cycle is already `Nat.find`; promoting
it to a Bool-reflective certificate is the last step to a fully kernel-checked,
algorithmic Carmichael witness generator — the constructive deliverable this engine
is configured to prize.

**Concept description**: # Future Directions — Entry-Point Duality and Primitive Divisors

## Synthesis

This cycle produced `Speculative/AutoResearch/FibonacciEntryPointDuality.lean`, a
self-contained, `sorry`-free development of the *rank of apparition* (entry point)
`z(p)` of the Fibonacci sequence and four results built on it:

* `fib_dvd_iff_fibEntry_dvd` — the master biconditional `p ∣ F_n ↔ z(p) ∣ n`;
* `isFibPrimitiveDivisor_iff_entry` — primitivity of `p` for `F_n` reduces to the
  single equation `z(p) = n`;
* `fib_dvd_iff` — the strong-divisibility law `F_m ∣ F_n ↔ m ∣ n` (`m ≥ 3`),
  recovered as the special case `p = F_m`;
* `fib_primitive_divisor_verified` — a `native_decide` certificate of Carmichael's
  theorem for `1 ≤ n ≤ 40`, `n ∉ {1,2,6,12}`.

The unifying discovery is that the previously *scattered, one-directional*
entry-point lemmas in the catalog (`CarmichaelComposite.fibEntryPt_dvd_of_fib_dvd`,
the `Algebra` LTE file's `fibEntryPoint`, and the computational primitive-part
extractors `CarmichaelProof.primPart` / `CarmichaelComposite.fibCoprimePart`) are
all corollaries of one biconditional, and that biconditional needs nothing beyond
`Nat.fib_gcd` and `Nat.fib_dvd`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_dvd_iff_fibEntry_dvd` | `p ∣ F_n ↔ z(p) ∣ n` | proved (sorry-free) |
| `isFibPrimitiveDivisor_iff_entry` | primitivity `⇔ z(p) = n` | proved (sorry-free) |
| `fib_dvd_iff` | `F_m ∣ F_n ↔ m ∣ n`, `m ≥ 3` | proved (sorry-free) |
| `fib_primitive_divisor_verified` | Carmichael for `n ≤ 40` | proved (`native_decide`) |

The genuinely open object in the catalog remains the *infinite tail* of
Carmichael's composite case (`Shared/CarmichaelProof.lean`, `fib_carmichael_composite`
for composite `n > 10000`), whose surrounding files additionally depend on a
missing `Shared.CarmichaelHelper` module. The directions below are chosen to chip
away at exactly that frontier with reusable, falsifiable lemmas.

---

## Direction 1 — A closed-form lower bound on the primitive part

**Conjecture.** Let `Φ*(n)` be the primitive part of `F_n` (the largest divisor of
`F_n` coprime to every `F_d` with `d ∣ n`, `d < n`, as already computed by
`CarmichaelProof.primPart`). Then for every composite `n ≥ 14`,
`Φ*(n) > n`, and in particular `Φ*(n) > 1`.

The key insight is that `Φ*(n)` tracks the cyclotomic factor `Φ_n(φ, ψ)` evaluated
at the Fibonacci recurrence roots, so `log Φ*(n) = φ(n)·log((1+√5)/2) + o(φ(n))`;
once Euler's totient `φ(n)` is shown to dominate `log n`, the inequality is purely
analytic and *uniform* in `n`, eliminating the `native_decide` ceiling at 10000.

Why now? The entry-point duality of this cycle already certifies that every prime
factor of `Φ*(n)` is primitive, so a single size bound `Φ*(n) > 1` upgrades to a
full existence proof — turning the open infinite tail into one growth lemma rather
than a case analysis.

## Direction 2 — Lifting-the-Exponent collapses the intrinsic prime

**Conjecture.** For a prime `p` with entry point `z = z(p)` and any `n` with `z ∣ n`,
`v_p(F_n) = v_p(F_z) + v_p(n/z)`, and consequently the only prime that can divide
`Φ*(n)` *without* being primitive is the largest prime factor of `n`.

The key insight is that LTE makes the `p`-adic valuation of `F_n` an *affine*
function of `v_p(n)`, so non-primitive contributions to `F_n` are bounded by `n`
itself — exactly the slack needed to make Direction 1's inequality `Φ*(n) > n`
sufficient rather than merely necessary.

Why now? The catalog's `Algebra/…Lifting_the_Exponent…` file already states the LTE
scaffold; combining it with `fib_dvd_iff_fibEntry_dvd` (this cycle) gives the
valuation identity on the nose, with no new transcendence input.

## Direction 3 — Entry points are eventually surjective onto divisor lattices

**Conjecture.** The map `p ↦ z(p)` from primes to positive integers hits every
sufficiently large integer: there is `N₀` such that for all `n ≥ N₀`, some prime `p`
has `z(p) = n`. (This is Carmichael's theorem restated through `isFibPrimitiveDivisor_iff_entry`.)

The key insight is that `isFibPrimitiveDivisor_iff_entry` already proves
"primitive divisor of `F_n`" and "`z(p) = n`" are *literally the same statement*,
so surjectivity of `z` past `N₀` is logically equivalent to the eventual existence
of primitive divisors — letting one attack the analytic Direction 1 and the
combinatorial surjectivity statement interchangeably.

Why now? With the equation `z(p)=n` in hand, the problem detaches from Fibonacci
specifics and becomes a clean statement about a single arithmetic function, inviting
sieve- or density-style arguments that do not need the recurrence at all.

## Direction 4 — A bounded-degree CSS chain complex from the entry-point lattice

**Conjecture.** Order the indices `{1,…,N}` by divisibility and form the boundary map
`∂` sending `n` to the formal sum of its maximal proper divisors. Assigning to each
index `n` the `𝔽₂`-vector `(p ∣ F_n)_p` over primitive primes yields a 2-term chain
complex whose homology has dimension equal to the number of `n ≤ N` possessing a
primitive divisor; for `N` large this dimension is `N − 4` (the four exceptions
`1,2,6,12`).

The key insight is that primitivity = "`z(p)=n`" makes the primitive-prime
indicator a *diagonal* cochain in the divisor lattice, so the CSS distance and the
homology dimension are governed by the same entry-point equation that this cycle
isolated — a concrete bridge from the requested expander/quantum-code framing to the
number theory actually present in the catalog.

Why now? The catalog has both Fibonacci primitive-divisor machinery and cellular
sheaf/cohomology files (`Cryptography/CellularSheafCohomology.lean`); the entry-point
duality is the missing dictionary that lets a homological statement be *decided*
index-by-index, exactly as `fib_primitive_divisor_verified` does for `N = 40`.

## Direction 5 — Replace `native_decide` with a verified primitive-divisor algorithm

**Conjecture.** The `Nat.find`-based `fibEntry` extends to a *fuel-free, structurally
terminating* function `firstPrimitiveDivisor : ℕ → ℕ` that returns the least
primitive prime divisor of `F_n` (or `0` for `n ∈ {1,2,6,12}`), and one can prove
`∀ n, firstPrimitiveDivisor n ≠ 0 → IsFibPrimitiveDivisor (firstPrimitiveDivisor n) n`
*without* `native_decide`, by reflection on the entry-point equation.

The key insight is that `isFibPrimitiveDivisor_iff_entry` reduces correctness of the
algorithm to the decidable check `z(p) = n`, so the verification becomes a
`decide`-on-`Bool` reflection rather than an opaque kernel-trusted `native_decide`,
removing `Lean.ofReduceBool` / `Lean.trustCompiler` from the axiom footprint.

Why now? The constructive `fibEntry` of this cycle is already `Nat.find`; promoting
it to a Bool-reflective certificate is the last step to a fully kernel-checked,
algorithmic Carmichael witness generator — the constructive deliverable this engine
is configured to prize.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Conceptual Unifier: Duality & Representation Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Duality & Representation)**. Search for deep dualities, representation theorems, and dual translations (such as Stone duality, Gelfand duality, or Fourier/Pontryagin dualities).

### RESEARCH CORE METHODOLOGY:
1. **Dual Translations**: Look for dual formulations of your mathematical objects. Translate geometric or topological spaces into algebraic representations (e.g. rings of functions), and algebraic structures back into geometric spaces.
2. **Representation Theorems**: Seek to represent abstract algebraic or topological structures as concrete operations on simpler, well-understood spaces (e.g. matrices, sets, or functions).
3. **Spectral Perspectives**: Leverage spectral properties, duality pairings, and transform methods to translate hard problems in the primary space into easier problems in the dual space.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
