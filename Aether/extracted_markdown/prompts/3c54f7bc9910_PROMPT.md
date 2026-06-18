
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

**Title**: This cycle mapped the *provability boundary* of Beal's Conjecture
**Domain**: Novelty
**Mathematical framing**: # Beal's Conjecture — Future Directions

## Synthesis

This cycle mapped the *provability boundary* of Beal's Conjecture
(`A^x + B^y = C^z`, `x,y,z > 2` ⟹ `gcd(A,B,C) > 1`) and dispatched every fragment
that lies inside it. Two structural mechanisms turned out to be decisive. First,
**shared structure in the bases**: when the two summand bases coincide (`A = B`),
the common base is forced into `C` and Beal holds non-vacuously
(`beal_equal_bases`, realized by `2^3 + 2^3 = 2^4`). This complements the catalog's
primitive reduction (`PrimitiveReduction.coprime_*_of_no_common_prime`), which
already disposes of the case where two bases share a prime. Second, **shared
structure in the exponents**: on the diagonal `x = y = z = n` the Beal equation is
literally the Fermat equation, so wherever Fermat's Last Theorem is known the
diagonal Beal case holds *vacuously*. We converted Mathlib's
`fermatLastTheoremThree` and `fermatLastTheoremFour` — and, through
`FermatLastTheoremFor.mono`, all multiples of 3 and 4 — into clean Beal theorems
(`beal_of_flt`, `beal_diagonal_{three,four,six,eight}`).

What failed, instructively, is the residue-obstruction route. The catalog's
`PrimitiveResidueSolution` records *unit* solutions in `ZMod N` and descends
across divisors (`Monotonicity`). We hoped to bridge "no unit solution mod `N`"
to "no coprime integer solution", but a pairwise-coprime integer solution does
*not* reduce to a unit solution modulo an arbitrary `N`: if a prime of `N`
divides one base, that base is a non-unit residue. So a single modular obstruction
cannot settle a mixed-exponent case — precisely why Beal is open there.

The emergent picture is a sharp trichotomy. Solutions split into (i) non-primitive
(handled by primitive reduction), (ii) primitive with equal exponents (handled by
FLT on the diagonal), and (iii) primitive with genuinely mixed exponents — the
open core, whose smallest entry is `(3,4,5)` (`beal_mixed_345`, left as a
conjecture). The computational fragment (`beal_verified_box`) gives kernel-checked
evidence inside an explicit finite box and exposes the scaling wall that the next
cycle should attack.

## Results Summary

- `beal_equal_bases`: **proved** — Beal holds non-vacuously whenever the two
  summand bases coincide (`A = B`), the only subtlety being the `A = 1` size bound.
- `beal_of_flt`: **proved** — generic bridge turning any known `FermatLastTheoremFor n`
  into the diagonal Beal case `A^n + B^n = C^n`.
- `beal_diagonal_three`: **proved** — Beal for `(3,3,3)` from `fermatLastTheoremThree`.
- `beal_diagonal_four`: **proved** — Beal for `(4,4,4)` from `fermatLastTheoremFour`.
- `beal_diagonal_six`: **proved** — Beal for `(6,6,6)` via `FermatLastTheoremFor.mono`.
- `beal_diagonal_eight`: **proved** — Beal for `(8,8,8)` via `FermatLastTheoremFor.mono`.
- `beal_verified_box`: **proved** (verified finite search) — every solution with
  bases in `[1,20]` and exponents in `[3,5]` has `gcd > 1`.
- `bealConjecture_diagonal`: **proved** — the diagonal fragment phrased against the
  catalog `BealConjecture` predicate.
- `beal_mixed_345`: **conjecture** — the smallest mixed-exponent triple `(3,4,5)`,
  the boundary of current techniques.
- `Speculative.Beal.Defs` (`BealConjecture`, `PrimitiveResidueSolution`):
  **infrastructure** — supplied the previously-missing shared definitions, repairing
  the build of the existing `PrimitiveReduction` and `Monotonicity` catalog files.

## Research Directions

### Direction 1: Push the computational box toward base 1000
**Hypothesis**: Beal holds for all `A,B,C ≤ 1000` and `3 ≤ x,y,z ≤ 5`, i.e. every
solution in that box has `gcd(A,B,C) > 1`.
**Test**: Replace the `native_decide` brute force in `beal_verified_box` with a
pruned search — fix `(x,y,z)`, enumerate `C^z`, and binary-search `A^x` complements
— then certify the result, scaling the bounds from 20 toward 1000.
**Why now**: `beal_verified_box` already proves the statement is decidable and true
on a small box; the only obstacle is the `O(N^3 · 27)` cost with `N^5`-sized values,
which a complement-search collapses to near `O(N^2)`.
**If true**: A reusable, kernel-checked "Beal up to N" certificate that future
cycles can cite as a base case for descent arguments.
**If false**: A counterexample would refute Beal outright — the highest-value
possible outcome. (None is expected below 1000.)
The key insight is that the search is *complement-bounded*: for fixed exponents,
each `C^z` admits at most one matching `A^x + B^y`, so the cube of candidates is
really a near-quadratic lookup.

