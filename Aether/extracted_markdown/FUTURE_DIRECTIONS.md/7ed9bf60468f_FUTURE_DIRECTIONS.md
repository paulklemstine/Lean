# Future Directions

## Synthesis

The configuration-based clause space framework creates a formal bridge between resolution proof complexity, graph theory, and memory-constrained computation. The three verified theorems — soundness, bottleneck, and clause count — establish the foundations. The directions below extend this bridge in three ways: (1) strengthening the proof-complexity theorems to capture the full Ben-Sasson-Wigderson inequality, (2) building the graph-theory connections into formal transfer theorems, and (3) using the computational infrastructure to test sharp conjectures about space complexity. Each direction is designed to be falsifiable: a single computational counterexample or formal disproof can refute the conjecture, driving iterative refinement.

---

### Direction 1: Width-Space Inequality at the Configuration Level

**Conjecture:** For every unsatisfiable CNF F and every configuration refutation π,
configurationSpace(π) ≥ minRefutationWidth(F) − maxInitWidth(F) + 1.

**Test:** Enumerate all resolution refutations of small CNFs (≤ 4 variables) and compute both sides. A single refutation with space below the width gap bound would refute the conjecture (or reveal a formalization error in the width definition).

**Impact:** This would formalize the Ben-Sasson-Wigderson (2001) width-space theorem at the configuration level. The current catalog has `clauseSpaceBound` and `allClauses_width_le_maxWidth` from `Catalog/Computation/ProofComplexity/WidthToSize.lean`, but these apply to tree-like resolution. Lifting to dag-like (configuration-based) resolution requires a new argument using random restrictions.

**Proof Strategy:** Define `minRefutationWidth(F)` as the infimum of maxWidth over all configuration refutations. Prove that if space ≤ s, then the set of variables appearing in all live clauses has size ≤ s · maxClauseWidth. Use a probabilistic deletion argument (formalized via finite combinatorics) to show that a random restriction reduces width while preserving refutability.

**Domain Bridges:** Connects to combinatorics (random restrictions), information theory (entropy bounds on clause sets).

**Catalog References:** `Catalog/Computation/ProofComplexity/WidthToSize.lean` — `allClauses_width_le_maxWidth`, `clauseSpaceBound`, `widthSpectrum`.

**Lineage:** Extends Theorem 2 (bottleneck) by providing a concrete instantiation of the separation hypothesis via width.

**Ambition:** Grand challenge — the random restriction argument has never been formalized in any proof assistant.

---

### Direction 2: Pebbling-to-Resolution Transfer

**Conjecture:** For any DAG G, the black pebbling number of G is at most the minimum clause space of the pebbling CNF Peb(G), up to an additive constant:
PebblingSpace(G) ≤ minClauseSpace(Peb(G)) ≤ PebblingSpace(G) + O(1).

**Test:** Generate all DAGs on ≤ 6 nodes. Compute exact black pebbling numbers (known algorithms exist). Construct Peb(G) and compute exact clause space via bounded-space search. Look for gaps exceeding any fixed constant.

**Impact:** Would create the first formal bridge between time-space tradeoffs (pebbling) and proof complexity (clause space). This is the central cross-domain connection envisioned by the framework.

**Proof Strategy:** Define `PebblingCNF(G)` following Ben-Sasson (2009). Show that any pebbling strategy of cost s can be simulated by a configuration refutation of space s + O(1), and conversely, any configuration refutation induces a pebbling strategy with comparable cost.

**Domain Bridges:** Computational complexity (pebbling games), graph algorithms (DAG pathwidth), VLSI layout.

**Catalog References:** `Computation/ProofComplexity/ConfigurationSpace.lean` — `ConfigStep`, `ReachableWithinBound`, `bottleneck_space_lower_bound`.

**Lineage:** Builds directly on the ConfigStep formalization and the bottleneck theorem.

**Ambition:** Grand challenge — connecting two major areas of complexity theory through formal verification.

---

### Direction 3: Exact Space of Narrow PHP Encodings

