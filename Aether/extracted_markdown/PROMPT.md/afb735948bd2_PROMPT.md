
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

**Title**: This cycle took the *single-modulus* law of apparition from the catalog
**Domain**: Pythagorean
**Mathematical framing**: # Future Directions: Multiplicative Structure of the Fibonacci Rank of Apparition

## Synthesis

This cycle took the *single-modulus* law of apparition from the catalog
(`FibonacciApparition.fib_dvd_iff_fibEntry_dvd`: `m ∣ F k ↔ fibEntry m ∣ k`) and
upgraded it to a statement about how the rank of apparition `fibEntry` interacts with the
**multiplicative structure of the modulus**. The central discovery is that `fibEntry` is an
*lcm-homomorphism on the coprime-modulus monoid*: for coprime `m, n > 0`,
`fibEntry (m * n) = lcm (fibEntry m) (fibEntry n)` (`fibEntry_mul_coprime`). The proof is a
clean local-to-global (CRT) argument: `m*n ∣ F k` splits into `m ∣ F k` and `n ∣ F k` exactly
when `m, n` are coprime, and each of those is the law of apparition for a smaller modulus.

The Critic phase showed coprimality is not cosmetic but essential: at `m = n = 2` the formula
already fails, because `fibEntry 4 = 6` while `lcm (fibEntry 2) (fibEntry 2) = lcm 3 3 = 3`
(`fibEntry_mul_coprime_fails`). The size of this gap — a factor of `2` — is precisely the
prime-power "delay" that the lcm formula cannot see, which is the structural reason the theory
splits into a coprime (CRT) part and a hard prime-power (Wall) part.

The supporting infrastructure that made this possible was (a) `fibEntry_dvd_of_dvd`,
divisibility-monotonicity of the entry point, which is the "functorial" half, and
(b) `fibEntry_eq_of`, an evaluation principle that converts the noncomputable `fibEntry`
(defined via `Nat.find`/`Classical`) into honest numeric values, enabling the counterexample.
Together these say: the coprime structure of `fibEntry` is completely understood; all remaining
depth lives in the prime-power tower `fibEntry p ∣ fibEntry (p²) ∣ ⋯` (`fibEntry_dvd_prime_pow`).

## Results Summary

- `fibEntry_dvd_of_dvd`: proved — divisibility-monotonicity `a ∣ b → fibEntry a ∣ fibEntry b`; the functorial backbone for assembling local data.
- `fibEntry_eq_of`: proved — evaluation principle pinning the noncomputable entry point from a "divides here, nowhere earlier" certificate.
- `fibEntry_two`: proved — `fibEntry 2 = 3`, the smallest concrete value, used as a counterexample ingredient.
- `fibEntry_four`: proved — `fibEntry 4 = 6`, the first prime-power value exhibiting Wall delay.
- `fibEntry_mul_coprime`: proved — the headline result: `fibEntry` is an lcm-homomorphism on coprime moduli (CRT upgrade of the law of apparition).
- `fibEntry_mul_coprime_fails`: proved (disproof of the naive generalization) — coprimality is necessary; `2·2` already breaks the lcm formula.
- `fibEntry_dvd_prime_pow`: proved — base case of the prime-power divisibility tower `fibEntry p ∣ fibEntry (p²)`.

## Research Directions

### Direction 1: CRT reconstruction of the full entry point
**Hypothesis**: For any `m > 0` with prime factorization `m = ∏ pᵢ^eᵢ`,
`fibEntry m = lcm_i (fibEntry (pᵢ^eᵢ))`.
**Test**: Induct on the number of distinct prime factors using `fibEntry_mul_coprime` at each
step (the inductive step is coprime because `p^e` is coprime to the remaining cofactor). Formalize
with `Nat.factorization` / `Finset.lcm` and prove the `Finset`-indexed lcm identity.
**Why now**: `fibEntry_mul_coprime` is exactly the two-factor base case; only the `Finset`
bookkeeping remains. This reduces *all* of entry-point theory to the prime-power case.
**If true**: Entry-point computation becomes fully local; Carmichael/primitive-divisor counting
can be done one prime power at a time.
**If false**: Would reveal a non-coprime interaction the two-factor case hides (very unlikely given the CRT proof, but the failure would be deeply informative).

