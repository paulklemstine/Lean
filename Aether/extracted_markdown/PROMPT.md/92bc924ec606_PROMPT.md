
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

**Title**: This cycle repaired the broken `Shared.CarmichaelHelper` dependency — whose abse
**Domain**: Tropical
**Mathematical framing**: # Future Directions — Proof-Complexity Holography meets Carmichael Primitivity

## Synthesis

This cycle repaired the broken `Shared.CarmichaelHelper` dependency — whose absence had
disabled `Shared.CarmichaelProof`, `Speculative.AutoResearch.CarmichaelComposite`, and
`Speculative.AutoResearch.FibPrimitive` — and re-read the Carmichael primitive-divisor
problem through the catalog's **proof-complexity holography** lens
(`Logic.ProofComplexity.Holography`), whose organizing principle is *local-to-global
propagation*. The Fibonacci **entry point** (rank of apparition, the least `k > 0` with
`p ∣ F_k`) is the number-theoretic twin of the proof metric `minDerivLen`: both are minimal-
index functionals. The structural discovery is that the **prime-index** case of Carmichael's
theorem is purely holographic — it needs *no* growth or analytic input. A single engine, the
strong-divisibility law `F_{gcd(m,n)} = gcd(F_m, F_n)` (`Nat.fib_gcd`), propagates the local
hypothesis "`n` is prime" to a global statement about **every** prime factor of `F_n` at once,
and even to coprimality of those factors with the entire earlier product `∏_{1≤k<n} F_k`.

What *failed* (productively) was the temptation to state primitivity for all `n ≥ 13`: the
exception theorems `fib_six_no_primitive` and `fib_twelve_no_primitive` show the prime
hypothesis is load-bearing. Composite indices `n` admit no primitive divisor exactly when the
primitive part collapses onto a small divisor of `n`; locating these boundary cases is as
informative as the positive theorems and pins down precisely where Carmichael's theorem
switches on. This isolates all remaining analytic difficulty in the composite tail, the lone
open `sorry` in `Shared.CarmichaelProof.fib_carmichael_composite` (composite `n > 10000`).

The unifying insight tying the directions below together: "entry point" and "minimal
derivation length" are two instances of one abstract *minimal-index functional*, and the
divisibility "triangle law" for entry points is the multiplicative analogue of the additive
propagation inequality `Holography.minDerivLen_translate_le`.

## Results Summary

- `fib_dvd_gcd`: proved — the gcd–Fibonacci bridge (`p ∣ F_m, p ∣ F_n ⇒ p ∣ F_{gcd(m,n)}`),
  the single engine for the entire prime-index branch.
- `fib_prime_all_divisors_primitive`: proved — for prime index `n`, *every* prime divisor of
  `F_n` is primitive, unconditionally (no growth bound).
- `fib_primitive_divisor_prime`: proved — prime case of Carmichael for `n ≥ 13`; the symbol
  consumed by the downstream Carmichael files (dependency now restored).
- `prime_index_all_prime_factors_primitive`: proved — holographic propagation over the whole
  set `(F_n).primeFactors`.
- `fib_prime_has_primitive`: proved — existence at the **sharp** threshold `n ≥ 3`, sharpening
  the consumers' `n ≥ 13`.
- `prime_index_coprime_earlier_product`: proved — "global newness": a prime factor of `F_n`
  (prime `n`) is coprime to `∏_{1≤k<n} F_k`.
- `fib_six_no_primitive`: disproved (counterexample) — `F_6 = 8` has no primitive prime
  divisor (`2 ∣ F_3`), refuting any "primitive for all `n`" claim.
- `fib_twelve_no_primitive`: disproved (counterexample) — `F_12 = 144` has no primitive prime
  divisor (`2 ∣ F_3`, `3 ∣ F_4`).

## Research Directions

### Direction 1: Close the composite tail via the cyclotomic primitive part
**Hypothesis**: For composite `n ≥ 13`, the Fibonacci primitive part
`Φ_n = ∏_{d ∣ n} F_d^{μ(n/d)}` satisfies `Φ_n > n`, and any non-primitive `Φ_n` is forced to
equal a single small prime dividing `n`; hence `F_n` always has a primitive prime divisor.
**Test**: `#eval` the bound `Φ_n > n` over composite `13 ≤ n ≤ 10^4` first; then formalize the
Möbius/growth estimate from `F_n ≥ φ^{n-2}` and geometric domination of `∑_{d<n, d∣n} F_d`.
**Why now**: The entry-point API delivered this cycle (`fib_dvd_gcd`,
`fib_prime_all_divisors_primitive`, `prime_index_coprime_earlier_product`) is exactly the
divisibility scaffolding such a proof needs; only the growth estimate is missing, and Mathlib
has `Nat.fib` growth lemmas plus `ArithmeticFunction.moebius`. The key insight is that the lone
remaining `sorry` is now *analytically isolated* — the entire combinatorial/divisibility half
is done.
**If true**: Carmichael's theorem becomes fully `sorry`-free in this project.
**If false**: A counterexample `n` with `Φ_n ≤ n` would refute Carmichael outright — a major
event — so even a near-miss sharpens the true growth constant.

