# Future Directions: Entropy-Bounded Computation (EBC)

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