### Direction 2: The prime-power tower and Wall's phenomenon
**Hypothesis**: For every prime `p` and `k ≥ 1`, either `fibEntry (p^(k+1)) = fibEntry (p^k)`
or `fibEntry (p^(k+1)) = p · fibEntry (p^k)`; the first alternative for `k = 1` happens iff `p`
is a Wall–Sun–Sun prime (none known below `2^64`).
**Test**: Prove the divisibility-and-ratio dichotomy via lifting-the-exponent applied to
`F(fibEntry p · p^j)`; the catalog file `Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors` already houses the LTE machinery to connect to.
**Why now**: `fibEntry_dvd_prime_pow` gives the divisibility half; the missing content is the
exact ratio, and the LTE catalog entry supplies the `p`-adic valuation control.
**If true**: Completes the structure theory of `fibEntry` (combined with Direction 1).
**If false**: A counterexample would *be* a Wall–Sun–Sun prime — a famous open target.

### Direction 3: Entry point of `lcm` and `gcd` of moduli
**Hypothesis**: `fibEntry (gcd a b) ∣ gcd (fibEntry a) (fibEntry b)` and
`lcm (fibEntry a) (fibEntry b) ∣ fibEntry (lcm a b)`, with equality in the second when `a, b`
are coprime.
**Test**: Both directions follow from `fibEntry_dvd_of_dvd` applied to the lattice inequalities
`gcd a b ∣ a`, `a ∣ lcm a b`; the coprime equality specializes `fibEntry_mul_coprime`.
**Why now**: `fibEntry_dvd_of_dvd` makes `fibEntry` a monotone map of divisibility lattices, so
these are immediate lattice-morphism statements.
**If true**: Establishes `fibEntry` as a lattice morphism (up to the prime-power defect), a clean
algebraic characterization.
**If false**: Pinpoints exactly where multiplicativity and the lattice structure diverge.

### Direction 4: Pisano period from the entry point
**Hypothesis**: The Pisano period `π(m)` is a multiple of `fibEntry m`, and `π(m) / fibEntry m ∈
{1, 2, 4}` (the "ratio of the period to the rank of apparition" is one of three values).
**Test**: Use the order of `F(fibEntry m + 1)` in `(ZMod m)ˣ` together with the pair-periodicity
already proved in `FibonacciApparition` (`fibPair`, `fibPair_descent`).
**Why now**: The pair-sequence dynamical system that proves `exists_pos_dvd_fib` is the same
object whose minimal period is `π(m)`; the entry point is the first return to a zero first
coordinate. The relationship is one short order-theoretic step away.
**If true**: Connects the rank of apparition to the Pisano period quantitatively, opening the
quadratic-reciprocity formula for `π(p)`.
**If false**: The `{1,2,4}` trichotomy is classical, so a Lean counterexample would indicate a
formalization-level subtlety worth isolating.

### Direction 5: Lucas-sequence generalization
**Hypothesis**: For a Lucas sequence `U_n(P, Q)` with `gcd(P,Q)=1` and discriminant `Δ ≠ 0`, the
analogue `lucasEntry` satisfies `lucasEntry (m*n) = lcm (lucasEntry m) (lucasEntry n)` for
coprime `m, n`.
**Test**: Reprove `fibEntry_mul_coprime` abstractly from the two inputs it actually used —
divisibility-monotonicity (Direction-style) and the gcd identity `gcd(U_m, U_n) = U_{gcd(m,n)}` —
then instantiate at `P=Q=1`.
**Why now**: The present proof of `fibEntry_mul_coprime` only invokes the law of apparition and
`Nat.Coprime.mul_dvd_of_dvd_of_dvd`; both transfer verbatim once the gcd identity is available
for `U`. The architecture is modular by design.
**If true**: One proof covers Fibonacci, Pell, Mersenne, and Lucas numbers simultaneously.
**If false**: Identifies which Lucas-sequence axiom (the gcd identity vs. coprimality of `P,Q`)
the CRT structure genuinely requires.

