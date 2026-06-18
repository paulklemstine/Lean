
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

**Title**: This cycle added `Catalog/Pythagorean/FibonacciEntryFactorization.lean`, which p
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Prime-power reduction of the Fibonacci rank of apparition

This cycle added `Catalog/Pythagorean/FibonacciEntryFactorization.lean`, which proves two new
`sorry`-free theorems on top of the catalog's entry-point theory
(`FibonacciApparition.fibEntry`, the law of apparition `fib_dvd_iff_fibEntry_dvd`, and the
binary multiplicativity `fibEntry_mul_coprime`):

* **`fibEntry_prod_coprime`** — finite multiplicativity: for a pairwise-coprime family of
  positive moduli, `fibEntry (∏ i, f i) = lcm_i (fibEntry (f i))`.
* **`fibEntry_eq_lcm_factorization`** — the prime-power reduction: for `n > 0`,
  `fibEntry n = lcm over p^vₚ(n) of fibEntry (p ^ vₚ(n))`.

Together these show that the entire (otherwise `Nat.find`-opaque) rank-of-apparition function
is *determined by its values on prime powers*. The directions below all exploit this
localization. Each is testable: it either reduces to a finite computation, or is a precise
divisibility/equality statement that a future cycle can attack as a fresh Lean target.

## Direction 1 — The prime-power tower and Wall's question

Conjecture: for every prime `p` and every `k ≥ 1`, `fibEntry (p^(k+1)) ∈ {fibEntry (p^k),
p · fibEntry (p^k)}`, and the "stay" case `fibEntry (p^(k+1)) = fibEntry (p^k)` happens for at
most one threshold `k = e_p` (the Wall exponent), after which the tower grows by exactly a
factor of `p` at each step. The falsifiable Lean target is the divisibility
`fibEntry (p^(k+1)) ∣ p · fibEntry (p^k)` together with `fibEntry (p^k) ∣ fibEntry (p^(k+1))`
(the second is already an instance of the proved `fibEntry_dvd_of_dvd`).

The key insight is that the reduction theorem `fibEntry_eq_lcm_factorization` makes prime
powers the *only* unknown in the whole theory, so the long-standing Wall–Sun–Sun question
("is `fibEntry (p^2) = fibEntry p` ever?") is exactly the `k = 1` boundary case of this tower
and nothing else needs to be understood globally.

Why now? We have a clean, machine-checked statement that fibEntry factors through prime
powers; the missing ingredient is a single lifting-the-exponent lemma
(`p^j ∣ F n → p^(j+1) ∣ F (p·n)`), which is a self-contained, provable Lean lemma rather than
a global conjecture.

## Direction 2 — Pisano period versus rank of apparition

Conjecture: for `m > 0`, the Pisano period `π(m)` (the period of `F mod m`) is an integer
multiple of `fibEntry m`, with quotient `π(m) / fibEntry m ∈ {1, 2, 4}`; moreover the quotient
is multiplicative-compatible with `fibEntry_prod_coprime` on coprime moduli (so the period also
localizes to prime powers).

The key insight is that `F(fibEntry m) ≡ 0` forces the pair `(F(fibEntry m), F(fibEntry m + 1))`
to be `(0, u)` for a unit `u` of multiplicative order `1`, `2`, or `4` in `(ℤ/m)ˣ`, and that
order is precisely the period-to-rank quotient.

Why now? The period side already exists implicitly in
`Catalog/Speculative/AutoResearch/FibonacciApparition.lean` (the `fibPair` dynamical system and
its pigeonhole periodicity), so the quotient bound can be phrased and proved with the same
`ZMod m × ZMod m` machinery already in the catalog.

## Direction 3 — Abstract reduction for strong divisibility sequences

Conjecture: the reduction theorem is not special to Fibonacci. For *any* strong divisibility
sequence `u` (one with `gcd (u m) (u n) = u (gcd m n)`) in which every modulus appears, the
abstract entry point `StrongDivSeq.entry u` satisfies both finite multiplicativity on coprime
moduli and `entry u n = lcm over p^vₚ(n) of entry u (p^vₚ(n))`. Instantiating at
`u n = a^n - 1` recovers the classical fact that the multiplicative order `ord_m(a)` is the lcm
of the orders modulo prime powers.

