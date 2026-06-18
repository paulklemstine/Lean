
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

**Title**: This cycle closed a concrete gap between two halves of the catalog that had only
**Domain**: Applications
**Mathematical framing**: # Future Directions — The Fibonacci Law of Apparition as an Arithmetic-Height / Tropical Duality

## Synthesis

This cycle closed a concrete gap between two halves of the catalog that had only
been linked *abstractly*: the tropical/ultrametric arithmetic-height machinery of
`Bridges/TropicalUltrametricBridge.lean` (the `NonArchNorm` structure and the
`padicHeightNorm`/`padicTropicalValuation` realisation of `p`-adic height as a
tropical valuation), and the strong-divisibility identity `Nat.fib_gcd` that powers
the catalog's Carmichael/Fibonacci work.

The bridge is the **rank of apparition**. In `Bridges/FibonacciApparitionDuality.lean`
we prove, for every modulus `m ≥ 1`, that there is a least positive index
`fibRank m` with `m ∣ fib (fibRank m)` (`fib_apparition_exists`), and the headline
*representation/duality theorem*

```
fib_dvd_iff_rank_dvd :  m ∣ fib n  ↔  fibRank m ∣ n .
```

Divisibility of Fibonacci **values** is translated, with no loss, into divisibility
of **indices** — the index-side dual of `fib (gcd m n) = gcd (fib m) (fib n)`. Two
consequences make the duality quantitative: the divisibility predicate is a
**min-plus (lattice) homomorphism** (`fib_dvd_gcd_iff`, sending the index `gcd` — a
tropical `min` — to logical conjunction), and the catalog's `p`-adic arithmetic
height of `fib n` drops below `1` *exactly* on the rank sublattice
(`fibHeight_lt_one_iff` / `padicNorm_fib_lt_one_iff`). In one sentence: the
non-archimedean size of a Fibonacci number is governed precisely by the
combinatorial object `fibRank p`.

The pleasant surprise is how little is needed. Existence of the rank reduces to the
single fact that the affine shift `T(a,b) = (b, a+b)` is a *bijection* of the finite
set `ZMod m × ZMod m`; a finite bijection has purely periodic orbits, so the orbit
of `(0,1)` returns to `(0,1)`. No Binet formula, no analysis — only injectivity,
packaged as `add_right_cancel`.

## Results summary

All statements below are proven `sorry`-free, depending only on
`propext`, `Classical.choice`, `Quot.sound`.

* `FibApparition.fib_apparition_exists` — every `m ≥ 1` divides some positive `fib k`
  (pure periodicity of the Fibonacci state pair mod `m`).
* `FibApparition.fib_dvd_iff_rank_dvd` — **the law of apparition** (value/index duality).
* `FibApparition.fib_dvd_gcd_iff` — divisibility is a `gcd → ∧` (min-plus) homomorphism.
* `FibApparition.padicNorm_fib_lt_one_iff` — Mathlib-native height capstone.
* `FibApparition.fibHeight_lt_one_iff` — catalog capstone: `TropUltra.padicHeightNorm`
  of `fib n` is `< 1` iff `fibRank p ∣ n`.

## Research directions

### 1. Primitivity is rank equality — and it re-frames the open Carmichael tail.

The catalog's `Shared/CarmichaelProof.lean` still leaves the *infinite tail*
(composite `n > 10000`) of the Fibonacci primitive-divisor theorem open. The
apparition theorem turns the very definition of "primitive divisor" into a clean
statement about the rank: a prime `p` is a primitive prime divisor of `fib n`
(it divides `fib n` but no earlier `fib k`) **iff** `fibRank p = n`. Conjecture:
`fib_dvd_iff_rank_dvd` makes this a one-line corollary, after which Carmichael's
theorem becomes the single arithmetic claim "for every composite `n > 12` there
exists a prime with `fibRank p = n`." The key insight is that primitivity is not an
analytic property of magnitudes but the *equality case* of the apparition duality,
so the whole problem collapses onto the surjectivity of `fibRank` onto
`{n : n > 12}`. Why now? We have just isolated `fibRank` and proven the iff that the
catalog's bridge-lemma was implicitly using; rebuilding the Carmichael file on top
of `fibRank` (and replacing its missing `Shared.CarmichaelHelper` import) is the
natural, falsifiable next step — small `n` are checkable by `decide`/`native_decide`,
so any wrong reformulation is caught immediately.