**Concept description**: # Future Directions: Multiplicative Structure of the Fibonacci Rank of Apparition

## Synthesis

This cycle took the *single-modulus* law of apparition from the catalog
(`FibonacciApparition.fib_dvd_iff_fibEntry_dvd`: `m ∣ F k ↔ fibEntry m ∣ k`) and
upgraded it to a statement about how the rank of apparition `fibEntry` interacts with the
**multiplicative structure of the modulus**. The central discovery is that `fibEntry` is an
*lcm-homomorphism on the coprime-modulus monoid*: for coprime `m, n > 0`,
`fibEntry (m * n) = lcm (fibEntry m) (fibEntry n)` (`fibEntry_mul_coprime`). The proof is a
clean local-to-global (CRT) argument: `m*n ∣ F k` splits into `m ∣ F k` and `n ∣ F k` exactly
when `m, n` are coprime, and each of those is the law of apparition for a smaller modulus.

The Critic phase showed coprimality is not cosmetic but essential: at `m = n = 2` the formula
already fails, because `fibEntry 4 = 6` while `lcm (fibEntry 2) (fibEntry 2) = lcm 3 3 = 3`
(`fibEntry_mul_coprime_fails`). The size of this gap — a factor of `2` — is precisely the
prime-power "delay" that the lcm formula cannot see, which is the structural reason the theory
splits into a coprime (CRT) part and a hard prime-power (Wall) part.

The supporting infrastructure that made this possible was (a) `fibEntry_dvd_of_dvd`,
divisibility-monotonicity of the entry point, which is the "functorial" half, and
(b) `fibEntry_eq_of`, an evaluation principle that converts the noncomputable `fibEntry`
(defined via `Nat.find`/`Classical`) into honest numeric values, enabling the counterexample.
Together these say: the coprime structure of `fibEntry` is completely understood; all remaining
depth lives in the prime-power tower `fibEntry p ∣ fibEntry (p²) ∣ ⋯` (`fibEntry_dvd_prime_pow`).

## Results Summary

- `fibEntry_dvd_of_dvd`: proved — divisibility-monotonicity `a ∣ b → fibEntry a ∣ fibEntry b`; the functorial backbone for assembling local data.
- `fibEntry_eq_of`: proved — evaluation principle pinning the noncomputable entry point from a "divides here, nowhere earlier" certificate.
- `fibEntry_two`: proved — `fibEntry 2 = 3`, the smallest concrete value, used as a counterexample ingredient.
- `fibEntry_four`: proved — `fibEntry 4 = 6`, the first prime-power value exhibiting Wall delay.
- `fibEntry_mul_coprime`: proved — the headline result: `fibEntry` is an lcm-homomorphism on coprime moduli (CRT upgrade of the law of apparition).
- `fibEntry_mul_coprime_fails`: proved (disproof of the naive generalization) — coprimality is necessary; `2·2` already breaks the lcm formula.
- `fibEntry_dvd_prime_pow`: proved — base case of the prime-power divisibility tower `fibEntry p ∣ fibEntry (p²)`.

## Research Directions

### Direction 1: CRT reconstruction of the full entry point
**Hypothesis**: For any `m > 0` with prime factorization `m = ∏ pᵢ^eᵢ`,
`fibEntry m = lcm_i (fibEntry (pᵢ^eᵢ))`.
**Test**: Induct on the number of distinct prime factors using `fibEntry_mul_coprime` at each
step (the inductive step is coprime because `p^e` is coprime to the remaining cofactor). Formalize
with `Nat.factorization` / `Finset.lcm` and prove the `Finset`-indexed lcm identity.
**Why now**: `fibEntry_mul_coprime` is exactly the two-factor base case; only the `Finset`
bookkeeping remains. This reduces *all* of entry-point theory to the prime-power case.
**If true**: Entry-point computation becomes fully local; Carmichael/primitive-divisor counting
can be done one prime power at a time.
**If false**: Would reveal a non-coprime interaction the two-factor case hides (very unlikely given the CRT proof, but the failure would be deeply informative).

