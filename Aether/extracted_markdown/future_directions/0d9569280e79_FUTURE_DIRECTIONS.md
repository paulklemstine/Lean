# Future Research Directions

## Synthesis

The confluence result for the tensor distributivity rewrite system opens a systematic research program connecting three themes: (1) extending the rewrite system to richer tensor algebras while preserving confluence, (2) bridging to compiler optimization and equality saturation, and (3) connecting to categorical coherence theory for monoidal-distributive categories. Each direction below builds on the formalized infrastructure — the ACEq relation, the distPotential measure, the distributing combinators — and targets specific, testable conjectures.

---

## Direction 1: Typed Higher-Order Tensor Rewriting with Binding

**Conjecture:** The tensor distributivity fragment extends to a simply-typed lambda calculus with tensor operations, and confluence modulo AC + β-equivalence holds for the combined system when distributivity rules are restricted to fire only at base types.

**Test:** Formalize a small simply-typed tensor calculus (scalars, vectors, matrices as base types; function types for parameterized expressions). Add the 8 distributivity rules + β-reduction. Enumerate critical pairs between β-reduction and distributivity rules. Check computationally (by BFS on terms of depth ≤ 4) whether all critical peaks are joinable modulo βη-equivalence + AC.

**Impact:** This would connect tensor simplification to the rich theory of higher-order rewriting (Nipkow, 1991; van Oostrom, 1994), enabling certified optimization of tensor programs written in functional languages. A negative result (non-confluence) would identify exactly which interactions between β-reduction and distributivity cause trouble, guiding the design of restricted calculi.

**Catalog References:** `Catalog/Pythagorean/TensorSortedRewrite.lean` (sorted tensor language), `Catalog/Pythagorean/TensorConfluence.lean` (confluence infrastructure).

