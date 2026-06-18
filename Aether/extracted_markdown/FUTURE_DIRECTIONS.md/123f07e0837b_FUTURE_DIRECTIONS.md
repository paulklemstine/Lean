# Future Directions: Configuration Graph Pathwidth

## Synthesis

The formally verified bridge between clause space and pathwidth opens a research program that flows in three directions: (1) deepening the theoretical correspondence from individual traces to full configuration graphs, (2) importing graph-theoretic lower bound machinery into proof complexity, and (3) exploiting the decomposition structure algorithmically for SAT solving and proof search. The five directions below form a coherent ladder: Direction 1 generalizes the proven theorems to the full conjecture; Directions 2-3 exploit the bridge in both directions; Direction 4 extends to richer proof systems; Direction 5 connects to statistical mechanics and phase transitions. Each direction builds on the formal definitions and theorems in `Pythagorean/ConfigGraph/Defs.lean` and `Pythagorean/ConfigGraph/Theorems.lean`.

---

### Direction 1: Universal Constant Conjecture for Full Bounded Configuration Graphs

**Conjecture**: There exists a universal constant c > 0 such that for every unsatisfiable CNF formula F with minimum clause space s, the pathwidth of the s-bounded configuration graph BConfGraph(F, s) is at most c · s.

**Test**: Enumerate all unsatisfiable CNFs over n ≤ 4 variables. For each, compute exact minimum clause space (by exhaustive trace search) and exact pathwidth of BConfGraph(F, s) (by brute-force or dynamic programming for |V| ≤ 20). Verify pw(BConfGraph(F,s)) ≤ c · s for c = 1, 2, 4. A single counterexample with ratio > c disproves the conjecture for that c.

**Impact**: If true, this would mean clause space lower bounds can be attacked purely via graph-theoretic pathwidth lower bounds (brambles, separators, minor theory). This would be a paradigm shift in proof complexity.

**Catalog References**: `Pythagorean/ConfigGraph/Defs.lean` (BoundedConfigAdj, minClauseSpace), `Pythagorean/ConfigGraph/Theorems.lean` (pathwidth_le_of_spaceBound, exists_decomp_of_bounded_trace).

**Proof Strategy**: Strategy B from the original formulation—use vertex separation equivalence. Define a linear order on configurations from an optimal proof trace. Show the frontier set at each cut of BConfGraph(F,s) is bounded by the number of "active" clauses at that cut, which is ≤ s. This requires a monotonicity/retraction argument showing the full graph doesn't have significantly wider bottlenecks than any single trace.

**Domain Bridges**: Graph minor theory (Robertson-Seymour), parameterized complexity, SAT solver memory optimization.

**Lineage**: Extends Theorems 1-3 from single traces to the full configuration graph.

**Ambition**: Grand challenge. Would unify proof complexity and structural graph theory.

---

### Direction 2: Forbidden Minor Characterization of Hard Formulas

**Conjecture**: Formulas requiring clause space ≥ k can be characterized by the presence of a specific graph minor in their configuration graph (analogous to the grid minor theorem for treewidth). Specifically, BConfGraph(F, s) contains a path-like minor of width Ω(s).

**Test**: For all unsatisfiable CNFs over 3 variables, compute BConfGraph(F, s) and search for the largest grid minor or path minor. Correlate minor size with clause space. If clause space k formulas consistently have path minors of width ≥ k/c for some constant c, this supports the conjecture.

**Impact**: Would provide a purely combinatorial certificate that a formula is hard (requires large space), importable from Robertson-Seymour theory.

**Catalog References**: `Pythagorean/ConfigGraph/Defs.lean` (BoundedConfigAdj, boundedConfigAdj_mono), `Pythagorean/ConfigGraph/Theorems.lean` (clauseSpace_le_maxBagSize_of_valid_decomp).

**Proof Strategy**: Use the excluded grid theorem: if pathwidth is large, a large grid minor exists. Combined with the conjecture from Direction 1, large clause space ⟹ large pathwidth ⟹ large grid minor ⟹ structural obstruction.

**Domain Bridges**: Graph minor theory, topological graph theory, extremal combinatorics.

**Lineage**: Depends on Direction 1. Extends the bridge to forbidden-minor characterizations.

