# Future Directions: Configuration Graph Pathwidth

## Synthesis

The results in this project establish the first rigorous bridge between resolution proof complexity (clause space) and structural graph theory (pathwidth). The core insight—that proof memory states form a graph whose layout invariants control proof difficulty—opens a bidirectional transfer: graph-theoretic tools can attack proof complexity problems, and proof complexity intuition can guide graph algorithm design. The directions below form a coherent research program: Direction 1 removes the regularity restriction, Direction 2 tackles the central conjecture, Direction 3 provides computational tools for testing, Direction 4 bridges to treewidth and broader decomposition theory, and Direction 5 connects to practical SAT solving. Together, they chart a path from the current foundational results toward a complete graph-geometric theory of proof resources.

---

## Direction 1: Interval Closure for General Traces

**Conjecture:** For any (possibly non-persistent) resolution refutation trace π with clause space s, the interval closure of the trace configurations forms a valid path decomposition whose width is at most f(s) for some function f with f(s) = O(s²).

**Test:** Implement interval closure (for each clause, fill it into all bags between its first and last appearance) and measure the maximum bag size after closure. Test on all unsatisfiable 2-variable and 3-variable CNFs. Compute the ratio closure_width / clause_space and determine whether it is bounded by a polynomial function.

**Impact:** This would extend our Theorem 3 (`persistent_trace_pathwidth_le`) from persistent traces to arbitrary traces, removing the most significant restriction in the current theory. It would make the pathwidth framework applicable to all resolution refutations, including those arising in modern CDCL solvers.

**Catalog References:** `Pythagorean/ConfigGraphPathwidth.lean` — `persistent_trace_pathwidth_le`, `IntervalProperty`

**Proof Strategy:** Define the interval closure operation on a list of Finsets. Prove that closure preserves vertex and edge covering. Bound the bag size increase: if a clause c has k "gaps" in its appearance, the closure adds c to those gap positions. The total number of live clauses at any position is bounded by the number of clauses whose first appearance is before and last appearance is after that position. Use a counting argument to bound this by s² in the worst case, or conjecture a tighter s · log(s) bound.

**Domain Bridges:** Programming languages (closure corresponds to variable liveness analysis in compilers), model checking (state space traversal with re-visitation).

**Lineage:** Extends the current persistent trace theory (Strategy A in the project) toward the full generality needed for Strategy B (elimination ordering approach).

**Ambition:** 🟡 Solid extension — technically challenging but within reach of current methods.

---

## Direction 2: Full Configuration Graph Pathwidth Conjecture

**Conjecture:** There exists a universal constant c > 0 such that for every unsatisfiable CNF formula F, pathwidth(ConfGraph_s(F)) ≤ c · s, where s = minClauseSpace(F).

**Test:** Exhaustively verify for all unsatisfiable CNFs on ≤ 3 variables. Compute exact pathwidth of the bounded configuration graph (restricted to the reachable component) and determine the smallest constant c that suffices. Test separately on minimally unsatisfiable formulas, where the conjecture may be tighter.

**Impact:** This is the central open question of the research program. A positive resolution would mean that *every* property of the configuration graph that depends on pathwidth—separator structure, forbidden minors, dynamic programming tractability—transfers directly to clause space bounds. This would provide a complete structural explanation for why some formulas require high clause space.

**Catalog References:** `Pythagorean/ConfigGraphPathwidth.lean` — `confGraph`, `confGraphAdj_mono`, `confGraph_subgraph`

**Proof Strategy:** Two approaches: (A) Show that the proof-relevant core of the configuration graph (configs reachable from ∅ and co-reachable from a contradiction-containing config) has a path decomposition constructible from an optimal refutation trace. This requires Direction 1 as a prerequisite. (B) Use the elimination ordering / vertex separation equivalence for pathwidth. Define a linear order on configurations induced by a BFS or DFS of the configuration graph and show the frontier size at each cut is bounded by O(s). This is more ambitious but would give a tighter bound.

**Domain Bridges:** Structural graph theory (graph minor theory, well-quasi-ordering), parameterized complexity (FPT algorithms for bounded pathwidth), statistical mechanics (phase transitions in configuration landscapes).

**Lineage:** Direct extension of Theorems 3 and 4 in the current project. Builds on all prior directions.

**Ambition:** 🔴 Grand challenge — would constitute a major advance in proof complexity and may require fundamentally new ideas.

---

## Direction 3: Efficient Pathwidth Computation for Configuration Graphs