The key insight is that the only Fibonacci-specific fact used in this cycle's proofs is the
law of apparition, which `Catalog/Novelty/FibonacciEntryPointInvariant.lean` already proves
abstractly from `gcd (u m) (u n) = u (gcd m n)` alone — so the reduction lifts verbatim once a
"totality" hypothesis (every modulus appears) is added.

Why now? `StrongDivSeq.entry`, `entry_dvd`, and `primitive_divisor_inj` are already in the
catalog; abstracting the two new theorems is a mechanical generalization that immediately pays
off in two concrete models (Fibonacci and base-`a` Mersenne/repunit).

## Direction 4 — Carmichael / Zsygmondy via the reduction

Conjecture: an index `n` carries a *primitive* prime divisor of `F n` exactly when some prime
power `p^vₚ(n)` in its factorization has `fibEntry (p^vₚ(n)) = n`; equivalently, the set of
"defective" indices (no primitive divisor) is finite and computable. The reduction theorem
turns the global Carmichael statement (`Catalog/Shared/CarmichaelProof.lean`) into a per-prime-
power appearance test.

The key insight is that `fibEntry` pins the first appearance of a modulus, and the lcm formula
shows `n` is a first appearance of *some* modulus iff `n` is the lcm of the prime-power ranks
beneath it — collapsing primitivity to a finite divisor-comparison at each `n`.

Why now? The composite Carmichael case in `CarmichaelProof.lean` still carries one `sorry`
(the infinite tail beyond the `native_decide` range); re-expressing that tail through
`fibEntry_eq_lcm_factorization` may replace the brute-force bound with a structural argument.

## Direction 5 — Average order of the rank of apparition

Conjecture: the summatory function `∑_{m ≤ x} fibEntry m` grows like `C · x^2` for an explicit
constant `C`, and the reduction theorem gives `C` as an Euler product over primes of the
prime-power contributions `fibEntry (p^k)`.

The key insight is that multiplicativity (`fibEntry_prod_coprime`) plus the lcm-over-prime-powers
formula expresses any Dirichlet-series / averaging statement about `fibEntry` as a product over
primes, exactly as for classical multiplicative functions.

Why now? With the prime-power reduction proved, the analytic-number-theory toolkit
(`ArithmeticFunction`, Euler products) in Mathlib becomes directly applicable to `fibEntry`,
which previously had no multiplicative handle.

**Concept description**: # Future Directions — Prime-power reduction of the Fibonacci rank of apparition

This cycle added `Catalog/Pythagorean/FibonacciEntryFactorization.lean`, which proves two new
`sorry`-free theorems on top of the catalog's entry-point theory
(`FibonacciApparition.fibEntry`, the law of apparition `fib_dvd_iff_fibEntry_dvd`, and the
binary multiplicativity `fibEntry_mul_coprime`):

* **`fibEntry_prod_coprime`** — finite multiplicativity: for a pairwise-coprime family of
  positive moduli, `fibEntry (∏ i, f i) = lcm_i (fibEntry (f i))`.
* **`fibEntry_eq_lcm_factorization`** — the prime-power reduction: for `n > 0`,
  `fibEntry n = lcm over p^vₚ(n) of fibEntry (p ^ vₚ(n))`.

Together these show that the entire (otherwise `Nat.find`-opaque) rank-of-apparition function
is *determined by its values on prime powers*. The directions below all exploit this
localization. Each is testable: it either reduces to a finite computation, or is a precise
divisibility/equality statement that a future cycle can attack as a fresh Lean target.

## Direction 1 — The prime-power tower and Wall's question

Conjecture: for every prime `p` and every `k ≥ 1`, `fibEntry (p^(k+1)) ∈ {fibEntry (p^k),
p · fibEntry (p^k)}`, and the "stay" case `fibEntry (p^(k+1)) = fibEntry (p^k)` happens for at
most one threshold `k = e_p` (the Wall exponent), after which the tower grows by exactly a
factor of `p` at each step. The falsifiable Lean target is the divisibility
`fibEntry (p^(k+1)) ∣ p · fibEntry (p^k)` together with `fibEntry (p^k) ∣ fibEntry (p^(k+1))`
(the second is already an instance of the proved `fibEntry_dvd_of_dvd`).

The key insight is that the reduction theorem `fibEntry_eq_lcm_factorization` makes prime
powers the *only* unknown in the whole theory, so the long-standing Wall–Sun–Sun question
("is `fibEntry (p^2) = fibEntry p` ever?") is exactly the `k = 1` boundary case of this tower
and nothing else needs to be understood globally.

