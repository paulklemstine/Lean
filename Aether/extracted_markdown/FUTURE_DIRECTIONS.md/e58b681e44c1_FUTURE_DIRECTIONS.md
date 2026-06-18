# Future Directions: Separator-Aware Forgetting Theory

## Synthesis

The formal verification of separator-aware forgetting as the unique minimal interaction-preserving policy opens a systematic research program connecting graph decomposition theory to solver engineering. The results in `Pythagorean/ClauseInteractionPathwidth/SeparatorAwareForgetting.lean` establish the *static* theory: given a fixed path decomposition, the frontier is optimal. The natural next steps push in five directions: (1) generalization from pathwidth to treewidth, (2) dynamic maintenance of decompositions during search, (3) empirical validation on industrial benchmarks, (4) semantic strengthening beyond structural interaction, and (5) approximate separator policies with provable guarantees. Each direction is independently testable and falsifiable, and together they form a coherent program for principled clause database management.

---

## Direction 1: Treewidth Generalization of Separator Optimality

**Ambition**: grand_challenge

**Conjecture**: The separator optimality theorem generalizes from path decompositions to tree decompositions. Specifically, for a tree decomposition (T, {B_t}) of the clause interaction graph and any edge e of T, the vertices in B_s ∩ B_t (where s, t are the endpoints of e) form the unique minimal interaction-preserving separator between the two components of T \ e.

**Test**: Formalize tree decompositions in Lean 4 with the standard axioms (vertex coverage, edge coverage, running intersection on tree paths). Define the analogous InteractionPreservingAtCut for tree edges. Prove or disprove the generalized minimality theorem. A disproof would require constructing a tree decomposition where a proper subset of the tree-edge separator preserves all cross-component interactions.

**Impact**: If true, this would establish that *treewidth*, not just pathwidth, governs optimal clause retention — dramatically expanding the class of problems where structural forgetting applies. Since treewidth ≤ pathwidth, this would give tighter bounds for many practical instances. It would also connect clause management to the vast literature on tree decomposition algorithms.

**Catalog References**: `SeparatorAwareForgetting.lean` — `frontier_eq_bag`, `frontier_interaction_preserving`, `frontier_vertex_necessary`

**Proof Strategy**: The key lemma is that the running intersection property on tree paths implies that cross-component edges (between the two subtrees of T \ e) must have both endpoints in the separator bags. The proof structure mirrors the path case but requires induction on tree structure rather than linear intervals.

**Domain Bridges**: Graph minor theory ↔ SAT solving ↔ parameterized complexity

**Lineage**: Direct generalization of the Frontier = Bag theorem and Minimality theorem from paths to trees.

---

## Direction 2: Online Approximate Separator Retention

**Ambition**: solid_extension

**Conjecture**: For clause interaction graphs that admit path decompositions of width ≤ k, an online algorithm that maintains an approximate separator using O(k log n) space achieves interaction preservation with probability ≥ 1 - 1/n at each reduction step, using only O(k) time per clause insertion/deletion.

**Test**: Implement an online decomposition tracker in a SAT solver that uses spectral or BFS-based heuristics to maintain an approximate frontier. Measure: (a) fraction of reduction steps where the approximate frontier is a superset of the true frontier (completeness), (b) fraction where it's a subset (precision), (c) wall-clock overhead per propagation step. Run on SAT Competition 2023 industrial benchmarks. The conjecture is refuted if completeness < 0.9 on > 30% of instances.

**Impact**: Resolves the practical bottleneck of exact decomposition computation. If the approximation is sufficient, separator-aware forgetting becomes deployable in production solvers.

**Catalog References**: `SeparatorAwareForgetting.lean` — `separatorAwareRetain_preserving`, `card_frontier_le_width_succ`

**Proof Strategy**: Use the fact that BFS layering gives O(pw · log n) width approximations. Show that the approximate bag at each BFS layer contains the true separator (by inclusion of true bags in approximate bags).

**Domain Bridges**: Streaming algorithms ↔ graph sketching ↔ solver engineering

**Lineage**: Builds on the verified algorithm `separatorAwareRetain` by relaxing exactness for efficiency.

---

## Direction 3: Semantic Interaction Preservation

**Ambition**: grand_challenge