### 2. The rank is an arithmetic function with a CRT/lcm law.

Conjecture: for coprime moduli `a` and `b`, `fibRank (a * b) = Nat.lcm (fibRank a)
(fibRank b)`, and more generally `m ∣ fib n ↔ ∀ prime powers q ‖ m, fibRank q ∣ n`.
The key insight is that the value-side Chinese Remainder Theorem is *dual* to an
index-side `lcm`: conjunction over prime-power components on the value side becomes a
single `lcm` divisibility on the index side, exactly because `fib_dvd_iff_rank_dvd`
linearises each component. Why now? `fib_dvd_gcd_iff` already exhibits `fibRank` as a
lattice homomorphism for `gcd`/`∧`; the multiplicative (lcm) law is the dual lattice
operation and is fully falsifiable by enumerating `fibRank` on small composite `m`.

### 3. The Pisano/companion-matrix bound `fibRank p ∣ p − (5 | p)`.

Our `fibState` is literally the forward orbit of the Fibonacci **companion matrix**
`[[0,1],[1,1]]` acting on `(F_p)²`. Conjecture: for an odd prime `p ≠ 5`, `fibRank p`
divides `p − legendreSym 5 p`, hence `fibRank p ≤ p + 1`; equivalently the order of
the companion matrix in `GL₂(F_p)` controls the rank. The key insight is that the
rank of apparition equals the multiplicative order of the companion matrix's
eigenvalue (the golden ratio) in the field `F_p` (or `F_{p²}`), so the classical
order-divides-group-size bound applies. Why now? The bijection `T` we already use
*is* that matrix; promoting `fibState` from a raw function to a `Matrix`/`ZMod`
power gives the order interpretation directly, and the resulting bound is sharply
falsifiable (it fails instantly for any miscomputed Legendre symbol).

### 4. Exact tropical valuation of Fibonacci numbers (lifting-the-exponent).

`fibHeight_lt_one_iff` is a *threshold* result; its quantitative refinement should be
an exact valuation formula. Conjecture: for an odd prime `p` and `fibRank p ∣ n`,
`padicValNat p (fib n) = padicValNat p (fib (fibRank p)) + padicValNat p
(n / fibRank p)`, so the `p`-adic arithmetic height of `fib n` is an *exact tropical
(min-plus) valuation* that is affine in `padicValNat p n` along the rank filtration.
The key insight is that the height is not merely `< 1` on multiples of the rank but
descends by a controlled, additive amount each time another factor of `p` enters the
index — a Fibonacci lifting-the-exponent law. Why now? Having pinned the *support* of
the height to the rank sublattice, the only remaining unknown is the *slope*, and the
formula is directly testable: compute `padicValNat p (fib n)` for a grid of `(p, n)`
and check affinity.

### 5. Abstract the whole theory to strong divisibility sequences.

The proof of `fib_dvd_iff_rank_dvd` used *only* `Nat.fib_gcd`, `Nat.fib_dvd`, and
positivity of `fib` on positive indices. Conjecture: the identical theorem holds for
any **strong divisibility sequence** `a : ℕ → ℕ` (one with `gcd (a m) (a n) =
a (gcd m n)` and `a n ≠ 0 ↔ n ≠ 0`), e.g. `a n = q^n − 1`, Lucas sequences, and
elliptic divisibility sequences. The key insight is that apparition is a *purely
order-theoretic* phenomenon of strong divisibility, with the Fibonacci specifics
entering only through existence of the rank (which itself follows from any eventual
periodicity mod `m`). Why now? A `class StrongDivSeq` carrying these two axioms would
let the catalog reuse `fibRank`, `*_dvd_iff_rank_dvd`, and the height capstone across
all of its `q`-analogue and Lucas-sequence files at once — a single abstraction
collapsing several would-be duplicate bridges. It is falsifiable by exhibiting any
strong divisibility sequence where the rank fails to control divisibility.

