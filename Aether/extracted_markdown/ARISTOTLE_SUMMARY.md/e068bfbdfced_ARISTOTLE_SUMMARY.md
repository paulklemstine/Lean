# Summary of changes for run 3017a8df-15bf-4b9a-91ec-6684147dc127
## Stereographic Neural Attention: Attention via the Riemann Sphere

### Research Summary

This research cycle established a rigorous mathematical foundation for **stereographic attention** — an attention mechanism that replaces the exponential kernel of softmax with the Cauchy kernel K(q,k) = 1/(1+‖q−k‖²), motivated by the geometry of stereographic projection onto the Riemann sphere.

### Lean 4 Proofs (18 theorems, all verified, zero sorries)

**Files:**
- `Novelty/StereographicAttention/Defs.lean` — Core definitions (Cauchy kernel, attention weights, parameterized Cauchy family, significant keys, sparsity radius)
- `Novelty/StereographicAttention/Theorems.lean` — 18 formally verified theorems

**Key theorems proved:**

1. **Cauchy Kernel Properties**: Positivity (K > 0), upper bound (K ≤ 1), self-attention maximality (K(q,q) = 1), symmetry (K(q,k) = K(k,q))

2. **Sparsity Radius Bound** (the core result): If K(q,k) ≥ ε then ‖q−k‖² ≤ 1/ε − 1. This tight characterization shows only keys within a computable radius contribute significantly. The converse is also proved.

3. **Monotone Decay**: Closer keys always receive more attention weight.

4. **Probability Distribution**: Normalized Cauchy weights sum to 1, each weight is nonneg — forming a valid probability distribution.

5. **Cauchy-Gaussian Bridge** (deepest result): (1 + r²/t)^{−t} → exp(−r²) as t → ∞. This proves that softmax attention is the infinite-temperature limit of stereographic attention, establishing a continuous family connecting the two mechanisms.

6. **Dimension Independence**: Kernel value depends only on distance, not ambient dimension.

7. **Polynomial Decay**: For |q−k| ≥ 1, K(q,k) ≤ 1/(q−k)².

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

### Deliverables

- **ARTICLE.md** — Popular science article (Scientific American style) about the geometric ideas
- **RESEARCH_PAPER.md** — Full research paper with abstract, definitions, PEGB analysis, algorithms, and references
- **FUTURE_DIRECTIONS.md** — 5 research directions including Riesz kernel generalization, harmonic attention, Möbius equivariance, universal approximation, and tropical stereographic attention
- **PACKAGE.json** — Complete package with 3 interactive HTML widgets (attention explorer, bridge visualizer, sparsity calculator)
- **demo.py** — Numerical demonstrations of all key properties
- **algorithms.py** — Type-hinted implementations (stereographic projection, sparse attention, multi-head attention, bridge annealing)
- **viz_kernel_decay.py, viz_sparsity.py, viz_bridge.py** — Visualization scripts