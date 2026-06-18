# Future Research Directions

## Synthesis

This research cycle established a complete formal chain connecting SSA program structure to optimal register allocation through graph coloring theory. The key results form a pipeline: SSA liveness intervals → interval graphs → chordal graphs → perfect elimination ordering → greedy coloring optimality → χ(G) = ω(G). Each link was machine-verified, providing the highest level of mathematical certainty.

The most promising cross-domain connection is between the register pressure profile and tropical geometry. The pressure profile P(i) is a piecewise-constant function that captures the "topography" of register demand across a program. Its maximum equals the clique number (a global graph invariant), while its local structure encodes fine-grained scheduling information. This local-to-global bridge has strong parallels in tropical algebra, where piecewise-linear functions encode algebraic structure.

The highest breakthrough potential lies in Direction 1 (List Coloring for Heterogeneous Registers), because modern CPUs have multiple register classes (integer, float, vector, predicate) and the current theory assumes homogeneous registers. Extending the chordal perfectness result to list coloring would immediately impact compiler design for real architectures.

---

### Direction 1: List Coloring of Chordal Interference Graphs

**Conjecture**: For chordal graphs arising from SSA programs, the list chromatic number χₗ(G) equals the chromatic number χ(G) = ω(G). That is, if every vertex has a list of at least ω(G) available colors (registers), then a valid list coloring exists.

**Test**: Construct 500 random chordal graphs with n ∈ [20, 100]. For each vertex, assign a random list of ω(G) colors from a palette of 2ω(G) colors. Attempt greedy list coloring on the PEO. Count failures. If the conjecture holds, all 500 should succeed.

**Impact**: This would extend the SSA register allocation optimality result to heterogeneous register files. Modern CPUs have 16 integer registers, 16 float registers, 32 vector registers, and 8 predicate registers — variables can only use registers of the correct type. List coloring captures this constraint exactly.

**Catalog References**: `Shared/RegisterGraphColoring.lean` (chordal_colorable_of_clique_bound, interval_graph_is_chordal)

**Proof Strategy**: The key tool would be the *kernel-perfect* property of chordal graphs. A graph is kernel-perfect if every induced subgraph of every orientation has a kernel. Chordal graphs are known to be kernel-perfect, and kernel-perfectness implies χₗ = χ for perfect graphs (Galvin's theorem). Formalize the kernel-perfectness of chordal graphs, then derive list colorability.

**Domain Bridges**: Graph Theory ↔ Compiler Optimization ↔ Combinatorial Optimization

**Lineage**: Builds on chordal_colorable_of_clique_bound, interval_graph_is_chordal, greedy_coloring_from_ordering from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Register Pressure and Scheduling

**Conjecture**: The register pressure profile P(i) of a chordal graph with PEO σ is a *tropical convex function* in the following sense: for any three consecutive PEO positions i < j < k, P(j) ≤ max(P(i), P(k)). Equivalently, the "peaks" of register pressure form a tropically convex set.

**Test**: Generate 10,000 random interval graphs with n ∈ [10, 50]. Compute the register pressure profile for each. Check whether P(j) ≤ max(P(i), P(k)) holds for all consecutive triples i < j < k. Report violation rate.

**Impact**: If true, this would connect register allocation to tropical geometry, opening new algorithmic approaches. Tropical convexity would mean that register pressure peaks are "well-behaved" — you can't create a hidden pressure peak between two low-pressure regions, which has implications for instruction scheduling.

**Catalog References**: `Shared/RegisterGraphColoring.lean` (registerPressure, maxRegisterPressure), `Tropical/` (tropical algebra definitions if available)

**Proof Strategy**: Analyze how interval endpoints relate to register pressure. In an interval graph ordered by right endpoints, the pressure at position i depends on how many earlier intervals extend past position i. This has a monotone structure that might yield tropical convexity. Key lemma: if an interval overlaps positions i and k but not j, then... (this needs careful analysis of whether such configurations exist in interval graphs).

**Domain Bridges**: Tropical Geometry ↔ Compiler Optimization ↔ Combinatorics

**Lineage**: Builds on registerPressure, interval_graph_is_chordal from this cycle.

**Ambition**: extension

---

### Direction 3: Weighted Spill Cost Minimization

**Conjecture**: For chordal interference graphs with vertex weights w(v) representing variable access frequency, the minimum-weight spill set (when k < ω(G) registers are available) can be computed in polynomial time. Specifically, it equals the minimum-weight vertex set whose removal reduces the clique number to ≤ k.

**Test**: Generate 200 weighted chordal graphs. For each, compute the minimum-weight set whose removal reduces ω to ≤ k (by brute force for small n ≤ 20). Compare with the greedy heuristic (spill highest-degree vertex, recompute, repeat). Measure the gap.

**Impact**: Current compiler heuristics for spill selection (e.g., spill the variable with highest degree, or lowest frequency/degree ratio) are ad hoc. A polynomial-time optimal algorithm for weighted chordal graphs would replace heuristics with exact optimization, potentially improving runtime of compiled programs by reducing cache-unfriendly memory accesses from spills.

**Catalog References**: `Shared/RegisterGraphColoring.lean` (spill_cost_clique_lower_bound), `Computation/InfoEfficientAlgorithms.lean` (for algorithmic complexity)

**Proof Strategy**: Use the PEO structure. The problem reduces to: find a minimum-weight vertex set that hits every clique of size > k. For chordal graphs, cliques are efficiently enumerable (via PEO), and the hitting set problem on chordal hypergraphs may be solvable by dynamic programming on the elimination tree. Key lemma: every maximal clique in a chordal graph appears as a "local clique" at some PEO position.

**Domain Bridges**: Optimization ↔ Compiler Design ↔ Graph Theory

**Lineage**: Builds on spill_cost_clique_lower_bound, peo_later_neighbors_bound from this cycle.

**Ambition**: extension

---

### Direction 4: Register Allocation for Non-SSA Programs via Chordal Completion

**Conjecture**: For any graph G (not necessarily chordal), the minimum number of edges that must be added to make G chordal (the *minimum fill-in*) equals the minimum number of "copies" (variable splits) needed to transform the interference graph into one that admits optimal register allocation.

**Test**: Take 50 non-SSA programs (or equivalently, 50 non-chordal graphs). Compute the minimum fill-in (NP-hard in general, but feasible for small graphs). Compare with the number of variable splits needed to bring the program into SSA form. Verify equality or find a counterexample.

**Impact**: This would provide a precise mathematical characterization of the "cost of SSA conversion" — one of the fundamental tradeoffs in compiler design. Programs not in SSA form have non-chordal interference graphs, and the gap between χ(G) and ω(G) measures the register allocation suboptimality.

**Catalog References**: `Shared/RegisterGraphColoring.lean` (chordal_colorable_of_clique_bound, InterferenceGraph)

**Proof Strategy**: The connection between SSA conversion and chordal completion is known informally in the compiler literature but has never been formalized. The key insight is that splitting a variable v into v₁, v₂ at a program point corresponds to adding a fill edge in the interference graph. Formalize the SSA conversion algorithm as a sequence of fill operations, then show that the resulting graph is chordal if and only if the program is in SSA form.

**Domain Bridges**: Graph Theory ↔ Compiler Theory ↔ Combinatorial Optimization

**Lineage**: Builds on SimpleGraph.IsChordal, PerfectEliminationOrdering, interval_graph_is_chordal from this cycle.

**Ambition**: grand_challenge
