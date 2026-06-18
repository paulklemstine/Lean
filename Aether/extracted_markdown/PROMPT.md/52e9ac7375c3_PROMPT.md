
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

**Title**: *capacity / packing* layer on top of the catalog's Fibonacci
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Stereographic Capacity Theory for Fibonacci Apparitions

## Synthesis

This cycle built a *capacity / packing* layer on top of the catalog's Fibonacci
divisibility lattice (`Cryptography.FibonacciDivisibilityLattice`, the
`Fib_gcd_identity` lineage). The pivot was reading the apparition law
`m ∣ fib n ↔ entry m ∣ n` not as a divisibility fact but as a statement that *the
apparition index set is a set of multiples*, and therefore admits exact counting.

The new file `Catalog/Computation/FibonacciApparitionCapacity.lean` proves four
results, all `sorry`-free and depending only on `propext`, `Classical.choice`,
`Quot.sound`:

1. **`entry_dvd_of_dvd`** — the rank of apparition is monotone for divisibility:
   `a ∣ b → entry a ∣ entry b`.
2. **`entry_lcm`** — `entry` is an lcm-homomorphism:
   `entry (lcm a b) = lcm (entry a) (entry b)`.
3. **`apparition_count`** — exact capacity: `#{n ∈ (0,N] : m ∣ fib n} = N / entry m`.
4. **`apparition_density_bound`** — uniform packing density: for `m ≥ 2`,
   `3 · #{apparitions ≤ N} ≤ N`, with `1/3` sharp (witnessed by `m = 2`,
   `entry 2 = 3`).

This is a Cryptography → Computation bridge: a Lucas/rank-of-apparition structure
became an exact counting/packing theorem.

## Results summary

| Result | Statement | Status |
|---|---|---|
| `entry_dvd_of_dvd` | `a ∣ b → entry a ∣ entry b` | proved |
| `entry_lcm` | `entry (lcm a b) = lcm (entry a) (entry b)` | proved |
| `apparition_count` | `#{n ∈ (0,N] : m ∣ fib n} = N / entry m` | proved |
| `apparition_density_bound` | `m ≥ 2 → 3 · #{apparitions ≤ N} ≤ N` | proved |

---

## Direction 1 — `entry` is **not** a gcd-homomorphism (refute the dual)

The lcm-homomorphism `entry (lcm a b) = lcm (entry a) (entry b)` begs the dual
question: is `entry (gcd a b) = gcd (entry a) (entry b)`? **Conjecture: this is
false, and the witness `a = 4, b = 6` refutes it.** Here `entry 4 = 6`,
`entry 6 = 12`, `gcd(4,6) = 2`, so the left side is `entry 2 = 3`, while the right
side is `gcd(6,12) = 6 ≠ 3`. The falsifiable task is to formalize this
counterexample and then characterize *exactly* the pairs `(a,b)` for which the gcd
identity does hold (the data suggests: precisely when `entry a` and `entry b` are
already "aligned", e.g. one rank divides the other).

The key insight is that `lcm` is the join in the apparition lattice and is preserved
because `lcm a b ∣ fib n ↔ a ∣ fib n ∧ b ∣ fib n` decomposes a single apparition set
into an intersection, whereas `gcd` is the meet and corresponds to a *union* of
apparition sets, which is not itself a set of multiples — so no rank can represent
it in general.

Why now? `entry_lcm` is already proved, so the homomorphism machinery is in place;
the meet/join asymmetry is the immediate stress-test and a clean adversarial result
(a proved non-theorem with an explicit witness) that sharpens the structure.

## Direction 2 — Law of apparition modulo a prime

