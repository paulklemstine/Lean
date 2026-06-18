# Summary of changes for run 6ac94215-b55b-48cc-b7a9-ac5c23e1ce80
# Integrated Information Theory — Formal Mathematics of Consciousness

## Summary

This research cycle formalizes Integrated Information Theory (IIT) in Lean 4, reducing the integrated information measure Φ to the **minimum directed cut** of a causal graph, and proving its fundamental properties with complete machine-verified proofs.

## Lean 4 Proofs (14 theorems, 0 sorries)

### `Novelty/IIT/Core.lean` — Core Theory (7 theorems)
- **`phi_pos_iff_connected`** (Fundamental Theorem): Φ > 0 ⟺ the causal system is causally connected. This is the central result — integrated information requires irreducible causal structure.
- **`causallyConnected_of_phi_pos`**: Forward direction — positive Φ implies every partition has crossing edges.
- **`phi_pos_of_causallyConnected`**: Reverse direction — connectivity implies positive Φ.
- **`phi_zero_of_disconnected`**: Any decomposable partition drives Φ to zero.
- **`cutSize_compl`**: Cut symmetry — cutSize(A) = cutSize(Aᶜ).
- **`cutSize_le_card_sq`**: Cut size bounded by |S|².
- **`phi_nonneg`**: Φ ≥ 0.

### `Novelty/IIT/Composition.lean` — Composition, Exclusion, and Complexity (7 theorems)
- **`phi_mono_of_extension`**: Monotonicity — adding causal edges cannot decrease Φ.
- **`cutSize_mono_of_extension`**: Pointwise monotonicity of cut sizes.
- **`phi_eq_cutSize_mip_aux`**: The MIP (minimum information partition) exists and achieves Φ.
- **`nontrivialSubsets_card`**: Exactly 2ⁿ − 2 non-trivial partitions (exponential complexity).
- **`nontrivialSubsets_card_ge`**: At least n non-trivial partitions.
- **`cutSize_zero_of_no_cross_edges`**: Zero-edge characterization.
- **`cutSize_complete`**: Complete graph cut formula.

Plus: categorical structure with `CausalMorphism`, identity, and composition.

## Key Mathematical Insights

1. **IIT ↔ Graph Connectivity Bridge**: The Fundamental Theorem establishes that integrated information is exactly graph connectivity — connecting neuroscience to spectral graph theory and the Cheeger constant.
2. **Monotonicity as Composition**: Adding causal structure can only increase integration, formalizing IIT's composition axiom.
3. **Exponential Complexity**: Computing Φ requires examining 2ⁿ − 2 partitions, connecting consciousness to computational complexity.

## Deliverables

- **`ARTICLE.md`** — Popular science article (Scientific American style) about the mathematics of consciousness
- **`RESEARCH_PAPER.md`** — Full research paper with PEGB analysis for all major theorems
- **`FUTURE_DIRECTIONS.md`** — 5 research directions including Spectral IIT, Weighted Φ, NP-hardness, k-partitions, and Quantum Φ
- **`demo.py`** — Numerical demonstrations of all theorems
- **`algorithms.py`** — Type-hinted implementations of Φ computation
- **`viz_phi_landscape.py`**, **`viz_mip_barbell.py`** — Visualization scripts
- **`PACKAGE.json`** — Complete package with 2 interactive HTML demos (causal system explorer and phase transition simulator)

All proofs use only standard axioms (propext, Classical.choice, Quot.sound). The build is clean with no warnings or sorries.