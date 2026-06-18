# Future Directions: Symplectic Cryptography Research Roadmap

## Breakthrough Opportunities (ranked by impact)

### 1. Symplectic Group Order Formula
- **Theorem Statement**: For prime q and positive n, `|Sp(2n, F_q)| = q^{n²} · ∏_{k=1}^{n} (q^{2k} - 1)`
- **Proof Strategy**:
  1. Induction on n: count symplectic bases by choosing e₁ (q^{2n}-1 options), then f₁ with ω(e₁,f₁)=1, then recurse on the symplectic complement
  2. Alternative: use the Bruhat decomposition of Sp(2n, F_q) to factor the order
  3. Key lemma: the symplectic complement of a symplectic pair has dimension 2(n-1)
- **Why This Is Revolutionary**: Exact group order is needed for tight security bounds, birthday-bound analysis, and parameter selection. This single formula determines the key space size for all symplectic cryptographic constructions.
- **Catalog Leverage**: Build on `symplectic_pow_cond`, `symplectic_det_identity`
- **Research Mode**: prove
- **Estimated Depth**: 4 (requires significant Mathlib linear algebra infrastructure)

### 2. Reciprocal Eigenvalue Theorem (General Case)
- **Theorem Statement**: For M ∈ Sp(2n, F_q) with eigenvalue λ over the algebraic closure, λ⁻¹ is also an eigenvalue with equal multiplicity.
- **Proof Strategy**:
  1. Show the characteristic polynomial χ_M(t) satisfies t^{2n} · χ_M(t⁻¹) = χ_M(t) (palindromic)
  2. Derive from M^T J M = J → det(tI - M) has palindromic coefficients
  3. Key lemma: M and (J M⁻¹ J⁻¹)^T have the same characteristic polynomial
- **Why This Is Revolutionary**: This is THE structural property providing quantum resistance. A full formal proof would be the first machine-verified statement about why symplectic DLP resists Shor's algorithm.
- **Catalog Leverage**: `symplectic_2x2_charpoly_palindromic`, `symplectic_det_identity`
- **Research Mode**: prove
- **Estimated Depth**: 3

### 3. Symplectic Diffie-Hellman Protocol
- **Theorem Statement**: Define the symplectic DDH assumption and prove IND-CPA security of the resulting key exchange protocol.
- **Proof Strategy**:
  1. Define SymplecticDDH: (M, M^a, M^b, M^{ab}) is indistinguishable from (M, M^a, M^b, M^c)
  2. Construct key exchange: Alice sends M^a, Bob sends M^b, shared key = M^{ab}
  3. Prove IND-CPA security via reduction to DDH
- **Why This Is Revolutionary**: First formally verified post-quantum key exchange based on symplectic geometry, bridging classical Diffie-Hellman to post-quantum security.
- **Catalog Leverage**: `symplecticOneWayFn`, `symplecticOWF_homomorphic`, `zk_verification_eq`
- **Research Mode**: formalize
- **Estimated Depth**: 3

### 4. Symplectic Hash Collision Resistance (Full Proof)
- **Theorem Statement**: Any algorithm finding collisions in h(M) = ω(Me₁, Me₂) requires Ω(√q) queries (birthday bound is tight).
- **Proof Strategy**:
  1. Prove the hash is regular: each fiber has exactly |Sp(2n,F_q)|/q elements
  2. Use the orbit-stabilizer theorem for the Sp action on pairs of vectors
  3. Apply the birthday bound to get Ω(√q) query complexity
- **Why This Is Revolutionary**: Would establish the first formally verified collision resistance bound for a group-theoretic hash function.
- **Catalog Leverage**: `birthday_bound_meaningful`, `birthday_bound_monotone`
- **Research Mode**: prove
- **Estimated Depth**: 4

