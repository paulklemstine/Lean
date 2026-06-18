
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

**Title**: Entropy-Bounded Computation framework from a cold start as
**Domain**: Applications
**Mathematical framing**: # Future Directions: Entropy-Bounded Computation (EBC)

## Synthesis

This cycle built the Entropy-Bounded Computation framework from a cold start as a
*bridge* between thermodynamics (Landauer's principle), information theory (bit
counting) and computational complexity (step / measurement counts and search).
The framework lives in three files — `Defs.lean` (structures), `Theorems.lean`
(13 results) and `Quantum.lean` (5 results) — and every result compiles with only
the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via
`#print axioms`). There are **zero `sorry`s**, including in supporting lemmas.

The structural insight that emerged is that *cost is an additive monoid
homomorphism out of the free monoid of computation steps*. Both the classical
cost model (`totalCost_append`) and the quantum one (`quantum_cost_additive`) are
literally the same statement: a `(List, ++) → (ℝ, +)` homomorphism obtained by
counting erased bits and scaling by the per-bit factor `tf = kB·T·ln 2`. This
single algebraic fact is what makes budgets compositional and lets a *cost lower
bound* convert mechanically into a *step-count upper bound*
(`step_count_bounded_by_budget`). The one genuinely analytic ingredient is the
polynomial-versus-exponential separation `poly_isLittleO_exp`, distilled from
Mathlib's `isLittleO_pow_exp_pos_mul_atTop` by identifying `2^x` with
`exp((ln 2)·x)`; it is the engine behind every complexity separation here
(`entropy_gap_unbounded`, `entropy_gap_const`, `search_cost_exceeds_poly_budget`).

What did *not* fully materialize is the deep structural content behind the
quantum results: `quantum_circuit_cost` and `deferred_measurement_cost_invariant`
are true essentially by definition because our circuit abstraction records only
counts, not gate orderings or measurement statistics. This is a deliberate,
honest "cost-accounting shadow" of the deferred-measurement principle, and it
pinpoints exactly where the next cycle must add structure (a real circuit
semantics with an equivalence relation) to make the statement non-trivial. The
critique below makes this boundary precise.

## Results Summary

