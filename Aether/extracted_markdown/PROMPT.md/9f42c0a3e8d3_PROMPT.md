
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

**Title**: This cycle isolated the *mechanism* behind the bridge between finite-description
**Domain**: Applications
**Mathematical framing**: # Future Directions: The Oracle Counting Barrier

## Synthesis

This cycle isolated the *mechanism* behind the bridge between finite-description
complexity and three-valued oracle non-computability, and reduced it to a single,
domain-agnostic cardinal fact. The file `OracleCountingBarrier.lean` proves five
results that together say: the space of three-valued oracles on `N` statements has
size `3^N` (`oracle_card`); any program space strictly smaller than `3^N` fails to
cover it, regardless of how programs are compiled into oracles (`oracle_not_covered`);
a fixed program budget `b^k` is eventually outrun by `3^N` (`budget_gap_exists`);
binary descriptions of length `N` are strictly too poor, `2^N < 3^N`
(`binary_insufficient`); and the computable fraction `C / 3^N → 0`
(`computable_fraction_tendsto_zero`).

The central insight that organizes all of this: the *coverage* obstruction and the
*information* obstruction are logically independent. Coverage (`oracle_not_covered`)
needs nothing about the number "3" — it works for any answer alphabet of size `≥ 2`
and follows purely from `Fintype.card_le_of_surjective`. The number "3" only enters
the *information* story, where it produces the `log₂ 3 ≈ 1.585` bits-per-statement
deficit that `2^N < 3^N` witnesses. Factoring the argument this way is what makes
the proofs one or two lines each and makes the core lemma reusable across domains
(proof search, learning, tropical solution sets) by merely changing the codomain.

The most fertile cross-domain connection is between `oracle_not_covered` and
information theory: the abstract counting lemma is the finite, constructive shadow
of Shannon's source-coding bound, and `binary_insufficient` is its sharpest
finite instance. This suggests "mathematical truth has a positive entropy rate that
no finite binary description can match" can be stated and partially proved entirely
within finite combinatorics, sidestepping the machinery of Kolmogorov complexity.

---

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `oracle_card` | `card (Fin N → Fin 3) = 3^N` | Counts the oracle space |
| `oracle_not_covered` | `card P < 3^N → ∃ O, O ∉ range f` | The reusable counting barrier |
| `budget_gap_exists` | `∀ b k, ∃ N, b^k < 3^N` | Fixed budgets are eventually outrun |
| `binary_insufficient` | `1 ≤ N → 2^N < 3^N` | Information deficit of binary descriptions |
| `computable_fraction_tendsto_zero` | `C / 3^N → 0` | Almost all oracles are uncomputable |

All five compile with `sorry = 0` and depend only on `propext`, `Classical.choice`,
and `Quot.sound`.

---

## Direction 1: A Quantitative Three-vs-Two Entropy Gap

**Conjecture.** Define the per-statement description deficit
`D(N) = log₂(3^N) − log₂(2^N) = N·(log₂ 3 − 1)`. Then for the abstract
counting barrier, the *minimal* binary program length `ℓ(N)` needed merely to
index all `3^N` oracles satisfies `ℓ(N) = ⌈N·log₂ 3⌉`, and the fraction of
oracles reachable by programs of length `≤ N` is exactly `2^N / 3^N = (2/3)^N`.

**The key insight is** that `binary_insufficient` is not an inequality to be
weakened but the first term of an exact geometric law `(2/3)^N`, so the
"information deficit" is a precisely computable rate, not an asymptotic slogan.

**Why now?** We already have `oracle_card`, `binary_insufficient`, and
`computable_fraction_tendsto_zero` in hand; the only new ingredient is replacing
the constant budget `C` by the *binary* budget `2^N` and proving the ratio is
exactly `(2/3)^N`, which the existing `tendsto_pow_atTop_nhds_zero_of_lt_one`
machinery already supports.

**Test / falsification.** Compute `2^N / 3^N` for `N = 1..10` and check it equals
the value of `computable_fraction_tendsto_zero`'s integrand at `C = 2^N`; if any
oracle outside the `2^N` image can be indexed by a length-`N` binary string, the
conjecture is false.

---

## Direction 2: Alphabet-Generic Counting Barrier

