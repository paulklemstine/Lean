# Future Directions: Entropy-Bounded Computation (EBC) — Cycle 2

## Synthesis

This cycle did two things on top of the existing EBC core (`Defs.lean`,
`Theorems.lean`, `Quantum.lean`). First, it **completed the framework**: the core
files referenced a `Bridges.EBC.Defs` module that was missing, so the previous
cycle's `Theorems.lean` and `Quantum.lean` did not actually compile. We
reconstructed `Defs.lean` faithfully (Landauer parameters, computation
steps/sequences, search problems, Maxwell demons, reversible computations) so the
entire EBC tower now builds with only the standard axioms `propext`,
`Classical.choice`, `Quot.sound`. Second, it **discharged two items the previous
cycle explicitly deferred**, in two new files `Generalizations.lean` and
`CryptoQuantumBridge.lean`.

The previous cycle's critique flagged a conjecture: the flagship
`step_count_bounded_by_budget` only needs a *uniform positive lower bound*
`minBits` on bits erased, yielding the sharper `minBits · length · tf ≤ B`. We
proved exactly that (`step_count_bounded_general`) and showed the old flagship is
its `minBits = 1` instance (`step_count_bounded_by_budget_recovered`). The
boundary case `minBits = 0` is genuinely where the bound goes vacuous — the
zero-dissipation reversible regime where length is thermodynamically unbounded.

The structural insight that emerged is that the **information bound and the
energy bound are literally the same inequality, related by the factor `tf`**. We
formalized the decision-tree comparison-sort lower bound honestly as an
*injectivity* bound — distinguishing the `n!` permutations by their length-`L`
binary comparison traces forces `log₂(n!) ≤ L`
(`comparison_sort_length_lower_bound`) — and then turned it into a Landauer
*energy* statement (`sorting_energy_lower_bound`): sorting `n` elements with
unit-erasure comparisons dissipates at least `log₂(n!) · tf` joules. Separately,
we showed Grover's quadratic search speedup is precisely a *halving of the
exponent* inside one fixed energy law (`grover_speedup`), and we built a genuine
cross-domain bridge proving the quantum and classical cost models are the same
additive functional (`quantum_cost_eq_classical`,
`quantum_bruteForce_cost`), from which the quantum brute-force energy wall follows
immediately (`quantum_search_energy_wall`).

## Results Summary

- `EBC.LandauerParams` / `ComputationStep` / `StepSequence` / `SearchProblem` / `MaxwellDemon` / `ReversibleComputation`: reconstructed — the previously-missing `Defs.lean`, making the whole EBC tower compile.
- `minBits_mul_length_le_totalBits`: proved — a uniform per-step lower bound scales to a total-bits lower bound.
- `step_count_bounded_general`: proved — closes the previous cycle's conjecture: `minBits · length · tf ≤ B`; budget caps step count whenever steps dissipate a fixed minimum.
- `step_count_bounded_by_budget_recovered`: proved — the old flagship is the `minBits = 1` special case, confirming the generalization.
- `comparison_sort_length_lower_bound`: proved — decision-tree sorting lower bound at its information-theoretic root: `log₂(n!) ≤ L`.
- `totalBits_of_unit_steps`: proved — a unit-erasure sequence erases exactly `length` bits.
- `sorting_energy_lower_bound`: proved — unifies decision-tree and thermodynamic lower bounds: sorting costs at least `log₂(n!) · tf` joules.
- `grover_speedup`: proved — Grover's quadratic speedup is exponent halving in one Landauer energy law.
- `quantum_cost_eq_classical`: proved — cross-domain bridge: quantum cost equals classical cost of erasing the measurement bits.
- `quantum_bruteForce_cost`: proved — a quantum circuit measuring all `2^n` candidates costs the same as classical brute force.
- `quantum_search_energy_wall`: proved — brute-force quantum search eventually beats any polynomial energy budget.

## Research Directions

### Direction 1: Sharpen the sorting bound to Ω(n log n) via Stirling
**Hypothesis**: `sorting_energy_lower_bound` can be sharpened from `log₂(n!) · tf`
to an explicit `c · n · log₂ n · tf` lower bound for an absolute constant `c` and
all `n ≥ 2`, by composing it with Mathlib's Stirling bounds on `Real.log (n!)`.
**Test**: Prove `Nat.log 2 (n!) ≥ ⌊(n/2) · log₂(n/2)⌋` (or a clean Stirling-based
real inequality) and chain it through `sorting_energy_lower_bound`.
**Why now?**: This cycle reduced the whole problem to the single integer
inequality `log₂(n!) ≤ L`; the only missing piece is a lower bound on `log₂(n!)`,
which is pure analysis already present in Mathlib. The key insight is that the
information-to-energy conversion is *already done* — the remaining work is a
self-contained number-theoretic estimate, completely decoupled from the EBC model.
**If true**: the first formally verified Ω(n log n) *energy* lower bound for
comparison sorting.
**If false**: would expose that our injectivity model of "distinguishing
permutations" is weaker than the comparison-tree model, sharpening what a
"comparison" must reveal.