- `tempFactor_pos`: proved — the per-bit Landauer cost `kB·T·ln 2` is strictly positive; load-bearing positivity for every inequality.
- `totalBits_append`: proved — bit counts are additive over concatenation.
- `totalCost_append`: proved — Landauer cost is additive (the cost model is a monoid homomorphism into `(ℝ,+)`).
- `totalCost_nonneg`: proved — cost is nonnegative for a nonnegative per-bit factor.
- `totalCost_le_append_right`: proved — appending steps cannot decrease cost (budget monotonicity).
- `step_count_bounded_by_budget`: proved — flagship: an energy budget `B` admits at most `B/tf` unit-erasure steps (Landauer's principle as a complexity bound).
- `bruteForce_cost`: proved — brute-forcing an `n`-bit key space costs exactly `2^n·tf`.
- `demon_cost_additive`: proved — a Maxwell demon's erasure cost is additive over composition.
- `reversible_comp_bijective`: proved — reversible computations compose to bijections (zero-cost, information preserving).
- `reversible_comp_cost_zero`: proved — composite reversible computations still have zero Landauer cost.
- `poly_isLittleO_exp`: proved — analytic core: `x^k =o[atTop] 2^x`.
- `entropy_gap_unbounded`: proved — discrete gap: eventually `n^k < 2^n`.
- `search_cost_exceeds_poly_budget`: proved — cryptographic payoff: brute-force cost eventually beats any polynomial budget.
- `entropy_gap_const`: proved — generalization: the gap survives any constant multiplier `C`, i.e. eventually `C·n^k < 2^n`.
- `quantum_circuit_cost`: proved — quantum cost depends only on measurement count, not gate count.
- `unitary_compose_free`: proved — a measurement-free circuit has zero cost.
- `quantum_cost_additive`: proved — quantum cost is additive over composition.
- `measurement_budget_bound`: proved — a budget caps the number of measurements.
- `deferred_measurement_cost_invariant`: proved — deferring measurements preserves total cost (cost-level deferred-measurement principle).

### Critique of the best theorem (`step_count_bounded_by_budget`)

The strongest assumption that can be weakened is `hmin : ∀ s ∈ seq, 1 ≤ bitsErased s`
(every step erases at least one bit). The theorem really only needs a *uniform
positive lower bound* `minBits ≥ 1` on erased bits, which would yield the sharper
`minBits · length · tf ≤ B`. The boundary case where the result breaks down is
`minBits = 0`: a sequence of "free" reversible steps has zero cost yet unbounded
length, so no budget can cap the step count — exactly the regime where Bennett's
reversible simulation lives. The generalized statement
`(minBits : ℝ) · length · tf ≤ B` under `∀ s ∈ seq, minBits ≤ bitsErased s` is a
clean `conjecture` for the next cycle; the proof changes only by replacing the
`length ≤ totalBits` step with `minBits · length ≤ totalBits`.

## Research Directions

### Direction 1: Entropy Hierarchy Theorem via Diagonalization
**Hypothesis**: Define `ENTROPY(f)` as the class of decision problems solvable by a
`StepSequence` of total cost `≤ f(n)·tf` on length-`n` inputs. Then for every
`k ≥ 1`, `ENTROPY(n^k) ⊊ ENTROPY(n^(k+1))`.
**Test**: Formalize a universal simulator as a `StepSequence` transformer whose
overhead is *additive* (no constant-factor blowup, since cost composes by
`totalCost_append`), then diagonalize using `entropy_gap_const` to find a problem
in the larger class but not the smaller.
**Why now**: `entropy_gap_const` (proved this cycle) gives exactly the constant-
multiplier room needed to absorb the polynomial simulation overhead; the additive
cost model removes the constant-factor headache that complicates the classical
time hierarchy. The key insight is that EBC's additive (rather than multiplicative)
cost composition makes the simulation overhead a *sum*, so the diagonalization
budget `n^(k+1)` strictly dominates `C·n^k` for any fixed `C`.
**If true**: the first formally verified hierarchy theorem in the Landauer cost
model, a thermodynamic analogue of the time hierarchy theorem.
**If false**: it would reveal that additive cost composition collapses the
hierarchy — a surprising statement that simulation is "too cheap" thermodynamically.

### Direction 2: Thermodynamic Sorting Lower Bound
**Hypothesis**: Any comparison-based sorting procedure for `n` elements, modeled
as a `StepSequence` where each comparison erases exactly one bit, has length at
least `⌈log₂ (n!)⌉`, hence `Ω(n log n)`.
**Test**: Define `ComparisonSort n` as a `StepSequence` whose steps bisect the set
of consistent permutations, set the budget to the Landauer cost of distinguishing
`n!` permutations, and apply `step_count_bounded_by_budget` (with `minBits = 1`)
in its contrapositive form; close the `Ω(n log n)` shape with Mathlib's Stirling
bounds on `Real.log (n !)`.
**Why now**: `step_count_bounded_by_budget` is proved and provides precisely the
budget→count mechanism. The key insight is that the information-theoretic sorting
bound and the Landauer energy bound are *the same inequality* viewed through
`tf`: distinguishing `n!` outcomes needs `log₂(n!)` bits, which costs
`log₂(n!)·kT ln 2` joules.
**If true**: unifies two independently discovered lower-bound techniques
(decision-tree and thermodynamic) inside one formal statement.
**If false**: would expose a step in the bisection model that erases more or
fewer than one bit, sharpening our understanding of what a "comparison" costs.

### Direction 3: Reversible Simulation and the Time–Entropy Trade-off
**Hypothesis**: There is a transform `bennett_simulate : StepSequence → ReversibleComputation × ℕ`
sending a `T`-step irreversible computation to a reversible one (Landauer cost `0`
by `reversible_comp_cost_zero`) with time overhead `g(T)`, and for entropy budget
`B < T·tf` the minimum simulation time obeys `time ≥ T²/(B/tf + 1)`.
**Test**: Formalize a pebble game on the computation DAG over `ℕ` (avoiding `Fin`
friction) and prove the trade-off as a counting argument on pebbling strategies;
the zero-cost half follows immediately from `reversible_comp_cost_zero`.
**Why now**: the `ReversibleComputation` structure and its zero-cost theorems are
in place. The key insight is EBC's clean separation of *cost* (in `tf` units) from
*time* (step counts): the trade-off is a statement relating these two independent
coordinates, exactly the boundary case `minBits = 0` flagged in the critique.
**If true**: a verified Pareto frontier between dissipated energy and runtime.
**If false**: the pebbling counting bound is loose, indicating a better reversible
strategy than Bennett's.

### Direction 4: Genuine Deferred-Measurement via Circuit Semantics
**Hypothesis**: Enrich `QuantumCircuit` to an ordered list of gate/measurement
events with a measurement-statistics equivalence `≈`. Then every circuit is `≈`
to one with all measurements at the end, and this transform preserves
`measurementCount` (hence cost by `quantum_circuit_cost`).
**Test**: Prove `defer c ≈ c` for the enriched semantics by induction on the
event list, commuting each measurement past one trailing unitary at a time.
**Why now**: this cycle proved the *cost-accounting shadow*
(`deferred_measurement_cost_invariant`) and isolated exactly what is missing — an
equivalence relation tracking outcomes rather than counts. The key insight is that
the cost invariance is already free; the only new content needed is that deferring
preserves `measurementCount`, which the count-level lemma already encapsulates.
**If true**: the first formally verified deferred-measurement principle with real
semantic content, showing entropy cost is independent of *when* bits are extracted.
**If false**: deferral changes the measurement count for some gate set, revealing
a non-trivial obstruction (e.g. classically controlled gates) to free deferral.

### Direction 5: Cryptographic Brute-Force Energy Wall
**Hypothesis**: For concrete Landauer parameters (`kB ≈ 1.38·10⁻²³ J/K`,
`T = 300 K`), the brute-force Landauer cost of an `n`-bit key space,
`2^n · kB·T·ln 2`, exceeds any fixed polynomial energy budget for large `n`; and
a Grover-style `2^(n/2)` search is asymptotically and *concretely* cheaper.
**Test**: Instantiate `search_cost_exceeds_poly_budget` at the concrete `tf`,
prove the explicit inequality `2^(n/2) · tf < 2^n · tf` for `n ≥ 2` via
`pow_lt_pow_right`, and add a numeric corollary bounding the `n = 256` cost from
below by an absolute constant.
**Why now**: `search_cost_exceeds_poly_budget` and `bruteForce_cost` are proved;
plugging in the concrete `tf` and a `2^(n/2)` term is pure arithmetic over an
already-established separation. The key insight is that Grover's quadratic
speedup is exactly a *halving of the exponent* in the same `2^n·tf` energy law,
so the speedup is visible as a strict inequality between two instances of one
theorem.
**If true**: a physically meaningful, formally verified lower bound connecting
post-quantum key-size recommendations to thermodynamics.
**If false**: the concrete arithmetic would surface where the asymptotic gap fails
to engage at cryptographically relevant `n`, refining the security message.

**Concept description**: # Future Directions: Entropy-Bounded Computation (EBC)

## Synthesis

This cycle built the Entropy-Bounded Computation framework from a cold start as a
*bridge* between thermodynamics (Landauer's principle), information theory (bit
counting) and computational complexity (step / measurement counts and search).
The framework lives in three files — `Defs.lean` (structures), `Theorems.lean`
(13 results) and `Quantum.lean` (5 results) — and every result compiles with only
the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via
`#print axioms`). There are **zero `sorry`s**, including in supporting lemmas.

