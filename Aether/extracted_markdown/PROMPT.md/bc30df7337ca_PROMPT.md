
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

**Title**: **Entropy-Bounded Computation (EBC)** framew
**Domain**: Computation
**Mathematical framing**: # Future Directions: Computational Complexity as Physical Law

## Synthesis

This research cycle established the **Entropy-Bounded Computation (EBC)** framework, which formalizes the connection between computational complexity and thermodynamics through Landauer's principle. The central result is the **entropy gap theorem**: the thermodynamic cost gap between polynomial and exponential search grows without bound, providing a physical interpretation of the P ≠ NP conjecture. The framework consists of five interconnected structures (EntropyBudgetSystem, MaxwellDemon, ReversibleComputation, IrreversibleStep, ComplexityEntropyDuality) with 13 formally verified theorems.

The most promising cross-domain connection is between the **Maxwell's demon bound** (from the Shared/CryptoEntropyBridges catalog) and **computational search complexity**. Our demon composition theorem shows that thermodynamic irreversibility composes additively across computational agents, which connects to both cryptographic security (breaking keys requires entropy proportional to key length) and the polynomial hierarchy (each level requires strictly more entropy). The entropy gap theorem provides the mathematical foundation for a physically-grounded complexity theory.

The highest breakthrough potential lies in **Direction 1 (Quantum Entropy Budget)**: quantum computation is fundamentally reversible except for measurement, suggesting that the EBC framework should yield tighter bounds for quantum complexity classes. If the quantum extension shows that BQP has a different entropy profile than P, it would provide a new approach to the BQP vs. P question — one grounded in physics rather than pure combinatorics.

---

### Direction 1: Quantum Entropy Budget and the Measurement Bottleneck

**Conjecture**: In a quantum extension of the EBC framework, the entropy cost of a quantum computation is determined entirely by the number of measurements, not the number of unitary gates. Formally: for a quantum circuit with U unitary gates and M measurements, the total Landauer cost is exactly M · kT · ln(2), independent of U. This implies that BQP computations with polynomially many measurements have polynomial entropy cost, while QMA-hard problems require exponentially many measurements under standard complexity assumptions.

**Test**: 
1. Formalize a `QuantumEntropyBudgetSystem` where steps are either unitary (cost 0) or measurement (cost kT·ln(2)).
2. Prove that the total cost equals the measurement count times the Landauer unit.
3. Implement Grover's algorithm and Shor's algorithm in the framework and compute their entropy costs.
4. Compare: Grover uses O(√N) measurements, Shor uses O(n²) measurements. Check whether these match empirical predictions.

**Impact**: If true, this gives a clean physical characterization of quantum advantage: quantum computers are powerful not because they compute differently, but because they defer entropy production until measurement. This would connect BQP to a physical resource (measurement budget) rather than an abstract computational model. If false, it reveals that quantum coherence has hidden entropy costs, challenging the deferred measurement principle.

**Catalog References**: `Shared/CryptoEntropyBridges.lean` (maxwell_demon_bound), `Speculative/ComplexityPhysics/Theorems.lean` (step_count_bounded_by_budget, reversible_comp_is_id)

**Proof Strategy**: 
1. Define `QuantumStep` as either `Unitary (cost = 0)` or `Measurement (cost = kT·ln(2))`.
2. Prove cost additivity via the existing demon_composition_cost pattern.
3. For the measurement bottleneck theorem, show that any quantum circuit can be rearranged (by the deferred measurement principle) to have all measurements at the end, concentrating all entropy cost.
4. Connect to BQP by bounding the measurement count for polynomial-time quantum algorithms.

**Domain Bridges**: Computation (entropy budget) ↔ Physics (quantum measurement) ↔ Cryptography (post-quantum security)

**Lineage**: Builds on entropy_gap_unbounded, step_count_bounded_by_budget, reversible_comp_is_id from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Entropy Complexity Classes and the Thermodynamic Polynomial Hierarchy