### Direction 2: Lifting-the-Exponent for Fibonacci, `v_p(F_{mk}) = v_p(F_m) + v_p(k)`
**Hypothesis**: For odd prime `p` with entry point `m = z(p)`, the `p`-adic valuation obeys
`v_p(F_{mk}) = v_p(F_m) + v_p(k)`; equivalently `F_{mp}/F_m ≡ p·r^{p-1} (mod p²)`.
**Test**: `decide`-check the congruence `F_{mp}/F_m ≡ p·r^{p-1} (mod p²)` for many concrete
`(m,p)`; then transport the standard LTE (`padicValNat.pow_sub_pow`) along the eigenvalue
factorization `F_n = (φ^n − ψ^n)/√5` in `ℤ_p[√5]`.
**Why now**: The key insight is that the prime-power case of Direction 1 reduces entirely to
this single valuation identity, and the companion-matrix eigenvalue viewpoint links directly
to the catalog's `Algebra.CharpolyRecognition`.
**If true**: The prime-power bookkeeping for Direction 1 collapses to one lemma.
**If false**: The failure pinpoints the primes (e.g. `p = 5`, the ramified case) where the
naive LTE breaks, which is itself a publishable boundary.

### Direction 3: Entry point as a quasi-metric ("rank holography")
**Hypothesis**: Define `rank p = z(p)`. Then `rank` satisfies a divisibility triangle law
`z(p) ∣ gcd(k, n)` whenever `p ∣ F_k` and `p ∣ F_n` — the multiplicative analogue of the
additive `derivOfLen_comp` — but `rank` is **not** exactly multiplicative on coprime arguments.
**Test**: Prove the triangle law from `fib_dvd_gcd` (immediate); then `#eval`-search for the
first coprime pair where `z(p·q) ≠ lcm(z(p), z(q))` to disprove exact multiplicativity.
**Why now**: `Holography.minDerivLen_translate_le` supplies the exact propagation/Lipschitz
template. The key insight is that proving the rank version would exhibit "proof-complexity
holography" and "primitive-divisor theory" as two instances of one abstract minimal-functional
theorem.
**If true (triangle law)**: A reusable abstract "minimal-index functional" interface usable by
both the Logic and Number-Theory catalog branches.
**If false (multiplicativity)**: The first counterexample is a concrete, citable datum about
coincidence primes.

### Direction 4: Zsygmondy for general Lucas sequences `U_n(P,Q)`
**Hypothesis**: For every nondegenerate Lucas sequence with `gcd(P,Q) = 1`, the strong-
divisibility law `gcd(U_m, U_n) = U_{gcd(m,n)}` holds, and therefore the prime-index argument
of `fib_prime_all_divisors_primitive` generalizes verbatim: for prime `n`, every prime divisor
of `U_n` is primitive.
**Test**: Prove the general `U`-gcd law by induction (Mathlib lacks it for general `U`); then
re-derive the prime case of Zsygmondy mechanically.
**Why now**: The key insight is that this cycle's prime-index proof uses *only* the gcd law and
nothing Fibonacci-specific, so the generalization is a clean import once the law is in place.
**If true**: A strict generalization of this cycle's headline (the prime case of Zsygmondy's
theorem).
**If false**: The exact `(P,Q)` where strong divisibility fails (necessarily `gcd(P,Q) ≠ 1`)
delimits which Lucas sequences retain primitivity — a sharp testable boundary.

### Direction 5: Effective exception census across `(P,Q)`
**Hypothesis**: Across nondegenerate Lucas sequences, the indices `n` with **no** primitive
divisor form a finite, explicitly computable set depending only on `(P,Q)`; for Fibonacci it is
exactly `{1, 2, 6, 12}` (this cycle proved the `6` and `12` exceptions).
**Test**: A verified `native_decide` sweep, range-bounded by the growth estimate of Direction
1, enumerating the exceptional `n` for each small `(P,Q)`.
**Why now**: The key insight is that exceptions occur precisely when the primitive part `Φ_n`
collapses to a divisor of `n`, a `decide`-checkable condition; the `interval_cases`-plus-`decide`
exception proofs here scale directly once a growth bound caps the search range.
**If true**: A certified, machine-checked exception census — the effective form of Carmichael's
classification.
**If false**: "Fibonacci has no exception beyond `n = 12`" failing is exactly the composite
tail of Direction 1; any violating `n` refutes Carmichael, so a falsification here is a
headline result.

