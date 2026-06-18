# Future Research Directions

## Synthesis

This research cycle established the mathematical foundations of nonlinear tropical hash functions (NTSHA), proving that shift equivariance is the precise structural weakness of linear tropical hashes and that modular reduction breaks this symmetry. The tropical Merkle-Damgård construction was formalized with its distinctive monotonic descent property, and exact counting formulas for mining probability were derived from order statistics.

The most promising cross-domain connection is between **tropical hash security and tropical optimization**. The NTSHA hash h(m,k,p) = min_i((m_i + k_i) mod p) is a nonlinear tropical form whose preimage analysis connects to modular tropical linear programming. The modular reduction introduces a periodic structure that interacts with tropical convexity in ways that could yield either polynomial-time mining algorithms (for structured instances) or provable hardness results (for random instances). This connects to the Catalog's existing tropical algebra work in `Catalog/Tropical/Algebra.lean` and cryptographic primitives in `Catalog/Cryptography/TropicalOneWayFoundations.lean`.

The collision shift invariance theorem reveals that linear tropical hash collisions form tropical affine subspaces. The key open question is whether NTSHA collisions have similar geometric structure or whether modular reduction genuinely randomizes them. If the latter, NTSHA may achieve provable collision resistance — a property that remains unproven for any widely-used hash function.

---

### Direction 1: Tropical Hash Preimage Complexity from Modular Tropical LP

**Conjecture**: For the NTSHA hash with prime modulus p and dimension k ≥ 2, any algorithm that finds a preimage m given NTSHA(m, k_fixed, p) = t requires Ω(p^{1/2}) operations in the worst case. Equivalently, the modular tropical feasibility problem "find x with min_i((x_i + c_i) mod p) ≤ t" has no polynomial-time algorithm when t = 0.

**Test**: Implement a modular tropical preimage solver using (1) brute force, (2) lattice reduction on the modular structure, and (3) tropical simplex. Measure scaling with p for k = 2, 3, 4. If any method scales polynomially, the conjecture is false.

**Impact**: If true, this would be the first provable lower bound for a tropical hash function, establishing tropical cryptography on firm complexity-theoretic ground. If false, the polynomial algorithm would itself be a significant contribution to tropical optimization.

**Catalog References**: `Catalog/Cryptography/TropicalOneWayFoundations.lean`, `Catalog/Cryptography/TropicalNPHardness.lean`

**Proof Strategy**: Model the preimage problem as a system of modular tropical inequalities. Reduce from a known hard problem (e.g., subset sum or shortest vector problem) to modular tropical feasibility. The modular reduction creates a connection to lattice problems that may enable the reduction.

**Domain Bridges**: Tropical Geometry <-> Computational Complexity <-> Lattice Cryptography

**Lineage**: Builds on the shift equivariance breaking theorem (mod_breaks_shift_structure) and mining feasibility result from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Merkle-Damgård Length Extension Immunity

**Conjecture**: The tropical Merkle-Damgård chain MD(iv, blocks, p) with compression Compress(s, b) = min(s, (s+b) mod p) is immune to length extension attacks. Formally: given MD(iv, m₁, p) = h, there does not exist a polynomial-time algorithm to compute MD(iv, m₁ ++ m₂, p) for arbitrary m₂ without knowledge of iv.

**Test**: Implement the tropical MD chain for p = 101, k = 10. Given h = MD(iv, m₁), attempt to compute MD(iv, m₁ ++ m₂) for random m₂ without iv. Measure success rate over 10,000 trials. Compare to classical MD which always succeeds (h acts as new IV).

**Impact**: Classical Merkle-Damgård is famously vulnerable to length extension attacks (SHA-256 suffers from this). If tropical MD is immune, it would demonstrate a structural advantage of tropical constructions over classical ones.

**Catalog References**: `Catalog/Cryptography/TropicalCryptoPrimitives.lean`, `Catalog/Tropical/HashInversion.lean`

**Proof Strategy**: The key insight is the monotonic descent property: MD(iv, blocks) ≤ iv. Since the attacker doesn't know iv, they cannot determine the state after m₁. The monotonic descent means the state space contracts, making length extension harder. Formalize as: the function h ↦ MD(h, m₂) is not injective on [0, p), so knowledge of h = MD(iv, m₁) does not uniquely determine MD(iv, m₁ ++ m₂).

**Domain Bridges**: Tropical Geometry <-> Cryptographic Protocol Design <-> Information Theory

**Lineage**: Builds on merkle_damgard_chain_le_iv and merkle_damgard_append from this cycle.

**Ambition**: extension

---

### Direction 3: Phase Transition in Tropical Mining Difficulty