**Conjecture (Lucas's law of apparition):** for every prime `p ≠ 5`,
`entry p ∣ p - legendreSym 5 p`, i.e. `entry p ∣ p - 1` when `5` is a quadratic
residue mod `p` (`p ≡ ±1 mod 5`) and `entry p ∣ p + 1` otherwise
(`p ≡ ±2 mod 5`). Falsifiable: a single prime violating the claimed divisor would
sink it; verifying it for all primes below a bound is a concrete first milestone.

The key insight is that `fib (p - legendreSym 5 p) ≡ 0 (mod p)` follows from the
Binet/`ZMod` identity `fib p ≡ legendreSym 5 p (mod p)` together with
`fib (p+1) ≡ ...`, after which `apparition_count` immediately upgrades this single
divisibility into the statement that a `Θ(N/p)` fraction of indices `≤ N` are
apparitions of `p`.

Why now? `apparition_count` turns any apparition-index bound into a density
statement for free, so proving the rank bound `entry p ≤ p + 1` instantly yields a
quantitative "every prime appears with density `≥ 1/(p+1)`" theorem — exactly the
capacity viewpoint this cycle introduced.

## Direction 3 — Close the Carmichael composite tail via rank growth

`Catalog/Shared/CarmichaelProof.lean` proves the primitive-divisor theorem for
composite `13 ≤ n ≤ 10000` by `native_decide` but leaves the tail `n > 10000` as a
`sorry`. **Conjecture:** the tail follows from a *rank-injectivity* statement —
for composite `n`, the primitive part `primPart n` exceeds `1` because the ranks
`entry (fib d)` for proper divisors `d ∣ n` cannot jointly exhaust the prime factors
of `fib n` once `fib n` outgrows `∏_{d ∣ n, d < n} fib d`.

The key insight is that a prime `p` is primitive for `F_n` iff `entry p = n`
(catalog `primitive_iff_entry_eq`), so the existence of a primitive divisor is
equivalent to `entry` *hitting* `n`; combined with `entry_dvd_of_dvd` and the
Carmichael–Zsygmondy size estimate `fib n > ∏_{d∣n, d<n} fib d` for large `n`, the
counting becomes a pigeonhole on apparition indices.

Why now? This cycle established `entry` as a structured (monotone, lcm-respecting)
function with an exact counting law; that is precisely the toolkit needed to replace
the brute-force `native_decide` window with a uniform argument for the infinite tail.

## Direction 4 — Capacity theory for general Lucas / strong divisibility sequences

**Conjecture:** every *strong divisibility sequence* `u` (i.e. `gcd(u_m,u_n) =
u_{gcd(m,n)}`) with `u` eventually strictly increasing admits a rank function
`entryU` satisfying the same package proved here: `u_m ∣ u_n ↔ entryU m ∣ n`,
`entryU` is an lcm-homomorphism, and `#{n ∈ (0,N] : m ∣ u_n} = N / entryU m`. The
Fibonacci file is the prototype; the claim is that *nothing was special about
Fibonacci* beyond the gcd identity plus monotonicity.

The key insight is that all four theorems used only two inputs — the gcd identity
(for the apparition law) and strict monotonicity (for rank well-definedness via
`Nat.find`) — so abstracting to a typeclass `StrongDivSeq` should reproduce them
verbatim, with Lucas sequences `U_n(P,Q)` and Mersenne-type sequences as instances.

Why now? The proofs in this cycle are short and structural rather than
Fibonacci-arithmetic-specific, which is exactly the signal that the right move is to
generalize the carrier and harvest many sequences (Pell, Lucas, repunits) at once.

## Direction 5 — Sharp lower bounds and a packing "Pisano" refinement

`apparition_density_bound` gives the uniform upper bound `density ≤ 1/3`. **Conjecture
(two-sided):** for every `m ≥ 1` the apparition density of `m` is *exactly*
`1 / entry m`, and moreover `entry m` divides the Pisano period `π(m)` with quotient
in `{1, 2, 4}`; consequently `density(m) ∈ {1, 2, 4} / π(m)`. Falsifiable: a modulus
with `π(m) / entry m ∉ {1,2,4}` refutes the quotient claim.

The key insight is that `apparition_count = N / entry m` is the *exact* count, not
just a bound, so dividing by `N` and taking `N → ∞` makes the density literally
`1/entry m`; tying `entry m` to the Pisano period `π(m)` then converts the capacity
statement into a statement about the order of the Fibonacci shift matrix in
`SL₂(ℤ/m)`.

Why now? With the exact count `N / entry m` in hand, the asymptotic density is a
one-line limit, so the only remaining content is the arithmetic of `entry m` versus
`π(m)` — a self-contained, highly testable number-theoretic target.

**Concept description**: # Future Directions — Stereographic Capacity Theory for Fibonacci Apparitions

## Synthesis

This cycle built a *capacity / packing* layer on top of the catalog's Fibonacci
divisibility lattice (`Cryptography.FibonacciDivisibilityLattice`, the
`Fib_gcd_identity` lineage). The pivot was reading the apparition law
`m ∣ fib n ↔ entry m ∣ n` not as a divisibility fact but as a statement that *the
apparition index set is a set of multiples*, and therefore admits exact counting.

The new file `Catalog/Computation/FibonacciApparitionCapacity.lean` proves four
results, all `sorry`-free and depending only on `propext`, `Classical.choice`,
`Quot.sound`:

1. **`entry_dvd_of_dvd`** — the rank of apparition is monotone for divisibility:
   `a ∣ b → entry a ∣ entry b`.
2. **`entry_lcm`** — `entry` is an lcm-homomorphism:
   `entry (lcm a b) = lcm (entry a) (entry b)`.
3. **`apparition_count`** — exact capacity: `#{n ∈ (0,N] : m ∣ fib n} = N / entry m`.
4. **`apparition_density_bound`** — uniform packing density: for `m ≥ 2`,
   `3 · #{apparitions ≤ N} ≤ N`, with `1/3` sharp (witnessed by `m = 2`,
   `entry 2 = 3`).

This is a Cryptography → Computation bridge: a Lucas/rank-of-apparition structure
became an exact counting/packing theorem.

## Results summary

| Result | Statement | Status |
|---|---|---|
| `entry_dvd_of_dvd` | `a ∣ b → entry a ∣ entry b` | proved |
| `entry_lcm` | `entry (lcm a b) = lcm (entry a) (entry b)` | proved |
| `apparition_count` | `#{n ∈ (0,N] : m ∣ fib n} = N / entry m` | proved |
| `apparition_density_bound` | `m ≥ 2 → 3 · #{apparitions ≤ N} ≤ N` | proved |

---

## Direction 1 — `entry` is **not** a gcd-homomorphism (refute the dual)

The lcm-homomorphism `entry (lcm a b) = lcm (entry a) (entry b)` begs the dual
question: is `entry (gcd a b) = gcd (entry a) (entry b)`? **Conjecture: this is
false, and the witness `a = 4, b = 6` refutes it.** Here `entry 4 = 6`,
`entry 6 = 12`, `gcd(4,6) = 2`, so the left side is `entry 2 = 3`, while the right
side is `gcd(6,12) = 6 ≠ 3`. The falsifiable task is to formalize this
counterexample and then characterize *exactly* the pairs `(a,b)` for which the gcd
identity does hold (the data suggests: precisely when `entry a` and `entry b` are
already "aligned", e.g. one rank divides the other).

The key insight is that `lcm` is the join in the apparition lattice and is preserved
because `lcm a b ∣ fib n ↔ a ∣ fib n ∧ b ∣ fib n` decomposes a single apparition set
into an intersection, whereas `gcd` is the meet and corresponds to a *union* of
apparition sets, which is not itself a set of multiples — so no rank can represent
it in general.

Why now? `entry_lcm` is already proved, so the homomorphism machinery is in place;
the meet/join asymmetry is the immediate stress-test and a clean adversarial result
(a proved non-theorem with an explicit witness) that sharpens the structure.

## Direction 2 — Law of apparition modulo a prime

**Conjecture (Lucas's law of apparition):** for every prime `p ≠ 5`,
`entry p ∣ p - legendreSym 5 p`, i.e. `entry p ∣ p - 1` when `5` is a quadratic
residue mod `p` (`p ≡ ±1 mod 5`) and `entry p ∣ p + 1` otherwise
(`p ≡ ±2 mod 5`). Falsifiable: a single prime violating the claimed divisor would
sink it; verifying it for all primes below a bound is a concrete first milestone.

The key insight is that `fib (p - legendreSym 5 p) ≡ 0 (mod p)` follows from the
Binet/`ZMod` identity `fib p ≡ legendreSym 5 p (mod p)` together with
`fib (p+1) ≡ ...`, after which `apparition_count` immediately upgrades this single
divisibility into the statement that a `Θ(N/p)` fraction of indices `≤ N` are
apparitions of `p`.

Why now? `apparition_count` turns any apparition-index bound into a density
statement for free, so proving the rank bound `entry p ≤ p + 1` instantly yields a
quantitative "every prime appears with density `≥ 1/(p+1)`" theorem — exactly the
capacity viewpoint this cycle introduced.

## Direction 3 — Close the Carmichael composite tail via rank growth

`Catalog/Shared/CarmichaelProof.lean` proves the primitive-divisor theorem for
composite `13 ≤ n ≤ 10000` by `native_decide` but leaves the tail `n > 10000` as a
`sorry`. **Conjecture:** the tail follows from a *rank-injectivity* statement —
for composite `n`, the primitive part `primPart n` exceeds `1` because the ranks
`entry (fib d)` for proper divisors `d ∣ n` cannot jointly exhaust the prime factors
of `fib n` once `fib n` outgrows `∏_{d ∣ n, d < n} fib d`.

The key insight is that a prime `p` is primitive for `F_n` iff `entry p = n`
(catalog `primitive_iff_entry_eq`), so the existence of a primitive divisor is
equivalent to `entry` *hitting* `n`; combined with `entry_dvd_of_dvd` and the
Carmichael–Zsygmondy size estimate `fib n > ∏_{d∣n, d<n} fib d` for large `n`, the
counting becomes a pigeonhole on apparition indices.

Why now? This cycle established `entry` as a structured (monotone, lcm-respecting)
function with an exact counting law; that is precisely the toolkit needed to replace
the brute-force `native_decide` window with a uniform argument for the infinite tail.

## Direction 4 — Capacity theory for general Lucas / strong divisibility sequences

**Conjecture:** every *strong divisibility sequence* `u` (i.e. `gcd(u_m,u_n) =
u_{gcd(m,n)}`) with `u` eventually strictly increasing admits a rank function
`entryU` satisfying the same package proved here: `u_m ∣ u_n ↔ entryU m ∣ n`,
`entryU` is an lcm-homomorphism, and `#{n ∈ (0,N] : m ∣ u_n} = N / entryU m`. The
Fibonacci file is the prototype; the claim is that *nothing was special about
Fibonacci* beyond the gcd identity plus monotonicity.

The key insight is that all four theorems used only two inputs — the gcd identity
(for the apparition law) and strict monotonicity (for rank well-definedness via
`Nat.find`) — so abstracting to a typeclass `StrongDivSeq` should reproduce them
verbatim, with Lucas sequences `U_n(P,Q)` and Mersenne-type sequences as instances.

Why now? The proofs in this cycle are short and structural rather than
Fibonacci-arithmetic-specific, which is exactly the signal that the right move is to
generalize the carrier and harvest many sequences (Pell, Lucas, repunits) at once.

## Direction 5 — Sharp lower bounds and a packing "Pisano" refinement

`apparition_density_bound` gives the uniform upper bound `density ≤ 1/3`. **Conjecture
(two-sided):** for every `m ≥ 1` the apparition density of `m` is *exactly*
`1 / entry m`, and moreover `entry m` divides the Pisano period `π(m)` with quotient
in `{1, 2, 4}`; consequently `density(m) ∈ {1, 2, 4} / π(m)`. Falsifiable: a modulus
with `π(m) / entry m ∉ {1,2,4}` refutes the quotient claim.

The key insight is that `apparition_count = N / entry m` is the *exact* count, not
just a bound, so dividing by `N` and taking `N → ∞` makes the density literally
`1/entry m`; tying `entry m` to the Pisano period `π(m)` then converts the capacity
statement into a statement about the order of the Fibonacci shift matrix in
`SL₂(ℤ/m)`.

Why now? With the exact count `N / entry m` in hand, the asymptotic density is a
one-line limit, so the only remaining content is the arithmetic of `entry m` versus
`π(m)` — a self-contained, highly testable number-theoretic target.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v12 Depth Requirements -- Speculative Specifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Speculative Specifying (Bold Conjectures)**. Target high-risk, high-reward, grand-challenge level research.

### RESEARCH CORE METHODOLOGY:
1. **Grand Challenges**: Formulate bold, surprising, and non-trivial conjectures that challenge existing intuition. Even if a complete proof cannot be achieved in this cycle, outline precise strategies, obstacles, and partial results.
2. **Deep Speculation**: Explore radical connections that seem distant or impossible at first glance. Frame your theorems as seeds for entirely new fields of study.
3. **Long-Term Roadmap**: Dedicate significant intellectual effort to detailing the proof strategies and testable predictions in your future directions, laying out a clear path for future researchers.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
