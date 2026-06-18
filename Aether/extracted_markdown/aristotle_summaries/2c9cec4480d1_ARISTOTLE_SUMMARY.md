# Summary of changes for run fbffe2be-d2ff-4979-85b9-5c97933b5ce5
## Research Cycle: Gap Automaton Spectral Theory

### Lean 4 Proofs (`Tropical/GapAutomatonSpectral.lean`)

Formalized 11 theorems with complete proofs (zero `sorry`), all verified to use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

**Novel Definitions:**
- `walkCount` — Recursive directed walk counting in multigraphs
- `GapSFT` — Subshift of finite type from prime gap sieve automata, with transfer matrix construction and word growth function
- `entrywiseLe` — Entrywise partial order on ℕ-valued matrices

**Core Theorems (genuine mathematical insight):**
1. **`walkCount_eq_pow`** — The Walk-Matrix Correspondence: walks of length k from s to t equal (A^k)(s,t). The fundamental bridge between combinatorial graph theory and linear algebra.
2. **`walkCount_add`** — Walk Decomposition: walks of length m+n decompose at midpoints, corresponding to A^(m+n) = A^m · A^n.
3. **`closedWalks_eq_trace`** — Closed walks of length k = tr(A^k), connecting cycle counting to eigenvalue sums.
4. **`entrywiseLe_mul_of_entrywiseLe`** — Entrywise monotonicity of matrix multiplication for ℕ-valued matrices.
5. **`entrywiseLe_pow_of_entrywiseLe`** — Entrywise monotonicity propagates through matrix powers.
6. **`diagonal_pow_lower_bound`** — Self-loop growth bound: if A(i,i) ≥ c then (A^k)(i,i) ≥ c^k, giving spectral radius lower bounds from local data.
7. **`gapSFT_alphabet_mono`** — Enlarging the gap alphabet increases all transfer matrix entries.
8. **`gapSFT_walk_growth_mono`** — Combined: alphabet inclusion implies walk count inequality at every length.
9. **`sieve6_monotonicity`** — Concrete application to the {2,3}-sieve automaton.

**Conjecture with testable prediction:** Spectral gap monotonicity across sieve depths (stated informally with computational test specified in the docstring).

### Other Deliverables
- **ARTICLE.md** — Popular-science article (~2000 words) about the mathematical ideas, not formal verification
- **RESEARCH_PAPER.md** — Full research paper with abstract, definitions, proof sketches, algorithms, and references
- **FUTURE_DIRECTIONS.md** — 5 research directions with synthesis, conjectures, tests, and proof strategies
- **demo.py** — 6 interactive demos verifying all theorems computationally
- **algorithms.py** — Type-hinted implementations of transfer matrix construction, walk counting, and spectral analysis
- **viz_walk_growth.py** — Three-panel matplotlib visualization
- **PACKAGE.json** — Complete JSON bundle with 3 interactive HTML widgets (Gap Automaton Explorer, Walk Decomposition Visualizer, Spectral Growth Bound Checker)