**Conjecture**: Define ENTROPY(f(n)) as the class of problems solvable with total Landauer cost at most f(n) · kT · ln(2). Then:
1. P ⊆ ENTROPY(n^c) for some constant c depending on the problem.
2. NP ⊆ ENTROPY(2^n) but NP ⊄ ENTROPY(n^c) for any c (assuming P ≠ NP).
3. The entropy hierarchy ENTROPY(n) ⊊ ENTROPY(n²) ⊊ ENTROPY(n³) ⊊ ... is strict.
4. ENTROPY(log n) = L (logarithmic space).

Part (3) is the most surprising claim: it asserts that entropy complexity has no "speed-up" theorem — you cannot simulate n² entropy with n entropy, even approximately.

**Test**:
1. Formalize ENTROPY(f) as a complexity class within the EBC framework.
2. Prove the containments P ⊆ ENTROPY(n^c) by analyzing standard algorithms.
3. For part (3), attempt to prove a hierarchy theorem using diagonalization.
4. Test computationally: implement sorting algorithms (merge sort vs. bubble sort) and measure their actual Landauer costs. Merge sort should use O(n log n) entropy; bubble sort O(n²).

**Impact**: If the entropy hierarchy is strict, it provides a new complexity hierarchy that is *physically meaningful* — each level corresponds to a different thermodynamic regime. This would be the first complexity hierarchy with a direct physical interpretation. If not strict, it means entropy can be "recycled" in unexpected ways.

