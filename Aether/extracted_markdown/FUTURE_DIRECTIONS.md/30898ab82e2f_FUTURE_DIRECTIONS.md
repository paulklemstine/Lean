# Future Research Directions

## Synthesis

This research cycle established the list coloring extension of chordal graph perfectness and its application to heterogeneous register allocation. The key result — that χₗ(G) = χ(G) = ω(G) for chordal graphs — bridges three domains: compiler optimization (SSA register allocation), graph theory (perfect graphs and choosability), and combinatorial optimization (greedy algorithms on structured instances). The formal verification pipeline produced machine-checked proofs of all main theorems, building on the existing catalog of SSA-to-graph-coloring results.

The most promising cross-domain connection from this cycle is between register pressure profiles and tropical geometry. The register pressure function P(i) = |LaterNeighbors(i)| + 1 at each PEO position encodes the local clique structure. Its maximum equals ω(G), but its full shape — the "topography" of register demand across the program — contains scheduling information not captured by ω alone. This function lives naturally in the tropical semiring (ℝ ∪ {−∞}, max, +), where "addition" is max and "multiplication" is +. The connection suggests that tropical algebraic methods could yield new algorithms for register allocation with scheduling constraints.

The highest breakthrough potential lies in Direction 1 (Online List Coloring for JIT Compilation), because JIT compilers face the heterogeneous register allocation problem in an online setting where variables arrive dynamically. A competitive ratio guarantee for online list coloring on chordal graphs would have immediate practical impact on JIT compiler design for JavaScript engines, JVM implementations, and WebAssembly runtimes.

---

### Direction 1: Online List Coloring for JIT Compilation

**Conjecture**: For chordal graphs revealed online (vertices arrive one at a time with their adjacencies to previously revealed vertices and their color lists), there exists a deterministic online list coloring algorithm with competitive ratio 1 — i.e., it uses no more colors than the offline optimum — provided the graph is revealed in reverse PEO order and each list has size ≥ ω(G).

**Test**: Implement an online simulator that reveals vertices of random chordal graphs (n ∈ [50, 500]) in reverse PEO order. For each vertex, reveal its adjacencies to already-revealed vertices and a random list of ω(G) colors from a palette of 3ω(G). Run the greedy online algorithm (assign the first available color from the list). Measure whether a valid coloring is always produced. If any instance fails, the conjecture is false.

**Impact**: If true, this provides a theoretical foundation for optimal register allocation in JIT compilers, where compilation happens at runtime and variables are processed as they appear. If false, the failure cases would reveal which graph structures resist online coloring, guiding the design of better JIT heuristics.

**Catalog References**: `Shared/RegisterGraphColoring.lean` (chordal coloring pipeline), `Computation/ListColoringChordal.lean` (list coloring theorems)

**Proof Strategy**: The key would be to show that when vertices arrive in reverse PEO order, each new vertex's already-revealed neighbors form a clique (by the PEO simplicial property). Since the list has ≥ ω(G) colors and the clique has < ω(G) members, a valid color always exists. The main challenge is formalizing "online" in Lean — likely as a function from partial graphs to colorings satisfying a consistency condition.

**Domain Bridges**: Compiler theory (JIT optimization) ↔ Online algorithms (competitive analysis) ↔ Graph theory (chordal structure)

**Lineage**: Builds on greedy_list_coloring_peo and chordal_choosable_of_clique_bound from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Weighted List Coloring and Register Cost Minimization

**Conjecture**: For chordal graphs with a PEO σ and a cost function w : V × C → ℝ≥0 (cost of assigning color c to vertex v), there exists a polynomial-time algorithm that finds a minimum-cost list coloring, provided |L(v)| ≥ ω(G) for all v. The optimal cost can be computed by dynamic programming along the PEO in O(n · max|L(v)|²) time.

**Test**: Generate 200 random chordal graphs with n ∈ [20, 80]. For each, assign random costs w(v,c) ∈ [0,1] and lists of size ω(G). Run (a) brute-force optimal list coloring, (b) the proposed DP algorithm. Compare costs. If they always match, the algorithm is correct. If the DP sometimes gives suboptimal results, the conjecture is false.

**Impact**: In real compilers, not all registers are equal. Callee-saved registers require save/restore instructions; some registers are faster for certain operations. A weighted list coloring algorithm would enable cost-optimal register allocation, reducing both code size and execution time.

**Catalog References**: `Shared/RegisterGraphColoring.lean`, `Computation/InfoEfficientAlgorithms.lean` (algorithm efficiency framework)

**Proof Strategy**: The PEO provides a tree decomposition of width ω−1. Dynamic programming on tree decompositions is well-studied. The key lemma would be: for each PEO position i, the optimal coloring of positions ≥ i depends on positions < i only through the colors assigned to the later neighbors of i (which form a clique of size < ω). This gives a state space of at most |C|^ω, yielding polynomial time when ω is bounded.

**Domain Bridges**: Combinatorial optimization (weighted coloring) ↔ Compiler optimization (register cost) ↔ Dynamic programming (tree decomposition)

**Lineage**: Extends the list coloring results to an optimization setting. Builds on greedy_list_coloring_peo.

**Ambition**: extension

---

### Direction 3: Tropical Geometry of Register Pressure Profiles

**Conjecture**: The register pressure profile P : Fin n → ℕ of a chordal graph G with PEO σ is a *tropical polynomial* in the sense that P(i) = max_j (a_j + b_j · i) for some finite collection of linear functions, where the "slopes" b_j correspond to rates of liveness change. Furthermore, the number of linear pieces in P equals the number of maximal cliques in G.