**Ambition**: Grand challenge. Would be the first forbidden-minor theorem in proof complexity.

---

### Direction 3: Pathwidth-Guided SAT Solving

**Conjecture**: A SAT solver that computes an approximate path decomposition of the (estimated) configuration graph and uses it to guide clause learning and forgetting will achieve lower peak memory usage than standard CDCL solvers on structured instances, with at most a constant factor overhead in time.

**Test**: Implement a prototype solver that (a) estimates BConfGraph structure from the clause database, (b) computes an approximate path decomposition, (c) uses the decomposition to prioritize which clauses to keep in memory. Compare peak memory and solving time against MiniSat/CaDiCaL on SAT Competition benchmarks. Measure the correlation between estimated pathwidth and actual peak memory.

**Impact**: A practical SAT solving paradigm informed by structural graph theory, potentially solving memory-bound instances more efficiently.

**Catalog References**: `Pythagorean/ConfigGraph/Defs.lean` (traceToPathDecomposition, PathDecomposition.width).

**Proof Strategy**: The theoretical foundation is Theorem 2: bounded traces yield bounded-width decompositions. The algorithmic challenge is computing decompositions approximately and online during solving.

**Domain Bridges**: SAT solving, parameterized algorithms, dynamic programming on decompositions.

**Lineage**: Builds directly on the trace decomposition construction.

**Ambition**: Solid extension. Translates theory into practice.

---

### Direction 4: Extension to Stronger Proof Systems

**Conjecture**: The clause-space-to-pathwidth correspondence extends to polynomial calculus (monomial space) and cutting planes (inequality space), with the same universal constant or a constant depending only on the proof system.

**Test**: Define configuration graphs for polynomial calculus (configurations = sets of monomials) and cutting planes (configurations = sets of inequalities). Enumerate small instances (n ≤ 3 variables). Compute space and pathwidth. Verify the proportionality constant.

**Impact**: Would unify space complexity across proof systems under a single graph-theoretic framework.

**Catalog References**: `Pythagorean/ConfigGraph/Defs.lean` (ResolutionTrace, PathDecomposition — the definitions are already system-agnostic).

**Proof Strategy**: The trace decomposition construction (Theorem 1) is already generic over the clause/monomial type α. The key question is whether the interval property holds or can be enforced in these richer systems.

**Domain Bridges**: Algebraic proof complexity, polynomial optimization, semidefinite programming.

**Lineage**: Direct generalization of the current framework.

**Ambition**: Solid extension. Broadens the theory substantially.

---

### Direction 5: Phase Transitions in Configuration Graph Pathwidth

**Conjecture**: For random k-CNF formulas at the satisfiability threshold (clause-to-variable ratio ≈ 2^k ln 2), the pathwidth of the bounded configuration graph undergoes a phase transition: it jumps from O(1) to Ω(n) as the ratio crosses the threshold. Furthermore, the transition width correlates with the energy barrier in the associated constraint satisfaction landscape.

**Test**: Generate random 3-CNF formulas at ratios r = 3.0, 3.5, 4.0, 4.27, 4.5, 5.0 with n = 8, 10, 12 variables. For each, estimate clause space and compute BConfGraph pathwidth (or upper bounds via heuristic decompositions). Plot pathwidth vs. r and look for a sharp transition near r ≈ 4.27. Compare with known phase transition results for resolution space.

**Impact**: Would connect proof complexity phase transitions to graph-theoretic invariants and statistical mechanics energy landscapes, potentially explaining why SAT solvers slow down near the threshold.

**Catalog References**: `Pythagorean/ConfigGraph/Defs.lean` (BoundedConfigAdj, minClauseSpace), `Pythagorean/ConfigGraph/Theorems.lean` (all main theorems).

**Proof Strategy**: Use the trace-to-decomposition construction to convert known resolution space lower bounds at the threshold (Ben-Sasson, Nordström) into pathwidth lower bounds. For the upper bound, use the vertex separation characterization of pathwidth.

**Domain Bridges**: Random graph theory, statistical mechanics, phase transitions, constraint satisfaction.

**Lineage**: Combines Direction 1 with probabilistic proof complexity.

**Ambition**: Grand challenge. Would establish the first rigorous connection between proof complexity phase transitions and graph-theoretic invariants.