**Concept description**: # Future Directions — Proof-Complexity Holography meets Carmichael Primitivity

## Synthesis

This cycle repaired the broken `Shared.CarmichaelHelper` dependency — whose absence had
disabled `Shared.CarmichaelProof`, `Speculative.AutoResearch.CarmichaelComposite`, and
`Speculative.AutoResearch.FibPrimitive` — and re-read the Carmichael primitive-divisor
problem through the catalog's **proof-complexity holography** lens
(`Logic.ProofComplexity.Holography`), whose organizing principle is *local-to-global
propagation*. The Fibonacci **entry point** (rank of apparition, the least `k > 0` with
`p ∣ F_k`) is the number-theoretic twin of the proof metric `minDerivLen`: both are minimal-
index functionals. The structural discovery is that the **prime-index** case of Carmichael's
theorem is purely holographic — it needs *no* growth or analytic input. A single engine, the
strong-divisibility law `F_{gcd(m,n)} = gcd(F_m, F_n)` (`Nat.fib_gcd`), propagates the local
hypothesis "`n` is prime" to a global statement about **every** prime factor of `F_n` at once,
and even to coprimality of those factors with the entire earlier product `∏_{1≤k<n} F_k`.

What *failed* (productively) was the temptation to state primitivity for all `n ≥ 13`: the
exception theorems `fib_six_no_primitive` and `fib_twelve_no_primitive` show the prime
hypothesis is load-bearing. Composite indices `n` admit no primitive divisor exactly when the
primitive part collapses onto a small divisor of `n`; locating these boundary cases is as
informative as the positive theorems and pins down precisely where Carmichael's theorem
switches on. This isolates all remaining analytic difficulty in the composite tail, the lone
open `sorry` in `Shared.CarmichaelProof.fib_carmichael_composite` (composite `n > 10000`).

The unifying insight tying the directions below together: "entry point" and "minimal
derivation length" are two instances of one abstract *minimal-index functional*, and the
divisibility "triangle law" for entry points is the multiplicative analogue of the additive
propagation inequality `Holography.minDerivLen_translate_le`.

## Results Summary

- `fib_dvd_gcd`: proved — the gcd–Fibonacci bridge (`p ∣ F_m, p ∣ F_n ⇒ p ∣ F_{gcd(m,n)}`),
  the single engine for the entire prime-index branch.
- `fib_prime_all_divisors_primitive`: proved — for prime index `n`, *every* prime divisor of
  `F_n` is primitive, unconditionally (no growth bound).
- `fib_primitive_divisor_prime`: proved — prime case of Carmichael for `n ≥ 13`; the symbol
  consumed by the downstream Carmichael files (dependency now restored).
- `prime_index_all_prime_factors_primitive`: proved — holographic propagation over the whole
  set `(F_n).primeFactors`.
- `fib_prime_has_primitive`: proved — existence at the **sharp** threshold `n ≥ 3`, sharpening
  the consumers' `n ≥ 13`.
- `prime_index_coprime_earlier_product`: proved — "global newness": a prime factor of `F_n`
  (prime `n`) is coprime to `∏_{1≤k<n} F_k`.
- `fib_six_no_primitive`: disproved (counterexample) — `F_6 = 8` has no primitive prime
  divisor (`2 ∣ F_3`), refuting any "primitive for all `n`" claim.
- `fib_twelve_no_primitive`: disproved (counterexample) — `F_12 = 144` has no primitive prime
  divisor (`2 ∣ F_3`, `3 ∣ F_4`).

## Research Directions

### Direction 1: Close the composite tail via the cyclotomic primitive part
**Hypothesis**: For composite `n ≥ 13`, the Fibonacci primitive part
`Φ_n = ∏_{d ∣ n} F_d^{μ(n/d)}` satisfies `Φ_n > n`, and any non-primitive `Φ_n` is forced to
equal a single small prime dividing `n`; hence `F_n` always has a primitive prime divisor.
**Test**: `#eval` the bound `Φ_n > n` over composite `13 ≤ n ≤ 10^4` first; then formalize the
Möbius/growth estimate from `F_n ≥ φ^{n-2}` and geometric domination of `∑_{d<n, d∣n} F_d`.
**Why now**: The entry-point API delivered this cycle (`fib_dvd_gcd`,
`fib_prime_all_divisors_primitive`, `prime_index_coprime_earlier_product`) is exactly the
divisibility scaffolding such a proof needs; only the growth estimate is missing, and Mathlib
has `Nat.fib` growth lemmas plus `ArithmeticFunction.moebius`. The key insight is that the lone
remaining `sorry` is now *analytically isolated* — the entire combinatorial/divisibility half
is done.
**If true**: Carmichael's theorem becomes fully `sorry`-free in this project.
**If false**: A counterexample `n` with `Φ_n ≤ n` would refute Carmichael outright — a major
event — so even a near-miss sharpens the true growth constant.

