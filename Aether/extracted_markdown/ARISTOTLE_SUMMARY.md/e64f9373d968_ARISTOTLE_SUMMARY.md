# Summary of changes for run fc241335-535c-4ce7-a6f0-a08f9ee94773
## Completed: Arithmetic Monodromy from Persistent Homology of Newton Iteration Graphs

### Formally Verified Mathematics (Lean 4)

**File:** `Catalog/Speculative/NewtonPersistence/Basic.lean`

Built a complete Lean 4 formalization with **zero sorries** and clean axioms (only `propext`, `Classical.choice`, `Quot.sound`). The development includes:

**New Definitions:**
- `newtonStep?`: The Newton map N_f(x) = x - f(x)/f'(x) as a partial function
- `IsNewtonFixed`: Nonsingular Newton fixed point predicate
- `IsNewtonEdge`: Newton functional graph edge relation
- `rootBasinDepth`: Basin-depth filtration for persistence (depth 0 = nonsingular roots, ⊤ otherwise)
- `beta0`: Zeroth Betti number (connected components) of a finite graph
- `newtonFixedCount`, `rootCount`: Persistence and arithmetic statistics
- `predecessorCount`: Fiber filtration statistic

**7 Proved Theorems:**

1. **`newton_fixed_iff_eval_eq_zero`** — Over any field, N_f(x) = x ⟺ f(x) = 0 when f'(x) ≠ 0. The foundational arithmetic-dynamical identity.

2. **`squarefree_eval_derivative_ne_zero`** — Squarefree polynomials over perfect fields have nonzero derivative at every root. Uses the chain: squarefree ↔ separable (over perfect fields) → coprimality of f and f'.

3. **`card_newtonFixed_eq_card_roots_of_squarefree`** — For squarefree f over ZMod p, |{Newton fixed points}| = |{roots}|. The arithmetic monodromy bridge: the Newton persistence statistic S_p(f) recovers the Frobenius fixed-point count.

4. **`card_depth_zero_eq_card_roots`** — The depth-0 barcode multiplicity equals the root count for squarefree polynomials.

5. **`beta0_of_empty_graph`** — β₀ of a discrete graph equals the vertex count (each vertex is its own connected component).

6. **`beta0_depthZero_eq_rootCount`** — The topological–arithmetic bridge: β₀ of the depth-0 subgraph equals the number of roots. Connects topology (connected components) to arithmetic (Frobenius statistics) through dynamics (Newton iteration).

7. **`persistence_separates_root_counts`** — If two squarefree polynomials have different root counts mod p, their Newton persistence statistics differ. The persistence statistic is at least as discriminating as Frobenius root-count data.

Plus supporting lemmas: `isNewtonFixed_iff`, `rootBasinDepth_eq_zero_iff`, `rootBasinDepth_eq_zero_iff_isNewtonFixed`, `root_isNewtonFixed_of_squarefree`, `root_in_own_predecessor_fiber`.

### Written Deliverables

- **`ARTICLE.md`** — A ~2500-word popular-science article explaining how Newton's root-finding algorithm, when run in finite arithmetic worlds, produces dynamical fingerprints of hidden algebraic symmetry. Written for a general educated audience.

- **`RESEARCH_PAPER.md`** — A comprehensive research paper with abstract, theorem statements, proof sketches, algorithms with complexity analysis, computational experiments, conjectures with refutation criteria, and references.

- **`FUTURE_DIRECTIONS.md`** — Five research directions with the required structured format: (1) Higher-depth barcodes encoding Frobenius cycle types, (2) Spectral theory of Newton adjacency matrices, (3) ML classification of Galois groups from persistence data, (4) Tropical Newton dynamics, (5) A persistent Chebotarev theorem (grand challenge).

### Python Code

- **`demo.py`** — Interactive demonstration verifying all theorems computationally: fixed point = root verification, root-count distributions across primes for different Galois groups, basin-depth histograms, β₀ bridge.

- **`algorithms.py`** — Documented implementations of Newton graph construction, fixed-point finding, basin-depth histograms, and theorem verification functions.

- **`applications.py`** — Galois group fingerprinting, Chebotarev prediction comparison, and depth-profile analysis beyond root counts.

### Visualizations

- **`viz_root_distributions.py`** — Bar charts of S_p(f) distributions for 4 polynomials with different Galois groups (S₃, ℤ/3, S₅, V₄).
- **`viz_newton_graph.py`** — Circular-layout Newton functional graphs over small finite fields with depth coloring.
- **`viz_depth_heatmap.py`** — Heatmaps of basin-depth histograms across many primes.

### Interactive Demos

- **`interactive_newton.html`** — Interactive Newton graph explorer with polynomial/prime selectors.
- **`interactive_galois.html`** — Interactive Galois fingerprint comparison with adjustable prime bound.

### Data Package

- **`PACKAGE.json`** — Complete JSON bundle of all deliverables for web templating.