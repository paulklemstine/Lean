# Summary of changes for run e604605b-a360-4dd5-af78-b7a86a39cad2
## Completed: Tropical Scaling Exponents for Computation DAGs

### Formally Verified Mathematics (Lean 4)

Created `Speculative/TropicalScaling/Basic.lean` — a complete, sorry-free formalization (~400 lines) containing:

**Core Definitions:**
- `TropAffine`: tropical affine forms (rational slope × intercept pairs) representing path cost functions
- `TropicalProfile`: nonempty finite sets of affine forms, modeling all source-to-sink path costs in a computation DAG
- `TropicalProfile.envelope`: pointwise minimum (tropical envelope) — the optimal complexity at each scale
- `TropicalProfile.scalingExponent`: minimum slope across all path costs — the power-law scaling rate
- `WeightedDAG`: weighted computation DAGs with vertex/edge counts and tropical profiles
- `TropicalEquivalent` / `ExtTropicalEquivalent`: two notions of tropical equivalence

**Key Theorems (all fully proved, no sorry):**
1. **Eventual dominance** (`eval_le_of_slope_lt`): Lower-slope affine forms eventually dominate higher-slope ones
2. **Scaling exponent rationality** (`scalingExponent_rational`): The exponent is always rational
3. **Tropical invariance** (`scalingExponent_tropical_invariant`): The scaling exponent is invariant under tropical equivalence
4. **Envelope invariance** (`envelope_tropical_invariant`): The full envelope is invariant
5. **Asymptotic sandwich** (`envelope_asymptotic_sandwich`): The envelope is eventually squeezed between two affine functions with slope = scaling exponent
6. **Non-isomorphic examples**: Two explicit pairs of non-isomorphic but tropically equivalent DAGs:
   - Chain (3 vertices) ≈ Diamond (4 vertices), both with α = 1/2
   - Wide (5 vertices) ≈ Deep (6 vertices), both with α = 1/3
7. **Computed exponents** (`chainDAG_exponent`, `wideDAG_exponent`): Concrete exponent values verified
8. **Extensional transfer** (`ext_equiv_same_asymptotics`): Asymptotic bounds transfer across extensional equivalence

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

### Additional Deliverables

- **ARTICLE.md**: ~2000-word popular science article explaining how tropical geometry reveals hidden mathematical laws behind AI scaling
- **RESEARCH_PAPER.md**: ~5000-word research paper with abstract, full theorem statements, proof sketches, algorithms with complexity analysis, computational experiments, and references
- **FUTURE_DIRECTIONS.md**: 5 falsifiable scientific hypotheses (exponent completeness, polylog corrections, motivic refinement, complexity transfer, tropical minor monotonicity) each with precise conjectures, tests, and refutation criteria
- **demo.py**: Interactive demonstration of all theorems with numerical examples (runs successfully)
- **algorithms.py**: Complete implementations of tropical profile extraction, scaling exponent computation (O(V+E) DP), and equivalence testing with exact rational arithmetic
- **applications.py**: Architecture comparison, composition rules, optimal path selection, ASCII envelope visualization, and scaling law prediction
- **PACKAGE.json**: Complete JSON data package bundling all artifacts