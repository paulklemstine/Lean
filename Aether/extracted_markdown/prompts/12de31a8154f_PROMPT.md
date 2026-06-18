
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

**Title**: This cycle was about *closing proofs* in the Fibonacci primitive-divisor program
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Closing Carmichael: from the certified band to the asymptotic tail

## Synthesis

This cycle was about *closing proofs* in the Fibonacci primitive-divisor program.
On arrival the Carmichael subsystem was, in fact, not even building: the module
`Shared.CarmichaelProof` and its dependents imported a `Shared.CarmichaelHelper`
file that did not exist, `Speculative.CarmichaelPrimitiveDivisor` imported the
composite module under the wrong path, and the package source root was
misconfigured. We repaired all three, then supplied the genuinely missing
mathematics: the **prime-index case** of Carmichael's theorem.

The prime case turns out to be elementary once phrased through the
rank-of-apparition: every prime factor of `F p` (`p` prime) has entry point a
divisor of `p`, hence `1` or `p`; the value `1` is impossible because `F 1 = 1`.
We proved this in `Shared/CarmichaelHelper.lean` (`fib_primitive_divisor_prime`)
and then *synthesized* it, in `Speculative/CarmichaelSynthesis.lean`, with the
two other strands already present in the catalog — the `native_decide`
composite certificate of `Speculative.AutoResearch.CarmichaelComposite` and the
entry-point theory of the LTE file
`Algebra.…Fibonacci_Primitive_Divisors`. The synthesis yields a `sorry`-free
Carmichael theorem on the **certified band** `13 ≤ n ≤ 10000`, a strengthening
that *all* prime factors of `F p` are primitive for prime `p`, the entry-point
bridge `fibEntryPoint q = p`, and an injectivity corollary giving infinitely
many primes as Fibonacci primitive divisors.

## Results summary

Fully proved this cycle (`sorry = 0`, only `propext`/`Classical.choice`/`Quot.sound`,
plus `Lean.ofReduceBool` for the `native_decide` band):

* `CarmichaelHelper.fib_primitive_divisor_prime` — Carmichael, prime index `≥ 13`.
* `CarmichaelSynthesis.fib_all_prime_factors_primitive` — for prime `p ≥ 3`,
  *every* prime factor of `F p` is primitive.
* `CarmichaelSynthesis.fib_carmichael_certified_band` — Carmichael on `13 ≤ n ≤ 10000`,
  glued from the prime branch and the computational composite certificate without
  touching the open tail.
* `CarmichaelSynthesis.fib_prime_entryPoint_eq` — entry point of a prime factor of
  `F p` equals `p`.
* `CarmichaelSynthesis.fib_primitive_primes_injective_on_primes` — distinct prime
  indices give distinct least primitive primes ⇒ infinitude.

Still open (one `sorry`, deliberately documented): the **asymptotic composite
tail** `fib_carmichael_composite` for composite `n > 10000` in
`Shared/CarmichaelProof.lean`.

## Direction 1 — Close the composite tail via the cyclotomic/primitive part `Φ_n`

The remaining `sorry` is the infinite composite tail: for composite `n > 10000`,
`F n` has a primitive prime divisor. The right object is the *primitive part*
`Φ_n := ∏_{d ∣ n} F_d ^ μ(n/d)`, the Fibonacci analogue of the cyclotomic value.
**The key insight is** that, by Lifting-the-Exponent (already formalized as
`fib_lte`), every prime dividing `Φ_n` is primitive *except possibly the largest
prime factor `P` of `n`, which can occur only to the first power*; hence a single
size comparison `Φ_n > P` (and `Φ_n > 1`) produces a primitive divisor. Concretely:
prove `Φ_n ∣ F_n`, prove the "at most one exceptional prime, valuation ≤ 1"
lemma from `fib_lte` + `entry_point_dvd_sq_sub_one`, and bound
`Φ_n ≥ φ^{φ(n)} / C > n ≥ P` using the existing `fib_exponential_lower_bound`.
**Why now?** The two hardest ingredients already exist and are `sorry`-free in
this very project — the Fibonacci LTE lemma and the matrix-diagonalization proof
that `z(p) ∣ p² − 1`. Only the bookkeeping product `Φ_n` and one growth estimate
are missing, so the tail is now a *finite* assembly task rather than new theory.

## Direction 2 — Replace `native_decide` on `[13,10000]` by a uniform proof

The certified band currently rests on a `native_decide` over the coprime-part
algorithm. **The key insight is** that the same `Φ_n` machinery from Direction 1,
once it covers `n > 10000`, almost certainly covers the *entire* range `n ≥ 13`
with at most a handful of genuinely exceptional small `n` ({1,2,6,12}), removing
the artificial `10000` cutoff and the trust placed in `Lean.ofReduceBool`.
**Why now?** With `fib_carmichael_certified_band` already isolating the band as a
standalone lemma, swapping its proof is a drop-in replacement that cannot regress
the public theorem; the cutoff `10000` is exposed as a pure proof artifact, not
mathematics, making it a clean falsifiable target (does the `Φ_n` bound already
bite at `n = 13`?).