**Concept description**: # Future Directions — The Fibonacci Law of Apparition as an Arithmetic-Height / Tropical Duality

## Synthesis

This cycle closed a concrete gap between two halves of the catalog that had only
been linked *abstractly*: the tropical/ultrametric arithmetic-height machinery of
`Bridges/TropicalUltrametricBridge.lean` (the `NonArchNorm` structure and the
`padicHeightNorm`/`padicTropicalValuation` realisation of `p`-adic height as a
tropical valuation), and the strong-divisibility identity `Nat.fib_gcd` that powers
the catalog's Carmichael/Fibonacci work.

The bridge is the **rank of apparition**. In `Bridges/FibonacciApparitionDuality.lean`
we prove, for every modulus `m ≥ 1`, that there is a least positive index
`fibRank m` with `m ∣ fib (fibRank m)` (`fib_apparition_exists`), and the headline
*representation/duality theorem*

```
fib_dvd_iff_rank_dvd :  m ∣ fib n  ↔  fibRank m ∣ n .
```

Divisibility of Fibonacci **values** is translated, with no loss, into divisibility
of **indices** — the index-side dual of `fib (gcd m n) = gcd (fib m) (fib n)`. Two
consequences make the duality quantitative: the divisibility predicate is a
**min-plus (lattice) homomorphism** (`fib_dvd_gcd_iff`, sending the index `gcd` — a
tropical `min` — to logical conjunction), and the catalog's `p`-adic arithmetic
height of `fib n` drops below `1` *exactly* on the rank sublattice
(`fibHeight_lt_one_iff` / `padicNorm_fib_lt_one_iff`). In one sentence: the
non-archimedean size of a Fibonacci number is governed precisely by the
combinatorial object `fibRank p`.

The pleasant surprise is how little is needed. Existence of the rank reduces to the
single fact that the affine shift `T(a,b) = (b, a+b)` is a *bijection* of the finite
set `ZMod m × ZMod m`; a finite bijection has purely periodic orbits, so the orbit
of `(0,1)` returns to `(0,1)`. No Binet formula, no analysis — only injectivity,
packaged as `add_right_cancel`.

## Results summary

All statements below are proven `sorry`-free, depending only on
`propext`, `Classical.choice`, `Quot.sound`.

* `FibApparition.fib_apparition_exists` — every `m ≥ 1` divides some positive `fib k`
  (pure periodicity of the Fibonacci state pair mod `m`).
* `FibApparition.fib_dvd_iff_rank_dvd` — **the law of apparition** (value/index duality).
* `FibApparition.fib_dvd_gcd_iff` — divisibility is a `gcd → ∧` (min-plus) homomorphism.
* `FibApparition.padicNorm_fib_lt_one_iff` — Mathlib-native height capstone.
* `FibApparition.fibHeight_lt_one_iff` — catalog capstone: `TropUltra.padicHeightNorm`
  of `fib n` is `< 1` iff `fibRank p ∣ n`.

## Research directions

### 1. Primitivity is rank equality — and it re-frames the open Carmichael tail.

The catalog's `Shared/CarmichaelProof.lean` still leaves the *infinite tail*
(composite `n > 10000`) of the Fibonacci primitive-divisor theorem open. The
apparition theorem turns the very definition of "primitive divisor" into a clean
statement about the rank: a prime `p` is a primitive prime divisor of `fib n`
(it divides `fib n` but no earlier `fib k`) **iff** `fibRank p = n`. Conjecture:
`fib_dvd_iff_rank_dvd` makes this a one-line corollary, after which Carmichael's
theorem becomes the single arithmetic claim "for every composite `n > 12` there
exists a prime with `fibRank p = n`." The key insight is that primitivity is not an
analytic property of magnitudes but the *equality case* of the apparition duality,
so the whole problem collapses onto the surjectivity of `fibRank` onto
`{n : n > 12}`. Why now? We have just isolated `fibRank` and proven the iff that the
catalog's bridge-lemma was implicitly using; rebuilding the Carmichael file on top
of `fibRank` (and replacing its missing `Shared.CarmichaelHelper` import) is the
natural, falsifiable next step — small `n` are checkable by `decide`/`native_decide`,
so any wrong reformulation is caught immediately.

