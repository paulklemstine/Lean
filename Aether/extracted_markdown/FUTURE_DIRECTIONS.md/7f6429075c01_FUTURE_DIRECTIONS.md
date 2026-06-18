# Future Directions: Tropical Cryptography Research Roadmap

## Breakthrough Opportunities (ranked by impact)

### 1. Tropical NTRU Encryption

- **Theorem Statement**: There exists a tropical analogue of the NTRU encryption scheme that is IND-CPA secure under the tropical discrete log hardness assumption. Specifically: for dimension d and key space size 2^d, the advantage of any PPT adversary in distinguishing encryptions is negligible in d.
- **Proof Strategy**:
  - A: Define tropical polynomial ring R = (ℝ[x]/(x^d - 1), min, +) and construct key generation, encryption, decryption.
  - B: Reduce CPA security to the tropical shortest vector problem.
  - C: Use the structural obstruction (no cyclic group) to show quantum adversaries gain no advantage over classical ones.
- **Why This Is Revolutionary**: Combines NTRU's efficiency (O(d log d) operations) with structural quantum resistance, rather than relying on hardness assumptions alone.
- **Catalog Leverage**: `minplus_mul_assoc`, `tropical_owf_quantum_resistance`, `tropical_information_loss`
- **Research Mode**: formalize
- **Estimated Depth**: 4

### 2. Certified Adversarial Robustness via Tropical Networks

- **Theorem Statement**: ∀ ε > 0, ∀ tropical neural network f with L layers and maximum weight W, the certified ℓ∞ robustness radius of f at any input x is at least margin(f, x) / (W^L), where margin(f, x) is the classification margin.
- **Proof Strategy**:
  - A: Compose the 1-Lipschitz bound for tropical linear maps (our `minplusvec_nonexpansive`) across L layers.
  - B: Account for the tropical ReLU activation (which is just another min operation, hence 1-Lipschitz).
  - C: Use the CertifiedTropicalRobustness structure to package the bound.
- **Why This Is Revolutionary**: Gives the first Lipschitz certification for tropical neural networks that is tight (not an overestimate). Current certified robustness methods for standard networks are extremely loose.
- **Catalog Leverage**: `minplusvec_nonexpansive`, `min_lipschitz`, `CertifiedTropicalRobustness`
- **Research Mode**: prove
- **Estimated Depth**: 3

### 3. Tropical Matrix Power Distinctness

- **Theorem Statement**: For a generic d×d matrix A (with algebraically independent entries), the tropical powers A^⊗1, A^⊗2, ..., A^⊗n are pairwise distinct for all n ≤ 2^d.
- **Proof Strategy**:
  - A: Show that the diagonal entries of A^⊗n are strictly decreasing in n (they represent shortest cycles of length n).
  - B: Use the algebraic independence of entries to avoid degenerate cancellations.
  - C: Alternatively, encode binary subsets via tropical products (our `exponential_subset_count`) and show injectivity.
- **Why This Is Revolutionary**: Establishes that the tropical one-way function is injective on its domain, a necessary condition for a cryptographic function to be meaningful.
- **Catalog Leverage**: `minplus_mul_assoc`, `minplus_entry_le_path`, `exponential_subset_count`
- **Research Mode**: prove
- **Estimated Depth**: 4

### 4. Tropical Eigenvalue ↔ Lattice SVP Reduction

- **Theorem Statement**: Computing the tropical eigenvalue of a d×d matrix is at least as hard as approximating the shortest vector in a d-dimensional lattice to within polynomial factors.
- **Proof Strategy**:
  - A: Embed lattice basis vectors as rows of a tropical matrix.
  - B: Show that the tropical eigenvalue (minimum cycle mean) encodes the shortest vector length.
  - C: Prove that any efficient tropical eigenvalue algorithm yields an efficient SVP approximation algorithm.
- **Why This Is Revolutionary**: Creates a two-way bridge between tropical cryptography and lattice-based cryptography, allowing tropical systems to inherit decades of confidence in lattice hardness.
- **Catalog Leverage**: `MinPlusMul`, `minplus_preserves_finite`, `tropical_security_bits`
- **Research Mode**: discover
- **Estimated Depth**: 5

### 5. Quantum Query Lower Bounds for Tropical Problems

