
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

**Title**: This cycle treated the rank of apparition `fibRank` not as an ad-hoc arithmetic
**Domain**: Applications
**Mathematical framing**: # Future Directions — The Fibonacci apparition adjunction and the road to Carmichael's tail

## Synthesis

This cycle treated the rank of apparition `fibRank` not as an ad-hoc arithmetic
gadget but as **one half of a Galois adjunction** `fibRank ⊣ fib` between the
divisibility preorder on *moduli* and the divisibility preorder on *indices*.
The spine of the catalog's primitive-divisor program — `m ∣ F n ↔ fibRank m ∣ n`
— is exactly the adjunction inequality, and once it is read this way the
structural theorems become formal consequences of the adjunction rather than
separate computations.

Two concrete payoffs were formalized (sorry-free) this cycle:

* The adjunction itself, with the `HasFibRank` hypothesis **removed**: the spine
  `fibRank m ∣ n ↔ m ∣ F n` holds for *every* `m` (`fibRank_dvd_iff'`).
* The representation consequence that a left adjoint preserves joins: `fibRank`
  is an exact **lcm-homomorphism** `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`
  (`fibRank_lcm`), lifting to arbitrary finite joins (`fibRank_finset_lcm`), while
  meets are preserved only up to divisibility (`fibRank_gcd_dvd`).

In parallel the long-standing structural gap that prevented the whole
Carmichael development from compiling — the missing prime-index case
`fib_primitive_divisor_prime` — was closed by the rank argument: for a prime
index every prime divisor of `F n` is automatically primitive.

## Results summary

