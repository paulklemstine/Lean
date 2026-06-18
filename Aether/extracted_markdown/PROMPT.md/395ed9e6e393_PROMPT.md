
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

**Title**: This cycle added `Catalog/Pythagorean/FibonacciEntryFactorization.lean`, which c
**Domain**: Tropical
**Mathematical framing**: # Future Directions — Prime-power reduction of the Fibonacci rank of apparition

This cycle added `Catalog/Pythagorean/FibonacciEntryFactorization.lean`, which closes the
multiplicative theory of the Fibonacci rank of apparition `fibEntry`. The catalog already
contained the two-factor coprime law (`FibonacciEntryPointInvariant.fibEntry_mul_coprime`)
and the unrestricted join law (`FibonacciApparitionLattice.fibEntry_lcm`). The new file
proves the **full prime-power reduction**

> `fibEntry n = lcm_{p^{vₚ(n)} ∥ n} fibEntry (p^{vₚ(n)})`  (theorem `fibEntry_factorization`),

routed through a reusable multi-factor join engine `fibEntry_prod_coprime` and the CRT
divisibility shape `coprime_prod_dvd_iff`, with monotonicity
`fibEntry_dvd_of_factorization_le` and the base case `fibEntry_one`. Everything is
`sorry`-free and depends only on the standard axioms. The directions below extend this
frontier.

## 1. The Wall–Sun–Sun barrier: `fibEntry (p²) = p · fibEntry p`?

For every known prime `p`, the rank of apparition of `p²` is exactly `p · fibEntry p`; a
prime where `fibEntry (p²) = fibEntry p` instead is precisely a **Wall–Sun–Sun prime**,
none of which are known. Combined with `fibEntry_factorization`, settling the exponent
behaviour `fibEntry (p^(k+1)) = p · fibEntry (p^k)` for `k ≥ 1` would make `fibEntry`
*completely* explicit from its values on primes alone.

The key insight is that `fibEntry_factorization` already isolates the prime-power case as
the *only* remaining unknown, so the entire mystery of the rank of apparition collapses to
the single lifting-the-exponent step `fibEntry (p^{k+1}) / fibEntry (p^k) ∈ {1, p}`,
provable from `Catalog/Shared/FibonacciLTE.lean` for `k ≥ 1` except on the Wall–Sun–Sun
locus.

**Why now?** The reduction theorem proved this cycle is exactly the statement that makes
the prime-power recurrence the *sole* obstruction; before it, an exponent law would not
have determined `fibEntry` on composite moduli. With `FibonacciLTE` already in the catalog,
the `p`-adic valuation machinery needed for the lift is in place.

## 2. Pisano period vs. rank of apparition: `π(n) = lcm` over prime powers too

The Pisano period `π(n)` (the period of `F_k mod n`) satisfies the same prime-power
reduction `π(n) = lcm_{p^{vₚ(n)}} π(p^{vₚ(n)})`, and is a bounded multiple of `fibEntry n`
(the ratio `π(n)/fibEntry(n) ∈ {1,2,4}`). Formalizing `π` as `addOrderOf` of the Fibonacci
shift on `ZMod n × ZMod n` and proving its reduction would let one transport
`fibEntry_prod_coprime` verbatim.

The key insight is that both invariants are join-homomorphisms out of `(ℕ_{>0},·)`, so the
abstract engine `fibEntry_prod_coprime` should be re-provable once for *any* function
satisfying the law of apparition `m ∣ u k ↔ entry m ∣ k`, with Pisano period and rank of
apparition as two instances.

**Why now?** The engine is already stated for an arbitrary pairwise-coprime family; only
the law-of-apparition interface is Fibonacci-specific. Abstracting that interface (mirroring
`StrongDivSeq` in `FibonacciEntryPointInvariant.lean`) is a small refactor that immediately
yields the Pisano reduction.

## 3. Carmichael-style primitive divisors of composite indices

`fibEntry_factorization` says a modulus `m` is primitive for `F_n` (entry point `= n`) iff
`n = lcm` of the prime-power entry points dividing `m`. This gives a *computable*
characterization of which composite `m` can be primitive divisors, refining the catalog's
prime-only `FibonacciApparition.prime_primitive_divisor_iff`.

The key insight is that primitivity of a composite `m` is now a pure lattice condition on
the multiset `{fibEntry (p^{vₚ(m)})}`, namely that their lcm has no proper realization at a
smaller index — a condition checkable from the prime-power data alone.