**Conjecture**: For the NTSHA hash with modulus p and dimension k, there exists a critical target value t* ≈ p/(k+1) such that for t > t* + O(p/k²), mining succeeds in expected O(1) attempts, while for t < t* − O(p/k²), mining requires expected Ω(p^k) attempts. The transition width scales as Θ(p/k²).

**Test**: For p = 1000 and k = 5, 10, 20, 50, compute the empirical mining success probability as a function of target t. Plot the success curve and measure the width of the transition from "easy" (>50% success per attempt) to "hard" (<1% success per attempt). Verify the predicted critical point t* = p/(k+1) and transition width scaling.

**Impact**: A sharp phase transition would enable optimal difficulty calibration for tropical proof-of-work systems. The width of the transition determines how precisely difficulty must be set — a narrow transition means the system is sensitive to parameter changes, while a broad transition gives more robustness.

**Catalog References**: `Catalog/Tropical/Applications.lean`, `Catalog/Cryptography/TropicalCryptocurrencyMining.lean`

**Proof Strategy**: Use the exact counting formula count_min_at_least to derive the CDF of the hash output. Apply Stirling-type approximations to the sum E[min] = Σ ((N-t)/N)^k to locate the critical point. Bound the transition width using concentration inequalities for sums of geometric-like terms.

**Domain Bridges**: Probability Theory <-> Tropical Geometry <-> Protocol Economics

**Lineage**: Builds on count_min_at_least and mining_probability_monotone from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Collision Geometry and Random Graph Structure

**Conjecture**: For the NTSHA hash with modulus p and dimension k, define the collision graph G(p,k) on vertex set {0,...,p-1}^k where (m₁, m₂) is an edge iff NTSHA(m₁, k_fixed, p) = NTSHA(m₂, k_fixed, p). Then G(p,k) has connected components whose size distribution follows a power law with exponent −3/2, analogous to random graph percolation near criticality.

**Test**: For p = 31 and k = 3, construct the full collision graph. Compute connected component sizes and fit to a power law. Compare exponent to −3/2. Repeat for p = 37, 41 to check universality.

**Impact**: If the collision graph has random-graph structure, this would connect tropical hash security to percolation theory and random graph theory. The exponent −3/2 would indicate that the collision structure is in the same universality class as Erdős-Rényi random graphs at criticality, suggesting that tropical hash collisions are as hard to exploit as random collisions.

**Catalog References**: `Catalog/Cryptography/TropicalCryptoBridge.lean`, `Catalog/Tropical/AdvancedTheory.lean`

**Proof Strategy**: Model NTSHA as a random function and apply results from random graph theory. The modular reduction acts as a mixing operation that should produce pseudorandom collision structure. The key lemma would be that for random keys, NTSHA is pairwise independent (or close to it), which implies Erdős-Rényi-like behavior.

**Domain Bridges**: Tropical Geometry <-> Random Graph Theory <-> Statistical Physics

**Lineage**: Builds on collision_pigeonhole and collision_shift_invariant from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Tropical Homomorphic Properties of NTSHA

**Conjecture**: Define the "tropical ciphertext space" as ℤ_p^k with componentwise tropical operations modulo p. The NTSHA hash is NOT homomorphic: NTSHA(m₁ ⊕ m₂, k, p) ≠ NTSHA(m₁, k, p) ⊕ NTSHA(m₂, k, p) in general, where ⊕ is componentwise tropical addition (min) modulo p. However, there exists a modified construction NTSHA'(m, k, p) that IS additively homomorphic while retaining preimage resistance.

**Test**: For p = 97, k = 5, sample 1000 random message pairs and verify that NTSHA is not homomorphic. Then construct NTSHA' candidates and test both homomorphism and preimage resistance.

**Impact**: A homomorphic tropical hash would enable verifiable tropical computation — checking that a computation was performed correctly without revealing the inputs. This would connect to the tropical homomorphic encryption work in `Catalog/Cryptography/TropicalHomomorphicEncryption.lean`.

**Catalog References**: `Catalog/Cryptography/TropicalHomomorphicEncryption.lean`, `Catalog/Cryptography/TropicalHomomorphic.lean`

**Proof Strategy**: For the non-homomorphism of NTSHA, construct explicit counterexamples (similar to mod_breaks_shift_structure). For the existence of NTSHA', explore constructions based on tropical matrix multiplication rather than scalar operations — the matrix structure may provide enough algebraic compatibility for homomorphism.

**Domain Bridges**: Tropical Algebra <-> Homomorphic Encryption <-> Verifiable Computation

**Lineage**: Builds on mod_breaks_shift_structure and the NTSHA definition from this cycle.

**Ambition**: extension