**Proof Strategy:** Use the modular confluence technique (Toyama's theorem for disjoint combinations) to separate β-reduction from distributivity. The key technical challenge is the smulVec/dot interaction with λ-abstraction.

**Domain Bridges:** Proof theory (Curry-Howard for linear types), compiler optimization (partial evaluation of tensor kernels).

**Lineage:** Extends the current 8-rule system to the next natural level of expressiveness.

**Ambition:** Grand challenge — would unify term rewriting theory for algebra with lambda calculus theory.

---

## Direction 2: Equality Saturation and E-Graph Extraction for Tensor Normal Forms

**Conjecture:** The normalizeCanon algorithm is optimal in the following sense: among all representations of a tensor expression's normal form modulo AC, the one produced by normalizeCanon minimizes the number of distinct subexpressions (maximal sharing). Equivalently, the e-graph saturation of the AC-equivalence class has normalizeCanon's output as the smallest extraction.

**Test:** Implement an e-graph representation of tensor expressions. Saturate with the AC axioms + scalMul-scalAdd distribution. Extract the smallest term. Compare with normalizeCanon output on 1000 randomly generated terms of size 5-20. Measure the sharing ratio (number of unique subterms / total term size).

**Impact:** This bridges the formal rewriting theory to the practical equality saturation paradigm used in systems like egg (Willsey et al., 2021) and Metatheory.jl. A positive result would make normalizeCanon the extraction function for a tensor e-graph optimizer. A negative result would identify cases where sharing-aware normalization improves on syntactic normalization.

**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean` (normalizeCanon), `Catalog/Pythagorean/EqualitySaturationExtraction.lean`.

**Proof Strategy:** Define a cost model on TensorExpr (number of constructor applications). Prove normalizeCanon is locally optimal: no single AC rearrangement reduces cost. Then attempt global optimality by analyzing the structure of AC-equivalence classes.

**Domain Bridges:** Compiler optimization (phase ordering), algebraic combinatorics (Catalan numbers for binary tree shapes).

**Lineage:** Direct extension of normalizeCanon's completeness theorem.

**Ambition:** Solid extension — connects two active research communities (rewriting theory and equality saturation).

---

## Direction 3: Quantum Circuit Rewriting via Tensor Distributivity

**Conjecture:** The tensor distributivity rewrite system, when instantiated with matrices from SU(2)⊗SU(2) (2-qubit gates), produces a confluent modulo AC normal form for quantum circuits on 2 qubits, where AC-equivalence corresponds to commutativity of parallel gates.

**Test:** Represent 2-qubit quantum circuits as tensor expressions: gates are matrices, state vectors are vec, composition is mulVec. Enumerate all 2-qubit circuits of depth ≤ 5 using {CNOT, H, T} gate set. Apply distributivity rules (distributing controlled gates over superpositions). Check confluence by BFS.

**Impact:** Quantum circuit optimization currently relies on ad hoc peephole rules. A confluent rewrite system would provide canonical circuit forms, enabling deterministic circuit comparison and certified optimization. **The key insight is** that distributivity in the tensor algebra precisely corresponds to the linearity of quantum mechanics — distributing a unitary over a superposition is the algebraic content of quantum parallelism.

**Why now?** The tensor rewriting infrastructure formalized here provides the first machine-verified foundation for relating term rewriting to quantum circuit simplification. Quantum computing hardware is reaching the scale where certified optimization matters.

**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean`, `Catalog/Pythagorean/TensorSortedRewrite.lean`.

**Proof Strategy:** Instantiate the 3-sorted tensor calculus with ℂ²-valued vectors and 2×2 complex matrices. Verify that the 8 rules remain sound. Analyze critical pairs specific to the quantum gate basis.

**Domain Bridges:** Quantum computing (circuit optimization), category theory (compact closed categories for quantum protocols).

**Lineage:** Novel application of the confluence theorem to a new domain.

**Ambition:** Grand challenge — paradigm-shifting if it leads to a general confluence theory for quantum circuit rewriting.

---

## Direction 4: Tropical Tensor Distributivity and Min-Plus Normal Forms

**Conjecture:** The 8 distributivity rules, interpreted over the tropical semiring (ℝ ∪ {∞}, min, +), remain confluent modulo AC, and the normal forms correspond to shortest-path decompositions in weighted graphs.

**Test:** Implement the tropical version of the tensor rewrite system. Generate tropical tensor expressions corresponding to adjacency matrices of random weighted graphs (n = 5..20). Normalize using the tropical analog of normalizeCanon. Compare normal forms with known shortest-path decompositions.

**Impact:** This would connect tensor rewriting to combinatorial optimization, providing a new algebraic perspective on shortest-path algorithms. **The key insight is** that tropical distributivity (min distributes over +) has the same algebraic form as classical distributivity, so the confluence proof should transfer.

**Why now?** Tropical geometry and combinatorics have seen explosive growth. Connecting them to term rewriting theory via the tensor calculus creates a new bridge between algebra and optimization.

**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean`, `Catalog/Tropical/`.

**Proof Strategy:** Show that the distPotential measure is semiring-independent (it counts structural patterns, not numerical values). Transfer the confluence proof by abstracting over the coefficient semiring.

**Domain Bridges:** Combinatorial optimization (shortest paths, assignment problems), algebraic statistics (tropical Grassmannians).

**Lineage:** Extends the semiring-parametric aspects of the tensor calculus.

**Ambition:** Solid extension with novel domain bridge.

---

## Direction 5: Automated Critical Pair Analysis for Many-Sorted Rewrite Systems

**Conjecture:** There exists an efficient algorithm (polynomial in the number of rules × term depth) that, given a many-sorted rewrite system, automatically enumerates all critical pairs and checks joinability modulo a specified equational theory (AC, distributivity, etc.).

**Test:** Implement the algorithm for the tensor calculus. Input: the 8 rules + sort discipline. Output: complete list of critical pairs with joinability witnesses. Verify that the output matches the manual analysis in this paper. Then apply to extensions with 12, 16, 20 rules (adding trace, transpose, Kronecker product operations).

**Impact:** This would automate the most labor-intensive part of confluence proofs, enabling rapid exploration of rewrite system extensions. **The key insight is** that the sort discipline dramatically prunes the space of possible overlaps — most term overlaps are sort-incorrect and can be eliminated without evaluation.

**Why now?** The manual critical pair analysis in this work revealed the essential overlap between rules 7 and 8. Automating this process would have caught it immediately and would scale to the larger systems needed for practical tensor optimization.

**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean` (manual critical pair analysis), `Catalog/Pythagorean/KnuthBendixCompletion.lean`.

**Proof Strategy:** Adapt the Knuth-Bendix completion algorithm to many-sorted signatures with AC-theories. The key technical contribution would be efficient unification modulo AC in the sorted setting.

**Domain Bridges:** Automated reasoning (completion procedures), programming language design (type-directed optimization).

**Lineage:** Methodological extension — automating the proof technique rather than extending the mathematical content.

**Ambition:** Solid extension with high practical impact.
