# Summary of changes for run 17ddfd63-9068-4021-a2b5-ff1fd71a1481
## Completed: Pathwidth-Guided SAT Solving — Structural Complexity Theory for Clause Learning

### Formally Verified Mathematics (Lean 4)

Two Lean files totaling ~385 lines with **10 machine-verified theorems and zero `sorry`** statements:

**`Pythagorean/ClauseInteractionPathwidth/Defs.lean`** — Core definitions:
- `confGraph`: Clause interaction graph of a CNF formula
- `PathDecomp`: Path decomposition with running intersection property
- `activeFrontier`: Clauses spanning a given cut
- `retainAtCut`: Path-respecting retention policy
- `clauseEval`: Clause evaluation under partial assignments
- `maxFrontierSize`: Peak memory metric

**`Pythagorean/ClauseInteractionPathwidth/Theorems.lean`** — Main results:

1. **Separator Theorem** (`path_bag_separates`): Every cut bag separates past from future — clauses before and after a cut can only interact through the cut bag. Proved by contradiction using edge coverage and the interval property.

2. **Active Frontier ⊆ Bag** (`activeFrontier_subset_bag`): The frontier at any cut is contained in the corresponding bag, via the running intersection property.

3. **Memory Bound** (`activeFrontier_card_le_bag_card`): Frontier cardinality ≤ bag cardinality.

4. **Width Bound** (`activeFrontier_card_le_width_succ`): Frontier size ≤ pathwidth + 1. The key result: *bounded pathwidth implies bounded live clause memory*.

5. **Frontier ⊆ Retained** (`activeFrontier_subset_retainAtCut`): All frontier clauses are retained.

6. **Edge Preservation** (`retainAtCut_preserves_frontier_edges`): All edges between frontier clauses are preserved by the retention policy.

7. **Bag Retention** (`bag_mem_subset_retainAtCut`): Every clause in the bag ∩ F is retained.

8. **Bag Locality** (`bag_locality_of_clause_evaluation`): Clause evaluation depends only on the clause's variables — the cross-domain DP connection.

9. **Cut Locality** (`cut_locality`): Assignments agreeing on bag variables produce identical evaluations for frontier clauses.

10. **Max Frontier Bound** (`maxFrontierSize_le_width_succ`): Peak frontier across all cuts ≤ width + 1.

All theorems depend only on standard axioms (propext, Classical.choice, Quot.sound).

### Supporting Deliverables

- **`ARTICLE.md`** — Popular science article (~1700 words) on the hidden geometry of SAT solver memory
- **`RESEARCH_PAPER.md`** — Comprehensive research paper with definitions, theorem statements, proof sketches, algorithms, experiments, and references
- **`FUTURE_DIRECTIONS.md`** — 5 falsifiable conjectures with structured format (memory-pathwidth correlation, separator-aware forgetting, width learnability regime, DP equivalence, ML decomposition discovery)
- **`demo.py`** — Interactive demonstrations: small formulas, interaction graphs, decompositions, frontier bounds, separator property, retention comparison
- **`algorithms.py`** — Core algorithms: greedy elimination decomposition, sliding window decomposition, frontier computation, retention analysis
- **`applications.py`** — Applications: formula family comparison, memory savings analysis, DP locality demonstration, scalability benchmarks
- **`PACKAGE.json`** — Complete JSON data package for web templating