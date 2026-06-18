# Future Directions: Tropical Cryptography Research Program

## Overview

This document outlines five breakthrough-level research directions opened by the formalization of tropical (min-plus) public-key cryptography. Each direction includes specific conjectures, proof strategies, cross-domain connections, and concrete next steps.

---

## Direction 1: Formal NP-Hardness of Tropical Matrix Factorization

### The Problem
Establish that the tropical matrix factorization problem — given K ∈ (ℕ∞)^{n×n}, find A, B such that tropMul A B = K — is NP-hard under many-one (Karp) reductions.

### Conjecture
**Conjecture 1.1**: The decision problem "Given K and a threshold t, does there exist A, B with tropMul A B = K and A(0,0) ≤ t?" is NP-complete.

### Proof Strategy
1. **Reduce from Shortest Path with Forbidden Pairs**: This problem (known to be NP-hard) asks: given a graph and pairs of vertices that cannot both appear on a path, find a shortest path avoiding all forbidden pairs. Encode the forbidden-pair constraints as tropical matrix factorization constraints.
2. **Reduce from 3-Partition**: The entries of the factorization matrices must "partition" the path-cost budget among intermediate vertices, analogous to 3-Partition.
3. **Alternative**: Reduce from the Assignment Problem with precedence constraints, which is NP-hard and naturally maps to tropical matrix structure.

### Key Lemmas Needed
- `karp_reduction_forbidden_pairs_to_trop_factor`: A computable function from Shortest-Path-with-Forbidden-Pairs instances to tropical factorization instances, preserving YES/NO.
- `trop_factor_in_NP`: A certificate (A, B) can be verified in polynomial time (tropMul is O(n³)).
- `forbidden_pairs_is_NP_hard`: Standard NP-hardness result (from Gabow et al., 1976).

### Candidate Lean Files
- `Cryptography/TropicalNPHardness.lean`
- `Cryptography/KarpReductions.lean`

### Cross-Domain Connections
- **Computational Complexity → Cryptography**: First formal Cook/Karp reduction linking tropical algebra to classical complexity classes.
- **Operations Research → Security**: Scheduling/routing hardness results transfer to cryptographic hardness.

---

## Direction 2: Tropical ElGamal KEM and Standardization

### The Problem
Package the tropical Diffie-Hellman key exchange into a Key Encapsulation Mechanism (KEM) suitable for NIST-style standardization, with CCA2 security via the Fujisaki-Okamoto transform.

### Conjecture
**Conjecture 2.1**: The Fujisaki-Okamoto transform applied to the tropical ElGamal scheme yields a CCA2-secure KEM, assuming the tropical DDH problem is hard and a random oracle exists.

### Proof Strategy
1. **Define TropicalKEM**: Encapsulate the tropical shared secret as a symmetric key, using a hash function for key derivation.
2. **Apply FO Transform**: The standard FO transform (Hofheinz-Hövelmanns-Kiltz variant) converts CPA-secure PKE to CCA2-secure KEM. Verify that tropical ElGamal satisfies the required structural properties: correctness, γ-spreadness (the ciphertext has sufficient entropy).
3. **Prove γ-spreadness**: Show that tropical ciphertexts have high min-entropy, using the non-commutativity and dimension bounds already established.

### Key Lemmas Needed
- `tropical_gamma_spread`: For random r, the distribution of (tropPow G r, tropMul (tropPow (tropPow G a) r) M) has min-entropy ≥ γ.
- `fo_transform_cca2`: Generic FO transform theorem (may need to be formalized from scratch).
- `tropical_kem_correctness`: The KEM decapsulation recovers the encapsulated key.
- `tropical_kem_cca2_security`: The full CCA2 security theorem.

### Candidate Lean Files
- `Cryptography/TropicalKEM.lean`
- `Cryptography/FujisakiOkamoto.lean`

### Cross-Domain Connections
- **Standardization → Deployment**: A formally verified KEM with concrete security bounds could be submitted to future NIST post-quantum rounds.
- **Symmetric Cryptography → Tropical**: The key derivation step connects tropical hardness to symmetric-key security.

