# Summary of changes for run 9cab5a5d-19bc-4fa8-ae87-512b1c59f59f
# Cellular Automata as Algebraic Geometry over GF(2): Research Cycle Complete

## Summary

This research cycle formalized elementary cellular automata (ECAs) as polynomial dynamical systems over GF(2) and studied their fixed-point varieties. The central conjecture — that fixed-point variety dimension correlates with Wolfram's complexity classification — was **falsified** by computation: Rule 110 (Turing-complete) has a single fixed point (dim 0) while Rule 204 (identity) has maximal dimension. This negative result is itself a significant scientific finding.

## Lean 4 Formalization (`Shared/CellularAlgebraicGeometry.lean`)

320 lines, 16 theorems, **zero sorries**, all axioms standard. Key results:

1. **ANF Uniqueness** (`anf_eval_correct`, `anf_unique`): Every ECA rule has a unique Algebraic Normal Form polynomial over GF(2), computed by Möbius inversion.

2. **Submodule Structure** (`ECAFixedSubmodule`): For additive (degree ≤ 1) ECA rules, the fixed-point set is a GF(2)-submodule of GF(2)^n. This is proved via three closure lemmas: zero membership, additive closure, and scalar closure.

3. **Degree-Linearity Bridge** (`additive_degree_le_one`, `rule110_not_additive`, `rule110_maximal_degree`): Additive rules have ANF degree ≤ 1. Rule 110 has maximal degree 3 and is provably not additive.

4. **Fixed-Point Characterization**: Rule 0 has a unique fixed point (zero), Rule 204 fixes every state, and fixed points are invariant under iteration.

5. **Nilpotency** (`rule0_nilpotent`): Rule 0 sends every state to zero in one step.

Novel definitions: `ECALocalRule`, `ANFCoeffs`, `IsAdditiveRule`, `ECAFixedSubmodule`, `IsNilpotentRule`, `algebraicDegree`.

## Deliverables

- **`ARTICLE.md`**: Popular-science article (~2500 words) on the ideas behind viewing cellular automata as algebraic geometry
- **`RESEARCH_PAPER.md`**: In-depth research paper (~4000 words) with definitions, proofs, computational results, and discussion
- **`FUTURE_DIRECTIONS.md`**: 5 research directions including orbit zeta functions, Gröbner bases for nonlinear varieties, sheaf cohomology, number-theoretic dimension formulas, and generalization to GF(p)
- **`demo.py`**: Computational demo showing ANF computation, fixed-point counting, subspace verification, and degree-complexity correlation
- **`algorithms.py`**: Type-hinted implementations of ANF computation and fixed-point dimension calculation
- **`viz_anf_degree.py`**: Matplotlib visualization script
- **`PACKAGE.json`**: Complete package with 2 interactive HTML widgets (ECA Rule Explorer and ANF Degree Heatmap)