**Conjecture:** There exists a family of unsatisfiable CNFs NarrowPHP(n) with maxInitWidth ≤ 3 such that minClauseSpace(NarrowPHP(n)) = n + O(1) for all n ≥ 2.

**Test:** Construct narrow PHP encodings using the chain-clause technique. For n = 2, 3, 4, 5, compute exact minimum clause space. Verify that the values are n + c for a fixed constant c. A non-linear growth pattern or a formula with space much less than n would refute the conjecture.

**Impact:** Would demonstrate that the width-space gap lower bound can be linear, even with bounded initial clause width. This would be the first provably linear space lower bound via the configuration framework.

**Proof Strategy:** Use `allTraceClauses_card_bound` to control the clause universe, then apply a counting argument: if space < n, then the configuration can encode fewer than 2^n possible states, but the proof must distinguish n + 1 pigeons.

**Domain Bridges:** Combinatorics (counting arguments), coding theory (information-theoretic bounds).

**Catalog References:** `Catalog/Computation/ProofComplexity/Resolution.lean` — `php_width_lower_bound`, `php_unsat`. `Computation/ProofComplexity/ConfigurationSpace.lean` — `allTraceClauses_card_bound`.

**Lineage:** Combines Theorem 3 (clause count) with PHP width bounds from the catalog.

**Ambition:** Solid extension — a concrete instantiation of the abstract framework.

---

### Direction 4: Configuration Graph Pathwidth

**Conjecture:** There exists a universal constant c such that for every unsatisfiable CNF F,
minClauseSpace(F) ≥ (1/c) · pathwidth(ConfGraph_s(F))
where ConfGraph_s(F) is the configuration graph restricted to configurations of size ≤ s, for s = minClauseSpace(F).

**Test:** For all CNFs over ≤ 3 variables, compute minClauseSpace and the pathwidth of the bounded configuration graph. Search for the best constant c. A counterexample would be a CNF where pathwidth grows much faster than clause space.

**Impact:** Would formalize the intuition that clause space measures a form of "width" of the proof space. Pathwidth is well-studied in graph theory, and connecting it to clause space would import decades of graph-theoretic results into proof complexity.

**Proof Strategy:** Use the trace-as-path interpretation: any configuration refutation of space s defines a path decomposition of width s in the configuration graph. The pathwidth is at most s. For the lower bound, use the bottleneck theorem.

**Domain Bridges:** Graph theory (pathwidth, treewidth), parameterized complexity, graph searching.

**Catalog References:** `Computation/ProofComplexity/ConfigurationSpace.lean` — `bottleneck_space_lower_bound`, `trace_bounded_reachable`.

**Lineage:** Direct extension of Theorem 2 into graph-theoretic territory.

**Ambition:** Solid extension — makes the graph-theory connection precise.

---

### Direction 5: Certified Space Certificates for SAT Solvers

**Conjecture:** For any CNF F refutable in clause space s, the bounded-space search algorithm terminates in time polynomial in clauseSpaceBound(|vars(F)|, s) and produces a machine-checkable space certificate.

**Test:** Implement the certified search for CNFs with ≤ 5 variables and space ≤ 4. Measure running time and verify that certificates check against the formal Lean definitions. Failure to produce certificates within the predicted time bound would refute the conjecture.

**Impact:** Would create the first certified clause-space analysis tool, analogous to DRAT checkers for proof length. This has direct SAT-solving applications.

**Proof Strategy:** Implement bounded-space search as a decidable function in Lean. Prove that the search is complete (explores all reachable configurations) and that found traces satisfy `IsConfigurationRefutation`. Use the `clauseSpaceBound` to bound the search space.

**Domain Bridges:** Software verification, certified algorithms, SAT solving.

**Catalog References:** `Catalog/Computation/ProofComplexity/WidthToSize.lean` — `clauseSpaceBound`, `clauseSpaceBound_mono`. `Computation/ProofComplexity/ConfigurationSpace.lean` — all main theorems.

**Lineage:** Completes the computational loop: theorems → algorithm → certification → application.

**Ambition:** Solid extension with high practical value.
