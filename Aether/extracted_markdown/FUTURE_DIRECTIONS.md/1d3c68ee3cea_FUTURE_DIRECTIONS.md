# Future Directions: Tropical Foundations for Optimal Rewriting

## Synthesis

The cost-minimality theorem and tropical cost algebra established in this work open a rich landscape of research directions that bridge rewrite theory, tropical geometry, information theory, and compiler optimization. The central insight — that normalization is simultaneously simplification, optimization, and compression — suggests that these three perspectives can be unified at a deeper structural level.

The directions below form a coherent research program: Directions 1-2 extend the cost-minimality theorem to richer settings (multi-cost, modular), Direction 3 bridges to tropical algebraic geometry, Direction 4 connects to algorithmic applications in equality saturation, and Direction 5 poses a grand challenge connecting to quantum information theory.

---

## Direction 1: Multi-Cost Pareto Optimization via Tropical Polyhedra

**Conjecture**: For a convergent rewrite system R with k cost functions c₁, ..., cₖ, each cost-compatible, the normal form lies on the Pareto frontier of the equivalence class in ℕᵏ. Moreover, the Pareto frontier of each equivalence class is a tropical polytope.

**Test**: For 100 randomly generated convergent systems with k = 3 cost functions:
1. Compute the cost vectors (c₁(t), c₂(t), c₃(t)) for all terms equivalent to each seed term (up to depth 12).
2. Compute the Pareto frontier.
3. Verify the normal form lies on the Pareto frontier.
4. Check whether the Pareto frontier is a tropical polytope (vertices connected by tropical line segments).

**Impact**: If true, this extends cost-minimality from single objectives to multi-objective optimization, directly relevant to compiler optimization where multiple metrics (speed, size, power) must be balanced. The tropical polytope structure would provide efficient algorithms for Pareto extraction.

**Catalog References**: 
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`: `convergent_rewrite_induces_optimizer`
- `Pythagorean/TropicalCostMinimality.lean`: `normal_form_cost_minimal`

**Proof Strategy**: Extend the cost-minimality proof to vector-valued costs. The key insight is that the tropical semiring structure extends coordinate-wise to ℕᵏ, where tropical addition becomes the Pareto minimum operation.

**Domain Bridges**: Multi-objective optimization, tropical convexity, compiler optimization

**Lineage**: Direct extension of the cost-minimality theorem to vector-valued costs.

**Ambition**: ★★★☆☆ (solid extension)

---

## Direction 2: Modular Convergence and Compositional Cost Minimality

**Conjecture**: If a rewrite system R is decomposed into modules R₁, ..., Rₘ, each convergent and pairwise commuting (Church-Rosser modulo), and each module has its own cost function cᵢ compatible with Rᵢ, then the modular normal form minimizes the aggregate cost c = c₁ + ... + cₘ.

**Test**: For 50 randomly generated modular systems with m = 3 modules:
1. Verify modular convergence (each module confluent and terminating).
2. Verify pairwise commutation.
3. Compute modular normal forms.
4. Verify aggregate cost minimality against exhaustive enumeration.

**Impact**: Most practical rewrite systems are modular (e.g., separate arithmetic, boolean, and control-flow optimizations in a compiler). Compositional cost minimality would provide a modular correctness argument for multi-pass optimization.

**Catalog References**:
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`: `compose_normalizers_sound`
- `Pythagorean/TropicalCostMinimality.lean`: `normal_form_cost_minimal`

**Proof Strategy**: Use the composition theorem from the catalog to decompose the problem. The key challenge is showing that inter-module interactions don't break cost minimality.

**Domain Bridges**: Modular programming, compiler passes, category theory (modular monads)

**Lineage**: Extends `compose_normalizers_sound` to cost minimality.

**Ambition**: ★★★☆☆ (solid extension)

---

## Direction 3: Tropical Gröbner Bases for Non-Convergent Systems

**Conjecture**: For a non-convergent rewrite system R (terminating but not confluent), the set of all normal forms of a term t (under different reduction strategies) forms a tropical ideal in the tropical semiring of costs. The tropical Gröbner basis of this ideal characterizes the "essential" normal forms.

