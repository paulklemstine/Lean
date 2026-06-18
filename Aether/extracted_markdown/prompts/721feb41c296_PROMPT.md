
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

**Title**: This cycle attacked the priority target `CarmichaelComposite` and the broken
**Domain**: Cryptography
**Mathematical framing**: # Future Directions — Proof-Complexity Holography meets Carmichael Primitivity

## Synthesis

This cycle attacked the priority target `CarmichaelComposite` and the broken
`Shared.CarmichaelHelper` dependency through the lens of the catalog's
**proof-complexity holography** program (`Logic.ProofComplexity.Holography`), whose
organizing principle is *local-to-global propagation*: a local one-step bound propagates
holographically to a global metric statement (`translate_deriv`,
`minDerivLen_translate_le`).

The Fibonacci **entry point** (rank of apparition) — the least `k > 0` with `p ∣ F_k` — is
the number-theoretic twin of the proof metric `minDerivLen`: both are minimal-index
functionals. We showed Carmichael's primitive-divisor theorem obeys *the same* local→global
pattern: the local hypothesis "`n` is prime" propagates to a global primitivity statement
about **every** prime factor of `F_n` at once, with the strong-divisibility identity
`F_{gcd(m,n)} = gcd(F_m, F_n)` (`Nat.fib_gcd`) as the entire engine. This isolates all the
analytic difficulty in the *composite* case, exactly where `gcd(k,n)` can be a nontrivial
proper divisor (the "slack" that the prime/chain case lacks).

## Results summary

New file `Shared/CarmichaelHelper.lean` (previously missing — its absence broke
`CarmichaelProof`, `CarmichaelComposite`, `FibPrimitive`):
* `CarmichaelHelper.fib_dvd_gcd` — the gcd–Fibonacci bridge.
* `CarmichaelHelper.fib_prime_all_divisors_primitive` — for prime `n`, **every** prime
  divisor of `F_n` is primitive (unconditional, no growth bound).
* `CarmichaelHelper.fib_primitive_divisor_prime` (+ root alias) — the prime branch consumed
  by the downstream Carmichael files.

New file `Logic/ProofComplexity/FibonacciPrimitiveHolography.lean`:
* `prime_index_all_prime_factors_primitive` — holographic propagation over
  `(F_n).primeFactors`.
