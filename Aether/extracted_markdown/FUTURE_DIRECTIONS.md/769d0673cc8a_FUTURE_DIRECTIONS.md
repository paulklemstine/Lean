# Future Research Directions: Quantum Error Correction Bounds

## Synthesis

This research cycle established a comprehensive formal framework for quantum error-correcting code bounds, unifying the Singleton, Hamming, Gilbert-Varshamov, BPT, and Plotkin bounds with entanglement-assisted extensions. The most significant finding is the clean quantification of entanglement's value: each ebit relaxes the Singleton bound by exactly one unit, improving maximum distance by 1/2. This creates a precise "exchange rate" between entanglement and error correction capability.

The most promising cross-domain connection is between the **BPT topological bounds** and **algebraic code constructions**. The toric code saturates the 2D BPT bound (kd² = n), and the recently discovered good quantum LDPC codes bypass it by not being geometrically local. Formalizing the transition from local to non-local codes — and understanding which algebraic structures enable it — could unify topological and algebraic approaches to quantum coding theory.

The framework built in this cycle (QStabCode, EACode, TopoCode, WeightEnumerator, CodeFamily structures) provides a foundation for all future directions. The key gap is the absence of concrete quantum LDPC code constructions in the formalization, which would connect to the Catalog's existing algebraic machinery.

---

### Direction 1: Quantum MacWilliams Identities and Shadow Enumerators

**Conjecture**: The quantum MacWilliams identity relates a code's weight enumerator A(x,y) to its shadow enumerator B(x,y) via a specific linear transformation involving Krawtchouk polynomials. Formally: B_j = (1/K) Σ_i A_i · P_j(i; n) where P_j is the Krawtchouk polynomial and K = 2^k. The shadow enumerator B satisfies B_0 = 1 and B_j ≥ 0 for all j, and these non-negativity constraints provide *tighter* bounds on code parameters than the Singleton bound alone.

**Test**: For the [[5,1,3]] code, compute A = (1, 0, 0, 15, 0, 0) → derive B via MacWilliams transform → verify B ≥ 0 and that the resulting LP bound matches the Singleton bound. Then find (n,k) pairs where the LP bound from MacWilliams is strictly tighter than Singleton.

**Impact**: If the LP bound is strictly tighter, it identifies parameter regimes where no quantum code exists despite satisfying all known algebraic bounds. This would close open existence questions for specific (n,k,d) triples.

**Catalog References**: `Catalog/Physics/QuantumMacWilliams/Krawtchouk.lean`, `Catalog/Physics/QuantumMacWilliams/WeightEnumerator.lean`

**Proof Strategy**: (1) Formalize Krawtchouk polynomials as functions ℕ → ℕ → ℤ. (2) Define the MacWilliams transform as a matrix acting on weight enumerators. (3) Prove the transform is involutive up to scaling. (4) Derive non-negativity constraints on B. (5) Show these constraints imply known bounds in special cases.

**Domain Bridges**: Algebra (Krawtchouk polynomials, orthogonality) <-> Physics (quantum codes) <-> Computation (LP relaxation algorithms)

**Lineage**: Builds on `WeightEnumerator` structure and `hasDistance` property from this cycle's `Physics/QuantumCodeBounds.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Degenerate Codes Beyond the Hamming Bound

**Conjecture**: There exists a degenerate stabilizer code [[n, 1, d]] for some specific (n, d) where the quantum Hamming volume V_q(n, ⌊(d-1)/2⌋) > 2^{n-1} — i.e., a code whose parameters violate the quantum Hamming bound that would constrain any nondegenerate code. The smallest candidate is [[13, 1, 5]] where V_q(13, 2) = 1 + 39 + 468 = 508 and 2^12 = 4096, so the Hamming bound is far from tight; we need to look at [[n, 1, d]] with larger d/n ratio.

**Test**: Compute V_q(n, t) and 2^{n-1} for all n ≤ 50 and find the smallest n where there exists d such that (a) k + 2d ≤ n + 2 is satisfied (Singleton), (b) the Hamming bound V_q(n,t) ≤ 2^{n-1} is violated, and (c) construct an explicit degenerate code with these parameters using stabilizer group enumeration.

**Impact**: Proving the existence (or impossibility) of Hamming-bound-violating degenerate codes would resolve a 25-year-old open question in quantum coding theory. A positive result would demonstrate that degeneracy is a genuinely stronger resource than nondegeneracy.

**Catalog References**: `Catalog/Physics/StabilizerBounds.lean` (NondegenerateCode structure, hamming bound)

**Proof Strategy**: (1) Systematically compute V_q(n, t) for candidate parameters. (2) For candidates satisfying Singleton but violating Hamming, attempt explicit construction of stabilizer groups. (3) Formalize the construction and verify distance via weight analysis.

**Domain Bridges**: Algebra (symplectic geometry over F₂) <-> Physics (degenerate quantum codes) <-> Computation (exhaustive search)

**Lineage**: Builds on `shor_degeneracy` theorem showing the Shor code uses only 11% of syndromes.

