# Summary of changes for run a528eb21-4924-41e5-af95-37c14764d610
## Completed: Quantum Circuit Rewriting via Tensor Distributivity

### Formally Verified Mathematics (Lean 4)

**File:** `Catalog/Pythagorean/QuantumCircuitRewriting.lean` — 450+ lines, **zero sorries**, builds cleanly.

I formalized a distributive rewrite system for quantum circuit expressions and proved 9 non-trivial theorems establishing that distributive rewriting yields a canonical normal form. The central insight: **quantum linearity is distributivity** — the linearity of quantum mechanics corresponds exactly to the algebraic distributive law.

**Key definitions:**
- `QExpr` — Quantum tensor expression language (gates, sequential composition, formal addition, identity)
- `QRewriteStep` — One-step distributive rewrite relation (left/right distribution + identity laws)
- `expand` — Distributive expansion to sum-of-products normal form
- `ParallelACEq` — Equivalence modulo permutation of summands (captures AC commutativity)
- `IsQuantumNormalForm` / `IsProduct` — Normal form predicates

**Proved theorems (all machine-verified, clean axioms):**
1. **One-step soundness** (`qrewrite_sound`): Every rewrite preserves denotation in any semiring
2. **Multi-step soundness** (`qrewrite_star_sound`): Rewrite chains preserve semantics
3. **Expansion soundness** (`expand_sound`): The normalization function correctly computes sum-of-products
4. **Semantic confluence** (`confluence_via_normalize`): Any two rewrite paths from a common source yield semantically equal results
5. **AC-equivalence preserves semantics** (`same_nf_same_semantics`): Permuted normal forms have equal denotation
6. **Cross-domain bridge** (`rewrite_equiv_algebraic_eq`): Rewrite equivalence = algebraic equality in every semiring
7. **Normalization soundness** (`normalize_sound`): The normalize function preserves semantics
8. **Expansion invariance** (`expand_perm_of_rewrite` / `expand_perm_of_rewrite_star`): Rewrites correspond to monomial permutations
9. **Grand confluence theorem** (`distributive_normalization_confluent`): Any two rewrite sequences from a common source yield AC-equivalent expansions

Supporting lemmas: `denoteMono_append`, `denoteNF_append`, `denoteNF_map_append`, `denoteNF_flatMap`, `monoToExpr_denote`, `expand_nonempty`.

### Documentation

- **`ARTICLE.md`** — 1,900-word popular science article explaining why quantum circuits are hard to compare and how distributivity provides canonical forms (no mention of formal verification tools)
- **`RESEARCH_PAPER.md`** — 2,500-word comprehensive research paper with abstract, full theorem statements, proof sketches, computational experiments, and references
- **`FUTURE_DIRECTIONS.md`** — 5 research directions with structured format: gate-specific completion, categorical coherence, entanglement-aware normal forms, tropical variants, and BDD-based scalability

### Python Code

- **`demo.py`** — Interactive demo: constructs 2-qubit circuits, normalizes them, verifies soundness numerically, demonstrates confluence, and searches for counterexamples up to configurable depth
- **`algorithms.py`** — Core algorithms with docstrings: `expand`, `normalize`, `equiv_check`, `monomial_count`, `classify_circuits`
- **`applications.py`** — Applications: identity circuit detection, gate count optimization, equivalence checking, entanglement analysis

### Visualizations

- **`viz_expansion_tree.py`** — Expression tree → sum-of-products visualization
- **`viz_confluence.py`** — Confluence diamond diagram
- **`viz_normal_form_landscape.py`** — Statistical landscape of normal forms (4-panel chart)

### Interactive Demos

- **`interactive_rewriting.html`** — Step-by-step distributive rewriting explorer
- **`interactive_confluence.html`** — Confluence diamond visualizer with preset examples

### Data Package

- **`PACKAGE.json`** — Complete JSON bundle of all artifacts for web templating