The structural insight that emerged is that *cost is an additive monoid
homomorphism out of the free monoid of computation steps*. Both the classical
cost model (`totalCost_append`) and the quantum one (`quantum_cost_additive`) are
literally the same statement: a `(List, ++) → (ℝ, +)` homomorphism obtained by
counting erased bits and scaling by the per-bit factor `tf = kB·T·ln 2`. This
single algebraic fact is what makes budgets compositional and lets a *cost lower
bound* convert mechanically into a *step-count upper bound*
(`step_count_bounded_by_budget`). The one genuinely analytic ingredient is the
polynomial-versus-exponential separation `poly_isLittleO_exp`, distilled from
Mathlib's `isLittleO_pow_exp_pos_mul_atTop` by identifying `2^x` with
`exp((ln 2)·x)`; it is the engine behind every complexity separation here
(`entropy_gap_unbounded`, `entropy_gap_const`, `search_cost_exceeds_poly_budget`).

What did *not* fully materialize is the deep structural content behind the
quantum results: `quantum_circuit_cost` and `deferred_measurement_cost_invariant`
are true essentially by definition because our circuit abstraction records only
counts, not gate orderings or measurement statistics. This is a deliberate,
honest "cost-accounting shadow" of the deferred-measurement principle, and it
pinpoints exactly where the next cycle must add structure (a real circuit
semantics with an equivalence relation) to make the statement non-trivial. The
critique below makes this boundary precise.

## Results Summary

