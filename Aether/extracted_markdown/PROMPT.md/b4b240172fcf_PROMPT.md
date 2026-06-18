
## PHASE A: LEAN 4 ONLY — DOING THE MATH

You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

### DELIVERABLES (strict — only this):
1. **lean files (count chosen by the Plan)**
2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
   conjectures as a freeform narrative (NOT a form). Each direction MUST
   include a "The key insight is..." sentence and a "Why now?" justification.
   This file drives the next research cycle — make it count.

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


## Concept

**Title**: The EBC framework formalizes the connection between computational complexity and
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Entropy-Bounded Computation

## What We Built

The EBC framework formalizes the connection between computational complexity and thermodynamics through Landauer's principle in Lean 4. The core structures (LandauerParams, EntropyBudgetSystem, IrreversibleStep, StepSequence, ReversibleComputation, MaxwellDemon, SearchProblem) support fully verified theorems about entropy cost additivity, reversible computation, budget constraints, and the entropy gap between polynomial and exponential search.

All 13 declarations (9 theorems, 3 definitions, 4 examples) compile without sorry, using only standard axioms.

---

## Direction 1: Quantum Measurement as the Sole Entropy Source

The EBC framework currently treats all irreversible steps uniformly. In quantum computing, unitary gates are perfectly reversible (zero entropy cost), while measurements collapse superpositions and produce entropy. The key insight is that the EBC framework can be refined to distinguish reversible gates (cost 0) from measurement gates (cost kT·ln 2), giving a resource theory where quantum advantage is characterized by measurement budget rather than gate count.

**Testable conjecture**: Define `QuantumStep` as an inductive type with `Unitary (cost = 0)` and `Measurement (cost = tempFactor)` variants. Prove that the total cost of a quantum circuit equals `(number of measurements) * tempFactor`, independent of the number of unitary gates. Then formalize the deferred measurement principle as a theorem that any mixed circuit can be rearranged to have measurements only at the end, preserving total cost.

**Why now?** The `landauer_cost_additive` and `reversible_is_involution` theorems from this cycle provide the exact compositional structure needed. Unitary gates compose as `ReversibleComputation` (zero cost by `reversible_is_involution`), and measurements compose additively (by `landauer_cost_additive`). The framework is ready for this extension without architectural changes.

---

## Direction 2: Strict Entropy Hierarchy via Diagonalization

The `entropy_budget_monotone` theorem shows that larger budgets permit more computations (containment). But does strictly more budget permit strictly more problems? The key insight is that the entropy gap theorem (`exp_eventually_exceeds_poly`) provides the separation needed for a diagonalization argument: a problem solvable with n^(k+1) entropy budget can simulate and diagonalize against all n^k-bounded computations, because the simulation overhead is polynomial and the gap is superpolynomial.

**Testable conjecture**: Define `ENTROPY(f) := {problems decidable by an EBS with budget f(n) * tempFactor}`. Prove that for k ≥ 1, there exists a problem in ENTROPY(n^(k+1)) \ ENTROPY(n^k). The proof should formalize a universal simulation argument where the simulator uses budget proportional to the simulated computation's budget plus overhead for the diagonalization step.

**Why now?** The `step_count_bounded_by_budget` theorem gives the resource bound, and `exp_eventually_exceeds_poly` gives the gap. Together they provide the quantitative separation needed to show the universal simulator with n^(k+1) budget has enough room to simulate all n^k-bounded machines and diagonalize. This is a direct analogue of the time hierarchy theorem, but for entropy.

---

## Direction 3: Landauer Cost of Sorting — A Physical Lower Bound

Comparison-based sorting requires Ω(n log n) comparisons, a classical information-theoretic result. The key insight is that each comparison is an `IrreversibleStep` that bisects the space of permutations, erasing exactly 1 bit. The total Landauer cost of sorting n elements is therefore at least ⌈log₂(n!)⌉ · kT · ln(2), giving a thermodynamic proof of the sorting lower bound.

**Testable conjecture**: Define `ComparisonSort n` as a `StepSequence` where each step has `bitsErased = 1` and the total number of steps is at least ⌈log₂(n!)⌉. Prove using `step_count_bounded_by_budget` that any comparison sort uses at least ⌈log₂(n!)⌉ steps, and verify computationally for small n (n=1: 0 steps, n=2: 1 step, n=3: 3 steps, n=10: 22 steps).

**Why now?** The `step_count_bounded_by_budget` theorem provides the exact mechanism: if each comparison erases 1 bit (minBits = 1), then the number of comparisons ≤ budget / tempFactor. Inverting this gives the lower bound. The `BinTree` infrastructure from `Computation.ThermodynamicSorting` (already in the catalog) provides the decision tree model. Bridging these two formalizations would unify information-theoretic and thermodynamic sorting bounds.