- **Theorem Statement**: Any quantum algorithm solving the tropical matrix inversion problem (recovering A from A^⊗n · v for random v) requires Ω(2^{d/2}) quantum queries.
- **Proof Strategy**:
  - A: Adapt the polynomial method to show that any quantum algorithm must make many queries to distinguish tropical products.
  - B: Use the non-injectivity of min (our `min_not_injective`) to bound the information gained per query.
  - C: Apply the adversary bound method from quantum complexity theory.
- **Why This Is Revolutionary**: Gives the first *proven* quantum lower bound for a tropical problem, rather than relying on structural arguments.
- **Catalog Leverage**: `min_not_injective`, `tropical_information_loss`, `fundamental_tropical_asymmetry`
- **Research Mode**: discover
- **Estimated Depth**: 5

## Under-explored Territory

### Tropical Algebraic Geometry for Crypto
The tropical analogue of algebraic curves (tropical curves) has rich combinatorial structure. Tropical Jacobians and divisor theory could yield new cryptographic primitives based on the tropical analogue of the elliptic curve discrete log problem. The existing `TropicalLanglandsVarieties.lean` and `CompactTropicalChoquetRadon.lean` provide starting infrastructure.

### Idempotent Analysis and Max-Plus Neural Networks
The 1-Lipschitz property of tropical maps is just the beginning. Idempotent analysis (the max-plus analogue of functional analysis) provides tools for studying tropical eigenspaces, spectral theory, and Perron-Frobenius theory — all potentially relevant to neural network architecture design.

### Tropical Homological Algebra
Tropical modules over tropical semirings have a homological theory that is poorly understood. Free resolutions in the tropical setting could provide complexity-theoretic lower bounds via algebraic arguments.

## Cross-Domain Bridges

### Tropical → Lattice Cryptography
- The shortest vector problem in a lattice can be encoded as a tropical optimization problem.
- Our `MinPlusMul` definition computes shortest paths, which are dual to shortest vectors.
- **Conjectured correspondence**: Tropical matrix rank ↔ lattice rank, tropical eigenvalue ↔ lattice minimum.

### Tropical → Certified ML
- The `minplusvec_nonexpansive` theorem provides a bridge from tropical algebra to verified robustness.
- Composing tropical layers gives provable Lipschitz bounds for deep networks.
- **Conjectured**: Tropical networks achieve the optimal Lipschitz constant among all networks with the same architecture.

### Tropical → Quantum Information
- The `PostQuantumObstruction` typeclass captures the algebraic reason for quantum resistance.
- Any semiring where addition is idempotent automatically satisfies this typeclass.
- **Conjectured**: The class of PostQuantumObstruction algebras is precisely the class of algebras where no quantum speedup is possible for the discrete log problem.

### Berggren Semigroup → Tropical Encoding
- The Berggren semigroup (from `BerggrenAntiRigidity.lean`) embeds into GL₂(ℤ).
- Tropical encoding of Berggren words could combine the free-monoid injectivity of Berggren with the quantum resistance of tropical algebra.
- **Specific connection**: The anti-involution rigidity theorem (`adjugate2_not_in_BergSemigroup`) could have a tropical analogue where the "tropical adjugate" operation is also rigid.

## Open Problems Encountered

1. **Tropical matrix power injectivity**: We proved associativity of min-plus multiplication but could not prove that distinct exponents always give distinct powers for generic matrices. This requires algebraic independence arguments that go beyond current Mathlib infrastructure.

2. **Tight Grover bound**: We established d² ≤ 2^d but the actual quantum speedup for tropical problems is unclear. Is it √(2^d) (Grover) or something intermediate?

3. **Min-plus matrix group**: Does the set of d×d min-plus matrices with finite entries and a "tropical determinant" ≠ ∞ form a group? If so, this would be the natural setting for tropical Diffie-Hellman, but invertibility in the tropical setting is subtle.

4. **Tropical PKE**: Can we build a complete public-key encryption scheme (not just a one-way function) from tropical operations? The non-injectivity of min creates challenges for decryption correctness.

5. **Connection to mean payoff games**: Tropical eigenvalues correspond to optimal strategies in mean payoff games. Can game-theoretic hardness results be leveraged for cryptographic security proofs?