### Direction 2: The prime-power tower and Wall's phenomenon
**Hypothesis**: For every prime `p` and `k ≥ 1`, either `fibEntry (p^(k+1)) = fibEntry (p^k)`
or `fibEntry (p^(k+1)) = p · fibEntry (p^k)`; the first alternative for `k = 1` happens iff `p`
is a Wall–Sun–Sun prime (none known below `2^64`).
**Test**: Prove the divisibility-and-ratio dichotomy via lifting-the-exponent applied to
`F(fibEntry p · p^j)`; the catalog file `Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors` already houses the LTE machinery to connect to.
**Why now**: `fibEntry_dvd_prime_pow` gives the divisibility half; the missing content is the
exact ratio, and the LTE catalog entry supplies the `p`-adic valuation control.
**If true**: Completes the structure theory of `fibEntry` (combined with Direction 1).
**If false**: A counterexample would *be* a Wall–Sun–Sun prime — a famous open target.

### Direction 3: Entry point of `lcm` and `gcd` of moduli
**Hypothesis**: `fibEntry (gcd a b) ∣ gcd (fibEntry a) (fibEntry b)` and
`lcm (fibEntry a) (fibEntry b) ∣ fibEntry (lcm a b)`, with equality in the second when `a, b`
are coprime.
**Test**: Both directions follow from `fibEntry_dvd_of_dvd` applied to the lattice inequalities
`gcd a b ∣ a`, `a ∣ lcm a b`; the coprime equality specializes `fibEntry_mul_coprime`.
**Why now**: `fibEntry_dvd_of_dvd` makes `fibEntry` a monotone map of divisibility lattices, so
these are immediate lattice-morphism statements.
**If true**: Establishes `fibEntry` as a lattice morphism (up to the prime-power defect), a clean
algebraic characterization.
**If false**: Pinpoints exactly where multiplicativity and the lattice structure diverge.

### Direction 4: Pisano period from the entry point
**Hypothesis**: The Pisano period `π(m)` is a multiple of `fibEntry m`, and `π(m) / fibEntry m ∈
{1, 2, 4}` (the "ratio of the period to the rank of apparition" is one of three values).
**Test**: Use the order of `F(fibEntry m + 1)` in `(ZMod m)ˣ` together with the pair-periodicity
already proved in `FibonacciApparition` (`fibPair`, `fibPair_descent`).
**Why now**: The pair-sequence dynamical system that proves `exists_pos_dvd_fib` is the same
object whose minimal period is `π(m)`; the entry point is the first return to a zero first
coordinate. The relationship is one short order-theoretic step away.
**If true**: Connects the rank of apparition to the Pisano period quantitatively, opening the
quadratic-reciprocity formula for `π(p)`.
**If false**: The `{1,2,4}` trichotomy is classical, so a Lean counterexample would indicate a
formalization-level subtlety worth isolating.

### Direction 5: Lucas-sequence generalization
**Hypothesis**: For a Lucas sequence `U_n(P, Q)` with `gcd(P,Q)=1` and discriminant `Δ ≠ 0`, the
analogue `lucasEntry` satisfies `lucasEntry (m*n) = lcm (lucasEntry m) (lucasEntry n)` for
coprime `m, n`.
**Test**: Reprove `fibEntry_mul_coprime` abstractly from the two inputs it actually used —
divisibility-monotonicity (Direction-style) and the gcd identity `gcd(U_m, U_n) = U_{gcd(m,n)}` —
then instantiate at `P=Q=1`.
**Why now**: The present proof of `fibEntry_mul_coprime` only invokes the law of apparition and
`Nat.Coprime.mul_dvd_of_dvd_of_dvd`; both transfer verbatim once the gcd identity is available
for `U`. The architecture is modular by design.
**If true**: One proof covers Fibonacci, Pell, Mersenne, and Lucas numbers simultaneously.
**If false**: Identifies which Lucas-sequence axiom (the gcd identity vs. coprimality of `P,Q`)
the CRT structure genuinely requires.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Pythagorean
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