---

## Direction 4: Time-Entropy Tradeoff via Bennett's Pebble Game

The `reversible_compose` definition shows that reversible computations compose. Bennett's pebble game shows that any T-step irreversible computation can be simulated reversibly in O(T · S) time and O(S · log T) space, at zero entropy cost. The key insight is that this creates a formal time-entropy tradeoff curve: you can trade entropy budget for time, but the exchange rate is multiplicative (not additive), creating a non-trivial optimization landscape.

**Testable conjecture**: Define `PebbleGame(T, S)` as a `ReversibleComputation` that simulates a T-step irreversible computation using S space. Prove that the pebble game's composition (via `reversible_compose`) has zero total Landauer cost (via `reversible_is_involution`), and that its step count is O(T · S). Then prove the Pareto frontier: for any entropy budget B < T · tempFactor, the minimum time to simulate the computation is Ω(T²/B).

**Why now?** The `ReversibleComputation` structure and `reversible_compose` definition provide the exact framework. The zero-cost property (`reversible_is_involution`) is already proved. What remains is formalizing the pebble game's time overhead, which is a counting argument over the pebbling strategy. The EBC framework's additive cost model makes the tradeoff analysis clean.

---

## Direction 5: Maxwell's Demon Composition and Cryptographic Key Search

The `demon_composition_cost` theorem shows that sequential demons have additive cost. The key insight is that breaking an n-bit cryptographic key by exhaustive search requires a Maxwell's demon with 2^n measurements, each erasing 1 bit, for a total Landauer cost of 2^n · kT · ln(2). This gives a thermodynamic lower bound on brute-force cryptanalysis: at room temperature (T ≈ 300K), searching a 256-bit key space costs at least 2^256 · 3 × 10^{-21} J ≈ 10^{56} J, far exceeding the Sun's total energy output.

**Testable conjecture**: Define `BruteForceSearch(n)` as a `MaxwellDemon` with `measurements = 2^n`. Prove that its `entropyCost` equals `2^n * tempFactor`. Then, using `entropy_gap_unbounded`, prove that no polynomial-time algorithm can achieve the same search with polynomial entropy cost (assuming the entropy gap is tight). This connects the EBC framework to post-quantum cryptographic security.

**Why now?** The `demon_composition_cost` theorem and `entropy_gap_unbounded` theorem are the exact tools needed. The demon models the adversary, and the gap theorem shows that polynomial-time alternatives are thermodynamically separated from brute force. This bridge between physics and cryptography is natural within the EBC framework and would be the first formally verified thermodynamic security argument.

**Concept description**: # Future Directions: Entropy-Bounded Computation

## What We Built

The EBC framework formalizes the connection between computational complexity and thermodynamics through Landauer's principle in Lean 4. The core structures (LandauerParams, EntropyBudgetSystem, IrreversibleStep, StepSequence, ReversibleComputation, MaxwellDemon, SearchProblem) support fully verified theorems about entropy cost additivity, reversible computation, budget constraints, and the entropy gap between polynomial and exponential search.

All 13 declarations (9 theorems, 3 definitions, 4 examples) compile without sorry, using only standard axioms.

---

## Direction 1: Quantum Measurement as the Sole Entropy Source

The EBC framework currently treats all irreversible steps uniformly. In quantum computing, unitary gates are perfectly reversible (zero entropy cost), while measurements collapse superpositions and produce entropy. The key insight is that the EBC framework can be refined to distinguish reversible gates (cost 0) from measurement gates (cost kT·ln 2), giving a resource theory where quantum advantage is characterized by measurement budget rather than gate count.

**Testable conjecture**: Define `QuantumStep` as an inductive type with `Unitary (cost = 0)` and `Measurement (cost = tempFactor)` variants. Prove that the total cost of a quantum circuit equals `(number of measurements) * tempFactor`, independent of the number of unitary gates. Then formalize the deferred measurement principle as a theorem that any mixed circuit can be rearranged to have measurements only at the end, preserving total cost.

**Why now?** The `landauer_cost_additive` and `reversible_is_involution` theorems from this cycle provide the exact compositional structure needed. Unitary gates compose as `ReversibleComputation` (zero cost by `reversible_is_involution`), and measurements compose additively (by `landauer_cost_additive`). The framework is ready for this extension without architectural changes.

---

## Direction 2: Strict Entropy Hierarchy via Diagonalization

The `entropy_budget_monotone` theorem shows that larger budgets permit more computations (containment). But does strictly more budget permit strictly more problems? The key insight is that the entropy gap theorem (`exp_eventually_exceeds_poly`) provides the separation needed for a diagonalization argument: a problem solvable with n^(k+1) entropy budget can simulate and diagonalize against all n^k-bounded computations, because the simulation overhead is polynomial and the gap is superpolynomial.