**Catalog References**: `Speculative/ComplexityPhysics/Theorems.lean` (entropy_budget_monotone, entropy_gap_unbounded), `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm)

**Proof Strategy**: 
1. Define ENTROPY(f) formally as `{L | ∃ EBS with budget = f(n) that decides L}`.
2. For P ⊆ ENTROPY(n^c): any P algorithm makes poly(n) steps, each costing at most 1 bit.
3. For hierarchy strictness: adapt the time hierarchy theorem proof, using the entropy gap theorem to show that more entropy budget allows solving strictly more problems.
4. The diagonalization argument: construct a language L_k that can be decided with n^(k+1) entropy but not n^k entropy.

**Domain Bridges**: Computation (complexity classes) ↔ Physics (entropy budget) ↔ Logic (hierarchy theorems)

**Lineage**: Directly extends entropy_budget_monotone and entropy_gap_unbounded.

**Ambition**: grand_challenge

---

### Direction 3: Landauer Cost of Specific Algorithms

**Conjecture**: The Landauer cost of comparison-based sorting of n elements is exactly ⌈log₂(n!)⌉ · kT · ln(2), matching the information-theoretic lower bound. Any sorting algorithm that uses fewer comparisons than ⌈log₂(n!)⌉ must use non-comparison operations that cost additional entropy. In other words, the Landauer cost provides an independent proof of the Ω(n log n) comparison-based sorting lower bound.

**Test**:
1. Formalize comparison-based sorting in the EBC framework, where each comparison is an IrreversibleStep that halves the search space.
2. Prove that ⌈log₂(n!)⌉ comparisons are necessary via the entropy budget.
3. Implement merge sort and quicksort in the framework and verify their entropy costs match the theoretical predictions.
4. Check boundary case: for n = 1, cost should be 0; for n = 2, cost should be kT·ln(2).

**Impact**: This would be the first formally verified proof that the sorting lower bound is a *physical law*, not just an information-theoretic bound. It demonstrates that the EBC framework can recover known complexity bounds from thermodynamic principles.

**Catalog References**: `Speculative/ComplexityPhysics/Foundations.lean` (IrreversibleStep, landauerCost), `Speculative/ComplexityPhysics/Theorems.lean` (one_bit_erasure_cost, step_count_bounded_by_budget)

**Proof Strategy**:
1. Model a comparison as an IrreversibleStep from Fin(n!) (permutation space) to two halves.
2. After k comparisons, the remaining search space has size at most n!/2^k.
3. The search terminates when the space has size 1, requiring k ≥ log₂(n!).
4. Each comparison costs kT·ln(2) by one_bit_erasure_cost, giving total cost ≥ ⌈log₂(n!)⌉ · kT·ln(2).

**Domain Bridges**: Computation (sorting algorithms) ↔ Physics (Landauer cost) ↔ EML (information theory)

**Lineage**: Builds on IrreversibleStep, one_bit_erasure_cost, step_count_bounded_by_budget.

**Ambition**: extension

---

### Direction 4: Reversible Computing and Bennett's Pebble Game

**Conjecture**: In the EBC framework, any irreversible computation of T steps on S space can be made reversible using O(T · S) time and O(S · log T) space (Bennett's result). Formalizing this in the EBC framework gives: the entropy cost of simulating an irreversible computation reversibly is exactly 0, but the time overhead is multiplicative. This creates a time-entropy tradeoff: you can eliminate entropy cost entirely at the price of a polynomial time increase.

**Test**:
1. Formalize Bennett's pebble game in Lean as a ReversibleComputation.
2. Prove that the reversible simulation has zero Landauer cost (using reversible_comp_is_id).
3. Prove the time overhead bound: the reversible simulation takes O(T · S) steps.
4. Test: implement a reversible AND gate using Toffoli gates and verify zero entropy cost.

**Impact**: This direction explores the *escape hatch* from the entropy budget: reversible computing avoids Landauer costs but pays in time. The time-entropy tradeoff is fundamental to understanding whether thermodynamics truly constrains complexity or merely introduces overhead.

**Catalog References**: `Speculative/ComplexityPhysics/Foundations.lean` (ReversibleComputation), `Speculative/ComplexityPhysics/Theorems.lean` (reversible_comp_is_id, reversible_involution)

**Proof Strategy**:
1. Define a `PebbleGame` structure modeling Bennett's construction.
2. Show the pebble game produces a ReversibleComputation.
3. Count the number of pebbling steps to get the time bound.
4. Use reversible_comp_is_id to show zero entropy cost.

**Domain Bridges**: Computation (reversible circuits) ↔ Physics (entropy-free computation) ↔ Cryptography (side-channel resistance)

**Lineage**: Extends reversible_comp_is_id and ReversibleComputation.

**Ambition**: extension

---

### Direction 5: Entropy Production Rate and Computational Speed Limits

**Conjecture**: There exists a fundamental speed limit on computation analogous to the Margolus-Levitin bound: no physical system can perform more than 2E/(πℏ) irreversible operations per second, where E is the system's energy above ground state. Combined with the Landauer cost per operation, this gives a maximum computational throughput of 2E/(πℏ · kT · ln 2) irreversible bits per second. For a 1-watt computer at room temperature, this is approximately 4.4 × 10³¹ bit operations per second.

**Test**:
1. Formalize the Margolus-Levitin bound as an axiom in the EBC framework.
2. Derive the maximum bit rate from the bound and Landauer's principle.
3. Compute the maximum bit rate for realistic parameters (1W, 300K, 1 kg).
4. Compare with actual computer performance (modern CPUs achieve ~10¹⁰ ops/sec, far below the limit).

**Impact**: This connects the EBC framework to quantum mechanics (Margolus-Levitin) and gives absolute physical limits on computation. The gap between current computers and the physical limit (~10²¹ factor) suggests enormous room for improvement in computational efficiency.

**Catalog References**: `Speculative/ComplexityPhysics/Theorems.lean` (step_count_bounded_by_budget), `Shared/CryptoEntropyBridges.lean` (maxwell_demon_bound)

**Proof Strategy**:
1. Introduce the Margolus-Levitin bound as a parameter in EntropyBudgetSystem.
2. Derive budget = (2E · τ) / (πℏ · kT · ln 2) from the bound.
3. Apply step_count_bounded_by_budget with c = kT·ln(2).
4. Compute explicit values for standard physical parameters.

**Domain Bridges**: Physics (quantum speed limits) ↔ Computation (throughput bounds) ↔ EML (information rates)

**Lineage**: Builds on step_count_bounded_by_budget and the full EBC framework.

**Ambition**: extension

**Concept description**: # Future Directions: Computational Complexity as Physical Law

## Synthesis

This research cycle established the **Entropy-Bounded Computation (EBC)** framework, which formalizes the connection between computational complexity and thermodynamics through Landauer's principle. The central result is the **entropy gap theorem**: the thermodynamic cost gap between polynomial and exponential search grows without bound, providing a physical interpretation of the P ≠ NP conjecture. The framework consists of five interconnected structures (EntropyBudgetSystem, MaxwellDemon, ReversibleComputation, IrreversibleStep, ComplexityEntropyDuality) with 13 formally verified theorems.

The most promising cross-domain connection is between the **Maxwell's demon bound** (from the Shared/CryptoEntropyBridges catalog) and **computational search complexity**. Our demon composition theorem shows that thermodynamic irreversibility composes additively across computational agents, which connects to both cryptographic security (breaking keys requires entropy proportional to key length) and the polynomial hierarchy (each level requires strictly more entropy). The entropy gap theorem provides the mathematical foundation for a physically-grounded complexity theory.

The highest breakthrough potential lies in **Direction 1 (Quantum Entropy Budget)**: quantum computation is fundamentally reversible except for measurement, suggesting that the EBC framework should yield tighter bounds for quantum complexity classes. If the quantum extension shows that BQP has a different entropy profile than P, it would provide a new approach to the BQP vs. P question — one grounded in physics rather than pure combinatorics.

---

### Direction 1: Quantum Entropy Budget and the Measurement Bottleneck

**Conjecture**: In a quantum extension of the EBC framework, the entropy cost of a quantum computation is determined entirely by the number of measurements, not the number of unitary gates. Formally: for a quantum circuit with U unitary gates and M measurements, the total Landauer cost is exactly M · kT · ln(2), independent of U. This implies that BQP computations with polynomially many measurements have polynomial entropy cost, while QMA-hard problems require exponentially many measurements under standard complexity assumptions.

**Test**: 
1. Formalize a `QuantumEntropyBudgetSystem` where steps are either unitary (cost 0) or measurement (cost kT·ln(2)).
2. Prove that the total cost equals the measurement count times the Landauer unit.
3. Implement Grover's algorithm and Shor's algorithm in the framework and compute their entropy costs.
4. Compare: Grover uses O(√N) measurements, Shor uses O(n²) measurements. Check whether these match empirical predictions.

**Impact**: If true, this gives a clean physical characterization of quantum advantage: quantum computers are powerful not because they compute differently, but because they defer entropy production until measurement. This would connect BQP to a physical resource (measurement budget) rather than an abstract computational model. If false, it reveals that quantum coherence has hidden entropy costs, challenging the deferred measurement principle.

**Catalog References**: `Shared/CryptoEntropyBridges.lean` (maxwell_demon_bound), `Speculative/ComplexityPhysics/Theorems.lean` (step_count_bounded_by_budget, reversible_comp_is_id)

**Proof Strategy**: 
1. Define `QuantumStep` as either `Unitary (cost = 0)` or `Measurement (cost = kT·ln(2))`.
2. Prove cost additivity via the existing demon_composition_cost pattern.
3. For the measurement bottleneck theorem, show that any quantum circuit can be rearranged (by the deferred measurement principle) to have all measurements at the end, concentrating all entropy cost.
4. Connect to BQP by bounding the measurement count for polynomial-time quantum algorithms.

**Domain Bridges**: Computation (entropy budget) ↔ Physics (quantum measurement) ↔ Cryptography (post-quantum security)

**Lineage**: Builds on entropy_gap_unbounded, step_count_bounded_by_budget, reversible_comp_is_id from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Entropy Complexity Classes and the Thermodynamic Polynomial Hierarchy

**Conjecture**: Define ENTROPY(f(n)) as the class of problems solvable with total Landauer cost at most f(n) · kT · ln(2). Then:
1. P ⊆ ENTROPY(n^c) for some constant c depending on the problem.
2. NP ⊆ ENTROPY(2^n) but NP ⊄ ENTROPY(n^c) for any c (assuming P ≠ NP).
3. The entropy hierarchy ENTROPY(n) ⊊ ENTROPY(n²) ⊊ ENTROPY(n³) ⊊ ... is strict.
4. ENTROPY(log n) = L (logarithmic space).

Part (3) is the most surprising claim: it asserts that entropy complexity has no "speed-up" theorem — you cannot simulate n² entropy with n entropy, even approximately.

**Test**:
1. Formalize ENTROPY(f) as a complexity class within the EBC framework.
2. Prove the containments P ⊆ ENTROPY(n^c) by analyzing standard algorithms.
3. For part (3), attempt to prove a hierarchy theorem using diagonalization.
4. Test computationally: implement sorting algorithms (merge sort vs. bubble sort) and measure their actual Landauer costs. Merge sort should use O(n log n) entropy; bubble sort O(n²).

**Impact**: If the entropy hierarchy is strict, it provides a new complexity hierarchy that is *physically meaningful* — each level corresponds to a different thermodynamic regime. This would be the first complexity hierarchy with a direct physical interpretation. If not strict, it means entropy can be "recycled" in unexpected ways.

**Catalog References**: `Speculative/ComplexityPhysics/Theorems.lean` (entropy_budget_monotone, entropy_gap_unbounded), `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm)