## Direction 3 — Quantitative primitive divisors: a lower bound on `ω(Φ_n)`

Beyond mere existence, Carmichael-type results predict *how many* primitive primes
appear. **The key insight is** that `Φ_n / gcd(Φ_n, P)` is a product of distinct
primitive primes, so `log Φ_n` divided by `log` of the largest Fibonacci prime
factor gives an explicit lower bound on the number of primitive prime divisors of
`F_n`, computable from `fib_exponential_lower_bound`. A falsifiable form: for all
`n ≥ 30`, `F_n` has at least `2` distinct primitive prime divisors — testable by
`#eval` and then provable from the same size estimate. **Why now?** The injectivity
theorem `fib_primitive_primes_injective_on_primes` already shows primitivity is the
correct invariant for *counting*; upgrading from "≥ 1" to "≥ k" reuses exactly the
entry-point bookkeeping just built.

## Direction 4 — Transport the entry-point method to Lucas and general Lehmer sequences

The whole argument used only: a strong divisibility law (`gcd(U_m,U_n)=U_{gcd}`),
an LTE lemma, and exponential growth. **The key insight is** that these three
hypotheses can be abstracted into a typeclass `StrongDivisibilitySequence` so that
the prime-index Carmichael theorem, the entry-point bridge, and the injectivity
corollary become *one* generic proof instantiated by Fibonacci, Lucas `L_n`, and
Mersenne `2^n − 1`. **Why now?** Our prime-case proof already factors through only
`Nat.fib_gcd` and `Nat.fib_one`; nothing Fibonacci-specific survives, so the
generalization is a refactor that immediately triples the catalog's theorem count
(Fibonacci ∪ Lucas ∪ Mersenne) at near-zero marginal proof cost — and it predicts
the Bang–Zsygmondy exceptional sets, a sharp falsifiable claim.

**Concept description**: # Future Directions — Closing Carmichael: from the certified band to the asymptotic tail

## Synthesis

This cycle was about *closing proofs* in the Fibonacci primitive-divisor program.
On arrival the Carmichael subsystem was, in fact, not even building: the module
`Shared.CarmichaelProof` and its dependents imported a `Shared.CarmichaelHelper`
file that did not exist, `Speculative.CarmichaelPrimitiveDivisor` imported the
composite module under the wrong path, and the package source root was
misconfigured. We repaired all three, then supplied the genuinely missing
mathematics: the **prime-index case** of Carmichael's theorem.

The prime case turns out to be elementary once phrased through the
rank-of-apparition: every prime factor of `F p` (`p` prime) has entry point a
divisor of `p`, hence `1` or `p`; the value `1` is impossible because `F 1 = 1`.
We proved this in `Shared/CarmichaelHelper.lean` (`fib_primitive_divisor_prime`)
and then *synthesized* it, in `Speculative/CarmichaelSynthesis.lean`, with the
two other strands already present in the catalog — the `native_decide`
composite certificate of `Speculative.AutoResearch.CarmichaelComposite` and the
entry-point theory of the LTE file
`Algebra.…Fibonacci_Primitive_Divisors`. The synthesis yields a `sorry`-free
Carmichael theorem on the **certified band** `13 ≤ n ≤ 10000`, a strengthening
that *all* prime factors of `F p` are primitive for prime `p`, the entry-point
bridge `fibEntryPoint q = p`, and an injectivity corollary giving infinitely
many primes as Fibonacci primitive divisors.

## Results summary

Fully proved this cycle (`sorry = 0`, only `propext`/`Classical.choice`/`Quot.sound`,
plus `Lean.ofReduceBool` for the `native_decide` band):

* `CarmichaelHelper.fib_primitive_divisor_prime` — Carmichael, prime index `≥ 13`.
* `CarmichaelSynthesis.fib_all_prime_factors_primitive` — for prime `p ≥ 3`,
  *every* prime factor of `F p` is primitive.
* `CarmichaelSynthesis.fib_carmichael_certified_band` — Carmichael on `13 ≤ n ≤ 10000`,
  glued from the prime branch and the computational composite certificate without
  touching the open tail.
* `CarmichaelSynthesis.fib_prime_entryPoint_eq` — entry point of a prime factor of
  `F p` equals `p`.
* `CarmichaelSynthesis.fib_primitive_primes_injective_on_primes` — distinct prime
  indices give distinct least primitive primes ⇒ infinitude.

Still open (one `sorry`, deliberately documented): the **asymptotic composite
tail** `fib_carmichael_composite` for composite `n > 10000` in
`Shared/CarmichaelProof.lean`.

