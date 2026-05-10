# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-09 21:17*

## Breakthrough Opportunities (ranked by impact)

### 1. Barabanov Norm Construction for Irreducible Weight Systems

- **Theorem Statement**: For any irreducible weight system 𝒜 with JSR ρ > 0, there exists a norm ‖·‖_B such that ∀ A ∈ 𝒜, ∀ x, ‖Ax‖_B ≤ ρ · ‖x‖_B, with equality achieved for some A, x.
- **Proof Strategy**:
  1. Define candidate norm via limsup: ‖x‖_B = limsup_{k→∞} ρ^{-k} · max_{products P of length k} ‖P·x‖
  2. Show this limit exists using submultiplicativity and the JSR definition
  3. Verify norm axioms using irreducibility (positive definiteness requires no proper invariant subspace)
  4. Key lemma: `irreducible_system_barabanov_candidate_is_norm`
- **Why This Is Revolutionary**: Provides the *tight* Lipschitz constant, replacing the conservative max-norm bound with the optimal JSR bound. This would give the strongest possible robustness certificates.
- **Catalog Leverage**: Build on `depth_product_norm_bound`, `contractive_convergence_rate`, `geometric_tail_bound`
- **Research Mode**: prove
- **Estimated Depth**: 4/5

### 2. Artin-Wedderburn Minimal Architecture Decomposition

- **Theorem Statement**: For a weight algebra A over an algebraically closed field, A/J(A) ≅ ∏ M_{nᵢ}(k), and the widths nᵢ give the minimal architecture.
- **Proof Strategy**:
  1. Show A/J(A) is semisimple (by definition of Jacobson radical)
  2. Apply Artin-Wedderburn theorem from Mathlib (`Ideal.jacobson`, `Subalgebra` API)
  3. Prove JSR is preserved under quotient by nilpotent ideal
  4. Key lemma: `quotient_by_radical_preserves_jsr`, `semisimple_artin_wedderburn_decomposition`
- **Why This Is Revolutionary**: Provides *provably optimal* neural network compression — the mathematically smallest network computing the same function.
- **Catalog Leverage**: Build on `nilpotent_pruning_bound`, `nilpotent_norm_vanishes`, `growth_equiv_preserves_polynomial`
- **Research Mode**: prove
- **Estimated Depth**: 5/5

### 3. GK-Dimension Bounds VC-Dimension

- **Theorem Statement**: For a weight algebra A with GK-dim(A) = d, the VC-dimension of the function class {x ↦ Wx : W ∈ A} is O(d · log(d)).
- **Proof Strategy**:
  1. Show polynomial growth of degree d limits the number of dichotomies on any finite set
  2. Use Sauer-Shelah lemma to convert growth bound to VC-dimension bound
  3. Key lemma: `gk_dim_bounds_dichotomy_count`, `sauer_shelah_polynomial_growth`
- **Why This Is Revolutionary**: Bridges algebraic complexity (GK-dimension) to statistical learning theory (VC-dimension), enabling certified generalization bounds from algebraic structure alone.
- **Catalog Leverage**: Build on `tensor_growth_polynomial_bound`, `polynomial_growth_monotone`, `complexity_dichotomy`
- **Research Mode**: prove
- **Estimated Depth**: 3/5

### 4. Tropical Joint Spectral Radius

- **Theorem Statement**: The tropical JSR ρ_trop(𝒜) = lim_{k→∞} max_{products P of length k} (⊕_{ij} P_{ij})^{1/k} equals the tropical eigenvalue of the tropical convex hull of 𝒜.
- **Proof Strategy**:
  1. Define tropical semiring (ℝ ∪ {-∞}, max, +) and tropical matrices
  2. Prove tropical Perron-Frobenius: irreducible tropical matrices have a unique tropical eigenvalue
  3. Show tropical JSR equals this eigenvalue via tropical spectral theory
  4. Key lemma: `tropical_perron_frobenius`, `tropical_jsr_equals_eigenvalue`
- **Why This Is Revolutionary**: Connects tropical geometry to certified robustness, enabling combinatorial algorithms for JSR computation that are faster than SDP-based approaches.
- **Catalog Leverage**: Build on existing tropical semiring definitions in catalog, `jsr_exponential_decay_identity`
- **Research Mode**: prove
- **Estimated Depth**: 4/5

### 5. Quantum Channel JSR for Quantum Neural Networks

- **Theorem Statement**: For a set of quantum channels {Φ₁, ..., Φₘ} (completely positive trace-preserving maps), the quantum JSR ρ_Q(Φ) = lim_{k→∞} max_{compositions of length k} ‖Φ_{i₁} ∘ ... ∘ Φ_{iₖ}‖_{♢}^{1/k} exists and satisfies the quantum Barabanov theorem.
- **Proof Strategy**:
  1. Extend weight system theory to completely positive maps
  2. Use Choi-Jamiołkowski isomorphism to reduce to matrix JSR
  3. Apply Barabanov construction in the diamond norm
  4. Key lemma: `quantum_submultiplicativity`, `choi_jsr_reduction`
- **Why This Is Revolutionary**: Opens the field of certified quantum neural network analysis, combining quantum information theory with operator-algebraic deep learning.
- **Catalog Leverage**: Build on `spectral_radius_trivial_bound`, `residual_lipschitz_bound`
- **Research Mode**: discover
- **Estimated Depth**: 5/5