**Testable conjecture**: Define `ENTROPY(f) := {problems decidable by an EBS with budget f(n) * tempFactor}`. Prove that for k ≥ 1, there exists a problem in ENTROPY(n^(k+1)) \ ENTROPY(n^k). The proof should formalize a universal simulation argument where the simulator uses budget proportional to the simulated computation's budget plus overhead for the diagonalization step.

**Why now?** The `step_count_bounded_by_budget` theorem gives the resource bound, and `exp_eventually_exceeds_poly` gives the gap. Together they provide the quantitative separation needed to show the universal simulator with n^(k+1) budget has enough room to simulate all n^k-bounded machines and diagonalize. This is a direct analogue of the time hierarchy theorem, but for entropy.

---

## Direction 3: Landauer Cost of Sorting — A Physical Lower Bound

Comparison-based sorting requires Ω(n log n) comparisons, a classical information-theoretic result. The key insight is that each comparison is an `IrreversibleStep` that bisects the space of permutations, erasing exactly 1 bit. The total Landauer cost of sorting n elements is therefore at least ⌈log₂(n!)⌉ · kT · ln(2), giving a thermodynamic proof of the sorting lower bound.

**Testable conjecture**: Define `ComparisonSort n` as a `StepSequence` where each step has `bitsErased = 1` and the total number of steps is at least ⌈log₂(n!)⌉. Prove using `step_count_bounded_by_budget` that any comparison sort uses at least ⌈log₂(n!)⌉ steps, and verify computationally for small n (n=1: 0 steps, n=2: 1 step, n=3: 3 steps, n=10: 22 steps).

**Why now?** The `step_count_bounded_by_budget` theorem provides the exact mechanism: if each comparison erases 1 bit (minBits = 1), then the number of comparisons ≤ budget / tempFactor. Inverting this gives the lower bound. The `BinTree` infrastructure from `Computation.ThermodynamicSorting` (already in the catalog) provides the decision tree model. Bridging these two formalizations would unify information-theoretic and thermodynamic sorting bounds.

---

## Direction 4: Time-Entropy Tradeoff via Bennett's Pebble Game

The `reversible_compose` definition shows that reversible computations compose. Bennett's pebble game shows that any T-step irreversible computation can be simulated reversibly in O(T · S) time and O(S · log T) space, at zero entropy cost. The key insight is that this creates a formal time-entropy tradeoff curve: you can trade entropy budget for time, but the exchange rate is multiplicative (not additive), creating a non-trivial optimization landscape.

**Testable conjecture**: Define `PebbleGame(T, S)` as a `ReversibleComputation` that simulates a T-step irreversible computation using S space. Prove that the pebble game's composition (via `reversible_compose`) has zero total Landauer cost (via `reversible_is_involution`), and that its step count is O(T · S). Then prove the Pareto frontier: for any entropy budget B < T · tempFactor, the minimum time to simulate the computation is Ω(T²/B).

**Why now?** The `ReversibleComputation` structure and `reversible_compose` definition provide the exact framework. The zero-cost property (`reversible_is_involution`) is already proved. What remains is formalizing the pebble game's time overhead, which is a counting argument over the pebbling strategy. The EBC framework's additive cost model makes the tradeoff analysis clean.

---

## Direction 5: Maxwell's Demon Composition and Cryptographic Key Search

The `demon_composition_cost` theorem shows that sequential demons have additive cost. The key insight is that breaking an n-bit cryptographic key by exhaustive search requires a Maxwell's demon with 2^n measurements, each erasing 1 bit, for a total Landauer cost of 2^n · kT · ln(2). This gives a thermodynamic lower bound on brute-force cryptanalysis: at room temperature (T ≈ 300K), searching a 256-bit key space costs at least 2^256 · 3 × 10^{-21} J ≈ 10^{56} J, far exceeding the Sun's total energy output.

**Testable conjecture**: Define `BruteForceSearch(n)` as a `MaxwellDemon` with `measurements = 2^n`. Prove that its `entropyCost` equals `2^n * tempFactor`. Then, using `entropy_gap_unbounded`, prove that no polynomial-time algorithm can achieve the same search with polynomial entropy cost (assuming the entropy gap is tight). This connects the EBC framework to post-quantum cryptographic security.

**Why now?** The `demon_composition_cost` theorem and `entropy_gap_unbounded` theorem are the exact tools needed. The demon models the adversary, and the gap theorem shows that polynomial-time alternatives are thermodynamically separated from brute force. This bridge between physics and cryptography is natural within the EBC framework and would be the first formally verified thermodynamic security argument.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