* `fib_prime_has_primitive` — existence at the **sharp** threshold `n ≥ 3` (sharpening the
  consumers' `n ≥ 13`).
* `prime_index_coprime_earlier_product` — "global newness": a prime factor of `F_n` is
  coprime to `∏_{1 ≤ k < n} F_k`.
* `fib_six_no_primitive`, `fib_twelve_no_primitive` — the two genuine exceptions, pinning the
  boundary where Carmichael's theorem switches on.

All new theorems are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`. The single remaining `sorry` in the project,
`Shared.CarmichaelProof.fib_carmichael_composite` (composite `n > 10000`), is the analytic
heart of Carmichael's theorem and is the subject of Direction 1 below.

## Research directions

### 1. Close the composite tail via the cyclotomic primitive part
The lone open `sorry` is: for composite `n > 10000`, `F_n` has a primitive prime divisor.
The classical route is the **primitive part** `Φ_n = ∏_{d ∣ n} F_d^{μ(n/d)}`, which collects
exactly the primes of entry point `n`. The key insight is that `Φ_n` is the value at the
golden ratio of the `n`-th *Lucas cyclotomic factor*, and a non-primitive `Φ_n` is forced to
equal a single small "intrinsic" prime dividing `n`; a lower bound `Φ_n > n` (from
`F_n ≥ φ^{n-2}` and `∑_{d<n, d∣n} F_d` being geometrically dominated) then guarantees a
primitive factor. **Why now?** The entry-point API (`fib_dvd_gcd`,
`fib_prime_all_divisors_primitive`, `prime_index_coprime_earlier_product`) is exactly the
divisibility scaffolding such a proof needs; only the Möbius/growth estimate is missing, and
Mathlib already has `Nat.fib` growth lemmas and `ArithmeticFunction.moebius`. Falsifiable:
the conjectured bound `Φ_n > n` for composite `n ≥ 13` is a finite-plus-asymptotic claim that
can be stress-tested by `#eval` before formalization.

### 2. Lifting-the-Exponent (LTE) for Fibonacci `v_p(F_{mk}) = v_p(F_m) + v_p(k)`
For an odd prime `p` with entry point `m = z(p)`, the `p`-adic valuation satisfies
`v_p(F_{mk}) = v_p(F_m) + v_p(k)`. The key insight is that this is the ordinary LTE
(`padicValNat.pow_sub_pow`, already in Mathlib) transported along the eigenvalue
factorization `F_n = (φ^n - ψ^n)/√5` in `ℤ_p[√5]`, so that `F_{mp}/F_m ≡ p·r^{p-1} (mod p²)`.
**Why now?** This single identity reduces the prime-power case of Direction 1 to bookkeeping,
and the eigenvalue companion-matrix viewpoint connects directly to the catalog's
`Algebra.CharpolyRecognition`. Falsifiable: the congruence `F_{mp}/F_m ≡ p·r^{p-1} (mod p²)`
is `decide`-checkable for many concrete `(m,p)`.

### 3. Entry point as a genuine quasi-metric ("rank holography")
Define `rank p = entryPoint p` and study the map `p ↦ rank p` as a minimal-index functional
parallel to `minDerivLen`. The key insight is that `rank` satisfies a divisibility "triangle
law" `rank p ∣ gcd(k, n)` whenever `p ∣ F_k` and `p ∣ F_n`, the multiplicative analogue of
the additive `derivOfLen_comp`. **Why now?** `Holography.minDerivLen_translate_le` gives the
exact template (a Lipschitz/propagation inequality); proving the rank version would make
"proof-complexity holography" and "primitive-divisor theory" two instances of one abstract
minimal-functional theorem. Falsifiable: claim `rank` is *exactly* multiplicative on coprime
arguments — almost surely **false** (carry/coincidence primes), and locating the first
counterexample is itself a result.

### 4. Zsygmondy for general Lucas sequences `U_n(P,Q)`
Generalize from Fibonacci (`P=1, Q=-1`) to arbitrary nondegenerate Lucas sequences
`U_n(P,Q)`. The key insight is that the prime-index argument of
`fib_prime_all_divisors_primitive` uses *only* the strong-divisibility law
`gcd(U_m, U_n) = U_{gcd(m,n)}`, which holds for every Lucas sequence with `gcd(P,Q)=1`; hence
the entire prime case generalizes verbatim. **Why now?** Mathlib lacks a general Lucas-sequence
`fib_gcd`, but it is a clean induction; once present, the prime case of Zsygmondy's theorem
follows for free, a strict generalization of this cycle's headline. Falsifiable: the
strong-divisibility law fails when `gcd(P,Q) ≠ 1` — pinpointing exactly which Lucas sequences
retain primitivity is a sharp, testable boundary.

### 5. Effective exception census across `(P,Q)`
Conjecture: across nondegenerate Lucas sequences, the indices `n` with **no** primitive divisor
form a finite, explicitly computable set depending only on `(P,Q)` (for Fibonacci: exactly
`{1,2,6,12}`, as `fib_six_no_primitive` and `fib_twelve_no_primitive` confirm two of them).
The key insight is that exceptions occur precisely when the primitive part `Φ_n` collapses to
a divisor of `n`, a condition checkable by a verified `native_decide` sweep bounded by the
growth estimate of Direction 1. **Why now?** The `interval_cases`-plus-`decide` exception
proofs here scale directly into a certified census once the growth bound caps the search range.
Falsifiable: the claim "Fibonacci has *no* exception beyond `n = 12`" is exactly the composite
tail of Direction 1, and any `n` violating it would refute Carmichael outright.

**Concept description**: # Future Directions — Proof-Complexity Holography meets Carmichael Primitivity

## Synthesis

This cycle attacked the priority target `CarmichaelComposite` and the broken
`Shared.CarmichaelHelper` dependency through the lens of the catalog's
**proof-complexity holography** program (`Logic.ProofComplexity.Holography`), whose
organizing principle is *local-to-global propagation*: a local one-step bound propagates
holographically to a global metric statement (`translate_deriv`,
`minDerivLen_translate_le`).

The Fibonacci **entry point** (rank of apparition) — the least `k > 0` with `p ∣ F_k` — is
the number-theoretic twin of the proof metric `minDerivLen`: both are minimal-index
functionals. We showed Carmichael's primitive-divisor theorem obeys *the same* local→global
pattern: the local hypothesis "`n` is prime" propagates to a global primitivity statement
about **every** prime factor of `F_n` at once, with the strong-divisibility identity
`F_{gcd(m,n)} = gcd(F_m, F_n)` (`Nat.fib_gcd`) as the entire engine. This isolates all the
analytic difficulty in the *composite* case, exactly where `gcd(k,n)` can be a nontrivial
proper divisor (the "slack" that the prime/chain case lacks).

## Results summary

New file `Shared/CarmichaelHelper.lean` (previously missing — its absence broke
`CarmichaelProof`, `CarmichaelComposite`, `FibPrimitive`):
* `CarmichaelHelper.fib_dvd_gcd` — the gcd–Fibonacci bridge.
* `CarmichaelHelper.fib_prime_all_divisors_primitive` — for prime `n`, **every** prime
  divisor of `F_n` is primitive (unconditional, no growth bound).
* `CarmichaelHelper.fib_primitive_divisor_prime` (+ root alias) — the prime branch consumed
  by the downstream Carmichael files.

New file `Logic/ProofComplexity/FibonacciPrimitiveHolography.lean`:
* `prime_index_all_prime_factors_primitive` — holographic propagation over
  `(F_n).primeFactors`.
* `fib_prime_has_primitive` — existence at the **sharp** threshold `n ≥ 3` (sharpening the
  consumers' `n ≥ 13`).
* `prime_index_coprime_earlier_product` — "global newness": a prime factor of `F_n` is
  coprime to `∏_{1 ≤ k < n} F_k`.
* `fib_six_no_primitive`, `fib_twelve_no_primitive` — the two genuine exceptions, pinning the
  boundary where Carmichael's theorem switches on.

All new theorems are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`. The single remaining `sorry` in the project,
`Shared.CarmichaelProof.fib_carmichael_composite` (composite `n > 10000`), is the analytic
heart of Carmichael's theorem and is the subject of Direction 1 below.

## Research directions

### 1. Close the composite tail via the cyclotomic primitive part
The lone open `sorry` is: for composite `n > 10000`, `F_n` has a primitive prime divisor.
The classical route is the **primitive part** `Φ_n = ∏_{d ∣ n} F_d^{μ(n/d)}`, which collects
exactly the primes of entry point `n`. The key insight is that `Φ_n` is the value at the
golden ratio of the `n`-th *Lucas cyclotomic factor*, and a non-primitive `Φ_n` is forced to
equal a single small "intrinsic" prime dividing `n`; a lower bound `Φ_n > n` (from
`F_n ≥ φ^{n-2}` and `∑_{d<n, d∣n} F_d` being geometrically dominated) then guarantees a
primitive factor. **Why now?** The entry-point API (`fib_dvd_gcd`,
`fib_prime_all_divisors_primitive`, `prime_index_coprime_earlier_product`) is exactly the
divisibility scaffolding such a proof needs; only the Möbius/growth estimate is missing, and
Mathlib already has `Nat.fib` growth lemmas and `ArithmeticFunction.moebius`. Falsifiable:
the conjectured bound `Φ_n > n` for composite `n ≥ 13` is a finite-plus-asymptotic claim that
can be stress-tested by `#eval` before formalization.

### 2. Lifting-the-Exponent (LTE) for Fibonacci `v_p(F_{mk}) = v_p(F_m) + v_p(k)`
For an odd prime `p` with entry point `m = z(p)`, the `p`-adic valuation satisfies
`v_p(F_{mk}) = v_p(F_m) + v_p(k)`. The key insight is that this is the ordinary LTE
(`padicValNat.pow_sub_pow`, already in Mathlib) transported along the eigenvalue
factorization `F_n = (φ^n - ψ^n)/√5` in `ℤ_p[√5]`, so that `F_{mp}/F_m ≡ p·r^{p-1} (mod p²)`.
**Why now?** This single identity reduces the prime-power case of Direction 1 to bookkeeping,
and the eigenvalue companion-matrix viewpoint connects directly to the catalog's
`Algebra.CharpolyRecognition`. Falsifiable: the congruence `F_{mp}/F_m ≡ p·r^{p-1} (mod p²)`
is `decide`-checkable for many concrete `(m,p)`.

### 3. Entry point as a genuine quasi-metric ("rank holography")
Define `rank p = entryPoint p` and study the map `p ↦ rank p` as a minimal-index functional
parallel to `minDerivLen`. The key insight is that `rank` satisfies a divisibility "triangle
law" `rank p ∣ gcd(k, n)` whenever `p ∣ F_k` and `p ∣ F_n`, the multiplicative analogue of
the additive `derivOfLen_comp`. **Why now?** `Holography.minDerivLen_translate_le` gives the
exact template (a Lipschitz/propagation inequality); proving the rank version would make
"proof-complexity holography" and "primitive-divisor theory" two instances of one abstract
minimal-functional theorem. Falsifiable: claim `rank` is *exactly* multiplicative on coprime
arguments — almost surely **false** (carry/coincidence primes), and locating the first
counterexample is itself a result.

### 4. Zsygmondy for general Lucas sequences `U_n(P,Q)`
Generalize from Fibonacci (`P=1, Q=-1`) to arbitrary nondegenerate Lucas sequences
`U_n(P,Q)`. The key insight is that the prime-index argument of
`fib_prime_all_divisors_primitive` uses *only* the strong-divisibility law
`gcd(U_m, U_n) = U_{gcd(m,n)}`, which holds for every Lucas sequence with `gcd(P,Q)=1`; hence
the entire prime case generalizes verbatim. **Why now?** Mathlib lacks a general Lucas-sequence
`fib_gcd`, but it is a clean induction; once present, the prime case of Zsygmondy's theorem
follows for free, a strict generalization of this cycle's headline. Falsifiable: the
strong-divisibility law fails when `gcd(P,Q) ≠ 1` — pinpointing exactly which Lucas sequences
retain primitivity is a sharp, testable boundary.

### 5. Effective exception census across `(P,Q)`
Conjecture: across nondegenerate Lucas sequences, the indices `n` with **no** primitive divisor
form a finite, explicitly computable set depending only on `(P,Q)` (for Fibonacci: exactly
`{1,2,6,12}`, as `fib_six_no_primitive` and `fib_twelve_no_primitive` confirm two of them).
The key insight is that exceptions occur precisely when the primitive part `Φ_n` collapses to
a divisor of `n`, a condition checkable by a verified `native_decide` sweep bounded by the
growth estimate of Direction 1. **Why now?** The `interval_cases`-plus-`decide` exception
proofs here scale directly into a certified census once the growth bound caps the search range.
Falsifiable: the claim "Fibonacci has *no* exception beyond `n = 12`" is exactly the composite
tail of Direction 1, and any `n` violating it would refute Carmichael outright.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Cryptography
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