**Conjecture.** `oracle_not_covered` generalizes verbatim to oracles valued in
`Fin a` for any `a ≥ 1`: if `card P < a^N` then no `f : P → (Fin N → Fin a)` is
surjective. Moreover the three special cases `a = 2` (decision oracles), `a = 3`
(true/false/unknown), and `a → ∞` (real-valued confidence, via a discretization
limit) are unified by a single lemma parameterized by `a`.

**The key insight is** that the "3" in this cycle was never used by the coverage
argument; promoting it to a variable `a` exposes the barrier as a statement about
*any* finite answer space and lets decision-, modal-, and confidence-oracles share
one proof.

**Why now?** The current `oracle_not_covered` proof routes entirely through
`Fintype.card_le_of_surjective` and `oracle_card`; both have obvious `a`-generic
analogues (`Fintype.card_fun`), so the generalization is a low-risk refactor that
immediately multiplies the theorem's reach.

**Test / falsification.** Re-prove the `a`-generic lemma and recover the `a = 3`
file as a one-line specialization; failure to specialize cleanly falsifies the
claim that the argument is genuinely alphabet-agnostic.

---

## Direction 3: Logically Consistent Oracles Still Escape

**Conjecture.** Fix a set `R` of implications `i → j` among the `N` statements and
call an oracle *consistent* if it never assigns `true` to `i` and a non-`true`
verdict to `j` when `i → j ∈ R`. The number `L(N,R)` of consistent oracles still
grows exponentially (faster than `2^N`) whenever `R` leaves `Ω(N)` statements
mutually independent, so the counting barrier `card P < L(N,R)` still bites:
adding logical structure does **not** make the oracle space computable.

**The key insight is** that consistency only prunes a *sub-exponential* logical
skeleton; the exponential freedom lives on the antichain of `R`-independent
statements, which the barrier already handles via `oracle_not_covered`.

**Why now?** `oracle_not_covered` is stated for an *arbitrary* `Fintype` codomain
embedded in `Oracle N`; the consistent-oracle subtype is exactly such a finite
codomain, so the existing barrier applies the moment we lower-bound `L(N,R)`.

**Test / falsification.** Enumerate consistent oracles for `N ≤ 8` and a random
`R`; if `L(N,R)` ever drops to a polynomial in `N`, the exponential lower bound —
and hence the conjecture — fails.

---

## Direction 4: Composition Amplifies the Gap (Finite Jump)

**Conjecture.** For oracle spaces `Oracle N`, the *composition space*
`Oracle N → Oracle N` has cardinality `(3^N)^(3^N) = 3^(N·3^N)`, which exceeds
`3^(b^k)` for every fixed program budget and *every* `N ≥ 1`. Hence composing
oracles is strictly harder to compute than evaluating them — a finite, fully
constructive analogue of the Turing jump raising degree.

**The key insight is** that the jump phenomenon need not invoke the halting
problem: the bare cardinal inequality `3^(N·3^N) > 3^(b^k)`, an iterate of
`budget_gap_exists`, already certifies a strict increase in description cost.

**Why now?** `budget_gap_exists` and `oracle_card` give both the growth lemma and
the base count; the composition space is just `Oracle N → Oracle N`, whose
cardinality follows from `oracle_card` applied twice, so the inequality is within
immediate reach.

**Test / falsification.** Check `3^(N·3^N) > 3^(b^k)` numerically for small
`N, b, k`; exhibiting a finite program family that realizes all compositions at a
fixed budget would falsify the strict-increase claim.

---

## Direction 5: Tropical Solution Oracles Inherit the Barrier

**Conjecture.** Map each tropical polynomial system on `n` equations to its
solution-set "verdict vector" in `Fin N → Fin 3` (feasible / infeasible /
degenerate per probe point). The number of realizable verdict vectors grows
exponentially in `n`, so by `oracle_not_covered` no fixed-size family of tropical
certificates computes them all — the oracle barrier transfers to tropical geometry.

**The key insight is** that tropical solution sets, once discretized into a
three-valued verdict per probe, become honest elements of `Oracle N`, so the
*same* `oracle_not_covered` lemma applies with no new combinatorics.

**Why now?** The catalog already develops tropical complexity transfer
(`Tropical/ComplexityTransfer.lean`); pairing it with `oracle_not_covered` only
requires a counting bound on realizable verdict vectors, which tropical
hyperplane-arrangement counts already supply.

