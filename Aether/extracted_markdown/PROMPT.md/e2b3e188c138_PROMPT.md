
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

**Title**: This cycle isolated the *entry point* (rank of apparition) `z(p) = ` least `k > 
**Domain**: Applications
**Mathematical framing**: # Future Directions — Fibonacci Entry Points and Carmichael's Theorem

## Synthesis

This cycle isolated the *entry point* (rank of apparition) `z(p) = ` least `k > 0`
with `p ∣ F(k)` as the single organizing object behind the catalog's scattered
Carmichael/primitive-divisor reasoning. The new file
`FibonacciEntryPoint.lean` proves, with `sorry = 0` and only the standard
axioms, a small but complete theory:

* `fibEntryPt_dvd` — `z(p) ∣ n` whenever `p ∣ F(n)` (no primality needed);
* `fib_dvd_of_fibEntryPt_dvd` — the converse, via `Nat.fib_dvd`;
* `dvd_fib_iff_fibEntryPt_dvd` — the clean equivalence `p ∣ F(n) ↔ z(p) ∣ n`;
* `primitive_iff_fibEntryPt_eq` — `p` is a primitive divisor of `F(n)` iff `z(p) = n`;
* `fib12_no_primitive` — the sharp counterexample explaining the bound `n ≥ 13`.

The deliberate gap is the *existence* of a primitive divisor for every composite
`n > 50000` (the lone genuine `sorry` left in `Shared/CarmichaelProof.lean`'s
`fib_carmichael_composite`). Everything below is a roadmap toward closing it, plus
adjacent conjectures the entry-point lens makes newly tractable.

## Results Summary

A self-contained, axiom-clean entry-point calculus now exists over Mathlib. It
recasts "primitive divisor" as the purely order-theoretic statement `z(p) = n`,
which is exactly the certificate a future LTE/growth argument must produce. The
catalog files that previously asserted these facts ad hoc (and did not build, due
to a missing `Shared.CarmichaelHelper`) can be retargeted at this reusable theory.

---

## Direction 1 — Fibonacci Lifting-the-Exponent (the keystone)

**Conjecture.** For an odd prime `p` with entry point `z(p) = m` and `p ≠ 5`,
the `p`-adic valuation satisfies `v_p(F(m·k)) = v_p(F(m)) + v_p(k)` for all
`k ≥ 1`; for `p = 5`, `v_5(F(k)) = v_5(k)`.

**The key insight is** that `F(mk)/F(m)` expands, via the companion matrix
`V = [[1,1],[1,0]]` diagonalized over `ℤ_p[√5]`, as a binomial sum whose
leading nontrivial term is `k · r^{k-1}` modulo the maximal ideal, so the
valuation is *additive* in `k` exactly like the classical `padicValNat.pow_sub_pow`
LTE for `a^n - b^n`.

**Why now?** `primitive_iff_fibEntryPt_eq` reduces "primitive divisor of `F(n)`"
to producing a prime with `z(p) = n`; LTE is the precise tool that controls how
`z(p)` propagates to multiples, so this conjecture is the missing multiplicative
half of the already-proven divisibility half.

## Direction 2 — Cyclotomic / Möbius primitive part grows past every index

**Conjecture.** Define `Φ_n := ∏_{d ∣ n} F(d)^{μ(n/d)}` (the Möbius "primitive
part"). Then `log Φ_n = φ(n) · log φ_golden + o(n)`, and for all `n > 50000`
the integer `Φ_n` has a prime factor `q` with `z(q) = n`; consequently
`fib_carmichael_composite` holds for all such `n`, closing the open `sorry`.

**The key insight is** that the only obstructions to a prime factor of `Φ_n`
being primitive are the finitely many "intrinsic" primes dividing `n` itself
(the Zsygmondy exceptions), and a counting bound `Φ_n > n · ∏_{p ∣ n} p`
forces a genuinely new prime once `φ(n) log φ_golden` dominates `log n`.

**Why now?** Direction 1 supplies the valuation identity that turns the divisor
product into a telescoping estimate; combined with Mathlib's
`Nat.fib` growth lemmas this becomes an effective inequality verifiable above an
explicit threshold, matching the computational `native_decide` range below it.

## Direction 3 — Entry points realize a uniform-distribution / density law

**Conjecture.** The set `{p prime : z(p) = n}` is nonempty for every `n ∉ {1,2,6,12}`,
and the counting function `#{p ≤ x : z(p) ∣ n}` satisfies an asymptotic of
Chebotarev type governed by the splitting of `x² - x - 1` in `ℚ(√5)`.

