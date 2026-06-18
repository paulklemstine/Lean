# Future Directions: Configuration Graph Pathwidth

## Synthesis

The formalization of configuration graph pathwidth establishes the first rigorous dictionary entry translating proof memory into graph width. The central result — that regular resolution traces with clause space *s* yield path decompositions of width ≤ *s* − 1 — opens a bidirectional corridor between proof complexity and structural graph theory. The five directions below explore both sides of this corridor: two grand challenges aim to complete the dictionary (proving the converse bound and extending to tree-like proofs), while three solid extensions build directly on the current theorems to deepen the theory, expand its computational reach, and connect it to algorithmic SAT solving.

All directions are grounded in the formalized definitions (`PathDecomp`, `ConfigTrace`, `traceMemoryNumber`, `confGraphBoundedAdj`) and the three main theorems (`pathwidth_of_regular_trace_le`, `exists_pathDecomp_of_refutation`, `traceMemoryNumber_le_minClauseSpace`). Each hypothesis is falsifiable through either formal proof, counterexample construction, or computational experiment.

---

## Direction 1: Universal Constant Conjecture — Full Configuration Graph Pathwidth

**Conjecture:** There exists a universal constant *c* ≤ 4 such that for every unsatisfiable CNF formula *F*,
$$\text{pathwidth}(\text{ConfGraph}_s(F)) \leq c \cdot s$$
where *s* = minClauseSpace(*F*).

**Test:** Exhaustive computation on all unsatisfiable CNF formulas over *n* ≤ 4 variables, computing exact pathwidth of bounded configuration graphs. A single counterexample with ratio > 4 would refute the specific constant; any finite counterexample would constrain *c*. For larger formulas, asymptotic analysis of known formula families (pigeonhole, Tseitin, random 3-SAT) would test whether the ratio grows.

**Impact:** A proof would establish a deep equivalence: proof memory and graph width are the same invariant up to constants. This would import all pathwidth lower bound techniques (balanced separators, excluded minors, Bramble-based bounds) into proof complexity, potentially resolving open clause space lower bound problems.

**Catalog References:** `Pythagorean/ConfigGraphPathwidth.lean` — `clauseSpace_dominates_pathwidth_conjecture` (formal statement), `confGraphBounded_mono` (monotonicity foundation), `traceMemoryNumber_le_minClauseSpace` (partial result).

**Proof Strategy:** 
1. Prove for tree-like resolution first (Direction 2), where the configuration graph has additional structure.
2. Use the vertex separation characterization of pathwidth: construct a linear ordering of configurations where the frontier at each cut is bounded by O(*s*).
3. The ordering comes from a canonical exploration strategy (e.g., BFS on the refutation component), and the frontier bound follows from the clause space constraint on reachable configurations.

**Domain Bridges:** Structural graph theory (pathwidth/treewidth theory), parameterized algorithms (bounded-width dynamic programming), proof complexity (resolution space bounds), statistical mechanics (energy landscapes of state spaces).

**Lineage:** Extends `traceMemoryNumber_le_minClauseSpace` from single-trace to full-graph pathwidth.

**Ambition:** Grand Challenge — would unify two major subfields of discrete mathematics.

---

## Direction 2: Tree-Like Resolution and Treewidth

**Conjecture:** For tree-like resolution, the configuration graph of any optimal-space refutation has *treewidth* at most *s* − 1, where *s* is the tree-like clause space.

**Test:** 
1. Formalize tree-like resolution traces (where the resolution derivation DAG is a tree).
2. Construct tree decompositions from tree-like traces.
3. Verify on pigeonhole formulas PHP(n, n-1) where tree-like clause space is Θ(n).
4. Computational: compare treewidth and pathwidth for configuration graphs of tree-like vs. general refutations.

**Impact:** Would extend the pathwidth theory to treewidth, the more fundamental graph invariant. Since treewidth ≤ pathwidth, this would be a strictly stronger result. It would connect tree-like resolution (the most studied restricted proof system) to the most studied graph width parameter.

**Catalog References:** `Pythagorean/ConfigGraphPathwidth.lean` — `PathDecomp` (generalize to tree decompositions), `pathwidth_of_regular_trace_le` (template for tree-like analog).

**Proof Strategy:**
1. Define `TreeDecomp` analogously to `PathDecomp` but with a tree structure on bags.
2. For tree-like traces, the derivation tree provides the tree structure directly.
3. Each bag contains the clauses "active" at that node of the derivation tree.
4. The tree structure of the proof transfers to the tree structure of the decomposition.

