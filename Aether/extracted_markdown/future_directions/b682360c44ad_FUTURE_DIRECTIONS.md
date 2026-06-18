# Future Directions: Extending the Verified Toric Code

## Breakthrough Opportunities (ranked by impact)

### 1. Surface Codes on Higher-Genus Surfaces

- **Theorem Statement**: For genus-g surface Σ_g with L×L grid, the CSS code parameters are [[2L², 2g, L]], encoding 2g logical qubits.
- **Proof Strategy**:
  1. Generalize the CW-decomposition to surfaces with g handles
  2. Prove β₁(Σ_g) = 2g using the Euler characteristic χ = 2 - 2g
  3. Show the minimum homological weight remains L (independent of genus for standard CW-structures)
- **Why This Is Revolutionary**: Enables verified multi-logical-qubit topological memories. Higher-genus codes are proposed for fault-tolerant quantum computers requiring many logical qubits.
- **Catalog Leverage**: Build directly on `ToricCode.boundary_sq_zero`, `ToricCode.euler_characteristic`, `ToricCode.verified_construction`
- **Research Mode**: prove
- **Estimated Depth**: 4

### 2. Spectral Gap of the Toric Code Hamiltonian

- **Theorem Statement**: The toric code Hamiltonian H = -Σ_v A_v - Σ_f B_f has spectral gap Δ ≥ 2, and the ground space degeneracy is exactly 4.
- **Proof Strategy**:
  1. Define the Hamiltonian as a sum of commuting projectors
  2. Prove frustration-freeness: ground states simultaneously minimize all terms
  3. Use the commuting projector structure to bound the gap from below
- **Why This Is Revolutionary**: The spectral gap is the key parameter for topological protection at finite temperature. A verified gap bound would enable certified thermal stability estimates.
- **Catalog Leverage**: `ToricCode.ground_space_dim`, `ToricCode.boundary_sq_zero`
- **Research Mode**: prove
- **Estimated Depth**: 5

### 3. Verified Minimum-Weight Perfect Matching Decoder

- **Theorem Statement**: ∀ error patterns e with wt(e) < L/2, the MWPM decoder on the toric code syndrome correctly identifies e in O(L² log L) time.
- **Proof Strategy**:
  1. Formalize the syndrome graph and matching algorithm
  2. Prove correctness: below the decoding radius, the minimum-weight matching uniquely recovers the error
  3. Bound the complexity using weighted bipartite matching
- **Why This Is Revolutionary**: Connects formal verification to practical quantum computing. Google, IBM, and other quantum hardware vendors use MWPM decoders; a verified implementation would be immediately applicable.
- **Catalog Leverage**: `ToricCode.correctable_weight_bound`, `ToricCode.horizontal_cycle_weight`
- **Research Mode**: prove
- **Estimated Depth**: 5

### 4. Quantum LDPC Codes via Homological Products

- **Theorem Statement**: The homological product of two classical LDPC codes C₁, C₂ yields a quantum LDPC code with parameters [[n₁·n₂, k₁·k₂, min(d₁,d₂)]] and stabilizer weight ≤ w₁ + w₂.
- **Proof Strategy**:
  1. Define the tensor product of chain complexes
  2. Apply the Künneth formula to compute homology
  3. Bound the distance using product structure
- **Why This Is Revolutionary**: Good quantum LDPC codes (e.g., Panteleev-Kalachev) achieve constant rate AND growing distance. Verifying the product construction opens the path to verified good qLDPC codes.
- **Catalog Leverage**: `ToricCode.CSSParams`, `ToricCode.boundary_sq_zero`
- **Research Mode**: prove
- **Estimated Depth**: 4

### 5. Collision-Resistant Hash from Homology

- **Theorem Statement**: The syndrome map σ: F₂^n → F₂^(n-k) of the toric code is a homomorphic hash function with collision resistance parameter ≥ L (minimum weight of a collision = minimum weight of a codeword).
- **Proof Strategy**:
  1. Define the hash function as the syndrome map
  2. Prove homomorphism: σ(x + y) = σ(x) + σ(y) over F₂
  3. Prove collision resistance: any collision has weight ≥ L by the code distance
- **Why This Is Revolutionary**: Provides a post-quantum hash construction with security directly tied to the verified code distance. The lattice structure of F₂^n makes this analogous to lattice-based crypto.
- **Catalog Leverage**: `ToricCode.toricParams_d`, `ToricCode.quantum_singleton_bound`
- **Research Mode**: prove
- **Estimated Depth**: 3

## Under-explored Territory

### Topological Order Beyond 2D
- The BKT bound d = O(√n) limits 2D codes. Higher-dimensional hyperbolic codes and expander-based codes bypass this. Formalizing the BKT bound itself (not just verifying the toric code satisfies it) would be foundational.

### Anyonic Statistics from Chain Complexes
- The toric code supports abelian anyon excitations (e-particles and m-particles). Formalizing the braiding statistics as a representation of the braid group would connect our chain complex construction to topological quantum computation.

### Fault-Tolerant Gates
- Transversal gates on surface codes are limited by the Eastin-Knill theorem. Formalizing which gates are transversal for the toric code (only Pauli and CNOT) and connecting to magic state distillation would bridge coding theory and quantum circuit complexity.

## Cross-Domain Bridges

### Algebraic Topology ↔ Machine Learning
- Neural network decoders for the toric code learn functions F₂^s → F₂^n. The homological structure constrains the target function space, potentially enabling Lipschitz bounds on the decoder that certify robustness against adversarial noise.

### Quantum Error Correction ↔ Statistical Mechanics
- The toric code threshold maps to a phase transition in the random-bond Ising model on the Nishimori line. Formalizing this correspondence would connect verified coding bounds to verified critical exponents.

### Homological Algebra ↔ Cryptography
- Syndrome decoding on LDPC codes is a key problem in code-based cryptography (McEliece, BIKE). The toric code provides a structured instance where the problem's hardness is controlled by a single topological invariant (the code distance L).

## Open Problems Encountered

### 1. Full Homology Computation
- Computing dim H₁(T²; F₂) = 2 requires rank computation of the boundary matrices over F₂. This needs either:
  - A Mathlib-compatible rank computation for matrices over finite fields
  - A combinatorial argument via the winding number isomorphism H₁ ≅ F₂²
- Currently stated as a parameter (k = 2) rather than derived from the chain complex.

### 2. Distance Lower Bound from Winding Numbers
- The minimum weight of a non-trivial homology class is L (not just that the winding cycles achieve weight L). Proving the lower bound requires showing that any cycle with winding number ≥ 1 must use at least L edges. This needs a formal theory of winding numbers as homomorphisms H₁(T²; F₂) → F₂.

### 3. Explicit Incidence Matrix Formulation
- An alternative approach defines the boundary maps via explicit matrices over ZMod 2 and proves ∂² = 0 by matrix multiplication. This would connect to the matrix-based formulation used in engineering implementations.

### 4. Thermal Stability
- Proving that the logical error rate decreases as exp(-cL) at temperature T < T_c requires formalizing the Peierls argument for the random-bond Ising model. No Lean formalization of Peierls-type arguments currently exists.