| Result | File | Status |
| --- | --- | --- |
| `fib_primitive_divisor_prime` (prime-index Carmichael) | `Catalog/Shared/CarmichaelHelper.lean` | proved, `sorry = 0` |
| `fibRank_dvd_iff'` (Fibonacci Galois adjunction, hypothesis-free) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_lcm` (join / lcm homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_finset_lcm` (finite join homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_mono`, `fibRank_gcd_dvd` (meet sub-law) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |

The single remaining `sorry` in the program is the **composite asymptotic tail**
`fib_carmichael_composite` for `n > 10000` in `Catalog/Shared/CarmichaelProof.lean`
(the finite band `13 ≤ n ≤ 10000` is already certified by `native_decide`).

---

## Direction 1 — Close the composite tail through the cyclotomic value `Φ_n`

State and prove, for composite `n > 12`, that the homogeneous cyclotomic value
`Φ_n = ∏_{d ∣ n} (F d) ^ μ(n/d)` is a positive integer satisfying
`∏_{d ∣ n} Φ_d = F n`, that every prime dividing `Φ_n` with rank a *proper*
divisor of `n` equals the largest prime factor `P` of `n` and divides `Φ_n` to
first power (an LTE corollary of the already-proven `fib_lte`), and finally that
`Φ_n > n`. Then a primitive prime divisor exists.

The key insight is that the existence question collapses to a single scalar
inequality `Φ_n > n`: the reduction `primitive part = F_n / N` with
`N = (F_n/Φ_n)·N₂` and `N₂ ∣ n` shows the primitive part is `> 1` precisely when
`Φ_n` outgrows `n`, so all the number theory is concentrated in one golden-ratio
size bound `Φ_n ≍ α^{φ(n)}`.

Why now? Every analytic ingredient already lives in the catalog sorry-free —
`fib_lte` (lifting the exponent), `fib_exponential_lower_bound`, and the full
entry-point/rank spine — so the remaining work is the Möbius bookkeeping plus one
`φ(n) ≥ c√n` estimate rather than a from-scratch theory.

## Direction 2 — The adjunction is sharp: classify when `fibRank` preserves meets

Conjecture: `fibRank (gcd a b) = gcd (fibRank a) (fibRank b)` holds **iff**
`fibRank a` and `fibRank b` are "rank-coprime in apparition", and fails for the
first time at an explicit small pair; only the divisibility `fibRank_gcd_dvd`
survives in general.

The key insight is that a left adjoint preserves joins but generally not meets,
so the gcd law must degrade exactly where the apparition lattice is not
distributive over the prime-power decomposition — a defect that should be
measurable and pinned to concrete witnesses.

Why now? `fibRank_lcm` and `fibRank_gcd_dvd` are in hand, so the equality
question is a finite search away from a counterexample and a clean
characterization; the falsifiable form (find the least failing `(a,b)`) makes it
immediately testable by `decide`.

## Direction 3 — Lift the adjunction to every strong divisibility sequence

Generalize `fibRank_dvd_iff'` and `fibRank_lcm` from `Nat.fib` to an arbitrary
strong divisibility sequence `u` (the `IsStrongDivSeq` setting already in
`Catalog/Applications/UnifiedRankOfApparition.lean`): prove `rank u ⊣ u` and that
`rank u` is an lcm-homomorphism.

The key insight is that nothing in the join law used Fibonacci-specific identities
— only the meet law `u (gcd m n) = gcd (u m) (u n)` — so the entire adjunction is
a theorem about strong divisibility sequences, with Fibonacci, Lucas, Mersenne
`2^n - 1`, and `q^n - 1` as instances of one engine.

Why now? The `rank u` machinery (`rank_dvd_iff`, `rank_dvd_of_dvd`) is already
proved sorry-free, so the generalization is a re-derivation of this cycle's two
headline theorems one abstraction level up.

## Direction 4 — A Stone-style duality between indices and apparition supports

Define the apparition support functor `n ↦ Supp(n) = { p prime | p ∣ F n }` and
its adjoint `S ↦ ⋂_{p ∈ S} (multiples of fibRank p)`, and prove they form a
Galois connection whose closed indices are exactly the multiples and whose closed
supports are exactly the "rank-saturated" prime sets; primitive divisors are the
points where the support strictly grows.

The key insight is that Carmichael's theorem is precisely the statement that this
Galois connection is *non-degenerate* for `n ∉ {1,2,6,12}` — primitivity is the
order-theoretic assertion that `Supp(n) ⊋ ⋃_{d ∣ n, d < n} Supp(d)`, turning an
analytic divisor question into a duality/closure statement.

Why now? With `fibRank_dvd_iff'` giving `p ∣ F n ↔ fibRank p ∣ n`, the support
functor is already definable and computable, so the connection's unit/counit
laws reduce to the lcm/gcd homomorphism results proved this cycle.

**Concept description**: # Future Directions — The Fibonacci apparition adjunction and the road to Carmichael's tail

## Synthesis

This cycle treated the rank of apparition `fibRank` not as an ad-hoc arithmetic
gadget but as **one half of a Galois adjunction** `fibRank ⊣ fib` between the
divisibility preorder on *moduli* and the divisibility preorder on *indices*.
The spine of the catalog's primitive-divisor program — `m ∣ F n ↔ fibRank m ∣ n`
— is exactly the adjunction inequality, and once it is read this way the
structural theorems become formal consequences of the adjunction rather than
separate computations.

Two concrete payoffs were formalized (sorry-free) this cycle:

* The adjunction itself, with the `HasFibRank` hypothesis **removed**: the spine
  `fibRank m ∣ n ↔ m ∣ F n` holds for *every* `m` (`fibRank_dvd_iff'`).
* The representation consequence that a left adjoint preserves joins: `fibRank`
  is an exact **lcm-homomorphism** `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`
  (`fibRank_lcm`), lifting to arbitrary finite joins (`fibRank_finset_lcm`), while
  meets are preserved only up to divisibility (`fibRank_gcd_dvd`).

In parallel the long-standing structural gap that prevented the whole
Carmichael development from compiling — the missing prime-index case
`fib_primitive_divisor_prime` — was closed by the rank argument: for a prime
index every prime divisor of `F n` is automatically primitive.

## Results summary

| Result | File | Status |
| --- | --- | --- |
| `fib_primitive_divisor_prime` (prime-index Carmichael) | `Catalog/Shared/CarmichaelHelper.lean` | proved, `sorry = 0` |
| `fibRank_dvd_iff'` (Fibonacci Galois adjunction, hypothesis-free) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_lcm` (join / lcm homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_finset_lcm` (finite join homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_mono`, `fibRank_gcd_dvd` (meet sub-law) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |

The single remaining `sorry` in the program is the **composite asymptotic tail**
`fib_carmichael_composite` for `n > 10000` in `Catalog/Shared/CarmichaelProof.lean`
(the finite band `13 ≤ n ≤ 10000` is already certified by `native_decide`).

---

## Direction 1 — Close the composite tail through the cyclotomic value `Φ_n`

State and prove, for composite `n > 12`, that the homogeneous cyclotomic value
`Φ_n = ∏_{d ∣ n} (F d) ^ μ(n/d)` is a positive integer satisfying
`∏_{d ∣ n} Φ_d = F n`, that every prime dividing `Φ_n` with rank a *proper*
divisor of `n` equals the largest prime factor `P` of `n` and divides `Φ_n` to
first power (an LTE corollary of the already-proven `fib_lte`), and finally that
`Φ_n > n`. Then a primitive prime divisor exists.

The key insight is that the existence question collapses to a single scalar
inequality `Φ_n > n`: the reduction `primitive part = F_n / N` with
`N = (F_n/Φ_n)·N₂` and `N₂ ∣ n` shows the primitive part is `> 1` precisely when
`Φ_n` outgrows `n`, so all the number theory is concentrated in one golden-ratio
size bound `Φ_n ≍ α^{φ(n)}`.

Why now? Every analytic ingredient already lives in the catalog sorry-free —
`fib_lte` (lifting the exponent), `fib_exponential_lower_bound`, and the full
entry-point/rank spine — so the remaining work is the Möbius bookkeeping plus one
`φ(n) ≥ c√n` estimate rather than a from-scratch theory.

## Direction 2 — The adjunction is sharp: classify when `fibRank` preserves meets

Conjecture: `fibRank (gcd a b) = gcd (fibRank a) (fibRank b)` holds **iff**
`fibRank a` and `fibRank b` are "rank-coprime in apparition", and fails for the
first time at an explicit small pair; only the divisibility `fibRank_gcd_dvd`
survives in general.

The key insight is that a left adjoint preserves joins but generally not meets,
so the gcd law must degrade exactly where the apparition lattice is not
distributive over the prime-power decomposition — a defect that should be
measurable and pinned to concrete witnesses.

Why now? `fibRank_lcm` and `fibRank_gcd_dvd` are in hand, so the equality
question is a finite search away from a counterexample and a clean
characterization; the falsifiable form (find the least failing `(a,b)`) makes it
immediately testable by `decide`.

## Direction 3 — Lift the adjunction to every strong divisibility sequence

Generalize `fibRank_dvd_iff'` and `fibRank_lcm` from `Nat.fib` to an arbitrary
strong divisibility sequence `u` (the `IsStrongDivSeq` setting already in
`Catalog/Applications/UnifiedRankOfApparition.lean`): prove `rank u ⊣ u` and that
`rank u` is an lcm-homomorphism.

The key insight is that nothing in the join law used Fibonacci-specific identities
— only the meet law `u (gcd m n) = gcd (u m) (u n)` — so the entire adjunction is
a theorem about strong divisibility sequences, with Fibonacci, Lucas, Mersenne
`2^n - 1`, and `q^n - 1` as instances of one engine.

Why now? The `rank u` machinery (`rank_dvd_iff`, `rank_dvd_of_dvd`) is already
proved sorry-free, so the generalization is a re-derivation of this cycle's two
headline theorems one abstraction level up.

## Direction 4 — A Stone-style duality between indices and apparition supports

Define the apparition support functor `n ↦ Supp(n) = { p prime | p ∣ F n }` and
its adjoint `S ↦ ⋂_{p ∈ S} (multiples of fibRank p)`, and prove they form a
Galois connection whose closed indices are exactly the multiples and whose closed
supports are exactly the "rank-saturated" prime sets; primitive divisors are the
points where the support strictly grows.

The key insight is that Carmichael's theorem is precisely the statement that this
Galois connection is *non-degenerate* for `n ∉ {1,2,6,12}` — primitivity is the
order-theoretic assertion that `Supp(n) ⊋ ⋃_{d ∣ n, d < n} Supp(d)`, turning an
analytic divisor question into a duality/closure statement.

Why now? With `fibRank_dvd_iff'` giving `p ∣ F n ↔ fibRank p ∣ n`, the support
functor is already definable and computable, so the connection's unit/counit
laws reduce to the lcm/gcd homomorphism results proved this cycle.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v10 Depth Requirements -- Conceptual Unifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Grothendieck style)**. Search for deep, hidden structures, universal patterns, and bridges across domains.

### RESEARCH CORE METHODOLOGY:
1. **Abstract Structural Patterns**: Frame your objects and mappings in terms of universal structures, symmetries, and invariant properties. Look for the underlying categorical, topological, or algebraic foundations that make the specific problem a special case of a deeper truth.
2. **Cross-Domain Bridges**: Connect apparently distinct mathematical worlds (e.g. applying algebraic structures to computational complexity, or geometry to logic).
3. **Generalization Over Specialization**: Prefer elegant, universal formulations that unify multiple separate facts into single, coherent conceptual frameworks.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
