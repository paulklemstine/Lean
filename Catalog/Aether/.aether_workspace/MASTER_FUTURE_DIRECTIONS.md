# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-08 17:30*

## Breakthrough Opportunities (ranked by impact)

### 1. Toric Code as a Chain Complex — Full Formalization

**Theorem Statement**: For the torus T² with standard CW-decomposition on an L×L grid, the chain complex C₀(T²) → C₁(T²) → C₂(T²) over F₂ defines a CSS code with parameters [[2L², 2, L]].

**Proof Strategy**:
- Define the torus as Fin L × Fin L with periodic identification
- Construct the boundary maps explicitly using edge/face incidence
- Verify ∂²=0 using `native_decide` for small L, then prove generally by showing each face contributes an even number of edges to any vertex boundary
- Compute H₁(T², F₂) ≅ F₂² to get 2 logical qubits
- Show minimum non-trivial homology support has size L

**Why Revolutionary**: This would be the first fully formalized construction of the toric code in a proof assistant, connecting topological quantum memory to verified mathematics.

**Catalog Leverage**: Builds directly on `F2ChainComplex.toCSSCode`, `cohomological_distance_cert`

**Research Mode**: prove

**Estimated Depth**: 3

### 2. Surface Code Distance Bounds with Genus

**Theorem Statement**: For a closed orientable surface Σ_g of genus g with a cellulation having n₂ faces, n₁ edges, n₀ vertices, the Čech stabilizer code has distance d ≥ √(n₁/g) when the cellulation is sufficiently regular.

**Proof Strategy**:
- Use the Euler characteristic χ = n₀ - n₁ + n₂ = 2 - 2g
- Apply systolic geometry: the systole of Σ_g satisfies sys(Σ_g) ≥ c·√(area/g) by the Gromov-Buser-Sarnak bound
- Translate systole to minimum homology support in the chain complex
- The key lemma: minimum weight of a non-trivial Z₁-cocycle ≥ systole / max(edge length)

**Why Revolutionary**: Would establish the first formalized connection between Riemannian geometry (systoles) and quantum code distance, opening systolic geometry as a tool for quantum code design.

**Catalog Leverage**: `cohomological_distance_cert`, `cech_dim_bound`

**Research Mode**: prove

**Estimated Depth**: 4

### 3. Quantum LDPC Codes from Expander Chain Complexes

**Theorem Statement**: For a (c,d)-bipartite expander graph G with second eigenvalue λ < d/2, the associated Sipser-Spielman chain complex yields a CSS code with parameters [[n, Ω(n), Ω(√n)]].

**Proof Strategy**:
- Construct the chain complex from the Tanner code of the expander graph
- Use expansion to prove distance: any low-weight vector in ker(∂₂)\im(∂₁) has support touching a fraction of vertices, contradicting expansion
- The key ingredient is the expander mixing lemma applied to the Čech cochains
- Dimension follows from rank-nullity + expansion bound on rank(∂₁)

**Why Revolutionary**: Quantum LDPC codes with linear dimension and polynomial distance are the holy grail of quantum error correction. This would formalize the core argument.

**Catalog Leverage**: `F2ChainComplex`, `xDistanceLB`, `logical_qubit_bound`

**Research Mode**: prove

**Estimated Depth**: 5

### 4. Functorial Decoder Construction

**Theorem Statement**: Given a chain map φ: C → C' between chain complexes with known decoders for C', one can construct a decoder for C with correction radius ≥ t(C') / ‖φ‖, where ‖φ‖ is the operator norm of φ.f1.

**Proof Strategy**:
- Define the "pullback decoder" D_C(e) = φ.f1⁻¹(D_C'(φ.f1 *ᵥ e))
- Use `chain_morphism_preserves_x_logical` to show logical operators map correctly
- Bound the correction radius using the weight-preserving properties of φ
- The norm ‖φ‖ controls the weight expansion, giving the radius bound

**Why Revolutionary**: Establishes decoder transfer as a functorial operation, meaning new decoders can be constructed by composing morphisms — a categorical approach to quantum decoding.

**Catalog Leverage**: `F2ChainMorphism.comp`, `chain_morphism_preserves_x_logical`

**Research Mode**: prove

**Estimated Depth**: 3

### 5. Tropical Čech Codes

**Theorem Statement**: The tropical deformation of a Čech stabilizer code (replacing F₂ with the tropical semiring) gives a lattice code whose shortest vector problem is at least as hard as decoding the original quantum code.

**Proof Strategy**:
- Define the "tropical chain complex" by replacing addition with min and multiplication with addition
- Show the tropical boundary condition min-plus ∂² = ∞ is analogous to ∂² = 0
- Construct a reduction from syndrome decoding to shortest vector via the tropical isomorphism
- Use the catalog's tropical geometry infrastructure for the tropical semiring formalization

**Why Revolutionary**: Connects quantum error correction to lattice-based cryptography and tropical geometry, opening a three-way bridge between topology, quantum info, and post-quantum security.

**Catalog Leverage**: `maslov_tropical_error_bound`, tropical semiring definitions

**Research Mode**: discover

**Estimated Depth**: 4