**Conjecture**: There exists a natural strengthening of InteractionPreservingAtCut — call it *resolution-preserving* — such that a retention policy R is resolution-preserving if and only if every resolution proof using cross-cut clause pairs remains derivable from R plus future clauses. The frontier is resolution-preserving, but the minimum resolution-preserving set can be strictly smaller than the frontier.

**Test**: Formalize resolution derivability in Lean 4. Define resolution-preserving retention. Prove or disprove that the frontier is resolution-preserving (expected: yes). Construct an example where a proper subset of the frontier is resolution-preserving but the full frontier is not necessary (expected: possible when some frontier clauses are subsumed by others).

**Impact**: If confirmed, this would separate *structural* from *semantic* optimality, showing that structural interaction preservation is a sufficient but not necessary condition for maintaining proof-theoretic completeness. This opens a new optimization axis: semantic compression of the frontier.

**Catalog References**: `Defs.lean` — `clauseEval`, `clausesAdjacent`; `Theorems.lean` — `retainAtCut_preserves_frontier_edges`

**Proof Strategy**: For the positive direction (frontier is resolution-preserving), show that any resolution step using a cross-cut pair has both clauses in the bag, hence in the frontier. For the separation example, construct clauses where c₁ ⊆ c₂ (subsumption) and c₂ is in the frontier but c₁ suffices.

**Domain Bridges**: Proof complexity ↔ clause learning theory ↔ interpolation

**Lineage**: Extends `retainAtCut_preserves_frontier_edges` from edge-level to proof-level preservation.

---

## Direction 4: Empirical Pathwidth of Industrial SAT Instances

**Ambition**: solid_extension

**Conjecture**: For ≥ 60% of SAT Competition 2023 industrial benchmarks, the clause interaction graph of the learned clause database (at the point of first reduction) has an approximate pathwidth ≤ 50, computable by a greedy elimination algorithm in under 10 seconds.

**Test**: Instrument CaDiCaL or Kissat to dump the clause interaction graph at each reduction point. Run a greedy pathwidth approximation algorithm on each dump. Report: (a) distribution of approximate pathwidths, (b) correlation with instance difficulty (solve time), (c) correlation with LBD distribution. The conjecture is refuted if median approximate pathwidth > 100.

**Impact**: If true, validates the practical relevance of the theoretical framework — the width bounds are meaningful for real instances. If false, identifies the structural gap between theory and practice, motivating research on alternative decomposition types (e.g., treewidth, clique-width).

**Catalog References**: `Theorems.lean` — `activeFrontier_card_le_width_succ`, `maxFrontierSize_le_width_succ`

**Proof Strategy**: Empirical only. Use the MMD (minimum degree) heuristic for pathwidth approximation.

**Domain Bridges**: SAT competition analysis ↔ empirical algorithmics ↔ graph structure mining

**Lineage**: Tests the practical assumptions underlying the width bound theorems.

---

## Direction 5: Separator-Aware Forgetting in Parallel/Portfolio SAT Solvers

**Ambition**: solid_extension

**Conjecture**: In a portfolio SAT solver running k copies of a CDCL solver with shared clause databases, using a common path decomposition for clause exchange filtering — accepting only clauses in the frontier of the receiving solver's decomposition — reduces communication volume by ≥ 50% while preserving ≥ 95% of the solve rate on industrial instances.

**Test**: Modify a parallel SAT solver (e.g., Mallob, Plingeling) to compute approximate decompositions for each solver thread. Use the frontier as a filter for incoming shared clauses: only accept a shared clause if it falls within the receiving thread's current frontier. Measure: (a) clause exchange volume (bytes/second), (b) solve rate vs. baseline, (c) memory per thread. The conjecture is refuted if solve rate drops by > 10%.

**Impact**: Addresses one of the key scalability bottlenecks in parallel SAT solving: managing the flood of shared clauses. The frontier filter provides a principled, structurally motivated alternative to ad-hoc quality thresholds (e.g., LBD ≤ 3).

**Catalog References**: `SeparatorAwareForgetting.lean` — `frontier_separates_past_from_future`, `InteractionPreservingAtCut`

**Proof Strategy**: The theoretical justification is that non-frontier clauses from one thread cannot interact with clauses that are strictly past or future in another thread's decomposition, so discarding them loses no structural information.

**Domain Bridges**: Parallel computing ↔ distributed systems ↔ communication complexity

**Lineage**: Applies the separator framework to clause exchange filtering, a new application domain.
