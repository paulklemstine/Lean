# Summary of changes for run 71b3a4c1-e5f3-4aa2-b4a1-f52d4898dcb1
## Circuit Complexity Barriers: Algebrization, Proof Systems, and Formula Structure

### Lean 4 Proofs (`Computation/CircuitBarriers.lean`)

A complete, sorry-free formalization of complexity theory barriers with **15+ formally verified theorems**:

**Formula Structure Theory (structural induction + calc):**
- `formula_leaves_le_pow_depth`: leaves(φ) ≤ 2^depth(φ) — fundamental depth-width trade-off
- `formula_numVars_le_leaves`: |vars(φ)| ≤ leaves(φ) — distinct variables bounded by leaf count
- `formula_numVars_le_pow_depth`: |vars(φ)| ≤ 2^depth(φ) — composition of the above two
- `formula_leaves_le_size`: leaves(φ) ≤ size(φ)

**Novel Definitions:**
- `AlgebraicOracle`: Low-degree polynomial extensions of Boolean oracles over arbitrary fields
- `ProofSystem`: Abstract proof system with soundness/completeness and simulation ordering
- `BoolFormula`: Full Boolean formulas with negation, restriction operations, and variable tracking
- `VarStatus` / `Restriction`: Random restriction framework for switching lemma applications

**Algebrization Barrier (by_contra):**
- `algebrization_barrier`: Algebraically separated properties cannot be equated by any algebrizing technique

**Proof System Framework (obtain/rcases):**
- `ProofSystem.simulates_refl`: Simulation is reflexive
- `ProofSystem.simulates_trans`: Simulation composes transitively with monotone bounds

**Random Restriction Framework (induction + cases):**
- `restrict_eval_eq`: Restrictions preserve formula semantics
- `restrict_depth_le`: Restrictions never increase depth
- `restrict_leaves_le`: Restrictions never increase leaf count

**Additional Results:**
- `BoolFormula.eval_depends_only_on_vars`: Evaluation depends only on mentioned variables
- `three_barriers_impossibility`: Relativizing techniques cannot separate oracle-dependent classes
- `shannon_bound_pos`: Shannon's counting lower bound is positive (induction + by_cases + calc)
- `num_boolean_functions`: Exact count of Boolean functions on n variables

**Conjecture with Testable Prediction:**
- `depthVariableConjecture`: Any formula using all n distinct variables has depth ≥ ⌈log₂(n)⌉. Testable by enumerating small formulas. In fact follows from the proved `formula_numVars_le_pow_depth`.

### Supporting Documents
- **ARTICLE.md**: ~2000-word Scientific American-style article about the three barriers to P vs NP, focused on mathematical ideas (no mention of formal verification tools)
- **RESEARCH_PAPER.md**: ~4000-word research paper with abstract, definitions, proof sketches, and references
- **FUTURE_DIRECTIONS.md**: 5 research directions with Synthesis section, including a grand challenge (formal switching lemma → AC⁰ lower bounds) and extensions to KW games, resolution complexity, natural proofs, and tropical methods

### Python Code
- **demo.py**: Comprehensive demonstration with numerical examples for all results
- **algorithms.py**: Type-hinted implementations of random restrictions, switching lemma experiments, sensitivity computation, and formula analysis

### Visualizations
- **viz_formula_depth.py**: Formula leaves vs 2^depth bound + Shannon counting
- **viz_barriers.py**: Three barriers Venn diagram + sensitivity plots
- **viz_switching.py**: Random restriction depth reduction simulation

### Interactive Demos (in PACKAGE.json)
1. **Formula Depth-Width Explorer**: Slider-based exploration of the 2^depth bound
2. **Random Restriction Simulator**: Monte Carlo simulation of depth reduction
3. **Three Barriers Explainer**: Clickable guide to relativization, natural proofs, and algebrization

All Lean proofs compile with zero sorries and use only standard axioms (propext, Classical.choice, Quot.sound).