# Summary of changes for run cd25fe6f-8ad9-4224-944a-70837f7b8f10
## The Topology of Argumentation: Why Debates Have Holes

### Summary

I formalized the connection between Dung's argumentation frameworks and abstract simplicial complexes in Lean 4, producing a complete research package with 18 machine-verified theorems, all without `sorry`.

### Lean 4 Proofs (`Novelty/ArgumentationComplex.lean`)

**18 theorems, all formally verified**, organized into 10 sections:

1. **Simplicial Complex Property** (`conflict_free_downward_closed`): Subsets of conflict-free sets are conflict-free — the fundamental property that makes conflict-free sets form an abstract simplicial complex (the "argumentation complex" K(AF)).

2. **Dung's Fundamental Lemma** (`fundamental_lemma`): If S is admissible and argument a is acceptable w.r.t. S, and S ∪ {a} is conflict-free, then S ∪ {a} is admissible. This is the constructive engine of argumentation semantics.

3. **Symmetric Bridge Theorem** (`symmetric_cf_is_admissible`, `symmetric_preferred_is_maximal_cf`, `symmetric_maximal_cf_is_preferred`): For symmetric attack relations, conflict-free = admissible. This bridges argumentation theory to graph independence theory — preferred extensions are exactly maximal independent sets.

4. **Semantic Hierarchy** (`stable_is_admissible`, `stable_implies_preferred`): Every stable extension is a preferred extension (strict containment in general).

5. **Preferred Extension Existence** (`preferred_extension_exists`): Every finite AF has at least one preferred extension.

6. **Complex Characterization** (`full_set_conflict_free_iff_no_attacks`, `no_attacks_unique_preferred`): K(AF) is a full simplex iff no attacks exist; in that case, the entire argument set is the unique preferred extension.

7. **Characteristic Function** (`characteristicFn_monotone`, `admissible_iff_cf_and_sub_char`): Monotonicity of Dung's F operator and characterization of admissible sets as pre-fixpoints.

8. **f-Vector Identity** (`f0_eq_non_self_attacking`): The number of 0-faces equals the number of non-self-attacking arguments.

### Deliverables

- **`Novelty/ArgumentationComplex.lean`** — 314-line Lean 4 file with 18 proved theorems
- **`Novelty/ARTICLE.md`** — Popular science article (~2000 words) on the topology of debate
- **`Novelty/RESEARCH_PAPER.md`** — Research paper with full PEGB analysis for key theorems
- **`Novelty/FUTURE_DIRECTIONS.md`** — 5 research directions including homological phase transitions, spectral gaps, persistent homology, nerve complexes, and tropical argumentation
- **`Novelty/algorithms.py`** — Type-hinted Python implementations of all argumentation semantics
- **`Novelty/demo.py`** — 6 demos showing the theorems in action computationally
- **`Novelty/viz_argumentation.py`** — Matplotlib visualizations of Euler characteristics and f-vectors
- **`Novelty/PACKAGE.json`** — Full package with 2 interactive HTML widgets (Argumentation Complex Explorer, Semantic Hierarchy Visualizer)

### Key Mathematical Insights

- The original Euler characteristic conjecture (χ = |preferred| - |grounded|) was **disproved** computationally (3-cycle gives χ=3 but |pref|-|grounded|=1).
- The Symmetric Bridge theorem reveals that three separate mathematical traditions (argumentation theory, graph theory, topological combinatorics) study the same object.
- Computational experiments reveal periodic behavior in the Euler characteristic for cyclic frameworks.