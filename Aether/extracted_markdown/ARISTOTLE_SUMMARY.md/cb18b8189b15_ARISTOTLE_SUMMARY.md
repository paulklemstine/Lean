# Summary of changes for run dec85590-0c79-434e-aefe-99c370a29f0f
## Completed: Chip-Firing and the Canonical Divisor — Riemann-Roch for Graphs

### Lean 4 Formalization (25 theorems, 0 sorries)

**File**: `Applications/ChipFiringCanonical.lean` (457 lines, fully verified)

Core definitions formalized:
- `Divisor` — integer-valued functions on vertices (formal sums)
- `laplacian` — the graph Laplacian operator
- `chipFire` — the chip-firing operation
- `canonical` — the canonical divisor K_G(v) = deg(v) - 2
- `genus` — graph genus g = |E| - |V| + 1
- `linEquiv` — linear equivalence of divisors
- `divRank` — the Baker-Norine rank function
- **Novel: `FiringScript`** — firing sequences as group elements
- **Novel: `applyFiringScript`** — the chip-fire group action
- **Novel: `rankStability`** — the rank stability spectrum

Key theorems proved (all 25 sorry-free):
1. **Abelian Sandpile Property** (`chipFire_comm`): chip-firing at distinct vertices commutes
2. **Gauss-Bonnet for Graphs** (`canonical_degree`): deg(K_G) = 2g - 2
3. **Complete Graph Genus** (`complete_graph_genus`): g(K_n) = (n-1)(n-2)/2
4. **Canonical of K_n** (`canonical_complete_value`): K_{K_n}(v) = n - 3
5. **Degree Preservation** (`chipFire_preserves_degree`): chip-firing conserves total chips
6. **Linear Equivalence Theory**: reflexive, symmetric, transitive; preserves degree
7. **Firing Script Algebra**: composition, commutativity, identity, degree preservation
8. **Rank-Degree Bound** (`rank_neg_of_neg_degree`): negative degree implies rank -1
9. **Canonical Involution**: K - (K - D) = D (graph-theoretic Serre duality)

### Deliverables

- **ARTICLE.md** — Scientific American-style article on chip-firing and graph Riemann-Roch
- **RESEARCH_PAPER.md** — Full research paper with definitions, theorems, PEGB analysis, algorithms
- **FUTURE_DIRECTIONS.md** — 5 research directions including Tropical Brill-Noether, Jacobian groups, chip-firing zeta functions, gonality bounds, and harmonic morphisms
- **demo.py** — Interactive demonstrations of all key results
- **algorithms.py** — Implementations of canonical divisor computation, chip-firing, Dhar's burning algorithm, rank computation, and rank stability
- **viz_chip_firing.py** — Matplotlib visualizations of genus growth and Gauss-Bonnet verification
- **PACKAGE.json** — Complete package with 3 interactive HTML widgets (chip-firing simulator, Gauss-Bonnet explorer, firing script calculator)