### Direction 2: A descent attack on the boundary case `(3,4,5)`
**Hypothesis**: `A^3 + B^4 = C^5` with `gcd(A,B,C) = 1` has no solution
(`beal_mixed_345`).
**Test**: Following Darmon–Granville, treat `(3,4,5)` as a hyperbolic signature
(`1/3 + 1/4 + 1/5 < 1`) and reduce to finitely many twists of a fixed curve, then
attempt a modular/Chabauty argument; as a first Lean step, formalize the genus
computation that bounds the number of primitive solutions.
**Why now**: The `beal_of_flt` pattern shows how to ingest a deep number-theory
input as a Beal case; `(3,4,5)` is the unique smallest open triple isolated by this
cycle's trichotomy.
**If true**: The first *primitive mixed-exponent* Beal case in the catalog, opening
a template for `(3,4,5)`-type signatures.
**If false**: A primitive counterexample, which would itself disprove Beal.
The key insight is that hyperbolic signatures `(p,q,r)` make the solution set a
finite, curve-theoretic object rather than an unbounded Diophantine search.

### Direction 3: Strengthen the equal-base case to "shared base ⟹ shared factor"
**Hypothesis**: If `A^x + B^y = C^z` and `gcd(A,B) > 1`, then `gcd(A,B,C) > 1` for
all positive exponents (not only `x,y,z > 2`).
**Test**: Generalize `beal_equal_bases` by replacing `A = B` with `gcd(A,B) = d > 1`,
extracting a prime `p ∣ d`, and pushing it through the sum as in
`PrimitiveReduction.prime_dvd_pair_implies_dvd_third`.
**Why now**: `beal_equal_bases` is the `d = A = B` instance, and the catalog already
proves the prime-divides-third step; merging them removes the equal-base
restriction entirely.
**If true**: Collapses the entire non-primitive case of Beal to a one-line corollary
and subsumes both this cycle's equal-base result and the catalog reduction.
**If false**: Would reveal an exponent-sensitive obstruction in the divisibility
step, contradicting the catalog lemma — so failure would expose a bug.
The key insight is that `beal_equal_bases` never used `A = B` beyond extracting a
single shared prime, so the hypothesis can be weakened to `gcd(A,B) > 1` verbatim.

### Direction 4: Make the modular obstruction faithful to coprime solutions
**Hypothesis**: There is a modulus invariant — not `PrimitiveResidueSolution` but a
"`≤ one non-unit base`" residue predicate — whose absence mod some `N` does rule out
primitive integer solutions for a fixed exponent triple.
**Test**: Define `WeakResidueSolution N x y z` allowing at most one of `a,b,c` to be
a non-unit (mirroring pairwise coprimality), reprove the `Monotonicity` descent for
it, and search for an obstructing `N` for a chosen exponent triple.
**Why now**: This cycle pinpointed exactly why the unit-based obstruction fails to
bridge to Beal; the fix is a precisely identified weakening of the unit condition.
**If true**: Revives modular obstructions as a genuine Beal tool and could settle
several mixed-exponent triples by a finite mod-`N` check.
**If false**: Confirms that no congruence obstruction suffices, sharpening the case
that Beal's mixed core is irreducibly "global" (modular/curve-theoretic).
The key insight is that pairwise coprimality permits *one* non-unit residue per
modulus, so the obstruction object must mirror that asymmetry rather than demand
three units.

### Direction 5: Diagonal Beal for every exponent via a packaged FLT interface
**Hypothesis**: `∀ n ≥ 3, FermatLastTheoremFor n`, and hence diagonal Beal holds for
*all* `n ≥ 3` through `beal_of_flt`.
**Test**: Track the Mathlib formalization of FLT; as soon as `FermatLastTheoremFor n`
becomes available for general `n` (or for new specific `n`), instantiate
`beal_of_flt`/`bealConjecture_diagonal` to extend the diagonal coverage with zero
extra proof.
**Why now**: `beal_of_flt` is already a clean adapter; the diagonal coverage is now
exactly as wide as Mathlib's FLT, so progress is *free* on every FLT advance.
**If true**: Diagonal Beal becomes a permanent corollary of FLT, leaving only the
mixed-exponent core open.
**If false**: Impossible for `n ≥ 3` (FLT is a theorem); the only risk is that
Mathlib lacks the statement, which is a library gap, not a mathematical one.
The key insight is decoupling: `beal_of_flt` isolates the *only* number-theoretic
input the diagonal needs, so the Beal diagonal automatically tracks FLT forever.