**Test / falsification.** For `n ≤ 5`, enumerate realizable verdict vectors and
compare to `3^N`; if a small certificate family reproduces every vector, the
transfer fails.

**Concept description**: # Future Directions: The Oracle Counting Barrier

## Synthesis

This cycle isolated the *mechanism* behind the bridge between finite-description
complexity and three-valued oracle non-computability, and reduced it to a single,
domain-agnostic cardinal fact. The file `OracleCountingBarrier.lean` proves five
results that together say: the space of three-valued oracles on `N` statements has
size `3^N` (`oracle_card`); any program space strictly smaller than `3^N` fails to
cover it, regardless of how programs are compiled into oracles (`oracle_not_covered`);
a fixed program budget `b^k` is eventually outrun by `3^N` (`budget_gap_exists`);
binary descriptions of length `N` are strictly too poor, `2^N < 3^N`
(`binary_insufficient`); and the computable fraction `C / 3^N → 0`
(`computable_fraction_tendsto_zero`).

The central insight that organizes all of this: the *coverage* obstruction and the
*information* obstruction are logically independent. Coverage (`oracle_not_covered`)
needs nothing about the number "3" — it works for any answer alphabet of size `≥ 2`
and follows purely from `Fintype.card_le_of_surjective`. The number "3" only enters
the *information* story, where it produces the `log₂ 3 ≈ 1.585` bits-per-statement
deficit that `2^N < 3^N` witnesses. Factoring the argument this way is what makes
the proofs one or two lines each and makes the core lemma reusable across domains
(proof search, learning, tropical solution sets) by merely changing the codomain.

The most fertile cross-domain connection is between `oracle_not_covered` and
information theory: the abstract counting lemma is the finite, constructive shadow
of Shannon's source-coding bound, and `binary_insufficient` is its sharpest
finite instance. This suggests "mathematical truth has a positive entropy rate that
no finite binary description can match" can be stated and partially proved entirely
within finite combinatorics, sidestepping the machinery of Kolmogorov complexity.

---

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `oracle_card` | `card (Fin N → Fin 3) = 3^N` | Counts the oracle space |
| `oracle_not_covered` | `card P < 3^N → ∃ O, O ∉ range f` | The reusable counting barrier |
| `budget_gap_exists` | `∀ b k, ∃ N, b^k < 3^N` | Fixed budgets are eventually outrun |
| `binary_insufficient` | `1 ≤ N → 2^N < 3^N` | Information deficit of binary descriptions |
| `computable_fraction_tendsto_zero` | `C / 3^N → 0` | Almost all oracles are uncomputable |

All five compile with `sorry = 0` and depend only on `propext`, `Classical.choice`,
and `Quot.sound`.

---

## Direction 1: A Quantitative Three-vs-Two Entropy Gap

**Conjecture.** Define the per-statement description deficit
`D(N) = log₂(3^N) − log₂(2^N) = N·(log₂ 3 − 1)`. Then for the abstract
counting barrier, the *minimal* binary program length `ℓ(N)` needed merely to
index all `3^N` oracles satisfies `ℓ(N) = ⌈N·log₂ 3⌉`, and the fraction of
oracles reachable by programs of length `≤ N` is exactly `2^N / 3^N = (2/3)^N`.

**The key insight is** that `binary_insufficient` is not an inequality to be
weakened but the first term of an exact geometric law `(2/3)^N`, so the
"information deficit" is a precisely computable rate, not an asymptotic slogan.

**Why now?** We already have `oracle_card`, `binary_insufficient`, and
`computable_fraction_tendsto_zero` in hand; the only new ingredient is replacing
the constant budget `C` by the *binary* budget `2^N` and proving the ratio is
exactly `(2/3)^N`, which the existing `tendsto_pow_atTop_nhds_zero_of_lt_one`
machinery already supports.

**Test / falsification.** Compute `2^N / 3^N` for `N = 1..10` and check it equals
the value of `computable_fraction_tendsto_zero`'s integrand at `C = 2^N`; if any
oracle outside the `2^N` image can be indexed by a length-`N` binary string, the
conjecture is false.

---

## Direction 2: Alphabet-Generic Counting Barrier

**Conjecture.** `oracle_not_covered` generalizes verbatim to oracles valued in
`Fin a` for any `a ≥ 1`: if `card P < a^N` then no `f : P → (Fin N → Fin a)` is
surjective. Moreover the three special cases `a = 2` (decision oracles), `a = 3`
(true/false/unknown), and `a → ∞` (real-valued confidence, via a discretization
limit) are unified by a single lemma parameterized by `a`.