**Why now?** The composite case was previously inaccessible because no reduction expressed
`fibEntry m` for composite `m`; with the reduction proved this cycle, the composite
primitive-divisor predicate becomes a finite lattice computation over the factorization
support.

## 4. Effective bounds: `fibEntry n ≤ ψ(n)` via the prime-power reduction

Each prime-power entry point satisfies `fibEntry (p^k) ≤ p^{k-1}(p+1)` (a classical bound),
so the reduction gives `fibEntry n ≤ lcm_p p^{vₚ(n)-1}(p+1) ∣ n·∏_{p∣n}(1+1/p)`. Formalizing
the per-prime bound and pushing it through `Finset.lcm` would yield the first machine-checked
effective bound on the Fibonacci rank of apparition.

The key insight is that `Finset.lcm_dvd_iff` turns the global bound into independent
per-prime-power bounds, exactly the divide-and-conquer structure the reduction theorem
exposes.

**Why now?** `Finset.lcm_dvd_iff` is the only nontrivial glue, and it is already used inside
`fibEntry_prod_coprime`; the remaining work is the single-prime estimate, which is a finite
`p`-adic computation supported by `Catalog/Shared/FibonacciLTE.lean`.

## 5. Universality: prime-power reduction for all strong divisibility sequences

`FibonacciEntryPointInvariant.lean` already abstracts the *gcd* half of the theory to
arbitrary strong divisibility sequences `u` (those with `gcd(u m, u n) = u(gcd m n)`),
covering Fibonacci, Lucas, and base-`a` Mersenne/repunit sequences. The natural completion
is to prove the *lcm* (prime-power reduction) half abstractly: `entry_u (∏ p^{vₚ(n)}) =
lcm entry_u (p^{vₚ(n)})` for every such `u`.

The key insight is that the engine `fibEntry_prod_coprime` used *only* the law of apparition
and `coprime_prod_dvd_iff`, both of which hold for any strong divisibility sequence whose
entry map is total — so a single abstract theorem would simultaneously deliver the
prime-power reduction for Fibonacci, Lucas, and Mersenne numbers.

**Why now?** The abstract `StrongDivSeq.entry` and `entry_dvd` infrastructure already exists
in the catalog; pairing it with the now-proven concrete reduction shows precisely which two
ingredients (totality + coprime-product divisibility) must be abstracted, making the
universal statement a guided generalization rather than a fresh development.

**Concept description**: # Future Directions — Prime-power reduction of the Fibonacci rank of apparition

This cycle added `Catalog/Pythagorean/FibonacciEntryFactorization.lean`, which closes the
multiplicative theory of the Fibonacci rank of apparition `fibEntry`. The catalog already
contained the two-factor coprime law (`FibonacciEntryPointInvariant.fibEntry_mul_coprime`)
and the unrestricted join law (`FibonacciApparitionLattice.fibEntry_lcm`). The new file
proves the **full prime-power reduction**

> `fibEntry n = lcm_{p^{vₚ(n)} ∥ n} fibEntry (p^{vₚ(n)})`  (theorem `fibEntry_factorization`),

routed through a reusable multi-factor join engine `fibEntry_prod_coprime` and the CRT
divisibility shape `coprime_prod_dvd_iff`, with monotonicity
`fibEntry_dvd_of_factorization_le` and the base case `fibEntry_one`. Everything is
`sorry`-free and depends only on the standard axioms. The directions below extend this
frontier.

## 1. The Wall–Sun–Sun barrier: `fibEntry (p²) = p · fibEntry p`?

For every known prime `p`, the rank of apparition of `p²` is exactly `p · fibEntry p`; a
prime where `fibEntry (p²) = fibEntry p` instead is precisely a **Wall–Sun–Sun prime**,
none of which are known. Combined with `fibEntry_factorization`, settling the exponent
behaviour `fibEntry (p^(k+1)) = p · fibEntry (p^k)` for `k ≥ 1` would make `fibEntry`
*completely* explicit from its values on primes alone.

The key insight is that `fibEntry_factorization` already isolates the prime-power case as
the *only* remaining unknown, so the entire mystery of the rank of apparition collapses to
the single lifting-the-exponent step `fibEntry (p^{k+1}) / fibEntry (p^k) ∈ {1, p}`,
provable from `Catalog/Shared/FibonacciLTE.lean` for `k ≥ 1` except on the Wall–Sun–Sun
locus.