**Concept description**: # Beal's Conjecture — Future Directions

## Synthesis

This cycle mapped the *provability boundary* of Beal's Conjecture
(`A^x + B^y = C^z`, `x,y,z > 2` ⟹ `gcd(A,B,C) > 1`) and dispatched every fragment
that lies inside it. Two structural mechanisms turned out to be decisive. First,
**shared structure in the bases**: when the two summand bases coincide (`A = B`),
the common base is forced into `C` and Beal holds non-vacuously
(`beal_equal_bases`, realized by `2^3 + 2^3 = 2^4`). This complements the catalog's
primitive reduction (`PrimitiveReduction.coprime_*_of_no_common_prime`), which
already disposes of the case where two bases share a prime. Second, **shared
structure in the exponents**: on the diagonal `x = y = z = n` the Beal equation is
literally the Fermat equation, so wherever Fermat's Last Theorem is known the
diagonal Beal case holds *vacuously*. We converted Mathlib's
`fermatLastTheoremThree` and `fermatLastTheoremFour` — and, through
`FermatLastTheoremFor.mono`, all multiples of 3 and 4 — into clean Beal theorems
(`beal_of_flt`, `beal_diagonal_{three,four,six,eight}`).

What failed, instructively, is the residue-obstruction route. The catalog's
`PrimitiveResidueSolution` records *unit* solutions in `ZMod N` and descends
across divisors (`Monotonicity`). We hoped to bridge "no unit solution mod `N`"
to "no coprime integer solution", but a pairwise-coprime integer solution does
*not* reduce to a unit solution modulo an arbitrary `N`: if a prime of `N`
divides one base, that base is a non-unit residue. So a single modular obstruction
cannot settle a mixed-exponent case — precisely why Beal is open there.

The emergent picture is a sharp trichotomy. Solutions split into (i) non-primitive
(handled by primitive reduction), (ii) primitive with equal exponents (handled by
FLT on the diagonal), and (iii) primitive with genuinely mixed exponents — the
open core, whose smallest entry is `(3,4,5)` (`beal_mixed_345`, left as a
conjecture). The computational fragment (`beal_verified_box`) gives kernel-checked
evidence inside an explicit finite box and exposes the scaling wall that the next
cycle should attack.

## Results Summary

- `beal_equal_bases`: **proved** — Beal holds non-vacuously whenever the two
  summand bases coincide (`A = B`), the only subtlety being the `A = 1` size bound.
- `beal_of_flt`: **proved** — generic bridge turning any known `FermatLastTheoremFor n`
  into the diagonal Beal case `A^n + B^n = C^n`.
- `beal_diagonal_three`: **proved** — Beal for `(3,3,3)` from `fermatLastTheoremThree`.
- `beal_diagonal_four`: **proved** — Beal for `(4,4,4)` from `fermatLastTheoremFour`.
- `beal_diagonal_six`: **proved** — Beal for `(6,6,6)` via `FermatLastTheoremFor.mono`.
- `beal_diagonal_eight`: **proved** — Beal for `(8,8,8)` via `FermatLastTheoremFor.mono`.
- `beal_verified_box`: **proved** (verified finite search) — every solution with
  bases in `[1,20]` and exponents in `[3,5]` has `gcd > 1`.
- `bealConjecture_diagonal`: **proved** — the diagonal fragment phrased against the
  catalog `BealConjecture` predicate.
- `beal_mixed_345`: **conjecture** — the smallest mixed-exponent triple `(3,4,5)`,
  the boundary of current techniques.
- `Speculative.Beal.Defs` (`BealConjecture`, `PrimitiveResidueSolution`):
  **infrastructure** — supplied the previously-missing shared definitions, repairing
  the build of the existing `PrimitiveReduction` and `Monotonicity` catalog files.

## Research Directions

### Direction 1: Push the computational box toward base 1000
**Hypothesis**: Beal holds for all `A,B,C ≤ 1000` and `3 ≤ x,y,z ≤ 5`, i.e. every
solution in that box has `gcd(A,B,C) > 1`.
**Test**: Replace the `native_decide` brute force in `beal_verified_box` with a
pruned search — fix `(x,y,z)`, enumerate `C^z`, and binary-search `A^x` complements
— then certify the result, scaling the bounds from 20 toward 1000.
**Why now**: `beal_verified_box` already proves the statement is decidable and true
on a small box; the only obstacle is the `O(N^3 · 27)` cost with `N^5`-sized values,
which a complement-search collapses to near `O(N^2)`.
**If true**: A reusable, kernel-checked "Beal up to N" certificate that future
cycles can cite as a base case for descent arguments.
**If false**: A counterexample would refute Beal outright — the highest-value
possible outcome. (None is expected below 1000.)
The key insight is that the search is *complement-bounded*: for fixed exponents,
each `C^z` admits at most one matching `A^x + B^y`, so the cube of candidates is
really a near-quadratic lookup.