### 2. The rank is an arithmetic function with a CRT/lcm law.

Conjecture: for coprime moduli `a` and `b`, `fibRank (a * b) = Nat.lcm (fibRank a)
(fibRank b)`, and more generally `m ∣ fib n ↔ ∀ prime powers q ‖ m, fibRank q ∣ n`.
The key insight is that the value-side Chinese Remainder Theorem is *dual* to an
index-side `lcm`: conjunction over prime-power components on the value side becomes a
single `lcm` divisibility on the index side, exactly because `fib_dvd_iff_rank_dvd`
linearises each component. Why now? `fib_dvd_gcd_iff` already exhibits `fibRank` as a
lattice homomorphism for `gcd`/`∧`; the multiplicative (lcm) law is the dual lattice
operation and is fully falsifiable by enumerating `fibRank` on small composite `m`.

### 3. The Pisano/companion-matrix bound `fibRank p ∣ p − (5 | p)`.

Our `fibState` is literally the forward orbit of the Fibonacci **companion matrix**
`[[0,1],[1,1]]` acting on `(F_p)²`. Conjecture: for an odd prime `p ≠ 5`, `fibRank p`
divides `p − legendreSym 5 p`, hence `fibRank p ≤ p + 1`; equivalently the order of
the companion matrix in `GL₂(F_p)` controls the rank. The key insight is that the
rank of apparition equals the multiplicative order of the companion matrix's
eigenvalue (the golden ratio) in the field `F_p` (or `F_{p²}`), so the classical
order-divides-group-size bound applies. Why now? The bijection `T` we already use
*is* that matrix; promoting `fibState` from a raw function to a `Matrix`/`ZMod`
power gives the order interpretation directly, and the resulting bound is sharply
falsifiable (it fails instantly for any miscomputed Legendre symbol).

### 4. Exact tropical valuation of Fibonacci numbers (lifting-the-exponent).

`fibHeight_lt_one_iff` is a *threshold* result; its quantitative refinement should be
an exact valuation formula. Conjecture: for an odd prime `p` and `fibRank p ∣ n`,
`padicValNat p (fib n) = padicValNat p (fib (fibRank p)) + padicValNat p
(n / fibRank p)`, so the `p`-adic arithmetic height of `fib n` is an *exact tropical
(min-plus) valuation* that is affine in `padicValNat p n` along the rank filtration.
The key insight is that the height is not merely `< 1` on multiples of the rank but
descends by a controlled, additive amount each time another factor of `p` enters the
index — a Fibonacci lifting-the-exponent law. Why now? Having pinned the *support* of
the height to the rank sublattice, the only remaining unknown is the *slope*, and the
formula is directly testable: compute `padicValNat p (fib n)` for a grid of `(p, n)`
and check affinity.

### 5. Abstract the whole theory to strong divisibility sequences.

The proof of `fib_dvd_iff_rank_dvd` used *only* `Nat.fib_gcd`, `Nat.fib_dvd`, and
positivity of `fib` on positive indices. Conjecture: the identical theorem holds for
any **strong divisibility sequence** `a : ℕ → ℕ` (one with `gcd (a m) (a n) =
a (gcd m n)` and `a n ≠ 0 ↔ n ≠ 0`), e.g. `a n = q^n − 1`, Lucas sequences, and
elliptic divisibility sequences. The key insight is that apparition is a *purely
order-theoretic* phenomenon of strong divisibility, with the Fibonacci specifics
entering only through existence of the rank (which itself follows from any eventual
periodicity mod `m`). Why now? A `class StrongDivSeq` carrying these two axioms would
let the catalog reuse `fibRank`, `*_dvd_iff_rank_dvd`, and the height capstone across
all of its `q`-analogue and Lucas-sequence files at once — a single abstraction
collapsing several would-be duplicate bridges. It is falsifiable by exhibiting any
strong divisibility sequence where the rank fails to control divisibility.

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