### 5. Perfect Zero-Knowledge via Liouville
- **Theorem Statement**: The Liouville ZK protocol achieves perfect zero-knowledge: the simulator's transcript distribution equals the real transcript distribution.
- **Proof Strategy**:
  1. Define the transcript distribution formally using Finset-valued random variables
  2. Show the simulator's commitment C_sim = M^s · N^{-b} is uniformly distributed over Sp by Liouville
  3. Prove distributional equality using `liouville_finite_volume`
- **Why This Is Revolutionary**: First formal proof that a physical principle (Liouville's theorem) implies a cryptographic property (perfect zero-knowledge).
- **Catalog Leverage**: `liouville_finite_volume`, `liouville_det_one`, `zk_completeness`
- **Research Mode**: prove
- **Estimated Depth**: 5

### 6. Lattice-Symplectic Hybrid Hash
- **Theorem Statement**: Define h(M) = ω(Me₁, Me₂) mod Λ for a lattice Λ ⊂ Z^{2n}, achieving both symplectic and lattice hardness.
- **Proof Strategy**:
  1. Define symplectic matrices over Z: Sp(2n, Z)
  2. Reduce modulo a lattice to get finite output
  3. Prove collision resistance reduces to both symplectic DLP and shortest vector problem
- **Why This Is Revolutionary**: Combines two post-quantum hardness assumptions (symplectic DLP + SVP) for defense-in-depth security.
- **Catalog Leverage**: `hash_form_invariance`, `hash_of_product`
- **Research Mode**: formalize
- **Estimated Depth**: 4

## Under-explored Territory

### Symplectic Coding Theory
Many definitions exist for symplectic bases and forms, but the connection to error-correcting codes is largely unexplored in formal mathematics. Symplectic self-dual codes (codes C = C^⊥_ω where ⊥_ω is the symplectic dual) have deep connections to quantum error correction.

### Categorical Symplectic Geometry
The category of symplectic vector spaces and symplectic maps has rich structure (it's a dagger category). Formalizing this could connect to the categorical Shannon theory already in the catalog.

### Computational Aspects
While we prove existence of repeated squaring, explicit algorithms for:
- Computing the symplectic characteristic polynomial
- Finding eigenvalues in F_{q²}
- Extracting discrete logarithms from eigenvalue information

are all missing and would make the security analysis concrete.

## Cross-Domain Bridges

### Symplectic ↔ Tropical Geometry
The tropicalization of the symplectic form ω(x,y) = max_i(x_{2i} + y_{2i+1}, x_{2i+1} + y_{2i}) could define tropical symplectic matrices, connecting to the existing tropical algebra in the catalog.

### Symplectic ↔ Machine Learning
Hamiltonian neural networks (HNNs) preserve symplectic structure by construction. The Liouville volume preservation theorem could provide formal guarantees on the expressiveness of HNN layers — connecting our formalization to certified robustness results.

### Symplectic ↔ Quantum Computing
Clifford gates in quantum computing correspond to elements of the symplectic group Sp(2n, F_2). Our formalization over general CommRing specializes to give formal properties of Clifford circuits, connecting to quantum error correction.

## Open Problems Encountered

1. **J² = -I formal proof**: We attempted to prove that the standard symplectic matrix squares to -I but the componentwise matrix computation was difficult to automate. This should be achievable with better Fin arithmetic.

2. **det(J) computation**: Computing det(J) = 1 (or (-1)^n) for the standard symplectic matrix J would allow strengthening `symplectic_det_identity` to `det(M)² = 1`.

3. **Symplectic group as a Lean Group instance**: Making SymplecticMat into a formal Group instance (with inverse) requires showing symplectic matrices are invertible, which needs det(M)² = 1 ≠ 0.

4. **Finiteness of Sp(2n, F_q)**: While obvious, proving `Fintype (SymplecticMat n (ZMod q))` requires showing it's a decidable subset of a finite type.

5. **Security reduction formalization**: The reduction from symplectic DLP to F_{q²}* DLP requires substantial algebraic number theory infrastructure (field extensions, embeddings, root-finding in finite fields).