### Direction 2: A descent attack on the boundary case `(3,4,5)`
**Hypothesis**: `A^3 + B^4 = C^5` with `gcd(A,B,C) = 1` has no solution
(`beal_mixed_345`).
**Test**: Following Darmon–Granville, treat `(3,4,5)` as a hyperbolic signature
(`1/3 + 1/4 + 1/5 < 1`) and reduce to finitely many twists of a fixed curve, then
attempt a modular/Chabauty argument; as a first Lean step, formalize the genus
computation that bounds the number of primitive solutions.
**Why now**: The `beal_of_flt` pattern shows how to ingest a deep number-theory
input as a Beal case; `(3,4,5)` is the unique smallest open triple isolated by this
cycle's trichotomy.
**If true**: The first *primitive mixed-exponent* Beal case in the catalog, opening
a template for `(3,4,5)`-type signatures.
**If false**: A primitive counterexample, which would itself disprove Beal.
The key insight is that hyperbolic signatures `(p,q,r)` make the solution set a
finite, curve-theoretic object rather than an unbounded Diophantine search.

### Direction 3: Strengthen the equal-base case to "shared base ⟹ shared factor"
**Hypothesis**: If `A^x + B^y = C^z` and `gcd(A,B) > 1`, then `gcd(A,B,C) > 1` for
all positive exponents (not only `x,y,z > 2`).
**Test**: Generalize `beal_equal_bases` by replacing `A = B` with `gcd(A,B) = d > 1`,
extracting a prime `p ∣ d`, and pushing it through the sum as in
`PrimitiveReduction.prime_dvd_pair_implies_dvd_third`.
**Why now**: `beal_equal_bases` is the `d = A = B` instance, and the catalog already
proves the prime-divides-third step; merging them removes the equal-base
restriction entirely.
**If true**: Collapses the entire non-primitive case of Beal to a one-line corollary
and subsumes both this cycle's equal-base result and the catalog reduction.
**If false**: Would reveal an exponent-sensitive obstruction in the divisibility
step, contradicting the catalog lemma — so failure would expose a bug.
The key insight is that `beal_equal_bases` never used `A = B` beyond extracting a
single shared prime, so the hypothesis can be weakened to `gcd(A,B) > 1` verbatim.

### Direction 4: Make the modular obstruction faithful to coprime solutions
**Hypothesis**: There is a modulus invariant — not `PrimitiveResidueSolution` but a
"`≤ one non-unit base`" residue predicate — whose absence mod some `N` does rule out
primitive integer solutions for a fixed exponent triple.
**Test**: Define `WeakResidueSolution N x y z` allowing at most one of `a,b,c` to be
a non-unit (mirroring pairwise coprimality), reprove the `Monotonicity` descent for
it, and search for an obstructing `N` for a chosen exponent triple.
**Why now**: This cycle pinpointed exactly why the unit-based obstruction fails to
bridge to Beal; the fix is a precisely identified weakening of the unit condition.
**If true**: Revives modular obstructions as a genuine Beal tool and could settle
several mixed-exponent triples by a finite mod-`N` check.
**If false**: Confirms that no congruence obstruction suffices, sharpening the case
that Beal's mixed core is irreducibly "global" (modular/curve-theoretic).
The key insight is that pairwise coprimality permits *one* non-unit residue per
modulus, so the obstruction object must mirror that asymmetry rather than demand
three units.

### Direction 5: Diagonal Beal for every exponent via a packaged FLT interface
**Hypothesis**: `∀ n ≥ 3, FermatLastTheoremFor n`, and hence diagonal Beal holds for
*all* `n ≥ 3` through `beal_of_flt`.
**Test**: Track the Mathlib formalization of FLT; as soon as `FermatLastTheoremFor n`
becomes available for general `n` (or for new specific `n`), instantiate
`beal_of_flt`/`bealConjecture_diagonal` to extend the diagonal coverage with zero
extra proof.
**Why now**: `beal_of_flt` is already a clean adapter; the diagonal coverage is now
exactly as wide as Mathlib's FLT, so progress is *free* on every FLT advance.
**If true**: Diagonal Beal becomes a permanent corollary of FLT, leaving only the
mixed-exponent core open.
**If false**: Impossible for `n ≥ 3` (FLT is a theorem); the only risk is that
Mathlib lacks the statement, which is a library gap, not a mathematical one.
The key insight is decoupling: `beal_of_flt` isolates the *only* number-theoretic
input the diagonal needs, so the Beal diagonal automatically tracks FLT forever.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
