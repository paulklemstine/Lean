# Future Directions: Pathwidth-Guided SAT Solving

## Synthesis

The theory of clause interaction pathwidth opens a new bridge between structural graph theory and SAT solving practice. The verified theorems — separator, frontier bound, local edge preservation, and bag locality — establish the mathematical foundation for treating clause databases as geometric objects governed by decomposition width. The directions below extend this foundation in complementary ways: Conjecture A validates the theory empirically, Conjecture B tests its practical value against existing heuristics, Conjecture C seeks the fundamental phase transition, Conjecture D establishes the DP equivalence, and Conjecture E pushes into the grand challenge of automated decomposition discovery. Together, these form a coherent research program that could transform SAT solving from heuristic engineering into a principled structural discipline.

---

## Direction 1: Memory-Pathwidth Correlation

**Conjecture:** For industrial SAT benchmark families with strong modular structure (hardware verification, bounded model checking, planning), the estimated pathwidth of the evolving clause interaction graph is positively correlated (Spearman ρ > 0.7) with peak clause-database memory under CDCL solvers.

**Test:** Instrument MiniSat or CaDiCaL to log the clause interaction graph at regular intervals during solving. Compute approximate pathwidth using the greedy elimination heuristic. Measure Spearman rank correlation between pathwidth traces and peak memory across 500+ SAT Competition benchmarks. Control for formula size.

**Impact:** If confirmed, this validates pathwidth as a *predictive* structural invariant for solver memory, not just a theoretical bound. If falsified (ρ < 0.3), the theory would need revision — perhaps treewidth or a different graph parameter is more appropriate.

**Catalog References:** `Catalog/Pythagorean/ConfigGraph/Defs.lean` (PathDecomposition, ResolutionTrace), `Catalog/Pythagorean/ConfigGraph/Theorems.lean` (clauseSpace_le_maxBagSize_of_valid_decomp).

**Proof Strategy:** Formalize the correlation claim as a probabilistic statement over a measure on CNF families. Use the existing frontier bound theorem to derive upper bounds on expected memory given expected pathwidth.

**Domain Bridges:** Connects to benchmark science, empirical algorithm analysis, and statistical learning theory.

**Lineage:** Extends the clause space / pathwidth bridge from `Catalog/Pythagorean/ConfigGraph/Theorems.lean`.

**Ambition:** Solid extension — validates existing theory empirically.

---

## Direction 2: Separator-Aware Forgetting Dominates Activity-Only Forgetting

**Conjecture:** On SAT instances whose clause interaction graphs have empirical pathwidth ≤ k (for k ≤ 50), path-respecting forgetting achieves strictly lower peak memory than LBD/activity-only forgetting in GLUCOSE, with at most 2x runtime overhead, on ≥ 60% of industrial benchmarks.

**Test:** Implement path-respecting forgetting as a plugin for CaDiCaL. On each database reduction event, retain clauses in the current bag + active frontier instead of using LBD scores. Benchmark against stock CaDiCaL on SAT Competition 2023 industrial track. Measure peak memory, runtime, and solve rate.

**Impact:** If confirmed, this demonstrates practical value of the structural theory — a new clause management strategy competitive with state-of-the-art. If falsified, the overhead of maintaining decompositions may be too high, suggesting that approximate pathwidth-awareness (without exact decompositions) is the right level of abstraction.

**Catalog References:** `Pythagorean/ClauseInteractionPathwidth/Theorems.lean` (activeFrontier_card_le_width_succ, retainAtCut_preserves_frontier_edges).

**Proof Strategy:** The correctness guarantee follows from our local edge preservation theorem. The quantitative claim requires empirical validation.

**Domain Bridges:** Connects to systems engineering, SAT solver architecture, and algorithm engineering.

**Lineage:** Direct application of the frontier bound and edge preservation theorems.

**Ambition:** Solid extension — translates theory into practice.

---

## Direction 3: Width Predicts Learnability Regime (Phase Transition)

**Conjecture:** There exists a threshold function T(k) = O(k²) such that: for any CNF F with clause interaction pathwidth ≤ k, there exists a CDCL strategy whose retained database size never exceeds T(k) · |F| while maintaining solvability (finding a satisfying assignment or proving UNSAT within polynomial overhead vs. unrestricted CDCL).