**The key insight is** that `z(p)` equals the multiplicative order of the golden
ratio mod `p` (when `5` is a QR) or twice the order of `-φ̄/φ` otherwise, so the
entry-point distribution is an Artin-style primitive-root problem in disguise.

**Why now?** `dvd_fib_iff_fibEntryPt_dvd` already expresses divisibility purely
through `z`, so density statements about primitive divisors translate directly
into statements about orders mod `p`, where Mathlib's `ZMod` and `orderOf` API
gives a concrete formal target.

## Direction 4 — Transfer the entry-point calculus to all Lucas sequences

**Conjecture.** For any nondegenerate Lucas sequence `U_n(P,Q)` with
`gcd(P,Q)=1`, the analogue `z_U(p)` satisfies the same three pillars proven here
(`z ∣ n` ⇔ `p ∣ U_n`, primitivity ⇔ `z = n`), and Carmichael's theorem holds
with a finite, explicitly computable exceptional set depending only on `(P,Q)`.

**The key insight is** that the proofs in `FibonacciEntryPoint.lean` used *only*
strong divisibility `U_{gcd(m,n)} = gcd(U_m,U_n)` and `m ∣ n → U_m ∣ U_n`, both
of which hold for every Lucas sequence — so the entire file generalizes with the
Fibonacci-specific lemmas swapped for their Lucas counterparts.

**Why now?** The current proofs are deliberately written against the two abstract
divisibility facts, making the generalization a refactor (introduce a typeclass
`StrongDivisibilitySequence`) rather than new mathematics.

## Direction 5 — A formal Zsygmondy theorem for `aⁿ − bⁿ`

**Conjecture.** For coprime `a > b ≥ 1`, `aⁿ − bⁿ` has a primitive prime divisor
for all `n` outside an explicit finite set, and the *same* entry-point machinery
(`z(p) =` order of `a/b` mod `p`) yields the proof, unifying Bang–Zsygmondy and
Carmichael under one Lean development.

**The key insight is** that primitive-divisor existence for `aⁿ−b⁛` and for `F(n)`
are the two faces of order theory in `(ℤ/p)^×`; the entry point is the order, and
"primitive" is "the order is exactly `n`" — verbatim our `primitive_iff_fibEntryPt_eq`.

**Why now?** Mathlib already contains `padicValNat.pow_sub_pow` (LTE for `aⁿ−bⁿ`)
and `ZMod.orderOf` theory, so the `aⁿ−bⁿ` case is *closer* to formalization than
Fibonacci — proving it first would give a template (and the missing LTE input) for
finishing Direction 2.

**Concept description**: # Future Directions — Fibonacci Entry Points and Carmichael's Theorem

## Synthesis

This cycle isolated the *entry point* (rank of apparition) `z(p) = ` least `k > 0`
with `p ∣ F(k)` as the single organizing object behind the catalog's scattered
Carmichael/primitive-divisor reasoning. The new file
`FibonacciEntryPoint.lean` proves, with `sorry = 0` and only the standard
axioms, a small but complete theory:

* `fibEntryPt_dvd` — `z(p) ∣ n` whenever `p ∣ F(n)` (no primality needed);
* `fib_dvd_of_fibEntryPt_dvd` — the converse, via `Nat.fib_dvd`;
* `dvd_fib_iff_fibEntryPt_dvd` — the clean equivalence `p ∣ F(n) ↔ z(p) ∣ n`;
* `primitive_iff_fibEntryPt_eq` — `p` is a primitive divisor of `F(n)` iff `z(p) = n`;
* `fib12_no_primitive` — the sharp counterexample explaining the bound `n ≥ 13`.

The deliberate gap is the *existence* of a primitive divisor for every composite
`n > 50000` (the lone genuine `sorry` left in `Shared/CarmichaelProof.lean`'s
`fib_carmichael_composite`). Everything below is a roadmap toward closing it, plus
adjacent conjectures the entry-point lens makes newly tractable.

## Results Summary

A self-contained, axiom-clean entry-point calculus now exists over Mathlib. It
recasts "primitive divisor" as the purely order-theoretic statement `z(p) = n`,
which is exactly the certificate a future LTE/growth argument must produce. The
catalog files that previously asserted these facts ad hoc (and did not build, due
to a missing `Shared.CarmichaelHelper`) can be retargeted at this reusable theory.

---

## Direction 1 — Fibonacci Lifting-the-Exponent (the keystone)

**Conjecture.** For an odd prime `p` with entry point `z(p) = m` and `p ≠ 5`,
the `p`-adic valuation satisfies `v_p(F(m·k)) = v_p(F(m)) + v_p(k)` for all
`k ≥ 1`; for `p = 5`, `v_5(F(k)) = v_5(k)`.