Why now? We have a clean, machine-checked statement that fibEntry factors through prime
powers; the missing ingredient is a single lifting-the-exponent lemma
(`p^j ∣ F n → p^(j+1) ∣ F (p·n)`), which is a self-contained, provable Lean lemma rather than
a global conjecture.

## Direction 2 — Pisano period versus rank of apparition

Conjecture: for `m > 0`, the Pisano period `π(m)` (the period of `F mod m`) is an integer
multiple of `fibEntry m`, with quotient `π(m) / fibEntry m ∈ {1, 2, 4}`; moreover the quotient
is multiplicative-compatible with `fibEntry_prod_coprime` on coprime moduli (so the period also
localizes to prime powers).

The key insight is that `F(fibEntry m) ≡ 0` forces the pair `(F(fibEntry m), F(fibEntry m + 1))`
to be `(0, u)` for a unit `u` of multiplicative order `1`, `2`, or `4` in `(ℤ/m)ˣ`, and that
order is precisely the period-to-rank quotient.

Why now? The period side already exists implicitly in
`Catalog/Speculative/AutoResearch/FibonacciApparition.lean` (the `fibPair` dynamical system and
its pigeonhole periodicity), so the quotient bound can be phrased and proved with the same
`ZMod m × ZMod m` machinery already in the catalog.

## Direction 3 — Abstract reduction for strong divisibility sequences

Conjecture: the reduction theorem is not special to Fibonacci. For *any* strong divisibility
sequence `u` (one with `gcd (u m) (u n) = u (gcd m n)`) in which every modulus appears, the
abstract entry point `StrongDivSeq.entry u` satisfies both finite multiplicativity on coprime
moduli and `entry u n = lcm over p^vₚ(n) of entry u (p^vₚ(n))`. Instantiating at
`u n = a^n - 1` recovers the classical fact that the multiplicative order `ord_m(a)` is the lcm
of the orders modulo prime powers.

The key insight is that the only Fibonacci-specific fact used in this cycle's proofs is the
law of apparition, which `Catalog/Novelty/FibonacciEntryPointInvariant.lean` already proves
abstractly from `gcd (u m) (u n) = u (gcd m n)` alone — so the reduction lifts verbatim once a
"totality" hypothesis (every modulus appears) is added.

Why now? `StrongDivSeq.entry`, `entry_dvd`, and `primitive_divisor_inj` are already in the
catalog; abstracting the two new theorems is a mechanical generalization that immediately pays
off in two concrete models (Fibonacci and base-`a` Mersenne/repunit).

## Direction 4 — Carmichael / Zsygmondy via the reduction

Conjecture: an index `n` carries a *primitive* prime divisor of `F n` exactly when some prime
power `p^vₚ(n)` in its factorization has `fibEntry (p^vₚ(n)) = n`; equivalently, the set of
"defective" indices (no primitive divisor) is finite and computable. The reduction theorem
turns the global Carmichael statement (`Catalog/Shared/CarmichaelProof.lean`) into a per-prime-
power appearance test.

The key insight is that `fibEntry` pins the first appearance of a modulus, and the lcm formula
shows `n` is a first appearance of *some* modulus iff `n` is the lcm of the prime-power ranks
beneath it — collapsing primitivity to a finite divisor-comparison at each `n`.

Why now? The composite Carmichael case in `CarmichaelProof.lean` still carries one `sorry`
(the infinite tail beyond the `native_decide` range); re-expressing that tail through
`fibEntry_eq_lcm_factorization` may replace the brute-force bound with a structural argument.

## Direction 5 — Average order of the rank of apparition

Conjecture: the summatory function `∑_{m ≤ x} fibEntry m` grows like `C · x^2` for an explicit
constant `C`, and the reduction theorem gives `C` as an Euler product over primes of the
prime-power contributions `fibEntry (p^k)`.

The key insight is that multiplicativity (`fibEntry_prod_coprime`) plus the lcm-over-prime-powers
formula expresses any Dirichlet-series / averaging statement about `fibEntry` as a product over
primes, exactly as for classical multiplicative functions.

Why now? With the prime-power reduction proved, the analytic-number-theory toolkit
(`ArithmeticFunction`, Euler products) in Mathlib becomes directly applicable to `fibEntry`,
which previously had no multiplicative handle.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