- `tempFactor_pos`: proved — the per-bit Landauer cost `kB·T·ln 2` is strictly positive; load-bearing positivity for every inequality.
- `totalBits_append`: proved — bit counts are additive over concatenation.
- `totalCost_append`: proved — Landauer cost is additive (the cost model is a monoid homomorphism into `(ℝ,+)`).
- `totalCost_nonneg`: proved — cost is nonnegative for a nonnegative per-bit factor.
- `totalCost_le_append_right`: proved — appending steps cannot decrease cost (budget monotonicity).
- `step_count_bounded_by_budget`: proved — flagship: an energy budget `B` admits at most `B/tf` unit-erasure steps (Landauer's principle as a complexity bound).
- `bruteForce_cost`: proved — brute-forcing an `n`-bit key space costs exactly `2^n·tf`.
- `demon_cost_additive`: proved — a Maxwell demon's erasure cost is additive over composition.
- `reversible_comp_bijective`: proved — reversible computations compose to bijections (zero-cost, information preserving).
- `reversible_comp_cost_zero`: proved — composite reversible computations still have zero Landauer cost.
- `poly_isLittleO_exp`: proved — analytic core: `x^k =o[atTop] 2^x`.
- `entropy_gap_unbounded`: proved — discrete gap: eventually `n^k < 2^n`.
- `search_cost_exceeds_poly_budget`: proved — cryptographic payoff: brute-force cost eventually beats any polynomial budget.
- `entropy_gap_const`: proved — generalization: the gap survives any constant multiplier `C`, i.e. eventually `C·n^k < 2^n`.
- `quantum_circuit_cost`: proved — quantum cost depends only on measurement count, not gate count.
- `unitary_compose_free`: proved — a measurement-free circuit has zero cost.
- `quantum_cost_additive`: proved — quantum cost is additive over composition.
- `measurement_budget_bound`: proved — a budget caps the number of measurements.
- `deferred_measurement_cost_invariant`: proved — deferring measurements preserves total cost (cost-level deferred-measurement principle).

### Critique of the best theorem (`step_count_bounded_by_budget`)

The strongest assumption that can be weakened is `hmin : ∀ s ∈ seq, 1 ≤ bitsErased s`
(every step erases at least one bit). The theorem really only needs a *uniform
positive lower bound* `minBits ≥ 1` on erased bits, which would yield the sharper
`minBits · length · tf ≤ B`. The boundary case where the result breaks down is
`minBits = 0`: a sequence of "free" reversible steps has zero cost yet unbounded
length, so no budget can cap the step count — exactly the regime where Bennett's
reversible simulation lives. The generalized statement
`(minBits : ℝ) · length · tf ≤ B` under `∀ s ∈ seq, minBits ≤ bitsErased s` is a
clean `conjecture` for the next cycle; the proof changes only by replacing the
`length ≤ totalBits` step with `minBits · length ≤ totalBits`.

## Research Directions

### Direction 1: Entropy Hierarchy Theorem via Diagonalization
**Hypothesis**: Define `ENTROPY(f)` as the class of decision problems solvable by a
`StepSequence` of total cost `≤ f(n)·tf` on length-`n` inputs. Then for every
`k ≥ 1`, `ENTROPY(n^k) ⊊ ENTROPY(n^(k+1))`.
**Test**: Formalize a universal simulator as a `StepSequence` transformer whose
overhead is *additive* (no constant-factor blowup, since cost composes by
`totalCost_append`), then diagonalize using `entropy_gap_const` to find a problem
in the larger class but not the smaller.
**Why now**: `entropy_gap_const` (proved this cycle) gives exactly the constant-
multiplier room needed to absorb the polynomial simulation overhead; the additive
cost model removes the constant-factor headache that complicates the classical
time hierarchy. The key insight is that EBC's additive (rather than multiplicative)
cost composition makes the simulation overhead a *sum*, so the diagonalization
budget `n^(k+1)` strictly dominates `C·n^k` for any fixed `C`.
**If true**: the first formally verified hierarchy theorem in the Landauer cost
model, a thermodynamic analogue of the time hierarchy theorem.
**If false**: it would reveal that additive cost composition collapses the
hierarchy — a surprising statement that simulation is "too cheap" thermodynamically.

### Direction 2: Thermodynamic Sorting Lower Bound
**Hypothesis**: Any comparison-based sorting procedure for `n` elements, modeled
as a `StepSequence` where each comparison erases exactly one bit, has length at
least `⌈log₂ (n!)⌉`, hence `Ω(n log n)`.
**Test**: Define `ComparisonSort n` as a `StepSequence` whose steps bisect the set
of consistent permutations, set the budget to the Landauer cost of distinguishing
`n!` permutations, and apply `step_count_bounded_by_budget` (with `minBits = 1`)
in its contrapositive form; close the `Ω(n log n)` shape with Mathlib's Stirling
bounds on `Real.log (n !)`.
**Why now**: `step_count_bounded_by_budget` is proved and provides precisely the
budget→count mechanism. The key insight is that the information-theoretic sorting
bound and the Landauer energy bound are *the same inequality* viewed through
`tf`: distinguishing `n!` outcomes needs `log₂(n!)` bits, which costs
`log₂(n!)·kT ln 2` joules.
**If true**: unifies two independently discovered lower-bound techniques
(decision-tree and thermodynamic) inside one formal statement.
**If false**: would expose a step in the bisection model that erases more or
fewer than one bit, sharpening our understanding of what a "comparison" costs.

### Direction 3: Reversible Simulation and the Time–Entropy Trade-off
**Hypothesis**: There is a transform `bennett_simulate : StepSequence → ReversibleComputation × ℕ`
sending a `T`-step irreversible computation to a reversible one (Landauer cost `0`
by `reversible_comp_cost_zero`) with time overhead `g(T)`, and for entropy budget
`B < T·tf` the minimum simulation time obeys `time ≥ T²/(B/tf + 1)`.
**Test**: Formalize a pebble game on the computation DAG over `ℕ` (avoiding `Fin`
friction) and prove the trade-off as a counting argument on pebbling strategies;
the zero-cost half follows immediately from `reversible_comp_cost_zero`.
**Why now**: the `ReversibleComputation` structure and its zero-cost theorems are
in place. The key insight is EBC's clean separation of *cost* (in `tf` units) from
*time* (step counts): the trade-off is a statement relating these two independent
coordinates, exactly the boundary case `minBits = 0` flagged in the critique.
**If true**: a verified Pareto frontier between dissipated energy and runtime.
**If false**: the pebbling counting bound is loose, indicating a better reversible
strategy than Bennett's.

### Direction 4: Genuine Deferred-Measurement via Circuit Semantics
**Hypothesis**: Enrich `QuantumCircuit` to an ordered list of gate/measurement
events with a measurement-statistics equivalence `≈`. Then every circuit is `≈`
to one with all measurements at the end, and this transform preserves
`measurementCount` (hence cost by `quantum_circuit_cost`).
**Test**: Prove `defer c ≈ c` for the enriched semantics by induction on the
event list, commuting each measurement past one trailing unitary at a time.
**Why now**: this cycle proved the *cost-accounting shadow*
(`deferred_measurement_cost_invariant`) and isolated exactly what is missing — an
equivalence relation tracking outcomes rather than counts. The key insight is that
the cost invariance is already free; the only new content needed is that deferring
preserves `measurementCount`, which the count-level lemma already encapsulates.
**If true**: the first formally verified deferred-measurement principle with real
semantic content, showing entropy cost is independent of *when* bits are extracted.
**If false**: deferral changes the measurement count for some gate set, revealing
a non-trivial obstruction (e.g. classically controlled gates) to free deferral.

### Direction 5: Cryptographic Brute-Force Energy Wall
**Hypothesis**: For concrete Landauer parameters (`kB ≈ 1.38·10⁻²³ J/K`,
`T = 300 K`), the brute-force Landauer cost of an `n`-bit key space,
`2^n · kB·T·ln 2`, exceeds any fixed polynomial energy budget for large `n`; and
a Grover-style `2^(n/2)` search is asymptotically and *concretely* cheaper.
**Test**: Instantiate `search_cost_exceeds_poly_budget` at the concrete `tf`,
prove the explicit inequality `2^(n/2) · tf < 2^n · tf` for `n ≥ 2` via
`pow_lt_pow_right`, and add a numeric corollary bounding the `n = 256` cost from
below by an absolute constant.
**Why now**: `search_cost_exceeds_poly_budget` and `bruteForce_cost` are proved;
plugging in the concrete `tf` and a `2^(n/2)` term is pure arithmetic over an
already-established separation. The key insight is that Grover's quadratic
speedup is exactly a *halving of the exponent* in the same `2^n·tf` energy law,
so the speedup is visible as a strict inequality between two instances of one
theorem.
**If true**: a physically meaningful, formally verified lower bound connecting
post-quantum key-size recommendations to thermodynamics.
**If false**: the concrete arithmetic would surface where the asymptotic gap fails
to engage at cryptographically relevant `n`, refining the security message.

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
