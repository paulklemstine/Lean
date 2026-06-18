# Future Directions: Geometric Complexity Theory Formalization

## Breakthrough Opportunities (ranked by impact)

### 1. Explicit Occurrence Obstructions for Perm_n vs Det_{n²}

**Theorem Statement**: For each n ≥ 2, there exists a partition λ such that the irreducible GL-representation V_λ occurs in the coordinate ring of the orbit closure of perm_n but not in that of det_{n²}.

**Proof Strategy**:
- Approach A: Use the Kronecker coefficient computation to find specific partitions where multiplicities differ. Compute Kronecker coefficients for small n using the Murnaghan-Nakayama rule.
- Approach B: Use plethysm computations — the coordinate ring of det's orbit closure involves plethystic substitutions, and specific representation-theoretic identities give vanishing results.
- Approach C: Leverage recent results of Bürgisser-Ikenmeyer on rectangular Kronecker coefficients.

**Why This Is Revolutionary**: Would resolve the permanent vs. determinant conjecture for specific sizes, providing concrete evidence for VP ≠ VNP. Even partial results (e.g., for n = 3, 4) would be significant.

**Catalog Leverage**: Build on `GCT.gct_main` (Theorem 25) and `GCT.perm_lower_bound` (Theorem 26).

**Research Mode**: discover
**Estimated Depth**: 5 (requires substantial representation theory infrastructure)

---

### 2. Bridge GCT to Quantum Circuit Depth (BQP vs P)

**Theorem Statement**: If a polynomial family f has orbit closure dimension d, then f can be computed by a quantum circuit of depth O(log d), and conversely, quantum circuits of depth T compute polynomials with orbit dimension ≤ 2^{O(T)}.

**Proof Strategy**:
- Define quantum circuit families as polynomial families with specific algebraic structure.
- Show that the unitary group action on quantum states is compatible with the GL-action on polynomial spaces.
- Use Schur-Weyl duality to translate between GL-representations and symmetric group representations relevant to quantum state spaces.

**Why This Is Revolutionary**: Would connect GCT to quantum computational complexity, potentially showing that representation-theoretic obstructions also yield quantum circuit depth lower bounds.

**Catalog Leverage**: Build on `GCT.circuit_from_dim` (Theorem 9) and the tensor amplification theorems (17-20).

**Research Mode**: formalize
**Estimated Depth**: 4

---

### 3. Certified Robustness Calculus via Orbit Closure Theory

**Theorem Statement**: For a neural network with polynomial activation functions of degree d, the decision boundary is contained in the orbit closure of a polynomial of degree d·L (where L is the depth). The Lipschitz constant of the decision boundary is bounded by the orbit dimension.

**Proof Strategy**:
- Model neural networks with polynomial activations as orbit closure containment problems.
- Show that composition of polynomial maps corresponds to orbit closure chain operations.
- Use the separation certificate framework (Theorems 21-24) to define certified robustness.

**Why This Is Revolutionary**: Would provide algebraic certificates of neural network robustness, complementing existing Lipschitz-based approaches.

**Catalog Leverage**: Build on `GCT.SeparationCert`, `GCT.certified_noncontain` (Theorem 21), `GCT.cert_circuit_bound` (Theorem 23).

**Research Mode**: formalize
**Estimated Depth**: 3

---

### 4. SVP-Hard Lattice Problems Require High-Complexity GL-Representations

**Theorem Statement**: The polynomial family encoding the shortest vector problem (SVP) on n-dimensional lattices has representation-theoretic complexity ≥ 2^{Ω(n)}: any irreducible GL-representation occurring in its coordinate ring must be indexed by a partition of size ≥ 2^{cn} for some constant c > 0.

**Proof Strategy**:
- Encode SVP as a polynomial optimization problem via the theta function.
- Show that the theta function's orbit closure has high representation-theoretic complexity by analyzing its GL-module decomposition.
- Use counting arguments on the number of lattice vectors of bounded norm.