**The key insight is** that `F(mk)/F(m)` expands, via the companion matrix
`V = [[1,1],[1,0]]` diagonalized over `ℤ_p[√5]`, as a binomial sum whose
leading nontrivial term is `k · r^{k-1}` modulo the maximal ideal, so the
valuation is *additive* in `k` exactly like the classical `padicValNat.pow_sub_pow`
LTE for `a^n - b^n`.

**Why now?** `primitive_iff_fibEntryPt_eq` reduces "primitive divisor of `F(n)`"
to producing a prime with `z(p) = n`; LTE is the precise tool that controls how
`z(p)` propagates to multiples, so this conjecture is the missing multiplicative
half of the already-proven divisibility half.

## Direction 2 — Cyclotomic / Möbius primitive part grows past every index

**Conjecture.** Define `Φ_n := ∏_{d ∣ n} F(d)^{μ(n/d)}` (the Möbius "primitive
part"). Then `log Φ_n = φ(n) · log φ_golden + o(n)`, and for all `n > 50000`
the integer `Φ_n` has a prime factor `q` with `z(q) = n`; consequently
`fib_carmichael_composite` holds for all such `n`, closing the open `sorry`.

**The key insight is** that the only obstructions to a prime factor of `Φ_n`
being primitive are the finitely many "intrinsic" primes dividing `n` itself
(the Zsygmondy exceptions), and a counting bound `Φ_n > n · ∏_{p ∣ n} p`
forces a genuinely new prime once `φ(n) log φ_golden` dominates `log n`.

**Why now?** Direction 1 supplies the valuation identity that turns the divisor
product into a telescoping estimate; combined with Mathlib's
`Nat.fib` growth lemmas this becomes an effective inequality verifiable above an
explicit threshold, matching the computational `native_decide` range below it.

## Direction 3 — Entry points realize a uniform-distribution / density law

**Conjecture.** The set `{p prime : z(p) = n}` is nonempty for every `n ∉ {1,2,6,12}`,
and the counting function `#{p ≤ x : z(p) ∣ n}` satisfies an asymptotic of
Chebotarev type governed by the splitting of `x² - x - 1` in `ℚ(√5)`.

**The key insight is** that `z(p)` equals the multiplicative order of the golden
ratio mod `p` (when `5` is a QR) or twice the order of `-φ̄/φ` otherwise, so the
entry-point distribution is an Artin-style primitive-root problem in disguise.

**Why now?** `dvd_fib_iff_fibEntryPt_dvd` already expresses divisibility purely
through `z`, so density statements about primitive divisors translate directly
into statements about orders mod `p`, where Mathlib's `ZMod` and `orderOf` API
gives a concrete formal target.

## Direction 4 — Transfer the entry-point calculus to all Lucas sequences

**Conjecture.** For any nondegenerate Lucas sequence `U_n(P,Q)` with
`gcd(P,Q)=1`, the analogue `z_U(p)` satisfies the same three pillars proven here
(`z ∣ n` ⇔ `p ∣ U_n`, primitivity ⇔ `z = n`), and Carmichael's theorem holds
with a finite, explicitly computable exceptional set depending only on `(P,Q)`.

**The key insight is** that the proofs in `FibonacciEntryPoint.lean` used *only*
strong divisibility `U_{gcd(m,n)} = gcd(U_m,U_n)` and `m ∣ n → U_m ∣ U_n`, both
of which hold for every Lucas sequence — so the entire file generalizes with the
Fibonacci-specific lemmas swapped for their Lucas counterparts.

**Why now?** The current proofs are deliberately written against the two abstract
divisibility facts, making the generalization a refactor (introduce a typeclass
`StrongDivisibilitySequence`) rather than new mathematics.

## Direction 5 — A formal Zsygmondy theorem for `aⁿ − bⁿ`

**Conjecture.** For coprime `a > b ≥ 1`, `aⁿ − bⁿ` has a primitive prime divisor
for all `n` outside an explicit finite set, and the *same* entry-point machinery
(`z(p) =` order of `a/b` mod `p`) yields the proof, unifying Bang–Zsygmondy and
Carmichael under one Lean development.

**The key insight is** that primitive-divisor existence for `aⁿ−b⁛` and for `F(n)`
are the two faces of order theory in `(ℤ/p)^×`; the entry point is the order, and
"primitive" is "the order is exactly `n`" — verbatim our `primitive_iff_fibEntryPt_eq`.

**Why now?** Mathlib already contains `padicValNat.pow_sub_pow` (LTE for `aⁿ−bⁿ`)
and `ZMod.orderOf` theory, so the `aⁿ−bⁿ` case is *closer* to formalization than
Fibonacci — proving it first would give a template (and the missing LTE input) for
finishing Direction 2.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
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