---

## Direction 3: Zero-Knowledge Proofs for Tropical Path Witnesses

### The Problem
Construct zero-knowledge proof systems for the following language: "I know matrices A, B such that tropMul A B = K" (equivalently: "I know a set of shortest-path witnesses in a layered graph").

### Conjecture
**Conjecture 3.1**: There exists an honest-verifier zero-knowledge proof of knowledge for tropical matrix factorization with communication complexity O(n² log B) and soundness error 1/2 per round.

### Proof Strategy
1. **Commitment-based protocol**: The prover commits to A and B using a binding commitment scheme. The verifier challenges with a random row index i. The prover reveals row i of A and the corresponding column contributions to K, allowing the verifier to check consistency without learning the full matrices.
2. **Sigma protocol structure**: Commit → Challenge → Response. Prove honest-verifier zero-knowledge by simulation. Prove special soundness by extraction.
3. **Tropical-specific optimization**: The min-plus structure allows a more efficient protocol: the prover can commit to the "argmin witnesses" (which k achieves the minimum for each (i,j)) rather than the full matrices.

### Key Lemmas Needed
- `tropical_zkp_completeness`: An honest prover always convinces the verifier.
- `tropical_zkp_soundness`: A cheating prover is caught with probability ≥ 1/2.
- `tropical_zkp_zero_knowledge`: The verifier's view can be simulated without the witness.
- `tropical_zkp_knowledge_extraction`: From two accepting transcripts with different challenges, one can extract A and B.

### Candidate Lean Files
- `Cryptography/TropicalZeroKnowledge.lean`
- `Cryptography/SigmaProtocol.lean`

### Cross-Domain Connections
- **Graph Theory → ZK Proofs**: Path witnesses in layered graphs become the "knowledge" being proved.
- **Blockchain → Tropical**: ZK proofs for tropical facts could enable privacy-preserving routing or scheduling protocols.

---

## Direction 4: Entropy Amplification for Tropical Shared Secrets

### The Problem
Prove that the min-entropy of the tropical shared secret G^(ab) grows with the matrix dimension n and the exponent size, providing quantitative security guarantees via the Leftover Hash Lemma.

### Conjecture
**Conjecture 4.1**: For random a, b uniformly chosen from {1, ..., 2^κ} and G a random n×n matrix with entries in {0, ..., B}, the min-entropy of tropPow G (a·b) satisfies:

    H_∞(tropPow G (a·b) | G) ≥ c · n² · log₂(B+1) - o(n²)

for an absolute constant c > 0.

### Proof Strategy
1. **Lower bound via collision probability**: Show that Pr[tropPow G (a₁·b₁) = tropPow G (a₂·b₂)] is small by analyzing when two different exponent products yield the same tropical power.
2. **Use tropical rank**: The tropical rank of G^m grows with m (up to n), and matrices of high tropical rank have large image sets under tropical powering.
3. **Connect to orbit structure**: The orbit {G, G², G³, ...} in tropical matrix space has size related to the tropical spectral radius, providing entropy bounds.
4. **Apply the existing `post_quantum_key_security_from_minEntropy`** to convert the entropy lower bound into a semantic security statement.

### Key Lemmas Needed
- `tropical_collision_probability_bound`: Upper bound on Pr[G^a = G^b] for random a ≠ b.
- `tropical_rank_growth`: tropRank(tropPow G m) is non-decreasing in m.
- `tropical_orbit_size_lower_bound`: |{tropPow G m : 0 ≤ m ≤ T}| ≥ f(n, B, T).
- `tropical_min_entropy_lower_bound`: The main entropy bound.
- `tropical_hashed_key_security`: Applying LHL to derive a key with negligible statistical distance to uniform.

### Candidate Lean Files
- `Cryptography/TropicalEntropy.lean`
- `Cryptography/TropicalRankTheory.lean`

### Cross-Domain Connections
- **Information Theory → Cryptography**: Min-entropy bounds provide quantitative security guarantees.
- **Tropical Geometry → Entropy**: The geometry of tropical orbits determines the entropy of shared secrets.
- **Optimization → Randomness**: The degree of freedom in shortest-path witnesses contributes to entropy.