**Test**: Generate 1000 random interval graphs (which are chordal) with n ∈ [30, 100]. For each, compute the PEO, the pressure profile P, and the number of maximal cliques. Check whether P is always piecewise-linear (i.e., the second differences Δ²P are zero except at finitely many breakpoints) and whether the number of pieces equals the number of maximal cliques. A single counterexample disproves the conjecture.

**Impact**: If true, this would establish a dictionary between:
- Maximal cliques ↔ Linear pieces of P
- Clique number ω ↔ Maximum value of P
- Number of maximal cliques ↔ Tropical degree of P
This dictionary would connect register allocation to tropical algebraic geometry, potentially enabling new algorithms based on tropical methods.

**Catalog References**: `Bridges/OperadicTropicalization.lean` (tropical_profile_complete_for_bounded_architecture_congruence), `Computation/OracleApplicationsFrontier.lean` (tropical_and_bound)

**Proof Strategy**: Start by proving the conjecture for interval graphs (where the PEO can be chosen as sorting by left endpoint). In this case, P(i) counts the number of intervals covering the right endpoint of the i-th interval, which is a step function. The breakpoints correspond to maximal cliques (which for interval graphs are exactly the "coverage peaks"). The general chordal case would follow from the fact that every chordal graph is an intersection graph of subtrees of a tree.

**Domain Bridges**: Tropical geometry (piecewise-linear functions) ↔ Graph theory (chordal structure) ↔ Compiler theory (register pressure)

**Lineage**: Builds on pressure_eq_local_clique and max_pressure_le_clique_bound from this cycle. Connects to tropical_profile_complete_for_bounded_architecture_congruence from the catalog.

**Ambition**: grand_challenge

---

### Direction 4: Fractional Choosability and Random List Assignments

**Conjecture**: For a chordal graph G with clique number ω ≥ 3, if each vertex v receives a uniformly random list L(v) of size ω − 1 from a palette of size 2ω, the probability that a valid list coloring exists approaches 0 as n → ∞. More precisely, Pr[colorable] ≤ exp(−c · n) for some constant c > 0 depending on ω.

**Test**: For each ω ∈ {3, 5, 7, 10}, generate 500 random chordal graphs with n ∈ {20, 50, 100, 200}. For each graph, draw 100 random list assignments of size ω − 1 from a palette of 2ω colors. Check colorability (by backtracking). Plot the fraction of colorable instances vs. n for each ω. If the fraction decays exponentially, the conjecture is supported. If it plateaus, the conjecture is false.

**Impact**: This would quantify the "gap" between ω-choosability (which always succeeds) and (ω−1)-choosability (which always fails for adversarial lists). Understanding the probability landscape helps compiler designers understand the robustness of register allocation: how much "slack" is needed in register availability to ensure allocation succeeds with high probability?

**Catalog References**: `Computation/CSPPhaseTransition.lean` (phase transition theory), `Computation/ListColoringChordal.lean`

**Proof Strategy**: Use the Lovász Local Lemma or second-moment method. For each maximal clique C of size ω, the probability that C cannot be colored from lists of size ω − 1 is bounded below (by a birthday-paradox argument). If these "bad events" are sufficiently independent (which the chordal structure may guarantee), the probability that ALL cliques are colorable decays exponentially.

**Domain Bridges**: Probabilistic combinatorics (random structures) ↔ Graph theory (choosability) ↔ Compiler theory (robustness of allocation)

**Lineage**: Builds on ChordalPerfectness conjecture from this cycle and extends the list coloring analysis to the probabilistic setting.

**Ambition**: extension

---

### Direction 5: Register Allocation for Non-SSA Programs via Graph Perfection

**Conjecture**: For programs not in SSA form, the interference graph G satisfies χ(G) ≤ ω(G) + O(√n), where the additive error term depends on the number of "phi-function eliminations" or "critical edges" that break the chordal structure. More precisely, if G can be made chordal by removing at most d edges, then χ(G) ≤ ω(G) + d.

**Test**: Generate 300 random "near-chordal" graphs: start with a chordal graph on n ∈ [30, 100] vertices, then add d ∈ {1, 3, 5, 10} random edges. Compute χ(G) (by exact algorithm for small n, heuristic for larger n) and ω(G). Check whether χ(G) ≤ ω(G) + d always holds. If a counterexample is found, determine the tightest bound.

**Impact**: Real compiler programs are rarely in perfect SSA form. Understanding how far from optimality register allocation can drift when the interference graph deviates from chordality would guide compiler designers on when to invest in SSA repair vs. accepting suboptimal allocation.

**Catalog References**: `Shared/RegisterGraphColoring.lean` (chordal_colorable_of_clique_bound), `Computation/ListColoringChordal.lean`

**Proof Strategy**: For each added edge e = (u,v), the chromatic number can increase by at most 1 (since removing e reduces the graph to a subgraph). But this gives only χ ≤ χ(G−edges) + d = ω + d, which may be tight. The key question is whether the chordal structure provides better bounds (e.g., χ ≤ ω + ⌊d/2⌋) due to the interplay between added edges and existing cliques.

**Domain Bridges**: Graph theory (near-perfect graphs) ↔ Compiler theory (non-SSA programs) ↔ Parameterized complexity (distance to chordality)

**Lineage**: Extends the exact optimality results to approximate settings. Builds on chordal_colorable_of_clique_bound.

**Ambition**: extension
