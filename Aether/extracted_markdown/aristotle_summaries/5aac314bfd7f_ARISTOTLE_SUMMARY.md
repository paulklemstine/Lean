# Summary of changes for run e807b0a4-a892-44b4-ab60-246294ffaf17
Established the **Entropy-Bounded Computation (EBC)** framework, which couples computational complexity to thermodynamics via Landauer's principle, as a new self-contained, fully-verified Lean file.

**Deliverables**

1. `Catalog/Speculative/ComplexityPhysics/Foundations.lean` — a self-contained Lean 4 development (imports Mathlib only) that compiles with **zero `sorry`** and uses only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`). It contains:

   Core EBC theory:
   - `landauerUnit` / `landauerCost` definitions (energy of bit erasure = k·T·log 2 per bit);
   - `one_bit_erasure_pos` — bit erasure has strictly positive cost;
   - `landauerCost_strictMono` — cost is strictly increasing in the bit count;
   - `EntropyBudgetSystem` structure and `step_count_bounded_by_budget` — a finite energy budget caps the number of irreversible steps;
   - `entropy_gap_unbounded` — the thermodynamic cost gap between exponential (2^n) and polynomial (n^c) search is unbounded (a physical shadow of P ≠ NP), proved via exponential-dominates-polynomial asymptotics;
   - `ReversibleComputation` and `reversible_comp_is_id` — reversible steps produce zero net entropy.

   New quantum contribution (the measurement bottleneck):
   - `measurement_bottleneck` — the total Landauer cost of a quantum circuit equals its measurement count times the Landauer unit, independent of the number of unitary gates;
   - `unitary_steps_are_free`, `totalCost_perm_invariant` (a thermodynamic deferred-measurement principle), and `poly_measurements_poly_cost`;
   - boundary case `unitary_circuit_zero_cost` (purely unitary circuits cost zero), plus two worked `example` blocks.

   Each theorem carries a one–two sentence proof sketch and an explanatory docstring.

2. `Catalog/Speculative/ComplexityPhysics/FUTURE_DIRECTIONS.md` — five testable, falsifiable research conjectures (quantum search lower bounds, reversible time–space tradeoff, a strict thermodynamic complexity hierarchy, entropy-additivity across composed agents, and Margolus–Levitin throughput limits), each with a "The key insight is…" sentence and a "Why now?" justification grounded in the lemmas just proved.

The referenced catalog files (`Speculative/ComplexityPhysics/*`, `Shared/CryptoEntropyBridges.lean`) did not previously exist (cold start), so the framework was built from scratch. The file builds cleanly with no warnings.