### Direction 2: Entropy Hierarchy Theorem via additive simulation overhead
**Hypothesis**: Defining `ENTROPY(f)` as the problems solvable by a `StepSequence`
of cost `≤ f(n) · tf`, we have `ENTROPY(n^k) ⊊ ENTROPY(n^(k+1))` for all `k ≥ 1`.
**Test**: Build a universal simulator as a `StepSequence` transformer whose
overhead is *additive* (justified by `totalCost_append`), then diagonalize using
`entropy_gap_const` to separate the classes.
**Why now?**: `entropy_gap_const` (previous cycle) already gives the
constant-multiplier room to absorb simulation overhead, and `step_count_bounded_general`
now lets us reason about cost-to-count conversion with a tunable `minBits`. The
key insight is that EBC's *additive* (not multiplicative) cost composition makes
the simulation overhead a sum, so the budget `n^(k+1)` strictly dominates
`C · n^k` for any fixed `C` — exactly the gap `entropy_gap_const` provides.
**If true**: the first verified hierarchy theorem in the Landauer cost model.
**If false**: additive cost composition collapses the hierarchy — i.e. simulation
is thermodynamically "too cheap".

### Direction 3: The minBits = 0 boundary and the time–entropy trade-off
**Hypothesis**: For a reversible simulation transform sending a `T`-step
irreversible computation (cost `≤ T · tf`) to a zero-cost reversible one
(`reversible_comp_cost_zero`), the minimum simulation *time* obeys a trade-off
`time ≥ T² / (B/tf + 1)` when the entropy budget is `B < T · tf`.
**Test**: Formalize a pebble game on the computation DAG over `ℕ`; the zero-cost
half is immediate, and the trade-off is a counting argument on pebbling strategies.
**Why now?**: This cycle pinned down the exact boundary where step-count bounds
fail — `minBits = 0`, proven vacuous in `step_count_bounded_general`'s Lab
Notebook. The key insight is that EBC cleanly separates *cost* (in `tf` units)
from *time* (step counts); the trade-off is a statement relating these two
independent coordinates precisely in the regime where cost gives no information.
**If true**: a verified Pareto frontier between dissipated energy and runtime.
**If false**: the pebbling bound is loose, indicating a cheaper reversible
strategy than Bennett's.

### Direction 4: Genuine deferred measurement via ordered circuit semantics
**Hypothesis**: Enrich `QuantumCircuit` to an ordered list of gate/measurement
events with a measurement-statistics equivalence `≈`; then every circuit is `≈`
to one with all measurements at the end, and this transform preserves
`measurementCount` (hence cost, via `quantum_cost_eq_classical`).
**Test**: Prove `defer c ≈ c` by induction on the event list, commuting each
measurement past one trailing unitary at a time.
**Why now?**: This cycle's `quantum_cost_eq_classical` shows the cost is fully
determined by `measurementCount`, so the cost-invariance half is already free; the
only new content is a structural `≈` tracking outcomes rather than counts. The key
insight is that the energy argument is settled, isolating the remaining work as
purely a semantic equivalence question.
**If true**: the first verified deferred-measurement principle with real semantic
content.
**If false**: deferral changes the measurement count for some gate set (e.g.
classically controlled gates), revealing a concrete obstruction to free deferral.

### Direction 5: Concrete cryptographic energy floor at n = 256
**Hypothesis**: Instantiating `tf = kB · T · ln 2` at `kB ≈ 1.38·10⁻²³ J/K`,
`T = 300 K`, the brute-force cost `2^256 · tf` exceeds a concrete absolute energy
bound (e.g. far above any plausible energy budget), while `grover_speedup` shows
the `2^128` quantum cost is strictly — and concretely — smaller.
**Test**: Build a `LandauerParams` with the concrete constants, compute a rational
lower bound for `tempFactor`, and combine with `bruteForce_cost` and
`grover_speedup` at `n = 256` to produce an explicit numeric inequality.
**Why now?**: `grover_speedup` and `bruteForce_cost` are proved and parametric in
`tf`; plugging concrete constants is pure arithmetic over an already-established
separation. The key insight is that post-quantum key-size guidance (256-bit keys
giving 128-bit quantum security) is exactly the exponent-halving of
`grover_speedup` made numeric.
**If true**: a physically meaningful, formally verified link between key-size
recommendations and thermodynamics.
**If false**: the concrete arithmetic surfaces where the asymptotic gap fails to
engage at cryptographically relevant `n`, refining the security message.