**Ambition**: grand_challenge

---

### Direction 3: Good Quantum LDPC Codes and BPT Bypass

**Conjecture**: The recently discovered Panteleev-Kalachev (2022) and Leverrier-Zémor (2022) quantum LDPC codes achieve constant rate R > 0 and growing distance d = Θ(n^α) for some α > 0, bypassing the 2D BPT bound kd² ≤ n. Formalizing these constructions requires: (1) defining LDPC parity check matrices over F₂, (2) proving the minimum distance grows polynomially, (3) proving the rate is bounded away from 0.

**Test**: For a specific construction (e.g., Sipser-Spielman expander codes adapted to the quantum setting), verify that for n ≤ 1000, the code family achieves k ≥ n/10 and d ≥ n^{0.1}, which would violate kd² ≤ n for sufficiently large n.

**Impact**: Formalizing the first good quantum LDPC code would be a landmark result, bridging expander graph theory and quantum coding theory. It would demonstrate that geometric locality is the essential constraint, not quantum mechanics itself.

**Catalog References**: `Catalog/Physics/StabilizerBounds.lean` (BPT2D definition), `Catalog/Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: (1) Formalize bipartite expander graphs. (2) Define the hypergraph product construction. (3) Prove expansion implies minimum distance. (4) Prove the resulting code has constant rate. (5) Verify BPT violation.

**Domain Bridges**: Computation (expander graphs) <-> Physics (quantum LDPC codes) <-> Algebra (homological algebra of chain complexes)

**Lineage**: Builds on `BPT2D`, `TopoCode`, and `CodeFamily` structures from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Entanglement-Assisted Capacity and Catalytic Codes

**Conjecture**: For an EA code [[n, k, d; c]], the net information rate (k - c)/n satisfies a modified GV-type existence bound: codes with net rate R_net > 0 and distance d = Θ(n^{1/2}) exist for c = Θ(n). Moreover, when c = n - k (maximum entanglement), the EA-Singleton bound becomes d ≤ n + 1, and this is achievable — the *maximal entanglement EA code* achieves d = n + 1 for k = 0, c = n.

**Test**: For n = 7, k = 1, systematically compute d_max(c) for c = 0, 1, ..., 6 and verify the linear relationship d_max = ⌊(8+c)/2⌋. Then for c = 6: d_max = 7, check if an explicit EA [[7, 1, 7; 6]] code can be constructed.

**Impact**: Understanding the precise entanglement-distance tradeoff would quantify entanglement as a cryptographic resource. If the maximal-entanglement code exists, it provides a perfect quantum secret sharing scheme.

**Catalog References**: `Catalog/Physics/VonNeumannEntropy.lean` (entropy bounds), `Catalog/Physics/Entanglement.lean`

**Proof Strategy**: (1) Extend EACode structure with net rate. (2) Prove EA-GV bound existence. (3) Construct explicit maximal-entanglement codes. (4) Connect to quantum secret sharing via complementary access structures.

**Domain Bridges**: Physics (entanglement, QEC) <-> Cryptography (secret sharing, quantum key distribution) <-> Algebra (symplectic codes over F₂)

**Lineage**: Builds on `EACode`, `ea_requires_entanglement`, `ea_efficiency` from this cycle.

**Ambition**: extension

---

### Direction 5: Surface Code Threshold and Fault-Tolerant Overhead

**Conjecture**: The surface code [[2L²-2L+1, 1, L]] achieves a fault-tolerance threshold p_th ≈ 1% under depolarizing noise, and the logical error rate decays as p_L ∝ (p/p_th)^{L/2} below threshold. Formalizing this requires: (1) a noise model (depolarizing channel), (2) a decoder (minimum-weight perfect matching), (3) a threshold theorem relating physical and logical error rates.

**Test**: For L = 3, 5, 7, compute the logical error rate under depolarizing noise with p = 0.001 using Monte Carlo simulation, and verify the exponential decay p_L ∝ (p/p_th)^{L/2}. Verify that the overhead n/k = 2L²-2L+1 grows polynomially while the logical error rate decays exponentially.

**Impact**: A formal threshold theorem would connect discrete combinatorial code theory to continuous error rate analysis, bridging pure mathematics and practical quantum computing. It would provide certified guarantees for quantum computer architectures.

**Catalog References**: `Catalog/Physics/ToricCode.lean`, `Catalog/Physics/StabilizerBounds.lean`

**Proof Strategy**: (1) Formalize the depolarizing channel as a probability distribution over Pauli errors. (2) Define the minimum-weight perfect matching decoder. (3) Prove that below threshold, errors form short loops that the decoder corrects. (4) Use Peierls-type argument to bound the logical error rate.

**Domain Bridges**: Physics (noise models, fault tolerance) <-> Computation (MWPM algorithms, complexity) <-> Algebra (percolation theory)

**Lineage**: Builds on `surfaceN`, `surface_singleton`, `surface_bpt` from this cycle.

**Ambition**: extension