**Conjecture:** The special structure of configuration graphs (vertices are subsets of a ground set, edges connect subsets differing by one element—i.e., the graph is a subgraph of the Boolean lattice's Hasse diagram) admits a pathwidth algorithm running in time O(2^{O(s)} · poly(|F|)) rather than the general 2^{O(n log n)} for arbitrary n-vertex graphs.

**Test:** Implement the dynamic programming algorithm for pathwidth on configuration graphs for formulas with up to 4 variables. Compare running time with general-purpose pathwidth algorithms. Measure whether the special structure provides speedup.

**Impact:** Efficient pathwidth computation would transform the conjecture from a theoretical question to an experimentally testable one on meaningful-sized instances. It would also provide a practical tool for analyzing the memory complexity of specific formulas.

**Catalog References:** `Pythagorean/ConfigGraphPathwidth.lean` — `confGraph`, `ConfigPathDecompCert`

**Proof Strategy:** Exploit the lattice structure of the configuration graph. The vertices form a sub-lattice of the power set lattice, and edges follow the Hasse diagram. Use lattice-theoretic properties (grading by cardinality, monotone separators) to prune the DP state space. Consider adapting the Bodlaender-Kloks linear-time pathwidth algorithm for graphs of bounded pathwidth, since we conjecture the pathwidth is O(s).

**Domain Bridges:** Algorithms (parameterized complexity, FPT algorithms), lattice theory (Boolean lattice structure), SAT solving (clause database analysis).

**Lineage:** Provides the computational backbone for testing Direction 2.

**Ambition:** 🟡 Solid extension — requires algorithmic innovation but is grounded in known techniques.

---

## Direction 4: From Pathwidth to Treewidth — Resolution DAGs

**Conjecture:** The treewidth of the resolution proof DAG (not the configuration graph, but the DAG of derived clauses with derivation edges) is bounded by O(s²) where s is the clause space. Furthermore, tree-like resolution proofs produce DAGs with treewidth O(s).

**Test:** For small unsatisfiable formulas, enumerate all resolution refutations, build the proof DAG, compute its treewidth (using exact algorithms for small graphs), and compare with clause space. Determine whether the relationship is linear or requires a quadratic blowup.

**Impact:** Treewidth is more powerful than pathwidth and controls a broader class of algorithms. If resolution proof DAGs have bounded treewidth relative to clause space, this would connect to the rich theory of tree decompositions in databases (query evaluation), constraint satisfaction, and Bayesian inference.

**Catalog References:** `Pythagorean/ConfigGraphPathwidth.lean` — full theorem suite

**Proof Strategy:** The proof DAG has clauses as vertices and derivation steps as edges. Define a tree decomposition where each bag corresponds to a "live clause set" at some point in a depth-first traversal of the DAG. The interval property for tree decompositions is weaker (subtree-closed rather than interval-closed), so general traces may directly give tree decompositions even without the persistence property.

**Domain Bridges:** Database theory (conjunctive query evaluation on bounded-treewidth instances), Bayesian networks (inference complexity), constraint satisfaction (tractable CSP classes).

**Lineage:** Generalizes the path decomposition results to tree decompositions, expanding the structural graph theory toolkit available for proof complexity.

**Ambition:** 🔴 Grand challenge — treewidth of proof DAGs is a deep question with implications across theoretical computer science.

---

## Direction 5: Configuration Pathwidth as a SAT Solver Metric

**Conjecture:** For practical SAT instances, the pathwidth of the (reachable) configuration graph correlates more strongly with solver runtime and memory usage than traditional complexity measures (number of variables, clause density, community structure).

**Test:** Select 50 benchmark SAT instances from the SAT Competition suite. For each, estimate the configuration graph pathwidth using the greedy heuristic (upper bound) and compare with: (a) wall-clock solving time of MiniSat/CaDiCaL, (b) peak memory usage, (c) number of learned clauses. Compute Pearson and Spearman correlations. Compare with clause-to-variable ratio and community structure metrics.

**Impact:** If confirmed, this would provide a new structural predictor of SAT solver difficulty. Current predictors (clause density, backdoor size, community structure) capture different aspects of hardness. Pathwidth would capture the *memory landscape* aspect—how tightly the solver's state space can be linearized.

**Catalog References:** `Pythagorean/ConfigGraphPathwidth.lean` — `confGraph`, `PathDecompWidth`

**Proof Strategy:** This is primarily an empirical direction. The theoretical grounding comes from our proven connection between clause space and pathwidth for persistent traces. The hypothesis is that this connection extends to the heuristic search trajectories of CDCL solvers, which are approximately persistent (learned clauses are rarely re-derived).

**Domain Bridges:** SAT solving (CDCL, proof logging), machine learning (feature engineering for algorithm selection), software verification (predicting verification difficulty).

**Lineage:** Applies the theoretical framework to practical SAT solving, closing the loop between theory and practice.

**Ambition:** 🟡 Solid extension — requires significant engineering but is experimentally testable.
