# Future Research Directions

## Synthesis

This research cycle established the theory of **nonlinear tropical hash functions** through the introduction of NTSHA — the Nonlinear Tropical Secure Hash Algorithm, which augments the standard tropical hash TSHA(m, h) = min_i(m_i + h_i) with modular reduction: NTSHA_p(m, h) = min_i((m_i + h_i) mod p). The central discovery is that this simple modification breaks the shift equivariance that makes TSHA cryptographically trivial, while introducing a periodic lattice structure in preimage fibers that connects tropical hashing to lattice-based post-quantum cryptography.

The most promising cross-domain connection is between **tropical fiber geometry** and **lattice cryptography**. The fiber periodicity theorem shows that NTSHA preimage sets are unions of cosets of the sublattice (pℤ)^k ⊂ ℤ^k. If finding short representatives in these coset structures can be reduced to the Shortest Vector Problem (SVP) or Learning With Errors (LWE), then NTSHA would inherit the conjectured post-quantum hardness of these problems. This connects to the Catalog's existing work in `Cryptography/TropicalOneWayFoundations.lean` (tropical matrix one-way functions), `Cryptography/TropicalPostQuantum.lean` (post-quantum tropical primitives), and `Cryptography/TropicalGammaSpread.lean` (tropical security scaling).

The highest breakthrough potential lies in **Direction 1** (Tropical-Lattice Security Reduction), because a formal reduction from NTSHA inversion to SVP would be the first rigorous post-quantum security guarantee for any tropical cryptographic primitive. The avalanche deficiency identified in this cycle (Direction 3) also represents a fundamental barrier that must be overcome — or worked around — for practical applications.

---

### Direction 1: Tropical-Lattice Security Reduction for NTSHA Preimage Problems

**Conjecture**: For prime p and dimension k, finding a short preimage m ∈ ℤ^k (with ‖m‖_∞ ≤ B) such that NTSHA_p(m, h) = y is at least as hard as solving the Bounded Distance Decoding (BDD) problem on the lattice (pℤ)^k with target determined by y and h. Formally: there exists a polynomial-time reduction from BDD_{(pℤ)^k, r} to NTSHA-Preimage_{p,k,B} for appropriate r = r(p, k, B).

**Test**: Implement both NTSHA preimage search and BDD on (pℤ)^k lattices for p = 23, k = 10. Time both problems for increasing B. If NTSHA preimage search is consistently faster than BDD by more than a polynomial factor, the reduction cannot exist in the stated direction.

**Impact**: If true, this would be the first rigorous post-quantum security guarantee for a tropical cryptographic primitive, connecting the min-plus world to the well-studied lattice hardness landscape. If false, the failure would reveal structural differences between tropical fiber geometry and lattice geometry that could guide the design of harder tropical constructions.

**Catalog References**: `Cryptography/TropicalOneWayFoundations.lean`, `Cryptography/TropicalPostQuantum.lean`, `Cryptography/TropicalGammaSpread.lean`

**Proof Strategy**: (1) Formalize the BDD problem on (pℤ)^k. (2) Show that any NTSHA preimage in the fundamental domain [0,p)^k corresponds to a lattice point close to a target determined by y and h. (3) Prove that the modular constraints create enough "noise" that the closest lattice point problem is non-trivial. Key lemma: the NTSHA fiber within [0,p)^k is a tropical polyhedron whose vertices are determined by the achievability condition (m_j + h_j) mod p = y.

**Domain Bridges**: Tropical Geometry <-> Lattice Cryptography <-> Post-Quantum Security

