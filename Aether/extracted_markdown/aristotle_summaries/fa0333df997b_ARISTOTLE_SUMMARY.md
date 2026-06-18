# Summary of changes for run 8b53a7d9-8e34-4260-ae7c-3b2ab3c8a48f
## Causal Inference: Do-Calculus as Formal Logic — Lean 4 Formalization

### Deliverables

**`Physics/DoCalculus.lean`** (396 lines, 0 sorries, 27 proven theorems) — A complete formalization of Pearl's do-calculus framework as a formal logical system in Lean 4. Also copied to `Catalog/Physics/DoCalculus.lean`.

**`FUTURE_DIRECTIONS.md`** — 5 falsifiable research conjectures extending the formalization.

### Key Definitions
- **`CausalDAG n`**: Directed acyclic graphs on `Fin n` with topological ordering (acyclicity by construction)
- **`CausalDAG.mutilate`**: Graph mutilation — the graph-theoretic do-operator that removes incoming edges to intervention targets
- **`CausalDAG.reaches`**: Reachability (transitive closure of edges) with `ancestors`, `descendants`, and set-level variants
- **`DSepOracle`**: Abstract d-separation satisfying graphoid axioms (symmetry, decomposition, weak union)
- **`DoCalculusRule`**: Pearl's three do-calculus rules as a formal inference system with graph conditions
- **`DoDerivation`**: Sequences of valid rule applications forming causal inference derivations
- **`BackDoorCriterion`**: The back-door criterion for causal effect identification

### Main Theorems (all fully proven, no sorry)

1. **`reaches_strict_mono`**: Reachability preserves strict topological ordering — the fundamental acyclicity guarantee
2. **`mutilate_compose`**: Sequential interventions compose: `(G.mutilate S).mutilate T` has the same edges as `G.mutilate (S ∪ T)`
3. **`mutilate_comm`**: Interventions commute: order doesn't matter
4. **`mutilate_idem`**: Interventions are idempotent: repeating has no effect
5. **`intervention_disconnects`**: **Intervention Fixpoint Theorem** — intervened vertices have no ancestors in the mutilated graph, formalizing that intervention disconnects variables from their causes
6. **`wf_reaches`**: Well-foundedness of the reachability relation, enabling induction along DAG structure
7. **`mutilate_reaches_of_reaches`**: Monotonicity — reachability in mutilated graphs implies reachability in the original

Plus 20 additional supporting theorems covering edge antisymmetry, concrete DAG constructions (empty, complete, chain graphs), and structural properties.

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).