### Direction 2: Lifting-the-Exponent for Fibonacci, `v_p(F_{mk}) = v_p(F_m) + v_p(k)`
**Hypothesis**: For odd prime `p` with entry point `m = z(p)`, the `p`-adic valuation obeys
`v_p(F_{mk}) = v_p(F_m) + v_p(k)`; equivalently `F_{mp}/F_m ≡ p·r^{p-1} (mod p²)`.
**Test**: `decide`-check the congruence `F_{mp}/F_m ≡ p·r^{p-1} (mod p²)` for many concrete
`(m,p)`; then transport the standard LTE (`padicValNat.pow_sub_pow`) along the eigenvalue
factorization `F_n = (φ^n − ψ^n)/√5` in `ℤ_p[√5]`.
**Why now**: The key insight is that the prime-power case of Direction 1 reduces entirely to
this single valuation identity, and the companion-matrix eigenvalue viewpoint links directly
to the catalog's `Algebra.CharpolyRecognition`.
**If true**: The prime-power bookkeeping for Direction 1 collapses to one lemma.
**If false**: The failure pinpoints the primes (e.g. `p = 5`, the ramified case) where the
naive LTE breaks, which is itself a publishable boundary.

### Direction 3: Entry point as a quasi-metric ("rank holography")
**Hypothesis**: Define `rank p = z(p)`. Then `rank` satisfies a divisibility triangle law
`z(p) ∣ gcd(k, n)` whenever `p ∣ F_k` and `p ∣ F_n` — the multiplicative analogue of the
additive `derivOfLen_comp` — but `rank` is **not** exactly multiplicative on coprime arguments.
**Test**: Prove the triangle law from `fib_dvd_gcd` (immediate); then `#eval`-search for the
first coprime pair where `z(p·q) ≠ lcm(z(p), z(q))` to disprove exact multiplicativity.
**Why now**: `Holography.minDerivLen_translate_le` supplies the exact propagation/Lipschitz
template. The key insight is that proving the rank version would exhibit "proof-complexity
holography" and "primitive-divisor theory" as two instances of one abstract minimal-functional
theorem.
**If true (triangle law)**: A reusable abstract "minimal-index functional" interface usable by
both the Logic and Number-Theory catalog branches.
**If false (multiplicativity)**: The first counterexample is a concrete, citable datum about
coincidence primes.

### Direction 4: Zsygmondy for general Lucas sequences `U_n(P,Q)`
**Hypothesis**: For every nondegenerate Lucas sequence with `gcd(P,Q) = 1`, the strong-
divisibility law `gcd(U_m, U_n) = U_{gcd(m,n)}` holds, and therefore the prime-index argument
of `fib_prime_all_divisors_primitive` generalizes verbatim: for prime `n`, every prime divisor
of `U_n` is primitive.
**Test**: Prove the general `U`-gcd law by induction (Mathlib lacks it for general `U`); then
re-derive the prime case of Zsygmondy mechanically.
**Why now**: The key insight is that this cycle's prime-index proof uses *only* the gcd law and
nothing Fibonacci-specific, so the generalization is a clean import once the law is in place.
**If true**: A strict generalization of this cycle's headline (the prime case of Zsygmondy's
theorem).
**If false**: The exact `(P,Q)` where strong divisibility fails (necessarily `gcd(P,Q) ≠ 1`)
delimits which Lucas sequences retain primitivity — a sharp testable boundary.

### Direction 5: Effective exception census across `(P,Q)`
**Hypothesis**: Across nondegenerate Lucas sequences, the indices `n` with **no** primitive
divisor form a finite, explicitly computable set depending only on `(P,Q)`; for Fibonacci it is
exactly `{1, 2, 6, 12}` (this cycle proved the `6` and `12` exceptions).
**Test**: A verified `native_decide` sweep, range-bounded by the growth estimate of Direction
1, enumerating the exceptional `n` for each small `(P,Q)`.
**Why now**: The key insight is that exceptions occur precisely when the primitive part `Φ_n`
collapses to a divisor of `n`, a `decide`-checkable condition; the `interval_cases`-plus-`decide`
exception proofs here scale directly once a growth bound caps the search range.
**If true**: A certified, machine-checked exception census — the effective form of Carmichael's
classification.
**If false**: "Fibonacci has no exception beyond `n = 12`" failing is exactly the composite
tail of Direction 1; any violating `n` refutes Carmichael, so a falsification here is a
headline result.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Tropical
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