## Direction 1 — Close the composite tail via the cyclotomic/primitive part `Φ_n`

The remaining `sorry` is the infinite composite tail: for composite `n > 10000`,
`F n` has a primitive prime divisor. The right object is the *primitive part*
`Φ_n := ∏_{d ∣ n} F_d ^ μ(n/d)`, the Fibonacci analogue of the cyclotomic value.
**The key insight is** that, by Lifting-the-Exponent (already formalized as
`fib_lte`), every prime dividing `Φ_n` is primitive *except possibly the largest
prime factor `P` of `n`, which can occur only to the first power*; hence a single
size comparison `Φ_n > P` (and `Φ_n > 1`) produces a primitive divisor. Concretely:
prove `Φ_n ∣ F_n`, prove the "at most one exceptional prime, valuation ≤ 1"
lemma from `fib_lte` + `entry_point_dvd_sq_sub_one`, and bound
`Φ_n ≥ φ^{φ(n)} / C > n ≥ P` using the existing `fib_exponential_lower_bound`.
**Why now?** The two hardest ingredients already exist and are `sorry`-free in
this very project — the Fibonacci LTE lemma and the matrix-diagonalization proof
that `z(p) ∣ p² − 1`. Only the bookkeeping product `Φ_n` and one growth estimate
are missing, so the tail is now a *finite* assembly task rather than new theory.

## Direction 2 — Replace `native_decide` on `[13,10000]` by a uniform proof

The certified band currently rests on a `native_decide` over the coprime-part
algorithm. **The key insight is** that the same `Φ_n` machinery from Direction 1,
once it covers `n > 10000`, almost certainly covers the *entire* range `n ≥ 13`
with at most a handful of genuinely exceptional small `n` ({1,2,6,12}), removing
the artificial `10000` cutoff and the trust placed in `Lean.ofReduceBool`.
**Why now?** With `fib_carmichael_certified_band` already isolating the band as a
standalone lemma, swapping its proof is a drop-in replacement that cannot regress
the public theorem; the cutoff `10000` is exposed as a pure proof artifact, not
mathematics, making it a clean falsifiable target (does the `Φ_n` bound already
bite at `n = 13`?).

## Direction 3 — Quantitative primitive divisors: a lower bound on `ω(Φ_n)`

Beyond mere existence, Carmichael-type results predict *how many* primitive primes
appear. **The key insight is** that `Φ_n / gcd(Φ_n, P)` is a product of distinct
primitive primes, so `log Φ_n` divided by `log` of the largest Fibonacci prime
factor gives an explicit lower bound on the number of primitive prime divisors of
`F_n`, computable from `fib_exponential_lower_bound`. A falsifiable form: for all
`n ≥ 30`, `F_n` has at least `2` distinct primitive prime divisors — testable by
`#eval` and then provable from the same size estimate. **Why now?** The injectivity
theorem `fib_primitive_primes_injective_on_primes` already shows primitivity is the
correct invariant for *counting*; upgrading from "≥ 1" to "≥ k" reuses exactly the
entry-point bookkeeping just built.

## Direction 4 — Transport the entry-point method to Lucas and general Lehmer sequences

The whole argument used only: a strong divisibility law (`gcd(U_m,U_n)=U_{gcd}`),
an LTE lemma, and exponential growth. **The key insight is** that these three
hypotheses can be abstracted into a typeclass `StrongDivisibilitySequence` so that
the prime-index Carmichael theorem, the entry-point bridge, and the injectivity
corollary become *one* generic proof instantiated by Fibonacci, Lucas `L_n`, and
Mersenne `2^n − 1`. **Why now?** Our prime-case proof already factors through only
`Nat.fib_gcd` and `Nat.fib_one`; nothing Fibonacci-specific survives, so the
generalization is a refactor that immediately triples the catalog's theorem count
(Fibonacci ∪ Lucas ∪ Mersenne) at near-zero marginal proof cost — and it predicts
the Bang–Zsygmondy exceptional sets, a sharp falsifiable claim.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- Conceptual Unifier: Homotopy & Path Spaces Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Homotopy & Path Spaces)**. Explore topological paths, homotopical structures, and higher categorical localization (such as infinity-categories, model categories, and path spaces).

### RESEARCH CORE METHODOLOGY:
1. **Homotopy & Deformation**: Model mathematical structures and mappings up to continuous deformation or equivalence. Study path spaces, fundamental groupoids, and higher-dimensional homotopical invariants.
2. **Localization & Universality**: Define localizations that invert specific classes of morphisms, exposing the underlying universal homotopy properties of your mathematical structures.
3. **Higher Categorical Invariance**: Frame results through the lens of infinity-categories or model categories, ensuring definitions are invariant under homotopical equivalence.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
