# Future Directions: Entropy-Bounded Computation (EBC)

This research cycle established the **Entropy-Bounded Computation (EBC)**
framework in `Foundations.lean`, coupling computational complexity to
thermodynamics through Landauer's principle. The verified results are:

- `one_bit_erasure_pos`, `landauerCost_strictMono` — bit erasure has strictly
  positive, monotone Landauer cost;
- `step_count_bounded_by_budget` — a finite energy budget caps the number of
  irreversible steps;
- `entropy_gap_unbounded` — the thermodynamic cost gap between exponential
  (`2^n`) and polynomial (`n^c`) search is unbounded, a physical shadow of
  `P ≠ NP`;
- `reversible_comp_is_id` — reversible (bijective) steps produce zero net
  entropy;
- the **quantum measurement bottleneck** suite: `measurement_bottleneck`,
  `unitary_steps_are_free`, `totalCost_perm_invariant`,
  `poly_measurements_poly_cost`, and the boundary result
  `unitary_circuit_zero_cost`.

The central new contribution is the *measurement bottleneck theorem*: the total
Landauer cost of a quantum circuit equals its measurement count times the
Landauer unit, completely independent of the number of unitary gates. This
isolates measurement — not gate count — as the sole carrier of thermodynamic
cost in quantum computation, and via `totalCost_perm_invariant` it gives a
thermodynamic form of the deferred-measurement principle. The following
directions extend this frontier.

---

## Direction 1: A Measurement-Count Lower Bound for Quantum Search

**Conjecture.** Any quantum circuit that decides an unstructured search problem
on `N = 2^n` items with bounded error must contain `Ω(√N)` measurements, and
hence (by `measurement_bottleneck`) dissipates `Ω(√N) · landauerUnit` of energy.
Grover's algorithm is therefore thermodynamically optimal: its `Θ(√N)`
measurement budget matches the lower bound.

**The key insight is** that `measurement_bottleneck` converts an *information*
lower bound (each measurement extracts at most one bit toward identifying the
marked item) directly into an *energetic* lower bound, so the BBBV optimality of
Grover search becomes a statement about minimal heat dissipation rather than
query count.

**Test.** Formalize a `QuantumSearchCircuit` decision predicate, prove that a
circuit with `m` measurements distinguishes at most `2^m` marked-item hypotheses,
and conclude `m ≥ n`/`m ≥ √N` for the respective regimes; then instantiate the
bound for an explicit Grover-shaped circuit and compare with
`poly_measurements_poly_cost`.

**Why now?** `measurement_bottleneck` and `poly_measurements_poly_cost` already
reduce the energetic cost to a pure counting quantity (`measurementCount`), so
the remaining work is a finite combinatorial counting argument rather than any
new thermodynamic modeling — exactly the shape the current framework supports.

---

## Direction 2: An Energetic Time–Space Tradeoff via Reversible Simulation

**Conjecture.** Within EBC, every irreversible circuit of `T` steps can be
simulated by a circuit of zero Landauer cost (purely unitary, in the sense of
`unitary_circuit_zero_cost`) at the price of a multiplicative time blow-up
bounded by a fixed polynomial in `T`. This formalizes Bennett's reversible
simulation as a clean *cost-for-time* exchange: entropy can always be driven to
zero, but never for free in time.

**The key insight is** that `unitary_circuit_zero_cost` already certifies the
"zero entropy" half of Bennett's theorem for purely unitary circuits, so the
open content is purely the *combinatorial step-count bookkeeping* of the pebble
game, decoupled from any physics.

**Test.** Define a `PebbleGame` structure producing a `ReversibleComputation`,
prove its simulated trace is purely unitary (apply `unitary_circuit_zero_cost`
for zero cost), and bound its length by `O(T · S)` via induction on the pebbling
recursion; check the `T = 1` base case and a 2-step example.