**Domain Bridges:** Graph minor theory (treewidth), parameterized complexity (Courcelle's theorem), proof complexity (tree-like vs. general resolution), database theory (treewidth of query graphs).

**Lineage:** Natural generalization of Direction 1 restricted to tree-like proofs.

**Ambition:** Grand Challenge — would give the first treewidth characterization of a proof complexity measure.

---

## Direction 3: Non-Regular Traces and Convex Closure Width

**Conjecture:** For any (not necessarily regular) configuration trace with clause space *s*, the convex closure width — the maximum bag size after extending each element's lifetime to a contiguous interval — is at most *s* · log(*n*), where *n* is the trace length.

**Test:**
1. Implement convex closure: for each clause, extend its lifetime from first to last appearance.
2. Measure the maximum bag size of the enlarged decomposition on random resolution traces.
3. Construct adversarial non-regular traces that maximize the convex closure blowup.
4. Prove or disprove the logarithmic bound.

**Impact:** Would extend the main theorem beyond regular resolution, covering the full generality of resolution proof systems. The logarithmic overhead, if tight, would quantify the cost of clause re-derivation in graph-theoretic terms.

**Catalog References:** `Pythagorean/ConfigGraphPathwidth.lean` — `PathDecomp.MonotoneProp` (the property we relax), `monotone_implies_interval` (the theorem that needs a non-monotone analog).

**Proof Strategy:**
1. Define `ConvexClosure(T)`: for each element *x*, define *B*′ᵢ = {*x* : ∃*j* ≤ *i*, *x* ∈ *C*ⱼ ∧ ∃*k* ≥ *i*, *x* ∈ *C*ₖ}.
2. Prove *B*′ satisfies the interval property by construction.
3. Bound |*B*′ᵢ| by analyzing how many clauses have "lifetimes" spanning position *i*.
4. Use a counting argument: each clause contributes to at most (last − first + 1) bags, and the total contribution is bounded by the sum of lifetimes.

**Domain Bridges:** Resolution proof complexity (general vs. regular resolution), amortized analysis, interval scheduling theory.

**Lineage:** Directly extends `pathwidth_of_regular_trace_le` to non-regular traces.

**Ambition:** Solid Extension — removes the main limitation of the current theory.

---

## Direction 4: Pathwidth-Based Clause Space Lower Bounds

**Conjecture:** For Tseitin formulas on expander graphs with *n* vertices, the pathwidth of the bounded configuration graph is Ω(n), providing an alternative proof of the Ω(n) clause space lower bound.

**Test:**
1. Construct Tseitin formulas on small expander graphs (n ≤ 10).
2. Build bounded configuration graphs and compute exact pathwidth.
3. Verify the pathwidth is Ω(n) experimentally.
4. Attempt to prove the lower bound using graph separator arguments applied to the configuration graph.

**Impact:** Would demonstrate that pathwidth methods can *reprove* known clause space lower bounds, validating the approach. If the pathwidth proof is simpler or more general than existing proofs, it would vindicate the entire program.

**Catalog References:** `Pythagorean/ConfigGraphPathwidth.lean` — `traceMemoryNumber_le_minClauseSpace` (establishes the lower bound direction), `confGraphBoundedAdj` (defines the graph to analyze).

**Proof Strategy:**
1. Use the expansion property of the base graph to show the configuration graph has no small balanced separators.
2. Apply the pathwidth-separator theorem: pathwidth(*G*) ≥ *n*/2 if *G* has no balanced separator of size < *n*/2.
3. Translate the separator bound back to clause space via `traceMemoryNumber_le_minClauseSpace`.

**Domain Bridges:** Expander graphs, spectral graph theory, proof complexity (Tseitin formulas), algebraic topology (cohomological width).

**Lineage:** Applies `traceMemoryNumber_le_minClauseSpace` in the "hard direction" to derive lower bounds.

**Ambition:** Solid Extension — validates the lower bound pathway of the theory.

---

## Direction 5: Structurally Adaptive SAT Solving

**Conjecture:** A SAT solver that estimates the pathwidth of the relevant configuration graph region and adapts its memory management strategy accordingly will solve unsatisfiable instances 20-50% faster than a solver with fixed memory policy, on benchmark instances where clause space is the bottleneck.

**Test:**
1. Implement a prototype solver with two modes: linear-scan (for low pathwidth) and CDCL with aggressive clause deletion (for high pathwidth).
2. Estimate pathwidth at runtime using a fast heuristic (e.g., minimum degree elimination).
3. Compare performance against MiniSat and CaDiCaL on SAT Competition benchmarks.
4. Measure correlation between estimated pathwidth and actual solver memory peaks.

**Impact:** Would provide the first practical application of configuration graph pathwidth theory to SAT solving. Even a modest speedup would demonstrate that proof-theoretic structural invariants have algorithmic value.

**Catalog References:** `Pythagorean/ConfigGraphPathwidth.lean` — `confGraphBoundedAdj` (defines the state space), `pathwidth_of_regular_trace_le` (provides the theoretical guarantee for low-pathwidth strategies).

**Proof Strategy:** This is primarily experimental. The theoretical justification is:
1. Low pathwidth ⟹ linear exploration suffices (path decomposition guides the search).
2. High pathwidth ⟹ must maintain more clauses (our theorems give the width bound).
3. Adaptive switching minimizes the mismatch between strategy and problem structure.

**Domain Bridges:** SAT solving (CDCL, look-ahead), algorithm engineering, heuristic search, operations research (scheduling under memory constraints).

**Lineage:** Applies the entire theorem package to algorithm design.

**Ambition:** Solid Extension — bridges theory to practice.