**Test:** Generate random CNFs with controlled clause interaction pathwidth using planted-solution models on bounded-pathwidth graphs. For each k ∈ {2, 5, 10, 20, 50}, measure the minimum retained database size that preserves solvability across 1000 instances. Plot the threshold function and fit T(k).

**Impact:** If confirmed with T(k) = O(k²), this establishes a *learnability regime* governed by pathwidth — a fundamental complexity-theoretic result. If T(k) grows exponentially, bounded-memory solving is infeasible even for bounded-pathwidth instances, and the theory needs to account for proof-length blowup.

**Catalog References:** `Catalog/Pythagorean/ConfigGraph/Theorems.lean` (pathwidth_le_of_spaceBound), `Pythagorean/ClauseInteractionPathwidth/Theorems.lean` (maxFrontierSize_le_width_succ).

**Proof Strategy:** Formalize T(k) as the minimum over all valid decompositions of maxBagSize · |F|. Use the frontier bound to show T(k) ≤ (k+1) · |F|. The harder direction — showing this is achievable — requires connecting to resolution proof length.

**Domain Bridges:** Connects to phase transition phenomena in random CSPs, proof complexity lower bounds, and parameterized complexity.

**Lineage:** Grand challenge extending the frontier bound theorem.

**Ambition:** Grand challenge — paradigm-shifting if established.

---

## Direction 4: Dynamic Programming Equivalence

**Conjecture:** For CNFs F with clause interaction pathwidth pw(confGraph(F)) ≤ k, a path-guided solver (CDCL with pathwidth-bounded forgetting) and a bag-state dynamic program have asymptotically equivalent memory requirements: both Θ(2^k · |F|).

**Test:** Implement both a pathwidth-bounded CDCL variant and an explicit DP algorithm over path decompositions for the same formula families. Compare state counts, retained clause counts, and peak memory on synthetic bounded-pathwidth CNFs with k ∈ {2, 4, 6, 8, 10}. Measure the constant factor.

**Impact:** If confirmed, this establishes a formal computational equivalence between two paradigms — clause learning and dynamic programming — unified by pathwidth. This would be a landmark result connecting proof search to algebraic computation. If falsified, the constant factors differ too much for practical equivalence, but the asymptotic relationship may still hold.

**Catalog References:** `Pythagorean/ClauseInteractionPathwidth/Theorems.lean` (cut_locality, bag_locality_of_clause_evaluation).

**Proof Strategy:** The upper bound (DP memory ≤ O(2^k · |F|)) follows from the cut locality theorem: at each bag, the DP state space is bounded by 2^|bagVars|. The lower bound requires a counting argument showing that any solving strategy must represent this many states.

**Domain Bridges:** Connects to automata theory, transfer-matrix methods in statistical physics, database join processing, and constraint satisfaction.

**Lineage:** Extends the cut locality theorem into a computational equivalence.

**Ambition:** Grand challenge — would unify two major algorithmic paradigms.

---

## Direction 5: Automated Decomposition Discovery via Machine Learning

**Conjecture:** A graph neural network trained on clause interaction graphs can predict approximate path decompositions with width within a factor of 2 of optimal, in O(n log n) time, for n-clause formulas from industrial distributions.

**Test:** Generate training data by computing near-optimal path decompositions for 10,000 industrial SAT subformulas using exact algorithms (for small n ≤ 100) and the best known heuristics (for larger n). Train a GNN to predict elimination orderings. Evaluate approximation ratio and runtime on held-out test instances.

**Impact:** If confirmed, this solves the main practical obstacle to pathwidth-guided solving: the cost of computing decompositions. A fast, accurate predictor would make the entire theory practically applicable. If falsified (approximation ratio > 5), pathwidth may be too hard to approximate from local graph features, suggesting that alternative structural parameters (e.g., bandwidth, cutwidth) might be more tractable.

**Catalog References:** All theorems in `Pythagorean/ClauseInteractionPathwidth/` — the GNN must produce decompositions satisfying the axioms for the theorems to apply.

**Proof Strategy:** Verify that GNN-produced decompositions satisfy the three axioms (vertex coverage, edge coverage, interval property) by construction. The width approximation guarantee would be empirical.

**Domain Bridges:** Connects to machine learning for combinatorial optimization, graph neural networks, and algorithm configuration.

**Lineage:** Enables practical deployment of the entire theoretical framework.

**Ambition:** Solid extension with high practical impact — makes the theory usable at scale.