**Why now?** The reversible-computation scaffolding (`ReversibleComputation`,
`reversible_comp_is_id`) and the zero-cost certificate are in place, turning the
deep physical claim into a tractable recursion-counting lemma.

---

## Direction 3: A Strict Thermodynamic Complexity Hierarchy

**Conjecture.** Define `ENTROPY(f)` as the class of problems decidable by an
`EntropyBudgetSystem` whose total dissipation is at most `f(n) · landauerUnit`.
Then the hierarchy is strict: `ENTROPY(n) ⊊ ENTROPY(n²) ⊊ ENTROPY(n³) ⊊ ⋯`, and
no "entropy speed-up" theorem exists — `f`-entropy problems genuinely need
`Ω(f)` dissipation.

**The key insight is** that `step_count_bounded_by_budget` already shows a budget
*upper-bounds* step count, so the missing ingredient is a matching diagonalized
*lower bound*: a language whose deciders provably require more than `f(n)` steps,
mirroring the classical time-hierarchy diagonalization but charged in Landauer
units.

**Test.** Formalize `ENTROPY(f)`, prove `P ⊆ ENTROPY(n^c)` by charging one bit
per step, then construct a diagonal language `L_k` decidable within `n^{k+1}`
dissipation but not `n^k`, reusing `entropy_gap_unbounded` to certify the gap is
genuinely unbounded across levels.

**Why now?** `entropy_gap_unbounded` provides the unbounded-separation engine and
`step_count_bounded_by_budget` provides the budget↔step bridge; together they
supply both directions a hierarchy theorem needs.

---

## Direction 4: Entropy-Additivity Across Composed Computational Agents

**Conjecture.** When two independent computations (or "Maxwell demons") are run
in sequence or in parallel, their Landauer costs add exactly:
`totalCost (c₁ ++ c₂) = totalCost c₁ + totalCost c₂`, and more generally the
measurement count is additive. Consequently, breaking an `ℓ`-bit cryptographic
key — which requires at least `ℓ` irreversible decisions — costs at least
`ℓ · landauerUnit`, giving a thermodynamic security floor.

**The key insight is** that `measurement_bottleneck` makes total cost an affine
function of an additive counting functional (`measurementCount` is a
`List.countP`, hence additive over `++`), so additivity of cost is immediate and
extends to arbitrary finite compositions.

**Test.** Prove `totalCost_append` and `measurementCount_append`, derive an
`n`-fold composition law by induction, and instantiate it as a key-recovery
entropy bound `cost ≥ ℓ · landauerUnit` for an `ℓ`-measurement key search.

**Why now?** The cost functional is already a sum over a mapped list, so
additivity is a short corollary of `measurement_bottleneck` and existing
`List.countP`/`List.sum` append lemmas — a direct, low-risk extension that opens
the cryptographic bridge.

---

## Direction 5: Physical Throughput Limits from Margolus–Levitin

**Conjecture.** Adjoining the Margolus–Levitin speed limit (at most `2E/(πℏ)`
orthogonalizing operations per second for energy `E` above ground state) to EBC
yields a maximum irreversible-bit throughput of `2E / (πℏ · landauerUnit)` bit
operations per second. Combined with `step_count_bounded_by_budget`, this turns
a finite *energy* budget into a finite *rate* budget.

**The key insight is** that `step_count_bounded_by_budget` already converts a
budget into a step cap with `costPerStep = landauerUnit`; supplying the energy as
`E · τ` from a speed limit makes the same lemma output a throughput bound with no
new proof machinery.

**Test.** Introduce the Margolus–Levitin rate as a hypothesis (a `variable`, not
an axiom), derive `numSteps ≤ 2Eτ / (πℏ · landauerUnit)` via
`step_count_bounded_by_budget`, and evaluate the explicit constant for room
temperature and a 1 W power budget.

**Why now?** `step_count_bounded_by_budget` is exactly the bridge lemma needed;
the only addition is treating the speed limit as a parameter, keeping the
development axiom-free while reaching an absolute physical ceiling on
computation.