---

## Direction 5: Cryptanalysis via Tropical Rank and Residuation

### The Problem
Systematically study attacks on tropical cryptographic schemes using tools from tropical linear algebra, particularly tropical rank, residuation (the right adjoint of tropical multiplication), and the tropical eigenvalue problem.

### Conjecture
**Conjecture 5.1**: If the tropical rank of G is less than n/2, then the tropical DLP for G can be solved in polynomial time using tropical rank decomposition.

**Conjecture 5.2**: If the tropical rank of G equals n (generic case), then no polynomial-time algorithm solves the tropical DLP.

### Proof Strategy
1. **Low-rank attack**: If G has tropical rank r < n, then G can be written as a tropical product of an n×r and an r×n matrix. This decomposition reveals structural information about G^a, potentially allowing recovery of a.
2. **Residuation attack**: The residual A\B (largest X with A⊗X ≤ B) can be computed in polynomial time. Investigate whether iterating residuation operations can recover factorization witnesses.
3. **Eigenvalue attack**: The tropical eigenvalue λ of G satisfies G^n[i,i] = n·λ for all i (Cuninghame-Green theorem). If λ can be computed efficiently, it constrains the exponent a.
4. **Defend via parameter selection**: Use the attack analysis to establish minimum parameter requirements (dimension, entry bound, tropical rank) for security.

### Key Lemmas Needed
- `tropical_rank_decomposition`: If tropRank(G) = r, compute G = P ⊗ Q with P : n×r, Q : r×n.
- `residual_computable`: The residual A\B is computable in O(n³).
- `low_rank_dlp_attack`: If tropRank(G) < n/2, recover a from (G, G^a) in poly time.
- `generic_rank_hardness`: If tropRank(G) = n, no known poly-time attack exists (conditional).
- `tropical_security_parameter_lower_bound`: Updated dimension bounds incorporating rank constraints.

### Candidate Lean Files
- `Cryptography/TropicalCryptanalysis.lean`
- `Cryptography/TropicalRank.lean`
- `Cryptography/TropicalResiduation.lean`

### Cross-Domain Connections
- **Tropical Linear Algebra → Security**: Rank and residuation theory directly inform parameter selection.
- **Combinatorial Optimization → Attack Complexity**: The complexity of computing tropical rank determines the feasibility of rank-based attacks.
- **Control Theory → Cryptanalysis**: Tropical eigenvalues arise in control theory (cycle time of discrete event systems), and the same theory constrains cryptographic exponents.

---

## Summary Table

| Direction | Difficulty | Impact | Dependencies | Timeline |
|:----------|:----------|:-------|:-------------|:---------|
| 1. NP-Hardness | Very High | Foundational | Complexity theory formalization | 6-12 months |
| 2. KEM/Standardization | High | Practical | FO transform formalization | 3-6 months |
| 3. Zero-Knowledge | High | Theoretical | Sigma protocol framework | 4-8 months |
| 4. Entropy Amplification | Medium-High | Security | Tropical rank theory | 3-6 months |
| 5. Cryptanalysis | Medium | Security | Tropical linear algebra | 2-4 months |

**Recommended order**: 5 → 4 → 2 → 3 → 1 (cryptanalysis first to validate parameters, then entropy bounds, then packaging for deployment, then advanced theoretical results).

---

## Team Structure

- **Tropical Algebra Team**: Focus on Directions 4 and 5. Expertise in tropical geometry, combinatorial optimization, and lattice theory.
- **Cryptography Engineering Team**: Focus on Direction 2. Expertise in KEM design, NIST submission requirements, and side-channel analysis.
- **Formal Verification Team**: Focus on Directions 1 and 3. Expertise in Lean 4, proof automation, and complexity theory formalization.
- **Cryptanalysis Red Team**: Continuous adversarial analysis across all directions. Attempt to break proposed schemes and identify parameter weaknesses.

Each team should maintain a shared knowledge base of tropical algebraic identities, attack strategies, and verified lemmas, updated after each research cycle.