**Lineage**: Builds on `modular_fiber_periodic` and `ntsha_fiber_characterization` from this cycle, and `tropical_security_scaling` from `TropicalGammaSpread.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Iterated NTSHA with Key Schedules and Mixing Properties

**Conjecture**: Define the iterated NTSHA as F^(r)(m, h₁, ..., h_r) where F^(1)(m, h₁) = NTSHA_p(m, h₁) and F^(r+1) applies NTSHA_p with key h_{r+1} to the expanded output of F^(r). For r ≥ log₂(p) rounds with pseudorandom key schedule h₁, ..., h_r, the output distribution of F^(r) on uniform inputs is within statistical distance ε = 2^{-Ω(r)} of the uniform distribution on {0, ..., p-1}.

**Test**: For p = 31, k = 8, compute the output distribution of F^(r) for r = 1, 2, 4, 8, 16 rounds over 10^6 random inputs. Measure the total variation distance from uniform. If the distance does not decrease exponentially in r, the conjecture is falsified.

**Impact**: If true, iterated NTSHA achieves pseudorandom output — overcoming the avalanche deficiency of single-round tropical hashing. This would make tropical hash functions practically viable for lightweight cryptographic applications. If false, it reveals a fundamental barrier in the mixing capacity of min-plus operations.

**Catalog References**: `Cryptography/TropicalCryptocurrencyMining.lean` (hash chain dynamics), `Cryptography/TropicalNonlinearHash.lean` (hash iteration monotonicity)

**Proof Strategy**: (1) Analyze the Markov chain defined by NTSHA key rotation on {0,...,p-1}. (2) Show the transition matrix is doubly stochastic for uniform keys. (3) Bound the spectral gap using the coupling method. Key insight: the min operation is an order-preserving contraction on {0,...,p-1}, so the Markov chain mixes by "collapsing" the state space. The modular reduction provides the expansion needed to prevent trivial convergence to 0.

**Domain Bridges**: Tropical Algebra <-> Markov Chain Mixing <-> Pseudorandom Generators

**Lineage**: Builds on `hash_iterate_monotone`, `hash_iterate_terminal`, and `ntsha_output_bounded` from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical Avalanche Amplification via Polynomial Composition

**Conjecture**: Define the tropical polynomial hash TPH_d(m, h, a) = min_{i,j} (a_{ij} · (m_i + h_i)^j mod p) where the minimum is over i ∈ {1,...,k} and j ∈ {0,...,d} and a_{ij} are key coefficients. For degree d ≥ 2, TPH_d achieves superlinear avalanche: there exists a constant C > 0 such that for generic keys, a unit perturbation Δm_i = 1 causes output change ≥ C · d.

**Test**: For p = 101, k = 5, d = 2, 3, 4, 5, compute the average output change from single-coordinate unit perturbations over 10^5 random (m, h, a) triples. Plot average change vs. d. If the relationship is sublinear, the conjecture is falsified.

**Impact**: If true, tropical polynomial hashing overcomes the fundamental avalanche deficiency of linear tropical hashing (Theorem 7.1 from this cycle), opening the door to tropical hash functions with genuine cryptographic avalanche properties. If false, it establishes that min-plus operations have an inherent avalanche ceiling, regardless of composition degree.

**Catalog References**: `Cryptography/TropicalNonlinearHash.lean` (avalanche bound theorems), `Tropical/FormulaDefinability.lean`

**Proof Strategy**: (1) Define tropical polynomial evaluation formally. (2) For degree d = 2, analyze (m_i + h_i)^2 mod p: a unit change Δm = 1 gives Δ(m+h)^2 = 2(m+h) + 1, which is generically ≥ 2 for large p. (3) Prove that the minimum over multiple polynomial terms preserves superlinear sensitivity with positive probability. Key obstacle: the min operation can always "mask" the perturbed coordinate if another coordinate achieves a smaller value.

**Domain Bridges**: Tropical Polynomial Algebra <-> Cryptographic Avalanche Theory <-> Nonlinear Dynamics

**Lineage**: Builds on `tropical_avalanche_nonneg_increase` and `avalanche_exact_dim1` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Tropical Merkle Tree Security and Length Extension Resistance

**Conjecture**: The tropical Merkle tree construction (using NTSHA at each node) is vulnerable to a length extension attack: given NTSHA_p(m₁ ‖ m₂, h₁ ‖ h₂) = v, an attacker can compute NTSHA_p(m₁ ‖ m₂ ‖ m₃, h₁ ‖ h₂ ‖ h₃) = min(v, NTSHA_p(m₃, h₃)) without knowing m₁ or m₂, using only v and h₃. Formally: the concatenation decomposition theorem enables length extension.

**Test**: Implement a length extension oracle: given only v (the hash of an unknown message) and a new key block h₃, compute the hash of the extended message. Verify that the oracle is correct for 1000 random (m₁, m₂, m₃, h₁, h₂, h₃) tuples.

**Impact**: If true (which we expect), this identifies a concrete attack on tropical Merkle-Damgård, motivating the design of tropical hash constructions resistant to length extension (e.g., tropical sponge constructions). If the attack can be formalized and then a resistant construction proved secure, this would be a complete security analysis.

**Catalog References**: `Cryptography/TropicalNonlinearHash.lean` (ntsha_concat_decomposition), `Cryptography/TropicalCryptocurrencyMining.lean` (tropicalMerkle*)

**Proof Strategy**: The proof follows directly from `ntsha_concat_decomposition`: NTSHA_p(m₁‖m₂‖m₃, h₁‖h₂‖h₃) = min(NTSHA_p(m₁‖m₂, h₁‖h₂), NTSHA_p(m₃, h₃)) = min(v, NTSHA_p(m₃, h₃)). The attacker needs only v and h₃. Define a tropical sponge construction that absorbs message blocks through a state update that is NOT simply min, preventing the decomposition. Prove the sponge construction does not satisfy concatenation decomposition.

**Domain Bridges**: Tropical Hash Functions <-> Sponge Constructions <-> Protocol Security

**Lineage**: Builds on `ntsha_concat_decomposition` and the Merkle idempotency observation from TropicalCryptocurrencyMining.lean.

**Ambition**: extension

---

### Direction 5: Statistical Distribution of NTSHA Values and Mining Difficulty Calibration

**Conjecture**: For NTSHA_p with uniformly random m, h ∈ {0,...,N}^k where N ≫ p, the hash value V = NTSHA_p(m, h) satisfies P(V = j) = (1 - j/p)^k - (1 - (j+1)/p)^k for j = 0, 1, ..., p-1. In particular, P(V = 0) = 1 - (1 - 1/p)^k ≈ 1 - e^{-k/p} for large p.

**Test**: For p = 31, k = 10, N = 10000, sample 10^6 random (m, h) pairs and compute the empirical distribution of NTSHA values. Compare with the predicted distribution. If the maximum absolute deviation exceeds 3/√(10^6) ≈ 0.003, the conjecture is falsified (at 3-sigma level).

**Impact**: If true, this provides the calibration theory needed for tropical mining difficulty: setting target t means the probability of a random nonce achieving the target is P(V ≤ t) = 1 - (1 - (t+1)/p)^k. This determines the expected number of mining attempts and hence the economic cost of tropical proof-of-work. If false, the true distribution would reveal non-uniformity in the modular reduction that could be exploited.

**Catalog References**: `Cryptography/TropicalCryptocurrencyMining.lean` (mining difficulty, concentration conjecture), `Cryptography/TropicalEntropy.lean`

**Proof Strategy**: (1) Show that for uniform m_i, h_i ∈ {0,...,N}, the sum S_i = m_i + h_i is approximately uniform on {0,...,2N}. (2) Then S_i mod p is approximately uniform on {0,...,p-1} when N ≫ p. (3) The minimum of k independent uniform-on-{0,...,p-1} random variables has CDF 1 - ((p-j)/p)^k. (4) The PMF follows by differencing. Key lemma: quantify the approximation error from step (2) using the discrepancy bound |P(S mod p = j) - 1/p| ≤ 1/(N+1).

**Domain Bridges**: Tropical Hash Functions <-> Order Statistics <-> Proof-of-Work Economics

**Lineage**: Builds on the concentration conjecture from `TropicalCryptocurrencyMining.lean` and `ntsha_output_bounded` from this cycle.

**Ambition**: extension