**Proof Strategy**: 
1. Define ENTROPY(f) formally as `{L | ∃ EBS with budget = f(n) that decides L}`.
2. For P ⊆ ENTROPY(n^c): any P algorithm makes poly(n) steps, each costing at most 1 bit.
3. For hierarchy strictness: adapt the time hierarchy theorem proof, using the entropy gap theorem to show that more entropy budget allows solving strictly more problems.
4. The diagonalization argument: construct a language L_k that can be decided with n^(k+1) entropy but not n^k entropy.

**Domain Bridges**: Computation (complexity classes) ↔ Physics (entropy budget) ↔ Logic (hierarchy theorems)

**Lineage**: Directly extends entropy_budget_monotone and entropy_gap_unbounded.

**Ambition**: grand_challenge

---

### Direction 3: Landauer Cost of Specific Algorithms

**Conjecture**: The Landauer cost of comparison-based sorting of n elements is exactly ⌈log₂(n!)⌉ · kT · ln(2), matching the information-theoretic lower bound. Any sorting algorithm that uses fewer comparisons than ⌈log₂(n!)⌉ must use non-comparison operations that cost additional entropy. In other words, the Landauer cost provides an independent proof of the Ω(n log n) comparison-based sorting lower bound.

**Test**:
1. Formalize comparison-based sorting in the EBC framework, where each comparison is an IrreversibleStep that halves the search space.
2. Prove that ⌈log₂(n!)⌉ comparisons are necessary via the entropy budget.
3. Implement merge sort and quicksort in the framework and verify their entropy costs match the theoretical predictions.
4. Check boundary case: for n = 1, cost should be 0; for n = 2, cost should be kT·ln(2).