**The key insight is** that the "3" in this cycle was never used by the coverage
argument; promoting it to a variable `a` exposes the barrier as a statement about
*any* finite answer space and lets decision-, modal-, and confidence-oracles share
one proof.

**Why now?** The current `oracle_not_covered` proof routes entirely through
`Fintype.card_le_of_surjective` and `oracle_card`; both have obvious `a`-generic
analogues (`Fintype.card_fun`), so the generalization is a low-risk refactor that
immediately multiplies the theorem's reach.

**Test / falsification.** Re-prove the `a`-generic lemma and recover the `a = 3`
file as a one-line specialization; failure to specialize cleanly falsifies the
claim that the argument is genuinely alphabet-agnostic.

---

## Direction 3: Logically Consistent Oracles Still Escape

**Conjecture.** Fix a set `R` of implications `i → j` among the `N` statements and
call an oracle *consistent* if it never assigns `true` to `i` and a non-`true`
verdict to `j` when `i → j ∈ R`. The number `L(N,R)` of consistent oracles still
grows exponentially (faster than `2^N`) whenever `R` leaves `Ω(N)` statements
mutually independent, so the counting barrier `card P < L(N,R)` still bites:
adding logical structure does **not** make the oracle space computable.

**The key insight is** that consistency only prunes a *sub-exponential* logical
skeleton; the exponential freedom lives on the antichain of `R`-independent
statements, which the barrier already handles via `oracle_not_covered`.

**Why now?** `oracle_not_covered` is stated for an *arbitrary* `Fintype` codomain
embedded in `Oracle N`; the consistent-oracle subtype is exactly such a finite
codomain, so the existing barrier applies the moment we lower-bound `L(N,R)`.

**Test / falsification.** Enumerate consistent oracles for `N ≤ 8` and a random
`R`; if `L(N,R)` ever drops to a polynomial in `N`, the exponential lower bound —
and hence the conjecture — fails.

---

## Direction 4: Composition Amplifies the Gap (Finite Jump)

**Conjecture.** For oracle spaces `Oracle N`, the *composition space*
`Oracle N → Oracle N` has cardinality `(3^N)^(3^N) = 3^(N·3^N)`, which exceeds
`3^(b^k)` for every fixed program budget and *every* `N ≥ 1`. Hence composing
oracles is strictly harder to compute than evaluating them — a finite, fully
constructive analogue of the Turing jump raising degree.

**The key insight is** that the jump phenomenon need not invoke the halting
problem: the bare cardinal inequality `3^(N·3^N) > 3^(b^k)`, an iterate of
`budget_gap_exists`, already certifies a strict increase in description cost.

**Why now?** `budget_gap_exists` and `oracle_card` give both the growth lemma and
the base count; the composition space is just `Oracle N → Oracle N`, whose
cardinality follows from `oracle_card` applied twice, so the inequality is within
immediate reach.

**Test / falsification.** Check `3^(N·3^N) > 3^(b^k)` numerically for small
`N, b, k`; exhibiting a finite program family that realizes all compositions at a
fixed budget would falsify the strict-increase claim.

---

## Direction 5: Tropical Solution Oracles Inherit the Barrier

**Conjecture.** Map each tropical polynomial system on `n` equations to its
solution-set "verdict vector" in `Fin N → Fin 3` (feasible / infeasible /
degenerate per probe point). The number of realizable verdict vectors grows
exponentially in `n`, so by `oracle_not_covered` no fixed-size family of tropical
certificates computes them all — the oracle barrier transfers to tropical geometry.

**The key insight is** that tropical solution sets, once discretized into a
three-valued verdict per probe, become honest elements of `Oracle N`, so the
*same* `oracle_not_covered` lemma applies with no new combinatorics.

**Why now?** The catalog already develops tropical complexity transfer
(`Tropical/ComplexityTransfer.lean`); pairing it with `oracle_not_covered` only
requires a counting bound on realizable verdict vectors, which tropical
hyperplane-arrangement counts already supply.

**Test / falsification.** For `n ≤ 5`, enumerate realizable verdict vectors and
compare to `3^N`; if a small certificate family reproduces every vector, the
transfer fails.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