**Why This Is Revolutionary**: Would provide representation-theoretic evidence for the hardness of SVP, strengthening the foundation of post-quantum lattice cryptography.

**Catalog Leverage**: Build on `GCT.LatticeInstance`, `GCT.post_quantum_security` (Theorem 33), `GCT.lattice_scaling` (Theorem 34).

**Research Mode**: formalize
**Estimated Depth**: 4

---

### 5. Algebraic Natural Proofs and Statistical Zero-Knowledge

**Theorem Statement**: If an algebraic separator for VP vs VNP can be computed in polynomial time, then it yields a statistical zero-knowledge proof that a given polynomial is VNP-hard.

**Proof Strategy**:
- Show that evaluation of algebraic separators can be simulated by a prover/verifier protocol.
- Use the representation-theoretic structure to build the simulator (Schur's lemma gives the required equivariance).
- Apply the barrier theorem to show the simulator must have exponential complexity.

**Why This Is Revolutionary**: Would connect GCT to interactive proof systems, bridging algebraic complexity and computational complexity through zero-knowledge protocols.

**Catalog Leverage**: Build on `GCT.AlgSeparator`, `GCT.algebraic_natural_proofs_barrier` (Theorem 11), `GCT.barrier_dichotomy` (Theorem 16).

**Research Mode**: formalize
**Estimated Depth**: 4

---

## Under-explored Territory

### Representation-Theoretic Infrastructure
The formalization currently axiomatizes representation multiplicities abstractly. Building concrete infrastructure — Young tableaux, Schur functors, plethysm — in Lean 4 would enable:
- Computation of specific obstruction witnesses
- Verification of representation-theoretic identities
- Connection to existing Mathlib representation theory

### Concrete GCT for Small Cases
The `Fingerprint` model provides a concrete computational framework. Extending it with:
- Actual multiplicity computations for det_n and perm_m for small n, m
- Verification of known obstruction results (Bürgisser-Ikenmeyer)
- Algorithmic obstruction search

### Orbit Closure Geometry
The current formalization treats orbit closures abstractly. Connecting to Mathlib's algebraic geometry (schemes, varieties, coordinate rings) would:
- Ground the axioms in concrete algebraic geometry
- Enable geometric arguments about orbit closure structure
- Connect to the theory of algebraic groups

## Cross-Domain Bridges

### GCT ↔ Tropical Geometry
Tropicalization of orbit closures may yield combinatorial obstructions that are easier to compute than representation-theoretic ones. The tropical permanent and tropical determinant have been studied, and their Newton polytopes provide geometric data relevant to GCT.

### GCT ↔ Category Theory
Orbit closure containment forms a preorder (category with at most one morphism between objects). The representation multiplicity function is a functor from this category to the poset of natural numbers. This functorial perspective may yield new structural results.

### GCT ↔ Information Theory
The representation-theoretic complexity of a polynomial can be viewed as an entropy measure — the "information content" of the polynomial's algebraic structure. High entropy = high complexity, connecting GCT to thermodynamic arguments.

## Open Problems Encountered

1. **Completeness of the Obstruction Method**: Is the converse of Theorem 1 true? Does non-containment always imply the existence of a representation-theoretic obstruction? This is the GCT completeness conjecture.

2. **Quantitative Barrier Bounds**: What is the precise exponent in the algebraic natural proofs barrier? Our Theorem 11 gives a lower bound of 2^{cn} but the optimal c is unknown.

3. **Tensor Amplification Limits**: Can tensor amplification be iterated to boost any positive gap to an exponential gap? Our Theorem 17 gives quadratic amplification, but iterated squaring might not converge.

4. **Decidability of Obstruction Existence**: Is there an algorithm that, given descriptions of two polynomial families, decides whether an obstruction exists? This connects to computability questions about representation theory.

5. **Connection to Algebraic Natural Proofs for Specific Problems**: Can the barrier theorem be applied to specific algebraic proof techniques (e.g., shifted partial derivatives, evaluation dimension) to show they cannot resolve VP vs VNP?
