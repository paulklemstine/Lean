# Summary of changes for run 3d9da381-b243-476c-b647-e2fa40ece333
## Entropy-Bounded Computation Framework — Lean 4 Formalization

### What was built

Three self-contained Lean 4 files formalizing the connection between computational complexity and thermodynamics through Landauer's principle, plus a research directions document:

**`Computation/EntropyBoundedComputation/Defs.lean`** — Core structures:
- `LandauerParams`, `IrreversibleStep`, `StepSequence`, `EntropyBudgetSystem`
- `ReversibleComputation`, `MaxwellDemon`, `SearchProblem`

**`Computation/EntropyBoundedComputation/Theorems.lean`** — 18 theorems including:
- `step_count_bounded_by_budget` — The central budget constraint: if each step erases ≥ minBits, then numSteps × minBits ≤ budget/tempFactor
- `exp_eventually_exceeds_poly` — For any polynomial degree k, ∃ N, ∀ n ≥ N, n^k < 2^n (proved via real analysis: n^k/2^n → 0)
- `entropy_gap_unbounded` — For any C, k, ∃ N, ∀ n ≥ N, C·n^k < 2^n
- `demon_cost_additive` — Sequential Maxwell's demons have additive entropy cost
- `reversible_forward_bijective` — Reversible computations are bijections (axiom-free!)
- `reversible_compose_inverse` — Composing with inverse gives identity
- `total_cost_eq_bits_times_temp` — Total cost factors as totalBits × tempFactor
- `budget_monotone`, `maxSteps_monotone` — Monotonicity results

**`Computation/EntropyBoundedComputation/Quantum.lean`** — 5 theorems extending to quantum computation:
- `quantum_circuit_cost` — Total cost = measurementCount × tempFactor (unitaries are free)
- `gate_count_decomposition` — unitaryCount + measurementCount = numGates
- `measurement_budget_bound` — Budget limits measurements: measurementCount ≤ budget/tempFactor
- `unitary_compose_free` — Any number of unitary gates costs nothing
- `pure_unitary_no_measurements` — Purely unitary circuits have zero measurements

**`FUTURE_DIRECTIONS.md`** — 5 research directions: entropy hierarchy theorem, thermodynamic sorting bound, Bennett's reversible simulation, deferred measurement principle, cryptographic brute-force bound.

### Verification

- **0 sorry's** across all three Lean files
- All theorems depend only on standard axioms (propext, Classical.choice, Quot.sound)
- Clean build with no errors
- 23 theorems + 7 definitions + 4 examples total