**Why now?** The reduction theorem proved this cycle is exactly the statement that makes
the prime-power recurrence the *sole* obstruction; before it, an exponent law would not
have determined `fibEntry` on composite moduli. With `FibonacciLTE` already in the catalog,
the `p`-adic valuation machinery needed for the lift is in place.

## 2. Pisano period vs. rank of apparition: `π(n) = lcm` over prime powers too

The Pisano period `π(n)` (the period of `F_k mod n`) satisfies the same prime-power
reduction `π(n) = lcm_{p^{vₚ(n)}} π(p^{vₚ(n)})`, and is a bounded multiple of `fibEntry n`
(the ratio `π(n)/fibEntry(n) ∈ {1,2,4}`). Formalizing `π` as `addOrderOf` of the Fibonacci
shift on `ZMod n × ZMod n` and proving its reduction would let one transport
`fibEntry_prod_coprime` verbatim.

The key insight is that both invariants are join-homomorphisms out of `(ℕ_{>0},·)`, so the
abstract engine `fibEntry_prod_coprime` should be re-provable once for *any* function
satisfying the law of apparition `m ∣ u k ↔ entry m ∣ k`, with Pisano period and rank of
apparition as two instances.

**Why now?** The engine is already stated for an arbitrary pairwise-coprime family; only
the law-of-apparition interface is Fibonacci-specific. Abstracting that interface (mirroring
`StrongDivSeq` in `FibonacciEntryPointInvariant.lean`) is a small refactor that immediately
yields the Pisano reduction.

## 3. Carmichael-style primitive divisors of composite indices

`fibEntry_factorization` says a modulus `m` is primitive for `F_n` (entry point `= n`) iff
`n = lcm` of the prime-power entry points dividing `m`. This gives a *computable*
characterization of which composite `m` can be primitive divisors, refining the catalog's
prime-only `FibonacciApparition.prime_primitive_divisor_iff`.

The key insight is that primitivity of a composite `m` is now a pure lattice condition on
the multiset `{fibEntry (p^{vₚ(m)})}`, namely that their lcm has no proper realization at a
smaller index — a condition checkable from the prime-power data alone.

**Why now?** The composite case was previously inaccessible because no reduction expressed
`fibEntry m` for composite `m`; with the reduction proved this cycle, the composite
primitive-divisor predicate becomes a finite lattice computation over the factorization
support.

## 4. Effective bounds: `fibEntry n ≤ ψ(n)` via the prime-power reduction

Each prime-power entry point satisfies `fibEntry (p^k) ≤ p^{k-1}(p+1)` (a classical bound),
so the reduction gives `fibEntry n ≤ lcm_p p^{vₚ(n)-1}(p+1) ∣ n·∏_{p∣n}(1+1/p)`. Formalizing
the per-prime bound and pushing it through `Finset.lcm` would yield the first machine-checked
effective bound on the Fibonacci rank of apparition.

The key insight is that `Finset.lcm_dvd_iff` turns the global bound into independent
per-prime-power bounds, exactly the divide-and-conquer structure the reduction theorem
exposes.

**Why now?** `Finset.lcm_dvd_iff` is the only nontrivial glue, and it is already used inside
`fibEntry_prod_coprime`; the remaining work is the single-prime estimate, which is a finite
`p`-adic computation supported by `Catalog/Shared/FibonacciLTE.lean`.

## 5. Universality: prime-power reduction for all strong divisibility sequences

`FibonacciEntryPointInvariant.lean` already abstracts the *gcd* half of the theory to
arbitrary strong divisibility sequences `u` (those with `gcd(u m, u n) = u(gcd m n)`),
covering Fibonacci, Lucas, and base-`a` Mersenne/repunit sequences. The natural completion
is to prove the *lcm* (prime-power reduction) half abstractly: `entry_u (∏ p^{vₚ(n)}) =
lcm entry_u (p^{vₚ(n)})` for every such `u`.

The key insight is that the engine `fibEntry_prod_coprime` used *only* the law of apparition
and `coprime_prod_dvd_iff`, both of which hold for any strong divisibility sequence whose
entry map is total — so a single abstract theorem would simultaneously deliver the
prime-power reduction for Fibonacci, Lucas, and Mersenne numbers.

**Why now?** The abstract `StrongDivSeq.entry` and `entry_dvd` infrastructure already exists
in the catalog; pairing it with the now-proven concrete reduction shows precisely which two
ingredients (totality + coprime-product divisibility) must be abstracted, making the
universal statement a guided generalization rather than a fresh development.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Tropical
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