**Test**: For 100 non-confluent terminating systems:
1. Enumerate all normal forms of each term (there may be multiple).
2. Compute the cost set {c(nf) : nf is a normal form of t}.
3. Check whether this cost set has the structure of a tropical ideal (closed under tropical addition and multiplication).
4. Compute the tropical Gröbner basis and verify it characterizes the "essential" normal forms.

**Impact**: This would extend the tropical framework beyond convergent systems to the much larger class of terminating systems. Non-confluent systems arise naturally in optimization where multiple valid simplifications exist (e.g., different register allocation strategies).

**Catalog References**:
- `Pythagorean/TropicalCostMinimality.lean`: `TropicalCostAlgebra`, tropical semiring properties
- `Catalog/Pythagorean/ConvergentRewriteSystems.lean`: `Confluent`, `Terminating`

**Proof Strategy**: Define tropical ideals of cost sets. Show closure under tropical operations. Adapt the Buchberger algorithm to the tropical setting on cost sets.

**Domain Bridges**: Tropical algebraic geometry, Gröbner basis theory, computational algebra

**Lineage**: Extends the tropical cost algebra to non-convergent settings.

**Ambition**: ★★★★☆ (grand challenge)

---

## Direction 4: Tropical Extraction for Equality Saturation

**Conjecture**: In equality saturation (e-graph based optimization), the extraction problem (finding the cheapest term in the e-graph) can be solved in polynomial time when the underlying rewrite system is convergent, by computing the tropical projection (normal form) instead of solving an NP-hard extraction problem.

**Test**: 
1. Implement an e-graph framework for small term languages.
2. For convergent rule sets, compare: (a) exhaustive e-graph extraction via ILP, (b) direct normalization.
3. Verify they produce the same result.
4. Measure speedup: extraction is NP-hard in general, but should be polynomial for convergent systems.

**Impact**: Equality saturation (egg, egglog) is a dominant paradigm in compiler optimization. Identifying when the extraction problem is tractable (i.e., when the system is convergent) would be practically transformative.

**Catalog References**:
- `Pythagorean/TropicalCostMinimality.lean`: `normal_form_cost_minimal`, `tropical_cost_extract`
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`: `convergent_rewrite_induces_optimizer`

**Proof Strategy**: Show that convergence of the rule set implies the e-graph's cost function is a tropical valuation, which can be minimized greedily.

**Domain Bridges**: Compiler optimization, integer linear programming, complexity theory

**Lineage**: Applies cost-minimality theorem to the extraction problem in equality saturation.

**Ambition**: ★★★☆☆ (solid extension with high practical impact)

---

## Direction 5: Quantum Rewrite Systems and Von Neumann Entropy Cost

**Conjecture**: In a quantum rewrite system where terms are quantum circuits and the cost function is the von Neumann entropy of the output density matrix, convergent quantum rewrite systems produce normal forms that minimize entropy — i.e., maximize quantum coherence.

**Test**:
1. Define a small quantum circuit rewrite system (e.g., Clifford+T gate set with known identities).
2. Verify convergence of the rule set.
3. For each circuit, compute the normal form and its output entropy.
4. Verify entropy minimality against all equivalent circuits up to bounded depth.

**Impact**: This would connect rewrite theory to quantum information theory, providing a formal foundation for quantum circuit optimization. The entropy-minimality property would mean that circuit simplification preserves quantum resources optimally.

**Catalog References**:
- `Pythagorean/TropicalCostMinimality.lean`: `normal_form_cost_minimal`, `cost_compatible_wf`

**Proof Strategy**: The key challenge is showing that von Neumann entropy (a real-valued function) can be discretized to ℕ while preserving cost compatibility. Alternatively, extend the framework to ℝ-valued cost functions with well-foundedness replaced by a descending chain condition.

**Domain Bridges**: Quantum information theory, quantum computing, von Neumann algebras

**Lineage**: Grand challenge extending cost minimality from classical to quantum systems.

**Ambition**: ★★★★★ (paradigm-shifting grand challenge)