**Impact**: This would be the first formally verified proof that the sorting lower bound is a *physical law*, not just an information-theoretic bound. It demonstrates that the EBC framework can recover known complexity bounds from thermodynamic principles.

**Catalog References**: `Speculative/ComplexityPhysics/Foundations.lean` (IrreversibleStep, landauerCost), `Speculative/ComplexityPhysics/Theorems.lean` (one_bit_erasure_cost, step_count_bounded_by_budget)

**Proof Strategy**:
1. Model a comparison as an IrreversibleStep from Fin(n!) (permutation space) to two halves.
2. After k comparisons, the remaining search space has size at most n!/2^k.
3. The search terminates when the space has size 1, requiring k ≥ log₂(n!).
4. Each comparison costs kT·ln(2) by one_bit_erasure_cost, giving total cost ≥ ⌈log₂(n!)⌉ · kT·ln(2).

**Domain Bridges**: Computation (sorting algorithms) ↔ Physics (Landauer cost) ↔ EML (information theory)

**Lineage**: Builds on IrreversibleStep, one_bit_erasure_cost, step_count_bounded_by_budget.

**Ambition**: extension

---

### Direction 4: Reversible Computing and Bennett's Pebble Game

**Conjecture**: In the EBC framework, any irreversible computation of T steps on S space can be made reversible using O(T · S) time and O(S · log T) space (Bennett's result). Formalizing this in the EBC framework gives: the entropy cost of simulating an irreversible computation reversibly is exactly 0, but the time overhead is multiplicative. This creates a time-entropy tradeoff: you can eliminate entropy cost entirely at the price of a polynomial time increase.

**Test**:
1. Formalize Bennett's pebble game in Lean as a ReversibleComputation.
2. Prove that the reversible simulation has zero Landauer cost (using reversible_comp_is_id).
3. Prove the time overhead bound: the reversible simulation takes O(T · S) steps.
4. Test: implement a reversible AND gate using Toffoli gates and verify zero entropy cost.

**Impact**: This direction explores the *escape hatch* from the entropy budget: reversible computing avoids Landauer costs but pays in time. The time-entropy tradeoff is fundamental to understanding whether thermodynamics truly constrains complexity or merely introduces overhead.

**Catalog References**: `Speculative/ComplexityPhysics/Foundations.lean` (ReversibleComputation), `Speculative/ComplexityPhysics/Theorems.lean` (reversible_comp_is_id, reversible_involution)

**Proof Strategy**:
1. Define a `PebbleGame` structure modeling Bennett's construction.
2. Show the pebble game produces a ReversibleComputation.
3. Count the number of pebbling steps to get the time bound.
4. Use reversible_comp_is_id to show zero entropy cost.

**Domain Bridges**: Computation (reversible circuits) ↔ Physics (entropy-free computation) ↔ Cryptography (side-channel resistance)

**Lineage**: Extends reversible_comp_is_id and ReversibleComputation.

**Ambition**: extension

---

### Direction 5: Entropy Production Rate and Computational Speed Limits

**Conjecture**: There exists a fundamental speed limit on computation analogous to the Margolus-Levitin bound: no physical system can perform more than 2E/(πℏ) irreversible operations per second, where E is the system's energy above ground state. Combined with the Landauer cost per operation, this gives a maximum computational throughput of 2E/(πℏ · kT · ln 2) irreversible bits per second. For a 1-watt computer at room temperature, this is approximately 4.4 × 10³¹ bit operations per second.

**Test**:
1. Formalize the Margolus-Levitin bound as an axiom in the EBC framework.
2. Derive the maximum bit rate from the bound and Landauer's principle.
3. Compute the maximum bit rate for realistic parameters (1W, 300K, 1 kg).
4. Compare with actual computer performance (modern CPUs achieve ~10¹⁰ ops/sec, far below the limit).

**Impact**: This connects the EBC framework to quantum mechanics (Margolus-Levitin) and gives absolute physical limits on computation. The gap between current computers and the physical limit (~10²¹ factor) suggests enormous room for improvement in computational efficiency.

**Catalog References**: `Speculative/ComplexityPhysics/Theorems.lean` (step_count_bounded_by_budget), `Shared/CryptoEntropyBridges.lean` (maxwell_demon_bound)

**Proof Strategy**:
1. Introduce the Margolus-Levitin bound as a parameter in EntropyBudgetSystem.
2. Derive budget = (2E · τ) / (πℏ · kT · ln 2) from the bound.
3. Apply step_count_bounded_by_budget with c = kT·ln(2).
4. Compute explicit values for standard physical parameters.

**Domain Bridges**: Physics (quantum speed limits) ↔ Computation (throughput bounds) ↔ EML (information rates)

**Lineage**: Builds on step_count_bounded_by_budget and the full EBC framework.

**Ambition**: extension

**Novelty estimate**: 0.6
**Breakthrough potential**: 0.6
Research domain: Computation
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v5 Depth Requirements (MANDATORY — WORLD-CLASS STANDARD)

You are working on the frontier of mathematics. The Catalog has 100+ research
packages already. Each new cycle must contribute something genuinely new —
not a rephrasing, not a textbook exercise, not a "mathematics of X" parlor trick.

### STEP 1: PLAN (REQUIRED — before any Lean code)

Before writing any `.lean` file, you MUST output a `## Plan` section that
states, in plain prose:

- **Strategy**: Grothendieck path (define a new structure, prove its properties)
  OR Cauchy path (extend an existing catalog result). Choose the one that fits
  the concept. Do BOTH only if the concept genuinely demands it.
- **Files**: What `.lean` files you will create and what each contains.
  Use sensible names. No fixed count.
- **Theorems**: A list of the theorems you will prove, with one-sentence statements.
- **Why this is non-trivial**: A paragraph explaining the structural insight
  that makes this work world-class. If you cannot write this paragraph, the
  work is not world-class. Pick a different concept.

The Plan is not optional. Cycles that skip the Plan are rejected.

### STEP 2: PEGB for EVERY theorem (strict)

For EACH theorem you prove, you MUST provide all four of:

- **P**roof: A complete, non-trivial Lean 4 proof.
- **E**xample: A concrete worked example (an `example` block or a specific instance).
- **G**eneralization: A one-level-up generalization (a stronger statement, a
  broader class, a higher categorical level). State it as a `theorem` or `lemma`
  with `sorry` if proving it would take the cycle too far — but STATE it.
- **B**oundary: A counterexample or limit-case analysis. When does the result
  fail? What assumptions are essential?

"Top 3-5 theorems" is no longer accepted. EVERY theorem you produce must have
full PEGB. If you produce 2 theorems with full PEGB, that's better than 5 theorems
with PEGB on only 2.

### STEP 3: Anti-patterns (REJECTED outright)

The following tactics are BLACKLISTED for the primary proof of any non-trivial theorem:

- `native_decide`, `decide`, `norm_num`, `rfl` — unless the statement is genuinely
  a numeric/equality fact and the tactic is doing real work (not papering over
  a structural insight).
- `Aesop` — unless the goal is provably trivial (≤ 3 hypotheses, no arithmetic).
- `omega`, `linarith` on quantified goals — these are not "proofs" of structural
  statements.
- `simp only []` with no explicit simp set — this is "let the lemma solver figure it out."

If your only proof of a non-trivial theorem uses one of these, the theorem is not
worth proving. Find a structural proof, or drop the theorem.

### STEP 4: Novelty check

A theorem is "novel" only if a working mathematician in the area would say
"I haven't seen that before." Test yourself:

- Is the statement in a textbook? If yes, find a non-trivial generalization.
- Is the statement a rephrasing of a known result? If yes, the cycle is not novel.
- Is the proof essentially the same as a known proof? If yes, the contribution
  is the statement, not the proof — make sure the statement is genuinely new.

"Mathematics of X" where X is a real-world phenomenon (memes, dreams, consciousness,
art, music, social networks) is NOT a mathematical contribution unless you formalize
X as a precise mathematical object first. If you cannot formalize X rigorously, pick
a different topic.

### STEP 5: Either path (Aristotle's choice)

You are NOT required to follow a specific path. Choose the one that fits the concept:

**Grothendieck path** (define a new structure):
- Invent a new operator, category, algebraic variety, or combinatorial object.
- State its defining properties as axioms or definitions.
- Prove 2-4 non-obvious theorems about it.
- Best for: novel concepts, unexplored territory, "what if we defined X this way?".

**Cauchy path** (extend an existing result):
- Pick a specific catalog theorem (cite it by name).
- Generalize, strengthen, or bridge it.
- Prove the new version is strictly stronger or more general.
- Best for: deepening the catalog, building on existing strength.

You may do BOTH if the concept requires it. But the Plan must justify why both paths
are needed in a single cycle.

### STEP 6: Theorem count

No fixed count. Some concepts deserve 2 deep theorems. Some deserve 6. The Plan
must justify the count. The quality bar is "every theorem has full PEGB" — not
"produce a specific number".

### STEP 7: Cite your sources

Your `## Plan` and any prose must reference specific catalog results by name or path
when you build on them. The catalog is the substrate; you are growing new math on it.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
