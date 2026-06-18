# Future Directions: Entropy-Bounded Computation Framework

## What Was Built

The EBC framework now spans three files with 0 sorry's:

- **Defs.lean**: Core structures (LandauerParams, EntropyBudgetSystem, IrreversibleStep, StepSequence, ReversibleComputation, MaxwellDemon, SearchProblem)
- **Theorems.lean**: 15 theorems including `step_count_bounded_by_budget`, `exp_eventually_exceeds_poly`, `entropy_gap_unbounded`, `demon_cost_additive`, `reversible_forward_bijective`, `budget_monotone`, and more
- **Quantum.lean**: 8 theorems/definitions including `quantum_circuit_cost`, `gate_count_decomposition`, `measurement_budget_bound`, `unitary_compose_free`

All proofs compile cleanly with only standard axioms (propext, Classical.choice, Quot.sound).

---

## Direction 1: Entropy Hierarchy Theorem via Diagonalization

The `step_count_bounded_by_budget` theorem bounds the number of computational steps within an entropy budget, and `entropy_gap_unbounded` shows exponential search dominates polynomial. The next step is a proper hierarchy theorem: define ENTROPY(f) as the class of problems solvable with entropy budget f(n)·tempFactor, then prove strict containment ENTROPY(n^k) ⊊ ENTROPY(n^(k+1)).

The key insight is that the universal simulation argument needs only polynomial overhead — a simulator with n^(k+1) budget can simulate all n^k-bounded computations and diagonalize against them, because `entropy_gap_unbounded` provides the asymptotic room. This would be the first formally verified entropy hierarchy theorem, analogous to the time hierarchy theorem but in the Landauer cost model.

Why now? The gap theorem and budget bound are already proved. What remains is formalizing a universal simulator as a StepSequence transformer and proving its overhead is polynomial. The EBC framework's additive cost model makes this cleaner than classical time hierarchy proofs because there's no constant-factor overhead from simulation.

---

## Direction 2: Thermodynamic Sorting Lower Bound

Comparison-based sorting requires Ω(n log n) comparisons. Each comparison is an IrreversibleStep erasing 1 bit (it bisects the space of permutations). Using `step_count_bounded_by_budget` with minBits = 1, the number of comparisons is bounded by budget/tempFactor. Setting the budget equal to the Landauer cost of sorting n! permutations gives a lower bound of ⌈log₂(n!)⌉ comparisons.

The key insight is that this gives a *thermodynamic* proof of the sorting lower bound: the information-theoretic argument (n! permutations require log₂(n!) bits to distinguish) is equivalent to a Landauer cost argument (sorting dissipates at least log₂(n!) · kT·ln(2) energy). Formalizing this bridge would unify two independently discovered lower bound techniques.

Why now? The `step_count_bounded_by_budget` theorem provides exactly the mechanism needed. The missing piece is formalizing `ComparisonSort n` as a StepSequence where each step has bitsErased = 1 and proving that any valid sorting procedure for n elements requires at least ⌈log₂(n!)⌉ steps. Stirling's approximation (already in Mathlib as bounds on log of factorials) would give the Ω(n log n) form.

---

## Direction 3: Bennett's Reversible Simulation and Time-Entropy Tradeoff

The `reversible_compose` definition shows reversible computations compose at zero entropy cost. Bennett's theorem (1973) shows any T-step irreversible computation can be simulated reversibly in O(T^(1+ε)) time. This creates a Pareto frontier: you can trade entropy budget for time.

The key insight is formalizing this as a function `bennett_simulate : StepSequence params → ReversibleComputation α × ℕ` where the ℕ is the time overhead, and proving that the output ReversibleComputation has zero Landauer cost (by `reversible_compose`) while the time overhead satisfies a quantitative bound. The tradeoff curve — for entropy budget B < T·tempFactor, minimum simulation time is Ω(T²/B) — would follow from a counting argument on pebbling strategies.

Why now? The `ReversibleComputation` structure and zero-cost theorems are in place. The pebble game formalization requires only natural number arithmetic on a graph (the computation DAG). The EBC framework's clean separation between cost (measured in tempFactor units) and time (measured in step counts) makes the tradeoff analysis tractable.

---

## Direction 4: Quantum Measurement Complexity and Deferred Measurement

The `quantum_circuit_cost` theorem shows total cost equals measurementCount × tempFactor. The deferred measurement principle states that any quantum circuit can be rearranged so all measurements occur at the end, without changing the computation's outcome or total cost.

The key insight is that formalizing this requires a notion of quantum circuit *equivalence* — two circuits are equivalent if they produce the same measurement statistics. The deferred measurement transformation preserves measurement count (hence cost by `quantum_circuit_cost`) while reordering gates. This would give the first formally verified proof that quantum computation's entropy cost depends only on the number of classical bits extracted, not on when they're extracted.

Why now? The `QuantumCircuit` structure and `quantum_circuit_cost` theorem provide the cost model. What's needed is a `CircuitEquivalence` relation (same measurement statistics) and a constructive proof that any circuit can be transformed to deferred form while preserving this equivalence. The `gate_count_decomposition` theorem already shows the counting infrastructure works.

---

## Direction 5: Cryptographic Brute-Force Entropy Bound

The `demon_cost_additive` theorem shows sequential information-gathering operations have cumulative cost. A brute-force search of an n-bit key space requires 2^n measurements (one per candidate key), and `entropy_gap_unbounded` shows this cost exceeds any polynomial budget for large n.

The key insight is that this gives a *physical* lower bound on brute-force cryptanalysis: at temperature T, searching an n-bit key space costs at least 2^n · kT·ln(2) joules. At room temperature, a 256-bit key space requires ≈ 10^56 joules — more than the Sun's lifetime energy output. Formalizing this connects the EBC framework to post-quantum cryptographic security by showing that Grover's quadratic speedup (2^(n/2) measurements) gives a concrete, physically meaningful advantage.

Why now? The `demon_cost_scaling` theorem already shows cost scales linearly with measurements. The `entropy_gap_unbounded` theorem provides the polynomial-exponential separation. Connecting these to a formal `BruteForceSearch n` definition and proving the physical energy bound requires only arithmetic on the concrete Landauer parameters (kB ≈ 1.38 × 10^-23 J/K, T ≈ 300 K).
